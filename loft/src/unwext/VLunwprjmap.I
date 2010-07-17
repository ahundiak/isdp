/* $Id: VLunwprjmap.I,v 1.4 2002/04/30 20:18:40 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwprjfc.I
 *
 * Description: Functions related to the projection or mapping of
 *		Featute Objects.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwprjmap.I,v $
 *      Revision 1.4  2002/04/30 20:18:40  ramarao
 *      Fixed crash in TR# 5245.
 *
 *      Revision 1.3  2001/02/20 01:07:46  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 20:01:33  ramarao
 *      *** empty log message ***
 *
# Revision 1.3  2000/10/16  17:27:32  pinnacle
# ah
#
# Revision 1.2  2000/07/06  13:48:14  pinnacle
# Replaced: loft/src/unwext/VLunwprjmap.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/05/15  21:22:28  pinnacle
# Created: loft/src/unwext/VLunwprjmap.I by rchennup for Service Pack
#
# Revision 1.5  2000/03/31  21:45:30  pinnacle
# Replaced: src/unwext/VLunwprjmap.I for:  by impd252 for loft
#
# Revision 1.4  2000/03/30  23:30:34  pinnacle
# Replaced: src/unwext/VLunwprjmap.I for:  by impd252 for loft
#
# Revision 1.2  2000/03/23  20:46:32  pinnacle
# Replaced: src/unwext/VLunwprjmap.I for:  by impd252 for loft
#
 *
 * MM/DD/YY   AUTHOR    	DESCRIPTION
 * 03/23/00   JLL, Rama Rao	Creation
 * 10/16/00   ah                Added env to VDdrawCurve
 *************************************************************************/

class implementation VDSroot;

#include "bsparameters.h"
#include "bserr.h"
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "exmacros.h"
#include "VDmem.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "vlstructure.h"
#include "vlunfold.h"
#include "vldbgmacros.h"
#include "VDgeom.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

extern GRclassid OPP_GR3dlinestr_class_id, OPP_GRgrgrp_class_id,
		 OPP_GRpoint_class_id;

from EMSsubbs	import	EMproject_curve_onto_surface,
			EMproject_curve_along_surface_normals;
from GRcurve	import	GRendpts;

IGRlong VLprojAndMapCrvOntoDevSrf( dev, cst, objToMap, fromMat, toMat,
				   numMapCrvs, mapCrvs, msg )
