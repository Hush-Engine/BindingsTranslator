namespace HushBindingGen;
using System.IO;
using System.Diagnostics;
using System;

class FileUtils {
	public static EError WriteAt(FileCheckpoint* checkpoint, StringView content, Span<uint8> tempBuffer) {
		Debug.Assert(checkpoint != null, "Cannot write at file with a null checkpoint");
		let filePath = StringView(&checkpoint.fileName[0]);
		if (checkpoint.seekOffset == 0) {
			// Overwrite the file
			File.WriteAllText(filePath, content);
			return EError.OK;
		}
		FileStream stream = scope .();
		defer stream.Close();

		let res = stream.Open(filePath, FileMode.OpenOrCreate, FileAccess.ReadWrite);
		if (res case .Err(let err)) {
			Console.WriteLine($"Failed to open file, error: {err}");
			return EError.OPEN_FILE_ERROR;
		}
		let streamSeekRes = stream.Seek(checkpoint.seekOffset);

		if (streamSeekRes case .Err(let err)) {
			Console.WriteLine($"Failed to seek file, error: {err}");
			return EError.SEEK_FILE_ERROR;
		}

		// Memory buffer for restoring the contents (should be quite small since we are at the end of the class scope when we hit this
		int size = (stream.TryRead(tempBuffer));
		stream.Seek(stream.Position - size, .Absolute);

		uint8[] dest = scope uint8[tempBuffer.Length];
		int count = System.Text.UTF8Encoding.UTF8.Encode(content, dest);

		for (int i = 0; i < count; i++) {
			stream.Write(dest[i]);
		}

		checkpoint.seekOffset = stream.Position;


		for (int i = 0; i < tempBuffer.Length && tempBuffer[i] != '\0'; i++) {
			stream.Write(tempBuffer[i]);
		}

		return EError.OK;
	}
}

