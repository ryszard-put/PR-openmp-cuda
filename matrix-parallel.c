#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>

int main(int argc, char** argv)
{
  srand(time(NULL));
  if (argc < 3) {
    perror("Blad podania parametrow");
    exit(-1);
  }

  int size = atoi(argv[1]);
  int numOfThreads = atoi(argv[2]);
  int** matrix = malloc(size * sizeof(int*));
  for (int i = 0; i < size; i++) {
    matrix[i] = malloc(size * sizeof(int));
  }
  
  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      matrix[i][j] = rand() % 5 + 1;
    }
  }

  int** result = malloc(size * sizeof(int*));
  for (int i = 0; i < size; i++) {
    result[i] = malloc(size * sizeof(int));
  }

  double time_sum = 0.0; 
  omp_set_num_threads(numOfThreads);

  for(int t = 0; t < 10; t++){
    double start = omp_get_wtime();

    int i, j, k; 
    #pragma omp parallel for shared(matrix, result, size) private(i,j,k)
    for (i = 0; i < size; i++) {
      for (j = 0; j < size; j++) {
        int sum = 0;
        for (k = 0; k < size; k++) {
          sum += matrix[i][k] * matrix[k][j];
        }
        result[i][j] = sum;
      }
    }
    double end = omp_get_wtime();
    time_sum += (end - start);
  }
  

  printf("Macierz o rozmiarze %dx%d, czas: %f\n", size, size, time_sum / 10.0);
  return 0;
}