struct unw_obj_plat     *dev;   /*I: unwrap structure */
struct GRvg_construct   *cst;   /*I: contruction list */
struct GRobj_env        *objToMap; /*I: Curve to project and Map */
IGRdouble               *fromMat, *toMat; /* I: Transformation Matrices */
IGRint                  *numMapCrvs; /*O: number of output curves maped */
struct GRid             **mapCrvs;   /*O: curves projected and mapped */
IGRlong			*msg;
{
IGRint			i, loc_numMapCrvs;
IGRlong			sts, loc_sts, loc_msg, nb_inter;
IGRshort		trfMatType;
IGRdouble		pnt[3], nrm[3], trfMat[16];
OM_S_OBJID		*projCrvs=NULL;
struct GRid		gr_obj;
struct GRobj_env 	surface;
struct IGRplane		plane;
struct GRlc_info 	curv_info,surf_info;

     SetProc( VLprojAndMapCrvOntoDevSrf ); Begin

     *numMapCrvs    = 0;
     loc_numMapCrvs = 0;
     *mapCrvs       = NULL;
     plane.point    = pnt;
     plane.normal   = nrm;
     nb_inter       = 0;

      __DBGpr_obj( "dev->surf_id ", dev->surf_id.obj_id );
     sts = om$send( msg      = message NDnode.ASreturn_go(
                                        &surface.obj_id,
                                        &surface._matrix_type,
                                        surface._matrix ),
                senderid = NULL_OBJID,
                targetid = dev->surf_id.obj_id.objid,
                targetos = dev->surf_id.obj_id.osnum );
     if( sts & 1 )
     {
        surface._md_os = surface._osnum;
        ex$get_modid(   mod_osnum = surface._md_os,
                        mod_id    = &surface._md_id ) ;
        __DBGpr_obj( "Surface Module ID ", surface.mod_env.md_id );
     }
     else surface = dev->surf_id;
     __DBGpr_obj( "Surface Obj ID ", surface.obj_id );

     sts = om$send( msg = message GRvg.GRdetplane( msg,
						   &surface._matrix_type,
						   surface._matrix,
						   &plane ),
                 senderid = surface._objid,
                 targetid = surface._objid,
                 targetos = surface._osnum);
     __CheckRC( sts, *msg, "GRvg.GRdetplane", wrapup );
     __DBGpr_vec("Planar Surface Normal ", plane.normal );

     curv_info.located_obj = objToMap->obj_id;
     curv_info.module_info = objToMap->mod_env;

     surf_info.located_obj = surface.obj_id;
     surf_info.module_info = surface.mod_env;

     __DBGpr_obj("Curve to project ", curv_info.located_obj );
     __DBGpr_obj("Surface Info ", surf_info.located_obj );

     sts = om$send(msg=message EMSsubbs.EMproject_curve_along_surface_normals(
                                 &curv_info,
                                 &surf_info,
                                 cst,
                                 FALSE,
                                 TRUE,
                                 &nb_inter,
                                 &projCrvs,
                                 msg),
                    senderid = surf_info.located_obj.objid,
                    targetid = surf_info.located_obj.objid,
                    targetos = surf_info.located_obj.osnum);
/*
     This function leaves junk graphics in the space, which are non-locatable.
     sts = om$send(msg=message   EMSsubbs.EMproject_curve_onto_surface(
                                 &curv_info,
                                 &surf_info,
                                 cst,
				 plane.normal,
                                 FALSE,
                                 TRUE,
				 &nb_inter,
                                 &projCrvs,
                                 msg),
                 senderid = surf_info.located_obj.objid,
                 targetid = surf_info.located_obj.objid,
                 targetos = surf_info.located_obj.osnum);
*/
     __CheckRC( sts, *msg, "EMproject_curve_onto_surface", wrapup );
     __DBGpr_int("EMproject_curve_onto_surface function returns ", nb_inter );

     if( !nb_inter ) goto wrapup;

     gr_obj.objid = projCrvs[0] ;
     gr_obj.osnum = cst->env_info->md_id.osnum;

     if( (vd_$is_ancestry_valid( object  = &gr_obj,
				 classid = OPP_GRgrgrp_class_id )) )
     {
	  IGRint	num_comp, num_ret;

	  __DBGpr_com("EMproject_curve_onto_surface returns Grphic Group object");
	  sts = om$send( msg = message GRowner.GRget_number_components(
						msg, &num_comp ),
			 senderid = NULL_OBJID,
			 targetid = gr_obj.objid,
			 targetos = gr_obj.osnum  );
	  __CheckRC( sts, *msg, "GRowner.GRget_number_components", wrapup );
	  __DBGpr_int("Graphic group has components ", num_comp );

	  loc_numMapCrvs = num_comp;

	  if( !(*mapCrvs = _MALLOC( loc_numMapCrvs, struct GRid ) ) )
		vd_$mem_fail();

	  sts = om$send( msg = message GRowner.GRget_components(
					msg, cst->env_info,
					*mapCrvs, num_comp, &num_ret,
					(IGRint) 0, OM_K_MAXINT ),
                         senderid = NULL_OBJID,
                         targetid = gr_obj.objid,
                         targetos = gr_obj.osnum  );
          __CheckRC( sts, *msg, "GRowner.GRget_components", wrapup );

	  _FREE( projCrvs );
	  if( !( projCrvs = _MALLOC( loc_numMapCrvs, OM_S_OBJID  ) ) )
                vd_$mem_fail();

	  for( i=0; i<loc_numMapCrvs; ++i ) projCrvs[i] = (*mapCrvs)[i].objid ;

          sts = om$send( msg = message GRowner.GRdrop(
                                        msg, cst->env_info ),
                         senderid = NULL_OBJID,
                         targetid = gr_obj.objid,
                         targetos = gr_obj.osnum  );
          __CheckRC( sts, *msg, "GRowner.GRdrop", wrapup );

          sts = om$send( msg = message GRgraphics.GRdelete(
                                        msg, cst->env_info ),
                         senderid = NULL_OBJID,
                         targetid = gr_obj.objid,
                         targetos = gr_obj.osnum  );
          __CheckRC( sts, *msg, "GRowner.GRdelete", wrapup );
     }
     else
     {
	  loc_numMapCrvs = 0;

          if( !(*mapCrvs = _MALLOC( nb_inter, struct GRid ) ) )
               vd_$mem_fail();
	  for( i=0; i<nb_inter; ++i )
	  {
		gr_obj.objid = projCrvs[i];
		gr_obj.osnum = cst->env_info->md_id.osnum;

		if( !vd_$is_ancestry_valid( object   = &gr_obj,
					    classid  = OPP_GRpoint_class_id ))
		{
		  (*mapCrvs)[i].objid = projCrvs[i];
		  (*mapCrvs)[i].osnum = cst->env_info->md_id.osnum; 
		  loc_numMapCrvs++;
		}
	  }
     }

     sts = VLapplyTransf( *mapCrvs, loc_numMapCrvs, cst->env_info, fromMat,
			  toMat, trfMat, &trfMatType, msg );
     __CheckRC( sts, *msg, "VLapplyTransf", wrapup );

     sts = *msg = MSSUCC;

wrapup:
     if( !(sts&(*msg)&1) )
     {
	__DBGpr_com("Function Failed: So delteting the intersections");
        for(i=0; i<loc_numMapCrvs; i++)
        {
            loc_sts = om$send(msg = message GRgraphics.GRdelete( &loc_msg,
                                                     cst->env_info ),
                    senderid = NULL_OBJID,
                    targetid = projCrvs[i],
                    targetos = cst->env_info->md_id.osnum  );
        }

	loc_numMapCrvs = 0;
	_FREE( *mapCrvs );
     }

     *numMapCrvs = loc_numMapCrvs;

     cst->geometry   = NULL;
     _FREE( projCrvs );
     End
     return sts;
}

