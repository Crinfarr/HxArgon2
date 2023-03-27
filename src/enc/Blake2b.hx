package enc;

import haxe.ds.Vector;
import haxe.Exception;
import haxe.io.Bytes;

class Blake2b {
	private static final initvector:Vector<Bytes> = Vector.fromArrayCopy([
		Bytes.ofHex("6a09e667f3bcc908"),
		Bytes.ofHex("bb67ae8584caa73b"),
		Bytes.ofHex("3c6ef372fe94f82b"),
		Bytes.ofHex("a54ff53a5f1d36f1"),
		Bytes.ofHex("510e527fade682d1"),
		Bytes.ofHex("9b05688c2b3e6c1f"),
		Bytes.ofHex("1f83d9abfb41bd6b"),
		Bytes.ofHex("5be0cd19137e2179"),
	]);

	public static function getHash(msg:Bytes, key:Null<Bytes>, cbHashLen:Int):Bytes {
		if (msg.length < 0 || msg.length > Math.pow(2, 128))
			throw new Exception("Unhashable data: msg must be between 0 and 2^128 bytes");
		var cbMessageLen = msg.length;
		var cbKeyLen = key.length;
		var statevector:Vector<Bytes> = initvector.copy();

		var keylen:Int;
		if (key == null) {
			keylen = 0;
		}
		else {
			keylen = key.length;
		}

		return Bytes.ofString(''); // HACK REMOVE THIS
	}
}
