/***************************************************************************
 * I/VDS
 *
 * File:        vdval/om/VDvalCompEqp.I
 *
 * Description: Validation Compute Equipment routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalCompEqp.I,v $
 *      Revision 1.4  2001/11/16 15:18:11  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/08/24 20:01:52  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/08/14 19:15:45  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/08/02 15:33:39  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/31/01  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDbuf.h"
#include "VDtest.h"
#include "VDgeomc.h"
#include "VDdraw.h"
#include "VDobj2.h"

#include "VDval.h"
#include "VDvalLike.h"

#include "VDxdom.h"
#include "VDctx.h"
#include "VDss.h"

#include "acdef.h"
#include "acrepdef.h"
#include "acrepmacros.h"

#include "macro.h"
#include "acmacros.h"

VDASSERT_FFN("VDvalCompEqp.I");

static deleteOE(TGRobj_env *objOE)
{
  if (objOE->obj_id.objid != NULL_OBJID) {  
    VDobjDelete(objOE,NULL,NULL,NULL,1,NULL,NULL);
  }
}
static deleteID(TGRid *objID)
{
  if (objID->objid != NULL_OBJID) {  
    VDobjDelete(NULL,objID,NULL,NULL,1,NULL,NULL);
  }
}

from ACmacro_defn import ACgive_upscan;
from ACncpx       import ACmplace;

from VDSroot      import VDputAttrDrivenSymb;

/* -----------------------------------------------
 * Postpone the decision about keeping the
 * collector boundaries by wrapping the attribute accessor
 */
static IGRstat getAtr(TGRid *nodeID, IGRchar *name, IGRchar *value)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint i;
  TGRid  childID;

  // Init
  *value = 0;
  
  // Cycle through
  for(i = 0; VDctxGetNthTreeChild(nodeID,i,&childID); i++){
    if (VDctxIsNodeType(&childID,VDCTX_NODE_TYPE_SS_OM_COLLECTOR)) {
      sts = VDctxGetTxtAtr(&childID,name,value);
      if (sts) {
	retFlag = 1;
	goto wrapup;
      }
    }
  }
  
 wrapup:
  return retFlag;
}

extern VDclassid OPP_text_exp_class_id;
extern VDclassid OPP_expression_class_id;
extern VDclassid OPP_ACconst_class_id;

from NDnode     import NDchg_state;
from NDnode     import NDmove_to_root;

from expression import NDset_value;
from expression import modify;


/* -----------------------------------------------
 * Helper routine to turn an attribute value into
 * an expression object
 *
 * Basically copied from ACrg_collect.ACreturn_foot
 */
