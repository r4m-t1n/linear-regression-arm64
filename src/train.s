.global main

.data
x_ptr:              .quad 0
y_ptr:              .quad 0

weight_:            .float 1.0
bias_:              .float 0.0

sample_size:        .word 0
learning_rate:      .float 0.01
epochs:             .word 100

filename:           .asciz "data.csv"
epoch_string:       .asciz "Epoch %d, weight: %.4f, bias: %.4f, loss: %.4f\n"

zero_float:         .float 0.0

norm_constant:      .float 0.1

.text
main:
    ldr x9, =learning_rate         // address of learning_rate to x9
    ldr s23, [x9]                  // number of learning_rate to s9

    adr x0, filename               // address of filename
    ldr x1, =x_ptr                 // address of pointer x
    ldr x2, =y_ptr                 // address of pointer y
    ldr x3, =sample_size           // address of sample_size
    bl read_csv

    ldr x18, =sample_size          // address of sample_size to s18
    ldr s24, [x18]                 // number of sample_size to s18

    ldr x10, =x_ptr
    ldr x10, [x10]                 // address of array x
    
    ldr x11, =y_ptr
    ldr x11, [x11]                 // address of array y

    ldr x5, =norm_constant         // a constant for normalizing x array
    ldr s29, [x5]

    fcvtzs x19, s24                // convert sample size to int

    bl normalize_array

    ldr x12, =weight_              // address of weight_ buffer to x12
    ldr s16, [x12]                 // number of weight_ to s16
    ldr x13, =bias_                // address of bias_ buffer to x13
    ldr s17, [x13]                 // number of bias_ to s17

    ldr x4, =epochs                // address of epochs buffer to x4
    ldr w19, [x4]                  // number of epochs to w4

    mov w20, 0                     // index of train_loop from 0 to epochs
    b train_loop

train_loop:
    add w20, w20, 1

    adr x0, zero_float             // address of zero_float to s0
    ldr s25, [x0]                  // number of zero_flat to s25

    fmov s18, s25                  // sum of derivatives of weight
    fmov s19, s25                  // sum of derivatives of bias
    fmov s20, s25                  // total loss

    mov x0, 0                      // index of forward_loop from 0 to sample_size

    bl forward_loop

    fdiv s18, s18, s24             // mean of dw
    fdiv s19, s19, s24             // mean of db

    bl optimize

    mov w21, 10
    udiv w22, w20, w21             // w22 = w20 / 10
    msub w23, w22, w21, w20        // w23 = w20 % 10

    cmp w23, 0                    // If w23 != 0, skip printing
    bne skip_epoch_print

    // save registers:
    stp x29, x30, [sp, -112]!      // save fp and lr, allocate 112 bytes for registers
    mov x29, sp                    // update fp

    stp x9, x10, [sp, 16]          // x9 (learning_rate address), x10 (x array address)
    stp x11, x12, [sp, 32]         // x11 (y array address), x12 (weight_ address)
    stp x13, x18, [sp, 48]         // x13 (bias_ address), x18 (sample_size address)
    str w20, [sp, 64]              // w20 (epoch)
    str w19, [sp, 68]              // w19 (epochs)

    stp s16, s17, [sp, 72]         // s16 (weight), s17 (bias)
    stp s18, s19, [sp, 88]         // s18 (sum of dw), s19 (sum of db)
    stp s20, s23, [sp, 104]        // s20 (total loss), s23 (learning_rate)
    str s24, [sp, 120]             // s24 (sample_size)

    fdiv s2, s20, s24              // calculate mean of total loss
    adr x0, epoch_string           // address of epoch_string
    mov w1, w20                    // epoch
    fcvt d0, s16                   // weight
    fcvt d1, s17                   // bias
    fcvt d2, s2                    // loss
    bl printf

    // restore registers:
    ldr s24, [sp, 120]
    ldp s20, s23, [sp, 104]
    ldp s18, s19, [sp, 88]
    ldp s16, s17, [sp, 72]

    ldr w19, [sp, 68]
    ldr w20, [sp, 64]
    ldp x13, x18, [sp, 48]
    ldp x11, x12, [sp, 32]
    ldp x9, x10, [sp, 16]

    ldp x29, x30, [sp], 112       // restore fp and lr and adjust sp

    cmp w20, w19
    ble train_loop

    b exit

skip_epoch_print:
    cmp w20, w19
    blt train_loop

    b exit

forward_loop:
    stp x29, x30, [sp, -16]!       // save frame pointer and link register
    mov x29, sp

    lsl x1, x0, 2
    ldr s3, [x10, x1]              // s3 = x[i]
    ldr s4, [x11, x1]              // s4 = y[i]

    fmov s0, s16                   // put weight in temporary register
    fmov s1, s17                   // put bias in temporary register

    bl linear_model                // goes to model.s and calculates the y_hat in s14

    bl mean_squared_error          // goes to loss.s and calculates the loss in s5

    bl back_propagation            // goes to optimizer.s and calculates dw & db

    fadd s18, s18, s6              // with s6 being the derivative of weight, calculated from optimizer.s file
    fadd s19, s19, s7              // with s7 being the derivative of bias, calculated from optimizer.s file
    fadd s20, s20, s5              // adds the calculated loss to the total loss

    add x0, x0, 1
    scvtf s25, x0
    fcmp s25, s24                  // s19 = sample_size
    blt forward_loop

    ldp x29, x30, [sp], 16        // restore fp and lr

    ret

exit:
    mov x0, 0
    mov x8, 93
    svc 0
