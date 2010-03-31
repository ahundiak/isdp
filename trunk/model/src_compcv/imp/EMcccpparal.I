class implementation GRcompcurve;

#include "EMScc.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsicmpcvoff.h"
#include "matypemx.h"
#include "mamulmx.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscveval.h"
#include "bscrossp.h"

method GRcpparallel(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
                    struct GRmd_env *offset_env; 
                    struct IGRline *direction_boreline;
                    struct IGRline *distance_boreline; IGRdouble *distance;
                    IGRboolean *apparent_flag; IGRmatrix projection_matrix;
                    GRobjid *objid)

/*
Abstract:
	This method creates a new composite curve parallel to the 
  	original curve.

Arguments
    GRcpparallel(IGRlong *msg; IGRshort *mx_type, 
                 IGRmatrix matrix; struct GRmd_env *offset_env;
                 struct IGRline *direction_boreline; 
                 struct IGRline *distance_boreline; 
                 IGRdouble *distance; IGRboolean *apparent_flag;
                 IGRmatrix projection_matrix; GRobjid *objid)

	IGRlong *msg; 			return message
	IGRshort *mx_type, 		matrix type of original object
	IGRmatrix matrix; 		matrix for original object
	struct GRmd_env *offset_env;	environment for offset
	struct IGRline *direction_boreline; 
					boreline to indicate direction
					of offset
	struct IGRline *distance_boreline; 
					boreline to indicate distance 
					for offset ( send NULL pointer
					if sending distance)
	IGRdouble *distance; 		distance for offset (send NULL
					if sending distance_boreline)	
	IGRboolean *apparent_flag;	flag to indicate if the offset 
					is to be apparent
					 1 - do apparant offset
					 0 - offset in plane of element
     	IGRmatrix projection_matrix;   matrix to use for apparent offset
			NOTE: non-planar elements will always be an
			      apparent offset
	GRobjid *objid   	      	offset object's id

Description


Return Code
    MSSUCC - successful completion
    MSFAIL - error occured


History
    dhm     09/29/88    Creation date.
    dhm     01/20/89    Initialized const_list->msg and newflag.
    Sudha   06/21/93        modified for BSprototype ansification
*/

{
  IGRlong     msg_loc, status, size, bytes_out;
  IGRint      off_code;
  IGRdouble   dist, t, dotp;
  IGRmatrix   temp_matrix;
  IGRpoint    line_pt, curve_pt, cveval[2], pnt1, pnt2;
  IGRvector   vector, crossp, sidevec;
  IGRboolean  right_side, sts;
  IGRshort    active_level, temp_mx_type;
  IGRshort    r1 = 4, c1 = 4, c2 = 4;
  IGRchar     errmsg[EMMAXERRMSG_LEN];
  struct GRid off_cv_id;
  struct IGRdisplay	active_display;
  struct GRparms    prj_parm;
  struct GRvg_construct		const_list;
  struct IGRbsp_curve       *closest_curve;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg,"GRcompcurve.GRcpparallel\n");

  /*
   * If composite isn't planar or apparent_flag is TRUE, then
   * multiply the composite's matrix by the projection matrix.
   */

  if ( !(ME.GRgraphics->properties & GRIS_PLANAR) || (*apparent_flag) )
  {
    sts = MAmulmx(&msg_loc, &r1, &c1, &c2, matrix, projection_matrix,
                  temp_matrix);
    EMerr_hndlr(!sts || EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    sts = MAtypemx(&msg_loc, temp_matrix, &temp_mx_type);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
  }
  else
  {
    temp_mx_type = *mx_type;
    OM_BLOCK_MOVE(matrix, temp_matrix, sizeof(IGRmatrix));
  }

  /* 
   * Set distance up.
   */

  if (distance_boreline)
  {
    status = om$send(msg = message GRgraphics.GRlnproject(&msg_loc,
                           &temp_mx_type, temp_matrix, distance_boreline,
                           line_pt, curve_pt, &t, &prj_parm),
                     targetid = my_id);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    dist = BSdistptpt(&msg_loc, line_pt, curve_pt);
    EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
  }
  else
    dist = *distance;

  /*
   * Get the vector to send to the offset method.
   */

  OM_BLOCK_MOVE(direction_boreline->point1, pnt1, sizeof(IGRpoint));
  OM_BLOCK_MOVE(direction_boreline->point2, pnt2, sizeof(IGRpoint));

  vector[0] = pnt2[0] - pnt1[0];
  vector[1] = pnt2[1] - pnt1[1];
  vector[2] = pnt2[2] - pnt1[2];
  BSnorvec(&msg_loc, vector);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  /*
   * Determine the side to offset to.
   */

  status = om$send(msg = message GRgraphics.GRlnproject(&msg_loc,
                         &temp_mx_type, temp_matrix, direction_boreline,
                         line_pt, curve_pt, &t, &prj_parm),
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  status = om$send(msg = message GRcurve.GRgenabsg(&msg_loc, &temp_mx_type,
                       	 temp_matrix, (char **) &closest_curve),
                   targetid = prj_parm.leaf_id.objid,
                   targetos = prj_parm.leaf_id.osnum);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  BScveval(closest_curve, prj_parm.u, 1, cveval, &msg_loc);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  sidevec[0] = line_pt[0] - cveval[0][0];
  sidevec[1] = line_pt[1] - cveval[0][1];
  sidevec[2] = line_pt[2] - cveval[0][2];

  BScrossp(&msg_loc, cveval[1], vector, crossp);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  dotp = BSdotp(&msg_loc, crossp, sidevec);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  right_side = (dotp > 0 ? TRUE : FALSE);

  /*
   * Set up the construct list.
   */

  size = sizeof(struct IGRdisplay);
  gr$get_active_display(msg = &msg_loc, 
                        sizbuf = &size,
                        buffer = &active_display,
                        nret = &bytes_out);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  size = sizeof(IGRshort);
  gr$get_active_level(msg = &msg_loc,
                      sizbuf = &size,
                      buffer = &active_level,
                      nret = &bytes_out);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  const_list.msg        = &msg_loc;
  const_list.newflag    = FALSE;
  const_list.class_attr = NULL;
  const_list.level      = active_level;
  const_list.display    = &active_display;
  const_list.env_info   = offset_env;
  const_list.name       = NULL;
  const_list.properties = GRIS_NEW | GRIS_LOCATABLE 
                                   | GRIS_DISPLAYABLE;

  /*
   * Call the offset method.
   */

  off_code = BSCONSTOFF;
  status = om$send(msg = message GRcurve.EMcvoffset(&msg_loc,
                         &temp_mx_type, temp_matrix, &const_list, &dist,
                         vector, right_side, TRUE, &off_code, FALSE, TRUE,
                         &off_cv_id, NULL, NULL, NULL),
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  *objid = off_cv_id.objid;


  ret_end:
    return(status);
}

end implementation GRcompcurve;
