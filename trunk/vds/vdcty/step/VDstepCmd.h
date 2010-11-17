/* $Id$  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdcty/step/VDstepCmd.h
 *
 * Description: STEP Command Include File
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDstepCmd.h,v $
 *      Revision 1.1.2.1  2004/11/29 16:27:16  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/29/04  ah      Creation
 ***************************************************************************/

#ifndef VDstepCmd_include
#define VDstepCmd_include

#ifndef   VDtag_include
#include "VDtag.h"
#endif

#ifndef   VDfrmc_include
#include "VDfrmc.h"
#endif

#ifndef   VDpdm_include
#include "VDpdm.h"
#endif

#ifndef   VDtest_include
#include "VDtest.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* -----------------------------------------------
 * Turn all command tracing on or off
 */
#define VDSTEP_TRACE 1

// Need to put these in VDfrmc.h
#define VDfrmShowg(form,gadget) VIg_display(form,gadget)
#define VDfrmHideg(form,gadget) VIg_erase  (form,gadget)

/* -----------------------------------------------
 * Create Snap Shot
 */
#define VDSTEP_FORM_EXPORT227_NAME    "STEP_AP227.F"
#define VDSTEP_FORM_EXPORT227_NUM      125

#define VDSTEP_FORM_EXPORT227_G_FILENAME 13
#define VDSTEP_FORM_EXPORT227_G_XML_SS   16
#define VDSTEP_FORM_EXPORT227_G_XML_EDO  17
#define VDSTEP_FORM_EXPORT227_B_SELECT   18
#define VDSTEP_FORM_EXPORT227_G_STATUS   19


extern void    VDtestExport227        __((TVDtestTestInfo *testInfo));

extern IGRstat VDstepCmdInitExport227 __((TVDtestTestInfo *testInfo, 
                                         VDobjid pplObjid, 
                                         VDosnum pplOsnum));

extern void    VDstepCmdKillExport227 __(());
extern void    VDstepCmdLoopExport227 __(());

extern IGRint  VDstepCmdNotifyExport227 __((IGRint    f_label,
					   IGRint    gadget,
					   IGRdouble value,
					   Form      form));

extern void VDstepCmdObjectExport227 __((TGRobj_env *objOE));

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif
