class implementation NMnonmanibnd;

#include "emsmacros.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asbox.h"		/* NULL_GRID */
#include "nddef.h"		/* ND_ADD */
#include "ndmacros.h"

extern OMuword OPP_GRcurve_class_id, OPP_GRconnector_class_id, 
               OPP_SKmgr_class_id;

method NDconnect(int num_parents; struct GRid *parents; struct GRid original;
		    IGRint type)
{
 IGRlong 		sts = OM_S_SUCCESS, EMmsg = EMS_S_Success;
 struct GRid		my_GRid;
 IGRlong		own_flag = 1, own_idx = 0, gr_idx = MAXINT;
 IGRint			i, bytes_in, bytes_out;
 struct GRmd_env 	env;
 struct GRid 		nmtpid;
 IGRboolean		found_nmtpid = FALSE;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 bytes_in = sizeof(struct GRmd_env);
 gr$get_module_env(msg = &EMmsg, sizbuf = &bytes_in, buffer = &env, 
                   nret = &bytes_out);
 if(!(1&EMmsg)) goto wrapup;

 /* Flexibly own suitable parents.
 */
 for(i=0; i<num_parents; i++)
  {
   /* Why don't we just ignore all parents other than surfaces?
      Need to look at this.

      Without the additional SKmgr check, profiles were also getting
      owned.

      Sunit. 19-Aug-92.
   */
   if(EFisAncestryValid(&EMmsg, parents[i].objid, 
		   parents[i].osnum, OPP_GRcurve_class_id, TRUE))
    continue;

   if(!EFisAncestryValid(&EMmsg, parents[i].objid, 
		   parents[i].osnum, OPP_GRconnector_class_id, TRUE))
    continue;

   if(EFisAncestryValid(&EMmsg, parents[i].objid, 
		   parents[i].osnum, OPP_SKmgr_class_id, TRUE))
    continue;

   if(!found_nmtpid)
    {
     sts = NMcreate_nmtp(&EMmsg, &parents[i], &env, &nmtpid, NULL, 
           NMcrtnmtp_QueryOnly, NULL);
     if(!(1&EMmsg&sts)) goto wrapup;
     if(EMmsg != EMS_I_Fail) found_nmtpid = TRUE;
    }

   sts = om$send(msg = message GRconnector.GRflexconn(&EMmsg, &own_flag, 
           &my_GRid, &own_idx, &gr_idx), targetid = parents[i].objid, 
           targetos = parents[i].osnum);
   if(!(1&EMmsg&sts)) goto wrapup;
   own_idx++;
  }

sts = om$send(mode = OM_e_wrt_message, 
              msg = message NDnodein.NDconnect(num_parents, parents,  original,
              type), targetid = my_id);

if(found_nmtpid)
 {
  IGRint		ndcode = GR_GEOM_POSTED;

  nd$wait_batch(type = ndcode, nb_obj = 1, 
                 l_object = &nmtpid, 
		 l_obj_info = &env);   /* want it to get update */

 }

wrapup:
EMWRAPUP(EMmsg, sts, "NMnonmanibnd.NDconnect");
return(sts);
}

end implementation NMnonmanibnd;