/* This function project a curve onto a non developable surface (a doubly curved   surface) and map the result onto the unwraped surface */ 
IGRlong VLprojAndMapCrvOntoNonDevSrf( dev, cst, cht3D, objToMap, IsMultiSol, 
			  	      numMapCrvs,  mapCrvs, msg )

struct unw_obj_plat	*dev;   /*I: unwrap structure */
struct GRvg_construct	*cst;	/*I: contruction list */
double			cht3D;	/*I: 3D cht applied to stroke the curve */
struct GRobj_env	*objToMap; /*I: Curve to project and Map */
IGRboolean              IsMultiSol;
int			*numMapCrvs; /*O: number of output curves maped */
struct GRid             **mapCrvs;   /*O: curves projected and mapped */
IGRlong			*msg;	     /*O: return code MSSUCC or MSFAIL*/
{
BSrc			rc;
IGRlong			sts, loc_sts,loc_msg;
IGRint			i, j, k, loc_numMapCrvs, MaxPts, numCreatedCrvs;
IGRdouble               *pars=NULL, *uvs=NULL, savedActiveCht, mdist,
			bastol, ptDr[3],vecDr[6], base[3];
IGRpoint		*pts=NULL;
OM_S_OBJID		*projCrvs=NULL;
struct GRobj_env	tempObj_env;
struct IGRbsp_curve     *cv=NULL;
struct IGRpolyline      lst;

	SetProc( VLprojAndMapCrvOntoNonDevSrf ); Begin

	*numMapCrvs = 0;
	*mapCrvs    = NULL;
	loc_numMapCrvs = 0;
	numCreatedCrvs = 0;
	lst.points = NULL;

	BSxtractpar ( &rc, BSTOLBASIS, &bastol );

	if( IsMultiSol )
	{
	   /* project the curve onto the in mimnimum distance */
	   __DBGpr_com("Calling VLproject_curve");
	   sts = VLproject_curve( &dev->surf_id, objToMap, cst, 
				  &loc_numMapCrvs, &projCrvs ); 
	   __CheckRC( sts, 1, "VLproject_curve", wrapup ); 
	   __DBGpr_int("VLproject_curve returns ", loc_numMapCrvs );
	}
	else loc_numMapCrvs = 1;

	if( loc_numMapCrvs < 1 ) goto wrapup;

	/* Malloc the array solution */
	if( !(*mapCrvs = _MALLOC( loc_numMapCrvs, struct GRid ) ) )
	  vd_$mem_fail();

	numCreatedCrvs = 0;
	for(i=0; i<loc_numMapCrvs; i++)
	{
            _FREE( pars );
            _FREE( uvs );
            _FREE( pts );
            _FREE( lst.points );
            _FREE( cv );

	    /* 
	     * Retrieve the geometry of the projected curve, stroke it and
	     * project each vertex in minimum distance.
	     */
	    if( !IsMultiSol )
	    {
		tempObj_env = *objToMap;			
	    }
	    else
	    {
		tempObj_env.obj_id.objid = projCrvs[i];
		tempObj_env.obj_id.osnum = cst->env_info->md_id.osnum;
		tempObj_env.mod_env = *cst->env_info;
	    }

	    __DBGpr_int("Mapping Curve Index ", i );
	    sts = VLgetGeometry( &tempObj_env, (IGRboolean) FALSE, NULL_OBJID, 
 				 (IGRchar **)&cv, msg );
	    __CheckRC( sts, *msg, "VLgetGeometry", wrapup );

	    /*
	     * project the curve onto the surface in mdist onto the surface and
	     * retrieve the normal just do a BSsfeval if parametric tessalation,
	     * else 2 steps compute. If the retrieved curve is already a 
	     * Linestring then we do not need to stroke the curve else we
	     * call the stroking function
	     */
	    __DBGpr_int("Curve Order ", cv->order );	
	    if( cv->order == 2 )
	    {
		__DBGpr_int("Input Curve is Line string: Number of Poles ", 
				cv->num_poles );
		MaxPts = 3 * cv->num_poles;
		lst.num_points = cv->num_poles;
		lst.points = NULL;
	
	        if( !(lst.points = _MALLOC( MaxPts, IGRdouble ) ) )
          	   vd_$mem_fail();	
		if( !(pts = _MALLOC( cv->num_poles, IGRpoint  ) ) )
		   vd_$mem_fail();

		for(j=0; j<lst.num_points; ++j )
		  for(k=0; k<3; ++k )
		    pts[j][k] = cv->poles[3*j+k];
	    }
	    else
	    {
		/*
		 * Retrieve the active cht and do some test because sometimes 
		 * this cht is crazy
		 */
		BSxtractpar ( &rc, BSTOLCHRDHT, &savedActiveCht );
		BSchangepar ( &rc, BSTOLCHRDHT, cht3D );
			
		/* Evaluate the points at the cht value */
		BSchtptstcv( cv, &lst.num_points, &pts,
			     &pars, &rc);		
		if( rc != BSSUCC )
		{	
		   BSchangepar ( &rc, BSTOLCHRDHT, savedActiveCht );
		   *msg = MSFAIL;
		   goto wrapup;
		}
		__DBGpr_int("BSchtptstcv(Stroking) returns ", lst.num_points );
		/* Set back the cht as it used be */
		BSchangepar ( &rc, BSTOLCHRDHT, savedActiveCht );

		MaxPts = 3 * lst.num_points;
                if( !(lst.points = _MALLOC( MaxPts, IGRdouble ) ) )
                   vd_$mem_fail();
	     }/* end of the stroking of the projected curve */

	     __DBGpr_int("Allocating memory[uv] for ", lst.num_points );
	     #if vdsDEBUG
		for( j=0; j<lst.num_points; ++j )
		  __DBGpr_vec("Point ", pts[j] );
	     #endif
             if( !( uvs = _MALLOC( 2*lst.num_points, IGRdouble ) ) )
                   vd_$mem_fail();

/* Sometimes this gives problems. Especially, if for some of the points, 
   minimum distance calculations are failing.

	      __DBGpr_dbl("Before calling BSmdarrptsf, bastol ", bastol );
	      BSmdarrptsf( (int)lst.num_points, pts, dev->surface, 
			   bastol, TRUE, FALSE, FALSE, FALSE,
                    	   uvs, NULL, NULL, NULL, &rc);
	      __DBGpr_int("After calling BSmdarrptsf, rc ", rc );
*/

              for( j=0; j<lst.num_points; ++j )
              {
                 BSmdistptsf( &rc, dev->surface, pts[j], &uvs[2*j],
                              &uvs[2*j+1], base, &mdist );
                 if( rc != BSSUCC )
                 {
                    uvs[2*j]   = uvs[2*(j-1)];
                    uvs[2*j+1] = uvs[2*(j-1)+1];
                 }
              }

             /*
              * Upto now we just retrieved or compute the points that should
              * be projected onto the surface. The tessalation is made with
              * 2 different methodes VLtessOpt0() and VLtessOpt1().
              * VLtessOpt0() is for the parametric case. In this case we do
              * not need to perform a double mapping as it should be done
              * with VLtessOpt1().
              */
	      if (dev->tesselation_option == PARAMETRIC)
	      {
		  __DBGpr_com("Processing for Natural Mesh");
		  for(k=0;k<lst.num_points;k++)
		  {
		      __DBGpr_dbl("U-parameter ", uvs[2*k]);
		      __DBGpr_dbl("V-parameter ", uvs[2*k+1]);
		      BSsfeval( dev->devsrf, uvs[2*k], uvs[2*k+1],
			        0, &(lst.points[3*k]), &rc );
		      __DBGpr_vec("Point on Unwrap Surface",&(lst.points[3*k]));
		  }
	      }
	      else
	      {
		  __DBGpr_com("Processing for Boundaries Mesh");
		  for(k=0;k<lst.num_points;k++)
		  {
                      __DBGpr_dbl("U-parameter ", uvs[2*k]);
                      __DBGpr_dbl("V-parameter ", uvs[2*k+1]);
		      BSsfevaln( dev->surface,uvs[2*k],uvs[2*k+1],1,
			         &j,ptDr,vecDr,&rc);
		      FAevPtSfFaDr( (IGRshort) 3,dev->P,dev->devsrf,dev->def,
				    ptDr, vecDr, uvs[2*k],uvs[2*k+1],
				    &(lst.points[3*k]),&rc);
		      __DBGpr_vec("Point on Unwrap Surface",&(lst.points[3*k]));
		  }
	      }

	      sts = VLunwRemoveDuplicatePoints( cv->phy_closed,
                                &lst.num_points, &lst.points );

	      /* Construct the linestring */

	      (*mapCrvs)[i].objid = NULL_OBJID;
	      (*mapCrvs)[i].osnum = cst->env_info->md_id.osnum;

 	      cst->geometry	= (IGRchar *) &lst;

  	      sts = om$construct( classid = OPP_GR3dlinestr_class_id, 
				  p_objid = &(*mapCrvs)[i].objid, 
         			  osnum   = (*mapCrvs)[i].osnum,
				  msg     = message GRgraphics.GRaltconstruct(
						cst) );
	      __CheckRC( sts, 1, "GRaltconstruct:GR3dlinestr", wrapup ) ;

	      numCreatedCrvs++;

	      cst->geometry	= NULL;
	      _FREE( pars );
	      _FREE( uvs );
	      _FREE( pts );
	      _FREE( lst.points );
	      _FREE( cv );
	}
	sts = *msg = MSSUCC;

wrapup:
	/* Delete the curve projected onto the 3D surface */
	if( projCrvs )
	{
	  for(i=0; i<loc_numMapCrvs; i++)
	  {
	    loc_sts = om$send(msg = message GRgraphics.GRdelete( &loc_msg,
							cst->env_info ),
                         senderid = NULL_OBJID,
			 targetid = projCrvs[i],
                         targetos = cst->env_info->md_id.osnum  );
	  }
	}

	if( !(sts&(*msg)&1) )
	{
	    /* 	Delete the curve mapped curves that we computed earlier simply
		because one failed. */	
	    for(i=0; i<numCreatedCrvs; i++)
	    {
		loc_sts = om$send(msg = message GRgraphics.GRdelete(
						&loc_msg,
						cst->env_info ),
			senderid = NULL_OBJID,
			targetid = (*mapCrvs)[i].objid,
			targetos = (*mapCrvs)[i].osnum  );
	    }
	    _FREE( *mapCrvs );
	    loc_numMapCrvs = 0;
	}

	*numMapCrvs = loc_numMapCrvs;

	cst->geometry   = NULL;
	_FREE( projCrvs );
	_FREE( pars );
	_FREE( uvs );
	_FREE( pts );
	_FREE( lst.points );
	_FREE( cv );

	return sts;
} /* end of VLprojAndMapCrvOntoNonDevSrf */

