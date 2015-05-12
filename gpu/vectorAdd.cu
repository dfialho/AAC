#include <stdio.h>

#define CPU

#define SIZE	1024

#ifdef CPU
void VectorAdd(int *a, int *b, int *c, int n)
{
	int i;
	int j;

	for (i = 0; i < n; ++i)
#else
__global__ void VectorAdd(int *a, int *b, int *c, int n)
{
	int i = threadIdx.x;
	int j;

	if (i < n)
#endif
	{
		for (j = 0; j < SIZE*SIZE; j++)
		{
			c[i] = a[i] * b[i] * j;
		}
	}
	
}

int main()
{
	int *a, *b, *c;

	a = (int *)malloc(SIZE*sizeof(int));
	b = (int *)malloc(SIZE*sizeof(int));
	c = (int *)malloc(SIZE*sizeof(int));

#ifndef CPU
	int *d_a, *d_b, *d_c;


	cudaMalloc(&d_a, SIZE*sizeof(int));
	cudaMalloc(&d_b, SIZE*sizeof(int));
	cudaMalloc(&d_c, SIZE*sizeof(int));
#endif

	for (int i = 0; i < SIZE; ++i)
	{
		a[i] = i;
		b[i] = i;
		c[i] = 0;
	}

#ifdef CPU
	VectorAdd(a, b, c, SIZE);
#else
	cudaMemcpy(d_a, a, SIZE*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, SIZE*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_c, c, SIZE*sizeof(int), cudaMemcpyHostToDevice);

	VectorAdd<<< 1, SIZE >>>(d_a, d_b, d_c, SIZE);
	
	cudaMemcpy(c, d_c, SIZE*sizeof(int), cudaMemcpyDeviceToHost);
#endif

	for (int i = 0; i < 10; ++i)
		printf("c[%d] = %d\n", i, c[i]);

	printf("\ndone! %d\n", c[SIZE-1]);

	free(a);
	free(b);
	free(c);

#ifndef CPU
	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);
#endif

	return 0;
}