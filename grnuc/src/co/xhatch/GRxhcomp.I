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

#define   _xh_check_mem(ptr,msg) if(ptr==NULL) {msg=MSFAIL;return(OM_E_ABORT);}

from GRowner    import GRget_number_components;
from GRowner    import GRget_components;
from GRnotify    import GRntfyconn;

method GRxhcompute(IGRlong         *msg; 
                  struct GRmd_env  *module_info;                    
                  struct GRid      *xhatch_gg)
/*
Abstract
      This method will construct the lines which represent the crosshatching.
      This method is envoked when the crosshatching is initially created
      and if the crosshating is assocative whenever the primary element
      or one of the boundaries is modified or manipulated.

Arguments
      *msg	    IGRlong	      Completion code
      *module_info  struct GRmd_env   Module enviroment the crosshatching
                                      lines are to be conntructed in.
      *xhatch_gg    struct GRid       The object id and object space #
                                      of a graphic group the constructed
                                      lines will be in.  If NULL is
                                      passed in the method will contruct 
                                      a graphic group.
Return Values
    	MSSUCC if successful
    	MSFAIL (severe) if failure
*/


{
  IGRlong                      status;   
  OM_S_CHANSELECT              chansel;
  OM_S_CHANSELECT              comp_chansel;
  IGRint                       count;
  OMuint                       notify_count;
  IGRint                       i,j;
  struct GRid                 *objects = NULL;
  OM_S_OBJECT_LINKAGE         *notify_list = NULL;
  struct GRmd_env              mod_env;
  struct GRid                  my_grid;
  IGRlong                      index = 0;
  IGRlong                      conn_flag = 1;

  status = OM_S_SUCCESS;
  *msg = MSSUCC;
  _xh_check_win();

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  status = om$send(msg = message  GRowner.GRget_number_components(msg,
                                                                  &count), 
                   targetid = xhatch_gg->objid,
                   targetos = xhatch_gg->osnum);

  if( (status & 1) && (*msg & 1) )
    {
      if(count > 0)
      {
        objects = (struct GRid *)om$malloc(size=(sizeof(struct GRid))*count);
        if(objects == NULL) return(OM_E_NODYNMEM);
      
        status = om$send(msg = message GRowner.GRget_components(msg,
							      &mod_env,
  							      objects,
							      count,
							      &count,
							      0,
							      OM_K_MAXINT), 
		       targetid = xhatch_gg->objid,
		       targetos = xhatch_gg->osnum);
      
        chansel.type = OM_e_name;
        chansel.u_sel.name = "GRcoxhatch.to_notify";	

        status = om$get_channel_count(objid = my_grid.objid,
     	  		              osnum = my_grid.osnum,
				      p_chanselect = &chansel,
				      count = &notify_count);

        notify_list = (OM_S_OBJECT_LINKAGE *)om$malloc( size = 
	  		       (sizeof(OM_S_OBJECT_LINKAGE)) * notify_count);
        if(notify_list == NULL) return(OM_E_NODYNMEM);
      
        status = om$get_channel_objects(objid = my_grid.objid,
   			                osnum = my_grid.osnum,
				        p_chanselect = &chansel,
				        list  =  notify_list,
				        size  =  notify_count,
				        count = &notify_count );
        chansel.type = OM_e_name;
        chansel.u_sel.name = "GRconnector.to_owners";	
        comp_chansel.type = OM_e_name;
        comp_chansel.u_sel.name = "GRowner.to_components";	

        for(i=0; i<count; i++)
	  {
	    for(j=0; j<notify_count; j++)
	      {
	        if((notify_list[j].S_objid == objects[i].objid) &&
		  (notify_list[j].osnum == objects[i].osnum) )
		  {
		    objects[i].objid = NULL_OBJID;
		  }
	      }

	    if(objects[i].objid != NULL_OBJID)
	      {
	        status = om$send(msg = message GRconnector.GRdisconn(msg,
		  						   xhatch_gg),
	  	  	         targetid = objects[i].objid,
			         targetos = objects[i].osnum);

	         status = om$send(msg = message GRgraphics.GRdelete(msg,
	  							  module_info),
	  	   	          targetid = objects[i].objid,
			          targetos = objects[i].osnum);
	      }
	  }
        if(objects) om$dealloc(ptr = objects);
        if(notify_list) om$dealloc(ptr = notify_list);      
      }
    }
  else
    {
      xhatch_gg->osnum = OM_Gw_current_OS;
      status = om$construct(osnum = xhatch_gg->osnum,
    			    classname = "GRxhgg",
			    p_objid = &xhatch_gg->objid);

      status = om$send(msg = message GRconnector.GRflexconn( msg,
                                                             &conn_flag,
							     &my_grid, 
							     &index,
							     &index),
		       targetid = xhatch_gg->objid,
		       targetos = xhatch_gg->osnum);      
    }

  /* call compute function */
  if(me->xhatch_spacing == 0 && me->pattern_def.num_angles==1 &&
     me->pattern_def.pass[0].num_lines==1 && 
     me->pattern_def.pass[0].lines[0].perp_dist_next_line!=0)
    {
     me->xhatch_spacing = me->pattern_def.pass[0].lines[0].perp_dist_next_line;
      me->pattern_def.pass[0].lines[0].perp_dist_next_line = 0;
    }

  status = GRxh_generate_crosshatch(msg,
		 		    &me->window_grid,
                                    xhatch_gg,
   				    my_grid,
                                    me->xhatch_color,
                                    me->xhatch_spacing,
                                    me->xhatch_angle,
                                   &me->pattern_def,
                                    me->origin,
				    module_info,
				    me->associative_flag);

  return(status);
}

end implementation GRcoxhatch;




