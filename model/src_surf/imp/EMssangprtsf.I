/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;
/*
HISTORY:

 Long ago:  ??  : Creation.
 08/26/92:  NP  : Modified for ANSI compliance. Moved declaration of static functions
		  to global scope.
*/
#include "EMS.h"
#include "msdef.h"
#include "OMmacros.h"
#include "EMSopt.h"        /* For trim options */
#include "gocmacros.h"     /* GRgetabsg                    */
#include "emsedgedef.h"    /* EMlinestring */
#include "madef.h"         /* For PI */
#include <stdio.h>
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h" /* IF_EQ_GRID */

#ifndef DEBUG
#define DEBUG	0
#endif

#if DEBUG
#define GeomPtrBuff	1
#else
#define GeomPtrBuff	20
#endif


extern OMuword OPP_EMSgenbs_class_id;

extern IGRlong 		EMgetvggeom(), EFbuild_graphic_group();

struct EMSprtl
{
 struct GRid obj;
 struct IGRpolyline poly;
};

%safe
static IGRint	EMgetPrtlGeomXyz(), EMgetPrtlGeomUv();
%endsafe

method EMcreateAngularPartingSurface(
     IGRlong *EMmsg;
     struct GRmd_env *my_env;		/* my env */
     struct IGRbsp_surface *my_geom;	/* my geometry if known */
     struct GRvg_construct *c_list;     /* for new surf */
     IGRushort options;		/* currently ignored */
     IGRint	num_pairs;		/* number of normal/angular parting
					   line pairs being passed.
					 */
     struct IGRpolyline  *nprtl, 
			 *angprtl;	/* xyz points for normal and angular
					   parting lines if known
					*/
     struct GRlc_info *nprtlobj, 
		      *angprtlobj;	/* Obj info for parting lines.
					   If xyzpoints passed in this
					   is ignored.
					*/
     struct IGRpolyline *nprtluv, 
			*angprtluv;	/* UV data for parting lines in
					   my parametric space if known.
					*/
     IGRdouble		*sidept;	/* A point on the side where parting
					   surface should be constructed
					   wrt to me. If null always on
					   my natural side.
					*/
     struct GRid *outid;		/* more than 1 surfs, this will be
					   the graphic group id. If 1 surf
					   this will the that surf id.  
					*/
     struct IGRbsp_surface **psurfs)	/* Surface geometries. Mem allocated
					   upon input for 'num_pairs' number
					   of geometry pointers.
					*/
{
 IGRlong			rc, sts = OM_S_SUCCESS;
 struct IGRbsp_surface 		*my_geomloc = NULL, 
				**psurf_loc = NULL, 
				*psurf_locbuff[GeomPtrBuff];
 struct EMSprtl			*nprtl_loc = NULL, 
				*angprtl_loc = NULL, 
				nprtl_locbuff[GeomPtrBuff], 
				angprtl_locbuff[GeomPtrBuff];
				
 struct EMSprtl			*nprtluv_loc = NULL, 
				*angprtluv_loc = NULL, 
				nprtluv_locbuff[GeomPtrBuff], 
				angprtluv_locbuff[GeomPtrBuff];
				
 struct IGRpolyline		*thisuv, *thisxyz;
				
 IGRint				i, j, m;
 struct GRid			my_GRid;
 IGRboolean			natside = FALSE;
 extern void			BSptonnsdsf(), BSdrftangsf();
 struct BSpartgrp		norjunk, angjunk, *thisjunk;
 extern IGRboolean		BSfreesf();
 struct GRid			*srfid = NULL, srfid_buff[GeomPtrBuff];

 *EMmsg = EMS_S_Success;
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 for(i=0; i<GeomPtrBuff; i++)
  {
   nprtl_locbuff[i].poly.points = NULL;
   angprtl_locbuff[i].poly.points = NULL;
   nprtluv_locbuff[i].poly.points = NULL;
   angprtluv_locbuff[i].poly.points = NULL;
  }

 if( (!nprtl && !nprtlobj) || (!angprtl && !angprtlobj) || 
     (!outid && !psurfs))
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  } 

  /* Obtain xyz points for the normal and angular parting lines.
  */
  sts = EMgetPrtlGeomXyz(EMmsg, num_pairs, nprtl, nprtlobj, &nprtl_loc, 
			  nprtl_locbuff);
  if(!(1&*EMmsg)) goto wrapup;

  sts = EMgetPrtlGeomXyz(EMmsg, num_pairs, angprtl, angprtlobj, &angprtl_loc, 
			  angprtl_locbuff);
  if(!(1&*EMmsg&sts)) goto wrapup;
  
  if(my_geom) my_geomloc = my_geom;
  else
   {
    enum EMSdatatype junk;

    sts = EMgetvggeom(EMmsg, &my_env->md_env.matrix_type,
			     my_env->md_env.matrix, &my_GRid, &my_geomloc, 
			     &junk);
    if(!(1&*EMmsg&sts)) goto wrapup;
   }


  /* Obtain the parametric data for the parting lines in my UV space
  */
   sts = EMgetPrtlGeomUv(EMmsg, num_pairs, nprtluv, nprtl_loc, &nprtluv_loc, 
			  nprtluv_locbuff, my_geomloc);
   if(!(1&*EMmsg&sts))	goto wrapup;

   sts = EMgetPrtlGeomUv(EMmsg, num_pairs, angprtluv, angprtl_loc, 
			 &angprtluv_loc, angprtluv_locbuff, my_geomloc);
   if(!(1&*EMmsg&sts))	goto wrapup;

  /* Which side is the parting surface to be created wrt my natural
     normal?
  */
  if(sidept)
   {
    BSptonnsdsf(my_geomloc, sidept,&natside,&rc);
    EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   }
  else natside = TRUE;

  /* Ready to create angular parting surfaces from each normal parting line
     and angular parting line pair.
  */
  if(num_pairs > GeomPtrBuff)
    psurf_loc = (struct IGRbsp_surface **) om$malloc(size = num_pairs *
				sizeof(struct IGbsp_surface *));
  else psurf_loc = psurf_locbuff;

  for(i=0; i<num_pairs; i++) psurf_loc[i] = NULL;
  if(outid)
   {
    outid->osnum = c_list->env_info->md_id.osnum;
    if(num_pairs > GeomPtrBuff)
     srfid = (struct GRid *) om$malloc(size = num_pairs * sizeof(struct GRid));
    else srfid = srfid_buff;
    EMerr_hndlr(!srfid, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   }

  for(i=0; i<num_pairs; i++)
   {
    for(j=0; j<2; j++)
     {
      thisjunk = j ? &angjunk : &norjunk;
      thisxyz = j ? &angprtl_loc[i].poly : &nprtl_loc[i].poly;
      thisuv = j ? &angprtluv_loc[i].poly : &nprtluv_loc[i].poly;

      thisjunk->num = thisxyz->num_points;
      thisjunk->pts = (IGRpoint *) thisxyz->points;
      thisjunk->par = (BSpair *) thisuv->points;
      thisjunk->next = NULL;
     }

    BSdrftangsf(my_geomloc, natside, &norjunk, &angjunk, &psurf_loc[i], &rc);
    EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    if(outid)
     {
      c_list->geometry = (IGRchar *) psurf_loc[i];
      sts = om$construct(classid = OPP_EMSgenbs_class_id, 
			 p_objid = &srfid[i].objid, 
			 osnum = outid->osnum, 
			 msg = message GRgraphics.GRconstruct(c_list));
      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);
      srfid[i].osnum = outid->osnum;
     }
    if(psurfs) psurfs[i] = psurf_loc[i];
    psurf_loc[i] = NULL;
   }

  if(outid && (num_pairs > 1))
    sts = EFbuild_graphic_group(num_pairs, NULL, srfid, c_list, 
				&outid->objid, EMmsg);
  else if(outid) *outid = *srfid;

