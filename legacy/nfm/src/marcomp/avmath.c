
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* avmath.c -- autoview math functions */

#include "avhdr.h"
#include "3dpak.c"
/*  ARBAXIS.C    9/15/88 */


/*  This module defines the ARBAXIS routine for obtaining an
    arbitrary but repeatable coordinate axis from a given entity
    normal (extrusion direction).  In this manner, a complete coordinate
    system can be (reliably) built from only 3 real numbers.

    Support routines are provided here for creating a 4x4 coordinate
    system matrix from an entity normal, and for transforming a point
    given the normal.  Some general vector geometry support routines
    are also included.


*/


#define X  0			   /* Coordinate indices */
#define Y  1
#define Z  2
#define T  3

#define ARBBOUND  0.015625  /* aka "1/64" */
#define ZERO 1e-10

/*  Local stuff */

static double yaxis[3] = {0.0, 1.0, 0.0};
static double zaxis[3] = {0.0, 0.0, 1.0};


/*  ARBAXIS -- Given a unit vector to be used as one of the axes of a
               coordinate system, choose a second axis.  The choice is
               in principal arbitrary; we just want to make it pre-
               dictable.  Our method is to examine the given Z axis
               and see if it is close to the world Z axis or the
               negative of the world Z axis.  If it is, we cross the
               given Z axis with the world Y axis to arrive at the
               arbitrary X axis.  If not, we cross the given Z axis with
               the world Z axis to arrive at the arbitrary X axis.
               The boundary at which the decision is made was designed to
               be both inexpensive to calculate and to be completely
               portable across machines.  This is done by having a
               sort of "square" polar cap, the bounds of which is
               1/64, which is fully specifiable in 6 decimal fraction
               digits and in 6 binary fraction bits.

               To get a right-handed system, treat the axis returned by
               this function as the cyclically next one after the given
               axis (e.g., if you give it a Z-axis, it returns a
               suitable X-axis).

*/
void arbaxis(newaxis, givenaxis)
double *newaxis, *givenaxis;
{
    if (fabs(givenaxis[X]) < ARBBOUND && fabs(givenaxis[Y]) < ARBBOUND)
      crossproduct(yaxis,givenaxis,newaxis);
    else
      crossproduct(zaxis,givenaxis,newaxis);
/* crossproduct now normalizes automatically */
}

/*  GETA4BY4 -- Given the entity's normal (extrusion direction vector),
                return a 4x4 matrix that defines the transform in 3D.
                mat is assumed to be matrix[4][4], where the
                the first subscript represents X,Y,Z,Dummy.

                Speed is sacrificed here in favor of comprehensibility.
*/

void geta4by4(normaxis, mat)
double normaxis[4];
double mat[4][4];
{
    double xdir[4], ydir[4], zdir[4];

    memcpy(zdir,normaxis,4*sizeof(double));

    /* First get the arbitrary x axis of the entity given its norm (Z) */

    arbaxis(xdir, zdir);

    /* Now we cross our new X-axis with our norm (Z) to get the Y-axis */

    crossproduct(zdir, xdir, ydir);

    /* And we normalize that to a unit vector */

/* crossproduct now normalizes automatically */

    /* We now have all the components of the transformation matrix. */
    
    identity(mat);
/*
    mat[0][0] = xdir[X];
    mat[0][1] = xdir[Y];
    mat[0][2] = xdir[Z];
    mat[1][0] = ydir[X];
    mat[1][1] = ydir[Y];
    mat[1][2] = ydir[Z];
    mat[2][0] = zdir[X];
    mat[2][1] = zdir[Y];
    mat[2][2] = zdir[Z];
*/
    memcpy(mat[0],xdir,3*sizeof(double));
    memcpy(mat[1],ydir,3*sizeof(double));
    memcpy(mat[2],zdir,3*sizeof(double));
}

/*  acadtrans  --   Transform a point, given a normal vector (3 reals).
                Returns the point in pt.  */

