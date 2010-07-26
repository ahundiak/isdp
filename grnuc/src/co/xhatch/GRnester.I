/* #######################    APOGEE COMPILED   ######################## */

class implementation Root;
/* */
/* ----------------------------------------------------------------------------
Abstract
    This function builds an IGRcv_prism structure gived the curve defining
    the prism and the window_id where it was located.

Notes
    The window_id can be found in the locate stack struct or the event
    button structure.

History
    dhm   7/14/88   creation date.
    rc    7/15/88   added code to get the range of the prism.
    bmr   3/21/89   copied for xhatch.
---------------------------------------------------------------------------  */
#include "coimport.h"
#include "OMminimum.h"
#include "OMindex.h"
#include "OMprimitives.h"
#include "OMDB.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "grgsdef.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "codebug.h"
#include "igrmacros.h"

from GRgraphics import GRgetrang, GRlocate;
from module     import GRmod_passon;
from OMindex    import pass;
from GRvg       import GRgetsize,GRgetgeom,GRgeomprops;

extern OMuword  OPP_GRpoint_class_id;

extern OMuword  OPP_GRcurve_class_id, OPP_GRreffile_class_id;

IGRlong GRxhbuild_cvprism(msg, window_id, curve, prism, range)

     IGRlong      *msg;
     struct GRid  window_id;
     struct IGRbsp_curve   *curve;
     struct IGRcv_prism    *prism;
     GRrange      range;
     
