/***************************************************************************
 * I/VDS
 *
 * File:        vdval/x2/VDvalBsp.c
 *
 * Description: XML BSpline routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalBsp.c,v $
 *      Revision 1.5  2001/08/02 15:32:46  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/07/30 15:49:22  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/07/29 16:57:37  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/07/28 17:34:34  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/07/23 16:28:36  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/13/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDgeomc.h"
#include "VDval.h"

VDASSERT_FFN("VDvalBsp.c");

/* -----------------------------------------------
 * Append text string without constant reallocing
 */
static void appendText(IGRchar **buf, IGRint *pnt, IGRint *size, IGRint inc, IGRchar *txt)
{
  IGRint len;
  IGRchar *p;
  
  // Have room?
  len = strlen(txt);
  if (*pnt + len >= *size) {
    p = realloc(*buf,*size + inc);
    if (p == NULL) goto wrapup;
    *buf = p;
    *size = *size + inc;
  }
  strcpy(*buf + *pnt,txt);
  *pnt = *pnt + len;
  
 wrapup:
  return;
}

extern IGRdouble fabs(IGRdouble);

/* -----------------------------------------------
 * Convert double to text watching out for unusual values
 */
static void convertDoubleToText(IGRdouble val, IGRint dec, IGRchar *txt)
{
  IGRchar fmt[32];
  IGRchar buf[1024];
  IGRchar *p;
  
  // Some range checking
  if (val >  999999999.) val =  999999999.;
  if (val < -999999999.) val = -999999999.;
  if (fabs(val) < .0000001) val = 0.0;

  // Format it
  sprintf(fmt,"%%.%df",dec);
  sprintf(buf,fmt,val);

  // sprintf(buf,"%.14e",val);

  // Drop trailing zero's
  for(p = buf + strlen(buf) - 1 ; (p >= buf) && (*p == '0'); p--);

  // Tack on space
  if ((p < buf) || (*p != '.')) p++;
  strcpy(p," ");

  // Drop leading zero
  p = buf;
  if ((*p == '0') && (*(p+1) == '.')) p++;
  if ((*p == '-') && (*(p+1) == '0') && (*(p+2) == '.')) {
    p++;
    *p = '-';
  }

  // Done
  strcpy(txt,p);

 wrapup:  
  return;
}

/* -----------------------------------------------
 * Allow access to this for now
 */
