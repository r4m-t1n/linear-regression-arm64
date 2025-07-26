.global back_propagation
.global optimize

.text
back_propagation:
    fmov s25, -2.0              // -2.0 to s25
    fsub s8, s4, s2             // error = y[i] - y_hat

    fmul s6, s8, s3             // dw = -2 * error * x[i]
    fmul s6, s6, s25

    fmul s7, s8, s25            // db = -2 * error

    ret

optimize:
    fmul s26, s23, s18
    fmul s27, s23, s19

    fsub s16, s16, s26          // w - (learning_rate * dw)
    fsub s17, s17, s27          // b - (learning_rate * db)

    ret
