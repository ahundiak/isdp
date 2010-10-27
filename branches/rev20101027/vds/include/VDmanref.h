/* $Id: VDmanref.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:	include/VDmanref.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDmanref.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/12/30  15:43:28  pinnacle
 * Created: include/VDmanref.h by mdong for vds
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      12/17/97      Adz & Ming        Creation
 *			
 ***************************************************************************/

#include "FI.h"
#include "CIforms.h"

extern FIf_set_cmd_oid_os ();
extern FIfld_set_text ();
extern FIfld_set_select ();
extern FIfld_set_mode ();
extern FIfld_get_select ();
extern FIfld_set_line_color ();
extern FIfld_get_line_color ();
extern FIfld_set_num_rows();
extern FIf_new ();
extern FIf_delete ();
extern FIf_display ();
extern FIg_get_state ();
extern FIg_disable ();
extern FIg_enable ();
extern FIg_erase ();
extern FIg_display ();
extern FIfld_get_text ();
extern FIg_set_state_off ();
extern FIfld_get_num_rows ();
extern FIfld_pos_cursor ();
extern FIfld_get_num_vis_rows ();
extern FIg_set_state ();



#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* EXRf_tools.c */
extern int EXRcenter_message __((Form form, int g_label, char *msg_str));
extern int EXRget_text __((Form form, int gadget_label, int row, int col, char *text, int *text_size));
extern int EXRconvert_lev_array __((IGRint *msg, IGRint *levels, char * buffer));
extern int EXRget_on_off_lev __((IGRint *msg, IGRint *levels, IGRshort *on_levels, IGRshort *num_on_levels, IGRshort *off_levels, IGRshort *num_off_levels));

#if defined(__cplusplus)
}
#endif

#ifndef EXRdetail_include

#define EXRdetail_include

#define EXR_GET_TEXT_MAX   80
#define EXR_GET_DEF_LAYER  "0-1023"

/* definition for the structure of reference file */
struct EXR_reffile{
        IGRchar         ref_name[EXR_GET_TEXT_MAX];
        IGRulong        properties;
        int             display;
        GRspacenum      osnum;
        struct GRid     ctx_id;
        struct GRmd_env md_env;
};

/**  Structure definitions for the forms **/

typedef struct EXRform_globals
{
    int  cur_ref_idx;
    int  cur_ref_level;
    int  ref_count;

    int  main_form_exists;
    int  ref_form_exists;
    int  help_form_exist;

    int  main_form_displayed;
    int  ref_form_displayed;
    int  help_form_displayed;

    Form main_form;
    Form ref_form;
    Form help_form;
} EXRglobals;

typedef struct EXRref_struct
 {
    int  level;
    int  on_off;
    int  parent;
    int  display;
    char ref_file[40];
    char file[256];
    GRspacenum  osnum;
    struct GRid ctx_id;
    struct GRmd_env md_env;
 } EXRreference_files;

#endif

/*****   Form Information.     ***********/

#define EXRREF_FORM    200

#define EXR_REF_FORM   "VDmref"

/*****   Gadget Labels   ***********/
#define EXR_SINGLE_SELECT_MODE  0
#define EXR_MULTI_SELECT_MODE   1

/*****   Manipulate Reference Files Form       *****/

#define EXR_REF_FILES_SCF       14  /** Multi Select **/
#define EXR_ON_OFF_LAY_TOGGLE   15
#define EXR_SEL_MODE_TOGGLE     34
#define EXR_DISPLAY_TOGGLE      36
#define EXR_NESTED_REFS_BUTTON  17
#define EXR_LAYERS_MCF          20  /** Multi Select **/
#define EXR_GG_SINGLE_REF       30  /* gadgets 13 17, 20, 21, 22, 23, 24, 25 */
#define EXR_HELP                40  /* don't use FI_HELP due to initialize */

#define EXR_USED_TEXT           13
#define EXR_USED_RECT           25
#define EXR_LAYER_TEXT          22
#define EXR_LAYER_RECT          23
#define EXR_VALUE_TEXT          21
#define EXR_VALUE_RECT          24

#define EXR_KEYIN_LAYER_FIELD   31
#define EXR_KEYIN_TEXT          32
#define EXR_GG_MULTIPLE_REF     33  /* gadgets 31, 32                     */



