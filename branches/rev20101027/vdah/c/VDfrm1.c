/* $Id: VDfrm1.c,v 1.4 2001/02/22 22:51:30 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDfrm1.I
 *
 * Description: FI macros
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDfrm1.c,v $
 *      Revision 1.4  2001/02/22 22:51:30  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/01/11 16:34:30  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:57  art
 *      s merge
 *
 * Revision 1.2  2000/12/08  20:49:26  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/06  14:51:48  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  14:11:24  pinnacle
 * ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/20/98  ah      Creation 
 * 06/03/00  ah      Misspelled VDfrmGetListNumRows
 * 07/15/00  ah      Add VDfrmGetListtext
 * 11/09/00  pn      fix of display of VDct1Nodes on VDatPocket.frm 
 * 11/29/00  ah      Change to c file
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDfrmc.h"

#include "stdarg.h"
 
/* ---------------------------------------
 * Get text
 */
IGRstat VDfrmGetText
 (Form     form,
  IGRint   gadget,
  IGRint   row,
  IGRint   col,
  IGRint   len,

  IGRint     *sel,
  IGRint     *pos,
  IGRchar    *txt,
  IGRint     *rows,
  TGRobj_env *objOE,
  TGRid      *objID
 )
{
  IGRstat retFlag = 0;
  
  IGRchar txtx[128],*p;
  IGRint  selx;
  IGRint  posx;
  IGRchar name[128];
  TGRid   frmID;

  // Arg check
  if (form == NULL) goto wrapup;

  // Maybe only want rows
  if (rows) {
    *rows = 0;
    VIfld_get_num_rows(form,gadget,rows);
    retFlag = 1;
    goto wrapup;
  }
  VIf_get_name(form,name);

  if (!strcmp(name,"VDatPocket.frm")) {
    if (gadget == 26) {
      if (col > 4) col = col -2;
    }
  }
  //printf("Testing the Gadget [%d] \n",gadget);
  /* 
   * TR fix for prevention of a back screen error message
   * TR 4108  pn 11/02/2000
   */
  if (!((gadget == 15) && (!strcmp(name,"VDatPocket.frm"))))
    VIfld_get_text(form,gadget,row,col,len,txtx,&selx,&posx);
  //printf("End testing the Gadget\n");
  
  
  if (txt) strcpy(txt,txtx);
  if (sel) *sel = selx;
  if (pos) *pos = posx;

  // Maybe want an id
  if ((objOE != NULL) || (objID != NULL)) {
    frmID.osnum = atoi(txtx);
    p = strchr(txtx,'-');

    if (p) {
      frmID.objid = atoi(p+1);
    }
    else   {
      frmID.objid = NULL_OBJID;
    }
    if (objOE != NULL)  objOE->obj_id = frmID;
    if (objID != NULL) *objID         = frmID;

  }

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Get text
 * Note: use of txtx buffer is critical
 */
IGRstat VDfrmGetfText(Form     form,
		      IGRint   gadget,
		      IGRint   row,
		      IGRint   col,
		      IGRchar *txt)
{
  IGRstat retFlag = 0;

  IGRint len = 128;
  IGRint sel,pos;
  IGRchar txtx[128];
  
  // Arg check
  if (form == NULL) goto wrapup;
  if (txt  == NULL) goto wrapup;

  // Do It
  *txt = 0;
  VIfld_get_text(form,gadget,row,col,len,txtx,&sel,&pos);
  strcpy(txt,txtx);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
/* ---------------------------------------
 * Get Pointer
 */
IGRstat VDfrmGetfPnt(Form     form,
		    IGRint   gadget,
		    IGRint   row,
		    IGRint   col,
		    void   **pnt)
{
  IGRstat retFlag = 0;

  IGRint  len = 128;
  IGRint  sel,pos;
  IGRchar txt[128];
  IGRchar *p;
  
  // Arg check
  if (form == NULL) goto wrapup;
  if (pnt  == NULL) goto wrapup;
  *pnt = 0;
  
  // Do It
  *txt = 0;
  VIfld_get_text(form,gadget,row,col,len,txt,&sel,&pos);

  // Convert
  *pnt = (void*)atol(txt);
    
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Get GRid
 */
IGRstat VDfrmGetfID(Form     form,
		    IGRint   gadget,
		    IGRint   row,
		    IGRint   col,
		    TGRid   *id)
{
  IGRstat retFlag = 0;

  IGRint  len = 128;
  IGRint  sel,pos;
  IGRchar txt[128];
  IGRchar *p;
  
  // Arg check
  if (form == NULL) goto wrapup;
  if (id   == NULL) goto wrapup;
  id->objid = NULL_OBJID;
  
  // Do It
  *txt = 0;
  VIfld_get_text(form,gadget,row,col,len,txt,&sel,&pos);

  // Convert
  id->osnum = atoi(txt);
  p = strchr(txt,'-');
  if (p) id->objid = atoi(p+1);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Set text
 */
IGRstat VDfrmSetText
 (Form     form,
  IGRint   gadget,
  IGRint   row,
  IGRint   col,
  IGRint   sel,
  IGRchar *txt,
  IGRint   rows,
  TGRobj_env *objOE,
  TGRid      *objID
  )
{
  IGRstat retFlag = 0;
  IGRchar text[128];
  IGRchar  msgTxt[128], name[128];
  

  // printf(">>> VDfrmSetText %d\n",rows);
  // Arg check
  if (form == NULL) {
    goto wrapup;
  }

  // Might want to set number of rows
  if (rows >= 0) {
    VIfld_set_num_rows(form,gadget,rows);
    retFlag = 1;
    goto wrapup;
  }
  
  // Blank text if none passed
  if (txt == NULL) {
     txt = text;
    *txt = 0;
  }
  
  // Maybe want id
  if (objOE) {
    sprintf(txt,"%d-%d",objOE->obj_id.osnum,objOE->obj_id.objid);
  }
  if (objID) {
    sprintf(txt,"%d-%d",objID->osnum,objID->objid);
  }

  /* 
   * added to fix TR 4108 which had problem showing on gadget 26 on VDatPocket.frm
   * with VDct1 nodes not displaying on the form
   * it was caused by the form not alligning in the number of collumns that are used
   * to display the node data.  This form does not have a place to show data sent in for 
   * col's 2 or 3.  The data is offset otherwise by 2 places as a result
   * pn 11/09/2000
   */
  VIf_get_name(form,name);

  if (!strcmp(name,"VDatPocket.frm")) {
    // if it is coming into the VDatPocket.frm gadget 26
    if (gadget == 26) {
      if((col == 2) || (col == 3))  {
        // handles the omission of these two collums and alligns the text
        retFlag = 1;
        goto wrapup;
      }
      if (col > 3) {
        col = col -2;
      }
    }
  }
  /*
   * End TR 4108 fix of display pn 
   */
  //printf("...> VDfrmSetText\n");
  //printf("form %s gadget %d row %d col %d txt %s sel %d\n",name,gadget,row,col,txt,sel);

  VIfld_set_text(form,gadget,row,col,txt,sel);
  //printf("<... VDfrmSetText\n");
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Set text
 */
IGRstat VDfrmSetfText(Form     form,
		      IGRint   gadget,
		      IGRint   row,
		      IGRint   col,
		      IGRchar *txt)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (form == NULL) goto wrapup;
  if (txt  == NULL) goto wrapup;
  
  // Do It
  VIfld_set_text(form,gadget,row,col,txt,0);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Store a pointer in text format
 */
IGRstat VDfrmSetfPnt(Form     form,
		     IGRint   gadget,
		     IGRint   row,
		     IGRint   col,
		     void    *pnt)
{
  IGRstat retFlag = 0;
  IGRchar txt[32];
  
  // Arg check
  if (form == NULL) goto wrapup;

  // Make to pointer
  if (txt  == NULL) strcpy(txt,"0");
  else              sprintf(txt,"%ld",pnt);
  
  // Do It
  VIfld_set_text(form,gadget,row,col,txt,0);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Store a GRid in text format
 */
IGRstat VDfrmSetfID(Form     form,
		    IGRint   gadget,
		    IGRint   row,
		    IGRint   col,
		    TGRid   *id)
{
  IGRstat retFlag = 0;
  IGRchar txt[32];
  
  // Arg check
  if (form == NULL) goto wrapup;

  // Make to pointer
  if (id == NULL) strcpy(txt,"NO_ID");
  else            sprintf(txt,"%d-%d",id->osnum,id->objid);
  
  // Do It
  VIfld_set_text(form,gadget,row,col,txt,0);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Set number of rows
 */
IGRstat VDfrmSetNumRows(Form     form,
			IGRint   gadget,
			IGRint   rows)
{
  IGRstat retFlag = 0;
  
  
  // printf(">>> VDfrmSetNumRows %d %d\n",gadget,rows);
  // Arg check
  if (form == NULL) goto wrapup;
  
  // Set em
  VIfld_set_num_rows(form,gadget,rows);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Get number of rows
 */
IGRstat VDfrmGetNumRows(Form    form,
			IGRint  gadget,
			IGRint *rows,
			IGRint *vis,
			IGRint *off)
{
  IGRstat retFlag = 0;

  // Arg check
  if (rows != NULL) *rows = 0;
  if (vis  != NULL) *vis  = 0;
  if (off  != NULL) *off  = 0;
  
  if (form == NULL) goto wrapup;
  
  // Get em
  if (rows) VIfld_get_num_rows    (form,gadget,rows);
  if (vis)  FIfld_get_num_vis_rows(form,gadget,vis);
  if (off)  FIfld_get_row_offset  (form,gadget,off);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}
/* ---------------------------------------
 * Make sure that the given row can be seen
 */
IGRstat VDfrmShowRow(Form form, IGRint gadget, IGRint row)
{
  IGRstat retFlag = 1;
  
  IGRint rows,vis,off;

  // Grab some data
  VDfrmGetNumRows(form,gadget,&rows,&vis,&off);
  
  // Arg check
  if ((row < 0) || (row >= rows)) goto wrapup;
  
  // At Top
  if (row < off) {
    VDfrmSetActiveRow(form,gadget,row,0);
    goto wrapup;
  }
  // Already showing
  if (row < (off + vis)) goto wrapup;
  
  // At bottom
  VDfrmSetActiveRow(form,gadget,row,vis-1);

 wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Set number of list rows
 */
IGRstat VDfrmSetListNumRows(Form     form,
			    IGRint   gadget,
                            IGRint   col,
			    IGRint   rows)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (form == NULL) goto wrapup;
  
  // Set em
  VIfld_set_list_num_rows(form,gadget,col,rows);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Set number of list rows
 */
IGRstat VDfrmSetgListNumRows(Form   form,
			     IGRint gadget,
			     IGRint rows)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (form == NULL) goto wrapup;
  
  // Set em
  VIfld_set_list_num_rows(form,gadget,0,rows);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Get number of list rows
 */
IGRstat VDfrmGetListNumRows(Form    form,
			    IGRint  gadget,
			    IGRint  col,
			    IGRint *rows)
{
  IGRstat retFlag = 0;
  // Arg check
  if (rows == NULL) goto wrapup;
  *rows = 0;
  if (form == NULL) goto wrapup;
  
  // Get em
  FIfld_get_list_num_rows(form,gadget,col,rows);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Get number of list rows
 */
IGRstat VDfrmGetgListNumRows(Form    form,
			     IGRint  gadget,
			     IGRint *rows)
{
  IGRstat retFlag = 0;
  // Arg check
  if (rows == NULL) goto wrapup;
  *rows = 0;
  if (form == NULL) goto wrapup;
  
  // Get em
  FIfld_get_list_num_rows(form,gadget,0,rows);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Set mode
 */
IGRstat VDfrmSetMode(Form     form,
		     IGRint   gadget,
		     IGRint   col,
		     IGRint   mode)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (form == NULL) goto wrapup;
  
  // Set em
  FIfld_set_mode(form,gadget,col,mode);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Get mode
 */
IGRstat VDfrmGetMode(Form    form,
		     IGRint  gadget,
		     IGRint  col,
		     IGRint *mode)
{
  IGRstat retFlag = 0;
  IGRchar name[128];
  
  // Arg check
  if (mode == NULL) goto wrapup;
  *mode = 0;
  if (form == NULL) goto wrapup;
  VIf_get_name(form,name);
  // Get em
  FIfld_get_mode(form,gadget,col,mode);
  //printf("VDfrm1.I VDfrmGetMode form %s gadget %d col %d \n",name,gadget,col);
  
  retFlag = 1;

wrapup:
  return retFlag;
}
/* ---------------------------------------
 * Set select
 */
IGRstat VDfrmSetSelect(Form     form,
		       IGRint   gadget,
		       IGRint   row,
		       IGRint   col,
		       IGRint   select)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (form == NULL) goto wrapup;
  
  // Set em
  VIfld_set_select(form,gadget,row,col,select);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Get select
 */
IGRstat VDfrmGetSelect(Form    form,
		       IGRint  gadget,
		       IGRint  row,
		       IGRint  col,
		       IGRint *select)
{
  IGRstat retFlag = 0;
  IGRchar name[128];
  
  
  // Arg check
  if (select == NULL) goto wrapup;
  *select = 0;
  if (form == NULL) goto wrapup;
  VIf_get_name(form,name);
  // Get em
  VIfld_get_select(form,gadget,row,col,select);
  // printf("VDfrm1.I VDfrmGetSelect form %s gadget %d col %d Selection!\n",name,gadget,col);
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Get active row and position
 */
IGRstat VDfrmGetActiveRow(Form    form,
			  IGRint  gadget,
			  IGRint *row,
			  IGRint *pos)
{
  IGRstat retFlag = 0;
  IGRint  posx;
  
  // Arg check
  if (pos != NULL) *pos = 0;
  if (row == NULL) goto wrapup;
  *row = 0;
  if (form == NULL) goto wrapup;
  
  // Get em
  VIfld_get_active_row(form,gadget,row,&posx);
  if (pos) *pos = posx;
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Set active row and position
 * Actually brings the select row into position
 */
IGRstat VDfrmSetActiveRow(Form    form,
			  IGRint  gadget,
			  IGRint  row,
			  IGRint  pos)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (form == NULL) goto wrapup;
  
  // Get em
  FIfld_set_active_row(form,gadget,row,pos);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Updates text status field, gadget is usually 10
 * just a wrapper for now
 */
IGRstat VDfrmSetStatus(Form    form,
		       IGRint  gadget,
		       IGRchar *txt)
{
  return VDfrmSetText(form,gadget,0,0,0,txt,-1,NULL,NULL);
}

  
/* ---------------------------------------
 * Insert blank row at specified position
 */
IGRstat VDfrmInsertBlankRow(Form    form,
			    IGRint  gadget,
			    IGRint  row)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (form == NULL) goto wrapup;
  
  // Get em
  VIfld_insert_blank_row(form,gadget,row);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Delete some rows
 */
IGRstat VDfrmDeleteRows(Form    form,
			IGRint  gadget,
			IGRint  row,
			IGRint  cnt)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (form == NULL) goto wrapup;
  
  // Get em
  VIfld_delete_rows(form,gadget,row,cnt);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Set state
 */
IGRstat VDfrmSetState(Form     form,
		      IGRint   gadget,
		      IGRint   state)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (form == NULL) goto wrapup;
  
  // Set em
  VIg_set_state(form,gadget,state);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Get State
 */
IGRstat VDfrmGetState(Form    form,
		      IGRint  gadget,
		      IGRint *state)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (state == NULL) goto wrapup;
  *state = 0;
  if (form == NULL) goto wrapup;
  
  // Get em
  VIg_get_state(form,gadget,state);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Text List Processing
 */
IGRstat VDfrmSetListText(Form     form,
			 IGRint   gadget,
			 IGRint   row,
			 IGRint   col,
			 IGRint   sel,
			 IGRchar *txt,
			 IGRint   rows)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (form == NULL) goto wrapup;
  
  if (rows >= 0) {
    VIfld_set_list_num_rows(form,gadget,col,rows);
    retFlag = 1;
    goto wrapup;
  }
  
  if (txt != NULL) {
    VIfld_set_list_text(form,gadget,row,col,txt,sel);
    retFlag = 1;
    goto wrapup;
  }
  
wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Text List Processing
 */
IGRstat VDfrmSetgListText(Form     form,
			  IGRint   gadget,
			  IGRint   row,
			  IGRchar *txt)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (form == NULL) goto wrapup;
  if (txt  == NULL) goto wrapup;

  // Doit
  VIfld_set_list_text(form,gadget,row,0,txt,0);
  
wrapup:
  return retFlag;
}

/* ---------------------------------------
 * 15 Jul 2000 - Never implemented GetListText
 * Text List Processing
 */
IGRstat VDfrmGetListText(Form     form,
			 IGRint   gadget,
			 IGRint   row,
			 IGRint   col,
			 IGRint  *sel,
			 IGRchar *txt)
{
  IGRstat retFlag = 0;
  IGRint  selFlag;
  IGRchar txtx[128];
  
  // Arg check
  if (form == NULL) goto wrapup;
  if (txt  == NULL) goto wrapup;
  *txt = 0;
  
  // Doit
  FIfld_get_list_text(form,gadget,row,col,64,(IGRuchar *)txtx,&selFlag);
  strcpy(txt,txtx);
  
  if (sel) *sel = selFlag;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get text from list
 */
IGRstat VDfrmGetgListText(Form     form,
			  IGRint   gadget,
			  IGRint   row,
			  IGRchar *txt)
{
  IGRstat retFlag = 0;
  IGRint  selFlag;
  IGRchar txtx[128];
  
  // Arg check
  if (form == NULL) goto wrapup;
  if (txt  == NULL) goto wrapup;
  *txt = 0;
  
  // Doit
  FIfld_get_list_text(form,gadget,row,0,128,(IGRuchar *)txtx,&selFlag);
  strcpy(txt,txtx);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------
 * Create a form
 */
IGRstat VDfrmCreateForm 
  (IGRint   label, 
   IGRchar *name,
   IGRint (*notify)(), 
   VDobjid  objid,
   VDosnum  osnum,
   Form    *form,
   IGRint   load
  )
{
  IGRstat retFlag = 0;

  // Arg check
  if (form == NULL) goto wrapup;
  *form = NULL;

  // Create it
  VIf_new(label,name,notify,form);
  if (*form == NULL) goto wrapup;

  // Attach command object
  if (objid != NULL_OBJID) {
    VIf_set_cmd_oid_os(*form,objid,osnum);
  }

  // Position it
  VDfrmFormPosition(*form,load,1,0);
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------
 * Delete a form
 */
IGRstat VDfrmDeleteForm(Form form, IGRint save)
{
  IGRstat retFlag = 0;

  // Arg Check
  if (form == NULL) goto wrapup;

  // Save position
  VDfrmFormPosition(form,save,0,1);

  // Delete it
  VIf_delete(form);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------
 * Get form by name
 */
IGRstat VDfrmGetFormByName(IGRchar *name, Form *form)
{
  IGRstat retFlag = 0;

  if (form == NULL) goto wrapup;
  *form = NULL;

  if (name == NULL) goto wrapup;

  VI_get_form_by_name(name,form);
  if (*form == NULL) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------
 * Display a form
 */
IGRstat VDfrmDisplayForm(Form   form,
                         IGRint show,
                         IGRint *flag
                        )
{
  IGRstat retFlag = 0;

  // Arg Check
  if (form == NULL) goto wrapup;

  if (show) {
    VIf_display(form);
    if (flag) *flag = 1;
  }
  else {
    VIf_erase(form);
    if (flag) *flag = 0;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------
 * Position a form
 */
IGRstat VDfrmFormPosition(Form   form, 
                          IGRint file, 
                          IGRint load, 
                          IGRint save
                         )
{
  IGRstat retFlag = 0;

  // Arg Check
  if (form == NULL) goto wrapup;

  // File
  if (file) {

    if (load) {
      retFlag = VDfrmLoadFormPositionFromFile(form);
      goto wrapup;
    }

    if (save) {
      retFlag = VDfrmSaveFormPositionInFile(form);
      goto wrapup;
    }
  }

wrapup:
  return retFlag;
}

/* ------------------------------------------
 * Gets the form's position from a file
 */
IGRstat VDfrmLoadFormPositionFromFile(Form form)
{
  IGRstat retFlag = 0;
  
  IGRchar name[128],*pnt;
  IGRint  x,y;

  FILE   *file = NULL;
  IGRchar buf[128];

  // Arg check
  if (form == NULL) goto wrapup;

  // Form information
  *name = 0;
  VIf_get_name(form,name);
  if (*name == 0) goto wrapup;

  // Open file
  file = fopen(".VDahFrmMgr","r");
  if (file == NULL) goto wrapup;

  // Find the attribute
  while(fgets(buf,sizeof(buf),file)) {
    pnt = strchr(buf,' ');
    if (pnt) *pnt = 0;
    if ((strcmp(name,buf) == 0) && (pnt)) {
      pnt++;
      x = atoi(pnt);
      y = 0;
      pnt = strchr(pnt,',');
      if (pnt) y = atoi(pnt+1);

      VIf_set_location(form,x,y);
      //printf("Load Position %s %d,%d\n",name,x,y);
      
      x = y = 0;
      VIf_get_location(form,&x,&y);
      //printf("Gott Position %s %d,%d\n",name,x,y);

      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  if (file) fclose(file);
  return retFlag;
}

/* ----------------------------------------
 * Saves the form's position in a file
 */
IGRstat VDfrmSaveFormPositionInFile(Form form)
{
  IGRstat retFlag = 0;

  IGRchar name[128];
  IGRint  x,y,found;
  IGRint  x1,y1;
  
  FILE    *fileIn  = NULL;
  FILE    *fileOut = NULL;
  IGRchar  buf[128],*pnt,*p;

  // Arg check
  if (form == NULL) goto wrapup;

  // Form information
  *name = 0;
  VIf_get_name(form,name);
  if (*name == 0) goto wrapup;
  
  x = y = 0;
  VIf_get_location(form,&x,&y);
  //printf("Save Position %s %d,%d\n",name,x,y);
  
  // Open files
  fileIn  = fopen(".VDahFrmMgr", "r");
  fileOut = fopen(".VDahFrmMgrX","w");
  if (fileOut == NULL) goto wrapup;
  
  // Cycle through
  found = 0;
  while((fileIn != NULL) && (fgets(buf,sizeof(buf),fileIn))) {

    pnt = strchr(buf,' ');
    if (pnt) {
      *pnt = 0;
      if (strcmp(name,buf) == 0) {

        // Got a match
        found = 1;

	/* ---------------------------------------------------
	 * For some reason, the VIf_get_location has started to
	 * shift by 5 pixels,  very strange, related to 
	 * Solaris 2.6?.  Hack around for now
	 *
	 * First time is still off by 5 but can live with that
	 */
	p = pnt + 1;
	x1 = atoi(p);
	p = strchr(p,',');
	if (p) y1 = atoi(p+1);
	else   y1 = 0;
	if ((x == (x1 + 5)) && (y == (y1 + 5))) {
	  x = x1;
	  y = y1;
	}
	
	// Save it
        sprintf(buf,"%s %d,%d\n",name,x,y);
	//printf("Save Position %s %d,%d\n",name,x,y);
      }
      else *pnt = ' ';
    }
    fputs(buf,fileOut);
  }

  // Append if not found
  if (found == 0) {
    fprintf(fileOut,"%s %d,%d\n",name,x,y);
  }

  // Close up
  if (fileIn) fclose(fileIn);
  fclose(fileOut);
  
  // Rename
  remove(".VDahFrmMgr");
  rename(".VDahFrmMgrX",".VDahFrmMgr");

  retFlag = 1;
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * 30 Nov 2000
 * Make some simplified interfaces
 */

IGRstat VDfrmResetForm(Form form)
{
  if (form == NULL) return 0;
  VIf_reset(form);
  return 1;
}
IGRstat VDfrmShowForm(Form form)
{
  if (form == NULL) return 0;
  VIf_display(form);
  return 1;
}
IGRstat VDfrmHideForm(Form form)
{
  if (form == NULL) return 0;
  VIf_erase(form);
  return 1;
}

IGRstat VDfrmSetgFmt(Form form, IGRint gadget, IGRchar *fmt, ...)
{
  va_list ap;
  IGRchar buf[256];

  // Arg check
  if ((form == NULL) || (fmt == NULL)) return 0;

  // Buf the message
  va_start(ap,  fmt);
  vsprintf(buf, fmt, ap);  
  va_end(ap);

  return VIg_set_text(form,gadget,buf);
}

IGRstat VDfrmSetgText(Form form, IGRint gadget, IGRchar *txt)
{
  if ((form == NULL) || (txt == NULL)) return 0;
  return VIg_set_text(form,gadget,txt);
}
IGRstat VDfrmGetgText(Form form, IGRint gadget, IGRchar *txt)
{
  if ((form == NULL) || (txt == NULL)) return 0;
  return VIg_get_text(form,gadget,txt);
}

IGRstat VDfrmSetlText(Form form, IGRint gadget, IGRint row, IGRchar *txt)
{
  if ((form == NULL) || (txt == NULL)) return 0;
  return VIfld_set_list_text(form,gadget,row,0,txt,0);
}
IGRstat VDfrmGetlText(Form form, IGRint gadget, IGRint row, IGRchar *txt)
{
  IGRint sel;
  
  if ((form == NULL) || (txt == NULL)) return 0;
  return VIfld_get_list_text(form,gadget,row,0,128,txt,&sel);
}

/* ------------------------------------------
 * Create a form
 */
IGRstat VDfrmNewForm(IGRint   label, 
		     IGRchar *name,
		     IGRint (*notify)(),
		     IGRint   load,
		     Form    *form)
{
  IGRstat retFlag = 0;

  // Arg check
  if (form == NULL) goto wrapup;
  *form = NULL;

  // Create it
  VIf_new(label,name,notify,form);
  if (*form == NULL) goto wrapup;

  // Position it
  VDfrmFormPosition(*form,load,1,0);
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Use this to start user interaction with the forms
 */
IGRstat VDfrmProcessForms()
{
  // if (display == NULL) return 0;
  
  FI_process_forms();

  return 1;
}
/* -----------------------------------------------
 * Gat a form name
 */
IGRstat VDfrmGetFormName(Form form, IGRchar *name)
{
  if (name == NULL) return 0; *name = 0;
  if (form == NULL) return 0;
  VIf_get_name(form,name);
  return 1;
}
