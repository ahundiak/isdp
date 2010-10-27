/* $Id: VDpdm.h,v 1.20 2002/05/10 19:33:38 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDpdm.h
 *
 * Description:	PDM Routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDpdm.h,v $
 * Revision 1.20  2002/05/10 19:33:38  ahundiak
 * ah
 *
 * Revision 1.19  2001/11/08 20:12:15  jdsauby
 * JTS MP TR 5764, added cache routines - jds
 *
 * Revision 1.18  2001/10/03 14:09:42  jdsauby
 * JTSMP CRs 5448,5527,5591
 *
 * Revision 1.17  2001/09/05 18:10:42  jdsauby
 * JTS TR 5545
 *
 * Revision 1.16  2001/07/26 13:32:30  jdsauby
 * MP5447 - jds
 *
 * Revision 1.15  2001/06/29 16:45:17  jdsauby
 * Modified for TR3403
 *
 * Revision 1.14  2001/06/04 13:06:41  jdsauby
 * CR3403, new replace part
 *
 * Revision 1.13  2001/05/14 20:50:08  jdsauby
 * CR5180 Update Nodes
 *
 * Revision 1.12  2001/04/24 20:39:25  jdsauby
 * Post table timestamp  CR 4474
 *
 * Revision 1.11  2001/04/12 20:40:31  jdsauby
 * sp 11
 *
 * Revision 1.10  2001/03/30 20:32:10  jdsauby
 * js
 *
 * Revision 1.9  2001/03/29 19:35:55  jdsauby
 * Set Purpose Info command added
 *
 * Revision 1.8  2001/03/08 14:37:59  jdsauby
 * Re - organization of VDpdm.h
 *
 * Revision 1.7  2001/03/07 19:06:00  jdsauby
 * Added VDpdmStartup to be used in VDCmdStrtupi
 *
 * Revision 1.6  2001/03/05 19:42:54  jdsauby
 * Finish Purpose Info
 *
 * Revision 1.5  2001/03/02 21:40:28  jdsauby
 * Added purpose Info
 *
 * Revision 1.4  2001/02/23 16:09:10  jdsauby
 * Added RefList structure
 *
 * Revision 1.3  2001/02/21 13:03:15  jdsauby
 * CR4088
 *
 * Revision 1.2  2001/01/14 16:11:39  art
 * sp merge
 *
 * Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 * Initial import to CVS
 *
 * Revision 1.1  2000/03/09  21:42:00  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/08/00  ah      Creation
 * 12/11/00  ah      c friendly
 * 01/12/01  ah      sp17 merge
 ***************************************************************************/

#ifndef VDpdm_include
#define VDpdm_include

#ifndef   VDtypedefc_include
#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif
#endif

#ifndef   VDpdmDef_include
#include  "VDpdmDef.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* -----------------------------------------------
 * Called from VDStartup
 * Sets the PDM, Purpose Infos, and checks approved
 * hull configurations.
 * ***/
extern IGRstat VDpdmStartup __(());

/* -----------------------------------------------
 * Compare approved for hull configurations of active
 * file to that of each reference file.
 * ***/
extern IGRstat VDpdmCompareCfgRefToActive __(( VDpdmHullApp *actShips, 
	                                       IGRint       *ref_filekey,
		                               IGRchar      *ref_rev));

/* ------------------------------------------------
 * External Functions used.    vdpdm/func/VDpdmFileKey.C
 * */
/* set the file key for Catalog, Part, Revision */
extern IGRstat VDpdmSetFileKeyForCPR __(( IGRchar *catalog,
	                                  IGRchar *part,
					  IGRchar *revision,
					  IGRint  *fileKey ));

/* get the file key for Catalog, Part, Revision */
extern IGRstat VDpdmGetFileKeyForCPR __(( IGRchar *catalog,
	                                  IGRchar *part,
					  IGRchar *revision,
					  IGRint  *fileKey ));

/* get the catalog, part, and rev for a filekey */
extern IGRstat VDpdmGetCPRForFilekey __(( IGRint  *fileKey,
	                                  IGRchar *catalog,
					  IGRchar *part,
					  IGRchar *rev   ));
/* Get the filekey for an osnum */
extern IGRstat VDpdmGetFilekeyForOS __((VDosnum  osnum,
                                        IGRint   *filekey));

