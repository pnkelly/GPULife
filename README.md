This is repository is a demonstration of GPU interoperability. 

So far, only CUDA and OpenACC with MPI are functioning, but 
OpenMP4 is being added in Testing. 

CUDA+OpenACC: contains the interoperable GPU languages + MPI
Hybrid: contains all the GPU languages, but they are not interoperable

testing: OpenACC+OpenMP4 with cmake

  In testing directory
  -- with PGI 16.5, OpenMPI 1.10.1, Cuda 8.0
  cmake .
  make
  mpirun -n 2 ./gameOfLife
