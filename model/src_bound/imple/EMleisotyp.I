/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlinedge;

#include "EMS.h"
#include "emsmacros.h"                  /* for EMWRAPUP */
#include "bstypes.h"                    /* for BSrc */
#include "bserr.h"                      /* for BSSUCC */
%safe
#include <math.h>			/* fabs	*/
%endsafe
#include "OMmacros.h"

from EMSsubbs import EMget_natedge_info;

method EMsetIsoType(IGRlong *EMmsg;
		    GRobjid sfid;
		    IGRuchar *outtype, *intype_u, *intype_v;
		    IGRboolean update)
{
 IGRlong			sts;
 IGRdouble      		beg_par, end_par, tmp_par, *pts;
 IGRuchar 		edtype[4], cvtype, *cvtype_ptr = NULL;
 IGRushort 		edprops[4];
 IGRboolean			iso_u = FALSE, whole_iso = TRUE;
 struct GRmdenv_info 		env;
 extern void 			EMidmatrix();
 extern IGRlong 		EFget_clipped_edge_type();
 
 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 pts = ME.EMSlinedge->points;

 if(!(ME.EMSedge->ed_props & EMED_ISO))
  {
   *EMmsg = EMS_I_Useless;
   goto wrapup;
  }

  if(fabs(pts[0] - pts[2]) < fabs(pts[1] - pts[3]))
   {
    iso_u = TRUE;
    beg_par = pts[1];
    end_par = pts[3];
   }
  else
   {
    iso_u = FALSE;
    beg_par = pts[0];
    end_par = pts[2];
   }
  if (beg_par > end_par)
   {
    tmp_par = beg_par;
    beg_par = end_par;
    end_par = tmp_par;
   }

  if (beg_par != 0.0 || end_par != 1.0)  whole_iso = FALSE;
  else whole_iso = TRUE;

 if(intype_u && iso_u) cvtype_ptr = intype_u;
 else if(intype_v && !iso_u) cvtype_ptr = intype_v;

 if(!cvtype_ptr)
  {
   if(IF_NULL_OBJID(sfid))
    sts = om$send(msg = message EMSedge.EMgetsurface_info(EMmsg, &sfid, NULL), 
			targetid = my_id);
   if(IF_NULL_OBJID(sfid))
    {
     *EMmsg = EMS_I_Useless;
     goto wrapup;
    }

   /* We can use identity matrix for determining iso curve type since
     the surface orientation does not affect what the iso type is.
   */
   EMidmatrix (EMmsg, &env.matrix_type, env.matrix);	
	
   sts = om$send(msg = message EMSsubbs.EMget_natedge_info(EMmsg, 
			&env, edtype, edprops), targetid = sfid);
   if(!(1&*EMmsg&sts)) goto wrapup;

   cvtype_ptr = iso_u ? &edtype[0] : &edtype[1];
  }

  if(!cvtype_ptr)
   {
    *EMmsg = EMS_I_Useless;
    goto wrapup;
   }

  cvtype = *cvtype_ptr;
  if(!whole_iso)
   {
    sts = EFget_clipped_edge_type(EMmsg, cvtype, &cvtype);
    if(!(1&sts&*EMmsg)) goto wrapup;
   }
  
  if(update) ME.EMSedge->curve_type = cvtype;
  if(outtype) *outtype = cvtype;

wrapup:
EMWRAPUP(*EMmsg, sts, "In EMSlinedge.EMsetIsoType")
return(sts);
}


end implementation EMSlinedge;
