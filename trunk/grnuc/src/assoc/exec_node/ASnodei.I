class implementation ASnode;
/*
   Ch    dec 87 :  update for the 1.1 release

   This is the implementation file of the class ASnode and gather only the
   overrided method of GRgraphics and GRvg.
*/

#include "AS_status.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "asdef.h"
#include "nddef.h"
#include "asmacros.h"
#include "asbox.h"
#include "dpmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grownmacros.h"
#include "exmacros.h"

#define AS_DEBUG 1

from ACpretgo  import ACgive_info;

method NDupdate(int *msg, cn_type, count;
                struct GRid *parents;
                int *parent_state;
                struct GRid *context,*new_objid;
                struct GRmd_env *md_env)
{
 long status,loc_msg;
 enum GRdpmode dpmode;
 OM_S_OBJID sv_md;
 struct GRid cur_mod;
 extern IGRboolean ASbroadcast_in_progress;
 IGRboolean save_br;

 new_objid->objid = my_id;
 new_objid->osnum = OM_Gw_current_OS;

 /*"cn_type %x\n",cn_type */

 /* Depending on parent state, recompute or not */

 NDcontrol_parent_state(count,parent_state,msg);

 if(!(1&*msg)) return OM_S_SUCCESS;


/* In case of stop, don't update */

 if( (cn_type&ND_COMP_TYPE) == ND_COMP_STOPPED)
   {
    *msg = ND_COMP_OUT_OF_DATE;
    return OM_S_SUCCESS;
   }

/* Get cur mod id for display */

 if(   !(cn_type&ND_COMP_NO_DISPLAY)
    || !(cn_type&ND_COMP_NO_ERASE))
   {
    status = ex$get_cur_mod(id = &cur_mod.objid, osnum = &cur_mod.osnum);
    as$status();
   }


 save_br = ASbroadcast_in_progress;
 ASbroadcast_in_progress = TRUE;

/* if Rtree defined removed the element from R-tree */

 if(!(cn_type&ND_COMP_NO_REM_RT))
  {
   /*| remove from R-tree */
   status = om$send(msg = message GRgraphics.GRremwrng(&loc_msg,md_env),
		    targetid = my_id);
  }
 if(!(cn_type&ND_COMP_NO_ERASE))
  {
   /*| erase */
   dpmode = GRbehe;
   status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
				   &md_env->md_env.matrix_type,
				   md_env->md_env.matrix,
				   &dpmode,
				   &cur_mod),
		    targetid = my_id);
   as$status();
  }

/*| recompute the element */

 loc_msg = 0;
 sv_md = md_env->md_id.objid;
 md_env->md_id.objid = NULL_OBJID;
 status = om$send(msg = message NDnode.NDcompute_node(&loc_msg,cn_type,
						count,parents,md_env),
		  targetid = my_id);
 md_env->md_id.objid = sv_md;

/* If context compute, transfer symbology */

 if(context && context->objid != NULL_OBJID)
		 ACtrans_symb(*context,*new_objid);

/* make sure that a completion code is returned */
 if(! loc_msg) *msg = ND_COMP_SUCC;
 else *msg = loc_msg;


/* if Rtree defined add the element to R-tree */

 if(!(cn_type&ND_COMP_NO_ADD_RT))
  {
   /*| add to R-tree */
   status = om$send(msg =  message GRgraphics.GRaddwrng(&loc_msg,md_env),
                    targetid = my_id);
  }
/* display the element */

 if(!(cn_type&ND_COMP_NO_DISPLAY))
  {
   /*| display */
   dpmode = GRbd;
   status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
				   &md_env->md_env.matrix_type,
				   md_env->md_env.matrix,
				   &dpmode,
				   &cur_mod),
		    targetid = my_id);
   as$status();
  }

ASbroadcast_in_progress = save_br;

/*" completion code %d\n",*msg */
 return OM_S_SUCCESS;
}


