/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsplane;

%safe
#include <math.h>
%endsafe


#include "EMS.h"
#include "OMmacros.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
#include "EMSxsection.h"

/*
    History  
             RC      11/18/88      Creation Date
*/

method EMput_alignment_info (
 IGRlong      *EMmsg;
 IGRchar      alignment_info_fmt;
 IGRdouble    *trans_vec,  
              rot_ang,
              *align_mat)
{
  IGRlong OM_stat;
  IGRint  vla_size;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  switch (alignment_info_fmt)
  {
    case EMS_FMT_TRANS_VEC_ROT_ANGLE:
      OM_BLOCK_MOVE (trans_vec, me->alignment_info, sizeof(IGRpoint));
      me->alignment_info[3] = rot_ang;
      break;

    case EMS_FMT_MATRIX:

      vla_size = om$dimension_of (varray = me->alignment_info);
      if (vla_size < 16)
      {
       OM_stat = om$vla_set_dimension (varray = me->alignment_info,
                                       size = 16);
       EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      } /* if (vla_size < 16) */

      OM_BLOCK_MOVE (align_mat, me->alignment_info, 
                     sizeof(IGRdouble) * 16);
      break;

    default:
     break;
  } /* switch (alignment_info_fmt) */
 
  me->alignment_info_fmt = alignment_info_fmt;

 wrapup:
  EMWRAPUP (OM_stat, *EMmsg, "In EMSxsplane.EMput_alignment_info");
  return (OM_stat);
}
end implementation EMSxsplane;
