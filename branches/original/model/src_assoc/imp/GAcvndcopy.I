class implementation GAcurve;

#include "exmacros.h"
#include "nddef.h"
#include "EMSkey.h"
#include "REcurve.h"
#include "maerr.h"


method NDcopy_graph(IGRlong *EMmsg;IGRint cp_type;
  		    struct GRmd_env *fr_env,*to_env;
		    struct NDcp_list *list;
                    int list_count;
		    int position)
{
 int is_msc;
 IGRlong status;
 IGRuint mytype, info_size;
 struct NDcp_list *myinx;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 myinx = &list[position];
 myinx->original = my_id;

 om$send (msg = message GAcurve.GAis_msc(EMmsg, &is_msc),
          targetid = my_id);



 if (myinx->position & ND_BODY)
 {
/*
 * When the copy reaches the MSC it is assumed that it has the key.
 */
  if (is_msc)
  {
   status = om$send (msg = message EMSassoc.EMget_info(EMmsg,
                         NULL, &mytype, &info_size, NULL),
                   targetid = my_id);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

/*
 * If my key is not stored then request for a storage of key. Added this
 * to cause the generation of keys in model space counterparts when they are
 * connected to construction macros.
 */

  if (!((mytype == EMSmsc_key) ||
       (mytype == EMSmsc_id_key) ||
	(mytype == EMSmsc_long_key)))
  {
    IGRlong msg_loc;
    om$send (msg = message EMSpointerA.EMstore_key_from_id(&msg_loc,
                         EMS_OPT_STORE_ID, NULL),
             targetid = my_id);
  }
 }

/* end pp 06/01/92 */

  myinx->clone = NULL_OBJID;

  status = om$send (msg = message EMSassoc.NDcopy_graph(EMmsg, cp_type,
                                                 fr_env, to_env, list,
                         list_count, position),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

  if (is_msc && (mytype == EMSmsc_id_key))
  {
   struct EMSobjid_key *info;
   info = (struct EMSobjid_key *) alloca (info_size);
   EMerr_hndlr(!info, *EMmsg, MANOMEMORY, wrapup);

   status = om$send (msg = message EMSassoc.EMget_info(EMmsg,
                         NULL, &mytype, &info_size, (char **) &info),
                   targetid = my_id);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   info_size = info_size - sizeof (struct EMSobjid_key);

   status = om$send (msg = message EMSassoc.EMput_info(EMmsg, NULL,
                         EMSmsc_key,info_size,
                         (char *) info->key_info),
                   targetid = myinx->clone,
                   targetos = to_env->md_id.osnum);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
  else if(is_msc && (mytype == EMSmsc_long_key))
  {
   struct EMSlong_key *info;
   IGRlong key_size;
   
   info = (struct EMSlong_key *) alloca (info_size);
   EMerr_hndlr(!info, *EMmsg, MANOMEMORY, wrapup);

   status = om$send (msg = message EMSassoc.EMget_info(EMmsg,
                         NULL, &mytype, &info_size, (char **) &info),
                   targetid = my_id);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   EMcheckfor_offset_corruption(info,info_size);
   if(info->noncount_st.offset >0)
     key_size = info->noncount_st.offset - sizeof(struct EMSlong_key);
  else 
    key_size = info_size - sizeof(struct EMSlong_key);  

   status = om$send (msg = message EMSassoc.EMput_info(EMmsg, NULL,
                         EMSmsc_key,key_size,
                         (char *) info->key_info),
                   targetid = myinx->clone,
                   targetos = to_env->md_id.osnum);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
 }
 else
 {
  if (myinx->clone == NULL_OBJID)
  {
   IGRshort split_flag;
   split_flag = FALSE;
   
   if(ASMget_splitpart() == TRUE)
    {
       if(to_env->md_id.objid == NULL_OBJID)
        {
           ex$get_modid(mod_osnum = to_env->md_id.osnum,
                        mod_id = &(to_env->md_id.objid));
           split_flag = TRUE;
        }
       status = om$send (msg = message GRgraphics.GRcopy(EMmsg,fr_env,to_env,
                                                         &myinx->clone),
                         targetid = my_id);
       if(split_flag)
         to_env->md_id.objid = NULL_OBJID;
       
    }
  else
   status = om$send (msg = message GRgraphics.GRcopy(EMmsg,fr_env,to_env,
                          &myinx->clone),
                    targetid = my_id);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
  }
 }

wrapup:
 EMWRAPUP(*EMmsg, status, "In GAcurve: NDcopy error");
 return (status);
}

method NDselect_copy(long *msg;
                     int select_type;
		     struct GRid *selected_obj;
                     int *info;
		     int selected_size, 
                     *selected_nb)
/* ********************************************************************
Description
This method adds any dimensional handles(if any) to the list that is
getting copied. We need to do this to preserve integrity of the system
and since theoretically the surface/solid is "owning" those entities.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is failure

History
 pp : 08/13/92 : Creation
*********************************************************************** */
{
 IGRlong status;
 int is_msc=0;
 struct GRid my_grid;

 *msg = MSSUCC;
 status = OM_S_SUCCESS;
 *selected_nb = 0;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

/*
 * Add myself.
 */
 *selected_nb = 0;

  if (selected_size > (*selected_nb))
  {
   selected_obj[*selected_nb].objid = my_id;
   selected_obj[*selected_nb].osnum = OM_Gw_current_OS;
  }
  ++(*selected_nb);

 om$send (msg = message GAcurve.GAis_msc(msg, &is_msc),
          targetid = my_id);

 if (!is_msc)
 {
  EFadd_to_copy_list(msg, my_grid, info, selected_size, selected_nb,
                    select_type, selected_obj);
  EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, wrapup);
 }

wrapup:
 EMWRAPUP (*msg, status, "In GAcurve: NDselect_copy method error");
 return (status);
}

end implementation GAcurve;
