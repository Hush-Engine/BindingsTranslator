namespace HushBindingGen;
using System;
using System.Collections;

enum ETypeKind {
	PRIMITIVE,
	STRUCT,
	ARRAY,
	FUNCTION_POINTER
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
	CHAR = "char".Fnv1a(),

	// Type equivalents (only here for string comparisons)
	INT = "int".Fnv1a(),
	UNSIGNED_LONG_LONG = "unsigned long long".Fnv1a(),
	_BOOL = "_Bool".Fnv1a(),
	
	STRUCT,
	FUNCTION_POINTER
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
	public bool isConstant;
	public uint64 align;
	public StringView structName;
}

struct Argument {
	const int64 MAX_FIELD_NAME = 128;
	public char8[MAX_FIELD_NAME] name;
	public TypeInfo typeInfo;
}

public enum EScopeType {
    Struct,
    Function,
    Unknown
}

public struct ParseRegion {
    public EScopeType type;
    public StringView content;
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

	private Dictionary<StringView, StructDescription> m_registeredStructsByName = new Dictionary<StringView, StructDescription>() ~ delete _;

	// A dictionary of all functions and function pointers
	public Dictionary<StringView, FunctionProps> m_functions = new Dictionary<StringView, FunctionProps>() ~ delete _;

	private Dictionary<String, Variant> m_defines = new Dictionary<String, Variant>() ~ delete _;

	private bool IsValidIdentifierChar(char8 c) {
		return c.IsLetterOrDigit || c == '_';
	}

	private bool FindNumberBetween(in StringView baseString, char8 opening, char8 closing, out uint64 number, int* startIndex) {
		let buffer = scope String(4);
		number = 0;
		bool inEnclosing = false;
		for (int i = 0; i < baseString.Length; i++) {
			if (baseString[i] == opening && !inEnclosing) {
				*startIndex = i;
				inEnclosing = true;
				continue;
			}
			if (!inEnclosing) continue;
			if (baseString[i] == closing) {
				inEnclosing = false;
				break;
			}
			buffer.Append(baseString[i]);
		}

		let parseRes = uint64.Parse(buffer);
		if (parseRes case .Err) {
			return false;
		}
		number = parseRes.Value;
		return true;
	}

	private StringView FindContentsInBetween(in StringView baseString, char8 opening, char8 closing, out int startIndex) {
		startIndex = 0;
		bool inEnclosing = false;
		int lastIndex = 0;
		for (int i = 0; i < baseString.Length; i++) {
			if (baseString[i] == opening && !inEnclosing) {
				startIndex = i;
				inEnclosing = true;
				continue;
			}
			if (!inEnclosing) continue;
			if (baseString[i] == closing) {
				inEnclosing = false;
				break;
			}
			lastIndex++;
		}

		return baseString.Substring(startIndex + 1, lastIndex);
	}

	public static uint64 GetSizeOf(ECType type) {
		switch (type) {
		case ECType.VOID:
			return 0;
		case ECType.INT8:
			return sizeof(int8);
		case ECType.INT16:
			return sizeof(int16);
		case ECType.INT:
		case ECType.INT32:
			return sizeof(int32);
		case ECType.INT64:
			return sizeof(int64);
		case ECType.CHAR:
			return sizeof(char8);
		case ECType.UINT8:
			return sizeof(uint8);
		case ECType.UINT16:
			return sizeof(uint16);
		case ECType.UINT32:
			return sizeof(uint32);
		case ECType.UNSIGNED_LONG_LONG:
		case ECType.UINT64:
			return sizeof(uint64);
		case ECType.FLOAT32:
			return sizeof(float);
		case ECType.FLOAT64:
			return sizeof(double);
		case ECType.BOOL8:
			return sizeof(bool);
		case ECType._BOOL:
			return sizeof(bool);
		case ECType.STRUCT:
			// this.m_registeredStructsByName.ContainsKey(str);
			return 0;
		case ECType.FUNCTION_POINTER:
			// NYI but we should
			return 0;
		default:
			return 0;
		}
		return 0;
	} 
	