{
  struct var_list list[3];
  IGRlong             error, status, total_poles, bytes_ret;
  IGRint              i, j;
  IGRshort            mat_typ, index;
  IGRmatrix           vw_mat, wv_mat;
  IGRdouble           vw_vol[6], *poles, *poles_ptr;
  IGRboolean          b_status;
  extern  IGRboolean  MArptsxform();
  extern  IGRboolean  BSunwght_p();
  extern  IGRboolean  MAtypemx();
  extern  IGRboolean  MAoptsxform();
  extern  IGRboolean  BSbx2();
  
  /*
   * Initalize the variables.
   */
  
  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  index = 4;
  prism->curve = *curve;
  poles = NULL;
  
  /*
   * Get the world to view matrix, view volume and view origin.
   */
  list[0].var = WLD_TO_VIEW;
  list[0].var_ptr = (IGRchar *)wv_mat;
  list[0].num_bytes = sizeof(IGRdouble) * 16;
  list[0].bytes_returned = &bytes_ret;
  
  list[1].var = VW_VOLUME;
  list[1].var_ptr = (IGRchar *)vw_vol;
  list[1].num_bytes = sizeof(IGRdouble) * 6;
  list[1].bytes_returned = &bytes_ret;
  
  list[2].var = END_PARAM;
  list[2].var_ptr = NULL;
  list[2].num_bytes = 0;
  list[2].bytes_returned = NULL;
  
  status = dp$inq_set_gragad(msg = msg,
                             osnum = window_id.osnum,
                             gragad_objid = window_id.objid,
                             which_error = &error,
                             var_list = list);
  _m_check2p(status,*msg,"GRxhbuild_cvprism: dp$inq_set_gragad  ");
  _m_check2q(status,*msg);
  /*
   * Get the view(local) to world matrix for the prism.
   */
  
  b_status = MAinvmx(msg, &index, wv_mat, vw_mat);
  _m_check_boolp(b_status,"GRxhbuild_cvprism: MAinvmx  ");
  _m_check_boolq(b_status);
  
  /*
   * Transform the curve's poles from world to view(local) coordinates.
   */
  
  if (!curve->rational)
    {
      b_status = MAtypemx(msg, wv_mat, &mat_typ);
      _m_check_boolp(b_status,"GRxhbuild_cvprism: MAtypemx  ");
      _m_check_boolq(b_status);
      
      b_status = MAoptsxform(msg, &curve->num_poles, &mat_typ,
			   wv_mat, curve->poles, prism->curve.poles);
      _m_check_boolp(b_status,"GRxhbuild_cvprism: MAoptsxform  ");
      _m_check_boolq(b_status);
    }
  else
    {
      b_status = MArptsxform(msg, &curve->num_poles, &curve->rational,
			   curve->weights, wv_mat, curve->poles,
			   prism->curve.poles);
      _m_check_boolp(b_status,"GRxhbuild_cvprism: MArptsxform  ");
      _m_check_boolq(b_status);
    }
  
  /* 
   * Get the range of the prism box.  Have to take the poles of the prism
   * to the view volume min and max z-depth.  This is done to have two
   * faces form the range box.  Next, have to translate both faces of the
   * prism from the view(local) system to the world coordinate system.
   * Last, call the math function which calculates the min and max
   * range points. 
   */
  
  poles = (IGRdouble *) om$malloc(size = curve->num_poles * 2 * 3 *
                                  sizeof(IGRdouble) );
  
  for (i = 0; i < 2; i++)
    {
      poles_ptr = i ? &poles[curve->num_poles * 3] : poles;
      
      if (curve->rational)
	{
	  b_status = BSunwght_p(msg, prism->curve.poles, curve->weights,
			   &curve->num_poles, poles_ptr);
	  
	} /* if (curve->rational) */
      else
	{
	  OM_BLOCK_MOVE(prism->curve.poles, poles_ptr,
			sizeof(IGRdouble) * curve->num_poles * 3);
	  
	} /* else for if (curve->rational) */
      
      for (j = 2; j < (curve->num_poles *3); j += 3)
	poles_ptr[j] = i ? vw_vol[5] : vw_vol[2];
      
      b_status = MAtypemx(msg, vw_mat, &mat_typ);
      _m_check_boolp(b_status,"GRxhbuild_cvprism: MAtypemx  ");
      _m_check_boolq(b_status);
      
      b_status = MAoptsxform(msg, &curve->num_poles, &mat_typ,
			     vw_mat, poles_ptr, poles_ptr);
      _m_check_boolp(b_status,"GRxhbuild_cvprism: MAoptsxform  ");
      _m_check_boolq(b_status);
      
    } /* for (i = 0; i < 2; i++) */
  
  total_poles = curve->num_poles * 2;
  b_status = BSbx2(msg, &total_poles, poles, NULL, range, &range[3]);
  
  /*
   * Subtract the view min depth from the max depth to get the height.
   */
  
  prism->height = vw_vol[5] - vw_vol[2];
  
  /*
   * Since math treats the prism with postive depth, it is necessary
   * to translate the objects in viewing coordinate system by
   * minimum display depth.
   */
  
  wv_mat[11] -= vw_vol[2];
  b_status = MAinvmx(msg, &index, wv_mat, prism->matrix);
  _m_check_boolp(b_status,"GRxhbuild_cvprism: MAinvmx  ");
  _m_check_boolq(b_status);
  
  /*
   * Project poles onto matrix defining back of the prism
   * by zeroing out the z coordinate of each pole.
   */
  
  for (i = 2; i < (curve->num_poles * 3); i += 3)
    prism->curve.poles[i] = 0;
  
  
 quit:
  if (poles)  om$dealloc(ptr = poles);
  
  return(status);
}

/* ---------------------------------------------------------------------------
Abstract
    This function passes the GRlocate message to objects whose range
    intersects or is enclosed by the input curve.

Notes
    The window id of the input curve can be found in the GRlc_stack
    structure returned by the locate filter.

History
    dhm   5/20/88   creation date.
    dhm   8/4/88    changed my cvl.prism_attr from GR_LC_INSIDE to
                    GO_INSIDE.
    bmr   3/21/89   copied for xhatch.
    WBC   7/27/92   calling lc$check_id after the locate to clear the
                    posted objects, otherwise the posted objects will
                    not be located the next time they are identified
-------------------------------------------------------------------------- */

