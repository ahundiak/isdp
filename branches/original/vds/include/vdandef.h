/* $Id: vdandef.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / vdandef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdandef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
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
 * Revision 1.5  1995/07/13  13:09:50  pinnacle
 * Replaced: include/vdandef.h for:  by jwfrosch for vds.240
 *
 * Revision 1.4  1995/06/23  15:40:54  pinnacle
 * Replaced: include/vdandef.h for:  by yzhu for vds.240
 *
 * Revision 1.2  1995/05/19  15:59:32  pinnacle
 * Replaced: include/vdandef.h by yzhu r#
 *
 * Revision 1.2  1994/12/12  17:10:26  pinnacle
 * Replaced:  include/vdandef.h r#
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* I/VDS
 *
 * File:        ~VDS/include/vdandef.h
 *
 * Description: This file is the include file for functions that  
 *              place annotation/item
 *
 * History:
 *      08/07/94        Chaya V. Rao
 *
 */
/*============================================================================*/

#ifndef vdandef_include

#define vdandef_include


#define  VD_ANNOT_LEFT_BASE      0.0      
#define  VD_ANNOT_LEFT_CENTER    1.0 
#define  VD_ANNOT_LEFT_CAP       2.0 
 
#define  VD_ANNOT_CENTER_BASE    3.0 
#define  VD_ANNOT_CENTER_CENTER  4.0 
#define  VD_ANNOT_CENTER_CAP     5.0
 
#define  VD_ANNOT_RIGHT_BASE     6.0 
#define  VD_ANNOT_RIGHT_CENTER   7.0 
#define  VD_ANNOT_RIGHT_CAP      8.0

struct VDan_segs
{
   IGRdouble   angle;
   IGRdouble   len;
};

struct VDan_ldrline
{
   IGRint            num_segs;
   struct VDan_segs  *segs;
};

struct deg_name
{
        IGRchar        fname[80];
        IGRchar        pname[80];
};

struct VD_id_name
{   
        struct GRid		tbl_id;
        IGRchar         	tbl_name[80];	               
        struct deg_name 	deg_file;
};

struct VDitemNbElm{
     IGRchar            itemNum[80];          /* whole item number name. */
     IGRchar            itemPre[80];          /* item prefix.            */
     IGRchar            itemSuf[80];          /* item suffix.            */
     IGRint             itemSeq;              /* item sequence number.   */
};

struct VDTblId_Name
{
    struct GRobj_env	tbl_id;			/* GRobj_env of Table		*/
    IGRchar		tbl_nm[80];		/* Table Name as displayed	*/
    IGRchar		pth_nm[80];		/* Full Path Name of Table	*/
};
#endif
