 /* $Id: VDct1HvacTree.c,v 1.9 2002/05/16 21:22:24 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1HvacTree.c
 *
 * Description: HVAC Engineering Tree
 *
 * Dependencies:
 *
 * Revision History:
 *      
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/14/01  js      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDobj2.h" 
#include "VDrisc.h"
#include "VDos.h"
#include "VDassert.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"

#include "VDct1Ris.h"
#include "VDct1Part.h"
#include "VDct1Attrs.h"
#include "VDct1Forms.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/tree/VDct1HvacTree.c");

#define MY_TREE VDCT1_TREE_TYPE_HVAC_TREE

#define HVAC_EQPT_TYPE_BACS   1
#define HVAC_EQPT_TYPE_RTAP   2
#define HVAC_EQPT_TYPE_CTAP   3

#define HVAC_FLANGE_SHAPE_RECT 1
#define HVAC_FLANGE_SHAPE_CIRC 2
#define HVAC_FLANGE_SHAPE_FO   3

static IGRstat isBacsOrTap(TGRobj_env  *modelOE,
	                   IGRint      *type)
{
    VDASSERT_FN("isBacsOrTap");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar eqp_family[80];
    IGRint  str_len;
    IGRchar *p;
    IGRchar buf[80];

    VDASSERTW(modelOE->obj_id.objid != NULL_OBJID);
    VDASSERTW(type);

    *eqp_family = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    VDobjGetTxtAtr(modelOE,NULL,"eqp_family",eqp_family);
    if (*eqp_family == 0) goto wrapup;

    retFlag = 1;

    // last 4 chars determine whether it is a rtap,ctap,or bacs.
    str_len = strlen(eqp_family);
    p = eqp_family;
    p = p + (str_len - 4);

    strcpy(buf,p);

    // bolted access
    if (!strcmp(buf,"bacs")) {
	*type = HVAC_EQPT_TYPE_BACS;
	goto wrapup;
    }

    // rectangular tap
    if (!strcmp(buf,"rtap")) {
	*type = HVAC_EQPT_TYPE_RTAP;
	goto wrapup;
    }

    // circular tap
    if (!strcmp(buf,"ctap")) {
	*type = HVAC_EQPT_TYPE_CTAP;
	goto wrapup;
    }
    
    // done
    *type = 0;
    retFlag = 0;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

#if 0
/* --------------------------------------------------
 * Compute nodeName for some nodes
 * Need to compute the node name for equipment type tapouts
 * and for bolted access covers and stuff like that.
 */
static IGRstat makeNodeName(TVDct1JD *parentJD,TVDctBaseInfo *baseInfo)
{
  VDASSERT_FN("makeNodeName");
  
  IGRstat        retFlag = 0;
  TVDct1JD       parentClassJD;
  IGRstat        sts;
  
    //args check
  VDASSERTW(parentJD);
  VDASSERTW(baseInfo);  

  // tapouts


  // bolted access covers
  

  // spools


  // run the default afterwards
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  sts = _RTCJDC(&parentClassJD)->makeNodeName(parentJD,baseInfo);
  if (!(sts & 1)) goto wrapup;  

  sts  = VDjt1CleanName(parentJD,baseInfo->nodeName);

  // success
  retFlag = 1;
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",_RTCJDBC(parentJD),fn,retFlag);
  }
  return retFlag;
}
#endif

/* ----------------------------------------------
 * Get the vent detail type, and number from the model object
 * **/
static IGRstat getVentDetailNumber(TGRobj_env  *modelOE,
                                   IGRchar     *detailType,
				   IGRchar     *detailNo)
{
  VDASSERT_FN("getVentDetailNumber");

  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar detail[80];
  IGRchar buf  [80];
  IGRchar *p,*a,*d;
  IGRint  detLen;

  // Arg check
  VDASSERTW(modelOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(detailType); *detailType = 0;
  VDASSERTW(detailNo);   *detailNo   = 0;

  // init
  *detail = 0;
  detLen  = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // get the detail_no attribute
  VDobjGetTxtAtr(modelOE,NULL,"detail_no", detail);
  if (*detail == 0) goto wrapup;

  // split detail into detailType and detailNo
  // The last 3 characters is the number, the remaining at the beginning is the type

  detLen = strlen(detail);
  VDASSERTW(detLen > 3);
  memcpy(buf,detail,(detLen - 3));
  *(buf + (detLen - 3)) = 0;

  // verify that buf has a A or a D in it, otherwise, we may have a detail_no
  // attribute that does not follow convention
  a = strchr(buf,'A');
  d = strchr(buf,'D');
  if ( !a && !d ) goto wrapup;
  strcpy(detailType,buf);

  p = detail + (detLen - 3);
  strcpy(detailNo,p);
  
  // done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}
  
/* -----------------------------------------------
 * Auto Generate Nodes may need to get new parent
 * for active modelOE.
 */
static IGRstat getParentForModelObject(TVDct1JD    *parentNodeJD,
				       TGRobj_env  *modelOE)
{
  VDASSERT_FN("getParentForModelObject");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD newParentJD;
  TVDct1JD parentJD;
  TVDct1JD rootJD;
    
  IGRchar  nodeType  [80];
  IGRchar  nodeName  [80];
  IGRchar  attrVD    [80];
  IGRchar  attrDetail[80];
  IGRchar  attrUnit  [80];
  IGRchar  next_vd   [80];
  IGRint   nextVD;
  
  
  //Arg Check
  VDASSERTW(parentNodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  // init
  parentJD.id.objid    = NULL_OBJID;
  newParentJD.id.objid = NULL_OBJID;
  
  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
  // first need VD and VD number attributes
  sts = getVentDetailNumber(modelOE, attrVD, attrDetail);
  if (!(sts & 1)) goto wrapup;
  
  // find a group node with that name
  _RTCJDB(parentNodeJD)->
    findNodeByTypeName(parentNodeJD,0,VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
		       VDCT1_ENG_NODE_TYPE_GROUP,attrVD,&parentJD);

  // if one is not found create it under top node
  if (parentJD.id.objid == NULL_OBJID) {
    
    // get the root node
    _RTCJDB(parentNodeJD)->getRootForNode(parentNodeJD,&rootJD);
    if (rootJD.id.objid == NULL_OBJID) goto wrapup;
    
    // create a group node
    _RTCJDB(&rootJD)->
      createNode(&rootJD,VDCT1_ENG_NODE_TYPE_GROUP,attrVD,&parentJD);
    if (parentJD.id.objid == NULL_OBJID) goto wrapup;

    // set the comm_code attribute for the node
    _RTCJDB(&parentJD)->setAttr(&parentJD,VDCT1_ATTR_COMM_CODE,attrVD);
    
  }
  
  /* ----------------------------------------------------
   * if we are this far, then parentJD is equal to a group with
   * the Vent Detail type attribute as the name.
   * Now, we need an EA2 for the VD
   */
 
  // build the EA2 nodename
  _RTCJDB(parentNodeJD)->getAttr(parentNodeJD,VDCT1_ATTR_UNIT,attrUnit);
  if (*attrUnit == 0) goto wrapup;
  sprintf(nodeName,"LP%s%s07.%s%s",VDCT1_DEFAULT_HVAC_LABOR_CODE,attrUnit,attrVD,attrDetail);
  
  // find a EA2 node with the VD number
  _RTCJDB(&parentJD)->
    findNodeByTypeName(&parentJD,0,VDCT1_FIND_NODE_OPT_NODE_DOWN,
		       VDCT1_ENG_NODE_TYPE_ENGASSY2,nodeName,&newParentJD);
  
  // if one is not found, create it under the pal group
  if (newParentJD.id.objid == NULL_OBJID) {
    
    // create it
    _RTCJDB(&parentJD)->
      createNode(&parentJD,VDCT1_ENG_NODE_TYPE_ENGASSY2,nodeName,&newParentJD);
    if (newParentJD.id.objid == NULL_OBJID) goto wrapup;

    // we have created a node, now update the next_vd attribute
    _RTCJDB(parentNodeJD)->getAttr(parentNodeJD,VDCT1_ATTR_NEXT_VD,next_vd);
    if ( atoi(attrDetail) > atoi(next_vd) ) {
	nextVD = atoi(attrDetail) + 1;
	sprintf(next_vd,"%d",nextVD);
	_RTCJDB(parentNodeJD)->setAttr(parentNodeJD,VDCT1_ATTR_NEXT_VD,next_vd);
    }

  }
  
  // the new parent is now the Engr Assy 2 Detail no.
  // done
  *parentNodeJD = newParentJD;
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}
  


/* -------------------------------------------------
 * Get current value of next_vd, update it to plus one
 * **/
static void getNextVD(TVDct1JD  *nodeJD,
                      IGRchar   *next_vd)
{
  VDASSERT_FN("getNextVD");

  TVDct1JD   rootJD;

  IGRint     nextVD;
  IGRchar    buf[128];

  // Arg Check
  VDASSERTW(nodeJD && nodeJD->cl);
  VDASSERTW(next_vd); *next_vd = 0;

  *buf = 0;

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
  // get the root node
  VDjt1GetRootForNode(nodeJD, &rootJD);
  if (rootJD.id.objid == NULL_OBJID) goto wrapup;

  // get the current attribute value
  VDjt1GetAttr(&rootJD,VDCT1_ATTR_NEXT_VD,buf);
  if (*buf == 0) goto wrapup;

  // set next_vd
  nextVD = atoi(buf);
  sprintf(next_vd,"%03d",nextVD);
  VDASSERTW(*next_vd != 0);

  // increase the value of next vd on root
  nextVD++;
  sprintf(buf,"%d",nextVD);
  VDjt1SetAttr(&rootJD,VDCT1_ATTR_NEXT_VD,buf);

  // done
wrapup:
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  return;
}

  
/* --------------------------------------------------
 * Compute nodeName for ENGASSY2
 * Puts the results in baseInfo->nodeName
 */
static IGRstat computeEngAssy2Name(TVDct1JD *parentJD,TVDctBaseInfo *baseInfo)
{
    VDASSERT_FN("computeEngAssy2Name");
    IGRstat  retFlag = 0;
    IGRstat  sts;

    IGRchar   next_vd[128],comm_code[80];
    IGRchar   unit[128];

    // Init
    *next_vd   = 0;
    *comm_code = 0;
    *unit      = 0;

    // Say Hi
    if (traceFlag) {
	printf(">>> %s %s\n",ffn(),fn);
    }

    //args check
    VDASSERTW(parentJD && parentJD->cl);
    VDASSERTW(baseInfo); 

    // get a valid comCode
    VDjt1GetValidCommCode(parentJD,baseInfo,comm_code);
    if (*comm_code == 0) goto wrapup;

    VDjt1GetAttr(parentJD,VDCT1_ATTR_UNIT,unit);
    if (*unit == 0) goto wrapup;; 

    getNextVD(parentJD,next_vd);
    if (*next_vd == 0) goto wrapup;;

    sprintf(baseInfo->nodeName,"LP%s%s%s.%s%s",
	    VDCT1_DEFAULT_HVAC_LABOR_CODE,unit,"07",comm_code,next_vd);

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) {
	printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    }
    return retFlag;
}


/* ---------------------------------------------------------
 * Check to see if attribute can be updated
 */
static IGRstat isAttrUpdateValid(TVDct1JD  *nodeJD,
				 IGRchar   *attrName)
{
  VDASSERT_FN("isAttrUpdateValid");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD  parentClassJD;
  
  VDASSERTW(attrName != NULL);
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeJD->cl != NULL);
  
  // say hi
  if (traceFlag) printf (">>> %s %s %s\n",ffn(),fn,attrName);
  
  // do the regular one first
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  sts = _RTCJDC(&parentClassJD)->
    isAttrUpdateValid(nodeJD,attrName);
  if (!(sts & 1)) goto wrapup;

  // computed attributes
  if (!strcmp(attrName,VDCT1_ATTR_NEXT_VD))  goto wrapup;
  
  // done, all other attributes can be updated
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* ------------------------------------------------------------
 * recomputer for move and copy nodes
 */
static IGRstat computeMoveCopyNode(TVDct1JD *parentJD,
				   TVDct1JD *nodeJD)
{
  VDASSERT_FN("computeMoveCopyNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDctBaseInfo  baseInfo;
  
  VDASSERTW(parentJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // pull down parent attributes
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_AV_HULL);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_CONT_HULL);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_NUM);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_REV);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_LABOR_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_UNIT);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ZONE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_TREE_NUM);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMM_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMMODITY);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COST_CODE);

  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


