namespace HushBindingGen;
using System;

class MathUtils {

	// I miss SFINAE :c

	public static int DigitCount(int integer) {
		if (integer == 0) return 1;
		float count = Math.Floor(Math.Log10(integer)) + 1;
		return (int)count;
	}
	
	public static int DigitCount(uint64 integer) {
		if (integer == 0) return 1;
		float count = Math.Floor(Math.Log10(integer)) + 1;
		return (int)count;
	}
}
