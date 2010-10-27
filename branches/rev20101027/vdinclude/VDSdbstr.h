/* $Id: VDSdbstr.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDSdbstr.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbstr.h,v $
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
 * Revision 1.3  1996/05/16  21:21:16  pinnacle
 * Replaced: vdinclude/VDSdbstr.h for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1996/04/22  14:10:20  pinnacle
 * Replaced: vdinclude/VDSdbstr.h for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/19/96   tlb		Removed duplicate file from $VDS/include
 *				Remove: DOUBLE, VDS_DIR
 *				Rename with VDS_BUF_*
 *	05/09/96   tlb		Remove: LOGIN   
 *			
 *
 * -------------------------------------------------------------------*/

#ifndef	VDSdbstr_include
#define	VDSdbstr_include

/* declarations */
#define  	VDS_BUF_MAX_CHAR    	5
#define  	VDS_BUF_MEM_START    	50
#define  	VDS_BUF_MEM_STEP    	10
#define  	VDS_BUF_MAX_PART    	50
#define		VDS_BUF_CAT_ATTR	6
#define		VDS_BUF_MAX_ATTR_LEN    25
#define		VDS_BUF_F_CAT_ATTR	3
#define  	VDS_BUF_MAX_WORD    	80
#define  	VDS_BUF_MAX_LONG    	240
#define  	VDS_BUF_MAX_STRING 	1024
#define  	VDS_BUF_SIZE 		512

/* #define		TRUE		1 */
/* #define		FALSE		0 */

/* external definitions */
#define         VDS_FAM_TEMP_FILE     	"/tmp/family"
#define         LIBRARY  	"pdmlibraries"
#define         LIBREV  	"vds"


/* constants */
#define         ONE  		"\1"
#define         NULL_FORMAT  	"NULL"

#define         NULLSTR     	""
#define         NULL_STRING  	"NULL"

/* characters */
#define         BACK_N          '\n'
#define         BLANK           ' '
#define         COLUMN          ':'
#define         EQUAL           '='
#define         SLASH           '/'

/* PDM attributes */
#define		PDU_DESCRIPTION_ATTR	"n_itemdesc"

#define         RIS_KEYWORD_FILE        "keyword.doc"

struct MFseg
{
       char  text[VDS_BUF_MAX_WORD];
       char  unit[VDS_BUF_MAX_WORD];
};

struct MFlin
{
        int            seg_num;
        struct MFseg   name[VDS_BUF_MAX_PART];
};

struct MFparam
{
       char  name[VDS_BUF_MAX_WORD];
       char  value[VDS_BUF_MAX_WORD];
};

struct MFpart
{
        int            number;
        struct MFparam *parameter;
};

#endif