static IGRstat createHvacImpMatlNodes(TVDct1JD   *nodeJD,
	                              TGRobj_env *modelOE,
				      IGRchar    *fast_assy,
				      IGRdouble   fast_qty)
{
    VDASSERT_FN("createHvacImpMatlNodes");
    IGRstat retFlag = 0;
    IGRstat sts;

    TVDct1JD   parentJD;
    TVDct1JD   newJD;
    TVDrisInfo ris;
    IGRint     i,j;
    IGRchar    sql[1024];
    IGRdouble  qty;
    IGRchar    attrQty[80];

    // init
    VDrisInitInfo( &ris );

    // arg check
    VDASSERTW(nodeJD->id.objid != NULL_OBJID);
    VDASSERTW(modelOE->obj_id.objid != NULL_OBJID);
    VDASSERTW(*fast_assy != 0);
    VDASSERTW(fast_qty   >  0);
    
    // say hi
    if (traceFlag) printf(">>> %s %s <%s>\n",ffn(),fn,fast_assy);
    
    // get parent node
    _RTCJDB(nodeJD)->getTreeParent(nodeJD,&parentJD);
    if (parentJD.id.objid == NULL_OBJID) goto wrapup;

    // get the assy members
    sprintf(sql,
	    "Select unit_meas, assy_qty, assy_part from tm_hvac_im_ps where %s='%s';",
	    "fast_assy",fast_assy);
    
    VDrisQuery( &ris, sql );
    if (ris.rows < 1) goto wrapup;

    // create the nodes
    for (i = 0; i < ris.rows; i++) {

	j = i * ris.cols;

	// create one node
	_RTCJDB(&parentJD)->createNode(&parentJD,VDCT1_ENG_NODE_TYPE_PART,ris.buf[j+2],&newJD);
	if (newJD.id.objid == NULL_OBJID) goto wrapup;
	
	// set the unit_measure attribute
	_RTCJDB(&newJD)->setAttr(&newJD,VDCT1_ATTR_UNIT_MEASURE,ris.buf[j]);

	// set the qty attribute
	qty = atof(ris.buf[j+1]) * fast_qty;
	sprintf(attrQty,"%.3f",qty);
	_RTCJDB(&newJD)->setAttr(&newJD,VDCT1_ATTR_QTY,attrQty);

    }  // end of nodes


    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


static IGRstat computeNoBoltsForFlange(IGRdouble width,
	                               IGRdouble depth,
				       IGRdouble cflg_thk,
				       IGRdouble bolt_spacing,
				       IGRint    shape,
				       IGRdouble *qty)
{
    VDASSERT_FN("computeNoBoltsForFlange");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRdouble fw1,fd1,bolt_off,perim;
    IGRint    iwnb,idnb,wnb,dnb,no_bolts;


    VDASSERTW(width > 0);
    VDASSERTW(cflg_thk > 0);
    VDASSERTW(bolt_spacing > 0);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    if (cflg_thk < 38.1) bolt_off = 9.525;
    else                 bolt_off = 17.4625;

    switch(shape) {

      case HVAC_FLANGE_SHAPE_RECT:
	  VDASSERTW(depth > 0);

	  // fw and fd are the flange width and depth for placing the bolts
	  fw1 = width - (2 * bolt_off);
	  fd1 = depth - (2 * bolt_off);
	  //printf("### fw1 <%.3f> fd1 <%.3f>\n",fw1,fd1);

	  iwnb = (fw1/bolt_spacing);
	  idnb = (fd1/bolt_spacing);
	  //printf("### iwnb <%d> idnb <%d>\n",iwnb,idnb);

	  wnb = iwnb + 2;

	  if ( (fd1 - (idnb*bolt_spacing)) < (bolt_spacing/2) ) dnb = idnb + 2;
	  else                                                  dnb = idnb + 3;

	  //printf("### wnb <%d> dnb <%d>\n",wnb,dnb);
	  *qty = (wnb + dnb) * 2;

	  VDASSERTW(*qty > 0);

	  // done
	  retFlag = 1;
	  goto wrapup;

      case HVAC_FLANGE_SHAPE_CIRC:

	  perim = 3.14156 * (width - bolt_off);
	  no_bolts = 4;
	  while (perim/no_bolts > bolt_spacing) no_bolts++;
	  
	  *qty = no_bolts;
	  VDASSERTW(*qty > 0);
	  
	  retFlag = 1;
	  goto wrapup;

      case HVAC_FLANGE_SHAPE_FO:
	  VDASSERTW(depth > 0);

	  perim = 3.14156 * (depth - bolt_off);
	  no_bolts = 4;
	  while (perim/no_bolts > bolt_spacing) no_bolts++;

	  no_bolts = no_bolts + 2;

	  fw1 = width - (2 * bolt_off);
	  iwnb = (fw1/bolt_spacing);

	  *qty = no_bolts + (2 * iwnb);
	  VDASSERTW(*qty > 0);

	  retFlag = 1;
	  goto wrapup;

      default:
	  retFlag = 0;
	  goto wrapup;

    } // end of switch

    // done, better not get to here

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

    
static IGRstat getAssyNoQtyForFlange(TVDct1JD   *nodeJD,
	                             TGRobj_env *modelOE,
				     IGRdouble  *qty)
{
    VDASSERT_FN("getAssyNoQtyForFlange");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRdouble  width,depth,cflg_thk,duct_thk,shape_code,bolt_spacing;
    IGRdouble  f_width,f_depth;
    IGRchar    spec_name[80],duct_matl[80];
    IGRint     shape;

    VDASSERTW(nodeJD->id.objid != NULL_OBJID);
    VDASSERTW(modelOE->obj_id.objid != NULL_OBJID);

    width        = 0.0;
    depth        = 0.0;
    cflg_thk     = 0.0;
    duct_thk     = 0.0;
    shape_code   = 0.0;
    bolt_spacing = 0.0;
    f_width      = 0.0;
    f_depth      = 0.0;
    shape        = 0;
    *spec_name   = 0;
    *duct_matl   = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // grab some attributes
    //printf("### grab some attributes\n");
    sts = VDobjGetDblAtr(modelOE,NULL,"width_1",&width);
    //printf("### width_1 <%.3f>\n",width);

    sts = VDobjGetDblAtr(modelOE,NULL,"depth_1",&depth);
    //printf("### depth_1 <%.3f>\n",depth);

    sts = VDobjGetDblAtr(modelOE,NULL,"cflg_thk",&cflg_thk);
    //printf("### cflg_thk <%.3f>\n",cflg_thk);

    sts = VDobjGetDblAtr(modelOE,NULL,"duct_thk",&duct_thk);
    //printf("### duct_thk <%.3f>\n",duct_thk);

    sts = VDobjGetDblAtr(modelOE,NULL,"shape_code",&shape_code);
    //printf("### shape_code <%.3f>\n",shape_code);

    sts = VDobjGetTxtAtr(modelOE,NULL,"spec_name",spec_name);
    //printf("### spec_name <%s>\n",spec_name);

    sts = VDobjGetTxtAtr(modelOE,NULL,"duct_matl",duct_matl);
    //printf("### duct_matl <%s>\n",duct_matl);

    // set flange width and depth
    f_width = width + (2*duct_thk) + (2*cflg_thk);
    f_depth = depth + (2*duct_thk) + (2*cflg_thk);

    // bolt spacing depends on duct_matl or spec_name
    if ( (!strcmp(duct_matl,"11GA")) ||
	 (!strcmp(duct_matl,"14GA")) ||
	 (!strcmp(duct_matl,"0.080THK")) ||
	 (!strcmp(spec_name,"SST TUBING")) ) bolt_spacing = 60;
    else                                     bolt_spacing = 75;

    // shape
    if      ( (shape_code - 1.0) == 0.0 ) shape = HVAC_FLANGE_SHAPE_FO;
    else if ( (shape_code - 2.0) == 0.0 ) shape = HVAC_FLANGE_SHAPE_CIRC;
    else                                  shape = HVAC_FLANGE_SHAPE_RECT;

    
    // finally, get the qty
    sts = computeNoBoltsForFlange(f_width,f_depth,cflg_thk,bolt_spacing,shape,qty);
    if (!(sts & 1)) goto wrapup;

    VDASSERTW(*qty > 0);
    *qty = *qty/2;
    //printf("### qty of fast = <%f>\n",*qty);

    // done
    retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

static IGRstat getAssyNoQtyForBacs(TVDct1JD   *nodeJD,
	                           TGRobj_env *modelOE,
				   IGRdouble  *qty)
{
    VDASSERT_FN("getAssyNoQtyForBacs");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRdouble acs_w1,acs_w2,acs_length;
    IGRdouble width,depth,hyp,leg;

    VDASSERTW(nodeJD->id.objid != NULL_OBJID);
    VDASSERTW(modelOE->obj_id.objid != NULL_OBJID);
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    
    // get the dimensional attributes for the bacs
    VDobjGetDblAtr(modelOE,NULL,"acs_w1",&acs_w1);
    VDobjGetDblAtr(modelOE,NULL,"acs_w2",&acs_w2);
    VDobjGetDblAtr(modelOE,NULL,"acs_length",&acs_length);

    width = (acs_w1 + acs_w2) / 2;

    leg   = abs(acs_w1 - acs_w2);
    hyp   = sqrt( (leg*leg) + (acs_length * acs_length) );
    depth = (acs_length + hyp) / 2;

    VDASSERTW(width > 0);
    VDASSERTW(depth > 0);

    //printf("### width <%f> depth <%f>\n",width,depth);

    sts = computeNoBoltsForFlange(width,depth,25.4,75,HVAC_FLANGE_SHAPE_RECT,qty);
    if (!(sts & 1)) goto wrapup;

    VDASSERTW(*qty > 0);
    //printf("### qty of fast = <%f>\n",*qty);

    // done
    retFlag = 1;


wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
    

    
static IGRstat getAssyNoQty(TVDct1JD   *nodeJD,
			    TGRobj_env *modelOE,
			    IGRdouble  *fast_qty)
{
    VDASSERT_FN("getAssyNoQty");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRdouble qty = 0;

    VDASSERTW(nodeJD->id.objid != NULL_OBJID);
    VDASSERTW(modelOE->obj_id.objid != NULL_OBJID);
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // check if equipment, then it also must be a bacs
    sts = VDobjIsAncestryValid(modelOE,NULL,0,"VDequipment");
    if (sts & 1) {

	sts = getAssyNoQtyForBacs(nodeJD,modelOE,&qty);
	if (sts & 1) {
	    *fast_qty = qty;
	    retFlag = 1;
	    goto wrapup;
	}

    }

    // if hvac, then it must have some sort of flange attributes
    sts = VDobjIsAncestryValid(modelOE,NULL,0,"VRHvac");
    if (sts & 1) {
	
	sts = getAssyNoQtyForFlange(nodeJD,modelOE,&qty);
	if (sts & 1) {
	    *fast_qty = qty;
	    retFlag = 1;
	    goto wrapup;
	}

    }

    // done
    retFlag = 0;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


static IGRstat getImpliedMatlAssyNo(TVDct1JD   *nodeJD,
	                            TGRobj_env *modelOE,
				    IGRchar    *fast_assy)
{
    VDASSERT_FN("getImpliedMatlAssyNo");
    IGRstat retFlag = 0;
    IGRstat sts;

    TVDrisInfo ris;
    IGRchar    sql[1024];

    IGRchar  eqp_family[80];
    IGRchar  eqp_partno[80];
    IGRchar  comp_code[80];
    IGRchar  cage_mino[80];
    IGRint   type = 0;

    // init
    VDrisInitInfo( &ris );
    *eqp_family = 0;
    *eqp_partno = 0;
    *comp_code  = 0;
    *cage_mino  = 0;
    *sql        = 0;
    
    // arg check
    VDASSERTW(nodeJD->id.objid != NULL_OBJID);
    VDASSERTW(modelOE->obj_id.objid != NULL_OBJID);
    VDASSERTW(fast_assy); *fast_assy = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // if equip, check that it is a bacs
    sts = VDobjIsAncestryValid(modelOE,NULL,0,"VDequipment");
    if (sts & 1) {
	
	// and if bolted access or tap.
	if (!isBacsOrTap(modelOE,&type)) goto wrapup;
	if (type != HVAC_EQPT_TYPE_BACS) goto wrapup;

	// it is a bacs, get eqp_family and eqp_partno
	VDobjGetTxtAtr(modelOE,NULL,"eqp_family",eqp_family);
	VDASSERTW(*eqp_family != 0);
	VDobjGetTxtAtr(modelOE,NULL,"eqp_partno",eqp_partno);
	VDASSERTW(*eqp_partno != 0);

	// build the required sql
	sprintf(sql,
		"Select fast_assy from tm_hvac_imp_matl where %s='%s' and %s='%s';",
		"eqp_family",eqp_family,"eqp_partno",eqp_partno);

    } // done for equip

    // if hvac
    sts = VDobjIsAncestryValid(modelOE,NULL,0,"VRHvac");
    if (sts & 1) {

	// get comp_code, cage_mino
	VDobjGetTxtAtr(modelOE,NULL,"comp_code",comp_code);
	VDASSERTW(*comp_code != 0);
	VDobjGetTxtAtr(modelOE,NULL,"mat_id_key",cage_mino);
	VDASSERTW(*cage_mino != 0);

	// build the sql
	sprintf(sql,
		"Select fast_assy from tm_hvac_imp_matl where %s='%s' and %s='%s';",
		"comp_code",comp_code,"cage_mino",cage_mino);

    }  // done for hvac

    // should have an sql now
    if (*sql == 0) goto wrapup;

    // query for it, it should be unique, if not, take the first
    VDrisQuery( &ris, sql );
    if (ris.rows < 1) goto wrapup;

    // set fast_assy
    strcpy(fast_assy,ris.buf[0]);
    VDASSERTW(*fast_assy != 0);

    // done
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


/* ---------------------------------------------------------------
 * get weight and qty for Rtap
 * **/
static IGRstat getWeightAndQtyForRtap(TVDct1JD   *nodeJD,
				      TGRobj_env *modelOE,
				      IGRchar    *attrWeight,
				      IGRchar    *attrQty)
{
    VDASSERT_FN("getWeightAndQtyForRtap");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar unit_wt[80];
    IGRdouble width_3,
              depth_3,
	      branch_len,
	      strlen_3;
	    
    IGRdouble qty;

    // init
    *unit_wt = 0;
    width_3   = 0.0;
    depth_3   = 0.0;
    branch_len   = 0.0;
    strlen_3   = 0.0;
    qty      = 0.0;

    // arg check
    VDASSERTW(nodeJD->id.objid != NULL_OBJID);
    VDASSERTW(modelOE->obj_id.objid != NULL_OBJID);
    VDASSERTW(attrWeight); *attrWeight = 0;
    VDASSERTW(attrQty);    *attrQty    = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // get the weight attribute from the node
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_WEIGHT,unit_wt);

    // get the dimensional attributes off of the bacs
    VDobjGetDblAtr(modelOE,NULL,"width_3",&width_3);
    VDobjGetDblAtr(modelOE,NULL,"depth_3",&depth_3);
    VDobjGetDblAtr(modelOE,NULL,"branch_len",&branch_len);
    VDobjGetDblAtr(modelOE,NULL,"strlen_3",&strlen_3);

    // calculate the qty, in mm^2
    qty = ((2*width_3) + (2*depth_3)) * (branch_len + strlen_3);
    VDASSERTW(qty > 0);

    // convert to m^2
    qty = qty * 0.000001;

    // set the attribute values
    sprintf(attrQty,"%.3f",qty);
    VDASSERTW(*attrQty != 0);

   
    if (*unit_wt != 0) {
	sprintf(attrWeight,"%.3f",(qty * atof(unit_wt)));
	VDASSERTW(*attrWeight != 0);
    }

    // done
    retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
  

/* ---------------------------------------------------------------
 * get weight and qty for Ctap
 * **/
static IGRstat getWeightAndQtyForCtap(TVDct1JD   *nodeJD,
				      TGRobj_env *modelOE,
				      IGRchar    *attrWeight,
				      IGRchar    *attrQty)
{
    VDASSERT_FN("getWeightAndQtyForCtap");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar unit_wt[80];
    IGRdouble width_3,
              branch_len,
	      strlen_3;
	    
    IGRdouble qty;

    // init
    *unit_wt = 0;
    width_3   = 0.0;
    branch_len   = 0.0;
    strlen_3   = 0.0;
    qty      = 0.0;

    // arg check
    VDASSERTW(nodeJD->id.objid != NULL_OBJID);
    VDASSERTW(modelOE->obj_id.objid != NULL_OBJID);
    VDASSERTW(attrWeight); *attrWeight = 0;
    VDASSERTW(attrQty);    *attrQty    = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // get the weight attribute from the node
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_WEIGHT,unit_wt);

    // get the dimensional attributes off of the bacs
    VDobjGetDblAtr(modelOE,NULL,"width_3",&width_3);
    VDobjGetDblAtr(modelOE,NULL,"branch_len",&branch_len);
    VDobjGetDblAtr(modelOE,NULL,"strlen_3",&strlen_3);

    // calculate the qty, in mm^2
    qty = (width_3 * 3.14156) * (branch_len + strlen_3);
    VDASSERTW(qty > 0);

    // convert to m^2
    qty = qty * 0.000001;

    // set the attribute values
    sprintf(attrQty,"%.3f",qty);
    VDASSERTW(*attrQty != 0);

   
    if (*unit_wt != 0) {
	sprintf(attrWeight,"%.3f",(qty * atof(unit_wt)));
	VDASSERTW(*attrWeight != 0);
    }

    // done
    retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
  
/* ---------------------------------------------------------------
 * get weight and qty for BACS
 * **/
static IGRstat getWeightAndQtyForBacs(TVDct1JD   *nodeJD,
				      TGRobj_env *modelOE,
				      IGRchar    *attrWeight,
				      IGRchar    *attrQty)
{
    VDASSERT_FN("getWeightAndQtyForBacs");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar unit_wt[80];
    IGRdouble acs_w1,
              acs_w2,
	      acs_lg;
	    
    IGRdouble qty;

    // init
    *unit_wt = 0;
    acs_w1   = 0.0;
    acs_w2   = 0.0;
    acs_lg   = 0.0;
    qty      = 0.0;

    // arg check
    VDASSERTW(nodeJD->id.objid != NULL_OBJID);
    VDASSERTW(modelOE->obj_id.objid != NULL_OBJID);
    VDASSERTW(attrWeight); *attrWeight = 0;
    VDASSERTW(attrQty);    *attrQty    = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // get the weight attribute from the node
    _RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_WEIGHT,unit_wt);

    // get the dimensional attributes off of the bacs
    VDobjGetDblAtr(modelOE,NULL,"acs_w1",&acs_w1);
    VDobjGetDblAtr(modelOE,NULL,"acs_w2",&acs_w2);
    VDobjGetDblAtr(modelOE,NULL,"acs_length",&acs_lg);

    // calculate the qty, in mm^2
    qty = acs_lg * ((acs_w1 + acs_w2) / 2);
    VDASSERTW(qty > 0);

    // convert to m^2
    qty = qty * 0.000001;

    // set the attribute values
    sprintf(attrQty,"%.3f",qty);
    VDASSERTW(*attrQty != 0);

   
    if (*unit_wt != 0) {
	sprintf(attrWeight,"%.3f",(qty * atof(unit_wt)));
	VDASSERTW(*attrWeight != 0);
    }

    // done
    retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
    
/* -----------------------------------------------------
 * Helper function for computeNodeModel
 * computes the implied materials stuff
 * **/
static void computeHvacImpliedMaterials(TVDct1JD   *nodeJD,
	                                TGRobj_env *modelOE)
{
    VDASSERT_FN("computeHvacImpliedMaterials");
    IGRstat sts;

    IGRchar    fast_assy[80];
    IGRdouble  fast_qty = 0;
    

    // init
    *fast_assy = 0;

    // arg check
    VDASSERTW(nodeJD->id.objid != NULL_OBJID);
    VDASSERTW(modelOE->obj_id.objid != NULL_OBJID);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get implied materials assembly number
    sts = getImpliedMatlAssyNo(nodeJD,modelOE,fast_assy);
    if (!(sts & 1)) goto wrapup;
    VDASSERTW(*fast_assy != 0);
    //printf("### fast_assy = <%s>\n",fast_assy);

    /********
     * Because we have a fast_assy number, we know that the object modelOE, must either be
     * bolted access cover, or a component with a flange in it, such as FLANGE, SPOOL, HSPL.
     * So, in getting the qty, we know that there will exist certain flange attributes that
     * can help us to determine the number of fastener assemblies.
     * *******/
    // get the qty for the assembly number
    sts = getAssyNoQty(nodeJD,modelOE,&fast_qty);
    if (!(sts & 1)) goto wrapup;
    VDASSERTW(fast_qty > 0);
    //printf("### fast_qty = <%f>\n",fast_qty);


    // create implied material nodes under same parent as this one
    sts = createHvacImpMatlNodes(nodeJD,modelOE,fast_assy,fast_qty);
    


    // done

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}
    
/* -----------------------------------------------------------------
 * helper function for computeNodeModel
 * **/
static void setAttrWeightAndQty(TVDct1JD   *nodeJD,
				TGRobj_env *modelOE)
{
    VDASSERT_FN("setAttrWeightAndQty");
    IGRstat sts;

    IGRchar surfArea[80];
    IGRchar unitWeight[80];
    IGRchar attrWeight[80];
    IGRchar cage[80];
    IGRchar attrQty[80];

    IGRdouble weight, qty;

    // init
    *cage = 0;
    *surfArea = 0;
    *unitWeight = 0;
    *attrWeight = 0;
    weight = 0.0;
    qty = 0.0;

    // arg check
    VDASSERTW(nodeJD->id.objid != NULL_OBJID);
    VDASSERTW(modelOE->obj_id.objid != NULL_OBJID);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // if HVAC
    sts = VDobjIsAncestryValid(modelOE,NULL,0,"VRHvac");
    if (sts & 1) {

	// and, if not inline eqpt
	VDobjGetTxtAtr(modelOE,NULL,"cage",cage);
	if (*cage != 0) goto wrapup;

	// get the surface are attribute
	VDobjGetTxtAtr(modelOE,NULL,VDCT1_ATTR_SURF_AREA,surfArea);
	if (*surfArea == 0) goto wrapup;

	// convert to meters squared
	qty = atof(surfArea) * 0.000001;

	sprintf(attrQty,"%.3f",qty);

	// total weight = surface area * weight
	// weight has already been set on Node from Engtree.
	// get the weight attribute
	_RTCJDB(nodeJD)->getAttr(nodeJD,VDCT1_ATTR_WEIGHT,unitWeight);
	if (*unitWeight != 0) {

	    // unitWeight is in KG/M2
	    weight = qty * atof(unitWeight);
	    VDASSERTW(weight > 0);

	    // set the attrWeight
	    sprintf(attrWeight,"%.3f",weight);
	}
    
    }  // end of HVAC

    // if HVAC special equipment
    sts = VDobjIsAncestryValid(modelOE,NULL,0,"VDequipment");
    if (sts & 1) {

	IGRint type = 0;

	// and if bolted access or tap.
	if (!isBacsOrTap(modelOE,&type)) goto wrapup;

	switch (type) {

	  case HVAC_EQPT_TYPE_BACS:
	      sts = getWeightAndQtyForBacs(nodeJD,modelOE,attrWeight,attrQty);
	      if (!(sts & 1)) goto wrapup;
	      break;

	  case HVAC_EQPT_TYPE_RTAP:
	      sts = getWeightAndQtyForRtap(nodeJD,modelOE,attrWeight,attrQty);
	      if (!(sts & 1)) goto wrapup;
	      break;

	  case HVAC_EQPT_TYPE_CTAP:
	      sts = getWeightAndQtyForCtap(nodeJD,modelOE,attrWeight,attrQty);
	      if (!(sts & 1)) goto wrapup;
	      break;

	  default:
	      goto wrapup;

	} // end of switch

    }  // end of equipment

    // finally, set the attributes on the node
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_WEIGHT,attrWeight);
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_QTY,   attrQty);
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_UNIT_MEASURE,"M2");


    // done

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}


/* -----------------------------------------------------------------
 * Helper function for computeNode
 * **/
static IGRstat computeNodeModel(TVDct1JD   *nodeJD,
				TGRobj_env *modelOE,
				IGRint     imp_matl)
{
    VDASSERT_FN("computeNodeModel");

    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar wet_wt[80];

    *wet_wt = 0;

    // arg check
    VDASSERTW(nodeJD->id.objid != NULL_OBJID);
    VDASSERTW(modelOE->obj_id.objid != NULL_OBJID);
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
    // set the weight and qty attributes for modelOE nodes
    setAttrWeightAndQty(nodeJD,modelOE);

    // do the implied materials stuff for hvac nodes
    if (imp_matl) computeHvacImpliedMaterials(nodeJD,modelOE);
    
    // wet wt
    VDct1GetMiscStaticAttrValue(nodeJD,modelOE,"wet_wt",wet_wt);
    if (*wet_wt != 0) {
	_RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_WET_WEIGHT,wet_wt);
    }

    // done
    retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ------------------------------------------------------------------
 * generic recomputer, used to compute any misc attributes
 */
static IGRstat computeNode(TVDct1JD *nodeJD)
{
  VDASSERT_FN("computeNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD       parentClassJD;
  TGRobj_env     modelOE;
  
  IGRchar  op[3];
  
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // init
  modelOE.obj_id.objid = NULL_OBJID;
  
    
  // Call the engtree compute node first
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->computeNode(nodeJD);

  // copy attributes from model to node
  _RTCJDB(nodeJD)->getModelObject(nodeJD,&modelOE);
  if (modelOE.obj_id.objid != NULL_OBJID) {
    _RTCJDB(nodeJD)->copyAttributesFromModelToNode(nodeJD,&modelOE);

    computeNodeModel(nodeJD, &modelOE, 1);

  }
  
  // pre-expand the modelobject
  if (modelOE.obj_id.objid != NULL_OBJID) {
  
    strcpy(op," ");
    _RTCJDB(nodeJD)->preExpandContractNode(nodeJD,op);
 
  }

  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


static IGRstat reComputeNode(TVDct1JD *nodeJD)
{
  VDASSERT_FN("reComputeNode");

  IGRstat        retFlag = 0;
  TVDct1JD       childJD,childJDx,parentClassJD;
  TVDctBaseInfo  baseInfo;
  TGRobj_env     modelOE;
  IGRint         i;
  IGRchar        buf[128];
  IGRchar        op[3];
  IGRstat        sts;

  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
    
  // Call the engtree compute node first
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->computeNode(nodeJD);

  // does it have a modelOE
  modelOE.obj_id.objid = NULL_OBJID;
  VDjt1GetModelObject(nodeJD,&modelOE);

  if (modelOE.obj_id.objid == NULL_OBJID) {
      // check model_id attribute to see if one did exist
      strcpy(buf,"");
      VDjt1GetAttr(nodeJD,VDCT1_ATTR_MODEL_ID,buf);

      if (strcmp(buf,"")) {
	      // it did have a model_object attached, delete it
	      sts = VDjt1GetBaseInfo(nodeJD,&baseInfo);
	      if (sts) 
		  printf("Mark Deleted Node <%s %s>\n",
			  baseInfo.nodeType,baseInfo.nodeName);

	      _RTCJDB(nodeJD)->markNodeAsDeleted(nodeJD);
      }
  }

  if (modelOE.obj_id.objid != NULL_OBJID) {
    _RTCJDB(nodeJD)->copyAttributesFromModelToNode(nodeJD,&modelOE);

    computeNodeModel(nodeJD, &modelOE, 0);

  }
  
  // pre-expand the modelobject
  if (modelOE.obj_id.objid != NULL_OBJID) {
  
    strcpy(op," ");
    _RTCJDB(nodeJD)->preExpandContractNode(nodeJD,op);
 
  }
  
  // do the kids
  for (i = 0; _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJD); i++) {
      _RTCJDB(&childJD)->reComputeNode(&childJD);

      // if the child was deleted, we need to continue with the other children.
      _RTCJDB(nodeJD)->getTreeChild(nodeJD,i,&childJDx);
      if (childJD.id.objid != childJDx.id.objid) i--;
  }

  // done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}



/* --------------------------------------------------------------------
 * Copies attributes from model to node
 * This needs to call a ppl
 */
static IGRstat copyAttributesFromModelToNode(TVDct1JD   *nodeJD,
					     TGRobj_env *modelOE)
{
  VDASSERT_FN("copyAttributesFromModelToNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar buf[256],tmp[256];
  
  TVDfld fld;

  IGRchar nodeAttrName  [128];
  IGRchar modelAttrName [128];
      
  TVDctBaseInfo baseInfo;

  TGRid    objID;
  TVDct1JD parentClassJD,parentJD;
  
  
  // Arg check
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);
  VDASSERTW((modelOE->obj_id.objid != 0) && (modelOE->obj_id.objid != NULL_OBJID));

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // init (makes little sense)
  objID.objid = NULL_OBJID;
  if (nodeJD)  objID = nodeJD->id;
  if (modelOE) objID = modelOE->obj_id;
  if (objID.objid == NULL_OBJID) goto wrapup;

  VDobjGetClassName(modelOE,NULL,buf);
  if (traceFlag) printf("### className = %s\n",buf);
  
  // Call the ancestor first to get unit/zone/compt_number
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->copyAttributesFromModelToNode(nodeJD,modelOE);

  // For equipment
  sts = VDobjIsAncestryValid(modelOE,NULL,0,"VDequipment");
  if (sts) {
      
      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_NOMENCLATURE,
	                  modelOE,VDCT1_ATTR_NOMENCLATURE);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_PART_DESCR,
	                  modelOE,VDCT1_ISDP_ATTR_EQP_DESC);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_PART_REMARKS,
	                  modelOE,VDCT1_ISDP_ATTR_EQP_NUMBER);
#if 0

      // special components built as equipment, tapouts and bolted access covers
      // Access Covers
      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_TRANS_LEN,
	                  modelOE,"acs_length");

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_WIDTH_1,
	                  modelOE,"acs_w1");

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_WIDTH_2,
	                  modelOE,"acs_w2");

      // tap outs
      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_TRANS_LEN,
	                  modelOE,"branch_len");

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_WIDTH_3,
	                  modelOE,VDCT1_ATTR_WIDTH_3);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_DEPTH_3,
	                  modelOE,VDCT1_ATTR_DEPTH_3);
