NVCC ?= nvcc
NVCCFLAGS ?=
RM = rm -f

# Gencode arguments
ifeq ($(TARGET_ARCH),$(filter $(TARGET_ARCH),armv7l aarch64 sbsa))
SMS ?= 53 61 70 72 75
else
SMS ?= 50 52 60 61 70 75
endif

ifeq ($(SMS),)
$(info >>> WARNING - no SM architectures have been specified - waiving sample <<<)
SAMPLE_ENABLED := 0
endif

ifeq ($(GENCODE_FLAGS),)
# Generate SASS code for each SM architecture listed in $(SMS)
$(foreach sm,$(SMS),$(eval GENCODE_FLAGS += -gencode arch=compute_$(sm),code=sm_$(sm)))

# Generate PTX code from the highest SM architecture in $(SMS) to guarantee forward-compatibility
HIGHEST_SM := $(lastword $(sort $(SMS)))
ifneq ($(HIGHEST_SM),)
GENCODE_FLAGS += -gencode arch=compute_$(HIGHEST_SM),code=compute_$(HIGHEST_SM)
endif
endif

all: time_kernel_launch

time_kernel_launch: time_kernel_launch.cu
	$(NVCC) $(NVCCFLAGS) $(GENCODE_FLAGS) time_kernel_launch.cu -o $@

clean:
	-$(RM) time_kernel_launch
