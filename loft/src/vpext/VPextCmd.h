/* $Id: VPextCmd.h,v 1.1 2002/04/09 14:45:48 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VPextCmd.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VPextCmd.h,v $
 * Revision 1.1  2002/04/09 14:45:48  ahundiak
 * ah
 *
 * Revision 1.1.1.1  2001/01/04 21:11:11  cvs
 * Initial import to CVS
 *
 * Revision 1.1  1999/05/24  17:58:06  pinnacle
 * ah
 *
 * Revision 1.3  1998/11/29  14:40:16  pinnacle
 * ah
 *
 * Revision 1.2  1998/06/14  16:10:34  pinnacle
 * ah
 *
 * Revision 1.1  1998/06/02  17:23:14  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/15/98  ah      Creation
 *
 ***************************************************************************/
#ifndef VPextCmd_include
#define VPextCmd_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

typedef struct {
  Form  form;  // Not null impiles created
  int   dis;   // Is displayed
  int   act;   // Is active
  TGRid id;    // Main object
} TVPextForm;

typedef struct {
  TVPextForm ext;

  Form  form;
  int   gadget;
  int   enableWakeup;
  int   initedOK;
  TGRid cmdID;

  OM_S_CLASSLIST classList;

  TGRid setID;  // Active set id 
  TGRid pplID;
  
} TVPextCMD_Info;

/* ----------------------------------------------------------
 * Form Interface
 */

#define VPEXT_FORM_G_FILE_NAME 14
#define VPEXT_FORM_G_FILE_WHAT 20
#define VPEXT_FORM_G_FILE_HULL 21
#define VPEXT_FORM_G_FILE_STAT 24
#define VPEXT_FORM_B_FILE_SEND 22

#define VPEXT_FORM_G_SETS 15
#define VPEXT_FORM_G_TREE 16

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

/* -------------------------------------------------------
 * Interface to Manager 
 */
extern IGRstar VPextCMD_Init   __((TVPextCMD_Info *info));
extern IGRstar VPextCMD_Sleep  __((TVPextCMD_Info *info));
extern IGRstar VPextCMD_Wakeup __((TVPextCMD_Info *info));
extern IGRstar VPextCMD_Delete __((TVPextCMD_Info *info));

extern IGRstar VPextCMD_NotifyForm   __((TVPextCMD_Info *info));
extern IGRstar VPextCMD_NotifyObject __((TVPextCMD_Info *info, TGRobj_env *objOE));

extern IGRstar VPextCMD_ClassList __((OM_S_CLASSLIST *classList));

extern IGRstat VPextCMD_ExtractTreeNode __((TVPextCMD_Info *info, TGRid *nodeID));
extern IGRstat VPextCMD_ExtractTree     __((TVPextCMD_Info *info));
extern IGRstat VPextCMD_ExtractSetup    __((TVPextCMD_Info *info));
extern IGRstat VPextCMD_ExtractShip     __((TVPextCMD_Info *info));

/* -------------------------------------------------------
 * Activates Form
 */
#if 0
extern IGRstar VDbtCMD_SetActivateForm    __((TVDbtCMD_Info *info));
extern IGRstar VDbtCMD_LeafActivateForm   __((TVDbtCMD_Info *info));
extern IGRstar VDbtCMD_TreeActivateForm   __((TVDbtCMD_Info *info));
extern IGRstar VDbtCMD_AttrActivateForm   __((TVDbtCMD_Info *info));
extern IGRstar VDbtCMD_StageActivateForm  __((TVDbtCMD_Info *info));
 
/* -------------------------------------------------------
 * Notifies Form
 */
extern IGRstar VDbtCMD_SetNotifyForm    __((TVDbtCMD_Info *info));
extern IGRstar VDbtCMD_LeafNotifyForm   __((TVDbtCMD_Info *info));
extern IGRstar VDbtCMD_TreeNotifyForm   __((TVDbtCMD_Info *info));
extern IGRstar VDbtCMD_AttrNotifyForm   __((TVDbtCMD_Info *info));
extern IGRstar VDbtCMD_StageNotifyForm  __((TVDbtCMD_Info *info));

/* -------------------------------------------------------
 * Set specific functions
 */
extern IGRstat VDbtCMD_SetFillTypes __((Form form, IGRint gadget));

#endif

// -------------------------
#if defined(__cplusplus)
}
#endif

#endif











