class implementation Root;

#include "VDtypedef.h"
#include "VDdir.h"
#include "VDobj.h"

#include "VPpdf.h"

from GRgraphics import GRgetname;
from ACcpx      import find_macro;
from ACcpx_defn import ACgive_name;

extern GRclassid OPP_ACcpx_class_id;
extern GRclassid OPP_ACcpx_defn_class_id;
#if 0
/* ---------------------------------------
 * Write object id
 */
IGRstar VPpdfWriteObjID(TGRid *id) 
{
  IGRstat retFlag = 0;

  VPpdfWriteAttrInt(
    PDF_ATR_ISDP_OBJ_OSNUM,
    id->osnum
  );
  VPpdfWriteAttrInt(
    PDF_ATR_ISDP_OBJ_OBJID,
    id->objid
  );

  retFlag = 1;

  return retFlag;
}

/* ---------------------------------------
 * Write object class
 */
IGRstar VPpdfWriteObjClass(TGRid *id) 
{

  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar className[32];

  sts = om$get_classname(
    osnum = id->osnum,
    objid = id->objid,
    classname = className
  );
  if (!(sts & 1)) goto wrapup;

  VPpdfWriteAttrText(
    PDF_ATR_ISDP_OBJ_CLASS,
    className
  );

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Write object directory name
 */
IGRstar VPpdfWriteObjDirName(TGRid *id) 
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar objName[DI_PATH_MAX];

  *objName = 0;

  sts = di$untranslate(
    objname = objName,
    objid = id->objid,
    osnum = id->osnum
  );
  if (sts != DIR_S_SUCCESS) goto wrapup;
  if (*objName == 0)        goto wrapup;

  VPpdfWriteAttrText(
    PDF_ATR_ISDP_OBJ_NAME,
    objName
  );
  retFlag = 1;

wrapup:
  return retFlag;

}

/* ------------------------------------
 * Write object's name
 */
IGRstar VPpdfWriteObjName(TGRid *id) 
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRchar objName[DI_PATH_MAX];

  *objName = 0;

  sts = om$send(
    msg = message GRgraphics.GRgetname(&msg,objName),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum
  );

  if (!(sts & msg & 1)) {
    sts = VPpdfWriteObjDirName(id);
    if (sts & 1) retFlag = 1;
    goto wrapup;
  }

  if (*objName == 0) goto wrapup;

  VPpdfWriteAttrText(
    PDF_ATR_ISDP_OBJ_NAME,
    objName
  );
  retFlag = 1;

wrapup:
  return 1;
}

/* ------------------------------------
 * Write macro name
 */
IGRstar VPpdfWriteMacName(TGRid *id) 
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar *macName = NULL;

  TGRid macId;

  // Filter class
  sts = vdobj$IsAncestryValid(objID = id, superClassID = OPP_ACcpx_class_id);
  if (!(sts & 1)) goto wrapup;

  /* Get Macro Defn */
  sts = om$send(
    msg = message ACcpx.find_macro(&macId),
    senderid = NULL_OBJID,
    targetid = id->objid,
    targetos = id->osnum);

  if (!(sts & 1)) goto wrapup;

  sts = om$send(
    msg = message ACcpx_defn.ACgive_name(&macName),
    senderid = NULL_OBJID,
    targetid = macId.objid,
    targetos = macId.osnum);

  if (!(sts & 1)) goto wrapup;
  if (macName == NULL) return 1;

  VPpdfWriteAttrText(
    PDF_ATR_ISDP_MAC_NAME,
    macName
  );
  retFlag = 1;

wrapup:
  return retFlag;

}

/* ---------------------------------------------------
 * Beginning of an object
 */
IGRstar VPpdfWriteObjInfo(IGRint recType, TGRid *id) 
{

  VPpdfWriteHdr(
    recType,
    PDF_OBJ_DT,
    PDF_OBJ_LEN
  );

  VPpdfWriteObjID   (id);
  VPpdfWriteObjClass(id);
  VPpdfWriteMacName (id);
  VPpdfWriteObjName (id);

  return 1;
}
#endif

end implementation Root;
