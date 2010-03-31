/*
History
	SM	Many moons ago		Creation
	SM	06-Sepr-91		Instead of deleting childless pointers
					with Root.delete, put them in delete
					batch.
	SM	27-Feb-92		When childless pointers are put
					in the batch, disconnect them
					from myself.
*/
class implementation NMassoctrans;

#include "nddef.h"
#include "ndmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

extern OMuword OPP_EMSpointer_class_id;
extern struct ext_list NDdelete;

method NDget_objects(IGRint type;
                     struct GRid *list;
                     IGRint size; 
                     struct GRid **buffer;
		     IGRint ifrom;
                     IGRint ito;
                     IGRint *count)
{
 IGRlong 		sts = OM_S_SUCCESS, EMmsg = EMS_S_Success;
 IGRboolean		got_env = FALSE;
 struct GRmd_env 	my_env;
 IGRint 		bytes_in, bytes_out, rc;
 struct GRid 		my_GRid;

 if(count) *count = 0;

 if(type & ND_CHILDREN)
 {
  struct GRid		*junk = NULL;
  IGRint		loc_count, i, ptrcount;
  OM_S_CHANSELECT	to_children;

  EMmake_chanselect(NDchildren_children, &to_children);

  bytes_in = sizeof(struct GRmd_env);
  gr$get_module_env(msg = &rc, sizbuf = &bytes_in, buffer = &my_env, 
                    nret = &bytes_out);
  EMerr_hndlr(!(1&rc), EMmsg, EMS_E_Fail, wrapup);

  got_env = TRUE;

  sts = om$send(mode = OM_e_wrt_message, 
         msg = message NDnodein.NDget_objects(ND_CHILDREN | ND_IN_BUF, NULL, 
	       NULL, &junk, 0, MAXINT, &loc_count), targetid = my_id);
  if(!(1&sts)) goto wrapup;
   for(i=0; i<loc_count; i++)    
    {
     if(!EFisAncestryValid(&EMmsg, junk[i].objid, junk[i].osnum, 
	 OPP_EMSpointer_class_id, FALSE)) continue;
     sts = om$get_channel_count(objid = junk[i].objid, osnum = junk[i].osnum, 
	   p_chanselect = &to_children, count = (OMuint *) &ptrcount);
     if(!(1&sts)) goto wrapup;
     if(!ptrcount && (NDin_buffer(junk[i], &NDdelete) == -1))
      {
       sts = om$send(msg = message NDnode.NDdisconnect(0, NULL), 
             targetid = junk[i].objid, targetos = junk[i].osnum);
       if(!(1&sts)) goto wrapup;

       nd$wait_batch(type = GR_DELETED, nb_obj = 1, 
                     l_object = &junk[i], 
		     l_obj_info = &my_env);
      }
    }
 }


 /* Doing transmigration only if type was ND_ROOT was causing the problem of 
    the owner (child) transmigrating before the component (father) in an 
    ownership tree. Therefore, always trying transmigration untill I figure 
    out a better way.
    June 24, 1991.
*/
 sts = om$send(msg = message NMassoctrans.NMtransmigrate
       (&EMmsg, NULL, NULL, NULL), targetid = my_id);
 if(!(1&EMmsg) && (1&sts)) sts = OM_E_ABORT;
 if(!(1&sts&EMmsg)) goto wrapup;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 if( (EMmsg == EMS_I_Useless) && (NDin_buffer(my_GRid, &NDdelete) == -1))
  {
   if(!got_env)
    {
     bytes_in = sizeof(struct GRmd_env);
     gr$get_module_env(msg = &rc, sizbuf = &bytes_in, buffer = &my_env, 
                       nret = &bytes_out);
     EMerr_hndlr(!(1&rc), EMmsg, EMS_E_Fail, wrapup);
     got_env = TRUE;
    }
   nd$wait_batch(type = GR_DELETED, nb_obj = 1, 
                 l_object = &my_GRid, l_obj_info = &my_env);
  }
 /*else*/
  sts = om$send(mode = OM_e_wrt_message, 
        msg = message NDnodein.NDget_objects(type, list, size, buffer, ifrom, 
	     ito, count), targetid = my_id);
wrapup:
EMWRAPUP(EMmsg, sts, "NMassoctrans.NDget_objects");
return(sts);
}
end implementation NMassoctrans;
