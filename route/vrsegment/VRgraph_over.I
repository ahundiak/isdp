/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           method GRlocate_owner                            */
/*                                                                            */
/*  DESCRIPTION: Locate one of the construction plane of the control segment  */
/*               if this one is not selected.                                 */
/*                                                                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


class implementation VRCnrlSeg;


#include "igrdef.h"    
#include "grdpbdef.h"    
#include "grdpbmacros.h"    
#include "grerr.h"
#include "grownerdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "nddef.h"
#include "AS_status.h"

#define AS_DEBUG 1


/*****************************************************************************/

/* To locate the centerline for read only operation 			     */

method GRget_locate_properties(IGRlong *msg; IGRint *properties )
{
  *msg = MSSUCC;
  *properties = GR_LC_OWN_READ     | GR_LC_OWN_WRITE     |
                GR_LC_CMP_READ     | GR_LC_CMP_WRITE |
                GR_LC_OWN_PRM_READ | GR_LC_OWN_PRM_WRITE |
                GR_LC_RIGID;

  return(OM_S_SUCCESS);
}


/*****************************************************************************/

method GRlocate_owner
  (
  IGRlong          *p_msg;        /* OUT    Completion code                   */
  struct GRlc_cvl  *p_cvl;        /* IN     Module and action handler info    */
  struct GRlc_path *p_path;       /* IN/OUT The locate path of objects        */
  IGRint           *p_path_pos    /* IN/OUT Position of the obj in the path   */
  )

{
  IGRint         	nb_parent;          /* Number of parents to get       */
  IGRlong     		status;             /* Status returned by om          */
  double      		proj_parm;          /* Projected parameter            */
  IGRpoint 		dummy_pt,tmp;       /* dummy points                   */
  struct 	GRid 	list[3];            /* Parents to get 	       	      */
  struct 	GRparms	parms;              /* parms structure                */


  *p_msg = MSSUCC;
  status = OM_S_SUCCESS;

  /* Save initial locate point */

  if( p_cvl->attributes.type == GR_pt_loc ||
                                        p_cvl->attributes.type == GR_bl_loc )
  { 
    tmp[0] = p_cvl->attributes.acc_point[0] ;
    tmp[1] = p_cvl->attributes.acc_point[1] ;
    tmp[2] = p_cvl->attributes.acc_point[2] ;
  }

  /* Project if possible on segment */

  if( p_cvl->attributes.type == GR_pt_loc )
  {
    status = om$send( msg      = message GRgraphics.GRptproject
                                 ( p_msg, &p_cvl->module.md_env.matrix_type,
                                   p_cvl->module.md_env.matrix, tmp,
  		       		   p_cvl->attributes.acc_point, &parms ),
                      targetid = my_id);
    as$status( action = RET_STATUS );
    as$status( sts = *p_msg, action = RET_STATUS );
  }
  else if( p_cvl->attributes.type == GR_bl_loc )
  {
    /*| bore line locate */
    status = om$send( msg      = message GRgraphics.GRlnproject
                                 ( p_msg, &p_cvl->module.md_env.matrix_type,
                                   p_cvl->module.md_env.matrix,
                                   &p_cvl->attributes.acc_line, dummy_pt,
 		       		   p_cvl->attributes.acc_point, &proj_parm,
				   &parms ),
                      targetid = my_id);
    as$status( action = RET_STATUS );
    as$status( sts = *p_msg, action = RET_STATUS );
  }
  else if( p_cvl->attributes.type == GR_rp_loc ||
                                         p_cvl->attributes.type == GR_cv_loc )
       {
         /*| fence locate */;
       }
       else if( p_cvl->attributes.type == GR_nam_loc ||
                                    p_cvl->attributes.type == GR_crit_loc )
            { 
              /*| name locate */;
            }

  /* Add myself to the locate path */

  GRlc_add_path( p_path, p_path_pos, my_id, OM_Gw_current_OS );
  p_path[*p_path_pos].lc_info.module_info = p_cvl->module;

  /* Send locate owner to the planes */

  /*| Get the commun ( index = 1 ) and vertical ( index = 2 ) parents planes */
  /*| of the control segment                                                 */

  status = om$send( msg      = message NDnode.NDget_objects
                               ( ND_ROOT, list, 3, NULL, 0, OM_K_MAXINT, &nb_parent ),
                    targetid = my_id,
                    targetos = OM_Gw_current_OS);
  as$status(action = RET_STATUS);

  /* The system propose the common plane to locate */

  /*"Try to locate the plane %d.%d\n", list[1].objid, list[1].osnum */

  *p_msg = GR_I_NO_RESPONSE;
  status = om$send( msg      = message GRcmpowner.GRlocate_owner
                                       ( p_msg, p_cvl, p_path, p_path_pos ),
                    targetid = list[1].objid,
                    targetos = list[1].osnum);
  as$status( action = RET_STATUS );
  as$status( sts = *p_msg, action = RET_STATUS );

  if( status != OM_I_STOP_SENDING ) 
  {
    /* The user has refused the common plane ==> the system propose the */
    /* vertical one                                                     */

    /*"Try to locate the plane %d.%d\n", list[2].objid, list[2].osnum */

    *p_msg = GR_I_NO_RESPONSE;

    status = om$send( msg      = message GRcmpowner.GRlocate_owner
                                         ( p_msg, p_cvl, p_path, p_path_pos ),
                      targetid = list[2].objid,
                      targetos = list[2].osnum);
    as$status( action = RET_STATUS );
    as$status( sts = *p_msg, action = RET_STATUS );
  }

  /*| Try now myself */
  
  if( status & *p_msg & 1 )
  {
    if( status != OM_I_STOP_SENDING ) 
    {
      int owner_eligible, component_eligible;
 
      /*
       *  None of the owners responded to the locate message.
       */

       owner_eligible = FALSE;       /* Since I do not have an owner */

       component_eligible =
          ( p_cvl->attributes.obj_attr.owner_action & LC_OBJ_W_OWNER ) ? 2 : 1;
                  
       /*"owner_eligible %d component eligible %d\n",owner_eligible,component_eligible*/
       
       status = om$send( msg      = message GRgraphics.GRlocate_processing
                                    ( p_msg, p_cvl, p_path, p_path_pos,
                                      &owner_eligible, &component_eligible
                                    ),
                         targetid = my_id);
    }

    if( status & *p_msg & 1 )
    {
      if( p_path[*p_path_pos].call_action_handler )
      {
        status = ( *p_cvl->action_handler )
                 ( ( p_cvl->act_parms ), &p_path[*p_path_pos].lc_info,
                   ( p_cvl->locate_args ), &p_path[*p_path_pos].action );
      }
    }
  }

  GRlc_remove_path( p_path, p_path_pos );

  if( status == OM_I_STOP_SENDING )
  {
    int i;
    for (i=0; i <= *p_path_pos; ++i) p_path[i].call_action_handler = FALSE;
  }

  if( p_cvl->attributes.type == GR_pt_loc ||
                                        p_cvl->attributes.type == GR_bl_loc )
  {
    /*| Restore initial locate point */
    p_cvl->attributes.acc_point[0] = tmp[0];
    p_cvl->attributes.acc_point[1] = tmp[1];
    p_cvl->attributes.acc_point[2] = tmp[2];
  }

  return(status);

}


end implementation VRCnrlSeg;
