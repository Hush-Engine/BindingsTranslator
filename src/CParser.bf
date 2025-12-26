namespace HushBindingGen;
using System;

enum ETypeKind {
	PRIMITIVE,
	STRUCT,
	ARRAY
}

enum ECType {
	UNDEFINED,
	VOID = "void".Fnv1a(),
	INT8 = "int8_t".Fnv1a(),
	INT16 = "int16_t".Fnv1a(),
	INT32 = "int32_t".Fnv1a(),
	INT64 = "int64_t".Fnv1a(),
	UINT8 = "uint8_t".Fnv1a(),
	UINT16 = "uint16_t".Fnv1a(),
	UINT32 = "uint32_t".Fnv1a(),
	UINT64 = "uint64_t".Fnv1a(),
	FLOAT32 = "float".Fnv1a(),
	FLOAT64 = "double".Fnv1a(),
	BOOL8 = "bool".Fnv1a(),

	// Type equivalents (only here for string comparisons)
	INT = "int".Fnv1a(),
	CHAR = "char".Fnv1a(),
	UNSIGNED_LONG_LONG = "unsigned long long".Fnv1a(),
	
	STRUCT,
}

struct StructDescription {
	const int64 MAX_FIELD_NAME = 128;
	const int64 MAX_STRUCT_FIELDS = 64;
	public char8[MAX_FIELD_NAME] name;
	public Argument[MAX_STRUCT_FIELDS] fields;
	public uint32 fieldCount;
	public uint64 size;
	public uint64 align;
}

struct TypeInfo {
	public ETypeKind kind;
	public ECType type;
	public uint8 pointerLevel;
	public uint64 size;
}

struct Argument {
	const int64 MAX_FIELD_NAME = 128;
	public char8[MAX_FIELD_NAME] name;
	public TypeInfo typeInfo;
}

struct FunctionProps {
	// If we generate a fn name bigger than this, let's reflect
	const int64 MAX_FN_NAME = 1024;
	const int64 MAX_ARG_COUNT = 16;

	public char8[MAX_FN_NAME] name;
	public Argument[MAX_ARG_COUNT] args;
	public TypeInfo returnType;
}

class CParser {
	const int64 MAX_FIELD_NAME = 128;
	
	private bool IsValidIdentifierChar(char8 c) {
		return c.IsLetterOrDigit || c == '_';
	}

	private EError TryParseType(StringView typeString, ref TypeInfo typeInfo, bool countPtrLevel = false) {
		StringView strippedType = typeString.Strip();
		// We could have alignas or array types
		ECType hash = (ECType)strippedType.Fnv1a();
		switch (hash) {
		case ECType.VOID:
			typeInfo.type = ECType.VOID;
			break;
		case ECType.INT8:
			typeInfo.type = ECType.INT8;
			typeInfo.size = sizeof(int8);
			break;
		case ECType.INT16:
			typeInfo.type = ECType.INT16;
			typeInfo.size = sizeof(int16);
			break;
		case ECType.INT32:
			typeInfo.type = ECType.INT32;
			typeInfo.size = sizeof(int32);
			break;
		case ECType.INT64:
			typeInfo.type = ECType.INT64;
			typeInfo.size = sizeof(int64);
			break;
		case ECType.UINT8:
		case ECType.CHAR:
			typeInfo.type = ECType.UINT8;
			typeInfo.size = sizeof(uint8);
			break;
		case ECType.UINT16:
			typeInfo.type = ECType.UINT16;
			typeInfo.size = sizeof(uint16);
			break;
		case ECType.UINT32:
			typeInfo.type = ECType.UINT32;
			typeInfo.size = sizeof(uint32);
			break;
		case ECType.UNSIGNED_LONG_LONG:
		case ECType.UINT64:
			typeInfo.type = ECType.UINT64;
			typeInfo.size = sizeof(uint64);
			break;
		case ECType.FLOAT32:
			typeInfo.type = ECType.FLOAT32;
			typeInfo.size = sizeof(float);
			break;
		case ECType.FLOAT64:
			typeInfo.type = ECType.FLOAT64;
			typeInfo.size = sizeof(double);
			break;
		case ECType.BOOL8:
			typeInfo.type = ECType.BOOL8;
			typeInfo.size = sizeof(bool);
			break;
		case ECType.INT:
			typeInfo.type = ECType.INT;
			typeInfo.size = sizeof(int);
			break;
		
		default:
			typeInfo.type = ECType.STRUCT;
			typeInfo.kind = ETypeKind.STRUCT;
			break;
		}
		return EError.OK;
	}
	