/* --------------------------------------------------------------
 * Returns pdu username and user_id
 * **/
extern IGRstat VDpdmGetUsernameID __(( IGRchar *username, IGRlong *userid ));

/* ------------------------------------------------------------------------
 * Verifies logged into pdm
 */
extern IGRstat VDpdmVerifyLogin __(());
  
/* ----------------------------------------------------
 * Main interface for getting pdm info
 */
extern IGRstat VDpdmGetPdmInfo __((VDosnum  osnum, TVDpdmInfo *pdmInfo));

#ifndef c_ONLY
#omdef vdpdm$GetPdmInfo(osnum = OM_K_NOT_AN_OS, pdmInfo)
VDpdmGetPdmInfo((osnum),(pdmInfo))
#endomdef
#endif

/* ----------------------------------------------------
 * Gets either the expression object or it's value
 */
extern IGRstat VDpdmGetPdmInfoExp __((VDosnum  osnum, 
				      TGRid   *objID, 
				      IGRchar *path,
				      IGRchar *text));

#ifndef c_ONLY
#omdef vdpdm$GetPdmInfoExp(osnum = OM_K_NOT_AN_OS,
			   objID = NULL,
			   path  = NULL,
			   text  = NULL)
VDpdmGetPdmInfoExp((osnum),(objID),(path),(text))
#endomdef
#endif

/* ------------------------------------------------------------------------
 * Creates, validates or updates the pdm info expression
 * Designed to be called during file retrieval to ensure
 * the expression is up to date
 */
extern IGRstat VDpdmUpdatePdmInfo __((VDosnum osnum));
  
#ifndef c_ONLY
#omdef vdpdm$UpdatePdmInfo(osnum = OM_K_NOT_AN_OS)
VDpdmUpdatePdmInfo(osnum)
#endomdef
#endif

/* --------------------------------------------------------------
 * Just like the pdm info functions, for Purpose Info
 * ***/

// Get Purpose Info for osnum
extern void VDpdmGetPurposeInfo __((VDosnum osnum, TVDpdmPurposeInfo *purpInfo));

// Query from database Purpose Info for fileKey
extern void VDpdmQryPurposeInfo __((IGRint fileKey, TVDpdmPurposeInfo *purpInfo));

// Set Purpose Info for osnum
extern void VDpdmSetPurposeInfo __((VDosnum osnum, TVDpdmPurposeInfo *purpInfo));

// Called when file is retrieved to sync exp with database
extern void VDpdmUpdatePurposeInfo __((VDosnum osnum));

/* ------------------------------------------
 * Check zone, unit, or system values depending on
 * purpose
 * **/
extern IGRstat VDrrvCheckPurposeValues __(( TVDpdmPurposeInfo *info,
                                            IGRchar           *msg ));

/* ---------------------------
 * Set Purpose info form
 * **/
extern IGRstat VDpdmCmdSetPurposeInfo __((VDosnum           osnum,
                                          TVDpdmPurposeInfo *info));

/* ------------------------------------------
 * Approved Coonfiguration
 * ***/

/* ---------------------------------------------------------------
 * Find a revision that matches approved hull configuration
 * **/
extern IGRstat VDpdmGetApprCfgRevision __((VDpdmHullApp *actShips,   /* Input */
                                           IGRint       *filekey,    /* Input */
				           IGRchar      *app_rev));  /* Output */

// Sets the default approved configuration '0' for a CPR
extern IGRstat VDpdmSetDefaultApprCfgForCPR __(( IGRchar *catalog,
	                                         IGRchar *part,
						 IGRchar *revision ));

/* ----------------------------------------------------
 * Get the Approved For Hull Config given a filekey.
 * Put it into the VDpdmHullApp struct given a fileKey
 * ***/
extern IGRstat VDpdmGetApprCfgforFilekey __((IGRint       *fileKey,
	                                     VDpdmHullApp *ships));

extern IGRstat VDpdmGetHullAppforFilekey __((IGRint       *filekey,
	                                     VDpdmHullApp *ships));
 
/* ------------------------------------------
 * Check if revision is valid.  A valid revision has
 * no alpha characters.  It is purely numeric.
 * **/
extern IGRstat VDpdmIsRevisionValid __((IGRchar *revision));

/* -------------------------------------------------
 * Places a post_date record for the input dynamic table
 * **/
