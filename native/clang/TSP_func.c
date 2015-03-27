#ifndef _TCL
#include <tcl.h>
#endif

#ifndef _MATH_H
#include <math.h>
#endif

#ifndef _LIBC_LIMITS_H_
#include <limits.h>
#endif


#define TRUE 1
#define FALSE 0
#define TSP_DIV_BY_ZERO "tsp: divide by zero"
#define TSP_DOMAIN_ERROR "tsp: domain error"

/* only record the first error */
#define RAISE_ERROR(m) *rc = TCL_ERROR; if (*exprErrMsg == NULL) *exprErrMsg = m; return 0

#define CHECK_NAN(a) if (a == NAN) return NAN

/* functions that can raise errors have macros to add rc and exprErrMsg parameters */

#define TSP_func_int_div(a,b) _TSP_func_int_div(rc, &exprErrMsg, (a), (b))
Tcl_WideInt
_TSP_func_int_div(int* rc, char** exprErrMsg, Tcl_WideInt dividend, Tcl_WideInt divisor) {
    Tcl_WideInt quotient;

    if (divisor == 0) {
        RAISE_ERROR(TSP_DIV_BY_ZERO);
    }
    if (dividend == LLONG_MIN && divisor == -1) {
        /* Avoid integer overflow on (Long.MIN_VALUE / -1) */
        quotient = LLONG_MIN;
    } else {
        quotient = dividend / divisor;
        /* Round down to a smaller negative number if  */
        /* there is a remainder and the quotient is    */
        /* negative or zero and the signs don't match. */
        if (((quotient < 0) || ((quotient == 0) && (((dividend < 0) && (divisor > 0)) || ((dividend > 0)
                    && (divisor < 0))))) && ((quotient * divisor) != dividend)) {
            quotient -= 1;
        }
    }
    return quotient;
}


#define TSP_func_int_mod(a,b) _TSP_func_int_div(rc, &exprErrMsg, (a), (b))
Tcl_WideInt
_TSP_func_int_mod(int* rc, char** exprErrMsg, Tcl_WideInt dividend, Tcl_WideInt divisor) {
    Tcl_WideInt remainder = 0;
    int neg_divisor = 0;

    if (divisor == 0) {
        RAISE_ERROR(TSP_DIV_BY_ZERO);
    }

    if (dividend == LLONG_MIN && divisor == -1) {
        remainder = 0;
    } else {
        if (divisor < 0) {
            divisor = -divisor;
            dividend = -dividend;
            neg_divisor = 1;
        }
        remainder = dividend % divisor;
        if (remainder < 0
                && !(neg_divisor && (dividend == LLONG_MIN))) {
            remainder += divisor;
        }
    }
    if ((neg_divisor && (remainder > 0))
                || (!neg_divisor && (remainder < 0))) {
        remainder = -remainder;
    }
    return remainder;
}


#define TSP_func_double_div(a,b) _TSP_func_double_div(rc, &exprErrMsg, (a), (b))
double
_TSP_func_double_div(int* rc, char** exprErrMsg, double x, double y) {
    CHECK_NAN(x);
    CHECK_NAN(y);
    if (y == 0.0) {
        RAISE_ERROR(TSP_DIV_BY_ZERO);
    } else {
        return x / y;
    }
}

int
TSP_func_util_strcmp(Tcl_DString* s1, Tcl_DString* s2) {
    int match;
    int length1 = Tcl_DStringLength(s1);
    int length2 = Tcl_DStringLength(s2);
    length1 = Tcl_NumUtfChars(Tcl_DStringValue(s1), length1);
    length2 = Tcl_NumUtfChars(Tcl_DStringValue(s2), length2);
    match = Tcl_UtfNcmp(Tcl_DStringValue(s1), Tcl_DStringValue(s2), (length1 < length2) ? length1 : length2);
    if (match == 0) {
        return length1 - length2;
    } else {
        return match;
    }
}

int
TSP_func_str_lt(Tcl_DString* s1, Tcl_DString* s2) {
    return (TSP_func_util_strcmp(s1, s2) < 0) ? TRUE : FALSE;
}

int
TSP_func_str_gt(Tcl_DString* s1, Tcl_DString* s2) {
    return (TSP_func_util_strcmp(s1, s2) > 0) ? TRUE : FALSE;
}

int
TSP_func_str_le(Tcl_DString* s1, Tcl_DString* s2) {
    return (TSP_func_util_strcmp(s1, s2) <= 0) ? TRUE : FALSE;
}

int
TSP_func_str_ge(Tcl_DString* s1, Tcl_DString* s2) {
    return (TSP_func_util_strcmp(s1, s2) >= 0) ? TRUE : FALSE;
}

