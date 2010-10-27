/* $Id: VDcvgGeom.I,v 1.2 2001/01/11 19:18:52 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        VDcvgGeom.I
 *
 * Description: Some geometry routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcvgGeom.I,v $
 *      Revision 1.2  2001/01/11 19:18:52  art
 *      sp merge
 *
# Revision 1.3  2000/06/19  18:07:00  pinnacle
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
 * 01/13/00  ah      Creation
 *
 ***************************************************************************/

class implementation VDSroot;

#include "VDtypedef.h"
#include "VDgeom.h"
#include "VDmem.h"
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
#include "bsdistptpt.h"

#define M_PI            3.14159265358979323846
#define M_PI_2          1.57079632679489661923
#define M_PI_4          0.78539816339744830962

double tan (double);
double acos(double);

static int traceFlag;

from GRtext import GRgettxattr;

/* -----------------------------------------------
 * Returns the text string and attributes
 * if a text object
 */
IGRstat VDcvgGetTextInfo(TGRobj_env *a_textOE, 
			 TGRid      *a_textID, 
			 IGRchar    *a_textBuf, 
			 IGRint      a_textLen,
			 TGRestx    *a_textAttr)
{
  IGRstat   retFlag = 0;
  IGRstat   sts,msg;
  
  TGRid     textID;

  IGRuchar *str;
  IGRshort  len;
  IGRint    beg;
  
  TGRestx   attr;

  // Arg Init
  if (a_textBuf) *a_textBuf = 0;
  if (a_textAttr) memset(a_textAttr,0,sizeof(TGRestx));
  
  // Get the object
  textID.objid = NULL_OBJID;
  if (a_textOE) textID =  a_textOE->obj_id;
  if (a_textID) textID = *a_textID;
  if (textID.objid == NULL_OBJID) goto wrapup;

  // Get the text
  len = 0;
  str = NULL;
  
  sts = om$send(msg = message GRtext.
		GRgettxattr(&msg,
			    &attr,
			    &len,
			    &str),
	  senderid = NULL_OBJID,
	  targetid = textID.objid,
	  targetos = textID.osnum);
  
  if ((str == NULL) || (!(sts & 1))) goto wrapup;
  
  // Paranoid check
  if (attr.text_length < attr.num_char) attr.text_length = attr.num_char;
  
  beg = attr.text_length - attr.num_char;
  len = attr.num_char;
  
  // Check for overflow
  if (a_textLen > 0) {
    if (len >= a_textLen) len = a_textLen - 1;
  }
  
  // Damn thing is not null terminated!
  if (a_textBuf) {
    memcpy(a_textBuf,str + beg,len);
    *(a_textBuf + len) = 0;
  }
  free(str);

  // And the attributes
  if (a_textAttr) *a_textAttr = attr;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Gets the 2d rotational angle for a text matrix
 * Copied from Sherry's routine
 */
IGRstat VDcvgGet2DRotateAngle(IGRdouble mat[16], IGRdouble *angle)
{
  IGRstat   retFlag;
  IGRdouble cosAng;
  IGRdouble sinAng;
  IGRdouble tolAng;
  
  // Arg check
  retFlag = 0;
  if (angle == NULL) goto wrapup;
  *angle = 0.0;
  if (mat == NULL) goto wrapup;
  
  // Look for standard angles
  tolAng = .0001;
  cosAng = mat[0];
  sinAng = mat[4];
  
  if ((fabs(cosAng) < tolAng) &&
      (fabs(sinAng) < tolAng)) {
    goto wrapup;
  }
  if (fabs(cosAng) < tolAng) {
    if (sinAng > 0.0) *angle = M_PI * 0.5;
    else              *angle = M_PI * 1.5;
    retFlag = 1;
    goto wrapup;
  }
  if (fabs(sinAng) < tolAng) {
    if (cosAng > 0.0) *angle = 0.0;
    else              *angle = M_PI;
    retFlag = 1;
    goto wrapup;
  }
  
  // Not a special case
  *angle = atan(sinAng / cosAng);
  if (*angle > 0.0) {
    if (sinAng < 0.0) *angle = *angle + M_PI;
  }
  if (*angle < 0.0) {
    if (sinAng > 0.0) *angle = *angle +  M_PI;
    else              *angle = *angle + (M_PI * 2.0);
  }
    
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Grabs a set of points along the curve
 * Pts needs to have room for n points
 * n will usually be odd as first and last points are returned
 *
 * 18 April 2000 - Rewrite based on arc length
 */
IGRstat VDcvgGetListOfPoints(TGRbsp_curve *bsp, IGRint n, IGRdouble *pts)
{
  IGRstat retFlag = 0;
  IGRdouble par = 0.0;

  IGRdouble inc;
  IGRdouble len;
  
  IGRdouble totalLen;
  
  IGRint    i;
  
  // Arg check
  if (pts == NULL) goto wrapup;
  if (bsp == NULL) goto wrapup;
  if (n <= 1)      goto wrapup;
  
  // Get inc
  vdgeom$GetCrvArcLen(crv = bsp, len = &totalLen);
  inc = totalLen / (n - 1);

  // Do first and last just to avoid rounding issues
  VDgeomGetCrvPt(bsp,0.0,&pts[0]);
  VDgeomGetCrvPt(bsp,1.0,&pts[(n-1)*3]);
  
  // Cycle through
  for(i = 1; i < (n-1); i++) {
    len = i * inc;
    vdgeom$GetCrvArcParPt(crv = bsp, len = len, pt = &pts[i*3]);
  }

#if 0
  // Get Increment
  inc = 1.0 / (n-1);
  par = 0.0;
  for(i = 0; i < n; i++) {
    VDgeomGetCrvPt(bsp,par,&pts[i*3]);  
    par += inc;
  }
#endif

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Tests if a list of points are linear
 * Create a line segment and measure distance from it
 */
IGRstat VDcvgArePtsLinear(IGRint n, IGRdouble *pts, IGRdouble tol) 
{
  IGRstat   retFlag = 0;
#if 0
  IGRint    code;
  IGRpoint  pt;
  IGRvector vec;
  IGRdouble err;
  BSrc      rc;
#endif

  IGRchar       lineBuf[VDGEOM_SIZE_LINE];
  TGRbsp_curve *line = NULL;
  IGRpoint      pt;
  IGRint        i;
  IGRdouble     dis;

  // printf(">>> VDcvgArePtsLinear %d %.2f\n",n,tol);
  // tol = 0.7;
  
  // Make a line segment
  line = (TGRbsp_curve*)lineBuf;
  VDgeomMakeLineCurve(&pts[0],&pts[(n-1)*3],&line);

  // Check distance for each point
  for(i = 1; i < (n-1); i++) {
    VDgeomGetDisPtCrv(&pts[i*3],line,&dis);
    if (dis > tol) goto wrapup;
  }
  
  /* ---------------------------------------------
   * Original style, did not always work as desired
   */
#if 0
  BSlsqptlpl2(n,pts,NULL,2,&code,pt,vec,&err,&rc);

  if (rc != BSSUCC) goto wrapup;

  switch(code) {
  case 1:
  case 2:
    retFlag = 1;
    goto wrapup;
  case 4:  break;
  default: goto wrapup;
    
  }
  if (err > tol) goto wrapup;
#endif

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Tests if a list of points form an arc
 * Need an odd number of points
 */
IGRstat VDcvgArePtsArc(IGRint n, IGRdouble *pts, IGRdouble tol) 
{
  IGRstat   retFlag = 0;
  BSrc      rc;

  struct {
    IGRshort order;
    IGRlong  num_poles;
    IGRshort rational;
    IGRshort num_bound;

    TGRbsp_curve *bsp;
    IGRpoint      cen;
    IGRdouble     radius;
    
  } arc;

  IGRint    i;
  IGRdouble radius;
  
  // Init
  memset(&arc,0,sizeof(arc));
  
  /* Allocate room for arc */
  arc.order     = 4;
  arc.num_poles = 20;
  arc.rational  = 1;
  arc.num_bound = 0;
  arc.bsp       = NULL;

  BSalloccv(arc.order,
	    arc.num_poles,
	    arc.rational,
	    arc.num_bound,
	    &arc.bsp,
	    &rc);

  if (arc.bsp == NULL) {
    printf("Problem allocating arc geomotry\n");
    goto wrapup;
  }

  /* Arc It */
  BSarc3pts(&rc,&pts[0],&pts[(n/2)*3],&pts[(n-1)*3],arc.bsp);
  if (rc != BSSUCC) {
    // OK if it fails, might be linear set of points
    //printf("Problem Creating Arc\n");
    goto wrapup;
  }
  // vdgeom$Print(txt = "The arc", crv = arc.bsp);
  
  /* Get Center */
  BSarccen(&rc,arc.bsp,arc.cen);
  if (rc != BSSUCC) {
    printf("Problem Getting Center Of Arc\n");
    goto wrapup;
  }

  /* Get radius */
  arc.radius = BSdistptpt(&rc,&pts[(n/2)*3],arc.cen);
#if 0
  printf("Arc Created: %12.4f,%12.4f,%12.4f Radius: %12.4f\n",
	 arc.cen[0],
	 arc.cen[1],
	 arc.cen[2],
	 arc.radius);
#endif
  /* Now test to see if it is really an arc */
  for(i = 0; i < n; i++ ){
    
    radius = BSdistptpt(&rc,arc.cen,&pts[i*3]);
    
    if (fabs(radius - arc.radius) > tol) {
      // printf("Radius %2d %12.4f\n",i,radius);
      goto wrapup;
    }
  }
  
  // Done
  retFlag = 1;

wrapup:
  _FREECV(&rc,arc.bsp);
  
  return retFlag;
}

/* ------------------------------------------------
 * Given a production arc, return center and radius
 */
IGRstat VDcvgGetArcCenterRadius(TGRbsp_curve *bsp, IGRpoint cen, IGRdouble *radius) 
{
  IGRstat   retFlag = 0;
  BSrc      rc;

  struct {
    IGRshort order;
    IGRlong  num_poles;
    IGRshort rational;
    IGRshort num_bound;

    TGRbsp_curve *bsp;
    IGRpoint      cen;
    IGRdouble     radius;
  
    IGRpoint beg,ene,mid;
    
  } arc;

  IGRint    i;
  
  // Init
  memset(&arc,0,sizeof(arc));
  *radius = 0.0;
  for(i = 0; i < 3; i++) cen[i] = 0.0;
  
  // Allocate room for arc
  arc.order     = 4;
  arc.num_poles = 20;
  arc.rational  = 1;
  arc.num_bound = 0;
  arc.bsp       = NULL;

  BSalloccv(arc.order,
	    arc.num_poles,
	    arc.rational,
	    arc.num_bound,
	    &arc.bsp,
	    &rc);

  if (arc.bsp == NULL) {
    printf("Problem allocating arc geomotry\n");
    goto wrapup;
  }

  // Pull three points
  VDgeomGetCrvPt(bsp,0.0,arc.beg);
  VDgeomGetCrvPt(bsp,0.5,arc.mid);
  VDgeomGetCrvPt(bsp,1.0,arc.ene);

  /* Arc It */
  BSarc3pts(&rc,arc.beg,arc.mid,arc.ene,arc.bsp);

  if (rc != BSSUCC) {
    printf("Problem Creating Arc\n");
    goto wrapup;
  }
  // vdgeom$Print(txt = "The arc", crv = arc.bsp);
  
  /* Get Center */
  BSarccen(&rc,arc.bsp,cen);
  if (rc != BSSUCC) {
    printf("Problem Getting Center Of Arc\n");
    goto wrapup;
  }

  /* Get radius */
  *radius = BSdistptpt(&rc,arc.mid,cen);
  
  // Done
  retFlag = 1;

wrapup:
  _FREECV(&rc,arc.bsp);
  
  return retFlag;
}

/* --------------------------------------------------------
 * Finds the longest arc starting from the knot in question
 */
IGRstat VDcvgGetCrvInfo(TGRbsp_curve *bsp,          // I - Curve geometry
			IGRint        flag,         // I - 0=line,1=arc 
			IGRdouble     tol,          // I - Tolerance
                        IGRint        numPts,       // I - Number of points(max 50)
			IGRint        begKnotIndex, // I - Index of where to start
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
  
  IGRdouble par1,par2,par3,par3x;
  IGRint i,j;

  IGRdouble pts[50*3];
  
  //vdgeom$Print(crv = bsp, txt = "Check Curve ");

  // Say if
  if (traceFlag) printf(">>> Crv Info %d %2d\n",flag,begKnotIndex);
  
  // Init values
  memset(&crv,0,sizeof(crv));

  // Arg check
  if (bsp == NULL) goto wrapup;
  if (endKnotIndex == NULL) goto wrapup;
  *endKnotIndex = begKnotIndex;
  if ((begKnotIndex < 0) || (begKnotIndex >= bsp->num_knots)) goto wrapup;
  if (numPts > 50) numPts = 50;
  
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

  /* Setup Paraneters */
  par1 = bsp->knots[begKnotIndex];

  for(i = begKnotIndex+1; i < bsp->num_knots; i++) {

    par3 = bsp->knots[i];
    
    if (fabs(par3 - par1) > .001) {

      par2 = (par1 + par3) / 2.0;

      BSpartofcv(&rc,bsp,par1,par2,par3,crv.bsp);

      if (rc != BSSUCC) {
        printf("Problem Getting Part Of\n");
        goto wrapup;
      }

      // Get a list of points from it
      VDcvgGetListOfPoints(crv.bsp, numPts, pts);
	
      // Is it an line or arc######
      if (flag == 1) {
	sts = VDgeomIsCrvCirArc(crv.bsp,tol);
	if (sts == 2) sts = 1;
      }
      else           sts = VDgeomIsCrvLinear(crv.bsp,tol);

      if (!(sts & 1)) {
#if 0
	printf("-------- BEG ----------\n");
	vdgeom$Print(crv = crv.bsp);
	printf("-------- END ----------\n");
#endif
	goto wrapup; // First segment is neither
      }

      // Got one for sure
      *endKnotIndex = i;
      retFlag = 1;
      
      // Can additional segments be combined
      for(j = i + 1; j < bsp->num_knots; j++ ){

	par3x = bsp->knots[j];
	if (fabs(par3x - par3) > .001) {

	  par2 = (par1 + par3x) / 2.0;

	  BSpartofcv(&rc,bsp,par1,par2,par3x,crv.bsp);

	  // Get a list of points from it
	  VDcvgGetListOfPoints(crv.bsp, numPts, pts);

	  // Is the combined segment an arc
	  if (flag == 1) {
	    sts = VDgeomIsCrvCirArc(crv.bsp,tol);
	    if (sts == 2) sts = 1;
	  }
	  else           sts = VDgeomIsCrvLinear(crv.bsp,tol);

	  if (!(sts & 1)) goto wrapup;	  
	  *endKnotIndex = j;	  
	}
	par3 = par3x;
      }
      goto wrapup;
    }
  }

  // No first segment
  retFlag = 2;
  
wrapup:
  _FREECV(&rc,crv.bsp);
  if (traceFlag) printf("<<< Crv Info %d %2d %2d %d\n",flag,begKnotIndex,*endKnotIndex,retFlag);
  return retFlag;
}

end implementation VDSroot;