IGRlong GRauto_nester(msg, 
		      lc_info, 
		      window, 
		      attributes,
                      eligible_classes,
		      ret_objects, 
		      num_entries)

     IGRlong             *msg;          /* return code */
     struct GRlc_info    *lc_info;      /* info about the surrounding curve */
     struct GRid         window;        /* id of window where locate point is*/
     struct GRlc_locate  *attributes;
     OM_S_CLASSLIST      *eligible_classes;
     struct GRlc_info    **ret_objects; /* array of objects located */
     IGRlong             *num_entries;  /* number of objects found */
     
{
  struct ret_obj_info
    {
      IGRint           array_size;
      IGRlong          *num_entries;
      struct GRlc_info    **lc_info;
    };
  
  IGRint                         begin_ind, end_ind, bytes_in, bytes_out;
  IGRint                         rtree_msg_loc; 
  IGRlong                        status;
  IGRlong                        GRxhbuild_cvprism();
  struct GRlc_cvl                cvl;       
  OM_S_CLASSLIST                 rtree_classes; 
  OM_S_KEY_DESC                  obj_key, target_key;
  DB_3D_DBL_BOX                  obj_range_box, 
                                 target_rng_box;
  OM_S_MESSAGE                   locate_msg, rtree_pass_msg;
  OMuword                        msg_size;
  GRrange                        range;
  IGRint                         level[35];
  IGRlong                        error, bytes_ret;
  struct var_list                list[2];
  struct ret_obj_info            act_args;
  struct GRgraphics_GRlocate_Msg loc_arglist;
  struct OMindex_pass_Msg        pass_arglist;
  struct IGRbsp_curve            *curve;
  IGRint                         GRnester_action_hndlr();
  struct GRmd_env                mod_env;
  IGRlong                        size;
  
  /*
   * Initialize
   */
  
  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  curve = NULL;
  
  /*
   * Set up the rtree and eligible classes to locate.
   */
  rtree_classes = *eligible_classes;
  
  /*
   * Get the current module info.  It could be different
   * from the input located object's module info.
   */
  
  bytes_in = sizeof(struct GRmd_env);
  status = gr$get_module_env(msg = msg,
			     sizbuf = &bytes_in,
			     buffer = &mod_env,
			     nret = &bytes_out);
  _m_check2q(status,*msg);
  /*
   * Set the cvl struct equal to the values just gotten.
   */

  cvl.module = mod_env;
  cvl.classes = eligible_classes;
  cvl.r_classes = &rtree_classes;
  cvl.attributes.type = GR_cv_loc;
  cvl.attributes.obj_attr = *attributes;

  /*
   * Get the input curve's geometry for the curve prism structure.
   */
  status = om$send(msg = message GRvg.GRgetsize(msg,
				     &lc_info->module_info.md_env.matrix_type,
				      lc_info->module_info.md_env.matrix,
						&size),
                   senderid = NULL_OBJID,
		   targetos = lc_info->located_obj.osnum,	
		   targetid = lc_info->located_obj.objid);
  _m_check2p(status,*msg,"GRauto_nester:GRvg.GRgetsize");
  _m_check2q(status,*msg);
  if(size<0) goto quit;
    
  curve = (struct IGRbsp_curve *) om$malloc( size = size);
  
  if(curve == NULL) goto quit;
  status = om$send(msg = message GRvg.GRgetgeom(msg,
				     &lc_info->module_info.md_env.matrix_type,
				      lc_info->module_info.md_env.matrix,
				      (IGRchar *)curve),
                   senderid = NULL_OBJID,
		   targetos = lc_info->located_obj.osnum,	
		   targetid = lc_info->located_obj.objid);
  _m_check2p(status,*msg,"GRauto_nester:GRvg.GRgetgeom");
  _m_check2q(status,*msg);

  /*
   * This function returns the curve prism matrix, height, and 
   * xy_plane curve.
   */

  status = GRxhbuild_cvprism(msg, window, curve,
                           &cvl.attributes.acc_cv_prism, range);
  _m_check2p(status,*msg,"GRauto_nester:GRxhbuild_cvprism");
  _m_check2q(status,*msg);

  cvl.prism_attr = GO_INSIDE; /* get objects inside the input curve */
  
  /*
   * Get the levels needed by the cvl struct.
   */
  
  list[0].var = LEVELS;
  list[0].var_ptr = (IGRchar*) level;
  list[0].num_bytes = sizeof(IGRint) * 35;
  list[0].bytes_returned = &bytes_ret;
  
  list[1].var = END_PARAM;
  list[1].var_ptr = NULL;
  list[1].num_bytes = 0;
  list[1].bytes_returned = NULL;
  
  status = dp$inq_set_gragad(msg = msg,
                             osnum = window.osnum,
                             gragad_objid = window.objid,
                             which_error = &error,
                             var_list = list);
  _m_check2p(status,*msg,"GRauto_nester:dp$inq_set_gragad");
  _m_check2q(status,*msg);

  cvl.levels = level;

  /*
   * In the act_args struct, initialize the num_entries and array_size
   * to 0 and the lc_info to ret_objects.
   */

  *num_entries = 0;
  act_args.num_entries = num_entries;
  act_args.array_size = 0;
  act_args.lc_info = ret_objects;
  cvl.action_handler = (IGRint (*)())GRnester_action_hndlr;
  cvl.act_parms = (IGRchar *) &act_args;

  /*
   * Make the GRlocate message in order to send it to the pass method.
   */

  target_key.type = KEY_3D_DBL; 
  target_key.key.p_3ddbl = &target_rng_box;

  loc_arglist.cvl = &cvl;
  loc_arglist.range_key = &target_key;

  msg_size = sizeof(struct GRgraphics_GRlocate_Msg);
  status = om$make_message(classname = "GRgraphics",
                           methodname = "GRlocate",
                           size = msg_size,
                           p_arglist = &loc_arglist,
                           p_msg = &locate_msg);
  _m_checkp(status,"GRauto_nester:om$make_message 1");
  _m_checkq(status);
  /*
   * Make the OMrtree.pass message in order to send it to GRmod_passon.
   */
  obj_key.type = KEY_3D_DBL;
  obj_key.key.p_3ddbl = &obj_range_box;

  obj_range_box.xmin = range[0];
  obj_range_box.ymin = range[1];
  obj_range_box.zmin = range[2];
  obj_range_box.xmax = range[3];
  obj_range_box.ymax = range[4];
  obj_range_box.zmax = range[5];

  pass_arglist.msg = &locate_msg;
  pass_arglist.p_select_key = &obj_key;
  pass_arglist.classlist = NULL;
  pass_arglist.p_target_key = &target_key;
  pass_arglist.user_compare = NULL;
  pass_arglist.ret = &rtree_msg_loc;
  msg_size = sizeof(struct OMindex_pass_Msg);
  status = om$make_message(classname = "OMrtree",
                           methodname = "pass",
                           size = msg_size,
                           p_arglist = &pass_arglist,
                           p_msg = &rtree_pass_msg);
  _m_checkp(status,"GRauto_nester:om$make_message 2");
  _m_checkq(status);
  /*
   * Pass the GRlocate message out the primary channel thru
   * the GRmod_passon message.
   */

  begin_ind = 0;
  end_ind = 0;
  om$send(msg = message module.GRmod_passon(msg,
			    &rtree_pass_msg, "module.primary", &begin_ind, &end_ind),
	  senderid = NULL_OBJID,
	  targetid = mod_env.md_id.objid,
	  targetos = mod_env.md_id.osnum);

  /* clear the list of elements that were "hit" during this locate */

  lc$check_id(rc = &error,
              mode = LC_DELETE);

 quit:
   if (curve) om$dealloc(ptr = curve);
   return(status);
}
/* */

