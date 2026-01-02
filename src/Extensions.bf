
namespace System {
	extension StringView {
		/// @brief Finds the last index of the char to check along a substring from 0 to maxCheckIdx
		public int LastIndexOfMax(char8 c, int maxCheckIdx) {
			return -1;
		}

		public StringView Strip()
		{
			int start = 0;
			int end = mLength;

			while (start < end && this[start].IsWhiteSpace)
				start++;

			while (end > start && this[end - 1].IsWhiteSpace)
				end--;

			return this.Substring(start, end - start);
		}

		
		public uint32 Fnv1a()
		{
		    uint32 hash = 0x811c9dc5u;
		    const uint32 prime = 0x1000193u;

		    for (int i = 0u; i < mLength; ++i)
		    {
		        uint8 value = (uint8)mPtr[i];
		        hash = (hash ^ value) * prime;
		    }

		    return hash;
		}

		public void CountAndGetFirstIdx(char8 token, out int count, out int firstIndex) {
			count = 0;
			firstIndex = -1;
			for (int i = 0; i < this.mLength; i++) {
				if (this[i] != token) continue;
				count++;
				if (firstIndex == -1) {
					firstIndex = i;
				}
			}
		}
		
	}
	extension String {

		public StringView Strip()
		{
			int start = 0;
			int end = mLength;

			while (start < end && this[start].IsWhiteSpace)
				start++;

			while (end > start && this[end - 1].IsWhiteSpace)
				end--;

			return this.Substring(start, end - start);
		}

		
		public uint32 Fnv1a()
		{
		    uint32 hash = 0x811c9dc5u;
		    const uint32 prime = 0x1000193u;

		    for (int i = 0u; i < mLength; ++i)
		    {
		        uint8 value = (uint8)this[i];
		        hash = (hash ^ value) * prime;
		    }

		    return hash;
		}
		
	}
}

