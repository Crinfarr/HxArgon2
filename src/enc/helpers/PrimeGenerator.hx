package enc.helpers;

import haxe.Exception;

class PrimeGenerator {
    private static final A249270:Float=2.920050977316134;
    //^^ decimal expansion of lim_{n->inf} (1/n)Sum_{k=1..n}([largest prime k cannot be divided by])
    //aka OLIS A249270
    //I can't fit a lot of it into a haxe float
    private static function _nthprime(n:Int):Float {
        if (n==1) return A249270;
        var n_1 = _nthprime(n-1);
        return (Math.floor(n_1)*(n_1-Math.floor(n_1)+1));
    }
    public static function nthPrime(n:Int):Int {
        if (n<=0) throw new Exception('Cannot generate ${n}th prime');
        if (n>=14) trace("WARNING: GENERATING PRIMES PAST 41 IS !!INACCURATE!! and !!SHOULD NOT BE DONE WITH THIS FUNCTION!!");
        return Math.floor(
            _nthprime(n)
        );
    }
}