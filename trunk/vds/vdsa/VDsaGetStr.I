/* $Id: VDsaGetStr.I,v 1.9 2001/11/09 15:08:39 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsa/VDbtSa.I
 *
 * Description: Smart Attribute Handler
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsaGetStr.I,v $
 *      Revision 1.9  2001/11/09 15:08:39  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/03/18 22:37:46  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/03/01 22:00:37  ad
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/02/20 22:54:47  jayadev
 *      vd$exp_evaluate() interpretation of expression return codes
 *
 *      Revision 1.5  2001/02/13 15:11:52  jayadev
 *      vd$exp_evaluate args changed
 *
 *      Revision 1.4  2001/02/11 17:08:51  paul_noel
 *      Removed Print Statements for Pload
 *
 *      Revision 1.3  2001/02/09 22:59:05  jayadev
 *      expression evaluation macro function for VDexp.h
 *
 *      Revision 1.2  2001/01/19 13:17:59  paul_noel
 *      New file to handle SA_OTM Expressions
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *      Initial import to CVS
 *
## Revision 1.2  2000/04/04  21:33:10  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/04/17  12:59:52  pinnacle
# ah
#
# Revision 1.4  1998/04/10  21:37:36  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/30/98  ah      Creation
 * 04/04/00  Alwin   When it fails on ACgive_structure call ACdb_give_structure
 * 05/02/01  Jayadev vd$exp_evaluate() interface function 
 * 03/01/01  Adz     Add MdEnv check for VDsaGetStruct (to avoid crashes).
 * 03/01/01  Adz     ETL 4635
 * 03/18/01  ah      Add call for dynamic functions
 ***************************************************************************/

class implementation VDbtBase;

#include "VDbt.h"
#include "VDsa.h"
#include "VDsaProto.h"

// For the expression Stuff
#include  "VDmem.h"
#include  "VDdrwlo.h"
#include  "VDdrwgr.h"
#include  "VDdrwgrProto.h"
#include  "VDdrwgrMacro.h"
#include  "vdtblmacros.h"
#include  "VDattrexp.h"
#include  "VDexp.h"
#include  "v_dbgmacros.h"

#include "ACdb_info.h"

from ACdb_info import ACget_db_info;
from ACdb_info import ACgive_db_structure;

/* ------------------------------------------------------
 * Give Struct VDS Interfac
 */
