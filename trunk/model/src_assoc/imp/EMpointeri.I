/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpointer;

#include "emserr.h"
#include "madef.h" /* For MAIDMX */
#include "EMSmsgdef.h"
#include "EMSmsgnumdef.h"
#include "asbox.h" /* For NULL_GRID */
#include "nddef.h" /* For ND_NC_NEW */
#include "asmacros.h" /* For as$make_source */
#include "grdpbdef.h"
#include "grdpbmacros.h" /* gr$get_mod... */
#include "gocmacros.h"
#include "maidmx.h"

from ACpretendin import ACiconnect;
from EMScreator import EMgive_noncount_based_key;
method EMinit(IGRlong *EMmsg;
              unsigned int options;
              struct GRid *parent_GRid;
              struct GRid *context_GRid;
              OM_S_OBJID component_objid)
/* **********************************************************
Description
 This message will initialise a pointer object. It will cause
 the objid to be stored in the instance data.

Arguments
 Input
   options : Currently not supported
   parent_GRid : The parent of the pointer object.
   context_GRid : context with which this object is viewed
   component_objid : Objid of the component who is causing this
                  indirection. 

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well.
 EMS_E_Fail: Failure.

History:
 Creation : PP : 04/24/91
*********************************************************** */
{
 IGRlong status,long_rc;
 IGRuint key_size;
 unsigned char *key;
 IGRuint mytype;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 long_rc = OM_S_SUCCESS; /* fix for umr */

 status = om$send (msg = message NDnode.NDconnect (1,parent_GRid,
                   NULL_GRID,
                   ND_ADD), 
                   targetid = my_id);
 EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 status = om$send( msg = message EMScreator.EMgive_noncount_based_key(
						&long_rc,
						options,
					        &component_objid,
						&mytype,
						&key_size,
						NULL),
	   targetid = parent_GRid->objid,
	   targetos = parent_GRid->osnum);
 if(status & long_rc & 1)
   {

     key = stackalloc(key_size);
     if(!key) goto wrapup;

     status = om$send( msg = message EMScreator.EMgive_noncount_based_key(
						&long_rc,
						options,
					        &component_objid,
						&mytype,
						&key_size,
						&key),
	   targetid = parent_GRid->objid,
	   targetos = parent_GRid->osnum);
     EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);

     status = om$send (msg = message EMSpointer.EMput_pointer_info(EMmsg,
			      NULL, mytype,
		    	      key_size,
                              (char *)key),
		       targetid = my_id);
     EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
     
   }
 else
   {
     mytype = EMS_ASobject_id;

     
     status = om$send (msg = message EMSpointer.EMput_pointer_info(EMmsg,
                          NULL, mytype,
                          sizeof(OM_S_OBJID),
                          (char *)&component_objid),
                    targetid = my_id);
     EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
   }

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSpointer:EMinit error");
 return (status);
}

method NDupdate(IGRint *EMmsg;
                IGRint cnt_type;
                IGRint count;
	        struct GRid *list;
	        IGRint *parent_state;
	        struct GRid *context,*new_objid;
	        struct GRmd_env *md_env)

