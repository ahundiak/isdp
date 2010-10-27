/* $Id: VDbtCmd.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDbtCmd.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbtCmd.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1998/04/05  13:33:18  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/04/98  ah      Creation
 *
 ***************************************************************************/
#ifndef VDbtCmd_include
#define VDbtCmd_include

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
} TVDbtForm;

typedef struct {
  TVDbtForm mgr,set,leaf,tree,stage,rep,attr;

  Form  form;
  int   gadget;
  int   enableWakeup;
  int   initedOK;
  TGRid cmdID;

  OM_S_CLASSLIST classList;

} TVDbtCMD_Info;

#endif

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

/* -------------------------------------------------------
 * Interface to ppl 
 */
extern IGRstat VDbtCMD_MgrInit   __((TVDbtCMD_Info *info));
extern IGRstat VDbtCMD_MgrSleep  __((TVDbtCMD_Info *info));
extern IGRstat VDbtCMD_MgrWakeup __((TVDbtCMD_Info *info));
extern IGRstat VDbtCMD_MgrDelete __((TVDbtCMD_Info *info));

extern IGRstat VDbtCMD_MgrNotifyForm   __((TVDbtCMD_Info *info));
extern IGRstat VDbtCMD_MgrNotifyObject __((TVDbtCMD_Info *info, TGRobj_env *objOE));

extern IGRstat VDbtCMD_MgrClassList __((OM_S_CLASSLIST *classList));

// -------------------------
#if defined(__cplusplus)
}
#endif


