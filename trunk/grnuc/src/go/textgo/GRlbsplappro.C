/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRlbsplapproj
 
     Abstract:
                This routine constructs a plane defined by a local bounded
           system, a boreline from button structure information and returns the
           intersecting point of the plane and the boreline.
-----
%SC%

     VALUE =  GRlbsplapproj(msg,lbsys,button,proj_pnt,tparam)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                   DESCRIPTION
     ----------   ------------     -------------------------------------
     *lbsys       struct IGRlbsys  local bounded system
     *button      struct EX_button contains point and view info
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   ---------------------------------------
     *msg         IGRlong         Completion code
                                    - MSSUCC if successful
     proj_pnt     IGRpoint        apparent projection of point onto
                                  plane defined by local bounded system
     *tparam      IGRdouble       t parameter of the proj_pnt

     VALUE (IGRboolean) = TRUE            - always successful
-----
%MD%

     MODULES INVOKED: 

-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
        
        WBC  05/05/88 : Design date.
        WBC  05/05/88 : Creation date.
        SCW  07/22/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine constructs a plane defined by a local bounded system,
a boreline from button structure information and returns the
intersecting point of the plane and the boreline.  The point
returned is the "apparent" projection of the point in the button
structure onto the plane defined by the local bounded system.
----*/
/*EH*/

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "msdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "ex.h"
#include "grimport.h"

IGRboolean GRlbsplapproj(msg,lbsys,button,proj_pnt,tparam)

IGRlong              *msg;         /* completion code                      */
struct   IGRlbsys    *lbsys;       /* local bounded system geometry        */
struct   EX_button   *button;      /* contains a point and gragad info     */
IGRpoint             proj_pnt;     /* the "apparent" project point         */
IGRdouble            *tparam;      /* t parameter of the project           */
                                   /* (intersection) point                 */
{
    extern IGRboolean  MAlnplisect();
    extern IGRboolean  MAptsxform();
    extern IGRboolean  MAdetplane();
    extern IGRboolean  MAbrlnconstr();

    struct var_list var_list[2];    /* used to inquire for view rot matrix */
    struct IGRline  boreline;
    struct IGRplane lbsys_plane;    /* plane defined by a local bounded sys*/
    IGRpoint        plane_point;    /* point on plane define by the lbsys  */
    IGRvector       normal_vect;    /* vector normal to the plane          */
    IGRmatrix       vw_rot_matrix;  /* locate point's view rotation matrix */
    IGRdouble       points[9];
    IGRdouble       tolerance;
    IGRlong         temp_msg, which_error, num;
    IGRint          status;

    *msg = MSSUCC;

    /*
     *  compute three non-linear points on the same plane as
     *  the text object
     */

    num = 3;

    points[0] = 1;
    points[1] = 0;
    points[2] = 0;
    points[3] = 0;
    points[4] = 1;
    points[5] = 0;
    points[6] = 1;
    points[7] = 1;
    points[8] = 0;

    MAptsxform(&temp_msg,&num,lbsys,points,points);

    /*
     *  construct a plane from the three points
     */

    tolerance = 0.0;
    lbsys_plane.point = plane_point;
    lbsys_plane.normal = normal_vect;

    MAdetplane(&temp_msg,points,&num,&tolerance,&lbsys_plane);

    /*
     *  construct a boreline from the input data point
     */

    var_list[0].var = VIEW_ROTATION;
    var_list[0].var_ptr = (IGRchar *)vw_rot_matrix;
    var_list[0].num_bytes = sizeof(IGRmatrix);
    var_list[0].bytes_returned = &num;
    var_list[1].var = END_PARAM;

    status = dp$inq_set_gragad(msg = &temp_msg,
                               osnum = button->osnum,
                               gragad_objid = button->objid,
                               which_error = &which_error,
                               var_list = var_list);

    if (1 & status & temp_msg)
    {
        boreline.point1 = points;
        boreline.point2 = &points[3];

        points[6] = button->x;
        points[7] = button->y;
        points[8] = button->z;

        MAbrlnconstr(&msg,&points[6],vw_rot_matrix,&boreline);

        /*
         *  intersect the plane with the boreline to get the "apparent" project
         *  point on the plane defined by the local bounded system
         */

        MAlnplisect(&temp_msg,&boreline,&lbsys_plane,
                    &tolerance,proj_pnt,tparam);
    }
    return(TRUE);
}
