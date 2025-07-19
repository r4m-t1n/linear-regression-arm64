.global main

.data
x:                  .float 35.7, 55.9, 58.2, 81.9, 56.3, 48.9, 33.9, 21.8, 48.4, 60.4, 68.4
y:                  .float 0.5,  14.0, 15.0, 28.0, 11.0,  8.0,  3.0, -4.0,  6.0, 13.0, 21.0

weight_:            .float 0.0
bias_:              .float 0.0

sample_size:        .float 11.0
learning_rate:      .float 0.01
epochs:             .word 100

epoch_string:       .asciz "Epoch %d, weight: %.2f, bias: %.2f, loss: %.3f\n"

zero_float:         .float 0.0

.text
main:
    adr x9, learning_rate         // address of learning_rate to x9
    ldr s9, [x9]                  // number of learning_rate to s9

    adr x10, x                    // address of array x
    adr x11, y                    // address of array y

    adr x12, weight_              // address of weight_ buffer to x12
    ldr s12, [x12]                // number of weight_ to s12
    adr x13, bias_                // address of bias_ buffer to x13
    ldr s13, [x13]                // number of bias_ to s13

    adr x18, sample_size          // address of sample_size to s18
    ldr s19, [x18]                // number of sample_size to s18

    adr x4, epochs                // address of epochs buffer to x4
    ldr w4, [x4]                  // number of epochs to w4

    mov w1, 0                     // index of train_loop from 0 to epochs
    b train_loop

train_loop:
    adr x0, zero_float            // address of zero_float to s0
    ldr s25, [x0]                 // number of zero_flat to s25

    fmov s20, s25                 // sum of derivatives of weight
    fmov s21, s25                 // sum of derivatives of bias
    fmov s22, s25                 // total loss

    mov w5, 0                     // index of forward_loop from 0 to sample
    mov x5, 0

    bl forward_loop

    fdiv s20, s20, s19
    fdiv s21, s21, s19
    bl optimize

    adr x0, epoch_string          // address of epoch_string
    mov w1, w1                    // not necessary but to know that the second argument is for epoch number
    fmov s0, s12                  // weight
    fmov s1, s13                  // bias
    fdiv s2, s22, s19             // loss
    bl printf

    add w1, w1, 1
    cmp w1, w4
    blt train_loop

    b exit


forward_loop:
    lsl x1, x5, 2
    ldr s10, [x10, x1]            // s10 = x[i]
    ldr s11, [x11, x1]            // s11 = y[i]

    bl back_propagation
    fadd s20, s20, s16            // with s16 being the derivative of weight, calculated from optimizer.s file
    fadd s21, s21, s17            // with s17 being the derivative of bias, calculated from optimizer.s file

    bl linear_model               // goes to model.s and calculates the y_hat in s14

    bl mean_squared_error         // goes to loss.s and calculates the loss in s15

    fadd s22, s22, s15            // adds the calculated loss to the total loss

    add w5, w5, 1
    add x5, x5, 1
    scvtf s24, w5
    fcmp s24, s19                 // s19 = sample_size
    blt forward_loop

    ret

exit:
    mov x0, 0
    mov x8, 93
    svc 0