method NDmove_to_root(IGRlong *msg; struct GRid *src_grid; 
		      struct GRmd_env *md_env )
{
 struct GRid my_grid,go_grid;
 IGRlong status, status_state;
 OM_S_OBJECT_LINKAGE go_ln;
 OMuint count;
 char obj_state;
 
 status_state = om$send(msg = message NDnode.NDget_state(&obj_state),
		  targetid = my_id);

 if(status_state&1 && obj_state&ND_DONT_MVRT)
  {
   status = om$send(msg = message NDnodein.NDmove_to_root(msg,src_grid,md_env),
		    targetid = my_id,
		    mode = OM_e_wrt_message);
   return(status);
  }

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 /*| get first graphic object */

 status = om$get_channel_objects(object = me, p_chanselect = &AS_to_comp,
				list = &go_ln, size = 1, count = &count);
 if(!(status&1) || count <1) return (OM_W_ABORT);

 go_grid.objid=go_ln.S_objid;
 go_grid.osnum=go_ln.osnum;

 /*| Disconnect the graphic objects from the owner */

 status = om$send( msg = message GRconnector.GRdisconn( msg, &my_grid ),
		   p_chanselect = &AS_to_comp);
 as$status( action = RET_STATUS);

 /*| We create an source object and connect the first graphic object */

 status = as$make_source( go_grid = go_grid, as_grid = src_grid,
                          as_os = md_env->md_id.osnum);
 as$status( action = RET_STATUS);

 /*| Move the channels children and to_owner to the assoc_grid object */

 status = om$send( msg = message Root.move_chan
			( ND_children, my_id, OM_Gw_current_OS, ND_children),
                    targetid = src_grid->objid,
		    targetos = src_grid->osnum);
 as$status( action = RET_STATUS);

 status = om$send( msg = message Root.move_chan
			( AS_to_owner, my_id, OM_Gw_current_OS, AS_to_owner), 
                   targetid = go_grid.objid, targetos = go_grid.osnum);
 as$status( action = RET_STATUS);

 
 if(status_state)
  {
   status = om$send( msg = message NDnode.NDchg_state(~0,obj_state),
                   targetid = src_grid->objid,
                   targetos = src_grid->osnum );
   as$status();
  }

 status = om$send( msg = message Root.delete(1),
		   targetid = my_id);
 as$status( action = RET_STATUS );
 

 return(OM_S_SUCCESS);
}


method NDcopy_to_root(IGRlong *msg; IGRint cp_type;
		      struct GRmd_env *obj_info, *new_info;
		      struct GRid *newobjid)
{
 IGRlong  status;
 struct GRid owner;
 char obj_state;

 status = om$send( msg = message NDnode.NDcopy(msg, cp_type,
					       obj_info, new_info, &owner),
                   targetid = my_id );
 as$status(action = RET_STATUS);

 status = om$send( msg = message NDnode.NDget_state(&obj_state),
		   targetid = my_id);
 if(status&1  && obj_state)
  {
   obj_state = obj_state & ~ND_DONT_MVRT;
   status = om$send( msg = message NDnode.NDchg_state(~0,obj_state),
                   targetid = owner.objid, targetos = owner.osnum );
  }
		  

 status = om$send( msg = message NDnode.NDmove_to_root(msg, newobjid, 
 		   new_info),
                   targetid = owner.objid, targetos = owner.osnum );

 /*" return %d %d\n",newobjid->objid,newobjid->osnum */
 as$status();
 return(status);
}


method NDcopy(IGRlong *msg; int cp_type;
	      struct GRmd_env *obj_dsenv, *new_dsenv; struct GRid *newobjid)
{
 IGRlong status,actmsg;
 struct GRid active_owner;
 
 /*| use the GRcopy overriden by GRowner */
 /*| DO NOT CONNECT TO ACTIVE OWNER */

  gr$get_active_owner ( msg=&actmsg,active_owner=&active_owner);
  if(actmsg == MSSUCC) gr$clear_active_owner(msg= &actmsg);


