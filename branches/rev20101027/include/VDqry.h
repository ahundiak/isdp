/* $Id: VDqry.h,v 1.2 2001/10/17 19:39:27 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDqry.h
 *
 * Description:	VDS Query Routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDqry.h,v $
 * Revision 1.2  2001/10/17 19:39:27  jdsauby
 * Added vd_attrs to support better reporting JDS 10/17/01
 *
 * Revision 1.1  2001/10/16 15:33:50  jdsauby
 * JTS MP CR 5536
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/08/01  js      Creation
 ***************************************************************************/

#ifndef VDqry_include
#define VDqry_include

#ifndef   VDtypedefc_include
#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif
#endif

#ifndef   VDpdmDef_include
#include  "VDpdmDef.h"
#endif

#ifndef   VDrisc_include
#include  "VDrisc.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

#define VDQRY_OPTION_DEL_PART   "Delete Part"
#define VDQRY_OPTION_DEL_POST   "Delete Post"
#define VDQRY_OPTION_SELECT     "Select"

#define VDQRY_ATTR_CATALOG       "CAT"
#define VDQRY_ATTR_CATALOG_LEN   3
#define VDQRY_ATTR_PART          "PART"
#define VDQRY_ATTR_PART_LEN      4
#define VDQRY_ATTR_REVISION      "REV"
#define VDQRY_ATTR_REVISION_LEN  3
#define VDQRY_ATTR_FILEKEY       "FKEY"
#define VDQRY_ATTR_FILEKEY_LEN   4


#define VDQRY_TBL_NAME        "vds_query"
#define VDQRY_COLN_PRIORITY   "priority"
#define VDQRY_COLN_TABLE_NAME "table_name"
#define VDQRY_COLN_OPTION     "vd_option"
#define VDQRY_COLN_QUERY      "vd_query"
#define VDQRY_COLN_ATTRIBUTES "vd_attrs"
#define VDQRY_COLN_REMARKS    "remarks"

#define VDQRY_COLI_PRIORITY   0
#define VDQRY_COLI_TABLE_NAME 1
#define VDQRY_COLI_OPTION     2
#define VDQRY_COLI_QUERY      3
#define VDQRY_COLI_ATTRIBUTES 4
#define VDQRY_COLI_REMARKS    5


/* --------------------------------------------
 * Query info structures
 * **/
typedef struct
{
    IGRchar  tbl_name[32];
    IGRchar  vd_query[240];
    IGRchar  vd_attrs[240];
    IGRchar  remarks [80];
} TVDqryInfo;

typedef struct
{
    IGRint      max;
    IGRint      inc;
    IGRint      cnt;
    IGRint      file_key;
    IGRchar     catalog  [80];
    IGRchar     part     [80];
    IGRchar     rev      [80];
    IGRchar     vd_option[32];
    TVDqryInfo *infos;
} TVDqryInfos;

/* --------------------------------------------
 * Qry data storage structure
 * **/
typedef struct
{
    IGRint      max;
    IGRint      inc;
    IGRint      cnt;
    IGRchar   **tbl_name;
    TVDrisInfo *data;
    TVDrisInfo *cols;
} TVDqryData;



/* -------------------------------------------------
 * The functions, macros
 * **/

/* ------------------------------------------------------
 * vdqry$execute(osnum = NULL,       I
 *	         file_key = NULL,    I
 *		 catalog  = NULL,    I
 *		 part     = NULL,    I
 *		 rev      = NULL,    I
 *		 option)             I
 *
 * This macro returns a 1 for success, and a 0 for failure.
 * It will look into the vd_query table using the required given
 * option, to execute a query.  Use this macro if no return data
 * is required.
 * Along with the option, at least the osnum, or file_key, or catalog
 * and part and rev are required as input
 * **/

extern IGRstat VDqryExecute __((VDosnum   *osnum,
	                        IGRint    *file_key,
		                IGRchar   *catalog,
		                IGRchar   *part,
		                IGRchar   *rev,
		                IGRchar   *option));
#ifndef c_ONLY
#omdef vdqry$execute(osnum    = NULL,
	             file_key = NULL,
		     catalog  = NULL,
		     part     = NULL,
		     rev      = NULL,
		     option)
VDqryExecute((osnum),(file_key),(catalog),(part),(rev),(option))
#endomdef
#endif

/* ----------------------------------------------------------------
 * Initialize TVDqryData
 * ***/
extern IGRstat VDqryInitQryData __((TVDqryData *data));
#ifndef c_ONLY
#omdef vdqry$init_data(data)
VDqryInitQryData((data))
#endomdef
#endif

/* -----------------------------------------------
 * Frees a TVDqryData structure
 */
extern IGRstat VDqryFreeQryData __((TVDqryData *data));
#ifndef c_ONLY
#omdef vdqry$free_data(data)
VDqryFreeQryData((data))
#endomdef
#endif

/* ----------------------------------------------------------------
 * Query it, return 1 for success, 0 for failure.
 * Also, return the data.  this would be used to find all the data
 * that has been posted about a given CPR, osnum, or file_key.
 * It is up to the calling routine to init and free the TVDqryData structure.
 * 
 * vdqry$query(osnum    = NULL,
 *	       file_key = NULL,
 *	       catalog  = NULL,
 *	       part     = NULL,
 *	       rev      = NULL,
 *	       option,
 *	       table    = NULL,
 *	       data)
 *
 * It is required to give an option, a pointer to an already initialized
 * TVDqryData structure, and an osnum or file_key or catalog and part and rev.
 * If a table is given, then only that table will have the query executed on it.
 * If no tables are given, then data for all tables matching option and other
 * inputs will be stored into the TVDqryData structure.
 * ***/
extern IGRstat VDqryQuery __((VDosnum    *osnum,
	                      IGRint     *file_key,
		              IGRchar    *catalog,
		              IGRchar    *part,
		              IGRchar    *rev,
		              IGRchar    *option,
		              IGRchar    *table,
		              TVDqryData *data));
#ifndef c_ONLY
#omdef vdqry$query(osnum    = NULL,
	           file_key = NULL,
		   catalog  = NULL,
		   part     = NULL,
		   rev      = NULL,
		   option,
		   table    = NULL,
		   data)
VDqryQuery((osnum),(file_key),(catalog),(part),(rev),(option),(table),(data))
#endomdef
#endif

/* ----------------------------------------------------------------
 * Query it, return 1 for success, 0 for failure.
 * Also, fill up the report file with all of the data
 *
 * vdqry$report(osnum    = NULL,
 *	        file_key = NULL,
 *	        catalog  = NULL,
 *	        part     = NULL,
 *	        rev      = NULL,
 *	        option,
 *	        table    = NULL,
 *	        rpt_file)
 *
 * This will use the vdqry$query macro to get the data with the same options.
 * The difference being that this macro will process and store the data into
 * the given report file.  Report file is a required input
 * ***/
extern IGRstat VDqryReport __((VDosnum    *osnum,
	                       IGRint     *file_key,
		               IGRchar    *catalog,
		               IGRchar    *part,
		               IGRchar    *rev,
		               IGRchar    *option,
		               IGRchar    *table,
		               IGRchar    *rpt_file));
#ifndef c_ONLY
#omdef vdqry$report(osnum    = NULL,
	            file_key = NULL,
		    catalog  = NULL,
		    part     = NULL,
		    rev      = NULL,
		    option,
		    table    = NULL,
		    rpt_file)
VDqryReport((osnum),(file_key),(catalog),(part),(rev),(option),(table),(rpt_file))
#endomdef
#endif


/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
