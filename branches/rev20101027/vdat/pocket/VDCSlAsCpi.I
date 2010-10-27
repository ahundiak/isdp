/* $Id: VDCSlAsCpi.I,v 1.13 2001/10/29 20:18:18 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdat/pocket/VDCSlAsCpi.I
 *
 * Description: This is the implementation file for command, VDSlAsCp.
 *              It has routines for interfacing with the form,
 *		SelAssyCmp.frm, which allows selection of sets and nodes
 *		from the Assembly Tree.
 *
 *		The leaf IDs of sets or nodes are added to a saveset
 *		which is passed back to a pocket menu icon using a
 *		software input queue (through ex$putque).
 *		One of the four view windows( plan,iso,aft,stbd ) must
 *		be UNcollapsed for ex$putque to work.
 *		A saveset is a temporary grouping object for group gener-
 *		ators such as "Elements in Fence" (should never be saved).
 *		Here, it is used to collect assembly components (see Notes). 
 *
 *		The command must be invoked again for more than one set
 *		to be selected.
 *
 *		The form will have nodes (i.e., SA, PSU etc) if the set
 *		has a tree (node entries are highlighted if selected; if
 *		none are selected the leafs of the entire set are 
 *		selected). No nodes appear if the set doesn't have a
 *		tree, a production set, for example (the entire set is
 *		selected).
 *			
 *		The form has a hidden gadget (field) which holds the IDs
 *		for mgr, sets, tree, and set. These are used to manipulate
 *		data. The tree field has a hidden column for node IDs.
 *
 *		All functions set retFlag to 0, all functions will return
 *		a retFlag value of 1 IF there are no jumps to wrapup.
 *
 * Dependencies:        Forms:
 *                      SelAssyCmp.frm, "Select Assembly Components"
 *
 * Notes:
 *
 *    Sample sequence of passing component data into another command:
 *    1. At select command, type Select Assembly Components
 *    2. At select command, type Generate Plate Report From Model
 *    3. Type in an output file name, then at prompt, "identify plate",
 *       select your components on first form and accept (check off).
 *    4. Second form (Generate Plate Report) prompts you to "accept fence
 *       content" - do this by pressing a tentative snappoint on the window
 *       (middle mouse button).
 *    5. Cancel (X off) second form - the plate report will be generated
 *       using the input from Select Assembly Components command.
 *
 * Revision History:
 *      $Log: VDCSlAsCpi.I,v $
 *      Revision 1.13  2001/10/29 20:18:18  ylong
 *      CR5709
 *
 *      Revision 1.12  2001/07/20 18:50:28  ylong
 *      CR4080
 *
 *      Revision 1.11  2001/07/17 18:41:52  ylong
 *      *** empty log message ***
 *
 *      Revision 1.10  2001/06/15 13:30:29  ylong
 *      *** empty log message ***
 *
 *      Revision 1.9  2001/05/25 17:04:56  ylong
 *      CR5067 and CR3986
 *
 *      Revision 1.8  2001/03/01 19:55:04  ylong
 *      *** empty log message ***
 *
 *      Revision 1.7  2001/02/23 23:21:35  ylong
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/02/23 14:28:51  ylong
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/02/09 17:06:10  ylong
 *      Change called functions for reorgnization
 *
 *      Revision 1.2  2001/01/11 21:01:17  art
 *      sp merge
 *
# Revision 1.4  2000/12/08  19:52:36  pinnacle
# pn
#
# Revision 1.3  2000/06/27  16:47:44  pinnacle
# ah
#
# Revision 1.2  2000/04/13  18:55:28  pinnacle
# ah
#
# Revision 1.12  2000/03/09  16:59:10  pinnacle
# ylong
#
# Revision 1.11  2000/02/22  19:32:16  pinnacle
# TR179901066
#
# Revision 1.10  2000/01/24  15:47:44  pinnacle
# ah
#
# Revision 1.9  1999/12/07  16:03:34  pinnacle
# ylong
#
# Revision 1.8  1999/10/29  19:54:54  pinnacle
# (No comment)
#
# Revision 1.7  1999/10/26  19:03:28  pinnacle
# ah
#
# Revision 1.6  1999/01/25  22:42:08  pinnacle
# Replaced: vdat/pocket/VDCSlAsCpi.I for:  by vsrivast for vds
#
# Revision 1.5  1999/01/25  21:19:46  pinnacle
# Replaced: vdat/pocket/VDCSlAsCpi.I for:  by vsrivast for vds
#
# Revision 1.4  1999/01/21  16:13:18  pinnacle
# Replaced: vdat/pocket/VDCSlAsCpi.I for:  by vsrivast for vds
#
# Revision 1.3  1999/01/11  21:50:34  pinnacle
# Replaced: vdat/pocket/VDCSlAsCpi.I for:  by vsrivast for vds
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  EJM     Created this file.
 * 01/97/97  ah	     VDatGetSetMgr prototype changed
 * 02/26/98  ah      Removed VDatMAC.h
 * 04/10/98  ah      TR179800633 Add ability to specify 2d view
 * 01/11/99  vinit   Added Search Capability to the Pocket Menu Form 
 * 09/01/99  ah      Added support for new outfit tree
 * 10/21/99  ah      TR1799001020 Could not locate from multiple ref files
 * 10/27/99  ylong   Added VDatPKTGetNodeOE() to select a staging tree node,
 *			   VDatFormFillLastNode() to get last selected node
 * 12/07/99  ylong   Show last selected node in both states
 * 01/24/00  ah      Lots of small changes to implement last selected node
 * 02/21/00  ylong   TR179901066 after searching node,  the row should be set to
 *                   "active" and "selected", if found.
 * 03/09/00  ylong   TR179901080 Added method VDCcheckCommands
 * 04/03/00  adz     TR179901332 Add check for Vis Edge commands
 * 04/04/00  ah      Broke up into several files
 *                   Implemented control line locating
 * 12/08/00  pn      Implementing TR4108 fixes for VDct1Base Class nodes
 * 02/07/01  ylong   Added VDatPKTNotifyMultiSelect functionality
 ***************************************************************************/

