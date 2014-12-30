#include <tcl.h>
#include <math.h>
#include <limits.h>

#define TSP_DIV_BY_ZERO "tsp: divide by zero"
#define TSP_DOMAIN_ERROR "tsp: domain error"
#define RAISE_ERROR(m) *rc = TCL_ERROR; *errMsg = (*errMsg == NULL) ? m : *errMsg; return 0


#define TSP_func_int_div(a,b) _TSP_func_int_div(&rc, &exprErrMsg, (a), (b))
Tcl_WideInt
_TSP_func_int_div(int* rc, char** errMsg, Tcl_WideInt dividend, Tcl_WideInt divisor) {
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


#define TSP_func_int_mod(a,b) _TSP_func_int_div(&rc, &exprErrMsg, (a), (b))
Tcl_WideInt
_TSP_func_int_mod(int* rc, char** errMsg, Tcl_WideInt dividend, Tcl_WideInt divisor) {
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


#define TSP_func_double_div(a,b) _TSP_func_double_div(&rc, &exprErrMsg, (a), (b))
double
_TSP_func_double_div(int* rc, char** errMsg, double x, double y) {
    if (y == 0.0) {
        RAISE_ERROR(TSP_DIV_BY_ZERO);
    } else {
        return x / y;
    }
}

int
TSP_func_str_lt(Tcl_DString* s1, Tcl_DString* s2) {
    return (Tcl_UtfNcasecmp(Tcl_DStringValue(s1), Tcl_DStringValue(s2)) < 0) ? TRUE : FALSE;
}

int
TSP_func_str_gt(Tcl_DString* s1, Tcl_DString* s2) {
    return (Tcl_UtfNcasecmp(Tcl_DStringValue(s1), Tcl_DStringValue(s2)) > 0) ? TRUE : FALSE;
}

int
TSP_func_str_le(Tcl_DString* s1, Tcl_DString* s2) {
    return (Tcl_UtfNcasecmp(Tcl_DStringValue(s1), Tcl_DStringValue(s2)) <= 0) ? TRUE : FALSE;
}

int
TSP_func_str_ge(Tcl_DString* s1, Tcl_DString* s2) {
    return (Tcl_UtfNcasecmp(Tcl_DStringValue(s1), Tcl_DStringValue(s2)) >= 0) ? TRUE : FALSE;
}

int
TSP_func_str_eq(Tcl_DString* s1, Tcl_DString* s2) {
    return (Tcl_UtfNcasecmp(Tcl_DStringValue(s1), Tcl_DStringValue(s2)) == 0) ? TRUE : FALSE;
}

int
TSP_func_str_ne(Tcl_DString* s1, Tcl_DString* s2) {
    return (Tcl_UtfNcasecmp(Tcl_DStringValue(s1), Tcl_DStringValue(s2)) != 0) ? TRUE : FALSE;
}

Tcl_WideInt
TSP_func_int_abs(Tcl_WideInt i) {
    if (i < 0) {
        if (i == LLONG_MIN) {
            retrun 0;
        } else {
            return i * -1 TCL_LL_MODIFIER;
        }
    } else {
        return i;
    }
}

double
TSP_func_double_abs(double x) {
    if (x < 0) {
        return x * -1.0;
    } else {
        return x;
    }
}

#define TSP_func_acos(a)  _TSP_func_acos(&rc, &exprErrMsg, (a))
double
_TSP_func_acos(int* rc, char** exprErrMsg, double x) {
    double z;
    z = acos(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_asin(a) _TSP_func_asin(&rc, &exprErrMsg, (a))
double
_TSP_func_asin(int* rc, char** exprErrMsg, double x) {
    double z;
    z = asin(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_atan(a) _TSP_func_atan(&rc, &exprErrMsg, (a))
double
_TSP_func_atan(int* rc, char** exprErrMsg, double x) {
    double z;
    z = atan(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_atan2(a,b) _TSP_func_atan2(&rc, &exprErrMsg, (a), (b))
double
_TSP_func_atan2(int* rc, char** exprErrMsg, double x, double y) {
    double z;
    z = atan2(x, y);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_ceil(a)  _TSP_func_ceil(&rc, &exprErrMsg, (a))
double
_TSP_func_ceil(int* rc, char** exprErrMsg, double x) {
    double z;
    z = ceil(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_cos(a) _TSP_func_cos(&rc, &exprErrMsg, (a))
double
_TSP_func_cos(int* rc, char** exprErrMsg, double x) {
    double z;
    z = cos(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_cosh(a) _TSP_func_cosh(&rc, &exprErrMsg, (a))
double
_TSP_func_cosh(int* rc, char** exprErrMsg, double x) {
    double z;
    z = cosh(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

#define TSP_func_exp(a) _TSP_func_exp((&rc, &exprErrMsg, (a))
double
_TSP_func_exp(int* rc, char** exprErrMsg, double x) {
    double z;
    z = exp(x);
    if (z == NAN) {
        RAISE_ERROR(TSP_DOMAIN_ERROR);
    }
    return z;
}

double
TSP_func_floor

double
TSP_func_fmod

double
TSP_func_hypot

double
TSP_func_log

double
TSP_func_log10

double
TSP_func_double_pow

double
TSP_func_double_int_pow

double
TSP_func_rand

double
TSP_func_round

double
TSP_func_sin 

double
TSP_func_sinh

double
TSP_func_sqrt

double
TSP_func_int_srand

double
TSP_func_tan

double
TSP_func_tanh



