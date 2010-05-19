/* $Id: VDpdmForms.h,v 1.13 2002/01/10 21:12:35 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDpdmForms.h
 *
 * Description:	PDM Additional Routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDpdmForms.h,v $
 * Revision 1.13  2002/01/10 21:12:35  jdsauby
 * JTSMP CR5866, added clear all and set all gadgets
 *
 * Revision 1.12  2001/10/03 14:09:47  jdsauby
 * JTSMP CRs 5448,5527,5591
 *
 * Revision 1.11  2001/07/26 13:32:33  jdsauby
 * MP5447 - jds
 *
 * Revision 1.10  2001/06/29 16:45:21  jdsauby
 * Modified for TR3403
 *
 * Revision 1.9  2001/06/04 13:06:43  jdsauby
 * CR3403, new replace part
 *
 * Revision 1.8  2001/05/14 20:50:08  jdsauby
 * CR5180 Update Nodes
 *
 * Revision 1.7  2001/04/24 20:39:29  jdsauby
 * Post table timestamp  CR 4474
 *
 * Revision 1.6  2001/04/13 20:15:12  jdsauby
 * Changed some notebook form stuff
 *
 * Revision 1.5  2001/04/12 20:40:35  jdsauby
 * sp 11
 *
 * Revision 1.4  2001/03/29 19:36:00  jdsauby
 * Set Purpose Info command added
 *
 * Revision 1.3  2001/03/02 21:40:31  jdsauby
 * Added purpose Info
 *
 * Revision 1.2  2001/02/21 13:03:20  jdsauby
 * CR4088
 *
 * Revision 1.1  2001/02/05 15:48:31  jdsauby
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

#ifndef VDpdmForms_include
#define VDpdmForms_include

#ifndef   VDtypedefc_include
#include "VDtypedefc.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VDpdmMain.F  - Main utilities form */
#define VDPDM_MAIN_F_NAME      "VDpdmMain.F"    
#define VDPDM_MAIN_G_PART_HULL  12
#define VDPDM_MAIN_G_HULL_PART  13
#define VDPDM_MAIN_G_NOTEBOOK   19
#define VDPDM_MAIN_G_MACROS     20
#define VDPDM_MAIN_G_PRODUCTION 21
#define VDPDM_MAIN_G_REPL_PART  22

/* VDpdmPartHull.F - Form for getting the hulls for a part */
#define VDPDM_PART_HULL_F_NAME      "VDpdmPtHull.F"
#define VDPDM_PART_HULL_G_CATALOG     19
#define VDPDM_PART_HULL_G_PART        20
#define VDPDM_PART_HULL_G_REV         21
#define VDPDM_PART_HULL_G_FILEKEY     22
#define VDPDM_PART_HULL_B_CLASS       12
//#define VDPDM_PART_HULL_G_L1          23
//#define VDPDM_PART_HULL_G_L2          24
//#define VDPDM_PART_HULL_G_L3          25
//#define VDPDM_PART_HULL_G_L4          26
//#define VDPDM_PART_HULL_G_L5          27
//#define VDPDM_PART_HULL_G_L6          28
//#define VDPDM_PART_HULL_G_L7          29
//#define VDPDM_PART_HULL_G_L8          30
//#define VDPDM_PART_HULL_G_L9          31
//#define VDPDM_PART_HULL_G_L10         32
//#define VDPDM_PART_HULL_T_ALL_ACTIVE  13
#define VDPDM_PART_HULL_STATUS        42
#define VDPDM_PART_HULL_APPL_TO       43
#define VDPDM_PART_HULL_APPR_FOR      44
#define VDPDM_PART_HULL_ADD           45
#define VDPDM_PART_HULL_SET_ALL       13
#define VDPDM_PART_HULL_REMOVE        46
#define VDPDM_PART_HULL_CLEAR_ALL     24
#define VDPDM_PART_HULL_G_PURPOSE     51
#define VDPDM_PART_HULL_G_ZONE        59
#define VDPDM_PART_HULL_G_UNIT        58
#define VDPDM_PART_HULL_G_SYSTEM      57
#define VDPDM_PART_HULL_G_LOC_FILE    62

#define VDPDM_HULL_PART_F_NAME        "VDpdmHullPt.F"
#define VDPDM_HULL_PART_G_HULL          13
#define VDPDM_HULL_PART_G_ZONE          20
#define VDPDM_HULL_PART_G_DISPLAY       12
#define VDPDM_HULL_PART_G_FILE          26
#define VDPDM_HULL_PART_G_DELIMITOR     27
#define VDPDM_HULL_PART_G_WRITE         23
#define VDPDM_HULL_PART_G_STATUS        42
#define VDPDM_HULL_PART_G_PURPOSE       28
#define VDPDM_HULL_PART_G_UNIT          30
#define VDPDM_HULL_PART_G_SYSTEM        33
//#define VDPDM_HULL_PART_
/* ----------------------------------------------------
 * Form Initialization routines
 * ***/

// PART HULL form
extern IGRstat VDpdmInitPtHull __(());

// HULL PART form
extern IGRstat VDpdmInitHullPt __(());

