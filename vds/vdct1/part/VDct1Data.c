/* $Id: VDct1Data.c,v 1.4.2.1 2004/03/29 16:22:30 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/part/VDct1Data.c
 *
 * Description: Misc Data Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Data.c,v $
 *      Revision 1.4.2.1  2004/03/29 16:22:30  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/02/11 17:24:16  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.3  2001/02/02 19:02:36  jdsauby
 *      JS, JTS CR4087.  Changed to use same function to generate mat_id_key for a model object.
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/01/00  ah      Creation
 * 11/17/10  ah      SOL10 Removed unused cage code block
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDobj2.h"

#include "VDrisc.h"

#include "VDct1Ris.h"
#include "VDct1Part.h"

 
/* Added for VDitemdbGetMatIDForObject    */
extern IGRstat VDitemdbGetMatIDForObject();


#if 0
 /*      Now if PPL vds/vditem/ppl/VDit_route.u       */
/* --------------------------------------------
 * Clean Method Type for query
 * **/
static IGRstat cleanMethodType(IGRchar *mtype,
	                       IGRchar *cleantype)
{
    IGRstat retFlag = 0;
    IGRchar *p;
    IGRint  i, alpha, intstr;
   
    
    // arg check
    if (mtype[0] == '\0') goto wrapup;
    
    // set them to be equal
    strcpy(cleantype,mtype);

    // check for a decimal
    if (p = strchr(cleantype,'.')) {
	alpha = 0;

	// does it also have a letter making it alpha-numeric?
	for (i = 0; i < strlen(cleantype); i++) {
	    if (cleantype[i] >= 'A') {
		alpha = 1;
	    }
	}
	if (alpha == 0)  {
	    // no letters, pure number
	    intstr = atoi(mtype);
	    sprintf(cleantype,"%d",intstr);
	}
    }

    // done

wrapup:
    return retFlag;
}

/* ---------------------------------------------
 * Get the material code from rway_codelist, list_num 145
 */
static IGRstat getMaterialCode(IGRchar *duct_matl,
			       IGRchar *material)
{
  IGRstat retFlag = 0;
  
  TVDrisInfo ris;

  // Arg check
  if (duct_matl == NULL) goto wrapup;
    
  // init
  VDrisInitInfo(&ris);
  
  // build the sql
  sprintf(ris.sql,
	  "select short_txt from rway_codelist where list_num = 145 and long_txt = '%s';",
	  duct_matl);
  
  VDrisQuery(&ris,NULL);
  if (ris.rows < 1) goto wrapup;
  
  // set it
  strcpy(material,ris.buf[0]);
  
  // done
  retFlag = 1;
  
 wrapup:
  VDrisFreeInfo(&ris);
  return retFlag;
}

/* ---------------------------------------------
 * compute the mino for wway objects.  The mino
 * is actually queried from the db (OPS) based on
 * attributes that exist on the model object
 */
static IGRstat computeMinoForWWayObject(TGRid   *objID,
					IGRchar *mino)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRstat traceFlag = 0;
  IGRint  i;
  
  IGRchar methd[32],cleanMethod[32];
  IGRchar *p,*buf;
  IGRchar ops_type[80];
  IGRchar ops_modifier[80];
    
  IGRchar    methodType[32],cleanType[32];
  IGRchar    material  [32],duct_matl[32];
  IGRdouble  width;
  IGRdouble  noTiers;
  IGRchar    downComer [64];

  TVDrisInfo ris;
  IGRdouble  dc;
  
  IGRint     dp,dp1,dp2,dp3,dp4,dp5,dp6,dp7,dp8,dp9;
  
  if (traceFlag) printf(">>>computePartCageNumForWWayObject\n");
  
  // Arg check
  if (objID->objid == NULL_OBJID) goto wrapup;
  
  // init
  VDrisInitInfo(&ris);
  retFlag     = 0;
  *methd      = NULL;
  *methodType = NULL;
  *cleanType  = NULL;
  *downComer  = NULL;
  *duct_matl  = NULL;
  width       = 0;
  noTiers     = 0;
  dc = 0.0;
  dp=dp1=dp2=dp3=dp4=dp5=dp6=dp7=dp8=dp9 = 0;

  *mino = NULL;
   
  // get some attributes
  if (traceFlag) printf("### getting attributes ...\n");
  
  // get method_no first
  VDobjGetTxtAtr(NULL,objID,"method_no", methd);
  if (*methd == NULL) goto wrapup;
  if (traceFlag) printf("### method_no = %s\n",methd);
   
  // clean the method no, should be in format '2-b-1'
  // clean out any '-'
  p = 0;
  while (p = strchr(methd,'-')) 
     strcpy(p,p+1);
   
  // clean out any '"'
  p = 0;
  while (p = strchr(methd,'"'))
    strcpy(p,p+1);
  
  strcpy(cleanMethod,methd);
  
  if (traceFlag) printf("### clean method = %s\n",cleanMethod);
    
  // get methode_type
  VDobjGetTxtAtr(NULL,objID,"method_type", methodType);
  if (*methodType == NULL) goto wrapup;
  if (traceFlag) printf("### method_type = %s\n",methodType);
   
  // clean out any '"' from method_type
  p = 0;
  while (p = strchr(methodType,'"'))
    strcpy(p,p+1);
 
  // could have been placed as a number (ie 1.00000), need to drop the decimal zeros
  cleanMethodType(methodType,cleanType);
  if (*cleanType == NULL) goto wrapup; 

  // get duct_matl
  VDobjGetTxtAtr(NULL,objID,"duct_matl",duct_matl);
  if (*duct_matl == NULL) goto wrapup;
  if (traceFlag) printf("### duct_matl = %s\n",duct_matl);
  
  // Convert material to alpha code
  sts = getMaterialCode(duct_matl,material);
  if (!(sts & 1)) goto wrapup;
  
  // get width_1
  VDobjGetDblAtr(NULL,objID,"width_1",&width);
  if (width == 0) goto wrapup;
  if (traceFlag) printf("### width_1 = %.0f\n",width);

  // Convert width from mm to inch
  width = width/25.4;
  
  // get no_tiers_1
  VDobjGetDblAtr(NULL,objID,"no_tiers_1",&noTiers);
  if (noTiers == 0) goto wrapup;
  if (traceFlag) printf("### no_tiers_1 = %.0f\n",noTiers);

  // dp is a tricky on, if dp is not found, then it might be dp1
  // if dp1 is found, then we need to keep looking for the other dps
  // until ther are no more
  VDobjGetDblAtr(NULL,objID,"dp",&dc);
  if (dc) {
    dp =(dc/25.4) + 0.99;
    sprintf(downComer,"%d",dp);
  }
  
  if (traceFlag) printf("### dp = %d\n",dp);
 
  if (!dc) {
    dc = 0.0;
    VDobjGetDblAtr(NULL,objID,"dp1",&dc);
    if (!dc) goto wrapup;
    if (dc) {
      dp1 = (dc/25.4) + 0.99;
      dc = 0.0;
      VDobjGetDblAtr(NULL,objID,"dp2",&dc);
    }
    
    if (dc) {
      dp2 = (dc/25.4) + 0.99;;
      dc = 0.0;
      VDobjGetDblAtr(NULL,objID,"dp3",&dc);
      sprintf(downComer,"%d-%d",dp1,dp2);
    }
    
    if (dc) {
      dp3 = (dc/25.4) + 0.99;;
      dc = 0.0;
      VDobjGetDblAtr(NULL,objID,"dp4",&dc);
      sprintf(downComer,"%d-%d-%d",dp1,dp2,dp3);
    }
    
    if (dc) {
      dp4 = (dc/25.4) + 0.99;;
      dc = 0.0;
      VDobjGetDblAtr(NULL,objID,"dp5",&dc);
      sprintf(downComer,"%d-%d-%d-%d",dp1,dp2,dp3,dp4);
    }
    
    if (dc) {
      dp5 = (dc/25.4) + 0.99;;
      dc = 0.0;
      VDobjGetDblAtr(NULL,objID,"dp6",&dc);
      sprintf(downComer,"%d-%d-%d-%d-%d",dp1,dp2,dp3,dp4,dp5);
    }
    
    if (dc) {
      dp6 = (dc/25.4) + 0.99;;
      dc = 0.0;
      VDobjGetDblAtr(NULL,objID,"dp7",&dc);
      sprintf(downComer,"%d-%d-%d-%d-%d-%d",dp1,dp2,dp3,dp4,dp5,dp6);
    }
    
    if (dc) {
      dp7 = (dc/25.4) + 0.99;;
      dc = 0.0;
      VDobjGetDblAtr(NULL,objID,"dp8",&dc);
      sprintf(downComer,"%d-%d-%d-%d-%d-%d-%d",dp1,dp2,dp3,dp4,dp5,dp6,dp7);
    }
    
    if (dc) {
      dp8 = (dc/25.4) + 0.99;;
      dc = 0.0;
      VDobjGetDblAtr(NULL,objID,"dp9",&dc);
      sprintf(downComer,"%d-%d-%d-%d-%d-%d-%d-%d",
	      dp1,dp2,dp3,dp4,dp5,dp6,dp7,dp8);
    }
    
    if (dc) {
      dp9 = (dc/25.4) + 0.99;
      dc = 0.0;
      sprintf(downComer,"%d-%d-%d-%d-%d-%d-%d-%d-%d",
	      dp1,dp2,dp3,dp4,dp5,dp6,dp7,dp8,dp9);
    }
  }
  
  // build the ops_type
  sprintf(ops_type,"WH%s%s",cleanMethod,cleanType);
  
  // build the ops_modifier
  sprintf(ops_modifier,"%s-%.0f-%.0f-%s",material,width,noTiers,downComer);
  
  // now query the tm_items to get the mino
   // build the query
  sprintf(ris.sql,
	  "select item_num from tm_items where tree_type='%s' and tree_modifier='%s' and item_cur_rev=1;",
	  ops_type,ops_modifier);
  if (traceFlag) printf("### %s\n",ris.sql);
  
  // query
  VDrisQuery(&ris,NULL);
  if (ris.rows < 1) goto wrapup;
  
  // set it
  strcpy(mino,ris.buf[0]);
  if (traceFlag) printf ("### mino = %s\n",mino);

  // done
  if (*mino != NULL) retFlag = 1;
    
