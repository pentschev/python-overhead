#include <chrono>
#include <iostream>
#include <string>

#ifdef EXTERN 
#include "noop.h"
#else
static inline void noop() {
    return;
}
#endif

int main(int argc, char** argv){
    if (argc != 2) {
        fprintf(stderr, "Usage: %s NUMBER_OF_ITERATIONS\n", argv[0]);
        return 1;
    }

    size_t iterations = std::stoll(argv[1]);

    auto start = std::chrono::steady_clock::now();
    for(size_t i=0; i < iterations; ++i)
        noop();
    auto elapsed = std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now() - start).count();

    double average_ns = ((double)(elapsed / 1e6) / iterations) * 1e9;

#ifdef EXTERN
    std::cout << "C++ (externally linked) total [average] runtime for " << iterations
#else
    std::cout << "C++ (inlined) total [average] runtime for " << iterations
#endif
              << " iterations: " << (double)(elapsed / 1e6) << "s ["
              << average_ns << "ns]" << std::endl;

    return 0;
}
