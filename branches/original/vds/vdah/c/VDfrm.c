/* $Id: VDfrm.c,v 1.3 2001/01/11 16:34:30 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDfrm.I
 *
 * Description: FI wrappers
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDfrm.c,v $
 *      Revision 1.3  2001/01/11 16:34:30  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:57  art
 *      s merge
 *
 * Revision 1.1  2000/12/06  14:51:48  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  14:11:24  pinnacle
 * ah
 *
# Revision 1.2  1998/04/29  17:27:00  pinnacle
# test
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/03/10  19:32:40  pinnacle
# ah
#
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/20/98  ah      Creation  
 * 04/29/98  ah      Just a pinnacle test
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDfrmc.h"

/* ----------------------------------------
 * FI_SUCCESS is unfortunately 0
 * Other error codes are positive numbers
 * There is not really one for null pointers
 * There is one for invalid values which we will use
 * Not quite what we want but don't want to make a new
 * one for now
 * FI_ILLEGAL_VALUES = 17
 */

#define VI_SUCC FI_SUCCESS
#define VI_FAIL FI_ILLEGAL_VALUES

/* ----------------------------------------
 * Like a trace mechnism and information
 * mechanism
 */

static struct 
{
  char funcName[64];
  char formName[64];
  int  gadget;
} viINFO;

/* ---------------------------------------------------
 * Standard Routine to intercept/print errors
 */
int VI_error(int errCode, char *errMsg)
{
  char errBuf [128];
  char errBufX[128];

  // Ignore if no errors  
  if (errCode == FI_SUCCESS) goto wrapup;

  // Some errors can actually be treated as warnings and ignored
  switch(errCode) {
  case FI_INVALID_ROW: goto wrapup;
  }
  
  // Init
  *errBuf = 0;
  if (errMsg) strcpy(errBufX,errMsg);
  else       *errBufX = 0;
  
  // Map error code
  
  switch(errCode) {
  case -1:                            strcpy(errBuf,"VALIDATE");                   break;
  case FI_SUCCESS:                    strcpy(errBuf,"SUCCESS");                    break;
  case FI_FORM_FILE_NOT_FOUND:        strcpy(errBuf,"FORM_FILE_NOT_FOUND");        break;
  case FI_FORM_FILE_READ_ERROR:       strcpy(errBuf,"FORM_FILE_READ_ERROR");       break;
  case FI_FORM_NOT_DISPLAYED:         strcpy(errBuf,"FORM_NOT_DISPLAYED");         break;
  case FI_FORM_DISPLAYED:             strcpy(errBuf,"FORM_DISPLAYED");             break;
  case FI_QUIET_MODE_ON:              strcpy(errBuf,"QUIET_MODE_ON");              break;
  case FI_NO_WINDOWS_AVAIL:           strcpy(errBuf,"NO_WINDOWS_AVAIL");           break;
  case FI_NO_SUCH_FORM:               strcpy(errBuf,"NO_SUCH_FORM");               break;
  case FI_LABEL_IN_USE:               strcpy(errBuf,"LABEL_IN_USE");               break;
  case FI_NO_SUCH_GADGET:             strcpy(errBuf,"NO_SUCH_GADGET");             break;
  case FI_NO_MEMORY:                  strcpy(errBuf,"MEMORY");                     break;
  case FI_NO_SUCH_GROUP:              strcpy(errBuf,"NO_SUCH_GROUP");              break;
  case FI_NO_PASS_ON:                 strcpy(errBuf,"NO_PASS_ON");                 break;
  case FI_NO_SUCH_VS:                 strcpy(errBuf,"NO_SUCH_VS");                 break;
  case FI_INVALID_GADGET_TYPE:        strcpy(errBuf,"INVALID_GADGET_TYPE");        break;
  case FI_INVALID_FORMAT:             strcpy(errBuf,"INVALID_FORMAT");             break;
  case FI_INVALID_VERSION:            strcpy(errBuf,"INVALID_VERSION");            break;
  case FI_ILLEGAL_VALUES:             strcpy(errBuf,"ILLEGAL_VALUES");             break;
  case FI_FORM_FILE_OPEN_DENIED:      strcpy(errBuf,"FORM_FILE_OPEN_DENIED");      break;
  case FI_INVALID_BUFFER:             strcpy(errBuf,"INVALID_BUFFER");             break;
  case FI_LOAD_FONT_ERROR:            strcpy(errBuf,"LOAD_FONT_ERROR");            break;
  case FI_NO_SUCH_ENV_FUNCTION:       strcpy(errBuf,"NO_SUCH_ENV_FUNCTION");       break;
  case FI_INVALID_ROW:                strcpy(errBuf,"INVALID_ROW");                break;
  case FI_INVALID_COL:                strcpy(errBuf,"INVALID_COL");                break;
  case FI_NO_CONNECTION:              strcpy(errBuf,"NO_CONNECTION");              break;
  case FI_UNABLE_TO_SAVE_FORM:        strcpy(errBuf,"UNABLE_TO_SAVE_FORM");        break;
  case FI_FORM_FILE_SAVE_ERROR:       strcpy(errBuf,"FORM_FILE_SAVE_ERROR");       break;
  case FI_INVALID_NEWER_FORM_VERSION: strcpy(errBuf,"INVALID_NEWER_FORM_VERSION"); break;
//case FI_INVALID_SYMBOL_FILE:        strcpy(errBuf,"INVALID_SYMBOL_FILE");        break;
//case FI_INVALID_SYMBOL_INDEX:       strcpy(errBuf,"INVALID_SYMBOL_INDEX");       break;
										       
  default:                            strcpy(errBuf,"UNKNOWN");
    
  }  
  fprintf(stderr,"*#* %s,%s,%d,%s - %s\n",
	 viINFO.funcName,
         viINFO.formName,
         viINFO.gadget,
	 errBuf,
         errBufX);
  
wrapup:
  return errCode;
}

