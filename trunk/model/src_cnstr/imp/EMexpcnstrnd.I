/*
  DESCRIPTION

    This file contains the overrides of the ND methods. Some behaviour
    has to be tailor made to suit specific needs

  NOTES
   
    This class has all of it's parents on the NDfather.father channel.
    All parents of this class are categorized under two classes: 1) classes
    that return parameter_generic as the type on NDgive_structure and 
    2) those that do not.


  HISTORY

    SS  :  03/21/91  :  Creation
*/

class implementation EMSexpcnstr;

#include "grdpbdef.h"
#include "grdpbmacros.h" 
#include "madef.h"
#include "asbox.h"
#include "nddef.h"
#include "asmacros.h"
#include "dimplcmacros.h"

#define OKTORETURNGO 0

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSparamgm_class_id;

from ACpretendin import ACiconnect;
from DMroot import inq_geom_type;

method make_orphan()
{
  IGRboolean status;
  OMuint num_parents;
  IGRint i;
  IGRlong msg_loc, stat_OM;
  struct GRid grid;
  struct GRmd_env md_env;
  struct ret_struct ret_struct;
  OM_S_CHANSELECT chan_to_parents;
  OM_S_OBJECT_LINKAGE *objlist;

  status = TRUE;

  num_parents = 0;
  EMmake_chanselect (NDfather_father, &chan_to_parents);
  om$get_channel_count (p_chanselect = &chan_to_parents, count = &num_parents,
   object = me);

  if (num_parents)
    {
    objlist = (OM_p_OBJECT_LINKAGE) alloca (num_parents * 
               sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!objlist, status, FALSE, ret_end);

    stat_OM = om$get_channel_objects (p_chanselect = &chan_to_parents,
               object = me, count = &num_parents, size = num_parents,
               list = objlist);
    EMerr_hndlr (EMSerror (stat_OM), status, FALSE, ret_end);

    md_env.md_env.matrix_type = MAIDMX;
    ex$get_modid (mod_osnum = OM_Gw_current_OS, mod_id = &md_env.md_id.objid);
    md_env.md_id.osnum = OM_Gw_current_OS;

    for (i=0; i<num_parents; i++)
      {
      ret_struct.type = NULL;
      om$send (msg = message NDnode.NDgive_structure (&msg_loc,
       &ret_struct, &md_env), targetid = objlist[i].S_objid,
       targetos = objlist[i].osnum);

      if (ret_struct.type & parameter_generic)
        {
        grid.objid = objlist[i].S_objid;
        grid.osnum = objlist[i].osnum;

        om$send (msg = message NDnode.NDdisconnect (1, &grid),
         targetid = my_id);
        }
      }
    }

ret_end:
  if (!status)
    return (om$send (msg = message expression.make_orphan(),
             mode = OM_e_wrt_message, targetid = my_id));
  else
    return (OM_S_SUCCESS);
}


