/***************************************************************

dsdef.h
     
General Description:

     The dsdef.h include file defines misc string sizes, projection
     angle, units and border types. Also error message are defined 
     for the macro's return code.

Dependencies:

     None
     
****************************************************************/

#ifndef dsdef_include
#define dsdef_include

/*
 * General defintions.
 */
#define MAX_FILE_LEN     80
#define MAX_STANDARD_LEN 20
#define MAX_CELL_LEN     80
#define MAX_SHEET_LEN	 40

#define MAX_NO_STANDARDS 10
#define MAX_NO_SHEETS    100

#define GRDS_NO_STANDARDS     500
#define GRDS_NO_SHEETS        502
#define GRDS_BAD_DEFINITION   504

/*  
 * Macro interface definitions.
 */
#define  DS_THIRD_ANGLE       0x0
#define  DS_FIRST_ANGLE	      0x1

#define  DS_IMPERIAL          0x0
#define  DS_METRIC            0x1

#define  DS_CELL_LIB          0x0
#define  DS_REFERENCE         0x1
#define  DS_NOBORDER          0x2

/* Drawing Sheet Manager Name */
#define  DS_SUPER_NAME        "DrwShtMgr"

/*************** PRIVATE *************************/

/* op */
#define ds_get           0
#define ds_put           1
#define ds_del           2

/* arg */
#define ds_num_standards 	0
#define ds_num_sheets    	1
#define ds_standards     	2
#define ds_sheets        	3
#define ds_default_standard     4
#define ds_standard_by_name     5
#define ds_sheet_by_name        6

/* standard properties defines */
#define DSTD_UNITS          0x00000001  /* Metric = 1, Imperial = 0 */
#define DSTD_PROJECTION     0x00000002  /* First = 1, Third = 0 */
#define DSTD_IMPERIAL       0x00000004  /* Imperial Supported = 1 */
#define DSTD_METRIC         0x00000008  /* Metric Supported = 1 */
#define DSTD_THIRD          0x00000010  /* Third Supported = 1 */
#define DSTD_FIRST          0x00000020  /* First Supported = 1 */

/* sheet properties defines */
#define DSHT_UNITS          0x00000001  /* Metric = 1, Imperial = 0 */
#define DSHT_PROJECTION     0x00000002  /* First = 1, Third = 0 */
#define DSHT_FILETYPE       0x00000004  /* Reference = 1, Cell = 0 */

/* standard and sheet properties macros */
#define DSTD_IS_METRIC(p)           ((p & DSTD_UNITS) ? TRUE : FALSE)
#define DSTD_IS_IMPERIAL(p)         ((p & DSTD_UNITS) ? FALSE : TRUE)
#define DSTD_IS_FIRST(p)            ((p & DSTD_PROJECTION) ? TRUE : FALSE)
#define DSTD_IS_THIRD(p)            ((p & DSTD_PROJECTION) ? FALSE : TRUE)
#define DSTD_METRIC_SUPPORTED(p)    ((p & DSTD_METRIC) ? TRUE : FALSE)
#define DSTD_IMPERIAL_SUPPORTED(p)  ((p & DSTD_IMPERIAL) ? TRUE : FALSE)
#define DSTD_THIRD_SUPPORTED(p)     ((p & DSTD_THIRD) ? TRUE : FALSE)
#define DSTD_FIRST_SUPPORTED(p)     ((p & DSTD_FIRST) ? TRUE : FALSE)
#define DSHT_IS_METRIC(p)           ((p & DSHT_UNITS) ? TRUE : FALSE)
#define DSHT_IS_IMPERIAL(p)         ((p & DSHT_UNITS) ? FALSE : TRUE)
#define DSHT_IS_FIRST(p)            ((p & DSHT_PROJECTION) ? TRUE : FALSE)
#define DSHT_IS_THIRD(p)            ((p & DSHT_PROJECTION) ? FALSE : TRUE)
#define DSHT_IS_REFERENCE(p)        ((p & DSHT_FILETYPE) ? TRUE : FALSE)
#define DSHT_IS_CELL(p)             ((p & DSHT_FILETYPE) ? FALSE : TRUE)
#endif






