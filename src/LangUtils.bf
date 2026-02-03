namespace HushBindingGen;

using System;

struct Scopes {
	const int MAX_SCOPES = 4;
	public char8[MAX_SCOPES][64] scopes;
	public int64 count;
}

public class LangUtils {
	public static Scopes ExtractScopes(StringView name) {
		// Find every __
		const StringView delimitter = "__";
		Scopes scopeList = Scopes();
		for (StringView scopeName in name.Split(delimitter)) {
			let refScope = ref scopeList.scopes[scopeList.count];
			scopeName.CopyTo(refScope);
			scopeList.count++;
		}
		// Eliminate the last one (should be the name)
		scopeList.scopes[scopeList.count - 1] = .();
		scopeList.count--;
		
		return scopeList;
	}
}
