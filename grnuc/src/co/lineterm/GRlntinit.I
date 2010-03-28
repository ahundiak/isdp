/* #######################    APOGEE COMPILED   ######################## */

class implementation  GRlnterm;
#include "coimport.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "codebug.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "msdef.h"
#include "dp.h"
#include "maerr.h"
#include "exdef.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "msdef.h"
#include "lcdef.h"
#include "grownerdef.h"
#include "godef.h"
#include "grerr.h"
#include "grgsdef.h"

#define LAST     0
#define START    1
from IGEgragad   import DPinrot;
from GRnotify    import GRntfyconn;
from GRvg        import GRgetsize;
from GRvg        import GRgetgeom;
from GRconnector import GRflexconn;
from GRcurve     import GRptextend;
from GRcurve     import GRdisextend; 
from GRgraphics  import GRxform;
from GRgraphics  import GRcopy;

method GRlnterminit( IGRlong         *msg;     
		    struct GRid     *element;
		    struct GRevent  *accept_event; 
		    struct GRmd_env *ModuleInfo;
		    struct GRid     *cell_id;)
{
  
  IGRlong                      status;   
  struct GRactive_symbol_def   active_cell;
  struct GRid                  cell_header;
  IGRlong                      size;
  struct IGRbsp_curve         *bspline_ptr = NULL;   
  IGRchar                     *char_ptr = NULL;   
  IGRdouble                    dist_from_end;
  IGRdouble                    dist_from_start;
  IGRdouble                   *end_point;
  IGRdouble                   *start_point;
  IGRdouble                    accept_point[3];
  IGRdouble                    angle[3];
  IGRdouble                    scale[3];
  IGRmatrix                    rot_matrix;
  struct GRid                  my_grid;
  struct GRid                  view_grid;
  OM_S_CHANSELECT              chansel;
  IGRlong                      index = 0;
  IGRlong                      flag = 1;
  IGRpoint                     attach_pt;
  IGRpoint                     ref_pt;
  struct GRid                  NULL_GRID;  
  IGRlong                      relindex2;	
  IGRint                       tag_index = OM_K_MAXINT;
  IGRboolean                   tag_flag = FALSE;
  GRspacenum                   tagged_os;
  IGRlong                      ret_size;
  IGRlong                      num_bytes;
  struct GRdpb_scale           dpb_scale;
  struct var_list              list[2];
  IGRshort                     act_level;
  IGRlong                      bytes_ret;
  IGRlong                      error;
  struct GRevent               ref_event;
  IGRpoint                     axis_point,isect_point,sweep_point;
  IGRint		       i,k;

  NULL_GRID.objid = NULL_OBJID;
  NULL_GRID.osnum = 0;
  
  relindex2 = 0;
  me->attach_event = *accept_event;
  ref_event = *accept_event;
  accept_point[0] = accept_event->event.button.x;
  accept_point[1] = accept_event->event.button.y;
  accept_point[2] = accept_event->event.button.z;
  
  my_grid.osnum = OM_Gw_current_OS;
  my_grid.objid = my_id;
  
  chansel.type = OM_e_name;
  chansel.u_sel.name = "GRlnterm.to_notify";
  
  status = om$send (msg = message GRnotify.GRntfyconn(msg,
						      &my_grid, 
						      &chansel,
						      &tag_index,
						      &tag_flag,
						      &tagged_os),
		    targetid = element->objid,
		    targetos = element->osnum);   
  
  status = om$send( msg = message GRvg.GRgetsize(msg,
					     &ModuleInfo->md_env.matrix_type,
						 ModuleInfo->md_env.matrix,
						 &size ),
		   targetid = element->objid,
		   targetos = element->osnum);
  _m_check2q( status, *msg );
  
  char_ptr = om$malloc( size = size );
  
