cd src

set -e

as -g -o train.o train.s
as -g -o optimizer.o optimizer.s
as -g -o model.o model.s
as -g -o loss.o loss.s
as -g -o normalize.o normalize.s
gcc -c data_loader.c -o data_loader.o

gcc -g train.s optimizer.s model.s normalize.s loss.s data_loader.o -o train
echo "Build finished. Run with ./train"