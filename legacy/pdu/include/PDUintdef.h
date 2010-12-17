/**************************************************************************
 *** definitions for the EMS internal component of Product Data User    ***
 *									*
 *  History		11/8/89  changed PDU_K_ORIENTATION_LEN 528	*
 *				 added  PDU_K_VWORIGIN_LEN 100 LMM	*
 **************************************************************************/

#ifndef PDUdef
#define PDUdef	1

#include "PDUcommand.h"
#include "PDUerror.h"
#include "stdio.h"

extern   int PDM_debug_on;

/* PDU constants */

#define	PDU_PRODUCT_DATA_FILE	"/usr/ip32/product_data"
#define PDU_MAIN_DIR		"PDU"
#define PDU_ORIGINS_DIR		"origins"
#define PDU_PARTS_DIR		"parts"
#define PDU_TAGNO_DIR           "tag"
#define PDU_SERIAL_DIR          "serial"
#define PDU_ALTTAG_DIR          "alt_tag"
#define PDU_ASMSTR_DIR          "asm_incl_str"
#define PDU_INCBOM_DIR          "incl_BOM"
#define PDU_EXPBOM_DIR          "p_explode"
#define PDU_TAGGEN_DIR          "tag_gen"
#define PDU_TAGCNT_DIR          "tag_cnt"
#define PDU_MGR_NAME		"Part Mgr"
#define PDU_OWNER_CHANNAME	"GRcmpowner.to_components"
#define PDU_MEMBER_CHANNAME	"GRconnector.to_owners"
#define PDU_MGR_CLASS		"GRsvset"
#define PDU_MGR_CHANNAME	PDU_OWNER_CHANNAME
#define PDU_PTR_CLASS		"GRclhdr"
#define PDU_CONVERT_DIR		"converted"

/* report types for part pointers */
#define PDU_REPORT_VIEW         1
#define PDU_REPORT_ORIGIN       2
#define PDU_REPORT_PARTID       3
#define PDU_REPORT_SERIAL       4
#define PDU_REPORT_LOCATION     5
#define PDU_REPORT_ORIENTATION  6
#define PDU_REPORT_CHECKIN      219
#define PDU_REPORT_GENBOM       220
#define PDU_REPORT_LIST         221
#define PDU_REPORT_ATTACH       222
#define PDU_REPORT_CONVERT      223
#define PDU_REPORT_PARTSPEC	7
#define PDU_REPORT_REPLACE	8

/* column count for part reports */
#define PDU_PARTSPEC_COLS	3
#define PDU_ATTACH_COLS		4
#define PDU_REPLACE_COLS	5
#define PDU_LIST_COLS		6
#define PDU_GENBOM_COLS		9
#define PDU_CHECKIN_COLS	9
#define PDU_CONVERT_COLS	9

#define PDU_K_MAXINT		((int) 0x7fffffff)
#define	PDU_K_DELIMITER		'\1'
#define	PDU_K_ORIENTATION_LEN	528
#define	PDU_K_VWORIGIN_LEN	100

#define PDU_DEFAULT_QUANTITY	"1"
#define PDU_DEFAULT_USAGE	"..."
#define PDU_DEFAULT_HISTORY	"..."
#define PDU_DEFAULT_SYMBOL	'X'
#define PDU_INDICATOR_LEVEL	1023

#define PDU_SYMBOL_INDEX	0
#define PDU_VISIBLE_INDEX	1
#define PDU_INVISIBLE_INDEX	2

#define PDU_PART_TEXT		3
#define PDU_ORIGIN_TEXT		2

#define PDU_VISIBLE_PART	7
#define PDU_INVISIBLE_PART	2
#define PDU_VISIBLE_ORIGIN	2

/* indices of text fields in part pointer visible text */
#define PART_PARTID_FIELD       0
#define PART_REVISION_FIELD     1
#define PART_CATALOG_FIELD      2
#define PART_DATE_FIELD         3
#define PART_SERIAL_FIELD       4
#define PART_USAGEID_FIELD      5
#define PART_QUANTITY_FIELD     6
#define PART_VIEWNAME_FIELD     0
#define PART_HISTORY_FIELD      1
#define PART_ORIENT_FIELD       2

/* indices of text fields in origin pointer visible text */
#define ORIGIN_NAME_FIELD       0
#define ORIGIN_DATE_FIELD       1
#define ORIGIN_LOCATION_FIELD   2
#define PDU_NULL_FIELD		-1

/* external process requests */
#define PDU_EXT_NFSMOUNT	0
#define PDU_EXT_NFSUNMOUNT	1
#define PDU_EXT_OSCONVERT	2

/* view orientation strings for common windows */
#define PDU_TOP			"1:0:0:0:0:1:0:0:0:0:1:0:0:0:0:1:"
#define PDU_FRONT		"1:0:0:0:0:0:1:0:0:-1:0:0:0:0:0:1:"
#define PDU_RIGHT		"0:1:0:0:0:0:1:0:1:0:0:0:0:0:0:1:"
#define PDU_LEFT		"0:-1:0:0:0:0:1:0:-1:0:0:0:0:0:0:1:"
#define PDU_BACK		"-1:0:0:0:0:0:1:0:0:1:0:0:0:0:0:1:"
#define PDU_BOTTOM		"1:0:0:0:0:-1:0:0:0:0:-1:0:0:0:0:1:"

/* view orientation strings for common windows */
#define PDUTOP			"PDUtop"
#define PDUFRONT		"PDUfront"
#define PDURIGHT		"PDUright"
#define PDULEFT			"PDUleft"
#define PDUBACK			"PDUback"
#define PDUBOTTOM		"PDUbottom"
#define PDU_DEFAULT_VIEW	"PDUview"

/* expressions constants */
#define TEXT			0
#define NUMERIC			1
#define EXP_MAX_LEN		128

/* file service support */
#define PDU_FS_DIRNAME		"pdu.fs"
#define PDU_NFSMOUNT_DIR	".nfs"
#define PDU_PATHNAME_SIZE	256

/* general constants */
#ifndef NULLSTR
#define NULLSTR			""
#endif
#ifndef NULLCHAR
#define NULLCHAR		'\0'
#endif
#ifndef NULL
#define NULL			0
#endif
#ifndef TRUE
#define TRUE			1
#endif
#ifndef FALSE
#define FALSE			0
#endif
#ifndef ON
#define ON			1
#endif
#ifndef OFF
#define OFF			0
#endif

#endif
