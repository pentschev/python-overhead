NVCC ?= nvcc
NVCCFLAGS ?=
RM = rm -f

all: time_kernel_launch

time_kernel_launch: time_kernel_launch.cu
	$(NVCC) $(NVCCFLAGS) time_kernel_launch.cu -o $@

clean:
	-$(RM) time_kernel_launch