/* ---------------------------------------------------
 * Fills in the viINFO data structure
 * also makes sure that any form pointer passed
 * is not null and has a valid name
 */
int VIf_validate(char *funcName, Form form, int gadget) 
{
  int retFlag = VI_FAIL;
  int sts;

  // Init the data structure
  memset(&viINFO,0,sizeof(viINFO));
  if (funcName) strcpy(viINFO.funcName,funcName);
  viINFO.gadget = gadget;
  
  if (form == NULL) {
    VI_error(-1,"NULL Form Pointer");
    goto wrapup;
  }

  // Use their validate routine
  sts = FIf_is_valid(form);
  if (sts != FI_SUCCESS) {
    VI_error(sts,"FIf_is_valid Failed");
    goto wrapup;
  }

  // Check the name just to be sure  
  FIf_get_name(form,viINFO.formName);
  if (viINFO.formName == 0) {
    VI_error(-1,"NO Form Name for NON-NULL Form Pointer");
    goto wrapup;
    
  }
  retFlag = VI_SUCC;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * This is sort of a special case
 * It shows the user is concerned about
 * the form pointer
 * Just pass through with no checks for now
 */
int VIf_is_valid (Form form)
{
  return FIf_is_valid(form);
}

/* ------------------------------------------
 * Delete Form
 */
int VIf_delete(Form form)
{
  int sts;

  sts = VIf_validate("VIf_delete",form,0);
  if (sts != VI_SUCC) goto wrapup;

  sts = FIf_delete(form);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* ------------------------------------------
 * Erase Form
 */
int VIf_erase(Form form)
{
  int sts;

  sts = VIf_validate("VIf_erase",form,0);
  if (sts != VI_SUCC) goto wrapup;

  sts = FIf_erase(form);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* ------------------------------------------
 * Reset Form
 */
int VIf_reset(Form form)
{
  int sts;

  sts = VIf_validate("VIf_reset",form,0);
  if (sts != VI_SUCC) goto wrapup;

  sts = FIf_reset(form);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* ------------------------------------------
 * Display Form
 */
int VIf_display(Form form)
{
  int sts;

  sts = VIf_validate("VIf_display",form,0);
  if (sts != VI_SUCC) goto wrapup;

  sts = FIf_display(form);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* ------------------------------------------
 * Get Gadget Text
 */
int VIg_get_text(Form form, int gadget, char *text)
{
  int sts;

  sts = VIf_validate("VIg_get_text",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  if (text == NULL) {
    VI_error(-1,"Text Pointer is NULL");
    goto wrapup;
  }

  sts = FIg_get_text(form,gadget,text);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* ------------------------------------------
 * Set Gadget Text
 */
int VIg_set_text(Form form, int gadget, char *text)
{
  int sts;

  sts = VIf_validate("VIg_set_text",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  if (text == NULL) {
    VI_error(-1,"Text Pointer is NULL");
    goto wrapup;
  }

  sts = FIg_set_text(form,gadget,text);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* ------------------------------------------
 * Get Gadget State
 */
int VIg_get_state(Form form, int gadget, int *state)
{
  int sts;

  sts = VIf_validate("VIg_get_state",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  if (state == NULL) {
    VI_error(-1,"State Pointer is NULL");
    goto wrapup;
  }

  sts = FIg_get_state(form,gadget,state);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* ------------------------------------------
 * Set Gadget State
 */
int VIg_set_state(Form form, int gadget, int state)
{
  int sts;

  sts = VIf_validate("VIg_set_state",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  sts = FIg_set_state(form,gadget,state);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* ------------------------------------------
 * Erase gadget
 */
int VIg_erase(Form form, int gadget)
{
  int sts;

  sts = VIf_validate("VIg_erase",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  sts = FIg_erase(form,gadget);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* ------------------------------------------
 * Display gadget
 */
int VIg_display(Form form, int gadget)
{
  int sts;

  sts = VIf_validate("VIg_display",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  sts = FIg_display(form,gadget);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* ------------------------------------------
 * Enable gadget
 */
int VIg_enable(Form form, int gadget)
{
  int sts;

  sts = VIf_validate("VIg_enable",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  sts = FIg_enable(form,gadget);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* ------------------------------------------
 * Disable gadget
 */
int VIg_disable(Form form, int gadget)
{
  int sts;

  sts = VIf_validate("VIg_disable",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  sts = FIg_disable(form,gadget);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* ------------------------------------------
 * Get Form by name
 */
int VI_get_form_by_name(char *name, Form *form)
{
  int sts = VI_FAIL;

  memset(&viINFO,0,sizeof(viINFO));
  strcpy(viINFO.funcName,"VI_get_form_by_name");
  
  if (name == NULL) {
    VI_error(-1,"Form Name Pointer is NULL");
    goto wrapup;
  }
  strcpy(viINFO.formName,name);

  if (form == NULL) {
    VI_error(-1,"Pointer to Form Pointer is NULL");
    goto wrapup;
  }

  // Do it
  sts = FI_get_form_by_name(name,form);

  /* I use this function to see if a form has
   * Has already been created, so no form is
   * not really an error here
   */
  if (sts == FI_NO_SUCH_FORM) goto wrapup;
  
  VI_error(sts,NULL);

wrapup:
  return sts;
}

/* -----------------------------------------------
 * New Form, should prototype notification routine
 */
int VIf_new(int label, 
            char *name,
            int (*notification_routine)(), 
            Form *form)
{
  int sts = VI_FAIL;

  memset(&viINFO,0,sizeof(viINFO));
  strcpy( viINFO.funcName,"VIf_new");

  if (name == NULL) {
    VI_error(-1,"Form Name Pointer is NULL");
    goto wrapup;
  }
  strcpy( viINFO.formName,name);
  
  if (form == NULL) {
    VI_error(-1,"Pointer to Form Pointer is NULL");
    goto wrapup;
  }

  if (notification_routine == NULL) {
    VI_error(-1,"notification routine is NULL");
    goto wrapup;
  }
  
  if (label < 0) {
    VI_error(-1,"Form label is negative");
    goto wrapup;
  }

  // Do it
  sts = FIf_new(label,name,notification_routine,form);
  VI_error(sts,NULL);
  if (sts != FI_SUCCESS) goto wrapup;
  
  
  // Validate it
  sts = VIf_validate("VIf_new",*form,0);
  if (sts != VI_SUCC) goto wrapup;

wrapup:
  return sts;
}

/* -------------------------------------------
 * Hook form to command object
 */
int VIf_set_cmd_oid_os(Form form, 
                       unsigned int   cmd_oid,
                       unsigned short cmd_os )
{
  int sts;

  // Validate
  sts = VIf_validate("VIf_set_cmd_oid_os",form,0);
  if (sts != VI_SUCC) goto wrapup;

  // No error checking on command object

  // Do it
  sts = FIf_set_cmd_oid_os(form,cmd_oid,cmd_os);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Collapse the form
 */
int VIf_collapse(Form form)
{
  int sts;

  // Validate
  sts = VIf_validate("VIf_collapse",form,0);
  if (sts != VI_SUCC) goto wrapup;

  // Do it
  sts = FIf_collapse(form);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* -----------------------------------
 * Convert to permanent window
 */
int VIf_cvrt_to_perm_win(Form form)
{
  int sts;

  // Validate
  sts = VIf_validate("VIf_cvrt_to_perm_win",form,0);
  if (sts != VI_SUCC) goto wrapup;

  // Do it
  sts = FIf_cvrt_to_perm_win(form);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Set form location
 */
int VIf_set_location(Form form, int x, int y)
{
  int sts;

  // Validate
  sts = VIf_validate("VIf_set_location",form,0);
  if (sts != VI_SUCC) goto wrapup;

  // Do it
  sts = FIf_set_location(form,x,y);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Get form location
 */
int VIf_get_location(Form form, int *x, int *y)
{
  int sts;

  // Validate
  sts = VIf_validate("VIf_get_location",form,0);
  if (sts != VI_SUCC) goto wrapup;

  // Pointers
  if ((x == NULL) || (y == NULL)) {
    VI_error(-1,"x or y is NULL");
    goto wrapup;
  }
    
  // Do it
  sts = FIf_get_location(form,x,y);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Get form name
 */
int VIf_get_name(Form form, char *name)
{
  int sts;

  // Validate
  sts = VIf_validate("VIf_get_name",form,0);
  if (sts != VI_SUCC) goto wrapup;

  // Pointers
  if (name == NULL) {
    VI_error(-1,"Name is NULL");
    goto wrapup;
  }
    
  // Do it
  sts = FIf_get_name(form,name);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Set Resize Off
 */
int VIf_set_resize_off(Form form)
{
  int sts;

  // Validate
  sts = VIf_validate("VIf_set_resize_off",form,0);
  if (sts != VI_SUCC) goto wrapup;

  // Do it
  sts = FIf_set_resize_off(form);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Set Resize On
 */
int VIf_set_resize_on(Form form)
{
  int sts;

  // Validate
  sts = VIf_validate("VIf_set_resize_on",form,0);
  if (sts != VI_SUCC) goto wrapup;

  // Do it
  sts = FIf_set_resize_on(form);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Get selected flag
 */
int VIfld_get_select(Form form, int gadget, int row, int col, int *sel)
{
  int sts;

  // Validate
  sts = VIf_validate("VIfld_get_select",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  // Pointers
  if (sel == NULL) {
    VI_error(-1,"Select Pointer is NULL");
    goto wrapup;
  }
    
  // Do it
  sts = FIfld_get_select(form,gadget,row,col,sel);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Set selected flag
 */
int VIfld_set_select(Form form, int gadget, int row, int col, int sel)
{
  int sts;

  // Validate
  sts = VIf_validate("VIfld_set_select",form,gadget);
  if (sts != VI_SUCC) goto wrapup;
    
  // Do it
  sts = FIfld_set_select(form,gadget,row,col,sel);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Set text
 */
int VIfld_set_text(Form form, int gadget, int row, int col, char *text, int sel)
{
  int sts;

  // Validate
  sts = VIf_validate("VIfld_set_text",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  // Pointers
  if (text == NULL) {
    VI_error(-1,"Text Pointer is NULL");
    goto wrapup;
  }
    
  // Do it
  sts = FIfld_set_text(form,gadget,row,col,text,sel);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Get text
 */
int VIfld_get_text(Form form, int gadget, int row, int col, int size, char *text, int *sel, int *pos)
{
  int sts;

  // Validate
  sts = VIf_validate("VIfld_get_text",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  // Pointers
  if (text == NULL) {
    VI_error(-1,"Text Pointer is NULL");
    goto wrapup;
  }
  if (sel == NULL) {
    VI_error(-1,"Select Pointer is NULL");
    goto wrapup;
  }
  if (pos == NULL) {
    VI_error(-1,"Position Pointer is NULL");
    goto wrapup;
  }
    
  // Do it
  sts = FIfld_get_text(form,gadget,row,col,size,(unsigned char*)text,sel,pos);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Set number rows
 */
int VIfld_set_num_rows(Form form, int gadget, int rows)
{
  int sts;

  // Validate
  sts = VIf_validate("VIfld_set_num_rows",form,gadget);
  if (sts != VI_SUCC) goto wrapup;
    
  // Do it
  sts = FIfld_set_num_rows(form,gadget,rows);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Get number rows
 */
int VIfld_get_num_rows(Form form, int gadget, int *rows)
{
  int sts;

  // Validate
  sts = VIf_validate("VIfld_get_num_rows",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  // Pointers
  if (rows == NULL) {
    VI_error(-1,"Rows Pointer is NULL");
    goto wrapup;
  }
    
  // Do it
  sts = FIfld_get_num_rows(form,gadget,rows);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Insert blank row
 */
int VIfld_insert_blank_row(Form form, int gadget, int row)
{
  int sts;

  // Validate
  sts = VIf_validate("VIfld_insert_blank_row",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  // Do it
  sts = FIfld_insert_blank_row(form,gadget,row);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Delete rows
 */
int VIfld_delete_rows(Form form, int gadget, int row, int rows)
{
  int sts;

  // Validate
  sts = VIf_validate("VIfld_delete_rows",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  // Do it
  sts = FIfld_delete_rows(form,gadget,row,rows);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* --------------------------------------------
 * Get active row
 */
int VIfld_get_active_row(Form form, int gadget, int *row, int *pos)
{
  int sts;

  // Validate
  sts = VIf_validate("VIfld_get_active_row",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  // Pointers
  if (row == NULL) {
    VI_error(-1,"Row Pointer is NULL");
    goto wrapup;
  }
  if (pos == NULL) {
    VI_error(-1,"Pos Pointer is NULL");
    goto wrapup;
  }

  // Do it
  sts = FIfld_get_active_row(form,gadget,row,pos);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}

/* ---------------------------------------------
 * Set number of list rows
 */
int VIfld_set_list_num_rows(Form form, int gadget, int col, int rows)
{
  int sts;

  // Validate
  sts = VIf_validate("VIfld_set_list_num_rows",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  // Do it
  sts = FIfld_set_list_num_rows(form,gadget,col,rows);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}
/* ---------------------------------------------
 * Set list text
 */
int VIfld_set_list_text(Form form, int gadget, int row, int col, char *text, int sel)
{
  int sts;

  // Validate
  sts = VIf_validate("VIfld_set_list_text",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  // Do it
#if defined(X11)
  sts = FIfld_set_list_text(form,gadget,row,col,(unsigned char*)text,sel);
#else
  sts = FIfld_set_list_text(form,gadget,row,col,text,sel);
#endif
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}
/* ---------------------------------------------
 * Get list text
 */
int VIfld_get_list_text(Form form, int gadget, int row, int col, int len, char *text, int *sel)
{
  int sts;

  // Validate
  sts = VIf_validate("VIfld_set_list_text",form,gadget);
  if (sts != VI_SUCC) goto wrapup;

  // Do it
  sts = FIfld_get_list_text(form,gadget,row,col,len,text,sel);
  VI_error(sts,NULL);
  
wrapup:
  return sts;
}


























