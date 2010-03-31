/* ###################   APOGEE COMPILED   ################## */
/*
History
	SM	Long Ago	Creation.
        Sudha   07/09/93        Modified for BSprototypes anisfication

*/

class implementation Root;

#include "EMS.h"
# include "OMerrordef.h" /* OM message codes */

%safe
#include <math.h>
%endsafe

#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "emsdattyp.h"
#include "emsinter.h"
/*#include "emsdef.h"*/
#include "emserr.h"
#include "EMSerrnumdef.h"
#include "EMSerrordef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfint.h"
#include "bspolyxttpt.h"
#include "bsfreecv.h"
#include "bschgdeppar.h"
#include "bsalloccv.h"

#ifndef DEBUG
#define DEBUG 0
#endif

%safe
static IGRdouble DIST();
%endsafe

from GRvg import GRpostabsg;

IGRint EMextend_poly(EMmsg, dim, inpoly, outpoly, extnd_pt, location, 
		      replace_endpt, mindist, outpypt, lentol, check_dist)
 IGRlong		*EMmsg;
 IGRint			dim;
 struct IGRpolyline	*inpoly, *outpoly;
 IGRdouble		*extnd_pt, *mindist, lentol;
 IGRint			*location;
 IGRboolean		replace_endpt;
 struct EMSpypoint	*outpypt;
 IGRboolean		check_dist;
{
 IGRlong		sts;
 struct EMSpypoint	loc_pyspace;
 IGRdouble		loc_mindist, *endpt, DIST(), dist, *new_pts, 
			dist1, dist2;
 IGRint			ptsize, from_ptinx, to_ptinx, num_pts = 0;
 IGRint			loc_location = UNKNOWN, 
			inx = 0, tot_pts = 0;

 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 new_pts = NULL;
 ptsize = dim * sizeof(IGRdouble);

 if(!outpypt) outpypt = &loc_pyspace;
 if(!mindist) mindist = &loc_mindist;
 if(!location) location = &loc_location;

 if(*location == UNKNOWN)
  {
   if( (dist1 = DIST(dim, extnd_pt, inpoly->points)) < 
       (dist2 = DIST(dim, extnd_pt, 
		&inpoly->points[inpoly->num_points * dim - dim])))
    *location = BEGIN;
   else *location = END;
  }

 if(*location == BEGIN)
   endpt = inpoly->points;
 else 
   endpt = &inpoly->points[inpoly->num_points * dim - dim];

 /* If the input point is within tolerance from the specified endpoint, 
    then exit.
 */
 if( check_dist && (dist1 = DIST(dim, endpt, extnd_pt)) < lentol)
  {*EMmsg = EMS_I_Degenerate; goto wrapup;}

 /* If the suitable end point is just to be replaced by the extnd_pt, do
    so and exit.
 */
 if(replace_endpt)
  {
   OM_BLOCK_MOVE(extnd_pt, endpt, ptsize);
   return(sts);
  }

 /* Project the extend point onto the polyline.
 */
 EMcnvtpypts(EMmsg, inpoly, dim, 1, extnd_pt, lentol, outpypt, mindist);
 if(!(1&*EMmsg)) goto wrapup;

 /* If the point is projected at the end point, replace the end point with
    the extend point and return.
 */
 if( (dist = DIST(dim, endpt, outpypt->point)) < lentol)
  {
   OM_BLOCK_MOVE(extnd_pt, endpt, ptsize);
   if(outpoly) *outpoly = *inpoly;
   return(sts);
  }

 /* Allocate space for maximum number of points.
 */
 new_pts = (IGRdouble *) malloc((inpoly->num_points + 1) * ptsize);
 EMerr_hndlr(!new_pts, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 tot_pts = 0;
 inx = 0;
 if(*location == BEGIN)
  {
   from_ptinx = outpypt->span_inx + 1;
   num_pts = inpoly->num_points - from_ptinx;

   OM_BLOCK_MOVE(extnd_pt, &new_pts[inx], ptsize);
   inx+= dim; tot_pts++;
   OM_BLOCK_MOVE(&inpoly->points[from_ptinx * dim], &new_pts[inx], 
			num_pts * ptsize);
   tot_pts += num_pts;
  }
 else
  {
   to_ptinx = outpypt->span_inx;
   num_pts = to_ptinx + 1;

   OM_BLOCK_MOVE(inpoly->points, &new_pts[inx], num_pts * ptsize);
   inx += dim * num_pts; tot_pts += num_pts;

   OM_BLOCK_MOVE(extnd_pt, &new_pts[inx], ptsize);
   inx += dim; tot_pts++;
  }

wrapup:
 if(new_pts)
  {
   if(outpoly)
    {
     outpoly->points = new_pts;
     outpoly->num_points = tot_pts;
    }
   else
    {
     free(inpoly->points);
     inpoly->points = new_pts;
     inpoly->num_points = tot_pts;
    }
  }
 else if(outpoly)*outpoly = *inpoly;
 return(sts);
}



/*
 If outcurve is NULL,  the incurve memeory is freed and the incurve pointer
 points to the new memory upon output. 
 If outcurve is non NULL, incurve is left intact and new curve is returned
 via outcurve.
 Memory for the new curve is ALWAYS malloced in this function.
*/

IGRint EMextend_curve(EMmsg, incurve, outcurve, extnd_pt, location, 
			     lentol, dim, check_dist)
IGRlong			*EMmsg;
struct IGRbsp_curve	**incurve, **outcurve;
IGRdouble		*extnd_pt, lentol;
IGRint			*location, dim;
IGRboolean		check_dist;
{
 IGRlong		sts, rc;
 IGRint			loc_location = UNKNOWN, ptsize, max_out_numpoles;
 IGRdouble		start_pt[3], stop_pt[3], *endpt, loc_extnd_pt[3], 
			dist1, dist2, savetol, DIST();
 struct EMSdataselect	junk_data;
 struct IGRbsp_curve	*temp_curve=NULL, *loc_out_curve = NULL;
 IGRboolean		bssts, modify_input = FALSE;
 extern IGRint		EMgetendpts_uv(), EMgetendpts_xyz();

   IGRint k,n;
   IGRdouble dist, *pars=NULL, *intpars1=NULL;
   IGRdouble par, par1, par2, par3;
   IGRpoint end_pt[2];

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 bssts = BSEXTRACTPAR(&rc, BSTOLBASIS, savetol);
 if(dim == 2) BSchgdeppar(lentol, &rc);

 if(!location) location = &loc_location;
 if(!outcurve) 
  {
   outcurve = (struct IGRbsp_curve **) &loc_out_curve;
   modify_input = TRUE;
  }
 *outcurve = NULL;

 ptsize = dim * sizeof(IGRdouble);
 junk_data.datatype = EMSdata_curve3d;
 junk_data.data.curve = (struct IGRbsp_curve *) *incurve;

 if(dim == 2)
  {
   sts = EMgetendpts_uv(EMmsg, &junk_data, FALSE, 1, start_pt, stop_pt);
   start_pt[2] = 0.0;
   stop_pt[2] = 0.0;
  }
 else if(dim == 3)
    sts = EMgetendpts_xyz(EMmsg, NULL, NULL, &junk_data, FALSE, 1, 
				start_pt, stop_pt);
 else {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(*location == UNKNOWN)
  {
   if( (dist1 = DIST(dim, extnd_pt, start_pt)) < 
       (dist2 = DIST(dim, extnd_pt, stop_pt)))
    *location = BEGIN;
   else *location = END;
  }

 if(*location == BEGIN)
   endpt = start_pt;
 else 
   endpt = stop_pt;

 /* If the extend point is within tolerance from the endpoint, then
    exit.
 */
 if( check_dist && (dist1 = DIST(dim, endpt, extnd_pt)) < lentol)
  {*EMmsg = EMS_I_Degenerate; goto wrapup;}

 /* Allocate space for the output curve
 */
 max_out_numpoles = (*incurve)->num_poles + 3 * (2 * (*incurve)->order -1);
 (void) BSalloccv((*incurve)->order, max_out_numpoles, (*incurve)->rational, 
		  0, outcurve, &rc);
 if(rc != BSSUCC) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

 if(dim == 2)
  {
   OM_BLOCK_MOVE(extnd_pt, loc_extnd_pt, ptsize);
   loc_extnd_pt[2] = 0.0;
  }

 /* Call the math function to do the polynomial extension.
 */

 if( (*incurve)->phy_closed)
   {
    IGRlong numpoles;
    if(dim==2) { loc_extnd_pt[2]=0.0; end_pt[0][2] = 0.0; }
    if(dim==2)
      BSmdistptcv(*incurve, loc_extnd_pt, &k, &n, &pars, &dist, &intpars1, &rc);
    else
      BSmdistptcv(*incurve, extnd_pt, &k, &n, &pars, &dist, &intpars1, &rc);

    if(rc != BSSUCC) {*EMmsg = EMS_E_Fail; goto wrapup;}
    par3 = (*location == BEGIN) ? 1.0 : pars[0] ;
    par1 = (*location == BEGIN) ? pars[0] : 0.0 ;
    par2 = (par1+par3)/2.0;
    if((par3 < lentol  || par3 > (1.0 - lentol) )  && 
      (par1 < lentol || par1 > (1.0 - lentol)) )
          {
          BScv_copy(&rc, *incurve, *outcurve);
          goto  modify_input;
          }
    
    numpoles = (*incurve)->num_poles +2* (*incurve)->order -1 ;
    (void) BSalloccv((*incurve)->order, numpoles, (*incurve)->rational, 
		  0, &temp_curve, &rc);
    if(rc != BSSUCC) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
    BSpartofcv(&rc, *incurve, par1, par2, par3, temp_curve); 
    if(rc != BSSUCC) {*EMmsg = EMS_E_Fail; goto wrapup;}

    par = (*location == BEGIN) ? 0.0 : 1.0 ;
    BScveval(temp_curve, par, 1, end_pt, &rc);
    if(dim==2) { loc_extnd_pt[2]=0.0; end_pt[0][2] = 0.0; }
    bssts = BSpolyxttpt(&rc, temp_curve, end_pt[0],
		      dim == 2 ? loc_extnd_pt : extnd_pt, 
		      *outcurve);
    if(rc != BSSUCC) {*EMmsg = EMS_E_Fail; goto wrapup;}

   }
   else
   {
   bssts = BSpolyxttpt(&rc, *incurve, endpt, 
		      dim == 2 ? loc_extnd_pt : extnd_pt, 
		      *outcurve);
   if(rc != BSSUCC) {*EMmsg = EMS_E_Fail; goto wrapup;}
   }


modify_input:
 if(modify_input)
  {
   bssts = BSfreecv(&rc, *incurve);
   *incurve = *outcurve;
  }

wrapup:

if(dim ==2) BSchgdeppar(savetol, &rc);
if(temp_curve) om$dealloc(ptr=temp_curve);

if(!(1&sts&*EMmsg))
 {
  if(*outcurve) bssts = BSfreecv(&rc, *outcurve);
  *outcurve = NULL;
 }
  if(pars) om$dealloc(ptr = pars);
  if(intpars1) om$dealloc(ptr = intpars1);
return(sts);
}

extern OMuword OPP_GRlinear_class_id, OPP_GRpoint_class_id;

IGRint EMextend_object(EMmsg, obj, extnd_pt, location, lentol, env, check_dist)
IGRlong			*EMmsg;
struct GRid		*obj;
IGRdouble		*extnd_pt, lentol;
IGRint			*location;
struct GRmd_env		*env;
IGRboolean		check_dist;
{
 extern IGRint		EMgetvggeom(), EMextend_curve();
 struct IGRbsp_curve	*crv = NULL, *newcrv = NULL, *ptr = NULL;
 struct GRpost_info	post_info;
 GRobjid		newobjid;
 IGRlong		sts, rc;
 IGRint			EMextend_poly(), loc_location = UNKNOWN;
 IGRdouble		start_pt[3], stop_pt[3], *endpt, dist1, dist2,
			DIST();
 struct EMSdataselect	junk_data;
 IGRshort		*mxtyp;
 IGRdouble		*mx;
 extern IGRint		EMgetendpts_xyz();
 extern IGRboolean	EFisAncestryValid();
 struct IGRpolyline	inpoly, outpoly;
 extern IGRboolean	GRabsg_del_by_objid();

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 outpoly.points = NULL;
 outpoly.num_points = 0;
 if(EFisAncestryValid(EMmsg, obj->objid, obj->osnum, OPP_GRpoint_class_id, 
		      FALSE))
  {
   *EMmsg = EMS_I_Degenerate;
   goto wrapup;
  }
 if(!location) location = &loc_location;
 junk_data.datatype = EMSdata_object;
 junk_data.data.object = (struct GRid *) obj;
 mxtyp = &env->md_env.matrix_type;
 mx = (IGRdouble *) env->md_env.matrix;

 sts = EMgetendpts_xyz(EMmsg, mxtyp, mx, &junk_data, FALSE, 1, 
		       start_pt, stop_pt);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(*location == UNKNOWN)
  {
   if( (dist1 = DIST(3, extnd_pt, start_pt)) < 
       (dist2 = DIST(3, extnd_pt, stop_pt)))
    *location = BEGIN;
   else *location = END;
  }

 if(*location == BEGIN)
   endpt = start_pt;
 else 
   endpt = stop_pt;

 /* If the extend point is within tolerance from the endpoint, then
    exit.
 */

 if( check_dist && (dist1 = DIST(3, endpt, extnd_pt)) < lentol)
  {*EMmsg = EMS_I_Degenerate; goto wrapup;}

 post_info.construct_flag = FALSE;

 sts = EMgetvggeom(EMmsg, mxtyp, mx, obj, &crv, NULL);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(EFisAncestryValid(EMmsg, obj->objid, obj->osnum, OPP_GRlinear_class_id, 
		      FALSE))
  {
   inpoly.num_points = crv->num_poles;
   inpoly.points = crv->poles;
#if DEBUG
   printf("Refining linear object\n");
#endif
   sts = EMextend_poly(EMmsg, 3, &inpoly, &outpoly, extnd_pt, location, FALSE, 
		       NULL, NULL, lentol, FALSE);
   if( (1&sts&*EMmsg) && (*EMmsg != EMS_I_Degenerate))
    {
     crv->num_poles = outpoly.num_points;
     if(crv->poles != outpoly.points)
       crv->poles = outpoly.points;
     else outpoly.points = NULL;	/* To prevent incorrect freeing*/
     crv->num_knots = 0;
     crv->knots = NULL;
     ptr = crv;
    }
  }
 else
  {
#if DEBUG
   printf("Refining curve object\n");
#endif
   sts = EMextend_curve(EMmsg, &crv, &newcrv, extnd_pt, location, lentol, 3, 
		       FALSE);
   if( (1&sts&*EMmsg) && (*EMmsg != EMS_I_Degenerate)) ptr = newcrv;
  }

 if(ptr)
  {
   sts = om$send(msg = message GRvg.GRpostabsg(EMmsg, env, &post_info, 
			(IGRchar *)ptr, &newobjid), 
		targetid = obj->objid, 
		targetos = obj->osnum, 
		senderid = NULL_OBJID);
   (void) GRabsg_del_by_objid(&obj->objid, &obj->osnum);
  }

wrapup:
if(crv) om$dealloc(ptr = crv);
if(outpoly.points) om$dealloc(ptr = outpoly.points);
if(newcrv) (void) BSfreecv(&rc, newcrv);
return(sts);
}

static IGRdouble DIST (dim, pt1, pt2)
IGRshort dim;
IGRdouble *pt1, *pt2;
{
  IGRint i;
  IGRdouble temp, dist_loc;

  dist_loc = 0.0;
  for (i=0; i<dim; i++)
    dist_loc += ((temp = pt2[i]-pt1[i]), temp*temp);
  dist_loc = sqrt(dist_loc);
  return(dist_loc);
}


end implementation Root;
