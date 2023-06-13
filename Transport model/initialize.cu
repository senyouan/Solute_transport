//#include "global.h"

cudaError_t Init_PNM()       // allocate space in GPU

{
	cudaError_t cudaStatus;
	cudaStatus = cudaSetDevice(0);
	if (cudaStatus != cudaSuccess)
	{
		fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
	}
    // allocate the area in the GPU
    cudaStatus = cudaMalloc((void**)&D_Prr, TF * sizeof(int));
	cudaStatus = cudaMalloc((void**)&D_Flux, TF * sizeof(double));// nozero * sizeof(double));
	cudaStatus = cudaMalloc((void**)&D_Trans, TF * sizeof(double));
	cudaStatus = cudaMalloc((void**)&D_Cons, (PE + 3) * sizeof(double));
	cudaStatus = cudaMalloc((void**)&D_Volume, PE * sizeof(double));
	cudaStatus = cudaMalloc((void**)&D_mintime, PE * sizeof(double));
	cudaStatus = cudaMalloc((void**)&D_deltaCons, PE * sizeof(double));
	cudaStatus = cudaMalloc((void**)&D_CoordMat, PE * sizeof(int));
    cudaStatus = cudaMalloc((void**)&D_CoordMat_sum, PE * sizeof(int));

	cudaMalloc(&d_minindex, sizeof(int));

	//copy data from CPU to GPU
	cudaStatus = cudaMemcpy(D_Prr, Prr.data(), TF * sizeof(int), cudaMemcpyHostToDevice);
	cudaStatus = cudaMemcpy(D_Flux, Flux.data(), TF * sizeof(double), cudaMemcpyHostToDevice);
	cudaStatus = cudaMemcpy(D_Trans, Trans.data(), TF * sizeof(double), cudaMemcpyHostToDevice);
	cudaStatus = cudaMemcpy(D_Cons, Cons, (PE + 3) * sizeof(double), cudaMemcpyHostToDevice);
	cudaStatus = cudaMemcpy(D_Volume, Volume.data(), PE * sizeof(double), cudaMemcpyHostToDevice);
	cudaStatus = cudaMemcpy(D_CoordMat, CoordMat.data(), PE * sizeof(int), cudaMemcpyHostToDevice);
	cudaStatus = cudaMemcpy(D_CoordMat_sum, CoordMat_sum.data(), PE * sizeof(int), cudaMemcpyHostToDevice);

	if (cudaStatus != cudaSuccess)
	{
		fprintf(stderr, "Copy data failed, Intput!");
	}
	//end copy
	return cudaStatus;
}

void initialize()
{

	cudaError_t cudaStatus;
	cudaStatus = cudaSetDevice(0);
	if (cudaStatus != cudaSuccess)
	{
		fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
		//return 1;
	}

	cudaStatus = Init_PNM(); //malloc memory
	if (cudaStatus != cudaSuccess)
	{
		fprintf(stderr, "LBM initialization failed!");
		//return 1;
	}

	//printf("finish blocking");
	//P_setup << <TgridSize, blockSize >> >(NZT, D_deltaCons);//, p0
	//cudaDeviceSynchronize();
    //cudaThreadSynchronize();
}

//------------------------------------------------------------------------------