	private EError TryParseStructField(ref StructDescription structDesc, StringView line) {
		// A struct field is whatever the first non whitespace word is, along with its pointer level
		// Run the array backwards to find all other info in one go
		
		// IMPORTANT: MISSING EDGE CASES (delete as we implement)
		// - alignas(n)
		// - Array types [] and [n]
		// - stdint
		// - _Bool
		// - Nested structs
		// - Types with multi-word names (i.e unsigned long long)

		if (line.Contains('}')) return EError.OK;

		bool nameIsSet = false;
		bool hasSemicolon = false;
		String wordBuffer = scope String(MAX_FIELD_NAME);
		// We assume the pointer level is simply the amount of times we see the '*' character in the string
		uint8 pointerLevel = 0;
		char8 prevChar = '\0';
		for (int i = line.Length - 1; i >= 0; i--) {
			if (line[i] == ';') {
				hasSemicolon = true;
			}
			bool shouldRecordWord = IsValidIdentifierChar(prevChar) || nameIsSet;
			if (shouldRecordWord) {
				// If we just started, let's append the previous char
				if (wordBuffer.IsEmpty) {
					wordBuffer.Insert(0, prevChar);
				}
				if (IsValidIdentifierChar(line[i])) {
					wordBuffer.Insert(0, line[i]);
				}
			}
			else if (!wordBuffer.IsEmpty) {
				// Identify our position, since we go backwards, we have name first, then type
				if (!nameIsSet) {
					StringView sv = wordBuffer;
					ref Argument field = ref structDesc.fields[structDesc.fieldCount];
					sv.CopyTo(field.name);
					structDesc.fieldCount++;
					nameIsSet = true;
				}
				else {
					// We have a type
					ref Argument field = ref structDesc.fields[structDesc.fieldCount];
					TryParseType(wordBuffer, ref field.typeInfo);
				}
				wordBuffer.Clear();
			}
			if (line[i] == '*') {
				pointerLevel++;
			}
			prevChar = line[i];
		}

		if (!hasSemicolon) {
			return EError.FORMAT_ERROR;
		}

		if (!wordBuffer.IsEmpty) {
			// We have a pending type
			ref Argument field = ref structDesc.fields[structDesc.fieldCount];
			TryParseType(wordBuffer, ref field.typeInfo);
		}
		return EError.OK;
	}
	
	/// @brief Parses a struct description, the string needs to be identified (from typedef struct to final enclosing curly bracket)
	public EError TryParseStruct(out StructDescription structDesc, StringView structRegion) {
		structDesc = StructDescription{};
		// typedef struct DVector4 {
		// 	double x;
		// 	double y;
		// 	double z; 
		// 	double w;
		// } DVector4;
		// Any given struct will be parsed by identifying the substr "typedef struct"
		uint32 index = 0;
		uint32 pendingBraces = 0;
		for (StringView part in structRegion.Split("\n")) {
			if (index != 0) {
				EError err = TryParseStructField(ref structDesc, part);
				index++;
				continue;
			}
			
			// Find substr and then name from that
			const String STRUCT_DECL = "typedef struct ";
			int indexBeforeWord = part.IndexOf(STRUCT_DECL);
			if (indexBeforeWord == -1) {
				Console.WriteLine("First line of struct declaration should match typedef struct ##name");
				return EError.FORMAT_ERROR;
			}
			int indexAfterWord = indexBeforeWord + STRUCT_DECL.Length;
			StringView rest = part.Substring(indexAfterWord);
			char8[] indexOptions = scope char8[](' ', '{');
			int lastIdx = rest.IndexOfAny(indexOptions);
			StringView name = rest.Substring(0, lastIdx);
			name.CopyTo(structDesc.name);
			index++;
		}

		return EError.OK;
	}
}
