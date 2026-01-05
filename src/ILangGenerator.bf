namespace HushBindingGen;

using System;

public interface ILangGenerator {

	public void EmitStruct(in StructDescription structDesc);

	public void EmitMethod(in StringView module, in FunctionProps funcDesc);

	
}

