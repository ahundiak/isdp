
/* $Id: VCCmdPTins.I,v 1.2 2001/02/20 01:09:40 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmd/VCCmdPTins.I
 *
 * Description:
 *      Implementation of insert terminal
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdPTins.I,v $
 *        Revision 1.2  2001/02/20 01:09:40  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1998/12/22  17:02:58  pinnacle
# Replaced: vccmd/VCCmdPTins.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.9  1997/07/14  22:52:50  pinnacle
# Replaced: vccmd/VCCmdPTins.I for:  by hverstee for cabling
#
# Revision 1.8  1997/04/28  22:35:38  pinnacle
# Replaced: vccmd/VCCmdPTins.I for:  by hverstee for cabling
#
# Revision 1.7  1997/03/12  21:57:12  pinnacle
# Replaced: vccmd/VCCmdPTins.I for:  by hverstee for cabling
#
# Revision 1.6  1997/01/03  18:13:48  pinnacle
# Replaced: vccmd/VCCmdPTins.I for:  by hverstee for cabling
#
# Revision 1.5  1996/12/18  17:47:12  pinnacle
# Replaced: vccmd/VCCmdPTins.I for:  by hverstee for cabling
#
# Revision 1.4  1996/10/30  15:27:40  pinnacle
# Replaced: vccmd/VCCmdPTins.I for:  by hverstee for cabling
#
# Revision 1.3  1996/10/08  21:59:26  pinnacle
# Replaced: vccmd/VCCmdPTins.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/03  18:31:10  pinnacle
# Replaced: vccmd/VCCmdPTins.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:16:44  pinnacle
# Created: vccmd/VCCmdPTins.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        12/02/98        law       TR179801645-Change parent repair.
 *
 *************************************************************************/

class implementation VCCmdPT;

#include "VCCmdForm.h"
#include "VCcreate.h"
#include "vrdbgmacros.h"

/*
#define   MY_DEBUG
*/

from   GRgraphics      import   GRdisplay;



/****************************************************************************
   Create a terminal macro.  Place it under parent eqpt or coord sys
****************************************************************************/

method VCCmdInsert ( int * sts )
{
  int		          status;
  IGRlong                 msg;
  struct GRid             ParId[4];
  IGRint                  NumPar;
  enum GRdpmode           Mode;
  IGRint                  i;
SetProc(Md- VCCmdInsert); Begin
  for(i=0;i<4;i++) 
  {
    ParId[i].objid      = NULL_OBJID;
    ParId[i].osnum      = me->ModuleInfo.md_id.osnum;
  }
  /*TR179801645 */
  __DBGpr_int("nVCConn_type was ",me->nVCConn_type);
  me->nVCConn_type = me->nVCConn_type | VC_TOFF_C_FULL;  
  __DBGpr_int("nVCConn_type was ",me->nVCConn_type);
  if(me->nVal != 16)
  {
    me->nVal = 16;
    MAidmx (&msg, me->dValues);
  }
  __DBGpr_mat("dValues ",me->dValues);

  /* No attribute coll. for virtual terms  */
  if (!(me->nVCConn_type & VC_GEN_VIRTUAL))
  {
    status =
    om$send (msg = message VCAT.VCAT_coll (&msg, &ParId[0], &ParId[1]),
        targetid = my_id);

    me->GenInfo.nNbAttr       = 2;
  }
  else
    me->GenInfo.nNbAttr       = 0;

  NumPar = me->GenInfo.nNbAttr;

  if (me->RefId.objid != NULL_OBJID)
  {
    ParId[me->GenInfo.nNbAttr] = me->RefId;
    NumPar++;
  }

  /*C Verify against database ... ?? */

  me->GenInfo.nStat        = VC_STATUS_INIT;
  me->GenInfo.nType        = me->nVCConn_type;
  me->GenInfo.cRep         = me->nACTrep;
  me->GenInfo.nProduct     = me->Product;
  me->GenInfo.nNbTopo      = 1; 
  me->GenInfo.bNoMtoFlg    = me->bMTO;

  strcpy (me->GenInfo.szCode,  me->CompCode);
  strcpy (me->GenInfo.szTagno, me->TagNum);

  me->GenInfo.Attr.Term.nCpt           = me->nCpt;
  me->GenInfo.Attr.Term.nOff           = me->nVal;
  me->GenInfo.Attr.Term.dOffVal        = me->dValues;

  /*A ----- Create & Place Component  ----- */
  
  status = 
  VC_CreateTerm (&msg, NumPar, ParId, &me->GenInfo, me->ActiveLevel,
                 &me->ActiveDisplay, &me->ModuleInfo, &me->ConstrId);

  if (msg == MSSUCC)
  {
    GRabsg_del_all();      /*    ??????   */

    Mode = GRbd;
    status = 
    om$send (msg = message GRgraphics.GRdisplay (&msg, 
                                 &me->ModuleInfo.md_env.matrix_type,
                                  me->ModuleInfo.md_env.matrix, 
                                 &Mode, 
                                 &me->ModuleInfo.md_id),
        targetid = me->ConstrId.objid,
        targetos = me->ConstrId.osnum);

    /*   collections used   */

    VC_INITSTR (me->TagNum);

    me->nSysref++;
    me->nUsrref++;
  }

  /*   Dehighlight refid    */

  dp$erase_hilite (msg = &msg,
                 osnum = me->RefId.osnum);

  /*   all done, reset ID's    */
  me->ConstrId.objid = NULL_OBJID;
  me->RefId.objid    = NULL_OBJID;  

  if (me->bTERM)
    *sts = VC_RTC_DONE;
  else
    *sts = VC_RTC_ALLOK;
End
  return OM_S_SUCCESS;
}

end implementation VCCmdPT;
