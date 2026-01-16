using System;
namespace HushBindingGen;

public class MemUtils {
	public static uint64 KiB(uint64 kib) {
		return 1024 * kib;
	}
	
	public static uint64 MiB(uint64 mib) {
		return 1024 * 1024 * mib;
	}
	
	public static uint64 GiB(uint64 gib) {
		return 1024 * 1024 * gib;
	}
}
