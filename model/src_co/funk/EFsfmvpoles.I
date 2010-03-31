/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "bserr.h"
#include "msdef.h"
#include "bsfreesf.h"
#include "bsexch_u_v.h"
#include "bsallocsf.h"

IGRlong EFsrf_move_poles(msg, srf, u, v, tleft, tright, surf)
IGRlong   *msg;              /* error return code */
struct GRlc_info   *srf;     /* input surface's info */
IGRboolean   u, v;           /* input direction to move poles in */
IGRdouble    tleft, tright;  /* input t value of side to move */
struct IGRbsp_surface **surf; /* output surface geometry */

/*
Abstract
    This function moves the second or second to the last row or column of
    poles according to the equation: x = x0 + (x - x0) * t.

Notes
    The variable, u, means constant in u which would make it a column.
    The variable, v, means constant in v which would make it a row.
    The variables, tleft and tright, are used to indicate t value for
    the second row or t value for second to last row, respectively.
    This function posts the new geometry to the object, srf, and returns
    the geometry, surf.

History
    dhm    10/5/88    creation date.
    Sudha   06/02/93        modified to include for BSprototype headers
*/

{
  IGRlong   msg_loc, status, size;
  IGRint    i, j;
  IGRboolean  sts;
  extern IGRboolean   GRabsg_del_all();
  IGRdouble      *row0, *row1, *row2, *row3;
  GRobjid        newid;
  struct IGRbsp_surface  *tempsurf, *gen_ptr;
  struct GRpost_info  info;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  tempsurf = NULL;
  gen_ptr = NULL;

  status = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                         &srf->module_info.md_env.matrix_type,
                         srf->module_info.md_env.matrix, &size),
                   senderid = NULL_OBJID,
                   targetid = srf->located_obj.objid,
                   targetos = srf->located_obj.osnum);
  EMomerr_hndlr(status, ret_end, "EFmovepoles error\n");
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  gen_ptr = (struct IGRbsp_surface *) om$malloc(size = size);
  EMerr_hndlr(!gen_ptr, *msg, MSNOMEM, ret_end);

  status = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                         &srf->module_info.md_env.matrix_type,
                         srf->module_info.md_env.matrix, (IGRchar *)gen_ptr),
                   senderid = NULL_OBJID,
                   targetid = srf->located_obj.objid,
                   targetos = srf->located_obj.osnum);
  EMomerr_hndlr(status, ret_end, "EFmovepoles error\n");
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);


  if (u)
  {
    BSallocsf(gen_ptr->v_order, gen_ptr->u_order, gen_ptr->v_num_poles,
              gen_ptr->u_num_poles, gen_ptr->rational,
              gen_ptr->num_boundaries, &tempsurf, &msg_loc);
    EMerr_hndlr(msg_loc != BSSUCC, *msg, MSNOMEM, ret_end);

    sts = BSexch_u_v(&msg_loc, gen_ptr, tempsurf);
    EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
  }
  else
    tempsurf = gen_ptr;

  row0 = (IGRdouble *) tempsurf->poles;
  row1 = (IGRdouble *) &tempsurf->poles[3 * tempsurf->u_num_poles];

  for (i = 0; i < tempsurf->u_num_poles; i++)
  {
    for (j = 0; j < 3; j++)
    {
      row1[j] = row0[j] + (row1[j] - row0[j]) * tleft;
    }

    row0+=3;
    row1+=3;
  }


  row2 = (IGRdouble *) &tempsurf->poles[(tempsurf->v_num_poles-2) * 
                                       tempsurf->u_num_poles * 3];
  row3 = (IGRdouble *) &tempsurf->poles[(tempsurf->v_num_poles-1) * 
                                       tempsurf->u_num_poles * 3];

  for (i = 0; i < tempsurf->u_num_poles; i++)
  {
    for (j = 0; j < 3; j++)
    {
      row2[j] = row3[j] + (row2[j] - row3[j]) * tright;
    }

    row2+=3;
    row3+=3;
  }

  if (u)
  {
    sts = BSexch_u_v(&msg_loc, tempsurf, gen_ptr);
    EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
  }

  info.construct_flag = FALSE;
  status = om$send(msg = message GRvg.GRpostabsg(&msg_loc,
                         &srf->module_info, &info,
                         (IGRchar *) gen_ptr, &newid),
                   senderid = NULL_OBJID,
                   targetid = srf->located_obj.objid,
                   targetos = srf->located_obj.osnum);
  EMomerr_hndlr(status, ret_end, "EFmovepoles error\n");
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  sts = GRabsg_del_all();

  *surf = gen_ptr;


  ret_end:
    if ( u && tempsurf)  BSfreesf(&msg_loc, tempsurf);

    return(status);

}

end implementation EMSsurface;
