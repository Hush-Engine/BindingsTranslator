
namespace System {
	extension StringView {
		/// @brief Finds the last index of the char to check along a substring from 0 to maxCheckIdx
		public int LastIndexOfMax(char8 c, int maxCheckIdx) {
			return -1;
		}

		public StringView Strip() {
			int startIdx = 0;
			char8 prevChar = '\0';
			int endTrimStart = mLength;
			for (int i = 0; i < mLength; i++) {
				char8 c = this[i];
				if (!c.IsWhiteSpace) {
					prevChar = c;
					continue;
				}
				if (prevChar != '\0' && !prevChar.IsWhiteSpace) {
					endTrimStart = i;
				}
				if (startIdx == 0) {
					startIdx = i + 1;
				}
				prevChar = c;
				
			}
			return this.Substring(startIdx, endTrimStart - startIdx);
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
		
	}
	extension String {
		
		public StringView Strip() {
			int startIdx = 0;
			char8 prevChar = '\0';
			int endTrimStart = mLength;
			for (int i = 0; i < mLength; i++) {
				char8 c = this[i];
				if (!c.IsWhiteSpace) {
					prevChar = c;
					continue;
				}
				if (prevChar != '\0' && !prevChar.IsWhiteSpace) {
					endTrimStart = i;
				}
				if (startIdx == 0) {
					startIdx = i + 1;
				}
				prevChar = c;
				
			}
			return this.Substring(startIdx, endTrimStart - startIdx);
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