	private bool IsTypeOrStruct(in StringView str) {
		ECType hash = (ECType)str.Fnv1a();
		switch (hash) {
		case ECType.VOID:
		case ECType.INT8:
		case ECType.INT16:
		case ECType.INT32:
		case ECType.INT64:
		case ECType.CHAR:
		case ECType.UINT8:
		case ECType.UINT16:
		case ECType.UINT32:
		case ECType.UNSIGNED_LONG_LONG:
		case ECType.UINT64:
		case ECType.FLOAT32:
		case ECType.FLOAT64:
		case ECType.BOOL8:
		case ECType._BOOL:
		case ECType.INT:
			return true;
		default:
			return this.m_registeredStructsByName.ContainsKey(str);
		}
		return false;
	}

	// Collects parse regions from a header file
	public EError SeparateScopes(StringView headerContent, ref List<ParseRegion> outRegions) {
	    StringView trimmed = headerContent.Strip();
    
	    uint32 currentPos = 0;
	    while (currentPos < trimmed.Length) {
	        StringView remaining = trimmed.Substring(currentPos);
        
	        // Skip whitespace
	        int firstNonWhitespace = 0;
	        for (char8 c in remaining) {
	            if (!c.IsWhiteSpace) break;
	            firstNonWhitespace++;
	        }
        
	        if (firstNonWhitespace >= remaining.Length) break;
        
	        remaining = remaining.Substring(firstNonWhitespace);
	        currentPos += (uint32)firstNonWhitespace;
        
	        // Check for struct definition
	        if (remaining.StartsWith("typedef struct")) {
	            // Find the closing brace and semicolon
	            int braceDepth = 0;
	            int endIdx = 0;
	            bool foundOpenBrace = false;
            
	            for (int i = 0; i < remaining.Length; i++) {
	                char8 c = remaining[i];
	                if (c == '{') {
	                    braceDepth++;
	                    foundOpenBrace = true;
	                } else if (c == '}') {
	                    braceDepth--;
	                    if (foundOpenBrace && braceDepth == 0) {
	                        // Find the semicolon after the closing brace
	                        for (int j = i + 1; j < remaining.Length; j++) {
	                            if (remaining[j] == ';') {
	                                endIdx = j + 1;
	                                break;
	                            }
	                        }
	                        break;
	                    }
	                }
	            }
            
	            if (endIdx == 0) {
	                Console.WriteLine("Malformed struct: no closing brace/semicolon found");
	                return EError.FORMAT_ERROR;
	            }
            
	            ParseRegion region = .() { type = .Struct, content = remaining.Substring(0, endIdx) };
	            outRegions.Add(region);
	            currentPos += (uint32)endIdx;
	        }
	        // Check for function declaration (extern or direct)
	        else if (remaining.StartsWith("extern") || IsLikelyFunctionSignature(remaining)) {
	            // Find the semicolon
	            int semiIdx = remaining.IndexOf(';');
	            if (semiIdx == -1) {
	                Console.WriteLine("Malformed function declaration: no semicolon found");
	                return EError.FORMAT_ERROR;
	            }
            
	            ParseRegion region = .() { type = .Function, content = remaining.Substring(0, semiIdx + 1) };
	            outRegions.Add(region);
	            currentPos += (uint32)semiIdx + 1;
	        }
	        else {
	            // Skip unknown content until next line
	            int nextLine = remaining.IndexOf('\n');
	            if (nextLine == -1) break;
	            currentPos += (uint32)nextLine + 1;
	        }
	    }
    
	    return EError.OK;
	}

	private bool IsLikelyFunctionSignature(in StringView content) {
		return false;
	}

	private bool TryParseFunctionPtr(in StringView str, out FunctionProps functionProps) {
		// First we identify if this even is a function ptr
		functionProps = FunctionProps();
		// A fn pointer is defined as ReturnType (*Name)(ArgType OptionalName, ArgType OptionalName ...);

		// First let's try to get the name of the function ptr
		int startIndex;
		StringView nameWithPtrIdentifier = this.FindContentsInBetween(str, '(', ')', out startIndex);
		if (nameWithPtrIdentifier.IsEmpty || nameWithPtrIdentifier[0] != '*') {
			return false; // Not a valid fn ptr
		}
		nameWithPtrIdentifier.Substring(1).CopyTo(functionProps.name);

		// Get the return type (start index of name - 1 due to opening parentheses)
		StringView retTypeStr = str.Substring(0, startIndex - 1).Strip();
		EError err = this.TryParseType(retTypeStr, ref functionProps.returnType, true);
		if (err != EError.OK) {
			return false;
		}

		// Then we get the list of arguments
		StringView argumentSignature = str.Substring(startIndex + nameWithPtrIdentifier.Length + 2);
		int _;
		argumentSignature = this.FindContentsInBetween(argumentSignature, '(', ')', out _);

		// Then we can maybe split by comma and parse the type one by one
		err = TryParseRawArgumentList(ref functionProps, argumentSignature);

		return err != EError.OK;
	}