method modify (IGRchar *name; IGRchar *syntax; IGRshort *msg)
{
  IGRchar geom_type;
  IGRshort s_msg_loc;
  OMuint count;
  IGRint i, inxlim;
  IGRlong stat_OM, msg_loc;
  struct GRid dim_grid;
  struct GRmd_env md_env;
  struct ret_struct ret_struct;
  IGRint sizbuf, nret;
  OM_S_CHANSELECT chan_to_parents, chan_to_comps;
  OM_S_OBJECT_LINKAGE objlist, *p_objlist;
  
  stat_OM = OM_S_SUCCESS;
  *msg = TRUE;

  /*
   * Invoke the default method to actually perform the modify
   */

  sizbuf = sizeof(struct GRmd_env);

  gr$get_module_env ( msg = &msg_loc,
                       sizbuf = &sizbuf,
                       buffer = &md_env,
                       nret = &nret );

  stat_OM = om$send (mode = OM_e_wrt_message, 
             msg = message expression.modify (name, syntax, &s_msg_loc),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & s_msg_loc), *msg, FALSE, ret_end);

  /*
   * The dimension handle owned by this object needs to have it's type set 
   * to implicit if this expression has any other expression parents
   * driving it.
   */

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  count = 0;
  om$get_channel_objects (object = me, p_chanselect = &chan_to_comps,
   count = &count, size = 1, list = &objlist);
  if (count)
    {
    dim_grid.objid = objlist.S_objid;
    dim_grid.osnum = OM_Gw_current_OS;

    geom_type = NULL;
    om$send (msg = message DMroot.inq_geom_type (&geom_type),
     targetid = dim_grid.objid);

    EMmake_chanselect (NDfather_father, &chan_to_parents);
    count = 0; 
    om$get_channel_count (object = me, p_chanselect = &chan_to_parents,
     count = &count);
    if (count)
      {
      p_objlist = (OM_p_OBJECT_LINKAGE) alloca (count *
                   sizeof (OM_S_OBJECT_LINKAGE));
      EMerr_hndlr (!p_objlist, *msg, FALSE, ret_end);

      om$get_channel_objects (object = me, p_chanselect = &chan_to_parents,
       count = &count, size = count, list = p_objlist);
      inxlim = count;

/*
      md_env.md_env.matrix_type = MAIDMX;
      ex$get_modid (mod_osnum = OM_Gw_current_OS,
       mod_id = &md_env.md_id.objid);
      md_env.md_id.osnum = OM_Gw_current_OS;
*/

      inxlim = count;
      for (i=0; i<inxlim; i++)
        {
        ret_struct.type = NULL;
        om$send (msg = message NDnode.NDgive_structure (&msg_loc,
         &ret_struct, &md_env), targetid = p_objlist[i].S_objid,
         targetos = p_objlist[i].osnum);

        if (! (ret_struct.type & parameter_generic))
          count--;
        }
      }

    if (count && !(geom_type & DIM_IMPLICIT))
      {
      dm$set_type (type = DIM_IMPLICIT, update = TRUE, md_env = &md_env,
       dim_grid = &dim_grid);
      }
    else if (!count && geom_type & DIM_IMPLICIT)
      {
      dm$set_type (type = DIM_IMPLICIT, op_code = BIT_CLEAR, update = TRUE,
       md_env = &md_env, dim_grid = &dim_grid);
      }
    }

ret_end:
  msg_loc = *msg;
  EMWRAPUP (msg_loc, stat_OM, "EMSexpcnstr.modify");
  return (stat_OM);
}


method NDconnect (IGRint nb_root; struct GRid *root;
                  struct GRid original; IGRint type)
{
  OMuint num_parents;
  IGRint i, j, conn_inx, start_inx;
  IGRlong msg_loc, stat_OM;
  struct GRmd_env md_env;
  struct GRid my_grid;
  struct ret_struct ret_struct;
  OM_S_CHANSELECT chan_to_parents, chan_to_children;
  OM_S_OBJECT_LINKAGE *objlist;

  msg_loc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * If the request is to add connections or this is a new set of parents
   * to be added, then make sure that the connections take place such
   * that all the expression-type parents are connected as if other type
   * of parents did not exist. Other kind of parents are simply added
   * at the end. The parents are then notified of the connection.
   */

  if (type == ND_ADD || type == ND_NEW)
    {
    num_parents = 0;
    EMmake_chanselect (NDfather_father, &chan_to_parents);
    om$get_channel_count (p_chanselect = &chan_to_parents,
     count = &num_parents, object = me);

    start_inx = 0;
    if (num_parents)
      {
      objlist = (OM_p_OBJECT_LINKAGE) alloca (num_parents * 
                 sizeof (OM_S_OBJECT_LINKAGE));
      EMerr_hndlr (!objlist, msg_loc, EMS_E_NoStackMemory, ret_end);

      om$get_channel_objects (p_chanselect = &chan_to_parents,
       object = me, count = &num_parents, size = num_parents,
       list = objlist);

      md_env.md_env.matrix_type = MAIDMX;
      ex$get_modid (mod_osnum = OM_Gw_current_OS,
       mod_id = &md_env.md_id.objid);
      md_env.md_id.osnum = OM_Gw_current_OS;

      for (start_inx=0; start_inx<num_parents; start_inx++)
        {
        ret_struct.type = NULL;
        om$send (msg = message NDnode.NDgive_structure (&msg_loc,
         &ret_struct, &md_env), targetid = objlist[start_inx].S_objid,
         targetos = objlist[start_inx].osnum);

        if (! (ret_struct.type & parameter_generic))
          break;
        }
      }

    EMmake_chanselect (NDchildren_children, &chan_to_children);
    for (i=0, j=start_inx; i<nb_root; i++, j++)
      {
      conn_inx = j;
      if (num_parents)
        {
        ret_struct.type = NULL;
        om$send (msg = message NDnode.NDgive_structure (&msg_loc,
         &ret_struct, &md_env), targetid = root[i].objid,
         targetos = root[i].osnum);

        if (! (ret_struct.type & parameter_generic))
          conn_inx = MAXINT;
        }

      stat_OM = om$send (msg = message Root.connect (chan_to_parents,
                 MAXINT, root[i].objid, root[i].osnum, chan_to_children, 
                 conn_inx), targetid = my_id);
      EMomerr_exit (stat_OM, ret_end);
      }

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    for (i=0; i<nb_root; i++)
      om$send (msg = message NDnode.NDnotify_connect (my_grid),
       targetid = root[i].objid, targetos = root[i].osnum);	
    }
  else
    stat_OM = om$send (mode = OM_e_wrt_message,
               msg = message expression.NDconnect (nb_root, root, original,
               type), targetid = my_id);

ret_end:
  EMWRAPUP (msg_loc, stat_OM, "EMSexpcnstr.NDconnect");
  return (stat_OM);
}