/* *************************************************************************

Description
 This method determines whether the component tag still exists and that
 the same is not in the mismatched list.

History
 Creation Date       : PP : 04/24/91
   ************************************************************************* */
{
 IGRlong status;
 IGRuint options;
 unsigned int mytype;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 new_objid->objid = my_id;
 new_objid->osnum = OM_Gw_current_OS;

 status = om$send (msg = message EMSpointer.EMget_pointer_info((long *)EMmsg, 
                         NULL, &mytype,
                         NULL,NULL),
                   targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

/*
 * calling notify listeners so that my_id's tag is incremented.
 * pp 08/19/91
 */

  GR_NOTIFY_LISTENERS(EMmsg, &status, GR_GEOM_MODIFIED);

 if (mytype == EMS_ASobject_key)
 {
  options = EMS_OPT_STORE_ID;

  status = om$send (msg = message EMSpointer.EMstore_id_from_key((long *)EMmsg,
                          options,
                          NULL),
                    targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 if(((mytype == EMS_ASlong_key) || (mytype == EMS_ASkey_and_id)) && 
     (ASMget_splitpart() == TRUE))
  {
    options = EMS_OPT_STORE_ID | EMS_OPT_STORE_KEY;
  status = om$send (msg = message EMSpointer.EMstore_id_from_key((long *)EMmsg,
                          options,
                          NULL),
                    targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
  

wrapup:
 if (!(1&status&*EMmsg))
  *EMmsg = ND_COMP_FAIL;
 else
  *EMmsg = ND_COMP_SUCC;

 return (status);
}

method ASreturn_go ( struct GRid *go;
                     IGRshort    *mat_type;
                     IGRdouble   *matrix )
/* *******************************************************
Description
 This method returns the graphic object that this pointer object
 is pointing to. If for some reason either due to topology matching failure
 the object does not exist then go->objid is returned as NULL_OBJID.

History
 Creation : PP : 04/24/91
 ******************************************************** */
{
 IGRlong         EMmsg, status;
 IGRuint type, info_size;
 char *info = NULL;

 EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 status = om$send (msg = message EMSpointer.EMget_pointer_info(&EMmsg,
                         NULL, &type, &info_size, NULL),
                   targetid = my_id);
 EMerr_hndlr (!(1&status&EMmsg), EMmsg, EMS_E_Fail, wrapup);

 if (info_size)
 {
  info = (char *) stackalloc(info_size);
  EMerr_hndlr(!info, EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  status = om$send (msg = message EMSpointer.EMget_pointer_info(&EMmsg,
                         NULL, &type, &info_size, &info),
                   targetid = my_id);
  EMerr_hndlr (!(1&status&EMmsg), EMmsg, EMS_E_Fail, wrapup);
 }

 go->objid = NULL_OBJID;
 go->osnum = OM_Gw_current_OS;

  if (type == EMS_ASkey_and_id)
  {
    struct EMSobjid_key *objid_key;

    objid_key = (struct EMSobjid_key *) info;
    go->objid = objid_key->objid;
  }
  else if (type == EMS_ASobject_id)
  {
   OM_S_OBJID *obj;
   obj = (OM_S_OBJID *) info;
   go->objid = *obj;
  }
  else if (type == EMS_ASnoncount_key)
  {
    struct EMSnoncountkey *noncount_st;
   noncount_st = (struct EMSnoncountkey *) info;
   go->objid = noncount_st->objid;
  }
  else if (type == EMS_ASlong_key)
  {
    struct EMSlong_key *long_key_st;
   long_key_st = (struct EMSlong_key *) info;
   go->objid = long_key_st->objid;
  }
  else
  {
   EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }

 if (matrix && mat_type)
 {

/*
 * Should always be an identity matrix.
 */
   struct GRmd_env mod_env;
   IGRint          sizbuf, nret;
   sizbuf = sizeof(struct GRmd_env);

   gr$get_module_env ( msg = &EMmsg,
                       sizbuf = &sizbuf,
                       buffer = &mod_env,
                       nret = &nret );
   if (!(1&EMmsg)) goto wrapup;

   *mat_type = mod_env.md_env.matrix_type;    

   memcpy (matrix, mod_env.md_env.matrix, sizeof(IGRmatrix));
 }

wrapup:
 if (info) stackfree (info);
 if (!(1&EMmsg)) status = OM_E_ABORT;
 return (status);
}

method NDdisplay(IGRint dp_type;enum GRdpmode pen;struct GRmd_env *env)

/* ****************************************************************

Description
 This method will display the component object which it is pointing.

Bugs
 May exist with the interfaction with reference files.

History
 Creation : PP : 04/24/91
****************************************************************** */

{
 IGRlong status;
 IGRlong EMmsg;
 IGRshort mat_type;
 IGRmatrix mat_ident;
 IGRdouble *mat;
 struct GRid component_GRid;
 struct GRid mod_grid;

 status = OM_S_SUCCESS;
 EMmsg = EMS_S_Success;
 component_GRid.objid = NULL_OBJID;

   status = om$send (msg = message NDnode.ASreturn_go(&component_GRid,
                         NULL, NULL),
                   targetid = my_id);
   if (!(1&status)) goto wrapup;

   if(env == NULL)
    {
     mat_type = MAIDMX;
     MAidmx(&EMmsg,mat_ident);
     mat = mat_ident;
    }
   else
    { 
     mat_type = env->md_env.matrix_type;
     mat = env->md_env.matrix;
    }
    GRfindmod(&mod_grid);
    if (component_GRid.objid != NULL_OBJID)
    {
     if (EFisAncestryValid(&EMmsg, component_GRid.objid, component_GRid.osnum,
                          OPP_GRgraphics_class_id, FALSE))
     {
      status = om$send(msg = message GRgraphics.GRdisplay(&EMmsg,
	         		    &mat_type,mat,&pen,&mod_grid),
                      targetid = component_GRid.objid,
                      targetos = component_GRid.osnum);
      EMerr_hndlr (!(1&status&EMmsg), EMmsg, EMS_E_Fail, wrapup);
     }
    }
  
wrapup:
 return (OM_S_SUCCESS);
}

method NDgive_structure (IGRlong *EMmsg; struct ret_struct *str;
                         struct GRmd_env *md_env)
/* ********************************************************
Description
 This override returns the type in str->type as other_generic.

History
 Creation : PP :03/08/91
*********************************************************** */
{
 IGRlong status;
 struct GRid go;
 IGRint msg_loc;
 extern OMuword OPP_GRbspline_class_id;


 status = OM_S_SUCCESS;
 *EMmsg = MSSUCC;
 str->type = other_generic;

 status = om$send (msg = message NDnode.ASreturn_go( &go, NULL, NULL),
                   targetid = my_id);
 if (!(1&status)) goto wrapup;

 if (go.objid == NULL_OBJID)
  return (OM_S_SUCCESS);

 if (EFisAncestryValid(&msg_loc, go.objid, go.osnum, 
                          OPP_GRbspline_class_id, FALSE))
 {
   status = ASgo_give_structure( go.objid, go.osnum,
                                 md_env ,str );
 }

wrapup:
 return (OM_S_SUCCESS);
}

method NDmove_to_root (IGRlong *msg; struct GRid *src_grid;
			  struct GRmd_env *md_env )
/*
 * This method is overriden to just pass this message to the children
 * if they do exist.
 * 12/04/91: WBC : Changed to pass the message NDparent_deleted to my
 * children.
 */

{
 IGRlong status;
 OM_S_CHANSELECT children;
 struct GRid my_grid;
 *msg = EMS_S_Success;

 status = OM_S_SUCCESS;

 status = om$make_chanselect (channame = "NDchildren.children",
                              p_chanselect = &children);
 EMerr_hndlr (!(1&status), *msg, EMS_E_OMerror, wrapup);

 /* must send with myself as the deleted parent */

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 status = om$send (msg = message NDnode.NDparent_deleted(msg, 1, &my_grid,
                                                         src_grid, md_env),
                   p_chanselect = &children);
 EMerr_hndlr (!(1&status), *msg, EMS_E_OMerror, wrapup);
 
 status = om$send (msg = message Root.delete(1),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, wrapup);

wrapup:
 EMWRAPUP (*msg, status, "In EMSpointer:NDmove_to_root error");
 return (status);
}

method NDmake_source(IGRlong *msg; struct GRid *located_obj,*context;
                     char *path; GRspacenum as_osnum; struct GRid *as)
{
 IGRboolean found = FALSE;
 IGRlong status;
 int i, j, context_count;
 OM_S_CHANSELECT to_notification;
 OM_S_CHANSELECT to_listeners;
 OM_S_OBJECT_LINKAGE *child_linkage = NULL;
 OM_S_OBJECT_LINKAGE child_context[2];
 struct GRid my_GRid;
 extern OMuword OPP_ACpretendin_class_id;


*msg = MSSUCC; 
my_GRid.objid = my_id;
my_GRid.osnum = OM_Gw_current_OS;

if(context->objid == NULL_OBJID)
 {
  if(as_osnum != OM_Gw_current_OS) return (OM_W_ABORT);
  as->objid = located_obj->objid;
  as->osnum = located_obj->osnum;
  *msg = MSSUCC;
  status = OM_S_SUCCESS;
 }
else
 {
   int child_count;

   EMmake_chanselect(GRnotify_notification, &to_notification);

   status = om$make_chanselect(channame = "ASsource.listeners",
                               p_chanselect = &to_listeners);
   if (!(1&status)) goto wrapup;

   status = om$get_channel_count(p_chanselect = &to_notification,
                                 objid = located_obj->objid,
                                 osnum = located_obj->osnum,
                                 count =(OMuint *) &child_count);
   if (!(1&status)) goto wrapup;

   if (child_count)
   {
   child_linkage = (OM_S_OBJECT_LINKAGE *) alloca(sizeof(OM_S_OBJECT_LINKAGE)
                     * child_count);
   EMerr_hndlr(!child_linkage, *msg, EMS_E_DynamicMemoryAllocated, wrapup);

   status = om$get_channel_objects(object = me, 
                                   p_chanselect = &to_notification, 
			           list = child_linkage,
   				   size = child_count,
				   count = (OMuint *)&child_count);
   EMerr_hndlr (!status, *msg, EMS_E_OMerror, wrapup);

   found = FALSE;

   for (i=0;i<child_count;i++)
   {
    if (EFisAncestryValid(msg, child_linkage[i].S_objid, 
                               child_linkage[i].osnum, 
                          OPP_ACpretendin_class_id, FALSE))
    {



     status = om$get_channel_objects(objid = child_linkage[i].S_objid,
                                     osnum = child_linkage[i].osnum,
                                   p_chanselect = &to_listeners, 
			           list = child_context,
   				   size = 2,
				   count = (OMuint *)&context_count);
     EMerr_hndlr (!(1&status), *msg, EMS_E_OMerror, wrapup);
     if (context_count != 2)
      continue;
 
     for (j=0;j<2;j++)
     {
      if ((context->objid == child_context[j].S_objid)
        &&(context->osnum == child_context[j].osnum))

      {
        as->objid = child_linkage[i].S_objid;
        as->osnum = child_linkage[i].osnum;
        found = 1;
        break;
      } 
     }
     if (found) break;
   }
  }
 }

  if(!found)
  {
    status = om$construct(	classid = OPP_ACpretendin_class_id,
			  	osnum	= as_osnum,
			  	p_objid = &(as->objid));
    EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, wrapup);

    as->osnum = as_osnum;

    status = om$send( 		msg 	= 
	      message ACpretendin.ACiconnect( 0, my_GRid,*context,"."),
		     targetid = as->objid,
		     targetos = as->osnum);
    EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, wrapup);
  }
 }

wrapup:
 EMWRAPUP (*msg, status, "In EMSpointer:NDmake_source error");
 return(status);
}

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 IGRlong status;
 struct GRid go;

 status = OM_S_SUCCESS;

 go.objid = NULL_OBJID;

 status = om$send (msg = message NDnode.ASreturn_go( &go, NULL, NULL),
                   targetid = my_id);

 if (go.objid != NULL_OBJID)
 {
  status = om$send (msg = message GRgraphics.GRgetobjinfo(msg, info),
                    targetid = go.objid,
                    targetos = go.osnum);
  if (!(1&status))
   strcpy(info->type, "EMSpointer");
 }

 return (status);
}
end implementation EMSpointer;


