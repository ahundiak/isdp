/*
  jla
  25-Oct-88
  GRxform and GRmodify of ACsym using batch
*/
class implementation ACsym;

#include "ASmacroi.h"
#include "macro.h"
#include "lc.h"
#include "lcdef.h"
#include "asbox.h"
#include "grdpb.h"
#include "grerr.h"
#include "godef.h"
#include "grownerdef.h"
#include "batch.h"

#define debug 0
#define AS_DEBUG

extern IGRboolean ASbroadcast_in_progress;
extern char ACactive_name[];

/* ========================================================================= */

method GRxform(IGRlong *msg; struct GRmd_env *md_env; 
	       IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
  struct GRid 		my_grid;
  char 			*foot_name;
  IGRdouble 		*foot_matrix;
  IGRint 		cn_type;
  IGRlong 		status;

  if(ASbroadcast_in_progress)
  { 
    printf("error in ACsym.GRxform : broadcast_in_progress\n");
    *msg = MSFAIL;
    return(OM_W_ABORT);
  }

  /*"xform_chan %d active_name %d\n",me->xform_chan,ACactive_name[0] */

  if( me->xform_chan != 1 || ACactive_name[0] == 0)
  {
    /* Macro is not open but can rigidly move (in a cell for example) */
    status = om$send(msg = message ACcpx.GRxform(msg, md_env, matrix_type,
						  matrix, newobjid),
		   mode = OM_e_wrt_message,
		   targetid = my_id);
    return(status);
  }

  /*| add element in xform list */
  /*"obj %d ACactive_name %s\n",my_id,ACactive_name*/

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  foot_name = ACactive_name;
  foot_matrix = matrix;

  /*"matrix address %d\n",matrix */
  /*"foot_ma address %d\n",&foot_matrix */
  nd$wait_batch(type = GR_GEOM_XFORMED,
		p_fr_info = md_env,
		l_object  = &my_grid,
		nb_obj    = 1,
		l_name    = &foot_name,
		l_obj_info = (char *)&foot_matrix);

  /* add element in modify list asking recompute */

  cn_type = ND_COMP_XF;
  nd$wait_batch(type = GR_GEOM_POSTED,
		p_fr_info = md_env,
		l_object = &my_grid,
		l_obj_info = &cn_type,
		nb_obj   = 1);

  *newobjid = my_id;
  return(OM_S_SUCCESS);
}

/* ========================================================================= */

method GRmodify(IGRlong *msg; struct GRmd_env *md_env; 
	        struct GRparms *parms; IGRpoint point;
		struct IGRline *boreline; GRobjid *newobjid)
{
  struct GRid 		my_grid;
  char 			*foot_name;
  IGRint 		cn_type;
  struct NDmodif_info 	foot_info;

  if(ASbroadcast_in_progress)
  { 
    printf("error in ACsym.GRmodify : broadcast_in_progress\n");
    *msg = MSFAIL;
    return(OM_W_ABORT);
  }

  if( me->xform_chan != 1 || ACactive_name[0] == 0)
  {
    /*|  macro not open */
    return(OM_S_SUCCESS);
  }
  /*| add element in xform list */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  foot_name = ACactive_name;

  foot_info.parms =  *parms;
  v_equal(point,foot_info.point);
  v_equal(boreline->point1,foot_info.boreline_pt1);
  v_equal(boreline->point2,foot_info.boreline_pt2);
  foot_info.parms =  *parms;

  /*^ pr_point("pt1",foot_info.boreline_pt1); */

  nd$wait_batch(type = GR_GEOM_MODIFIED,
		p_fr_info = md_env,
		l_object = &my_grid,
		nb_obj   = 1,
		l_name   = &foot_name,
		l_obj_info = &foot_info);


  /* add element in modify list asking recompute */

  cn_type = ND_COMP_XF;
  nd$wait_batch(type = GR_GEOM_POSTED ,
		p_fr_info = md_env,
		l_object = &my_grid,
		l_obj_info = &cn_type,
		nb_obj   = 1);
  *newobjid = my_id;
  return(OM_S_SUCCESS);
}
end implementation ACsym;


