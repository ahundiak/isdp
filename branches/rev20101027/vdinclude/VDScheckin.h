/* $Id: VDScheckin.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDScheckin.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDScheckin.h,v $
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
 * Revision 1.2  1996/05/30  20:48:08  pinnacle
 * Replaced: vdinclude/VDScheckin.h for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	05/30/96   tlb		Add REP_* constants
 *
 * -------------------------------------------------------------------*/

#ifndef	VDScheckin_include
#define	VDScheckin_include

#define		DB_WARNING	-2

/* 
 * Keys for posting
 */
#define		REG_CHECKIN	"_dynamic"
#define		DWG_CHECKIN	"_cit"

/*  
 * Representations for posting
 */
#define		REP_MODEL	"model"
#define		REP_SCHEM	"schematic"

#define         REG_CATALOG     "assembly_cat"
#define         REG_PARTNUM     "assembly_nam"
#define         REG_PARTREV     "assembly_ver"

#define         DWG_CATALOG     "dwg_cat"
#define         DWG_PARTNUM     "dwg_nam"
#define         DWG_PARTREV     "dwg_rev"

#define         COMP_NO_TABLE   "vds_comp_no"
#define         NEW_COMP_NO     "new_comp_no"
#define         OLD_COMP_NO     "old_comp_no"

#define         CATALOG_NAM     "n_catalogname"
#define         CATALOG_NUM     "n_catalogno"
#define         CATALOG_TAB     "nfmcatalogs"

#define         ITEM_NUM        "n_itemno"
#define         PART_NAM        "n_itemname"
#define         PART_REV        "n_itemrev"

#define		MAX_TABLES_NB	23
#define		REG_TABLES_NB	23
#define		DWG_TABLES_NB	23
#define         REG_FIRST_ATTR	4    /* the first are not feet */
#define         DWG_FIRST_ATTR	9    /* the first are not feet */
#define         MAX_ROW_CHAR    1024 /* Max line size (should be dyn. alloc.) */

#define		COOR_SYS_NAME	"ref"
#define		LOC_X		"loc_x"
#define		DOUBLE_COL	':'

#define		STRUCT_NAM	"struct"
#define		STRUCT_LEN	6
#define		MEMBER_NAM	"memb_name"

struct VDattr_data
{
     short          type;
     union
     {

           char      attr_c[80];
           int       attr_int;
           double    attr_dbl;
     } val;
};

struct VDrisdat
{
          char                  name[80];
          struct VDattr_data    data;
};

/* Definitions for VDScheckin directory only. MSM. Nov-1-93 */

/* 0 and 1 are used as failure and success in the system throughout. */

#define		VDS_E_DYNAMIC_TABLE_NOT_FOUND	2

#endif
