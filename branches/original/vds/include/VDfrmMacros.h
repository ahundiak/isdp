/* $Id: VDfrmMacros.h,v 1.1 2001/01/10 15:42:24 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDfrm.h
 *
 * Description: From macros
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDfrmMacros.h,v $
 *      Revision 1.1  2001/01/10 15:42:24  art
 *      sp merge
 *
 * Revision 1.2  2000/08/21  21:47:16  pinnacle
 * js
 *
 * Revision 1.1  2000/07/27  15:11:42  pinnacle
 * ah
 *
 * Revision 1.1  2000/07/17  18:51:32  pinnacle
 * ah
 *
 * Revision 1.3  1998/06/24  19:09:44  pinnacle
 * tr179801131
 *
 * Revision 1.2  1998/05/22  20:12:58  pinnacle
 * Replaced: include/VDfrm.h for:  by kddinov for vds
 *
 * Revision 1.1  1998/03/29  13:50:26  pinnacle
 * AssyTree
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/05/98  ah      creation
 * 05/22/98  anand   VDfrm_fld_set_sub_list 
 * 06/24/98  ah      Changed prototype for VDfrm_fld_set_sub_list
 * 05/07/99  ah      Added load from file flag to create/delete
 *                   Added various other functions
 * 01/10/01  ah      sp merge
 ***************************************************************************/

#ifndef VDfrmMacros_include
#define VDfrmMacros_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   FI_H_INCLUDED
#include "FI.h"
#endif

#ifndef VD_PPL
#include "CIforms.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

/* ------------------------------------------
 * Text Processing
 */
extern IGRstat VDfrmSetText
__((Form     form,
    IGRint   gadget,
    IGRint   row,
    IGRint   col,
    IGRint   sel,
    IGRchar *txt,
    IGRint   rows,

    TGRobj_env *objOE,
    TGRid      *objID
));

#omdef vdfrm$SetText
(
  form,
  gadget = 10,
  row    = 0,
  col    = 0,
  sel    = 0,
  txt    = NULL,
  rows   = -1,
  objOE  = NULL,
  objID  = NULL
)

VDfrmSetText((form),(gadget),(row),(col),(sel),(txt),(rows),(objOE),(objID))
#endomdef

/* -----------------------------------------------------
 * Little wrapper to set the status field on a form
 * usually gadget number 10
 */

extern IGRstat VDfrmSetStatus
  __((Form     form,
      IGRint   gadget,
      IGRchar *txt));

#omdef vdfrm$SetStatus
(form,
 gadget = 10,
 txt    = NULL
)

VDfrmSetStatus((form),(gadget),(txt))
#endomdef

/* -------------------------------------------------
 * Generic get text and other information
 */
extern IGRstat VDfrmGetText
__((Form     form,
    IGRint   gadget,
    IGRint   row,
    IGRint   col,
    IGRint   len,

    IGRint  *sel,
    IGRint  *pos,
    IGRchar *txt,
    IGRint  *rows,

    TGRobj_env *objOE,
    TGRid      *objID
));

#omdef vdfrm$GetText
(
  form,
  gadget,
  row  = 0,
  col  = 0,
  len  = 128,

  sel  = NULL,
  pos  = NULL,
  txt  = NULL,

  rows  = NULL,
  objOE = NULL,
  objID = NULL
)
VDfrmGetText((form),(gadget),(row),(col),(len),(sel),(pos),(txt),(rows),(objOE),(objID))
#endomdef

/* ----------------------------------------------------------
 * Explicit get/set number of rows, can do the same thing with
 * the above get/set text macros but this is easier to read
 */
extern IGRstat VDfrmGetNumRows 
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint *rows,     // O - number of rows (0 on failure)
      IGRint *vis,      // O - number of visible rows
      IGRint *off));    // O - offset of top row

#omdef vdfrm$GetNumRows
(
  form,
  gadget,
  rows = NULL,
  vis  = NULL,
  off  = NULL
)
VDfrmGetNumRows((form),(gadget),(rows),(vis),(off))
#endomdef

extern IGRstat VDfrmSetNumRows 
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint  rows));   // I - number of rows

#omdef vdfrm$SetNumRows
(
  form,
  gadget,
  rows
)
VDfrmSetNumRows((form),(gadget),(rows))
#endomdef

extern IGRstat VDfrmGetListNumRows 
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint  col,      // I - The column
      IGRint *rows));   // O - number of rows (0 on failure)

#omdef vdfrm$GetListNumRows
(
  form,
  gadget,
  col = 0,
  rows
)
VDfrmGetListNumRows((form),(gadget),(col),(rows))
#endomdef

extern IGRstat VDfrmSetListNumRows 
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint  col,      // I - The column
      IGRint  rows));   // I - number of rows

#omdef vdfrm$SetListNumRows
(
  form,
  gadget,
  col = 0,
  rows
)
VDfrmSetListNumRows((form),(gadget),(col),(rows))
#endomdef