IGRstar VDsaGiveStructureVDS(TGRobj_env  *objOE,
			     IGRchar     *attrName,
			     Tret_struct *attrData)
{
  IGRstat retFlag = 0;
  IGRlong sts,msg;

  struct ACdb_info dbInfo;
  
  if (!strcmp(attrName,VDSA_KEY_SA_VDS_DB_INFO)) {

    memset(&dbInfo,0,sizeof(dbInfo));

    sts = om$send(msg = message
		  ACdb_info.ACget_db_info(&msg,&dbInfo),
		  senderid = NULL_OBJID,
		  targetid = objOE->obj_id.objid,
		  targetos = objOE->obj_id.osnum);

    if (!(sts & msg & 1)) {
      printf("ACdb_info.ACget_db_info failed\n");
      goto wrapup;
    }
    attrData->type = text_type;
    sprintf(attrData->var.text_st.text_string,
	    "%s:%s:%s:%d",
	    dbInfo.catalog,dbInfo.part_num,dbInfo.revision,
	    dbInfo.serial_no);

    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Give Struct EXP Interface
 */
IGRstar VDsaGiveStructureEXP(TGRobj_env  *objOE,
			     IGRchar     *attrName,
			     Tret_struct *attrData)
{
  IGRstat retFlag = 0;
  IGRlong sts,msg;
  IGRlong status = OM_S_SUCCESS; // tblexp_exec has this name hard coded
  
  VDosnum curOS;
  IGRchar expName[128];

  TACrg_coll  expCOLL;

  // Init
  *expName = 0;
  ex$get_cur_mod(osnum = &curOS);
  
  // Parse it
  strcpy(expName,attrName + VDSA_KEY_SA_EXPn);
  if (*expName == 0) goto wrapup;
    
  sts = vd$tblexp_exec (msg      = &msg,
			osnum    = curOS,
                        tabnam   = expName ,
			flag     = TRUE,
			mode     = VD_EXP_SILENT,
			num_objs = 1,
			objList  = objOE,
			attr     = &expCOLL);

  if (!(sts & msg & 1)) {
    printf("Problem evaluating expression '%s'\n",attrName);
    goto wrapup;
  }
  
  switch(expCOLL.desc.type) {
	   
  case AC_ATTRIB_DOUBLE:
    attrData->type = double_type;
    attrData->var.root_pm_st.value = expCOLL.desc.value.att_exp;
    break;
    
  case AC_ATTRIB_TEXT: 
    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string, expCOLL.desc.value.att_txt );
    break;
    
  default:
    __DBGpr_str("Unknown expression collector for ",attrName);
    goto wrapup;
  }
  retFlag = OM_S_SUCCESS;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Give Struct PDM Interface
 */
IGRstar VDsaGiveStructurePDM(TGRobj_env  *objOE,
			     IGRchar     *attrName,
			     Tret_struct *attrData)
{
  IGRstat retFlag = 0;

  IGRchar data[128];
  
  // Dynamic table name
  if (!strcmp(attrName,VDSA_KEY_SA_PDM_DYN_TABLE)) {

    vdsa$GetDynTable(objOE = objOE,
		     tableName = data);

    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string, data);
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }

  // The family
  if (!strcmp(attrName,VDSA_KEY_SA_PDM_FAMILY)) {

    vdsa$GetDynTable(objOE = objOE,
		     family = data);

    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string, data);
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }
  
  // Catalog
  if (!strcmp(attrName,VDSA_KEY_SA_PDM_ASSY_CAT)) {

    vdsa$GetPDM(objID = &objOE->obj_id,
		assembly_cat = data);

    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string, data);
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }
  // Part
  if (!strcmp(attrName,VDSA_KEY_SA_PDM_ASSY_NAM)) {

    vdsa$GetPDM(objID = &objOE->obj_id,
		assembly_nam = data);

    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string, data);
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }
  // Ver
  if (!strcmp(attrName,VDSA_KEY_SA_PDM_ASSY_VER)) {

    vdsa$GetPDM(objID = &objOE->obj_id,
		assembly_ver = data);

    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string, data);
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }
  // seqno
  if (!strcmp(attrName,VDSA_KEY_SA_PDM_SEQNO)) {

    vdsa$GetPDM(objID = &objOE->obj_id,
		seqno = data);

    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string, data);
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }
  // all
  if (!strcmp(attrName,VDSA_KEY_SA_PDM_POST_ID)) {

    vdsa$GetPDM(objID = &objOE->obj_id,
		all = data);

    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string, data);
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }
  // file name
  if (!strcmp(attrName,VDSA_KEY_SA_PDM_FILE_NAME)) {

    vdsa$GetPDM(objID = &objOE->obj_id,
		fileName = data);

    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string, data);
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }

wrapup:
  return retFlag;
  
}

/* ------------------------------------------------------
 * Give Struct PPL Interface
 */
IGRstar VDsaGiveStructurePPL(TGRobj_env  *objOE,
			     IGRchar     *attrName,
			     Tret_struct *attrData)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar *p;
  
  IGRchar pplName[128];
  IGRchar pplFunc[128];
  IGRchar pplData[128];

  TGRid   pplID;
  IGRint  pplRet;
  
  // Init
  *pplName = 0;
  *pplFunc = 0;
  *pplData = 0;
   pplID.objid = NULL_OBJID;
  
  // Parse it
  strcpy(pplName,attrName + VDSA_KEY_SA_PPLn);
  if (*pplName == 0) goto wrapup;
    
  p = strchr(pplName,':');
  if (p) {
    *p = 0;
    strcpy(pplFunc,p+1);
  }
  p = strchr(pplFunc,':');
  if (p) {
    *p = 0;
    strcpy(pplData,p+1);
  }
  if (*pplFunc == 0) strcpy(pplFunc,"main");

  // Load it
  VDahPPL_Load(pplName,&pplID);
  if (pplID.objid == NULL_OBJID) {
    printf("Could not load PPL '%s'\n",attrName);
    goto wrapup;
  }

  // Global Data
  VDahPPL_SetValue(&pplID,"OBJECT_ID",   sizeof(TGRid),      (IGRchar*)&objOE->obj_id);
  VDahPPL_SetValue(&pplID,"OBJECT_ENV",  sizeof(TGRmd_env),  (IGRchar*)&objOE->mod_env);
  VDahPPL_SetValue(&pplID,"OBJECT_DATA", strlen(pplData)+1,  (IGRchar*)pplData);
  
  //VDahPPL_SetValue(&pplID,"OBJECT_RS",   sizeof(Tret_struct),(IGRchar*)attrData);
  
  // Run It
  sts = VDahPPL_Run(&pplID,pplFunc,&pplRet);
  if (!(sts & pplRet & 1)) goto wrapup;
  
  VDahPPL_GetValue(&pplID,"OBJECT_RS",sizeof(Tret_struct),(IGRchar*)attrData);
  retFlag = OM_S_SUCCESS;
  