#endif
  }
  
  
  // For HVAC stuff
  sts = VDobjIsAncestryValid(modelOE,NULL,0,"VRHvac");
  if (sts) {

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_COMP_CODE,
	                  modelOE,VDCT1_ATTR_COMP_CODE);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_SPEC_NAME,
	                  modelOE,VDCT1_ATTR_SPEC_NAME);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_DUCT_MATL,
	                  modelOE,VDCT1_ATTR_DUCT_MATL);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_SEQ_NUMBER,
	                  modelOE,VDCT1_ATTR_SEQ_NUMBER);
#if 0
      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_SURF_AREA,
	                  modelOE,VDCT1_ATTR_SURF_AREA);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_DUCT_LENGTH,
	                  modelOE,VDCT1_ATTR_DUCT_LENGTH);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_BEND_SWEEP,
	                  modelOE,VDCT1_ATTR_BEND_SWEEP);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_THROAT_RAD,
	                  modelOE,VDCT1_ATTR_THROAT_RAD);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_TRANS_LEN,
	                  modelOE,VDCT1_ATTR_TRANS_LEN);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_CORNER_RAD,
	                  modelOE,VDCT1_ATTR_CORNER_RAD);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_WIDTH_1,
	                  modelOE,VDCT1_ATTR_WIDTH_1);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_WIDTH_2,
	                  modelOE,VDCT1_ATTR_WIDTH_2);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_WIDTH_3,
	                  modelOE,VDCT1_ATTR_WIDTH_3);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_WIDTH_4,
	                  modelOE,VDCT1_ATTR_WIDTH_4);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_DEPTH_1,
	                  modelOE,VDCT1_ATTR_DEPTH_1);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_DEPTH_2,
	                  modelOE,VDCT1_ATTR_DEPTH_2);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_DEPTH_3,
	                  modelOE,VDCT1_ATTR_DEPTH_3);

      _RTCJDB(nodeJD)->copyAttributeFromModelToNode(
	                  nodeJD, VDCT1_ATTR_DEPTH_4,
	                  modelOE,VDCT1_ATTR_DEPTH_4);
