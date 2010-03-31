/* ###################   APOGEE COMPILED   ################## */
class implementation EMSparamvl;

#include "msdef.h"
#include "godef.h"
#include "dpdef.h"
#include "dp.h"
#include "exmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DImacros.h"
#include "nddef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#define SUPPORT_ONLY_DOES_NOT_WORK_FOR_MACROS 1

extern IGRint COpre_undelete_name();
extern GRclassid OPP_DMroot_class_id;
/*
 * Description:
 *
 *      This is the "real" delete for the parameter value and it's 
 *      dimension. It is most likely being sent by the associative 
 *      object.
 *
 * Notes:
 *
 * History:
 *
 *      jhw     06/28/91    Creation.
 *      jsd     05/10/93    Added the correct number of arguments to the call
 *                          to COpre_undelete_name.
 */
method EMparam_delete ( IGRlong * msg; struct GRmd_env * mod_env )
{
    IGRlong         om_msg = OM_S_SUCCESS ,
                    long_rc = MSSUCC;
    IGRint          i;

    OM_S_CHANSELECT to_components ,to_children;
    OM_S_OBJECT_LINKAGE *list;
    struct GRid     dim_id;
    IGRint ch_count = 0 ,child_count = 0;
    struct GRmd_env display_env;
    IGRboolean      aflag = 0;
   
    aflag = pwIsActivationOn();
    gr$get_module_env(buffer = &display_env);

    EMmake_chanselect(NDchildren_children,&to_children);
    EMmake_chanselect(GRcmpowner_to_components, &to_components);

    om_msg = om$get_channel_count( object = me,
				   p_chanselect = &to_children,
				   count = (OMuint *)&ch_count);
    if(!( om_msg &1)) goto wrapup;
    
    list = (OM_S_OBJECT_LINKAGE *) stackalloc(ch_count * 
					      sizeof(OM_S_OBJECT_LINKAGE));
    if(!list) goto wrapup;

    om_msg = om$get_channel_objects( object = me,
				    p_chanselect = &to_children,
				    list = list,
				    size = ch_count,
				    count = (OMuint *) &ch_count);
    if(!( om_msg &1)) goto wrapup;
    
/*
    while( ch_count--) ---KNAP
*/
    for (i=0; i<ch_count; i++)
      {
	if(EFisAncestryValid(&long_rc, list[i].S_objid,
			     list[i].osnum,
			     OPP_DMroot_class_id,FALSE))
	  child_count++;
      }
/*
    if(child_count >1) ---KNAP
*/
    if((ch_count - child_count) >1)
      {
	/* Do not delete this object because this parameter is shared by
	 * another feature
	 */
	
	return(OM_S_SUCCESS);
      }
    om_msg = om$get_objid_at_index ( object = me,
                                     p_chanselect = &to_components,
                                     index = 0,
                                     objidaddr = &dim_id.objid,
                                     osnumaddr = &dim_id.osnum );
    if (om_msg == OM_S_SUCCESS)
    {
        IGRlong       msg_loc;
        enum GRdpmode mode = GRbehe;
        IGRshort      action = 0, props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

        if (!(ex$is_invis(mod_osnum = OM_Gw_current_OS))) 
        {
          om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                                       &mod_env->md_env.matrix_type,
                                       mod_env->md_env.matrix,
                                 &mode,
                                 &mod_env->md_id),
                  senderid = dim_id.objid,
                  p_chanselect = &to_components );
        }
        else
        {
         if(aflag)
         {
          om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                                 &display_env.md_env.matrix_type,
                                 display_env.md_env.matrix,
                                 &mode,
                                 &display_env.md_id),
                  senderid = dim_id.objid,
                  p_chanselect = &to_components );
         } 
        }
        om$send ( msg = message GRgraphics.GRchgprops
                                            ( &msg_loc, &action, &props ),
                  p_chanselect = &to_components );

        if (mod_env->md_id.objid != NULL_OBJID)
        {
	 om$send(msg = message GRgraphics.GRremwrng(&msg_loc, mod_env),
                  p_chanselect = &to_components );
        }

        {
         struct GRmd_env temp_env;
         temp_env = *mod_env;
         temp_env.md_id.objid = NULL_OBJID;

         om_msg = om$send ( msg = message GRowner.GRdelete (&msg_loc,
                           &temp_env),
                           mode = OM_e_wrt_message,
                           p_chanselect = &to_components );
        }
    }
    else om_msg = OM_S_SUCCESS;

#if SUPPORT_ONLY_DOES_NOT_WORK_FOR_MACROS
{
  IGRchar mask, n_state;
/*
 * Change my state such that it gets deleted only if there is nobody 
 * depending on me.
 * pp 09/26/91
 */
  mask = ~0;
  n_state = ND_DEL_NO_CH;

  om$send (msg = message NDnode.NDchg_state(mask, n_state),
           targetid = my_id);
 }
#endif

 

    *msg = EMS_S_Success;

wrapup:
    return (OM_S_SUCCESS);

}

method GRdelete ( IGRlong * msg; struct GRmd_env * mod_env )
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRint          count = 0;
/*
    OM_S_CHANSELECT to_components;
 */

    *msg = MSSUCC;
/*
 * Do not delete the auto-dimension since the user does not have any
 * graphic handle to his expression after he deletes the same.
 * Prasad 02/10/92
 */

/*
    EMmake_chanselect(GRcmpowner_to_components, &to_components);

    om$get_channel_count ( objid = my_id,   
                           p_chanselect = &to_components,
                           count = &count );

    if (count)
    {
        om_msg = om$send ( msg = message GRgraphics.GRdelete (msg, mod_env),
                           p_chanselect = &to_components );
    }


    return (om_msg);
*/

/*
 * Delete prepended ".deleted_" to the object's name in case the object gets
 * undeleted.  Since EMSparamvl objects are no longer getting deleted, we need
 * to restore the object's name to its original value.  JSD - 03/24/92
 */

/*
 * Allow deletion of objects with names (auto dimensions) only
 * when they do not have any children. Kapil
 */

 /* does the object have a name ? */
  om_msg = di$start_untrans( osnum   =  OM_Gw_current_OS,
                             objid   =  my_id,
                             ptr     = &count );

  if (om_msg == DIR_S_SUCCESS)
  {
    struct GRid var_grid[100];
    int num_var;
    
    /* get my children */
    
    om_msg = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN,var_grid,
                           100, NULL, 0, 3, &num_var), targetid = my_id);
  
    if (num_var == 0)
    {
        om_msg = om$send ( msg = message expression.GRdelete (msg, mod_env),
                  mode = OM_e_wrt_message,
    		  targetid = my_id);                           
    }
    else
    {
      om_msg = COpre_undelete_name( count, my_id, OM_Gw_current_OS );

      om_msg = di$update_dir_form();
    }
  }

 return (om_msg);
}

end implementation EMSparamvl;

/*
    EMmake_chanselect(NDchildren_children, &to_children);

    om$get_channel_count ( objid = my_id,   
                           p_chanselect = &to_children,
                           count = &child_count );

    if (child_count <= 1)
    {
     IGRboolean delete = TRUE;
     struct GRid child_id;

     if (child_count)
     {
      om_msg = om$get_objid_at_index ( object = me,
                                       p_chanselect = &to_children,
                                       index = 0,
                                       objidaddr = &child_id.objid,
                                       osnumaddr = &child_id.osnum );
      if (sender_id != child_id.objid)
       delete = FALSE;
     }
      if (delete)
           om_msg = om$send ( msg = message Root.delete (NULL),
                              targetid = my_id );
    }
*/
