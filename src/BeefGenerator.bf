namespace HushBindingGen;

using System;
using System.Diagnostics;
using System.Collections;
using System.IO;

public struct ConstantDecl {
	public char8[32] className;
	public StringView name;
	public Variant value;

	public StringView GetClassName() {
		return .(&this.className[0]);
	}
	
}

public struct FileCheckpoint {
	public char8[32] fileName;
	public int64 seekOffset;

	public this(StringView filePath, int64 offset) {
		this.fileName = char8[32]();
		filePath.CopyTo(this.fileName);
		this.seekOffset = offset;
	}

	public StringView GetFileName() {
		return .(&this.fileName[0]);
	}
}

public class BeefGenerator : ILangGenerator {
	const uint64 CLASS_SIZE_THRESHOLD = 24;

	const StringView GEN_SRC_FOLDER = "generated/src";

	public CParser Parser { get; set; }

	// TODO: Replace String with some sort of SmallString class that contains a set 32 byte buffer
	private Dictionary<String, FileCheckpoint> m_checkpointsByStructName = new Dictionary<String, FileCheckpoint>() ~ delete _;

	~this() {
		for (var entry in this.m_checkpointsByStructName) {
			delete entry.key;
		}
	}

	private void EnsureProjectDirectory() {
		if (!Directory.Exists(GEN_SRC_FOLDER)) {
			Directory.CreateDirectory(GEN_SRC_FOLDER);
		}
	}
	
	public void ToTypeString(in TypeInfo type, String buffer, StringView* fieldName = null) {
		switch(type.type) {
		case ECType.UNDEFINED:
			Debug.Assert(false, "Undefined type cannot be parsed! Review parsing for this struct field");
			break;
		case ECType.CHAR:
			buffer.Append("char8");
			break;
		case ECType.FLOAT64:
			buffer.Append("double");
			break;
		case ECType.FLOAT32:
			buffer.Append("float");
			break;
		case ECType.BOOL8:
			buffer.Append("bool");
			break;
		case ECType.SIZE_T:
			buffer.Append("uint64");
			break;
		case ECType.FUNCTION_POINTER:
			Debug.Assert(fieldName != null, "When parsing a function pointer a field name is necessary for a lookup into the functions table");
			FunctionProps* fnProps = Parser.GetFunctionInfo(*fieldName);
			Runtime.Assert(fnProps != null, scope $"Could not find a function pointer with the name {*fieldName}");
			// Wooo, recursion
			FunctionPtrToStr(*fnProps, buffer);
			break;
		case ECType.ENUM:
			// For enum types, use the underlying type until we implement it in the generator
			buffer.Append(type.structName);
			break;
		case ECType.STRUCT:
			StructDescription* structDecl = Parser.GetStructByName(type.structName);
			Debug.Assert(structDecl != null, scope $"Struct by the name {type.structName} cannot be found on the parser's definitions, check that it was parsed correctly!");
			// Scopify
			StringView nameView = StringView(&structDecl.name[0]);
			Scopes typeScoped = LangUtils.ExtractScopes(nameView);
			ToFullyScopedName(buffer, typeScoped);
			break;
		default:
			type.type.ToString(buffer);
			buffer.ToLower();
			break;
		}
		
		// Apply ptr level
		for (uint8 i = 0; i < type.pointerLevel; i++) {
			buffer.Append("*");
		}
	}
	
	public void FunctionPtrToStr(in FunctionProps fnProps, String buffer) {
		let retTypeBuff = scope String(16);
		ToTypeString(fnProps.returnType, retTypeBuff);
		buffer.AppendF($"function {retTypeBuff}(");
		for (int i = 0; i < fnProps.args.Count && fnProps.args[i].typeInfo.type != ECType.UNDEFINED; i++) {
			retTypeBuff.Clear();
			ToTypeString(fnProps.args[i].typeInfo, retTypeBuff);
			buffer.AppendF($"{retTypeBuff} {fnProps.args[i].name},");
		}
		buffer.Length--; // remove last comma
		if (buffer[buffer.Length - 1].IsWhiteSpace) {
			buffer.Length--;
		}
		buffer.AppendF(")");
	}
	
