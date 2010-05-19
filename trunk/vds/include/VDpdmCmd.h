/* $Id: VDpdmCmd.h,v 1.7 2001/05/14 20:50:08 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDpdmCmd.h
 *
 * Description:	PDM Additional Routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDpdmCmd.h,v $
 * Revision 1.7  2001/05/14 20:50:08  jdsauby
 * CR5180 Update Nodes
 *
 * Revision 1.6  2001/04/12 20:40:33  jdsauby
 * sp 11
 *
 * Revision 1.5  2001/03/29 19:35:58  jdsauby
 * Set Purpose Info command added
 *
 * Revision 1.4  2001/03/08 14:38:02  jdsauby
 * Re - organization of VDpdm.h
 *
 * Revision 1.3  2001/03/05 19:42:56  jdsauby
 * Finish Purpose Info
 *
 * Revision 1.2  2001/02/21 13:03:18  jdsauby
 * CR4088
 *
 * Revision 1.1  2001/02/05 15:48:29  jdsauby
 * JTS MP CR4088
 *
 * Revision 1.1  2000/03/09  21:42:00  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/11/00  js      Creation
 ***************************************************************************/

#ifndef VDpdmCmd_include
#define VDpdmCmd_include

#ifndef   VDtypedefc_include
#include "VDtypedefc.h"
#endif

#ifndef   VDfrmc_include
#include "VDfrmc.h"
#endif

#ifndef   VDpdm_include
#include "VDpdm.h"
#endif

#ifndef   VDpdmDef_include
#include "VDpdmDef.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ------------------------------
 * Classifications structure
 * **/
typedef struct
{
    IGRchar l1 [80];
    IGRchar l2 [80];
    IGRchar l3 [80];
    IGRchar l4 [80];
    IGRchar l5 [80];
    IGRchar l6 [80];
    IGRchar l7 [80];
    IGRchar l8 [80];
    IGRchar l9 [80];
    IGRchar l10[80];
} TVDpdmClass;


// main startup called by PPL
extern IGRstat VDpdmUtilInitMain __(());
    
// clear up some gadgets on forms
// MultiColumn gadget
extern IGRstat VDpdmClearGadgetColumn __((Form form, IGRint gadget));

// List gadget
extern IGRstat VDpdmClearGadgetList __((Form form, IGRint gadget));

// Display non compliant reflist form
extern IGRstat VDpdmDisplayNonCompliantRefList __((TVDpdmInfo    *actInfo,
	                                           VDpdmHullApp  *actShips,
					           TVDpdmRefList *nonList ));


// get the list of purposes from the file $VDS/config/sets/vdpdm_purp.txt
// This function will allocate memory for the list, it is up to the caller
// to free it
extern FILE *VDpdmOpenPurpListFile __(());

extern IGRstat VDpdmFillPurposeListGadget __(( Form   form,
	                                       IGRint gadget));

/* --------------------------------------
 * fill a list gadget
 * ***/
extern IGRstat VDpdmFillGadgetList __(( Form       form,
                                        IGRint     gadget,
	                	        TVDrisInfo *ris ));


/* -------------------------------------------------
 * Fill the revision gadget.
 * I - Form, gadget, catalog, and part
 * **/
extern IGRstat VDpdmFillGadgetRev __((Form    form,
                                      IGRint  gadget,
			              IGRchar *catalog,
			              IGRchar *part));

/* -------------------------------------------------------
 * Fill the part gadget
 * I - form, gadget, catalog
 * **/
extern IGRstat VDpdmFillGadgetPart __(( Form    form,
                                        IGRint  gadget,
			                IGRchar *catalog));


/* -------------------------------------------------------
 * Fill the catalog gadget
 * I - form, gadget, classifications
 * **/
extern IGRstat VDpdmFillGadgetCatalog __(( Form        form,
                                           IGRint      gadget,
			                   TVDpdmClass *class));

/* -------------------------------------------
 * Fill the list of local files gadget
 * I - form, gadget, filename column, filekey column
 * **/
extern IGRstat VDpdmFillMCFActiveFile __(( Form    form,
                                           IGRint  gadget,
				           IGRint  colName,
				           IGRint  colKey ));

/* ---------------------------------------------
 * Form killers and loopers
 * **/

extern IGRstat VDpdmLoopMainForm __(());

extern IGRstat VDpdmKillMainForm __(());

extern IGRstat VDpdmKillPtHullForm __(());
extern IGRstat VDpdmKillHullPtForm __(());
extern IGRstat VDpdmKillNoteBkForm __(());
extern IGRstat VDpdmKillMacroForm  __(());


/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