int
TSP_func_str_eq(Tcl_DString* s1, Tcl_DString* s2) {
    return (TSP_func_util_strcmp(s1, s2) == 0) ? TRUE : FALSE;
}

int
TSP_func_str_ne(Tcl_DString* s1, Tcl_DString* s2) {
    return (TSP_func_util_strcmp(s1, s2) != 0) ? TRUE : FALSE;
}

Tcl_WideInt
TSP_func_int_abs(Tcl_WideInt i) {
    if (i < 0) {
        if (i == LLONG_MIN) {
            return 0;
        } else {
            return i * -1;
        }
    } else {
        return i;
    }
}

double
TSP_func_double_abs(double x) {
    CHECK_NAN(x);
    if (x < 0) {
        return x * -1.0;
    } else {
        return x;
    }
}

#define TSP_func_acos(a)  _TSP_func_acos(rc, &exprErrMsg, (a))
double
_TSP_func_acos(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = acos(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_asin(a) _TSP_func_asin(rc, &exprErrMsg, (a))
double
_TSP_func_asin(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = asin(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_atan(a) _TSP_func_atan(rc, &exprErrMsg, (a))
double
_TSP_func_atan(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = atan(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_atan2(a,b) _TSP_func_atan2(rc, &exprErrMsg, (a), (b))
double
_TSP_func_atan2(int* rc, char** exprErrMsg, double x, double y) {
    double z;
    CHECK_NAN(x);
    CHECK_NAN(y);
    z = atan2(x, y);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_ceil(a)  _TSP_func_ceil(rc, &exprErrMsg, (a))
double
_TSP_func_ceil(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = ceil(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_cos(a) _TSP_func_cos(rc, &exprErrMsg, (a))
double
_TSP_func_cos(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = cos(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_cosh(a) _TSP_func_cosh(rc, &exprErrMsg, (a))
double
_TSP_func_cosh(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = cosh(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_exp(a) _TSP_func_exp(rc, &exprErrMsg, (a))
double
_TSP_func_exp(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = exp(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_floor(a) _TSP_func_floor(rc, &exprErrMsg, (a))
double
_TSP_func_floor(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = floor(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_fmod(a) _TSP_func_fmod(rc, &exprErrMsg, (a), (b))
double
_TSP_func_fmod(int* rc, char** exprErrMsg, double x, double y) {
    double z;
    CHECK_NAN(x);
    CHECK_NAN(y);
    z = fmod(x, y);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_hypot(a,b) _TSP_func_hypot(rc, &exprErrMsg, (a), (b))
double
_TSP_func_hypot(int* rc, char** exprErrMsg, double x, double y) {
    double z;
    CHECK_NAN(x);
    CHECK_NAN(y);
    z = hypot(x, y);
    if (z == NAN || z == HUGE_VAL) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_log(a) _TSP_func_log(rc, &exprErrMsg, (a))
double
_TSP_func_log(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = log(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_log10(a) _TSP_func_log10(rc, &exprErrMsg, (a))
double
_TSP_func_log10(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = log(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_pow(a,b) _TSP_func_pow(rc, &exprErrMsg, (a), (b))
double
_TSP_func_double_pow(int* rc, char** exprErrMsg, double x, double y) {
    double z;
    CHECK_NAN(x);
    CHECK_NAN(y);
    z = pow(x, y);
    if (z == NAN || z == HUGE_VAL) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_int_pow(a,b) _TSP_func_int_pow(rc, &exprErrMsg, (a), (b))
double
_TSP_func_double_int_pow(int* rc, char** exprErrMsg, double x, Tcl_WideInt y) {
    double z;
    CHECK_NAN(x);
    z = pow(x, (double) y);
    if (z == NAN || z == HUGE_VAL) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}


double
TSP_func_rand() {
    return drand48(); 
}

double
TSP_func_round(double x) {
    return round(x);
}

#define TSP_func_sin(a) _TSP_func_sin(rc, &exprErrMsg, (a))
double
_TSP_func_sin(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = sin(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_sinh(a) _TSP_func_sin(rc, &exprErrMsg, (a))
double
_TSP_func_sinh(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = sinh(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_sqrt(a) _TSP_func_sqrt(rc, &exprErrMsg, (a))
double
_TSP_func_sqrt(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = sqrt(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

double
TSP_func_int_srand(Tcl_WideInt i) {
    srand48((long) i);
    return drand48();
}

#define TSP_func_tan(a) _TSP_func_tan(rc, &exprErrMsg, (a))
double
_TSP_func_tan(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = tan(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_tanh(a) _TSP_func_tanh(rc, &exprErrMsg, (a))
double
_TSP_func_tanh(int* rc, char** exprErrMsg, double x) {
    double z;
    CHECK_NAN(x);
    z = tanh(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}



