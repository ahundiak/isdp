class implementation ASnode;
/*
   Ch    dec 87 :  update for the 1.1 release

   This is the implementation file of the class ASnode and gather only the
   overrided method of GRvg.
*/


#include "AS_status.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "nddef.h"
#include "asbox.h"


#define AS_DEBUG 1

method GRclipto(IGRlong *msg; IGRchar *classname)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRcoplanar(IGRlong *msg; IGRshort *matrix_type;
 			   IGRmatrix matrix; IGRshort *num_objects;
 			   GRobjid *objid_ids; IGRdouble *tolerance; 
 			   struct IGRplane *plane)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}
 
method GRdetplane(IGRlong *msg; IGRshort *matrix_type;
			   IGRmatrix matrix; struct IGRplane *plane)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRgetexgeom(IGRlong *msg; IGRshort *matrix_type;
			    IGRmatrix matrix; IGRchar *geometry)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRgetexsize(IGRlong *msg; IGRshort *mx_type;
			    IGRmatrix matrix; IGRlong *size)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRinplane(IGRlong *msg; IGRshort *matrix_type;
			  IGRmatrix matrix; struct IGRplane *plane; 
			  IGRdouble *tolerance; IGRshort *rel)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRkeypoint(IGRlong *msg; IGRshort *matrix_type;
			   IGRmatrix matrix; struct IGRline *boreline; 
			   IGRpoint keypoint; struct GRparms *key_parm)
{
IGRint status;
struct GRid my_grid,null_grid,modifier;
char obj_state;

status = om$send(msg = message NDnode.NDget_state(&obj_state),
		 targetid = my_id);
if(status&1 && obj_state&ND_DIS_BY_CH) 
  {
   my_grid.objid = my_id;
   my_grid.osnum = OM_Gw_current_OS;
   null_grid.objid = NULL_OBJID;
   ASfind_modifier(my_grid,null_grid,&modifier);
   if(!IF_NULL_OBJID(modifier.objid))
     {status = om$send(msg = OPPmargs,
	      	       targetid = modifier.objid);
      return(status);
     }
  }
status = om$send(msg = message GRowner.GRkeypoint(msg, matrix_type, matrix,
					 	  boreline, keypoint, key_parm),
		 mode = OM_e_wrt_message,
		 targetid = my_id);
return(status);
}

method GRputattr(IGRlong *msg; IGRchar *attr)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRchgprops(IGRlong *msg; IGRshort *flag; IGRshort *props)
{
IGRint status;
IGRshort loc_props,loc_flag;

loc_props = *props&GRFILLED_DISPLAY;
if(loc_props)
  { /*| change filled display property */
    if(*flag)  loc_flag = 1;   /* change or replace */
    else       loc_flag = 0;   /* remove */
    status = om$send(msg = message GRgraphics.GRchgprops
					(msg,&loc_flag,&loc_props),
		     p_chanselect = &AS_to_comp);
    as$status();
  }


status = om$send(msg = message GRowner.GRchgprops(msg,flag,props),
		 targetid = my_id,
		 mode = OM_e_wrt_message);
return(status);
}

method GRdynmod(IGRlong *msg; IGRshort *mat_type;
			 IGRmatrix matrix; struct GRparms *modpt;
		         IGRpoint point; enum GRdyn_flag *action; 
			 IGRchar *buff; IGRboolean (*func)())
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method GRchgcolor(IGRlong *msg;IGRuint *rgb_value;
		  IGRushort *color)
{
IGRint status;
IGRint ASredirect_msg_to_mod();
char obj_state;


status = ASredirect_msg(OPPmargs,&me->to_components,my_id);

status = om$send(msg = message NDnode.NDget_state(&obj_state),
		 targetid = my_id);
if(status&1 && obj_state&ND_DIS_BY_CH) 
status = ASredirect_msg_to_mod(OPPmargs,my_id,OM_Gw_current_OS);

return(OM_S_SUCCESS);
}


