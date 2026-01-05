namespace HushBindingGen;

using System;

public class BeefGenerator : ILangGenerator {

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
		output.Append("\n}");
		Console.WriteLine($"Written struct:\n\n{output}");
	}

	void ILangGenerator.EmitMethod(in StringView module, in FunctionProps funcDesc)
	{
		// We can put functions with params as struct* self on the same file as the struct

	}
}
