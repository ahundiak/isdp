/* ###################   APOGEE COMPILED   ################## */
class implementation GRsubbc;

#include "EMS.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "bserr.h"
#include "msdef.h"

IGRlong EFcrv_move_poles(msg, crv, tleft, tright, curve)
IGRlong   *msg;              /* error return code */
struct GRlc_info   *crv;     /* input curve's info */
IGRdouble    tleft, tright;  /* input t value of side to move */
struct IGRbsp_curve **curve; /* output curve geometry */

/*
Abstract
   This function moves the second or the second to the last pole by
   the equation x = x0 + (x - x0) * t.  This maintains tangency at the
   endpoints.

Notes
   The variables, tleft and tright, are used to indicate t value for
   the second pole or t value for second to last pole, respectively.
   This function posts the new geometry to the object, crv, and returns
   the geometry, curve.

History
    dhm    10/7/88   creation date
*/

{
  IGRlong   msg_loc, status, size;
  IGRint    i;
  IGRboolean  sts;
  extern IGRboolean   GRabsg_del_all();
  IGRdouble      *pnt0, *pnt1, *pnt2, *pnt3;
  GRobjid        newid;
  struct IGRbsp_curve *gen_ptr;
  struct GRpost_info  info;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  gen_ptr = NULL;

  status = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                         &crv->module_info.md_env.matrix_type,
                         crv->module_info.md_env.matrix, &size),
                   senderid = NULL_OBJID,
                   targetid = crv->located_obj.objid,
                   targetos = crv->located_obj.osnum);
  EMomerr_hndlr(status, ret_end, "EFmovepoles error\n");
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  gen_ptr = (struct IGRbsp_curve *) om$malloc(size = size);
  EMerr_hndlr(!gen_ptr, *msg, MSNOMEM, ret_end);

  status = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                         &crv->module_info.md_env.matrix_type,
                         crv->module_info.md_env.matrix,(IGRchar *) gen_ptr),
                   senderid = NULL_OBJID,
                   targetid = crv->located_obj.objid,
                   targetos = crv->located_obj.osnum);
  EMomerr_hndlr(status, ret_end, "EFmovepoles error\n");
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  pnt0 = (IGRdouble *) gen_ptr->poles;
  pnt1 = (IGRdouble *) &gen_ptr->poles[3];

  for (i = 0; i < 3; i++)
  {
    pnt1[i] = pnt0[i] + (pnt1[i] - pnt0[i]) * tleft;
  }

  pnt2 = (IGRdouble *) &gen_ptr->poles[3 * (gen_ptr->num_poles-2)];
  pnt3 = (IGRdouble *) &gen_ptr->poles[3 * (gen_ptr->num_poles-1)];

  for (i = 0; i < 3; i++)
  {
    pnt2[i] = pnt3[i] + (pnt2[i] - pnt3[i]) * tright;
  }

  info.construct_flag = FALSE;
  status = om$send(msg = message GRvg.GRpostabsg(&msg_loc,
                         &crv->module_info, &info,
                         (IGRchar *) gen_ptr, &newid),
                   senderid = NULL_OBJID,
                   targetid = crv->located_obj.objid,
                   targetos = crv->located_obj.osnum);
  EMomerr_hndlr(status, ret_end, "EFcvmvpoles error\n");
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  sts = GRabsg_del_all();

  *curve = gen_ptr;


  ret_end:
    return(status);

}

end implementation GRsubbc;
