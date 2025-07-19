.global mean_squared_error

.text
mean_squared_error:
    fsub s15, s11, s14
    fmul s15, s15, s15

    ret
