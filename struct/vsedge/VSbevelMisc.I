/* $Id: VSbevelMisc.I,v 1.5 2001/05/04 18:22:15 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsedge/VSbevelMisc.I
 *
 * Description: Misc routines for bevels
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbevelMisc.I,v $
 *      Revision 1.5  2001/05/04 18:22:15  ramarao
 *      Removed a warning message.
 *
 *      Revision 1.4  2001/03/13 22:04:27  ramarao
 *      Fixed an overlap problem.
 *
 *      Revision 1.3  2001/03/02 18:53:23  ramarao
 *      Added Plate Names as Attributes.
 *
 *      Revision 1.2  2001/02/01 16:40:08  jayadev
 *      change for TR4420
 *
 *      Revision 1.1  2001/01/17 00:07:26  ramarao
 *      *** empty log message ***
 *
# Revision 1.2  2000/11/27  20:18:56  pinnacle
# ah
#
# Revision 1.1  2000/10/25  19:22:54  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/17/00  ah      Creation
 * 03/12/01  RR	     Changed VSbevelGetCurveOverlap function to call a 
 * 		     BS routine.
 * -------------------------------------------------------------------*/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDgeom.h"

#include "VSbevel2.h"

#include "bsmdistptsf.h"
#include "bssfevaln.h"
#include "bsmdstptcv.h"
#include "bsnorvec.h"

#include "EMSssprops.h"
#include "gotextdef.h"
#include "cotxmacros.h"
#include "dp.h"
#include "v_miscmacros.h"

VDASSERT_FFN("struct/vsedge/VDbevelMisc.I");

from ACrg_collect import AClist_attribute;
from ACrg_collect import ACset_list_attribute;
from ACrg_collect import ACadd_list_attribute;

from GR3dpoint    import GRgetpolyline;
from EMSsubbs     import EMget_props;
from GRtext       import GRgettxattr;

extern GRclassid  OPP_VSplate_class_id;

typedef struct GRdpb_text_symb TGRdpb_text_symb ;

static IGRint bevelFontSize;

/* -----------------------------------------------
 * Sets the active bevel font size
 * If a macro is passed then use the label font size
 * pulled from a foot, this saves having to store
 * it as an attribute
 *
 * Otherwise, use the passed set type
 */
