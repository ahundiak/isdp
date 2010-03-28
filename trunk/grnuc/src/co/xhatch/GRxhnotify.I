/* #######################    APOGEE COMPILED   ######################## */

class implementation  GRcoxhatch;

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
#include "igrmacros.h"
#include "comiscmac.h"
#include "msdef.h"
#include "dp.h"
#include "maerr.h"
#include "exdef.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"
#include "grerr.h"

from GRnotify    import GRntfyconn;
from GRcurve     import GRsplit;
#ifndef IDRAW
from GRvg        import GRfragment;
from GRconic     import GRaxmodify;
#endif /* IDRAW */
from GRlinear    import GRmoveseg;
from GRcurve     import GRinsvertex;
from GRcurve     import GRdelvertex;
from GRvg        import GRmodify;
from GRlinear    import GRremovepts;
from GRcurve     import GR2ptpartdel;
from GRcurve     import GR3ptpartdel;
from GRconic     import GRputarc;
from GRlinear    import GRputpolyline;
from GRowner     import GRget_components;
from GRowner     import GRget_number_components;
#define   _xh_check_win()\
{\
  status = \
  om$is_objid_valid(osnum=me->window_grid.osnum, objid=me->window_grid.objid);\
  if(status == OM_E_NOSUCHOBJ ||  status == OM_E_NO_OBJECT_SPACE)\
    {\
      me->associative_flag = FALSE;\
      return(OM_S_SUCCESS);\
    }\
}\



