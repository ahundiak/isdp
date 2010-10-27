/* $Id: VDaimCM.h,v 1.4 2002/05/28 20:08:37 tlstalli Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDaimCM.h
 *
 * Description:	CM Defines and Globals
 *
 * Dependencies:
 *
 * Revision History:
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/08/01  js      Creation
 ***************************************************************************/

#ifndef VDaimCM_include
#define VDaimCM_include

#ifndef   VDtypedefc_include
#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* Tracing of various AIM functions
 * **/
#define AIM_CM_TRACE_ADD_PART      170

/* CM states */
#define DEVELOPMENT	"Development"
#define CHECKING	"Checking"
#define CADVALIDATION	"Cad Validation"
#define REVIEW		"Review"
#define BASELINE	"Baseline"
#define RELEASE		"Release"
#define AVD_CM_WFLOW	"CM WORKFLOWr9"

/* Global CM Functions */
/*******************************************************
 * Function to determine if AIM is loaded.  This function is 
 * overwritten in the AIM code to return 1.
 * **/
extern int VDaimIsAimLoaded __(());
   
extern int CMstate_form __(());

/* To Query Context Rev, Name and Type from SIR_PDM_TABLE */
extern int PDMGetAttrsfromSirTable __((char *Catalog, char *Partid, char *Revision,
                            char *CntxtRev, char *CntxtName, char *CntxtType));

//                  Mainly searchst was to small but I went ahead and made the other
//					variables larger as well.
extern int PDMInfoOnCommandbar __((char *catalog, char *partid, char *revision));

extern int CheckAllowed __(());

/************************************************************
* Function CMReject
* IF a state is back to development, change the ARs selcted to WORKING
***************************************************/
extern int CMReject __(());

/********************************************
* Function CMRelease
* this is to Release the part.
* in SIR it changes the relaitonship to implemented
*****************************************************/
extern int CMRelease __(());

/*********************************************************
* Function: CMar_form
*
*
*
***********************************************************/
extern int CMar_form __(( char *catalog, char *partno, char *rev ));

/**********************************************************
* Function CMBaseline
* if file is CMEnabled, 1. baseline MDC, 2. Change the relation
* If not ; Just baseline the MDC
**********************************************************/

extern int CMBaseline __(());


//TLS 5-28-02 Added for new AMDC Phase II changes
/************************************************************
* Function CMCheckFile
* Check the file to make sure that DCC or an AR is selected 
* before doing any CM processing on the file.
***************************************************/

extern int CMCheckFile __(());


extern int IsRetOK __(());

/*******************************************************************
* SrCMCopySim()
* Function to take care about copy similar of a part.
* Nothing to worry about if it is a new part.
* If it is a revision, if old file is under CM control, MDC is baselined
* Revisioning is allowed only in Baseline and Release states.
*******************************************************************/
extern int SrCMCopySim __((char *CMMdcRev, char *t_LpdDesc));

/* added code Pullabhotla -  Function to Insert Attributes into SIR_PDM_TABLE
 */
extern int PDMInsertSirTable __((char *Refcat, char *Refpart, char *Refrev));

extern int SrValidateforRet __(( char *cat, char *part, char *rev ));

/***************************************************************
 * Added by Anjani
 * SirVDUpdCMAttrs updates the values in the SirPdmtable attributes 
 * which are written for CM management purpose
 * **************************************************************/
extern int SirVDUpdCMAttrs __(( char *catalog, 
                                char *partid, 
		                char *revision, 
		                char *Attr,
                                char *Value ));










/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