 status = om$send( msg = message GRowner.GRcopy( msg, obj_dsenv,
                   new_dsenv, &newobjid->objid ),
 		   mode = OM_e_wrt_message, targetid = my_id );
  if(actmsg == MSSUCC)
                 gr$put_active_owner ( msg=&actmsg,active_owner=&active_owner);

 as$status(action = RET_STATUS);
 newobjid->osnum = new_dsenv->md_id.osnum; 
 /*"copied object: %d, %d\n", newobjid->objid, newobjid->osnum */
 return (OM_S_SUCCESS);
}

/* Works correctly even if remove from R-tree fails */

method NDdelete(struct GRmd_env *md_env)
{
 IGRlong msg, status;
 OM_S_OBJID save_id;
 extern IGRboolean ASbroadcast_in_progress;
 IGRboolean save_br;
 

 /* remove myself from the Rtree */
 if(md_env->md_id.objid != NULL_OBJID)
  {
   status = om$send(msg = message GRgraphics.GRremwrng(&msg,md_env),
		    targetid = my_id);
 
  }

 /* delete graphic objects */
 /* I want them to be deleted immediately and not put in the batch */

 save_id = md_env->md_id.objid;
 md_env->md_id.objid = NULL_OBJID;
 save_br = ASbroadcast_in_progress;
 ASbroadcast_in_progress = TRUE;

 status = om$send( msg = message GRgraphics.GRdelete( &msg, md_env),
                   p_chanselect = &AS_to_comp);
 as$status();
 md_env->md_id.objid = save_id;
 ASbroadcast_in_progress = save_br;

 /*
    delete myself with respect to node message
 */


 status = om$send( msg = message NDnode.NDdelete(md_env),
                   mode = OM_e_wrt_message,
                   targetid = my_id);
 as$status();

 
 return(OM_S_SUCCESS);
}

method NDgive_structure(IGRlong *msg; struct ret_struct *str;
			struct GRmd_env *md_env )
{
 IGRint status;
 OM_S_OBJECT_LINKAGE go_link;
 OMuint count;

 *msg = MSFAIL;

/* get the graphic object (take first object if several) */

  status = om$get_channel_objects(object = me, p_chanselect = &AS_to_comp,
				 list = &go_link,size = 1, count = &count);

  as$status(action = RET_STATUS);
  if(count < 1) return (OM_W_ABORT);
				 
/* get its structure */

  status = ASgo_give_structure( go_link.S_objid, go_link.osnum,
			        md_env, str );
  *msg = MSSUCC;
  
  return( status );
}

method NDdisplay(IGRint dp_mode; enum GRdpmode pen; struct GRmd_env *obj_info)
 {
  struct GRmd_env loc_env;
  long loc_msg,status;
  struct GRid cur_mod;
  extern IGRboolean ASbroadcast_in_progress;
  IGRboolean save_br;

  if(obj_info == NULL)
    {
     obj_info = &loc_env;
     loc_env.md_env.matrix_type = MAIDMX;
     MAidmx((int *)&loc_msg,loc_env.md_env.matrix);
     loc_env.md_id.osnum = OM_Gw_current_OS;
     loc_env.md_id.objid = NULL_OBJID;
    }

  status = ex$get_cur_mod(id = &cur_mod.objid, osnum = &cur_mod.osnum);
  as$status(action = RET_STATUS);


  save_br = ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;
  status = om$send(msg = message GRowner.GRdisplay(&loc_msg,
			&obj_info->md_env.matrix_type,obj_info->md_env.matrix,
			&pen,&cur_mod),
		targetid = my_id);

  ASbroadcast_in_progress = save_br;
  return status;
}

/*
   This method return ONLY THE FIRST graphic object connected 
   and its environnement definition
*/

