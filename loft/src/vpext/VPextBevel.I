class implementation VDbtBase;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"

#include "VPextInfo.h"

from ACrg_collect import ACget_named_attribute;
from GRcurve      import GRendpts;

/* ---------------------------------------------------------------
 * Given a 3d curve, find any matching bevel
 */
IGRstar VPextGetBevelForEdge(TGRbsp_curve     *crv,
			     TVPextBevelInfos *bevels,
			     IGRint           *bevelInd)
{
  IGRstat retFlag = 0;
  IGRint  i;
  
  TVPextBevelInfo *bevel;
  IGRdouble dis0,dis1;

  // Arg check
  if (bevelInd == NULL) goto wrapup;
  *bevelInd = -1;
  
  // Cycle through
  for(i = 0; i < bevels->cnt; i++) {

    // get it
    bevel = &bevels->info[i];
    
    // Find distance of end points to the curve
    VDgeomGetDisPtCv(bevel->pt0,crv,&dis0);
    VDgeomGetDisPtCv(bevel->pt1,crv,&dis1);
    
    // For now, the first one that matches is it
    if ((dis0 < .01) && (dis1 < .01)) {
      *bevelInd = i;
      // printf("Bevel Found %u\n",bevel);
      
      return 1;
    }
    
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* -----------------------------------------------------
 * Gets a single bevel attribute
 */
IGRstar VPextGetBevelAttribute(TGRid     *bevelID, 
                               IGRchar   *a_name, 
                               IGRchar   *txt, 
                               IGRdouble *dbl)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRid colID; 
  TACrg_coll col;

  IGRchar name[40];
  IGRchar *p;
  
  // Init
  if (txt) *txt = 0;
  if (dbl) *dbl = 0.0;
  
  // Arg check
  if (name == NULL) goto wrapup;
  if ((bevelID == NULL) || (bevelID->objid == NULL_OBJID)) goto wrapup;

  // Get the collector
  vdchn$Get2(objID  = bevelID, 
             chnIDx = VDCHN_IDX_PARENT, 
             nth    = 2, 
             outID  = &colID);
  if (colID.objid == NULL_OBJID) goto wrapup;

  // name is case sensitive, lower is standard but edges use upper
  strcpy(name,a_name);
  for(p = name; *p; p++) {
    if ((*p >= 'a') && (*p <= 'z')) *p -= 32;
  }
  // Hack for stupid space
  if (!strcmp(name,"SPEC_NUMBER")) strcpy(name,"SPEC NUMBER");
  
  // Ask for the attribute
  memset(&col,0,sizeof(col));
  strcpy(col.name,name);

  sts = om$send(msg = message 
          ACrg_collect.ACget_named_attribute(&msg,&col),
          senderid = NULL_OBJID,
          targetid = colID.objid,
          targetos = colID.osnum);
  if (!(sts & msg & 1)) goto wrapup;

  // Extract value
  switch(col.desc.type) {
	   
  case AC_ATTRIB_DOUBLE:
    if (txt) sprintf(txt,"%f",col.desc.value.att_exp);
    if (dbl) *dbl = col.desc.value.att_exp;
    break;
    
  case AC_ATTRIB_TEXT: 
    if (txt)  strcpy(txt,col.desc.value.att_txt);
    if (dbl) *dbl = atof(col.desc.value.att_txt);

    // printf("%s '%s'\n",name,col.desc.value.att_txt);
    
    break;
    
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Gets a single possible bevel
 */
IGRstar VPextGetPlateBevel(TVPextPlateInfo *plateInfo,
			   TGRobj_env      *plateOE, 
                           TGRid           *bevelID,
                           TVPextBevelInfo *info)
{
  IGRstat retFlag = 0;
  IGRstat msg;
  IGRchar *p;
  
  TGRid parentID;

  IGRdouble lb,lo;

  FILE *bevelTraceFile = VPextGetBevelTraceFile();
  
  IGRchar stockx[32];
  IGRchar gapx  [32];
  IGRchar thicknessx[32];
  
  // Say hi
  // vdobj$Print(objID = bevelID);

  // Init
  memset(info,0,sizeof(TVPextBevelInfo));
  *stockx = 0;
  *gapx   = 0;
  *thicknessx = 0;
  
  /* --------------------------------------------------------
   * Verify plate is the actual main parent and not connected
   * somehow as the second parent
   * Somtimes, they are out to get you
   */
  vdobj$GetParent(objID = bevelID, idx = 0, parentID = &parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;
  if (parentID.objid != plateOE->obj_id.objid) goto wrapup;
  if (parentID.osnum != plateOE->obj_id.osnum) goto wrapup;
  
  // Xfer stuff
  info->bevelOE = *plateOE;

  info->bevelOE.obj_id = *bevelID;

  // No way of knowing matrix for sure, assume it's the same as the plate
  info->bevelOE.mod_env.md_id.osnum = bevelID->osnum;
  ex$get_modid(
    mod_osnum =  bevelID->osnum, 
    mod_id    = &info->bevelOE.mod_env.md_id.objid
  );

  // Get the spec and stock
  VPextGetBevelAttribute(bevelID, "process",     info->process, NULL);
  VPextGetBevelAttribute(bevelID, "spec_number", info->spec,    NULL);
  VPextGetBevelAttribute(bevelID, "allowance",   NULL,       &info->stock);
  VPextGetBevelAttribute(bevelID, "V",           NULL,       &info->gap);
  VPextGetBevelAttribute(bevelID, "LB",          NULL,       &lb);
  VPextGetBevelAttribute(bevelID, "LO",          NULL,       &lo);

  // Upper case the spec and process
  for(p = info->spec; *p; p++) {
    if ((*p >= 'a') && (*p <= 'z')) *p -= 32;
  }

  for(p = info->process; *p; p++) {
    if ((*p >= 'a') && (*p <= 'z')) *p -= 32;
  }
   
  // Process and spec are often the same value???

  // See if edge will have to be adjusted
  if (info->stock > .01) info->hasStock = 1;
  if (info->gap   > .01) info->hasGap   = 1;
  
  if (info->hasGap) {
    info->adjust = -1.0 * (info->gap * 0.5);
    info->hasAdjust = 1;

    sprintf(gapx,"%8.3f",info->gap);
  }

  if (info->hasStock) {
    info->adjust = info->stock;  // Intentionally override gap
    info->hasAdjust = 1;
    info->hasGap    = 0;

    sprintf(stockx,"%8.3f",info->stock);
  }
    
  if ((lb > 0.01) || (lo > .01)) {
    printf("Bevel %s %.3f %.3f\n",info->spec,lb,lo);
  }
  
  if ((strstr(plateInfo->desc,"sh.c_pas1"))  && (strlen(info->spec) == 4)) {
    info->hasThickness = 1;
    info->thickness = 22.0;
    sprintf(thicknessx,"%8.3f",info->thickness);
  }
  if ((strstr(plateInfo->desc,"dIB.c_p1s1")) && (strlen(info->spec) == 4)) {
    info->hasThickness = 1;
    info->thickness = 18.0;
    sprintf(thicknessx,"%8.3f",info->thickness);
  }
  
  // Only the the plate should have X or Y at the end of the bevel
  if ((strlen(info->spec) == 4) && (info->hasThickness == 0)) 
  {
    *(info->spec+3) = 0;
  }
  
  if (bevelTraceFile) {
    fprintf(bevelTraceFile,"%s %-6s %8s %8s %8s\n",
	    plateInfo->desc,info->spec,stockx,gapx,thicknessx);
  }
  
  // printf("Bevel %s %s\n",info->spec,info->adjust); 
 
  // Get it's graphic foot
  vdobj$GetFoot(objOE    = &info->bevelOE,
		footName = "edge_3d",
		footOE   = &info->footOE);

  if (info->footOE.obj_id.objid == NULL_OBJID) goto wrapup;
  //vdobj$Print(objOE = &info->footOE);
  
  // Get end points
  om$send(msg = message
	  GRcurve.GRendpts(&msg,
			   &info->footOE.mod_env.md_env.matrix_type,
			    info->footOE.mod_env.md_env.matrix,
			    info->pt0,info->pt1),
	  senderid = NULL_OBJID,
	  targetid = info->footOE.obj_id.objid,
	  targetos = info->footOE.obj_id.osnum);
  
  // Done
  retFlag = 1;

wrapup:

  return retFlag;
}

/* -----------------------------------------------------
 * Given a tree of plates, find all bevels
 * Call them bevels to avoid confusing with edges
 */
IGRstar VPextGetPlateBevels(TVPextPlateInfo *plateInfo)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint i,j;

  TVPextPlates     *plates = &plateInfo->plates;
  TVPextBevelInfos *bevels = &plateInfo->bevels;

  TGRobj_env plateOE;

  TVDvlaID bevelVLA;
  TGRid    bevelID;
  
  // Init
  vdvla_id$Construct(vla = &bevelVLA);
  
  // Process each plate in tree
  for(i = 0; i < plates->cnt; i++) {

    plateOE = plates->plateOEs[i];

    vdvla_id$Empty(vla = &bevelVLA);

    vdchn$GetChildrenByClass(objOE     = &plateOE,
                             className = "VSedge3Datt",
                             vla       = &bevelVLA);

    for(j = 0; 
        vdvla_id$GetAt(vla = &bevelVLA, nth = j, objID = &bevelID); 
        j++) {

      // vdobj$Print(objID = &bevelID);
      
      sts = VPextGetPlateBevel(plateInfo,
			       &plateOE,
                               &bevelID,
                               &bevels->info[bevels->cnt]);

      if (sts & 1) {
        if (bevels->cnt < VP_EXT_INFO_MAX) bevels->cnt++;
        else {
          vdobj$Print(objOE = &plateOE);
          printf("Huge number of bevels %s\n",bevels->cnt);
          return 0;
        }
      }
    }
  }

  retFlag = 1;

  return retFlag;
}

end implementation VDbtBase;