	public void EmitConstants(in Dictionary<String, Variant> constantDefines) {
		EnsureProjectDirectory();
		
		const uint64 guessSize = 1024 * 20; // 20kB for guess allocation
		String output = scope String(guessSize);
		// Separate the __ into namespaces and classes, the first one should always be Hush__

		let scopedConstants = scope Dictionary<StringView, List<ConstantDecl>>();

		for (let entry in constantDefines) {
			ConstantDecl toAdd = ConstantDecl();
			const StringView HUSH_IDENTIFIER = "Hush__";
			StringView constantName = entry.key;
			int hushIdentifierIdx = constantName.IndexOf(HUSH_IDENTIFIER);
			if (hushIdentifierIdx != -1) {
				constantName = constantName.Substring(hushIdentifierIdx + HUSH_IDENTIFIER.Length);
			}
			int classSeparatorIdx = constantName.IndexOf("__");
			if (classSeparatorIdx != -1) {
				StringView className = constantName.Substring(0, classSeparatorIdx);
				className.CopyTo(toAdd.className);
				constantName = constantName.Substring(classSeparatorIdx + 2);
			}
			toAdd.name = constantName;
			toAdd.value = entry.value;
			let key = toAdd.GetClassName();
			if (!scopedConstants.ContainsKey(key)) {
				let scopeList = new List<ConstantDecl>();
				defer :: delete scopeList;
				scopedConstants.Add(key, scopeList);
			}
			scopedConstants.GetValue(key).Value.Add(toAdd);
		}

		output.Append("namespace Hush;\n\n");

		String typeBuffer = scope String(16);
		for (let classScope in scopedConstants) {
			output.AppendF($"class {classScope.key} \{\n");
			for (let entry in classScope.value) {
				entry.value.VariantType.ToString(typeBuffer);
				defer typeBuffer.Clear();
				if (entry.value.VariantType.IsInteger) {
					output.AppendF($"\tpublic const {typeBuffer} {entry.name} = {entry.value.Get<int32>()};\n");
				}
				if (entry.value.VariantType.IsFloatingPoint) {
					output.AppendF($"\tpublic const {typeBuffer} {entry.name} = {entry.value.Get<double>()};\n");
				}
			}
			output.Append("}\n\n");
		}
		let fileWriteRes = File.WriteAllText(scope $"{GEN_SRC_FOLDER}/Constants.bf", output);
		if (fileWriteRes case .Err(let fileWriteErr)) {
			Console.WriteLine(scope $"Error generating constants, {fileWriteErr}");
		} 
	}
	
	public void EmitType(in TypeInfo type, ref String appendBuffer, StringView* fieldName = null) {
		String outType = scope String(16);
		ToTypeString(type, outType, fieldName);
		appendBuffer.AppendF($"{outType}");
		if (type.kind == ETypeKind.ARRAY) {
			// Use the size of the array
			// TODO: Handle pointers
			uint64 elementSize = CParser.GetSizeOf(type.type);
			appendBuffer.AppendF($"[{type.size / elementSize}]");
		}
	}

	private FileCheckpoint GetCheckpointForStruct(in Scopes classScoped, StringView className, out FileCheckpoint* outCheckpointRef) {
		let intendedFilePath = scope $"{GEN_SRC_FOLDER}/{className}.bf";
		outCheckpointRef = null;

		// We want to identify subclasses here too (use 1 bc of the namespace)
		if (classScoped.scopesCount <= 1) {
			// Init at a 0 offset
			return FileCheckpoint(intendedFilePath, 0);
		}
		// We only need to identify the last scope to be a struct in the file checkpoint dict
		int64 lastScopeIdx = classScoped.scopesCount - 1;
		StringView structName = .(&classScoped.scopes[lastScopeIdx][0]);
		// Find the checkcpoint to write to
		String* outKey = null;
		bool contains = this.m_checkpointsByStructName.TryGetRef(scope String(structName), out outKey, out outCheckpointRef);
		if (!contains) {
			return FileCheckpoint(intendedFilePath, 0);
		}
		// We get the actual file this sub struct is pointing to
		return *outCheckpointRef;
	}

	public void TabulateBuffer(String str, uint8 count) {
		Debug.Assert(str.AllocSize >= count, "Provided string buffer is not enough to store the tab count");
		for (uint8 i = 0; i < count; i++) {
			str.Append('\t');
		}
	}
	