/* ------------------------------------------
 * Text List Processing
 */
extern IGRstat VDfrmSetListText
__((Form     form,
    IGRint   gadget,
    IGRint   row,
    IGRint   col,
    IGRint   sel,
    IGRchar *txt,
    IGRint   rows
    ));

#omdef vdfrm$SetListText
(
  form,
  gadget,
  row  = 0,
  col  = 0,
  sel  = 0,
  txt  = NULL,
  rows = -1
)
VDfrmSetListText((form),(gadget),(row),(col),(sel),(txt),(rows))
#endomdef

extern IGRstat VDfrmGetListText
__((Form     form,
    IGRint   gadget,
    IGRint   row,
    IGRint   col,
    IGRint  *sel,
    IGRchar *txt
    ));

#omdef vdfrm$GetListText
(
  form,
  gadget,
  row  = 0,
  col  = 0,
  sel  = NULL,
  txt  = NULL
)
VDfrmGetListText((form),(gadget),(row),(col),(sel),(txt))
#endomdef

/* ----------------------------------------------------------
 * Explicit get/set field mode
 */
extern IGRstat VDfrmGetMode 
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint  col,      // I - The column
      IGRint *mode));   // O - The mode

#omdef vdfrm$GetMode
(
  form,
  gadget,
  col = 0,
  mode
)
VDfrmGetMode((form),(gadget),(col),(mode))
#endomdef

	/*************************************************************/
	/*** These are the field modes by increasing functionality ***/
	/*************************************************************/

#define FI_REVIEW		1
#define FI_SINGLE_SELECT	2
#define FI_MULTI_SELECT		3
#define FI_APPEND		4
#define FI_INSERT		0

extern IGRstat VDfrmSetMode
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint  col,      // I - The column
      IGRint  mode));   // I - The mode

#omdef vdfrm$SetMode
(
  form,
  gadget,
  col = 0,
  mode
)
VDfrmSetMode((form),(gadget),(col),(mode))
#endomdef

/* ----------------------------------------------------------
 * Explicit get/set select 
 */
extern IGRstat VDfrmGetSelect 
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint  row,      // I - The row
      IGRint  col,      // I - The column
      IGRint *sel));    // O - The select

#omdef vdfrm$GetSelect
(
  form,
  gadget,
  row = 0,
  col = 0,
  sel
)
VDfrmGetSelect((form),(gadget),(row),(col),(sel))
#endomdef

extern IGRstat VDfrmSetSelect
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint  row,      // I - The row
      IGRint  col,      // I - The column
      IGRint  sel));    // I - The select

#omdef vdfrm$SetSelect
(
  form,
  gadget,
  row = 0,
  col = 0,
  sel
)
VDfrmSetSelect((form),(gadget),(row),(col),(sel))
#endomdef

/* ----------------------------------------------------------
 * Explicit get/set gadget state
 */
extern IGRstat VDfrmGetState
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint *state));  // O - The state

#omdef vdfrm$GetState
(
  form,
  gadget,
  state
)
VDfrmGetState((form),(gadget),(state))
#endomdef

extern IGRstat VDfrmSetState
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint  state));  // I - The state

#omdef vdfrm$SetState
(
  form,
  gadget,
  state
)
VDfrmSetState((form),(gadget),(state))
#endomdef

/* ----------------------------------------------------------
 * Insert a blank row
 */
extern IGRstat VDfrmInsertBlankRow
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint  row));    // I - The row

#omdef vdfrm$InsertBlankRow
(
  form,
  gadget,
  row
)
VDfrmInsertBlankRow((form),(gadget),(row))
#endomdef

/* ----------------------------------------------------------
 * Deletes some rows
 */
extern IGRstat VDfrmDeleteRows
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint  row,      // I - Starting row
      IGRint  cnt));    // I - Number of rows

#omdef vdfrm$DeleteRows
(
  form,
  gadget,
  row,
  cnt = 1
)
VDfrmDeleteRows((form),(gadget),(row),(cnt))
#endomdef

/* ----------------------------------------------------------
 * Explicit get/set the active row
 */
extern IGRstat VDfrmGetActiveRow
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint *row,      // O - The row
      IGRint *pos));    // O - The position

#omdef vdfrm$GetActiveRow
(
  form,
  gadget,
  row,
  pos = NULL
)
VDfrmGetActiveRow((form),(gadget),(row),(pos))
#endomdef

extern IGRstat VDfrmSetActiveRow
  __((Form    form,     // I - The form
      IGRint  gadget,   // I - The gadget
      IGRint  row,      // I - The row
      IGRint  pos));    // I - The position

#omdef vdfrm$SetActiveRow
(
  form,
  gadget,
  row,
  pos = 0
)
VDfrmSetActiveRow((form),(gadget),(row),(pos))
#endomdef