method NDmake_source(IGRlong *msg; struct GRid *located_obj,*context;
                     char *path; GRspacenum as_osnum; struct GRid *as)
{
 IGRboolean found = FALSE;
 IGRlong status;
 OMuint context_count;
 int i, j;
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
   OMuint child_count;

   EMmake_chanselect(GRnotify_notification, &to_notification);

   status = om$make_chanselect(channame = "ASsource.listeners",
                               p_chanselect = &to_listeners);
   if (!(1&status)) goto wrapup;

   status = om$get_channel_count(p_chanselect = &to_notification,
                                 objid = located_obj->objid,
                                 osnum = located_obj->osnum,
                                 count = &child_count);
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
				   count = &child_count);
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
				   count = &context_count);
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
 EMWRAPUP (*msg, status, "In EMSexpcnstr:NDmake_source error");
 return(status);
}

#if OKTORETURNGO
method ASreturn_go ( struct GRid *go;
                     IGRshort    *mat_type;
                     IGRdouble   *matrix )
*/
/* *******************************************************
Description
 This method returns the dimensional handle as the graphic object if
 it exists, else it returns itself.

History
 Creation : PP : 04/24/91
 ******************************************************** */
/*
{
 IGRlong         EMmsg, status;
 OM_S_CHANSELECT to_components;
 IGRint comp_count;

 EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

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

  status = om$get_channel_count(objid = my_id,
                                osnum = OM_Gw_current_OS,
                                p_chanselect = &to_components,
                                count = &comp_count);
  if (!(1&status)) goto wrapup;

  if (comp_count != 1)
  {
    go->objid = my_id;
    go->osnum = OM_Gw_current_OS;
    goto wrapup;
  }

  status = om$get_objid_at_index(osnum = my_id,
                                 objid = OM_Gw_current_OS,
                                 p_chanselect = &to_components,
                                 index = 0,
                                 objidaddr = &go->objid,
                                 osnumaddr = &go->osnum);
  if (!(1&status)) goto wrapup;
wrapup:
 if (!(1&EMmsg)) status = OM_E_ABORT;
 return (status);
}
#endif

/*

Name
  NDparent_deleted

Abstract

Synopsis

Description
  My parent is deleted.
Return Value

Notes

Index

Keywords

History
  11/24/93 : G Mallikarjuna : created

 */

method NDparent_deleted ( long *msg; int count_deleted; struct GRid list_deleted [];
                          struct GRid *new_obj; struct GRmd_env *md_env)
{
  IGRlong stat_OM, msg_loc;
  enum GRdpmode mode;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  stat_OM = om$send (mode = OM_e_wrt_message, 
                     msg = message expression.NDparent_deleted(&msg_loc,count_deleted,
                           list_deleted, new_obj, md_env ), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
  mode = GRbd;
  stat_OM = om$send (msg = message NDnode.NDdisplay(NULL,mode,md_env),
                     targetid = my_id);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSexpcnstr.NDparent_deleted");
  return (stat_OM);
}

end implementation EMSexpcnstr;
