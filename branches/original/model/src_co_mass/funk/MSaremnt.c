/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include "msdef.h"

/* *************************
Description

This function computes the first area moments when given the origin about
which the properties are computed, centroid, in global coordinate system
and the properties. 

Arguments

Input
 origin : In global coordinate system
 centroid : In global coordinate system
 prop : array of size 20 whose format is the same as that for Area properties.

Output
 mx : First area moment about x axis.
 my : First area moment about y axis.

History: 

  Creation : pp : 02/15/90
******************************* */

MSget_first_area_moments(rec_origin,centroid,prop,mx,my)

double *rec_origin;
double *centroid;
double prop[20];
double *mx, *my;

{
  double newcent[3];
  double temp[3];
  double glo_loc[9];
  double sfarea;
  int i;
  double px;

  px = prop[5]*prop[5] + prop[6]*prop[6] + prop[7]*prop[7];

  if (px < 0.95) return (0);

  sfarea = prop[11];

  for (i=0;i<6;i++)
    glo_loc[i] = prop[i+5];

  glo_loc[6] = prop[6]*prop[10] - prop[9]*prop[7];
  glo_loc[7] = prop[7]*prop[8]  - prop[10]*prop[5];
  glo_loc[8] = prop[5]*prop[9]  - prop[8]*prop[6];

  for (i=0;i<3;i++)
   temp[i] = centroid[i] - rec_origin[i];

  for (i=0;i<3;i++)
   newcent[i] = glo_loc[i*3]*temp[0] + glo_loc[i*3+1]* temp[1] + 
                glo_loc[i*3+2]*temp[2];

  *mx = sfarea * newcent[0];
  *my = sfarea * newcent[1];

  return (1);
}
