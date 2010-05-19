/* $Id*/

/***************************************************************************
 * I/VDS
 *
 * File:        vdbt/pm/VDbtFunc.I
 *
 * Description: Piece Mark Functions
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDbtFunc.I,v $
 * Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 * Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/04/26  13:12:10  pinnacle
# ah
#
# Revision 1.4  1998/04/24  20:24:12  pinnacle
# ah
#
# Revision 1.3  1998/04/23  23:33:06  pinnacle
# ah
#
# Revision 1.2  1998/04/23  23:13:50  pinnacle
# ah
#
# Revision 1.1  1998/04/22  23:40:16  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/22/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDmaster.h"
#include "VDbt.h"
#include "VDsaProto.h"
#include "VDobj.h"
#include "VDchn.h"

from expression import DIgive_output; 
from expression import DIget_edit_string;
from expression import give_syntax;  // The winner
from expression import give_formula;

from ACcpx      import find_macro;

from ACcpx_defn import ACgive_feet_desc;

/* ------------------------------------------------------
 * Get piece mark for a plate
 * This routine has been replaced with a ppl but keep around
 * for later bench marking
 */
IGRstar VDbtGetPlatePieceMark(TGRobj_env *objOE, IGRchar *pieceMark)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar className[128];
  //IGRchar objName[1024];
  
  TGRid   pretendID;
  TGRid   pmID;
  
  struct {
    TGRid  theID;
    TGRid  defID;
    IGRint numFeet;
    struct myfeet *theFeet;
  } mac,cmp;
  
  IGRint  i;
  
  // Init
  memset(&mac,0,sizeof(mac));
  memset(&cmp,0,sizeof(cmp));
  
  // Arg check
  if (pieceMark == NULL) goto wrapup;
  *pieceMark = 0;
  
  if (objOE == NULL) goto wrapup;
  
  // Verify it is a src plate
  vdobj$Get(objOE = objOE, className = className);
  if (strcmp(className,"VSsrcPlate")) {
    goto wrapup;
  }

  // Get the parent
  vdchn$Get(il_objOE  = objOE,
	    ic_IDX    = VDCHN_IDX_FATHER,
	    ir_objIDX = 0,
	    or_objID  = &pretendID);

  if (pretendID.objid == NULL_OBJID) goto wrapup;

  // Want ACpretend or ACpretendin
  vdobj$Get(objID = &pretendID, className = className);
  mac.theID.objid = NULL_OBJID;
  
  // ACpretend connects via father channel
  if (!strcmp(className,"ACpretend")) {

    // Get the parent
    vdchn$Get(il_objID  = &pretendID,
	      ic_IDX    = VDCHN_IDX_FATHER,
	      ir_objIDX = 0,
	      or_objID  = &mac.theID);

    if (mac.theID.objid == NULL_OBJID) goto wrapup;
    goto got_the_macro;
    
  }

  // ACpretendin connects via listener channel
  if (!strcmp(className,"ACpretendin")) {

    TVDvlaID lstVLA;
    TGRid macID;
    
    VDvlaID_Construct(&lstVLA);

    // Unordered channels suck!
    vdchn$Get(il_objID = &pretendID,
	      ic_IDX   = VDCHN_IDX_LISTENER,
	      or_vlaID = &lstVLA);
    
    for(i = 0; VDvlaID_GetAt(&lstVLA,&macID,i); i++) {

      if (vdobj$IsAncestryValid(objID = &macID, superClassName = "ACncpx")) {
	mac.theID = macID;
	VDvlaID_Delete(&lstVLA);
	goto got_the_macro;
      } 
    }

    VDvlaID_Delete(&lstVLA);
    goto wrapup;
    
  }
  goto wrapup;
  
  // Got the macro
