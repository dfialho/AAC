#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

//#define CPUonly

void generateData(double vectY[], const double vectX[], size_t vectXSize)
{
    for (size_t i = 0; i < vectXSize; i++)
        vectY[i] = sin(0.02 * vectX[i]) + sin(0.001 * vectX[i]) + 0.1 * (rand() / (1.0 * RAND_MAX));
}

void aproximateValuesCPU(double y[], double x[], double yest[], int smooth, size_t N)
{
    for (size_t i = 0; i < N; i++)
    {
        double sumA = 0.0;
        double sumB = 0.0;
        double temp = 0.0;
        for (size_t j = 0; j < N; j++)
        {
            temp = exp((-1 * ((x[i] - x[j]) * (x[i] - x[j]))) / (2 * smooth * smooth));
            sumA = sumA + temp * y[j];
            sumB = sumB + temp;
        }
        yest[i] = sumA / sumB;
    }
}

__global__ void aproximateValuesGPU(double y[], double x[], double yest[], int smooth, size_t N)
{
    size_t i = threadIdx.x;
    if (i < N)
    {
        double sumA = 0.0;
        double sumB = 0.0;
        double temp = 0.0;
        for (size_t j = 0; j < N; j++)
        {
            temp = exp((-1 * ((x[i] - x[j]) * (x[i] - x[j]))) / (2 * smooth * smooth));
            sumA = sumA + temp * y[j];
            sumB = sumB + temp;
        }
        yest[i] = sumA / sumB;
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

    for (size_t i = 0; i < N; i++)
        x[i] = i / 10.0;

    generateData(y, x, N);

#ifdef CPUonly  
    aproximateValuesCPU(y, x, yest, smooth, N);

#else
    double* d_x;
    double* d_y;
    double* d_yest; //d_ quer dizer variável do dispositivo, convenção

    cudaMalloc(&d_x, N*sizeof(double));
    cudaMalloc(&d_y, N*sizeof(double));
    cudaMalloc(&d_yest, N*sizeof(double));

    cudaMemcpy(d_x, x, N*sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, y, N*sizeof(double), cudaMemcpyHostToDevice);

    // Máximo de 1024 threads concorrentes!
    for (size_t k = 0; k < N; k += 1024)
        aproximateValuesGPU << <1, (N - k > 1024 ? 1024 : N - k) >> >(d_y + k, d_x + k, d_yest + k, smooth, N);

    cudaMemcpy(yest, d_yest, N*sizeof(double), cudaMemcpyDeviceToHost);
    printf("gpu done\n");
#endif

    double *yest2 = (double*)malloc(N * sizeof(double));
    aproximateValuesCPU(y, x, yest2, smooth, N);
    printf("cpu done\n");

#ifndef CPUonly
    for (size_t i = 0; i < N; i++)
    {
        if (yest[i] != yest2[i])
            printf(":( > yest2[%d] = %lf\n", i, yest2[i]);
        printf("yest[%d] = %lf\n", i, yest[i]);
    }
#endif

    free(x);
    free(y);
    free(yest);
    free(yest2);

#ifndef CPUonly
    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_yest);
#endif

}