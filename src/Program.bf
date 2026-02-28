namespace HushBindingGen;
using System;
using System.Collections;
using System.IO;

class Program {

	private static void ProcessStruct(CParser parser, ILangGenerator generator, in StringView structDecl) {
		StructDescription desc;
		EError err = parser.TryParseStruct(out desc, structDecl);
		if (err != EError.OK) {
			Console.WriteLine($"Error {err}!");
		}

		generator.EmitStruct(desc);
	}

	private static void ProcessEnum(CParser parser, ILangGenerator generator, in StringView enumDecl) {
		EnumDescription desc;
		EError err = parser.TryParseEnum(out desc, enumDecl);
		if (err != EError.OK) {
			Console.WriteLine($"Error {err}!");
		}

		generator.EmitEnum(desc);
	}

	static void Main(String[] args) {
		// The first arg should contain the input file
#if !DEBUG
		if (args.Count < 1) {
			Console.WriteLine("Not enough arguments provided, at least one positional argument is needed, run with -help for more information");
			return;
		}
		StringView filePath = args[0];
#else
		StringView filePath = "HushBindings.h";
#endif
		const uint64 FILE_LENGTH_PREDICTION = MemUtils.MiB(2); // We can reserve at least 2MB 
		String fileBuffer = new String(FILE_LENGTH_PREDICTION);
		defer delete fileBuffer;
		let result = File.ReadAllText(filePath, fileBuffer);

		if (result case .Err(let e)) {
			Console.WriteLine($"Could not read file given by input, error: {e}!");
			return;
		}
		
		Console.WriteLine($"Parsing file: \n{filePath}...\n\n");

		let parser = scope CParser();
		let generator = scope BeefGenerator();
		generator.Parser = parser;

		List<ParseRegion> parsingRegions = scope List<ParseRegion>(500);

		EError err = parser.SeparateScopes(fileBuffer, ref parsingRegions);

		if (err != EError.OK) {
			Console.WriteLine($"Error parsing scopes: {err}");
		}


		for (ParseRegion region in parsingRegions) {
			if (region.type == EScopeType.Struct) {
				ProcessStruct(parser, generator, region.content);
				continue;
			}
			if (region.type == EScopeType.Enum) {
				ProcessEnum(parser, generator, region.content);
				continue;
			}
			if (region.type == EScopeType.Function) {
				FunctionProps functionProps;
				err = parser.TryParseFunction(out functionProps, region.content);
				if (err == EError.OK) {
					generator.EmitMethod(functionProps);
				}
				
				// Console.WriteLine($"Function: {region.content}");
				continue;
			}
			if (region.type == EScopeType.Define) {
				String key;
				Variant value;
				err = parser.TryParseDefine(region.content, out key, out value);
				parser.AddDefinition(key, value);
				continue;
			}
			if (region.type == EScopeType.Typedef) {
				String key;
				TypeInfo typeInfo;
				err = parser.TryParseTypedef(region.content, out key, out typeInfo);
				parser.AddTypedef(key, typeInfo);
				continue;
			}
		}

		generator.EmitConstants(parser.GetDefinitions());

		Console.WriteLine("Finished parsing, contents written to file: ! (RETURN to exit)");
		Console.Read();
	}
}