void VDvalConvertDoubleToText(IGRdouble val, IGRint dec, IGRchar *txt)
{
  VDASSERT_FN("VDvalConvertDoubleToText");

  // Arg check
  VDASSERTW(txt); *txt = 0;
  
  convertDoubleToText(val,dec,txt);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Convert point to text
 */
void VDvalConvertPointToText(IGRpoint pt, IGRchar *txt)
{
  VDASSERT_FN("VDvalConvertPointToText");

  IGRchar buf[128];
  IGRint  i;
  
  // Arg check
  VDASSERTW(pt);
  VDASSERTW(txt);
  strcpy(txt,"igr_point3d");
  for(i = 0; i < 3; i++) {
    strcat(txt," ");
    convertDoubleToText(pt[i],3,buf);
    strcat(txt,buf);
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Convert text to point
 */
IGRstat VDvalConvertTextToPoint(IGRchar *txt, IGRpoint pt)
{
  VDASSERT_FN("VDvalConvertTextToPoint");
  IGRstat retFlag = 0;
  
  IGRchar *p = txt;
  
  // Arg check
  VDASSERTW(pt);
  VDASSERTW(txt);

  VDvalStripWhitespace(&p);
  if (strncasecmp(p,"igr_point3d ",12)) goto wrapup;
  p = strchr(p,' ');

  pt[0] = VDvalParseDouble(&p);
  pt[1] = VDvalParseDouble(&p);
  pt[2] = VDvalParseDouble(&p);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Convert bsp to text string
 */
void VDvalConvertBspCurveToText(TGRbsp_curve *crv, IGRchar **a_txt)
{
  VDASSERT_FN("VDvalConvertBspCurveToText");
  
  IGRchar *txt = NULL;
  IGRint   inc = 256;
  IGRint   pnt;
  IGRint   size;
  
  IGRchar buf[128];
  IGRint  i,j,k;

  IGRdouble delta;
  
  // Arg check
  VDASSERTW(a_txt); *a_txt = NULL;
  VDASSERTW(crv && crv->num_poles);
  
  // The basic header
  txt = malloc(inc);
  VDASSERTW(txt);
  sprintf(txt,
	  "bsp_curve3d order %d num_poles %d num_knots %d "
	  "rational %d periodic %d non_uniform %d "
	  "num_boundaries %d planar %d phy_closed %d ",
	  crv->order,         crv->num_poles,crv->num_knots,
	  crv->rational,      crv->periodic, crv->non_uniform,
	  crv->num_boundaries,crv->planar,   crv->phy_closed);

  // For variable buffer
  size = inc;
  pnt = strlen(txt);

  // Add poles
  appendText(&txt,&pnt,&size,inc,"poles ");
  
  // First pole
  for(k = 0; k < 3; k++) {  
    convertDoubleToText(crv->poles[k],3,buf);
    appendText(&txt,&pnt,&size,inc,buf);
  }

  // Deltas from the first pole
  for(i = 1; i < crv->num_poles; i++) {
    for(j = 0; j < 3; j++) {
      k = (i * 3) + j;
      delta = crv->poles[k] - crv->poles[j];
      convertDoubleToText(delta,3,buf);
      appendText(&txt,&pnt,&size,inc,buf);
    }
  }
  
  // Add knots
  appendText(&txt,&pnt,&size,inc,"knots ");
  for(i = 0; i < crv->num_knots; i++) {
    convertDoubleToText(crv->knots[i],9,buf);
    appendText(&txt,&pnt,&size,inc,buf);
  }

  // Add Weights
  if (crv->weights) {  
    appendText(&txt,&pnt,&size,inc,"weights ");
    for(i = 0; i < crv->num_poles; i++) {
      convertDoubleToText(crv->weights[i],9,buf);
      appendText(&txt,&pnt,&size,inc,buf);
    }
  }
  
  // Add boundary
  if (crv->bdrys) {  
    appendText(&txt,&pnt,&size,inc,"boundaries ");
    for(i = 0; i < crv->num_boundaries; i++) {
      j = i * 2;
      convertDoubleToText(crv->bdrys[j+0],9,buf);
      appendText(&txt,&pnt,&size,inc,buf);
      convertDoubleToText(crv->bdrys[j+1],9,buf);
      appendText(&txt,&pnt,&size,inc,buf);
    }
  }
  appendText(&txt,&pnt,&size,inc,"done");
  
  // Done
  *a_txt = txt;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Convert a text string to xml
 */
void VDvalConvertTextToBspCurve(IGRchar *txt, TGRbsp_curve **a_crv)
{
  VDASSERT_FN("VDvalConvertTextToBspCurve");

  TGRbsp_curve *crv = NULL;
  TGRbsp_curve  crvx;
  
  IGRchar *p = txt;
  
  IGRchar buf[128];
  
  IGRint i,j,k;
  
  // Arg check
  VDASSERTW(a_crv); *a_crv = NULL;
  VDASSERTW(txt);
  
  // Is it a curve
  VDvalStripWhitespace(&p);
  if (strncasecmp(p,"bsp_curve3d ",12)) goto wrapup;
  p = strchr(p,' ');
  
  // Assorted variables
  VDvalParseText(&p,buf); crvx.order          = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); crvx.num_poles      = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); crvx.num_knots      = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); crvx.rational       = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); crvx.periodic       = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); crvx.non_uniform    = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); crvx.num_boundaries = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); crvx.planar         = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); crvx.phy_closed     = VDvalParseInteger(&p);
  
  // Alloc the curve
  VDgeom2AllocCurveMaster(crvx.order,
			  crvx.num_poles,
			  crvx.rational,
			  crvx.num_boundaries,
			  0,&crv,NULL,0,NULL);
  VDASSERTW(crv);
  crv->order          = crvx.order;
  crv->num_poles      = crvx.num_poles;
  crv->num_knots      = crvx.num_knots;  
  crv->rational       = crvx.rational;
  crv->periodic       = crvx.periodic;
  crv->non_uniform    = crvx.non_uniform;
  crv->planar         = crvx.planar;
  crv->phy_closed     = crvx.phy_closed;
  crv->num_boundaries = crvx.num_boundaries;
  
  // The poles delta from the first pole
  VDvalParseText(&p,buf);
  for(i = 0; i < crv->num_poles; i++) {
    for(j = 0; j < 3; j++) {
      k = (i * 3) + j;
      crv->poles[k] = VDvalParseDouble(&p);
      if (i) crv->poles[k] += crv->poles[j];
    }
  }
  
  // The knots
  VDvalParseText(&p,buf);
  for(i = 0; i < crv->num_knots; i++) {
    crv->knots[i] = VDvalParseDouble(&p);
  }

  // The weights
  if (crv->rational) {
    VDvalParseText(&p,buf);
    for(i = 0; i < crv->num_poles; i++) {
      crv->weights[i] = VDvalParseDouble(&p);
    }
  }
  // The boundaries
  if (crv->num_boundaries) {
    VDvalParseText(&p,buf);
    for(i = 0; i < crv->num_boundaries; i++) {
      j = i * 2;
      crv->bdrys[j+0] = VDvalParseDouble(&p);
      crv->bdrys[j+1] = VDvalParseDouble(&p);
    }
  }
  
  VDvalParseText(&p,buf);
