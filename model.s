.text
.align 2 
.global linear_model

linear_model:
    FMUL S3, S0, S1     // multiply x and weight
    FADD S0, S3, S2     // add the result to bias
    RET