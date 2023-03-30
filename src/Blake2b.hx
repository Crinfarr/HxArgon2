import haxe.io.Bytes;
import haxe.ds.Vector;
import helpers.SuperBytes;

class Blake2b {
    @:access
	private final IV:Vector<SuperBytes> = Vector.fromArrayCopy([
		SuperBytes.fromHexString("6a09e667f3bcc908"),
		SuperBytes.fromHexString("bb67ae8584caa73b"),
		SuperBytes.fromHexString("3c6ef372fe94f82b"),
		SuperBytes.fromHexString("a54ff53a5f1d36f1"),
		SuperBytes.fromHexString("510e527fade682d1"),
		SuperBytes.fromHexString("9b05688c2b3e6c1f"),
		SuperBytes.fromHexString("1f83d9abfb41bd6b"),
		SuperBytes.fromHexString("5be0cd19137e2179")
	]);
    @:access
	final delta:Vector<Vector<Int>> = Vector.fromArrayCopy([
		Vector.fromArrayCopy([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
		Vector.fromArrayCopy([14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3]),
		Vector.fromArrayCopy([11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4]),
		Vector.fromArrayCopy([7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8]),
		Vector.fromArrayCopy([9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13]),
		Vector.fromArrayCopy([2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9]),
		Vector.fromArrayCopy([12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11]),
		Vector.fromArrayCopy([13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10]),
		Vector.fromArrayCopy([6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5]),
		Vector.fromArrayCopy([10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0])
	]);

    private static function mix(vA:SuperBytes, vB:SuperBytes, vC:SuperBytes, vD:SuperBytes, x:SuperBytes, y:SuperBytes):Vector<SuperBytes> {
        // vA = vA+vB+x;
        return new Vector<SuperBytes>(4);//HACK STOP YELLING AT ME FORMATTER
    }
}
