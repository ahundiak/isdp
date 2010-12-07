/***************************************************************************
 * I/AIM
 *
 * File:        sir2/VDcoll.I
 *
 * Description: Collector Specific Functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcoll.I,v $
 *      Revision 1.2.2.3  2003/06/11 13:31:19  ahundiak
 *      ah
 *
 *      Revision 1.2.2.2  2003/06/05 16:45:17  ahundiak
 *      ah
 *
 *      Revision 1.2.2.1  2003/05/30 19:08:54  ahundiak
 *      ah
 *
 *      Revision 1.2  2003/05/27 13:35:15  ahundiak
 *      ah
 *
 *      Revision 1.1  2003/05/16 14:39:34  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/13/01  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDdir.h"
#include "VDos.h"
#include "VDppl1.h"

#include "VDPaimUtil.h"

VDASSERT_FFN("VDcoll.I");

from ACrg_collect import ACget_named_attribute;
from ACrg_collect import ACmod_list_attribute;
from ACrg_collect import ACadd_list_attribute;

extern VDclassid OPP_ACrg_collect_class_id;

/* ----------------------------------------------
 * Reads an text attribute
 */
IGRstat VDcollGetTextAttr(TGRid *collID, IGRchar *name, IGRchar *value)
{
  VDASSERT_FN("VDcollGetTextAttr");

  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TACrg_coll attr;

  /* Arg check */
  VDASSERTW(value); *value = 0;
  VDASSERTW(name && *name);
  VDASSERTW(collID && collID->objid != NULL_OBJID);

  /* Get It */
  strcpy(attr.name,name);
  sts = om$send(msg = message 
    ACrg_collect.ACget_named_attribute(&msg,&attr),
    senderid = NULL_OBJID,
    targetid = collID->objid,
    targetos = collID->osnum );

  /* Copy */
  if (!(sts & msg & 1)) goto wrapup;
  if (attr.desc.type != AC_ATTRIB_TEXT) goto wrapup;
  strcpy(value,attr.desc.value.att_txt);

  /* Done */
  retFlag = 1;

wrapup:
  return retFlag;
}
/* ----------------------------------------------
 * Reads an integer attribute
 */
IGRstat VDcollGetIntAttr(TGRid *collID, IGRchar *name, IGRint *value)
{
  VDASSERT_FN("VDcollGetTextAttr");

  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TACrg_coll attr;

  /* Arg check */
  VDASSERTW(value); *value = 0;
  VDASSERTW(name && *name);
  VDASSERTW(collID && collID->objid != NULL_OBJID);

  /* Get It */
  strcpy(attr.name,name);
  sts = om$send(msg = message 
    ACrg_collect.ACget_named_attribute(&msg,&attr),
    senderid = NULL_OBJID,
    targetid = collID->objid,
    targetos = collID->osnum );

  /* Copy */
  if (!(sts & msg & 1)) goto wrapup;
  if (attr.desc.type != AC_ATTRIB_DOUBLE) goto wrapup;
  *value = (IGRint)attr.desc.value.att_exp;

  /* Done */
  retFlag = 1;

wrapup:
  return retFlag;
}
/* ----------------------------------------------
 * Reads a double attribute
 */
