namespace HushBindingGen;

using System;

public interface ILangGenerator {

	public void EmitType(in TypeInfo type, ref String appendBuffer);
	
	public void EmitStruct(in StructDescription structDesc);

	public void EmitMethod(in StringView module, in FunctionProps funcDesc);

	
}

