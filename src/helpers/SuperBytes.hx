package helpers;
import haxe.Exception;
import haxe.io.BytesBuffer;
import haxe.io.Bytes;

/**
 * Abstract for using bytes to do,, byte math
 */
abstract SuperBytes(Bytes) {

    public var length(get, never):Int;
    private function get_length():Int {
        return this.length;
    }
    //helpers
    public function padToBytes(len:Int):SuperBytes {
        var out = Bytes.alloc(len);
        out.fill(0, len, 0);
        out.blit(out.length - this.length, this, 0, this.length);
        return out;
    }

    //inherent cast to
    @:to
    public function toBytes():Bytes {
        return this;
    }
    
    @:to
    public function toIntArray():Array<Int> {
        return [for (i in cast(this, SuperBytes)) i];
    }
    //inherent cast from
    @:from
    public inline function new(b:Bytes):SuperBytes {
        this = b;
    }
    
    @:from
    static inline function fromInt(b:Int):SuperBytes{
        return StringTools.hex(b);
    }

    @:from
    public static function fromHexString(s:String):SuperBytes {
        return Bytes.ofHex(s);
    }

    @:from
    public static function fromIntArray(a:Array<Int>):SuperBytes {
        var ret:BytesBuffer = new BytesBuffer();
        for (elem in a) {
            if (elem > 255) throw new Exception('Cannot convert ${elem} to byte: ${elem} >= 256');
            ret.addByte(elem);
        }
        return ret.getBytes();
    }

    //base math functions
    //please don't make me do byte multiplication
    //I will kill myself
    @:op(A+B)
    function add(B:SuperBytes):SuperBytes {
        final thisSB:SuperBytes = (cast (this, SuperBytes)).padToBytes(B.length);
        final otherSB:SuperBytes = B.padToBytes(this.length);
        
        var vals:Array<Int> = [];
        var carry:Int = 0;
        for (idx in 0...thisSB.length) {
            // trace(thisSB.length - idx - 1);
            final index = thisSB.length - idx - 1;
            final temp = thisSB[index] + otherSB[index] + carry;
            if (temp > 255) {
                carry = 1;
                vals = [temp-255].concat(vals);
            }
            else {
                carry = 0;
                vals = [temp].concat(vals);
            }
        }
        if (carry == 1) {
            vals = [carry].concat(vals);
        } 
        return vals;
    }

    //array access functions
    //(why do bytes not have these inherently?)
    @:op([])
    function arrAccess(idx:Int):Int {
        return this.get(idx);
    }

    @:op([])
    function arrWrite(idx:Int, val:Int):Void {
        this.set(idx, val);
    }
}