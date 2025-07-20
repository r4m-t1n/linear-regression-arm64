.global mean_squared_error

.text
mean_squared_error:
    fsub s5, s4, s2
    fmul s5, s5, s5

    ret
