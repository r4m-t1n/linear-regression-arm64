.global back_propagation
.global optimize

.text
back_propagation:

    bl linear_model        // goes to model.s and calculates the y_hat in s14

    fmov s7, -2.0          // -2.0 to s7
    fsub s8, s11, s14      // error = y[i] - y_hat

    fmul s16, s8, s10      // dw = -2 * error * x[i]
    fmul s16, s16, s7

    fmul s17, s8, s7       // db = -2 * error

    ret

optimize:

    fmul s5, s9, s16
    fmul s6, s9, s17

    fsub s12, s12, s5     // w - (learning_rate * dw)
    fsub s13, s13, s6     // b - (learning_rate * db)

    ret
