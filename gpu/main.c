#include <math.h>
#include <stdio.h>
#include <stdlib.h>

void generateData(double vectY[], const double vectX[], size_t vectXSize) {
  for (int i = 0; i < vectXSize; i++) {
    vectY[i] = sin(0.02 * vectX[i]) + sin(0.001 * vectX[i]) + 0.1 * (rand() / (1.0 * RAND_MAX));
  }
}

int main() {

  int N = 10000;  // numero de ponto no dataset
  int smooth = 4; // parametro de suavidade

  // criar o dataset de entrada
  double *x = malloc(N * sizeof(double));
  for (size_t i = 0; i < N; i++) {
    x[i] = i / 10.0;
  }

  // for (int i = 0; i < N; i++) {
  //   printf("x[%d] = %lf\n", i, x[i]);
  // }

  double *y = malloc(N * sizeof(double));
  generateData(y, x, N);

  // inicializar o yest
  double *yest = malloc(N * sizeof(double));
  for (int i = 0; i < N; i++) {
    yest[i] = 0.0;
  }

  // calcular valores aproximados
  for (size_t i = 0; i < N; i++) {
    double sumA = 0.0;
    double sumB = 0.0;
    for (size_t j = 0; j < N; j++) {
      sumA = sumA + exp((-1 * ((x[i] - x[j]) * (x[i] - x[j]))) / (2 * smooth * smooth)) * y[j];
      sumB = sumB + exp((-1 * ((x[i] - x[j]) * (x[i] - x[j]))) / (2 * smooth * smooth));
    }

    yest[i] = sumA / sumB;
  }

  for (int i = 0; i < N; i++) {
    printf("yest[%d] = %lf\n", i, yest[i]);
  }
}
