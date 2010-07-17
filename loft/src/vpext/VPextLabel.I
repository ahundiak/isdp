class implementation VDbtBase;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDgeom.h"

#include "maoptsxfo.h"

#include "VPextInfo.h"

from ACrg_collect import ACget_named_attribute;
from GRcurve      import GRendpts;
from GRtext       import GRgettxattr;
from GR3dtext     import GRgenabsg;

#define vdsDEBUGx 1

static int traceFlag;

/* -----------------------------------------------------
 * Gets a single possible label
 */
IGRstar VPextGetPlateLabel(TVPextPlateInfo *plateInfo,
			   TGRobj_env      *plateOE, 
                           TGRid           *labelID)
{
  IGRstat retFlag = 0;
  IGRstat msg;
  
  TGRid      parentID;
  TGRobj_env labelOE;
  TGRobj_env  textOE;
  
  IGRchar macroName[64];
  IGRuchar *str = NULL;
  IGRshort len;
  
  struct IGRlbsys *lbs = NULL;
  
  TVPextLabelInfo label;
  TVPextEdgeInfo *edge;
  
  IGRdouble dist,distx;
  IGRint    i,distFlag;
  
  IGRlong   numPoles;

  FILE *labelTraceFile = VPextGetLabelTraceFile();
  
  // Init
  parentID.objid = NULL_OBJID;
  labelOE.obj_id.objid = NULL_OBJID;
  *macroName = 0;
  
  /* --------------------------------------------------------
   * Verify plate is the actual main parent
   */
  vdobj$GetParent(objID = labelID, idx = 0, parentID = &parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;
  if (parentID.objid != plateOE->obj_id.objid) goto wrapup;
  if (parentID.osnum != plateOE->obj_id.osnum) goto wrapup;

  // Get next label
  if (plateInfo->labels.cnt >= VP_EXT_INFO_MAX) {
    printf("Huge number of labels\n");
    goto wrapup;
  }

  // Init label
  memset(&label,0,sizeof(label));
  label.type = 1;
  
  /* --------------------------------------------------------
   * Hard code the label macro
   */
  vdobj$Get(objID = labelID, macName = macroName);
  if (strcmp(macroName,"label_loft")) goto wrapup;
  
  // Say hi
  if (traceFlag) {
    printf(">>> VPextGetPlateLabel\n");
    vdobj$Print(objID = labelID);
  }

  // Get the foot
  labelOE        = *plateOE;
  labelOE.obj_id = *labelID;

  vdobj$GetFoot(objOE    = &labelOE, 
		footName = "text", 
		footOE   = &textOE);

  if (traceFlag) {
    vdobj$Print(objOE = &textOE);
  }
  if (textOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Get the text
  len = 0;
  om$send(msg = message GRtext.GRgettxattr(&msg,
					   NULL,
					   &len,
					   &str),
	  senderid = NULL_OBJID,
	  targetid = textOE.obj_id.objid,
	  targetos = textOE.obj_id.osnum);
  
  if (str == NULL) {
    printf("Problem getting label text\n");
    goto wrapup;
  }

  // Damn thing is not null terminated!
  memcpy(label.text,str,len);
  *(label.text + len) = 0;

  if (traceFlag) {
    printf("Text '%s'\n",label.text);
  }

  // Need 3d location
  om$send(msg = message GR3dtext.GRgenabsg(&msg,
					   &textOE.mod_env.md_env.matrix_type,
					    textOE.mod_env.md_env.matrix,
					   (IGRchar**)&lbs),
	  senderid = NULL_OBJID,
	  targetid = textOE.obj_id.objid,
	  targetos = textOE.obj_id.osnum);
  
  if (lbs == NULL) {
    printf("Problem getting label location\n");
    goto wrapup;
  }
  label.org3D[0] = lbs->matrix[ 3];
  label.org3D[1] = lbs->matrix[ 7];
  label.org3D[2] = lbs->matrix[11];

  // Generate 2d origin
  numPoles = 1;
  MAoptsxform(&msg,&numPoles,
	      &plateInfo->srcSrfMat.matrix_type,
	       plateInfo->srcSrfMat.matrix,
	       label.org3D,
	       label.org2D);
    
  if (traceFlag) {
    printf("Origin %12.4f,%12.4f,%12.4f\n",
           label.org3D[0],
           label.org3D[1],
           label.org3D[2]);
  }
  
  // Cycle through each edge and find nearest edge
  distFlag = 0;
  dist  = 0.0;
  distx = 0.0;
  
  for(i = 0; i < plateInfo->edges.cnt; i++) {

    edge = &plateInfo->edges.info[i];
    VDgeomGetDisPtCv(label.org3D, edge->crv3D, &dist);

    if (distFlag == 0){
      distFlag = 1;
      distx = dist;
      label.index = 0;
    }
    else {
      if (dist < distx) {
	distx = dist;
	label.index = i;
      }
    }
  }
  
  // Xfer
  plateInfo->labels.info[plateInfo->labels.cnt] = label;
  plateInfo->labels.cnt++;
  
  if (labelTraceFile) {
    fprintf(labelTraceFile,"%s %s\n",plateInfo->desc,label.text);
  }
  
  // Done
  retFlag = 1;

  if (traceFlag) {
     printf("@@ VPextGetPlateLabel, %d\n",label.index);
  }

wrapup:
  if (str) free(str);
  if (lbs) free(lbs);
  
  return retFlag;
}

/* -----------------------------------------------------
 * Given a tree of plates, find all labels
 */
IGRstar VPextGetPlateLabels(TVPextPlateInfo *plateInfo)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint i,j;

  TGRobj_env plateOE;

  TVDvlaID labelVLA;
  TGRid    labelID;

  TVPextPlates *plates = &plateInfo->plates;
  
  // Init
  vdvla_id$Construct(vla = &labelVLA);
  
  // Process each plate in tree
  for(i = 0; i < plates->cnt; i++) {

    plateOE = plates->plateOEs[i];

    vdvla_id$Empty(vla = &labelVLA);

    vdchn$GetChildrenByClass(objOE     = &plateOE,
                             className = "ACconst",
                             vla       = &labelVLA);

    for(j = 0; 
        vdvla_id$GetAt(vla = &labelVLA, nth = j, objID = &labelID); 
        j++) {
      
      sts = VPextGetPlateLabel(plateInfo,&plateOE,&labelID);
    }
  }

  retFlag = 1;

  vdvla_id$Delete(vla = &labelVLA);
  
  return retFlag;
}

end implementation VDbtBase;




