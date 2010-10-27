/***************************************************************************
 * I/VDS
 *
 * File:        vdval/om/VDvalCompEqp.I
 *
 * Description: XML Nozzle Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalCompNoz.I,v $
 *      Revision 1.1  2001/08/14 19:16:30  ahundiak
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

#include "VDctx.h"
#include "VDss.h"

#include "acdef.h"
#include "acrepdef.h"
#include "acrepmacros.h"

#include "macro.h"
#include "acmacros.h"

VDASSERT_FFN("VDvalCompNoz.I");

extern VDclassid OPP_ACconst_class_id;
extern VDclassid OPP_ACheader_class_id;

from ACmacro_defn import ACgive_upscan;
from ACncpx       import ACmplace;
from NDnode       import NDmove_to_root;

/* -----------------------------------------------
 * Compute an xml nozzle
 */
IGRstat VDvalComputeXmlNoz(TGRobj_env *macOE,
			   IGRint      opFlag,
			   IGRint     *feetCntx,
			   TGRid      *feetIDs)
{
  VDASSERT_FN("VDvalComputeXmlNoz");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  IGRint  msgx;

  TGRid      nozID;
  TGRid      cptID;
  TGRobj_env cptOE;
  
  IGRint     i,j;
  IGRint     feetCnt = 0;
  TGRmd_env *env;

  TGRid graID;
  
  IGRchab buf;
  IGRchab macName;
  IGRchar macRep;
  
  TGRobj_env parentOE;

  TGRid  macDefID;
  IGRint macDefTplI;
  IGRint macDefTplCnt = 0;
  IGRint macDefProp;
  struct sup *macDefTpls = NULL; // Do not free

  TGRid *tplIDs = NULL;
  IGRint tplI = 0;

  IGRchar *name;
  IGRint   type;

  TGRid  repID;
  TGRid  expID;
  TGRid  csID;
  IGRint csI = 0;

  IGRint rep;
  
  // Init
  nozID.objid = NULL_OBJID;

  // Say hi
  traceFlag = 0;
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  VDASSERTW(feetCntx); *feetCntx = 0;
  VDASSERTW(feetIDs);
  VDASSERTW(macOE);
  
  env = &macOE->mod_env;

  // Grab the internal data
  VDbufGetDomTree(macOE,&nozID);  
  VDASSERTW(nozID.objid != NULL_OBJID);

  // Make sure macro library is loaded
  VDctxGetTxtAtr(&nozID,"macro_lib",buf);
  VDASSERTW(*buf);
  ac$construct_path(mode = AC_ADD_PATH, name = buf);
  if (traceFlag) printf("Macro library %s\n",buf);

  // Start with the macro name
  VDctxGetTxtAtr(&nozID,"macro_name",macName);
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
#if 0
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
    VDctxGetTxtAtr(&nozID,"rep",buf);
    rep = atoi(buf);
    repID.objid = NULL_OBJID;
    ACgenerate_rep(rep,env->md_id.osnum,&repID);
    VDASSERTW(repID.objid != NULL_OBJID);
    if (traceFlag) VDobjPrint2(NULL,&repID);
    macDefTplI = 1;
    tplIDs[0] = repID;
    tplI = 1;
  }
#if 0
  // Basically skip the rep
  if (!strcmp(macDefTpls[0].prompt,"~rep")) {
    macDefTplI = 1;
  }