/* ---------------------------------------------------
 * Form to display list of non compliant reference files
 * ***/
#define VDPDM_NON_LIST_F_NAME          "VDpdmNonList.F"
#define VDPDM_NON_LIST_G_WRITE          21
#define VDPDM_NON_LIST_G_WRITE_FILE     36
#define VDPDM_NON_LIST_G_ACT_CATALOG    30
#define VDPDM_NON_LIST_G_ACT_PART       31
#define VDPDM_NON_LIST_G_ACT_REV        32
#define VDPDM_NON_LIST_G_ACT_FILENAME   33
#define VDPDM_NON_LIST_G_ACT_FILEKEY    34
#define VDPDM_NON_LIST_G_ACT_APPR_HULLS 19

#define VDPDM_NON_LIST_G_NON_LIST          11
#define VDPDM_NON_LIST_C_NON_LIST_CATALOG   0
#define VDPDM_NON_LIST_C_NON_LIST_PART      1
#define VDPDM_NON_LIST_C_NON_LIST_REV       2
#define VDPDM_NON_LIST_C_NON_LIST_FILENAME  3
#define VDPDM_NON_LIST_C_NON_LIST_HCFG      4
#define VDPDM_NON_LIST_C_NON_LIST_HAP       5

/* ---------------------------------------------------
 * Notebook from database form
 * **/
#define VDPDM_NOTEBK_F_NAME           "VDpdmNoteBk.F"
#define VDPDM_NOTEBK_F_NUM            555
#define VDPDM_NOTEBK_B_CLASS          24
#define VDPDM_NOTEBK_L_CATALOG        16
#define VDPDM_NOTEBK_L_PART           17
#define VDPDM_NOTEBK_L_REVISION       18
#define VDPDM_NOTEBK_G_FILEKEY        19
#define VDPDM_NOTEBK_B_POST           35

#define VDPDM_NOTEBK_F_HEADERS           11
#define VDPDM_NOTEBK_COLI_HDR_TITLE      0
#define VDPDM_NOTEBK_COLI_HDR_FILE       1
#define VDPDM_NOTEBK_COLI_HDR_DATE       2
#define VDPDM_NOTEBK_COLI_HDR_BLOB       3

#define VDPDM_NOTEBK_F_ACTIVE            31
#define VDPDM_NOTEBK_COLI_ACT_FILENAME   0
#define VDPDM_NOTEBK_COLI_ACT_FILEKEY    1

#define VDPDM_NOTEBK_B_EDIT           14
#define VDPDM_NOTEBK_B_ADD_TITLE      15
#define VDPDM_NOTEBK_STATUS           30

/*    Notebook Init  */
extern IGRstat VDpdmInitNoteBk __(());

/* ---------------------------------------------------
 * Form to Set Purpose Info
 * function VDpdmCmdSetPurposeInfo is included by VDpdmCmd.h
 * **/
#define VDPDM_SET_PURP_F_NAME         "VDpdmSetPurp.F"
#define VDPDM_SET_PURP_F_NUM          565
#define VDPDM_SET_PURP_L_PURP         19
#define VDPDM_SET_PURP_G_ZONE         16
#define VDPDM_SET_PURP_G_UNIT         17
#define VDPDM_SET_PURP_G_SYSTEM       18
#define VDPDM_SET_PURP_STATUS         20

/* --------------------------------------------------
 * Classifications Form
 * Used to go through classifications to get to catalog
 * **/
#define VDPDM_CLASS_F_NAME           "VDpdmClass.F"
#define VDPDM_CLASS_F_NUM            575
#define VDPDM_CLASS_G_L1             13
#define VDPDM_CLASS_G_L2             14
#define VDPDM_CLASS_G_L3             15
#define VDPDM_CLASS_G_L4             16
#define VDPDM_CLASS_G_L5             17
#define VDPDM_CLASS_G_L6             18
#define VDPDM_CLASS_G_L7             19
#define VDPDM_CLASS_G_L8             20
#define VDPDM_CLASS_G_L9             21
#define VDPDM_CLASS_G_L10            22
#define VDPDM_CLASS_STAT             23

extern IGRstat VDpdmCmdGetClassLevels __((TVDpdmClass *level));


/* ---------------------------------------------------
 * Macro Utilities form
 * **/
#define VDPDM_MACRO_F_NAME          "VDpdmMacro.F"
#define VDPDM_MACRO_F_NUM           585

#define VDPDM_MACRO_B_QUERY         15
#define VDPDM_MACRO_B_WRITE         16
#define VDPDM_MACRO_T_MACRO         28

#define VDPDM_MACRO_L_LIBRARY       30
#define VDPDM_MACRO_L_NAME          32

#define VDPDM_MACRO_B_CLASS         19
#define VDPDM_MACRO_L_CATALOG       20
#define VDPDM_MACRO_L_PART          21
#define VDPDM_MACRO_L_REVISION      22
#define VDPDM_MACRO_G_FILEKEY       23

#define VDPDM_MACRO_F_ACTIVE        18
#define VDPDM_MACRO_COLI_ACT_FILE    0
#define VDPDM_MACRO_COLI_ACT_KEY     1

