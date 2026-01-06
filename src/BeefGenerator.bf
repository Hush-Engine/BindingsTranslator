namespace HushBindingGen;

using System;
using System.IO;

public class BeefGenerator : ILangGenerator {

	private void ToTypeString(in TypeInfo type, String buffer) {
		switch(type.type) {
		case ECType.CHAR:
			buffer.Append("char8");
			return;
		case ECType.FLOAT64:
			buffer.Append("double");
			return;
		case ECType.FLOAT32:
			buffer.Append("float");
			return;
		default:
			type.type.ToString(buffer);
			buffer.ToLower();
			return;
		}
		
	}
	
	public void EmitType(in TypeInfo type, ref String appendBuffer) {
		if (type.kind != ETypeKind.STRUCT) {
			String outType = scope String(16);
			ToTypeString(type, outType);
			appendBuffer.AppendF($"{outType}");
		}
		if (type.kind == ETypeKind.ARRAY) {
			// Use the size of the array
			// TODO: Handle pointers
			uint64 elementSize = CParser.GetSizeOf(type.type);
			appendBuffer.AppendF($"[{type.size / elementSize}]");
		}
	}

	void ILangGenerator.EmitStruct(in StructDescription structDesc)
	{
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
			this.EmitType(field.typeInfo, ref output);
			output.AppendF($" {field.name};\n"); // Now the name and the semicolon
		}
		output.Append("}");
		if (!Directory.Exists("generated")) {
			Directory.CreateDirectory("generated");
		}
		let filePath = scope $"generated/{nameView}";
		let writeRes = File.WriteAllText(filePath, output);
		
		if (writeRes case .Err) {
			Console.WriteLine($"Could not generate file {filePath}!");
			return;
		}
		
		Console.WriteLine($"Written struct:\n\n{output}");
	}

	void ILangGenerator.EmitMethod(in StringView module, in FunctionProps funcDesc)
	{
		// We can put functions with params as struct* self on the same file as the struct

	}
}
