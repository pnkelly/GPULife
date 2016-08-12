/* Cuda Code for Game Of Life 
*  Priscilla Kelly June 21, 2016
*/

#include "stdio.h"
#include "stdlib.h"

/***************************************/
/* External c subroutine for CUDA      */
/***************************************/
extern "C" void call_loadTile_CUDA(int flag, int elements, int *Matrix, int **pointer2device) {

	size_t matSize = elements*sizeof(int);
	cudaError_t err = cudaSuccess;

	if (flag == 0) {

		/***************************************/
		/* Allocate Matrix to the GPU          */
		/***************************************/
		int *device;
		err = cudaMalloc(&device, matSize);
		if(err != cudaSuccess) {
			fprintf(stderr, "Failed to allocate device vector (error code %s)!\n",
					cudaGetErrorString(err));
			exit(EXIT_FAILURE);		
		}
		// move matrix to device
		err = cudaMemcpy(device,Matrix,matSize,cudaMemcpyHostToDevice);
		if (err != cudaSuccess) {
			fprintf(stderr, "%s Failed at line %s !\n",__FILE__,__LINE__);
			exit(EXIT_FAILURE);
		}
        
		*pointer2device = device;
		return;
	}

	if (flag == 1) {

		/***************************************/
		/* Free Device Global Memory           */
		/***************************************/
		err = cudaFree(*pointer2device);
		if (err != cudaSuccess){
			fprintf(stderr, "Failed to free device!\n");
			exit(EXIT_FAILURE);
		}
	}
	
	if (flag == 3) {
		cudaDeviceSynchronize();
		int *host_subMat = (int *)malloc(matSize);	
		if(host_subMat == NULL) {
			fprintf(stderr, "Failed to alocate host vector!\n");
 			exit(EXIT_FAILURE);     
		}
		err = cudaMemcpy(host_subMat,*pointer2device,matSize,cudaMemcpyDeviceToHost);
		if (err != cudaSuccess) {
			fprintf(stderr,"Failed to copy the submat from device (error code %s)!\n",cudaGetErrorString(err));
			exit(EXIT_FAILURE);
		}
		int i,j;
		int c=0;
		printf("New Rank\n");
		for(i=0;i<6;i++) {
			printf("[");
			for(j=0;j<6;j++) {
				printf(" %d ",host_subMat[c]);
				c++;	
			}	
			printf("]\n");
		}
		printf("\n");
		return;
	}	
}	
