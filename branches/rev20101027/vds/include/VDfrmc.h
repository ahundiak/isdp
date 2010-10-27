/* $Id: VDfrmc.h,v 1.2 2001/02/22 23:00:44 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDfrmc.h
 *
 * Description: c Version of forms wrappers
 *
 * Dependencies: VDtypedefc.h or VDtypedef.h
 *
 * Revision History:
 *      $Log: VDfrmc.h,v $
 *      Revision 1.2  2001/02/22 23:00:44  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/10 15:42:24  art
 *      sp merge
 *
 * Revision 1.4  2000/12/08  20:50:42  pinnacle
 * ah
 *
 * Revision 1.3  2000/12/07  13:34:10  pinnacle
 * ah
 *
 * Revision 1.2  2000/12/06  14:43:02  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  13:52:48  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/29/00  ah      Creation  
 * 01/10/01  ah      sp merge
 ***************************************************************************/
#ifndef VDfrmc_include
#define VDfrmc_include

/* -----------------------------------------------
 * This is a zdl safe file and defines the Form
 */
#ifndef   FI_H_INCLUDED
#include "FI.h"
#endif

/* -----------------------------------------------
 * This is a big honking non-zdl safe file
 * Since the idea is not to call any fi functions
 * directly it seems safe to skip the actual loading
 *
 * As long as the VD routines are written correctly then
 * we should be ok
 */
#ifndef   XFIPROTO_PUB_H_INCLUDED
// #include "XFIproto_pub.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* -------------------------------------------
 * VDS Wrapper Functions
 * Mainly to do error checking
 * Might allow possibility of swapping different form
 * library at a later date
 */

// General
extern int VI_get_form_by_name __((char *name, Form *form));

// Form
extern int VIf_delete  __((Form form));
extern int VIf_erase   __((Form form));
extern int VIf_reset   __((Form form));
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
extern int VIfld_set_list_text     __((Form form, int gadget, int row, int col, char *text, int  sel));
extern int VIfld_get_list_text     __((Form form, int gadget, int row, int col, int size, char *text, int *sel));

// Internal
extern int VI_error     __((int errCode, char *errMsg));
extern int VIf_validate __((char *funcName, Form form, int gadget));

/* ------------------------------------------
 * High level interface
 */
extern IGRstat VDfrmSetText        __((Form        form,   /* I - The form     */
				       IGRint      gadget, /* I - The gadget   */
				       IGRint      row,    /* I - The row      */
				       IGRint      col,    /* I - The col      */
				       IGRint      sel,    /* I - Is selected  */
				       IGRchar    *txt,    /* I - The text     */
				       IGRint      rows,   /* I - The num rows */
				       TGRobj_env *objOE,  /* I - The oe       */
				       TGRid      *objID));/* I - The id       */

extern IGRstat VDfrmSetfText       __((Form        form,   /* I - The form     */
				       IGRint      gadget, /* I - The gadget   */
				       IGRint      row,    /* I - The row      */
				       IGRint      col,    /* I - The col      */
				       IGRchar    *txt));  /* I - The text     */

extern IGRstat VDfrmSetfPnt        __((Form        form,   /* I - The form     */
				       IGRint      gadget, /* I - The gadget   */
				       IGRint      row,    /* I - The row      */
				       IGRint      col,    /* I - The col      */
				       void       *pnt));  /* I - The pointer  */

extern IGRstat VDfrmSetfID         __((Form        form,   /* I - The form     */
				       IGRint      gadget, /* I - The gadget   */
				       IGRint      row,    /* I - The row      */
				       IGRint      col,    /* I - The col      */
				       TGRid      *id));   /* I - The id       */

extern IGRstat VDfrmSetStatus      __((Form     form,      /* I - The form     */
				       IGRint   gadget,    /* I - The gadget   */
				       IGRchar *txt));     /* O - The status   */

#define VDfrmSetSts(form,gadget) VDfrmSetStatus(form,10,gadget)
#define VDfrmGetSts(form,gadget) VDfrmGetgText (form,10,gadget)

extern IGRstat VDfrmGetText        __((Form        form,   /* I - The form     */
				       IGRint      gadget, /* I - The gadget   */
				       IGRint      row,    /* I - The row      */
				       IGRint      col,    /* I - The col      */
				       IGRint      len,    /* I - The text len */
				       IGRint     *sel,    /* O - Is  selected */
				       IGRint     *pos,    /* O - The position */
				       IGRchar    *txt,    /* O - The text     */
				       IGRint     *rows,   /* O - The num rows */
				       TGRobj_env *objOE,  /* O - The oe       */
				       TGRid      *objID));/* O - The id       */