#endif

  // Cycle through and make expressions for everything else
  for(; macDefTplI < macDefTplCnt; macDefTplI++) {

    // Info
    name = macDefTpls[macDefTplI].prompt;
    type = macDefTpls[macDefTplI].type;
    
    // Expression
    if (type & parameter_generic) {

      // Expression
      VDvalCompGetAtrID(&nozID,name,env,&expID);
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
	printf("Generating cs\n");
	
	// Need to find the csI cs child
	VDvalCompGetCsID(&nozID,csI,env,&csID);
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
#if 1
  for(i = 0; i < tplI; i++) {  
    VDobjPrint2(NULL,&tplIDs[i]);
  }
#endif
  
  // And the rep
  VDctxGetTxtAtr(&nozID,"rep",buf);
  macRep = atoi(buf);
  
  // The nozzle needs to be hooked to a VRNozHold
  //VDobjGetTemplate(macOE,NULL,0,&parentOE);
  //VDobjPrint2(&parentOE,NULL);
  
  // Setup to place the graphical macro
  graID.osnum = macOE->obj_id.osnum;
  graID.objid = NULL_OBJID;
  //om$construct(classid = OPP_ACheader_class_id,
  om$construct(classid = OPP_ACconst_class_id,
	       p_objid = &graID.objid, 
	       osnum 	= graID.osnum );
  VDASSERTW(graID.objid != NULL_OBJID);

  /* ---------------------------------------------
   * This is as far as the real nozzle goes
   * Even though the macro needs a bunch of templates
   * only the nozzle itself is sent.  Somewhere in the process
   * a lower level routine ends up scaning the nozzle and 
   * making the needed expressions
   *
   * tplIDs[0] = macOE->obj_id;
   *
   * But I can't find where the process happens yet.
   * And it looks like just passing the list should work so
   * let's try it
   */
  
  // Place it
  sts = om$send(msg = message ACncpx.
		ACmplace(&msgx, 
			 AChdr_nodisplay,
			 AC_NO_REP,macName,
			 1,tplIDs,env),
		senderid = NULL_OBJID,
		targetid = graID.objid,
		targetos = graID.osnum);
#if 0
  sts = om$send(msg = message ACncpx.
		ACmplace(&msgx, 
			 AChdr_noprotect|AChdr_nodisplay,
			 macRep,macName,
			 1,tplIDs,env),
		senderid = NULL_OBJID,
		targetid = graID.objid,
		targetos = graID.osnum);
#endif
  if (!(sts & msgx & 1)) {
    printf("*** ACmplace failed\n");
  }

  // Move it to root
  om$send(msg = message NDnode.NDmove_to_root(&msg,&graID,env),
	  senderid = NULL_OBJID,
	  targetid = graID.objid,
	  targetos = graID.osnum);
  
  // Add it
  feetIDs[feetCnt] = graID;
  feetCnt++;
#endif

  // Find the connect point
  VDctxGetChildNodeByType(&nozID,VDCTX_NODE_TYPE_SS_OM_CPT,&cptID);
  if (cptID.objid != NULL_OBJID){
    
    // Place the macro
    VDbufPlaceMacro("VDxml","xml_cpt",NULL,NULL,&cptID,&cptOE);
    VDASSERTW(cptOE.obj_id.objid != NULL_OBJID);
    
    // Add it
    feetIDs[feetCnt] = cptOE.obj_id;
    feetCnt++;
  }

  // Done
  *feetCntx = feetCnt;
  retFlag = 1;

 wrapup:
  
  VDctxDeleteNode(&nozID);

  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  // Not sure if deleting is required
  if (tplIDs) {
    for(i = 0; i < tplI; i++) {  
      // deleteID(&tplIDs[i]);
      //VDobjPrint2(NULL,&tplIDs[i]);
      
    }    
    free(tplIDs);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Post placement process for nozzles
 * Takes as input an xml_eqp object
 */
void VDvalPostPlaceNozzles(TGRobj_env *eqpOE)
{
  VDASSERT_FN("VDvalPostPlaceNozzles");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRmd_env *env;
  
  TGRid eqpID;
  TGRid nozsID;
  TGRid nozID;

  TGRobj_env nozOE;
  TGRobj_env macOE;
  TGRobj_env parentOE;
  
  IGRint i;
  
  IGRchab parentFoot;
  IGRchar *p;
  
  // Arg check
  VDASSERTW(eqpOE && eqpOE->obj_id.objid != NULL_OBJID);
  env = &eqpOE->mod_env;
    
  // Convert to dom tree
  VDbufGetDomTree(eqpOE,&eqpID);
  VDASSERTW(eqpID.objid != NULL_OBJID);

  // Get the nozzles
  VDctxGetChildNodeByType(&eqpID,VDCTX_NODE_TYPE_SS_OM_NOZZLES,&nozsID);
  if (nozsID.objid == NULL_OBJID) goto wrapup;
  
  // Cycle through
  for(i = 0; VDctxGetNthTreeChild(&nozsID,i,&nozID); i++) {
    
    // Find the object that the macro will use
    VDctxGetTxtAtr(&nozID,"parent_foot",parentFoot);
    VDASSERTW(*parentFoot);
    
    VDobjGetFoot(eqpOE,NULL,"out1",&macOE);
    VDASSERTW(macOE.obj_id.objid != NULL_OBJID);

    p = strchr(parentFoot,':');
    if (p) strcpy(parentFoot,p+1);
    
    VDobjGetFoot(&macOE,NULL,parentFoot,&parentOE);
    VDASSERTW(parentOE.obj_id.objid != NULL_OBJID);
      
    // Place the macro
    VDbufPlaceMacro2("VDxml","xml_noz",NULL,NULL,&nozID,1,&parentOE,&nozOE);
    VDASSERTW(nozOE.obj_id.objid != NULL_OBJID);
      
  }

 wrapup:
  VDctxDeleteNode(&eqpID);

  return;
}

typedef struct 
{
  IGRchar     *attrName;
  Tret_struct *attrData;
  IGRint got_it;
} Tdata;

/* -----------------------------------------------
 * Process a node for a given ACgive_struct value
 */
static void processGiveStruct(TGRid *nodeID, void *a_data, IGRint *stopWalk)
{
  VDASSERT_FN("processGiveStruct");
  IGRstat sts;
  IGRchab buf;
  
  Tdata *data = (Tdata*)a_data;
  
  // Have it
  sts = VDctxGetTxtAtr(nodeID,data->attrName,buf);
  if (sts != 1) goto wrapup;

  // Quick check for doubles
  if (!strncmp(buf,"double ",7)) {
    data->attrData->type = double_type;
    data->attrData->var.root_pm_st.value = atof(buf+7);
    // printf("DBL %s %s\n",data->attrName,buf);
  }
  else {
    data->attrData->type = text_type;
    strcpy(data->attrData->var.text_st.text_string,buf);
    //printf("TXT %s %s\n",data->attrName,buf);
  }
  
  // Stop the walk
  data->got_it = 1;
  *stopWalk = 1;
  

 wrapup:
  return;
}

/* -----------------------------------------------
 * Ovrride for ACgive_structure
 */
IGRstar VDbufMacro_ACgive_structure(IGRint      *rc,
				    IGRint      *notUsed,
				    IGRchar     *attrName,
				    Tret_struct *attrData, 
				    TGRmd_env   *objEnv,
				    TGRid       *objID)
{
  VDASSERT_FN("VDbufMacro_ACgive_structure");
  
  IGRstat retFlag = OM_W_ABORT;
  
  TGRobj_env objOE;

  TGRid    treeID;

  IGRchab buf;
  
  IGRint stopWalk = 0;
  Tdata  data;
  
  // Init
  treeID.objid = NULL_OBJID;
  
  // Say hi
  traceFlag = 0;
  if (traceFlag) printf(">>> %s %s\n",fn,attrName);
  
  // Arg check
  VDASSERTW(attrData);
  VDASSERTW(attrName);
  VDASSERTW(rc);  *rc = MSFAIL;
  VDASSERTW(objID && objID->objid != NULL_OBJID);
  VDASSERTW(objEnv);

  objOE.obj_id  = *objID;
  objOE.mod_env = *objEnv;
  
  // Grab the internal data
  VDbufGetDomTree(&objOE,&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);

  // Walk to find the attribute
  data.attrName = attrName;
  data.attrData = attrData;
  data.got_it = 0;

  VDctxWalkNode(&treeID,1,processGiveStruct,&data,&stopWalk);
  if (data.got_it == 0) goto wrapup;
  
  // Done
  retFlag = OM_S_SUCCESS;
  
wrapup:

  VDctxDeleteNode(&treeID);

  if (retFlag == OM_S_SUCCESS) *rc = MSSUCC;
  if(traceFlag) printf("<<< %s %d\n",fn,retFlag);
  return retFlag;
}

end implementation Root;
