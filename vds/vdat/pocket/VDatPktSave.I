/* $Id: VDatPktSave.I,v 1.3 2001/06/15 15:58:13 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pocket/VDatPktSave.I
 *
 * Description: Saves the selected objects in the saveset
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatPktSave.I,v $
 *      Revision 1.3  2001/06/15 15:58:13  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/06/01 19:40:44  paul_noel
 *      Fix TR5215
 *
 *      Revision 1.1  2001/02/09 23:42:17  ylong
 *      Renamed
 *
 *      Revision 1.1  2001/01/11 21:01:17  art
 *      sp merge
 *
# Revision 1.8  2000/12/13  19:18:32  pinnacle
# pn
#
# Revision 1.7  2000/12/13  18:51:02  pinnacle
# pn
#
# Revision 1.6  2000/12/11  17:06:10  pinnacle
# pn
#
# Revision 1.5  2000/12/11  14:25:40  pinnacle
# pn
#
# Revision 1.4  2000/12/08  19:52:36  pinnacle
# pn
#
# Revision 1.3  2000/06/27  16:47:44  pinnacle
# ah
#
# Revision 1.2  2000/05/24  15:56:36  pinnacle
# ah
#
# Revision 1.1  2000/04/10  19:03:32  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/04/00  ah      Creation
 * 05/24/00  ah      Send viewOE when getting marking lines
 * 12/08/00  pn      TR4108 fixes for VDct1Base Class nodes access to tables
 ***************************************************************************/

class implementation VDatBase;
/*
#define  vdsDEBUG
*/
#include "VDmaster.h"		/* TGRid, struct TVDvlaID (VDvla.h)	      */
#include "VDbro1.h"

#include "comiscmac.h"          /* co$build_button                            */
#include "wl.h"			/* WLuint32, WLmouse_win_position	      */
#include "dpstruct.h"		/* for DPvd.h				      */
#include "DPvd.h"		/* DPvd_get_active_window_id, DPvd_actwin     */
#include "COBmacros.h"		/* _put_response			      */
#include "grgsmacros.h"

#include "VDmsg.h"              /* VD_E_CmdStkEpt                             */
#include "VDmem.h"		/* _MALLOC				      */
#include "VDppl1.h"

/* Assembly Tree Macros */
#include "VDatMaster.h"
#include "VDatPocket.h"
#include "VDahFrm.h"
#include "VDobj.h"
#include "VDfrm.h"
#include "VDct1.h"
#define ffn "VDatSave.I"
from GRgrset import GSobject_add;
static int traceFlag;
/* -----------------------------------
 * Fills in vla with all id's for selection
 * Recursive routine in which the objID can be different
 * objects (set,node or tree)
 * this is used by VDatPocket.frm form
 */
IGRstat VDct1GetLeafsVLA(TGRid *objID, TVDvlaID *leafVLA)
{
  IGRstat          retFlag = 0;
  IGRstat          traceFlag = 0;
  TGRid            childID;
  IGRint           i;
  TGRobj_env       objOE;
  TVDctBaseInfo    baseInfo;

   // say hi
  if(traceFlag) {
  // get the baseInfo
  vdct1$GetBaseInfo(objID = objID, baseInfo = &baseInfo); 
    printf("\n\n>>> VDatSave.I: VDct1GetLeafsVLA [%s] [%s] [%d] [%d]\n",
           baseInfo.nodeType,baseInfo.nodeName,objID->osnum,objID->objid);
  }

  // check if it is connected
  vdct1$GetNodeModelObject(nodeID  = objID,
			   modelOE = &objOE);

  // append any connected objects
  if(objOE.obj_id.objid != NULL_OBJID) VDvlaID_Append(leafVLA,objID);
  
  // get my kids
  for(i = 0;vdct1$GetTree1Child(objID = objID,nth = i,outID = &childID);i++) {
    VDct1GetLeafsVLA(&childID,leafVLA);
  }

  retFlag = 1;
wrapup:
  // say bye
  if(traceFlag) printf("<<< VDatLeaf.I: VDct1GetLeafsVLA(%d)\n\n",retFlag);
  return retFlag;
}