wrapup:
  if (pplID.objid != NULL_OBJID) VDahPPL_Delete(&pplID);
  
  return retFlag;
}

    
  
/* ------------------------------------------------------
 * Override ACgive_structure with a function
 */
#argsused
IGRstar VDsaGiveStructure(IGRint      *rc,
			  IGRint      *notUsed,
			  IGRchar     *attrName,
			  Tret_struct *attrData, 
			  TGRmd_env   *objENV,
			  TGRid       *objID)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  
  TGRobj_env objOE;
    
  // Dare to fail
  *rc = MSFAIL;
  
  if(traceFlag) printf(">>> VDsaGetStr.I: VDsaGiveStructure\n");
  
  // Arg Check
  if (attrName == NULL) goto wrapup;
  
  // Verify got a attribute of interest
  if (strncmp(attrName,VDSA_KEY_SA,VDSA_KEY_SAn)) goto wrapup;

  // Init, clearing attrData seems to cause a core dump sometimes
  // memset(attrData,0,sizeof(Tret_struct));
  memset(&objOE,0,sizeof(objOE));

  if ((objID == NULL) || (objID->objid == NULL_OBJID))  goto wrapup;
  objOE.obj_id  = *objID;

  if (objENV == NULL) objOE.mod_env.md_id.objid = NULL_OBJID;
  else                objOE.mod_env = *objENV;

  // See if it is a obj request
  if (!strncmp(attrName,VDSA_KEY_SA_OBJ,VDSA_KEY_SA_OBJn)) {
  
    retFlag = VDsaGiveStructureOBJ(&objOE,
				   attrName,
				   attrData);    
    goto wrapup;
    
  }

  // See if it is a pdm request
  if (!strncmp(attrName,VDSA_KEY_SA_PDM,VDSA_KEY_SA_PDMn)) {
  
    retFlag = VDsaGiveStructurePDM(&objOE,
				   attrName,
				   attrData);    
    goto wrapup;
    
  }

  // See if it is a dyn
  if (!strncmp(attrName,VDSA_KEY_SA_DYN,VDSA_KEY_SA_DYNn)) {
  
    retFlag = VDsaGiveStructureDYN(&objOE,
				   attrName,
				   attrData);    
    goto wrapup;
    
  }

  // See if it is a tbl
  if (!strncmp(attrName,VDSA_KEY_SA_TBL,VDSA_KEY_SA_TBLn)) {
  
    retFlag = VDsaGiveStructureTBL(&objOE,
				   attrName,
				   attrData);    
    goto wrapup;
    
  }

  // See if it is a set
  if (!strncmp(attrName,VDSA_KEY_SA_SET,VDSA_KEY_SA_SETn)) {
  
    retFlag = VDsaGiveStructureSET(&objOE,
				   attrName,
				   attrData);    
    goto wrapup;
    
  }

  // See if it is a ast
  if (!strncmp(attrName,VDSA_KEY_SA_AST,VDSA_KEY_SA_ASTn)) {
  if(traceFlag) printf("Processing Smart Attribute: AST\n");
    retFlag = VDsaGiveStructureAST(&objOE,
				   attrName,
				   attrData);    
    goto wrapup;
    
  }

  // See if it is a ppl
  if (!strncmp(attrName,VDSA_KEY_SA_PPL,VDSA_KEY_SA_PPLn)) {
    //printf("Processing Smart Attribute: PPL\n");
    retFlag = VDsaGiveStructurePPL(&objOE,
				   attrName,
				   attrData);    
    goto wrapup;
    
  }

  // See if it is a exp
  if (!strncmp(attrName,VDSA_KEY_SA_EXP,VDSA_KEY_SA_EXPn)) {
  
    retFlag = VDsaGiveStructureEXP(&objOE,
				   attrName,
				   attrData);    
    goto wrapup;
    
  }

  // DB Info hook
  if (!strncmp(attrName,VDSA_KEY_SA_VDS,VDSA_KEY_SA_VDSn)) {
    if(traceFlag) printf("Processing Smart Attribute: VDS\n");
    retFlag = VDsaGiveStructureVDS(&objOE,
				   attrName,
				   attrData);    
    goto wrapup;
    
  }

  // See if it is a dynamic function
  if (!strncmp(attrName,"SA_FUN",7)) {
    retFlag = VDsaGiveStructureFUN(&objOE,
				   attrName,
				   attrData);    
    goto wrapup;
    
  }

  /* 
   * Added to implement CR 4108  11/22/00 pn
   */
  // see if it is a OTM
  if (!strncmp(attrName,VDSA_KEY_SA_OTM,VDSA_KEY_SA_OTMn)) {
    if(traceFlag) printf("\n\nProcessing Smart Attribute: OTM\n");
    
    retFlag = VDsaGiveStructureOTM(&objOE,
				   attrName,
				   attrData);    
    goto wrapup;
    
  }
  // end CR 4108 implementation
  printf("Unknown Smart Attribute '%s'\n",attrName);


