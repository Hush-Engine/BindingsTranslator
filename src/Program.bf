namespace HushBindingGen;
using System;

class Program {
	static void Main(String[] args) {
		let structDecl =
		"""
		typedef struct Hush__RawQuery__QueryIterator {
			alignas(1) char m_member0[384];
			alignas(8) char m_member1[8];
			alignas(1) char m_member2[1];
			double m_doubleTest;
			float m_singleTest;
			int64_t m_signed64Test;
			uint64_t m_unsigned64Test;
			bool m_boolTest;
			int32_t m_signed32ArrTest[100];
			void (*ctor)(void *comp, int, const void *);
		} Hush__RawQuery__QueryIterator;
		""";

		Console.WriteLine($"String to parse: \n{structDecl}\n\n");

		let parser = scope CParser();
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
		
		Console.WriteLine("Finished parsing, contents written to file: ! (RETURN to exit)");
		Console.Read();
	}
}