/* ------------------------------------------
 * Put tree leaves or set leaves to a saveset 
 * I: *objID, id of node or set to save
 * I: *grset_id, graphic set for saving components (pieces, leaves)
 * I: *objOE, gets enviroment for view dependent items
 */
IGRlong VDatPKTAddToSaveSet(TGRid *addID, TGRid *grsetID, TGRobj_env *viewOE)
{
  /* ---------------------------------------------
   * 03 April 2000 - This was not being initialized
   * Not sure if it matters or not.
   * But went ahead and initialized it anyways
   */
  IGRint  env_prop = 0;
  IGRint  traceFlag;
  IGRlong retFlag = 0;
  IGRlong sts = MSSUCC;
  IGRlong msg = OM_S_SUCCESS;

  IGRint     leafI;
  TGRid      leafID;
  TVDvlaID   leafVLA;
  TGRobj_env leafOE,objOE;

  IGRint isVDatBase;
  IGRint isVDct1Base;
  
  IGRint nodeToggle;
  IGRint pickList[UNFOLD_NB_OPT]; // UNFOLD_NB_OPT = 9 
  
  // Say hi
  traceFlag = 0;
  if (traceFlag) {
    printf(">>> VDatPKTAddToSaveSet\n");
    vdobj$Print(objID = addID);
  }

  // Get list of leafs
  vdvla_id$Construct(vla = &leafVLA);

  // Is it VDatBase
  isVDatBase = vdobj$IsAncestryValid(objID = addID,
				     superClassID = OPP_VDatBase_class_id);
  // Is it VDct1Base
  isVDct1Base = vdobj$IsAncestryValid(objID = addID,
				      superClassID = OPP_VDct1Base_class_id);
  // no ancestry no work
  if((isVDatBase & 0) && (isVDct1Base & 0)) goto wrapup;
  
  // get the leafVLA.... depending on type
  if (isVDatBase & 1) VDatGetLeafsVLA(addID,&leafVLA);
  if (isVDct1Base & 1) VDct1GetLeafsVLA(addID,&leafVLA);
  

  // Get the node toggle
  VDatPKTGetStateSavedNodeToggle(&nodeToggle); 

  // For each leaf
  for(leafI = 0; 
      vdvla_id$GetAt(vla = &leafVLA, objID = &leafID, nth = leafI); 
      leafI++) {
    leafOE.obj_id.objid = NULL_OBJID;

    // Process to get the leafOE of the individual leafID
     if(isVDatBase & 1)  VDatGetLeafObject(&leafID,&leafOE);
     if(isVDct1Base & 1) {
       vdct1$GetNodeModelObject(nodeID  = &leafID,
                                modelOE = &leafOE);
       if(leafOE.obj_id.objid == NULL_OBJID) leafOE.obj_id  = leafID;
      }

     // use the leafID if selected
     if (nodeToggle)  leafOE.obj_id  = leafID;

     if (viewOE->obj_id.objid != NULL_OBJID) {
       // TR1799001020
       // Only transfer the matrix, leave the md_id alone
       leafOE.mod_env.md_env = viewOE->mod_env.md_env;
       //leafOE.mod_env = objOE->mod_env;
     }
     else {
       // Fake one
       gr$get_module_env(buffer =  &leafOE.mod_env);
       leafOE.mod_env.md_id.osnum = leafOE.obj_id.osnum;
       ex$get_modid(mod_osnum =  leafOE.mod_env.md_id.osnum, 
                    mod_id    = &leafOE.mod_env.md_id.objid);
     }      
     
     
     // Add it
     if (leafOE.obj_id.objid != NULL_OBJID) {

      sts = om$send(msg = message GRgrset.
		    GSobject_add(&msg,
				 &leafOE.obj_id,
				 &leafOE.mod_env,
				 &env_prop,NULL,NULL),
		    senderid = NULL_OBJID,
		    targetid = grsetID->objid,
		    targetos = grsetID->osnum);


      if( !( sts & 1)){
	om$report_error(sts = sts);
	printf("\nERROR: msg GRgrset.GSobject_add\n");
	printf("\n  leafID = %d\n", leafID.objid);
	goto wrapup;
      }
      if( !( msg & 1)){
	printf("\n  GSobject_add msg bad\n");
	goto wrapup;
      }
      // Now see if any line options were selected
      if(isVDatBase) {
        
      VDatPKTGetStatePickList(pickList);
      VDatPKTAddLinesToSaveSet(viewOE,&leafOE,pickList,grsetID);
      }
      
      
    } /* For each leaf */
  }
  
  // Done
  retFlag = 1;

wrapup:

  vdvla_id$Delete(vla = &leafVLA);

  if (traceFlag) {
    printf("<<< VDatPKTAddToSaveSet[%d]\n",retFlag);
  }  
  return retFlag;
}

