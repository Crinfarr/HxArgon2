package enc;

import enc.helpers.BigBits;
import haxe.ds.Vector;
import haxe.Exception;
import haxe.io.Bytes;

class Blake2b {
	private static final initvector:Vector<BigBits> = Vector.fromArrayCopy([
		BigBits.fromHex("6a09e667f3bcc908"),
		BigBits.fromHex("bb67ae8584caa73b"),
		BigBits.fromHex("3c6ef372fe94f82b"),
		BigBits.fromHex("a54ff53a5f1d36f1"),
		BigBits.fromHex("510e527fade682d1"),
		BigBits.fromHex("9b05688c2b3e6c1f"),
		BigBits.fromHex("1f83d9abfb41bd6b"),
		BigBits.fromHex("5be0cd19137e2179"),
	]);

	public static function getHash(msg:BigBits, key:Null<BigBits>, cbHashLen:Int):BigBits {
		if (msg.length < 0 || msg.length > Math.pow(2, 128))
			throw new Exception("Unhashable data: msg must be between 0 and 2^128 bytes");
		var cbMessageLen = msg.length;
		var statevector:Vector<BigBits> = initvector.copy();

		var keylen:Int;
		var keybits:BigBits;
		if (key == null) {
			keylen = 0;
		}
		else {
			keylen = key.length;
			keybits = key;
		}

		statevector[0] ^= BigBits.fromHex('0101${((keylen < 16)?'0':'')+StringTools.hex(keylen)}${((cbHashLen<16)?'0':'')+StringTools.hex(cbHashLen)}');

		var cBytesCompressed:Int = 0;
		var cBytesRemaining:Int = cbMessageLen;

		if (keylen > 0) {
			keybits = keybits.padTo(128*8);//128 *bytes* not 128 *bits*
			msg = keybits.concat(msg);
		}//TODO HERE ON
		return Bytes.ofString(''); // HACK REMOVE THIS
	}
	public static function compress(statevector:Vector<BigBits>, chunk:BigBits, t:Int, isLastBlock:Bool=false){
		var workVector:Vector<BigBits> = new Vector<BigBits>(16);
		var tBits:BigBits = BigBits.fromInt(t).padTo(128*8);
		chunk = chunk.padTo(128);

		for (i in 0...7)
			workVector.set(i, statevector[i]);
		for (i in 8...15) 
			workVector.set(i, initvector[i]);
		workVector[12] ^= tBits.lo(64);
		workVector[13] ^= tBits.hi(64);
		if (isLastBlock)
			workVector[14] ^= 'ffffffffffffffff';
		var wordVector:Vector<BigBits> = new Vector<BigBits>(16);
		var chunkBits = chunk.toBitArr();
		for (i in 0...15) {
			wordVector.set(i, new BigBits(chunkBits.splice(0, 8)));
		}

		for (i in 0...11) {
			//TODO HERE ON
		}
	}
	public static function mix(vec:Vector<BigBits>, mx:BigBits, my:BigBits){
		for (item in vec) {
			if (item.length != 8*8) {//if not 8 byte
				throw new Exception("Invalid word length; Check work vector");
			}
		}
		if (mx.length != 8*8 || my.length != 8*8)
			throw new Exception("Invalid word length; Check message");
		var vec4:Vector<Int> = vec.copy();
		vec4.set(0, (
			vec4.get(0)+vec4.get(1)//HACK HERE FIRST
		));
	}
}