	public void ILangGenerator.EmitStruct(in StructDescription structDesc)
	{
		Debug.Assert(Parser != null, "Null parser when trying to parse a struct, please set the Parser property of this implementation");
		// Given our source directory, we need to simply generate a Beef compatible struct string and put it into a file		

		StringView nameView = StringView(&structDesc.name[0]);
		Scopes classScoped = LangUtils.ExtractScopes(nameView);
		nameView = classScoped.GetName();
		// This is optional and will only be filled in by the function in case the checkpoint exists in the dictionary
		FileCheckpoint* beginCheckpointRef = null;
		FileCheckpoint checkpointToWriteBegin = GetCheckpointForStruct(classScoped, nameView, out beginCheckpointRef);
		// Make sure it is not null lol
		beginCheckpointRef = beginCheckpointRef == null ? &checkpointToWriteBegin : beginCheckpointRef;

		StringView filePath = checkpointToWriteBegin.GetFileName();
		const int MAX_STRUCT_GEN_LENGTH = 1024 * 3; // Just a few kB no struct should be bigger than this
		String output = scope String(MAX_STRUCT_GEN_LENGTH);
		const StringView DEFAULT_DECL = "[CRepr]";

		// Define if we want to make a struct or a class based on the size of it (24 bytes)
		String containerType = scope String(6);
		containerType += structDesc.size > CLASS_SIZE_THRESHOLD ? "class" : "struct";

		if (checkpointToWriteBegin.seekOffset <= 0) {
			output.Append("namespace Hush;\nusing System;\n");
		}
		
		String tabulation = scope String(4);
		uint8 tabCount = uint8(classScoped.scopesCount <= 0 ? 1 : classScoped.scopesCount - 1);
		TabulateBuffer(tabulation, tabCount); // tabs are N of scopes - 1 (namespace)
		
		output.AppendF($"\n{tabulation}{DEFAULT_DECL}\n{tabulation}public {containerType} {nameView} \{\n");

		int64 seekOffset = checkpointToWriteBegin.seekOffset;

		for (uint32 i = 0; i < structDesc.fieldCount; i++) {
			Argument* field = &structDesc.fields[i];
			// First type, then name
			output.AppendF($"{tabulation}\tpublic "); // All fields in the export should be public
			this.EmitType(field.typeInfo, ref output, &StringView(&field.name[0]));
			output.AppendF($" {field.name};\n"); // Now the name and the semicolon

			// We set the last file checkpoint here so that it stays in scope and we can add function definitions here
		}
		String key = new String(nameView);
		Console.Write(scope $"{containerType} for type: {key}... "); // FIXME: Removing this seems to trigger an access violation (??!!?!?
		seekOffset += (int64)output.Length;
		this.m_checkpointsByStructName[key] = FileCheckpoint(filePath, seekOffset);
		output.AppendF($"{tabulation}\}\n");

		EnsureProjectDirectory();

		uint8[] tempBuffer = scope uint8[MemUtils.KiB(3)];
		EError writeErr = FileUtils.WriteAt(beginCheckpointRef, output, tempBuffer);
		
		if (writeErr != EError.OK) {
			Console.WriteLine($"Could not generate file {filePath}!");
			return;
		}
		
		Console.WriteLine($"Written to file: {filePath}");
	}

	void ILangGenerator.EmitEnum(in EnumDescription enumDesc)
	{
		Debug.Assert(Parser != null, "Null parser when trying to parse an enum, please set the Parser property of this implementation");

		// First, name of the file needs to resemble the name of the enum
		const StringView HUSH_PREFIX = "Hush__";

		StringView nameView = StringView(&enumDesc.name[0]);
		
		Scopes enumScoped = LangUtils.ExtractScopes(nameView);
		nameView = enumScoped.GetName();
		int prefixIndex = nameView.IndexOf(HUSH_PREFIX);

		if (prefixIndex != -1) {
			nameView = nameView.Substring(prefixIndex + HUSH_PREFIX.Length);
		}

		const uint64 MAX_ENUM_GEN_LENGTH = MemUtils.KiB(2); // 2kB should be enough for any enum
		String output = scope String(MAX_ENUM_GEN_LENGTH);
		const StringView DEFAULT_DECL =
			"""
			namespace Hush;

			using System;
			using System.Collections;

			[CRepr]
			""";
		
		output.AppendF($"{DEFAULT_DECL}\nenum {nameView} : int32 \{\n");
		for (uint32 i = 0; i < enumDesc.valueCount; i++) {
			StringView valueNameView = StringView(&enumDesc.valueNames[i][0]);
			
			// Remove Hush__ prefix from enum values if present
			int valuePrefixIndex = valueNameView.IndexOf(HUSH_PREFIX);
			if (valuePrefixIndex != -1) {
				valueNameView = valueNameView.Substring(valuePrefixIndex + HUSH_PREFIX.Length);
			}
			
			output.AppendF($"\t{valueNameView} = {enumDesc.valueInts[i]},\n");
		}
		output.Append("}");

		EnsureProjectDirectory();
		
		let filePath = scope $"{GEN_SRC_FOLDER}/{nameView}.bf";
		let writeRes = File.WriteAllText(filePath, output);
		
		if (writeRes case .Err) {
			Console.WriteLine($"Could not generate file {filePath}!");
			return;
		}
		
		Console.WriteLine($"Written to file: {filePath}");
	}

