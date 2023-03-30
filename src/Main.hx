import helpers.SuperBytes;

class Main {
    static function main() {
        var data=StringTools.hex(Std.int(Math.random()*0x7fffffff), 8);
        trace(data);
        var a:SuperBytes = data;
        trace(a);
        trace(a.padToBytes(128));
    }
}