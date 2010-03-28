/* #######################    APOGEE COMPILED   ######################## */
class implementation Root;

#include "coimport.h"
#include "OMminimum.h"
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
#include "madef.h"
#include "msdef.h"
#include "dp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "grwireframe.h"
#include "bserr.h"
#include "EMSmsdismac.h"

#define  SURF_ELEMENT 0
#define  CSURF_ELEMENT 1
#define  CURVE_ELEMENT 2

from IGEgragad  import DPinrot;
from GRvg  import GRgetsize;
from GRvg  import GRgetgeom;


/*----------------------------------------
 *  CO_ni_measure_min_dis_2_ele
 *----------------------------------------
 */
IGRlong CO_ni_measure_min_dis_2_ele(msg,
				    events,
				    module_info,
				    distance,
				    units,
				    my_id,
				    my_chan_struct,
				    object_grids )
     
     IGRlong              *msg;
     struct GRevent       *events[];
     struct GRmd_env      *module_info[];
     IGRdouble            *distance;
     IGRchar              *units;
     GRobjid               my_id;
     OM_S_CHANSELECT      *my_chan_struct;
     struct GRid          *object_grids[];
{
  struct GRid          first_grid;
  struct GRid          second_grid;
  IGRuint              num_objects;
  OM_S_OBJECT_LINKAGE  chan_linkage[2];
  IGRpoint             point1,point2,approx_pt,dummy_pt;
  struct IGRline       line;
  IGRboolean           b_status;
  IGRlong              status;
  struct GRparms       Parms1;
  struct GRparms       Parms2;
  extern    IGRboolean    GR2objminline();
  IGRlong              size;
  IGRlong              ret_size;
  IGRboolean           apparent_flag;
  IGRboolean           absolute_flag,found;
  IGRpoint             pl_pt;
  IGRvector            view_vector;
  IGRmatrix            rot_matrix;
  IGRint               num_pts = 2;
  OMuword	       p_classid;
  GRobjid 	       oid1,oid2;
     
  
  status = OM_S_SUCCESS;
  *msg = MSSUCC;
  
  line.point1 = point1;
  line.point2 = point2;
  
  if ( my_chan_struct != NULL )  /* extract object from channel */
    {
      status = om$get_channel_objects(objid = my_id,
				      p_chanselect = my_chan_struct,
				      list = chan_linkage,
				      size = 2,
				      count = &num_objects );
      _m_checkq( status );
      
      second_grid.objid = chan_linkage[0].S_objid;
      second_grid.osnum = chan_linkage[0].osnum;
      
      first_grid.objid = chan_linkage[1].S_objid;
      first_grid.osnum = chan_linkage[1].osnum;
    }
  else
    {
      first_grid = *object_grids[0];
      second_grid = *object_grids[1];
    }

  found = FALSE;
  status = om$get_classid( osnum = first_grid.osnum,
                         objid = first_grid.objid,
                         p_classid = &p_classid );
 
    /* find out if the element subclasses from EMSsolid   */
  status = om$is_ancestry_valid( subclassid = p_classid,
                              superclassname = "EMScompsurf" );
  if( status == OM_S_SUCCESS ) found = TRUE;

  if(!found)
    {
    status = om$get_classid( osnum = second_grid.osnum,
                         objid = second_grid.objid,
                         p_classid = &p_classid );
 
    /* find out if the element subclasses from EMSsolid   */
    status = om$is_ancestry_valid( subclassid = p_classid,
                              superclassname = "EMScompsurf" );
    if( status == OM_S_SUCCESS ) found = TRUE;

    }
*distance = 0;
size = sizeof(apparent_flag);
  status = gr$get_apparent_flag(msg = msg,
                                sizbuf = &size,
                                buffer = &apparent_flag,
                                nret= &ret_size);

  if(found) 
    {
    status = ems$meas_mindis_bet_2_eli(
                msg = msg,
                first_grid = first_grid,
                second_grid = second_grid,
                mod_env1 = module_info[0],
                mod_env2 = module_info[1],
                event1 =events[0],
                event2 =events[1],
		app_flag = apparent_flag,
                point1 =point1,
                point2 =point2,
                mindist = distance
                );
     if(!(status & 1) ) goto quit;
    }
  else
   {
  status = co$project_event(msg     =  msg,
			    event   =  events[0],
			    module  =  module_info[0],
			    cob_id  =  my_id,
			    grid    = &first_grid,
			    parms   = &Parms1,
			    point   =  dummy_pt);
  _m_check2q(status, *msg);
  
  status = co$project_event(msg     =  msg,
			    event   =  events[1],
			    module  =  module_info[1],
			    cob_id  =  my_id,
			    grid    = &second_grid,
			    parms   = &Parms2,
			    point   =  approx_pt);
  _m_check2q(status, *msg);
  
  if(apparent_flag)
  {
      b_status = COproj_pt_to_view_pl(msg,
				      events[0],
				      pl_pt);
      /* load view vector */
      status = om$send(msg = message IGEgragad.DPinrot(msg,
						       rot_matrix ),
		       senderid = NULL_OBJID,
		       targetid = events[0]->event.button.objid,
		       targetos = events[0]->event.button.osnum );
      _m_check2q(status, *msg);
      
      view_vector[0] = rot_matrix[8];
      view_vector[1] = rot_matrix[9];
      view_vector[2] = rot_matrix[10];
  }
  
  size = sizeof(absolute_flag);
  status = gr$get_local_abs_flag(msg = msg,
				 sizbuf = &size,
				 buffer = &absolute_flag,
				 nret= &ret_size);
  
  /* GR2objminline wants local=TRUE and absolute=FALSE */
  /* This is opposite to the dpb setting */
  absolute_flag = ! absolute_flag;

  b_status = GR2objminline(msg,
			   &first_grid,
			   &module_info[0]->md_env,
			   &Parms1,
			   &second_grid,
			   &module_info[1]->md_env,
			   &Parms2,
			   &absolute_flag,
			   &apparent_flag,
			   pl_pt,
			   view_vector,
			   approx_pt,
			   &line);
  _m_checkq( *msg ); 

  }
  
  /*
   *  calculate the distance between the two points.
   */

  events[0]->event.button.x = point1[0];
  events[0]->event.button.y = point1[1];
  events[0]->event.button.z = point1[2];
  
  events[1]->event.button.x = point2[0];
  events[1]->event.button.y = point2[1];
  events[1]->event.button.z = point2[2];

  /* 
   * KLUDGE ALLERT!  ALL THE MEASUREMENT CODE NEEDS TO BE REWORKED 
   * Shelley Heard 10/8/92 
   */
  *events[3] = *events[0];
  *events[4] = *events[1];

  num_pts = 1;
  status = COcvt_pts_to_lcl_coord(msg,
				  num_pts,
				  point1,
				  point1);

  status = COcvt_pts_to_lcl_coord(msg,
				  num_pts,
				  point2,
				  point2);
    
  status = MA2ptdis(msg,
		    point1,
		    point2,
		    distance );
  
  /*
   *  we are measuring Distance
   */
  strncpy( units, GRIO_DISTANCE, GRIO_MAX_ALIAS_SIZE );
  
 quit:
  return( status );
}

end implementation Root;


