
/* $Id: VCCmdPBins.I,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdPBins.I
 *
 * Description:
 *      Implementation file for place backshell command object
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdPBins.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.1  1997/07/14  22:58:46  pinnacle
# Created: vccmd/VCCmdPBins.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *
 *************************************************************************/

class implementation VCCmdPB;

#include "VCCmdForm.h"
#include "VCcreate.h"

/*
#define MY_DEBUG
*/

from  GRgraphics import   GRdisplay;


/*=======================================================================*/

method VCCmdInsert ( int * sts )
{
  IGRint                  status;
  IGRint                  i;
  IGRint                  NumPar;
  IGRlong                 retmsg;
  struct GRid             parId[4];
  enum GRdpmode           Mode;

  /*  define the parent   */

  for(i=0;i<4;i++)
  {
    parId[i].objid      = NULL_OBJID;
    parId[i].osnum      = me->ModuleInfo.md_id.osnum;
  }

  /*  attribute parents   */
  status =
  om$send (msg = message VCAT.VCAT_coll (&retmsg, &parId[0], &parId[1]),
      targetid = my_id);

  me->GenInfo.nNbAttr       = 2;

  parId[me->GenInfo.nNbAttr] = me->RefId;
  NumPar                     = 3;

  me->GenInfo.nStat         = VC_STATUS_INIT;
  me->GenInfo.nType         = me->nVCConn_type;
  me->GenInfo.cRep          = me->nACTrep;
  me->GenInfo.nNbTopo       = 1;
  me->GenInfo.nProduct      = me->Product;
  me->GenInfo.bNoMtoFlg     = me->bMTO;

  strcpy (me->GenInfo.szCode, me->CompCode);
  VC_INITSTR (me->GenInfo.szTagno);

  me->GenInfo.Attr.Term.nCpt           = 0;
  me->GenInfo.Attr.Term.nOff           = me->nVal;
  me->GenInfo.Attr.Term.dOffVal        = me->dValues;

  status =
  VC_CreateBksh (&retmsg, NumPar, parId, &me->GenInfo, me->ActiveLevel,
                 &me->ActiveDisplay, &me->ModuleInfo, &me->ConstrId);


  if (retmsg == MSSUCC)
  {
    /*K Delete GRNUC buffer in order to display the right geometry */
    GRabsg_del_all();

    /*C Display my */
    Mode = GRbd;
    status =
    om$send( msg = message GRgraphics.GRdisplay( &retmsg,
                                        &me->ModuleInfo.md_env.matrix_type,
                                         me->ModuleInfo.md_env.matrix,
                                        &Mode, &me->ModuleInfo.md_id ),
        targetid = me->ConstrId.objid,
        targetos = me->ConstrId.osnum );

    VC_INITSTR (me->TagNum);

    me->nSysref++;
    me->nUsrref++;
#ifdef MY_DEBUG
    printf ("coll used %d %d \n",me->nSysref, me->nUsrref);
#endif
  }

  /*   Dehighlight reference    */

  dp$erase_hilite (msg = &retmsg,
                 osnum = me->RefId.osnum);

  /*   all done, reset ID's    */
  me->ConstrId.objid = NULL_OBJID;
  me->RefId.objid    = NULL_OBJID;

  if (me->bTERM)
    *sts = VC_RTC_DONE;
  else
    *sts = VC_RTC_ALLOK;

  return OM_S_SUCCESS;
}

end implementation VCCmdPB;

