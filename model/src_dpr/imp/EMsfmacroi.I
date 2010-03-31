/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmacro;

#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "OMmacros.h"
#include "msdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "nddef.h"

/*
 * This file contains overrides for EMdeactivate and EMactivate which
 * just return success as nothing special has to be done by the macro
 * object.
 * pp (05/25/90)
 */

method EMconstruct_associative(IGRlong *EMmsg;
                               IGRushort options;
                               GRobjid old_objid;
                               IGRint num_parents;
                               IGRchar *parent_info;
                               IGRint type;
                               IGRchar *recomp_info;
                               struct GRvg_construct *construct_list)
{
  IGRint status;
  IGRint info_size,obj_count,i,nb_root;
  struct GRid *grid,null_grid,new_grid,*list;
  IGRint parent_state;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 if( type == EMS_ASpattern_macro )
   {
     /* Current type is pattern macro  object , need to send ndupdate to
      * all the objects 
      */
     info_size = OM_DIMENSION_OF(ME.EMSassoc->info);
     obj_count = info_size/sizeof(struct GRid);
     grid = (struct GRid *)recomp_info;

     for ( i = 0; i< obj_count; i++)
       {
	 status = 
	 om$send( msg = message NDnode.NDget_objects(
					    ND_ROOT|ND_IN_BUF,
					    NULL,
					    0,
					    &list,
					    0,
					    OM_K_MAXINT,
					    &nb_root),
		 targetid = grid[i].objid,
		 targetos = grid[i].osnum);
	 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
	 
	 null_grid.objid = NULL_OBJID;
	 
	 status =
	 om$send( msg = message NDnode.NDupdate((int *)EMmsg,
						NULL,
						nb_root,
						list,
						&parent_state,
						&null_grid,
						&new_grid,
						construct_list->env_info),
		 targetid = grid[i].objid,
		 targetos = grid[i].osnum);
	 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
       }
     if(obj_count)
        OM_SET_DIMENSION(me^^EMSassoc.info, 0);
   }
 wrapup:
  return (status);
}

method EMdeactivate (
IGRlong	            *EMmsg;
IGRshort            *option;
struct GRmd_env     *md_env;
GRobjid             **display_ids;
IGRint              *display_count)
{
 *EMmsg = EMS_S_Success;
 return (OM_S_SUCCESS);
}

method EMactivate(IGRlong         *EMmsg; 
                   IGRshort        *option;
                   struct GRmd_env *env_info;
                   GRobjid         **display_ids;
                   IGRint          *display_count)
{
 *EMmsg = EMS_S_Success;
 return (OM_S_SUCCESS);
}

method EMgetsolidclass(IGRlong *EMmsg; IGRchar *desc)
{
  *EMmsg = EMS_S_Success;
  strcpy(desc, "EMSslmacro");
  return(OM_S_SUCCESS);
}

method EMcheckOverlap(IGRlong *EMmsg;
                      struct EMSinlist *inlist;
                      IGRboolean *does_overlap; IGRushort options)
/*
Description
    This message will determine if this tree node has an overlap of
    surfaces/topology based on the inlist.

Return Values    
    EMS_S_Success if all is well.

Notes
    About parameters:
        inlist  - contains surf/loop/edge ids that have been added so far. 
        does_overlap - TRUE if an overlap is detected.
        options - currently unused.

History
   PP : 06/18/90
*/
{
  *EMmsg = EMS_S_Success;
  *does_overlap = TRUE;
  return(OM_S_SUCCESS);
}

method EMcanRecompute(IGRlong *EMmsg; IGRboolean *can_rc)
/*
Description
    This message will indicate the ability of this node to recompute. 

Return Values
    EMS_S_Success is always returned.

Notes
    About parameters:
      can_rc - if true this node can recompute.

History
    PP 06/18/90 Creation.
*/
{
  *EMmsg = EMS_S_Success;
  *can_rc = TRUE;  
  return(OM_S_SUCCESS);
}

method EMislm(IGRlong *EMmsg; IGRboolean *is_lm)
/*
Description
   See EMSsurface.S

Return Values
   EMS_S_Success if all is well

History
    PP 06/18/90 Creation.
*/
{
   *EMmsg = EMS_S_Success; 
   *is_lm = FALSE;
   return(OM_S_SUCCESS);
}
method GRdelete( IGRlong *msg; struct GRmd_env *md_env)
{
  IGRint status;
  IGRlong long_rc;
  IGRushort options;
  OM_S_CHANSELECT to_notify;
  IGRuint info_size ,type;

  status = om$send( msg = message EMSassoc.EMget_info(
					   &long_rc,
					   options,
					   &type,
					   &info_size,
					   (char **)NULL),
		   targetid = my_id);

  if( (status & long_rc & 1) && type == EMS_ASpattern_macro)
    {
      EMmake_chanselect(GRnotify_notification, &to_notify);

      status = 
      om$send( msg = OPPmargs,
	       p_chanselect = &to_notify);
      /* Do not check for status */
    }

  status = 
  om$send( msg = message EMSdpr.GRdelete(msg,md_env),
	   mode = OM_e_wrt_message,
	   targetid= my_id);
  EMerr_hndlr(!(1&status), *msg, EMS_E_Fail, wrapup);

 wrapup:
  return(status);
}
end implementation EMSsfmacro;

