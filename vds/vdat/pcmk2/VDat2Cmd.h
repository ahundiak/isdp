/* $Id: VDat2Cmd.h,v 1.3 2001/04/12 19:12:26 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDat2Cmd.h
 *
 * Description: Command Routines, mostly the new piece mark stuff
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDat2Cmd.h,v $
 *      Revision 1.3  2001/04/12 19:12:26  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/22 14:41:47  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/18 22:49:45  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/16/01  ah      Creation
 ***************************************************************************/

#ifndef VDat2Cmd_include
#define VDat2Cmd_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* -----------------------------------------------
 * The routines
 */
extern void VDat2SetCmdStatusForm   __((Form form));
extern void VDat2SetCmdStatus       __((IGRint flag, IGRchar *msg));

extern void VDat2FormFillPcmkList   __((Form   form, 
					IGRint listGadget, 
					IGRint nextGadget, 
					IGRint procButton, 
					TGRid *treeID,
					TGRid *ssID,
					IGRint risNextPcmk));

extern void VDat2FormSyncPcmkList   __((Form form, IGRint gadget, TGRid *treeID));

extern void VDat2FormClearPcmkList  __((TGRid *treeID));

extern void VDat2FormNotifyGenerate __((Form form, IGRint nextPcmk, TGRid *treeID));
extern void VDat2FormNotifyVerify   __((Form form, IGRint nextpcmk, TGRid *treeID, TGRid *ssID));
extern void VDat2FormNotifyValidate __((Form form, TGRid *treeID));


//Cleanup
#if defined(__cplusplus)
}
#endif

#endif