IGRstat VDcollGetDblAttr(TGRid *collID, IGRchar *name, IGRdouble *value)
{
  VDASSERT_FN("VDcollGetDblAttr");

  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TACrg_coll attr;

  /* Arg check */
  VDASSERTW(value); *value = 0.0;
  VDASSERTW(name && *name);
  VDASSERTW(collID && collID->objid != NULL_OBJID);

  /* Get It */
  strcpy(attr.name,name);
  sts = om$send(msg = message 
    ACrg_collect.ACget_named_attribute(&msg,&attr),
    senderid = NULL_OBJID,
    targetid = collID->objid,
    targetos = collID->osnum );

  /* Copy */
  if (!(sts & msg & 1)) goto wrapup;
  if (attr.desc.type != AC_ATTRIB_DOUBLE) goto wrapup;
  *value = attr.desc.value.att_exp;

  /* Done */
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Sets a text attribute
 * Create if necessary
 */
IGRstat VDcollSetTextAttr(TGRid *collID, IGRchar *name, IGRchar *value)
{
  VDASSERT_FN("VDcollSetTextAttr");

  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TACrg_coll attr;

  /* Arg check */
  VDASSERTW(value);
  VDASSERTW(name && *name);
  VDASSERTW(collID && collID->objid != NULL_OBJID);

  /* See if have one */
  strcpy(attr.name,name);
  sts = om$send(msg = message 
    ACrg_collect.ACget_named_attribute(&msg,&attr),
    senderid = NULL_OBJID,
    targetid = collID->objid,
    targetos = collID->osnum );

  /* Update */
  if (sts & msg & 1)
  {
    attr.desc.type = AC_ATTRIB_TEXT;
    strcpy(attr.desc.value.att_txt,value);
    sts = om$send(msg = message 
      ACrg_collect.ACmod_list_attribute(&msg,1,&attr),
      senderid = NULL_OBJID,
      targetid = collID->objid,
      targetos = collID->osnum );
    if (sts & msg & 1) retFlag = 1;
    goto wrapup;
  }

  /* Add */
  attr.desc.type = AC_ATTRIB_TEXT;
  strcpy(attr.desc.value.att_txt,value);

  sts = om$send(msg = message 
    ACrg_collect.ACadd_list_attribute(&msg,1,&attr),
    senderid = NULL_OBJID,
    targetid = collID->objid,
    targetos = collID->osnum );
  if (sts & msg & 1) retFlag = 1;

wrapup:
  return retFlag;
}
/* ----------------------------------------------
 * Sets a integer attribute
 * Create if necessary
 */
IGRstat VDcollSetIntAttr(TGRid *collID, IGRchar *name, IGRint value)
{
  VDASSERT_FN("VDcollSetIntAttr");

  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TACrg_coll attr;

  /* Arg check */
  VDASSERTW(name && *name);
  VDASSERTW(collID && collID->objid != NULL_OBJID);

  /* See if have one */
  strcpy(attr.name,name);
  sts = om$send(msg = message 
    ACrg_collect.ACget_named_attribute(&msg,&attr),
    senderid = NULL_OBJID,
    targetid = collID->objid,
    targetos = collID->osnum );

  /* Update */
  if (sts & msg & 1)
  {
    attr.desc.type = AC_ATTRIB_DOUBLE;
    attr.desc.value.att_exp = (IGRdouble)value;
    sts = om$send(msg = message 
      ACrg_collect.ACmod_list_attribute(&msg,1,&attr),
      senderid = NULL_OBJID,
      targetid = collID->objid,
      targetos = collID->osnum );
    if (sts & msg & 1) retFlag = 1;
    goto wrapup;
  }

  /* Add */
  attr.desc.type = AC_ATTRIB_DOUBLE;
  attr.desc.value.att_exp = (IGRdouble)value;

  sts = om$send(msg = message 
    ACrg_collect.ACadd_list_attribute(&msg,1,&attr),
    senderid = NULL_OBJID,
    targetid = collID->objid,
    targetos = collID->osnum );
  if (sts & msg & 1) retFlag = 1;

wrapup:
  return retFlag;
}
/* ----------------------------------------------
 * Utility routine for defaulting to the current os
 * if none was specified.
 */
static VDosnum getOS(VDosnum osnum)
{
  if (osnum == OM_K_NOT_AN_OS) 
  {
    VDosGetCurrentOS(&osnum);
  }
  return osnum;
}
from GRvg import GRputname;
/* ----------------------------------------------
 * Create a new collector
 * with the specified name
 */
IGRstat VDcollCreate(VDosnum osnum, IGRchar *path, TGRid *collID)
{  
  VDASSERT_FN("VDcollCreate");

  IGRstat retFlag = 0;
  IGRstat sts,msg;

  /* Arg check */
  VDASSERTW(collID); 
  collID->objid = NULL_OBJID;

  /* Init */
  osnum = getOS(osnum);

  /* Create */
  collID->osnum = osnum;
  sts = om$construct(classid = OPP_ACrg_collect_class_id,
                     osnum   = osnum,
                     p_objid = &collID->objid);
  if(!(sts & 1)) 
  {
    collID->objid = NULL_OBJID;
    goto wrapup;
  }

  /* Want a name? */
  if (!path || *path == 0)
  {
    retFlag = 1;
    goto wrapup;
  }

  /* Add a name */
  sts = om$send(msg = message GRvg.GRputname(&msg,path),
			senderid = NULL_OBJID,
			targetid = collID->objid,
			targetos = collID->osnum);
  if (!(sts & msg &1)) goto wrapup;

  /* Done */
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Slightly easier interface to user attributes
 */
from VDSroot import VDSmodUsrAttributes;
from NDmacro import ACreturn_foot;
from ACcpx   import ACfind_temp_obj;

#include "ndmacros.h"

IGRstat VDobjSetUserTextAttr(TGRobj_env *a_objOE, TGRid *a_objID, IGRchar *name, IGRchar *value)
{
  VDASSERT_FN("VDobjSetUserTextAttr");

  IGRstat retFlag = 0;
  IGRstat sts,msg;
  IGRchar buf[128];

  TGRobj_env objOE;
  TACrg_coll attr;

  TGRid collID1;
  TGRid collID2;

  IGRint msgx;

  /* Pull object */
  objOE.obj_id.objid = NULL_OBJID;
  if (a_objOE) objOE = *a_objOE;
  if (a_objID)
  {
    objOE.obj_id = *a_objID;
    VDobjResetOE(&objOE);
  }
  if (objOE.obj_id.objid == NULL_OBJID) goto wrapup;

  /* Prepare the attribute */
  if (value == NULL) goto wrapup;
  if ( name == NULL) goto wrapup;
  if (*name == 0)    goto wrapup;

  strcpy(attr.desc.value.att_txt,value);
  strcpy(attr.name,name);
  attr.desc.type = AC_ATTRIB_TEXT;

  /* This is the foot */
  collID1.osnum = objOE.obj_id.osnum;
  collID1.objid = NULL_OBJID;
  sts = om$send(msg = message NDmacro.
                ACreturn_foot(&msg,"dyn_attr",&collID1,NULL,NULL),
                senderid = NULL_OBJID,
		targetid = objOE.obj_id.objid,
		targetos = objOE.obj_id.osnum);

  if (!(sts & msg & 1)) collID1.objid = NULL_OBJID;

  /* And this is the parent */
  collID2.osnum = objOE.obj_id.osnum;
  collID2.objid = NULL_OBJID;
  sts = om$send(msg = message ACcpx.
                ACfind_temp_obj(&msgx,"userpara",&collID2),
                senderid = NULL_OBJID,
		targetid = objOE.obj_id.objid,
		targetos = objOE.obj_id.osnum);

  if (!(sts & msgx & 1)) collID2.objid = NULL_OBJID;

  if ((collID1.objid != NULL_OBJID) &&
      (collID2.objid != NULL_OBJID))
  {
    /* Update directly if attribute exists */
    sts = VDcollGetTextAttr(&collID2, name, buf);
    if (sts & 1)
    {
      VDcollSetTextAttr(&collID2,name,value);
      VDcollSetTextAttr(&collID1,name,value);

      retFlag = 1;

      om$change_tag_version(osnum = objOE.obj_id.osnum,
                            objid = objOE.obj_id.objid);

      goto wrapup;
    }
  }

  /* Set it */
  sts = om$send(msg = message VDSroot.
                VDSmodUsrAttributes(&msg,1,&attr,&objOE.mod_env),
                senderid = NULL_OBJID,
                targetid = objOE.obj_id.objid,
                targetos = objOE.obj_id.osnum);
  if (!(sts & msg & 1)) goto wrapup;

  /* Force the tag ver to update */
  om$change_tag_version(osnum = objOE.obj_id.osnum,
                        objid = objOE.obj_id.objid);


  /* Done */
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Interface to the posting object info
 * All we really want is the type code back
 */ 
from ACdb_info import ACget_db_info;

IGRstat VDobjGetDbInfoType(TGRobj_env *a_objOE, TGRid *a_objID, IGRint *dbType)
{  
  VDASSERT_FN("VDobjGetDbInfoType");

  IGRstat retFlag = 0;

  IGRstat sts,msg;

  struct ACdb_info db_info;

  TGRobj_env objOE;

  /* Args */
  VDASSERTW(dbType); *dbType = 0;

  /* Pull object */
  objOE.obj_id.objid = NULL_OBJID;
  if (a_objOE) objOE = *a_objOE;
  if (a_objID)
  {
    objOE.obj_id = *a_objID;
    VDobjResetOE(&objOE);
  }
  if (objOE.obj_id.objid == NULL_OBJID) goto wrapup;

  /* Get it */
  sts = om$send(msg = message ACdb_info.
                ACget_db_info(&msg, &db_info),
                senderid = NULL_OBJID,
                targetid = objOE.obj_id.objid,
                targetos = objOE.obj_id.osnum);
  if (!(sts & msg & 1)) goto wrapup;

  *dbType = db_info.quantity;
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Never wrapped this before
 * Not a real VDctx routine yet as it only works on
 * actual isdp objects
 */
#include "VDtag.h"

IGRstat VDctxGetCompTagx(TGRid *objID, IGRchar *buf)
{
  VDASSERT_FN("VDctxGetCompTagx");
  
  IGRstat retFlag = 0;
  IGRchar fileName[80];
  
  TVDtag  tag;

  // Arg check
  VDASSERTW(objID && objID->objid != NULL_OBJID);
  VDASSERTW(buf); *buf = 0;

  // Use the file name
  VDosGetFileName(objID->osnum,fileName);
  VDASSERTW(*fileName);
  
  // Tag information
  VDtagGetInfo(NULL,objID,&tag,NULL);

  // Kee the file name
  sprintf(buf,":%s:%u:%u:%u:",fileName,objID->objid,tag.num,tag.ver);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Tag on the interface to the validate ppl
 */
IGRstat VDPaimRunValidatePPL(TGRid *objID, IGRchar *funcName, IGRchar *txt)
{
  IGRint        sts = 0;
  TGRid         pplID;
  IGRint        pplRet;
  Tret_struct	rsData;

  TGRobj_env    objOE;
 
  /* Arg Check */
  if (txt) *txt = 0;

  if (!funcName || *funcName == 0) goto wrapup;

  if (!objID || objID->objid == NULL_OBJID) goto wrapup; 

  /* Use objOE just to stay constant more or less */
  objOE.obj_id = *objID;
  VDobjResetOE(&objOE);

  /* The ppl does the work */
  vdppl$Load(name = "SirValidate", pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup; 
  
  vdppl$SetData(pplID = &pplID,
                name  = "OBJECT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)&(objOE.obj_id) );
 
  vdppl$SetData(pplID = &pplID,
                name  = "OBJECT_ENV",
                size  = sizeof(TGRmd_env),
                data  = (IGRchar*)&(objOE.mod_env) );
 
  /* run the ppl */
  vdppl$Run(pplID = &pplID, 
	    name  = funcName, 
	    ret   = &pplRet);
  
  /* get data */
  *rsData.var.text_st.text_string = 0;
  vdppl$GetData(pplID = &pplID,
                name  = "OBJECT_RS",
                size  = sizeof(Tret_struct),
                data  = (IGRchar*)&rsData);
 
  /* Check */
  if (*rsData.var.text_st.text_string == 0) goto wrapup;
  if (txt) strcpy(txt,rsData.var.text_st.text_string);

  /* success status set */
  sts = pplRet;
  
wrapup:
  return sts;
}

end implementation Root;