wrapup:
  if (traceFlag) printf("<<< computeMinoForWWayObject\n");
  VDrisFreeInfo(&ris);
  return retFlag;
}
  
/* --------------------------------------------------------
 * Waveguide MINOs are gotten from the part_num attribute in
 * the rway_comps table
 */
static IGRstat computeMinoForWaveguideObject(TGRid   *objID,
					     IGRchar *mino)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRstat traceFlag = 0;
  
  IGRchar comp_code[32];
  
  TVDrisInfo ris;
  
  // init 
  VDrisInitInfo(&ris);
  *comp_code = NULL;

  // get comp_code
  VDobjGetTxtAtr(NULL,objID,"comp_code",comp_code);
  if (*comp_code == NULL) goto wrapup;
  if (traceFlag) printf("### comp_code = %s\n",comp_code);

  // build the query
  sprintf(ris.sql,
	  "select part_num from rway_comps where comp_code = '%s';",
	  comp_code);
  if (traceFlag) printf("### %s\n",ris.sql);
  
  // query
  VDrisQuery(&ris,NULL);
  if (ris.rows < 1) goto wrapup;
  
  // set it
  if (traceFlag) printf ("### ris.buf[0] = %s\n",ris.buf[0]);
  
  strcpy(mino,ris.buf[0]);
  if (traceFlag) printf ("### mino = %s\n",mino);
  
  
  // done
  retFlag = 1;

    
