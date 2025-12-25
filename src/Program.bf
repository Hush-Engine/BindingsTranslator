namespace HushBindingGen;
using System;

class Program {
	static void Main(String[] args) {
		let structDecl =
		"""
		typedef struct DVector4 {
			double x;
			double y;
			double z; 
			double w;
		} DVector4;
		""";
		let parser = scope CParser();
		StructDescription desc;
		EError err = parser.TryParseStruct(out desc, structDecl);
		if (err != EError.OK) {
			Console.WriteLine($"Error {err}!");
		}
		Console.WriteLine("Hello world!");
	}
}