wrapup:

  if (retFlag == OM_S_SUCCESS) *rc = MSSUCC;
  if(traceFlag) printf("<<< VDsaGetStr.I: VDsaGiveStructure(%d)\n",retFlag);
  return retFlag;
}

/* --------------------------------------------------------
 * Interface to give struct
 */
IGRstar VDsaGetStruct(TGRobj_env  *objOE,
		      TGRid       *objID,
		      TGRmd_env   *objENV,
		      IGRchar     *name,
                      IGRint       sa,
                      IGRint       trace,

		      IGRint      *type,

		      IGRchar     *txt,
		      IGRchar     *tyt,
		      IGRdouble   *dbl,
		      IGRint      *jnt,
		      TVDfld      *fld,
		      TACrg_coll  *col,	     
		      Tret_struct *rs
		      )
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  IGRstat sts;
  IGRint  msg,di;
  
  Tret_struct rsx;
  TGRmd_env  tmpENV;
  
  TGRid      *objIDx = NULL;
  TGRmd_env *objENVx = NULL;
  
  // say hi
  if(traceFlag) printf(">>> VDsaGetStr.I: VDsaGetStruct\n");
  
  // Arg Check
  if (txt) *txt = 0;
  if (tyt) *tyt = 0;
  if (dbl) *dbl = 0.0;
  if (jnt) *jnt = 0;
  if (col) memset(col,0,sizeof(TACrg_coll));
  if (fld) memset(fld,0,sizeof(TVDfld));
  if (rs)  memset(rs, 0,sizeof(Tret_struct));
  if (type) *type = 0;
  
  // Need a name
  if ((name  == NULL) || (*name == 0)) goto wrapup;

  // Need objid
  if (objID) objIDx =  objID;
  if (objOE) objIDx = &objOE->obj_id;
  
  if ((objIDx == NULL) || (objIDx->objid == NULL_OBJID)) goto wrapup;

  // Optional env
  if (objENV) objENVx =  objENV;
  if (objOE)  objENVx = &objOE->mod_env;
  if ( ! objENVx ){
    /*
     * add local matrix
     */
	gr$get_module_env(buffer = &tmpENV);

	tmpENV.md_id.osnum = objIDx->osnum;
	ex$get_modid(mod_osnum =  tmpENV.md_id.osnum,
               	     mod_id    = &tmpENV.md_id.objid );
	objENVx = &tmpENV;
  }
  
  // Reset internal data
  memset(&rsx,0,sizeof(Tret_struct));

  // Jump directly to sa routine if prefix found
  if (trace) vdbro$PrintObject(objID = objIDx);

  if ((sa == 1) && (!strncmp(name,VDSA_KEY_SA,VDSA_KEY_SAn))) {
    sts = VDsaGiveStructure(&msg,&di,name,&rsx,objENVx,objIDx);
  }
  
  else {
    
    sts = om$send(msg = message
		  NDmacro.ACgive_structure(&msg,&di,name,&rsx,objENVx),
		  senderid = NULL_OBJID,
		  targetid = objIDx->objid,
		  targetos = objIDx->osnum);

	/* 
	 * Certain attributes are fetched from ACgive_db_structure, hence this
	 * additional call (for example end_treatment0, etc. )  Alwin
	 */
	if (!(sts & msg & 1))
	{
		sts = om$send(msg = message
			  ACdb_info.ACgive_db_structure(&msg,&di,name,&rsx,objENVx),
			  senderid = NULL_OBJID,
			  targetid = objIDx->objid,
			  targetos = objIDx->osnum);
	}
  }
  if (!(sts & msg & 1)) goto wrapup;

  // Parse the output
  if (rs) *rs = rsx;

  if (type) *type = rsx.type;

  if ((txt) && (rsx.type == text_type)) {
    strcpy(txt,rsx.var.text_st.text_string);
  }
  if ((dbl) && (rsx.type == double_type)) {
    *dbl = rsx.var.root_pm_st.value;
  }
  if ((jnt) && (rsx.type == double_type)) {
    *jnt = (IGRint)rsx.var.root_pm_st.value;
  }

  /* ---------------------------------------------
   * 08 Nov 2001 Changed the dbl part of this to use
   * the same code that ris uses to convert dbl to txt
   * Only a couple spots used this option so it should
   * be ok
   */
  if (tyt) 
  {
    if (rsx.type == text_type)   strcpy (tyt,rsx.var.text_st.text_string);
    if (rsx.type == double_type) {
      // sprintf(tyt,"%f",rsx.var.root_pm_st.value);
      VDcnvDblToTxt(rsx.var.root_pm_st.value,tyt);
    }
  }

  retFlag = 1;
  