	private EError TryParseRawArgumentList(ref FunctionProps functionProps, in StringView rawArgs) {
		int currentArgIdx = 0;
		for (StringView rawArg in rawArgs.Split(',')) {
			rawArg = rawArg.Strip();
			// There could or could not be a name for the argument here
			// A name would be the trailing non whitespace
			TypeInfo typeInfo = TypeInfo();
			int nameLength = rawArg.Length;
			int nameStartIdx = -1;
			for (int i = rawArg.Length - 1; i >= 0; i--) {
				if (!rawArg[i].IsLetterOrDigit) break;
				nameStartIdx = i;
			}

			if (nameStartIdx != -1) {
				nameLength -= nameStartIdx;
				StringView name = rawArg.Substring(nameStartIdx, nameLength);
				if (!this.IsTypeOrStruct(name)) {
					name.CopyTo(functionProps.args[currentArgIdx].name);				
					rawArg = rawArg.Substring(0, nameStartIdx);
				}
			}
			
			EError err = this.TryParseType(rawArg, ref typeInfo, true);
			if (err != EError.OK) {
				// Console.WriteLine($"Error parsing argument: {rawArg} of function pointer {nameWithPtrIdentifier}: {err}");
				Console.WriteLine($"Error parsing argument: {rawArg} of function: {err}");
				return err;
			}
			functionProps.args[currentArgIdx].typeInfo = typeInfo;
			currentArgIdx++;
		}
		return EError.OK;
	}