#endif
  }
 
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}


/* -----------------------------------------------
 * Returns value for form gadget
 * Every time we get a new parent,
 * this will get called.
 */
static IGRstat getGadgetText(TVDct1JD *nodeJD,
			     IGRchar  *formName,
			     IGRint    gadget,
			     IGRint    nth,
			     IGRchar  *txt)
{
  VDASSERT_FN("getGadgetText");
  
  IGRstat       retFlag = 0;
  TVDctBaseInfo baseInfo;
  TVDct1JD parentClassJD;
  
  // Arg check
  if (txt == NULL) goto wrapup;
  *txt = 0;
  if (formName == NULL) goto wrapup;
  
  // Need baseInfo
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

  // Tree Form
  if (!strcmp(formName,VDCT_FORM_TREE_F_NAME)) {
    
    switch(gadget) {
      case VDCT_FORM_TREE_G_DISPLAY:

	retFlag = 1;
	
	switch(nth) {
	  case 0: strcpy(txt,"1 ALL     Nodes");  break;
	  case 1: strcpy(txt,"2 Active  Nodes");  break;
	  case 2: strcpy(txt,"3 Latest  Frozen"); break;
	  case 3: strcpy(txt,"4 Deleted NODES");  break;
	  default: retFlag = 0;
	}
	break;	
    }
    goto wrapup;
  }
  
  // Node Form
  if (!strcmp(formName,VDCT_FORM_NODE_F_NAME)) {
    
    switch(gadget) {
    case VDCT_FORM_NODE_G_DOIT:
      
      retFlag = 1;

      // HVAC_TREE (Tree) options
      if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_HVACTREE)) {
	switch(nth) {
	  case 0: strcpy(txt,"1 Review    Node");          break;
	  case 1: strcpy(txt,"2 Create    Node");          break;
	  case 2: strcpy(txt,"4 Generate  Model Node(s)"); break;
	  case 3: strcpy(txt,"7 ReCompute Node");          break;
	  case 4: strcpy(txt,"D Delete    Node");          break;
	  case 5: strcpy(txt,"R Rename    Node");          break;
	  case 6: strcpy(txt,"M Move      Node");          break;
	  case 7: strcpy(txt,"S ReCompute STDASSY(s)");    break;
	  case 8: strcpy(txt,"X Del Marked Nodes(s)");     break;
	  default: retFlag = 0;
	}
      }
    
      // GROUP, ENGR_ASSY[6], ENGR_ASSY[2], ASSY_TYPE[2], ASSY_TYPE[6]  options
      else if(!strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_GROUP)    ||
	      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6) ||
	      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2) ||
	      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2)    ||
	      !strcmp(baseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY6) ) {
	switch(nth) {
	case  0: strcpy(txt,"1 Review  Node");          break;
	case  1: strcpy(txt,"2 Create  Node");          break;
	case  2: strcpy(txt,"3 Create     Model Node"); break;
	case  3: strcpy(txt,"5 Connect    Model Node"); break;
	case  4: strcpy(txt,"6 Disconnect Model Node"); break;
	case  5: strcpy(txt,"7 ReCompute Node");        break;
	case  6: strcpy(txt,"C Convert   Node");        break;
	case  7: strcpy(txt,"D Delete    Node");        break;
	case  8: strcpy(txt,"R Rename    Node");        break;
	case  9: strcpy(txt,"P Paste     Node(s)");     break;
	case 10: strcpy(txt,"M Move      Node");        break;
	case 11: strcpy(txt,"S ReCompute STDASSY(s)");  break;
	case 12: strcpy(txt,"X Del Marked Nodes(s)");     break;
	default: retFlag = 0;
	}
      }

      // ALL OTHER  options
      else {
	switch(nth) {
	case 0: strcpy(txt,"1 Review  Node");      break;
	default: retFlag = 0;
	}
      }
      
      break;	
           
    }
    goto wrapup;
  }

  // Try ancestor
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  retFlag = _RTCJDC(&parentClassJD)->getGadgetText(nodeJD,formName,gadget,nth,txt);
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}


