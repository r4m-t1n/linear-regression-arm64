.global linear_model

.text
linear_model:
    fmul s2, s0, s3
    fadd s2, s2, s1

    ret