extern IGRstat VDfrmGetfText       __((Form        form,   /* I - The form     */
				       IGRint      gadget, /* I - The gadget   */
				       IGRint      row,    /* I - The row      */
				       IGRint      col,    /* I - The col      */
				       IGRchar    *txt));  /* O - The text     */

extern IGRstat VDfrmGetfPnt        __((Form        form,   /* I - The form     */
				       IGRint      gadget, /* I - The gadget   */
				       IGRint      row,    /* I - The row      */
				       IGRint      col,    /* I - The col      */
				       void      **pnt));  /* 0 - The pointer  */

extern IGRstat VDfrmGetfID         __((Form        form,   /* I - The form     */
				       IGRint      gadget, /* I - The gadget   */
				       IGRint      row,    /* I - The row      */
				       IGRint      col,    /* I - The col      */
				       TGRid      *id));   /* O - The id       */

extern IGRstat VDfrmGetNumRows     __((Form    form,       /* I - The form     */
				       IGRint  gadget,     /* I - The gadget   */
				       IGRint *rows,       /* O - number of rows (0 on failure) */
				       IGRint *vis,        /* O - number of visible rows        */
				       IGRint *off));      /* O - offset of top row             */

extern IGRstat VDfrmSetNumRows     __((Form    form,       /* I - The form       */
				       IGRint  gadget,     /* I - The gadget     */
				       IGRint  rows));     /* I - number of rows */

extern IGRstat VDfrmShowRow        __((Form    form,       /* I - The form    */
				       IGRint  gadget,     /* I - The gadget  */
				       IGRint  row));      /* I - The row     */


extern IGRstat VDfrmGetListNumRows __((Form    form,       /* I - The form   */
				       IGRint  gadget,     /* I - The gadget */
				       IGRint  col,        /* I - The column */
				       IGRint *rows));     /* O - number of rows */

extern IGRstat VDfrmGetgListNumRows __((Form    form,       /* I - The form   */
					IGRint  gadget,     /* I - The gadget */
					IGRint *rows));     /* O - number of rows */


extern IGRstat VDfrmSetListNumRows __((Form    form,       /* I - The form       */
				       IGRint  gadget,     /* I - The gadget     */
				       IGRint  col,        /* I - The column     */
				       IGRint  rows));     /* I - number of rows */

extern IGRstat VDfrmSetgListNumRows __((Form    form,      /* I - The form       */
				        IGRint  gadget,    /* I - The gadget     */
					IGRint  rows));    /* I - number of rows */

extern IGRstat VDfrmSetListText    __((Form     form,      /* I - The form     */
				       IGRint   gadget,    /* I - The gadget   */
				       IGRint   row,       /* I - The row      */
				       IGRint   col,       /* I - The column   */
				       IGRint   sel,       /* I - Is  selected */
				       IGRchar *txt,       /* I - The text     */
				       IGRint   rows));    /* I - The num rows */

extern IGRstat VDfrmSetgListText   __((Form     form,      /* I - The form     */
				       IGRint   gadget,    /* I - The gadget   */
				       IGRint   row,       /* I - The row      */
				       IGRchar *txt));     /* I - The text     */

extern IGRstat VDfrmGetListText    __((Form     form,      /* I - The form     */
				       IGRint   gadget,    /* I - The gadget   */
				       IGRint   row,       /* I - The row      */
				       IGRint   col,       /* I - The column   */
				       IGRint  *sel,       /* O - Is  selected */
				       IGRchar *txt));     /* O - The text     */

extern IGRstat VDfrmGetgListText   __((Form     form,      /* I - The form     */
				       IGRint   gadget,    /* I - The gadget   */
				       IGRint   row,       /* I - The row      */
				       IGRchar *txt));     /* O - The text     */

extern IGRstat VDfrmGetMode        __((Form    form,       /* I - The form     */
				       IGRint  gadget,     /* I - The gadget   */
				       IGRint  col,        /* I - The column   */
				       IGRint *mode));     /* O - The mode     */

extern IGRstat VDfrmSetMode        __((Form    form,       /* I - The form     */
				       IGRint  gadget,     /* I - The gadget   */
				       IGRint  col,        /* I - The column   */
				       IGRint  mode));     /* I - The mode     */


extern IGRstat VDfrmGetSelect      __((Form    form,       /* I - The form     */
				       IGRint  gadget,     /* I - The gadget   */
				       IGRint  row,        /* I - The row      */
				       IGRint  col,        /* I - The column   */
				       IGRint *sel));      /* O - The select   */