IGRlong	VLprojAndMapCrvOntoSrf(	dev, nb_lines, lines, IsMultiSol,
		  		cst, fromMat, toMat, numCrvs, Crvs)
struct unw_obj_plat 	*dev;	  /* I: Unwrap Structure */
int			nb_lines; /* I: Number of lines */
struct GRobj_env	*lines;   /* I: Lines */
IGRboolean		IsMultiSol; /* I: The caller might already know that 
				single or multiple solution will be evaluated:
				- IsMultiSol = TRUE ---> the curve to project 
				will return serveral pieces 
				- IsMultiSol = FALSE ---> The curve is already 
				considered on the surface. No projection
				is applied. one to one mapping. This will
				some precious time */
struct GRvg_construct   *cst;     /* I: Construction List */
IGRdouble		*fromMat, *toMat; /* I: Transformation Matrices */
int                     *numCrvs; /* O: Number of Output curves */
struct GRid             **Crvs;   /* O: Output curves List */
{
BSrc		rc;
IGRlong		sts, msg, loc_msg; /* return codes */
IGRint		i, j;		   /* counter */
IGRdouble	cht3D;
int		nb_Crvs_max;       /* maximun number of element that can be 
				      stroke without realloc */
struct GRid	*mapCrvs;  /* Array curves result of the mapping of one
				      lines[i] curve */ 
IGRint		numMapCrvs;/* Number of mapping curves for one 
				      lines[i] curve */ 		

