#include <chrono>
#include <iostream>
#include <string>

// #include "helper_cuda.h"

// #ifdef EXTERN 
// #include "noop.h"
// #else
// static inline void noop() {
//     return;
// }
// #endif

__global__ void noop() {
  return;
}

int main(int argc, char** argv){
    if (argc != 2) {
        fprintf(stderr, "Usage: %s NUMBER_OF_ITERATIONS\n", argv[0]);
        return 1;
    }

    size_t iterations = std::stoll(argv[1]);

    auto start = std::chrono::steady_clock::now();
    for(size_t i=0; i < iterations; ++i) {
      cudaError_t err = cudaSuccess;
      noop<<<1, 32>>>();
      err = cudaGetLastError();

      if (err != cudaSuccess) {
        fprintf(stderr, "Failed to launch vectorAdd kernel (error code %s)!\n",
                cudaGetErrorString(err));
        exit(EXIT_FAILURE);
      }
    }
    auto elapsed = std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now() - start).count();


    double average_ns = ((double)(elapsed / 1e6) / iterations) * 1e9;

    std::cout << "CUDA kernel launch total [average] runtime for " << iterations
              << " iterations: " << (double)(elapsed / 1e6) << "s ["
              << average_ns << "ns]" << std::endl;

    return 0;
}