	private EError TryParseType(StringView typeString, ref TypeInfo typeInfo, bool countPtrLevel = false) {
		var typeString; // Mutable copy
		const String CONST_IDENTIFIER = "const";
		const String ALIGNAS_IDENTIFIER = "alignas";

		int alignIdx = typeString.IndexOf(ALIGNAS_IDENTIFIER);
		int _;
		bool hasValidAlignment = this.FindNumberBetween(typeString, '(', ')', out typeInfo.align, &_);
		
		if (alignIdx != -1 && !hasValidAlignment) {
			Console.WriteLine($"Could not parse specified alignment for type: {typeString}");
			return EError.FORMAT_ERROR;
		}

		if (hasValidAlignment) {
			int additionalOffset = 2 + MathUtils.DigitCount(typeInfo.align);
			typeString = typeString.Substring(alignIdx + ALIGNAS_IDENTIFIER.Length + additionalOffset);
		}
		
		int constIdx = typeString.IndexOf(CONST_IDENTIFIER);
		typeInfo.isConstant = constIdx != -1;
		if (typeInfo.isConstant) {
			typeString = typeString.Substring(constIdx + CONST_IDENTIFIER.Length);
		}

		// Count ptrs and susbtring replace
		if (countPtrLevel) {
			int pointerCount;
			int ptrFirstIdx;

			typeString.CountAndGetFirstIdx('*', out pointerCount, out ptrFirstIdx);
			if (ptrFirstIdx != -1) {
				typeString = typeString.Substring(0, ptrFirstIdx);
				typeInfo.pointerLevel = (uint8)pointerCount;
			}
		}
		
		StringView strippedType = typeString.Strip();

		ECType hash = (ECType)strippedType.Fnv1a();
		switch (hash) {
		case ECType.VOID:
			typeInfo.type = ECType.VOID;
			break;
		case ECType.INT8:
			typeInfo.type = ECType.INT8;
			typeInfo.size = sizeof(int8);
			typeInfo.align = alignof(int8);
			break;
		case ECType.INT16:
			typeInfo.type = ECType.INT16;
			typeInfo.size = sizeof(int16);
			typeInfo.align = alignof(int16);
			break;
		case ECType.INT: // Following MSVC and GCC standards on Windows, unspecified INT will most likely be 32-bits
			// I could not get it to fallthrough here once, you're welcome to try again later tho
			typeInfo.type = ECType.INT32;
			typeInfo.size = sizeof(int32);
			typeInfo.align = alignof(int32);
			break;
		case ECType.INT32:
			typeInfo.type = ECType.INT32;
			typeInfo.size = sizeof(int32);
			typeInfo.align = alignof(int32);
			break;
		case ECType.INT64:
			typeInfo.type = ECType.INT64;
			typeInfo.size = sizeof(int64);
			typeInfo.align = alignof(int64);
			break;
		case ECType.CHAR:
			typeInfo.type = ECType.CHAR;
			typeInfo.size = sizeof(char8);
			typeInfo.align = alignof(char8);
			break;
		case ECType.UINT8:
			typeInfo.type = ECType.UINT8;
			typeInfo.size = sizeof(uint8);
			typeInfo.align = alignof(uint8);
			break;
		case ECType.UINT16:
			typeInfo.type = ECType.UINT16;
			typeInfo.size = sizeof(uint16);
			typeInfo.align = alignof(uint16);
			break;
		case ECType.UINT32:
			typeInfo.type = ECType.UINT32;
			typeInfo.size = sizeof(uint32);
			typeInfo.align = alignof(uint32);
			break;
		case ECType.UNSIGNED_LONG_LONG:
		case ECType.UINT64:
			typeInfo.type = ECType.UINT64;
			typeInfo.size = sizeof(uint64);
			typeInfo.align = alignof(uint64);
			break;
		case ECType.FLOAT32:
			typeInfo.type = ECType.FLOAT32;
			typeInfo.size = sizeof(float);
			typeInfo.align = alignof(float);
			break;
		case ECType.FLOAT64:
			typeInfo.type = ECType.FLOAT64;
			typeInfo.size = sizeof(double);
			typeInfo.align = alignof(double);
			break;
		case ECType.BOOL8:
		case ECType._BOOL:
			typeInfo.type = ECType.BOOL8;
			typeInfo.size = sizeof(bool);
			typeInfo.align = alignof(bool);
			break;
		
		default:
			typeInfo.type = ECType.STRUCT;
			typeInfo.kind = ETypeKind.STRUCT;
			let key = scope String(strippedType);
			StringView* match = null;
			StructDescription* structRef = null;
			// TODO: DO NOT CHECK struct register if the pointer level is >= 1 (forward declaration)
			bool contains = this.m_registeredStructsByName.TryGetRef(strippedType, out match, out structRef);
			if (!contains) {
				Console.WriteLine($"Could not find struct by the name of {strippedType}, make sure it is declared before its usage!");
				return EError.UNRECOGNIZED_TYPE;
			}
			
			typeInfo.size = structRef.size;
			typeInfo.align = structRef.align;
			typeInfo.structName = *match;
			break;
		}

		if (countPtrLevel && typeInfo.pointerLevel > 0) {
			typeInfo.size = sizeof(void*);
			typeInfo.align = alignof(void*);
		}
		
		return EError.OK;
	}

