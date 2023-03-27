package enc.helpers;

import haxe.Exception;
import haxe.io.Bytes;
import haxe.ds.Vector;

abstract BigBits(Array<Int>) {
	/**
	 * How many bits long this is
	 */
	public var length(get, never):Int;
	private function get_length() {
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

	/**
	 * @param a Array of 0s and 1s to make a bit array with
	 */
	public inline function new(a:Array<Int>) {
		for (e in a) {
			if (e != 0 && e != 1) {
				throw new Exception('Cannot convert non-bit array to bit array: ${e} is not 0 or 1');
			}
		}
		this = a;
	}

	/**
	 * [Description]
	 * @param a Either 1 or 0 to push at the end
	 */
	public function push(a:Int) {
		if (a != 0 && a != 1) {
			throw new Exception("Cannot push non-binary numbers to BigBits");
		}
		this.push(a);
	}

	/**
	 * [Description]
	 * Drops leading zeroes; May be done automatically in the future
	 */
	public function dropLeading(){
		while(this[0] == 0) {
			this.remove(0);
		}
		return new BigBits(this);
	}

	/**
	 * [Description]
	 * @param size Length to pad to, returns this if less than current length
	 */
	public function padTo(size:Int) {
		var x = this;
		if (x.length > size)
			return new BigBits(x);
		while (this.length < size) {
			x = [0].concat(x);
		}
		return new BigBits(x);
	}

	/**
	 * [Description]
	 * @param a Bytes to convert to BigBits
	 */
	@:from
	public static function fromBytes(a:Bytes) {
		var _tmp = [];
		for (i in 0...a.length) {
			_tmp = _tmp.concat(toBin(a.get(i)).toArray());
		}
		return new BigBits(_tmp);
	}

	/**
	 * [Description]
	 * @param a Int to convert to BigBits
	 */
	@:from
	public static function fromInt(a:Int) {
		return new BigBits(toBin(a).toArray());
	}

	/**
	 * [Description]
	 * Converts BigBits to an array of 1s and 0s
	 */
	@:to
	inline function toBitArr() {
		return this;
	}


	@:op(A & B)
	function and(b:BigBits) {
		var thisArr:Array<Int> = new BigBits(this).padTo(b.length);
		var otherArr:Array<Int> = b;
		var out:BigBits = new BigBits([0]);
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

	@:op(A|B)
	function or(b:BigBits) {
		var thisArr:Array<Int> = new BigBits(this).padTo(b.length);
		var otherArr:Array<Int> = b.padTo(this.length);
		var out:BigBits = new BigBits([0]);
		for (i in 0...thisArr.length) {
			out.push((thisArr[i]==1||otherArr[i]==1)?1:0);
		}
		return out;
	}
}
