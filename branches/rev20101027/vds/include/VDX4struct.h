/* $Id: VDX4struct.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/VDX4struct.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDX4struct.h,v $
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

#define VDX_GET_TEXT_MAX   80
#define VDX_GET_DEF_LAYER  "0-1023"

/* definition for the structure of reference file */
struct VDX_reffile{
	IGRchar		ref_name[VDX_GET_TEXT_MAX];
	IGRulong	properties;
        int             display;
	GRspacenum	osnum;
	struct GRid	ctx_id;
	struct GRmd_env	md_env;
};

/**  Structure definitions for the forms **/

typedef struct VDXform_globals
{
    int		cur_ref_idx;
    int		cur_ref_level;
    int		ref_count; 

    int		main_form_exists;
    int		ref_form_exists;
    int		help_form_exist;

    int		main_form_displayed;
    int		ref_form_displayed;
    int		help_form_displayed;

    Form	main_form;
    Form	ref_form;
    Form	help_form;

    int		productionFlag ;

} VDXglobals; 

typedef struct VDXref_struct
 {
    int  level;
    int  on_off;
    int  parent;
    int  display;
    char ref_file[40];
    char file[256];
    GRspacenum	osnum;
    struct GRid	ctx_id;
    struct GRmd_env md_env;
 } VDXreference_files;

#endif