IGRstat VSbevelSetFontSize(IGRint fontSize, TGRobj_env *macOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRobj_env labelOE;

  struct IGRestx attr;
  
  // Have a macro ?
  if (macOE == NULL) {
    bevelFontSize = fontSize;
    retFlag = 1;
    goto wrapup;
  }
  
  /* ---------------------------------------------
   * This is kind of strange but want only one font size
   * to be used during the recomputes
   * So if one was already sei then don't change it
   */
  if (bevelFontSize) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Need a foot
  vdobj$GetFoot(objOE    = macOE,
		footName = "label" ,
		footOE   = &labelOE);
  if( labelOE.obj_id.objid == NULL_OBJID ) {

    vdobj$GetFoot(objOE    = macOE,
		  footName = "label1" ,
		  footOE   = &labelOE);
  }

  // This is ok during initial placement
  if(labelOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Get the text data
  sts = om$send(msg = message GRtext.
		GRgettxattr(&msg, &attr, NULL, NULL),
		senderid = NULL_OBJID ,
		targetid = labelOE.obj_id.objid ,
		targetos = labelOE.obj_id.osnum);

  if (!(sts & msg & 1)) goto wrapup;
  
  fontSize = attr.width;
  if (attr.height > fontSize) {
    fontSize = attr.height;
  }
  
  // Done
  bevelFontSize = fontSize;
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Return the font size to use
 */
IGRint VSbevelGetFontSize()
{
  TGRdpb_text_symb symb;
  
  // Default to active font size
  if (bevelFontSize < 1) {

    gr$get_text_symb(buffer = &symb);

    bevelFontSize = symb.Active_width;
    if (bevelFontSize <symb.Active_height) {
      bevelFontSize = symb.Active_height;
    }    
  }

  // Just in case
  if (bevelFontSize < 1) {
    bevelFontSize = 25;
  }

  // Done
  // printf("Bevel Font Size %d\n",bevelFontSize);
  
  return bevelFontSize;
}

extern IGRdouble sqrt(IGRdouble x);

/* -----------------------------------------------
 * Create a stock triangle symbol for the bevel
 */
IGRstat VSbevelCreateStockSymbol(IGRdouble  *pointPt,
				 IGRdouble  *orient,
				 TGRobj_env *macOE,
				 TGRid      *symID)
{
  VDASSERT_FN("VSbevelCreateStockSymbol");

  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRdouble tmp;
  IGRdouble pts[12];
  
  IGRint i,fontSize;
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }

  // Arg check
  VDASSERTW(symID);
  symID->objid = NULL_OBJID;
  VDASSERTW(pointPt);
  VDASSERTW(orient);
  VDASSERTW(macOE);

  // Init
  fontSize = VSbevelGetFontSize();

  // Make three vertices of triangle
  tmp = sqrt(3);
  for(i = 0; i < 3; i++) {

    pts[0+i] = pointPt[i] - 
      (orient[i+3] * fontSize);

    pts[9+i] = pointPt[i] - 
      (orient[i+3] * fontSize);
    
    pts[3+i] = pointPt[i] + 
      (orient[i]   * fontSize * .5 * tmp) +
      (orient[i+3] * fontSize * .5);

    pts[6+i] = pointPt[i] - 
      (orient[i]   * fontSize *.5 *tmp) +
      (orient[i+3] * fontSize *.5);
  }

  // Draw it
  VDdrawLinear(4,pts,&macOE->mod_env,symID);
  VDASSERTW(symID->objid != NULL_OBJID);
  
  // Done
  retFlag = 1;

  
 wrapup:
  if (traceFlag) {
    printf("<<< %s\n",fn);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Create a text label for the bevel
 */
IGRstat VSbevelCreateTextLabel(IGRchar        *textStr,
			       IGRint          stock,
			       IGRdouble      *pointPt,
			       IGRdouble      *orient,
			       TGRobj_env     *macOE,  // Osnum and env
			       TGRid          *textID)
{
  VDASSERT_FN("VSbevelCreateTextLabel");

  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRdouble rotMatrix[16];

  TGRsymbology	   symb;
  TGRdpb_text_symb txtSymb ;
  IGRint           fontSize;
  IGRushort        properties ;
  IGRshort         textLen;
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }

  // Arg check
  VDASSERTW(textID);
  textID->objid = NULL_OBJID;
  textID->osnum = macOE->obj_id.osnum;
  VDASSERTW(pointPt);
  VDASSERTW(orient);
  VDASSERTW(macOE);
  VDASSERTW(textStr);

  // Init
  fontSize = VSbevelGetFontSize();

  // Make a rotational matrix for label text
  rotMatrix[0]  = orient[0] ;
  rotMatrix[1]  = orient[1] ;
  rotMatrix[2]  = orient[2] ;
  rotMatrix[3]  = 0.0;
  rotMatrix[4]  = orient[3] ;
  rotMatrix[5]  = orient[4] ;
  rotMatrix[6]  = orient[5] ;
  rotMatrix[7]  = 0.0;
  rotMatrix[8]  = orient[6] ;
  rotMatrix[9]  = orient[7] ;
  rotMatrix[10] = orient[8] ;
  rotMatrix[11] = 0.0;
  rotMatrix[12] = pointPt[0] ;
  rotMatrix[13] = pointPt[1] ;
  rotMatrix[14] = pointPt[2] ;
  rotMatrix[15] = 1.0 ;

  // If set stock, move the origin above stock symbol
  if(stock) {
    rotMatrix[12] += 1.2*fontSize*orient[3];
    rotMatrix[13] += 1.2*fontSize*orient[4];
    rotMatrix[14] += 1.2*fontSize*orient[5];
  }
  
  // Get text symbology
  VDahGetActiveSymbology(&symb);
  gr$get_text_symb(buffer = &txtSymb);

  if (traceFlag) printf("Active Font %d\n",txtSymb.Active_font);

  // Stock is a bit smaller
  if(*textStr == 'S') fontSize *= 0.8;
  textLen = strlen(textStr);
  
  txtSymb.Active_width  = fontSize ;
  txtSymb.Active_height = fontSize ;
  txtSymb.Active_just   = CENTER_CENTER ;
  txtSymb.Active_flags  = GRFILLED_TEXT ;
  properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  sts = co$place_text(msg           = &msg,
		      text_string   =  textStr,
		      text_length   = &textLen,
		      origin        = &rotMatrix[12],
		      rot_matrix    =  rotMatrix,
		      ActiveDisplay = &symb.display_attr ,
		      ActiveLevel   =  symb.level ,
		      Properties    = &properties ,
		      TextSymb      = &txtSymb,
		      ActiveAngle   = 0.0,
		      ModuleInfo    = &macOE->mod_env,
		      flags	    = 1,
		      buffer	    = textID,
		      classname     = "GR3dtext");

  if (!(sts & msg & 1)) {
    printf("Text Placement Failed\n");
    goto wrapup;
  }
  
  if (traceFlag) printf("Second text %d\n",textID->objid);

  // Done
  retFlag = 1;
  
 wrapup:
  
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  return retFlag;
}


/* -----------------------------------------------
 * Fills in orient matrix for surface and stuff
 */
IGRstat VSbevelFillOrient(TGRbsp_surface *srfBsp,
			  TGRobj_env     *srfOE,
			  IGRdouble      *pointPt,
			  TGRbsp_curve   *crvBsp,
			  IGRdouble      *orient)
{
  VDASSERT_FN("VSbevelFillOrient");

  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRdouble srfPt [3];
  IGRdouble srfPt2[3];
  
  BSrc rc;
  
  IGRdouble u,v;
  IGRdouble dist;
  IGRint    num,i;
  IGRuchar  props ;
  IGRpoint  crvPt;
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }

  // Arg check
  VDASSERTW(orient);
  VDASSERTW(srfBsp);
  VDASSERTW(srfOE);
  VDASSERTW(pointPt);
  VDASSERTW(crvBsp);

  // Surface point
  BSmdistptsf(&rc, srfBsp, pointPt, &u, &v, srfPt, &dist);

  BSsfevaln(srfBsp,u,v,1,&num,srfPt2,(IGRpoint*)&orient[6],&rc);

  // Might be reversed? Need to test this
  sts = om$send(msg = message EMSsubbs.EMget_props(&msg, &props),
		senderid = NULL_OBJID,
		targetid = srfOE->obj_id.objid,
		targetos = srfOE->obj_id.osnum ) ;
  VDASSERTW(sts & msg & 1);
  
  if(props & EMSIS_NRML_REVERSED) {
    for(i = 6; i < 9; i++) {
      orient[i] *= -1.0;
    }
  }

  // Nearest point on curve (use srfPt???)
  BSmdstptcv(crvBsp, pointPt, &u, crvPt, &dist, &rc);

  // Make a normal unit vector, &orient[3], from bvlMidPnt to lblPnt, 
  BSmkvec (&rc, &orient[3], crvPt, pointPt) ; 
  BSnorvec(&rc, &orient[3]) ;			

  // Make a unit vector, &orient[0], by cross product of &[3] and &[6]
  BScrossp(&rc,&orient[3],&orient[6],&orient[0]);

  if (traceFlag) {
    printf("Orient %8.2f %8.2f %8.2f\n",orient[0],orient[1],orient[2]);
    printf("       %8.2f %8.2f %8.2f\n",orient[3],orient[4],orient[5]);
    printf("       %8.2f %8.2f %8.2f\n",orient[6],orient[7],orient[8]);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:

  return retFlag;
}

#define MAX_ATTRS 16

/* ----------------------------------------------------------------
 * Create the collector object and return a few bits of useful data
 */
IGRstat VSbevelCreateFootCollector(TGRobj_env *attrOE, 
				   TGRobj_env *macOE,
				   TGRid      *colID,
				   IGRchar    *textStr,
				   IGRint     *haveStock)
{
  VDASSERT_FN("VSbevelCreateFootCollector");

  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TACrg_coll  attrs[MAX_ATTRS], name_attr;
  TACrg_coll *attr;
  IGRint      attrCnt,i,plt_count;
  IGRchar     objName[1024], *p;
  TGRid	      par_plate;
    
  // Say hi
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }

  // Arg check
  VDASSERTW(colID); 
  colID->objid = NULL_OBJID;
  
  VDASSERTW(textStr);
  strcpy(textStr,"MISSING");
  
  VDASSERTW(haveStock);
  *haveStock = 0;
  
  VDASSERTW(attrOE);
  VDASSERTW(macOE);

  // Need the attributes
  attrCnt = 0;
  sts = om$send(msg = message ACrg_collect.
		AClist_attribute(&msg,MAX_ATTRS,attrs,&attrCnt),
		senderid = NULL_OBJID ,
		targetid = attrOE->obj_id.objid,
		targetos = attrOE->obj_id.osnum);
  VDASSERTW(attrCnt);
  
  if (traceFlag) {
    printf("Number of attributes %d\n",attrCnt);
  }

  // Dup it
  colID->osnum = macOE->obj_id.osnum;
  
  om$construct(classname = "ACrg_collect",
	       osnum     =  colID->osnum,
	       p_objid   = &colID->objid);
  VDASSERTW(colID->objid != NULL_OBJID);
  
  om$send(msg = message ACrg_collect.
	  ACset_list_attribute(&msg, attrCnt, attrs),
	  senderid = NULL_OBJID,
	  targetid = colID->objid,
	  targetos = colID->osnum) ;

  // Cycle through and look for certain labels
  for(i = 0; i < attrCnt; i++) {

    attr = &attrs[i];

    // Bevel Type
    if (!strcmp(attr->name,"bevel_type")) {
      
      strcpy(textStr,attr->desc.value.att_txt);
      if (*textStr == 0) strcpy(textStr,"UNKNOWN");
    }

    // Stock
    if (!strcmp(attr->name,"stock_value")) {
      if(attr->desc.value.att_exp > 0.001) *haveStock = 1;
    }

#if 0
    // Just a debug check
    if (!strcmp(attr->name,"offset_value")) {
      if(attr->desc.value.att_exp > 0.001) {
	printf("### Offset value %.2f for\n",attr->desc.value.att_exp);
	vdobj$Print(objOE = macOE);
      }      
    }

    // Just a debug check
    if (!strcmp(attr->name,"label_flag")) {
      if (strcmp(attr->desc.value.att_txt,"00")) {
	printf("### Label Flag '%s' for\n",attr->desc.value.att_txt);
	vdobj$Print(objOE = macOE);
      }      
    }	
#endif

  }

  plt_count = 0;
  for( i=0; i<7; ++i )
  {
      vdobj$GetParent( objID      = &macOE->obj_id,
                       idx        = i,
                       parentID   = &par_plate );
      if( vd_$is_ancestry_valid( object  = &par_plate,
				 classid = OPP_VSplate_class_id ) )
      {
	  name_attr.desc.type = AC_ATTRIB_TEXT;
	  sprintf( name_attr.name, "PlateName%d", plt_count );
	  vdobj$Get( objID = &par_plate, objPath = objName );
	  if( p = strstr( objName, "ref:" ) )	p += 3;
	  else					p = objName;
	  strcpy( name_attr.desc.value.att_txt, p );

	  sts = om$send(  msg = message ACrg_collect.ACadd_list_attribute
				 ( &msg, 1, &name_attr ),
          	senderid = NULL_OBJID,
          	targetid = colID->objid,
          	targetos = colID->osnum) ;
	  plt_count++;
      }
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {
    printf("<<< %s\n",fn);
  }
  return retFlag;
}

IGRstat VSbevelGetCurveOverlap(TGRbsp_curve *crv1,
                               TGRbsp_curve *crv2,
                               TGRobj_env   *macOE,
                               TGRbsp_curve **crv)
{
BSrc			rc;
IGRint			k, retFlag=0;
IGRint			numDistCvs1=0, numDistCvs2=0, numOvCvs=0, ovLapCode;
struct IGRbsp_curve     **DCvs1=NULL, **DCvs2=NULL, **OCvs=NULL;
 
   if( !crv1 || !crv2 || !crv ) return OM_E_INVARG;

   *crv = NULL;

   BSchk2cvsov( crv1, crv2, 5.0, 1, &ovLapCode,
                &numDistCvs1, &DCvs1, &numDistCvs2, &DCvs2,
                &numOvCvs, &OCvs, &rc );

   if( rc == BSSUCC && numOvCvs > 0 )
   {
       VDgeomAllocCrv( OCvs[0]->order, OCvs[0]->num_poles, OCvs[0]->rational,
		       OCvs[0]->num_boundaries, 0, crv );
       BScv_copy( &rc, OCvs[0], *crv );
       if( rc == BSSUCC ) retFlag = 1;
       else		  _FREE( *crv );
   }

   if( numDistCvs1 )
   {
      for( k=0; k<numDistCvs1; ++k )      BSfreecv( &rc, DCvs1[k] );
      _FREE( DCvs1 );
      numDistCvs1 = 0;
   }
   if( numDistCvs2 )
   {
      for( k=0; k<numDistCvs2; ++k )      BSfreecv( &rc, DCvs2[k] );
      _FREE( DCvs2 );
      numDistCvs2 = 0;
   }
   if( numOvCvs )
   {
      for( k=0; k<numOvCvs; ++k )      BSfreecv( &rc, OCvs[k] );
      _FREE( OCvs );
      numOvCvs = 0;
   }
   return retFlag;
}

#if 0
/* -----------------------------------------------
 * Finds where two curves overlap each other
 * In some cases, crv1 or crv2 may be returned
 * Calling routine needs to be careful when freeing
 */
IGRstat VSbevelGetCurveOverlap(TGRbsp_curve *crv1, 
			       TGRbsp_curve *crv2,
			       TGRobj_env   *macOE,
			       TGRbsp_curve **crv)
{
  VDASSERT_FN("VSbevelGetCurveOverlap");

  IGRstat retFlag = 0;
  
  struct {

    IGRdouble pt1[3],pt2[3];

    IGRdouble dis1,dis2;
    IGRdouble par1,par2;
    
  } c1,c2;
  
  IGRdouble tol = 5.0;  // This is pretty high but is what original code used
  IGRdouble dis;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }

  // Arg check
  VDASSERTW(crv); *crv = NULL;
  VDASSERTW(crv1);
  VDASSERTW(crv2);

  // Get end points
  VDgeomGetCrvPt(crv1,0.0,c1.pt1);
  VDgeomGetCrvPt(crv1,1.0,c1.pt2);
  VDgeomGetCrvPt(crv2,0.0,c2.pt1);
  VDgeomGetCrvPt(crv2,1.0,c2.pt2);
  
  // In many cases, curves match perfectly
  VDgeomGetDisPtPt(c1.pt1,c2.pt1,&dis);
  if (dis < tol) {
    VDgeomGetDisPtPt(c1.pt2,c2.pt2,&dis);
    if (dis < tol) {
      *crv = crv1;
      retFlag = 1;
      goto wrapup;
    }
  }
  VDgeomGetDisPtPt(c1.pt1,c2.pt2,&dis);
  if (dis < tol) {
    VDgeomGetDisPtPt(c1.pt2,c2.pt1,&dis);
    if (dis < tol) {
      *crv = crv1;
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // First curve may be inside of second curve
  VDgeomGetDisPtParCrv(c1.pt1,crv2,&c1.dis1,&c1.par1);
  VDgeomGetDisPtParCrv(c1.pt2,crv2,&c1.dis2,&c1.par2);
  if ((c1.dis1 < tol) && (c1.dis2 < tol)) {
    *crv = crv1;
    retFlag = 1;
    goto wrapup;
  }

  // Second curve may be inside of first curve
  VDgeomGetDisPtParCrv(c2.pt1,crv1,&c2.dis1,&c2.par1);
  VDgeomGetDisPtParCrv(c2.pt2,crv1,&c2.dis2,&c2.par2);
  if ((c2.dis1 < tol) && (c2.dis2 < tol)) {
    *crv = crv2;
    retFlag = 1;
    goto wrapup;
  }

  // Problems if both ends are out
  if ((c1.dis1 >= tol) && (c1.dis2 >= tol)) {
    
    // Complain
    printf("*** Edge curves do not overlap for \n");
    vdobj$Print(objOE = macOE);
    
    // Let it pass
    *crv = crv1;
    retFlag = 1;
    goto wrapup;
  }
     
  // They overlap so chop it
  VDgeomExtractCurve(crv1,c2.par1,c2.par2,crv);
  
  // Done
  retFlag = 1;

 wrapup:
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  return retFlag;
}

#endif

end implementation Root;

