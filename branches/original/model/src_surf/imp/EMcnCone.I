/* ###################   APOGEE COMPILED   ################## */
class implementation EMScone;

# ifndef DEBUG
# define DEBUG 0
# endif

# include "EMS.h"

/*
ABSTRACT

Given the axis points and the top and base radii, this method
generates a cone.

ALGORITHM

This method calls the math routine BSrttrncon1 to get the
geometry of the conical surface. The geometry is then posted to
surface along with other stuff by using GRconstruct.   

INPUT ARGUMENTS

*arglist  struct GRvg_construct   construct list
points[]  IGRpoint                point[0] & point[1] define the
                                  axis of the cone
*radius   IGRdouble               radius of top and base of cone

OUTPUT ARGUMENTS

*rc          IGRint         completion code
                               - MSSUCC if successful
                               - EMS_I_FlatConeGeneralSf if the
                                 height of the cone is zero and
                                 the cone is placed as a general
                                 surface.
                               - MSFAIL (severe) if failure
                                 due to allocation problems

HISTORY
        
12 Jun 1989 jBk Implemented check for flatness and corresponding
                conditional change of class to general surface.

gupta   09/25/86 : creation date
*/

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

#include "msmacros.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "bserr.h"
#include "bsparameters.h"   /* BSTOLLENVEC */
#include "EMS_I.h"

from  EMSgenbs import  GRconstruct;
method EMcone (IGRint *rc; struct GRvg_construct *arglist;
               IGRpoint points[]; IGRdouble *radius)
{
  extern   void         BSrttrncon1();
  IGRdouble    poles[14][3];
  IGRdouble    weights[14];
  IGRdouble    u_knots[10], v_knots[4];
  struct       IGRbsp_surface surface;
  struct       IGResbs element_specific;
  IGRlong      om_msg = OM_S_SUCCESS;
  IGRint       msg;
  extern IGRdouble BSdistptpt ();
  IGRdouble scalarHeight, dist_tol;

*rc = MSSUCC;

surface.poles = (double *) &poles[0][0];
surface.weights = (double *) &weights[0];
surface.u_knots = (double *) &u_knots[0];
surface.v_knots = (double *) &v_knots[0];

element_specific.is_polydis = NULL;
element_specific.is_surfdis = NULL;
element_specific.is_slowdis = NULL;
element_specific.type = NULL;
element_specific.u_rules = NULL;
element_specific.v_rules = NULL;

(void) BSrttrncon1(points[0], points[1], radius[0], 
                   radius[1], &surface, &msg);


    if (BSOKAY (msg))
    {
        scalarHeight = (BSdistptpt (&msg, points[0], points[1]));
    }

    if (BSOKAY (msg))
    {
        BSEXTRACTPAR (&msg, BSTOLLENVEC, dist_tol);
    }

    if (BSERROR (msg))
    {
        *rc = MSFAIL;
    }
    else
    {
        surface.pos_orient = 0;
        arglist->geometry = (IGRchar *) &surface;

        if (scalarHeight > dist_tol)
        {
            om_msg = om$send(
                msg = message GRgraphics.GRconstruct (arglist),
                targetid = my_id
            );
        }
        else /* flat cone */
        {
#           if DEBUG
            (void)fprintf (stderr, "flat cone %d %d -> EMSgenbs\n",
                OM_Gw_current_OS, my_id);
#           endif

            om_msg = om$change_class (
                objid = my_id,
                classname = "EMSgenbs",
                sd_override = OM_K_change_class_sd_override
            );

            if (EMSokay (om_msg))
            {
                om_msg = om$send (
                    msg = message EMSgenbs.GRconstruct (arglist),
                    targetid = my_id
                );

                if (EMSokay (om_msg) AND EMSokay (*rc))
                {
                    *rc = EMS_I_FlatConeGeneralSf;
                }
            }

        } /* else flat cone */
    }    

    if (EMSerror (om_msg) OR EMSerror (*rc) OR EMSerror (*arglist->msg))
    {
        om_msg = om$send (
            mode = OM_e_wrt_object,
            msg = message Root.delete(1),
            senderid = my_id,
            targetid = my_id
        );

        if (EMSokay (om_msg)) om_msg = OM_E_ABORT;
        if (EMSokay (*rc)) *rc = MSFAIL;
        if (EMSokay (*arglist->msg)) *arglist->msg = MSFAIL;
    }
  
    return om_msg;

} /* end of method EMcone */

end implementation EMScone;
