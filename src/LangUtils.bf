namespace HushBindingGen;

using System;
using System.Diagnostics;

struct Scopes {
	const int MAX_SCOPES = 4;
	public char8[MAX_SCOPES][64] scopes;
	public int64 scopesCount;
	public int64 nameIdx;

	public StringView GetScopeAt(int64 idx) {
		Debug.Assert(idx < this.scopesCount, "Out of bounds scope access, maybe you meant to call GetName?");
		return .(&this.scopes[idx][0]);
	}
	
	public StringView GetName() {
		return .(&this.scopes[nameIdx][0]);
	}

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
