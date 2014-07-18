package tsp.util;

import java.util.Random;
import tcl.lang.TclException;

public class TspFunc {
    // since we don't have access to interp, we have to throw a
    // TclException without an interp. use a specific string
    // to signify divide by zero and domain error
    public static final String DIVIDE_BY_ZERO = "tsp: divide by zero";
    public static final String DOMAIN_ERROR = "tsp: domain error";

    // we need our own private Random so we can seed it with srand()
    private static final Random randomInstance = new Random();

    public static long    IntDiv(long dividend, long divisor) throws TclException {
        // Note - this basically comes directly from tcl.lang.Expression

        if (divisor == 0) {
            throw new TclException(null, DIVIDE_BY_ZERO);
        }

        long quotient = 0;

        if (dividend == Long.MIN_VALUE && divisor == -1) {
            // Avoid integer overflow on (Long.MIN_VALUE / -1)
            quotient = Long.MIN_VALUE;
        } else {
            quotient = dividend / divisor;
            // Round down to a smaller negative number if
            // there is a remainder and the quotient is
            // negative or zero and the signs don't match.
            if (((quotient < 0) || ((quotient == 0) && (((dividend < 0) && (divisor > 0)) || ((dividend > 0) 
                    && (divisor < 0))))) && ((quotient * divisor) != dividend)) {
                quotient -= 1;
            }
        }
        return quotient;
    }

    public static long    IntMod(long dividend, long divisor) throws TclException {
        // Note - this basically comes directly from tcl.lang.Expression

        if (divisor == 0) {
            throw new TclException(null, DIVIDE_BY_ZERO);
        }

        long remainder = 0;
        boolean neg_divisor = false;

        if (dividend == Long.MIN_VALUE && divisor == -1) {
            remainder = 0;
        } else {
            if (divisor < 0) {
                divisor = -divisor;
                dividend = -dividend;
                neg_divisor = true;
            }
            remainder = dividend % divisor;
            if (remainder < 0
                    && !(neg_divisor && (dividend == Long.MIN_VALUE))) {
                remainder += divisor;
            }
        }
        if ((neg_divisor && (remainder > 0))
                    || (!neg_divisor && (remainder < 0))) {
            remainder = -remainder;
        }
        return remainder;
    }

    public static double  DoubleDiv(double x, double y) throws TclException {
        if (y == 0.0) {
            throw new TclException(null, DIVIDE_BY_ZERO);
        } else {
            return x / y;
        }
    }

    public static boolean StringLt(String s1, String s2) {
        return s1.compareTo(s2) < 0;
    }

    public static boolean StringGt(String s1, String s2) {
        return s1.compareTo(s2) > 0;
    }

    public static boolean StringLe(String s1, String s2) {
        return s1.compareTo(s2) <= 0;
    }

    public static boolean StringGe(String s1, String s2) {
        return s1.compareTo(s2) >= 0;
    }

    public static boolean StringEq(String s1, String s2) {
        return s1.compareTo(s2) == 0;
    }

    public static boolean StringNe(String s1, String s2) {
        return s1.compareTo(s2) != 0;
    }

    public static long    IntAbs(long i) {
        return Math.abs(i);
    }

    public static double  DoubleAbs(double x) {
        return Math.abs(x);
    }

    public static double  Acos(double x) {
        return Math.acos(x);
    }

    public static double  Asin(double x) {
        return Math.asin(x);
    }

    public static double  Atan(double x) {
        return Math.atan(x);
    }

    public static double  Atan2(double x, double y) throws TclException {
        if ((y == 0.0) && (x == 0.0)) {
            throw new TclException(null, DOMAIN_ERROR);
        }
        return Math.atan2(x, y);
    }

    public static double  Ceil(double x) {
        return Math.ceil(x);
    }

    public static double  Cos(double x) {
        return Math.cos(x);
    }

    public static double  Cosh(double x) {
        return Math.cosh(x);
    }

    public static double  Exp(double x) {
        return Math.exp(x);
    }

    public static double  Floor(double x) {
        return Math.floor(x);
    }

    public static double  Fmod(double x, double y) throws TclException {
        if (y == 0.0) {
            throw new TclException(null, DIVIDE_BY_ZERO);
        }
        return x % y;
    }

    public static double  Hypot(double x, double y) {
        return Math.hypot(x, y);
    }

    public static double  Log(double x) throws TclException {
        if (x < 0.0) {
            throw new TclException(null, DOMAIN_ERROR);
        }
        return Math.log(x);
    }

    public static double  Log10(double x) throws TclException {
        if (x < 0.0) {
            throw new TclException(null, DOMAIN_ERROR);
        }
        return Math.log10(x);
    }

    public static double  DoublePow(double x, double y) throws TclException {
        if (x < 0.0) {
            throw new TclException(null, DOMAIN_ERROR);
        }
        return Math.pow(x, y);
    }

    public static double  DoubleIntPow(double x, long j) {
        return Math.pow(x, (double) j);
    }

    public static double  Rand() {
        return randomInstance.nextDouble();
    }

    public static double  Round(double x) {
        return Math.round(x);
    }

    public static double  Sin(double x) {
        return Math.sin(x);
    }

    public static double  Sinh(double x) {
        return Math.sinh(x);
    }

    public static double  Sqrt(double x) {
        return Math.sqrt(x);
    }

    public static double  IntSrand(long i) {
        randomInstance.setSeed(i);
        return randomInstance.nextDouble();
    }

    public static double  Tan(double x) {
        return Math.tan(x);
    }

    public static double  Tanh(double x) {
        return Math.tanh(x);
    }

}

