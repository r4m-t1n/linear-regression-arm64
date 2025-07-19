.global linear_model

.text
linear_model:
    fmul s14, s12, s10
    fadd s14, s14, s13

    ret