/* -----------------------------------------------------
 * Decide what has been selected
 */
IGRlong VDatPKTFillSaveSet (Form form, TGRid *setID, TGRid *grsetID, TGRobj_env *viewOE)
{
  IGRstat retFlag = 0;
  IGRstat isVDat,isVDct1,sts;
  IGRstat traceFlag = 0;
  TGRid   treeID;
  TGRid   rowID;

  IGRint  row,rows,sel;
  IGRint  gadget = VDAT_FORM_PKT_G_TREE;
  
  // Say Hi
  if (traceFlag) printf("\n\n>>>------>>>>  VDatSave.I: VDatPKTFillSaveSet\n");
    
  /* ---------------------------------------------
   * Think this is old code before FabData sets were
   * being presented as trees
   */

  // VDatBase's can either be sets or trees
  isVDat = vdobj$IsAncestryValid(objID = setID,
                                 superClassID = OPP_VDatBase_class_id);
  isVDct1 = vdobj$IsAncestryValid(objID = setID,
                                  superClassID = OPP_VDct1Base_class_id); 

  // get the treeID's appropriate
  if (isVDat & 1) VDatGetTree(setID,&treeID);
  if (isVDct1 & 1) vdct1$GetTree1Parent(objID = setID, outID = &treeID);
  // if we don't have a treeID

  if(isVDat) {
    if (treeID.objid == NULL_OBJID) {
      retFlag = VDatPKTAddToSaveSet(setID, grsetID, viewOE);
      goto wrapup;
    }
  }
  
  // Find selected rows
  rows = -1;
  FIfld_get_num_rows(form,gadget,&rows);
  for(row = 0; row < rows; row++) {

    sel = -1;
    FIfld_get_select(form,gadget,row,2,&sel);

    if(sel & 1) {
      VDahFrmGetGRid(form,gadget,row,3,&rowID);
      // Add it
      sts = VDatPKTAddToSaveSet(&rowID, grsetID, viewOE);
      if (!(sts & 1)) goto wrapup;
    }
  }
  retFlag = 1;
  
wrapup:
 if (traceFlag) printf("<<< VDatSave.I: VDatPKTFillSaveSet(%d)\n\n",retFlag);
  return retFlag;
}

/* -----------------------------------------
 * Accept button clicked
 * Actually, after the accept button is pressed
 * The state table calls VDCpickedView which in turn calls here
 *
 * viewOE will either have NULL_OBJID or else a object from
 * the drawing that the user is trying to obtain model info from
 * use the viewOE for it's matrix
 */