  status = om$send(msg = message GRvg.GRgetgeom(msg,
					      &ModuleInfo->md_env.matrix_type,
						ModuleInfo->md_env.matrix,
						char_ptr ),
		   targetid = element->objid,
		   targetos = element->osnum);
  _m_check2q( status, *msg );  
  bspline_ptr = (struct IGRbsp_curve *)char_ptr;
/* *** FIX FOR TR 90N1447 *** */
  if ( bspline_ptr->rational )
  {
    k = 0;
    for ( i = 0; i < bspline_ptr->num_poles ; ++i )
    {
	bspline_ptr->poles[k] = bspline_ptr->poles[k]/bspline_ptr->weights[i]; 
	bspline_ptr->poles[k+1] = bspline_ptr->poles[k+1]/bspline_ptr->weights[i];
	bspline_ptr->poles[k+2] = bspline_ptr->poles[k+2]/bspline_ptr->weights[i];
        k = (i+1) * 3;
     }
   }
/* *** END OF FIX *** */
  
  end_point = &bspline_ptr->poles[(bspline_ptr->num_poles*3)-3];  
  start_point = &bspline_ptr->poles[0];  
  
  MA2ptdis(msg,
	   end_point,
	   accept_point,     
	   &dist_from_end );
  _m_checkq(*msg );
  
  MA2ptdis(msg,
	   start_point,
	   accept_point,     
	   &dist_from_start );
  _m_checkq(*msg );

  if(dist_from_start > dist_from_end)
    {
      attach_pt[0] = end_point[0];
      attach_pt[1] = end_point[1];
      attach_pt[2] = end_point[2];
      ref_pt[0] = bspline_ptr->poles[(bspline_ptr->num_poles*3)-6];  
      ref_pt[1] = bspline_ptr->poles[(bspline_ptr->num_poles*3)-5];  
      ref_pt[2] = bspline_ptr->poles[(bspline_ptr->num_poles*3)-4];  
      me->end_of_curve = LAST;
    }
  else
    {
      attach_pt[0] = start_point[0];
      attach_pt[1] = start_point[1];
      attach_pt[2] = start_point[2];
      ref_pt[0] = bspline_ptr->poles[3];  
      ref_pt[1] = bspline_ptr->poles[4];  
      ref_pt[2] = bspline_ptr->poles[5];  
      me->end_of_curve = START;     
    }
  
  list[0].var = WLD_TO_VIEW;
  list[0].var_ptr = (IGRchar *)rot_matrix;
  list[0].num_bytes = sizeof(IGRdouble) * 16;
  list[0].bytes_returned = &bytes_ret;
  
  list[1].var = END_PARAM;
  list[1].var_ptr = NULL;
  list[1].num_bytes = 0;
  list[1].bytes_returned = NULL;
  status = dp$inq_set_gragad(msg = msg,
			     osnum = accept_event->event.button.osnum,
			     gragad_objid = accept_event->event.button.objid,
			     which_error = &error,
			     var_list = list);
  _m_check2q( status, *msg );
  
  me->attach_event.event.button.x = attach_pt[0];
  me->attach_event.event.button.y = attach_pt[1];
  me->attach_event.event.button.z = attach_pt[2];

  ref_event.event.button.x = ref_pt[0];
  ref_event.event.button.y = ref_pt[1];
  ref_event.event.button.z = ref_pt[2];
  
  view_grid.objid = accept_event->event.button.objid;
  view_grid.osnum = accept_event->event.button.osnum;

  CO_ni_world_to_view(msg,&me->attach_event,&view_grid,sweep_point);
  CO_ni_world_to_view(msg,&ref_event,&view_grid,isect_point);


  axis_point[0] = isect_point[0] + 1.0;  /* X */
  axis_point[1] = isect_point[1];        /* Y */
  axis_point[2] = isect_point[2];        /* Z */

  MAang3pt(msg,axis_point,isect_point,sweep_point,angle);
  
  status = gr$symget_active_symbol (msg = msg, 
				    act_symbol_def  = &active_cell);
  _m_check2q( status, *msg);
  
  cell_header.objid = active_cell.objid;
  cell_header.osnum = active_cell.symbol_env.md_id.osnum,
  num_bytes = sizeof(struct GRdpb_scale);
  gr$get_active_scale(msg =     msg,
		      sizbuf = &num_bytes,
		      buffer = &dpb_scale,
		      nret =   &ret_size);
  
  scale[0] = dpb_scale.Active_xscale;
  scale[1] = dpb_scale.Active_yscale;
  scale[2] = dpb_scale.Active_zscale;
  
