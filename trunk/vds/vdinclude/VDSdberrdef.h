/* $Id: VDSdberrdef.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDSdberrdef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdberrdef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1996/04/05  22:27:42  pinnacle
 * Replaced: vdinclude/VDSdberrdef.h for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/05/96   tlb		Added VDS_PARTID_NO
 *
 * -------------------------------------------------------------------*/

#define	   VDS_S_SUCCESS		0x08708009
#define    VDS_E_FAILURE		0x08708342
#define	   VDS_E_OPEN_BUFFER		0x0870865a
#define	   VDS_E_WRITE_BUFFER		0x08708d42
#define	   VDS_E_BUILD_ARRAY		0x0870812a
#define	   VDS_E_BUILD_BUFFER_ARRAY	0x08708132
#define	   VDS_E_APPEND_BUFFER		0x08708042
#define	   VDS_E_INVALID_BUFFER_FORMAT	0x08708402
#define	   VDS_E_PART_EXISTS		0x0870869a
#define	   VDS_E_BUFFER_FORMAT		0x08708122
#define	   VDS_E_WRITE_COLUMN		0x08708d4a
#define	   VDS_E_CATALOG_NOT_FOUND	0x0870819a
#define    VDS_E_CATALOG_NOT_EMPTY      0x08708152
#define	   VDS_E_SQL_QUERY		0x08708c52
#define	   VDS_E_SQL_STMT		0x08708c5a
#define	   VDS_E_NO_MACROS_FOUND	0x087087f2
#define	   VDS_E_MACRO_NOT_FOUND	0x087084ea
#define	   VDS_E_COPY_BUFFER		0x0870826a
#define    VDS_E_WRITE_FORMAT		0x08708d5a
#define    VDS_E_TABLE_NOT_FOUND        0x08708c92
#define	   VDS_E_CATALOG_EXISTS		0x08708182
#define	   VDS_E_WRITE_ROW		0x08708d62

#define	   VDS_E_OPEN_FILE		0x0870818a
#define	   VDS_E_ALLOC_MEMORY		0x08708192

#define    VDS_E_CREAT_TABLE		0x087081a2
#define    VDS_E_GET_CATALOG_NAME	0x087081aa
#define    VDS_E_CLOSE_BUFFER		0x087081b2
#define    VDS_E_DELETE_CATALOG		0x087081ba
#define    VDS_E_QUE_LOC_ATT		0x087081c2
#define    VDS_E_QUE_ITEM_ATT		0x087081ca
#define    VDS_E_CREATE_APP		0x087081d2
#define    VDS_E_GET_CAT_TEMP		0x087081da
#define    VDS_E_BAD_NODE		0x087081e2
#define    VDS_E_BAD_PROTOCOL		0x087081ea
#define    VDS_E_BAD_USER		0x087081f2
#define    VDS_E_BAD_ENV		0x087081fa
#define    VDS_E_CLH			0x08708202
#define    VDS_E_USER_PASSWD		0x0870820a
#define    VDS_E_CONVERT_DATATYPE	0x08708212


#define         VDS_E_OPEN_RIS_KEYWORDFILE 0
#define         KEYWORD_FOUND           1
#define         KEYWORD_NOT_FOUND       2


/*********************************************************
 *** Definitions for the PDM/PDU Parametrics Subsystem ***
 *********************************************************/

/* parameter types for macro parameters */
#define VDS_PARTYPE_DOUBLE	"double"
#define VDS_PARTYPE_TEXT	"text"
#define VDS_PARTYPE_COORDSYS	"referential"
#define VDS_PARTYPE_POINT	"point"
#define VDS_PARTYPE_MACRO	"macro"
#define VDS_PARTYPE_LINE	"line"
#define VDS_PARTYPE_CONIC	"conic"
#define VDS_PARTYPE_CIRCLE	"circle"
#define VDS_PARTYPE_ARC		"arc"
#define VDS_PARTYPE_LBS		"lbs"
#define VDS_PARTYPE_PLANE	"plane"
#define VDS_PARTYPE_CURVE	"curve"
#define	VDS_PARTYPE_GENERIC	"generic"