     SetProc( VLprojAndMapCrvOntoSrf ); Begin
     msg = MSFAIL;

     numMapCrvs = 0;
     mapCrvs  = NULL;
     *numCrvs = 0;
     *Crvs    = NULL;

     /*
      * In all what is done here we assume that the curve to be projected
      * is already in the base or the offset face of the plate. We just redo 
      * this crazy work to make sure that the curve is projected onto the
      * correct face. Once the curve is projected, we should use a
      * geodesic approach for the mapping, it would provide a better  solution.
      * That is not the case today.  We just apply a one to one mapping in
      * the uv space.

      * If the surface is planar, meaning it's a real plan or a planar
      * BSpline surface then:
      *
      *   - we project the curve onto the planar surface along the normal
      *     of the surface.
      *   - we map the projected curve onto the unwrap surface that should 
      *     not be deformed. In fact it should be just a transformation matrix.
      *
      * Else the original surface is not developpable then:
      *
      *   - we project first the curve orginal surface. If the curve is not
      *     an order 2 Bspline or a linestring, the curve needs to be stroked 
      *     first.The projection process is in minimun distance and we retrieve
      *     the normal of the surface on each projected point.
      *   - This point, with it's normal is projected onto the surface with
      *     with the facettes that are not yet unwrapped.
      *   - The previous operation will return a the (u,v) value that will be
      *   - used compute the point onto the unwrapped surface.
      *
      */ 

