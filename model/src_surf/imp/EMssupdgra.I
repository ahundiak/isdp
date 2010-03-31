/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*
HISTORY:

Long Ago:  ?? 	Creation.
08/26/92:  NP	Modified for ANSI compliance.

*/


# include "EMS.h"

# include "EMSfrtdef.h"

extern IGRchar EMSrltBuffer[RLT_BUFFER_SIZE];

from EMSgradata import EMupdate;

method EMupdateGradata(IGRlong          *EMmsg;
                       IGRshort         *matrix_type;
                       IGRmatrix        matrix)
{
  IGRlong               sts = OM_S_SUCCESS;
  OM_S_CHANSELECT       to_gradata;
  struct IGResqbs       *rlt = NULL;
  struct EMSpartolbasis partol;

  partol.is_valid = FALSE;
  partol.mattyp = matrix_type;
  partol.mat = matrix;
    
  sts = om$make_chanselect(channame = "EMSrequester.to_helpers", 
                     p_chanselect = &to_gradata);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  sts = om$send(msg = message EMSgradata.EMupdate(EMmsg,
                        matrix_type,
                        matrix,
                        &rlt,
                        NULL,
                        NULL,
                        EMSrltBuffer,
                        RLT_BUFFER_SIZE,
                        &partol),
                p_chanselect = &to_gradata);
  EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:

  EMWRAPUP(*EMmsg,sts, "EMSsubbs.EMupdateGradata")
  if(rlt && (rlt ISNT (struct IGResqbs *)EMSrltBuffer)) om$dealloc(ptr=rlt);
  return(sts);
}

end implementation EMSsubbs;