extern IGRstat VDpdmPostTableTimestamp __(( IGRchar  *dyn_table ));

/* -------------------------------------------------
 * vdpdm/func/VDpdmReplPrt.I
 * **/
extern IGRstat VDpdmGetPartDescription __((IGRchar *catalog,
                                           IGRint   itemno,
				           IGRchar *descr));

extern IGRstat VDpdmGetCatalogNo __((IGRchar *catalog,
                                     IGRint  *catno));

extern IGRstat VDpdmGetItemNo __((TVDpdmInfo *info,
                                  IGRint     *itemno));

extern IGRstat VDpdmIsPartCheckedOut __((TVDpdmInfo  *info,
                                         IGRint      catno,
			                 IGRint      itemno));

extern IGRstat VDpdmIsViewsAvailable __((IGRchar *catalog,
                                         IGRint  *itno_old,
			                 IGRint  *itno_new));

/* ---------------------------------------------
 * Update GRpart 
 * **/
extern IGRstat VDpdmUpdateGRpartRev __((TGRid   *part_id,
			                IGRchar *new_rev));

extern IGRstat VDpdmUpdateGRpartUID __((TGRid   *part_id,
			                IGRchar *new_uid));

extern IGRstat VDpdmDeletePdmPart __((TGRid *part_id));


extern IGRstat VDpdmIsCOFileNameEqual __((IGRchar *catalog,
                                          IGRchar *part,
			                  IGRchar *rev_old,
			                  IGRchar *rev_new));

/* ---------------------------------------------
 * Database Notebook stuff
 * **/
extern IGRstat VDpdmUpdateVddbNbPosted __((VDosnum osnum,
	                                   IGRchar *value));

extern IGRstat VDpdmGetVddbNbPosted __((VDosnum osnum, IGRchar *nb_posted));

extern IGRstat VDpdmChangeNbNameToNbHeader __((IGRchar *NbName,
                                               IGRchar *nb_header));

/* ------------------------------------------------------------------------
 * check to see if a notebook header has been changed by an external app
 * **/
extern IGRstat VDpdmNbIsDbChanged __((IGRint   filekey,
	                              IGRchar *header));

extern IGRstat VDpdmUpdateNbBuffer __((VDosnum osnum,
	                               IGRchar *header,
			               IGRchar *filename));

/* ---------------------------------------------------------------------
 * Functions defined in VDpdmCache.c, used for caching query data from
 * database as related to filekeys, hull applicability, and approved for
 * ***/
/* ---------------------------------------------
 * Get the Filekey node
 * **/
extern IGRstat VDpdmCgetFilekeyNodeID __((IGRint *file_key,
	                                  TGRid  *nodeID));


/* ----------------------------------------------
 * Cache function for VDpdmGetCPRForFilekey
 * **/
extern IGRstat VDpdmCgetCPRForFilekey __((IGRint  *file_key,
	                                  IGRchar *a_catalog,
			                  IGRchar *a_part,
			                  IGRchar *a_rev));

extern IGRstat VDpdmCsetCPRForFilekey __((IGRint  *file_key,
	                                  IGRchar *catalog,
			                  IGRchar *part,
			                  IGRchar *rev));

/* ----------------------------------------------
 * Cache function for VDpdmGetCPRForFilekey
 * **/
extern IGRstat VDpdmCgetFilekeyForCPR __((IGRchar *a_cat,
	                                  IGRchar *a_part,
			                  IGRchar *a_rev,
			                  IGRint  *file_key));

/* ----------------------------------------------
 * Cache function for VDpdmGetHullAppforFilekey
 * **/
extern IGRstat VDpdmCgetHullAppforFilekey __((IGRint       *file_key,
	                                      VDpdmHullApp *ships));

extern IGRstat VDpdmCsetHullAppforFilekey __((IGRint       *file_key,
	                                      VDpdmHullApp *ships));

/* ----------------------------------------------
 * Cache function for VDpdmGetApprCfgForFilekey
 * **/
extern IGRstat VDpdmCgetApprCfgforFilekey __((IGRint       *file_key,
	                                      VDpdmHullApp *ships));

extern IGRstat VDpdmCsetApprCfgforFilekey __((IGRint       *file_key,
	                                      VDpdmHullApp *ships));



/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
