#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/sfrng.h"
#include "PWapi/sflp.h" 
#include "PWapi/lpprops.h"

/*
  ABSTRACT
  
  Returns the tightest range box in the UV-space of the surface
  that encloses all the faces.
*/

void pwGetSfUvRng 
(
  PWobjid sf,
  PWosnum os,
  PWrange2d uvrng
)
{
  int i, j;
  PWobjid face;
  PWrange2d lprng;

  pwGetNatSfUvRng (sf, os, uvrng);

  for (i=0, face=pwOuterFaceAtInxOfSf (sf, os, i);
       face != PW_K_NullObjid;
       i++, face=pwOuterFaceAtInxOfSf (sf, os, i))
  {
    pwGetLpRange (face, os, lprng);
    for (j=U; j<=V; j++)    
      if (lprng[MINIMUM][j] < uvrng[MINIMUM][j])
        uvrng[MINIMUM][j] = lprng[MINIMUM][j];
    for (j=U; j<=V; j++)    
      if (lprng[MAXIMUM][j] > uvrng[MAXIMUM][j])
        uvrng[MAXIMUM][j] = lprng[MAXIMUM][j];
  }
  
 /*
  * In case  u v values are not in the range of 0  
  * and 1 this fix forces values to lie between
  * 0 and 1 if it exceeds the limits.  --V.Srinivas
  */
  for(i=MINIMUM;i<=MAXIMUM;++i)
  {
   for(j=U;j<=V;++j)
   {
    if(uvrng[i][j]<0)
      uvrng[i][j]=0;
    else if(uvrng[i][j]>1)
      uvrng[i][j]=1;
   }
  }
  return;
}


/*
  ABSTRACT

  This function returns the range of the UV-space of the given
  surface
*/

void pwGetNatSfUvRng
(
  PWobjid  sfobj,
  PWosnum  os,
  PWrange2d uvrng
)
{
  uvrng[U][MINIMUM] = 0.0;
  uvrng[U][MAXIMUM] = 1.0;
  uvrng[V][MINIMUM] = 0.0;
  uvrng[V][MAXIMUM] = 1.0;

  return;
}
