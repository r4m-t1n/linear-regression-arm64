# ARM64 Linear Regression (1-Feature)

This is a simple linear regression model implemented in ARM64 assembly (with a little help from C for CSV reading). It’s designed for just **one feature**.

## Overview

- The input data is read from a CSV file (default: `data.csv`).
- Only one feature is used, so the model is basically:  
  `y = weight * x + bias`
- Reading the CSV is handled in C (`read_csv.c`), but everything else — training loop, math, etc. — is done entirely in ARM64 assembly.
- You can change most parameters directly in the `train.s` file.

## Configurable Parameters

|      Variable      | Default Value | Description
|--------------------|---------------|-------------
| `filename`         |  `data.csv`   | Path to the CSV file (in src/)
| `norm_constant`    |     `0.1`     | Multiplies each value in the x array to normalize the input, it can be lower
| `learning_rate`    |     `0.01`    | Learning rate for gradient descent
| `weight`           |     `1.0`     | Initial weight
| `bias`             |     `0.0`     | Initial bias
| `epochs`           |     `100`     | Number of training epochs

## Datasets

You can find a few sample datasets in the `examples/` folder.  
To use one of them, rename it to `data.csv` or update the `filename` variable in `train.s`.

## Run

You can use the provided `build.sh` script to compile everything:

```bash
chmod +x build.sh
./build.sh
```

This will assemble all `.s` files in the `src/` directory and compile `data_loader.c`, then link everything into the final `train` binary.
You'll see this message:

```bash
Build finished. Run with ./train
```

If you want to compile manually without the script:

```bash
cd src

as -g -o train.o train.s
as -g -o optimizer.o optimizer.s
as -g -o model.o model.s
as -g -o loss.o loss.s
as -g -o normalize.o normalize.s
gcc -c data_loader.c -o data_loader.o

gcc -g train.o optimizer.o model.o normalize.o loss.o data_loader.o -o train
```

Then run with:

```bash
./train
```

## Notes

- The model is trained using Mean Squared Error (MSE) as the loss function.
- The optimizer uses a simple gradient descent algorithm written in pure ARM64 assembly.
- All data values are expected to be `float`.