wrapup:

for(j=0; j<4; j++)
 {
  struct IGRpolyline *junkpoly = NULL;
  struct EMSprtl *junkprtl = NULL, *buff = NULL;

  switch(j)
   {
    case 0:
     junkpoly = nprtl;
     junkprtl = nprtl_loc;
     buff = nprtl_locbuff;
     break;

    case 1:
     junkpoly = nprtluv;
     junkprtl = nprtluv_loc;
     buff = nprtluv_locbuff;
     break;

    case 2:
     junkpoly = angprtl;
     junkprtl = angprtl_loc;
     buff = angprtl_locbuff;
     break;

    case 3:
     junkpoly = angprtluv;
     junkprtl = angprtluv_loc;
     buff = angprtluv_locbuff;
     break;
    
    default:
     break;
   }
  if(!junkpoly && junkprtl)
   for(i=0; i<num_pairs; i++)
    if(junkprtl[i].poly.points)
     {
      om$dealloc(ptr = junkprtl[i].poly.points);
      for(m=0; m<num_pairs; m++)
       if(junkprtl[m].poly.points == junkprtl[i].poly.points)
        junkprtl[m].poly.points = NULL;
     }

  if(junkprtl && (junkprtl != buff)) om$dealloc(ptr = junkprtl);
 }

for(i=0; i<num_pairs; i++)
 if(psurf_loc[i]) BSfreesf(&rc, psurf_loc[i]);

if(psurf_loc && (psurf_loc != psurf_locbuff))
 om$dealloc(ptr = psurf_loc);

if(my_geomloc && (my_geomloc != my_geom)) om$dealloc(ptr = my_geomloc);
if(srfid && (srfid != srfid_buff)) om$dealloc(ptr = srfid);

EMWRAPUP(*EMmsg, sts, "EMSsubbs.EMcreateAngularPartingSurface");
return(sts);
}


