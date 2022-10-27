
#define _CRT_SECURE_NO_WARNINGS
#include "global.h"
#include "initialize.cu"
#include "Output_PNM.cu"
#include "Iteration_PNM.cu"

int main(int argc, char *argv[])
{
	void setup();
	void Iteration();
	void initialize();

    setup();
    initialize();
 
    clock_t start, finish; 
	start = clock();
	//ieration
	double outT = 1.0; //double outT = 1.0;
	//t_sum = 335369.691918;
	for (t = 0; t < Time; t++)
	{
	    Iteration();
		t_sum = t_sum + hmint;
        if (int(pow(10, outT)) == t)
	    {
			Output_PNM();
			output(t);
			outT = outT + 0.1;
		}
        printf("%d\n", t);
		//getchar();
		finish=clock();
		if ((finish-start)/CLOCKS_PER_SEC > 47.5 * 3600)
    	{
	        break;
    	}
	}
    finish=clock();
    std::cout <<"total time for ieration:" << (double)(finish-start)/CLOCKS_PER_SEC << "\n";
    Output_PNM();
    Free_PNM();
	output(t);
}

//------------------------------------------------------------------------------
void setup()
{
    int i;
	//-----------------------------------------------------------
	sprintf(filename, "pth2pb_full.txt");
	if ((fp = fopen(filename, "r")) == NULL){ printf("Reading pth2pb_full.txt error.\n"); getchar(); exit(1); }
	for (i = 0; i < TF; i++)
	{
		fscanf(fp, "%d", &Prr[i]);
		fscanf(fp, "%lf", &Trans[i]);
		fscanf(fp, "%lf", &Flux[i]);
	}
	fclose(fp);
	//-----------------------------------------------------------
	sprintf(filename, "Volume.txt");
	if ((fp = fopen(filename, "r")) == NULL){ printf("Reading Volume.txt error.\n"); getchar(); exit(1); }
	for (i = 0; i < TF; i++)
	{
		fscanf(fp, "%lf", &Volume[i]);
	}
	fclose(fp);
	//-----------------------------------------------------------
	sprintf(filename, "coord_nr.txt");
	if ((fp = fopen(filename, "r")) == NULL){ printf("Reading coord_nr.txt error.\n"); getchar(); exit(1); }
	for (i = 0; i < PE; i++)
	{
		fscanf(fp, "%d", &CoordMat[i]);
	}
	fclose(fp);
	//-----------------------------------------------------------
	sprintf(filename, "coord_nr_sum.txt");
	if ((fp = fopen(filename, "r")) == NULL){ printf("Reading coord_nr_sum.txt error.\n"); getchar(); exit(1); }
	for (i = 0; i < PE; i++)
	{
		fscanf(fp, "%d", &CoordMat_sum[i]);
	}
	fclose(fp);

	//-----------------------------------------------------------
	//initialize the consentration
	Cons = new double [PE + 2];
	for(i = 0; i < PE; i++)
    {
        Cons[i] = A0;
    }
    for(i = 0; i < TP; i++)
    {
        Cons[i] = Ai;
    }
	Cons[PE] = Ai;//inlet
	Cons[PE + 1] = A0; //outlet}

	// for continue
	/*sprintf(filename, "Concentration_203235701.txt");
	if ((fp = fopen(filename, "r")) == NULL){ printf("Reading coord_nr_sum.txt error.\n"); getchar(); exit(1); }
	fscanf(fp, "%lf", &t_sum);
	for (i = 0; i < PE; i++)
	{
		fscanf(fp, "%lf", &Cons[i]);
	}
	fclose(fp);*/

}
void output(int t)
{
    int i;
    sprintf(filename, "Concentration_%d.txt",t);
    if ((fp = fopen(filename, "w")) == NULL) { printf("Concentration.txt open error.\n"); getchar(); exit(1); }
	fprintf(fp, "%.15f\n", t_sum);
    for (i = 0; i < PE; i++)
    {
        fprintf(fp, "%.15f\n", Cons[i]);
    }
    fclose(fp);
}