method ASreturn_go(struct GRid *go; IGRshort *mat_type;IGRdouble *matrix)
{
 IGRint msg,status;
 OM_S_OBJID go_l;
 OMuword osn;
 GRclassid go_classid;

/*" obj %d %d\n",my_id,OM_Gw_current_OS */

  status = om$get_objid_at_index(osnumaddr=&osn,
			          objid =my_id,
                                  p_chanselect = &AS_to_comp,
                                  index=0,
                                  objidaddr=&go_l);
  if(!(status&1)) return(status);
  status = om$get_classid(osnum = osn,objid =go_l ,
		  	   p_classid = &go_classid);
  as$status(action = RET_STATUS);
  if((om$is_ancestry_valid(subclassid = go_classid,
                      superclassid = OPP_ACpretgo_class_id)==OM_S_SUCCESS))
      {
      status = om$send(msg = message ACpretgo.ACgive_info(go),
	targetid = go_l );
      as$status();
      }
   else
      {
      go->objid=go_l;
      go->osnum = osn;
      }

  /* context now */

  if(mat_type != NULL)  *mat_type = MAIDMX;
  if(matrix != NULL)  MAidmx(&msg,matrix);
  return(OM_S_SUCCESS);
}

/*
   provides a print root method for points, lines, circles, arcs of circle
   planes, local coordinate system and parameters
*/

method NDprint_root ( struct GRmd_env *md_env; FILE *stream)
{

 as$printer_print_root();
 return(OM_S_SUCCESS);
}

method NDcopy_graph(IGRlong *msg;IGRint cp_type;
                 struct GRmd_env *fr_env,*to_env;
                 struct NDcp_list *copied_element; int copied_size;
                 int index)
{
 long status,loc_status,loc_msg;
 short mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
 short action;
 
 if(   (copied_element[index].position & ND_EXTERN)
    && (copied_element[index].clone == NULL_OBJID)) action = 0;
 else action = 1;

 status = om$send(msg = message NDnodein.NDcopy_graph(msg,cp_type,fr_env,
				to_env,copied_element,copied_size,index),
		  targetid = my_id,
		  mode = OM_e_wrt_message);

 if(status&1 && !action)
 {
   /* The object could be  copied to root : copied_element[index].clone
      is then an ASsource object. The change porpertied should then be done
      on the ASsource.listeners channel 
   */
   loc_status = om$send(msg   = message GRvg.GRchgprops(&loc_msg,&action,&mask),
      senderid = copied_element[index].clone,
      targetos = to_env->md_id.osnum,
      p_chanselect = &AS_to_comp);

   if(!(loc_status&1))
   loc_status = om$send(msg   = message GRvg.GRchgprops(&loc_msg,&action,&mask),
      senderid = copied_element[index].clone,
      targetos = to_env->md_id.osnum,
      p_chanselect = &AS_listeners);
  }


 return status;
}

method NDrm_assoc(long *msg; struct GRid *new_obj; struct GRmd_env *md_env)
{
 long status;
 char my_state;
 short set,props;

/* Init */

 set = 0;
 props = GR_RIGID_RELATIONSHIP;


 status = om$send(msg = message NDnode.NDget_state(&my_state),
		  targetid = my_id);

 if(my_state & ND_DEL_NO_CH)
  {
    new_obj->objid = NULL_OBJID;
    if(md_env->md_id.objid != NULL_OBJID)
     {
      status = om$send(msg = message GRgraphics.GRremwrng(msg,md_env),
		       p_chanselect = &AS_to_comp);
      as$status();
     }
    status = om$send(msg = message GRgraphics.GRdelete(msg,md_env),
		     p_chanselect = &AS_to_comp);
    as$status();
  }
 
 else
  {
   status = om$get_objid_at_index(osnumaddr=&new_obj->osnum,
                                  objid =my_id,
                                  p_chanselect = &AS_to_comp,
                                  index=0,
                                  objidaddr=&new_obj->objid);

   status = om$send(msg = message GRgraphics.GRchgprops(msg,&set,&props),
		    p_chanselect = &AS_to_comp);
   as$status();

   status = om$send(msg = message NDnode.NDrm_assoc(msg,new_obj,md_env),
                    p_chanselect = &AS_to_comp);
  }
  status = om$send(msg = message Root.delete(1),
                   targetid = my_id);
  return status;
}
end implementation ASnode;