method GRchgdp(IGRlong *msg; struct IGRdisplay *dp_info)
{
IGRint ASredirect_msg_to_mod();
IGRint status;
char obj_state;

/*"chgdp de %d\n",my_id */

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);

status = om$send(msg = message NDnode.NDget_state(&obj_state),
		 targetid = my_id);
if(status&1 && obj_state&ND_DIS_BY_CH) 
status = ASredirect_msg_to_mod(OPPmargs,my_id,OM_Gw_current_OS);

/*"status %d msg %d\n",status,*msg */

return(OM_S_SUCCESS);
}


method GRchglevel(IGRlong *msg; IGRshort *level)
{
IGRint status;
char obj_state;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);

status = om$send(msg = message NDnode.NDget_state(&obj_state),
		 targetid = my_id);

if(status&1 && obj_state&ND_DIS_BY_CH) 
status = ASredirect_msg_to_mod(OPPmargs,my_id,OM_Gw_current_OS);

return(OM_S_SUCCESS);
}


method GRchgstyle(IGRlong *msg; IGRuchar *style)
{
IGRint status;
char obj_state;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);

status = om$send(msg = message NDnode.NDget_state(&obj_state),
		 targetid = my_id);

if(status&1 && obj_state&ND_DIS_BY_CH) 
status = ASredirect_msg_to_mod(OPPmargs,my_id,OM_Gw_current_OS);

return(OM_S_SUCCESS);
}


method GRchgweight(IGRlong *msg; IGRuchar *weight)
{
IGRint status;
char obj_state;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);


status = om$send(msg = message NDnode.NDget_state(&obj_state),
		 targetid = my_id);

if(status&1 && obj_state&ND_DIS_BY_CH) 
status = ASredirect_msg_to_mod(OPPmargs,my_id,OM_Gw_current_OS);

return(OM_S_SUCCESS);
}


method GRfragment(IGRlong *msg; struct GRmd_env *env; 
		   struct GRid *complex; struct GRmd_env *new_env)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method EMpratpt (IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
                  IGRpoint wpoint_xyz; IGRdouble point_parametric[]; 
                  IGRint *num_parameters)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method EMptatpr (IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
                  IGRdouble point_parametric[]; IGRint num_parameters;
                  IGRpoint wpoint_xyz)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method EMintplane(struct GRvg_construct *construct_list;
                   struct IGRplane *plane;
                   struct GRlc_info *located_object;
                   int *number_of_intersections;
                   struct GRid **pointer_to_resulting_intersections;
                   int *msg)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method EMgetpoles (IGRlong *msg; IGRshort *mat_type; IGRmatrix mat;
                    IGRlong *frominx; IGRlong *offset; IGRdouble *buff;
                    IGRlong buff_size; IGRlong *ret_num; IGRboolean *is_reg)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


IGRint ASredirect_msg_to_mod( mess, send_id, send_os )
OM_S_MESSAGE *mess;
OM_S_OBJID    send_id;
GRspacenum    send_os;
{
 IGRint status;
 struct GRid my_grid, null_grid, modifier;
 extern OM_S_CHANSELECT AS_to_comp;

 my_grid.objid = send_id;
 my_grid.osnum = send_os;
 null_grid.objid = NULL_OBJID;

 ASfind_modifier( my_grid, null_grid, &modifier );
 if( !IF_NULL_OBJID(modifier.objid))
  {
   status = om$send( msg = mess, 
   		     senderid = modifier.objid, p_chanselect = &AS_to_comp );
   return(status);
  }
 return(OM_S_SUCCESS);
}

method GRmodify(IGRlong *msg; struct GRmd_env *md_env;
	        struct GRparms *parms; 
		IGRpoint point; struct IGRline *boreline;
		GRobjid *new_objid)
{
 return(OM_S_SUCCESS);
}

		    
end implementation ASnode;
	 
