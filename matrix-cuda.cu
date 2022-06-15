#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__global__ void gpu_matrixMult(int* A, int* B, int* C, int N)
{
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;

  int sum = 0;
  int row_n = row * N;

  if(row < N && col < N){
    for(int i = 0; i < N; i++){
      sum += A[row_n + i] * B[i * N + col];
    }
  }
  C[row_n + col] = sum;
}

void matrixMultiplication(int *A, int *B, int *C, int N){

    dim3 threadsPerBlock(N, N);
    dim3 blocksPerGrid(1, 1);
        if (N*N > 512){
            threadsPerBlock.x = 512;
            threadsPerBlock.y = 512;
            blocksPerGrid.x = ceil(double(N)/double(threadsPerBlock.x));
            blocksPerGrid.y = ceil(double(N)/double(threadsPerBlock.y));
        }

    gpu_matrixMult<<<blocksPerGrid,threadsPerBlock>>>(A, B, C, N);
}

__host__ void cpu_matrixMul(int* A, int* B, int* result, int N)
{
  for(int i = 0; i < N; i++) {
    for(int j = 0; j < N; j++) {
      int sum = 0;
      for(int k = 0; k < N; k++) {
        sum += A[N * i + k] + B[N * k + j];
      }
      result[N * i + j] = sum;
    }
  }
}

int main(int argc, char** argv)
{
  srand(time(NULL));
  if (argc < 2) {
    perror("Podaj wymiar macierzy");
    exit(-1);
  }

  int size = atoi(argv[1]);
  int* h_matrix = (int*)malloc(sizeof(int) * size * size);
  int* h_result = (int*)malloc(sizeof(int) * size * size);

  for(int i = 0; i < size * size; i++) {
    h_matrix[i] = rand() % 5 + 1;
  }

  int *d_matrix, *d_result;
  cudaMalloc((void**)&d_matrix, sizeof(int) * size * size);
  cudaMalloc((void**)&d_result, sizeof(int) * size * size);
  cudaMemcpy(d_matrix, h_matrix, sizeof(int) * size * size, cudaMemcpyHostToDevice);

  cudaEvent_t start, stop;
  float time;

  cudaEventCreate(&start);
  cudaEventCreate(&stop);

  cudaEventRecord(start, 0);
  matrixMultiplication(d_matrix, d_matrix, d_result, size);
  cudaDeviceSynchronize();
  cudaEventRecord(stop, 0);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&time, start, stop);

  cudaMemcpy(h_result, d_result, sizeof(int) * size * size, cudaMemcpyDeviceToHost);
  cudaDeviceSynchronize();

  printf("Rozmiar macierzy: %dx%d, czas CUDA: %f\n", size, size, time);
  cudaEventDestroy(start);
  cudaEventDestroy(stop);

  // testowanie na cpu
  int* result_cpu = (int*)malloc(sizeof(int) * size * size);

  clock_t start_cpu = clock();
  cpu_matrixMul(h_matrix, h_matrix, result_cpu, size);
  clock_t end_cpu = clock();

  double time_cpu = (double)(end_cpu - start_cpu) / (double)CLOCKS_PER_SEC;
  printf("Rozmiar macierzy: %dx%d, czas CPU: %f\n", size, size, time_cpu);
  cudaFree(d_matrix);
  cudaFree(d_result);
}