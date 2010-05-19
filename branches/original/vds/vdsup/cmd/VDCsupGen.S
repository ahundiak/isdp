/* $Id: VDCsupGen.S,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/cmd/VDCsupGen.S
 *
 * Description:
 *      The Command Object provides a form interface for placing/modifying 
 *	support curves.
 *
 *   Single support curves        VDsupCrv.frm
 *   Offset support curves        VDsupOff.frm
 *   Equidistant support curves   VDsupEqu.frm
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCsupGen.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/10/29  15:20:56  pinnacle
# Added Headers
#
 *
 * History:
 *      MM/DD/YY   AUTHOR  DESCRIPTION
 *      10/29/97   ah      added header
 *      07/11/97   EJM     CR#179701494  Support curve enhancements
 *                         Added message VDCsupSwapTrace
 ***************************************************************************/

class specification VDCsupGen (1:0) of VDS_LOCATE;

#include "VDmaster.h"

#include "VDsupMac.h"
#include "VDCsupForm.h"

instance VDCsupGen
{
  Form form_ptr;

  int  initFlag;
  int  ClearFlag;
  int  locateFlag;
  int  sleepFlag;

  TGRid  supId; /* Support curve to modify */

  TGRid  tl[VDSUP_I_MAX];  /* Template List */

  VDCsupFBI fbiList[32];

};

/* Need to use int here because of slic file */
message VDCsupIsBaseSurfDefined(int *msg);

message VDCsupSetSupport   (int *msg);

message VDCsupSetTraces    (int *msg);

message VDCsupSetObject    (int *msg; int gadget);

message VDCsupEraseHilite1 (int *msg);
message VDCsupSetLocateFlag(int *msg; int flag);

message VDCsupSetExpForm(int *msg; int label);

message VDCsupDelTrace(int *msg);

message VDCsupSaveFormLoc();

message VDCsupSwapTrace(int *msg; int gadget_label);

override init;
override delete;

end specification VDCsupGen;


