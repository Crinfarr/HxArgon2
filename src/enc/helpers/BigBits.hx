package enc.helpers;

import haxe.Int64;
import haxe.io.BytesBuffer;
import haxe.Exception;
import haxe.io.Bytes;
import haxe.ds.Vector;

abstract BigBits(Array<Int>) {
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
		while (Math.pow(2, p2) < num) {
			p2++;
		}
		var v = new Vector(p2 + 1);
		while (p2 >= 0) {
			if (_num >= Math.pow(2, p2)) {
				_num -= Math.pow(2, p2);
				v[v.length - p2 - 1] = 1;
				p2--;
			} else {
				v[v.length - p2 - 1] = 0;
				p2--;
			}
		}
		return v;
	}

	private static function bitToBytes(byteArr:Array<Array<Int>>):Bytes {
		var byteval:Int = 0;
		var bytes:BytesBuffer = new BytesBuffer();
		for (bitarr in byteArr) {
			if (bitarr.length != 8) {
				throw new Exception('Cannot cast ${bitarr} to byte: Must be length 8, got ${bitarr.length}');
			}
			while (bitarr.length != 0 ) {
				final p2:Int = 8-bitarr.length;
				byteval += Std.int(Math.pow(2, p2)*bitarr.pop());
			}
			bytes.addByte(byteval);
			byteval = 0;
		}
		return bytes.getBytes();
	}

	private static function bitToInt(bitArr:Array<Int>):Int {
		for (i in bitArr) {
			if (i != 0 || i != 1) {
				throw new Exception('Invalid bit: expected 0 or 1; got ${i}');
			}
		}
		final ilen  = bitArr.length;
		var val:Int = 0;
		while (bitArr.length > 0) {
			val += Std.int(Math.pow(2, ilen-bitArr.length)*bitArr.pop());
		}
		return val;
	}

	/**
	 * @param a Array of 0s and 1s to make a bit array with
	 */
	 @:from
	public inline function new(a:Array<Int>):BigBits {
		for (e in a) {
			if (e != 0 && e != 1) {
				throw new Exception('Cannot convert non-bit array to bit array: ${e} is not 0 or 1');
			}
		}
		this = a;
	}

	/**
	 * [Description]
	 * Adds [a] to the end of [this]
	 * @param a Either 1 or 0 to push at the end
	 */
	public function push(a:Int):Void {
		if (a != 0 && a != 1) {
			throw new Exception("Cannot push non-binary numbers to BigBits");
		}
		this.push(a);
	}

	/**
	 * [Description]
	 * Drops leading zeroes; May be done automatically in the future
	 */
	public function dropLeading():BigBits{
		while(this[0] == 0) {
			this.remove(0);
		}
		return this;
	}

	/**
	 * [Description]
	 * @param size Length to pad to, returns this if less than current length
	 */
	public function padTo(size:Int):BigBits {
		var x = this;
		if (x.length > size)
			return x;
		while (this.length < size) {
			x = [0].concat(x);
		}
		return x;
	}

	/**
	 * [Description]
	 * @param other 
	 */
	public inline function concat(other:BigBits):BigBits {
		var thisArr:Array<Int> = this;
		var otherArr:Array<Int> = other;
		return thisArr.concat(otherArr);
	}

	public inline function lo(bits:Int):BigBits {
		return this.slice(this.length - bits - 1);
	}

	public inline function hi(bits:Int):BigBits {
		return this.slice(0, bits);
	}

	/**
	 * [Description]
	 * @param a Bytes to convert to BigBits
	 */
	@:from
	public static function fromBytes(a:Bytes):BigBits {
		var _tmp = [];
		for (i in 0...a.length) {
			_tmp = _tmp.concat(toBin(a.get(i)).toArray());
		}
		return _tmp;
	}

	/**
	 * [Description]
	 * @param a Int to convert to BigBits
	 */
	@:from
	public static function fromInt(a:Int):BigBits {
		return toBin(a).toArray();
	}

	/**
	 * [Description]
	 * @param a Hex string to convert to BigBits
	 */
	@:from
	public static function fromHex(a:String):BigBits {
		return BigBits.fromBytes(Bytes.ofHex(a));
	}

	/**
	 * [Description]
	 * Converts BigBits to an array of 1s and 0s
	 */
	@:to
	public inline function toBitArr():Array<Int> {
		return this;
	}

	@:to
	public inline function toBytes():Bytes {
		var bitarr = this;
		if (bitarr.length%8 != 0) {
			throw new Exception('Cannot cast BigBits of length ${bitarr.length} to bytes; must be a multiple of 8 bits long.');
		}
		var tmparr:Array<Array<Int>> = [];
		while (bitarr.length > 0) {
			tmparr.push(bitarr.splice(0, 8));
		}
		return bitToBytes(tmparr);
	}
	@:to
	public inline function toInt():Int {
		return bitToInt(this);
	}

	/**
	 * [Description]
	 * Bitwise AND between 2 BigBits (or casts)
	 * @param b 
	 */
	@:op(A & B)
	inline function and(b:BigBits):BigBits {
		var thisArr:Array<Int> = new BigBits(this).padTo(b.length);
		var otherArr:Array<Int> = b;
		var out:BigBits = [0];
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
	 * [Description]
	 * Bitwise OR between 2 BigBits (or casts)
	 * @param b 
	 */
	@:op(A|B)
	inline function or(b:BigBits):BigBits {
		var thisArr:Array<Int> = new BigBits(this).padTo(b.length);
		var otherArr:Array<Int> = b.padTo(this.length);
		var out:BigBits = [0];
		for (i in 0...thisArr.length) {
			out.push((thisArr[i]==1||otherArr[i]==1)?1:0);
		}
		return out.dropLeading();
	}

	/**
	 * [Description]
	 * Bitwise XOR between 2 BigBits (or casts)
	 * @param b 
	 */
	@:op(A^B)
	inline function xor(b:BigBits):BigBits {
		var thisArr:Array<Int> = new BigBits(this).padTo(b.length);
		var otherArr:Array<Int> = b.padTo(this.length);
		var out:BigBits = [0];
		for (i in 0...thisArr.length) {
			out.push((thisArr[i]!=otherArr[i])?1:0);
		}
		return out.dropLeading();
	}

	/**
	 * Shifts [this] left b registers.
	 * @param b 
	 */
	@:op(A<<B)
	inline function lsh(b:Int):BigBits {
		return this.concat([for (_ in 0...b) 0]);
	}

	/**
	 * Arithmetic (signed) shifts [this] right B registers
	 * @param b 
	 */
	@:op(A>>B)
	inline function rshAri(b:Int):BigBits {
		final msb = this[0];
		var rt:Array<Int> = this;

		for (_ in 0...b) {
			this.pop();
			rt = [msb].concat(rt);
		}
		return rt;
	}

	/**
	 * Logical (unsigned) shifts [this] right B registers
	 * @param b 
	 */
	@:op(A>>>B)
	inline function rshLog(b:Int):BigBits {
		var rt:Array<Int> = this;
		for (_ in 0...b) {
			this.pop();
			rt = [0].concat(rt);
		}
		return rt;
	}

	@:op(A+B)
	inline function add(b:BigBits):BigBits {
		var x:BigBits = new BigBits(this)&b;
		var y:BigBits = new BigBits(this)^b;
		while (x != 0){
			x = x<<1;
			x = x&y;
			y = x^y;
		}
		return y;
	}
}