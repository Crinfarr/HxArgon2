package enc.helpers;

import haxe.io.BytesBuffer;
import haxe.Exception;
import haxe.io.Bytes;
import haxe.ds.Vector;

abstract Bits(Array<Int>) {
	/**
	 * How many bits long this is
	 */
	public var length(get, never):Int;

	private function get_length():Int {
		return this.length;
	}

	/**
	 * @param num Number to convert to binary
	 * @return a Vector representation of the number in binary  
	 */
	private static function toBin(num:Int):Vector<Int> {
		if (num == 0) {
			return Vector.fromArrayCopy([0]);
		}
		var _num:Float = num;
		var p2 = 0;
		while ((1<<p2) < num) {
			p2++;
		}
		var v = new Vector(p2 + 1);
		while (p2 >= 0) {
			if (_num >= (1<<p2)) {
				_num -= (1<<p2);
				v[v.length - p2 - 1] = 1;
				p2--;
			} else {
				v[v.length - p2 - 1] = 0;
				p2--;
			}
		}
		return v;
	}

	private static function bitToInt(bitArr:Array<Int>):Int {
		for (i in bitArr) {
			if (i != 0 || i != 1) {
				throw new Exception('Invalid bit: expected 0 or 1; got ${i}');
			}
		}
		final ilen = bitArr.length;
		var val:Int = 0;
		while (bitArr.length > 0) {
			val += (1<<(ilen - bitArr.length)) * bitArr.pop();
		}
		return val;
	}

	/**
	 * @param a Array of 0s and 1s to make a bit array with
	 */
	@:from
	public inline function new(a:Array<Int>):Bits {
		for (e in a) {
			if (e != 0 && e != 1) {
				throw new Exception('Cannot convert non-bit array to bit array: ${e} is not 0 or 1');
			}
		}
		this = a;
	}

	/**
	 * Adds [a] to the end of [this]
	 * @param a Either 1 or 0 to push at the end
	 */
	public function push(a:Int):Void {
		if (a != 0 && a != 1) {
			throw new Exception("Cannot push non-binary numbers to Bits");
		}
		this.push(a);
	}

	/**
	 * Drops leading zeroes; May be done automatically in the future
	 */
	public function dropLeading():Bits {
		while (this[0] == 0) {
			this.remove(0);
		}
		return this;
	}

	/**
	 * @param size Length to pad to, returns this if less than current length
	 */
	public function padTo(size:Int):Bits {
		var x = this;
		if (x.length > size)
			return x;
		while (this.length < size) {
			x = [0].concat(x);
		}
		return x;
	}

	/**
	 * Shifts all bits right, wrapping overflow to the left side.
	 * USE \[Bits\].toNearestByte() TO AVOID UNINTENDED BEHAVIOR
	 * @param nSpaces spaces to shift right 
	 */
	public function rotateRight(nSpaces:Int):Bits {
		final tBits:Bits = this;
		return (tBits.lo(nSpaces).concat(tBits.hi(tBits.length - nSpaces)));
	}

	/**
	 * Shifts all bits left, wrapping overflow to the right side.
	 * USE \[Bits\].toNearestByte() TO AVOID UNINTENDED BEHAVIOR
	 * @param nSpaces spaces to shift left
	 */
	public function rotateLeft(nSpaces:Int):Bits {
		final tBits:Bits = this;
		return (tBits.lo(tBits.length - nSpaces).concat(tBits.hi(nSpaces)));
	}

	/**
	 * Adds leading zeroes to the nearest multiple of 8 bits.
	 * @param keepLeadingZeroes Whether to drop all leading zeroes before rounding.
	 */
	public function toNearestByte(keepLeadingZeroes:Bool = false) {
		var bThis:Bits = this;
		if (!keepLeadingZeroes)
			bThis = bThis.dropLeading();
		return bThis.padTo(bThis.length + (bThis.length % 8));
	}

	/**
	 * @param other 
	 */
	public function concat(other:Bits):Bits {
		var thisArr:Array<Int> = this;
		var otherArr:Array<Int> = other;
		return thisArr.concat(otherArr);
	}

	/**
	 * Returns the lowest [bits] Bits of this function
	 * @param bits 
	 * @return Bits
	 */
	public function lo(bits:Int):Bits {
		return (new Bits(this)) & Bits.fromInt((1<<bits) - 1);
	}

	/**
	 * Returns the highest [bits] Bits of this function
	 * @param bits 
	 * @return Bits
	 */
	public function hi(bits:Int):Bits {
		return (new Bits(this)) & (Bits.fromInt((1<<bits) - 1)) << (this.length - bits);
	}

	/**
	 * @param a Bytes to convert to Bits
	 */
	@:from
	public static function fromBytes(a:Bytes):Bits {
		var _tmp = [];
		for (i in 0...a.length) {
			_tmp = _tmp.concat(toBin(a.get(i)).toArray());
		}
		return _tmp;
	}

	/**
	 * @param a Int to convert to Bits
	 */
	@:from
	public static function fromInt(a:Int):Bits {
		return toBin(a).toArray();
	}

	/**
	 * @param a Hex string to convert to Bits
	 */
	@:from
	public static function fromHex(a:String):Bits {
		return Bits.fromBytes(Bytes.ofHex(a));
	}

	/**
	 * Converts Bits to an array of 1s and 0s
	 */
	@:to
	public inline function toBitArr():Array<Int> {
		return this;
	}

	/**
	 * Returns a byte representation of an array of bits
	 * @param byteArr 
	 * @return Bytes
	 */
	@:to
	public inline function toBytes():Bytes {
		var byteval:Int = 0;
		var bytes:BytesBuffer = new BytesBuffer();
		var bits:Array<Int> = new Bits(this).toNearestByte();
		var bitArr:Array<Bits> = [];

		for (_ in 0...Std.int(bits.length / 8)) {
			bitArr.push(bits.splice(0, 8));
		}
		for (idx in 0...bitArr.length) {
			var aBit:Array<Int> = bitArr[idx];
			if (aBit.length != 8) {
				throw new Exception('Cannot cast ${aBit} to byte: Must be length 8, got ${aBit.length}');
			}
			while (aBit.length != 0) {
				final p2:Int = 8 - bitArr.length;
				byteval += (1<<p2) * aBit.pop();
			}
			bytes.addByte(byteval);
			byteval = 0;
		}
		return bytes.getBytes();
	}

	@:to
	public inline function toInt():Int {
		return bitToInt(this);
	}

	/**
	 * Bitwise AND between 2 Bits (or casts)
	 * @param b 
	 */
	@:op(A & B)
	inline function and(b:Bits):Bits {
		var thisArr:Array<Int> = new Bits(this).padTo(b.length);
		var otherArr:Array<Int> = b;
		var out:Bits = [0];
		if (thisArr.length > otherArr.length) {
			while (otherArr.length < thisArr.length) {
				otherArr = [0].concat(otherArr);
			}
		} else if (thisArr.length < otherArr.length) {
			while (thisArr.length < otherArr.length) {
				thisArr = [0].concat(thisArr);
			}
		}

		for (i in 0...thisArr.length) {
			out.push((thisArr[i] == 1 && otherArr[i] == 1) ? 1 : 0);
		}
		return out.dropLeading();
	}

	/**
	 * Bitwise OR between 2 Bits (or casts)
	 * @param b 
	 */
	@:op(A | B)
	inline function or(b:Bits):Bits {
		var thisArr:Array<Int> = new Bits(this).padTo(b.length);
		var otherArr:Array<Int> = b.padTo(this.length);
		var out:Bits = [0];
		for (i in 0...thisArr.length) {
			out.push((thisArr[i] == 1 || otherArr[i] == 1) ? 1 : 0);
		}
		return out.dropLeading();
	}

	/**
	 * Bitwise XOR between 2 Bits (or casts)
	 * @param b 
	 */
	@:op(A ^ B)
	inline function xor(b:Bits):Bits {
		var thisArr:Array<Int> = new Bits(this).padTo(b.length);
		var otherArr:Array<Int> = b.padTo(this.length);
		var out:Bits = [0];
		for (i in 0...thisArr.length) {
			out.push((thisArr[i] != otherArr[i]) ? 1 : 0);
		}
		return out.dropLeading();
	}

	/**
	 * Shifts [this] left b registers.
	 * @param b 
	 */
	@:op(A << B)
	inline function lsh(b:Int):Bits {
		return this.concat([for (_ in 0...b) 0]);
	}

	/**
	 * Arithmetic (signed) shifts [this] right B registers
	 * @param b 
	 */
	@:op(A >> B)
	inline function rshAri(b:Int):Bits {
		final msb = this[0];
		var rt:Array<Int> = this;

		for (_ in 0...b) {
			rt.pop();
			rt = [msb].concat(rt);
		}
		return rt;
	}

	/**
	 * Logical (unsigned) shifts [this] right B registers
	 * @param b 
	 */
	@:op(A >>> B)
	inline function rshLog(b:Int):Bits {
		var rt:Array<Int> = this;
		for (_ in 0...b) {
			rt.pop();
			rt = [0].concat(rt);
		}
		return rt;
	}
	@:op(~A)
	inline function not():Bits {
		this.map((bit) -> {
			return (bit+1)%2;
		});
		return this;
	}

	@:op(A + B)
	inline function add(b:Bits):Bits {
		var x:Bits = new Bits(this) & b;
		var y:Bits = new Bits(this) ^ b;
		while (x != 0) {
			x = x << 1;
			x = x & y;
			y = x ^ y;
		}
		return y;
	}
	@:op(A-B)
	inline function sub(b:Bits):Bits {
		var tBits:Bits = this;
		tBits = tBits.padTo(b.length);
		b = ~(b.padTo(tBits.length));

		var mask = new Bits([1])<<this.length;
		var ret = tBits + b;
		mask &= ret;
		ret ^= mask;
		mask.rotateLeft(1);
		ret += mask;
		return ret;
	}
}