/* -----------------------------------------------
 * The trick with model vs node returns is that
 * for the newer VDct1Base objects, they can be linked
 * to a GRset object and returned like everything else
 *
 * However, for the older struct VDatBase objects, they cannot
 * be linked so we can return 1 and only 1 VDatBase objects in
 * something pretending to be a GRset object
 */

class implementation VDCSlAsCp;

//#define  vdsDEBUG
#include "VDmaster.h"		/* TGRid, struct TVDvlaID (VDvla.h)	      */
#include "VDbro1.h"

#include "griomacros.h"
#include "comiscmac.h"          /* co$build_button                            */
#include "wl.h"			/* WLuint32, WLmouse_win_position	      */
#include "dpstruct.h"		/* for DPvd.h				      */
#include "DPvd.h"		/* DPvd_get_active_window_id, DPvd_actwin     */
#include "COBmacros.h"		/* _put_response			      */
#include "grgsmacros.h"

#include "VDmsg.h"              /* VD_E_CmdStkEpt                             */
#include "VDmem.h"		/* _MALLOC				      */
#include "VDppl1.h"
#include "vdtr_macros.h"

/* Assembly Tree Macros */
#include "VDatMaster.h"
#include "VDatPocket.h"
#include "VDahFrm.h"
#include "VDobj.h"
#include "VDfrm.h"

static int traceFlag;
static int cancel_it;

/* ---------------------------------
 * Row in the tree gadget was picked
 */