#define VDPDM_MACRO_F_RESULTS       11
#define VDPDM_MACRO_COLI_RES_CAT     0
#define VDPDM_MACRO_COLI_RES_PART    1
#define VDPDM_MACRO_COLI_RES_REV     2
#define VDPDM_MACRO_COLI_RES_LIB     3
#define VDPDM_MACRO_COLI_RES_MAC     4
#define VDPDM_MACRO_COLI_RES_QTY     5
#define VDPDM_MACRO_COLI_RES_KEY     6

#define VDPDM_MACRO_STATUS          29

/*    Notebook Init  */
extern IGRstat VDpdmInitMacro __(());

/* -------------------------------------------
 * Replace Part Form
 * **/
#define VDPDM_REPL_PART_F_NAME      "VDpdmRepPrt.F"
#define VDPDM_REPL_PART_F_NUM       595

#define VDPDM_REPL_PART_F_ACT              22
#define VDPDM_REPL_PART_ACT_COLI_CAT        0
#define VDPDM_REPL_PART_ACT_COLI_PART       1
#define VDPDM_REPL_PART_ACT_COLI_REV        2
#define VDPDM_REPL_PART_ACT_COLI_DESCR      3
#define VDPDM_REPL_PART_ACT_COLI_CATNO      4
#define VDPDM_REPL_PART_ACT_COLI_ITEMNO     5
#define VDPDM_REPL_PART_ACT_COLI_FILEKEY    6

#define VDPDM_REPL_PART_F_REF              11
#define VDPDM_REPL_PART_REF_COLI_APPR       0
#define VDPDM_REPL_PART_REF_COLI_CAT        1
#define VDPDM_REPL_PART_REF_COLI_PART       2
#define VDPDM_REPL_PART_REF_COLI_REV_OLD    3
#define VDPDM_REPL_PART_REF_COLI_DESCR      4
#define VDPDM_REPL_PART_REF_COLI_REV_NEW    5
#define VDPDM_REPL_PART_REF_COLI_VIEW       6
#define VDPDM_REPL_PART_REF_COLI_UID_OLD    7
#define VDPDM_REPL_PART_REF_COLI_ITNO_OLD   8
#define VDPDM_REPL_PART_REF_COLI_UID_NEW    9
#define VDPDM_REPL_PART_REF_COLI_ITNO_NEW  10
#define VDPDM_REPL_PART_REF_COLI_PART_ID   11
#define VDPDM_REPL_PART_REF_COLI_ACTION    12
#define VDPDM_REPL_PART_REF_COLI_FILEKEY   13


#define VDPDM_REPL_PART_STATUS             18

/*    Replace Part Init   */
extern IGRstat VDpdmInitReplPart __(());

/* -------------------------------------------
 * New Revision Sub-form
 * **/
#define VDPDM_NEW_REV_F_NAME          "VDpdmNewRev.F"
#define VDPDM_NEW_REV_F_NUM            605
#define VDPDM_NEW_REV_APPR_REV         15
#define VDPDM_NEW_REV_L_REV            13
#define VDPDM_NEW_REV_B_DO_NOT_REPLACE 14
#define VDPDM_NEW_REV_CUR_REV          11

extern IGRstat VDpdmCmdGetNewRev __((IGRint   p_filekey,
	                             IGRchar  *catalog,
                                     IGRchar  *part,
                                     IGRchar  *old_rev,
                                     IGRchar  *app_rev,
			             IGRchar  *new_rev));

/* --------------------------------------------
 * VDpdm Database Pesistent Notebook command form
 * VDpdmDbNb.F
 * **/
#define VDPDM_DBNB_F_NAME              "VDpdmDbNb.F"
#define VDPDM_DBNB_F_NUM                615
#define VDPDM_DBNB_MCF_NB_INFO          13
#define VDPDM_DBNB_MCF_COL_TITLE        0
#define VDPDM_DBNB_MCF_COL_TEXT_FILE    1
#define VDPDM_DBNB_MCF_COL_POST_DATE    2
#define VDPDM_DBNB_MCF_COL_BLOB_KEY     3
#define VDPDM_DBNB_MCF_COL_NB_INC       4
#define VDPDM_DBNB_MCF_COL_F_TIME       5
#define VDPDM_DBNB_B_BROWSE_DB          11
#define VDPDM_DBNB_B_ADD_TITLE          18
#define VDPDM_DBNB_B_DEL_TITLE          19
#define VDPDM_DBNB_STATUS               14

/* form init */
extern IGRstat VDpdmInitDbNb __(());

/* form killer */
extern IGRstat VDpdmKillDbNbForm __(());

/* -----------------------------------------------
 * VDpdmNbTitle.F, little sub form to get new title
 * ***/
#define VDPDM_NB_TITLE_F_NAME         "VDpdmNbTitle.F"
#define VDPDM_NB_TITLE_F_NUM           625
#define VDPDM_NB_TITLE_G_TITLE         11

extern IGRstat VDpdmDbNbAddTitle __((IGRchar *title));

/* and the killer */
extern IGRstat VDpdmNbKillTitle __(());

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
