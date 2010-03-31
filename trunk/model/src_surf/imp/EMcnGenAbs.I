/* ###################   APOGEE COMPILED   ################## */
class implementation EMScone;

#include "EMS.h"
# include "EMSssprops.h"
# include "msdef.h"

method GRgenabsg(IGRlong *EMmsg; IGRshort *matrix_type;
                 IGRmatrix matrix; IGRchar **absgptr)
/*
Abstract

    GENerate ABStract Geometry: This method generates the abstract
    geometry for the class EMScone.

Arguments

    matrix_type - input
        Type of matrix (idenetity, rotation, etc.)

    matrix - input
        Local to world matrix.

    absgptr - output
        The address of the generated abstract geometry.

Algorithm

    Invoke the appropriate method.

Return Status

    MSSUCC - Successful completion
    MSFAIL - Failure

Bugs

Notes

History

    31 Mar 88   AIC     Creation Date
*/
{
  IGRlong   sts = OM_S_SUCCESS;

  /*
   * Initialize
   */
  *EMmsg = MSSUCC;

  switch(me^^EMSsubbs.ss_props & EMSformat)
  {
    case EMSbsplineFormat:
      sts = om$send(msg = message EMSsubbs.GRgenabsg(EMmsg, matrix_type,
                    matrix, absgptr), mode = OM_e_wrt_message,
                    targetid = my_id);
      break;

    case EMSprojectedFormat:
      sts = om$send(msg = message EMSproject.GRgenabsg(EMmsg, matrix_type,
                    matrix, absgptr), mode = OM_e_wrt_message,
                    targetid = my_id);
      break;

    case EMSrevolvedFormat:
      sts = om$send(msg = message EMSrevol.GRgenabsg(EMmsg, matrix_type,
                    matrix, absgptr), mode = OM_e_wrt_message,
                    targetid = my_id);
      break;

    default:
      *EMmsg = EMS_E_InvalidCase;
      goto wrapup;
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMScone.GRgenabsg")
  return(sts);
}

end implementation EMScone;
