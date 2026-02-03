namespace HushBindingGen;

using System;
using System.Collections;

public interface ILangGenerator {

	public CParser Parser { get; set; }
	
	public void EmitConstants(in Dictionary<String, Variant> constantDefines);

	public void EmitType(in TypeInfo type, ref String appendBuffer, StringView* fieldName = null);
	
	public void EmitStruct(in StructDescription structDesc);

	public void EmitEnum(in EnumDescription enumDesc);

	public void EmitMethod(in FunctionProps funcDesc);

	
}

