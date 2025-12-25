namespace HushBindingGen;
using System;

enum ETypeKind {
	PRIMITIVE,
	STRUCT,
	ARRAY
}

enum ECType {
	VOID,
	INT8,
	INT16,
	INT32,
	INT64,
	UINT8,
	UINT16,
	UINT32,
	UINT64,
	FLOAT32,
	FLOAT64,
	BOOL8,
	STRUCT,
}

struct StructDescription {
	const int64 MAX_FIELD_NAME = 128;
	const int64 MAX_STRUCT_FIELDS = 64;
	public char8[MAX_FIELD_NAME] name;
	public Argument[MAX_STRUCT_FIELDS] fields;
	public uint64 size;
	public uint64 align;
}

struct TypeInfo {
	public ETypeKind kind;
	public ECType type;
	public uint8 pointerLevel;
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
	private EError TryParseStructField(ref StructDescription structDesc, StringView line) {
		
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
				index++;
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