wrapup:

  // say bye
  if(traceFlag) printf("<<< VDsaGetStr.I: VDsaGetStruct(%d)\n",retFlag);
  return retFlag;
  
}

/* ------------------------------------------------------
 * Interfaced by macro vd$exp_evaluate() 
 */
IGRstar VDevaluateEXP(IGRboolean        *succ,
		      IGRchar            *expName,
		      struct GRobj_env   *object,
		      struct ACrg_coll   *collector)
{
  IGRstat retFlag = 0;
  IGRlong sts,msg;
  IGRlong status = OM_S_SUCCESS; // tblexp_exec has this name hard coded
  VDosnum curOS;
  TACrg_coll  expCOLL;
  
  if( ! succ ) goto wrapup;
  if( ! expName ) goto wrapup;
  if( ! object ) goto wrapup;
  if( expName[0] == '\0') goto wrapup; 
  
  // initialize outputs
  *succ = 0;
  
  // Init
  ex$get_cur_mod(osnum = &curOS);
  
  strcpy(expCOLL.name, expName);
  expCOLL.desc.type = AC_ATTRIB_TYPE_NOT_DEF ;
  expCOLL.desc.value.att_txt[0] = '\0';
  
  // execute the expression on the object 
  sts = vd$tblexp_exec (msg      = &msg,
			osnum    = curOS,
                        tabnam   = expName ,
			flag     = TRUE,
			mode     = VD_EXP_SILENT,
			num_objs = 1,
			objList  = object,
			attr     = &expCOLL);
  
  if (!(sts & msg & 1)) {
    printf("Problem evaluating expression %s\n",expName);
    goto wrapup;
  }
  
  if( collector )
    *collector = expCOLL; // fill the output collector
  
  switch(expCOLL.desc.type) {
    
    case AC_ATTRIB_DOUBLE:
      
      if(expCOLL.desc.value.att_exp == 1.0) *succ = 1;
      else if(expCOLL.desc.value.att_exp == 0.0) *succ = 0;
      else *succ = 0;
            
      break;
      
    case AC_ATTRIB_TEXT: 
      if(strlen(expCOLL.desc.value.att_txt) == 0) *succ = 0;
      else if (expCOLL.desc.value.att_txt[0] == '\0') *succ = 0;
      else if (expCOLL.desc.value.att_txt[0] == ' ') *succ = 0;
      else if (expCOLL.desc.value.att_txt[0] == '0') *succ = 0;
      else if (expCOLL.desc.value.att_txt[0] == '1') *succ = 1;
      else *succ = 0;
 
      break;
      
    default:
      printf("Unknown expression collector for '%s'\n",expName);
      goto wrapup;
      
  }
  retFlag = OM_S_SUCCESS;
  
 wrapup:
  return retFlag;
}
end implementation VDbtBase;