#if 0
  printf("Curve order %d, poles %d, rational %d, Marker %s\n",
	 crvx.order,crvx.num_poles,crvx.rational,buf);
#endif
  // Done
  *a_crv = crv;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Returns the total number of bytes needed to hold
 * a surface in contigiuous memory, similiar to GRbc_size
 */
static void GRbs_size(TGRbsp_surface *srf, IGRint *num_list, IGRint *a_size)
{
  VDASSERT_FN("GRbs_size");
  
  IGRint size;
  IGRint i,cnt;
  IGRint num_poles;
  
  // Arg check
  VDASSERTW(a_size);*a_size = 0;
  VDASSERTW(srf);
  
  size = sizeof(TGRbsp_surface);
  
  num_poles = srf->u_num_poles * srf->v_num_poles;
  size += (num_poles * sizeof(IGRdouble) * 3);

  size += ((srf->u_num_knots + srf->v_num_knots) * sizeof(IGRdouble));
  
  if (srf->rational) size += (num_poles * sizeof(IGRdouble));
  
  size += (srf->num_boundaries * sizeof(struct IGRbsp_bdry_pts));

  cnt = 0;
  for(i = 0; i < srf->num_boundaries; i++) {
    cnt += num_list[i];
  }
  size += (cnt * 2 * sizeof(IGRdouble));
  
  // Done
  *a_size = size;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Partition the surface using the template as guidance
 */
static void GRbs_partition(TGRbsp_surface *srfx, IGRint *num_list, TGRbsp_surface *srf)
{
  VDASSERT_FN("GRbs_partition");
  
  IGRchar *p;
  IGRint  num_poles;
  IGRint  i;
  
  // Arg check
  VDASSERTW(srf); memset(srf,0,sizeof(TGRbsp_surface));
  VDASSERTW(srfx);

  // Xfer main values
  *srf = *srfx;
  
  // Poles
  p = (IGRchar*)srf + sizeof(TGRbsp_surface);
  srf->poles = (IGRdouble*)p;

  num_poles = srf->u_num_poles * srf->v_num_poles;
  p += num_poles * sizeof(IGRdouble) * 3;
  
  // Weights
  if (srf->rational) {
    srf->weights = (IGRdouble*)p;
    p += num_poles * sizeof(IGRdouble);
  }
  
  // Knots
  srf->u_knots = (IGRdouble *)p;
  p += srf->u_num_knots * sizeof(IGRdouble);
  srf->v_knots = (IGRdouble *)p;
  p += srf->v_num_knots * sizeof(IGRdouble);

  // Boundaries
  if (srf->num_boundaries == 0) goto wrapup;
  srf->bdrys = (struct IGRbsp_bdry_pts *)p;
  p+= srf->num_boundaries * sizeof(struct IGRbsp_bdry_pts);
  
  for(i = 0; i < srf->num_boundaries; i++) {
    srf->bdrys[i].num_points = num_list[i];
    srf->bdrys[i].points = (IGRdouble *)p;
    p += srf->bdrys[i].num_points * sizeof(IGRdouble) * 2;
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Use this to free a surface created with  VDvalConvertTextToBspSurface
 */
void VDvalFreeBspSurface(TGRbsp_surface *srf)
{
  VDASSERT_FN("VDvalFreeBspSurface");

  IGRint i;
  
  // Arg check
  VDASSERTW(srf);
  
  // Boundaries
  if (srf->bdrys) {
    for(i = 0; i < srf->num_boundaries; i++) {
      if (srf->bdrys[i].points) free(srf->bdrys[i].points);
    }
    free(srf->bdrys);
  }
  if (srf->weights) free(srf->weights);
  if (srf->v_knots) free(srf->v_knots);
  if (srf->u_knots) free(srf->u_knots);
  if (srf->poles)   free(srf->poles);
  
  free(srf);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Convert a surface text string to xml
 */
void VDvalConvertTextToBspSurface(IGRchar *txt, TGRbsp_surface **a_srf)
{
  VDASSERT_FN("VDvalConvertTextToBspSurface");

  TGRbsp_surface *srf = NULL;
  TGRbsp_surface  srfx;
  
  IGRchar *p = txt;
  
  IGRchar buf[128];
  
  IGRint i,j,k;
  IGRint num_poles;
  
  IGRint *num_bdrys_list = NULL;
  IGRint  num_list[20];
  
  IGRint size;
  
  // Arg check
  VDASSERTW(a_srf); *a_srf = NULL;
  VDASSERTW(txt);

  // Is it a curve
  VDvalStripWhitespace(&p);
  if (strncasecmp(p,"bsp_surface3d ",14)) goto wrapup;
  p = strchr(p,' ');
  
  // Assorted variables
  memset(&srfx,0,sizeof(TGRbsp_surface));
  VDvalParseText(&p,buf); srfx.u_order        = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.v_order        = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.u_num_poles    = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.v_num_poles    = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.u_num_knots    = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.v_num_knots    = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.u_periodic     = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.v_periodic     = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.u_non_uniform  = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.v_non_uniform  = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.u_phy_closed   = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.v_phy_closed   = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.rational       = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.planar         = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.pos_orient     = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.on_off         = VDvalParseInteger(&p);
  VDvalParseText(&p,buf); srfx.num_boundaries = VDvalParseInteger(&p);

  // Deal with boundaries
  if (srfx.num_boundaries > 20) num_bdrys_list = malloc(srfx.num_boundaries * sizeof(IGRint));
  else                          num_bdrys_list = num_list;
  
  for(i = 0; i < srfx.num_boundaries; i++) {
    num_bdrys_list[i] = VDvalParseInteger(&p);
  }
  
  // Alloc and partition
#if 0
  GRbs_size(&srfx,num_bdrys_list,&size);
  srf = malloc(size);
  VDASSERTW(srf);
  GRbs_partition(&srfx,num_bdrys_list,srf);
#endif
  // The poles
  num_poles = srfx.u_num_poles * srfx.v_num_poles;

  // Alloc surface
  srf = malloc(sizeof(TGRbsp_surface));
  *srf = srfx;
  
  if (num_poles) {
    srf->poles = malloc(sizeof(IGRdouble) * num_poles * 3);
    if (srf->rational) srf->weights = malloc(sizeof(IGRdouble) * num_poles);
  }
  if (srf->u_num_knots) srf->u_knots = malloc(sizeof(IGRdouble) * srf->u_num_knots);
  if (srf->v_num_knots) srf->v_knots = malloc(sizeof(IGRdouble) * srf->v_num_knots);
  if (srf->num_boundaries) {
    srf->bdrys = malloc(sizeof(struct IGRbsp_bdry_pts) * srf->num_boundaries);
    for(i = 0; i < srf->num_boundaries; i++) {
      srf->bdrys[i].points = malloc(sizeof(IGRdouble) * num_bdrys_list[i] * 2);
      srf->bdrys[i].num_points = num_bdrys_list[i];
    }
  }
  
    
  // The poles delta from the first poles
  VDvalParseText(&p,buf);
  for(i = 0; i < num_poles; i++) {
    for(j = 0; j < 3; j++) {
      k = (i*3) + j;
      srf->poles[k] = VDvalParseDouble(&p);
      if (i) srf->poles[k] += srf->poles[j]; 
    }
  }

  // The knots
  VDvalParseText(&p,buf);
  for(i = 0; i < srf->u_num_knots; i++) {
    srf->u_knots[i] = VDvalParseDouble(&p);
  }
  VDvalParseText(&p,buf);
  for(i = 0; i < srf->v_num_knots; i++) {
    srf->v_knots[i] = VDvalParseDouble(&p);
  }

  // The weights
  if (srf->rational) {
    VDvalParseText(&p,buf);
    for(i = 0; i < num_poles; i++) {
      srf->weights[i] = VDvalParseDouble(&p);
    }
  }

  // The boundaries (num_points filled in by GRbs_partition
  for(i = 0; i < srf->num_boundaries; i++) {
    VDvalParseText(&p,buf);
    for(j = 0; j < srf->bdrys[i].num_points; j++) {      
      k = j * 2;
      srf->bdrys[i].points[k+0] = VDvalParseDouble(&p);
      srf->bdrys[i].points[k+1] = VDvalParseDouble(&p);
    }
  } 
  VDvalParseText(&p,buf);

#if 0
  printf("Surface poles %d, rational %d, Marker %s\n",
	 num_poles,srfx.rational,buf);
#endif

  // Done
  *a_srf = srf;
  
 wrapup:
  if ((num_bdrys_list) && (num_bdrys_list != num_list)) free(num_bdrys_list);
  return;
}

/* -----------------------------------------------
 * Convert bsp to text string
 */
void VDvalConvertBspSurfaceToText(TGRbsp_surface *srf, IGRchar **a_txt)
{
  VDASSERT_FN("VDvalConvertBspSurfaceToText");
  
  IGRchar *txt = NULL;
  IGRint   inc = 512;
  IGRint   pnt;
  IGRint   size;
  
  IGRchar buf[128];
  IGRint  i,j,k;

  IGRint num_poles;

  IGRdouble delta;
  
  // Arg check
  VDASSERTW(a_txt); *a_txt = NULL;
  VDASSERTW(srf);

  if (traceFlag) printf(">>> VDvalConvertBspSurfaceToText\n");
  
  // The basic header
  txt = malloc(inc);
  VDASSERTW(txt);
  sprintf(txt,
	  "bsp_surface3d "
	  "u_order %d v_order %d "
	  "u_num_poles %d v_num_poles %d "
	  "u_num_knots %d v_num_knots %d "
	  "u_periodic %d v_periodic %d "
	  "u_non_uniform %d v_non_uniform %d "
	  "u_phy_closed %d v_phy_closed %d "
	  "rational %d "
	  "planar %d "
	  "pos_orient %d "
	  "pos_on_off %d "
	  "num_boundaries %d ",

	  srf->u_order,      srf->v_order,
	  srf->u_num_poles,  srf->v_num_poles,
	  srf->u_num_knots,  srf->v_num_knots,
	  srf->u_periodic,   srf->v_periodic,
	  srf->u_non_uniform,srf->v_non_uniform,
	  srf->u_phy_closed, srf->v_phy_closed,
	  srf->rational,
	  srf->planar,
	  srf->pos_orient,
	  srf->on_off,
	  srf->num_boundaries);
  
  // For variable buffer
  size = inc;
  pnt = strlen(txt);

  // Add boundary point counts
  for(i = 0; i < srf->num_boundaries; i++) {
    sprintf(buf,"%d ",srf->bdrys[i].num_points);
    appendText(&txt,&pnt,&size,inc,buf);
  }
  
  // Add poles
  appendText(&txt,&pnt,&size,inc,"poles ");
  num_poles = srf->u_num_poles *  srf->v_num_poles;
  VDASSERTW(num_poles);
  
  // First pole
  for(k = 0; k < 3; k++) {
    convertDoubleToText(srf->poles[k],3,buf);
    appendText(&txt,&pnt,&size,inc,buf);
  }
  // Rest are delta from the first pole
  for(i = 1; i < num_poles; i++) {
    for(j = 0; j < 3; j++) {
      k = (i * 3) + j;
      delta = srf->poles[k] - srf->poles[j]; 
      convertDoubleToText(delta,3,buf);
      appendText(&txt,&pnt,&size,inc,buf);
    }
  }

  // Add knots
  appendText(&txt,&pnt,&size,inc,"u_knots ");
  for(i = 0; i < srf->u_num_knots; i++) {
    convertDoubleToText(srf->u_knots[i],9,buf);
    appendText(&txt,&pnt,&size,inc,buf);
  }
  appendText(&txt,&pnt,&size,inc,"v_knots ");
  for(i = 0; i < srf->v_num_knots; i++) {
    convertDoubleToText(srf->v_knots[i],9,buf);
    appendText(&txt,&pnt,&size,inc,buf);
  }

  // Add Weights
  if (srf->weights) {  
    appendText(&txt,&pnt,&size,inc,"weights ");
    for(i = 0; i < num_poles; i++) {
      convertDoubleToText(srf->weights[i],9,buf);
      appendText(&txt,&pnt,&size,inc,buf);
    }
  }

  // Add boundary
  if (srf->bdrys) {
    for(i = 0; i < srf->num_boundaries; i++) {
      appendText(&txt,&pnt,&size,inc,"boundary ");
      for(j = 0; j < srf->bdrys[i].num_points; j++) {
	k = j * 2;
	convertDoubleToText(srf->bdrys[i].points[k+0],9,buf);
	appendText(&txt,&pnt,&size,inc,buf);
	convertDoubleToText(srf->bdrys[i].points[k+1],9,buf);
	appendText(&txt,&pnt,&size,inc,buf);
      }
    }
  }

  appendText(&txt,&pnt,&size,inc,"done");
  
  // Done
  *a_txt = txt;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Convert array of 3d points to text
 */
void VDvalConvertPointsToText(IGRint cnt, IGRdouble *pts, IGRchar **a_txt)
{
  VDASSERT_FN("VDvalConvertPointsToText");
  
  IGRchar *txt = NULL;
  IGRint   inc = 64;
  IGRint   pnt;
  IGRint   size;
  
  IGRchar buf[128];
  IGRint  i;
  
  // Arg check
  VDASSERTW(a_txt); *a_txt = NULL;
  VDASSERTW(cnt && pts);

  if (traceFlag) printf(">>> %s\n",fn);
  
  // The basic header
  txt = malloc(inc);
  VDASSERTW(txt);
  sprintf(txt,"igr_points3d %d ",cnt);
  
  // Cycle through
  size = inc;
  pnt = strlen(txt);

  cnt *= 3;
  for(i = 0; i < cnt; i++) {
    convertDoubleToText(pts[i],3,buf);
    appendText(&txt,&pnt,&size,inc,buf);
  }
  
  // Done
  *a_txt = txt;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Convert text to point
 * Call once toget the count, alloc then call again
 */
IGRstat VDvalConvertTextToPoints(IGRchar *txt, IGRint *a_cnt, IGRdouble *pts)
{
  VDASSERT_FN("VDvalConvertTextToPoints");
  IGRstat retFlag = 0;
  
  IGRchar *p = txt;
  
  IGRint cnt = 0;
  IGRint i;
  
  // Arg check
  if (a_cnt) *a_cnt = 0;
  VDASSERTW(txt);
  
  VDvalStripWhitespace(&p);
  if (strncasecmp(p,"igr_points3d ",13)) goto wrapup;
  retFlag = 1;

  // The count
  p = strchr(p,' ');
  cnt = VDvalParseInteger(&p);
  if (a_cnt) *a_cnt = cnt;

  // Want points?
  if (pts == NULL) goto wrapup;

  // Get em
  cnt *= 3;
  for(i = 0; i < cnt; i++) {
    pts[i] = VDvalParseDouble(&p);
  }
    
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Pump out an array of points
 */
void VDvalConvertDoublesToText(IGRint cnt, IGRdouble *dbls, IGRint dec, IGRchar **a_txt)
{
  VDASSERT_FN("VDvalConvertDoublesToText");
  
  IGRchar *txt = NULL;
  IGRint   inc = 64;
  IGRint   pnt;
  IGRint   size;
  
  IGRchar buf[128];
  IGRint  i;
  
  // Arg check
  VDASSERTW(a_txt); *a_txt = NULL;
  VDASSERTW(cnt && dbls);

  if (traceFlag) printf(">>> %s\n",fn);
  
  // The basic header
  txt = malloc(inc);
  VDASSERTW(txt);
  sprintf(txt,"doubles %d ",cnt);
  
  // Cycle through
  size = inc;
  pnt = strlen(txt);

  for(i = 0; i < cnt; i++) {
    convertDoubleToText(dbls[i],dec,buf);
    appendText(&txt,&pnt,&size,inc,buf);
  }
  
  // Done
  *a_txt = txt;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Convert text to doubles
 * Call once toget the count, alloc then call again
 */
IGRstat VDvalConvertTextToDoubles(IGRchar *txt, IGRint *a_cnt, IGRdouble *dbls)
{
  VDASSERT_FN("VDvalConvertTextToPoints");
  IGRstat retFlag = 0;
  
  IGRchar *p = txt;
  
  IGRint cnt = 0;
  IGRint i;
  
  // Arg check
  if (a_cnt) *a_cnt = 0;
  VDASSERTW(txt);
  
  VDvalStripWhitespace(&p);
  if (strncasecmp(p,"doubles ",8)) goto wrapup;
  retFlag = 1;

  // The count
  p = strchr(p,' ');
  cnt = VDvalParseInteger(&p);
  if (a_cnt) *a_cnt = cnt;

  // Want values?
  if (dbls == NULL) goto wrapup;

  // Get em
  for(i = 0; i < cnt; i++) {
    dbls[i] = VDvalParseDouble(&p);
  }
    
 wrapup:
  return retFlag;
}
