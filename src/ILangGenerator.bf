namespace HushBindingGen;

using System;
using System.Collections;

public interface ILangGenerator {

	public void EmitConstants(in Dictionary<String, Variant> constantDefines);

	public void EmitType(in TypeInfo type, ref String appendBuffer);
	
	public void EmitStruct(in StructDescription structDesc);

	public void EmitMethod(in StringView module, in FunctionProps funcDesc);

	
}