	public void ToFullyScopedName(String buffer, in Scopes typeScopes) {
		const int64 SKIP_NAMESPACE_IDX = 1;
		for (int64 i = SKIP_NAMESPACE_IDX; i < typeScopes.scopesCount; i++) {
			buffer.AppendF($"{typeScopes.GetScopeAt(i)}.");
		}
		buffer.Append(typeScopes.GetName());
	}

	public void EmitMethod(in FunctionProps funcDesc) {
		// We can put functions with params as struct* self on the same file as the struct
		// BUT, we still need a reference to the original function name to call it within the implemented function
		// i.e Hush__Entity__AddComponentRaw can go under:
		// class Entity {
		//     AddComponentRaw() {
		//         // But here we need to call it from the original C name
		//         Hush__Entity__AddComponentRaw();
		//     }
		// }
		StringView fnName = StringView(&funcDesc.name[0]);
		Scopes scopes = LangUtils.ExtractScopes(fnName);

		// Define both the link function and the public facing API

		// Link fn example from the SDL2 bindings
		// [LinkName("SDL_Init")]
		// public static extern int32 Init(InitFlag flags);
		const int MAX_FN_DECL_LENGTH = MemUtils.KiB(1);
		String output = scope String(MAX_FN_DECL_LENGTH);
		String fnImplementation = scope String(512);
		
		String typeBuffer = scope String(64);
		this.ToTypeString(funcDesc.returnType, typeBuffer);
		
		String tabulation = scope String(4);
		uint8 tabCount = uint8(scopes.scopesCount <= 0 ? 1 : scopes.scopesCount - 1);
		TabulateBuffer(tabulation, tabCount); // tabs are N of scopes - 1 (namespace)
		
		output.AppendF($"\n{tabulation}[LinkName(\"{fnName}\")]\n{tabulation}public static extern {typeBuffer} {fnName}(");

		StringView memberFnName = scopes.GetName();
		fnImplementation.AppendF($"{tabulation}public {typeBuffer} {memberFnName}(");
		// Then append the method args
		const int COMMA_AND_SPACE_OFFSET = 2;
		int argCount = 0;
		for (int i = 0; i < funcDesc.args.Count; i++) {
			if (funcDesc.args[i].typeInfo.type == ECType.UNDEFINED) {
				break;
			}
			typeBuffer.Clear();
			this.ToTypeString(funcDesc.args[i].typeInfo, typeBuffer);
			StringView argName = StringView(&funcDesc.args[i].name[0]);
			output.AppendF($"{typeBuffer} {argName}, ");
			if (argName == "self") {
				// Skip the self argument for the member function
				continue;
			}
			argCount++;
			fnImplementation.AppendF($"{typeBuffer} {argName}, ");
		}
		output.Length -= COMMA_AND_SPACE_OFFSET;
		if (argCount > 0) {
			fnImplementation.Length -= COMMA_AND_SPACE_OFFSET;
		}

		output.Append(");\n");
		fnImplementation.AppendF($") \{\n{tabulation}\t");

		// Now we add the implementation of this function, which should be a member function calling the linked fn
		if (funcDesc.returnType.type != ECType.VOID || funcDesc.returnType.pointerLevel > 0) {
			fnImplementation.Append("return ");
		}
		fnImplementation.AppendF($"{fnName}(");
		for (int i = 0; i < funcDesc.args.Count; i++) {
			Argument currArg = funcDesc.args[i];
			if (currArg.typeInfo.type == ECType.UNDEFINED) {
				break;
			}
			String nameBuffer = scope String(16);
			StringView argName = StringView(&currArg.name[0]);
			if (argName == "self") {
				argName = "&this";
			}
			if (argName.IsEmpty) {
				nameBuffer = scope $"arg{i}";
				argName = nameBuffer;
			}
			fnImplementation.AppendF($"{argName}, ");
		}

		fnImplementation.Length -= COMMA_AND_SPACE_OFFSET;
		fnImplementation.AppendF($");\n{tabulation}\}");

		output.AppendF($"{fnImplementation}\n");

		// Now, this output should be sent to the last book-kept offset on the scope
		let scopeWithName = scopes.scopes[scopes.scopesCount - 1];
		let structStr = scope String(&scopeWithName[0]);
		String* matchKey = null;
		FileCheckpoint* value = null;
		bool matched = this.m_checkpointsByStructName.TryGetRef(structStr, out matchKey, out value);

		if (!matched) return;

		// Use the largest expected file size
		uint8[] contentsAfter = scope uint8[MemUtils.KiB(5)];
		FileUtils.WriteAt(value, output, contentsAfter);
	}
}