IGRstat VDatPKTNotifyTree(Form form)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint gadget = VDAT_FORM_PKT_G_TREE;
  IGRint row, sel = 0;

  TGRid  nodeID;

  // Get selected row
  vdfrm$GetActiveRow(form   = form,
		     gadget = gadget,
		     row    = &row);
  if (row < 0) goto wrapup;

  // Get the node id
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = 3,
		objID  = &nodeID);  
  if (nodeID.objid == NULL_OBJID) goto wrapup;

  vdfrm$GetSelect (	form	= form,
			gadget	= gadget,
			row	= row,
			col	= 2,
			sel	= &sel);
  if( sel ) {
	IGRchar		nodePath[128], msgStr[128];

	msgStr[0] = nodePath[0] = '\0';
	vd$trget_nodeInfo (	nodeID	= &nodeID,
				path	= nodePath);
	sprintf(msgStr, "[%d,%d] %s", nodeID.osnum, nodeID.objid, nodePath);
	if( strlen(msgStr) > 40 ) strcpy(&msgStr[40], "*");
	vdfrm$SetText (	form	= form,
			gadget	= VDAT_FORM_PKT_G_MESSAGE,
			txt	= msgStr);
  }
  else {
	vdfrm$SetText (	form	= form,
			gadget	= VDAT_FORM_PKT_G_MESSAGE,
			txt	= "");
  }

  // Is it VDatBase
  sts = vdobj$IsAncestryValid(objID = &nodeID,
			      superClassID = OPP_VDatBase_class_id);
  if (sts & 1) {    
    VDatPKTFormNotifyTree(form,gadget,NULL);
  }
  // Is it VDct1Base
  sts = vdobj$IsAncestryValid(objID = &nodeID,
			      superClassID = OPP_VDct1Base_class_id);
  if (sts & 1) {    
    VDct1PKTFormNotifyTree(form,gadget,&nodeID);
  }
  
wrapup:
  return retFlag;
}

/* ---------------------------------
 * Row in the set list was picked
 */
IGRstat VDatPKTNotifySets(Form form)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint gadget = VDAT_FORM_PKT_L_SETS;
  IGRint row, sel = 0;

  TGRid setID;

  // Get selected row
  vdfrm$GetActiveRow(form   = form,
		     gadget = gadget,
		     row    = &row);
  if (row < 0) goto wrapup;

  // Get the set id
  vdfrm$GetText(form   = form,
		gadget = gadget,
		row    = row,
		col    = 3,
		objID  = &setID);  
  if (setID.objid == NULL_OBJID) goto wrapup;

  vdfrm$SetText (	form    = form,
			gadget  = VDAT_FORM_PKT_G_SET_NAME,
			txt	= "");
  // Show object id
  vdfrm$GetSelect (	form	= form,
			gadget	= gadget,
			row	= row,
			col	= 2,
			sel	= &sel);
  if( sel ) {
	IGRchar		nodePath[128], msgStr[128];

	msgStr[0] = nodePath[0] = '\0';
	vd$trget_nodeInfo (	nodeID	= &setID,
				path	= nodePath);
	sprintf(msgStr, "[%d,%d] %s", setID.osnum, setID.objid, nodePath);
	if( strlen(msgStr) > 40 ) strcpy(&msgStr[40], "*");
	vdfrm$SetText (	form	= form,
			gadget	= VDAT_FORM_PKT_G_MESSAGE,
			txt	= msgStr);
	VDatPKTFillSaveSetList ( form, VDAT_FORM_PKT_G_SET_NAME, &setID );
  }
  else {
	vdfrm$SetText (	form	= form,
			gadget	= VDAT_FORM_PKT_G_MESSAGE,
			txt	= "");
	FIfld_set_list_num_rows ( form, VDAT_FORM_PKT_G_SET_NAME, 0, 0 );
  }

  // Is it VDatBase
  sts = vdobj$IsAncestryValid(objID = &setID,
			      superClassID = OPP_VDatBase_class_id);
  if (sts & 1) {    
    VDatPKTFormFillTree(form, VDAT_FORM_PKT_G_TREE, &setID);
  }
  // Is it VDct1Base
  sts = vdobj$IsAncestryValid(objID = &setID,
			      superClassID = OPP_VDct1Base_class_id);
  if (sts & 1) {    
    VDct1PKTFormFillTree(form, VDAT_FORM_PKT_G_TREE, &setID);
  }
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Gets called when toggle between tree and pick
 * list is selected
 */