wrapup:
  VDrisFreeInfo(&ris);
  return retFlag;
  
}
/* --------------------------------------------------------
 * Collars will use method_no, method_type, material, width_1,
 * depth_1, trans_len, collar_type
 */
static IGRstat computeMinoForWWayCollarObject(TGRid   *objID,
					      IGRchar *mino)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRstat traceFlag = 0;
  
  IGRint  i;
  
  IGRchar methd[32],cleanMethod[32];
  IGRchar *p,*buf;
  IGRchar ops_type[80];
  IGRchar ops_modifier[80];
    
  IGRchar    methodType[32],cleanType[32];
  IGRchar    material  [32],duct_matl[32];
  IGRdouble  width1,depth1,trans_len;
  IGRdouble  ductThk;
  
  TVDrisInfo ris;
  
  // init 
  VDrisInitInfo(&ris);
  *methd      = NULL;
  *methodType = NULL;
  *cleanType  = NULL;
  *duct_matl  = NULL;
  width1      = 0;
  depth1      = 0;
  trans_len   = 0;

  *mino = NULL;
   
  // get some attributes
  if (traceFlag) printf("### getting attributes ...\n");
  
  // get method_no first
  VDobjGetTxtAtr(NULL,objID,"method_no",methd);
  if (*methd == NULL) goto wrapup;
  if (traceFlag) printf("### method_no = %s\n",methd);
   
  // clean the method no, should be in format '3-a-1'
  // clean out any '-'
  p = 0;
  while (p = strchr(methd,'-')) 
     strcpy(p,p+1);
   
  // clean out any '"'
  p = 0;
  while (p = strchr(methd,'"'))
    strcpy(p,p+1);
  
  strcpy(cleanMethod,methd);
  
  if (traceFlag) printf("### clean method = %s\n",cleanMethod);
    
  // get methode_type
  VDobjGetTxtAtr(NULL,objID,"method_type",methodType);
  if (*methodType == NULL) goto wrapup;
  if (traceFlag) printf("### method_type = %s\n",methodType);
  
  // clean out any '"' from method_type
  p = 0;
  while (p = strchr(methodType,'"'))
    strcpy(p,p+1);
  
  // could have been placed as a number (ie 1.00000), need to drop the decimal zeros
  cleanMethodType(methodType,cleanType);
  if (*cleanType == NULL) goto wrapup;

  // get duct_matl
  VDobjGetTxtAtr(NULL,objID,"duct_matl",duct_matl);
  if (*duct_matl == NULL) goto wrapup;
  if (traceFlag) printf("### duct_matl = %s\n",duct_matl);
  
  // Convert material to alpha code
  sts = getMaterialCode(duct_matl,material);
  if (!(sts & 1)) goto wrapup;
  
  // get width_1
  VDobjGetDblAtr(NULL,objID,"width_1",&width1);
  if (width1 == 0) goto wrapup;
  if (traceFlag) printf("### width_1 = %.0f\n",width1);

  // Convert width from mm to inch
  width1 = width1/25.4;
  
  // get depth_1
  VDobjGetDblAtr(NULL,objID,"depth_1",&depth1);
  if (depth1 == 0) goto wrapup;
  if (traceFlag) printf("### depth_1 = %.0f\n",depth1);

  // Convert depth from mm to inch
  depth1 = depth1/25.4;
    
  // get trans_len
  VDobjGetDblAtr(NULL,objID,"trans_len",&trans_len);
  if (trans_len == 0) goto wrapup;
  if (traceFlag) printf("### trans_len = %.0f\n",trans_len);

  // Convert trans_len from mm to inch
  trans_len = trans_len/25.4;

  // get ductThk
  VDobjGetDblAtr(NULL,objID,"duct_thk",&ductThk);
  if (traceFlag) printf("### duct_thk = %.3f\n",ductThk);

  // build the ops_type
  sprintf(ops_type,"CLR%s-%s",cleanMethod,cleanType);
  
  // build the ops_modifier
  sprintf(ops_modifier,"%s-%.0fX%.0fX%.0fX%.3f",material,width1,depth1,trans_len,ductThk);

    // now query the tm_items to get the mino
   // build the query
  sprintf(ris.sql,
	  "select item_num from tm_items where tree_type='%s' and tree_modifier='%s' and item_cur_rev=1;",
	  ops_type,ops_modifier);
  if (traceFlag) printf("### %s\n",ris.sql);
  
  // query
  VDrisQuery(&ris,NULL);
  if (ris.rows < 1) goto wrapup;
  
  // set it
  strcpy(mino,ris.buf[0]);
  if (traceFlag) printf ("### mino = %s\n",mino);

  // done
  if (*mino != NULL) retFlag = 1;
    
