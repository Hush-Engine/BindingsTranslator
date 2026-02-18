namespace HushBindingGen;

using System;

struct Scopes {
	const int MAX_SCOPES = 4;
	public char8[MAX_SCOPES][64] scopes;
	public int64 scopesCount;
	public int64 nameIdx;
}

public class LangUtils {
	public static Scopes ExtractScopes(StringView name) {
		// Find every __
		const StringView delimitter = "__";
		Scopes scopeList = Scopes();
		for (StringView scopeName in name.Split(delimitter)) {
			let refScope = ref scopeList.scopes[scopeList.scopesCount];
			scopeName.CopyTo(refScope);
			scopeList.scopesCount++;
		}
		// Eliminate the last one from the count, but not the array(should be the name)
		scopeList.nameIdx = scopeList.scopesCount - 1;
		scopeList.scopesCount--;
		
		return scopeList;
	}
}