IGRstat VDatPKTNotifyAccept(Form form, TGRobj_env *viewOE)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  IGRstat sts;

  IGRint setGadget = VDAT_FORM_PKT_L_SETS;
  IGRint row,pos;

  TGRid  setID;

  struct DPvd_actwin  awin;
  TGRobj_env grsetOE;

  TGRobj_env *listOE = NULL;

  IGRint count;
  
  // Say hi
  if (traceFlag) printf("\n\n>>> VDatPKTNotifyAccept\n");

  UI_prompt("");
  UI_status("Processing ...");

  // Update the form information
  VDatPKTSaveState(form);
  
  /* -----------------------------------------------
   * Get selected staging tree node, added by ylong
   * ah - I think if this returns true then the user wanted
   * a node but I am really not sure yet
   */
  sts = VDatPKTSaveTreeNode(form);
  if(sts & 1 ) {
     retFlag = 1;
    goto wrapup ;
  }
  // Get selected row
  row = -1;
  FIfld_get_active_row(form,setGadget,&row,&pos);
  if (row < 0) {
    UI_status("No Active set");
     goto wrapup;
  }
  // Get the set id
  VDahFrmGetGRid(form,setGadget,row,3,&setID);
  if (setID.objid == NULL_OBJID) {
    UI_status("No Active Set");
    goto wrapup;
  }
  
   /* ----------------------------------
   * Simulate FENCE LOCATE 
   * Some of the following code from vds/vdpocket/cmd/VDCmdQYnpti.I
   * Need an active window to get event data 
   */
  sts = DPvd_get_active_window( &awin );
  if( !(sts&1) ) {
    UI_status(" Open a vds graphics window");
    goto wrapup;
  }
  __DBGpr_int("active window id", awin.grid.objid);

  // Create graphics set to hold leaf data
  UI_status("Processing selected set ...");
  sts = VDatPKTCreateGRgrset(&grsetOE);
  if( !(sts & 1) )  goto wrapup;
    
  // Fill Up Save Set
  sts = VDatPKTFillSaveSet(form,&setID,&grsetOE.obj_id,viewOE);
  if (!(sts & 1)) {
    UI_status("No objects selected");
    goto wrapup;
  }
  
  // Put leaf data to software event queue
  sts = VDatPKTQueDataToCmdObj(awin, &grsetOE);
  if( !(sts) )    goto wrapup;
  

  /* find number of objects saved */
  as$start_fence(set       = &grsetOE.obj_id,
		 set_env   = &grsetOE.mod_env,
		 nb_obj    = &count,
		 p_obj_env = &listOE);

  ASend_fence(); // Frees listOE

  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDatPKTNotifyAccept(%d)\n\n\n",retFlag);
  return retFlag;
}

/*--------------------------------------------------------
 * If only a tree node is wanted (for drawing stuff) then
 * just put the node on the queue and the accept is done
 *
 */
IGRstat VDatPKTSaveTreeNode(Form form)
{
  IGRstat sts, retFlag = 0;
  IGRstat traceFlag = 0;
  IGRint  isVDat = 0,isVDct1 = 0;
  
  struct DPvd_actwin  awin;
  IGRint treeGadget = VDAT_FORM_PKT_G_TREE; //  26
  IGRint setGadget  = VDAT_FORM_PKT_L_SETS ; // 12
  IGRint row = -1, pos;
  IGRint select,rows,i;
  TGRid  nodeID;
  IGRint nodeToggle;
  
  TGRobj_env nodeOE;
  if (traceFlag) printf(">>>  VDatPKTSaveTreeNode\n");
  // Get selected row (This is where the last row selected comes into play)
  vdfrm$GetActiveRow(form   = form,
                     gadget = treeGadget,
                     row    = &row);
  if (row < 0)  goto wrapup;
  
  // get the form objects and check their ancestry
  // Get the node id
  vdfrm$GetText(form   = form,
                gadget = treeGadget,
                row    = row,
                col    = 3,
                objID  = &nodeOE.obj_id);
  if (nodeOE.obj_id.objid == NULL_OBJID)  goto wrapup;

  // Make sure the node is selected
  if( FIfld_get_select( form, treeGadget, row, 2, &select) != FI_SUCCESS )  goto wrapup ;
  if( !select )  goto wrapup ;

  // Is it VDct1Base
  isVDct1 = vdobj$IsAncestryValid(objOE = &nodeOE,
                              superClassID = OPP_VDct1Base_class_id);
     // Is it VDatBase
  isVDat = vdobj$IsAncestryValid(objOE = &nodeOE,
                              superClassID = OPP_VDatBase_class_id);
  // is the class right?
  if(( !(isVDat & 1) ) && (!(isVDct1 & 1)))  goto wrapup ;
  
  // Check node vs model toggle..
  VDatPKTGetStateSavedNodeToggle(&nodeToggle);
  if (nodeToggle == 0)  goto wrapup;

  gr$get_module_env(buffer = &nodeOE.mod_env);

  sts = DPvd_get_active_window( &awin );
  if( !(sts&1) ) {
    UI_status(" Open a vds graphics window");
     goto wrapup;
  }

  vdobj$Print(objOE = &nodeOE);

  // This process only accepts one node and only the last one selected
  // Art said it only accepts one node... I have verified this as true.
  sts = VDatPKTQueDataToCmdObj(awin, &nodeOE);
  if( !(sts & 1) ) goto wrapup;

    retFlag = 1;

wrapup:
  if (traceFlag) printf("<<<  VDatPKTSaveTreeNode(%d)\n",retFlag);
  return retFlag;
}