wrapup:
  if (traceFlag) printf("<<< computeMinoForWWayObject\n");
  VDrisFreeInfo(&ris);
  return retFlag;
}

static IGRstat computeMinoForWWayTransitObject(TGRid   *objID,
					       IGRchar *mino)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRstat traceFlag = 0;
  
  IGRchar comp_code[32];
  IGRint  i;
  
  IGRchar ops_type[80];
  IGRchar ops_modifier[80];
    
  IGRchar    material  [32],duct_matl[32];
  IGRdouble  width1,depth1,trans_len;
  IGRdouble  ductThk;
  
  TVDrisInfo ris;
  
  // init 
  VDrisInitInfo(&ris);
  retFlag     = 0;
  *comp_code  = NULL;
  *duct_matl  = NULL;
  width1      = 0;
  depth1      = 0;
  trans_len   = 0;

  *mino = NULL;
   
  // get some attributes
  if (traceFlag) printf("### getting attributes ...\n");
  
  // get comp_code
  VDobjGetTxtAtr(NULL,objID,"comp_code",comp_code);
  if (*comp_code == NULL) goto wrapup;
  if (traceFlag) printf("### comp_code = %s\n",comp_code);
  
  // get duct_matl
  VDobjGetTxtAtr(NULL,objID,"duct_matl",duct_matl);
  if (*duct_matl == NULL) goto wrapup;
  if (traceFlag) printf("### duct_matl = %s\n",duct_matl);
  
  // Convert material to alpha code
  sts = getMaterialCode(duct_matl,material);
  if (!(sts & 1)) goto wrapup;
  
  // get width_1
  VDobjGetDblAtr(NULL,objID,"width_1",&width1);
  if (width1 == 0) goto wrapup;
  if (traceFlag) printf("### width_1 = %.0f\n",width1);

  // Convert width from mm to inch
  width1 = width1/25.4;
  
  // get depth_1
  VDobjGetDblAtr(NULL,objID,"depth_1",&depth1);
  if (depth1 == 0) goto wrapup;
  if (traceFlag) printf("### depth_1 = %.0f\n",depth1);

  // Convert depth from mm to inch
  depth1 = depth1/25.4;
    
  // get trans_len
  VDobjGetDblAtr(NULL,objID,"trans_len",&trans_len);
  if (trans_len == 0) goto wrapup;
  if (traceFlag) printf("### trans_len = %.0f\n",trans_len);

  // Convert trans_len from mm to inch
  trans_len = trans_len/25.4;

  // get ductThk
  VDobjGetDblAtr(NULL,objID,"duct_thk",&ductThk);
  if (traceFlag) printf("### duct_thk = %.3f\n",ductThk);

  // build the ops_type
  strcpy(ops_type,comp_code);
  
  // build the ops_modifier
  sprintf(ops_modifier,"%s-%.0fX%.0fX%.0fX%.3f",material,width1,depth1,trans_len,ductThk);

    // now query the tm_items to get the mino
   // build the query
  sprintf(ris.sql,
	  "select item_num from tm_items where tree_type='%s' and tree_modifier='%s' and item_cur_rev=1;",
	  ops_type,ops_modifier);
  if (traceFlag) printf("### %s\n",ris.sql);
  
  // query
  VDrisQuery(&ris,NULL);
  if (ris.rows < 1) goto wrapup;
  
  // set it
  strcpy(mino,ris.buf[0]);
  if (traceFlag) printf ("### mino = %s\n",mino);

  // done
  if (*mino != NULL) retFlag = 1;
    
