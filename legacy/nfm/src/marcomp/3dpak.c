
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#ifndef PI
#define PI 3.141592653589793
#endif

#ifdef THESE
double degreestoradians(degrees)
double degrees;
{
  return(degrees*PI/180.0);
}

void setpoint(pakpoint,x,y,z)
double pakpoint[4],x,y,z;
{

  pakpoint[0]=x;
  pakpoint[1]=y;
  pakpoint[2]=z;
  pakpoint[3]=1.0;
}
#endif

void printmatrix(mat)
double mat[4][4];
{
  short i,j;

  for (i=0; i<4; i++) {
    for (j=0; j<4; j++)
      printf("%8.4lf  ",mat[i][j]);
    printf("\n");
  }
}

#ifdef THESE
void printpoint(pakpoint)
double pakpoint[4];
{
  short i;

  printf("%7.4lf, %7.4lf, %7.4lf, %7.4lf\n",pakpoint[0],pakpoint[1],pakpoint[2],pakpoint[3]);
}

#endif

void identity(mat)
double mat[4][4];
{
  static double identitymat[4][4]={
                             {1.0, 0.0, 0.0, 0.0},
                             {0.0, 1.0, 0.0, 0.0},
                             {0.0, 0.0, 1.0, 0.0},
                             {0.0, 0.0, 0.0, 1.0},
                           };
/* even more cheating version */
  memcpy(mat,identitymat,16*sizeof(double));
}

void matmult(mata,matb,matc)
double mata[4][4],matb[4][4],matc[4][4];
{
/* c=a*b */
  double tmat[4][4];
  register short i,j;

  for (i=0; i<4; i++)    /* row of left matrix */
    for (j=0; j<4; j++)  /* col of right matrix */
      tmat[i][j]=mata[i][0]*matb[0][j]+
                 mata[i][1]*matb[1][j]+
                 mata[i][2]*matb[2][j]+
                 mata[i][3]*matb[3][j];
  /* copy back to matc -- high speed version */
  memcpy(matc,tmat,16*sizeof(double));
}

void transformpoint3d(pakpoint,mat,pakpoint2)
double pakpoint[4],mat[4][4],pakpoint2[4];
{
  short i;
  double tpoint[4];

  for (i=0; i<4; i++)
    tpoint[i]=
      pakpoint[0]*mat[0][i]+
      pakpoint[1]*mat[1][i]+
      pakpoint[2]*mat[2][i]+
      pakpoint[3]*mat[3][i];
  /* Remove size_t as it is not neccessary - SSRS - 25/11/93 */
  /*memcpy(pakpoint2,tpoint,(size_t)4*sizeof(double));*/
  memcpy(pakpoint2,tpoint,4*sizeof(double));
/*  for (i=0; i<4; i++) pakpoint2[i]=tpoint[i]; */
}


void translatematrix(pt0,mat)
double pt0[3],mat[4][4];
{
/*
  double tmat[4][4];

  identity(tmat);
  memcpy(tmat[3],pt0,3*sizeof(double));
  matmult(tmat,mat,mat);
*/
  mat[3][0]=mat[0][0]*pt0[0]+mat[1][0]*pt0[1]+mat[2][0]*pt0[2]+mat[3][0];
  mat[3][1]=mat[0][1]*pt0[0]+mat[1][1]*pt0[1]+mat[2][1]*pt0[2]+mat[3][1];
  mat[3][2]=mat[0][2]*pt0[0]+mat[1][2]*pt0[1]+mat[2][2]*pt0[2]+mat[3][2];
  mat[3][3]=mat[0][3]*pt0[0]+mat[1][3]*pt0[1]+mat[2][3]*pt0[2]+mat[3][3];
}