void VDvalCompGetAtrID(TGRid *nodeID, IGRchar *name, TGRmd_env *env, TGRid *expID)
{
  IGRstat sts;
  IGRshort rc;
  
  IGRchab   buf;
  IGRdouble dbl;
  
  VDclassid expClassId;
  
  // Init
  expID->objid = NULL_OBJID;
  
  // Get the value
  sts = getAtr(nodeID,name,buf);
  if (sts == 0) goto wrapup;
  
  // Double
  if (strncmp(buf,"double ",7)) expClassId = OPP_text_exp_class_id;
  else {
    expClassId = OPP_expression_class_id;
    dbl = atof(buf+7);
  }

  // Make it
  expID->osnum = env->md_id.osnum;
  sts = om$construct(classid = expClassId,
		     osnum   = expID->osnum,
		     msg = message NDnode.
		     NDchg_state(ND_SUP_ONLY|ND_WAIT_DEL,ND_SUP_ONLY|ND_WAIT_DEL),
		     p_objid = &expID->objid);
  if (!(sts & 1)) goto wrapup;

  // Set value
  if (expClassId == OPP_text_exp_class_id) {    
    om$send(msg = message expression.modify(NULL,buf,&rc),
	    senderid = NULL_OBJID,
	    targetid = expID->objid,
	    targetos = expID->osnum);
  }
  else {
    om$send(msg = message expression.NDset_value(NULL,dbl,NULL,&rc),
	    senderid = NULL_OBJID,
	    targetid = expID->objid,
	    targetos = expID->osnum);
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * helper function to create the nth cs
 */
void VDvalCompGetCsID(TGRid *nodeID, IGRint nth, TGRmd_env *env, TGRid *csID)
{
  VDASSERT_FN("getCsID");

  IGRstat sts;
  
  IGRint i,j;
  TGRid  childID;

  IGRdouble matrix[16];
  
  IGRchar *buf;
  
  // Init
  csID->objid = NULL_OBJID;
  
  // Need to find the nth cs child
  j = 0;
  for(i = 0; VDctxGetNthTreeChild(nodeID,i,&childID); i++) {
    if (VDctxIsNodeType(&childID,VDCTX_NODE_TYPE_SS_OM_CS)) {
      if (j < nth) j++;
      else {

	// Get the data
	sts = VDctxGetTxtAtrPtr(&childID,"matrix",&buf);
	VDASSERTW(sts);
	VDvalConvertTextToDoubles(buf,NULL,matrix);
	
	// Make a cs
	VDdrawCS(matrix,env,csID);
	goto wrapup;
      }
    }
  }

 wrapup:
  return;
}

/* -----------------------------------------------
 * Compute an xml piece
 */
IGRstat VDvalComputeXmlEqp(TGRobj_env *macOE,
			   IGRint      opFlag,
			   IGRint     *feetCntx,
			   TGRid      *feetIDs)
{
  VDASSERT_FN("VDvalComputeXmlEqp");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  IGRint  msgx;
  
  TGRobj_env eqpOE;
  TGRid      eqpID;
    
  IGRint     i,j;
  IGRint     feetCnt = 0;
  TGRmd_env *env;

  IGRchar macName[128];
  IGRchab buf;
  
  TGRid macDefID;

  IGRint macDefTplI;
  IGRint macDefTplCnt = 0;
  IGRint macDefProp;
  struct sup *macDefTpls = NULL; // Do not free

  IGRint rep;
  TGRid  repID;
  TGRid  expID;
  
  TGRid *tplIDs = NULL;
  IGRint tplI = 0;

  IGRint   type;
  IGRchar *name;

  TGRid  csID;
  IGRint csI = 0;

  TGRid  macID;
    
  TGRid  nozzleGroupID;
  
  // Init
  eqpID.objid = NULL_OBJID;

  // Say hi
  // traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  VDASSERTW(feetCntx); *feetCntx = 0;
  VDASSERTW(feetIDs);
  VDASSERTW(macOE);
  
  env = &macOE->mod_env;
  
  // Generate xml if a piece is attached
  VDobjGetTemplate(macOE,NULL,0,&eqpOE);
  if (eqpOE.obj_id.objid == NULL_OBJID) {

    // Grab the internal data
    VDbufGetDomTree(macOE,&eqpID);
    VDASSERTW(eqpID.objid != NULL_OBJID);
  }
  else {
    
    // Read from the equipment
    VDvalConvertEqpToDom(&eqpOE,NULL,&eqpID);
    VDASSERTW(eqpID.objid != NULL_OBJID);

    VDbufSetDomTree(macOE,&eqpID);
    
    VDctxSaveTreeToXmlFile(&eqpID,"eqp.xml");
  }

  // Make sure macro library is loaded
  VDctxGetTxtAtr(&eqpID,"macro_lib",buf);
  VDASSERTW(*buf);
  ac$construct_path(mode = AC_ADD_PATH, name = buf);
  if (traceFlag) printf("Macro library %s\n",buf);

  // Start with the macro name
  VDctxGetTxtAtr(&eqpID,"macro_name",macName);
  VDASSERTW(*macName);
  if (traceFlag) printf("Macro name %s\n",macName);

  // Need the defination
  macDefID.objid = NULL_OBJID;
  ac$find_macro_defn(action          = ACfind_load,
		     macro_name      = macName,
		     p_macro_defn_id = &macDefID);
  if (macDefID.objid == NULL_OBJID) {
    VDlogPrintFmt(VDLOG_ERROR,1,"*** Could not find macro def for %s",macName);
    goto wrapup;
  }
  if (traceFlag) VDobjPrint2(NULL,&macDefID);

  // Need the templates
  om$send(msg = message ACmacro_defn.
	  ACgive_upscan(&macDefTplCnt,&macDefProp,&macDefTpls),
	  senderid = NULL_OBJID,
	  targetid = macDefID.objid,
	  targetos = macDefID.osnum);
  VDASSERTW(macDefTplCnt);
  macDefTplI = 0;
#if 0  
  if (traceFlag) {
    for(i = 0; i < macDefTplCnt; i++) {
      printf("%2d %s\n",i,macDefTpls[i].prompt);
    }
  }
#endif
  // Allocate room for the generated templates
  tplIDs = malloc(macDefTplCnt * sizeof(TGRid));
  VDASSERTW(tplIDs);
  tplI = 0;
  
  // If a rep is needed then make one
  if (!strcmp(macDefTpls[0].prompt,"~rep")) {
    VDctxGetTxtAtr(&eqpID,"rep",buf);
    rep = atoi(buf);
    repID.objid = NULL_OBJID;
    ACgenerate_rep(rep,env->md_id.osnum,&repID);
    VDASSERTW(repID.objid != NULL_OBJID);
    if (traceFlag) VDobjPrint2(NULL,&repID);
    macDefTplI = 1;
    tplIDs[0] = repID;
    tplI = 1;
  }
  
  // Cycle through and make expressions for everything else
  for(; macDefTplI < macDefTplCnt; macDefTplI++) {

    // Info
    name = macDefTpls[macDefTplI].prompt;
    type = macDefTpls[macDefTplI].type;
    
    // Expression
    if (type & parameter_generic) {

      // Expression
      VDvalCompGetAtrID(&eqpID,name,env,&expID);
      if (expID.objid != NULL_OBJID) {
	tplIDs[tplI] = expID;
	tplI++;
      }
      else {
	VDlogPrintFmt(VDLOG_ERROR,1,"*** Warning no value found for %s",name);
      } 
    }
    else {

      // CS
      if (type == ref_generic) {

	// Need to find the csI cs child
	VDvalCompGetCsID(&eqpID,csI,env,&csID);
	if (csID.objid != NULL_OBJID) {
	  tplIDs[tplI] = csID;
	  tplI++;
	  csI++; 
	}
	else {
	  VDlogPrintFmt(VDLOG_ERROR,1,"*** Warning no nth %d cs found for %s",csI+1,name);
	}     
      }
      else {
	VDlogPrintFmt(VDLOG_ERROR,1,"*** Unknown template type for %s",name);
      }
      
    }
  }
#if 0
  for(i = 0; i < tplI; i++) {  
    VDobjPrint2(NULL,&tplIDs[i]);
  }
#endif
  // Ready for the macro itself
  macID.osnum = macOE->obj_id.osnum;
  macID.objid = NULL_OBJID;
  om$construct(classid = OPP_ACconst_class_id,
	       p_objid = &macID.objid,
	       osnum   =  macID.osnum);
  VDASSERTW(macID.objid != NULL_OBJID);

  // Place it
  sts = om$send(msg = message ACncpx.ACmplace(&msgx,
					      AChdr_nodisplay,
					      AC_NO_REP,
					      macName,
					      tplI,
					      tplIDs,
					      env),
		senderid = NULL_OBJID,
		targetid = macID.objid,
		targetos = macID.osnum );

  // Delete if failed
  if (!(sts & msgx & 1)) {
    deleteID(&macID);
    VDlogPrintFmt(VDLOG_ERROR,1,"*** Failed to place macro %s",macName);
    goto wrapup;
  }

  // Move it to root
  om$send(msg = message NDnode.NDmove_to_root(&msg,&macID,env),
	  senderid = NULL_OBJID,
	  targetid = macID.objid,
	  targetos = macID.osnum);

  /* Called this method for CR: 179700254 */
#if 0
  om$send(msg = message VDSroot.
	  VDputAttrDrivenSymb(&msg,env,"equip.att"),
	  senderid = NULL_OBJID,
	  targetid = macOE->obj_id.objid,
	  targetos = macOE->obj_id.osnum);
#endif

  // Add it
  feetIDs[feetCnt] = macID;
  feetCnt++;

  // Done
  *feetCntx = feetCnt;
  retFlag = 1;

 wrapup:

  // Not sure if deleting is required
  if (tplIDs) {
    for(i = 0; i < tplI; i++) {  
      deleteID(&tplIDs[i]);
      //VDobjPrint2(NULL,&tplIDs[i]);
      
    }    
    free(tplIDs);
  }
  
  VDctxDeleteNode(&eqpID);

  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}

end implementation Root;


