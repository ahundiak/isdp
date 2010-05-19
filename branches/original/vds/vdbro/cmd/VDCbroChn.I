/* $Id: VDCbroChn.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbro/cmd/VDCbroChn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCbroChn.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/25  14:27:54  pinnacle
# ah
#
# Revision 1.1  1997/10/29  17:22:28  pinnacle
# ah creation
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 *      11/25/97  ah      VDmaster.h changes
 ***************************************************************************/

class implementation VDCbro;

#include "VDmaster.h"
#include "VDmsg.h"

#include "VDbro.h"
#include "VDCbro.h"

/* -----------------------------------------------------
 * List channel
 */
IGRstat VDCbroListChnOne(
  TGRid        *id, 
  GRclassid     classId,
  IGRboolean    expandFlag, 
  IGRint        chnIndex,
  VDbroFrmInfo *frmInfo
)
{
  IGRstat sts;

  IGRchar desc[1024];
  IGRchar work[1024];

  IGRint i;

  OMuint  chnCount,chnSize;

  OM_S_OBJECT_LINKAGE  *chnLink;
  OM_S_CHANSELECT       chnSelect;

  OM_S_CHANNUM chnNum;
  IGRchar      chnName[OM_K_MAXCHANNAME_LEN];

  TGRid        chnId;

  VDbroObjInfo objInfo;

  /* Get channel */
  chnNum.classid = classId;
  chnNum.number  = chnIndex;

  sts = om$get_channel_name(
    channum  = chnNum, 
    channame = chnName
  );
  if (!(sts & 1)) return 0;

  /* Indenting */
  *desc = 0;
  for(i = 0; i < frmInfo->indent; i++) { strcat(desc," "); }

  /* Expansion Symbol */
  if (expandFlag) strcat(desc,"+");
  else            strcat(desc,"-");

  /* Object Id */
  sprintf(work,"CHN %s",chnName);
  strcat (desc,work);

  FIfld_insert_blank_row(frmInfo->form,VDBRO_FRM_L_OBJ,frmInfo->row);
  FIfld_set_text        (frmInfo->form,VDBRO_FRM_L_OBJ,frmInfo->row,0,desc,FALSE);
  frmInfo->row++;

  /* See if need to list kids */
  if (!expandFlag) return 1;

  /* Get List of objects on channel */
  sts = om$make_chanselect(
    channum = chnNum, 
    p_chanselect = &chnSelect
  );
  if (!(sts & 1)) return 1;

  chnCount = 0;
  sts  = om$get_channel_count(
    osnum = id->osnum,
    objid = id->objid,
    p_chanselect = &chnSelect,
    count = &chnCount
  );
  if (!(sts & 1)) return 0;

  if (chnCount <= 0) return 1;

  chnSize = chnCount * sizeof(OM_S_OBJECT_LINKAGE);
  chnLink = NULL;
  chnLink = (OM_S_OBJECT_LINKAGE*)om$malloc(size = chnSize);

  if (chnLink == NULL) return 1;

  sts  = om$get_channel_objects(
    osnum = id->osnum,
    objid = id->objid,
    p_chanselect = &chnSelect,
    list  =  chnLink,
    size  =  chnSize,
    count = &chnCount);

  if (!(sts & 1)) return 1;

  frmInfo->indent += 2;
  for(i = 0; i < chnCount; i++) {
    chnId.osnum =  chnLink[i].osnum,
    chnId.objid =  chnLink[i].S_objid,

    VDbroGetObjInfo(&chnId,&objInfo);
    objInfo.frmInfo = frmInfo;
    VDCbroSetObjForm(&objInfo,0);

  }
  frmInfo->indent -= 2;

  om$dealloc(ptr = chnLink);

  return 1;
}

/* -----------------------------------------------------
 * List channel objects
 */
IGRstat VDCbroListChn(
  TGRid        *id,  
  IGRboolean    expandFlag,
  VDbroFrmInfo *frmInfo
)
{
  IGRstat sts;
  IGRint  chnIndex,i;

  GRclassid classIdList[256];
  GRclassid classId;

  /* Generate list of class id's */
  sts = om$get_classid(
    osnum = id->osnum,
    objid = id->objid,
    p_classid = &classId);
  if (!(sts & 1)) return 0;

  memset(classIdList,0,sizeof(classIdList));
  VDbroGenClassIdList(classId,classIdList);

  /* Process each channel for each class */
  for(i = 0; classIdList[i]; i++) {
  
    for(chnIndex = 0; 
        VDCbroListChnOne(id,classIdList[i],expandFlag,chnIndex,frmInfo); 
        chnIndex++);
  }

  return 1;
}

/* -----------------------------------------------------
 * Recursive Routine to Generate List Parent Classes
 */
IGRstat VDbroGenClassIdList(GRclassid classId, GRclassid *classIdList)
{
  IGRstat sts;
  IGRint  i;
  OMuint  parentNum = 0;

  GRclassid parentList[16];

  /* See if class already processed */
  if (classId == 0) return 1;
  for(i = 0; (classIdList[i]) && (classIdList[i] != classId); i++);
  if (classIdList[i] == classId) return 1;
  classIdList[i] = classId;

  /* Go through parents */
  sts = om$get_all_parents(
    classid     =  classId, 
    parentlist  = &parentList[0],
    size        =  sizeof(parentList),
    count       = &parentNum);
  if (!(sts & 1)) return 1;

  for(i = 0; i < parentNum; i++) {
    VDbroGenClassIdList(parentList[i],classIdList);
  }

  return 1;
}

end implementation VDCbro;