static IGRint EMgetPrtlGeomXyz(EMmsg, num_pairs, poly, lcinfo, loc_ptr, 
			       locbuff)
IGRlong			*EMmsg;
IGRint			num_pairs;
struct IGRpolyline	*poly;
struct GRlc_info	*lcinfo;
struct EMSprtl		**loc_ptr, *locbuff;
{
 IGRlong	sts = OM_S_SUCCESS, rc;
 IGRint		i, j;
 enum EMSdatatype junk;
 struct IGRbsp_curve *crv = NULL;
 extern IGRboolean EFstroke_the_curve();
 IGRdouble chttol = 0.001;
 IGRboolean found = FALSE;

*EMmsg = EMS_S_Success;
*loc_ptr = NULL;

BSEXTRACTPAR(&rc, BSTOLCHRDHT, chttol);

if(num_pairs > GeomPtrBuff)
 *loc_ptr = (struct EMSprtl *) om$malloc(size = num_pairs *
				sizeof(struct EMSprtl));
else *loc_ptr = locbuff;

EMerr_hndlr(!(*loc_ptr), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

for(i=0; i<num_pairs; i++)
 {
  (*loc_ptr)[i].poly.points = NULL;
  (*loc_ptr)[i].poly.num_points = 0;
  (*loc_ptr)[i].obj.objid = NULL_OBJID;
 }

for(i=0; i<num_pairs; i++)
 {
  crv = NULL;
  if(poly) (*loc_ptr)[i].poly = poly[i];
  else
   {
    found = FALSE;
    for(j=0; j<i; j++)
     if(found = IF_EQ_GRID((*loc_ptr)[j].obj, lcinfo[i].located_obj))
      break;

    if(found)
     (*loc_ptr)[i] = (*loc_ptr)[j];
    else
     {
      sts = EMgetvggeom(EMmsg, &lcinfo[i].module_info.md_env.matrix_type, 
			    lcinfo[i].module_info.md_env.matrix, 
			    &lcinfo[i].located_obj, 
			    &crv, &junk);
      if(!(1&*EMmsg&sts)) goto wrapup;
      if( (junk != EMSdata_curve3d)||!crv) {*EMmsg = EMS_E_Fail; goto wrapup;}

      /* Stroke the curve and return the stroked points.
      */
      (void) EFstroke_the_curve(crv, &chttol, &(*loc_ptr)[i].poly, EMmsg);
      if(!(1&*EMmsg)) goto wrapup;
      (*loc_ptr)[i].obj = lcinfo[i].located_obj;
     }
   }
  om$dealloc(ptr = crv);
  crv = NULL;
 }

wrapup:
if(crv) om$dealloc(ptr = crv);
return(sts);
}



static IGRint EMgetPrtlGeomUv(EMmsg, num_pairs, uv, xyz, loc_ptr, locbuff, srf)
IGRlong			*EMmsg;
IGRint			num_pairs;
struct IGRpolyline	*uv;
struct EMSprtl		*xyz, **loc_ptr, *locbuff;
struct IGRbsp_surface	*srf;
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			i, j;
 extern void		BSprptsonsf();
 IGRlong 		rc;
 IGRboolean		onsrf, found = FALSE;

*EMmsg = EMS_S_Success;
*loc_ptr = NULL;
if(num_pairs > GeomPtrBuff)
 *loc_ptr = (struct EMSprtl *) om$malloc(size = num_pairs *
				sizeof(struct EMSprtl));
else *loc_ptr = locbuff;

EMerr_hndlr(!(*loc_ptr), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

for(i=0; i<num_pairs; i++)
 {
  (*loc_ptr)[i].poly.points = NULL;
  (*loc_ptr)[i].poly.num_points = 0;
  (*loc_ptr)[i].obj.objid = NULL_OBJID;
 }

for(i=0; i<num_pairs; i++)
 {
  (*loc_ptr)[i].obj = xyz[i].obj;

  if(uv)
   (*loc_ptr)[i].poly = uv[i];
  else
   {
    found = FALSE;
    for(j=0; j<i; j++)
     if(found = IF_EQ_GRID((*loc_ptr)[j].obj, (*loc_ptr)[i].obj)) break;

    if(found)
     (*loc_ptr)[i] = (*loc_ptr)[j];
    else
     {
      (*loc_ptr)[i].poly.num_points = xyz[i].poly.num_points;
      (*loc_ptr)[i].poly.points = (IGRdouble *) om$malloc(size = 
	xyz[i].poly.num_points * 2 * sizeof(IGRdouble));
      EMerr_hndlr(!(*loc_ptr)[i].poly.points, *EMmsg, EMS_E_NoDynamicMemory, 
		wrapup);

      BSprptsonsf(xyz[i].poly.num_points, xyz[i].poly.points, srf, 
		(*loc_ptr)[i].poly.points, &onsrf, &rc);
      EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     }
   }
 }

wrapup:
return(sts);
}

end implementation EMSsubbs;