/*-----------------------------------------------------------------------------
* FUNCTION: VDfrm_fld_set_sub_list
* 		Filters out the associative list of a gadget, according to
*		the text types in the gadget itself.
*---------------------------------
*  Anand, May '98
*---------------------------------
* 
* PARAMETERS
*
* I: Form       fp              - pointer to the form
*
* I: IGRint     GadgetLabel     - gadget label with associative list.
*
* I: IGRint     MessageLabel    - message field, if <= 0 UI_message is used.
*
* I: IGRint     CaseFlag        - 1  case sensitive search,
*                                 otherwise case insensitive search.
*
* O: IGRint     *UniqueMatch    - 1 if exact match is found,
*                                 0 otherwise.
*
* O: IGRint     *NewListCount   - New number of entries in the associated list.
-----------------------------------------------------------------------------*/

extern IGRstat VDfrm_fld_set_sub_list
__((Form     fp,
    IGRint   GadgetLabel,
    IGRint   MessageLabel,
    IGRchar *MasterList,
    IGRint   mstrlstsiz,
    IGRint   mstrlstcnt,
    IGRint  *p_NewListCount,
    IGRint   CaseFlag,
    IGRint  *item_index,
    IGRint  *p_UniqueMatch
    ));

/* ---------------------------------------
 * Not going to bother updating this macro for now,
 * not being used anyways
 */
#if 0
#omdef vdfrm$SetSubList (
  fp,
  GadgetLabel,
  MessageLabel  = 10,
  NewListCount  = NULL,
  CaseFlag      = 1,
  UniqueMatch   = NULL )

VDfrm_fld_set_sub_list((fp),(GadgetLabel),(MessageLabel),(NewListCount),(CaseFlag),(UniqueMatch))
#endomdef
#endif

#define VD_FRM_ERROR_OCCURRED		0
#define VD_FRM_SUCCESS			1
#define VD_FRM_NO_ASSOCIATIVE_LIST	2
#define VD_FRM_ASSOCIATIVE_LIST_EMPTY	4

/* ------------------------------------------
 * Create a form
 */

extern IGRstat VDfrmCreateForm 
  __((IGRint   label,    // I - Form label
    IGRchar *name,       // I - Form name
    IGRint (*notify)(),  // I - Notification routine
    VDobjid  objid,      // I - Command object attachment
    VDosnum  osnum,      // I - Command object attachement
    Form    *form,       // O - Created Form
    IGRint   load        // I - Load position from file
));

#omdef vdfrm$CreateForm
(
  label,
  name,
  notify,
  objid = NULL_OBJID,
  osnum = OM_Gw_current_OS,
  form,
  load = 1
)
VDfrmCreateForm((label),(name),(notify),(objid),(osnum),(form),(load))
#endomdef

/* ------------------------------------------
 * Get a form by name
 */
extern IGRstat VDfrmGetFormByName
  __((IGRchar *name,                 // I - Form Name
      Form    *form                  // O - The form
));
#omdef vdfrm$GetFormByName
(
  name,
  form
)
VDfrmGetFormByName((name),(form))
#endomdef

/* ------------------------------------------
 * Delete a form
 */
extern IGRstat VDfrmDeleteForm
  __((Form   form,               // I - Form to delete
      IGRint save                // I - Save position to file
      ));
#omdef vdfrm$DeleteForm
(
 form,
 save = 1
)
VDfrmDeleteForm((form),(save))
#endomdef

/* ------------------------------------------
 * Position a form
 */
extern IGRstat VDfrmDisplayForm
  __((Form    form,                 // I - The form
      IGRint  show,                 // I - 1 to display, 0 to erase
      IGRint *flag                  // O - Optional setting of display flag
      ));

#omdef vdfrm$DisplayForm
(
  form,
  show = 1,
  flag = NULL
)
VDfrmDisplayForm((form),(show),(flag))
#endomdef

#omdef vdfrm$EraseForm
(
  form,
  show = 0,
  flag = NULL
)
VDfrmDisplayForm((form),(show),(flag))
#endomdef


/* ------------------------------------------
 * Position a form
 */
extern IGRstat VDfrmFormPosition
  __((Form   form,                   // I - The form 
      IGRint file,                   // I - Position using file       
      IGRint load,                   // I - Load the psoition
      IGRint save                    // I - Save the position
      ));

extern IGRstat VDfrmLoadFormPositionFromFile __((Form form));
extern IGRstat VDfrmSaveFormPositionInFile   __((Form form));

#omdef vdfrm$LoadFormPosition
(
  form,
  file = 1
)

VDfrmFormPosition((form),(file),(1),(0))
#endomdef

#omdef vdfrm$SaveFormPosition
(
  form,
  file = 1
)

VDfrmFormPosition((form),(file),(0),(1))
#endomdef

// -------------------------
#if defined(__cplusplus)
}
#endif


#endif








