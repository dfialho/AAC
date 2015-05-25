#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

//#define CPUonly
#define N 50000 // numero de ponto no dataset


void generateData(float vectY[], const float vectX[])
{
    for (size_t i = 0; i < N; i++)
        vectY[i] = sin(0.02 * vectX[i]) + sin(0.001 * vectX[i]) + 0.1 * (rand() / (1.0 * RAND_MAX));
}

float timeDiff(struct timespec tStart, struct timespec tEnd)
{
   struct timespec diff;

   diff.tv_sec  = tEnd.tv_sec  - tStart.tv_sec  - (tEnd.tv_nsec<tStart.tv_nsec?1:0);
   diff.tv_nsec = tEnd.tv_nsec - tStart.tv_nsec + (tEnd.tv_nsec<tStart.tv_nsec?1000000000:0);

   return ((float) diff.tv_sec) + ((float) diff.tv_nsec)/1e9;
}

void aproximateValuesCPU(float y[], float x[], float yest[], int smooth)
{
    for (size_t i = 0; i < N; i++)
    {
        float sumA = 0.0;
        float sumB = 0.0;
        float temp = 0.0;
        for (size_t j = 0; j < N; j++)
        {
            temp = exp((-1 * ((x[i] - x[j]) * (x[i] - x[j]))) / (2 * smooth * smooth));
            sumA = sumA + temp * y[j];
            sumB = sumB + temp;
        }
        yest[i] = sumA / sumB;
    }
}