/* -----------------------------------------------------
 * Determine type of node to create duing copy operation
 *
 * I - copyJD copyBaseInfo              Node being copied
 * I - parentJD parentBaseInfo          Parent where node is to be copied
 *
 * O - info - Node Type to create
 *
 * This is really only for transformations, calling routine will
 * ensure that if this fails then a valid node type does exists
 */
static IGRstat getPasteNodeType(TVDct1JD          *parentJD, 
				TVDct1JD          *copyJD,
				TVDctNodeTypeInfo *info)
{
  VDASSERT_FN("getPasteNodeType");
  
  IGRstat          retFlag = 0;
  TVDctBaseInfo    parentBaseInfo;
  TVDctBaseInfo    copyBaseInfo;
  IGRstat          sts;
  
  TVDct1JD         parentClassJD;

  //Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  //Arg check
  VDASSERTW(&parentJD != NULL);
  VDASSERTW(&copyJD   != NULL);
  VDASSERTW(info);
    
  // Get base info of objects
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&parentBaseInfo);
  if (*parentBaseInfo.nodeType == 0) goto wrapup;
  
  _RTCJDB(copyJD)->getBaseInfo(copyJD,&copyBaseInfo);
  if (*copyBaseInfo.nodeType == 0) goto wrapup;

  if (traceFlag) {
    printf ("parentBaseInfo.nodeType = %s\n",parentBaseInfo.nodeType);
    printf ("copyBaseInfo.nodeType   = %s\n",copyBaseInfo.nodeType);
  }
  
  //Do it
  // STD_ASSY and STD_ASSY[2] convert to ASSY_TYPE[2]
  if (!strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY2) ||
      !strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY) ) {
    
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY2);
    goto wrapup;
  }
   
  // STD_PART and STD_PART[4] convert to PART
  if (!strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART) ||
      !strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART4) ) {
    
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PART);
    goto wrapup;
  }
   
  // STD_ASSY[6] converts to ASSY_TYPE[6]
  if (!strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY6)) {
    
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY6);
    goto wrapup;
  }

  // Everything else converts as is, send it up to production implementation
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDC(&parentClassJD)->getPasteNodeType(parentJD,copyJD,info);

  //Done
 
  