      __DBGpr_int("Number of input Lines ", nb_lines );
      if( !nb_lines ) goto wrapup;

      __DBGpr_int("Surface Developpable? ", dev->developpable );
      nb_Crvs_max = nb_lines;

      if( !(*Crvs = _MALLOC( nb_lines, struct GRid ) ) )
          vd_$mem_fail(msg=&msg);

      BSxtractpar ( &rc, BSTOLCHRDHT, &cht3D );

      for ( i=0; i<nb_lines; i++ )
      {
          __DBGpr_int("Curve Index ", i );
          __DBGpr_obj("\tCurve to Map ", lines[i].obj_id );	
	  if( dev->developpable > 0 )
	  {
	       sts = VLprojAndMapCrvOntoDevSrf(dev, cst, &lines[i], 
			      fromMat, toMat, &numMapCrvs,  &mapCrvs, &msg );
	       if( !(sts&msg&1) ) numMapCrvs = 0;
	  }
	  else
	  {
            /*
             * loop to each curve and apply the projection process
             * Actually the function called performs the following:
             *  - project the lines[ii] onto the proper surface.
             *    Lines[ii] can produce n projected lines
             *    then for each piece of lines[ii] we:
             *
             *          - retrieve the geometry
             *          - do the stroking
             *          - execute what is explained above
             */
                sts = VLprojAndMapCrvOntoNonDevSrf( dev, cst, cht3D,
                                  &lines[i], IsMultiSol, 
                                  &numMapCrvs,  &mapCrvs, &msg );
		if( !(sts&msg&1) ) numMapCrvs = 0;
	  }
	  __DBGpr_int("\tNumber of curves returned ", numMapCrvs );

	  if( !numMapCrvs ) 
	  {
		numMapCrvs = 0;
		_FREE(mapCrvs );
		continue;
	  }

	  __DBGpr_int("\t*numCrvs+numMapCrvs ", (*numCrvs)+numMapCrvs );
	  __DBGpr_int("\tnb_Crvs_max ", nb_Crvs_max );
	  if( ( (*numCrvs)+numMapCrvs ) >= nb_Crvs_max)
	  {
	 	 nb_Crvs_max = *numCrvs + numMapCrvs + nb_lines - i;
		 __DBGpr_int("\tReallocated memory to ", nb_Crvs_max );
                 if( !( *Crvs = _REALLOC( *Crvs, nb_Crvs_max, struct GRid ) ) )
                    vd_$mem_fail(msg=&msg);
	  }

	  /*
	   * copy the result into the resulting structure 
	   */ 
	  for(j=0;j<numMapCrvs;j++) (*Crvs)[*numCrvs + j]  = mapCrvs[j];
	  *numCrvs += numMapCrvs;		
	  numMapCrvs = 0;
	  _FREE( mapCrvs );	
      } 

      __DBGpr_int("Final Output ", *numCrvs );	
      __DBGpr_objlist("Output Objects", *numCrvs, *Crvs );
      sts = MSSUCC;
wrapup:

      cst->geometry = NULL;
      _FREE( mapCrvs );

      End
      return sts;
	 
}/*end of VLprojAndMapCrvOntoSrf */


IGRlong VLprojAndMapRollCrvOntoSrf( dev, nb_lines, lines, IsMultiSol,
                                    cst, fromMat, toMat, numCrvs, Crvs)
struct unw_obj_plat     *dev;     /* I: Unwrap Structure */
int                     nb_lines; /* I: Number of lines */
struct GRobj_env        *lines;   /* I: Lines */
IGRboolean              IsMultiSol; /* I: The caller might already know that
                                single or multiple solution will be evaluated:
                                - IsMultiSol = TRUE ---> the curve to project
                                will return serveral pieces
                                - IsMultiSol = FALSE ---> The curve is already
                                considered on the surface. No projection
                                is applied. one to one mapping. This will
                                some precious time */
struct GRvg_construct   *cst;     /* I: Construction List */
IGRdouble               *fromMat, *toMat; /* I: Transformation Matrices */
int                     *numCrvs; /* O: Number of Output curves */
struct GRid             **Crvs;   /* O: Output curves List */
{
BSrc			rc;
IGRint			i, j, k;
IGRlong			sts, msg, loc_sts, loc_msg, nb_inter=0;
IGRshort                trfMatType;
IGRdouble		u[2], v[2], base[3], dist, ptDr[3], vecDr[6],
			spt[3], ept[3], trfMat[16];
OM_S_OBJID              *projCrvs=NULL;
struct GRobj_env	surface;
struct GRlc_info        curv_info,surf_info;