/* -----------------------------------
 *  Queue event data to command object
 *  I: awin, window id
 *  I: grset_id, graphic set id
 *  I: mod_info, object space id plus transformation matrix
 */
IGRlong VDatPKTQueDataToCmdObj( struct DPvd_actwin awin, TGRobj_env *grsetOE)
{
  IGRlong	  retFlag = 0;
  IGRstat         traceFlag = 0;
  IGRlong	  sts = MSSUCC, msg = OM_S_SUCCESS;
  IGRlong	  size = 0;
  IGRint	  response;
  struct GRevent  event;

  /*
   *  Format response data.
   */
  if (traceFlag) printf(">>>  VDatPKTQueDataToCmdObj\n");
  co$build_button(msg    = &msg,
                  objid  = awin.grid.objid,
                  osnum  = awin.grid.osnum,
                  button = &event.event.button);
  if( !(msg&1) ){
    if(traceFlag) printf("\n   co$build_button failed\n");
    goto wrapup;
  }
  if(traceFlag) printf("\n   co$build_button worked\n");
  event.num_id = 1;
  event.num_val = 0;
  event.response = EX_DATA;
  event.subtype = GRst_LOCATE;
  event.located_object[0].located_obj = grsetOE->obj_id;
  event.located_object[0].module_info = grsetOE->mod_env;

  size = sizeof( struct GRevent ) - ( 2 * sizeof ( IGRlong ) );

  /*
   * Put EX_OBJID event on front of software queue
   * All input to a Command object comes from the software input queue
   *   through an input filter.
   */

  response = EX_OBJID;     
  sts = ex$putque(msg      = &msg,
                  response = &response,
                  byte     = &size,
                  buffer   = (IGRchar *)&event.event.button );

  if( !(sts&1) ){
    if(traceFlag) printf("Went wrapup ex$putque\n");
    goto wrapup;
  }
  if(traceFlag) printf("ex$putque worked\n");
  // Done
  retFlag = 1;

 wrapup:
  if (traceFlag) printf("<<<  VDatPKTQueDataToCmdObj(%d)\n",retFlag);
  return retFlag;

} /* VDatQueDataToCmdObj */

/* ----------------------------------------------
 *  Create a graphic set which contains a saveset
 *  O: *grset_id, graphic set id 
 *  O: mod_info, object space id plus transformation matrix
 */
IGRlong VDatPKTCreateGRgrset(TGRobj_env *grsetOE)

{
  IGRlong retFlag = 0;
  IGRlong sts = MSSUCC;
  IGRlong msg = OM_S_SUCCESS;
  if (traceFlag) printf(">>> VDatPKTCreateGRgrset\n"); 
  gr$get_module_env(buffer = &grsetOE->mod_env);

  grsetOE->obj_id.osnum = grsetOE->mod_env.md_id.osnum;
  
  /* Construct save set, defines module environment */
  sts = gr$gsinit(msg      = &msg,
		  senderid = NULL_OBJID,
		  flag     = 2,
		  p_objid  = &grsetOE->obj_id.objid,
		  osnum    =  grsetOE->obj_id.osnum);

  if( !(sts & 1) ){
    om$report_error( sts = sts );
    goto wrapup;
  }

  /* Performs any needed clipping */
  sts = gr$gspost_processing(msg = &msg, 
			     senderid  = NULL_OBJID, 
			     object_id = &grsetOE->obj_id);

  if( !( sts & 1 )){
    om$report_error( sts = sts );
    goto wrapup;
  }

  /* Define current select set */
  sts = gr$gsput_select_set(msg           = &msg,
			    mod_env       = &grsetOE->mod_env,
			    select_set_id = &grsetOE->obj_id);

  if( !( sts & 1 )){
    om$report_error(sts = sts);
    goto wrapup;
  }

  // Done
  retFlag = 1;

 wrapup:
  if (traceFlag) printf("<<< VDatPKTCreateGRgrset(%d)\n",retFlag);  
  return retFlag;

} /* VDatPKTCreateGRgrset */

end implementation VDatBase;