wrapup:
  if (traceFlag) printf("<<< computeMinoForWWayObject\n");
  VDrisFreeInfo(&ris);
  return retFlag;
  
}


/* -----------------------------------------------
 * Raceways need some computing for a part cage num
 */
IGRstat VDct1ComputePartCageNumForWWayObject(TGRid   *objID,
					     IGRchar *cage_code,
					     IGRchar *part_cage_num)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRstat traceFlag = 0;
    
  IGRdouble par_2;
  IGRchar   par[12];
  

  IGRchar mino[32];
  
  
  // Arg check
  if (objID->objid == NULL_OBJID) goto wrapup;

  // init
  par_2 = 0;
  *part_cage_num = 0;

  // say hi
  if (traceFlag) printf (">>> VDct1ComputePartCageNumForWWayObject\n");
  
  
  // Get the par_2 attribute
  VDobjGetDblAtr(NULL,objID,"par_2",&par_2);
  if (traceFlag) printf("### par_2 = %.0f\n",par_2);
  sprintf(par,"%.0f",par_2);
  
  switch (*par) {
    
  case '1':
    sts = computeMinoForWWayObject(objID,mino);
    if (!(sts & 1)) goto wrapup;
    sprintf(part_cage_num,"%s-%s",cage_code,mino);
    retFlag = 1;
    goto wrapup;
        
  case '2':
    sts = computeMinoForWaveguideObject(objID,mino);
    if (!(sts & 1)) goto wrapup;
    sprintf(part_cage_num,"%s-%s",cage_code,mino);
    retFlag = 1;
    goto wrapup;
    
  case '3':
    sts = computeMinoForWWayCollarObject(objID,mino);
    if (!(sts & 1)) goto wrapup;
    sprintf(part_cage_num,"%s-%s",cage_code,mino);
    retFlag = 1;
    goto wrapup;
    
  case '4':
    sts = computeMinoForWWayTransitObject(objID,mino);
    if (!(sts & 1)) goto wrapup;
    sprintf(part_cage_num,"%s-%s",cage_code,mino);
    retFlag = 1;
    goto wrapup;
    
  default:
    //strcpy(mino,"NOT COMPUTED");
    sts = computeMinoForWWayObject(objID,mino);
    //sts = computeMinoForWaveguideObject(objID,mino);
    if (!(sts & 1)) goto wrapup;
    sprintf(part_cage_num,"%s-%s",cage_code,mino);
    retFlag = 1;
    goto wrapup;
    
  }
   
  // done

wrapup:
  if (traceFlag) printf("<<< VDct1ComputePartCageNumForWWayObject\n");
  if (traceFlag) printf("### part_cage_num = %s\n",part_cage_num);
  
  return retFlag;
}
/*    End of stuff in PPL vds/vditem/ppl/VDit_route.u     */
#endif

/* -----------------------------------------------
 * Get the part_num from a model object
 * Get the part_id as well if possible
 */