  num_bytes = sizeof(IGRshort);

  gr$get_active_level (
                msg    =  msg,
                sizbuf = &num_bytes,
                buffer = &act_level,
                nret   = &ret_size );
  _m_checkq(*msg);   


  status = gr$sym_sm_place ( msg        = msg, 
			     origin     = attach_pt,
			     angle      = &angle[0],
			     scale      = scale,
                             level      = act_level,
			     rot_matrix = rot_matrix,
			     symbol_env = &active_cell.symbol_env,
			     target_env = ModuleInfo,
			     sdh_id     = &cell_header,
			     sm_id      = cell_id);
  _m_check2q( status, *msg );
  
  status = om$send(msg = message GRconnector.GRflexconn(msg,
							&flag,
							&my_grid,
							&index,
							&index ),
		   targetid = cell_id->objid,
		   targetos = cell_id->osnum );
  
 quit:
  if(bspline_ptr) om$dealloc( ptr = bspline_ptr );
  return(status);
}

method GRnotifylis (IGRlong      *msg; 
		    IGRlong      *OMmsg; 
		    IGRlong      *mask;
		    OM_S_MESSAGE *graphics_msg)
{
  IGRlong                        status;
  IGRlong                        rc;
  struct GRcurve_GRptextend_Msg  *ptextend_msg;
  struct GRcurve_GRdisextend_Msg *disextend_msg;
  struct GRgraphics_GRcopy_Msg  *copy_msg;
  struct GRgraphics_GRxform_Msg *xform_msg;
  struct GRmd_env               *loc_env;
  IGRdouble                      loc_point[3]; 
  IGRdouble                      atch_point[3];
  IGRlong                        NumberToTrans;
  IGRboolean                     b_status; 
  IGRdouble                      delta[3];
  IGRdouble                      dist_from_end;
  IGRdouble                      dist_from_start;
  IGRshort                       current_end;
  IGRshort                       matrix_type;
  IGRmatrix                      t_matrix;
  GRobjid                        newobjid;
  OM_S_CHANSELECT                chansel;
  struct GRid                    cell_id;
  struct GRid                    line_term;
  struct GRid                    go_element;
  IGRlong                        size;
  struct IGRbsp_curve           *bspline_ptr = NULL;   
  IGRlong                        index = 0;
  IGRint                         tag_index = OM_K_MAXINT;
  IGRboolean                     tag_flag = FALSE;
  GRspacenum                     tagged_os;
  IGRlong                        flag = 1;
  
  chansel.type = OM_e_addr;
  chansel.u_sel.addr = &me->to_components;
  
  switch (*mask)
    {
    case GR_COPIED: 
      copy_msg = (struct GRgraphics_GRcopy_Msg *) graphics_msg->p_arglist;
      
      /* copy cell */
      status = om$send(msg = message GRgraphics.GRcopy(&rc,
						       copy_msg->obj_dsenv,
						       copy_msg->obj_dsenv,
						       &cell_id.objid),
		       p_chanselect = &chansel);
      cell_id.osnum = copy_msg->new_dsenv->md_id.osnum;
      
      
      /* copy line term object */
      line_term.osnum = copy_msg->new_dsenv->md_id.osnum;
      status = om$construct_and_copy(objid = my_id,
				     obj_osnum = line_term.osnum,
				     p_objid = &line_term.objid);
      
      chansel.type = OM_e_name;
      chansel.u_sel.name = "GRlnterm.to_notify";	  
      status = om$send (msg = message GRnotify.GRntfyconn(&rc,
							  &line_term, 
							  &chansel,
							  &tag_index,
							  &tag_flag,
							  &tagged_os),
			targetid = *(copy_msg->newobjid),
			targetos = copy_msg->new_dsenv->md_id.osnum);   
      
      status = om$send(msg = message GRconnector.GRflexconn(&rc,
							    &flag,
							    &line_term,
							    &index,
							    &index ),
		       targetid = cell_id.objid,
		       targetos = cell_id.osnum );
      
      break;
      
    case GR_GEOM_XFORMED:
      xform_msg = (struct GRgraphics_GRxform_Msg *) graphics_msg->p_arglist;
      chansel.type = OM_e_addr;
      chansel.u_sel.addr = &me->to_components;
      newobjid = *(xform_msg->newobjid);
      status = om$send(msg = graphics_msg, p_chanselect = &chansel);
      *(xform_msg->newobjid) = newobjid;

      atch_point[0] = me->attach_event.event.button.x;
      atch_point[1] = me->attach_event.event.button.y;
      atch_point[2] = me->attach_event.event.button.z;
      NumberToTrans = 1;
      b_status = MAptsxform(
                 msg,
                &NumberToTrans,
                 xform_msg->matrix,
                 atch_point,
                 atch_point );
      _m_check_boolq(b_status);

      me->attach_event.event.button.x = atch_point[0];
      me->attach_event.event.button.y = atch_point[1];
      me->attach_event.event.button.z = atch_point[2];
      
      break;
      
    case GR_DISPLAYED:
      status = om$send(msg = graphics_msg, p_chanselect = &chansel);
      break;
      
    case GR_GEOM_MODIFIED:
#if defined(__STDC__) || defined(__cplusplus)
      if((graphics_msg->select.FuncIndex == GRcurve_OPP_GRptextend_method_index)||
         (graphics_msg->select.FuncIndex == GRcurve_OPP_GRdisextend_method_index))
#else
      if((graphics_msg->select.FuncIndex == GRcurve$GRptextend_method_index)||
         (graphics_msg->select.FuncIndex == GRcurve$GRdisextend_method_index))
#endif
	{

#if defined(__STDC__) || defined(__cplusplus)
      if(graphics_msg->select.FuncIndex == GRcurve_OPP_GRptextend_method_index)
#else
      if(graphics_msg->select.FuncIndex == GRcurve$GRptextend_method_index)
#endif
	{  ptextend_msg = (struct GRcurve_GRptextend_Msg *)
	                graphics_msg->p_arglist;
           loc_env   = (struct GRmd_env *) ptextend_msg->env;
           loc_point[0] = ptextend_msg->new_end[0]; 
           loc_point[1] = ptextend_msg->new_end[1]; 
           loc_point[2] = ptextend_msg->new_end[2]; 
        }       
      else
	{  disextend_msg = (struct GRcurve_GRdisextend_Msg *)
	                graphics_msg->p_arglist;
 	   loc_env   = (struct GRmd_env *) disextend_msg->env;
           loc_point[0] = disextend_msg->new_end[0];
           loc_point[1] = disextend_msg->new_end[1];
           loc_point[2] = disextend_msg->new_end[2];
        } 

	  chansel.type = OM_e_addr;  
	  chansel.u_sel.addr = &me->to_notify;	  
	  om$get_objid_at_index (objid = my_id, 
				 p_chanselect = &chansel,
				 index = 0, 
				 objidaddr = &go_element.objid, 
				 osnumaddr = &go_element.osnum);
	  
	  status = om$send( msg = message GRvg.GRgetsize(msg,
					 &loc_env->md_env.matrix_type,
					 loc_env->md_env.matrix,
							 &size ),
			   targetid = go_element.objid,
			   targetos = go_element.osnum);
	  
	  bspline_ptr = (struct IGRbsp_curve *)om$malloc( size = size );
	  
	  status = om$send(msg = message GRvg.GRgetgeom(msg,
					&loc_env->md_env.matrix_type,
						loc_env->md_env.matrix,
						(IGRchar *)bspline_ptr ),
			   targetid = go_element.objid,
			   targetos = go_element.osnum);
	  
	  MA2ptdis(msg,
		   &bspline_ptr->poles[(bspline_ptr->num_poles*3)-3],
		   loc_point,
		   &dist_from_end );
	  
	  MA2ptdis(msg,
		   &bspline_ptr->poles[0],
		   loc_point,
		   &dist_from_start );
	  
	  current_end = (dist_from_start > dist_from_end)?LAST:START;
	  
	  if(current_end == me->end_of_curve)
	    {
	      if(me->end_of_curve == START)
		{
		  delta[0] = bspline_ptr->poles[0] - 
		    me->attach_event.event.button.x;
		  delta[1] = bspline_ptr->poles[1] - 
		    me->attach_event.event.button.y;
		  delta[2] = bspline_ptr->poles[2] - 
		    me->attach_event.event.button.z;
		  
		  me->attach_event.event.button.x = bspline_ptr->poles[0];  
		  me->attach_event.event.button.y = bspline_ptr->poles[1];  
		  me->attach_event.event.button.z = bspline_ptr->poles[2];  
		}
	      else
		{
		  delta[0] = bspline_ptr->poles[(bspline_ptr->num_poles*3)-3]- 
		    me->attach_event.event.button.x;
		  delta[1] = bspline_ptr->poles[(bspline_ptr->num_poles*3)-2]- 
		    me->attach_event.event.button.y;
		  delta[2] = bspline_ptr->poles[(bspline_ptr->num_poles*3)-1]- 
		    me->attach_event.event.button.z;
		  
		  me->attach_event.event.button.x = 
		    bspline_ptr->poles[(bspline_ptr->num_poles*3)-3];  
		  me->attach_event.event.button.y = 
		    bspline_ptr->poles[(bspline_ptr->num_poles*3)-2];  
		  me->attach_event.event.button.z = 
		    bspline_ptr->poles[(bspline_ptr->num_poles*3)-1];  
		}

	      MAtrlmx(msg,delta,t_matrix);
	      MAtypemx(msg,t_matrix,&matrix_type);
	      
	      chansel.u_sel.addr = &me->to_components;
	      status = om$send(msg = message GRgraphics.GRxform(&rc,
							         loc_env,
								&matrix_type,
								 t_matrix,
								&newobjid),
			       p_chanselect = &chansel);
	    }
	}
      if(bspline_ptr) om$dealloc( ptr = bspline_ptr );
      break;
      

    /* BEGIN TR FIX 91N0194 */

    case GR_ATTR_MODIFIED:
      status = om$send(msg = graphics_msg, p_chanselect = &chansel);
      break;

    /* END TR FIX 91N0194 */



    case GR_DELETED:
      status = om$send(msg = graphics_msg, p_chanselect = &chansel);
      status = om$send(msg = message Root.delete(FALSE), targetid = my_id);
      break;
    }
  
quit:
  return(OM_S_SUCCESS);
}
/*************************************************************************
  THE FOLLOWING IS A KLUDGE UNTIL WE CAN MOVE TO THE GRAPH MANAGER.
  THIS IS TO SOLVE ONLY THE PROBLEM WITH DOUBLE X-FORMS WHEN
  PROCESSING FENCE CONTENTS.  (BMR)
  ***************************************************************************/
