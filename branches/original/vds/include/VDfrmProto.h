/* $Id: VDfrmProto.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDfrmProto.h
 *
 * Description: FI wrappers
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDfrmProto.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1998/03/02  18:37:44  pinnacle
 * AssyTree
 *
 * Revision 1.2  1998/02/25  16:03:50  pinnacle
 * ah
 *
 * Revision 1.1  1998/02/20  23:52:10  pinnacle
 * AssyTree
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/20/98  ah      Creation  
 ***************************************************************************/
#ifndef VDfrmProto_include
#define VDfrmProto_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* For the Form Definition */
#ifndef   FI_H_INCLUDED
#include "FI.h"
#endif

/* --------------------------------------------------------------------------
 * Copied from VX_proto.h
 */
#ifndef VD_PPL
%safe
#if defined(X11)
#include "XFIproto_pub.h"
#elif defined(ENV5)
#include "FIproto_pub.h"
#endif
%endsafe
#endif

/*
 * VDS declared prototype routines.
 */

#if defined(__cplusplus)
extern "C" {
#endif


extern int VDfld_set_list_text __((Form form, int label, int row, int col,char *text, int sel_flg));

extern int VDgrp_callback __((Form form, int group_label, 
                           void (*callback_routine)(), int user_arg));

/*
 * End of copied stuff
 * ------------------------------------------------------------------------ */

/* -------------------------------------------
 * VDS Wrapper Functions
 */

// General
extern int VI_get_form_by_name __((char *name, Form *form));

// Form
extern int VIf_delete  __((Form form));
extern int VIf_erase   __((Form form));
extern int VIf_display __((Form form));

extern int VIf_new __((int label, 
            char *name,
            int (*notification_routine)(), 
            Form *form));

extern int VIf_set_cmd_oid_os __((Form form, 
                       unsigned int   cmd_oid,
                       unsigned short cmd_os));

extern int VIf_is_valid __((Form form));

extern int VIf_collapse __((Form form));

extern int VIf_cvrt_to_perm_win __((Form form));

extern int VIf_get_location __((Form form, int *xpos, int *ypos));
extern int VIf_set_location __((Form form, int  xpos, int  ypos));

extern int VIf_set_resize_off __((Form form));
extern int VIf_set_resize_on  __((Form form));

extern int VIf_get_name __((Form form, char *name));

// Gadget
extern int VIg_erase     __((Form form, int gadget));
extern int VIg_display   __((Form form, int gadget));
extern int VIg_enable    __((Form form, int gadget));
extern int VIg_disable   __((Form form, int gadget));
extern int VIg_set_text  __((Form form, int gadget, char *text));
extern int VIg_get_text  __((Form form, int gadget, char *text));
extern int VIg_set_state __((Form form, int gadget, int   state));
extern int VIg_get_state __((Form form, int gadget, int  *state));

// Fields
extern int VIfld_get_text     __((Form form, int gadget, int  row, int col, int size, char *text, int *sel, int *pos));
extern int VIfld_set_text     __((Form form, int gadget, int  row, int col, char *text, int  sel));
extern int VIfld_get_select   __((Form form, int gadget, int  row, int col, int *sel));
extern int VIfld_set_select   __((Form form, int gadget, int  row, int col, int  sel));
extern int VIfld_get_num_rows __((Form form, int gadget, int *rows));
extern int VIfld_set_num_rows __((Form form, int gadget, int  rows));
extern int VIfld_delete_rows  __((Form form, int gadget, int  row, int rows));

extern int VIfld_get_active_row   __((Form form, int gadget, int *row, int *pos));
extern int VIfld_insert_blank_row __((Form form, int gadget, int  row));

extern int VIfld_set_list_num_rows __((Form form, int gadget, int col, int rows));
extern int VIfld_set_list_text     __((Form form, int gadget, int row, int col, char *text, int sel));

// Internal
extern int VI_error     __((int errCode, char *errMsg));
extern int VIf_validate __((char *funcName, Form form, int gadget));


// So PPL programs dont need to extern them
#ifdef VD_PPL
extern FIf_display();
extern FIf_delete();
extern FIf_erase();
extern FIf_new();
extern FIf_set_cmd_oid_os();
extern FIf_get_name();

extern FIg_erase();
extern FIg_display();
extern FIg_enable();
extern FIg_disable();
extern FIg_get_text();
extern FIg_set_text();
extern FIg_get_state();
extern FIg_set_state();

extern FIfld_delete_rows();
extern FIfld_set_num_rows(); 
extern FIfld_get_num_rows();
extern FIfld_get_active_row();
extern FIfld_insert_blank_row();

extern FIfld_get_text();
extern FIfld_set_text();
extern FIfld_get_select();
extern FIfld_set_select();

extern FIfld_set_list_num_rows();
extern FIfld_set_list_text();

extern FI_get_form_by_name();
#endif

#if defined(__cplusplus)
}
#endif

#endif