extern IGRstat VDfrmSetSelect      __((Form    form,       /* I - The form     */
				       IGRint  gadget,     /* I - The gadget   */
				       IGRint  row,        /* I - The row      */
				       IGRint  col,        /* I - The column   */
				       IGRint  sel));      /* I - The select   */

extern IGRstat VDfrmGetState       __((Form    form,       /* I - The form     */
				       IGRint  gadget,     /* I - The gadget   */
				       IGRint *state));    /* O - The state    */


extern IGRstat VDfrmSetState       __((Form    form,       /* I - The form     */
				       IGRint  gadget,     /* I - The gadget   */
				       IGRint  state));    /* I - The state    */

extern IGRstat VDfrmInsertBlankRow __((Form    form,       /* I - The form     */
				       IGRint  gadget,     /* I - The gadget   */
				       IGRint  row));      /* I - The row      */

extern IGRstat VDfrmDeleteRows     __((Form    form,       /* I - The form       */
				       IGRint  gadget,     /* I - The gadget     */
				       IGRint  row,        /* I - Starting row   */
				       IGRint  cnt));      /* I - Number of rows */


extern IGRstat VDfrmGetActiveRow   __((Form    form,       /* I - The form     */
				       IGRint  gadget,     /* I - The gadget   */
				       IGRint *row,        /* O - The row      */
				       IGRint *pos));      /* O - The position */


extern IGRstat VDfrmSetActiveRow   __((Form    form,       /* I - The form     */
				       IGRint  gadget,     /* I - The gadget   */
				       IGRint  row,        /* I - The row      */
				       IGRint  pos));      /* I - The position */


extern IGRstat VDfrmCreateForm     __((IGRint   label,     /* I - Form label                 */
				       IGRchar *name,      /* I - Form name                  */
				       IGRint (*notify)(), /* I - Notification routine       */
				       VDobjid  objid,     /* I - Command object attachment  */
				       VDosnum  osnum,     /* I - Command object attachement */
				       Form    *form,      /* O - Created Form               */
				       IGRint   load));    /* I - Load position from file    */

extern IGRstat VDfrmNewForm        __((IGRint   label,     /* I - Form label              */
				       IGRchar *name,      /* I - Form name               */
				       IGRint (*notify)(), /* I - Notification routine    */
				       IGRint   load,      /* I - Load position from file */
				       Form    *form));    /* O - Created Form            */

extern IGRstat VDfrmGetFormByName  __((IGRchar *name,      /* I - Form name */
				       Form    *form));    /* O - The  form */

extern IGRstat VDfrmGetFormName    __((Form     form,      /* I - The form  */
				       IGRchar *name));    /* O - From name */

extern IGRstat VDfrmDeleteForm     __((Form   form,        /* I - Form to delete        */
				       IGRint save));      /* I - Save position to file */

extern IGRstat VDfrmDisplayForm    __((Form    form,       /* I - The form                         */
				       IGRint  show,       /* I - 1 to display, 0 to erase         */
				       IGRint *flag));     /* O - Optional setting of display flag */

extern IGRstat VDfrmFormPosition   __((Form   form,        /* I - The form            */
				       IGRint file,        /* I - Position using file */    
				       IGRint load,        /* I - Load the psoition   */
				       IGRint save));      /* I - Save the position   */

extern IGRstat VDfrmLoadFormPositionFromFile __((Form form));
extern IGRstat VDfrmSaveFormPositionInFile   __((Form form));

extern IGRstat VDfrmResetForm __((Form form));
extern IGRstat VDfrmShowForm  __((Form form));
extern IGRstat VDfrmHideForm  __((Form form));

extern IGRstat VDfrmSetgFmt  __((Form form, IGRint gadget, IGRchar *fmt, ...)); 
 
extern IGRstat VDfrmSetgText __((Form form, IGRint gadget, IGRchar *txt));  
extern IGRstat VDfrmGetgText __((Form form, IGRint gadget, IGRchar *txt));

extern IGRstat VDfrmSetlText __((Form form, IGRint gadget, IGRint row, IGRchar *txt));  
extern IGRstat VDfrmGetlText __((Form form, IGRint gadget, IGRint row, IGRchar *txt));

extern IGRstat VDfrmProcessForms __(());
 
/* -------------------------------------------------------
 * For standalone programs
 * vdahc/VDfrm2.c
 */
extern IGRstat VDfrmOpenDisplay  __((IGRint argc, IGRchar *argv[]));
extern IGRstat VDfrmCloseDisplay __(());

/* -------------------------------------------------------
 * Macros for the people who love macros
 */

#ifndef c_ONLY

