tsp::proc tsp_hmac {key text} {
    #tsp::procdef var -args var var
    #tsp::int keyLen msgLen padLen i
    #tsp::var blocks k_ipad k_opad

    # if key is longer than 64 bytes, reset it to MD5(key).  If shorter, 
    # pad it out with null (\x00) chars.
    set keyLen [string length $key]
    if {$keyLen > 64} {
        set key [binary format H32 [tsp_md5 $key]]
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
    append k_opad [binary format H* [tsp_md5 $k_ipad]]

    # Perform outer md5
    return [tsp_md5 $k_opad]
}
