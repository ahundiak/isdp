/* $Id: VDpdmDef.h,v 1.7 2002/05/10 19:33:38 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDpdmDef.h
 *
 * Description:	PDM Defines
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

#ifndef VDpdmDef_include
#define VDpdmDef_include

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

/* -------------------------------------------
 * Useful constants
 * ***/
#define VDPDM_NO_OF_HULLS_IN_CLASS  12
#define VDPDM_LIST_OF_HULLS  "lpd17,lpd18,lpd19,lpd20,lpd21,lpd22,lpd23,lpd24,lpd25,lpd26,lpd27,lpd28"

// is_approved or is_not_approved
#define VDPDM_IS_APPROVED         1
#define VDPDM_IS_NOT_APPROVED     0
#define VDPDM_IS_APPROVED_DEFAULT 0

// is_production or is_not_production
#define VDPDM_IS_PRODUCTION         1
#define VDPDM_IS_NOT_PRODUCTION     0
#define VDPDM_IS_PRODUCTION_DEFAULT 0

/* ------------------------------------
 * TRACING
 * **/
#define VDPDM_TRACE_APP_CFG   71
#define VDPDM_TRACE_MACRO     72
#define VDPDM_TRACE_NOTEBOOK  73
#define VDPDM_TRACE_REPL_PART 74
#define VDPDM_TRACE_FILE_KEY  75

/* -----------------------------------
 * Attributes for Caching, used in VDpdmCache.c
 * **/
#define VDPDM_CACHE_ATTR_FILEKEY   "file_key"
#define VDPDM_CACHE_ATTR_CATALOG   "catalog"
#define VDPDM_CACHE_ATTR_PART      "part"
#define VDPDM_CACHE_ATTR_REVISION  "revision"
#define VDPDM_CACHE_ATTR_APPL_TO   "applicable_to"
#define VDPDM_CACHE_ATTR_APPR_FOR  "approved_for"


/* ---------------------------------
 * Data Structures
 * ***/

/* ---------------------------------------------
 * Basic pdm info structure
 */
typedef struct 
{
  IGRchar catalog [40];
  IGRchar part    [40];
  IGRchar rev     [40];
  IGRchar filename[40];
  IGRint  filekey;
} TVDpdmInfo;

/* --------------------------------------------
 * Reference list structure
 * **/
typedef struct
{
  IGRint     cnt;
  IGRint     max;
  IGRint     inc;
  TVDpdmInfo *infos;
} TVDpdmRefList;

/* --------------------------------------------
 * Purpose Info Structure. 
 * 09 May 2002 - ah
 * The filekey confuses some things when trying to
 * work offline, remove it and rely on pdm info
 * ***/
typedef struct
{
  IGRint  filekeyRemoved;
  IGRchar purpose  [80];
  IGRchar zone     [12];
  IGRchar unit     [12];
  IGRchar system   [40];
} TVDpdmPurposeInfo;

/* ------------------------------------
 * Hull Applicability or Approved structure, basically
 * a list of hulls.
 * ***/
typedef struct
{
    IGRint  file_key;
    IGRint  cnt;
    IGRchar hulls[VDPDM_NO_OF_HULLS_IN_CLASS][81];
} VDpdmHullApp;

/* ------------------------------------------------------
 * Tables and stuff
 * */

/* File key table */
#define VDPDM_FILE_KEY_TABLE_NAME              "vdpdm_file_keys"
#define VDPDM_FILE_KEY_COLN_CATALOG            "p_catalog"
#define VDPDM_FILE_KEY_COLN_PART               "p_part"
#define VDPDM_FILE_KEY_COLN_REVISION           "p_revision"
#define VDPDM_FILE_KEY_COLN_FILE_KEY           "file_key"

/* table index */
#define VDPDM_FILE_KEY_COLI_CATALOG            0
#define VDPDM_FILE_KEY_COLI_PART               1
#define VDPDM_FILE_KEY_COLI_REVISION           2
#define VDPDM_FILE_KEY_COLI_FILE_KEY           3

/* KEY TABLE */
#define VDPDM_KEY_TABLE_TABLE_NAME             "vdpdm_key_table"
#define VDPDM_KEY_TABLE_COLN_KEY_NAME          "key_name"
#define VDPDM_KEY_TABLE_COLN_VALUE             "value"
#define VDPDM_KEY_TABLE_COLN_UPD_DATE          "upd_date"

/* table index */
#define VDPDM_KEY_TABLE_COLI_KEY_NAME          0
#define VDPDM_KEY_TABLE_COLI_VALUE             1
#define VDPDM_KEY_TABLE_COLI_UPD_DATE          2

