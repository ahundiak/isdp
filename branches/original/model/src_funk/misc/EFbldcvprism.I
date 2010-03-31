/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

#include "EMS.h"
/*
Abstract
    This function builds an IGRcv_prism structure gived the curve defining
    the prism and the window_id where it was located.

Notes
    The window_id can be found in the locate stack struct or the event
    button structure.

History
    dhm   7/14/88   creation date.
    rc    7/15/88   added code to get the range of the prism.
    SM    10/12/92  'index' should be 'short' -- SUN problem
    Sudha 07/08/93  Modified for BSprototypes ansification

*/

#include "OMindex.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "emsdef.h"
#include "emserr.h"
#include "msdef.h"
#include "bserr.h"
#include "matypemx.h"
#include "marptsxfo.h"
#include "maoptsxfo.h"
#include "mainvmx.h"
#include "bsunwght_p.h"
#include "bsbx2.h"

IGRlong EFbuild_cvprism(msg, window_id, curve, prism, range)

IGRlong      *msg;
struct GRid  window_id;
struct IGRbsp_curve   *curve;
struct IGRcv_prism    *prism;
GRrange      range;

{
  struct var_list list[3];
  IGRlong    msg_loc, error, status, total_poles, bytes_ret;
  IGRint     i, j;
  IGRshort   index;
  IGRshort   mat_typ;
  IGRmatrix  vw_mat, wv_mat;
  IGRchar    errmsg[EMMAXERRMSG_LEN];
IGRboolean   sts;
  IGRdouble  vw_vol[6], *poles, *poles_ptr;

  /*
   * Initalize the variables.
   */

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg, "EMbuild_cvprism error\n");
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

  status = dp$inq_set_gragad(msg = &msg_loc,
                             osnum = window_id.osnum,
                             gragad_objid = window_id.objid,
                             which_error = &error,
                             var_list = list);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Get the view(local) to world matrix for the prism.
   */

  status = MAinvmx(&msg_loc, &index, wv_mat, vw_mat);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Transform the curve's poles from world to view(local) coordinates.
   */

  if (!curve->rational)
  {
    status = MAtypemx(&msg_loc, wv_mat, &mat_typ);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    status = MAoptsxform(&msg_loc, &curve->num_poles, &mat_typ,
             wv_mat, curve->poles, prism->curve.poles);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
  }
  else
  {
    status = MArptsxform(&msg_loc, &curve->num_poles, &curve->rational,
             curve->weights, wv_mat, curve->poles,
             prism->curve.poles);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
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
  EMerr_hndlr(!poles, *msg, MSNOMEM, ret_end);

  for (i = 0; i < 2; i++)
  {
    poles_ptr = i ? &poles[curve->num_poles * 3] : poles;

    if (curve->rational)
    {
      sts = BSunwght_p(&msg_loc, prism->curve.poles, curve->weights,
                       &curve->num_poles, poles_ptr);
      EMerr_hndlr(!sts || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

    } /* if (curve->rational) */
    else
    {
      OM_BLOCK_MOVE(prism->curve.poles, poles_ptr,
                    sizeof(IGRdouble) * curve->num_poles * 3);

    } /* else for if (curve->rational) */

    for (j = 2; j < (curve->num_poles *3); j += 3)
       poles_ptr[j] = i ? vw_vol[5] : vw_vol[2];

    status = MAtypemx(&msg_loc, vw_mat, &mat_typ);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    status = MAoptsxform(&msg_loc, &curve->num_poles, &mat_typ,
                         vw_mat, poles_ptr, poles_ptr);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  } /* for (i = 0; i < 2; i++) */

  total_poles = curve->num_poles * 2;
  sts = BSbx2(&msg_loc, &total_poles, (IGRpoint *)poles, NULL, range, &range[3]);
  EMerr_hndlr (!sts || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

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
  status = MAinvmx(&msg_loc, &index, wv_mat, prism->matrix);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Project poles onto matrix defining back of the prism
   * by zeroing out the z coordinate of each pole.
   */

  for (i = 2; i < (curve->num_poles * 3); i += 3)
     prism->curve.poles[i] = 0;


ret_end:
   if (poles)  om$dealloc(ptr = poles);

   return(status);
}

end implementation Root;
