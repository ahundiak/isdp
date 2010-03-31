/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

/*
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
*/

#include "EMS.h"
#include "OMindex.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "grgsdef.h"
#include "lcdef.h"
#include "lc.h"
#include "msdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "bserr.h"
#include "bsparameters.h"

from GRgraphics import GRgetrang, GRlocate;
from module import GRmod_passon;
from OMindex import pass;

extern OMuword  OPP_GRcurve_class_id, OPP_GRreffile_class_id;

IGRlong EMauto_nester(msg, lc_info, window, ret_objects, num_entries)

IGRlong     *msg;                  /* return code */
struct GRlc_info    *lc_info;      /* info about the surrounding curve */
struct GRid         window;        /* id of window where locate point is */
struct GRlc_info    **ret_objects; /* array of objects located */
IGRlong     *num_entries;          /* number of objects found */

{
  struct ret_obj_info
  {
    IGRint           array_size;
    IGRlong          *num_entries;
    struct GRlc_info    **lc_info;
  };

  IGRint           begin_ind, end_ind, bytes_in, bytes_out;
  IGRlong          msg_loc, rtree_msg_loc, status, EFbuild_cvprism();
  IGRchar          errmsg[EMMAXERRMSG_LEN];
  struct GRlc_cvl  cvl;         /* locate communication vector list */
  struct GRlc_locate  attr;          /* attributes of objects to find */
  OM_S_CLASSLIST      elig_classes;  /* eligible classes to locate */
  OM_S_CLASSLIST      rtree_classes;  /* rtree classes to locate */
  OM_S_KEY_DESC    obj_key, target_key;
  DB_3D_DBL_BOX    obj_range_box, target_range_box;
  OM_S_MESSAGE     locate_msg, rtree_pass_msg;
  OMuword          msg_size, eliclass, rclass;
  GRrange          range;
  IGRint           level[35];
  IGRlong          error, bytes_ret;
  struct var_list  list[2];
  struct ret_obj_info    act_args;
  struct GRgraphics_GRlocate_Msg    loc_arglist;
  struct OMindex_pass_Msg    pass_arglist;
  struct IGRbsp_curve    *curve;
  IGRint           EMnester_action_hndlr();
  struct GRmd_env  mod_env;

  /*
   * Initialize
   */

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg, "EMauto_nester error\n");
  curve = NULL;

  /*
   * Set up the rtree and eligible classes to locate.
   */

  rtree_classes.w_count = elig_classes.w_count = 1;
  rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
  eliclass = OPP_GRcurve_class_id;
  rclass = OPP_GRcurve_class_id;
  elig_classes.p_classes = &eliclass;
  rtree_classes.p_classes = &rclass;

  /*
   * Set the locate properties and owner_action.
   */

  attr.properties = LC_LC_ONLY | LC_RW | LC_DP_ONLY | LC_PLANAR_ONLY;
  attr.owner_action = LC_RIGID_OWNER | LC_RIGID_COMP | LC_INTERMIDIATE |
                      LC_FLEX_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER;

  /*
   * Get the current module info.  It could be different
   * from the input located object's module info.
   */

  bytes_in = sizeof(struct GRmd_env);
  gr$get_module_env(msg = &msg_loc,
                    sizbuf = &bytes_in,
                    buffer = &mod_env,
                    nret = &bytes_out);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Set the cvl struct equal to the values just gotten.
   */

  cvl.module = mod_env;
  cvl.classes = &elig_classes;
  cvl.r_classes = &rtree_classes;
  cvl.attributes.type = GR_cv_loc;
  cvl.attributes.obj_attr = attr;

  /*
   * Get the input curve's geometry for the curve prism structure.
   */

  status = EMget_the_geometry(lc_info, TRUE, FALSE, FALSE, NULL_OBJID,
                              &curve, &msg_loc);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * This function returns the curve prism matrix, height, and 
   * xy_plane curve.
   */

  status = EFbuild_cvprism(&msg_loc, window, curve,
                           &cvl.attributes.acc_cv_prism, range);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  cvl.prism_attr = GO_INSIDE; /* get objects inside the input curve */

  /*
   * Get the levels needed by the cvl struct.
   */

  list[0].var = LEVELS;
  list[0].var_ptr = (IGRchar *)level;
  list[0].num_bytes = sizeof(IGRint) * 35;
  list[0].bytes_returned = &bytes_ret;

  list[1].var = END_PARAM;
  list[1].var_ptr = NULL;
  list[1].num_bytes = 0;
  list[1].bytes_returned = NULL;

  status = dp$inq_set_gragad(msg = &msg_loc,
                             osnum = window.osnum,
                             gragad_objid = window.objid,
                             which_error = &error,
                             var_list = list);
  EMomerr_hndlr(status, ret_end, errmsg);

  cvl.levels = level;

  /*
   * In the act_args struct, initialize the num_entries and array_size
   * to 0 and the lc_info to ret_objects.
   */

  *num_entries = 0;
  act_args.num_entries = num_entries;
  act_args.array_size = 0;
  act_args.lc_info = ret_objects;
  cvl.action_handler = EMnester_action_hndlr;
  cvl.act_parms = (IGRchar *) &act_args;

  /*
   * Make the GRlocate message in order to send it to the pass method.
   */

  loc_arglist.cvl = &cvl;
  loc_arglist.range_key = &target_key;
  msg_size = sizeof(struct GRgraphics_GRlocate_Msg);
  status = om$make_message(classname = "GRgraphics",
                           methodname = "GRlocate",
                           size = msg_size,
                           p_arglist = &loc_arglist,
                           p_msg = &locate_msg);
  EMomerr_hndlr(status, ret_end, errmsg);

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

  target_key.key.p_3ddbl = &target_range_box;

  pass_arglist.msg = &locate_msg;
  pass_arglist.p_select_key = &obj_key;
  pass_arglist.classlist = NULL;
  pass_arglist.p_target_key = &target_key;
  pass_arglist.user_compare = NULL;
  pass_arglist.ret = (IGRint *)&rtree_msg_loc;
  msg_size = sizeof(struct OMindex_pass_Msg);
  status = om$make_message(classname = "OMrtree",
                           methodname = "pass",
                           size = msg_size,
                           p_arglist = &pass_arglist,
                           p_msg = &rtree_pass_msg);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Pass the GRlocate message out the primary channel thru
   * the GRmod_passon message.
   */

  begin_ind = 0;
  end_ind = 0;
  status = om$send(msg = message module.GRmod_passon(&msg_loc,
                         &rtree_pass_msg, "primary", &begin_ind, &end_ind),
                   senderid = NULL_OBJID,
                   targetid = mod_env.md_id.objid,
                   targetos = mod_env.md_id.osnum);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);


 ret_end:
   if (curve)  free(curve);

   return(status);

}

end implementation Root;
