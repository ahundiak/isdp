class implementation EMSpointer;

#include "nddef.h"
#include "maerr.h"
#include "EMSlcdef.h"

from EMSboundary import EMgetxyzobj;

method NDcopy_graph(IGRlong *EMmsg;IGRint cp_type;
  		    struct GRmd_env *fr_env,*to_env;
		    struct NDcp_list *list;
                    int list_count;
		    int position)
{
 IGRlong status;
 IGRuint info_size;
 IGRuint mytype;
 struct NDcp_list *myinx;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 myinx = &list[position];
 myinx->original = my_id;


 if (myinx->position & ND_BODY)
 {
/*
 * When the copy reaches the pointer it is assumed that it has the key.
 * This is usually set by the parent when he gets the copy message. 
 */
  myinx->clone = NULL_OBJID;

  status = om$send (msg = message EMSpointer.EMget_pointer_info(EMmsg, NULL, 
                         &mytype,
                         &info_size,NULL),
                   targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);

/*
 * If my key is not stored then request for a storage of key. Added this
 * to cause the generation of keys in pointers when they are
 * connected to construction macros.
 */

  if (!((mytype == EMS_ASobject_key) || (mytype == EMS_ASkey_and_id)))
  {
    IGRint msg_loc;
    om$send (msg = message EMSpointerA.EMstore_key_from_id((IGRlong *)&msg_loc,
                         EMS_OPT_STORE_ID, NULL),
             targetid = my_id);
  }

/* end pp 06/01/92 */

  status = om$send (msg = message NDnodein.NDcopy_graph(EMmsg, cp_type,
                         fr_env, to_env, list,list_count,position),
                   mode = OM_e_wrt_message,
                   targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

/*
 * Make sure that the copied entity does not have an id stored inside.
 */

  if (mytype == EMS_ASkey_and_id)
  {
   int temp_type;
   struct EMSobjid_key *info;

   info = (struct EMSobjid_key *) alloca(info_size);
   EMerr_hndlr(!info, *EMmsg, MANOMEMORY, wrapup);

   status = om$send (msg = message EMSpointer.EMget_pointer_info(EMmsg,
                           NULL,&mytype, &info_size, (char **)&info),
                     targetid = my_id);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

   temp_type = EMS_ASobject_key;
   info_size = info_size - sizeof (struct EMSobjid_key);
   status = om$send (msg = message EMSpointer.EMput_pointer_info(EMmsg, NULL,
                          temp_type,info_size,
                          (char *)info->key_info),
                   targetid = myinx->clone,
                   targetos = to_env->md_id.osnum);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
 }
 else if (myinx->position & ND_ROOT)
 {
/*
 * If I am root element, then do not do anything.
 */
  *EMmsg = MSSUCC;
  return (OM_S_SUCCESS);
 }
 else if (myinx->position & ND_EXTERN)
 {
  *EMmsg = EMS_I_InvalidCase;
  goto wrapup;
 }

wrapup:
 EMWRAPUP(*EMmsg, status, "In EMSpointer: NDcopy_graph error");
 return (status);
}

method ACcopy_to_Groot(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *fr_env,*to_env;
  			 struct GRid *newobjid)
{
 IGRlong status,msg_loc;
 struct GRid component_GRid;
 extern OMuword OPP_GRgraphics_class_id, OPP_EMSboundary_class_id;

 *msg = MSSUCC;
 status = OM_S_SUCCESS;

 newobjid->objid = NULL_OBJID;
 newobjid->osnum = to_env->md_id.osnum;

 if (cp_type & ND_TO_DEF_TEMP)
 {
  status = om$send (msg = message NDnode.ASreturn_go(&component_GRid,
                        NULL, NULL),
                  targetid = my_id);
  if (!(1&status)) goto wrapup;

  if (EFisAncestryValid(&msg_loc, component_GRid.objid, component_GRid.osnum,
                          OPP_GRgraphics_class_id, FALSE))
  {
   IGRshort props, clear_bits;
   status = om$send (msg = message GRgraphics.GRcopy(msg, fr_env,
                         to_env, &newobjid->objid),
                   targetid = component_GRid.objid,
                   targetos = component_GRid.osnum);
   EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);
/*
 * Clear the rigid relationship bit if the same is set.
 */
    clear_bits = 0;
    props = GR_RIGID_RELATIONSHIP;
    status = om$send(msg = message GRgraphics.GRchgprops(msg,
                             &clear_bits, &props),
       	  targetid = newobjid->objid,
          targetos = newobjid->osnum);
    EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, wrapup);
  }
  else if (EFisAncestryValid(&msg_loc,component_GRid.objid, 
                component_GRid.osnum,OPP_EMSboundary_class_id, FALSE))
  {
   status = om$send (msg = message EMSboundary.EMgetxyzobj(msg,EMSlcopt_noassoc,
                           &to_env->md_env,NULL,NULL,NULL,NULL,
                           to_env->md_id.osnum, &newobjid->objid),
                     targetid = component_GRid.objid,
                     targetos = component_GRid.osnum);
   EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);
  }
 }

wrapup:
 EMWRAPUP (*msg, status, "In EMSpointer:ACcopy_to_Groot error");
 return (status);
}

end implementation EMSpointer;

