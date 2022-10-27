# Solute_transport
1. Copy nework into the 0Data file
2. Change the Gen.in
  viscosity, pa.s;
  pressure at the inlet Pa;
  pressure at the oulet Pa;
  molecular diffusion mm^2/s;
  time step;
  Initial condition, mol/mm^3, 1M= 10^-6 mol/mm^3
  Inlet condition, mol/mm^3
3. Run Data_gen.exe in 0Data
4. Login CSF3
5. qrsh -l v100 bash
6. cd your folder
7. module load libs/cuda
8. copy all codes and generated data in 0Data
9. make
10. ./GPU.out
