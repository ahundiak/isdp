/* ###################   APOGEE COMPILED   ################## */
/* 
   DESCRIPTION
  
   This method "posts" a composite curve into the database.
   It really just sets the planar and physically closed bits
   properly in the composite curves instance data.
  
   RETURN VALUES
   
   msg	  	 	completion code
  			- MSSUCC if successful
  			- MSFAIL (severe) if failure
  
   newobjid    		same as my_id
  
   NOTES
  
   If a failure occurs, the object's instance data will not be modified.
   
   Note that if the object id of the module object is passed in as the  
   NULL_OBJID then no R-tree modifications will take place.  If you are 
   doing this then be careful since there will be a mismatch.
   
   HISTORY
  
   05/08/87 : rlw : Creation date
   04/05/88 : dhm : Added GR_NOTIFY_LISTENERS
   09/26/88 : rlw : Modified to flag colinear curves as planar
   10/29/92 : SM  : Generate merged curve to determine closure. In case of
                    any problem, do the old thing. This change was made to
                    better handle composites generated from sf/sf intersection
                    where the trace tol is 2*cht. See GRccgenabs.I for related
                    changes.
   Sudha   06/21/93        modified for BSprototype ansification
 */

class implementation GRcompcurve;

#include "EMScc.h"
#include "bs.h"
#include "bsparameters.h"
#include "maerr.h"			/* Has MA error codes */
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "godef.h"
#include "gocmacros.h"
#include "bsparameters.h"
#include "bsdistptpts.h"

extern short _SM_KLUDGE_TO_PREVENT_MERGE_MANIA;

method GRpostabsg(
  IGRlong *msg; 			/* Error return code */
  struct GRmd_env *md_env;		/* My module enviroment info */
  struct GRpost_info *post_info; 	/* Post information */
  IGRchar *absptr;			/* Pointer to curve structure */
  GRobjid *newobjid)			/* Resultant id after posting */
{
 IGRboolean	status;
 IGRlong	sts, loc_msg;
 IGRdouble	dist_tolsq, distance_squared;
 IGRpoint	start_point, end_point, plane_point, plane_normal;
 struct 	IGRbsp_curve *curve;
 struct		IGRplane plane;
/*
 * Initialize
 */
 *msg = MSSUCC;
 *newobjid = my_id;			/* Once a comp, always a comp */
 status = BSEXTRACTPAR(&loc_msg, BSTOLSQLENVEC, dist_tolsq);
/*
 * Update stuff
 */
 if (!post_info->construct_flag) ME.GRgraphics->properties |= GRIS_MODIFIED;
/*
 * Update the control information in the instance data
 */
 ME.GRcompcurve->comp_props = 0;
/*
 * Am I planar?
 */
 plane.point = (IGRdouble *) &plane_point[0];
 plane.normal = (IGRdouble *) &plane_normal[0];
 sts = om$send(mode = OM_e_wrt_object,
               msg = message GRvg.GRdetplane(
                 msg,
                 &md_env->md_env.matrix_type,
                 md_env->md_env.matrix,
                 &plane),
               senderid = my_id,
               targetid = my_id);
  if (!(1 & sts)) return(sts);
 if ((*msg == MSSUCC) ||
     (*msg == MASDGENRAT))
  ME.GRgraphics->properties = ME.GRgraphics->properties | GRIS_PLANAR;
 else
  {
   *msg = MSSUCC;
   ME.GRgraphics->properties = ME.GRgraphics->properties & ~GRIS_PLANAR;
  }

/*
 * Am I physically closed?
 */
if(_SM_KLUDGE_TO_PREVENT_MERGE_MANIA)
  sts = OM_E_ABORT;
else
 sts = om$send(msg = message GRcurve.GRgenabsg(msg, 
       &md_env->md_env.matrix_type, md_env->md_env.matrix,
       (IGRchar **) &curve), targetid = my_id);

 if(1&*msg&sts)
  {
   if(curve->phy_closed)
    ME.GRcompcurve->comp_props |= GRIS_PHY_CLOSED;
   else
    ME.GRcompcurve->comp_props &= ~GRIS_PHY_CLOSED;
  }
 else
  {
   sts = om$send(mode = OM_e_wrt_object,
               msg = message GRcurve.GRendpts(
                 msg,
                 &md_env->md_env.matrix_type,
                 md_env->md_env.matrix,
                 start_point,
                 end_point),
               senderid = my_id,
               targetid = my_id);
   if (!(1 & sts)) return(sts);
   distance_squared = BSdistptpts(&loc_msg,
                                start_point,
                                end_point);
   if (distance_squared < dist_tolsq)
    ME.GRcompcurve->comp_props |= GRIS_PHY_CLOSED;
   else
    ME.GRcompcurve->comp_props &= ~GRIS_PHY_CLOSED;
  }

/*
 * End of routine
 */

 GR_NOTIFY_LISTENERS(msg, &sts, GR_GEOM_POSTED);

 return(OM_S_SUCCESS);
}

end implementation GRcompcurve;
