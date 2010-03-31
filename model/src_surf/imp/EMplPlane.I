/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  EMSplane
     METHOD NAME:  EMplane

     Abstract: 
              This method generates a 3 point plane. The points
              are given either in rectangular or parallelogram 
              form.

-----
%SC%    

     EMplane(*rc, *arglist, points[], type)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *arglist  struct GRvg_construct   construct list
     points[]  IGRpoint                points defining the plane
     type      IGRint                  rectangular or parallelogram

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *rc          IGRint         completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
                                      due to allocation problems
     
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  
               BSplane3pt
               BSparallogr

     Methods:  
           GRconstruct
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:

-----
%CH%

HISTORY
        
24 May 1988 jBk Removed element_specific structure assignments.
25 Sep 1986 NG  Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

    This method calls the math routine BSplane3pt or BSparallogr
    depending upon type specified. The geometry is then posted to
    surface along with other stuff by using GRconstruct.   


----*/
/*EH*/

class implementation EMSplane;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

# if DEBUG
# include <stdio.h>
# endif

# ifndef FALSE
# define FALSE 0
# endif

# ifndef TRUE
# define TRUE 1
# endif

# define PLANE 0
# define PARA 1

#include "msmacros.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "bserr.h"

method EMplane (IGRint *rc; struct GRvg_construct *arglist;
                IGRpoint points[]; IGRint type)
{
  extern   void         BSparallogr();
  IGRdouble    poles[16][3];
  IGRdouble    weights[16];
  IGRdouble    u_knots[4], v_knots[4];
  IGRlong      om_msg = OM_S_SUCCESS;
  IGRint       msg;
  short        status;
  struct       IGRbsp_surface surface;
  extern   IGRboolean   BSplane3pt();


surface.poles = (double *) &poles[0][0];
surface.weights = (double *) &weights[0];
surface.u_knots = (double *) &u_knots[0];
surface.v_knots = (double *) &v_knots[0];

if (type == PLANE)
  {
   status = BSplane3pt(&msg, points[0], points[1],
                       points[2], &surface);

   if (!status)
     {
           *rc = MSFAIL;
       om_msg = om$send(mode = OM_e_wrt_object,
                        msg = message Root.delete(1),
                        senderid = my_id,
                        targetid = my_id);
       return(OM_E_ABORT);
     }
  }   
else

   (void) BSparallogr(points[0], points[1], points[2],
                      &surface, &msg);

if (BSERROR (msg))
 {
        *rc = MSFAIL;
 }

else
 {
    arglist->geometry = (IGRchar *) &surface;

    om_msg = om$send(mode = OM_e_wrt_object,
                     msg = message GRgraphics.GRconstruct
             (arglist),
                     senderid = my_id,
                     targetid = my_id);

    if (! (1 & om_msg))
      {
            om_msg = om$send(mode = OM_e_wrt_object,
                             msg = message Root.delete(1),
                             senderid = my_id,
                             targetid = my_id);
        return(OM_E_ABORT);
      }

  }
 
  
    return om_msg;

} /* end of method EMplane */

end implementation EMSplane;
