/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:             GRcreate_lbs
 
     Abstract:

               This routine initializes a local bounded system (LBS)
               geometry.  First it initializes the two local range 
               block diagonals (the extents).  Next it multiplies the 
               inverse of the view rotation matrix by the angle rotation 
               matrix and inserts the origin in the 4th column of the
               product matrix to produce the transformation matrix of
               the LBS.
-----
%SC%

  VALUE = GRcreate_lbs(msg,active_angle,rot_matrix,origin,lbs_extents,lbs_geom)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ------------------------------------
    *msg          IGRlong           completion code
    *active_angle IGRdouble         angle of text placement
    *rot_matrix   IGRmatrix         view rotation matrix
    *origin       IGRpoint          origin of text (justification point)
    *lbs_extents  struct extents    the extents of the element
                                    (relative to origin)
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
     ----------     --------------- -----------------------------------------
     *lbs_geom      struct IGRlbsys initialized local bounded system geometry

     VALUE (IGRlong) =    MSSUCC    - if successful
                          MSFAIL    - if failure
-----
%MD%

     MODULES INVOKED:

     modules:  MAtrnmx
               MArotmx
               MAmulmx
-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        WBC  04/01/86 : Design date.
        WBC  04/01/86 : Creation date.
        SCW  07/22/92 : Removed copyright header
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine initializes a local bounded system (LBS) geometry
for an element.  The local range block diagonal points are taken
from the extents, which were calculated with respect to the origin.
The transformation matrix is calculated by multiplying the inverse 
of the view rotation matrix by the angle rotation matrix (if given)
and then inserting the origin into the 4th column of the 
transformation matrix.

----*/
/*EH*/

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "igrdp.h"
#include "gotext.h"
#include "grimport.h"

IGRboolean GRcreate_lbs(msg,active_angle,rot_matrix,origin,
                        lbs_extents,lbs_geom)

IGRlong             *msg;
IGRdouble           *active_angle;
IGRdouble           *rot_matrix;
IGRdouble           *origin;
struct extents      *lbs_extents;
struct IGRlbsys     *lbs_geom;
{
        extern IGRboolean  MAtrnmx();
        extern IGRboolean  MArotmx();
        extern IGRboolean  MAmulmx();

        IGRboolean  status;
        IGRdouble   vect[3], invrotmatrix[16], angrotmatrix[16];
        IGRshort    dimension, i;
        IGRlong     temp_msg;

        *msg = MSSUCC;
        status = 1;
        dimension = 4;

        /* 
         *  Initialize extents (local range block diagonal points).
         */

        lbs_geom->diag_pt1[0] = lbs_extents->left;
        lbs_geom->diag_pt1[1] = lbs_extents->bottom;
        lbs_geom->diag_pt1[2] = 0;
        lbs_geom->diag_pt2[0] = lbs_extents->right;
        lbs_geom->diag_pt2[1] = lbs_extents->top;
        lbs_geom->diag_pt2[2] = 0;

        /*
         *  Calculate transformation matrix by multiplying the inverse
         *  (transpose) of the view rotation matrix by the angle rotation 
         *  matrix and inserting the origin in the 4th column.
         */

        if (MAtrnmx(&temp_msg, &dimension, rot_matrix, invrotmatrix))
        {
            if (*active_angle != 0)
            {
                vect[0] = 0;
                vect[1] = 0;
                vect[2] = 1;

                if (MArotmx(&temp_msg, vect, active_angle, angrotmatrix))
                {
                    MAmulmx(&temp_msg, &dimension, &dimension, &dimension,
                            invrotmatrix, angrotmatrix, lbs_geom->matrix);
                }
                else
                {
                    *msg = MSFAIL;
                    status = 0;
                }
            }
            else
            {
                for (i=0; i < 16; ++i)
                {
                    lbs_geom->matrix[i] = invrotmatrix[i];
                }
            }

            lbs_geom->matrix[3]  = origin[0];
            lbs_geom->matrix[7]  = origin[1];
            lbs_geom->matrix[11] = origin[2];
        }
        else
        {
            *msg = MSFAIL;
            status = 0;
        }
        
        return(status);
}