     SetProc( VLprojAndMapRollCrvOntoSrf ); Begin

     *numCrvs = 0;

      __DBGpr_obj( "dev->surf_id ", dev->surf_id.obj_id );
     sts = om$send( msg      = message NDnode.ASreturn_go(
                                        &surface.obj_id,
                                        &surface._matrix_type,
                                        surface._matrix ),
                senderid = NULL_OBJID,
                targetid = dev->surf_id.obj_id.objid,
                targetos = dev->surf_id.obj_id.osnum );
     if( sts & 1 )
     {
        surface._md_os = surface._osnum;
        ex$get_modid(   mod_osnum = surface._md_os,
                        mod_id    = &surface._md_id ) ;
        __DBGpr_obj( "Surface Module ID ", surface.mod_env.md_id );
     }
     else surface = dev->surf_id;
     __DBGpr_obj( "Surface Obj ID ", surface.obj_id );

     for( i=0; i<nb_lines; ++i )
     {
        curv_info.located_obj = lines[i].obj_id;
        curv_info.module_info = lines[i].mod_env;

     	surf_info.located_obj = surface.obj_id;
     	surf_info.module_info = surface.mod_env;

     	__DBGpr_obj("Curve to project ", curv_info.located_obj );
     	__DBGpr_obj("Surface Info ", surf_info.located_obj );

     	sts = om$send(msg=message 
			    EMSsubbs.EMproject_curve_along_surface_normals(
                                 &curv_info,
                                 &surf_info,
                                 cst,
                                 FALSE,
                                 TRUE,
                                 &nb_inter,
                                 &projCrvs,
                                 &msg),
                    senderid = surf_info.located_obj.objid,
                    targetid = surf_info.located_obj.objid,
                    targetos = surf_info.located_obj.osnum);
	if( !nb_inter ) goto continue_next;
	__DBGpr_int("Number of Intersections ", nb_inter );

	__DBGpr_int("Surafce Developpable? ", dev->developpable );
	for(j=0; j<nb_inter; j++)
	{
	   __DBGpr_int("Curve ", j+1 );
	   sts = om$send(msg=message GRcurve.GRendpts (
				&msg, &cst->env_info->md_env.matrix_type,
				cst->env_info->md_env.matrix, spt, ept ),
			senderid = NULL_OBJID,
			targetid = projCrvs[j],
			targetos = cst->env_info->md_id.osnum );
	   if( !(sts&1&msg) ) continue;
	   __DBGpr_vec("Start Point of PrjCurve ", spt );
	   __DBGpr_vec("End Point of PrjCurve ", ept );

	   if( dev->developpable > 0 )
	   {
	      sts = VLcreateLineSeg( spt, ept, cst->env_info, 
				     cst, &(*Crvs)[*numCrvs], &msg );
	      if( !(sts&1&msg) ) continue;
	      __DBGpr_obj("Output Curve ", (*Crvs)[*numCrvs] );

	      sts = VLapplyTransf( &(*Crvs)[*numCrvs], 1, cst->env_info,
			fromMat, toMat, trfMat, &trfMatType, &msg );
	      if( !(sts&1&msg) ) continue;
	      (*numCrvs) ++;
	   }
	   else
	   {
	      BSmdistptsf( &rc, dev->surface, spt, u, v, base, &dist );
	      if( rc != BSSUCC ) continue;

              BSmdistptsf( &rc, dev->surface, ept, u+1, v+1, base, &dist );
              if( rc != BSSUCC ) continue;

              if (dev->tesselation_option == PARAMETRIC)
              {
                  __DBGpr_com("Processing for Natural Mesh");
		  BSsfeval( dev->devsrf, u[0], v[0], 0, spt, &rc );
		  if( rc != BSSUCC ) continue;

		  BSsfeval( dev->devsrf, u[1], v[1], 0, ept, &rc );
                  if( rc != BSSUCC ) continue;
              }
              else
	      {
		  __DBGpr_com("Processing for Boundaries Mesh");
                  BSsfevaln( dev->surface, u[0], v[0], 1, &k, ptDr, vecDr, &rc);
		  if( rc != BSSUCC ) continue;

                  FAevPtSfFaDr( (IGRshort) 3,dev->P,dev->devsrf,dev->def,
                                    ptDr, vecDr, u[0], v[0], spt, &rc );
		  if( rc != BSSUCC ) continue;

                  BSsfevaln( dev->surface, u[1], v[1], 1, &k, ptDr, vecDr, &rc);
                  if( rc != BSSUCC ) continue;

                  FAevPtSfFaDr( (IGRshort) 3,dev->P,dev->devsrf,dev->def,
                                    ptDr, vecDr, u[1], v[1], ept, &rc );
                  if( rc != BSSUCC ) continue;
	      }
              __DBGpr_vec("Start Point on Unwrapped Surface ", spt );
              __DBGpr_vec("End Point on Unwrapped Surface ", ept );

              sts = VLcreateLineSeg( spt, ept, cst->env_info, 
				     cst, &(*Crvs)[*numCrvs], &msg );
              if( !(sts&1&msg) ) continue;
	      (*numCrvs)++;
	   }
	}


continue_next:
        for(j=0; j<nb_inter; j++)
        {
            loc_sts = om$send(msg = message GRgraphics.GRdelete( &loc_msg,
                                                     cst->env_info ),
                    senderid = NULL_OBJID,
                    targetid = projCrvs[j],
                    targetos = cst->env_info->md_id.osnum  );
        }

	nb_inter = 0;
	_FREE( projCrvs );
     }

wrapup:
     End
     return sts;
}

