package enc;

import enc.helpers.Bits;
import haxe.ds.Vector;
import haxe.Exception;
import haxe.io.Bytes;

class Blake2b {
	private static final initvector:Vector<Bits> = Vector.fromArrayCopy([
		Bits.fromHex("6a09e667f3bcc908"),
		Bits.fromHex("bb67ae8584caa73b"),
		Bits.fromHex("3c6ef372fe94f82b"),
		Bits.fromHex("a54ff53a5f1d36f1"),
		Bits.fromHex("510e527fade682d1"),
		Bits.fromHex("9b05688c2b3e6c1f"),
		Bits.fromHex("1f83d9abfb41bd6b"),
		Bits.fromHex("5be0cd19137e2179"),
	]);

	public static function getHash(msg:Bits, key:Null<Bits>, cbHashLen:Int):Bits {
		if (msg.length < 0 || msg.length > Math.pow(2, 128))
			throw new Exception("Unhashable data: msg must be between 0 and 2^128 bytes");
		var cbMessageLen = msg.length;
		var statevector:Vector<Bits> = initvector.copy();

		var keylen:Int;
		var keybits:Bits;
		if (key == null) {
			keylen = 0;
		} else {
			keylen = key.length;
			keybits = key;
		}

		statevector[0] ^= Bits.fromHex('0101${((keylen < 16) ? '0' : '') + StringTools.hex(keylen)}${((cbHashLen < 16) ? '0' : '') + StringTools.hex(cbHashLen)}');

		var cBytesCompressed:Int = 0;
		var cBytesRemaining:Int = cbMessageLen;

		if (keylen > 0) {
			keybits = keybits.padTo(128 * 8); // 128 *bytes* not 128 *bits*
			msg = keybits.concat(msg);
		}
		
		while (cBytesRemaining > 0) {
			final chunk = msg;
			cBytesCompressed += 128;
			cBytesRemaining -= 128;
			statevector = compress(statevector, chunk, cBytesCompressed);
		}
		var chunk = msg.hi(128*8);
		cBytesCompressed = cBytesCompressed + cBytesRemaining;
		chunk.padTo(128*8);
		statevector = compress(statevector, chunk, cBytesCompressed, true);
		var eVector = [];
		for (e in statevector) {
			eVector.concat(e.toBitArr());
		}
		return Bytes.ofString(''); // HACK REMOVE THIS
	}

	public static function compress(statevector:Vector<Bits>, chunk:Bits, t:Int, isLastBlock:Bool = false) {
		var workVector:Vector<Bits> = new Vector<Bits>(16);
		var tBits:Bits = Bits.fromInt(t).padTo(128 * 8);
		chunk = chunk.padTo(128);

		for (i in 0...8)
			workVector.set(i, statevector[i]);
		for (i in 8...16)
			workVector.set(i, initvector[i]);
		workVector[12] ^= tBits.lo(64);
		workVector[13] ^= tBits.hi(64);
		if (isLastBlock)
			workVector[14] ^= 'ffffffffffffffff';
		var wordVector:Vector<Bits> = new Vector<Bits>(16);
		var chunkBits = chunk.toBitArr();
		for (i in 0...16) {
			wordVector.set(i, new Bits(chunkBits.splice(0, 8)));
		}
		final sigma = [
			[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
			[14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3],
			[11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4],
			[7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8],
			[9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13],
			[2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9],
			[12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11],
			[13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10],
			[6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5],
			[10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0]
		];
		for (i in 0...12) {
			final sigmaLine = sigma[i % 10];
			for (j in 0...4) {
				var mixed = mix(Vector.fromArrayCopy([workVector[0 + j], workVector[4 + j], workVector[8 + j], workVector[12 + j]]), sigmaLine[0 + j],
					sigmaLine[1 + j]);
				workVector[0 + j] = mixed[0];
				workVector[4 + j] = mixed[1];
				workVector[8 + j] = mixed[2];
				workVector[12 + j] = mixed[3];
			}
			for (layout in [[0, 5, 10, 15, 8], [1, 6, 11, 12, 10], [2, 7, 8, 13, 12], [3, 4, 9, 14, 14]]) {
				var mixed = mix(Vector.fromArrayCopy([
					workVector[layout[0]],
					workVector[layout[1]],
					workVector[layout[2]],
					workVector[layout[3]]
				]), sigmaLine[layout[4]], sigmaLine[layout[4] + 1]);
				for (j in 0...4) {
					workVector[layout[j]] = mixed[j];
				}
			}
		}
		for (i in 0...8) {
			statevector[i] ^= workVector[i];
			statevector[i] ^= workVector[i+8];
		}
		return statevector;
	}

	public static function mix(vec:Vector<Bits>, mx:Bits, my:Bits):Vector<Bits> {
		for (item in vec) {
			if (item.length != 8 * 8) { // if not 8 byte
				throw new Exception("Invalid word length; Check work vector");
			}
		}
		if (mx.length != 8 * 8 || my.length != 8 * 8)
			throw new Exception("Invalid word length; Check message");
		var vec4:Vector<Bits> = vec.copy();

		vec4.set(0, (vec4.get(0) + vec4.get(1) + mx)); // set a add abx
		vec4.set(3, (vec4.get(3) ^ vec4.get(0)).toNearestByte(true).rotateRight(32)); // set d dxaRR32

		vec4.set(2, (vec4.get(2) + vec4.get(3))); // set c add cd
		vec4.set(1, (vec4.get(1) ^ vec4.get(2)).toNearestByte(true).rotateRight(24)); // set b bxcRR24

		vec4.set(0, (vec4.get(0) + vec4.get(1) + my)); // set a add aby
		vec4.set(3, (vec4.get(3) ^ vec4.get(0)).rotateRight(16)); // set d dxaRR16

		vec4.set(2, (vec4.get(2) + vec4.get(3))); // set c add cd
		vec4.set(1, (vec4.get(1) ^ vec4.get(2)).rotateRight(63)); // set b bxcRR63

		return vec4.copy(); // return vec4 abcd
	}
}