IGRstat VDct1GetPartCageNumForModelObject(TGRobj_env *a_objOE,
					  TGRid      *a_objID,
					  TVDct1_part_fld_part_cage_num a_part_cage_num,
					  TVDct1_part_fld_part_id       a_part_id)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   objID;

  IGRchar part_cage_num[64];
  IGRchar part_num     [64];
  IGRchar part_id      [64];
  IGRchar grade        [64];
  IGRchar cage_code    [64];
  IGRchar catalog_num  [64];
  
  IGRchar buf[256];
  IGRchar *p;
  
  IGRdouble thk;

  // Init
  *part_cage_num = 0;
  *part_id       = 0;

  // Arg check
  if (a_part_cage_num) *a_part_cage_num = 0;
  if (a_part_id)       *a_part_id  = 0;
  
  // Get the object
  objID.objid = NULL_OBJID;
  if (a_objOE) objID =  a_objOE->obj_id;
  if (a_objID) objID = *a_objID;
  if (objID.objid == NULL_OBJID) goto wrapup;


  /* -----------------------------------------------
   * CR JTSMP 4087 made for a generation of a mat_id_key, which
   * is essentially what this function did.  Generating the mat_id_key
   * is customizable, and therefore, this should also be.
   * So, just call the new function.  JDS 01Feb01
   * ***/
  sts = VDitemdbGetMatIDForObject(&objID,part_cage_num);
  if (!(sts & 1)) goto wrapup;
    
  // Done
  retFlag = 1;
  
 wrapup:

  // Return cage_num
  strupr(part_cage_num);
  if (a_part_cage_num) strcpy(a_part_cage_num,part_cage_num);
  
  // If a part_num was found, get part_id
  if ((*part_cage_num) && (a_part_id)) {
    VDct1ReadPartIdForPartCageNum(part_cage_num,part_id);
    strcpy(a_part_id,part_id);
    // printf("OPS HERE %s %s\n",part_cage_num,part_id);
    
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Get the part_num from a model object
 * Get the part_id as well if possible
 *
 * Hang onto this just in case decide to go back to
 * part_num only stuff and drop the cage code
 *
 * Try not to use this
 */
IGRstat VDct1GetPartNumForModelObject(TGRobj_env *a_objOE,
				      TGRid      *a_objID,
				      TVDct1_part_fld_part_num a_part_num,
				      TVDct1_part_fld_part_id  a_part_id)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar part_cage_num[64];
  IGRchar *p;

  // Arg check
  if (a_part_num) *a_part_num = 0;
  if (a_part_id)  *a_part_id  = 0;
  
  // Use the cage_num processor
  VDct1GetPartCageNumForModelObject(a_objOE,a_objID,part_cage_num,a_part_id);
  
  // Drop the cage
  p = strchr(part_cage_num,'-');
  if ((a_part_num) && (p) && ((p - part_cage_num) == 5)) {
    strcpy(a_part_num,p+1);
  }

  // Done
  retFlag = 1;
  
 wrapup:
  
  return retFlag;
}

/* -----------------------------------------------
 * When a database is not available, allow using
 * local data files
 *
 * This routine returns the directory path of the data files
 */
IGRstat VDct1GetDataDir(IGRchar *dir)
{
  IGRstat retFlag = 0;
  IGRchar *p;
  
  // Arg check
  if (dir == NULL) goto wrapup;
  
  // Look for env
  p = getenv("TM_DATA");
  if (p) strcpy(dir,p);
  else   strcpy(dir,"/usr/tmp/tm_data");
  
  // Create it
  // mkdir(dir,0777);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Given a model object, get the item_type from
 * the database.
 */
IGRstat VDct1GetItemTypeForModelObject(TGRobj_env *modelOE,
				       IGRchar    *itemType)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar part_cage_num[25];
  IGRchar isdp_cage_num[31];
  
  TVDrisInfo ris;
  
  // init
  *itemType = 0;
  
  //Get the isdp_cage_num
  VDct1GetPartCageNumForModelObject(modelOE,NULL,isdp_cage_num,NULL);
  if (*isdp_cage_num == 0) goto wrapup;
  
  //Convert to a true part_cage_num
  VDct1ReadCageNumForIsdpCageNum(isdp_cage_num,part_cage_num);
  if (*part_cage_num == 0) goto wrapup;
  
  VDct1QryItemTypeForPartCageNum(&ris,part_cage_num,itemType);
  if (*itemType == 0) goto wrapup;
 
  
  // done
  retFlag = 1;
  
wrapup:
  
  return retFlag;
}






