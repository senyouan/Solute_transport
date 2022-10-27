//#include "global.h"

cudaError_t Output_PNM() // Copy GPU data to CPU
{
	cudaError_t cudaStatus = cudaSuccess;
	cudaStatus = cudaSetDevice(0);

    cudaStatus = cudaMemcpy(Cons, D_Cons, (PE + 2) * sizeof(double), cudaMemcpyDeviceToHost);
	//cudaStatus = cudaMemcpy(Cons, D_deltaCons, (PE) * sizeof(double), cudaMemcpyDeviceToHost);

	if (cudaStatus != cudaSuccess)
	{
		fprintf(stderr, "Copy data failed, Output!");
	}
	return cudaStatus;
}



cudaError_t Free_PNM()  // Free memory in GPU

{
	cudaError_t cudaStatus = cudaSuccess;
	
	cudaFree(D_Flux);
	cudaFree(D_Trans);
	cudaFree(D_Cons);
	cudaFree(D_Volume);
	cudaFree(D_mintime);
	cudaFree(D_deltaCons);
	cudaFree(D_CoordMat);
	cudaFree(D_CoordMat_sum);
	cudaFree(D_Prr);
	cudaFree(d_minindex);
    return cudaStatus;
}
