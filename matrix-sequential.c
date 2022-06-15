#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char** argv)
{
  srand(time(NULL));
  if (argc < 2) {
    perror("Podaj nazwe pliku");
    exit(-1);
  }

  int size = atoi(argv[1]);
  int** matrix = malloc(size * sizeof(int*));
  for (int i = 0; i < size; i++) {
    matrix[i] = malloc(size * sizeof(int));
  }
  
  double time_sum = 0.0;

  for (int t = 0; t < 10; t++) {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        matrix[i][j] = rand() % 20 + 1;
      }
    }

    int** result = malloc(size * sizeof(int*));
    for (int i = 0; i < size; i++) {
      result[i] = malloc(size * sizeof(int));
    }


    clock_t start = clock();

    int i, j, k; 
    for (i = 0; i < size; i++) {
      for (j = 0; j < size; j++) {
        int sum = 0;
        for (k = 0; k < size; k++) {
          sum += matrix[i][k] * matrix[k][j];
        }
        result[i][j] = sum;
      }
    }

    clock_t end = clock();

    time_sum += (double)(end - start) / (double)CLOCKS_PER_SEC;
  }
  printf("Macierz o rozmiarze %dx%d, czas: %f\n", size, size, time_sum / 10.0);
  return 0;
}