/*\
  Name
  GRlocate_owner
  
  Description
  This method performs the locate operation for owners.  This method
  is responsible for locating the owner and the component that sent 
  this message.
  
  *msg           IGRlong              completion code
  *cvl           struct GRlc_cvl      Module and action handler info
  *path          struct GRlc_path     The locate path of objects
  *path_position  IGRint              Position of calling object in
                                      the path structure.
  
  Notes
   The msg should be initialized to GR_I_NO_RESPONSE.  Only
   legitimate owners can change the message setting.

Return Values
   MSSUCC            -  if successful completion 
   MSFAIL            -  if error occurred
   GR_I_NO_RESPONSE  -  If no legitimate owners.

History 

\*/

method GRlocate_owner (IGRlong *msg; struct GRlc_cvl *cvl;
                       struct GRlc_path *path; IGRint *path_position)
{
    IGRlong           status;
    status = OM_S_SUCCESS;

    /*
     *  See if we are in a fence locate.
     */
    *msg = GR_I_NO_RESPONSE;
    if ( (cvl->attributes.type != GR_cv_loc) &&
	(cvl->attributes.type != GR_rp_loc) )  

      {
	/*
	 *  Pass on to the next object.
	 */
	status = GRsend_to_next_sibling ( 
			 path[*path_position].lc_info.located_obj.osnum,
			 path[*path_position].lc_info.located_obj.objid,
	 	         OM_Gw_current_OS, 
			 my_id, 
			 message GRcmpowner.GRlocate_owner (msg, 
							    cvl, 
							    path, 
							    path_position) );
      }
    else
      {
	*msg = MSSUCC;
      }
   return (status);
}

end implementation GRlnterm;




