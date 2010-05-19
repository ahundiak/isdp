/* $Id: SMcon.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / SMcon.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMcon.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
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

/* include for the file SMChkFile.I and for the form SMBrkConx*/

#define		FI_MSG_FIELD	10
#define		EXIT		4
#define		SAVE		1
#define		CHK_BUTTON	23
#define		ALL_CONNECT	16
#define		NB_BROKEN	14
#define		NB_STILL_BRK	17
#define		CONNECTION	11


#define		CHK_CON		511

struct TagConInfo{
	struct GRid	obj;
	IGRchar		intname[OM_K_MAXINTOSNAME_LEN];
	OMuint		count;
	OM_S_OBJID	*oidlist;
	OMuint		*taglist;
	
};

struct	GoInfo{
	struct GRid	obj;
	IGRchar		obj_name[DI_PATH_MAX];
 	OMuint		tag;
	IGRchar		class_name[DI_PATH_MAX];
	GRclassid	class_id;
};

struct ConnInfo{
	struct GRid	source_id;
	IGRchar		class_name[DI_PATH_MAX];
	IGRchar		ref_name[DI_PATH_MAX];
	struct GRid	ref_id;
	OMuint		ref_osnum;
	struct GRid	context_id;
	struct GoInfo	go_info;
	int		nb_child;
	struct GoInfo	*child;
	
};