IGRstat VDatPKTNotifyToggleTreeList(Form form)
{
  IGRint state;

  // Get the state
  vdfrm$GetState(form   = form,
		 gadget = VDAT_FORM_PKT_T_TREE_OR_PICK_LIST,
		 state  = &state);

  if (state == 0) {
    VIg_erase  (form,VDAT_FORM_PKT_G_PICK_LIST);
    VIg_erase  (form,VDAT_FORM_PKT_T_MODEL_OR_NODE);
    VIg_display(form,VDAT_FORM_PKT_G_TREE);
    VIg_display(form,VDAT_FORM_PKT_B_MULTI_SELECT);
    VIg_display(form,VDAT_FORM_PKT_B_SELECT_FROM);
    VIg_display(form,VDAT_FORM_PKT_B_SELECT_TO);
    VIg_display(form,VDAT_FORM_PKT_G_SELECT_FROM);
    VIg_display(form,VDAT_FORM_PKT_G_SELECT_TO);
  }
  else {
    VIg_erase  (form,VDAT_FORM_PKT_B_MULTI_SELECT);
    VIg_erase  (form,VDAT_FORM_PKT_B_SELECT_FROM);
    VIg_erase  (form,VDAT_FORM_PKT_B_SELECT_TO);
    VIg_erase  (form,VDAT_FORM_PKT_G_SELECT_FROM);
    VIg_erase  (form,VDAT_FORM_PKT_G_SELECT_TO);
    VIg_erase  (form,VDAT_FORM_PKT_G_TREE);
    VIg_display(form,VDAT_FORM_PKT_G_PICK_LIST);
    VIg_display(form,VDAT_FORM_PKT_T_MODEL_OR_NODE);
  }

  return 1;
}

/* -----------------------------------------------
 * Hilight or unhilight group selection
 * by ylong
 */