#omdef vdfrm$SetText(form,gadget = 10,row = 0,col = 0,
		     sel = 0, txt = NULL,rows = -1,objOE = NULL,objID = NULL)
VDfrmSetText((form),(gadget),(row),(col),(sel),(txt),(rows),(objOE),(objID))
#endomdef

#omdef vdfrm$SetStatus(form,gadget = 10, txt = NULL)
VDfrmSetStatus((form),(gadget),(txt))
#endomdef

#omdef vdfrm$GetText(form,gadget,row  = 0,col  = 0,len  = 128,
		     sel = NULL,pos = NULL,txt = NULL,rows = NULL,objOE = NULL,objID = NULL)
VDfrmGetText((form),(gadget),(row),(col),(len),(sel),(pos),(txt),(rows),(objOE),(objID))
#endomdef

#omdef vdfrm$GetNumRows(form,gadget,rows = NULL,vis = NULL,off = NULL)
VDfrmGetNumRows((form),(gadget),(rows),(vis),(off))
#endomdef

#omdef vdfrm$SetNumRows(form,gadget,rows)
VDfrmSetNumRows((form),(gadget),(rows))
#endomdef

#omdef vdfrm$GetListNumRows(form,gadget,col = 0,rows)
VDfrmGetListNumRows((form),(gadget),(col),(rows))
#endomdef

#omdef vdfrm$SetListNumRows(form,gadget,col = 0,rows)
VDfrmSetListNumRows((form),(gadget),(col),(rows))
#endomdef

#omdef vdfrm$SetListText(form,gadget,row = 0,col = 0,sel = 0,txt = NULL,rows = -1)
VDfrmSetListText((form),(gadget),(row),(col),(sel),(txt),(rows))
#endomdef

#omdef vdfrm$GetListText(form,gadget,row = 0,col = 0,sel = NULL,txt = NULL)
VDfrmGetListText((form),(gadget),(row),(col),(sel),(txt))
#endomdef

#omdef vdfrm$GetMode(form,gadget,col = 0,mode)
VDfrmGetMode((form),(gadget),(col),(mode))
#endomdef

#omdef vdfrm$SetMode(form,gadget,col = 0,mode)
VDfrmSetMode((form),(gadget),(col),(mode))
#endomdef

#omdef vdfrm$GetSelect(form,gadget,row = 0,col = 0,sel)
VDfrmGetSelect((form),(gadget),(row),(col),(sel))
#endomdef

#omdef vdfrm$SetSelect(form,gadget,row = 0,col = 0,sel)
VDfrmSetSelect((form),(gadget),(row),(col),(sel))
#endomdef

#omdef vdfrm$GetState(form,gadget,state)
VDfrmGetState((form),(gadget),(state))
#endomdef

#omdef vdfrm$SetState(form,gadget,state)
VDfrmSetState((form),(gadget),(state))
#endomdef

#omdef vdfrm$InsertBlankRow(form,gadget,row)
VDfrmInsertBlankRow((form),(gadget),(row))
#endomdef

#omdef vdfrm$DeleteRows(form,gadget,row,cnt = 1)
VDfrmDeleteRows((form),(gadget),(row),(cnt))
#endomdef

#omdef vdfrm$GetActiveRow(form,gadget,row,pos = NULL)
VDfrmGetActiveRow((form),(gadget),(row),(pos))
#endomdef

#omdef vdfrm$SetActiveRow(form,gadget,row,pos = 0)
VDfrmSetActiveRow((form),(gadget),(row),(pos))
#endomdef

#omdef vdfrm$CreateForm(label,name,notify,
			objid = NULL_OBJID,osnum = OM_Gw_current_OS,
			form,load = 1)
VDfrmCreateForm((label),(name),(notify),(objid),(osnum),(form),(load))
#endomdef

#omdef vdfrm$GetFormByName(name,form)
VDfrmGetFormByName((name),(form))
#endomdef

#omdef vdfrm$DeleteForm(form,save = 1)
VDfrmDeleteForm((form),(save))
#endomdef

#omdef vdfrm$DisplayForm(form,show = 1,flag = NULL)
VDfrmDisplayForm((form),(show),(flag))
#endomdef

#omdef vdfrm$EraseForm(form,show = 0,flag = NULL)
VDfrmDisplayForm((form),(show),(flag))
#endomdef

#omdef vdfrm$LoadFormPosition(form,file = 1)
VDfrmFormPosition((form),(file),(1),(0))
#endomdef

#omdef vdfrm$SaveFormPosition(form,file = 1)
VDfrmFormPosition((form),(file),(0),(1))
#endomdef

#endif

#if defined(__cplusplus)
}
#endif

#endif
