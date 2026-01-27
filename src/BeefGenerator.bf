namespace HushBindingGen;

using System;
using System.Diagnostics;
using System.Collections;
using System.IO;

public struct ConstantDecl {
	public char8[64] className;
	public StringView name;
	public Variant value;
}

public class BeefGenerator : ILangGenerator {

	public CParser Parser { get; set; }

	private void ToTypeString(in TypeInfo type, String buffer, StringView* fieldName = null) {
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
		case ECType.SIZE_T:
			buffer.Append("uint64");
			break;
		case ECType.FUNCTION_POINTER:
			Debug.Assert(fieldName != null, "When parsing a function pointer a field name is necessary for a lookup into the functions table");
			FunctionProps* fnProps = Parser.GetFunctionInfo(*fieldName);
			Runtime.Assert(fnProps != null, scope $"Could not find a function pointer with the name {*fieldName}");
			function void(int32, uint64) arg;
			let retTypeBuff = scope String(16);
			// Wooo, recursion
			ToTypeString(fnProps.returnType, retTypeBuff);
			buffer.AppendF($"function {retTypeBuff}(");
			for (int i = 0; i < fnProps.args.Count && fnProps.args[i].typeInfo.type != ECType.UNDEFINED; i++) {
				retTypeBuff.Clear();
				ToTypeString(fnProps.args[i].typeInfo, retTypeBuff);
				buffer.AppendF($"{retTypeBuff} {fnProps.args[i].name},");
			}
			buffer.Length--; // remove last comma
			buffer.AppendF(")");
			break;
		case ECType.ENUM:
			// For enum types, use the underlying type until we implement it in the generator
			buffer.Append(type.structName);
			break;
		case ECType.STRUCT:
			StructDescription* structDecl = Parser.GetStructByName(type.structName);
			Debug.Assert(structDecl != null, scope $"Struct by the name {type.structName} cannot be found on the parser's definitions, check that it was parsed correctly!");
			buffer.Append(type.structName);
			break;
		default:
			type.type.ToString(buffer);
			buffer.ToLower();
			break;
		}
		
		// Apply ptr level
		Console.WriteLine(scope $"Pointer level: {type.pointerLevel}");
		for (uint8 i = 0; i < type.pointerLevel; i++) {
			buffer.Append("*");
		}
	}
	
	public void EmitConstants(in Dictionary<String, Variant> constantDefines) {
		if (!Directory.Exists("generated")) {
			Directory.CreateDirectory("generated");
		}
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
			let key = StringView(&toAdd.className[0]);
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
		File.WriteAllText("generated/Constants.bf", output);
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

	void ILangGenerator.EmitStruct(in StructDescription structDesc)
	{
		Debug.Assert(Parser != null, "Null parser when trying to parse a struct, please set the Parser property of this implementation");
		// Given our source directory, we need to simply generate a Beef compatible struct string and put it into a file		

		// First, the name of the file needs to resemble the name of the struct
		const StringView HUSH_PREFIX = "Hush__"; // Some structs under the Hush namespace will have this

		StringView nameView = StringView(&structDesc.name[0]);
		int prefixIndex = nameView.IndexOf(HUSH_PREFIX);

		if (prefixIndex != -1) {
			nameView = nameView.Substring(prefixIndex + HUSH_PREFIX.Length);
		}

		const int MAX_STRUCT_GEN_LENGTH = 1024 * 3; // Just a few kB no struct should be bigger than this
		String output = scope String(MAX_STRUCT_GEN_LENGTH);
		const StringView DEFAULT_DECL =
			"""
			namespace Hush;

			using System;
			using System.Collections;

			[CRepr]
			""";
		output.AppendF($"{DEFAULT_DECL}\nstruct {nameView} \{\n");
		for (uint32 i = 0; i < structDesc.fieldCount; i++) {
			Argument* field = &structDesc.fields[i];
			// First type, then name
			output.Append("\tpublic "); // All fields in the export should be public
			this.EmitType(field.typeInfo, ref output, &StringView(&field.name[0]));
			output.AppendF($" {field.name};\n"); // Now the name and the semicolon
		}
		output.Append("}");
		if (!Directory.Exists("generated")) {
			Directory.CreateDirectory("generated");
		}
		let filePath = scope $"generated/{nameView}.bf";
		let writeRes = File.WriteAllText(filePath, output);
		
		if (writeRes case .Err) {
			Console.WriteLine($"Could not generate file {filePath}!");
			return;
		}
		
		// Console.WriteLine($"Written struct:\n\n{output}");
		Console.WriteLine($"Written to file: {filePath}");
	}

	void ILangGenerator.EmitEnum(in EnumDescription enumDesc)
	{
		Debug.Assert(Parser != null, "Null parser when trying to parse an enum, please set the Parser property of this implementation");

		// First, name of the file needs to resemble the name of the enum
		const StringView HUSH_PREFIX = "Hush__";

		StringView nameView = StringView(&enumDesc.name[0]);
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

		if (!Directory.Exists("generated")) {
			Directory.CreateDirectory("generated");
		}
		let filePath = scope $"generated/{nameView}.bf";
		let writeRes = File.WriteAllText(filePath, output);
		
		if (writeRes case .Err) {
			Console.WriteLine($"Could not generate file {filePath}!");
			return;
		}
		
		Console.WriteLine($"Written to file: {filePath}");
	}

	void ILangGenerator.EmitMethod(in StringView module, in FunctionProps funcDesc)
	{
		// We can put functions with params as struct* self on the same file as the struct
		// BUT, we still need a reference to the original function name to call it within the implemented function
		// i.e Hush__Entity__AddComponentRaw can go under:
		// class Entity {
		//     AddComponentRaw() {
		//         // But here we need to call it from the original C name
		//         Hush__Entity__AddComponentRaw();
		//     }
		// }

	}
}
