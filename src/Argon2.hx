package;

import haxe.EnumTools.EnumValueTools;
import haxe.Exception;
import haxe.io.Bytes;

enum HashType {
	Argon2d;
	Argon2i;
	Argon2id;
}

class Argon2 {
	static function getHash(toHash:Bytes, salt:Bytes, parallelism:Int = 1, tagLength:Int, memSize:Int, iterations:Int, version:Int = 0x13, key:Null<Bytes>,
			assocData:Null<Bytes>, hashType:HashType):Bytes {
		if (toHash.length > 0xffffffff || toHash.length < 0x0)
			throw new Exception('Unhashable data: HashLength must be between 0 and 0xffffffff (${0xffffffff}) bytes; got ${toHash.length} bytes instead.');

		if (salt.length > 0xffffffff || salt.length < 0x8)
			throw new Exception('Unhashable data: Incorrect salt; expected between 0 and 0xffffffff (${0xffffffff}) bytes, got ${salt.length} bytes instead.');

		if (parallelism < 0x1 || parallelism > 0xffffff)
			throw new Exception('Hash function failed: Must start between 1 and 0xffffff ${0xffffff} threads, got ${parallelism} threads');

		if (tagLength < 4 || tagLength > 0xffffffff)
			throw new Exception('Hash function failed: TagLength must be between 4 and 0xffffffff (${0xffffffff}), got ${tagLength} tag bytes');

		if (memSize < 8 || memSize > 0xffffffff)
			throw new Exception('Hash function failed: Must use between 0x8 (${0x8}) and 0xffffffff (${0xffffffff}) kib, got ${memSize} kib');

		if (iterations < 1 || iterations > 0xffffffff)
			throw new Exception('Hash function failed: Must use between 1 and 0xffffffff (${0xffffffff}) iterations, got ${iterations} iterations');

		if (version != 0x13)
			throw new Exception('Only version 19 of Argon2 is currently supported.');

		if (key.length < 0 || key.length > 0xffffffff)
			throw new Exception('Hash function failed: Optional key length must be between 0 and 0xfffffff (${0xffffffff}) bytes, got ${key.length}');

		if (assocData.length < 0 || assocData.length > 0xffffffff)
			throw new Exception('Hash function failed: Optional associated data length must be between 0 and 0xffffffff (${0xffffffff}) bytes, got ${assocData.length} bytes');

        var argontype = ['i', 'd', 'id'][EnumValueTools.getIndex(hashType)];

		return Bytes.ofHex('0'); // STOP YELLING AT ME HAXE LINTER JFC
	}
}
