package;
import haxe.io.Bytes;
import enc.helpers.BigBits;

class Main {
    static function main() {
        var a:BigBits = Math.round(Math.random()*512);
        var b:BigBits = Math.round(Math.random()*512);
        trace(a);
        trace(b);
        trace((a&b).dropLeading());
        trace((a|b).dropLeading());
    }
}