IGRstat	VDatPKTNotifyMultiSelect(Form form, IGRint gadget)
{
  IGRstat	retFlag = 0;
  IGRint	i, row, numRows = 0, sel = 0, pos, state;
  IGRint	sel1 = 0,  sel2 = 0;
  static IGRint	row1 = -1, row2 = -1;
  IGRchar	text[128], *ptr = NULL;

  if(!form || gadget < 0) goto wrapup;

  switch( gadget ) {

  case VDAT_FORM_PKT_G_TREE:
    FIg_get_state(form, VDAT_FORM_PKT_B_SELECT_FROM, &state);
    if( state ) {
       FIg_set_text(form,VDAT_FORM_PKT_G_SELECT_FROM,"");
       FIfld_get_active_row(form, gadget, &row, &pos);
       vdfrm$GetText(   form    = form,
                        gadget  = gadget,
                        row     = row,
                        col     = 2,
                        txt     = text,
                        sel     = &sel);
       i = 0;
       row1 = row;
       FIg_set_state(form, VDAT_FORM_PKT_B_SELECT_FROM, 0);
       if( row < 0 ) break;
       for(ptr = text; isspace(ptr[i]); i++);
       FIg_set_text(form,VDAT_FORM_PKT_G_SELECT_FROM,&ptr[i]);
       break;
    }

    FIg_get_state(form, VDAT_FORM_PKT_B_SELECT_TO, &state);
    if( state ) {
       FIg_set_text(form,VDAT_FORM_PKT_G_SELECT_TO,"");
       FIfld_get_active_row(form, gadget, &row, &pos);
       vdfrm$GetText(   form    = form,
                        gadget  = gadget,
                        row     = row,
                        col     = 2,
                        txt     = text,
                        sel     = &sel);
       i = 0;
       row2 = row;
       FIg_set_state(form, VDAT_FORM_PKT_B_SELECT_TO, 0);
       if( row < 0 ) break;
       for(ptr = text; isspace(ptr[i]); i++);
       FIg_set_text(form,VDAT_FORM_PKT_G_SELECT_TO,&ptr[i]);
    }
    break;
  case VDAT_FORM_PKT_B_SELECT_FROM:
    FIg_set_state(form, VDAT_FORM_PKT_B_SELECT_TO, 0);
    FIg_set_text(form,VDAT_FORM_PKT_G_SELECT_FROM,"");
    break;
  case VDAT_FORM_PKT_B_SELECT_TO:
    FIg_set_state(form, VDAT_FORM_PKT_B_SELECT_FROM, 0);
    FIg_set_text(form,VDAT_FORM_PKT_G_SELECT_TO,"");
    break;
  case VDAT_FORM_PKT_B_MULTI_SELECT:
    if( row1 > -1 && row2 > -1 ) {
       vdfrm$GetText(   form    = form,
                        gadget  = VDAT_FORM_PKT_G_TREE,
                        row     = row1,
                        col     = 2,
                        sel     = &sel1);
       vdfrm$GetText(   form    = form,
                        gadget  = VDAT_FORM_PKT_G_TREE,
                        row     = row2,
                        col     = 2,
                        sel     = &sel2);
       if( sel1 && sel2 ) {
          sel = 1;
       }
       else if( !sel1 && !sel2 ) {
          sel = 0;
       }
       else {
          FIg_set_text(form,VDAT_FORM_PKT_G_SELECT_FROM,"");
          FIg_set_text(form,VDAT_FORM_PKT_G_SELECT_TO,"");
          break;
       }

       if(row1 > row2) {
          row = row1;
          row1 = row2;
          row2 = row;
       }
       for( row = row1; row <= row2; row++ ) {
           VIfld_set_select(form,VDAT_FORM_PKT_G_TREE,row,2,sel);
       }
       row1 = -1;
       row2 = -1;
       FIg_set_state(form, VDAT_FORM_PKT_B_MULTI_SELECT, 0);
       FIg_set_text(form,VDAT_FORM_PKT_G_SELECT_FROM,"");
       FIg_set_text(form,VDAT_FORM_PKT_G_SELECT_TO,"");
    }

    break;
  default:
    FIg_set_state(form, VDAT_FORM_PKT_B_SELECT_FROM, 0);
    FIg_set_state(form, VDAT_FORM_PKT_B_SELECT_TO, 0);
    FIg_set_text(form,VDAT_FORM_PKT_G_SELECT_FROM,"");
    FIg_set_text(form,VDAT_FORM_PKT_G_SELECT_TO,"");
  };

  retFlag = 1;
wrapup:
  return retFlag;
}

