/* $Id: VDctxOmi.I,v 1.10 2001/11/09 14:44:40 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/om/VDctxOmi.I
 *
 * Description: Model Object Interface
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxOmi.I,v $
 *      Revision 1.10  2001/11/09 14:44:40  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/09/18 14:01:28  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/05/24 21:06:13  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/05/02 15:33:36  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/04/06 12:42:49  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/03/13 00:18:32  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/03/09 22:11:43  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/07 16:24:52  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/02/22 22:47:43  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/17 14:21:35  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/01/14 16:09:04  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/15/01  ah      Creation
 * 09/18/01  ah      Internal calls not initializing results
 * 11/08/01  ah      Changed double to text routine
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDobj.h"
#include "VDctxPrivate.h"
#include "VDctx.h"
#include "VDdir.h"
#include "VDat.h"
#include "VDsa.h"

VDASSERT_FFN("vdctx/om/VDctxOm.c");

/* -----------------------------------------------
 * Copy VDatFld to VDfld structure
 */
static void cpRsToFld(Tret_struct *rs, TVDfld *fld)
{
  IGRchar *value;
  IGRchar *p;
  
  // Xfer
  fld->type = VDFLD_TYPE_NONE;
  
  value = fld->val.txt;
  
  switch(rs->type) {

    case text_type:
      strcpy(value,rs->var.text_st.text_string);
      fld->type = VDFLD_TYPE_TXT;
      break;

    case double_type:

      /* -----------------------------------------
       * This matches the routine in xml but 
       * really need a global double to string
       * routine.
       */
      fld->type = VDFLD_TYPE_DBL;
      VDcnvDblToTxt(rs->var.root_pm_st.value,value);
#if 0
      sprintf(value,"%f",rs->var.root_pm_st.value);
      for(p = value + strlen(value) - 1; (p >= value) && (*p == '0'); p--);
      if (p < value) strcpy(value,"0.0");
      else {
	if (*p == '.') strcpy(p,".0");
	else *(p+1) = 0;
      }
#endif
      break;
  }
  
 
wrapup:
  return;
}
from NDmacro   import ACgive_structure;
from ACdb_info import ACgive_db_structure;

/* -----------------------------------------------
 * Text Attribute
 */
