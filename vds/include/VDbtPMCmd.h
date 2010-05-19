/* $Id: VDbtPMCmd.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDbtPMCmd.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDbtPMCmd.h,v $
 * Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 * Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1998/04/22  23:38:56  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/21/98  ah      Creation
 *
 ***************************************************************************/
#ifndef VDbtPMCmd_include
#define VDbtPMCmd_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

typedef struct {
  Form  form;  // Not null impiles created
  int   dis;   // Is displayed
  int   act;   // Is active
  int   mode;  // Place = 0, Mod = 1, Rev = 2
  TGRid id;    // Main object
} TVDbtForm;

typedef struct {
  TVDbtForm pm;

  Form  form;
  int   gadget;
  int   enableWakeup;
  int   initedOK;
  TGRid cmdID;

  OM_S_CLASSLIST classList;

  TVDvlaOE *objVLA;  // Needs to be a pointer because of ppl

} TVDbtCMD_PM_Info;

#endif

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

/* -------------------------------------------------------
 * Interface to Manager 
 */
extern IGRstar VDbtCMD_PM_Init   __((TVDbtCMD_PM_Info *info));
extern IGRstar VDbtCMD_PM_Sleep  __((TVDbtCMD_PM_Info *info));
extern IGRstar VDbtCMD_PM_Wakeup __((TVDbtCMD_PM_Info *info));
extern IGRstar VDbtCMD_PM_Delete __((TVDbtCMD_PM_Info *info));

extern IGRstar VDbtCMD_PM_NotifyForm        __((TVDbtCMD_PM_Info *info));
extern IGRstar VDbtCMD_PM_NotifyObject      __((TVDbtCMD_PM_Info *info, TGRobj_env *objOE));
extern IGRstar VDbtCMD_PM_NotifyObjectFence __((TVDbtCMD_PM_Info *info, TGRobj_env *objOE));

extern IGRstar VDbtCMD_PM_ClassList __((OM_S_CLASSLIST *classList));

 
// -------------------------
#if defined(__cplusplus)
}
#endif