/* REF TABLES */
#define VDPDM_REF_TABLE_TABLE_NAME             "vdpdm_ref_tables"
#define VDPDM_REF_TABLE_COLN_TABLE_NAME        "table_name"
#define VDPDM_REF_TABLE_COLN_SHORT_DESCR       "short_descr"
#define VDPDM_REF_TABLE_COLN_LONG_DESCR        "long_descr"
#define VDPDM_REF_TABLE_COLN_TBL_PURPOSE       "tbl_purpose"

/* table index */
#define VDPDM_REF_TABLE_COLI_TABLE_NAME        0
#define VDPDM_REF_TABLE_COLI_SHORT_DESCR       1
#define VDPDM_REF_TABLE_COLI_LONG_DESCR        2
#define VDPDM_REF_TABLE_COLI_TBL_PURPOSE       3

/* hull applicability */
#define VDPDM_HULL_APP_TABLE_NAME              "vdpdm_hull_app"
#define VDPDM_HULL_APP_COLN_FILE_KEY           "file_key"
#define VDPDM_HULL_APP_COLN_CATALOG            "p_catalog"
#define VDPDM_HULL_APP_COLN_PART               "p_part"
#define VDPDM_HULL_APP_COLN_REVISION           "p_revision"
#define VDPDM_HULL_APP_COLN_HULL_APP           "hull_app"
#define VDPDM_HULL_APP_COLN_IS_APPROVED        "is_approved"
#define VDPDM_HULL_APP_COLN_IS_PRODUCTION      "is_production"

/* table index */
#define VDPDM_HULL_APP_COLI_FILE_KEY           0
#define VDPDM_HULL_APP_COLI_CATALOG            1
#define VDPDM_HULL_APP_COLI_PART               2
#define VDPDM_HULL_APP_COLI_REVISION           3
#define VDPDM_HULL_APP_COLI_HULL_APP           4
#define VDPDM_HULL_APP_COLI_IS_CURRENT         5
#define VDPDM_HULL_APP_COLI_IS_PRODUCTION      6

/* Purpose Info table  */
#define VDPDM_PURP_INFO_TABLE_NAME             "vdpdm_purp_info"
#define VDPDM_PURP_INFO_COLN_FILEKEY           "file_key"
#define VDPDM_PURP_INFO_COLN_PURPOSE           "purpose"
#define VDPDM_PURP_INFO_COLN_ZONE              "zone"
#define VDPDM_PURP_INFO_COLN_UNIT              "unit"
#define VDPDM_PURP_INFO_COLN_SYSTEM            "systm"


/* Notebook table */
#define VDPDM_NB_TABLE_NAME                    "vdpdm_notebook"
#define VDPDM_NB_COLN_FILE_KEY                 "file_key"
#define VDPDM_NB_COLN_BLOB_KEY                 "blob_key"
#define VDPDM_NB_COLN_NB_HEADER                "nb_header"
#define VDPDM_NB_COLN_NB_INC                   "nb_inc"
#define VDPDM_NB_COLN_POST_DATE                "post_date"

#define VDPDM_NB_COLI_FILE_KEY                 0
#define VDPDM_NB_COLI_BLOB_KEY                 1
#define VDPDM_NB_COLI_NB_HEADER                2
#define VDPDM_NB_COLI_NB_INC                   3
#define VDPDM_NB_COLI_POST_DATE                4

/* Macros table  */
#define VDPDM_MACRO_TABLE_NAME                 "vdpdm_macro"
#define VDPDM_MACRO_COLN_FILE_KEY              "file_key"
#define VDPDM_MACRO_COLN_MACRO_LIB             "macro_lib"
#define VDPDM_MACRO_COLN_MACRO_NAME            "macro_name"
#define VDPDM_MACRO_COLN_MACRO_QTY             "macro_qty"
#define VDPDM_MACRO_COLN_MACRO_SYMBOL          "macro_symbol"
#define VDPDM_MACRO_COLN_POST_DATE             "post_date"

/*  Post Date Table  */
#define VDPDM_POST_DATE_TABLE_NAME             "vdpdm_post_date"
#define VDPDM_POST_DATE_COLN_FILEKEY           "file_key"
#define VDPDM_POST_DATE_COLN_DB_TABLE          "db_table"
#define VDPDM_POST_DATE_COLN_POST_DATE         "post_date"


/* VDpdm Replace Part Actions  */
#define VDPDM_RE_PRT_ACTION_NONE               "0"
#define VDPDM_RE_PRT_ACTION_REV                "1"
#define VDPDM_RE_PRT_ACTION_UID                "2"
#define VDPDM_RE_PRT_ACTION_DEL                "3"

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
