//#include "global.h"

__global__ void deltaCons_calculation(int NY, int *D_CoordMat, int *D_CoordMat_sum, int *D_Prr, double *D_Flux, double *D_deltaCons, double *D_Cons, double *D_Trans)
{
    int tz=blockIdx.x*blockDim.x+threadIdx.x; //becase of the blockSize
    int ty=blockIdx.y*blockDim.y+threadIdx.y;
    int tx=blockIdx.z*blockDim.z+threadIdx.z;
	int tid=tx*NY*NZ+ty*NZ+tz;
    if (tx > NX || ty > NY || tz > NZ || tx < 0 || ty < 0 || tz < 0 || tid >= PE || tid < TP)//!!!!
    {
        return;
    }
	int i, cterm, csterm, poreterm;
	double fluxterm, DCterm, C1term, C2term;

	DCterm = 0;
	cterm = D_CoordMat[tid];
	csterm = D_CoordMat_sum[tid];
	for (i = 0; i < cterm; i++)
	{
		fluxterm = D_Flux[csterm + i];
		poreterm = D_Prr[csterm + i] - 1;
	    C1term = D_Cons[tid];
	    C2term = D_Cons[poreterm];
		if (fluxterm > 0)  // can do this judge in the data0!!!
		{
		    DCterm = DCterm + fluxterm * C2term;
		}
		if (fluxterm < 0)
		{
		    DCterm = DCterm + fluxterm * C1term;
		}
		DCterm = DCterm + D_Trans[csterm + i] * (C2term - C1term);
	}
	D_deltaCons[tid] = DCterm;
}
__global__ void Mintime_calculation(int NY, double *D_deltaCons, double *D_Volume, double *D_mintime, double *D_Cons)
{
    int tz=blockIdx.x*blockDim.x+threadIdx.x; //becase of the blockSize
    int ty=blockIdx.y*blockDim.y+threadIdx.y;
    int tx=blockIdx.z*blockDim.z+threadIdx.z;
	int tid=tx*NY*NZ+ty*NZ+tz;
    if (tx > NX || ty > NY || tz > NZ || tx < 0 || ty < 0 || tz < 0 || tid >= PE || tid < TP)//!!!!
    {
        D_mintime[tid] = 10000;
        return;
    }
	double DCterm = 0.0;
	double DC = 0.0;
	D_mintime[tid] = 0;
	DCterm = D_deltaCons[tid];
	DC = D_Cons[tid];
	if (D_Volume[tid] > 0.0)
		DCterm = DCterm / D_Volume[tid];
	if (DCterm > 0 &&  DC < 0.9999) //DC <= 1.0 &&
    {
	    D_mintime[tid] = (1.0 - DC) / DCterm;
	}
    if (DCterm < 0)
	{
	     D_mintime[tid] = -1.0 * DC / DCterm;
	}
	if(D_mintime[tid] < 10e-20)
	{
	    D_mintime[tid] = 1000000;
	}
      
	D_deltaCons[tid] = DCterm;
}

__global__ void C_calculation(int *d_minindex, int NY, double *D_Cons, double *D_deltaCons, double *D_mintime)
{
    int tz=blockIdx.x*blockDim.x+threadIdx.x; //becase of the blockSize
    int ty=blockIdx.y*blockDim.y+threadIdx.y;
    int tx=blockIdx.z*blockDim.z+threadIdx.z;
	int tid=tx*NY*NZ+ty*NZ+tz;
    if (tx > NX || ty > NY || tz > NZ || tx < 0 || ty < 0 || tz < 0 || tid >= PE || tid < TP)//!!!!
    {
        return;
    }
	double DC = 0.0;
	double DCterm = 0.0;
	DC = D_Cons[tid];
	DCterm = D_deltaCons[tid];
	if (DC <= 1.0)
	{
		D_Cons[tid] = D_Cons[tid] + D_mintime[*d_minindex-1] * D_deltaCons[tid];
	}
	if (DC > 1.0 && DCterm < 0.0)
	{
		D_Cons[tid] = D_Cons[tid] + D_mintime[*d_minindex-1] * D_deltaCons[tid];
	}
	/*D_Cons[tid] = D_Cons[tid] + D_mintime[*d_minindex-1] * D_deltaCons[tid];
	if (DC >= 1.0)
	{
		D_Cons[tid] = 1.0;
	}*/
}


void Iteration()
{   
    deltaCons_calculation << <gridSize, blockSize >> >(NY, D_CoordMat, D_CoordMat_sum, D_Prr, D_Flux, D_deltaCons, D_Cons, D_Trans);
	cudaDeviceSynchronize();
    cudaThreadSynchronize();

	Mintime_calculation << <gridSize, blockSize >> >(NY, D_deltaCons, D_Volume, D_mintime, D_Cons);
	cudaDeviceSynchronize();
    cudaThreadSynchronize();

    cublasHandle_t handle;
	cublasCreate(&handle);
	cublasSetPointerMode(handle, CUBLAS_POINTER_MODE_DEVICE);
	if(cublasIdamin(handle, PE, D_mintime, 1, d_minindex) != CUBLAS_STATUS_SUCCESS) {std::cout << ".";}  //convert to maximum value, to avoid the effect of 0
	cudaMemcpy(&hminindex, d_minindex, sizeof(int), cudaMemcpyDeviceToHost);
	cudaMemcpy(&hmint, D_mintime + hminindex - 1, sizeof(double), cudaMemcpyDeviceToHost);
	//printf("%d\n",hminindex);
	//cudaMemcpy(&hppkk, ppkk, sizeof(double), cudaMemcpyDeviceToHost);
	cublasDestroy(handle);
	//if (hppkk <= 0.0000001) {t = Time;}//error
	//al = hppkk / hppk;
	//cudaMemcpy(al, &hal, sizeof(double), cudaMemcpyHostToDevice);

	C_calculation << <gridSize, blockSize >> >( d_minindex, NY, D_Cons, D_deltaCons, D_mintime);
	cudaDeviceSynchronize();
    cudaThreadSynchronize();
}