void moveforrotsc(x,y,z,mat)
double x,y,z,mat[4][4];
{
/*
  double tmat[4][4];

  identity(tmat);
  tmat[3][0]=x;
  tmat[3][1]=y;
  tmat[3][2]=z;
  matmult(mat,tmat,mat);
*/
  mat[0][0]+=mat[0][3]*x;
  mat[0][1]+=mat[0][3]*y;
  mat[0][2]+=mat[0][3]*z;
  mat[1][0]+=mat[1][3]*x;
  mat[1][1]+=mat[1][3]*y;
  mat[1][2]+=mat[1][3]*z;
  mat[2][0]+=mat[2][3]*x;
  mat[2][1]+=mat[2][3]*y;
  mat[2][2]+=mat[2][3]*z;
  mat[3][0]+=mat[3][3]*x;
  mat[3][1]+=mat[3][3]*y;
  mat[3][2]+=mat[3][3]*z;
}

void scalematrix(xscale,yscale,zscale,mat)
double xscale,yscale,zscale,mat[4][4];
{
/*  double tmat[4][4]; */
  double xt,yt,zt;
  register short i;

  xt=mat[3][0]; yt=mat[3][1]; zt=mat[3][2];
  moveforrotsc(-xt,-yt,-zt,mat);    /* trans to origin */

/*  identity(tmat);
  tmat[0][0]=xscale;
  tmat[1][1]=yscale;
  tmat[2][2]=zscale;
  matmult(tmat,mat,mat);
*/

  for (i=0; i<4; i++) {
    mat[0][i]*=xscale;
    mat[1][i]*=yscale;
    mat[2][i]*=zscale;
  }

  moveforrotsc(xt,yt,zt,mat);       /* and back */
}

void rotatematrixz(angle,mat)
double angle,mat[4][4];
/* rotates about z axis only!! */
{
  double tmat[4][4];
/*  double xt,yt,zt; */
  double cosa,sina;

/*
  xt=mat[3][0]; yt=mat[3][1]; zt=mat[3][2];
  moveforrotsc(-xt,-yt,-zt,mat);

  identity(tmat);
  tmat[0][0]=cos(angle);
  tmat[0][1]=sin(angle);
  tmat[1][0] = -tmat[0][1];
  tmat[1][1]=tmat[0][0];
  matmult(tmat,mat,mat);
*/
  memcpy(tmat,mat,16*sizeof(double));
  cosa=cos(angle);
  sina=sin(angle);
  tmat[0][0]=mat[0][0]*cosa+mat[1][0]*sina;
  tmat[0][1]=mat[0][1]*cosa+mat[1][1]*sina;
  tmat[0][2]=mat[0][2]*cosa+mat[1][2]*sina;
  tmat[0][3]=mat[0][3]*cosa+mat[1][3]*sina;
  tmat[1][0]=mat[1][0]*cosa-mat[0][0]*sina;
  tmat[1][1]=mat[1][1]*cosa-mat[0][1]*sina;
  tmat[1][2]=mat[1][2]*cosa-mat[0][2]*sina;
  tmat[1][3]=mat[1][3]*cosa-mat[0][3]*sina;
  memcpy(mat,tmat,16*sizeof(double));
/*
  moveforrotsc(xt,yt,zt,mat);
*/
       /* and back */
}

#ifdef THESE
void rotatematrixx(angle,mat)
double angle,mat[4][4];
/* rotates about x axis only!! */
{
  double tmat[4][4];
  double xt,yt,zt;

  xt=mat[3][0]; yt=mat[3][1]; zt=mat[3][2];
  moveforrotsc(-xt,-yt,-zt,mat);    /* trans to origin */

  identity(tmat);
  tmat[1][1]=cos(angle);
  tmat[1][2]=sin(angle);
  tmat[2][1] = -tmat[1][2];
  tmat[2][2]=tmat[1][1];
  matmult(tmat,mat,mat);
  moveforrotsc(xt,yt,zt,mat);       /* and back */
}

void perspectivetransz(pakpoint,transval,pakpoint2)
double pakpoint[4],transval,pakpoint2[4];
{
  double tv;
  register short i;

  tv=transval*pakpoint[2]+1;
  for (i=0; i<3; i++)
    pakpoint2[i]=pakpoint[i]/tv;
}
#endif