__global__ void aproximateValuesGPU(float y[], float x[], float yest[], int smooth)
{
    size_t i = blockDim.x * blockIdx.x + threadIdx.x;

    if (i < N)
    {
        float sumA = 0.0;
        float sumB = 0.0;
        float temp = 0.0;
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
    int smooth = 4; // parametro de suavidade

    struct timespec timeVect[7];
    float timeCPU, timeGPU[7];
    cudaError_t err[] = { cudaSuccess , cudaSuccess , cudaSuccess };

    // criar o dataset de entrada
    float *x = (float*)malloc(N * sizeof(float));
    float *y = (float*)malloc(N * sizeof(float));
    float *yest = (float*)malloc(N * sizeof(float));
    float *yestCPU = (float*)malloc(N * sizeof(float));

    // Verify that allocations succeeded
    if (x == NULL || y == NULL || yest == NULL || yestCPU == NULL )
    {
        fprintf(stderr, "Failed to allocate on the host!\n");
        exit(EXIT_FAILURE);
    }

    for (size_t i = 0; i < N; i++)
        x[i] = i / 10.0;

    generateData(y, x);

/* CPU */
    printf("Performing the computation on the CPU...\n");
    clock_gettime(CLOCK_REALTIME, &timeVect[0]);

    aproximateValuesCPU(y, x, yestCPU, smooth);

    clock_gettime(CLOCK_REALTIME, &timeVect[1]);
    timeCPU = timeDiff(timeVect[0],timeVect[1]);
    printf("cpu done ... execution took %.6f seconds\n", timeCPU);

    printf("\n----------------------------------------------------------------------------\n\n");
/* GPU */

    printf("Performing the computation on the GPU...\n");
    clock_gettime(CLOCK_REALTIME, &timeVect[0]);
    clock_gettime(CLOCK_REALTIME, &timeVect[1]);

    // initialize the device (just measure the time for the first call to the device)
    clock_gettime(CLOCK_REALTIME, &timeVect[0]);
    cudaFree(0);
    clock_gettime(CLOCK_REALTIME, &timeVect[1]);

    printf(" ... Allocation of memory on the Device ...\n");
    float* d_x;
    float* d_y;
    float* d_yest; //d_ quer dizer variável do dispositivo, convenção

    err[0] = cudaMalloc(&d_x, N*sizeof(float));
    err[1] = cudaMalloc(&d_y, N*sizeof(float));
    err[2] = cudaMalloc(&d_yest, N*sizeof(float));

    if ((err[0] != cudaSuccess) || (err[1] != cudaSuccess) || (err[2] != cudaSuccess))
    {
        fprintf(stderr, "Failed to allocate on the Device\n");
        exit(EXIT_FAILURE);
    }

    clock_gettime(CLOCK_REALTIME, &timeVect[2]);

    printf(" ... Copying input data from the host memory to the CUDA device ...\n");
    err[0] = cudaMemcpy(d_x, x, N*sizeof(float), cudaMemcpyHostToDevice);
    err[1] = cudaMemcpy(d_y, y, N*sizeof(float), cudaMemcpyHostToDevice);
    

    if ((err[0] != cudaSuccess) || (err[1] != cudaSuccess))
    {
        fprintf(stderr, "Failed to copy data to the device!\n");
        exit(EXIT_FAILURE);
    }

    clock_gettime(CLOCK_REALTIME, &timeVect[3]);

    printf(" ... CUDA kernel launch with %d blocks of %d threads ...\n", N/1024, 1024);
    // Máximo de 1024 threads concorrentes!

    int blockDim = 1024;
    int gridDim = N / 1024 + (N % 1024 > 0);
    aproximateValuesGPU <<< gridDim, blockDim>>>(d_y, d_x, d_yest, smooth);

    err[0] = cudaGetLastError();
    if (err[0] != cudaSuccess)
    {
        fprintf(stderr, "Failed to launch yest calculation kernel (error code %s)!\n", cudaGetErrorString(err[0]));
        exit(EXIT_FAILURE);
    }

    clock_gettime(CLOCK_REALTIME, &timeVect[4]);

    printf("Copy output data from the CUDA device to the host memory\n");
    err[0] = cudaMemcpy(yest, d_yest, N*sizeof(float), cudaMemcpyDeviceToHost);
    if (err[0] != cudaSuccess)
    {
        fprintf(stderr, "Failed to copy yest from device to host (error code %s)!\n", cudaGetErrorString(err[0]));
        exit(EXIT_FAILURE);
    }
    clock_gettime(CLOCK_REALTIME, &timeVect[5]);

    err[0] = cudaFree(d_x);
    err[1] = cudaFree(d_y);
    err[2] = cudaFree(d_yest);

    if ((err[0] != cudaSuccess) || (err[1] != cudaSuccess) || (err[2] != cudaSuccess))
    {
        fprintf(stderr, "Failed to free device vectors!\n");
        exit(EXIT_FAILURE);
    }
    clock_gettime(CLOCK_REALTIME, &timeVect[6]);
    
    timeGPU[0] = timeDiff(timeVect[0],timeVect[1]);
    timeGPU[1] = timeDiff(timeVect[1],timeVect[2]);
    timeGPU[2] = timeDiff(timeVect[2],timeVect[3]);
    timeGPU[3] = timeDiff(timeVect[3],timeVect[4]);
    timeGPU[4] = timeDiff(timeVect[4],timeVect[5]);
    timeGPU[5] = timeDiff(timeVect[5],timeVect[6]);
    timeGPU[6] = timeDiff(timeVect[0],timeVect[6]);
    printf("gpu done  ... execution took %.6f seconds (speedup=%.3f), corresponging to:\n",timeGPU[6],timeCPU/timeGPU[6]);
    printf("          - first call to the device           -> %.6f seconds\n",timeGPU[0]);
    printf("          - allocation of memory on the device -> %.6f seconds\n",timeGPU[1]);
    printf("          - copying data from host to device   -> %.6f seconds\n",timeGPU[2]);
    printf("          - kernel execution on the device     -> %.6f seconds\n",timeGPU[3]);
    printf("          - copying data from device to host   -> %.6f seconds\n",timeGPU[4]);
    printf("          - freeing data on the device         -> %.6f seconds\n",timeGPU[5]);
    printf("----------------------------------------------------------------------------\n");

    FILE *inputFile = fopen("input", "w");
    FILE *cpuFile = fopen("cpu-yest", "w");
    FILE *gpuFile = fopen("gpu-yest", "w");

    if(cpuFile == NULL || gpuFile == NULL) {
        printf("ficheiro não pode ser criado\n");
    }

    for (size_t i = 0; i < N; i++) {
        fprintf(inputFile, "%.30f\n", y[i]);
        fprintf(cpuFile, "%.30f\n", yestCPU[i]);
        fprintf(gpuFile, "%.30f\n", yest[i]);
    } 

    int errors = 0;
    float avgerror=0;
    for (size_t i = 0; i < N; i++)
    {
        if (yest[i] != yestCPU[i])
        {
            errors++;
            avgerror +=  abs(yestCPU[i]-yest[i]);
        }
    }    

    if(errors)
        printf("\nTest Failed:\n\t %d errors found! (out of %d points, %d%%)\n\t average error: %.20f\n", errors, N, errors*100/N, avgerror/errors);    
    else
        printf("Test Passes\n");
    
    free(x);
    free(y);
    free(yest);
    free(yestCPU);  

    // Reset the device and exit
    err[0] = cudaDeviceReset();

    if (err[0] != cudaSuccess)
    {
        fprintf(stderr, "Failed to deinitialize the device! error=%s\n", cudaGetErrorString(err[0]));
        exit(EXIT_FAILURE);
    }

    printf("Done\n");
    return 0;
}