wrapup:
  if (traceFlag) printf("<<< %s %s [%s]\n",ffn(),fn,info->type);
  return 1;
}


/* --------------------------------------------------
 * Validate child type
 */
static IGRstat isChildTypeValid(TVDct1JD *parentJD,
				IGRchar  *childType)
{
  VDASSERT_FN("isChildTypeValid");

  IGRstat retFlag = 0;
  
  TVDctBaseInfo baseInfo;
  TVDctNodeType parentType;
  
  // Arg check
  VDASSERTW((parentJD->cl != NULL) && (parentJD->id.objid != NULL_OBJID));
  VDASSERTW(childType != NULL);

  // Need the parent info
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&baseInfo);
  strcpy(parentType,baseInfo.nodeType);
  if (*parentType == 0) goto wrapup;
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s %s %s %s\n",_RTCJDBC(parentJD),fn,parentType,childType);
  }
  
  // OK By default
  retFlag = 1;

  // HVAC_TREE can have GROUP
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_HVACTREE)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_GROUP))    goto wrapup;
  }
  
  // GROUP can have GROUP, ASSY2, ASSY6, ENGASSY2, ENGASSY6, or PART
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_GROUP)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_GROUP))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ENGASSY6)) goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY6))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))     goto wrapup;
    
  }
  
  // ENGASSY2 can have ASSY2 or PART
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_ENGASSY2)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))     goto wrapup;
  }
  
  // ENGASSY6 can have ENGASSY2, ASSY2, ASSY6 or PART 
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_ENGASSY6)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))    goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))     goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY6))    goto wrapup;
  }
  
  // ASSY2 can have ASSY2 or PART
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_ASSY2)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))     goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))    goto wrapup;
  }
  
  // ASSY6 can have ASSY2 or PART 
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_ASSY6)){
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_ASSY2))   goto wrapup;
    if(!strcmp(childType,VDCT1_ENG_NODE_TYPE_PART))    goto wrapup;
  }
  
  //PART nothing
  if(!strcmp( parentType,VDCT1_ENG_NODE_TYPE_PART)){
  }
  
  // Dont let anything be created manually
  retFlag = 0;
  
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",_RTCJDBC(parentJD),fn,retFlag);
  }

  return retFlag;
}



/* -------------------------------------------------
 * Create a node
 */
static IGRstat createNode(TVDct1JD *parentJD,
			  IGRchar  *nodeType, 
			  IGRchar  *nodeName,
			  TVDct1JD *nodeJD)
{ 
  VDASSERT_FN("createNode");
  
  IGRstat retFlag = 0;

  TVDctBaseInfo baseInfo;

  TVDct1JD   parentClassJD;
  TGRobj_env modelOE;

  IGRchar op[3];  

  TVDrisInfo ris;
  
  // Arg check
  VDASSERTW((parentJD->id.objid != NULL_OBJID) && (parentJD->cl != NULL));
  VDASSERTW(nodeType != NULL);
  VDASSERTW(nodeName != NULL);
  VDASSERTW(nodeJD);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s %s %s\n",
	   ffn(),_RTCJDBC(parentJD),fn,nodeType,nodeName);
  }
 
  //init 
  nodeJD->id.objid = NULL_OBJID;
  nodeJD->cl = parentJD->cl;
  
  // Use standard node create routine
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->createNode(parentJD,nodeType,nodeName,nodeJD);
  if (nodeJD->id.objid == NULL_OBJID) goto wrapup;

  // Init the date
  _RTCJDB(nodeJD)->computeDate(nodeJD,VDCT1_ATTR_ASSY_DATE);
  _RTCJDB(nodeJD)->computeDate(nodeJD,VDCT1_ATTR_PART_DATE);

  // Pull down some values and set them
  // GROUP, ENG_ASSY[2], ENG_ASSY[6], ASSY[2], ASSY[6], PART
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_AV_HULL);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_CONT_HULL);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_NUM);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_DWG_REV);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_LABOR_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_UNIT);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ZONE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMPARTMENT);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_TREE_NUM);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMM_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMMODITY);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COST_CODE);
  
  // compute
  VDjt1ComputeNode(nodeJD);


  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
  return retFlag;
}

/* -------------------------------------------------
 * Class filter
 */