method GRnotifylis (IGRlong      *msg; 
		    IGRlong      *OMmsg; 
		    IGRlong      *mask;
                    OM_S_MESSAGE *graphics_msg)
{
  IGRlong                          status;
  struct GRgraphics_GRxform_Msg    *xform_msg;
  struct GRcurve_GRinsvertex_Msg   *insert_msg;
  struct GRcurve_GRdelvertex_Msg   *delvert_msg;
  struct GRlinear_GRmoveseg_Msg    *moveseg_msg;
  struct GRlinear_GRremovepts_Msg  *rmpts_msg;
  struct GRvg_GRmodify_Msg         *modify_msg;
#ifndef IDRAW
  struct GRconic_GRaxmodify_Msg    *axmodify_msg;
#endif 
  struct GRgraphics_GRdelete_Msg   *delete_msg;
  struct GRgraphics_GRdisplay_Msg  *disp_msg;
  struct GRconic_GRputarc_Msg      *putarc_msg;
  struct GRlinear_GRputpolyline_Msg       *putpolyline_msg;
  OM_S_CHANSELECT                  chansel;
  OM_S_CHANSELECT                  not_chansel;
  struct GRid                      xh_gg;
  IGRlong                          index = 0;
  struct GRid                      go_element;  
  struct GRid                      *objects = NULL;  
  struct GRmd_env                  *env=0;
  struct GRmd_env                  mod_env;
  IGRint                           count=0;
  IGRlong                          i,j;
  enum GRdpmode                    dis_mode = GRbd;
  OM_S_OBJECT_LINKAGE             *notify_list = NULL;
  IGRuint                          notify_count=0;

  extern IGRboolean                dynamics_in_progress;
  
  
  if( (!me->associative_flag) || dynamics_in_progress)
    {
      return (1);
    }

  switch (*mask)
    {
    case GR_RTREE_MANIPULATION:
#if defined(__STDC__) || defined(__cplusplus)
      if(graphics_msg->select.FuncIndex == 
                                       GRgraphics_OPP_GRaddwrng_method_index)
#else
      if(graphics_msg->select.FuncIndex == GRgraphics$GRaddwrng_method_index)
#endif
         {
            chansel.type = OM_e_addr;
            chansel.u_sel.addr = &me->to_components;
				      
            status = om$send(msg = graphics_msg,
                             p_chanselect = &chansel);
             break;
          }
									   

    case GR_GEOM_POSTED:
      _xh_check_win();
#if defined(__STDC__) || defined(__cplusplus)
      if(graphics_msg->select.FuncIndex == GRconic_OPP_GRputarc_method_index)
#else
      if(graphics_msg->select.FuncIndex == GRconic$GRputarc_method_index)
#endif
	{
	  putarc_msg = (struct GRconic_GRputarc_Msg *)graphics_msg->p_arglist;
	  status = om$send(msg = message GRcoxhatch.GRxhget_gg(msg,
							       &xh_gg),
			   targetid = my_id);
	  
	  status = om$send(msg = message GRcoxhatch.GRxhcompute(msg,
                                                         putarc_msg->env,
								&xh_gg),
			   targetid = my_id);
	}

#if defined(__STDC__) || defined(__cplusplus)
      if(graphics_msg->select.FuncIndex ==
                                       GRlinear_OPP_GRputpolyline_method_index)
#else
      if(graphics_msg->select.FuncIndex == GRlinear$GRputpolyline_method_index)
#endif
	{
	  putpolyline_msg = 
            (struct GRlinear_GRputpolyline_Msg *)graphics_msg->p_arglist;

	  status = om$send(msg = message GRcoxhatch.GRxhget_gg(msg,
							       &xh_gg),
			   targetid = my_id);
	  
	  status = om$send(msg = message GRcoxhatch.GRxhcompute(msg,
                                                       putpolyline_msg->env,
								&xh_gg),
			   targetid = my_id);
	}
      break;

    case GR_GEOM_XFORMED:
      _xh_check_win();
      xform_msg = (struct GRgraphics_GRxform_Msg *) graphics_msg->p_arglist;
      status = om$send(msg = message GRcoxhatch.GRxhget_gg(msg,
							   &xh_gg),
                       targetid = my_id);
      
      status = om$send(msg = message GRcoxhatch.GRxhcompute(msg,
                                                            xform_msg->md_env,
							    &xh_gg),


                       targetid = my_id);
      break;

    case GR_DISPLAYED:
      _xh_check_win();
      disp_msg=(struct GRgraphics_GRdisplay_Msg *)graphics_msg->p_arglist; 

      if(*disp_msg->mode == GRbd || *disp_msg->mode == GRbe ||
	 *disp_msg->mode == GRhe || *disp_msg->mode == GRbehe ||
	 *disp_msg->mode == GRbdhd || *disp_msg->mode == GRbeheo ||
	 *disp_msg->mode == GRbehd || *disp_msg->mode == GRhdo ||
	 *disp_msg->mode == GRhhdo || *disp_msg->mode == GRheo ||
         *disp_msg->mode == GRbdhe)
	{
	  chansel.type = OM_e_name;
	  chansel.u_sel.name = "GRcoxhatch.to_notify";	
          status = om$get_channel_count(objid = my_id,
	   			        osnum = sender_os,
				        p_chanselect = &chansel,
				        count = &notify_count);
          
          notify_list = (OM_S_OBJECT_LINKAGE *)om$malloc ( size = 
			    (sizeof(OM_S_OBJECT_LINKAGE)) * notify_count);
          if(notify_list == NULL) return(OM_E_NODYNMEM);
  
          status = om$get_channel_objects(objid = my_id,
	   			          osnum = sender_os,
				          p_chanselect = &chansel,
				          list  =  notify_list,
				          size  =  notify_count,
				          count = &notify_count );

	  chansel.type = OM_e_addr;
	  chansel.u_sel.addr = &me->to_components;
	  status = om$send(msg = message GRowner.GRget_number_components(msg,
                                                 &count), 
			   p_chanselect = &chansel);
          if(count>0 && (status != OM_I_CHAN_EMPTY))
	    {
	      objects = (struct GRid *)om$malloc(size=
						 (sizeof(struct GRid))*count);
	      if(objects == NULL) 
		{
		  if(notify_list) om$dealloc(ptr = notify_list);
		  return(OM_E_NODYNMEM);
		}
	      
	      status = om$send(msg = message GRowner.GRget_components(msg,
								      &mod_env,
								      objects,
								      count,
								      &count,
								      0,
							      OM_K_MAXINT),
			       p_chanselect = &chansel);
	      
	      for(i=0; i<count; i++)
		{
		  for(j=0; j<notify_count; j++)
		    {
		      if( (notify_list[j].S_objid == objects[i].objid) &&
			 (notify_list[j].osnum == objects[i].osnum) )
			{
			  objects[i].objid = NULL_OBJID;
			}
		    }
		  if(objects[i].objid != NULL_OBJID)
		    {
		      status = om$send(msg = graphics_msg, 
				       targetid = objects[i].objid,
				       targetos = objects[i].osnum);
		    }
		}
	    }
	  if(objects) om$dealloc(ptr = objects);
	  if(notify_list) om$dealloc(ptr = notify_list);
	}
      break;

    case GR_GEOM_MODIFIED:
      _xh_check_win();
#if defined(__STDC__) || defined(__cplusplus)
      if(graphics_msg->select.FuncIndex == GRcurve_OPP_GRinsvertex_method_index)
#else
      if(graphics_msg->select.FuncIndex == GRcurve$GRinsvertex_method_index)
#endif
	{
	  insert_msg = (struct GRcurve_GRinsvertex_Msg *) 
	    graphics_msg->p_arglist;
	  env = insert_msg->md_env;	     
	}
      
#if defined(__STDC__) || defined(__cplusplus)
      else if(graphics_msg->select.FuncIndex == 
	      GRcurve_OPP_GRdelvertex_method_index)
#else
      else if(graphics_msg->select.FuncIndex == 
	      GRcurve$GRdelvertex_method_index)
#endif
	{
	  delvert_msg = (struct GRcurve_GRdelvertex_Msg *) 
	    graphics_msg->p_arglist;
	  env = delvert_msg->md_env;	     
	}
      
#if defined(__STDC__) || defined(__cplusplus)
      else if(graphics_msg->select.FuncIndex == 
	      GRlinear_OPP_GRmoveseg_method_index)
#else
      else if(graphics_msg->select.FuncIndex == 
	      GRlinear$GRmoveseg_method_index)
#endif
	{
	  moveseg_msg = (struct GRlinear_GRmoveseg_Msg *) 
	    graphics_msg->p_arglist;
	  env = moveseg_msg->env;	     
	}
      
#if defined(__STDC__) || defined(__cplusplus)
      else if(graphics_msg->select.FuncIndex == 
	      GRlinear_OPP_GRremovepts_method_index)
#else
      else if(graphics_msg->select.FuncIndex == 
	      GRlinear$GRremovepts_method_index)
#endif
	{
	  rmpts_msg = (struct GRlinear_GRremovepts_Msg *) 
	    graphics_msg->p_arglist;
	  env = rmpts_msg->env;	     
	}
      
#ifndef IDRAW
#if defined(__STDC__) || defined(__cplusplus)
      else if(graphics_msg->select.FuncIndex == 
	      GRconic_OPP_GRaxmodify_method_index)
#else
      else if(graphics_msg->select.FuncIndex == 
	      GRconic$GRaxmodify_method_index)
#endif
	{
	  axmodify_msg = (struct GRconic_GRaxmodify_Msg *) 
            graphics_msg->p_arglist;
	  env = axmodify_msg->md_env;	     
	}
#endif
#if defined(__STDC__) || defined(__cplusplus)
      else if(graphics_msg->select.FuncIndex == 
	      GRvg_OPP_GRmodify_method_index)
#else
      else if(graphics_msg->select.FuncIndex == 
	      GRvg$GRmodify_method_index)
#endif
	{
	  modify_msg = (struct GRvg_GRmodify_Msg *) graphics_msg->p_arglist;
	  env = modify_msg->md_env;	     
	  
	}
    
#if defined(__STDC__) || defined(__cplusplus)
      else if(graphics_msg->select.FuncIndex == 
                                       GRcurve_OPP_GRsplit_method_index ||
#ifndef IDRAW
	      graphics_msg->select.FuncIndex ==
                                       GRvg_OPP_GRfragment_method_index ||
#endif /* IDRAW */
	      graphics_msg->select.FuncIndex == 
	                               GRcurve_OPP_GR2ptpartdel_method_index ||
	      graphics_msg->select.FuncIndex == 
         	                       GRcurve_OPP_GR3ptpartdel_method_index )
#else
      else if(graphics_msg->select.FuncIndex == GRcurve$GRsplit_method_index ||
#ifndef IDRAW
	      graphics_msg->select.FuncIndex == GRvg$GRfragment_method_index ||
#endif /* IDRAW */
	      graphics_msg->select.FuncIndex == 
	         GRcurve$GR2ptpartdel_method_index ||
	      graphics_msg->select.FuncIndex == 
	         GRcurve$GR3ptpartdel_method_index )
#endif
	/* 
	  add test so we will delete only if wireframe.
	  recompute on holes
	  */
	{
          status = om$send(msg = message Root.delete(FALSE), targetid = my_id);
	}
      
    if(env)
	{
	  status = om$send(msg = message GRcoxhatch.GRxhget_gg(msg,
							       &xh_gg),
			   targetid = my_id);
	  
	  status = om$send(msg = message GRcoxhatch.GRxhcompute(msg,
								env,
								&xh_gg),
			   targetid = my_id);
	}
    break;
      
    case GR_DELETED:    
      chansel.type = OM_e_name;
      chansel.u_sel.name = "GRcoxhatch.to_notify";	
      status = om$get_objid_at_index(objid = my_id,
				     osnum = sender_os,
				     p_chanselect = &chansel,
				     index = index,
				     objidaddr = &go_element.objid,
				     osnumaddr = &go_element.osnum);
      
      if(sender_id == go_element.objid && 
	 sender_os == go_element.osnum)
	{
	  chansel.type = OM_e_addr;
	  chansel.u_sel.addr = &me->to_components;

	  status = om$send(msg = graphics_msg, 
			   p_chanselect = &chansel);
	  status = om$send(msg = message Root.delete(FALSE), targetid = my_id);
	}
      else /* a hole was deleted */
	{
	  _xh_check_win();
	  delete_msg = (struct GRgraphics_GRdelete_Msg *) 
	    graphics_msg->p_arglist;
	  
	  not_chansel.type = OM_e_name;
	  not_chansel.u_sel.name = "GRnotify.notification";	  

	  status = om$send(msg = message Root.disconnect (not_chansel,
                                                          my_id,
                                                          OM_Gw_current_OS,
                                                          chansel),
			   targetid = sender_id,
			   targetos = sender_os);
	  
	  status = om$send(msg = message GRcoxhatch.GRxhget_gg(msg,
							       &xh_gg),
			   targetid = my_id);
	  
	  status = om$send(msg = message GRcoxhatch.GRxhcompute(msg,
							delete_msg->md_env,
								&xh_gg),
			   targetid = my_id);
	  
	  chansel.type = OM_e_addr;
	  chansel.u_sel.addr = &me->to_components;

	  status = om$send(msg = message GRgraphics.GRdisplay(msg,	
				      &delete_msg->md_env->md_env.matrix_type,
	      			      delete_msg->md_env->md_env.matrix,
							      &dis_mode,
						  &delete_msg->md_env->md_id),
			   p_chanselect = &chansel);

	} /* end else */
      break;
    }/* end  case */

  return(OM_S_SUCCESS);
}

end implementation GRcoxhatch;















