class implementation SKexplicit;

#include "DIdef.h"
#include "nddef.h"
#include "ECmsg.h"
#include "msdef.h"
#include "msmacros.h"

method GRcopy(long *msg; struct GRmd_env *obj_dsenv;
              struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
    long     om_stat;
    struct GRid new_grid;

    *msg = MSSUCC;
    om_stat = om$send(msg = message NDmacro.ACcopy_to_Groot(msg,
                                ND_TO_DEF_TEMP,
                                obj_dsenv, new_dsenv,
                                &new_grid),
                      targetid = my_id);
    *newobjid = new_grid.objid;
    return(om_stat);
}

method SKcreate_geom(long *EMmsg; unsigned short options;
                     struct GRmd_env *md_env; GRobjid *geom_handle)
{
 *EMmsg = EMS_S_Success;
 return (OM_S_SUCCESS);
}

method GRaddwrng (long *EMmsg; struct GRmd_env *md_info)
{
 *EMmsg = MSSUCC;
 return (OM_S_SUCCESS);
}

method GRremwrng (long *EMmsg; struct GRmd_env *md_info)
{
 *EMmsg = MSSUCC;
 return (OM_S_SUCCESS);
}

method GRgetobjinfo(long *msg; struct GRobj_info *info)
{
 *msg = MSSUCC;
 ex$message ( buff = info->type, msgnumb = EMS_S_ConstrainedDimension );
 return(OM_S_SUCCESS);
}

method debug()
{
  long msg_loc;
  char expname[DI_PATH_MAX];

  om$send (mode = OM_e_wrt_parent, msg = message SKexplicit.debug(),
   targetid = my_id);

  fprintf (stderr, "\tDim value : [%lf]\n", ME.expression->value);
  strcpy (expname, "");
  om$send (msg = message SKexplicit.SKgetname (&msg_loc, NULL,
   expname), targetid = my_id);
  fprintf (stderr, "\tDim name : %s\n", expname);

  return (OM_S_SUCCESS);
}

/*

Name
  GRdelete

Abstract

Synopsis

Description
  If I have any children, I need to send the NDparent_deleted message to
  the children.
Return Value

Notes

Index

Keywords

History
  11/24/93 : G Mallikarjuna : created
  06/01/94 : Sudha          : fix tr#119415247 - add sender id argument.
			      if the sender id in SKconstraint.GRdelete
		              is GRundo then only we split profile.
 */

method GRdelete (IGRlong *msg; struct GRmd_env *md_env)
{
  int		  ii,num_del;
  long 		  stat_OM, msg_loc;
  OMuint	  count;
  GRobjid	  memid;
  GRspacenum	  memos;
  OM_S_CHANSELECT chan_to_children;
  struct GRid my_grid,new_obj;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  num_del = 1;
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  om$make_chanselect ( channame = "NDchildren.children",
                       p_chanselect = &chan_to_children );
  /* 
   * Make sure the children know that I'm going away
   */
  om$get_channel_count ( objid = my_id, osnum = OM_Gw_current_OS,
                         p_chanselect = &chan_to_children, count = &count );
  for (ii = 0; ii < count; ii++)
  {
    if (om$get_objid_at_index ( objid = my_id,
          p_chanselect = &chan_to_children, index = 0,
          objidaddr = &memid, osnumaddr = &memos ) & 1)
    {
      stat_OM = om$send ( msg = message NDnode.NDparent_deleted( &msg_loc, num_del,
                                &my_grid, &new_obj, md_env ), 
                          targetid = memid, 
                          targetos = memos );
    }
  }

  /*
   * Invoke the default message to do the rest of the work
   */
  stat_OM = om$send (mode = OM_e_wrt_parent,
                     msg = message SKexplicit.GRdelete (&msg_loc, md_env),
                     senderid = sender_id,
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKexplicit.GRdelete");
  return (stat_OM);
}


/*

Name
  SKexplicit_clean_up

Abstract

Synopsis

Description
	method to be called by dimension code to clean up dimension constraint
	in case of the reference file detach/delete

History
	Satya -- 04/21/94 -- Created

*/

method SKexplicit_clean_up(IGRlong *msg; struct GRmd_env *md_env)
{
   IGRlong	stat_OM,msg_loc;
   enum GRdpmode	dpmode;
  
   *msg = EMS_S_Success;
   stat_OM = OM_S_SUCCESS;
   
   
   dpmode = GRbehe;
   om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
            &md_env->md_env.matrix_type, md_env->md_env.matrix, &dpmode,
            &md_env->md_id), targetid = my_id);

   stat_OM = om$send (mode = OM_e_wrt_parent,
   		      msg = message SKexplicit.GRdelete (&msg_loc, md_env),
                            targetid = my_id);
   EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
 
ret_end:
  EMWRAPUP (*msg, stat_OM, "SKexplicit.SKexplicit_clean_up");
  return (stat_OM);
}

end implementation SKexplicit;
