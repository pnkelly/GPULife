#!/bin/csh
#module load openmpi
#module load gcc
echo compiling game of life
rm iter*
make clean
make run 
./gameOfLife 
echo done 

