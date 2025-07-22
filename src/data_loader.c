#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int count_lines(FILE *file, int* header) {
    int lines = 0;
    char buffer[1024];

    if (fgets(buffer, sizeof(buffer), file)) {
        lines++;
        if (strpbrk(buffer, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")) {
            *header = 1;
        }
    }

    while (fgets(buffer, sizeof(buffer), file)) {
        lines++;
    }
    rewind(file);
    return lines;
}

int read_csv(char* filename, float **x, float **y, float *sample_size) {

    FILE *file_ptr = fopen(filename, "r");
    if (file_ptr == NULL){
        perror("Error opening file");
        return -1;
    }

    char buffer[1024];

    int has_header = 0;
    int lines = count_lines(file_ptr, &has_header);
    *sample_size = has_header ? (lines - 1) : lines;

    if (has_header) {
        fgets(buffer, sizeof(buffer), file_ptr);
    }

    float x_num, y_num;

    *x = malloc(*sample_size * sizeof(float));
    *y = malloc(*sample_size * sizeof(float));

    int c = 0;

    while (fgets(buffer, sizeof(buffer), file_ptr)) {
        if (sscanf(buffer, "%f,%f", &x_num, &y_num) == 2) {
            (*x)[c] = x_num;
            (*y)[c] = y_num;
            c++;
        } else {
            printf("Failed to parse line: %s", buffer);
        }
    }
    fclose(file_ptr);

    return 0;
}