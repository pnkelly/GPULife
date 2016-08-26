/* LA-CC-16080

 Copyright © 2016 Priscilla Kelly and Los Alamos National Laboratory. All Rights Reserved.
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    3. The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
    THIS SOFTWARE IS PROVIDED BY Priscilla Kelly and Los Alamos National Laboratory "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
Priscilla Kelly <priscilla.noreen@gmail.com>
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#ifdef __APPLE_CC__
#include <OpenCL/OpenCL.h>
#include <OpenCL/cl_gl.h>
#else
#include <CL/cl.h>
#include <CL/cl_gl.h>
#endif
#if defined(__APPLE__)
#include <OpenGL/OpenGL.h>
#include <OpenGL/gl.h>
#include <GLUT/glut.h>
#else
#include <GL/glut.h>
#endif
#include <time.h>
#define ndims = 2

// Function Declarations
int **alloc2D(int row, int col);
void dealloc(int **array);

//MAIN
int main(int argc, char *argv[]) {

	int ierr;
	// Command line stuff
	int myRows = 5;
	int myCols = 5;
	int i,j;	
	int **subMatrix;
	subMatrix = alloc2D(myRows,myCols);
	printf("%s: SubMat in Main\n",__FILE__);
	for(i=0;i<myRows;i++) {
		printf("[");
		for(j=0;j<myCols;j++){
			printf(" %2d ",subMatrix[i][j]);
		}
		printf("]\n");
	}	
	int *sub1D = (int *)&(subMatrix[0][0]);	
	size_t dims = myRows*myCols;
	// this up would be given in a command line

	cl_platform_id platform;
	cl_device_id deviceID;
	cl_context cxt;
	cl_command_queue commands;
	cl_program program;
	cl_kernel kernel_applyRulesCL;

	ierr = clGetPlatformIDs(1,&platform,NULL);
	if (ierr != CL_SUCCESS) {
		printf("ERROR: Failed to create platform!\n");
		return(-1);
	}

	char ext_string[1024];
	ierr = clGetPlatformInfo(platform,CL_PLATFORM_EXTENSIONS,sizeof(ext_string),ext_string,NULL);
	
	char *extStringStart = NULL;
	extStringStart = strstr(ext_string,"cl_khr_gl_sharing");
	if (extStringStart != 0) {
		printf("Platform supports cl_khr_gl_sharing\n");
	}

	ierr = clGetDeviceIDs(platform,CL_DEVICE_TYPE_GPU,1,&deviceID,NULL);
	if (ierr != CL_SUCCESS) {
		printf("ERROR: Failed to create a device group!\n");
		return(-1);
	}
	// Get the properties from the current system
	cl_context_properties props[] = {

       #ifdef __APPLE__

		GLContextObj     CGLGetCurrentContext(void);
		CGLShareGroupObj  CGLGetShareGroup(CGLContextObj);

		CGLContextObj     kCGLContext     = CGLGetCurrentContext();
		CGLShareGroupObj  kCGLShareGroup  = CGLGetShareGroup(kCGLContext);

		cl_context_properties properties[] =
		{
		  CL_CONTEXT_PROPERTY_USE_CGL_SHAREGROUP_APPLE,
		  (cl_context_properties) kCGLShareGroup,
			  0
		};

	#elif __linux__
		CL_GL_CONTEXT_KHR, (cl_context_properties)glXGetCurrentContext(),
		CL_WGL_HDC_KHR, (cl_context_properties)glXGetCurrentDisplay(),
		CL_CONTEXT_PLATFORM, (cl_context_properties)platform, 0
	};

	#elif _WIN32
		CL_GL_CONTEXT_KHR, (cl_context_properties)wglGetCurrentContext(),
		CL_WGL_HDC_KHR, (cl_context_properties)wglGetCurrentDisplay(),
		CL_CONTEXT_PLATFORM, (cl_context_properties)platform, 0
	};

	#endif

	// create the OCL context using the new properties
	cxt = clCreateContext(props,1,&deviceID,0,0,&ierr);
	if (ierr != CL_SUCCESS) {
		printf("ERROR: failed to create context: %d\n",ierr);
	}
	
	commands = clCreateCommandQueue(cxt,deviceID,0,&ierr);
	if (ierr != CL_SUCCESS) {
		printf("ERROR: failed to create command queue %d\n",ierr);
	}

	// malloc buffer space
	int devptr;
	glGenBuffers(1,&devptr);
	glNamedBufferData(devptr,dims*sizeof(int),NULL,GL_STATIC_DRAW);

	ierr = clEnqueueAcquireGLObjects(commands,1,&devptr,0,0,0);
	if (ierr != CL_SUCCESS) {
		printf("ERROR: failed to aquire: %d\n",ierr);
	}

	ierr = clEnqueueWriteBuffer(commands,devptr,CL_TRUE,0,dims*sizeof(cl_int),(void *)&sub1D[0],0,NULL,NULL);

	if (ierr != CL_SUCCESS) {
		printf("ERROR: failed to allocate: %d\n",ierr);
	}

	/*
	// Set up kernel to run
	kernel_applyRulesCL = ezcl_create_kernel_wprogram(prog,"applyRulesOCL");
	ezcl_program_release(prog);
	// set arguments
	ezcl_set_kernel_arg(kernel_applyRulesCL,0,sizeof(cl_int), (void *)&myRows);
	ezcl_set_kernel_arg(kernel_applyRulesCL,1,sizeof(cl_int), (void *)&myCols);
	ezcl_set_kernel_arg(kernel_applyRulesCL,2,sizeof(cl_mem), update);

	int mod = dims%32;
	size_t globalSize, localSize;
	if (mod == 0) { // check if the total work elements is a factor of 32 
		globalSize = dims;
	} else {
		globalSize = dims + (32-mod);
	}
	localSize = 32;


	// loops
	
	// run everything
	ezcl_enqueue_ndrange_kernel(com_queue,kernel_applyRulesCL,1,NULL,&globalSize,&localSize,NULL);
	*/
	// read data back
	/*cl_command_queue com_queue = ezcl_get_command_queue();
	int recvSub[dims];
	clEnqueueReadBuffer(com_queue,update,CL_TRUE,0,dims*sizeof(cl_int),(void *)&recvSub[0],NULL,NULL,NULL);

	for (i=0;i<dims;i++) {
	printf(" %d ",recvSub[i]);
	}
	printf("\n");
	*/
	glBindBuffer(GL_ARRAY_BUFFER,0);
	//ezcl_device_memory_remove(update);
	dealloc(subMatrix);

    exit(0);
} // end of main

/***************************************/
/* Function: alloc 2D                  */
/***************************************/

int **alloc2D(int row, int col) {
	int i, j;
	size_t mem_size;
	int **arr;

	mem_size = col*sizeof(int *);
	arr = (int **)malloc(mem_size);

	mem_size = row*col*sizeof(int);
	arr[0] = (int *)malloc(mem_size);

	for(i = 1; i< col; i++) {
		arr[i] = arr[i-1]+row;
	}
	for(i=0;i<row;i++) {
		for(j=0;j<col;j++){
			arr[i][j] = i*10+j;
		}
	}	
	return arr;
}

/***************************************/
/* Function: dealloc 2D array          */
/***************************************/
void dealloc(int **array) {
	free(array[0]);
	free(array);
}

