class implementation NMinters;

#include "nddef.h"
#include "ndmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

extern struct ext_list NDdelete;

extern OMuword OPP_NMtrim_class_id, OPP_NMnonmani_class_id;

method NDget_objects(IGRint type;
                     struct GRid *list;
                     IGRint size; 
                     struct GRid **buffer;
		     IGRint ifrom;
                     IGRint ito;
                     IGRint *count)
{
 IGRlong 		sts = OM_S_SUCCESS, EMmsg = EMS_S_Success;
 struct GRid		*junk = NULL;
 IGRint			loc_count, i;
 IGRboolean		delete_me = TRUE;

 if(type & ND_CHILDREN)
  {
   struct GRid 		my_GRid;
   struct GRmd_env	my_env;
   IGRint 		bytes_in, bytes_out, rc;

   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;

   /* Get the children. If no children or all are in delete batch, my 
      existence is meaningless.
   */
   sts = om$send(mode = OM_e_wrt_message, 
         msg = message NDnodein.NDget_objects(ND_CHILDREN | ND_IN_BUF, NULL, 0,
	       &junk, 0, MAXINT, &loc_count), targetid = my_id);
   if(!(1&sts)) goto wrapup;

   for(i=0; i<loc_count; i++)
    {
     /* Only the NMnonmani and NMtrim children matter to me.
     */
     if(!EFisAncestryValid(&EMmsg, junk[i].objid, junk[i].osnum, 
        OPP_NMnonmani_class_id, FALSE) &&
	!EFisAncestryValid(&EMmsg, junk[i].objid, junk[i].osnum, 
	OPP_NMtrim_class_id, FALSE)) continue;
	
     if(NDin_buffer(junk[i], &NDdelete) == -1)
      {
       delete_me = FALSE; /* Atleast one child not in delete batch */
       break;
      }
    }

   if(delete_me && (NDin_buffer(my_GRid, &NDdelete) == -1))
    {
     bytes_in = sizeof(struct GRmd_env);
     gr$get_module_env(msg = &rc, sizbuf = &bytes_in, buffer = &my_env, 
                    nret = &bytes_out);
     EMerr_hndlr(!(1&rc), EMmsg, EMS_E_Fail, wrapup);
     nd$wait_batch(type = GR_DELETED, nb_obj = 1, 
                   l_object = &my_GRid, l_obj_info = &my_env);   
     /*goto wrapup;*/
    }
  }

sts = om$send(mode = OM_e_wrt_message, 
      msg = message NMassoctrans.NDget_objects(type, list, size, buffer, ifrom,
      ito, count), targetid = my_id);

wrapup:
EMWRAPUP(EMmsg, sts, "NMinters.NDget_objects");
return(sts);
}

end implementation NMinters;
