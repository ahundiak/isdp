/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRsmplmat

Description
   This routine creates a symbol placement matrix given the
   view rotation matrix, the active angle, the active scale, and
   origin point.

   *msg           IGRlong        completion message 
   *angle         IGRdouble      active angle in radians
   scale[3]       IGRdouble      active x, y, and z scale
   rot_matrix     IGRmatrix      view rotation matrix
   origin         IGRpoint       symbol origin (placement point)
   symbol_matrix  IGRmatrix      symbol placement matrix

Return Values
   MSSUCC    - if successful
   MSFAIL    - if failure

History
   DEM  06/25/86 : Design date and Creation date.
   HGW  05/19/86 : Changed angle from degrees to radians.
   HGW  11/16/87 : Changes for version 1.1
\*/

#include "coimport.h"
#include "igrtypedef.h"
#include "msdef.h"

extern   IGRboolean MAtrnmx();              /* transpose matrix        */
extern   IGRboolean MArotmx();              /* create matrix from angle*/
extern   IGRboolean MAmulmx();              /* multiply two matrices   */


IGRint GRsmplmat(msg,angle,scale,origin,rot_matrix,symbol_matrix)

IGRlong    *msg;                      /* completion code message */
IGRdouble  *angle;                    /* active angle in radians */
IGRdouble  scale[3];                  /* active xyz scale factors*/
IGRpoint   origin;                    /* symbol origin point     */
IGRmatrix  rot_matrix;                /* view rotation matrix    */
IGRmatrix  symbol_matrix;             /* symbol placement matrix */
{
   IGRboolean status;                 /* return status           */
   IGRlong    temp_msg;               /* function completion code*/
   IGRshort   dimension;              /* size of matrix          */
   IGRshort   i;                      /* index counter           */
   IGRdouble  vect[3];                /* vector for MArotmx      */
   IGRmatrix  invrotmatrix;           /* inverse of view matrix  */
   IGRmatrix  angrotmatrix;           /* active angle matrix     */
   IGRmatrix  scale_matrix;           /* scale factor matrix     */
   IGRmatrix  tmp_matrix;             /* temporary matrix        */

   *msg = MSSUCC;                     /* initialize success      */
   status = 1;
   dimension = 4;                     /* size of matrix (4x4)    */

   /*
    * Calculate the symbol placement matrix by multiplying the scale
    * factor matrix by the inverse (transpose) of the view rotation
    * matrix. Multiply that result by the angle rotation matrix and
    * insert the origin into the 4th column.
    */

   /*
    * create the scale factor matrix
    */

   for (i = 0; i < 16; ++i)
   {
      scale_matrix[i] = 0;
   }

   scale_matrix[0] = scale[0];           /* x scale factor          */
   scale_matrix[5] = scale[1];           /* y scale factor          */
   scale_matrix[10] = scale[2];          /* z scale factor          */
   scale_matrix[15] = 1;

   /*
    * transpose the view rotation matrix
    */

   if (MAtrnmx(&temp_msg,&dimension,rot_matrix,invrotmatrix))
   {

      /*
       * multiply the scale matrix by the inverse view matrix
       */

      if (MAmulmx(&temp_msg,&dimension,&dimension,&dimension,scale_matrix,
                  invrotmatrix,tmp_matrix))
      {

         /*
          * if the active angle is not equal to zero, create an
          * angle rotation matrix
          */

         if (*angle != 0)
         {
            vect[0] = 0;
            vect[1] = 0;
            vect[2] = 1;

            if (MArotmx(&temp_msg,vect,angle,angrotmatrix))
            {
               /*
                * multiply the resulting (scale x inverse view)
                * matrix by the angle rotation matrix
                */

               if (!MAmulmx(&temp_msg,&dimension,&dimension,&dimension,
                            tmp_matrix,angrotmatrix,symbol_matrix))
               {
                  *msg = MSFAIL;
                  status = 0;
               }
            }
            else                  /* MArotmx failed            */
            {
               *msg = MSFAIL;
               status = 0;
            }
         }
         else                        /* no active angle           */
         {
            for (i = 0; i < 16; ++i)
            {
               symbol_matrix[i] = tmp_matrix[i];
            }
         }
      }
      else                           /* MAmulmx failed            */
      {
         *msg = MSFAIL;
         status = 0;
      }
   }
   else                              /* MAtrnmx failed            */
   {
      *msg = MSFAIL;
      status = 0;
   }

   /*
    * fill in the 4th column of the symbol placement matrix with the
    * origin point
    */

   symbol_matrix[3] = origin[0];
   symbol_matrix[7] = origin[1];
   symbol_matrix[11] = origin[2];

   return(status);
}