static IGRstat getFilter(TVDct1JD       *nodeJD,
			 OM_S_CLASSLIST *classList)
{
  IGRstat retFlag = 0;
 
  if (classList == NULL) goto wrapup;
  VDomGetClassIdForClassName("VRHvac",     &classList->p_classes[0]);
  VDomGetClassIdForClassName("VDequipment",&classList->p_classes[1]);
  VDomGetClassIdForClassName("VSplate",    &classList->p_classes[2]);
  VDomGetClassIdForClassName("VSbeam",     &classList->p_classes[3]);
  classList->w_count = 4;

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Nth attribute of a given node
 */
static IGRstat getNodeAttrName(TVDct1JD *nodeJD,
			       IGRchar  *nodeType,
			       IGRint    nth,
			       IGRchar  *attrName)
{ 
  VDASSERT_FN("getNodeAttrName");
  
  IGRstat retFlag = 0;

  // Arg Check
  VDASSERTW(attrName != NULL);
  VDASSERTW(nodeType != NULL);
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s %s %s %2d\n",_RTCJDBC(nodeJD),fn,nodeType,nth);
  }
  
  // Init 
  *attrName = 0;
  retFlag = 1;
  
  // tree HVAC_TREE
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_HVACTREE)) {
    
    switch(nth) {
      case  0: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
      case  1: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_NUM_NEXT);     goto wrapup;
      case  3: strcpy(attrName,VDCT1_ATTR_NEXT_VD);      goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup;
      case  5: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
      case  6: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup;
      case  7: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
      case  8: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
      case  9: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
      case 10: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;
      case 11: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup;
    }
  }

  // GROUP
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_GROUP)) {

    switch(nth) {
      case  0: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
      case  1: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup;
      case  3: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup;
      case  5: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
      case  6: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
      case  7: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
      case  8: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
      case  9: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup; 
      case 10: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
      case 11: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;
      case 12: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup;
    }    
  }

  // ENG_ASSY[2],ENG_ASSY[6],ASSY_TYPE[2],ASSY_TYPE[6],PART
  if ( (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2)) ||
       (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6)) ||
       (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ASSY2)   ) ||
       (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_ASSY6)   )  ) {

    switch(nth) {
      case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup; 
      case  1: strcpy(attrName,VDCT1_ATTR_ASSY_REV);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_ASSY_DATE);    goto wrapup; 
      case  3: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
      case  5: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
      case  6: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
      case  7: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup; 
      case  8: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
      case  9: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
      case 10: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
      case 11: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
      case 12: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup;
      case 13: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
      case 14: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;
      case 15: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup;
      case 16: strcpy(attrName,VDCT1_ATTR_CAGE);         goto wrapup;
      case 17: strcpy(attrName,VDCT1_ATTR_MINO);         goto wrapup;
      case 18: strcpy(attrName,VDCT1_ATTR_ASSY_DESCR);   goto wrapup;
      case 19: strcpy(attrName,VDCT1_ATTR_ASSY_REMARKS); goto wrapup;
      case 20: strcpy(attrName,VDCT1_ATTR_WET_WEIGHT);   goto wrapup;
      case 21: strcpy(attrName,VDCT1_ATTR_WEIGHT);       goto wrapup;
      case 22: strcpy(attrName,VDCT1_ATTR_WEIGHT_UNITS); goto wrapup;
      case 23: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;  
      case 24: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;
      case 25: strcpy(attrName,VDCT1_ATTR_FIAN);         goto wrapup; 
      case 26: strcpy(attrName,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
      case 27: strcpy(attrName,VDCT1_ATTR_COATING);      goto wrapup; 
      case 28: strcpy(attrName,VDCT1_ATTR_MODEL_ID);     goto wrapup;
      case 29: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);   goto wrapup;
      case 30: strcpy(attrName,VDCT1_ATTR_PCT_MINO);     goto wrapup;

    }    
  }

  // PART
  if (!strcmp(nodeType,VDCT1_ENG_NODE_TYPE_PART))  {
    
    switch(nth) {
      case  0: strcpy(attrName,VDCT1_ATTR_FROZEN);       goto wrapup; 
      case  1: strcpy(attrName,VDCT1_ATTR_PART_REV);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_PART_DATE);    goto wrapup; 
      case  3: strcpy(attrName,VDCT1_ATTR_TREE_NUM);     goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_NODE_NUM);     goto wrapup;       
      case  5: strcpy(attrName,VDCT1_ATTR_AV_HULL);      goto wrapup; 
      case  6: strcpy(attrName,VDCT1_ATTR_CONT_HULL);    goto wrapup;
      case  7: strcpy(attrName,VDCT1_ATTR_ZONE);         goto wrapup; 
      case  8: strcpy(attrName,VDCT1_ATTR_UNIT);         goto wrapup;
      case  9: strcpy(attrName,VDCT1_ATTR_COMPARTMENT);  goto wrapup; 
      case 10: strcpy(attrName,VDCT1_ATTR_COM_CODE);     goto wrapup;
      case 11: strcpy(attrName,VDCT1_ATTR_COMMODITY);    goto wrapup;
      case 12: strcpy(attrName,VDCT1_ATTR_COST_CODE);    goto wrapup;
      case 13: strcpy(attrName,VDCT1_ATTR_DWG_NUM);      goto wrapup;
      case 14: strcpy(attrName,VDCT1_ATTR_DWG_REV);      goto wrapup;
      case 15: strcpy(attrName,VDCT1_ATTR_LABOR_CODE);   goto wrapup;
      case 16: strcpy(attrName,VDCT1_ATTR_CAGE);         goto wrapup;
      case 17: strcpy(attrName,VDCT1_ATTR_MINO);         goto wrapup;
      case 18: strcpy(attrName,VDCT1_ATTR_NOMENCLATURE); goto wrapup;
      case 19: strcpy(attrName,VDCT1_ATTR_PART_DESCR);   goto wrapup;
      case 20: strcpy(attrName,VDCT1_ATTR_PART_REMARKS); goto wrapup;
      case 21: strcpy(attrName,VDCT1_ATTR_WET_WEIGHT);   goto wrapup;
      case 22: strcpy(attrName,VDCT1_ATTR_WEIGHT);       goto wrapup;
      case 23: strcpy(attrName,VDCT1_ATTR_WEIGHT_UNITS); goto wrapup;
      case 24: strcpy(attrName,VDCT1_ATTR_QTY);          goto wrapup;  
      case 25: strcpy(attrName,VDCT1_ATTR_UNIT_MEASURE); goto wrapup;
      case 26: strcpy(attrName,VDCT1_ATTR_FIAN);         goto wrapup; 
      case 27: strcpy(attrName,VDCT1_ATTR_LINE_IDENT);   goto wrapup;   
      case 28: strcpy(attrName,VDCT1_ATTR_COATING);      goto wrapup;
      case 29: strcpy(attrName,VDCT1_ATTR_MODEL_ID);     goto wrapup;
      case 30: strcpy(attrName,VDCT1_ATTR_COPICS_NUM);   goto wrapup;
      case 31: strcpy(attrName,VDCT1_ATTR_PCT_MINO);     goto wrapup;
      case 32: strcpy(attrName,VDCT1_ATTR_COMP_CODE);    goto wrapup;
      case 33: strcpy(attrName,VDCT1_ATTR_SPEC_NAME);    goto wrapup;
      case 34: strcpy(attrName,VDCT1_ATTR_DUCT_MATL);    goto wrapup;
      case 35: strcpy(attrName,VDCT1_ATTR_SEQ_NUMBER);   goto wrapup;
      //case 35: strcpy(attrName,VDCT1_ATTR_SURF_AREA);    goto wrapup;
      //case 36: strcpy(attrName,VDCT1_ATTR_DUCT_LENGTH);  goto wrapup;
      //case 37: strcpy(attrName,VDCT1_ATTR_BEND_SWEEP);   goto wrapup;
      //case 38: strcpy(attrName,VDCT1_ATTR_THROAT_RAD);   goto wrapup;
      //case 39: strcpy(attrName,VDCT1_ATTR_TRANS_LEN);    goto wrapup;
      //case 40: strcpy(attrName,VDCT1_ATTR_CORNER_RAD);   goto wrapup;
      //case 41: strcpy(attrName,VDCT1_ATTR_WIDTH_1);      goto wrapup;
      //case 42: strcpy(attrName,VDCT1_ATTR_WIDTH_2);      goto wrapup;
      //case 43: strcpy(attrName,VDCT1_ATTR_WIDTH_3);      goto wrapup;
      //case 44: strcpy(attrName,VDCT1_ATTR_WIDTH_4);      goto wrapup;
      //case 45: strcpy(attrName,VDCT1_ATTR_DEPTH_1);      goto wrapup;
      //case 46: strcpy(attrName,VDCT1_ATTR_DEPTH_2);      goto wrapup;
      //case 47: strcpy(attrName,VDCT1_ATTR_DEPTH_3);      goto wrapup;
      //case 48: strcpy(attrName,VDCT1_ATTR_DEPTH_4);      goto wrapup;
      case 36: strcpy(attrName,VDCT1_ATTR_MAKE_BUY);     goto wrapup;
    }     
  }

  // Not found
  retFlag = 0;
    
wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Individual stage info
 */
