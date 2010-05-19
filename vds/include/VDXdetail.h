/* $Id $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/VDXdetail.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXdetail.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1999/04/19  14:08:00  pinnacle
 * for dynapipe
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/16/99        ylong           created
 *			
 ***************************************************************************/

#ifndef VDXdetail_include

#define VDXdetail_include

#define VDX_GET_TEXT_MAX 80

/* definition for the structure of reference file */
struct VDX_reffile{
	IGRchar		ref_name[VDX_GET_TEXT_MAX];
	IGRshort	mx_type;	/* GRcontext instance */
	IGRmatrix	matrix;
	IGRshort	flags;
        int             os_active;
        int             display;
	GRspacenum	osnum;
	struct GRid	ctx_id;
	struct GRmd_env	md_env;
};

#endif
