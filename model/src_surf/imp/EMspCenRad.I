/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:       EMSsphere
     METHOD NAMES:      EMsphere_by_center_radius

     Abstract:  This file contains the construct method for placing a sphere
                by giving it's center and radius.

-----
%SC%    

    VALUE = EMsphere_by_center_radius(arglist, center, radius)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *arglist     GRvg_construct construct arguments
     center       IGRpoint       the center of the sphere
     radius       IGRdouble      the radius of the sphere

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------


-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
              OM_send_object

     Methods:
              GRconstruct
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
           The return code in the input argument list can have the 
           following values:

          
                MSSUCC - successful
                MSFAIL - if failure
                GRSNOINVTRAN - if input matrix is not invertible
                GRSDGNEXCEED - if range exceeds design limits

           Note that if an error occurs then the object is deleted.
-----
%CH%

     CHANGE HISTORY:

        RLW     09/21/86 : The beginning
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine fills in the instance data for a sphere that has a
 given center and radius.

----*/
/*EH*/

#include "msdef.h"

class implementation EMSsphere;

#include "EMS.h"
method EMsphere_by_center_radius(struct GRvg_construct *arglist;
        IGRpoint center; IGRdouble radius)
{
 short          status;
 extern IGRboolean     BSprepsphr();
 int            sts;
 double         the_radius;
 double         poles[35][3], weights[35], u_knots[8], v_knots[10];
 struct         IGRbsp_surface surface;
/*
 * Initialize
 */
 *(arglist->msg) = MSSUCC;
 the_radius = radius;
/*
 * Get the surface definition
 */
 surface.poles   = (double *) &poles[0][0];
 surface.weights = (double *) &weights[0];
 surface.u_knots = (double *) &u_knots[0];
 surface.v_knots = (double *) &v_knots[0];
 status = BSprepsphr(arglist->msg, center, &the_radius, &surface);
  if (!status)
   {
    *(arglist->msg) = MSFAIL;
    sts = om$send(mode = OM_e_wrt_object,
                  msg = message Root.delete(1),
                  senderid = my_id,
                  targetid = my_id);
    return(OM_E_ABORT);
   }
 surface.pos_orient = 0;
 arglist->geometry = (IGRchar *) &surface;
/*
 * Fill the instance data and such
 */
 sts = om$send(mode = OM_e_wrt_object,
               msg = message GRgraphics.GRconstruct(arglist),
               senderid = my_id,
               targetid = my_id);
  if (!(1 & sts))
   {
    sts = om$send(mode = OM_e_wrt_object,
                  msg = message Root.delete(1),
                  senderid = my_id,
                  targetid = my_id);
    return(OM_E_ABORT);
   }
/*
 * End of routine
 */
 return(OM_S_SUCCESS);
}

end implementation EMSsphere;
