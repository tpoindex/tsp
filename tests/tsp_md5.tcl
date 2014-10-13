tsp::proc tsp_md5_byte0 {i} {
    #tsp::procdef int -args int
    set i [expr {0xff & $i}]
    return $i
}
tsp::proc tsp_md5_byte1 {i} {
    #tsp::procdef int -args int
    set i [expr {(0xff00 & $i) >> 8}]
    return $i
}
tsp::proc tsp_md5_byte2 {i} {
    #tsp::procdef int -args int
    set i [expr {(0xff0000 & $i) >> 16}]
    return $i
}
tsp::proc tsp_md5_byte3 {i} {
    #tsp::procdef int -args int
    set i [expr {((0xff000000 & $i) >> 24) & 0xff}]
    return $i
}

tsp::proc tsp_md5_bytes {i} {
    #tsp::procdef string -args int
    #tsp::def string result
    #tsp::def int b0 b1 b2 b3
    set b0 [tsp_md5_byte0 $i]
    set b1 [tsp_md5_byte1 $i]
    set b2 [tsp_md5_byte2 $i]
    set b3 [tsp_md5_byte3 $i]
    set result [format %0.2x%0.2x%0.2x%0.2x $b0 $b1 $b2 $b3]
    return $result
}





tsp::proc tsp_md5 {msg} \{

    #tsp::procdef string -args string
    


	#
	# 3.1 Step 1. Append Padding Bits
	#

	set msgLen [string length $msg]

	set padLen [expr {56 - $msgLen%64}]
	if {$msgLen % 64 > 56} {
	    incr padLen 64
	}

	# pad even if no padding required
	if {$padLen == 0} {
	    incr padLen 64
	}

	# append single 1b followed by 0b's
	append msg [binary format "a$padLen" \200]

	#
	# 3.2 Step 2. Append Length
	#

	# RFC doesn't say whether to use little- or big-endian
	# code demonstrates little-endian
	# This step limits our input to size 2^32b or 2^24B
	append msg [binary format "i1i1" [expr {8*$msgLen}] 0]
	
	#
	# 3.3 Step 3. Initialize MD Buffer
	#

	set A [expr 0x67452301]
	set B [expr 0xefcdab89]
	set C [expr 0x98badcfe]
	set D [expr 0x10325476]

	#
	# 3.4 Step 4. Process Message in 16-Word Blocks
	#

	# process each 16-word block
	# RFC doesn't say whether to use little- or big-endian
	# code says little-endian
	binary scan $msg i* blocks

	# loop over the message taking 16 blocks at a time

	foreach {X0 X1 X2 X3 X4 X5 X6 X7 X8 X9 X10 X11 X12 X13 X14 X15} $blocks {

	    # Save A as AA, B as BB, C as CC, and D as DD.
	    set AA $A
	    set BB $B
	    set CC $C
	    set DD $D

	    # Round 1.
	    # Let [abcd k s i] denote the operation
	    #      a = b + ((a + F(b,c,d) + X[k] + T[i]) <<< s).
	    # [ABCD  0  7  1]  [DABC  1 12  2]  [CDAB  2 17  3]  [BCDA  3 22  4]
	    set A [expr {$B + (([set x [expr {$A + (($B & $C) | ((~$B) & $D)) + $X0  + 0xd76aa478}]] << 7) |  (($x >> 25) & 127))}]
	    set D [expr {$A + (([set x [expr {$D + (($A & $B) | ((~$A) & $C)) + $X1  + 0xe8c7b756}]] << 12) |  (($x >> 20) & 4095))}]
	    set C [expr {$D + (([set x [expr {$C + (($D & $A) | ((~$D) & $B)) + $X2  + 0x242070db}]] << 17) |  (($x >> 15) & 131071))}]
	    set B [expr {$C + (([set x [expr {$B + (($C & $D) | ((~$C) & $A)) + $X3  + 0xc1bdceee}]] << 22) |  (($x >> 10) & 4194303))}]
	    # [ABCD  4  7  5]  [DABC  5 12  6]  [CDAB  6 17  7]  [BCDA  7 22  8]
	    set A [expr {$B + (([set x [expr {$A + (($B & $C) | ((~$B) & $D)) + $X4  + 0xf57c0faf}]] << 7) |  (($x >> 25) & 127))}]
	    set D [expr {$A + (([set x [expr {$D + (($A & $B) | ((~$A) & $C)) + $X5  + 0x4787c62a}]] << 12) |  (($x >> 20) & 4095))}]
	    set C [expr {$D + (([set x [expr {$C + (($D & $A) | ((~$D) & $B)) + $X6  + 0xa8304613}]] << 17) |  (($x >> 15) & 131071))}]
	    set B [expr {$C + (([set x [expr {$B + (($C & $D) | ((~$C) & $A)) + $X7  + 0xfd469501}]] << 22) |  (($x >> 10) & 4194303))}]
	    # [ABCD  8  7  9]  [DABC  9 12 10]  [CDAB 10 17 11]  [BCDA 11 22 12]
	    set A [expr {$B + (([set x [expr {$A + (($B & $C) | ((~$B) & $D)) + $X8  + 0x698098d8}]] << 7) |  (($x >> 25) & 127))}]
	    set D [expr {$A + (([set x [expr {$D + (($A & $B) | ((~$A) & $C)) + $X9  + 0x8b44f7af}]] << 12) |  (($x >> 20) & 4095))}]
	    set C [expr {$D + (([set x [expr {$C + (($D & $A) | ((~$D) & $B)) + $X10 + 0xffff5bb1}]] << 17) |  (($x >> 15) & 131071))}]
	    set B [expr {$C + (([set x [expr {$B + (($C & $D) | ((~$C) & $A)) + $X11 + 0x895cd7be}]] << 22) |  (($x >> 10) & 4194303))}]
	    # [ABCD 12  7 13]  [DABC 13 12 14]  [CDAB 14 17 15]  [BCDA 15 22 16]
	    set A [expr {$B + (([set x [expr {$A + (($B & $C) | ((~$B) & $D)) + $X12 + 0x6b901122}]] << 7) |  (($x >> 25) & 127))}]
	    set D [expr {$A + (([set x [expr {$D + (($A & $B) | ((~$A) & $C)) + $X13 + 0xfd987193}]] << 12) |  (($x >> 20) & 4095))}]
	    set C [expr {$D + (([set x [expr {$C + (($D & $A) | ((~$D) & $B)) + $X14 + 0xa679438e}]] << 17) |  (($x >> 15) & 131071))}]
	    set B [expr {$C + (([set x [expr {$B + (($C & $D) | ((~$C) & $A)) + $X15 + 0x49b40821}]] << 22) |  (($x >> 10) & 4194303))}]

	    # Round 2.
	    # Let [abcd k s i] denote the operation
	    #      a = b + ((a + G(b,c,d) + X[k] + T[i]) <<< s).
	    # Do the following 16 operations.
	    # [ABCD  1  5 17]  [DABC  6  9 18]  [CDAB 11 14 19]  [BCDA  0 20 20]
	    set A [expr {$B + (([set x [expr {$A + (($B & $D) | ($C & (~$D))) + $X1  + 0xf61e2562}]] << 5) |  (($x >> 27) & 31))}]
	    set D [expr {$A + (([set x [expr {$D + (($A & $C) | ($B & (~$C))) + $X6  + 0xc040b340}]] << 9) |  (($x >> 23) & 511))}]
	    set C [expr {$D + (([set x [expr {$C + (($D & $B) | ($A & (~$B))) + $X11 + 0x265e5a51}]] << 14) |  (($x >> 18) & 16383))}]
	    set B [expr {$C + (([set x [expr {$B + (($C & $A) | ($D & (~$A))) + $X0  + 0xe9b6c7aa}]] << 20) |  (($x >> 12) & 1048575))}]
	    # [ABCD  5  5 21]  [DABC 10  9 22]  [CDAB 15 14 23]  [BCDA  4 20 24]
	    set A [expr {$B + (([set x [expr {$A + (($B & $D) | ($C & (~$D))) + $X5  + 0xd62f105d}]] << 5) |  (($x >> 27) & 31))}]
	    set D [expr {$A + (([set x [expr {$D + (($A & $C) | ($B & (~$C))) + $X10 + 0x2441453}]] << 9) |  (($x >> 23) & 511))}]
	    set C [expr {$D + (([set x [expr {$C + (($D & $B) | ($A & (~$B))) + $X15 + 0xd8a1e681}]] << 14) |  (($x >> 18) & 16383))}]
	    set B [expr {$C + (([set x [expr {$B + (($C & $A) | ($D & (~$A))) + $X4  + 0xe7d3fbc8}]] << 20) |  (($x >> 12) & 1048575))}]
	    # [ABCD  9  5 25]  [DABC 14  9 26]  [CDAB  3 14 27]  [BCDA  8 20 28]
	    set A [expr {$B + (([set x [expr {$A + (($B & $D) | ($C & (~$D))) + $X9  + 0x21e1cde6}]] << 5) |  (($x >> 27) & 31))}]
	    set D [expr {$A + (([set x [expr {$D + (($A & $C) | ($B & (~$C))) + $X14 + 0xc33707d6}]] << 9) |  (($x >> 23) & 511))}]
	    set C [expr {$D + (([set x [expr {$C + (($D & $B) | ($A & (~$B))) + $X3  + 0xf4d50d87}]] << 14) |  (($x >> 18) & 16383))}]
	    set B [expr {$C + (([set x [expr {$B + (($C & $A) | ($D & (~$A))) + $X8  + 0x455a14ed}]] << 20) |  (($x >> 12) & 1048575))}]
	    # [ABCD 13  5 29]  [DABC  2  9 30]  [CDAB  7 14 31]  [BCDA 12 20 32]
	    set A [expr {$B + (([set x [expr {$A + (($B & $D) | ($C & (~$D))) + $X13 + 0xa9e3e905}]] << 5) |  (($x >> 27) & 31))}]
	    set D [expr {$A + (([set x [expr {$D + (($A & $C) | ($B & (~$C))) + $X2  + 0xfcefa3f8}]] << 9) |  (($x >> 23) & 511))}]
	    set C [expr {$D + (([set x [expr {$C + (($D & $B) | ($A & (~$B))) + $X7  + 0x676f02d9}]] << 14) |  (($x >> 18) & 16383))}]
	    set B [expr {$C + (([set x [expr {$B + (($C & $A) | ($D & (~$A))) + $X12 + 0x8d2a4c8a}]] << 20) |  (($x >> 12) & 1048575))}]

	    # Round 3.
	    # Let [abcd k s t] [sic] denote the operation
	    #     a = b + ((a + H(b,c,d) + X[k] + T[i]) <<< s).
	    # Do the following 16 operations.
	    # [ABCD  5  4 33]  [DABC  8 11 34]  [CDAB 11 16 35]  [BCDA 14 23 36]
	    set A [expr {$B + (([set x [expr {$A + ($B ^ $C ^ $D) + $X5  + 0xfffa3942}]] << 4) |  (($x >> 28) & 15))}]
	    set D [expr {$A + (([set x [expr {$D + ($A ^ $B ^ $C) + $X8  + 0x8771f681}]] << 11) |  (($x >> 21) & 2047))}]
	    set C [expr {$D + (([set x [expr {$C + ($D ^ $A ^ $B) + $X11 + 0x6d9d6122}]] << 16) |  (($x >> 16) & 65535))}]
	    set B [expr {$C + (([set x [expr {$B + ($C ^ $D ^ $A) + $X14 + 0xfde5380c}]] << 23) |  (($x >> 9) & 8388607))}]
	    # [ABCD  1  4 37]  [DABC  4 11 38]  [CDAB  7 16 39]  [BCDA 10 23 40]
	    set A [expr {$B + (([set x [expr {$A + ($B ^ $C ^ $D) + $X1  + 0xa4beea44}]] << 4) |  (($x >> 28) & 15))}]
	    set D [expr {$A + (([set x [expr {$D + ($A ^ $B ^ $C) + $X4  + 0x4bdecfa9}]] << 11) |  (($x >> 21) & 2047))}]
	    set C [expr {$D + (([set x [expr {$C + ($D ^ $A ^ $B) + $X7  + 0xf6bb4b60}]] << 16) |  (($x >> 16) & 65535))}]
	    set B [expr {$C + (([set x [expr {$B + ($C ^ $D ^ $A) + $X10 + 0xbebfbc70}]] << 23) |  (($x >> 9) & 8388607))}]
	    # [ABCD 13  4 41]  [DABC  0 11 42]  [CDAB  3 16 43]  [BCDA  6 23 44]
	    set A [expr {$B + (([set x [expr {$A + ($B ^ $C ^ $D) + $X13 + 0x289b7ec6}]] << 4) |  (($x >> 28) & 15))}]
	    set D [expr {$A + (([set x [expr {$D + ($A ^ $B ^ $C) + $X0  + 0xeaa127fa}]] << 11) |  (($x >> 21) & 2047))}]
	    set C [expr {$D + (([set x [expr {$C + ($D ^ $A ^ $B) + $X3  + 0xd4ef3085}]] << 16) |  (($x >> 16) & 65535))}]
	    set B [expr {$C + (([set x [expr {$B + ($C ^ $D ^ $A) + $X6  + 0x4881d05}]] << 23) |  (($x >> 9) & 8388607))}]
	    # [ABCD  9  4 45]  [DABC 12 11 46]  [CDAB 15 16 47]  [BCDA  2 23 48]
	    set A [expr {$B + (([set x [expr {$A + ($B ^ $C ^ $D) + $X9  + 0xd9d4d039}]] << 4) |  (($x >> 28) & 15))}]
	    set D [expr {$A + (([set x [expr {$D + ($A ^ $B ^ $C) + $X12 + 0xe6db99e5}]] << 11) |  (($x >> 21) & 2047))}]
	    set C [expr {$D + (([set x [expr {$C + ($D ^ $A ^ $B) + $X15 + 0x1fa27cf8}]] << 16) |  (($x >> 16) & 65535))}]
	    set B [expr {$C + (([set x [expr {$B + ($C ^ $D ^ $A) + $X2  + 0xc4ac5665}]] << 23) |  (($x >> 9) & 8388607))}]

	    # Round 4.
	    # Let [abcd k s t] [sic] denote the operation
	    #     a = b + ((a + I(b,c,d) + X[k] + T[i]) <<< s).
	    # Do the following 16 operations.
	    # [ABCD  0  6 49]  [DABC  7 10 50]  [CDAB 14 15 51]  [BCDA  5 21 52]
	    set A [expr {$B + (([set x [expr {$A + ($C ^ ($B | (~$D))) + $X0  + 0xf4292244}]] << 6) |  (($x >> 26) & 63))}]
	    set D [expr {$A + (([set x [expr {$D + ($B ^ ($A | (~$C))) + $X7  + 0x432aff97}]] << 10) |  (($x >> 22) & 1023))}]
	    set C [expr {$D + (([set x [expr {$C + ($A ^ ($D | (~$B))) + $X14 + 0xab9423a7}]] << 15) |  (($x >> 17) & 32767))}]
	    set B [expr {$C + (([set x [expr {$B + ($D ^ ($C | (~$A))) + $X5  + 0xfc93a039}]] << 21) |  (($x >> 11) & 2097151))}]
	    # [ABCD 12  6 53]  [DABC  3 10 54]  [CDAB 10 15 55]  [BCDA  1 21 56]
	    set A [expr {$B + (([set x [expr {$A + ($C ^ ($B | (~$D))) + $X12 + 0x655b59c3}]] << 6) |  (($x >> 26) & 63))}]
	    set D [expr {$A + (([set x [expr {$D + ($B ^ ($A | (~$C))) + $X3  + 0x8f0ccc92}]] << 10) |  (($x >> 22) & 1023))}]
	    set C [expr {$D + (([set x [expr {$C + ($A ^ ($D | (~$B))) + $X10 + 0xffeff47d}]] << 15) |  (($x >> 17) & 32767))}]
	    set B [expr {$C + (([set x [expr {$B + ($D ^ ($C | (~$A))) + $X1  + 0x85845dd1}]] << 21) |  (($x >> 11) & 2097151))}]
	    # [ABCD  8  6 57]  [DABC 15 10 58]  [CDAB  6 15 59]  [BCDA 13 21 60]
	    set A [expr {$B + (([set x [expr {$A + ($C ^ ($B | (~$D))) + $X8  + 0x6fa87e4f}]] << 6) |  (($x >> 26) & 63))}]
	    set D [expr {$A + (([set x [expr {$D + ($B ^ ($A | (~$C))) + $X15 + 0xfe2ce6e0}]] << 10) |  (($x >> 22) & 1023))}]
	    set C [expr {$D + (([set x [expr {$C + ($A ^ ($D | (~$B))) + $X6  + 0xa3014314}]] << 15) |  (($x >> 17) & 32767))}]
	    set B [expr {$C + (([set x [expr {$B + ($D ^ ($C | (~$A))) + $X13 + 0x4e0811a1}]] << 21) |  (($x >> 11) & 2097151))}]
	    # [ABCD  4  6 61]  [DABC 11 10 62]  [CDAB  2 15 63]  [BCDA  9 21 64]
	    set A [expr {$B + (([set x [expr {$A + ($C ^ ($B | (~$D))) + $X4  + 0xf7537e82}]] << 6) |  (($x >> 26) & 63))}]
	    set D [expr {$A + (([set x [expr {$D + ($B ^ ($A | (~$C))) + $X11 + 0xbd3af235}]] << 10) |  (($x >> 22) & 1023))}]
	    set C [expr {$D + (([set x [expr {$C + ($A ^ ($D | (~$B))) + $X2  + 0x2ad7d2bb}]] << 15) |  (($x >> 17) & 32767))}]
	    set B [expr {$C + (([set x [expr {$B + ($D ^ ($C | (~$A))) + $X9  + 0xeb86d391}]] << 21) |  (($x >> 11) & 2097151))}]

	    # Then perform the following additions. (That is increment each
	    #   of the four registers by the value it had before this block
	    #   was started.)
	    incr A $AA
	    incr B $BB
	    incr C $CC
	    incr D $DD
	}
	# 3.5 Step 5. Output

	# ... begin with the low-order byte of A, and end with the high-order byte
	# of D.

	return [bytes $A][bytes $B][bytes $C][bytes $D]
    
}


proc ::md5::hmac {key text} {
    # if key is longer than 64 bytes, reset it to MD5(key).  If shorter, 
    # pad it out with null (\x00) chars.
    set keyLen [string length $key]
    if {$keyLen > 64} {
	set key [binary format H32 [md5 $key]]
	set keyLen [string length $key]
    }

    # ensure the key is padded out to 64 chars with nulls.
    set padLen [expr {64 - $keyLen}]
    append key [binary format "a$padLen" {}]
    
    # Split apart the key into a list of 16 little-endian words
    binary scan $key i16 blocks

    # XOR key with ipad and opad values
    set k_ipad {}
    set k_opad {}
    foreach i $blocks {
	append k_ipad [binary format i [expr {$i ^ 0x36363636}]]
	append k_opad [binary format i [expr {$i ^ 0x5c5c5c5c}]]
    }

    # Perform inner md5, appending its results to the outer key
    append k_ipad $text
    append k_opad [binary format H* [md5 $k_ipad]]

    # Perform outer md5
    md5 $k_opad
}
