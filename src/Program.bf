namespace HushBindingGen;
using System;
using System.Collections;

class Program {

	private static void ProcessStruct(CParser parser, ILangGenerator generator, in StringView structDecl) {
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
				String* matchKey;
				parser.m_functions.TryGetRef(scope String(nameView), out matchKey, out fnDesc);
				Console.WriteLine($"\tFunction return type: {fnDesc.returnType.type};\n\tArgs:");
				for (int j = 0; j < fnDesc.args.Count; j++) {
					if (fnDesc.args[j].typeInfo.type == ECType.UNDEFINED) break;
					Console.WriteLine($"\t\tName: {fnDesc.args[j].name}; Type: {fnDesc.args[j].typeInfo.type}; Pointer Level: {fnDesc.args[j].typeInfo.pointerLevel}; Kind: {fnDesc.args[j].typeInfo.kind}; Size: {fnDesc.args[j].typeInfo.size} IsConst? {fnDesc.args[j].typeInfo.isConstant}; Alignment: {fnDesc.args[j].typeInfo.align}");
				}
			}
		}

		generator.EmitStruct(desc);
	}

	static void Main(String[] args) {
		let structDecl =
		"""
		#pragma once
		#include <stdint.h>


		#ifdef __cplusplus
		typedef bool _Bool;
		extern "C" {
		#endif

		typedef uint32_t Hush__ComponentTraits__EComponentOpsFlags;

		#define Hush__ComponentTraits__EComponentOpsFlags_None 0
		#define Hush__ComponentTraits__EComponentOpsFlags_HasCtor 1
		#define Hush__ComponentTraits__EComponentOpsFlags_HasDtor 2
		#define Hush__ComponentTraits__EComponentOpsFlags_HasCopy 4
		#define Hush__ComponentTraits__EComponentOpsFlags_HasMove 8
		#define Hush__ComponentTraits__EComponentOpsFlags_HasCopyCtor 16
		#define Hush__ComponentTraits__EComponentOpsFlags_HasMoveCtor 32
		#define Hush__ComponentTraits__EComponentOpsFlags_HasMoveDtor 64
		#define Hush__ComponentTraits__EComponentOpsFlags_HasMoveAssignDtor 128
		#define Hush__ComponentTraits__EComponentOpsFlags_NoCtor 256
		#define Hush__ComponentTraits__EComponentOpsFlags_NoDtor 512
		#define Hush__ComponentTraits__EComponentOpsFlags_NoCopy 1024
		#define Hush__ComponentTraits__EComponentOpsFlags_NoMove 2048
		#define Hush__ComponentTraits__EComponentOpsFlags_NoCopyCtor 4096
		#define Hush__ComponentTraits__EComponentOpsFlags_NoMoveCtor 8192
		#define Hush__ComponentTraits__EComponentOpsFlags_NoMoveDtor 16384
		#define Hush__ComponentTraits__EComponentOpsFlags_NoMoveAssignDtor 32768

		
		typedef struct Hush__ComponentTraits__ComponentOps {
			void (*ctor)(void *, int, const void *);
			void (*dtor)(void *, int, const void *);
			void (*copy)(void *, const void *, int, const void *);
			void (*move)(void *, void *, int, const void *);
			void (*copyCtor)(void *, const void *, int, const void *);
			void (*moveCtor)(void *, void *, int, const void *);
			void (*moveDtor)(void *, void *, int, const void *);
			void (*moveAssignDtor)(void *, void *, int, const void *);
		} Hush__ComponentTraits__ComponentOps;

		extern void * Hush__Entity__AddComponentRaw(Hush__Entity *self, unsigned long long componentId);
		
		""";

		Console.WriteLine($"String to parse: \n{structDecl}\n\n");

		let parser = scope CParser();
		let generator = scope BeefGenerator();
		generator.Parser = parser;

		List<ParseRegion> parsingRegions = scope List<ParseRegion>(500);

		EError err = parser.SeparateScopes(structDecl, ref parsingRegions);

		if (err != EError.OK) {
			Console.WriteLine($"Error parsing scopes: {err}");
		}

		for (ParseRegion region in parsingRegions) {
			if (region.type == EScopeType.Struct) {
				ProcessStruct(parser, generator, region.content);
				continue;
			}
			if (region.type == EScopeType.Function) {
				FunctionProps functionProps;
				err = parser.TryParseFunction(out functionProps, region.content);
				Console.WriteLine($"Function: {region.content}");
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
				
				continue;
			}
		}

		generator.EmitConstants(parser.GetDefinitions());

		Console.WriteLine("Finished parsing, contents written to file: ! (RETURN to exit)");
		Console.Read();
	}
}