IGRstat	VDatPKTNotifyClearSel( Form form )
{
  IGRstat	retFlag = 0;
  IGRint	row, numRows = 0;

  FIfld_get_num_rows(form, VDAT_FORM_PKT_G_TREE, &numRows);
  for ( row = 0; row < numRows; row++ ) {
	FImcf_set_select(form, VDAT_FORM_PKT_G_TREE, row, FALSE);
  }

  retFlag = 1;
wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Methods follow
 */

/* ----------------------------------------------------------------
 * The notification routine, activated by a mouse point on the form
 * I: form_label,   as define in FIf_new
 * I: gadget_label, #define for gadget
 * I: value,        field value
 * I: *form_ptr,    ptr to form, SelAssyCmp.frm
 */
method form_notification ( int      form_label;
                           int      gadget_label;
                           double   value;
                           char     *form_ptr )
{
  IGRstat retFlag = 1;
  IGRstat sts;
  int status = OM_S_SUCCESS; /* for _put_response, hidden */
   
  switch(gadget_label) {

  case VDAT_FORM_PKT_L_SETS:
    VDatPKTNotifySets(form_ptr);
    break;
    
  case VDAT_FORM_PKT_G_TREE:
    VDatPKTNotifyTree(form_ptr);
    break;

  case VDAT_FORM_PKT_G_SEARCH:
    VDatPKTNotifySearch(form_ptr);
    break;
      
  case VDAT_FORM_PKT_B_PICK:
    VDatPKTNotifyPick(form_ptr);
    break;

  case VDAT_FORM_PKT_T_TREE_OR_PICK_LIST:
    VDatPKTNotifyToggleTreeList(form_ptr);
    break;
    
  case VDAT_FORM_PKT_B_CLEAR_SEL:
    VDatPKTNotifyClearSel(form_ptr);
    break;

  case VDAT_FORM_PKT_B_SET_LOAD:
    VDatPKTNotifyLoadSet(form_ptr);
    break;

  case VDAT_FORM_PKT_B_SET_ADD:
    VDatPKTNotifyAddSet(form_ptr);
    break;

  case VDAT_FORM_PKT_B_SET_SAVE:
    VDatPKTNotifySaveSet(form_ptr);
    break;

  case VDAT_FORM_PKT_B_SET_DELET:
    VDatPKTNotifyDeleteSet(form_ptr);
    break;

  case FI_CANCEL:
    // 21 Jun 2000 State table not handling this
    cancel_it = 1;
    _put_response( resp = TERMINATE );   
    break;

  case FI_ACCEPT:

    // The control doesn't come to this anytime.. (See the state table)
    // sts = VDatPKTNotifyAccept(form_ptr);
    FIf_erase(form_ptr);    
    sts = 1;
    if (sts & 1) {
      _put_response( resp = EX_FORM_FINISHED );
    }
    break;
    
  } /* switch */

  VDatPKTNotifyMultiSelect(form_ptr, gadget_label);


quit:
  return retFlag;
}
		
/* -------------------------------------------------
 * Creation, display and initialization of form
 * Initialize instance of this (my_id) command class
 * I: type,    which command (me->mytype)
 * I: str_ptr, product path, eg., /usr/ip32/vds
 */
method init ( int type ; char * str_ptr )
{
  IGRlong retFlag = OM_E_ABORT;
  IGRlong sts;
  Form    form;
  
  // Say hi
  traceFlag = 0;
  if (traceFlag) {
    printf(">>> TreePocket.init\n");
  }
  cancel_it = 0;
  
  /* Init Parent */
  sts  = om$send(msg = message CEO_LOCATE.init( type, str_ptr ),
		 targetid = my_id,
		 mode = OM_e_wrt_message);
  as$status (sts = sts);

  // Make sure about the form pointer
  me->form_ptr = me->forms[0].form_ptr ;
  if (me->form_ptr == NULL) goto wrapup;
  form = me->form_ptr;

  // Default for model/node type is off
  // removed by ylong, VIg_erase(form,VDAT_FORM_PKT_T_TYPE);

  /* ---------------------------------------------
   * Show the tree gadget
   * blank the options gadget
   */
  VIg_erase  (form,VDAT_FORM_PKT_G_PICK_LIST);
  VIg_erase  (form,VDAT_FORM_PKT_T_MODEL_OR_NODE);
  VIg_display(form,VDAT_FORM_PKT_G_TREE);
  vdfrm$SetState(form   = form,
		 gadget = VDAT_FORM_PKT_T_TREE_OR_PICK_LIST,
		 state  = 0);
  
  // Fills in the list of sets
  VDatCMDMgrFillSets(form, VDAT_FORM_PKT_L_SETS);
  VDct1PKTFormFillSets (form, VDAT_FORM_PKT_L_SETS,0);
  
  // Fills in last selected node and make it active
  VDatPKTLoadState(form); // added by ylong

  // Set form location and display
  vdfrm$LoadFormPosition(form = form);
  vdfrm$DisplayForm(form = form);
  
  retFlag = 1;

wrapup:

  if (traceFlag) printf("<<< TreePocket.init\n");

  return retFlag;
} /* method init */

/* -----------------------------
 * Called at command termination after sleep function (if one exists)
 * I: f_defer_flag, not used
 */
method delete ( int f_defer_flag )
{
  IGRlong retFlag = 0, sts = 0;
  Form form = me->form_ptr;
  IGRstat traceFlag = 0;


  // Say hi
  if (traceFlag | 0) {
    printf(">>> TreePocket.delete\n");
  }
    
  // Make sure about form pointer
  if (form) {
    
    // Save the command state
    VDatPKTSaveState(form);
  
    // Delete the form
    UI_status("Deleting Locate Form ...");    
    vdfrm$DeleteForm(form = form);
    UI_status("Deleted Locate Form");
    me->form_ptr = NULL;
  }
  
  /* Delete this (my_id) class object */
  UI_status("Sending CEO_LOCATE.delete ...");    
  sts = om$send(msg = message CEO_LOCATE.delete ( 0 ),
		targetid = my_id,
		mode     = OM_e_wrt_message);
  UI_status("Sent CEO_LOCATE.delete");    

  // Done
  retFlag = 1;
  if (traceFlag | 0) printf("<<< TreePocket.delete\n");

  return retFlag;
}

/* -----------------------------------------------
 * This method is dded by ylong for TR179901080
 */
method VDCpickedView(int *ret; int flag)
{
  TGRobj_env objOE;
  IGRstat    traceFlag = 0;

  *ret = 0;

  if(traceFlag) printf("\n\n>>> VDCpickedView %d\n",flag);
  if (cancel_it)  return OM_S_SUCCESS;
  
  // printf(">>> VDCpickedView %d\n",flag);
  
  if (flag == 0) objOE.obj_id.objid = NULL_OBJID;
  else {
    
    objOE.obj_id  = me->event1.located_object[0].located_obj;
    objOE.mod_env = me->event1.located_object[0].module_info;
    
    //vdbro$PrintObject(objOE = &objOE);
  }

  VDatPKTNotifyAccept(me->form_ptr,&objOE);
  if(traceFlag) printf("<<<<<<<<<<<<  end  VDCpickedView\n\n");
  UI_prompt("");
  UI_status("");

  return OM_S_SUCCESS;
}

/* ---------------------------------------------------------------------
 * Checks a given object space and returns a count
 * of how many objects of a given class are found
 */
IGRstat VDclaCountObjectsForClasses(VDosnum    osnum,
				    IGRint     classCnt,
				    VDclassid *classes,
				    IGRint    *theCnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   objID;
  IGRint  max;
  IGRint  i;
  
  // Arg check
  if (theCnt == NULL) goto wrapup;
  *theCnt = 0;
  if (classes == NULL) goto wrapup;

  // Cycle through
  objID.osnum = osnum;
  max = OM_GA_OSDs[osnum]->CurSpaceMapSize;
  for(objID.objid = 0; objID.objid < max; objID.objid++) {

    for(i = 0; i < classCnt; i++) {
      sts = vdobj$IsAncestryValid(objID = &objID, superClassID = classes[i]);
      if (sts & 1) *theCnt = *theCnt + 1;
    }
    
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ---------------------------------------------------------------------
 * Added by ylong for TR179901080 to check what command invokes this one
 */
method VDCcheckCommands(int *ret)
{
  TGRobj_env	objOE;
  GRclassid	Class[10];
  int		cntClass = 0 ;
  int		cmdCount = 0 ;
  
SetProc(VDCcheckCommands); Begin

  *ret = 0;

  om$get_classid( classname = "VDm_drawing", p_classid = &Class[0] );
  om$get_classid( classname = "VDCmdExDr"  , p_classid = &Class[1] );
  om$get_classid( classname = "VEcheform"  , p_classid = &Class[2] );
  cntClass = 3 ;

  VDclaCountObjectsForClasses(OM_Gw_TransOSnum_0,cntClass,Class,&cmdCount);
  
  /*
   * Check if classes are active.
   */
  // VDpms_findall_ancestryobjects( cmdSpace, cntClass, Class, &cmdCount, NULL );

  __DBGpr_int("cmdCount", cmdCount);
  if( cmdCount ){
	/*
	 * Need to request for the drawing view environment ...
	 */
  	*ret = 1;
	__DBGpr_com("request for drawing view");
  }

End
  return ( OM_S_SUCCESS );
}

end implementation VDCSlAsCp;









