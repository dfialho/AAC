#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define CPUonly

#ifdef CPUonly
void generateData(double vectY[], const double vectX[], size_t vectXSize)
{
  for (size_t i = 0; i < vectXSize; i++)
  {
    vectY[i] = sin(0.02 * vectX[i]) + sin(0.001 * vectX[i]) + 0.1 * (rand() / (1.0 * RAND_MAX));
  }
}
#else
__global__ void generateData(double vectY[], const double vectX[], size_t vectXSize)
{
  size_t i = threadIdx.x;
  if (i < vectXSize)
  {
    vectY[i] = sin(0.02 * vectX[i]) + sin(0.001 * vectX[i]) + 0.1 /** (rand() / (1.0 * RAND_MAX))*/;
  }
}
#endif

#ifdef CPUonly
void aproximateValues(double y[], double x[], double yest[], int smooth, size_t N)
{
  for (size_t i = 0; i < N; i++)
  {
#else
__global__ void aproximateValues(double y[], double x[], double yest[], int smooth, size_t N)
{
  size_t i = threadIdx.x;
  if (i < N)
  {
#endif
    double sumA = 0.0;
    double sumB = 0.0;
    double temp = 0.0;
    for (size_t j = 0; j < N; j++)
    {
      temp = exp((-1 * ((x[i] - x[j]) * (x[i] - x[j]))) / (2 * smooth * smooth));
      sumA = sumA + temp * y[j];
      sumB = sumB + temp;
    }
    yest[i] = sumA /sumB;
  }
}


int main()
{

  size_t N = 10000;  // numero de ponto no dataset
  int smooth = 4; // parametro de suavidade

  // criar o dataset de entrada
  double *x = (double*)malloc(N * sizeof(double));
  double *y = (double*)malloc(N * sizeof(double));
  double *yest = (double*)malloc(N * sizeof(double));

  for (size_t i = 0; i < N; i++) {
    x[i] = i / 10.0;
  }
  memset(yest, 0, N*sizeof(double));

#ifdef CPUonly
  generateData(y, x, N);
  aproximateValues(y, x, yest, smooth, N);
#else
  double* d_x;
  double* d_y;
  double* d_yest; //d_ quer dizer variável do dispositivo, convenção

  cudaMalloc(&d_x, N*sizeof(double));
  cudaMalloc(&d_y, N*sizeof(double));
  cudaMalloc(&d_yest, N*sizeof(double));

  cudaMemcpy(d_x, x, N*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(d_yest, yest, N*sizeof(double), cudaMemcpyHostToDevice);

  generateData << <1, N >> > (d_y, d_x, N);
  aproximateValues << <1, N >> > (d_y, d_x, d_yest, smooth, N);

  cudaMemcpy(yest, d_yest, N*sizeof(double), cudaMemcpyDeviceToHost);
#endif

  for (size_t i = 0; i < N; i++)
  {
    printf("yest[%d] = %lf\n", i, yest[i]);
  }
}
