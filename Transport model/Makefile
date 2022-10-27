
NVCC = nvcc
CC = g++

LIBS += -lcublas
LIBS += -lcusparse
LOCAL += -arch=compute_70 -code=sm_70

MAIN = transport.cu
EXECNAME = GPU.out
 
all:

	$(NVCC)  $(MAIN) -o $(EXECNAME) $(LIBS) $(LOCAL)
 
#clean:
	rm -f *.o
	