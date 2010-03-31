/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
void MSaccprop(prop, acc_prop)


Given mass properties in global system at centroids of two objects
"prop" and "acc_prop", this returns the properties at the new centroid in
"acc_prop".


IGRdouble	prop[];	mass properties
IGRdouble	acc_prop[];	accumulated properties

Note:
1.	mass properties  prop are passed in as follows:
	
	0	volume
	1	mass
	2,3,4	centroid
	5	moment of inertia about x axis
	6	moment of inertia about y axis
	7	moment of inertia about z axis
	8	product moment xy
	9	product moment yz
	10	product moment zx
	11	surface area
        12,13,14 Center of Volume
        16,17,18 Centroid of Volume

History:
	gk	10/27/87		creation date
*/

# include "igrtypedef.h"
# include "emsmass.h"

void MSaccprop(prop, cum)

IGRdouble	*prop, *cum;

{
  IGRlong	i;
  IGRdouble	loc[NUMB_PROPS], c_cent[3], p_cent[3];

  loc[0] = prop[0] + cum[0];	/* volume */
  loc[1] = prop[1] + cum[1]; 	/* mass */

/* compute the new centroid */

  loc[2] = (prop[1] * prop[2] + cum[1] * cum[2]) / loc[1];
  loc[3] = (prop[1] * prop[3] + cum[1] * cum[3]) / loc[1];
  loc[4] = (prop[1] * prop[4] + cum[1] * cum[4]) / loc[1];

  p_cent[0] = prop[2] - loc[2];
  p_cent[1] = prop[3] - loc[3];
  p_cent[2] = prop[4] - loc[4];

  c_cent[0] = cum[2] - loc[2];
  c_cent[1] = cum[3] - loc[3];
  c_cent[2] = cum[4] - loc[4];

/* translate the prop and cum to the new centroid */

/* 1. moment about x axis */

  loc[5] = (prop[5] + cum[5]) +
	   (prop[1] * (p_cent[1]*p_cent[1] + p_cent[2]*p_cent[2])) +
	   (cum[1]  * (c_cent[1]*c_cent[1] + c_cent[2]*c_cent[2]));

/* 2. moment about y axis */

  loc[6] = (prop[6] + cum[6]) +
	   (prop[1] * (p_cent[2]*p_cent[2] + p_cent[0]*p_cent[0])) +
	   (cum[1]  * (c_cent[2]*c_cent[2] + c_cent[0]*c_cent[0]));

/* 3. moment about z axis */

  loc[7] = (prop[7] + cum[7]) +
	   (prop[1] * (p_cent[0]*p_cent[0] + p_cent[1]*p_cent[1])) +
	   (cum[1]  * (c_cent[0]*c_cent[0] + c_cent[1]*c_cent[1]));

/* 4. product moment xy */

  loc[8] = (prop[8] + cum[8]) +
	   (prop[1] * p_cent[0] * p_cent[1]) + 
	   (cum[1]  * c_cent[0] * c_cent[1]);

/* 5. product moment yz */

  loc[9] = (prop[9] + cum[9]) +
	   (prop[1] * p_cent[1] * p_cent[2]) + 
	   (cum[1]  * c_cent[1] * c_cent[2]);

/* 6. product moment zx */

  loc[10] = (prop[10] + cum[10]) +
	    (prop[1] * p_cent[2] * p_cent[0]) + 
	    (cum[1]  * c_cent[2] * c_cent[0]);

/* Surface area */

  loc[11] = prop[11] + cum[11];

/* Centroid of Volume */

   loc[16] = (prop[0]*prop[16] + cum[0]*cum[16])/(prop[0]+cum[0]);
   loc[17] = (prop[0]*prop[17] + cum[0]*cum[17])/(prop[0]+cum[0]);
   loc[18] = (prop[0]*prop[18] + cum[0]*cum[18])/(prop[0]+cum[0]);

  for(i = 0; i < 20; i ++) cum[i] = loc[i];
 return;
}