/* ----------------------------------------------------------------------------
Abstract

History
    dhm   5/20/88   creation date.
    bmr   3/21/89   copied for xhatch.
---------------------------------------------------------------------------- */


#argsused
IGRint GRnester_action_hndlr (args, new_entry, locate_args, action)
     
     struct GRlc_info      *new_entry;
     struct LC_action_args *locate_args;
     enum   GRlocate_action *action;
     IGRchar               *args;
     
{
  struct ret_obj_info
    {
      IGRint           array_size;
      IGRlong          *num_entries;
      struct GRlc_info    **lc_info;
    };
  
  IGRlong                 msg, status;
  struct GRprops          props;
  struct ret_obj_info    *entries;
  OMuword                 new_entry_classid;
  
  /*
   * Initialize
   */
  
  status = OM_S_SUCCESS;
  entries = (struct ret_obj_info *) args;
  
  switch (*action)
    {
      /*
       * These 2 cases are sent when a reference space is
       * entered during an rtree scan.
       */
      
    case end_transition:
    case start_transition:
      {
	status = OM_S_SUCCESS;
	goto ret_end;
      }
      
      /*
       * This case is called when an object is to be posted as
       * already located.
       */
      
    case post_object:
      {
	lc$check_id(rc = &msg, objid = new_entry->located_obj.objid,
		    osnum = new_entry->located_obj.osnum);
	status = OM_S_SUCCESS;
	goto ret_end;
      }
      
      /*
       * This case allows objects to check to see if it has already
       * been located -- helpful in solids and owners.      
       */
    case check_object:
      {
	lc$check_id(rc = &msg, objid = new_entry->located_obj.objid,
		    osnum = new_entry->located_obj.osnum, mode = LC_CHECK);
	if (msg == LC_ID_FOUND)
	  status = OM_S_SUCCESS;
	else
	  status = LC_ID_NOT_FOUND;
	goto ret_end;
      }
      
      /*
       * This case is called if the located object overlaps curve boundary.
       */
      
    case add_overlap:
      {
	status = OM_S_SUCCESS;
	goto ret_end;
      }

      /*
       * This case is called if the located object is outside curve boundary.
       */
      
    case add_outside:
      {
	status = OM_S_SUCCESS;
	goto ret_end;
      }
      
    } /* end switch (action) */
  
  
  /*
   * Get the geom. properties of the located object.
   */
  
  status = om$send(msg = message GRvg.GRgeomprops(&msg,
				 &new_entry->module_info.md_env.matrix_type,
				 new_entry->module_info.md_env.matrix, &props),
                   senderid = NULL_OBJID,
                   targetid = new_entry->located_obj.objid,
                   targetos = new_entry->located_obj.osnum);
  
  if ( (props.phy_closed) || (props.closed) )
    {
      status = om$get_classid(osnum = new_entry->located_obj.osnum,
			      objid = new_entry->located_obj.objid,
			      p_classid = &new_entry_classid);

      status = om$is_ancestry_valid(subclassid = new_entry_classid,
                                    superclassid = OPP_GRpoint_class_id);
      if (status == OM_S_SUCCESS)
	goto ret_end;
      
      if (entries->array_size == 0)
	{
	  *(entries->lc_info) = (struct GRlc_info *) om$malloc(size = 10 *
					       sizeof(struct GRlc_info) );
	  entries->array_size = 10;
	}
      else if ( (*entries->num_entries) >= entries->array_size )
	{
	  entries->array_size = entries->array_size + 1;
	  *(entries->lc_info) = (struct GRlc_info *)
	    om$realloc(ptr = (IGRchar *) *(entries->lc_info), size = entries->array_size *
		       sizeof(struct GRlc_info) );
	}
      
      (*(entries->lc_info))[*entries->num_entries] = *new_entry;
      (*entries->num_entries)++;
      
    }  /* end if object is closed */
  
 ret_end:  
  return(status);
  
}

end implementation Root;
