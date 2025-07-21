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
    stp x29, x30, [sp, -16]!    // save frame pointer and link register
    mov x29, sp

    fmul s26, s23, s18
    fmul s27, s23, s19

    fsub s16, s16, s26          // w - (learning_rate * dw)
    fsub s17, s17, s27          // b - (learning_rate * db)

    ldp x29, x30, [sp], #16     // restore fp and lr

    ret