got_the_macro:

  // Only way to get feet names is from the macro def?
  sts = om$send(msg = message ACcpx.find_macro(&mac.defID),
		senderid = NULL_OBJID,
		targetid = mac.theID.objid,
		targetos = mac.theID.osnum);
  if (mac.defID.objid == NULL_OBJID) goto wrapup;

  // Need a component named ID, macro def is the only way I know to get
  sts = om$send(msg = message ACcpx_defn.ACgive_feet_desc(&mac.numFeet,&mac.theFeet),
		senderid = NULL_OBJID,
		targetid = mac.defID.objid,
		targetos = mac.defID.osnum);

  // Search for it
  for(i = 0; (i < mac.numFeet) && (strcmp("ID",mac.theFeet[i].name)); i++);
  if (i >= mac.numFeet) goto wrapup;
  
  vdchn$Get(il_objID  = &mac.theID,
	    ic_IDX    = VDCHN_IDX_TO_COMPONENTS,
	    ir_objIDX = i,
	    or_objID  = &cmp.theID);
  if (cmp.theID.objid == NULL_OBJID) goto wrapup;

  // Now need to get a foot from the ID object
  sts = om$send(msg = message ACcpx.find_macro(&cmp.defID),
		senderid = NULL_OBJID,
		targetid = cmp.theID.objid,
		targetos = cmp.theID.osnum);
  if (cmp.defID.objid == NULL_OBJID) goto wrapup;

  // Need a component named Cut #
  sts = om$send(msg = message ACcpx_defn.ACgive_feet_desc(&cmp.numFeet,&cmp.theFeet),
		senderid = NULL_OBJID,
		targetid = cmp.defID.objid,
		targetos = cmp.defID.osnum);

  for(i = 0; (i < cmp.numFeet) && (strcmp("Cut #",cmp.theFeet[i].name)); i++);
  if (i >= cmp.numFeet) goto wrapup;


  vdchn$Get(il_objID  = &cmp.theID,
	    ic_IDX    = VDCHN_IDX_TO_COMPONENTS,
	    ir_objIDX = i,
	    or_objID  = &pmID);
  if (pmID.objid == NULL_OBJID) goto wrapup;

  sts = om$send(msg = message expression.give_syntax(pieceMark),
		senderid = NULL_OBJID,
		targetid = pmID.objid,
		targetos = pmID.osnum);

  /*    
  vdobj$Print(objOE = objOE);
  vdobj$Print(objID = &pretendID);
  vdobj$Print(objID = &mac.theID);
  vdobj$Print(objID = &mac.defID);
  vdobj$Print(objID = &cmp.theID);
  vdobj$Print(objID = &cmp.defID);
  vdobj$Print(objID = &pmID);

  printf("Piece Mark %s\n",pieceMark);
  */

  retFlag = 1;
   
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Override ACgive_structure "piece_mark"
 */
#argsused
IGRstar VDbtGiveStructurePieceMark
(IGRint      *rc,
 IGRint      *notUsed,
 IGRchar     *attrName,
 Tret_struct *attrData, 
 TGRmd_env   *objENV,
 TGRid       *objID
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env objOE;

  IGRchar *p;
  
  //IGRchar pieceMark[128];
  IGRchar ppl[128];
  
  // Dare to fail
  *rc = MSFAIL;

  // Toggle
  p = getenv("VDS_PIECE_MARKS");
  if ((p == NULL) || (*p != 1)) goto wrapup;
  
  // Arg Check
  if (attrName == NULL) goto wrapup;
  
  // Verify got a attribute of interest
  if (strcmp(attrName,"piece_mark")) goto wrapup;

  // Init, clearing attrData seems to cause a core dump sometimes
  // memset(attrData,0,sizeof(Tret_struct));
  memset(&objOE,0,sizeof(objOE));

  // Get the object
  if ((objID == NULL) || (objID->objid == NULL_OBJID))  goto wrapup;
  objOE.obj_id  = *objID;

  if (objENV == NULL) objOE.mod_env.md_id.objid = NULL_OBJID;
  else                objOE.mod_env = *objENV;

  // Use smart attribute string to kick off a ppl
  sprintf(ppl,"%s%s:%s:%s",VDSA_KEY_SA_PPL,"VDatPiece","GetPieceMark","piece_mark");
  
  sts = VDsaGiveStructurePPL(&objOE,ppl,attrData);
  if (sts & 1) retFlag = OM_S_SUCCESS;
    
#if 0
  // Only plates get special handling for now
  retFlag = VDbtGetPlatePieceMark(&objOE,pieceMark);
  if (retFlag & 1) {

    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string,pieceMark);    

    retFlag = OM_S_SUCCESS;
    goto wrapup;
  }
#endif

wrapup:

  if (retFlag == OM_S_SUCCESS) *rc = MSSUCC;
  
  return retFlag;
}

/* ------------------------------------------------------
 * Hook into source plates and beams
 * Gets called after those objects finish a reconstruct
 * Can be used to add addition piece mark processing
 */
#argsused
IGRstar VDbtAfterConstructFeet(TGRobj_env *objOE, IGRint purpose)
{
  IGRstat retFlag = 1;
  IGRstat sts;
  
  IGRchar *p;

  IGRchar ppl[128];
  
  Tret_struct rs;
  
  // Toggle
  p = getenv("VDS_PIECE_MARKS");
  if ((p == NULL) || (*p != 1)) goto wrapup;

  // Use smart attribute string to kick off a ppl
  sprintf(ppl,"%s%s:%s:%d",VDSA_KEY_SA_PPL,"VDatPiece","AfterConstructFeet",purpose);
  
  sts = VDsaGiveStructurePPL(objOE,ppl,&rs);
  if (sts & 1) retFlag = OM_S_SUCCESS;

wrapup:  
  return retFlag;
}


end implementation VDbtBase;


