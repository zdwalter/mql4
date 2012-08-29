////////////////////////////////////////////////////////////////////////////
//MLP neural network in C++
//Original source code by Dr Phil Brierley
//www.philbrierley.com
//Translated to C++ - dspink Sep 2005
//This code may be freely used and modified at will
//C++ Compiled using Bloodshed Dev-C++ free compiler http://www.bloodshed.net/
//C Compiled using Pelles C free windows compiler http://smorgasbordet.com/
////////////////////////////////////////////////////////////////////////////

//#include <iostream.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <math.h>


//// Data dependent settings ////
#define numInputs  3
#define numPatterns  4


//// User defineable settings ////
#define numHidden 4
const int numEpochs = 500;
const double LR_IH = 0.7;
const double LR_HO = 0.07;


//// functions ////
void initWeights();
void initData();
void calcNet();
void WeightChangesHO();
void WeightChangesIH();
void calcOverallError();
void displayResults();
double getRand();


//// variables ////
int patNum = 0;
double errThisPat = 0.0;
double outPred = 0.0;
double RMSerror = 0.0;

// the outputs of the hidden neurons
double hiddenVal[numHidden];

// the weights
double weightsIH[numInputs][numHidden];
double weightsHO[numHidden];

// the data
int trainInputs[numPatterns][numInputs];
int trainOutput[numPatterns];


//==============================================================
//************** function definitions **************************
//==============================================================


//***********************************
// calculates the network output
void calcNet(void)
{
    //calculate the outputs of the hidden neurons
    //the hidden neurons are tanh
    int i = 0;
    for(i = 0;i<numHidden;i++)
    {
        hiddenVal[i] = 0.0;

        for(int j = 0;j<numInputs;j++)
        {
            hiddenVal[i] = hiddenVal[i] + (trainInputs[patNum][j] * weightsIH[j][i]);
        }

        hiddenVal[i] = tanh(hiddenVal[i]);
    }

    //calculate the output of the network
    //the output neuron is linear
    outPred = 0.0;

    for(i = 0;i<numHidden;i++)
    {
        outPred = outPred + hiddenVal[i] * weightsHO[i];
    }
    //calculate the error
    errThisPat = outPred - trainOutput[patNum];

}


//************************************
//adjust the weights hidden-output
void WeightChangesHO(void)
{
    for(int k = 0;k<numHidden;k++)
    {
        double weightChange = LR_HO * errThisPat * hiddenVal[k];
        weightsHO[k] = weightsHO[k] - weightChange;

        //regularisation on the output weights
        if (weightsHO[k] < -5)
        {
            weightsHO[k] = -5;
        }
        else if (weightsHO[k] > 5)
        {
            weightsHO[k] = 5;
        }
    }

}


//************************************
// adjust the weights input-hidden
void WeightChangesIH(void)
{

    for(int i = 0;i<numHidden;i++)
    {
        for(int k = 0;k<numInputs;k++)
        {
            double x = 1 - (hiddenVal[i] * hiddenVal[i]);
            x = x * weightsHO[i] * errThisPat * LR_IH;
            x = x * trainInputs[patNum][k];
            double weightChange = x;
            weightsIH[k][i] = weightsIH[k][i] - weightChange;
        }
    }

}


//************************************
// generates a random number
double getRand(void)
{
    return ((double)rand())/(double)RAND_MAX;
}



//************************************
// set weights to random numbers 
void initWeights(void)
{

    for(int j = 0;j<numHidden;j++)
    {
        weightsHO[j] = (getRand() - 0.5)/2;
        for(int i = 0;i<numInputs;i++)
        {
            weightsIH[i][j] = (getRand() - 0.5)/5;
            printf("Weight = %f\n", weightsIH[i][j]);
        }
    }

}


//************************************
// read in the data
void initData(void)
{
    printf("initialising data\n");

    // the data here is the XOR data
    // it has been rescaled to the range
    // [-1][1]
    // an extra input valued 1 is also added
    // to act as the bias
    // the output must lie in the range -1 to 1

    trainInputs[0][0]  = 1;
    trainInputs[0][1]  = -1;
    trainInputs[0][2]  = 1;    //bias
    trainOutput[0] = 1;

    trainInputs[1][0]  = -1;
    trainInputs[1][1]  = 1;
    trainInputs[1][2]  = 1;       //bias
    trainOutput[1] = 1;

    trainInputs[2][0]  = 1;
    trainInputs[2][1]  = 1;
    trainInputs[2][2]  = 1;        //bias
    trainOutput[2] = -1;

    trainInputs[3][0]  = -1;
    trainInputs[3][1]  = -1;
    trainInputs[3][2]  = 1;     //bias
    trainOutput[3] = -1;

}


//************************************
// display results
void displayResults(void)
{
    for(int i = 0;i<numPatterns;i++)
    {
        patNum = i;
        calcNet();
        printf("pat = %d actual = %d neural model = %f\n",patNum+1,trainOutput[patNum],outPred);
    }
        printf("%d, %d\n", numInputs, numHidden);
    for(int i = 0; i < numInputs; i++)
    {
        for (int j = 0; j < numHidden; j++)
            printf("%.6f\t", weightsIH[i][j]); 
        printf("\n");
    }

        printf("lalala\n");
    for (int j = 0; j < numHidden; j++)
        printf("%.6f\t", weightsHO[j]); 
    printf("\n");
}


//************************************
// calculate the overall error
void calcOverallError(void)
{
    RMSerror = 0.0;
    for(int i = 0;i<numPatterns;i++)
    {
        patNum = i;
        calcNet();
        RMSerror = RMSerror + (errThisPat * errThisPat);
    }
    RMSerror = RMSerror/numPatterns;
    RMSerror = sqrt(RMSerror);
}



//==============================================================
//********** THIS IS THE MAIN PROGRAM **************************
//==============================================================


int main(void)
{
    // seed random number function
    srand ( time(NULL) );
    
    printf("tanh %f\n", tanh(8.623015));
    // initiate the weights
    initWeights();

    // load in the data
    initData();

    // train the network
    for(int j = 0;j <= numEpochs;j++)
    {
        for(int i = 0;i<numPatterns;i++)
        {
            //select a pattern at random
            patNum = rand()%numPatterns;

            //calculate the current network output
            //and error for this pattern
            calcNet();

            //change network weights
            WeightChangesHO();
            WeightChangesIH();
        }

        //display the overall network error
        //after each epoch
        calcOverallError();

        printf("epoch = %d RMS Error = %f\n",j,RMSerror);
    }

    //training has finished
    //display the results
    displayResults();


    return 0;
}

