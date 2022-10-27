#include<stdio.h>
#include<math.h>
#include<malloc.h>
#include<time.h>
#include<cuda.h>
#include<cuda_runtime.h>
#include "cublas_v2.h"
#include <iostream>
#include <stdlib.h>
//#include "defines.h"
#include"array.h"
#include"basic.h"

using namespace std;

#define  NX      128       // the size ofcalculation******************************************
#define  NZ      128      // the size of calculation********************************************
//#define  NZ      64     //  unknown should less than 64, we can set it 1******************************************

//#define  PE      58500   //pore
//#define  TT      167077  //throat
//#define  CN      11      //coordination number
//#define  BM      1506    //bottom boundary
//#define  TP      1506    //top boundary
//#define  TF      328130  //2 * (TT - BM - TP)

#define  Time    100000000000    //time step

#define  pi     3.1415926
void     output(int t);
void     setup();
void     Error();
/////////////////////////////////////////// Start GPU Parts



//bstd::Array<double, PE + TT - BM - TP, 1> AA; //PE + TT - BM - TP
//bstd::Array<int, PE + TT - BM - TP, 1> ArrI, ArrJ;
bstd::Array<double, PE, 1> Volume;
bstd::Array<int, PE, 1> CoordMat, CoordMat_sum;
bstd::Array<int, TF, 1> Prr;
bstd::Array<double, TF, 1> Flux, Trans;
//int nozero = PE + TT - BM - TP;
int t;
double *Cons;
//double basic[20]

FILE   *fp;
char  filename[100];

//variables in GPU
double *D_Flux = 0;
double *D_Trans = 0;
double *D_Cons = 0;
double *D_Volume = 0;
double *D_mintime = 0;
double *D_deltaCons = 0;

int *D_CoordMat = 0;
int *D_CoordMat_sum = 0;
int *D_Prr = 0;

int *d_minindex;
int hminindex;
double hmint = 0;
double t_sum = 0;
//double hppk, hppkk, al, ba;

static int iDivUp(int a, int b)
{
	return (a % b != 0) ? (a / b + 1) : (a / b);
	//return (a % (b * 2) != 0) ? ((a / (b * 2) + 1)*2) : (a / b);
}

int NY = iDivUp(PE, NX * NZ);
//NX = iDivUp(termmm, NY);

dim3 blockSize(128, 1, 1);
dim3 gridSize(iDivUp(NZ, blockSize.x), iDivUp(NY, blockSize.y), iDivUp(NX, blockSize.z));

//dim3 gridSize(iDivUp(iDivUp(termmm, NY), blockSize.x), iDivUp(NY, blockSize.y), iDivUp(NZ, blockSize.z));

//end PNM
