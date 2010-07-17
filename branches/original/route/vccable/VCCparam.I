
/* $Id: VCCparam.I,v 1.2 2001/02/20 01:08:55 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable / VCCparam.I
 *
 * Description:
 *   This file contains the method maintaining attributes
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCparam.I,v $
 *     Revision 1.2  2001/02/20 01:08:55  build
 *     Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/01  20:40:10  pinnacle
# Replaced: vccable/VCCparam.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.1  1997/10/07  06:31:48  pinnacle
# Created by apazhani .
#
 *
 * History:
 *        10/07/97        Alwin      Creation. Implemented this method to 
 *                                   expose these attributes, "tail_length"
 *                                   and "estim_length"; which are specific to
 *                                   CABLE object only.
 *
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG        1
#define MY_DEBUG	1
*/

#include "ACrg_collect.h"
#include "parametric.h"
#include "vc_param.h"
#include "vrdbgmacros.h"


method  VCGetInsPar (IGRlong   *msg;
                     IGRshort  *nNbPar;
              struct ACrg_coll *Coll)
{
  IGRint      status, direct_index = -1;
  IGRchar     szTag[VC_MAX_TAGNO];
  struct  ret_struct strLength;

SetProc(VCCable_VCGetInsPar ); Begin

  *msg    = MSSUCC;
  *nNbPar = 0;

  /* Get the common attributes from the "Super Class" Implementation */
  status = om$send ( msg = message VCRoot.VCGetInsPar ( msg, nNbPar, Coll ),
                              mode = OM_e_wrt_message,
                              targetid = my_id );
#ifdef MY_DEBUG
  printf("\n No of Params in Common = %d \n", *nNbPar );
#endif MY_DEBUG

  if (Coll)
  {
    Coll[*nNbPar].desc.type = AC_ATTRIB_DOUBLE;
    strcpy (Coll[*nNbPar].name, VC_N_TAIL_LENGTH_DB);

    status =
    om$send (msg = message VCRoot.ACgive_structure ( (IGRint*)msg, 
                                 &direct_index, VC_N_TAIL_LENGTH_DB, 
                                 &strLength, &VCANGLB_mdenv ),
                              targetid = my_id);

#ifdef MY_DEBUG
    printf("\n Tail_Length = %g \n", strLength.var.root_pm_st.value );
#endif MY_DEBUG

    Coll[*nNbPar].desc.value.att_exp = strLength.var.root_pm_st.value;
  }
  (*nNbPar)++;

  if (Coll)
  {
    Coll[*nNbPar].desc.type = AC_ATTRIB_DOUBLE;
    strcpy (Coll[*nNbPar].name, VC_N_ESTIM_LENGTH_DB);

    status =
    om$send (msg = message VCRoot.ACgive_structure ( (IGRint*)msg, 
                                 &direct_index, VC_N_ESTIM_LENGTH_DB, 
                                 &strLength, &VCANGLB_mdenv ),
                              targetid = my_id);

#ifdef MY_DEBUG
    printf("\n Estimated_Length = %g \n", strLength.var.root_pm_st.value );
#endif MY_DEBUG

    Coll[*nNbPar].desc.value.att_exp = strLength.var.root_pm_st.value;
  }
  (*nNbPar)++;

End;
  return (OM_S_SUCCESS);
}

end implementation VCCable;
