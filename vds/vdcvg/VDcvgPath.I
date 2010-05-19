/* $Id: VDcvgPath.I,v 1.5 2001/10/26 19:54:18 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        VDsvgPath.I
 *
 * Description: Path oriented routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcvgPath.I,v $
 *      Revision 1.5  2001/10/26 19:54:18  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/09/04 19:53:23  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/05/21 12:54:49  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/11 19:18:53  art
 *      sp merge
 *
# Revision 1.5  2000/08/05  16:01:44  pinnacle
# ah
#
# Revision 1.4  2000/06/19  18:07:00  pinnacle
# ah
#
# Revision 1.3  2000/04/28  19:19:10  pinnacle
# ah
#
# Revision 1.2  2000/04/25  16:11:22  pinnacle
# ah
#
# Revision 1.1  2000/04/14  17:06:04  pinnacle
# ah
#
# Revision 1.1  2000/02/22  20:15:30  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/13/99  ah      Creation
 * 05/18/01  ah      TR5226 Need to dynamically allocate cusps for big curves
 * 09/04/01  ah      TR5550 Make all arcs less than or equal to 230 degrees
 * 10/26/01  ah      TR5702 Make sure arcs less than 150mm do not get broken
 ***************************************************************************/

class implementation VDSroot;

#include "VDtypedef.h"
#include "VDgeom.h"
#include "VDmem.h"

#include "VDxml.h"
#include "VDcvg.h"

#include "math.h"
#include "bspartofcv.h"
#include "bsalloccv.h"
#include "bslsqptlnpl.h"  // Does not work on 3 points
#include "bslsqptlpl2.h"
#include "bststcvfln.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bscrossp.h"
#include "bststcvarct.h"
#include "bsangqdofpt.h"

#include "bsarc3pts.h"
#include "bsarccen.h"
#include "bsarclen2.h"
#include "bsdistptpt.h"
#include "bsfndcvcsp.h"

#define M_PI            3.14159265358979323846
#define M_PI_2          1.57079632679489661923
#define M_PI_4          0.78539816339744830962

double tan (double);
double acos(double);

typedef struct 
{
  IGRdouble par;
  IGRpoint  pt;
  IGRvector vec;
} Tptvec;

static int traceFlag;

/* -----------------------------------------------
 * Writes a path header
 */
