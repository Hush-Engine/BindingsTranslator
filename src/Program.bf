namespace HushBindingGen;
using System;
using System.Collections;

class Program {

	private static void ProcessStruct(CParser parser, in StringView structDecl) {
		StructDescription desc;
		EError err = parser.TryParseStruct(out desc, structDecl);
		if (err != EError.OK) {
			Console.WriteLine($"Error {err}!");
		}

		Console.WriteLine($"Struct: {desc.name}");
		for (uint32 i = 0; i < desc.fieldCount; i++) {
			let field = &desc.fields[i];
			Console.WriteLine($"Field: {field.name}; Type: {field.typeInfo.type}; Kind: {field.typeInfo.kind}; Size: {field.typeInfo.size} IsConst? {field.typeInfo.isConstant}; Alignment: {field.typeInfo.align}");
			if (field.typeInfo.kind == ETypeKind.FUNCTION_POINTER) {
				FunctionProps* fnDesc;
				StringView nameView = StringView(&field.name[0]);
				StringView* matchKey;
				parser.m_functions.TryGetRef(nameView, out matchKey, out fnDesc);
				Console.WriteLine($"\tFunction return type: {fnDesc.returnType.type};\n\tArgs:");
				for (int j = 0; j < fnDesc.args.Count; j++) {
					if (fnDesc.args[j].typeInfo.type == ECType.UNDEFINED) break;
					Console.WriteLine($"\t\tName: {fnDesc.args[j].name}; Type: {fnDesc.args[j].typeInfo.type}; Pointer Level: {fnDesc.args[j].typeInfo.pointerLevel}; Kind: {fnDesc.args[j].typeInfo.kind}; Size: {fnDesc.args[j].typeInfo.size} IsConst? {fnDesc.args[j].typeInfo.isConstant}; Alignment: {fnDesc.args[j].typeInfo.align}");
				}
			}
		}
	}

	static void Main(String[] args) {
		let structDecl =
		"""
		typedef struct Hush__Entity {
			alignas(8) char m_member0[8];
			alignas(8) char m_member1[8];
		} Hush__Entity;

		extern void * Hush__Entity__AddComponentRaw(Hush__Entity *self, unsigned long long componentId);
		
		""";

		Console.WriteLine($"String to parse: \n{structDecl}\n\n");

		let parser = scope CParser();
		List<ParseRegion> parsingRegions = scope List<ParseRegion>(500);

		EError err = parser.SeparateScopes(structDecl, ref parsingRegions);

		if (err != EError.OK) {
			Console.WriteLine($"Error parsing scopes: {err}");
		}

		for (ParseRegion region in parsingRegions) {
			if (region.type == EScopeType.Struct) {
				ProcessStruct(parser, region.content);
				continue;
			}
			if (region.type == EScopeType.Function) {
				FunctionProps functionProps;
				err = parser.TryParseFunction(out functionProps, region.content);
				Console.WriteLine($"Function: {region.content}");
				continue;
			}
		}

		Console.WriteLine("Finished parsing, contents written to file: ! (RETURN to exit)");
		Console.Read();
	}
}