	private EError TryGetFieldName(in StringView line, ref String wordBuffer, out int startNameIdx) {
		startNameIdx = -1;
		char8 prevChar = '\0';

		for (int i = line.Length - 1; i >= 0; i--) {
			bool shouldRecordWord =  IsValidIdentifierChar(prevChar);
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
				startNameIdx = i;
				return EError.OK;
			}
			// if (line[i] == '*') {
			// 	pointerLevel++;
			// }
			prevChar = line[i];
		}
		return EError.FORMAT_ERROR;
	}
	
	private EError TryParseStructField(ref StructDescription structDesc, StringView line) {
		var line; // Make mutable copy
		// A struct field is whatever the first non whitespace word is, along with its pointer level
		// Run the array backwards to find all other info in one go
		
		// IMPORTANT: MISSING EDGE CASES (delete as we implement)
		// - Array types [] and [n]
		// - Function pointers
		// - _Bool

		
		// Identify the array before the rest of it all lol
		uint64 arraySize;
		int firstBracketIdx = line.Length; // Start at full length so substring is a no-op if nothing is found
		bool isArray = this.FindNumberBetween(line, '[', ']', out arraySize, &firstBracketIdx);
		line = line.Substring(0, firstBracketIdx);

		FunctionProps functionPtrProps;
		if (this.TryParseFunctionPtr(line, out functionPtrProps)) {
			// If this suceeds, we fill the struct desc with the info of the fn ptr, add it to the map, and we early return
			ref Argument field = ref structDesc.fields[structDesc.fieldCount];

			StringView nameView = StringView(&functionPtrProps.name[0]);
			nameView.CopyTo(field.name);
			field.typeInfo.kind = ETypeKind.FUNCTION_POINTER;
			field.typeInfo.type = ECType.FUNCTION_POINTER;
			field.typeInfo.size = sizeof(function void());
			field.typeInfo.align = alignof(function void());

			// This does a reference to the local fixed array, if the value type is destroyed, so should be the key
			this.m_functions.TryAdd(nameView, functionPtrProps);
			return EError.OK;
		}
		
		String wordBuffer = scope String(MAX_FIELD_NAME);
		// We assume the pointer level is simply the amount of times we see the '*' character in the string
		int startNameIdx;
		EError err = this.TryGetFieldName(line, ref wordBuffer, out startNameIdx);

		if (err != EError.OK) {
			Console.WriteLine($"Could not parse name for struct field: {line}");
			return err;
		}

		ref Argument field = ref structDesc.fields[structDesc.fieldCount];

		StringView nameView = wordBuffer;
		nameView.CopyTo(field.name);
		wordBuffer.Clear();

		StringView typeString = line.Substring(0, startNameIdx + 1);
		err = this.TryParseType(typeString, ref field.typeInfo);
		if (err != EError.OK) {
			return err;
		}

		if (isArray) {
			field.typeInfo.kind = ETypeKind.ARRAY;
			field.typeInfo.size = field.typeInfo.size * arraySize;
		}

		if (!wordBuffer.IsEmpty) {
			// We have a pending type
			err = TryParseType(wordBuffer, ref field.typeInfo);
			if (err != EError.OK) return err;
		}
		return EError.OK;
	}
	
	/// @brief Parses a struct description, the string needs to be identified (from typedef struct to final enclosing curly bracket)
	public EError TryParseStruct(out StructDescription structDesc, in StringView structRegion) {
		structDesc = StructDescription{};
		// Any given struct will be parsed by identifying the substr "typedef struct"
		uint32 index = 0;
		uint32 pendingBraces = 0;
		for (StringView part in structRegion.Split("\n")) {
			// Identify the end of the struct
			if (part.Contains('}')) break;
			if (index != 0) {
				EError err = TryParseStructField(ref structDesc, part);
				if (err != EError.OK) return err;
				structDesc.fieldCount++;
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

		let key = scope String(&structDesc.name[0]);
		this.m_registeredStructsByName[key] = structDesc;

		return EError.OK;
	}

	public EError TryParseFunction(out FunctionProps functionProps, in StringView functionRegion) {
		// Parse the signature first, name and return type later (harder lol)
		int startIndex;
		StringView argListRaw = this.FindContentsInBetween(functionRegion, '(', ')', out startIndex);
		functionProps = FunctionProps();
		EError err = TryParseRawArgumentList(ref functionProps, argListRaw);

		if (err != EError.OK) {
			return err;
		}

		StringView nameAndRetType = functionRegion.Substring(0, startIndex);
		Console.WriteLine($"Name and ret: {nameAndRetType}");

		// Maybe the last idx could also be the pointer star, but, who knows :p
		int lastSpace = nameAndRetType.LastIndexOf(' ');
		StringView name = nameAndRetType.Substring(lastSpace + 1);
		name.CopyTo(functionProps.name);
		
		StringView cleanRet = nameAndRetType.Substring(0, lastSpace);
		const StringView EXTERN = "extern";
		int externIdx = cleanRet.IndexOf(EXTERN);

		if (externIdx != -1) {
			cleanRet = cleanRet.Substring(externIdx + EXTERN.Length);
		}
		
		// The rest we can assume is just the return type
		err = this.TryParseType(cleanRet, ref functionProps.returnType, true);
		return err;
	}
}