IGRstat VDcvgWritePathBeg(TVDcvgFileInfo *info)
{
  IGRstat retFlag = 0;
  TVDxmlFileInfo *xml = NULL;
  
  // Arg check
  if (info == NULL) goto wrapup;
  xml = &info->xml;
  
  // XML
  VDxmlWriteObjBeg(xml,XML_CVG_CURVE,0,1);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

IGRstat VDcvgWritePathEnd(TVDcvgFileInfo *info)
{
  IGRstat retFlag = 0;
  TVDxmlFileInfo *xml = NULL;
  
  // Arg check
  if (info == NULL) goto wrapup;
  xml = &info->xml;

  // XML
  VDxmlWriteObjEnd(xml,XML_CVG_CURVE,1);
      
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write a single point taking into account
 * transformation and scale factor
 */
IGRstat VDcvgWritePathVertex(TVDcvgFileInfo *info, 
			     IGRchar    cmd, 
			     IGRdouble *pt)
{
  IGRstat retFlag = 0;
  TVDxmlFileInfo *xml = NULL;
  
  // Arg check
  if (info == NULL) goto wrapup;
  xml = &info->xml;
  
  // XML
  switch(cmd) {

  case VDCVG_VERTEX_TYPE_MOVE_TO: 
    VDxmlWriteObjBeg(xml,XML_CVG_VERTEX,1,0);
    VDxmlWriteAtrTxt(xml,XML_CVG_VERTEX_TYPE,XML_CVG_VERTEX_TYPE_MOVE_TO,0,0);
    break;

  case VDCVG_VERTEX_TYPE_LINE_TO: 
    VDxmlWriteObjBeg(xml,XML_CVG_VERTEX,1,0);
    VDxmlWriteAtrTxt(xml,XML_CVG_VERTEX_TYPE,XML_CVG_VERTEX_TYPE_LINE_TO,0,0);
    break;

  default: goto wrapup;
    
  }
   

  VDxmlWriteAtrDbl(xml,XML_CVG_VERTEX_EX,pt[0],0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_VERTEX_EY,pt[1],0,0);
  
  VDxmlWriteAtrEnd(xml,0,0);
  VDxmlWriteObjEnd(xml,XML_CVG_VERTEX,0);

  // Debug
  //traceFlag = 1;
  if (traceFlag) {
    printf("VERTEX %c %12.3f %12.3f\n",cmd,pt[0],pt[1]);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
extern IGRdouble VDgeom2RadToDeg __((IGRdouble rad));

/* ------------------------------------
 * Write arc, already know it is an arc
 *
 * Break any arcs > 120 degrees into two arcs
 */
IGRstat VDcvgWritePathArc(TVDcvgFileInfo *info, TGRbsp_curve *bsp) 
{
  IGRstat retFlag = 0;
  IGRstat sts;
  BSrc    rc;

  IGRshort lineFlag;
  IGRpoint lineBeg,lineEnd;

  TGRbsp_curve *crv = NULL;
  IGRdouble parM;
  
  struct {
    IGRshort  flag;

    Tptvec beg,mid,ene,cen,dir; // end is reserved

    IGRdouble radius;
    IGRdouble angle;
    IGRdouble anglex;
    IGRdouble bulge;

    IGRboolean opt;
    IGRshort   quad;
    
    IGRint     large;  // True if > 180 degrees
    IGRint     sweep;  // 1 = Positive angle

    IGRdouble length;
    
  } arc;

  IGRint i;
  
  TVDxmlFileInfo *xml = NULL;
  
  // Arg check
  if (bsp == NULL)  goto wrapup;
  if (info == NULL) goto wrapup;
  xml = &info->xml;
  
  // Need point along arc, use .3 to get less then 180 degrees
  VDgeomGetCrvPt(bsp,0.0,arc.beg.pt);
  VDgeomGetCrvPt(bsp,0.5,arc.mid.pt); arc.mid.par = 0.5;
  VDgeomGetCrvPt(bsp,1.0,arc.ene.pt);

  // Bit more work on the mid point, use half of the arc length
  vdgeom$GetCrvArcLen(crv = bsp, len = &arc.length);
  arc.length *= 0.5;
  vdgeom$GetCrvArcParPt(crv = bsp, len = arc.length, pt = arc.mid.pt, par = &arc.mid.par);
  
  // Need center for other stuff
  VDcvgGetArcCenterRadius(bsp, arc.cen.pt, &arc.radius);
  
  // Sweep angle, always positive
  arc.opt = TRUE;
  BSangqdofpt(arc.opt,
	      arc.cen.pt,arc.beg.pt,arc.mid.pt,NULL,
	      arc.ene.pt,&arc.quad,&arc.angle,&rc);

  if (rc != BSSUCC) {
    printf("Problem with BSangqdofpt\n");
  }
  arc.anglex = VDgeom2RadToDeg(arc.angle);
  
  // printf("Arc Angle %.2f\n",arc.anglex);
  
  // Just to keep things simple, might want all angles less than 120 TR5550
  // TR5702, don't do this for small arcs
  if ((arc.anglex > 230.0) && (arc.length > 75.0)) {

    // Say hi
    // VLsmsLog1(1,1,"@@@ Breaking arc angle %.2f, %.2f\n",arc.anglex,arc.mid.par);
    
    // Holds shortest curve
    BSalloccv(bsp->order,bsp->num_poles + (bsp->order * 2) - 1,bsp->rational,0,&crv,&rc);
    if (rc != BSSUCC) {
      printf("Problem allocating new curve\n");
      goto wrapup;
    }
    // First half
    parM = arc.mid.par * .5;
    BSpartofcv(&rc,bsp,0.0,parM,arc.mid.par,crv);
    if (rc != BSSUCC) {
      printf("Problem breaking arc into smaller segments\n");
      goto wrapup;
    }
    VDcvgWritePathArc(info,crv);
    
    // Second half
    parM = ((1.0 - arc.mid.par) *.5) + arc.mid.par;
    BSpartofcv(&rc,bsp,arc.mid.par,parM,1.0,crv);
    if (rc != BSSUCC) {
      printf("Problem breaking arc into smaller segments\n");
      goto wrapup;
    }
    VDcvgWritePathArc(info,crv);

    // Done
    retFlag = 1;
    goto wrapup;
    
  }
  
  // A circle needs to be split into two curves
  if (fabs(arc.angle - (M_PI * 2.0)) < .01) {
    printf("Have a circle\n");
  }
  
  // Set to 1/4 tan
  arc.bulge = tan(arc.angle / 4.0);
  
  // Build vectors from center to arc points
  BSmkvec(&rc, arc.beg.vec, arc.cen.pt, arc.beg.pt);
  BSmkvec(&rc, arc.mid.vec, arc.cen.pt, arc.mid.pt);
  BSmkvec(&rc, arc.ene.vec, arc.cen.pt, arc.ene.pt);

  // The cross product should give the direction, 
  BScrossp(&rc,arc.beg.vec,arc.mid.vec,arc.dir.vec);

  // Exactly 180 can cause problems, thus use mid point
  if (arc.dir.vec[2] < 0.0) arc.bulge *= -1.0;

  // If the arc > 180 then normals are reversed
  // if (arc.angle > M_PI)     arc.bulge *= -1.0;
  
  // Large or not
  if (arc.angle <= M_PI) arc.large = 0;
  else                   arc.large = 1;
  
  // Sweep direction
  if (arc.bulge <= 0) arc.sweep = 0;
  else                arc.sweep = 1;
  
#if 0
  printf("------ Arc Dump ------\n");
  printf("Beg %8.2f %8.2f %8.2f\n",arc.beg.pt [0],arc.beg.pt [1],arc.beg.pt [2]);
  printf("Mid %8.2f %8.2f %8.2f\n",arc.mid.pt [0],arc.mid.pt [1],arc.mid.pt [2]);
  printf("End %8.2f %8.2f %8.2f\n",arc.ene.pt [0],arc.ene.pt [1],arc.ene.pt [2]);
  printf("Cen %8.2f %8.2f %8.2f\n",arc.cen.pt [0],arc.cen.pt [1],arc.cen.pt [2]);
  printf("Beg %8.2f %8.2f %8.2f\n",arc.beg.vec[0],arc.beg.vec[1],arc.beg.vec[2]);
  printf("End %8.2f %8.2f %8.2f\n",arc.ene.vec[0],arc.ene.vec[1],arc.ene.vec[2]);
  printf("Dir %8.2f %8.2f %8.2f\n",arc.dir.vec[0],arc.dir.vec[1],arc.dir.vec[2]);
  printf("Angle %f, Bulge %f\n",arc.angle,arc.bulge);
#endif

  // Write circular arc for xml file
  VDxmlWriteObjBeg(xml,XML_CVG_VERTEX,1,0);
  VDxmlWriteAtrTxt(xml,XML_CVG_VERTEX_TYPE,XML_CVG_VERTEX_TYPE_CARC_TO,0,1);
   
  VDxmlWriteAtrDbl(xml,XML_CVG_VERTEX_MX,arc.mid.pt[0],1,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_VERTEX_MY,arc.mid.pt[1],0,1);

  VDxmlWriteAtrDbl(xml,XML_CVG_VERTEX_EX,arc.ene.pt[0],1,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_VERTEX_EY,arc.ene.pt[1],0,1);

  VDxmlWriteAtrDbl(xml,XML_CVG_VERTEX_CX,arc.cen.pt[0],1,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_VERTEX_CY,arc.cen.pt[1],0,1);

  VDxmlWriteAtrDbl(xml,XML_CVG_VERTEX_RADIUS,    arc.radius,1,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_VERTEX_BULGE,     arc.bulge, 0,0);
  VDxmlWriteAtrDbl(xml,XML_CVG_VERTEX_INC_ANGLE, arc.angle, 0,0);

  VDxmlWriteAtrEnd(xml,0,1);
  VDxmlWriteObjEnd(xml,XML_CVG_VERTEX,1);
  
wrapup:

  _FREECV(&rc,crv);
  return retFlag;
}

#define NUM_PTS 9

/* --------------------------------------------------------
 * Finds the longest arc starting from the knot in question
 */
IGRstat VDcvgGetCrvInfox(TGRbsp_curve *bsp,          // I - Curve geometry
			 TVDgeomKnots *knots,
			 IGRdouble     tol,
			 IGRint        flag,         // I - 0=line,1=arc 
			 IGRint       *endKnotIndex) // O - Where it ended
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  BSrc rc;

  struct {
    IGRshort order;
    IGRlong  num_poles;
    IGRshort rational;
    IGRshort num_bound;
    TGRbsp_curve *bsp;
  } crv;
  
  IGRdouble par1,par2,par3;
  IGRint i;
  
  //vdgeom$Print(crv = bsp, txt = "Check Curve ");

  // Say if
  if (traceFlag) printf(">>> Crv Info %d %2d\n",flag,knots->i);
  
  // Init values
  memset(&crv,0,sizeof(crv));

  // Arg check
  if (bsp   == NULL) goto wrapup;
  if (knots == NULL) goto wrapup;
  if (endKnotIndex == NULL) goto wrapup;
  *endKnotIndex = knots->i;

  if ((knots->i + 1) >= knots->cnt) {
    retFlag = 2;
    goto wrapup;
  }
  
  // Holds shortest curve
  crv.order = 4;
  crv.num_poles = bsp->num_poles + (bsp->order * 2) - 1;
  crv.rational  = bsp->rational;
  crv.num_bound = 0;
  crv.bsp       = NULL;

  BSalloccv(crv.order,crv.num_poles,crv.rational,crv.num_bound,&crv.bsp,&rc);
  if (rc != BSSUCC) {
    printf("Problem allocating new curve\n");
    goto wrapup;
  }

  // See if first segment is either line or arc
  par1 = knots->knots[knots->i];
  par3 = knots->knots[knots->i + 1];
  par2 = (par1 + par3) / 2.0;

  BSpartofcv(&rc,bsp,par1,par2,par3,crv.bsp);

  if (rc != BSSUCC) {
    printf("Problem Getting Part Of\n");
    goto wrapup;
  }
	
  // Is it an line or arc######
  if (flag == 1) {
    sts = VDgeomIsCrvCirArc(crv.bsp,tol);
    if (sts == 2) sts = 1;
  }
  else sts = VDgeomIsCrvLinear(crv.bsp,tol);

  if (!(sts & 1)) {
    goto wrapup; // First segment failed
  }

  // Got one for sure
  *endKnotIndex = knots->i+1;
  retFlag = 1;
      
  // Can additional segments be combined
  for(i = knots->i+2; i < knots->cnt; i++ ){

    par3 = knots->knots[i];
    par2 = (par1 + par3) / 2.0;
    BSpartofcv(&rc,bsp,par1,par2,par3,crv.bsp);

    // Is the combined segment an arc
    if (flag == 1) {
      sts = VDgeomIsCrvCirArc(crv.bsp,tol);
      if (sts == 2) sts = 1;
    }
    else sts = VDgeomIsCrvLinear(crv.bsp,tol);
      
    if (!(sts & 1)) goto wrapup;	  
    *endKnotIndex = i;	  
  }
  
wrapup:
  _FREECV(&rc,crv.bsp);
  if (traceFlag) printf("<<< Crv Info %d %2d %2d %d\n",
			flag,knots->i,*endKnotIndex,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * This finds cases where the tip of a linear segment
 * starts to intrude on what should be an arc
 */
IGRstat VDcvgCheckForCusps(TVDcvgFileInfo *info,
			   TGRbsp_curve   *bsp,
			   TVDgeomKnots   *knots,
			   IGRint         *a_lineIndex)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint lineIndex,arcIndex;
  IGRint ix = knots->i;
  IGRdouble angle;
  
  for(knots->i++; knots->i < *a_lineIndex; knots->i++) {

    // Check for knuckle
    angle = 0.0;
    if ((knots->i+1) < knots->cnt) {
      
      VDgeomGetCurveAngle(bsp,
			  knots->knots[knots->i-1],
			  knots->knots[knots->i  ],
			  knots->knots[knots->i+1],
			  &angle);

      angle = VDgeomRadToDeg(angle);
#if 0
      printf("PARS  %3d, P1 %8.4f, P2 %8.4f, P3 %8.4f %12.4f\n",
	     knots->i,
	     knots->knots[knots->i-1],
	     knots->knots[knots->i  ],
	     knots->knots[knots->i+1],
	     angle);
#endif
    }
    if (angle < 179.5) {
      
      // Longest line or arc
      sts = VDcvgGetCrvInfox(bsp,knots,info->linearTol,0,&lineIndex);
      if (sts == 2) {
	retFlag = 1;
	goto wrapup; // Processed entire curve
      }
    
      sts = VDcvgGetCrvInfox(bsp,knots,info->arcTol,1,&arcIndex);
      if (sts == 2) {
	retFlag = 1;
	goto wrapup; // Processed entire curve
      }
      if (lineIndex < arcIndex) {

	// Re adjust
	//printf("Adjusting %3d %12.6f\n",knots->i,angle); 
	*a_lineIndex = knots->i;
	goto wrapup;
      }
    }
  }
  
  // Done

wrapup:
  knots->i = ix;
  return retFlag;
}

/* -----------------------------------
 * Breaks up curve into curves with no
 * internal knots then try and find the longest
 * linear or arc segment by putting back together
 *
 * Rewrite to use knot routines
 */
IGRstat VDcvgWritePathNthOrder(TVDcvgFileInfo *info, TGRbsp_curve *bsp)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  BSrc rc;

  struct {
    IGRshort order;
    IGRlong  num_poles;
    IGRshort rational;
    IGRshort num_bound;
    TGRbsp_curve *bsp;
  } crv;
  
  IGRint lineIndex,arcIndex;
  
  IGRpoint  pt;
  IGRdouble par,par1,par2,par3;

  TVDgeomKnots knots;
  IGRdouble    bufKnots[512];
  
  // vdgeom$Print(crv = bsp, txt = "Check Curve ");
  // printf(">>>  VDcvgWritePathNthOrder %.2f %.2f\n",info->linearTol,info->arcTol);
  
  /* Init values */
  memset(&crv,0,sizeof(crv));
  VDgeomInitKnots(&knots,bufKnots,512);

  // Arg check
  if (info == NULL) goto wrapup;
  if (bsp  == NULL) goto wrapup;
  
  // Holds shortest curve
  crv.order     = bsp->order;
  crv.num_poles = bsp->num_poles + (bsp->order * 2) - 1;
  crv.rational  = bsp->rational;
  crv.num_bound = 0;
  crv.bsp       = NULL;

  BSalloccv(crv.order,crv.num_poles,crv.rational,crv.num_bound,&crv.bsp,&rc);
  if (rc != BSSUCC) {
    printf("Problem allocating new curve\n");
    goto wrapup;
  }

  // List of knots (dups go away)
  vdgeom$GetKnotsFromCurve(crv = bsp, knots = &knots);
  
  // Basically process longest of line or arc
  for(knots.i = 0; knots.i < knots.cnt; knots.i++) {

    // Longest line or arc
    sts = VDcvgGetCrvInfox(bsp,&knots,info->linearTol,0,&lineIndex);
    if (sts == 2) {
      retFlag = 1;
      goto wrapup; // Processed entire curve
    }
    
    sts = VDcvgGetCrvInfox(bsp,&knots,info->arcTol,1,&arcIndex);
    if (sts == 2) {
      retFlag = 1;
      goto wrapup; // Processed entire curve
    }
    
    // Make sure have one or the other
    if (((lineIndex - knots.i) == 0) && ((arcIndex - knots.i) == 0)) {
      
      // Break into 2 and try again
      par1 = knots.knots[knots.i];
      par3 = knots.knots[knots.i+1];
      par3 = (par1 + par3) / 2.0;
      par2 = (par1 + par3) / 2.0;
      
      BSpartofcv(&rc,bsp,par1,par2,par3,crv.bsp);
      VDcvgWritePathNthOrder(info,crv.bsp);
      
      // 2nd Half
      par1 = knots.knots[knots.i];
      par3 = knots.knots[knots.i+1];
      par1 = (par1 + par3) / 2.0;
      par2 = (par1 + par3) / 2.0;
      
      BSpartofcv(&rc,bsp,par1,par2,par3,crv.bsp);
      VDcvgWritePathNthOrder(info,crv.bsp);
    }
    else {
      
      if (lineIndex >= arcIndex) {
	// printf("Line Index %2d\n",lineIndex);

	// Check for cusps where the first few knots are linear
	// When they should be part of the next arc
	VDcvgCheckForCusps(info,bsp,&knots,&lineIndex);
	
	// For a line, just dump the vertex
	//printf("PT,  i=%2d, index=%2d, numKnots=%2d, par = %8.5f\n",
	//     knots.i,lineIndex,knots.cnt,knots.knots[lineIndex]);
	
	par = knots.knots[lineIndex];
	//if (lineIndex +1 >= knots.cnt) par = 1.0;
	
	VDgeomGetCrvPt(bsp,par,pt);
	//printf("    %.2f,%.2f,%.2f\n",pt[0],pt[1],pt[2]);
	
	VDcvgWritePathVertex(info,VDCVG_VERTEX_TYPE_LINE_TO,pt);
	knots.i = lineIndex - 1;
      }
      else {

	//printf("Arc  Index %2d\n",arcIndex);
	// For an arc, need to calc some stuff
	//printf("ARC, i=%2d,index=%2d,numKnots=%2d\n",
	//     i,arcIndex,bsp->num_knots);

	par1 = knots.knots[knots.i];
	par3 = knots.knots[arcIndex];
	par2 = (par1 + par3) / 2;

	BSpartofcv(&rc,bsp,par1,par2,par3,crv.bsp);
	VDcvgWritePathArc(info,crv.bsp);

	knots.i = arcIndex - 1;
      }
    }
  }

  retFlag = 1;

wrapup:

  _FREECV(&rc,crv.bsp);
  VDgeomFreeKnots(&knots);
  
  return retFlag;
}

#if 0
/* -----------------------------------
 * Breaks up curve into curves with no
 * internal knots then try and find the longest
 * linear or arc segment by putting back together
 */
IGRstat VDcvgWritePathNthOrder(TVDcvgFileInfo *info, TGRbsp_curve *bsp)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  BSrc rc;

  struct {
    IGRshort order;
    IGRlong  num_poles;
    IGRshort rational;
    IGRshort num_bound;
    TGRbsp_curve *bsp;
  } crv;
  
  IGRint i,lineIndex,arcIndex,splitIndex;
  
  IGRpoint pt;
  IGRdouble par1,par2,par3;
  
  vdgeom$Print(crv = bsp, txt = "Check Curve ");
  // printf(">>>  VDcvgWritePathNthOrder %.2f %.2f\n",info->linearTol,info->arcTol);
  
  /* Init values */
  memset(&crv,0,sizeof(crv));

  // Arg check
  if (info == NULL) goto wrapup;
  if (bsp  == NULL) goto wrapup;
  
  // Holds shortest curve
  crv.order     = bsp->order;
  crv.num_poles = bsp->num_poles + (bsp->order * 2) - 1;
  crv.rational  = bsp->rational;
  crv.num_bound = 0;
  crv.bsp       = NULL;

  BSalloccv(crv.order,crv.num_poles,crv.rational,crv.num_bound,&crv.bsp,&rc);
  if (rc != BSSUCC) {
    printf("Problem allocating new curve\n");
    goto wrapup;
  }
  
  // Basically process longest of line or arc
  for(i = 1; i < bsp->num_knots; i++) {

    // Longest line or arc
    sts = VDcvgGetCrvInfo(bsp,0,info->linearTol,NUM_PTS,i,&lineIndex);
    if (sts == 2) {
      retFlag = 1;
      goto wrapup; // Processed entire curve
    }
    
    sts = VDcvgGetCrvInfo(bsp,1,info->arcTol,NUM_PTS,i,&arcIndex);
    if (sts == 2) {
      retFlag = 1;
      goto wrapup; // Processed entire curve
    }
    
    // Make sure have one or the other
    if (((lineIndex - i) == 0) && ((arcIndex - i) == 0)) {

      // Need next parameter value that is different
      par1 = bsp->knots[i];
      for(splitIndex = i + 1; 
	  (splitIndex < bsp->num_knots) && 
	  (fabs(par1 - bsp->knots[splitIndex]) < .001); 
	  splitIndex++);
      if (splitIndex >= bsp->num_knots) {
	printf("*** Problem with spplitting curve\n");
	goto wrapup;
      }
      
      // Break into 2 and try again
      par1 = bsp->knots[i];
      par3 = bsp->knots[splitIndex];
      par3 = (par1 + par3) / 2.0;
      par2 = (par1 + par3) / 2.0;
      
      BSpartofcv(&rc,bsp,par1,par2,par3,crv.bsp);

      //printf("Beg 1st Split %8.2f %8.2f\n",par1,par3);
      VDcvgWritePathNthOrder(info,crv.bsp);
      //printf("End 1st Split\n");
      
      par1 = bsp->knots[i];
      par3 = bsp->knots[splitIndex];
      par1 = (par1 + par3) / 2.0;
      par2 = (par1 + par3) / 2.0;
      
      BSpartofcv(&rc,bsp,par1,par2,par3,crv.bsp);
      //printf("Beg 2nd Split %8.2f %8.2f\n",par1,par3);
      VDcvgWritePathNthOrder(info,crv.bsp);
      //printf("Beg 2nd Split\n");

      i = splitIndex - 1;
      
    }
    else {
      
      if (lineIndex >= arcIndex) {
	//printf("Line Index %2d\n",lineIndex);

	// Check for cusps where the first few knots are linear
	// When they should be part of the next arc
	VDcvgCheckForCusps(info,bsp,i,&lineIndex);
	
	// For a line, just dump the vertex
	//printf("PT,  i=%2d,index=%2d,numKnots=%2d\n",
	//     i,lineIndex,bsp->num_knots);
	
	VDgeomGetCrvPt(bsp,bsp->knots[lineIndex],pt);
	VDcvgWritePathVertex(info,VDCVG_VERTEX_TYPE_LINE_TO,pt);
	i = lineIndex - 1;
      }
      else {

	//printf("Arc  Index %2d\n",arcIndex);
	// For an arc, need to calc some stuff
	//printf("ARC, i=%2d,index=%2d,numKnots=%2d\n",
	//     i,arcIndex,bsp->num_knots);

	par1 = bsp->knots[i];
	par3 = bsp->knots[arcIndex];
	par2 = (par1 + par3) / 2;

	BSpartofcv(&rc,bsp,par1,par2,par3,crv.bsp);
	VDcvgWritePathArc(info,crv.bsp);

	i = arcIndex - 1;
      }
    }
  }

  retFlag = 1;

wrapup:
  _FREECV(&rc,crv.bsp);
  return retFlag;
}
#endif

/* ----------------------------------------
 * Handles 2nd order non-rational
 */
IGRstat VDcvgWritePath2ndOrder(TVDcvgFileInfo *info, TGRbsp_curve *bsp) {

  IGRstat retFlag = 0;
  IGRint  i;
    
  IGRint    code;
  IGRpoint  pt;
  IGRvector vec;
  IGRdouble err;
  BSrc      rc;

  IGRint    numCusps;
  IGRdouble cusps[1000];
  
  // Arg check
  if (bsp  == NULL) goto wrapup;
  if (info == NULL) goto wrapup;
  
  // printf("Entered VPpdf2ndOrderCrv %d %d\n",bsp->order,bsp->num_poles);
  // see if 2nd order non-rational
  if (bsp->order != 2) goto wrapup;
  if (bsp->weights != NULL) {
    printf("Have a 2nd order RATIONAL curve???\n");
    goto wrapup;
  }

  /* ---------------------------------------------
   * Cusps don't work so good for line strings,
   * get em all over the place, can't use them for
   * breaking at corners
   *
   * Wonder if breaking the composite profile curve will work?
   *
   * So skip the cusp breaking routines in PathGeometry and write
   * the thing out directly
   */
  VDcvgWritePathNthOrder(info, bsp);
  retFlag = 1;
  if (1) goto wrapup;
  
#if 0
  numCusps = 0;  
  BSfndcvcsp(bsp,&numCusps,cusps,&rc);
  
  /* ------------------------------------------------
   * Many seemingly straight edges end up with hundreds
   * of poles, bounce against line tolerance to see if
   * it should be treated as a straight line
   *
   * A more advanced version might attempt to split the line if the
   * tolerance is exceeded but save that for later
   */
  BSlsqptlpl2(
    bsp->num_poles,bsp->poles,NULL,
    2,&code,
    pt,vec,&err,&rc);

  //printf("2nd Order, %d, %d, %.4f\n",bsp->num_poles,code,err);
  //vdgeom$Print(crv = bsp);
  
  if (err <= info->linearTol) {
    // Messes up on wl in 1038 pc 82
    //VDcvgWritePathVertex(file,VDCVG_VERTEX_TYPE_LINE_TO,&bsp->poles[(bsp->num_poles-1)*3]);
    //printf("Printed one pole\n");
    VDgeomGetCrvPt(bsp,1.0,pt);
    VDcvgWritePathVertex(info,VDCVG_VERTEX_TYPE_LINE_TO,pt);

    retFlag = 1;
    goto wrapup;
  }
  printf("Dumped 2nd order with %3d poles, %3d cusps\n",bsp->num_poles,numCusps);
  
  // Just dump out poles
  for(i = 1; i < bsp->num_poles; i++) {
    VDcvgWritePathVertex(info,VDCVG_VERTEX_TYPE_LINE_TO,&bsp->poles[3*i]);
  }
  retFlag = 1;
#endif

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Writes out parametric object
 */
IGRstat VDcvgWritePathSym(TVDcvgFileInfo *info,TVDgeomSym *sym)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint    flag;
  IGRdouble radius;
  IGRchar   type[32];
  
  TVDxmlFileInfo *xml = NULL;
  
  // Arg check
  if (info == NULL) goto wrapup;
  xml = &info->xml;
  if (sym == NULL)  goto wrapup;
  
  // Process different types
  switch(sym->type) {

    case VDGEOM_SYM_TYPE_CIRCLE:

      VDgeomGetDisPtPt(sym->center,sym->major,&radius);
      
      VDxmlWriteObjBeg(xml,XML_CVG_CURVE,1,0);
      VDxmlWriteAtrTxt(xml,XML_CVG_CURVE_TYPE,XML_CVG_CURVE_TYPE_CIRCLE,0,0);
      VDxmlWriteAtrDbl(xml,XML_CVG_CURVE_RADIUS,  radius,0,0);
      VDxmlWriteAtrDbl(xml,XML_CVG_CURVE_CENTER_X,sym->center[0],0,0);
      VDxmlWriteAtrDbl(xml,XML_CVG_CURVE_CENTER_Y,sym->center[1],0,0);
      VDxmlWriteAtrDbl(xml,XML_CVG_CURVE_CENTER_Z,sym->center[2],0,0);
      VDxmlWriteAtrEnd(xml,0,1);

      if (sym->bsp) VDcvgWritePathGeometry(info,0,sym->bsp);
      
      VDxmlWriteObjEnd(xml,XML_CVG_CURVE,1);
    
      break;

    case VDGEOM_SYM_TYPE_ELLIPSE:
    case VDGEOM_SYM_TYPE_OVAL:
  
      switch(sym->type) {
	case VDGEOM_SYM_TYPE_ELLIPSE: strcpy(type,XML_CVG_CURVE_TYPE_ELLIPSE); break;
	case VDGEOM_SYM_TYPE_OVAL:    strcpy(type,XML_CVG_CURVE_TYPE_OVAL);    break;
      }
      
      // Write it
      VDxmlWriteObjBeg(xml,XML_CVG_CURVE,1,0);
      VDxmlWriteAtrTxt(xml,XML_CVG_CURVE_TYPE,type,0,1);

      VDxmlWriteAtrDbl(xml,XML_CVG_CURVE_CENTER_X,sym->center[0],1,0);
      VDxmlWriteAtrDbl(xml,XML_CVG_CURVE_CENTER_Y,sym->center[1],0,0);
      VDxmlWriteAtrDbl(xml,XML_CVG_CURVE_CENTER_Z,sym->center[2],0,1);

      VDxmlWriteAtrDbl(xml,XML_CVG_CURVE_MAJOR_X, sym->major[0],1,0);
      VDxmlWriteAtrDbl(xml,XML_CVG_CURVE_MAJOR_Y, sym->major[1],0,0);
      VDxmlWriteAtrDbl(xml,XML_CVG_CURVE_MAJOR_Z, sym->major[2],0,1);

      VDxmlWriteAtrDbl(xml,XML_CVG_CURVE_MINOR_X, sym->minor[0],1,0);
      VDxmlWriteAtrDbl(xml,XML_CVG_CURVE_MINOR_Y, sym->minor[1],0,0);
      VDxmlWriteAtrDbl(xml,XML_CVG_CURVE_MINOR_Z, sym->minor[2],0,0);

      VDxmlWriteAtrEnd(xml,0,1);

      if (sym->bsp) VDcvgWritePathGeometry(info,0,sym->bsp);
      
      VDxmlWriteObjEnd(xml,XML_CVG_CURVE,1);
      break;
  
    default:
      // Not parametric???
      if (sym->bsp) VDcvgWritePathGeometry(info,-1,sym->bsp);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Write a geomotry path
 */
IGRstat VDcvgWritePathGeometry(TVDcvgFileInfo *info,
			       IGRint          nth,
			       TGRbsp_curve   *bsp)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  BSrc rc;
  IGRboolean arcStatus;
  
  struct {
    IGRshort order;
    IGRlong  num_poles;
    IGRshort rational;
    IGRshort num_bound;
    TGRbsp_curve *bsp;
  } crv;
  
  IGRint i;
  IGRpoint  pt;
  
  IGRdouble par1,par2,par3;
  IGRdouble arcLen;
  
  IGRdouble *cusps = NULL;
  IGRint    numCusps;
  
  // Init
  memset(&crv,0,sizeof(crv));
  
  // Arg check
  if ((info == NULL) || (bsp == NULL)) goto wrapup;
  
  // Begin path for self contained geometry
  if (nth < 0) VDcvgWritePathBeg(info);

  // Write first cooridinate for self contained or 1st geometry
  if (nth <= 0) {  
    VDgeomGetCrvPt(bsp,0.0,pt);
    VDcvgWritePathVertex(info,VDCVG_VERTEX_TYPE_MOVE_TO,pt);
  }

  /* -----------------------------------------------------------------
   * 08 Feb 2000, spades geomotry reader rejects anything under .75 mm
   * Put a check in here just to see the extent of the problem. 
   * Later might need better validation process to tell users where
   * the problem is.
   */
  par1 = .01;
  par2 = .50;
  par3 = .99;
  BSarclen2(&rc,&arcStatus,bsp,&par1,&par3,&par2,&arcLen);
  
  if (arcLen < 1.0) {

    if (arcLen > .01) {  
      printf("*** Small Non-Zero Arc Length %12.4f\n",arcLen);
    }

    /* -----------------------------------------
     * 19 Apr 2000 - Just skip it completely
     * Next segment will use it
     * Might be a problem for the very last one but oh well
     */

    // Just treat everything as a simple segment
    //pt[0] += 1.0;
    VDgeomGetCrvPt(bsp,1.0,pt);
    //VDcvgWritePathVertex(info,VDCVG_VERTEX_TYPE_LINE_TO,pt);
    goto all_done;
  }
   
  /* 2nd order curves are easy
   * Treat them as a special case because often get
   * line strings with hundreds of segments and the cusp
   * routine can get confused
   */
  sts = VDcvgWritePath2ndOrder(info,bsp);
  if (sts & 1) {
    //printf("Did a line string\n");
    goto all_done;
  }
  
  /* Want to make sure that all cusps are respected
   * Sometimes have problems when fitting arcs and end
   * up getting some of the straight segs included
   * because the tolerance is pretty loose
   */
  numCusps = 0;
  cusps = malloc(sizeof(IGRdouble)*(bsp->num_knots + 1));  // One case with 3100 !!!
  BSfndcvcsp(bsp,&numCusps,cusps,&rc);
  if (numCusps == 0) {
    
    /* More complicated curves */
    sts = VDcvgWritePathNthOrder(info,bsp);
    if (sts & 1) goto all_done;

    // Let it slide for now
    printf("*** Warning trouble printing cvg path\n");
  }
  // Dump out cusp info
#if 0
  printf("----- Cusp Info -----\n");
  for(i = 0; i < numCusps; i++) {
    par3 = cusps[i];
    VDgeomGetCrvPt(bsp,par3,pt);
    printf("Cusp %2d %10.2f %10.2f %10.2f %10.2f\n",i,par3,pt[0],pt[1],pt[2]);
  }
  printf("--\n");
#endif
  // Cycle and process each cusp
  par1 = 0.0;
  for(i = 0; i < numCusps; i++) {
    par3 = cusps[i];
    if (fabs(par3 - par1) > .001) {

      par2 = (par1 + par3) / 2.0;

      if (crv.bsp == NULL) {

	// Holds shortest curve
	crv.order     = bsp->order;
	crv.num_poles = bsp->num_poles + (bsp->order * 2) - 1;
	crv.rational  = bsp->rational;
	crv.num_bound = 0;
	crv.bsp       = NULL;

	BSalloccv(crv.order,crv.num_poles,crv.rational,crv.num_bound,&crv.bsp,&rc);
	if (rc != BSSUCC) {
	  printf("Problem allocating curve\n");
	  goto wrapup;
	}
      }
      /// printf("Cusp %2d %12.2f %12.2f\n",i,par1,par3);
      
      BSpartofcv(&rc,bsp,par1,par2,par3,crv.bsp);

      sts = VDcvgWritePathNthOrder(info,crv.bsp);
      if (!(sts & 1)) {

	// Let it slide for now
	printf("*** Warning trouble printing cvg path\n");
      }
      par1 = par3;
      
    }
  }
  
  // Need to pick up last
  if (par1 < .999) {

    par3 = 1.0;
    par2 = (par1 + par3) / 2.0;

    if (crv.bsp == NULL) {

      // Holds shortest curve
      crv.order     = bsp->order;
      crv.num_poles = bsp->num_poles + (bsp->order * 2) - 1;
      crv.rational  = bsp->rational;
      crv.num_bound = 0;
      crv.bsp       = NULL;

      BSalloccv(crv.order,crv.num_poles,crv.rational,crv.num_bound,&crv.bsp,&rc);
      if (rc != BSSUCC) {
	printf("Problem allocating curve\n");
	goto wrapup;
      }
    }
    // printf("Cusp %2d %12.2f %12.2f\n",i,par1,par3);
      
    BSpartofcv(&rc,bsp,par1,par2,par3,crv.bsp);

    sts = VDcvgWritePathNthOrder(info,crv.bsp);
    if (!(sts & 1)) {

      // Let it slide for noe
      printf("*** Warning trouble printing cvg path\n");
    }
  }
  
  // End of self contained
all_done:
  if (nth < 0) VDcvgWritePathEnd(info);
    
  // Done
  retFlag = 1;
  
wrapup:
  _FREECV(&rc,crv.bsp);
  if (cusps) free(cusps);
  
  return retFlag;
}

/* -----------------------------------------------
 * Write a graphic path object
 */
IGRstat VDcvgWritePathObject(TVDcvgFileInfo *info, 
			     IGRint          nth, 
			     TGRobj_env     *pathOE)
{
  IGRstat retFlag = 0;
  TGRbsp_curve *bsp = NULL;
  
  // Arg check
  if (info == NULL) goto wrapup;
  if ((pathOE == NULL) || (pathOE->obj_id.objid == NULL_OBJID)) goto wrapup;
  
  // Get the geometry
  vdgeom$Get2(objOE = pathOE, crv = &bsp);
  if (bsp == NULL) {
    printf("Problem getting geometry in VDcvgWritePathObject\n");
    goto wrapup;
  }
  //vdgeom$Print(crv = bsp);
  
  // Write it
  VDcvgWritePathGeometry(info,nth,bsp);
  
  // Done
  retFlag = 1;
  
wrapup:
  _FREE(bsp);
  
  return retFlag;
}

end implementation VDSroot;