void acadtrans(pt)
double pt[4];
{
    register int i;
    double sum[4];

    /* Now, do a standard matrix transformation on the point. */

    for (i=0; i<3; i++)
        sum[i] = ad3in.extrumat[0][i] * pt[X] +
                 ad3in.extrumat[1][i] * pt[Y] +
                 ad3in.extrumat[2][i] * pt[Z] +
                 ad3in.extrumat[3][i];

/*
    pt[X] = sum[X];
    pt[Y] = sum[Y];
    pt[Z] = sum[Z];
*/
    memcpy(pt,sum,3*sizeof(double));
}

#ifdef UNUSED
double vecdist(a,b)
double a[4],b[4];
{
  return(sqrt((a[0]-b[0])*(a[0]-b[0])+
              (a[1]-b[1])*(a[1]-b[1])+
              (a[2]-b[2])*(a[2]-b[2])));
}
#endif

void crossproduct(a,b,c)
/* c= a x b */
double a[4],b[4],c[4];
{
  double temp[4];

  temp[0]=a[1]*b[2]-a[2]*b[1]; 
  temp[1]=a[2]*b[0]-a[0]*b[2];
  temp[2]=a[0]*b[1]-a[1]*b[0];
  temp[3]=1.0;

  memcpy(c,temp,4*sizeof(double));
  normalize(c);
}

void normalize(a)
double a[4];
/* normalize a vector to unit length */
{
  double tnum;

  tnum=sqrt(a[0]*a[0]+a[1]*a[1]+a[2]*a[2]);
  a[0]/=tnum;
  a[1]/=tnum;
  a[2]/=tnum;
  a[3]=1.0;
}

void rotatearoundaxis(pttorot,targetpt,rotaxis,theta)
double pttorot[4],targetpt[4],rotaxis[4],theta;
{
  double rotpt[4];
  double rotmat[4][4];
  double n1,n2,n3,mr1,n1n2mr1,n1n3mr1,n2n3mr1,sint,cost;
  double tnum2,n1sin,n2sin,n3sin;
  short i;

  /* first, move to origin to rotate */
  for (i=0; i<3; i++) rotpt[i]=pttorot[i]-targetpt[i];
  rotpt[3]=1.0;
  tnum2=sqrt(rotaxis[0]*rotaxis[0]+rotaxis[1]*rotaxis[1]+rotaxis[2]*rotaxis[2]);
  n1=rotaxis[0]/tnum2;
  n2=rotaxis[1]/tnum2;
  n3=rotaxis[2]/tnum2;
  sint=sin(theta);
  cost=cos(theta);
  mr1=1-cost;
  n1n2mr1=n1*n2*mr1;
  n1n3mr1=n1*n3*mr1;
  n2n3mr1=n2*n3*mr1;
  n1sin=n1*sint;
  n2sin=n2*sint;
  n3sin=n3*sint;
  rotmat[0][0]=n1*n1+(1-n1*n1)*cost;
  rotmat[0][1]=n1n2mr1+n3sin;
  rotmat[0][2]=n1n3mr1-n2sin;
  rotmat[1][0]=n1n2mr1-n3sin;
  rotmat[1][1]=n2*n2+(1-n2*n2)*cost;
  rotmat[1][2]=n2n3mr1+n1sin;
  rotmat[2][0]=n1n3mr1+n2sin;
  rotmat[2][1]=n2n3mr1-n1sin;
  rotmat[2][2]=n3*n3+(1-n3*n3)*cost;
  rotmat[0][3]=rotmat[1][3]=rotmat[2][3]=rotmat[3][0]=rotmat[3][1]
    =rotmat[3][2]=0.0;
  rotmat[3][3]=1.0;
  transformpoint3d(rotpt,rotmat,rotpt);
/* now translate back out */
  for (i=0; i<3; i++) pttorot[i]=rotpt[i]+targetpt[i];
}


/* end of 3d routines */