static IGRstat getFldAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     privatE,
			 TVDfld    *fld)
{
  VDASSERT_FN("getFldAtr");
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  msg,di;
  TGRmd_env envx;
  
  Tret_struct rs;

  // Init
  memset(fld,0,sizeof(TVDfld));
  
  // Check out the env
  if (env == NULL) {

    // Assumme identity
    env = &envx;
    
    // The enviroment
    gr$get_module_env(buffer = env);

    // Tweak the md_id
    env->md_id.osnum = nodeID->osnum;
    ex$get_modid(mod_osnum =  env->md_id.osnum, 
		 mod_id    = &env->md_id.objid);
  }
  
  // Get it
  sts = om$send(msg = message
		NDmacro.ACgive_structure(&msg,&di,name,&rs,env),
		senderid = NULL_OBJID,
		targetid = nodeID->objid,
		targetos = nodeID->osnum);

  /* 
   * Certain attributes are fetched from ACgive_db_structure, hence this
   * additional call (for example end_treatment0, etc. )  Alwin
   */
  if (!(sts & msg & 1))
  {
    sts = om$send(msg = message
		  ACdb_info.ACgive_db_structure(&msg,&di,name,&rs,env),
		  senderid = NULL_OBJID,
		  targetid = nodeID->objid,
		  targetos = nodeID->osnum);
  }
  if (!(sts & msg & 1)) goto wrapup;
  
  // Xfer  
  cpRsToFld(&rs,fld);
  strcpy(fld->name,name);
    
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Text Attribute
 */
static IGRstat getTxtAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     privatE,
			 IGRchar   *value)
{
  VDASSERT_FN("getTxtAtr");
  IGRstat retFlag = 0;

  TVDfld  fld;
  
  // Init
  *value = 0;
  
  // Get it
  retFlag = getFldAtr(nodeID,env,name,privatE,&fld);

  if (traceFlag) printf(">>> %s %s %s %d\n",ffn(),fn,name,retFlag);

  if (retFlag) {
    strcpy(value,fld.val.txt);
  }
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Double Attribute
 */
static IGRstat getDblAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     privatE,
			 IGRdouble *value)
{
  VDASSERT_FN("getDblAtr");
  IGRstat retFlag = 0;
  
  TVDfld fld;
  
  // Init
  *value = 0.0;
  
  // Get it
  retFlag = getFldAtr(nodeID,env,name,privatE,&fld);
  if (retFlag) {
    *value = atof(fld.val.txt);
  }

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Field attributes
 * Needs to interface to the big get everything functions
 */
static void getFldAtrs(TGRid     *nodeID, 
		       TGRmd_env *env,  
		       IGRint     privatE,
		       IGRint    *cnt,
		       TVDfld    *flds)
{
  VDASSERT_FN("getFldAtr");
  
  // Init
  *cnt = 0;
  
wrapup:
  return;
}

static void getCompPath(TGRid *nodeID, IGRchar *compPath)
{
  IGRchar *p;

  *compPath = 0;
  
  VDobjGetPath(NULL,nodeID,compPath);

  p = strstr(compPath,":ref:");
  if (p) strcpy(compPath,p+4);
  
  return;
}
static void getPieceMark(TGRid *nodeID, IGRchar *pcmk)
{ 
  *pcmk = 0;
  getTxtAtr(nodeID,NULL,"SA_AST:StagingTree:0:pcmk",0,pcmk);
  
  // Done
  return;
}

static void getNodeName(TGRid *nodeID, IGRchar *nodeName)
{
  VDASSERT_FN("getNodeName");
  
  IGRchab buf;

  *nodeName = 0;
  VDobjGetName(NULL,nodeID,buf);
  if (strlen(buf) >= VDCTX_MAX_NAME_LEN) {
    printf("*** Truncating object name for %d,%d '%s'\n",nodeID->osnum,nodeID->objid,buf);
    *(buf+VDCTX_MAX_NAME_LEN) = 0;
  }

  strcpy(nodeName,buf);

 wrapup:  
  return;
}

static void getNodeType(TGRid *nodeID, IGRchar *nodeType)
{
  IGRstat sts;
  
  *nodeType = 0;
  
  sts = vdobj$IsAncestryValid(objID = nodeID, superClassName = "VSplate");
  if (sts == 1) {
    strcpy(nodeType,VDCTX_NODE_TYPE_OM_PLATE);
    return;
  }
  sts = vdobj$IsAncestryValid(objID = nodeID, superClassName = "VSbeam");
  if (sts == 1) {
    strcpy(nodeType,VDCTX_NODE_TYPE_OM_BEAM);
    return;
  }
  strcpy(nodeType,"unknown");
  
  return;
}

static IGRstat isNodeType(TGRid *nodeID, IGRchar *nodeType)
{
  IGRstat retFlag = 0;
  
  IGRchar nodeTypex[80];
  
  getNodeType(nodeID,nodeTypex);
  if (!strcmp(nodeType,nodeTypex)) retFlag = 1;
  
  return retFlag;
}

/* -----------------------------------------------
 * Base Information
 * Should a set return nodeType and nodeName?
 */
static IGRstat getBaseInfo(TGRid *nodeID, TVDctxBaseInfo *baseInfo)
{
  VDASSERT_FN("getBaseInfo");
  IGRstat retFlag = 0;

  memset(baseInfo,0,sizeof(TVDctxBaseInfo));
  
  strcpy(baseInfo->setType,VDCTX_TREE_TYPE_OM);
  VDosGetFileName(nodeID->osnum,baseInfo->setName);
  
  getNodeType(nodeID,baseInfo->nodeType);
  getNodeName(nodeID,baseInfo->nodeName);
    
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------------------------------
 * Get the model attached to the node
 * Since nodeID is the actual model object then just copy it
 * and fill in a unit matrix thus making this process easy(er)
 */ 
static void getModelObject(TGRid *nodeID, TGRobj_env *modelOE)
{
  VDASSERT_FN("getModelObject");

  // The object
  modelOE->obj_id = *nodeID;

  // The enviroment
  gr$get_module_env(buffer = &modelOE->mod_env);

  // Tweak the md_id
  modelOE->mod_env.md_id.osnum = nodeID->osnum;
  ex$get_modid(mod_osnum =  modelOE->mod_env.md_id.osnum, 
	       mod_id    = &modelOE->mod_env.md_id.objid);

  return;
  
}

/* -----------------------------------------------
 * Initializer
 */
IGRstat VDctxInitOmCP(TVDctxCP *baseCP, TVDctxCP *cp)
{
  VDASSERT_FN("VDctxInitOmCP");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(cp);
  VDASSERTW(baseCP);

  // Copy Base
  memcpy(cp,baseCP,sizeof(TVDctxCP));
  cp->parentCP = baseCP;
  
  // Xfer overrode functions
  cp->getTxtAtr  = getTxtAtr;
  cp->getDblAtr  = getDblAtr;
  cp->getFldAtr  = getFldAtr;
  cp->getFldAtrs = getFldAtrs;

  cp->getBaseInfo   = getBaseInfo;
  cp->getNodeName   = getNodeName;
  cp->getNodeType   = getNodeType;
  cp->isNodeType    = isNodeType;

  cp->getCompName   = getNodeName;
  cp->getCompPath   = getCompPath;
  cp->getPieceMark  = getPieceMark;

  cp->getModelObject  = getModelObject;
  
#if 0
  cp->get = get;
#endif

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Plop this in here for now
 * it's implement somewhere else but can't find it
 */
void VDobjGetObjFromPath(IGRchar *path, TGRobj_env *modelOE)
{
  VDASSERT_FN("VDobjGetObjFromPath");

  TGRid      objID;
  TGRobj_env objOE;
  
  IGRchab filex;
  IGRchab pathx;
  VDosnum osnum;
  
  // Arg check
  VDASSERTW(modelOE);
  modelOE->obj_id.objid = NULL_OBJID;
  VDASSERTW(path && *path);
  
  // First check in local file
  objID.objid = NULL_OBJID;
  di$translate(objname =  path,
	       p_objid = &objID.objid,
	       p_osnum = &objID.osnum);
  if (objID.objid != NULL_OBJID) goto got_it;

  // Try reference file
  ex$get_cur_mod (osnum = &osnum);
  VDosGetFileName(osnum,filex);
  
  sprintf(pathx,":%s:ref%s",filex,path);
  
  di$translate(objname =  pathx,
	       p_objid = &objID.objid,
	       p_osnum = &objID.osnum);

  if (objID.objid != NULL_OBJID) goto got_it;

  // Give up
  goto wrapup;
  
  // Fake the enviroment for now
 got_it:

  objOE.obj_id = objID;
  
  gr$get_module_env(buffer = &objOE.mod_env);

  objOE.mod_env.md_id.osnum = objID.osnum;
  
  ex$get_modid(mod_osnum =  objOE.mod_env.md_id.osnum,
	       mod_id    = &objOE.mod_env.md_id.objid);

  // This guy could be consumed
  VDatGetConsumingChild(&objOE,modelOE);

  // Done
 wrapup:
  return;
  
}

/* -----------------------------------------------
 * Get really sloppy here
 */
#include "dpmacros.h"

void VDctxEraseHilite()
{
  IGRstat msg;
  
  dp$erase_hilite(msg = &msg);

  return;
}

end implementation Root;