IGRlong VLunwBevelMap(  IGRlong         	*msg,
			struct unw_obj_plat     *dev ,
			struct GRobj_env	*edgeId,
			struct GRvg_construct	*cst,
			IGRdouble		*fromMat,
			IGRdouble		*toMat,
			struct GRid		*output )
{
BSrc			rc;
IGRlong                 sts;
struct GRobj_env	StrID;
struct IGRbsp_curve    	*edge_geom, *prj;

     SetProc( VLunwBevelMap ); Begin

     edge_geom = NULL;
     prj       = NULL;

     if (dev->developpable == 1)
     {
	IGRshort		trfMatType;
	IGRdouble		pnt[3], nrm[3], trfMat[16];
	struct GRobj_env	surface;
	struct IGRplane		plane;

	plane.point  = &pnt[0] ;
	plane.normal = &nrm[0] ;

      	__DBGpr_obj( "dev->surf_id ", dev->surf_id.obj_id );
     	sts = om$send( msg      = message NDnode.ASreturn_go(
                                        &surface.obj_id,
                                        &surface._matrix_type,
                                        surface._matrix ),
                senderid = NULL_OBJID,
                targetid = dev->surf_id.obj_id.objid,
                targetos = dev->surf_id.obj_id.osnum );
     	if( sts & 1 )
     	{
            surface._md_os = surface._osnum;
            ex$get_modid(   mod_osnum = surface._md_os,
                            mod_id    = &surface._md_id ) ;
            __DBGpr_obj( "Surface Module ID ", surface.mod_env.md_id );
        }
        else surface = dev->surf_id;
        __DBGpr_obj( "Surface Obj ID ", surface.obj_id );

        sts = om$send( msg = message GRvg.GRdetplane( msg,
                                                   &surface._matrix_type,
                                                   surface._matrix,
                                                   &plane ),
                 senderid = surface._objid,
		 targetid = surface._objid,
		 targetos = surface._osnum );
	__CheckRC( sts, *msg, "GRvg.GRdetplane", wrapup );
        __DBGpr_vec("Planar Surface Normal ", plane.normal );

	sts = VLgetGeometry( edgeId, FALSE, NULL_OBJID,
			     (IGRchar **)&edge_geom, msg );
	__CheckRC( sts, *msg, "VLgetGeometry", wrapup ) ;

        BSalloccv ( edge_geom->order, edge_geom->num_poles, 
	  	edge_geom->rational, edge_geom->num_boundaries, &prj, &rc);
	if( rc != BSSUCC ) { *msg = MSFAIL; goto wrapup; }

	BSprj_cv_pl( &rc, edge_geom, pnt, nrm, nrm, prj );
	if( rc != BSSUCC ) { *msg = MSFAIL; goto wrapup; }

        /* 16 Oct 2000 - Added env */
	VDdrawCurve( prj, cst->env_info, output );

        sts = VLapplyTransf( output, 1, cst->env_info,
                        fromMat, toMat, trfMat, &trfMatType, msg );
	__CheckRC( sts, *msg, "VLapplyTransf", wrapup ) ;
     }
     else
     {
         sts = VLbuildNeatUnwrapEdge( msg, dev, &edgeId->obj_id, cst, &StrID );
         __CheckRC( sts, *msg, "VL_unw_buildUnwrapEdge", wrapup );

	 *output = StrID.obj_id ;
     }

wrapup:
     _FREE( edge_geom );
     if( prj ) { BSfreecv( &rc, prj );   prj = NULL;     }
     End
     return sts;
}

end implementation VDSroot;