static IGRstat getNodeTypeInfo(TVDct1JD *nodeJD,
			       IGRint    nth, 
			       IGRint   *cnt, 
			       TVDctNodeTypeInfo *info)
{
  VDASSERT_FN("getNodeTypeInfo");
  
  IGRstat retFlag = 0;
  
  // Arg check
  if (cnt) *cnt = 7;  // Set this to total number of nodes
  VDASSERTW(info);

  // Just a switch
  switch(nth) {

  case 0:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_GROUP);
    strcpy(info->desc, "GROUP");
    strcpy(info->level,"U00");
    strcpy(info->table,"");
    return 1;

  case 1:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ENGASSY2);
    strcpy(info->desc, "ENGASSY2");
    strcpy(info->level,"U01");
    strcpy(info->table,"");
    return 1;

  case 2:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ENGASSY6);
    strcpy(info->desc, "ENGASSY6");
    strcpy(info->level,"U02");
    strcpy(info->table,"");
    return 1;

  case 3:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY2);
    strcpy(info->desc, "ASSY2");
    strcpy(info->level,"U03");
    strcpy(info->table,"");
    return 1;

  case 4:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_ASSY6);
    strcpy(info->desc, "ASSY6");
    strcpy(info->level,"U04");
    strcpy(info->table,"");
    return 1;

  case 5:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_PART);
    strcpy(info->desc, "PART");
    strcpy(info->level,"U05");
    strcpy(info->table,"");
    return 1;
 
  case 6:
    strcpy(info->type,VDCT1_ENG_NODE_TYPE_HVACTREE);
    strcpy(info->desc, "HVAC_TREE");
    strcpy(info->level,"S06");
    strcpy(info->table,"");
    return 1;  
  }
  
  // No More
  memset(info,0,sizeof(TVDctNodeTypeInfo));

 wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * get default nodeType and info
 * **/
static IGRstat getDefaultNodeTypeName(IGRint  nth,
                                      IGRchar *nodeType,
				      IGRchar *nodeName)
{
  VDASSERT_FN("getDefaultNodeTypeName");

  IGRstat retFlag = 0;

  // arg check
  VDASSERTW(nodeType); *nodeType = 0;
  VDASSERTW(nodeName); *nodeName = 0;

  retFlag = 1;

  switch( nth ) {

    case 0: 
	strcpy(nodeType,VDCT1_ENG_NODE_TYPE_GROUP);
	strcpy(nodeName,"VD");
	goto wrapup;

    case 1:
	strcpy(nodeType,VDCT1_ENG_NODE_TYPE_GROUP);
	strcpy(nodeName,"SVD");
	goto wrapup;

    case 2:
	strcpy(nodeType,VDCT1_ENG_NODE_TYPE_GROUP);
	strcpy(nodeName,"SPVD");
	goto wrapup;

    case 3:
	strcpy(nodeType,VDCT1_ENG_NODE_TYPE_GROUP);
	strcpy(nodeName,"PLVD");
	goto wrapup;

    case 4:
	strcpy(nodeType,VDCT1_ENG_NODE_TYPE_GROUP);
	strcpy(nodeName,"FLVD");
	goto wrapup;

    case 5:
	strcpy(nodeType,VDCT1_ENG_NODE_TYPE_GROUP);
	strcpy(nodeName,"VFA");
	goto wrapup;

    default:
	retFlag = 0;

  }

  // done
wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * create default nodes under the tree.
 * **/
static void createDefaultNodes(TVDct1JD  *treeJD)
{
  VDASSERT_FN("createDefaultNodes");

  IGRstat sts;

  TVDct1JD nodeJD;
  IGRchar  nodeType[80];
  IGRchar  nodeName[80];

  IGRint   i;

  TVDct1CommInfo  comm;

  // arg check
  VDASSERTW( (treeJD) && (treeJD->id.objid != NULL_OBJID) && (treeJD->cl) );
  

  // Create them
  for (i = 0; getDefaultNodeTypeName(i,nodeType,nodeName); i++) {

      // create the node
      nodeJD.id.objid == NULL_OBJID;
      _RTCJDB(treeJD)->createNode(treeJD,nodeType,nodeName,&nodeJD);
      if (nodeJD.id.objid == NULL_OBJID) break;
      
      // set the comm_code stuff
      VDct1GetCommInfo(nodeName, &comm);
      if (comm.comm_code == NULL) break;

      _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_COMM_CODE,comm.comm_code);
      _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_COMMODITY,comm.commodity);
      _RTCJDB(&nodeJD)->setAttr(&nodeJD,VDCT1_ATTR_COST_CODE,comm.cost_code);
  }

  // done
wrapup:
  return;
}

/* -------------------------------------------------
 * Create a set, override for some default nodes
 */
static IGRstat createSet(TVDct1JD *mgrJD,
			 IGRchar  *setType,
			 IGRchar  *setTypeRev,
			 IGRchar  *setName,
			 TVDct1JD *setJD)
{
  VDASSERT_FN("createSet");
  IGRstat retFlag = 0;

  TVDct1JD parentClassJD;
  TVDct1JD treeJD;
  IGRchar  dwgNum[80];

  // Arg Check
  VDASSERTW(setJD);
  VDASSERTW(mgrJD);
  VDASSERTW(setType);
  VDASSERTW(setName);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s %s\n",ffn(),fn,setType,setName);
  }

  // Use standard node create routine
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->createSet(mgrJD,setType,setTypeRev,setName,setJD);
  if (setJD->id.objid == NULL_OBJID) goto wrapup;
 
  // get the tree node for the set
  _RTCJDB(setJD)->getNodeForSet(setJD,&treeJD);
  if (treeJD.id.objid == NULL_OBJID) goto wrapup;

  // set the some attributes
  _RTCJDB(&treeJD)->setAttr(&treeJD,VDCT1_ATTR_UNIT,setName);
  _RTCJDB(&treeJD)->setAttr(&treeJD,VDCT1_ATTR_AV_HULL,  VDCT1_DEFAULT_ENG_AV_HULL);
  _RTCJDB(&treeJD)->setAttr(&treeJD,VDCT1_ATTR_CONT_HULL, VDCT1_DEFAULT_CONT_HULL);
  _RTCJDB(&treeJD)->setAttr(&treeJD,VDCT1_ATTR_FROZEN,   VDCT1_DEFAULT_FROZEN);
  _RTCJDB(&treeJD)->setAttr(&treeJD,VDCT1_ATTR_NEXT_VD,  "1");
  _RTCJDB(&treeJD)->setAttr(&treeJD,VDCT1_ATTR_LABOR_CODE,VDCT1_DEFAULT_HVAC_LABOR_CODE);
  
  sprintf(dwgNum,"%s-%s-07",VDCT1_DEFAULT_HVAC_LABOR_CODE,setName);
  _RTCJDB(&treeJD)->setAttr(&treeJD,VDCT1_ATTR_DWG_NUM,dwgNum);

  // create the default nodes
  createDefaultNodes(&treeJD);

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;  
}


/* -----------------------------------------------
 * Hello routine for testing
 */
static IGRstat hello(TVDct1JD *nodeJD)
{ 
  printf("@@@ Hello from %s\n",
	 _RTCJDB(nodeJD)->info.type);
  return 1;
}
/* -------------------------------------------------------------------
 * PDM Table
 */
static IGRstat getTreePostTable(TVDct1JD *nodeJD, IGRchar *table_name)
{
  VDASSERT_FN("getTreePostTable");
  IGRstat retFlag = 0;
  
  VDASSERTW(table_name);
  
  strcpy(table_name,"tm_hvac_dynamic");

  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * The only public routine
 * Used to init the various function pointers
 */
IGRstat VDct1InitHvacTreeClass(TVDct1EngTreeClass *engCL, 
			       TVDct1HvacTreeClass *cl)
{
  VDASSERT_FN("VDct1InitHvacTreeClass");
  
  IGRstat retFlag = 0;

  // Tracing
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_HVAC);

  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Copy the root
  VDct1CopyRootImps(engCL,cl);
  cl->prod = engCL->prod;
  cl->eng  = engCL->eng;
  
  // Data
  strcpy(cl->base.info.type,"HvacTree");
  strcpy(cl->base.info.rev, "000");
  strcpy(cl->base.info.desc,"HVAC Tree");
  
  // Fill up pointers
  cl->base.hello            = hello;
  cl->base.createSet        = createSet;

  cl->base.getNodeTypeInfo  = getNodeTypeInfo;  
  cl->base.getNodeAttrName  = getNodeAttrName;  
  cl->base.getFilter        = getFilter;

  cl->base.createNode       = createNode;       
  cl->base.isChildTypeValid = isChildTypeValid; 
  
  cl->base.getParentForModelObject       = getParentForModelObject;
  cl->base.copyAttributesFromModelToNode = copyAttributesFromModelToNode;

  cl->base.computeNode      = computeNode;
  cl->base.reComputeNode    = reComputeNode;
  cl->base.getTreePostTable = getTreePostTable;

  // Engineering Pointers
  cl->eng.computeEngAssy2Name  = computeEngAssy2Name;

  //Command Pointers
  cl->cmd.getGadgetText        = getGadgetText;
  cl->cmd.getPasteNodeType     = getPasteNodeType;
  cl->cmd.computeMoveCopyNode  = computeMoveCopyNode;
  cl->cmd.isAttrUpdateValid    = isAttrUpdateValid;
  //cl->cmd.makeNodeName         = makeNodeName;

  // Done
  retFlag = 1;

 wrapup:
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  return retFlag;
}


