/* $Id: VDStextdef.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDStextdef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDStextdef.h,v $
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


/****************************************************************************


		File:	VDStextdef.h
		Type:   c include file
		Use:	Defines constants for Text form Parameters
		Date:	10 September 1991 - Genisis -
		Autr:	adz - isdc
		
***************************************************************************/

#ifndef VDStextdef_include

#define VDStextdef_include

/* gadget labels for the form VDSTextSet */

#define	VDS_SELECT_FLD	30	/* set select		*/
#define	VDS_PREFIX_FLD	31
#define	VDS_EXPRES_FLD	32	/* select expression	*/
#define	VDS_SUFFIX_FLD	33
#define	VDS_READ_BUT	44
#define	VDS_WRITE_BUT	45
#define	VDS_ACTIVE_BUT	46
#define VDS_ATTACH_NAME 13
#define	VDS_FORM_ACT	100
#define	VDS_FORM_PAS	101
#define	VDS_FORM_INFO	255	/* exist for form notification */

#define VDS_EXPR_DIR	":set_refer"
#define	VDS_ACT_SELECT	"act_select"	/* expression name */
#define	VDS_EXP_NAME	"expr__"	/* expression index names */
#define VDS_SEPARATOR	"|"		/* insert separator for expression */
#define VDS_TEST_SEP	'|'		/* test separator character */

#define	VDS_SELECT_MAX	10  /* set select		*/
#define	VDS_PREFIX_MAX	20  /* expression length must be < 128 = EXP_MAX_LEN */
#define	VDS_EXPRES_MAX	70  /* select expression	*/
#define	VDS_SUFFIX_MAX	20

#define	VDS_REF_DIR	":ref:"		/* <filename>:<ref> */
#define	VDS_REFNAMES_DIR "refnames:"	/* <filename>:<ref>:<refnames> */

/* string constants */

struct VDStextset{

	IGRchar		exp_name[DI_PATH_MAX];	/* expression name	*/

	IGRchar		expres[DI_PATH_MAX];
	IGRchar		prefix[DI_PATH_MAX];
	IGRchar		suffix[DI_PATH_MAX];
	IGRchar		select[DI_PATH_MAX];

};


struct VDStextlist{

	IGRint		num_textset;
	IGRint		inc_textset;
	IGRint		max_textset;

	struct	VDStextset	*text;
};



#endif
