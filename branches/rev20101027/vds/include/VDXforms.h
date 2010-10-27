/* $Id: VDXforms.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/VDX4_inc.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXforms.h,v $
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

#include "FI.h"
#include "CIforms.h"

extern FIg_set_value ();
extern int FI_append_form_path ();
extern int FI_append_symbol_path ();
extern FIf_set_cmd_oid_os ();
extern FIfld_set_text ();
extern FIfld_set_select ();
extern FIfld_set_mode ();
extern FIfld_get_select ();
extern FIfld_set_line_color ();
extern FIfld_get_line_color ();
extern FIfld_set_max_num_rows();
extern FIfld_set_num_rows();
extern FIf_new ();
extern FIf_erase ();
extern FIf_delete ();
extern FIf_display ();
extern FIg_get_text_length ();
extern FIg_get_state ();
extern FIg_disable ();
extern FIg_enable ();
extern FIg_erase ();
extern FIg_display ();
extern FIg_get_text ();
extern FIg_set_text ();
extern FIfld_set_default_text ();
extern FIg_reset ();
extern FImcf_get_active_col ();
extern FIg_get_text_length ();
extern FIfld_get_text ();
extern FIg_get_type ();
extern FIfld_get_active_row ();
extern FIfld_get_text_length ();
extern FIfld_set_list_default_text ();
extern FIg_set_state_off ();
extern FIfld_get_num_rows ();
extern FIfld_pos_cursor ();
extern FIfld_get_num_vis_rows ();
extern FIg_set_state ();


/*****   Form Information.     ***********/

#define EX4RVW_FORM    100
#define VDXREF_FORM    200
#define VDXHLP_FORM    300

#define VDX_MAIN_FORM  "VDXmain"
#define VDX_REF_FORM   "VDXref"
#define VDX_HELP_FORM  "VDXhelp"

/*****   Gadget Labels   ***********/

/*****   Main Form       *****/

#define	VDX_PRODUCTION_DATA	13
#define VDX_COMPLETION_DIAL	14
#define VDX_WIN_FEN_TOGGLE	15
#define VDX_MANIP_REF_BUTTON	17
#define VDX_IGDS_FILE_FIELD	19

#define VDX_SINGLE_SELECT_MODE  0
#define VDX_MULTI_SELECT_MODE   1


/*****   Manipulate Reference Files Form       *****/

#define VDX_REF_FILES_SCF	14  /** Multi Select **/
#define VDX_ON_OFF_LAY_TOGGLE   15 	
#define VDX_SEL_MODE_TOGGLE     34 	
#define VDX_DISPLAY_TOGGLE      36 	
#define VDX_NESTED_REFS_BUTTON	17
#define VDX_LAYERS_MCF		20  /** Multi Select **/
#define VDX_GG_SINGLE_REF       30  /* gadgets 13 17, 20, 21, 22, 23, 24, 25 */ 
#define VDX_HELP                40  /* don't use FI_HELP due to initialize */ 

#define VDX_USED_TEXT	        13 
#define VDX_USED_RECT	        25
#define VDX_LAYER_TEXT	        22
#define VDX_LAYER_RECT	        23
#define VDX_VALUE_TEXT	        21
#define VDX_VALUE_RECT	        24

#define VDX_KEYIN_LAYER_FIELD   31
#define VDX_KEYIN_TEXT          32
#define VDX_GG_MULTIPLE_REF     33  /* gadgets 31, 32                     */

