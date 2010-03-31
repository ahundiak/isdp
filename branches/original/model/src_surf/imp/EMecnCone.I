/* ###################   APOGEE COMPILED   ################## */
class implementation EMSelpcone;

# ifndef DEBUG
# define DEBUG 0
# endif

#include "EMS.h"

# if DEBUG
# include <stdio.h>
# endif

#include "msdef.h"
#include "bserr.h"     /* for bs error definitons */
#include "bsconic.h"   /* for BSCIRCLE_ORDER etc declarations */
#include "bsparameters.h"   /* BSTOLLENVEC */
#include "EMSmsgdef.h" 
                       /* for EMS message code definitions */
#include "EMS_I.h"     /* EMS message subsystem codes */

from EMSgenbs import GRconstruct;

method EMconstruct_elliptical_cone (
    IGRlong *EMmsg;
    struct GRvg_construct *construct_list;
    IGRpoint base_center;
    IGRvector major_axis;
    IGRvector minor_axis;
    IGRvector height;
    IGRdouble scale
)

/* ***********************************************************************

Description
      This method constructs an elliptical cone when given the base_center
      major axis vector, minor axis vector and the height vector. When the
      scale factor is 1, it constructs an elliptical cylindrical surface
      or else it constructs an elliptical cone.

Arguments
      Input
        construct_list - pointer to construction information
        base_center    - base center of the elliptical cone.
        major_axis     - major axis vector of the base ellipse
        minor_axis     - minor axis vector of the base ellipse
        height         - height vector of the elliptical cone.
        scale          - scale factor.

      Output
        EMmsg          - completion status
                         EMS_S_Success : if successful
                         EMS_I_FlatConeGeneralSf: if the height
                                            of the cone is zero
                                            and the cone is
                                            placed as a general
                                            surface.
                         EMS_E_Fail    : if there is failure while calling
                                         GRconstruct method
                         EMS_E_BSerror : if there is an error from math
                                         while constructing the elliptical
                                         cone

Notes 
     If there is any error during the construction process, the object
     deletes itself.

History

12 Jun 1989 jBk Implemented check for flatness and corresponding
                conditional change of class to general surface.

PP        : 12/01/87              Creation

*********************************************************************** */
{
 IGRlong status,
         cln_sts;
 BSrc rc;
 struct IGRbsp_surface surface;
 IGRpoint poles [BSCIRCLE_NUM_POLES_MAX * 2];
 IGRdouble u_knots [BSCIRCLE_NUM_POLES_MAX + BSCIRCLE_ORDER];
 IGRdouble v_knots [4];
 IGRdouble weights [BSCIRCLE_NUM_POLES_MAX * 2];
 extern void BSellcylcon ();
 extern IGRdouble BSlenvec ();
 IGRdouble scalarHeight, dist_tol;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 surface.poles = (IGRdouble *) poles;
 surface.u_knots = (IGRdouble *) u_knots;
 surface.v_knots = (IGRdouble *) v_knots;
 surface.weights = (IGRdouble *) weights;
 
 (void) BSellcylcon ( base_center, major_axis, minor_axis, height,
                      scale,&surface,
                      &rc);
 EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

 construct_list->geometry = (IGRchar *) &surface;

 scalarHeight = (BSlenvec (&rc, height));

 EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

 BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);

 EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

 if (scalarHeight > dist_tol)
 {
    status = om$send (
        msg = message GRvg.GRconstruct (construct_list),
        targetid = my_id
    );

    EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 else
 {
#   if DEBUG
    (void)fprintf (stderr, "flat econe %d %d -> EMSgenbs\n",
        OM_Gw_current_OS, my_id);
#   endif

    status = om$change_class (
        objid = my_id,
        classname = "EMSgenbs",
        sd_override = OM_K_change_class_sd_override
    );

    EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    status = om$send (
        msg = message EMSgenbs.GRconstruct (construct_list),
        targetid = my_id
    );

    EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    *EMmsg = EMS_I_FlatConeGeneralSf;
 }

wrapup:
 if (EMSerror (status) OR
    EMSerror (*EMmsg) OR
    EMSerror (*construct_list->msg)
 )
 {
   cln_sts = om$send (msg = message Root.delete (1),
                      targetid = my_id);

    if (EMSokay (status)) status = OM_E_ABORT;
    if (EMSokay (*construct_list->msg)) *construct_list->msg = MSFAIL;
    if (EMSokay (*EMmsg)) *EMmsg = EMS_E_Fail;
 }

 return (status);
}

end implementation EMSelpcone;
