.global normalize_array

.text
normalize_array:

    lsl x1, x0, 2
    ldr s3, [x10, x1]

    fmul s3, s3, s29

    str s3, [x10, x1]

    add x0, x0, 1
    cmp x0, x19
    blt normalize_array

    ret
