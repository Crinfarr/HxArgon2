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
        return [for (i in new SuperBytes(this)) i];
    }
    //inherent cast from
    @:from
    public inline function new(b:Bytes):SuperBytes {
        this = b;
    }
    
    @:from
    static inline function fromInt(b:Int):SuperBytes{
        var ret:BytesBuffer = new BytesBuffer();
        while (b > 255) {
            ret.addByte(255);
            b -= 255;
        }
        ret.addByte(b);
        return ret.getBytes();
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


    //array access functions (why do bytes not have these inherently?)
    @:op([])
    function arrAccess(idx:Int):Int {
        return this.get(idx);
    }

    @:op([])
    function arrWrite(idx:Int, val:Int):SuperBytes {
        this.set(idx, val);
        return this;
    }
}