/* I/O types for macro parameters */
#define VDS_IOTYPE_DYNAMIC	"DC"
#define VDS_IOTYPE_LOCATE	"DL"
#define VDS_IOTYPE_STATIC	"SC"
#define VDS_IOTYPE_OUTPUT	"DO"
#define VDS_IOTYPE_USER_DYN	"UD"

/* default data types for macro parameters */
#define VDS_DATATYPE_DOUBLE	"double"
#define VDS_DATATYPE_TEXT	"char(80)"
#define VDS_DATATYPE_COORDSYS	"char(2)"
#define VDS_DATATYPE_POINT	"char(2)"
#define VDS_DATATYPE_MACRO	"char(20)"
#define VDS_DATATYPE_LINE	"char(2)"
#define VDS_DATATYPE_CONIC	"char(2)"
#define VDS_DATATYPE_CIRCLE	"char(2)"
#define VDS_DATATYPE_ARC	"char(2)"
#define VDS_DATATYPE_LBS	"char(2)"
#define VDS_DATATYPE_PLANE	"char(2)"
#define VDS_DATATYPE_CURVE	"char(2)"


#define   VDS_PARANUM_COL         0
#define   VDS_PARANAME_COL        1
#define   VDS_PARADATA_COL        2
#define   VDS_PARATYPE_COL        3
#define   VDS_IOTYPE_COL	  4
#define	  VDS_PARASYNO_COL	  5
#define	  VDS_PARAVAL_COL	  6	/* Default value for a column */


#define	  ADD_TABLE		101
#define	  ADD_DATA		201
#define	  PDM_LOC		303
#define	  PDM_CATALOG		304
#define	  PDM_PART		310

#define	  VDS_NFM_SEQNO_COL		11

#define	  VDS_BUFFER_SIZE		7000
#define	  VDS_BUFFER_TERM		'\1'



#define VDS_FILENAME_ATTR       "n_cofilename"
#define VDS_NFM_CATALOG_NAME    "n_catalogname"
#define VDS_NFM_CATALOG_DESC    "n_catalogdesc"
#define VDS_NFM_CATALOG_APPL    "n_application"
#define VDS_NFM_CATALOG_TYPE    "n_type"
#define VDS_DESCRIPTION_ATTR    "n_itemdesc"
#define VDS_PARTID_ATTR         "n_itemname"
#define VDS_PARTID_NO         	"n_itemno"
#define VDS_REVISION_ATTR       "n_itemrev"
#define VDS_PARTTYPE_ATTR       "p_parttype"
#define	VDS_DYNAMIC_TBL_NAME	"v_dynamictbl"
#define	VDS_SCH_DYN_TBL_NAME	"v_schdyntbl"
#define	VDS_CIT_TBL_NAME	"v_cittbl"
#define VDS_EQUIP_PPL_NAME	"v_pplfile"
#define	VDS_PRODUCT_NAME	"v_product"
#define VDS_PDM_CLASS_LEVEL	"p_level"

/* NFM constants */
#define VDS_NFM_ATTR_COL        0
#define VDS_NFM_DATA_COL        1
#define VDS_NFM_SYN_COL         2
#define VDS_NFM_PDM_COL         3
#define VDS_NFM_READ_COL        4
#define VDS_NFM_WRITE_COL       5
#define VDS_NFM_UPDATE_COL      6
#define VDS_NFM_DELETE_COL      7
#define VDS_NFM_REQ_COL         8
#define VDS_NFM_CHKIN_COL       9
#define VDS_NFM_CHKOUT_COL      10
#define VDS_NFM_SEQNO_COL       11
#define VDS_NFM_ATTRNO_COL      12
#define VDS_NFM_TABLENO_COL     13
#define VDS_NFM_LISTNO_COL      14
#define VDS_NFM_ADVICE_COL      15
#define VDS_NFM_MOD_OFFSET      16

#define VDS_NFM_BUFF_COLS       16
