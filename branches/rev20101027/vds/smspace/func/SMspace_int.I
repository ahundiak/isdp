/* $Id: SMspace_int.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/func / SMspace_int.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMspace_int.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  1998/12/18  14:20:12  pinnacle
# Replaced: smspace/func/SMspace_int.I for:  by impd251 for vds
#
# Revision 1.2  1998/12/17  17:37:30  pinnacle
# TR_179802025
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/04/10  14:49:52  pinnacle
# Replaced: smspace/func/SMspace_int.I for:  by impd for vds
#
# Revision 1.3  1998/02/25  17:59:08  pinnacle
# Replaced: smspace/func/SMspace_int*.I for:  by impd for vds
#
# Revision 1.2  1997/10/29  22:29:02  pinnacle
# TR179701957
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/09/20  19:26:02  pinnacle
# Replaced: smspace/func/SMspace_int.I for:  by jwfrosch for vds.241
#
# Revision 1.2  1996/04/29  09:15:42  pinnacle
# Replaced: smspace/func/SMspace_int.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/29/97	ah		TR179701987 Ref files not working
 *					Moved SMCrtSfBnd to SMspace_int1.I
 *	12/17/98	hf		TR179802025: SMint_support: Added 
 *					checks, "if (fabs(range[5]) > 1e12)"
 *					Test & correct transformation matrix:
 *					  surf[i].module_info.md_env.matrix_type
 *					  surf[i].module_info.md_env.matrix
 *
 * -------------------------------------------------------------------*/

/*

     PL       03-06-92  : Design date

ABSTRACT :

	Implements Functions used for the space management product.

	- 1/	SMint_curves
	- 2/	SMint_surfaces
	- 3/	SMint_support
	- 4/	SMIsTrack
	- 5/	SMget_sl_arc
	- 6/	SMIsEltInSlArc
	- 7/	SMIsEqualPt
	- 8/	SMIsEqualArc
	- 9/	SMint_ordercurves
	- 10/	SMCreatBndSurf
	- 11/	SMCreatBndPl
	- 12/   SMSurfBnd
	- 13/   SMCreatBndVol
	- 14/   SMGetDummyPl
	- 15/   SMImpBndSf
	- 16/   SMGetPtInArea
	- 17/	SMGetSfNotInLoop
	- 18/	SMBndBool
	- 19/   SMCrtSfBnd
	- 20/	SMGetInfFrmMask
	- 21/	SMGetMaskFrmInf
	- 22/   SMCrtVolBnd
	- 23/   SMOrdBndVol
	- 24/   SMOrdBndSf
	- 25/   SMCrtOrdSfBnd
	- 26/   SMCrtOrdVolBnd

*/

class implementation Root;

#include <stdio.h>
#include <string.h>
#include <math.h>

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grerr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "parametric.h"
#include "asmacros.h"

#include "bstypes.h"
#include "bserr.h"
#include "bsconic.h"

#include "emsdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "emsmapdef.h"
#include "emsimpdef.h"
#include "EMSssprops.h"
#include "EMSmsgdef.h"
#include "EMS.h"
#include "EMSopt.h"
#include "emssfintdef.h"
#include "VDSutil_def.h"
#include "macro.h"
#include "AS_status.h"
#include "SMgraph.h"
#include "SMmsg.h"
#include "VDmem.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"

/* include prototype */

#include "bsprptoncv.h"
#include "bsdistptpt.h"
#include "bspl_pl.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsmdstptcv.h"
#include "bsmdistcvcv.h"
#include "bsmdistptcv.h"
#include "bsmdistptsf.h"
#include "bsptlngen.h"
#include "bscvcv_int.h"
#include "bscveval_b.h"
#include "bscvarrevt.h"
#include "bsprj_cv_pl.h"
#include "bstst_plan.h"
#include "bsavgpts.h"
#include "bscvcoplan.h"
#include "bscollin.h"
#include "bsconstprcv.h"
#include "bsorthovec.h"

#define VD_DEBUG

#include "VDdebug.h"

/* #define   DEBUG 	1*/

/*#define OFF_DEBUG	1*/ 

#define   AS_DEBUG	1
#define   ORDER	2

from GRvg		import	GRgetgeom, GRgetsize, GRdetplane, GRprojpt,
				EMintplane,GRcenter;
from EMSsubbs		import	EMtangent_normal, EMget_props, EMreduce_range,
				EMset_props;
from GRgraphics		import	GRgetrang, GRdelete, GRconstruct, GRcopy;
from GRowner		import	GRget_number_components,GRget_components,GRdrop ;
from EMSplane		import	EMplane, EMplane_of_curve;
from GRcurve		import	GRrevparm;
from EMSproject		import	EMplace_surface_of_projection;
from EMSsurface		import	EMoffset, EMimpose_boundaries,
				EMgetactiveid, EMputLsIfNotThere;
from EMSsfboolean	import	EMboolean;
from EMSdpr		import	EMmake_primitive1;
from EMSsfstitch	import	EMmake_comp;
from ASnode		import	ASreturn_go;
from EMSsolid		import	EMorient_yourself;
from EMSsfdpr		import	EMgetsolidclass;
from EMSsubbs		import	GRgenabsg;

extern GRclassid	OPP_EMSplane_class_id, OPP_EMSsurface_class_id,
			OPP_GRcurve_class_id,OPP_EMScompsurf_class_id,
			OPP_EMSsubbs_class_id,OPP_EMSsfimpbnd_class_id,
			OPP_EMSproject_class_id,OPP_GRbcsubbc_class_id,
			OPP_EMSsfboolean_class_id, OPP_GRgrgrp_class_id,
			OPP_EMSsfstitch_class_id;

extern short _Pathway, _pathway_trim, _pathway_orient;

/*1 ======================  SMint_curves ======================

	Given an array of curves, the function computes all the
	intersections between them and sorts the intersection pts in
	an array of struct SMinters (cf SMgraph.h).
	SMinters is allocated in the function and must be deallocated
	by the user.

	The basis_tolerance and the chord_height_tolerance are modified
	to compute the intersections and then restore.

	return(1) if ok.
	else return(0).
*/

int	SMint_curves(nb_curves, curves, ordered, nb_inters, inters)
int			nb_curves;	/* (I) nb curves to intersect */
struct IGRbsp_curve	**curves;	/* (I) input curves */
IGRint			ordered;	/* (I) 1 if ordered input surface */
int			*nb_inters;	/* (O) nb intersections returned */
struct SMinters		**inters;	/* (O) intersections returned */

/*.SMint_curves*/
{
  int			i,k,l, next, n_int,tnb_inters, tnb_alloc;
  IGRboolean		oncurve, err_flag;
  BSrc			rc;
  IGRdouble		*pt1, *pt2,*par1, *par2, eps, dist0, dist, cht_tol;
  IGRlong		msg, nput, nret;
  struct SMinters	*tinters;

  if(nb_curves < 2 || curves == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }

  __enterFunction ( name = "SMint_curves" );

  if(inters != NULL) *inters = NULL;

  tinters = NULL;
  par1 = NULL;
  par2 = NULL;
  pt1 = NULL;
  pt2 = NULL;

  err_flag = FALSE;

  nput = sizeof(cht_tol);

  gr$get_chord_height_tolerance(msg    = &msg,
				sizbuf = &nput,
				buffer = &cht_tol,
				nret   = &nret);

  if(!(msg&1))
  {
    if (OM_Gf_verbose_warning) printf("error gr$get_chord_height_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }

  eps = 2*cht_tol;

  tnb_inters = 0;

  tnb_alloc = 2*nb_curves;
  tinters = _MALLOC (tnb_alloc, struct SMinters);
  if(tinters == NULL){
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }

  if(ordered )
  {
    for(i=0;i<nb_curves;i++)
    {
      if(i == nb_curves - 1) next = 0;
      else next = i+1;
      dist0 = eps;
      (void)VDmdistcvcv(curves[i], curves[next], &n_int, &pt1, &pt2,
			dist0, &dist, eps, &msg);
      if(dist > eps) n_int = 0;
      __printf ( ">>>> ORDERED msg = %d, n_int = %d, dist0 = %lg, dist = %lg", `msg, n_int, dist0, dist`);
      
      if(n_int)
      {
	par1 = _MALLOC(n_int, IGRdouble);
	if(par1 == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	par2 = _MALLOC(n_int, IGRdouble);
	if(par2 == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
      }

      for(l=0;l<n_int;l++)
      {
	(IGRboolean)BSprptoncv(&rc, curves[i], &pt1[3*l], &par1[l], &oncurve);
	if(rc != BSSUCC || oncurve == FALSE)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR 1 )BSprptoncv\n");
	  err_flag = TRUE;
	  goto wrapup;
	}

	(IGRboolean)BSprptoncv(&rc, curves[next], &pt2[3*l], &par2[l], &oncurve);

	if(rc != BSSUCC || oncurve == FALSE)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR 2 )BSprptoncv\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
      }

      for(l=0;l<n_int;l++)
      {
	if(tnb_inters >= tnb_alloc)
	{
	  tnb_alloc = tnb_alloc + INCR_ALLOC;
	  tinters = _REALLOC ( tinters, tnb_alloc, struct SMinters);
	  if(tinters == NULL)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }
	}
	tinters[tnb_inters].cv1 = i;
	tinters[tnb_inters].cv2 = next;
	tinters[tnb_inters].par1 = par1[l];
	tinters[tnb_inters].par2 = par2[l];
	tinters[tnb_inters].pt[0] = (pt1[3*l]+ pt2[3*l])/2;
	tinters[tnb_inters].pt[1] = (pt1[3*l+1]+ pt2[3*l+1])/2;
	tinters[tnb_inters].pt[2] = (pt1[3*l+2]+ pt2[3*l+2])/2;
	tnb_inters ++;

      }
      _FREE(par1);
      _FREE(par2);
      _FREE(pt1);
      _FREE(pt2);
    }

  }
  else
  {
    for(i=0;i<nb_curves;i++)
    {
      for(k=i+1;k<nb_curves;k++)
      {
	dist0 = eps;
	(void)VDmdistcvcv(curves[i], curves[k], &n_int, &pt1, &pt2,
			  dist0, &dist, eps, &msg);
      if(dist > eps) n_int = 0;
      __printf ( ">>>> NOT ORDERED msg = %d, n_int = %d, dist0 = %lg, dist = %lg", `msg, n_int, dist0, dist`);
	if(n_int)
	{
	  par1 = _MALLOC(n_int, IGRdouble);
	  if(par1 == NULL)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }
	  par2 = _MALLOC(n_int, IGRdouble);
	  if(par2 == NULL)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }
	}
	for(l=0;l<n_int;l++)
	{
	  (IGRboolean)BSprptoncv(&rc, curves[i], &pt1[3*l],
				 &par1[l], &oncurve);
	  if(rc != BSSUCC || oncurve == FALSE)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR 3 )BSprptoncv\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }

	  (IGRboolean)BSprptoncv(&rc, curves[k], &pt2[3*l],
				 &par2[l], &oncurve);
	  if(rc != BSSUCC || oncurve == FALSE)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR 4 )BSprptoncv\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }
	}
	for(l=0;l<n_int;l++)
	{
	  if(tnb_inters >= tnb_alloc)
	  {
	    tnb_alloc = tnb_alloc + INCR_ALLOC;
	    tinters = _REALLOC ( tinters, tnb_alloc, struct SMinters);
	    if(tinters == NULL)
	    {
	      if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	      err_flag = TRUE;
	      goto wrapup;
	    }
	  }
	  tinters[tnb_inters].cv1 = i;
	  tinters[tnb_inters].cv2 = k;
	  tinters[tnb_inters].par1 = par1[l];
	  tinters[tnb_inters].par2 = par2[l];
	  tinters[tnb_inters].pt[0] = (pt1[3*l]+ pt2[3*l])/2;
	  tinters[tnb_inters].pt[1] = (pt1[3*l+1]+ pt2[3*l+1])/2;
	  tinters[tnb_inters].pt[2] = (pt1[3*l+2]+ pt2[3*l+2])/2;
	  tnb_inters ++;

	}
	_FREE(par1);
	_FREE(par2);
	_FREE(pt1);
	_FREE(pt2);

      }
    }
  }

  if(nb_inters != NULL) *nb_inters = tnb_inters;
  if(inters != NULL && tnb_inters > 0)
  {
    (*inters) = NULL;
    (*inters) = _MALLOC(tnb_inters, struct SMinters);
    if((*inters) == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<tnb_inters;i++) (*inters)[i] = tinters[i];
  }

wrapup:

  _FREE(par1);
  _FREE(par2);
  _FREE(pt1);
  _FREE(pt2);
  _FREE(tinters);

  if(err_flag == TRUE)
  {
    if(inters != NULL && (*inters) != NULL)   _FREE(*inters);

    __exit_error_Function ( name = "SMint_curves" );
    
    return(0);
  }
  else
  {
    __exitFunction ( name = "SMint_curves" );
  
    return(1);
  }
}

/*2 ======================  SMint_surfaces ======================

	Given an array of surfaces , the function
	computes all the intersections between the surfaces and sorts
	the intersection curves in an array of struct SMsfinters
	(cf SMgraph.h).
	SMsfinters and SMcurve are allocated in the function and must be
	deallocated by the user.

	infinite is the flag for each object that indicates if the planes
	must be considered as infinite or not.

	The intersection curves are constructed except for plan/plan
	intersection (cvint_id.objid = NULL_OBJID )

	cvint_id.cv_geom is filled for all type of intersections.

	elem_type and sfinfo must be allocated by the user of nb_surf.

	return(1) if ok.
	else return(0).
*/

int	SMint_surfaces(msg, nb_surf, surf, cst, infinite, nb_inters, inters,
			SMcurve, elem_type)
long			*msg;		/* (O) completion code */
int			nb_surf;	/* (I) nb surf to intersect */
struct GRlc_info	*surf;		/* (I) input surfaces */
struct GRvg_construct   *cst;		/* (I) construction list  */
char			*infinite;	/* (I) flag for each surf */
int			*nb_inters;	/* (O) nb intersections returned */
struct SMsfinters	**inters;	/* (O) intersections returned */
struct SMcurve		**SMcurve;	/* (O) only to fill geom */
int			*elem_type;	/* (O) type of each surface */

/*.SMint_surfaces*/
{
  int			i,j, k,l, stat, tnb_inters, tnb_alloc, tmp, nb_sf1,
			type_flag,int_flag, num_pts, num_inter,sftype[2],
			i_alloc, count,nb_obj, n_pla;
  IGRboolean		world, err_flag;
  struct SMsfinters	*tinters;
  IGRdouble		plane_space[12], fact, range[6], obj_range[6],q[3],
			u[3],v1[3],v2[3], coef, basis_tol;
  struct IGRplane	plane[2];
  long			nput, nret, size;
  BSrc			rc;
  struct GRvg_construct tmp_cst;
  struct IGResbc	curve_specific;
  IGRushort		trim;
  struct GRid		*OBJECT, *GRint, *COMP;
  char			running[DI_PATH_MAX];
  GRclassid		obj_classid;

  GRint = NULL;
  tinters = NULL;
  tnb_inters = 0;
  OBJECT = NULL;
  COMP = NULL;
  fact = 0.;

  if(nb_surf < 2 || surf == NULL || elem_type == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  __enterFunction ( name = "SMint_surfaces" );

  err_flag = FALSE;
  if(inters != NULL) *inters = NULL;

  if(msg != NULL) *msg = MSSUCC;

  plane[0].point  = &plane_space[0];
  plane[0].normal = &plane_space[3];
  plane[1].point  = &plane_space[6];
  plane[1].normal = &plane_space[9];

  nput = sizeof(basis_tol);

  gr$get_basis_tolerance(	msg    = msg,
				sizbuf = &nput,
				buffer = &basis_tol,
				nret   = &nret);

  if(!((*msg)&1))
  {
    if (OM_Gf_verbose_warning) printf("error gr$get_basis_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }

  tnb_alloc = 2*nb_surf;
  tinters = _MALLOC (tnb_alloc, struct SMsfinters);
  if(tinters == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i_alloc=0;i_alloc<tnb_alloc;i_alloc++) tinters[i_alloc].cv_geom = NULL;

  for(i=0;i<nb_surf;i++)
  {
    if(i==0)
    {
      world = TRUE;
      stat = om$send( msg = message GRgraphics.GRgetrang(msg,
							 &surf[i].module_info.md_env.matrix_type,
							 surf[i].module_info.md_env.matrix,
							 &world, range),
		      senderid = NULL_OBJID,
		      targetid = surf[i].located_obj.objid,
		      targetos = surf[i].located_obj.osnum );

      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRgetrang\n" );
	err_flag = TRUE;
	goto wrapup;
      }
    }
    else
    {
      world = TRUE;
      stat = om$send( msg = message GRgraphics.GRgetrang(msg,
							 &surf[i].module_info.md_env.matrix_type,
							 surf[i].module_info.md_env.matrix,
							 &world, obj_range),
		      senderid  = NULL_OBJID,
		      targetid = surf[i].located_obj.objid,
		      targetos = surf[i].located_obj.osnum );
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRgetrang \n");
	err_flag = TRUE;
	goto wrapup;
      }
      for(k=0;k<3;k++)
      {
	if(range[k]   > obj_range[k]  )
	   range[k]   = obj_range[k];
	if(range[k+3] < obj_range[k+3])
	   range[k+3] = obj_range[k+3];
      }
    }
  } /* end for(i=0 ....) */

  for(i=0;i<nb_surf;i++)
  {
    tmp_cst = (*cst);
    if (infinite[i] != 'y' && infinite[i] != 'Y')	type_flag = SURF;
    else						type_flag = PLAN;

    nb_sf1 = 0;

    stat = SMelem_(type_flag, &surf[i].located_obj,
		   surf[i].module_info.md_env.matrix_type,
		   surf[i].module_info.md_env.matrix,
		   &elem_type[i],
		   &plane[0], NULL, NULL, &nb_sf1);
    sftype[0] = elem_type[i];
    if (!(stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR fonction SMelem_\n");
      err_flag = TRUE;
      goto wrapup;
    }
    if(sftype[0] == CURV)
    {
      if (OM_Gf_verbose_warning) printf("ERROR: element cannot be a curve\n");
      err_flag = TRUE;
      goto wrapup;
    }
    if(sftype[0] == PLAN)
    {
      fact = 1.1 * (IGRdouble)BSdistptpt(&rc, range, &(range[3]));
      if(rc != BSSUCC)
      {
	if (OM_Gf_verbose_warning) printf("ERROR BSdistptpt,\n");
	err_flag = TRUE;
	goto wrapup;
      }
    }
    for(k=i+1;k<nb_surf;k++)
    {
      if (infinite[k] != 'y' && infinite[k] != 'Y')	type_flag = SURF;
      else						type_flag = PLAN;

      nb_sf1 = 0;
      stat = SMelem_(type_flag, &surf[k].located_obj,
		     surf[k].module_info.md_env.matrix_type,
		     surf[k].module_info.md_env.matrix, &elem_type[k],
		     &plane[1], NULL, NULL, &nb_sf1);
      sftype[1] = elem_type[k];
      if (!(stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR fonction SMelem_\n");
	err_flag = TRUE;
	goto wrapup;
      }
      if(sftype[1] == CURV)
      {
	if (OM_Gf_verbose_warning) printf("ERROR: element cannot be a curve\n");
	err_flag = TRUE;
	goto wrapup;
      }

      n_pla = 0;

      sprintf(running,"%s%d%s%d","intersect surface ",i," with surface ",k);
      UI_status(running);

      if(sftype[0] == PLAN) n_pla = 1;
      if(sftype[1] == PLAN) n_pla = n_pla + 2;

      if( n_pla == 3 ){

	if(tnb_inters >= tnb_alloc)
	{
	  tmp = tnb_alloc + INCR_ALLOC;
	  tinters = _REALLOC (tinters, tmp, struct SMsfinters);
	  if(tinters == NULL)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }
	  for(i_alloc=tnb_alloc;i_alloc<tmp;i_alloc++) tinters[i_alloc].cv_geom = NULL;
	  tnb_alloc = tmp;
	}
	tinters[tnb_inters].sf1 = i;
	tinters[tnb_inters].sf2 = k;
	tinters[tnb_inters].cvint_id.objid = NULL_OBJID;
	tinters[tnb_inters].alloc_flag = TRUE;
	tinters[tnb_inters].cv_geom = NULL;
	(void)BSpl_pl(plane[0].point, plane[0].normal,
		      plane[1].point, plane[1].normal,
		      &int_flag, q, u, &rc);
	if(rc != BSSUCC )
	{
	  if (OM_Gf_verbose_warning) printf(" ERROR in BSpl_pl\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	if (int_flag != BSCINTERSECTING) continue;

	num_pts = 2;
	(void)BSalloccv(ORDER, num_pts, 0, 0,
			&(tinters[tnb_inters].cv_geom), &rc);
	if(rc != BSSUCC && rc!=BSNULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	tinters[tnb_inters].cv_geom->planar    = TRUE;
	tinters[tnb_inters].cv_geom->phy_closed= FALSE;
	tinters[tnb_inters].cv_geom->order     = ORDER;
	tinters[tnb_inters].cv_geom->num_poles = num_pts;
	tinters[tnb_inters].cv_geom->num_knots = num_pts + 2 * (ORDER - 1);

	/* Compute the end points of the line to do the intersection */

	(IGRboolean)BSmkvec(&rc, v1, range    , q);
	(IGRboolean)BSmkvec(&rc, v2, &range[3], q);

	if((IGRdouble)BSdotp(&rc,v1,v2) <= 0)
	{
	  /*|The point of the infinit line is inside the range*/
	}
	else
	{
	  /*|The point of the infinit line is not inside the range*/

	  fact = fact + (IGRdouble)BSdistptpt(&rc, q, range);
	}

	for(l=0;l<3;l++)
	{
	  tinters[tnb_inters].cv_geom->poles[l]   = q[l] - fact * u[l];
	  tinters[tnb_inters].cv_geom->poles[l+3] = q[l] + fact * u[l];
	  tinters[tnb_inters].cv_geom->knots[l+1] = (double) l/ (num_pts-1);
	}
	tinters[tnb_inters].cv_geom->knots[0]	 = 0;
	tinters[tnb_inters].cv_geom->knots[num_pts+1] = 1;
	tnb_inters ++;

	continue;
      }
      else if( n_pla == 0 )
      {
	/*===================================================*/
	/* general routine to intersect any type of element  */
	/*===================================================*/
	curve_specific.is_polydis = TRUE;
	curve_specific.is_curvedis = TRUE;
	GRint = NULL;
	tmp_cst.class_attr = (IGRchar *) &curve_specific;
	trim = EMSINT_TRIM_HANDLESTOP | NULL; /* trimming option */

	stat = EMintersect_two_element(	&(surf[i]),
					&(surf[k]),
					trim,
					&tmp_cst,
					&num_inter,
					&GRint,
					msg);
	as$status(sts = stat);
	if(!(stat & (*msg) & 1))
	{
	  if (OM_Gf_verbose_warning) printf("ERROR in EMintersect_two_element\n");
	  om$report_error(sts=stat);
	  err_flag = TRUE;
	  goto wrapup;
	}
      }
      else if( n_pla == 1 )
      {
	/*=========================================================*/
	/*  the first parent is a plane				   */
	/*=========================================================*/
	GRint = NULL;
	stat = om$send( msg      = message GRvg.EMintplane(
							   &tmp_cst,
							   &plane[0],
							   &surf[k],
							   &num_inter,
							   &GRint,
							   (int *)msg ),
			senderid = NULL_OBJID,
			targetid = surf[k].located_obj.objid,
			targetos = surf[k].located_obj.osnum );
	as$status(sts=stat);
	if (!((*msg)&stat&1))
	{
	  if (OM_Gf_verbose_warning) printf("ERROR in GRvg.EMintplane  \n");
	  err_flag = TRUE;
	  goto wrapup;
	}

      }
      else if( n_pla == 2 )
      {
	/*=========================================================*/
	/*  the second parent is a plane			   */
	/*=========================================================*/

	GRint = NULL;
	stat = om$send( msg      = message GRvg.EMintplane(
							   &tmp_cst,
							   &plane[1],
							   &surf[i],
							   &num_inter,
							   &GRint,
							   (int *)msg ),
			senderid = NULL_OBJID,
			targetid = surf[i].located_obj.objid,
			targetos = surf[i].located_obj.osnum );
	as$status(sts=stat);
	if (!((*msg)&stat&1))
	{
	  if (OM_Gf_verbose_warning) printf("ERROR in GRvg.EMintplane  \n");
	  err_flag = TRUE;
	  goto wrapup;
	}
      }

      if(num_inter < 1) continue;

      for(l=0;l<num_inter;l++)
      {
	stat = om$get_classid(	osnum     = GRint[l].osnum,
				objid     = GRint[l].objid,
				p_classid = &obj_classid);
	if( om$is_ancestry_valid(subclassid   = obj_classid,
				 superclassid = OPP_GRgrgrp_class_id )
	    == OM_S_SUCCESS )
	{
	  stat = om$send( msg = message GRowner.GRget_number_components
			  (msg, &nb_obj),
			  senderid = NULL_OBJID,
			  targetid = GRint[l].objid,
			  targetos = GRint[l].osnum );
	  as$status(sts=stat);
	  if (!((*msg)&stat&1))
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR in GRowner.GRget_number_components\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }

	  OBJECT = NULL;
	  OBJECT =  _MALLOC(nb_obj, struct GRid);
	  if(OBJECT == NULL)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }

	  stat = om$send( msg = message GRowner.GRget_components
			  (msg, tmp_cst.env_info,OBJECT, nb_obj,
			   &count,0,nb_obj),
			  senderid = NULL_OBJID,
			  targetid = GRint[l].objid,
			  targetos = GRint[l].osnum );
	  as$status(sts=stat);
	  if (!((*msg)&stat&1))
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR in GRowner.GRget_components \n");
	    err_flag = TRUE;
	    goto wrapup;
	  }

	  for(j=0;j<count;j++)
	  {
	    if(tnb_inters >= tnb_alloc)
	    {
	      tmp = tnb_alloc + count * num_inter + 1;
	      tinters = _REALLOC ( tinters, tmp, struct SMsfinters);
	      if(tinters == NULL)
	      {
		if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
		err_flag = TRUE;
		goto wrapup;
	      }
	      for(i_alloc=tnb_alloc;i_alloc<tmp;i_alloc++) tinters[i_alloc].cv_geom = NULL;
	      tnb_alloc = tmp;
	    }
	    tinters[tnb_inters].sf1 = i;
	    tinters[tnb_inters].sf2 = k;
	    tinters[tnb_inters].cvint_id = OBJECT[j];
	    tinters[tnb_inters].cv_geom = NULL;
	    tnb_inters ++;
	  }
	  _FREE(OBJECT);
	}
	else
	{
	  if(tnb_inters >= tnb_alloc)
	  {
	    tmp = tnb_alloc + num_inter + 1;
	    tinters = _REALLOC (tinters, tmp, struct SMsfinters);
	    if(tinters == NULL)
	    {
	      if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	      err_flag = TRUE;
	      goto wrapup;
	    }
	    for(i_alloc=tnb_alloc;i_alloc<tmp;i_alloc++) tinters[i_alloc].cv_geom = NULL;
	    tnb_alloc = tmp;
	  }
	  tinters[tnb_inters].sf1 = i;
	  tinters[tnb_inters].sf2 = k;
	  tinters[tnb_inters].cvint_id = GRint[l];
	  tinters[tnb_inters].cv_geom = NULL;
	  tnb_inters ++;
	}
      }
      _FREE(GRint);
    }

  }  /* End of  for(i=0;i<num_ent;i=i+1) */

  for(i=0;i<tnb_inters;i++)
  {
    tinters[i].alloc_flag = TRUE;
    if(tinters[i].cv_geom == NULL)
    {
      tinters[i].alloc_flag = FALSE;

      stat = om$send(msg = message GRvg.GRgetsize(msg,
						  &(tmp_cst.env_info->md_env.matrix_type),
						  tmp_cst.env_info->md_env.matrix,
						  &size ),
		     senderid = NULL_OBJID,
		     targetid = tinters[i].cvint_id.objid,
		     targetos = tinters[i].cvint_id.osnum );

      as$status(sts = stat);
      if(!(stat & (*msg) &1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetsize\n");
	err_flag = TRUE;
	goto wrapup;
      }

      tinters[i].cv_geom = (struct IGRbsp_curve *)_MALLOC(size, char);

      if(tinters[i].cv_geom == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR, Bad dynamic allocation \n");
	err_flag = TRUE;
	goto wrapup;
      }

      stat = om$send(msg = message GRvg.GRgetgeom(msg,
						  &((tmp_cst.env_info)->md_env.matrix_type),
						  (tmp_cst.env_info)->md_env.matrix,
						  (char *) tinters[i].cv_geom),
		     senderid = NULL_OBJID,
		     targetid = tinters[i].cvint_id.objid,
		     targetos = tinters[i].cvint_id.osnum );
      as$status(sts = stat);
      if(!(stat & (*msg) &1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetgeom\n");
	err_flag = TRUE;
	goto wrapup;
      }

      coef = 0;
      for(k=0;k<3;k=k+1)
      {
	coef = coef + fabs(tinters[i].cv_geom->poles[k] -
			   tinters[i].cv_geom->poles[3*(tinters[i].cv_geom->num_poles-1)+k]);
      }

      if (coef < basis_tol)	tinters[i].cv_geom->phy_closed = TRUE;
      else			tinters[i].cv_geom->phy_closed = FALSE;

    }
  }

  if(nb_inters != NULL) *nb_inters = tnb_inters;
  if(inters != NULL && tnb_inters != 0)
  {
    *inters = NULL;
    *inters = _MALLOC(tnb_inters, struct SMsfinters);
    if( (*inters) == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<tnb_inters;i++)
    {
      (*inters)[i].sf1 = tinters[i].sf1;
      (*inters)[i].sf2 = tinters[i].sf2;
      (*inters)[i].cvint_id = tinters[i].cvint_id;
      (*inters)[i].alloc_flag = tinters[i].alloc_flag;
      (*inters)[i].cv_geom = tinters[i].cv_geom;

    }
  }
  if(SMcurve != NULL && tnb_inters != 0)
  {
    *SMcurve = NULL;
    *SMcurve = _MALLOC(tnb_inters, struct SMcurve);
    if( (*SMcurve) == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<tnb_inters;i++)
    {
      (*SMcurve)[i].nb_intpt = 0;
      (*SMcurve)[i].pt_index = NULL;
      (*SMcurve)[i].cv_geom = tinters[i].cv_geom;
    }
  }
wrapup:
  UI_status("");
  _FREE(COMP);
  _FREE(GRint);
  _FREE(OBJECT);
  if(err_flag == TRUE)
  {
    if(tinters != NULL)
    {
      for(i=0;i<tnb_inters;i++)
      {
	if(tinters[i].cv_geom != NULL)
	{
	  if(tinters[i].alloc_flag == TRUE)
	  {
	    (IGRboolean)BSfreecv(&rc, tinters[i].cv_geom);
	  }
	  else
	  {
	    _FREE(tinters[i].cv_geom);
	  }

	  tinters[i].cv_geom = NULL;
	}
      }
      _FREE(tinters);
    }
    if(inters != NULL && (*inters) != NULL)_FREE(*inters);

    __exit_error_Function ( name = "SMint_surfaces" );

    return(0);
  }

  _FREE(tinters);
  __exitFunction ( name = "SMint_surfaces" );

  return(1);
}

/*3 ======================  SMint_support ======================

	Given an array of objects (surfaces or curves) with the
	first one taken as the support (first obj must be a surface),
	the function computes all the intersections between the support
	and each surfaces and sorts the intersection curves in an array of
	struct SMsfinters (cf SMgraph.h).

	If objects are curves, just fill the structure SMsfinters.

	SMsfinters and SMcurve are allocated in the function and must be
	deallocated by the user.
	infinite are the flag for each object that indicates if the planes
	must be considered as infinite or not.

	The intersection curves are constructed except for plan/plan
	intersection (cvint_id.objid = NULL_OBJID )

	cvint_id.cv_geom is filled for all type of intersections.
	if typesf is wanted (not NULL) it must be allocated by the user of
	nb_surf.

	return(1) if ok.
	else return(0).
*/

int	SMint_support(msg, nb_surf, surf, cst, infinite,
			nb_inters, inters, SMcurve, typesf)
long			*msg;		/* (O) completion code */
int			nb_surf;	/* (I) nb surf to intersect */
struct GRlc_info	*surf;		/* (I) input surfaces */
struct GRvg_construct   *cst;		/* (I) construction list  */
char			*infinite;	/* (I) flag for each surf */
int			*nb_inters;	/* (O) nb intersections returned */
struct SMsfinters	**inters;	/* (O) intersections returned */
struct SMcurve		**SMcurve;	/* (O) only to fill geom */
int			*typesf;	/* (O) return type of surf */
/*.SMint_support*/
{
  int			i,j,k,l, stat, tnb_inters, tnb_alloc, tmp,nb_sf1,
			type_flag,int_flag, elem_type[2],num_pts, num_inter,
			count, nb_obj, n_pla, i_alloc;
  IGRboolean		world, err_flag;
  struct SMsfinters	*tinters;
  IGRdouble		plane_space[12], fact, range[6], obj_range[6],q[3],
			u[3],v1[3],v2[3], coef, basis_tol;
  struct IGRplane	plane[2];
  struct GRvg_construct tmp_cst;
  BSrc			rc;
  struct IGResbc	curve_specific;
  IGRushort		trim;
  long			nput, nret, size;
  struct GRid		*OBJECT, *GRint, *COMP;
  char			running[DI_PATH_MAX];
  GRclassid		obj_classid;

  GRint = NULL;
  tinters = NULL;
  tnb_inters = 0;
  OBJECT = NULL;
  COMP = NULL;
  fact = 0.;

  if(nb_surf < 2 || surf == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  __enterFunction ( name = "SMint_support" );

  if(msg != NULL) *msg = MSSUCC;
  err_flag = FALSE;
  if(inters != NULL) *inters = NULL;

  plane[0].point  = &plane_space[0];
  plane[0].normal = &plane_space[3];
  plane[1].point  = &plane_space[6];
  plane[1].normal = &plane_space[9];

  nput = sizeof(basis_tol);

  gr$get_basis_tolerance(	msg    = msg,
				sizbuf = &nput,
				buffer = &basis_tol,
				nret   = &nret);

  if(!((*msg)&1))
  {
    if (OM_Gf_verbose_warning) printf("error gr$get_basis_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }

  tnb_alloc = 2*nb_surf;
  tinters = _MALLOC (tnb_alloc, struct SMsfinters);
  if(tinters == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i_alloc=0;i_alloc<tnb_alloc;i_alloc++) tinters[i_alloc].cv_geom = NULL;

  for(i=0;i<nb_surf;i++)
  {
    int rng_corr = 0;

    if ( surf[i].module_info.md_env.matrix_type == 0 )	// HF: 12/18/98 INVALID Matrix: convert to Identity Matrix
    {
      int j = 0;
      
      surf[i].module_info.md_env.matrix_type = 2;
      for(j=0; j < 16; j++)
      {
	surf[i].module_info.md_env.matrix[j] = 0.0;
      }
      for(j=0; j < 16; j+=4)
      {
	surf[i].module_info.md_env.matrix[j] = 1.0;
      }
      rng_corr = 1;
    }
    
    if(i==0)
    {
      world = TRUE;
      range[0] = range[1] = range[2] = -1.0;
      range[3] = range[4] = range[5] =  1.0;
      
      stat = om$send( msg = message GRgraphics.GRgetrang(msg,
							 &surf[i].module_info.md_env.matrix_type,
							  surf[i].module_info.md_env.matrix,
							 &world, range),
		      senderid = NULL_OBJID,
		      targetid = surf[i].located_obj.objid,
		      targetos = surf[i].located_obj.osnum );

      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRgetrang\n" );
	err_flag = TRUE;
	goto wrapup;
      }
      // HF: Some extra tests; probably unnecessary now (because of converting invalid matrix to identity)
      if (fabs(range[5]) > 1e12)
      {
	range[5] = 999.0;
	rng_corr = 1;
      }
      if (fabs(range[2]) > 1e12)
      {
	range[2] = -999.0;
	rng_corr = 1;
      }
      if ( rng_corr )
      {
  	double * ptr = NULL;
	
	__printf ("Range %d adjusted [%d,%d] : %lg %lg %lg %lg %lg %lg", `i, surf[i].located_obj.osnum, surf[i].located_obj.objid,
		  range[0], range[1], range[2], range[3], range[4], range[5]`);

	ptr = (double *)surf[i].module_info.md_env.matrix;
	
	__printf ("Matrix_type = %d", `surf[i].module_info.md_env.matrix_type`);
	__printf ("              %lg, %lg, %lg, %lg",`ptr[0], ptr[1], ptr[2], ptr[3]`);
	__printf ("              %lg, %lg, %lg, %lg",`ptr[4], ptr[5], ptr[6], ptr[7]`);
	__printf ("              %lg, %lg, %lg, %lg",`ptr[8], ptr[9], ptr[10], ptr[11]`);
	__printf ("              %lg, %lg, %lg, %lg",`ptr[12], ptr[13], ptr[14], ptr[15]`);
      }
    }
    else
    {
      world = TRUE;
      obj_range[0] = obj_range[1] = obj_range[2] = -1.0;
      obj_range[3] = obj_range[4] = obj_range[5] =  1.0;

      stat = om$send( msg = message GRgraphics.GRgetrang(msg,
							 &surf[i].module_info.md_env.matrix_type,
							  surf[i].module_info.md_env.matrix,
							 &world, obj_range),
		      senderid  = NULL_OBJID,
		      targetid = surf[i].located_obj.objid,
		      targetos = surf[i].located_obj.osnum );
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRgetrang \n");
	err_flag = TRUE;
	goto wrapup;
      }

      // HF: Some extra tests; probably unnecessary now (because of converting invalid matrix to identity)
      if (fabs(obj_range[5]) > 1e12)
      {
	obj_range[5] = 999.0;
	rng_corr = 1;
      }
      if (fabs(obj_range[2]) > 1e12)
      {
	obj_range[2] = -999.0;
	rng_corr = 1;
      }

      if ( rng_corr )
      {
  	double * ptr = NULL;

	__printf ("Range %d adjusted [%d,%d] : %lg %lg %lg %lg %lg %lg", `i, surf[i].located_obj.osnum, surf[i].located_obj.objid,
		  obj_range[0], obj_range[1], obj_range[2], obj_range[3], obj_range[4], obj_range[5]`);

	ptr = (double *)surf[i].module_info.md_env.matrix;
	
	__printf ("Matrix_type = %d", `surf[i].module_info.md_env.matrix_type`);
	__printf ("              %lg, %lg, %lg, %lg",`ptr[0], ptr[1], ptr[2], ptr[3]`);
	__printf ("              %lg, %lg, %lg, %lg",`ptr[4], ptr[5], ptr[6], ptr[7]`);
	__printf ("              %lg, %lg, %lg, %lg",`ptr[8], ptr[9], ptr[10], ptr[11]`);
	__printf ("              %lg, %lg, %lg, %lg",`ptr[12], ptr[13], ptr[14], ptr[15]`);
      }
      for(k=0;k<3;k++)
      {
	if(range[k]   > obj_range[k]  )
	   range[k]   = obj_range[k];
	if(range[k+3] < obj_range[k+3])
	   range[k+3] = obj_range[k+3];
      }
    }
  } /* end for(i=0 ....) */

  __printf ("           Range : %lg %lg %lg %lg %lg %lg", `range[0], range[1], range[2], range[3], range[4], range[5]`);
 
  if (infinite[0] != 'y' && infinite[0] != 'Y') type_flag = SURF;
  else						type_flag = PLAN;

  nb_sf1 = 0;
  stat = SMelem_(type_flag, &surf[0].located_obj,
		 surf[0].module_info.md_env.matrix_type,
		 surf[0].module_info.md_env.matrix,
		 &elem_type[0],
		 &plane[0], NULL, NULL, &nb_sf1);
  if (!(stat&1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR fonction SMelem_\n");
    err_flag = TRUE;
    goto wrapup;
  }
  if(typesf != NULL) typesf[0] = elem_type[0];

  if(elem_type[0] == CURV)
  {
    if (OM_Gf_verbose_warning) printf("ERROR: support cannot be a curve\n");
    err_flag = TRUE;
    goto wrapup;
  }
  if(elem_type[0] == PLAN)
  {
    fact = 1.1 * (IGRdouble)BSdistptpt(&rc, range, &(range[3]));
    if(rc != BSSUCC)
    {
      if (OM_Gf_verbose_warning) printf("ERROR BSdistptpt,\n");
      err_flag = TRUE;
      goto wrapup;
    }
  }

  for(k=1;k<nb_surf;k++)
  {
    if (infinite[k] != 'y' && infinite[k] != 'Y')	type_flag = SURF;
    else						type_flag = PLAN;

    nb_sf1 = 0;
    stat = SMelem_(type_flag, &surf[k].located_obj,
		   surf[k].module_info.md_env.matrix_type,
		   surf[k].module_info.md_env.matrix,
		   &elem_type[1],
		   &plane[1], NULL, NULL, &nb_sf1);
    if (!(stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR fonction SMelem_\n");
      err_flag = TRUE;
      goto wrapup;
    }
    if(typesf != NULL) typesf[k] = elem_type[1];
    if(elem_type[1] == CURV)
    {
      if(tnb_inters >= tnb_alloc)
      {
	tmp = tnb_alloc + INCR_ALLOC;
	tinters = _REALLOC (tinters, tmp, struct SMsfinters);
	if(tinters == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	for(i_alloc=tnb_alloc;i_alloc<tmp;i_alloc++) tinters[i_alloc].cv_geom = NULL;
	tnb_alloc = tmp;

      }
      tinters[tnb_inters].sf1 = -1;
      tinters[tnb_inters].sf2 = k;
      tinters[tnb_inters].cvint_id =  surf[k].located_obj;
      tinters[tnb_inters].cv_geom = NULL;
      tnb_inters ++;
      continue;
    }

    n_pla = 0;

    sprintf(running,"%s%d","intersect support with surface ",k);
    UI_status(running);

    if(elem_type[0] == PLAN) n_pla = 1;
    if(elem_type[1] == PLAN) n_pla = n_pla + 2;

    if( n_pla == 3 )
    {
      /*|plan/plan intersect */

      if(tnb_inters >= tnb_alloc)
      {
	tmp = tnb_alloc + INCR_ALLOC;
	tinters = _REALLOC (tinters, tmp, struct SMsfinters);
	if(tinters == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	for(i_alloc=tnb_alloc;i_alloc<tmp;i_alloc++) tinters[i_alloc].cv_geom = NULL;
	tnb_alloc = tmp;
      }
      tinters[tnb_inters].sf1 = 0;
      tinters[tnb_inters].sf2 = k;
      tinters[tnb_inters].cvint_id.objid = NULL_OBJID;
      tinters[tnb_inters].cv_geom = NULL;
      (void)BSpl_pl(plane[0].point, plane[0].normal,
		    plane[1].point, plane[1].normal,
		    &int_flag, q, u, &rc);
      if(rc != BSSUCC )
      {
	if (OM_Gf_verbose_warning) printf(" ERROR in BSpl_pl\n");
	err_flag = TRUE;
	goto wrapup;
      }
      if (int_flag != BSCINTERSECTING) continue;

      num_pts = 2;
      (void)BSalloccv(ORDER, num_pts, 0, 0,
		      &(tinters[tnb_inters].cv_geom), &rc);
      if(rc != BSSUCC && rc!=BSNULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
	err_flag = TRUE;
	goto wrapup;
      }
      tinters[tnb_inters].cv_geom->planar = TRUE;
      tinters[tnb_inters].cv_geom->phy_closed = FALSE;
      tinters[tnb_inters].cv_geom->order     = ORDER;
      tinters[tnb_inters].cv_geom->num_poles = num_pts;
      tinters[tnb_inters].cv_geom->num_knots = num_pts + 2 * (ORDER - 1);

      /* Compute the end points of the line to do the intersection */

      (IGRboolean)BSmkvec(&rc, v1, range    , q);
      (IGRboolean)BSmkvec(&rc, v2, &range[3], q);

      if((IGRdouble)BSdotp(&rc,v1,v2) <= 0)
      {
	/*|The point of the infinit line is inside the range*/
      }
      else
      {
	/*|The point of the infinit line is not inside the range*/

	fact = fact + (IGRdouble)BSdistptpt(&rc, q, range);
      }

      for(l=0;l<3;l++)
      {
	tinters[tnb_inters].cv_geom->poles[l]   = q[l] - fact * u[l];
	tinters[tnb_inters].cv_geom->poles[l+3] = q[l] + fact * u[l];
	tinters[tnb_inters].cv_geom->knots[l+1] = (double) l/ (num_pts-1);
      }
      tinters[tnb_inters].cv_geom->knots[0]	 = 0;
      tinters[tnb_inters].cv_geom->knots[num_pts+1] = 1;
      tnb_inters ++;

      continue;
    }
    else if( n_pla == 0 )
    {
      /*===================================================*/
      /* general routine to intersect any type of element  */
      /*===================================================*/
      curve_specific.is_polydis = TRUE;
      curve_specific.is_curvedis = TRUE;
      GRint = NULL;
      tmp_cst = (*cst);
      tmp_cst.class_attr = (IGRchar *) &curve_specific;
      trim = EMSINT_TRIM_HANDLESTOP | NULL; /* trimming option */

      stat = EMintersect_two_element(		&(surf[0]),
						&(surf[k]),
						trim,
						&tmp_cst,
						&num_inter,
						&GRint,
						 msg);
      as$status(sts = stat);
      if(!(stat & (*msg) & 1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in EMintersect_two_element\n");
	err_flag = TRUE;
	goto wrapup;
      }
    }
    else if( n_pla == 1 )
    {
      /*=========================================================*/
      /*  the first parent is a plane				 */
      /*=========================================================*/
      GRint = NULL;
      tmp_cst = (*cst);
      stat = om$send( msg      = message GRvg.EMintplane(
							 &tmp_cst,
							 &plane[0],
							 &surf[k],
							 &num_inter,
							 &GRint,
							 (int *)msg ),
		      senderid = NULL_OBJID,
		      targetid = surf[k].located_obj.objid,
		      targetos = surf[k].located_obj.osnum );
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRvg.EMintplane  \n");
	err_flag = TRUE;
	goto wrapup;
      }

    }
    else if( n_pla == 2 )
    {
      /*=========================================================*/
      /*  the second parent is a plane				 */
      /*=========================================================*/

      GRint = NULL;
      tmp_cst = (*cst);
      stat = om$send( msg      = message GRvg.EMintplane(
							 &tmp_cst,
							 &plane[1],
							 &surf[0],
							 &num_inter,
							 &GRint,
							 (int *)msg ),
		      senderid = NULL_OBJID,
		      targetid = surf[0].located_obj.objid,

		      targetos = surf[0].located_obj.osnum );
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRvg.EMintplane  \n");
	err_flag = TRUE;
	goto wrapup;
      }
    }

    if(num_inter < 1) continue;

    for(l=0;l<num_inter;l++)
    {
      stat = om$get_classid(	osnum     = GRint[l].osnum,
				objid     = GRint[l].objid,
				p_classid = &obj_classid);
      if( om$is_ancestry_valid(subclassid   = obj_classid,
			       superclassid = OPP_GRgrgrp_class_id )
	  == OM_S_SUCCESS )
      {
	stat = om$send( msg = message GRowner.GRget_number_components
			(msg, &nb_obj),
			senderid = NULL_OBJID,
			targetid = GRint[l].objid,
			targetos = GRint[l].osnum );	
	as$status(sts=stat);
	if (!((*msg)&stat&1))
	{
	  if (OM_Gf_verbose_warning) printf("ERROR in GRowner.GRget_number_components\n");
	  err_flag = TRUE;
	  goto wrapup;
	}

	OBJECT = NULL;
	OBJECT =  _MALLOC(nb_obj, struct GRid);
	if(OBJECT == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}

	tmp_cst = (*cst);
	stat = om$send( msg = message GRowner.GRget_components
			(msg, tmp_cst.env_info,OBJECT, nb_obj,
			 &count,0,nb_obj),
			senderid = NULL_OBJID,
			targetid = GRint[l].objid,
			targetos = GRint[l].osnum );
	as$status(sts=stat);
	if (!((*msg)&stat&1))
	{
	  if (OM_Gf_verbose_warning) printf("ERROR in GRowner.GRget_components \n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	for(j=0;j<count;j++)
	{
	  if(tnb_inters >= tnb_alloc)
	  {
	    tmp = tnb_alloc + count * num_inter + 1;
	    tinters = _REALLOC (tinters, tmp, struct SMsfinters);
	    if(tinters == NULL)
	    {
	      if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	      err_flag = TRUE;
	      goto wrapup;
	    }
	    for(i_alloc=tnb_alloc;i_alloc<tmp;i_alloc++) tinters[i_alloc].cv_geom = NULL;
	    tnb_alloc = tmp;
	  }
	  tinters[tnb_inters].sf1 = 0;
	  tinters[tnb_inters].sf2 = k;
	  tinters[tnb_inters].cvint_id = OBJECT[j];
	  tinters[tnb_inters].cv_geom = NULL;
	  tnb_inters ++;
	}
	_FREE(OBJECT);
      }
      else
      {
	if(tnb_inters >= tnb_alloc)
	{
	  tmp = tnb_alloc + num_inter + 1;
	  tinters = _REALLOC ( tinters, tmp, struct SMsfinters);
	  if(tinters == NULL)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }
	  for(i_alloc=tnb_alloc;i_alloc<tmp;i_alloc++) tinters[i_alloc].cv_geom = NULL;
	  tnb_alloc = tmp;
	}
	tinters[tnb_inters].sf1 = 0;
	tinters[tnb_inters].sf2 = k;
	tinters[tnb_inters].cvint_id = GRint[l];
	tinters[tnb_inters].cv_geom = NULL;
	tnb_inters ++;
      }
    }
    _FREE(GRint);
  }

  for(i=0;i<tnb_inters;i++)
  {
    tinters[i].alloc_flag = TRUE;
    if(tinters[i].cv_geom == NULL)
    {
      tinters[i].alloc_flag = FALSE;

      tmp_cst = (*cst);
      stat = om$send(msg = message GRvg.GRgetsize(msg,
						  &((tmp_cst.env_info)->md_env.matrix_type),
						  (tmp_cst.env_info)->md_env.matrix,
						  &size ),
		     senderid = NULL_OBJID,
		     targetid = tinters[i].cvint_id.objid,
		     targetos = tinters[i].cvint_id.osnum );

      as$status(sts = stat);
      if(!(stat & (*msg) &1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetsize\n");
	err_flag = TRUE;
	goto wrapup;
      }

      tinters[i].cv_geom = (struct IGRbsp_curve *)_MALLOC(size, char);

      if(tinters[i].cv_geom == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR, Bad dynamic allocation \n");
	err_flag = TRUE;
	goto wrapup;
      }

      tmp_cst = (*cst);
      stat = om$send(msg = message GRvg.GRgetgeom(msg,
						  &((tmp_cst.env_info)->md_env.matrix_type),
						  (tmp_cst.env_info)->md_env.matrix,
						  (char *) tinters[i].cv_geom),
		     senderid = NULL_OBJID,
		     targetid = tinters[i].cvint_id.objid,
		     targetos = tinters[i].cvint_id.osnum );
      as$status(sts = stat);
      if(!(stat & (*msg) &1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetgeom\n");
	err_flag = TRUE;
	goto wrapup;
      }
      coef = 0;
      for(k=0;k<3;k=k+1)
      {
	coef = coef + fabs(tinters[i].cv_geom->poles[k] -
			   tinters[i].cv_geom->poles[3*(tinters[i].cv_geom->num_poles-1)+k]);
      }

      if (coef < basis_tol) tinters[i].cv_geom->phy_closed = TRUE;
      else		    tinters[i].cv_geom->phy_closed = FALSE;
    }
  }

  if(nb_inters != NULL) *nb_inters = tnb_inters;
  if(inters != NULL && tnb_inters != 0)
  {
    *inters = NULL;
    *inters = _MALLOC(tnb_inters, struct SMsfinters);
    if( (*inters) == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<tnb_inters;i++) (*inters)[i].cv_geom = NULL;
    for(i=0;i<tnb_inters;i++)
    {
      (*inters)[i].sf1		= tinters[i].sf1;
      (*inters)[i].sf2		= tinters[i].sf2;
      (*inters)[i].alloc_flag	= tinters[i].alloc_flag;
      (*inters)[i].cvint_id	= tinters[i].cvint_id;
      (*inters)[i].cv_geom	= tinters[i].cv_geom;
    }
  }
  if(SMcurve != NULL && tnb_inters != 0)
  {
    *SMcurve = NULL;
    *SMcurve = _MALLOC(tnb_inters, struct SMcurve);
    if( (*SMcurve) == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<tnb_inters;i++)
    {
      (*SMcurve)[i].nb_intpt = 0;
      (*SMcurve)[i].pt_index = NULL;
      (*SMcurve)[i].cv_geom = tinters[i].cv_geom;
    }
  }

wrapup:

  UI_status("");
  _FREE(GRint);
  _FREE(OBJECT);
  _FREE(COMP);

  if(err_flag == TRUE)
  {
    if(tinters != NULL)
    {
      for(i=0;i<tnb_inters;i++)
      {
	if(tinters[i].cv_geom != NULL)
	{
	  if(tinters[i].alloc_flag == TRUE)
	    (IGRboolean)BSfreecv(&rc, tinters[i].cv_geom);
	  else _FREE(tinters[i].cv_geom);

	  tinters[i].cv_geom = NULL;
	}
      }
      _FREE(tinters);
    }
    if(inters != NULL && (*inters) != NULL) _FREE(*inters);

    __exit_error_Function ( name = "SMint_support" );

    return(0);
  }
  _FREE(tinters);
  __exitFunction ( name = "SMint_support" );
  return(1);
}

/*4 ======================  SMIsTrack ======================

	Function for the macro SMSfBound to determine if an input element
	can be taken as a track element:

	when the surface intersections are computed, if an element doesn't
	intersect any one of the others, we consider it as a tract
	element.

	Curve elements are not taken as track element.

	return(1) if ok.
	else return(0).
*/

int	SMIsTrack(msg, nb_surf, surf, nb_cv, cv_int, nb_track, index)
long			*msg;		/* (O) completion code */
int			nb_surf;	/* (I) nb surf  */
struct GRlc_info	*surf;		/* (I) surfaces intersected*/
int			nb_cv;		/* (I) nb intersections curves */
struct SMsfinters	*cv_int;	/* (I) intersections curves */
int			*nb_track;	/* (O) nb_track elt */
int			**index;	/* (O) track elt index in surf array*/
/*.SMIsTrack*/
{
  int		i,k;
  int		nb_tmp, *ind_tmp;
  struct GRid	*tmp;
  IGRboolean	err_flag, found;

  tmp = NULL;
  ind_tmp = NULL;
  nb_tmp = 0;
  err_flag = FALSE;

  if(index != NULL) *index = NULL;

  if(msg != NULL) *msg = MSSUCC;

  tmp = _MALLOC(nb_surf, struct GRid );
  if(tmp == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  ind_tmp = _MALLOC(nb_surf, int );
  if(ind_tmp == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }

  for(i=0;i<nb_surf;i++)
  {
    found = FALSE;

    /* search surface element in curves intersection */

    for(k=0;k<nb_cv;k++)
    {
      if(i == cv_int[k].sf1 || i== cv_int[k].sf2 ||
	 cv_int[k].sf1 == -1 || cv_int[k].sf2 == -1) {found =TRUE;break;}
    }

    if(found == FALSE)
    {
      ind_tmp[nb_tmp] = i;
      tmp[nb_tmp] = surf[i].located_obj;
      nb_tmp ++;
    }
  }

  if(nb_track != NULL) *nb_track = nb_tmp;

  if(index != NULL && nb_tmp != 0)
  {
    *index = _MALLOC(nb_tmp, int);
    if(*index == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<nb_tmp;i++) (*index)[i] = ind_tmp[i];
  }

wrapup:

  _FREE(tmp);
  _FREE(ind_tmp);
  if(err_flag == TRUE)
  {
    if(index != NULL && (*index) != NULL)_FREE(*index);
    return(0);
  }
  else return(1);
}

/*5 ======================  SMget_sl_arc ==========================

	Function for SMSfBound, to write loop index in struct sl_arc:
	sl_arc must be allocated by the user of loop.nb_edge.

	return(1) if ok.
	else return(0).
*/

int	SMget_sl_arc(msg, loop, graph, sl_arc)
long			*msg;		/* (O) completion code */
struct one_loop		loop;		/* (I) input loop   */
struct gr_arc		*graph;		/* (I) input graph */
struct sl_arc		*sl_arc;	/* (O) returned sl_arc structures*/

/*.SMget_sl_arc*/
{
  int		i;
  int		index_pt1, index_pt2, index_arc, index_cv, part_nb;
  IGRboolean	err_flag;

  if(graph == NULL || sl_arc == NULL )
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }

  if(msg != NULL) *msg = MSSUCC;
  err_flag = FALSE;

  index_arc = 0;
  for(i=0;i<loop.nb_edge -1;i++)
  {
    index_pt1 = graph[loop.edge[i]].pt;
    if(i == loop.nb_edge - 1)
    {
      index_pt2 = graph[loop.edge[0]].pt;
      index_cv  = graph[loop.edge[0]].cv;
      part_nb   = graph[loop.edge[0]].part_nb;
    }
    else
    {
      index_pt2 = graph[loop.edge[i+1]].pt;
      index_cv  = graph[loop.edge[i+1]].cv;
      part_nb   = graph[loop.edge[i+1]].part_nb;
    }

    sl_arc[index_arc].index_cv  = index_cv;
    sl_arc[index_arc].index_pt1 = index_pt1;
    sl_arc[index_arc].index_pt2 = index_pt2;
    sl_arc[index_arc].part_nb   = part_nb;
    index_arc ++;

  }

  if(err_flag == TRUE) return(0);
  else return(1);

}

/*6 ======================  SMIsEltInSlArc ==========================

	Function that return(1) if elt is in the array of sl_arc.
	else return(0).
*/

int	SMIsEltInSlArc(arc, nb_array, array, SMinters, index)
struct sl_arc		*arc;	  /* (I) sl_arc to search in array*/
int			nb_array; /* (I) nb elt in array */
struct sl_arc		*array;	  /* (I) array of sl_arc */
struct SMinters		*SMinters;/* (I) pts definition */
int			*index;    /* (O) index of arc in array if found */

/*.SMIsEltInSlArc*/
{
  int		i;

  for(i=0;i<nb_array;i++)
  {
    if(SMIsEqualArc(arc, &array[i], SMinters))
    {
      if(index != NULL) *index = i;
      return (1);
    }
  }
  return(0);
}

/*7 ======================  SMIsEqualPt ==========================

	Function that return(1) if pt1 is equal to pt2. (basis_tol)
	else return(0).
*/

int	SMIsEqualPt(pt1, pt2, SMinters)
int		pt1;	  /* (I) index pt1 in SMinters */
int		pt2;	  /* (I) index pt2 in SMinters */
struct SMinters	*SMinters;/* (I) pts definition */
/*.SMIsEqualPt*/
{
  long		msg, nput, nret;
  IGRdouble	dist, basis_tol;
  BSrc		rc;

  nput = sizeof(basis_tol);

  gr$get_basis_tolerance(		msg    = &msg,
					sizbuf = &nput,
					buffer = &basis_tol,
					nret   = &nret);
  if(!(msg&1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR gr$get_chord_height_tolerance\n");
    return(0);
  }

  dist = (IGRdouble)BSdistptpt(&rc, SMinters[pt1].pt, SMinters[pt2].pt);

  if(dist <= basis_tol) return(1);

  return(0);
}

/*8 ======================  SMIsEqualArc ==========================

	Function that return(1) if slarc1 is equal to slarc2.
	else return(0).
*/

int	SMIsEqualArc(sl_arc1, sl_arc2, SMinters)
struct sl_arc	*sl_arc1;  /* (I) arc1 definition */
struct sl_arc	*sl_arc2;  /* (I) arc2 definition */
struct SMinters	*SMinters; /* (I) pts definition */
/*.SMIsEqualArc*/
{
  int		eq1, eq2, eq3;

  eq1 = eq2 = eq3 = 0;

  if(sl_arc1->index_cv == sl_arc2->index_cv &&
     sl_arc1->part_nb  == sl_arc2->part_nb) eq1 = 1;
  if( SMIsEqualPt(sl_arc1->index_pt1, sl_arc2->index_pt1, SMinters) &&
      SMIsEqualPt(sl_arc1->index_pt2, sl_arc2->index_pt2, SMinters) )
    eq2 = 1;

  if( SMIsEqualPt(sl_arc1->index_pt1, sl_arc2->index_pt2, SMinters) &&
      SMIsEqualPt(sl_arc1->index_pt2, sl_arc2->index_pt1, SMinters) )
    eq3 = 1;

  if( (eq1  && eq2) || (eq1 && eq3) ) return (1);
  return (0);
}

/*9 ======================  SMint_ordercurves ======================

	Given an array of curves, the function computes all the
	consecutive intersections between them and sorts the intersection pts
	in an array of struct SMinters (cf SMgraph.h).
	SMinters is allocated in the function and must be deallocated
	by the user.

	return(1) if ok.
	else return(0).
*/

int	SMint_ordercurves(nb_curves, curves, nb_inters, inters)
int			nb_curves;	/* (I) nb curves to intersect */
struct IGRbsp_curve	**curves;	/* (I) input curves */
int			*nb_inters;	/* (O) nb intersections returned */
struct SMinters		**inters;	/* (O) intersections returned */

/*.SMint_ordercurves*/
{
  int			i,l, next, n_int,tnb_inters, tnb_alloc;
  IGRboolean		oncurve, err_flag;
  BSrc			rc;
  IGRdouble		*pt1, *pt2,*par1, *par2, eps, dist0, dist, cht_tol;
  IGRlong		msg, nput, nret;
  struct SMinters	*tinters;

  if(nb_curves < 2 || curves == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  __enterFunction ( name = "SMint_ordercurves" );

  if(inters != NULL) *inters = NULL;

  tinters = NULL;
  par1 = NULL;
  par2 = NULL;
  pt1 = NULL;
  pt2 = NULL;

  err_flag = FALSE;

  nput = sizeof(cht_tol);

  gr$get_chord_height_tolerance(msg    = &msg,
				sizbuf = &nput,
				buffer = &cht_tol,
				nret   = &nret);
  if(!(msg&1))
  {
    if (OM_Gf_verbose_warning) printf("error gr$get_chord_height_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }

  eps = 2*cht_tol;

  tnb_inters = 0;

  tnb_alloc = 2*nb_curves;
  tinters = _MALLOC (tnb_alloc, struct SMinters);
  if(tinters == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }

  for(i=0;i<nb_curves;i++)
  {
    if(i == nb_curves - 1) next = 0;
    else next = i+1;

    dist0 = eps;
    (void)VDmdistcvcv(curves[i], curves[next], &n_int, &pt1, &pt2,
		      dist0, &dist, eps, &msg);
    if(dist > eps) n_int = 0;
    if(n_int)
    {
      n_int = 1; /* take only the first one */
      par1 = _MALLOC(n_int, IGRdouble);
      if(par1 == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
	err_flag = TRUE;
	goto wrapup;
      }
      par2 = _MALLOC(n_int, IGRdouble);
      if(par2 == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
	err_flag = TRUE;
	goto wrapup;
      }
    }
    for(l=0;l<n_int;l++)
    {
      (IGRboolean)BSprptoncv(&rc, curves[i], &pt1[3*l],
			     &par1[l], &oncurve);
      if(rc != BSSUCC || oncurve == FALSE)
      {
	if (OM_Gf_verbose_warning) printf("ERROR )BSprptoncv\n");
	err_flag = TRUE;
	goto wrapup;
      }

      (IGRboolean)BSprptoncv(&rc, curves[next], &pt2[3*l],
			     &par2[l], &oncurve);

      if(rc != BSSUCC || oncurve == FALSE)
      {
	if (OM_Gf_verbose_warning) printf("ERROR )BSprptoncv\n");
	err_flag = TRUE;
	goto wrapup;
      }
    }

    for(l=0;l<n_int;l++)
    {
      if(tnb_inters >= tnb_alloc)
      {
	tnb_alloc = tnb_alloc + INCR_ALLOC;
	tinters = _REALLOC ( tinters, tnb_alloc, struct SMinters);
	if(tinters == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
      }
      tinters[tnb_inters].cv1 = i;
      tinters[tnb_inters].cv2 = next;
      tinters[tnb_inters].par1 = par1[l];
      tinters[tnb_inters].par2 = par2[l];
      tinters[tnb_inters].pt[0] = (pt1[3*l]+ pt2[3*l])/2;
      tinters[tnb_inters].pt[1] = (pt1[3*l+1]+ pt2[3*l+1])/2;
      tinters[tnb_inters].pt[2] = (pt1[3*l+2]+ pt2[3*l+2])/2;
      tnb_inters ++;

    }
    _FREE(par1);
    _FREE(par2);
    _FREE(pt1);
    _FREE(pt2);
  }

  if(nb_inters != NULL) *nb_inters = tnb_inters;
  if(inters != NULL && tnb_inters > 0)
  {
    (*inters) = NULL;
    (*inters) = _MALLOC(tnb_inters, struct SMinters);
    if((*inters) == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<tnb_inters;i++) (*inters)[i] = tinters[i];
  }

wrapup:

  _FREE(par1) ;
  _FREE(par2) ;
  _FREE(pt1) ;
  _FREE(pt2) ;
  _FREE(tinters)   ;

  if(err_flag == TRUE)
  {
    if(inters != NULL && (*inters) != NULL)   _FREE(*inters);

    __exit_error_Function ( name = "SMint_ordercurves" );
    return(0);
  }
  else
  {
    __exitFunction ( name = "SMint_ordercurves" );
    return(1);
  }
}

/*10 ====================== SMCreatBndSurf ==========================

	Function that creates a bounded surface based on a support
	surface, if given a composite curve on it and the curves
	that compose this composite.

	If support is a plane an EMplane_of_curve is performed.

	For single surface support an impose boundary is performed.

	For composite surface support a boolean diff is performed between
	the support and the surface of projection based on the closed
	planar curve (the curve must have been projected on the plane_cv).

	The bounded surface returned has the same orientation
	than the support.

	return(1) if ok.
	else return(0).

*/

int	SMCreatBndSurf(msg, closed_cv, cvgeom, nb_curves, curves,
			act_env, cst, elem_type, support_id, plane_cv,bndsurf)
long			*msg;	     /* (O) completion code */
struct GRlc_info	*closed_cv;  /* (I) input closed curve */
struct IGRbsp_curve	*cvgeom;     /* (I) geom of the curve if known */
int			nb_curves;   /* (I) nb input curves */
struct GRlc_info	*curves;     /* (I) input curves */
struct GRmd_env		*act_env;    /* (I) act mod env */
struct GRvg_construct   *cst;	     /* (I) construction list */
int			elem_type;   /* (I) type of the surface */
struct GRlc_info	*support_id; /* (I) support_id */
struct IGRplane		*plane_cv;   /* (I) plane def of curve (can be NULL
						for plane) */
struct	GRid		*bndsurf;     /* (O) constructed bounded surface */

/*.SMCreatBndSurf*/
{
int			i,k,n_int, stat, nb_time, type, num_deriv,
			nb_del,ssize,nb_cmp, found;
OMuint			count;
IGRboolean		pos_orient_flag, inside, err_flag, world, eval_bound,
			bound;
IGRdouble		obj_range[6],baryctr[3], fact, coef, param,base[3],
			dist1,dist2,dir_point[3],proj_vect[3], vect[3],
			dirvect[3],out_vect[3], pt1[3],pt2[3], *p_par1,*p_par2,
			*int_pts, *over0, *over1, *end_pts,
			point1[3],point2[3], dis_fact,tgvect[3],
			water_mark, dotp, bnd[6], planpt[6];
IGRpoint		tangent[1][2],left[2], right[2];
long			n_over, size;
struct GRvg_construct   tmp_cst;
struct IGRbsp_curve	*line,  *comp_cv, *geom;
BSrc			rc;
struct GRid		PROJCV, GRid_list, *TODEL, TMP, TMP1, *list;
GRobjid			*return_id, new_objid;
IGRushort		option=0,makecs_opt;
GRclassid		sfid_class;
OM_S_CHANSELECT		to_comps;
IGRuchar		props, c_props;
struct GRlc_info	bound_id;
struct IGRplane		plane, bndpl;
struct GRid	     active_id, top_lm_id;

  short sav_pathway_trim = _pathway_trim, sav_pathway_orient = _pathway_orient;

  if(msg != NULL) *msg = MSSUCC;

  err_flag = FALSE;

  list		= NULL;
  return_id	= NULL;
  TODEL		= NULL;
  geom		= NULL;
  line		= NULL;
  comp_cv	= NULL;
  p_par1	= NULL;
  p_par2	= NULL;
  int_pts	= NULL;
  over0		= NULL;
  over1		= NULL;
  end_pts	= NULL;
  water_mark	= 0;

  PROJCV.objid	= NULL_OBJID;
  GRid_list.objid	= NULL_OBJID;
  TMP.objid	= NULL_OBJID;
  TMP1.objid	= NULL_OBJID;
  new_objid	= NULL_OBJID;

  if(closed_cv == NULL || cst == NULL || support_id == NULL || bndsurf == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  __enterFunction ( name = "SMCreatBndSurf", argfmt = "nb_curves = %d, elem_type =%d, _pathway_trim =%d, _pathway_orient =%d",
		    args = `nb_curves, elem_type, _pathway_trim, _pathway_orient` );

  _pathway_trim   = 1;
  _pathway_orient = 1;

  tmp_cst = (*cst);

  bndsurf->objid = NULL_OBJID;
  bndsurf->osnum = act_env->md_id.osnum;

  stat = om$send( msg = message EMSsubbs.EMget_props(msg, &props),
		  senderid = NULL_OBJID,
		  targetid = support_id->located_obj.objid,
		  targetos = support_id->located_obj.osnum );

  if (!(stat&1)){ props = 0x00; }

  if(elem_type == PLAN)
  {
    tmp_cst = (*cst);
    tmp_cst.env_info = act_env; /* in RTREE */

    plane.point = &planpt[0];
    plane.normal= &planpt[3];
    stat = om$send (msg = message GRvg.GRdetplane(msg,
						  &support_id->module_info.md_env.matrix_type,
						  support_id->module_info.md_env.matrix,
						  &plane),
		    senderid = NULL_OBJID,
		    targetid = support_id->located_obj.objid,
		    targetos = support_id->located_obj.osnum );
    as$status(sts = stat);
    if(!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR in GRvg.GRdetplane\n" );
      err_flag = TRUE;
      goto wrapup;
    }
    /* don't pass geom otherwise, bad edges */

    stat = SMCreatBndPl(msg, closed_cv, NULL, &tmp_cst, bndsurf);
    if(!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMCreatBndPl\n");
      err_flag = TRUE;
      goto wrapup;
    }

    /* verify the orientation of the bounded plane */

    bndpl.point = &bnd[0];
    bndpl.normal= &bnd[3];
    stat = om$send (msg = message GRvg.GRdetplane(msg,
						  &cst->env_info->md_env.matrix_type,
						  cst->env_info->md_env.matrix,
						  &bndpl),
		    senderid = NULL_OBJID,
		    targetid = bndsurf->objid,
		    targetos = bndsurf->osnum );
    as$status(sts = stat);
    if(!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR in GRvg.GRdetplane\n" );
      err_flag = TRUE;
      goto wrapup;
    }

    dotp =    (IGRdouble)BSdotp(&rc,bndpl.normal,plane.normal);

    if( dotp < 0  )
    {
      stat = om$send(msg = message EMSsubbs.EMset_props(msg,
							EMSIS_NRML_REVERSED, EMS_O_TOGGLE),
		     senderid = NULL_OBJID,
		     targetid = bndsurf->objid,
		     targetos = bndsurf->osnum);
      as$status(sts = stat);
      if(!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in EMSsubbs.EMset_props\n" );
	err_flag = TRUE;
	goto wrapup;
      }
    }
    goto wrapup;
  }
  else if (elem_type == SURF)
  {
    tmp_cst = (*cst);
    tmp_cst.env_info = act_env;

    bound_id = (*support_id);

    stat = SMImpBndSf(msg, closed_cv, NULL, nb_curves,
		      curves, &bound_id, NULL, cst);
    if(!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMImpBndSf\n");
      bndsurf->objid = NULL_OBJID;
      err_flag = TRUE;
      goto wrapup;
    }

    bndsurf->objid = bound_id.located_obj.objid;
    bndsurf->osnum = bound_id.located_obj.osnum;
  }
  else
  {
    if(plane_cv == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
      err_flag = TRUE;
      goto wrapup;
    }
    stat = om$send(msg = message GRgraphics.GRcopy(msg,
						   &support_id->module_info, act_env,
						   &(bndsurf->objid)),
		   senderid = NULL_OBJID,
		   targetid = support_id->located_obj.objid,
		   targetos = support_id->located_obj.osnum);
    as$status(sts=stat);
    if (!((*msg)&stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRcopy \n");
      err_flag = TRUE;
      goto wrapup;
    }
    stat = om$send( msg = message GRvg.GRcenter(
						msg,
						&closed_cv->module_info.md_env.matrix_type,
						closed_cv->module_info.md_env.matrix,
						baryctr),
		    senderid = NULL_OBJID,
		    targetid = closed_cv->located_obj.objid,
		    targetos = closed_cv->located_obj.osnum  );

    as$status(sts=stat);
    if(!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRcenter\n");
      err_flag = TRUE;
      goto wrapup;
    }

    if(cvgeom == NULL)
    {
      stat = om$send(msg = message GRvg.GRgetsize(msg,
						  &closed_cv->module_info.md_env.matrix_type,
						  closed_cv->module_info.md_env.matrix,
						  &size ),
		     senderid = NULL_OBJID,
		     targetid = closed_cv->located_obj.objid,
		     targetos = closed_cv->located_obj.osnum );
      as$status(sts=stat);
      if(!(stat & (*msg) & 1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetsize\n");
	err_flag = TRUE;
	goto wrapup;
      }
      geom = NULL;
      geom = (struct IGRbsp_curve *)_MALLOC(size, char);
      if(geom == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation ");
	err_flag = TRUE;
	goto wrapup;
      }
      stat = om$send(msg = message GRvg.GRgetgeom(msg,
						  &closed_cv->module_info.md_env.matrix_type,
						  closed_cv->module_info.md_env.matrix,
						  (char *) geom),
		     senderid = NULL_OBJID,
		     targetid = closed_cv->located_obj.objid,
		     targetos = closed_cv->located_obj.osnum );
      as$status(sts=stat);
      if(!(stat & (*msg) & 1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetgeom\n");
	err_flag = TRUE;
	goto wrapup;
      }

      comp_cv = geom;
    }
    else comp_cv = cvgeom;

    world = TRUE;
    stat = om$send( msg = message GRgraphics.GRgetrang(msg,
						       &closed_cv->module_info.md_env.matrix_type,
						       closed_cv->module_info.md_env.matrix,
						       &world, obj_range),
		    senderid = NULL_OBJID,
		    targetid = closed_cv->located_obj.objid,
		    targetos = closed_cv->located_obj.osnum );

    as$status(sts=stat);
    if(!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetrang\n");
      err_flag = TRUE;
      goto wrapup;
    }

    fact = (IGRdouble)BSdistptpt(&rc, obj_range, &(obj_range[3]));
    if(rc != BSSUCC)
    {
      if (OM_Gf_verbose_warning) printf("ERROR BSdistptpt,\n");
      err_flag = TRUE;
      goto wrapup;
    }

    coef = fact / 100;

    inside = FALSE;
    n_int = 1;
    nb_time = 0;

    while(inside == FALSE && n_int != 0 && nb_time < 50)
    {
      (void)BSmdstptcv(comp_cv,baryctr, &param, base, &dist2, &rc);
      if(rc != BSSUCC )
      {
	if (OM_Gf_verbose_warning) printf(" ERROR in  BSmdstptcv\n");
	err_flag = TRUE;
	goto wrapup;
      }

      /* vect is the vector (baryctr, comp_cv) */

      (IGRboolean)BSmkvec(&rc,vect,baryctr,base);
      if(rc != BSSUCC )
      {
	if (OM_Gf_verbose_warning) printf(" ERROR in BSmkvec\n");
	err_flag = TRUE;
	goto wrapup;
      }
      (IGRboolean)BSnorvec(&rc,vect);
      if(rc != BSSUCC )
      {
	if (OM_Gf_verbose_warning) printf(" ERROR in BSnorvec\n");
	err_flag = TRUE;
	goto wrapup;
      }

      for(i=0;i<3;i=i+1)
	dir_point[i] = baryctr[i] + 1.5*(fact+dist2)*vect[i];

	  /* find vector ortho to vect */

      (IGRboolean)BScrossp(&rc, vect, plane_cv->normal,dirvect);
      if(rc != BSSUCC )
      {
	if (OM_Gf_verbose_warning) printf(" ERROR in BScrossp\n");
	err_flag = TRUE;
	goto wrapup;
      }

      for(i=0;i<3;i=i+1) baryctr[i] = baryctr[i] + coef * dirvect[i];

      /* -------------------------------------------------------

	 Take dir_point out of range of comp_cv (on plane) and create
	 an infinite segment from dir_point to the curve (min dist to
	 not have tangency) and intersect it with comp_cv;
	 if nb_int > 2 the middle point between intpt1 and intpt2 is
	 inside comp_cv.
	 if nb_int < 2 chg dir_point to have more than 1 intersection.

	 --------------------------------------------------------- */

      (void)BSmdstptcv(comp_cv,dir_point, &param, base, &dist1, &rc);
      if(rc != BSSUCC )
      {
	if (OM_Gf_verbose_warning) printf(" ERROR in  BSmdstptcv\n");
	err_flag = TRUE;
	goto wrapup;
      }

      /* out_vect is the vector (dir_point,base)*/

      (IGRboolean)BSmkvec(&rc,out_vect,dir_point,base);
      if(rc != BSSUCC )
      {
	if (OM_Gf_verbose_warning) printf(" ERROR in BSmkvec\n");
	err_flag = TRUE;
	goto wrapup;
      }
      (IGRboolean)BSnorvec(&rc,out_vect);
      if(rc != BSSUCC )
      {
	if (OM_Gf_verbose_warning) printf(" ERROR in BSnorvec\n");
	err_flag = TRUE;
	goto wrapup;
      }

      for(i=0;i<3;i=i+1)
	pt1[i] = dir_point[i] + 2*(fact+dist1)*out_vect[i];

      line = NULL;
      (void)BSalloccv(	2,
			2,
			0,
			0,
			&line,
			&rc);
      if(rc != BSSUCC && rc!=BSNULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation\n ");
	err_flag = TRUE;
	goto wrapup;
      }
      (IGRboolean)BSptlngen(&rc, dir_point, pt1,line, &type);
      if(rc != BSSUCC )
      {
	if (OM_Gf_verbose_warning) printf("ERROR surf_int,  BSptlngen\n");
	err_flag = TRUE;
	goto wrapup;
      }
      p_par1  = NULL;
      p_par2  = NULL;
      int_pts = NULL;
      over0   = NULL;
      over1   = NULL;
      end_pts = NULL;
      n_int   = 0;

      (IGRboolean)BScvcv_int(&rc, line, comp_cv, &n_int, &int_pts, &p_par1,
		 &p_par2, &n_over, &end_pts,  &over0, &over1);

      if(rc != BSSUCC )
      {
	if (OM_Gf_verbose_warning) printf("ERROR surf_int, BScvcv_int\n");
	err_flag = TRUE;
	goto wrapup;
      }

      /* look if the first intersection point has the same right
		     and left derivative */

      num_deriv = 1;
      eval_bound = TRUE;

      (IGRboolean)BScveval_b(&rc, comp_cv,&p_par2[0],&num_deriv,&eval_bound,
		 &bound, left,right);
      if(rc != BSSUCC)
      {
	if (OM_Gf_verbose_warning) printf("ERROR BScveval_b rc : %d\n",rc);
	err_flag = TRUE;
	goto wrapup;
      }

      if(n_int > 1 && bound == FALSE)
      {
	for(i=0;i<3;i=i+1)
	  dir_point[i] = (int_pts[i] + int_pts[i+3])/2;
	inside = TRUE;
      }
      if(line      != NULL) {(IGRboolean)BSfreecv(&rc, line) ;line       = NULL;}
      _FREE(p_par1);
      _FREE(p_par2);
      _FREE(int_pts);
      _FREE(over0);
      _FREE(over1);
      _FREE(end_pts);
      nb_time = nb_time +1;
    } /* end while */

    __printf ( "inside = %d, nb_time = %d, fact = %lg", `inside, nb_time, fact` );

    if(inside == FALSE)
    {
      if (OM_Gf_verbose_warning) printf("ERROR, Fail to find a point inside comp_cv\n");
      err_flag = TRUE;
      goto wrapup;
    }

    /* create surface of projection */

    PROJCV.objid	= NULL_OBJID;
    PROJCV.osnum	= cst->env_info->md_id.osnum;

    point1[0] = plane_cv->point[0] ;
    point1[1] = plane_cv->point[1] ;
    point1[2] = plane_cv->point[2] ;

    point2[0] = plane_cv->point[0] + 10*fact *plane_cv->normal[0];
    point2[1] = plane_cv->point[1] + 10*fact *plane_cv->normal[1];
    point2[2] = plane_cv->point[2] + 10*fact *plane_cv->normal[2];

    /* -----------------------------------------------------------------

       the surface of projection must be constructed in the direction and
       sense of the normal of the support to have consistent boolean
       difference. If we want to construct the bounded surface, the normal
       of the surface of projection must be oriented to ouside
       (inside for hole).
       The problem is that the pos_orient_flag in the
       EMplace_surface_of_projection is only used if curve is not composite
       (The normal of the surface_of_projection is to outside if pos = TRUE).

       ------------------------------------------------------------------ */

    /* find the orientation of the surface of projection */

    (IGRboolean)BSmkvec(&rc,proj_vect,point1,point2);
    if(rc != BSSUCC )
    {
      if (OM_Gf_verbose_warning) printf(" ERROR in BSmkvec\n");
      err_flag = TRUE;
      goto wrapup;
    }

    /* take point to the min dist of dir_point on comp_cv */

    (void)BSmdstptcv(comp_cv,dir_point, &param, base, &dist1, &rc);
    if(rc != BSSUCC )
    {
      if (OM_Gf_verbose_warning) printf(" ERROR in  BSmdstptcv\n");
      err_flag = TRUE;
      goto wrapup;
    }

    (IGRboolean)BSmkvec(&rc,vect,base, dir_point);
    if(rc != BSSUCC )
    {
      if (OM_Gf_verbose_warning) printf(" ERROR in BSmkvec\n");
      err_flag = TRUE;
      goto wrapup;
    }

    /* find the tangent to base point */

    dis_fact = 1.; /* scale factor for tangent */
    (void)BScvarrevt(comp_cv, &param, 1, dis_fact, tangent, &rc);
    if(rc != BSSUCC )
    {
      if (OM_Gf_verbose_warning) printf(" ERROR in  BScvarrevt\n");
      err_flag = TRUE;
      goto wrapup;
    }

    for(i=0;i<3;i=i+1)
    {
      pt1[i] = tangent[0][1][i];
      pt2[i] = tangent[0][2][i];
    }

    (IGRboolean)BSmkvec(&rc,tgvect,pt1, pt2);
    if(rc != BSSUCC )
    {
      if (OM_Gf_verbose_warning) printf(" ERROR in BSmkvec\n");
      err_flag = TRUE;
      goto wrapup;
    }

    /* find the cross product of vect and the tg to cv at base */

    (IGRboolean)BScrossp(&rc, vect, tgvect, out_vect);
    if(rc != BSSUCC )
    {
      if (OM_Gf_verbose_warning) printf(" ERROR in BScrossp\n");
      err_flag = TRUE;
      goto wrapup;
    }

    /* find the dot product of out_vect and proj_vect */

    dotp = (IGRdouble)BSdotp(&rc, out_vect, proj_vect);
    if(rc != BSSUCC )
    {
      if (OM_Gf_verbose_warning) printf(" ERROR in  BSdotp\n");
      err_flag = TRUE;
      goto wrapup;
    }

    if(dotp > 0.)
    {

      stat = om$send(	msg = message GRcurve.GRrevparm(msg,
							&closed_cv->module_info),
			senderid = NULL_OBJID,
			targetid = closed_cv->located_obj.objid ,
			targetos = closed_cv->located_obj.osnum);
      as$status(sts=stat);
      if(!(stat & (*msg) & 1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR GRcurve.GRrevparm\n");
	err_flag = TRUE;
	goto wrapup;
      }
    }

    tmp_cst = (*cst);
    pos_orient_flag = FALSE;	//TRUE;

    ex$message(msgnumb = SM_S_CstPrjSf);

    stat = om$construct( msg = message EMSproject.EMplace_surface_of_projection(
										&tmp_cst,
										&closed_cv->located_obj,
										cst->env_info,
										NULL,
										NULL,
										point1,
										point2,
										pos_orient_flag,
										&new_objid ),
			 classid = OPP_EMSproject_class_id,
			 p_objid = &PROJCV.objid,
			 osnum = PROJCV.osnum  );

    __printf( "surface of proj PROJCV.objid: %d, new_objid: %d", `PROJCV.objid, new_objid` );

    as$status(sts=stat);
    if(!(stat & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR EMSproject.EMplace_surface_of_projection\n");
      err_flag = TRUE;
      goto wrapup;
    }
    PROJCV.objid = new_objid;
    /* create natural boundary if no loopset exist on surface */

    stat = om$send (msg = message EMSsurface.EMputLsIfNotThere
		    (	msg,
			&cst->env_info->md_env,
			NULL,
			NULL,
			0,
			NULL),
		    senderid = NULL_OBJID,
		    targetid = PROJCV.objid,
		    targetos = PROJCV.osnum);
    as$status(sts=stat);
    if(!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR EMSsurface.EMputLsIfNotThere\n");
      err_flag = TRUE;
      goto wrapup;
    }

    nb_del = 0;
    stat = om$get_classid (	objid = PROJCV.objid,
				osnum = PROJCV.osnum,
				p_classid = &sfid_class);
    as$status(sts=stat);
    if(!(stat & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR om$get_classid\n");
      err_flag = TRUE;
      goto wrapup;
    }

    stat = om$is_ancestry_valid (	subclassid = sfid_class,
					superclassid = OPP_EMSsubbs_class_id);
    if (stat == OM_S_SUCCESS)
    {
      TODEL = NULL;
      TODEL = _MALLOC(1, struct GRid);
      if(TODEL == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
	err_flag = TRUE;
	goto wrapup;
      }

      TODEL[nb_del].objid = PROJCV.objid;
      TODEL[nb_del].osnum = PROJCV.osnum;
      nb_del = nb_del+1;

    }/* end OPP_EMSsubbs_class_id */
    else
    {
      stat = om$send(msg = message GRowner.GRget_number_components(
								   msg,
								   &nb_del),
		     senderid = NULL_OBJID,
		     targetid = PROJCV.objid,
		     targetos = PROJCV.osnum);
      as$status(sts=stat);
      if(!(stat & (*msg) & 1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR GRowner.GRget_number_components\n");
	err_flag = TRUE;
	goto wrapup;
      }

      if(nb_del == 0 )
      {
	if (OM_Gf_verbose_warning) printf("ERROR, owner has no component\n");
	err_flag = TRUE;
	goto wrapup;
      }

      TODEL = NULL;
      TODEL = _MALLOC(nb_del, struct GRid);
      if(TODEL == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
	err_flag = TRUE;
	goto wrapup;
      }
      count = 0;
      stat = om$send(msg = message GRowner.GRget_components(
							    msg,
							    cst->env_info,
							    TODEL,
							    nb_del,
							    (int *)&count,
							    0,
							    OM_K_MAXINT),
		     senderid = NULL_OBJID,
		     targetid = PROJCV.objid,
		     targetos = PROJCV.osnum);
      as$status(sts=stat);
      if(!(stat & (*msg) & 1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR GRowner.GRget_components\n");
	err_flag = TRUE;
	goto wrapup;
      }
    }

    ex$message(msgnumb = SM_S_BoolDif);

    TMP.objid = NULL_OBJID;
    TMP.osnum = cst->env_info->md_id.osnum;

    option = option
      		| EMSsfbool_opt_OpenIntPossible
		| EMSsfbool_opt_SingleTopology		// HF: 02/27/98 Added to improve behaviour of Bounded Surface
		| EMSsfbool_opt_retryDisjoint
		| EMSsfbool_opt_HandleStop ;

    stat = om$construct( msg = message EMSsfboolean.EMboolean(
							      msg,
							      &cst->env_info->md_env.matrix_type,
							       cst->env_info->md_env.matrix,
							      bndsurf->objid,
							      1,
							      &PROJCV.objid,
							      &tmp_cst,
							      EMSbool_difference,
							      option,
							      NULL,
							      NULL,
							      NULL,
							      NULL,
							      NULL ),
			 classid = OPP_EMSsfboolean_class_id,
			 p_objid = &TMP.objid,
			 osnum   =  TMP.osnum  );

    __printf("After EMSsfboolean.EMboolean() : TMP.objid = [%d,%d]", `TMP.osnum, TMP.objid`);

    as$status(sts=stat);
    if(!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR EMSsfboolean.EMboolean\n");
      err_flag = TRUE;
      goto wrapup;
    }

    stat = om$send(msg = message EMSsurface.EMgetactiveid(
							  msg,
							  &active_id,
							  &top_lm_id ),
		   senderid = NULL_OBJID,
		   targetid = TMP.objid,
		   targetos = TMP.osnum);
    if(!(stat & *msg & 1))
    {
      if (OM_Gf_verbose_warning) printf("Warning getting the top dpr\n");
      active_id = TMP;
    }

    stat = om$send(msg = message EMSdpr.EMmake_primitive1(
							  msg,
							  cst->env_info,
							  &TMP1 ),
		   senderid = NULL_OBJID,
		   targetid = active_id.objid,
		   targetos = active_id.osnum);

    as$status(sts=stat);
    if(  !(stat&(*msg)&1) )
    {
      stat = om$send( msg = message Root.delete(0),
		      senderid = NULL_OBJID,
		      targetid = active_id.objid,
		      targetos = active_id.osnum);
      as$status( sts = stat );
      active_id.objid = NULL_OBJID;
      err_flag = TRUE;
      goto wrapup;
    }

    stat = om$get_classid (	objid = TMP1.objid,
				osnum = TMP1.osnum,
				p_classid = &sfid_class);
    as$status(sts=stat);
    if (!(stat&1))
    {
      err_flag = TRUE;
      goto wrapup;
    }

#ifdef	DEBUG
    printf("after make_primitive TMP1.objid: %d\n", TMP1.objid);
#endif

    stat = om$is_ancestry_valid (subclassid = sfid_class,
				 superclassid = OPP_EMSsubbs_class_id);

    if (stat == OM_S_SUCCESS)
    {
      /*The remains of compressed tree is a single surface.*/

      water_mark	= 0;

      stat = om$send(msg = message EMSsubbs.EMreduce_range(msg,
							   cst->env_info,
							   &TMP1.objid,
							   water_mark),
		     senderid = NULL_OBJID,
		     targetid = TMP1.objid,
		     targetos = TMP1.osnum);

      if (!((*msg)&stat&1))
	if (OM_Gf_verbose_warning) printf("Warning range not reduced \n");

      GRid_list.objid = TMP1.objid;
      GRid_list.osnum = TMP1.osnum;

    }/* end OPP_EMSsubbs_class_id */
    else
    {
      /*The remains of compressed tree is a composite surface or solid.*/

      stat = om$send(msg = message GRowner.GRget_number_components(
								   msg,
								   &ssize),
		     senderid = NULL_OBJID,
		     targetid = TMP1.objid,
		     targetos = TMP1.osnum);
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in  GRowner.GRget_number_components \n");
	err_flag = TRUE;
	goto wrapup;
      }

      if(ssize == 0 )
      {
	if (OM_Gf_verbose_warning) printf("ERROR, owner has no component\n");
	err_flag = TRUE;
	goto wrapup;
      }

      return_id = NULL;
      return_id = _MALLOC(ssize, GRobjid);
      if(return_id == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
	err_flag = TRUE;
	goto wrapup;
      }

      list = NULL;
      list = _MALLOC(ssize, struct GRid);
      if(list == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
	err_flag = TRUE;
	goto wrapup;
      }
      count = 0;
      stat = om$send(msg = message GRowner.GRget_components(
							    msg,
							    cst->env_info,
							    list,
							    ssize,
							    (int *)&count,
							    0,
							    OM_K_MAXINT),
		     senderid = NULL_OBJID,
		     targetid = TMP1.objid,
		     targetos = TMP1.osnum);
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in  GRowner.GRget_components \n");
	err_flag = TRUE;
	goto wrapup;
      }

      stat = om$send(msg = message GRowner.GRdrop(msg,
						  cst->env_info),
		     senderid = NULL_OBJID,
		     targetid = TMP1.objid,
		     targetos = TMP1.osnum);
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in  GRowner.GRdrop  \n");
	err_flag = TRUE;
	goto wrapup;
      }
      nb_cmp = 0;
      for (i=0;i<ssize;i=i+1)
      {
	stat = om$get_classid (objid = list[i].objid,
			       osnum = list[i].osnum,
			       p_classid = &sfid_class);
	as$status(sts=stat);
	if (!(stat&1))
	{
	  err_flag = TRUE;
	  goto wrapup;
	}
	found = 0;
	for(k=0; k< nb_del;k=k+1)
	{
	  if(list[i].objid == TODEL[k].objid)
	  {

	    stat = om$send(msg = message GRgraphics.GRdelete
			   (msg, cst->env_info),
			   senderid = NULL_OBJID,
			   targetid = list[i].objid ,
			   targetos = list[i].osnum);
	    as$status(sts=stat);
	    if (!(stat&1))
	    {
	      if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRdelete \n");
	      err_flag = TRUE;
	      goto wrapup;
	    }
	    list[i].objid = NULL_OBJID;
	    found = 1;
	    break;
	  }
	}
	if(found) continue;
	stat = om$is_ancestry_valid (subclassid = sfid_class,
				     superclassid = OPP_EMSsubbs_class_id);
	if (stat == OM_S_SUCCESS)
	{
	  stat = om$send(msg = message EMSsubbs.EMreduce_range(msg,
							       cst->env_info,&return_id[nb_cmp],
							       water_mark),
			 senderid = NULL_OBJID,
			 targetos = list[i].osnum,
			 targetid = list[i].objid);
	  if (!((*msg)&stat&1))
	  {
	    if (OM_Gf_verbose_warning) printf("Warning range not reduced \n");
	    return_id[nb_cmp] = list[i].objid;
	  }

	  nb_cmp = nb_cmp+1;
	}
      }
      _FREE(list);

      if(nb_cmp == 1)
      {
	bndsurf->objid = return_id[0];
	goto wrapup;
      }
      else if(nb_cmp > 1)
      {
	GRid_list.objid = NULL_OBJID;
	GRid_list.osnum = act_env->md_id.osnum;

	makecs_opt = NULL;

	stat = om$construct(msg =
			    message EMSsfstitch.EMmake_comp(msg,
							    nb_cmp, return_id,
							    act_env,NULL, NULL, 0,
							    NULL, makecs_opt),
			    classid = OPP_EMSsfstitch_class_id,
			    p_objid = &GRid_list.objid,
			    osnum   = GRid_list.osnum);

#ifdef	DEBUG
	printf("sfstitch result GRid_list.objid: %d\n", GRid_list.objid);
#endif
	_FREE(return_id);

	if( (*msg == EMS_E_NoDynamicMemory) ||
	    (*msg == EMS_E_DynamicMemoryAllocated))
	{
	  if (OM_Gf_verbose_warning) printf("ERROR EMmake_comp bad dynamic memory allocated\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	else
	{
	  if(!(stat & 1))
	  {
	    om$report_error(sts=stat);
	    err_flag = TRUE;
	    goto wrapup;
	  }

	  if (*msg == EMS_I_Fail) /*Stitch failed.*/
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR mybool:Stitch failed\n");
	    stat = EMmake_chanselect (GRcmpowner_to_components,
				      &to_comps);
	    if(!(stat & 1))
	    {
	      if (OM_Gf_verbose_warning) printf("EMmake_chanselect fail \n");
	      err_flag = TRUE;
	      goto wrapup;
	    }
	    stat = om$get_channel_count( objid = GRid_list.objid,
					 osnum = GRid_list.osnum,
					 p_chanselect = &to_comps,
					 count = &count);
	    if(!(stat & 1))
	    {
	      if (OM_Gf_verbose_warning) printf("om$get_channel_count fail \n");
	      err_flag = TRUE;
	      goto wrapup;
	    }
	    if (!count)
	    {
	      /*Delete composite object.*/
	      stat = om$send(msg = message Root.delete(0),
			     senderid = NULL_OBJID,
			     targetos = GRid_list.osnum,
			     targetid = GRid_list.objid);
	      if(!(stat & 1))
	      {
		if (OM_Gf_verbose_warning) printf("ERROR in Root.delete\n");
		om$report_error(sts=stat);
		err_flag = TRUE;
		goto wrapup;
	      }
	    }
	    GRid_list.objid = NULL_OBJID;

	  }/*Stitch failed.*/
	}
      }
    }

    bndsurf->objid = GRid_list.objid;
  }

#ifdef	DEBUG
  printf("bndsurf.objid: %d\n", bndsurf->objid);
#endif

  if(bndsurf->objid != NULL_OBJID)
  {
    stat = om$send( msg = message EMSsubbs.EMget_props(msg, &c_props),
		    senderid = NULL_OBJID,
		    targetid = bndsurf->objid,
		    targetos = bndsurf->osnum );

    as$status(sts=stat);
    if (!(stat&1)) c_props = 0x00;

    if( ((props & EMSIS_NRML_REVERSED)&& (!(c_props & EMSIS_NRML_REVERSED)))
	|| (!(props & EMSIS_NRML_REVERSED)&&(c_props & EMSIS_NRML_REVERSED)))
    {
      stat = om$get_classid (objid = bndsurf->objid,
			     osnum = bndsurf->osnum,
			     p_classid = &sfid_class);
      if (!(stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR om$get_classid\n");
	err_flag = TRUE;
	goto wrapup;
      }
      stat = om$is_ancestry_valid (subclassid = sfid_class,
				   superclassid = OPP_EMSsubbs_class_id);

      if (stat == OM_S_SUCCESS)
      {
	stat = om$send(msg = message EMSsubbs.EMset_props(msg,
							  EMSIS_NRML_REVERSED,
							  EMS_O_TOGGLE),
		       senderid = NULL_OBJID,
		       targetid = bndsurf->objid,
		       targetos = bndsurf->osnum);
	as$status(sts=stat);
      }
      else
      {
	stat = om$send( msg = message GRowner.GRget_number_components
			(msg, &ssize),
			senderid = NULL_OBJID,
			targetid =  bndsurf->objid,
			targetos =  bndsurf->osnum );
	as$status(sts=stat);
	if (!((*msg)&stat&1))
	{
	  if (OM_Gf_verbose_warning) printf("ERROR in GRowner.GRget_number_components\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	_FREE(list);
	list = _MALLOC(ssize, struct GRid);
	if(list == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
	  err_flag = TRUE;
	  goto wrapup;

	}
	count = 0;
	stat = om$send(msg = message GRowner.GRget_components(
							      msg,
							      act_env,
							      list,
							      ssize,
							      (int *)&count,
							      0,
							      OM_K_MAXINT),
		       senderid = NULL_OBJID,
		       targetid = bndsurf->objid,
		       targetos = bndsurf->osnum);
	as$status(sts=stat);
	if (!((*msg)&stat&1))
	{
	  if (OM_Gf_verbose_warning) printf("ERROR in  GRowner.GRget_components \n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	for (i=0;i<ssize;i=i+1)
	{
	  stat = om$send(msg = message EMSsubbs.EMset_props(msg,
							    EMSIS_NRML_REVERSED,
							    EMS_O_TOGGLE),
			 senderid = NULL_OBJID,
			 targetid = list[i].objid,
			 targetos = list[i].osnum);
	  as$status(sts=stat);
	}
      }
    }
  }
  _FREE(list);

wrapup:

  UI_status("");

  _FREE(TODEL);
  _FREE(return_id);
  _FREE(list);
  _FREE(p_par1);
  _FREE(p_par2);
  _FREE(int_pts);
  _FREE(over0);
  _FREE(over1);
  _FREE(end_pts);
  if(line      != NULL) {(IGRboolean)BSfreecv(&rc, line)     ;line       = NULL;}
  _FREE(geom);

#ifdef	DEBUG
  printf("don't delete objects \n");
  if(err_flag == TRUE) return(0);
  else  return(1);

#endif

  if(om$is_objid_valid(osnum = PROJCV.osnum,objid = PROJCV.objid) & 1)
  {
    om$send(	msg = message GRgraphics.GRdelete(msg,
						  cst->env_info),
		senderid = NULL_OBJID,
		targetid = PROJCV.objid ,
		targetos = PROJCV.osnum);
    PROJCV.objid = NULL_OBJID;
  }

  _pathway_trim   = sav_pathway_trim;
  _pathway_orient = sav_pathway_orient;

  if(err_flag == TRUE)
  {
    if( bndsurf->objid != NULL_OBJID)
    {
      om$send(msg      = message GRgraphics.GRdelete(msg,
						     act_env),
	      senderid = NULL_OBJID,
	      targetid = bndsurf->objid,
	      targetos = bndsurf->osnum );
      bndsurf->objid = NULL_OBJID;
    }
    __exit_error_Function ( name = "SMCreatBndSurf" );
    return(0);
  }
  else
  {
    __exitFunction ( name = "SMCreatBndSurf" );
    return(1);
  }
}

/*11 ====================== SMCreatBndPl ==========================

	Function that creates a bounded surface based on a plane
	support, if given a closed curve on it.

	an EMplane_of_curve is performed.

	Tol is modified otherwise curve is not consider closed.

	return(1) if ok.
	else return(0).

*/

int	SMCreatBndPl(msg, closed_cv, cvgeom, cst, bndpl)
long			*msg;       /* (O) completion code */
struct GRlc_info	*closed_cv; /* (I) input closed curve */
struct IGRbsp_curve	*cvgeom;    /* (I) geom of the curve if known */
struct GRvg_construct   *cst;	    /* (I) construction list */
struct	GRid		*bndpl;     /* (O) constructed bounded plane */

/*.SMCreatBndPl*/
{
  int			stat;
  IGRboolean		test_degeneracy, construct_loopset, err_flag;
  struct GRlc_info	*lcinfo;
  struct IGRbsp_curve	*geom;

  if(closed_cv == NULL || cst == NULL || bndpl == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  __enterFunction ( name = "SMCreatBndPl" );

  if(msg != NULL) *msg = MSSUCC;
  err_flag = FALSE;

  geom = NULL;
  lcinfo = NULL;

  bndpl->objid = NULL_OBJID;
  bndpl->osnum = cst->env_info->md_id.osnum;

  if(cvgeom) geom = cvgeom;
  if(closed_cv) lcinfo = closed_cv;

  test_degeneracy   = TRUE;
  construct_loopset = TRUE;

  bndpl->objid = NULL_OBJID;
  bndpl->osnum = cst->env_info->md_id.osnum;

  stat = om$construct(msg       = message EMSplane.EMplane_of_curve(msg,
								    cst, lcinfo, geom, NULL,
								    test_degeneracy,
								    construct_loopset, NULL, NULL),
		      classid = OPP_EMSplane_class_id,
		      p_objid  = &(bndpl->objid),
		      osnum  = bndpl->osnum);

  as$status(sts=stat, action = RET_STATUS);

  if(err_flag == TRUE)
  {
    if(bndpl->objid != NULL_OBJID)
    {
      om$send(msg      = message GRgraphics.GRdelete(msg,cst->env_info),
	      senderid = NULL_OBJID,
	      targetid = bndpl->objid,
	      targetos = bndpl->osnum );
      bndpl->objid = NULL_OBJID;
    }
    __exit_error_Function ( name = "SMCreatBndPl" );
  
    return(0);
  }
  else
  {
    __exitFunction ( name = "SMCreatBndPl" );

    return(1);
  }
  
}

/*12 ====================== SMSurfBnd ==========================

	Function that creates a bounded surface if given the
	support and the limitating objects (cf macro SMSfBound)

	Algorithm:

		- compute intersections between the support and the
		limitating objects (nb_intcv, intcv)

		- compute all curve intersections (nb_intpt, intpt)
		- write the graph of these intersections :
			the nodes are intpt,
			the arc are the curves between intpt

		- detect all possible loops in the graph

		- choice of the loop that will be used to create the bounded
		  surface:

			- Get the Loops with the maximum number of limitating
			elements.

			- If there is more than one, try to find a track element

				- track elt is a surface that don't intersect
				the support.

				- or a surface not taken in any loops

			- If a track element is found (cannot be a composite
			surface):

				- choose the loop that is the closest than the
				track element. (min dist with the composite
				curve constructed on the loop)

			- If there is no track element or if there is more than
			one loop at the same distance from it, try to find
			a loop that takes into account the order of the input
			surfaces.

			- Otherwise take the first loop.

		- Constructs the composite curve based on the choosen loop.
		- Creates the surface based on the support and bounded by this
		composite curve:

			- If support is a plane an EMplane_of_curve is
			performed.

			- For single surface support an impose boundary
			is performed.

			- For composite surface a boolean diff is performed
			between the support and the surface of projection
			based on the closed planar curve. (the composite
			curve is projected on a dummy plane approximating
			the support).

		- Reverse the orientation of the bounded surface if it is not
		the same as the support.

	return(1) if ok.
	else return(0).

*/

int	SMSurfBnd(msg, num_ent, act_env, lc_obj, lc_track, inf_flag,
			ordered, rev_sup, cst, bnd_id)
long			*msg;       /* (O) completion code */
int			num_ent;    /* (I) nb input objects */
struct GRmd_env		*act_env;   /* (I) act mod env */
struct GRlc_info	*lc_obj;    /* (I) input surfaces */
struct GRlc_info	*lc_track;  /* (I) the track elt (NULL_OBJID if not) */
char			*inf_flag;  /* (I) infinite flag */
int			ordered;    /* (I) 1 for ordered surface input */
IGRint			rev_sup;    /* (I) 1 for reverse orient */
struct GRvg_construct   *cst;	    /* (I) construction list */
struct	GRid		*bnd_id;    /* (O) constructed bounded surface */

/*.SMSurfBnd*/
{
  struct IGRbsp_curve	**plcurve, **plcurve1, *cvgeom, *compcv, *projcv,
			**comp_curve;
  struct IGRbsp_surface	*surfgeom;
  struct IGRplane	plane[2], const_pl, *plan1;
  struct GRlc_info      *curves, **part_id, final_curve, *part_cv;
  struct ret_struct	ret_st;
  struct GRvg_construct tmp_cst;
  struct GRid		prj_comp, comp_id, *comp_loop;

  struct SMsfinters	*cvinters;
  struct SMinters	*ptinters;
  struct SMcurve	*SMcurve;
  struct gr_arc		*graph;
  struct sl_arc		*sl_arc, *wrk_arc;
  struct SMExactInt	*IntPts;

  IGRdouble		range[6], *pt1, *pt2, *par1, *par2,
			basis_tol, cht_tol, tol, track_point[3],
			plane_space[12], pl_space[6],
			*trackdist, mindist;

  IGRboolean		world, err_flag;
  IGRboolean		by_track, by_first;

  char			running[DI_PATH_MAX];

  IGRshort		n_int, n_par;

  long			stat, nput, nret;

  IGRint		numedge, type_flag,nb_slarc, nb_alloc_arc,sl_index,
			elem_type, *typesf, nb_cvinters, nb_ptinters,
			nb_elt_in_graph,  min_loopindex,
			*loop_index,nb_maxloop, loop_taken,
			nb_sf1, nb_curves,
			close_cv,  i,  k, l,
			**sfloop, *nb_sfloop;

  struct loop_on_surf	loops, loop_on_surf;
  BSrc			rc;

#ifdef	DEBUG
  printf("num_ent: %d\n", num_ent);
  for(i=0;i<num_ent;i++)
    printf("obj: %d, %d\n", lc_obj[i].located_obj.objid,lc_obj[i].located_obj.osnum);
#endif

  if(num_ent == 0 || act_env == NULL || lc_obj == NULL || inf_flag == NULL
     || lc_track == NULL || cst == NULL || bnd_id == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Invalid Argument\n");
    return(0);
  }
  __enterFunction ( name = "SMSurfBnd" );

  if(msg != NULL) *msg = MSSUCC;
  pt1 = pt2 = par1 = par2 = NULL;

  IntPts		= NULL;
  curves		= NULL;
  part_cv		= NULL;
  part_id		= NULL;
  surfgeom		= NULL;
  comp_curve		= NULL;
  typesf		= NULL;
  comp_loop		= NULL;
  compcv		= NULL;
  cvgeom		= NULL;
  sfloop		= NULL;
  nb_sfloop		= NULL;
  plan1			= NULL;
  plcurve		= NULL;
  plcurve1		= NULL;
  cvinters		= NULL;
  nb_cvinters		= 0;
  ptinters		= NULL;
  SMcurve		= NULL;
  graph			= NULL;
  loops.nb_loop		= 0;
  loops.one_loop	= NULL;
  loop_on_surf.nb_loop	= 0;
  loop_on_surf.one_loop = NULL;
  loop_index		= NULL;
  wrk_arc		= NULL;
  sl_arc		= NULL;
  projcv		= NULL;
  nb_alloc_arc		= 100;
  nb_curves		= 0;
  nb_slarc		= 0;
  nb_maxloop		= 0;
  nb_cvinters		= 0;
  trackdist		= NULL;
  min_loopindex		= 0;
  loop_taken		= -1;

  prj_comp.objid = NULL_OBJID;
  comp_id.objid = NULL_OBJID;

  close_cv = 0;

  const_pl.point  = &pl_space[0];
  const_pl.normal = &pl_space[3];

  plane[0].point  = &plane_space[0];
  plane[0].normal = &plane_space[3];
  plane[1].point  = &plane_space[6];
  plane[1].normal = &plane_space[9];

  err_flag = FALSE;

  bnd_id->objid = NULL_OBJID;
  bnd_id->osnum = act_env->md_id.osnum;

  nput = sizeof(basis_tol);

  gr$get_basis_tolerance(msg    = msg,
			 sizbuf = &nput,
			 buffer = &basis_tol,
			 nret   = &nret);

  if(!((*msg)&1))
  {
    if (OM_Gf_verbose_warning) printf("error gr$get_basis_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }
  nput = sizeof(cht_tol);

  gr$get_chord_height_tolerance(msg    = msg,
				sizbuf = &nput,
				buffer = &cht_tol,
				nret   = &nret);

  if(!((*msg)&1))
  {
    if (OM_Gf_verbose_warning) printf("error gr$get_chord_height_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }
  tol = cht_tol ;

  world = TRUE;
  stat = om$send( msg = message GRgraphics.GRgetrang(msg,
						     &lc_obj[0].module_info.md_env.matrix_type,
						     lc_obj[0].module_info.md_env.matrix,
						     &world, range),
		  senderid = NULL_OBJID,
		  targetid = lc_obj[0].located_obj.objid,
		  targetos = lc_obj[0].located_obj.osnum );

  as$status(sts=stat);
  if (!((*msg)&stat&1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRgetrang\n" );
    err_flag = TRUE;
    goto wrapup;
  }

  nb_sf1 = 0;
  if (inf_flag[0] != 'y' && inf_flag[0] != 'Y') type_flag = SURF;
  else				      type_flag = PLAN;

  stat = SMelem_(type_flag, &(lc_obj[0].located_obj),
		 lc_obj[0].module_info.md_env.matrix_type,
		 lc_obj[0].module_info.md_env.matrix,
		 &elem_type, &plane[0], NULL, NULL, &nb_sf1);
  if (!(stat&1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR fonction SMelem_\n");
    err_flag = TRUE;
    goto wrapup;
  }

  if(elem_type != PLAN)
  {
    stat = om$send (msg = message EMSsurface.EMputLsIfNotThere
		    (	msg,
			&lc_obj[0].module_info.md_env,
			NULL,
			NULL,
			0,
			NULL),
		    senderid = NULL_OBJID,
		    targetid = lc_obj[0].located_obj.objid,
		    targetos = lc_obj[0].located_obj.osnum);
    as$status(sts=stat);
    if (!((*msg)&stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR in EMSsurface.EMputLsIfNotThere\n");
      err_flag = TRUE;
      goto wrapup;
    }
    lc_obj[0].module_info = (*act_env);
    lc_obj[0].located_obj = lc_obj[0].located_obj;
  }

  /* SPECIAL CASE FOR SUPPORT COMPOSITE AND ONLY ONE LIMITATING SURFACE
     (hull and plane) we directly make support boolean diff with object */

  if(num_ent == 2 && elem_type == COMP_SF)
  {
    stat = SMBndBool(msg, act_env, lc_obj, inf_flag, cst, bnd_id);

    if(!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMBndBool\n");
      err_flag = TRUE;
      goto wrapup;
    }

    goto wrapup;
  }

  /* -----------------------------------------------------------------------

     we have (num_ent) objects that will give (num_ent-1) intersection cv
     we make intersection between support and surface i and create the
     intersection curve => INT_CURVE[i-1] (geom curve[i-1] )

     ----------------------------------------------------------------------- */

  typesf = _MALLOC(num_ent, int);
  if(typesf == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }

  tmp_cst = (*cst);
  stat = SMint_support(msg, num_ent, lc_obj, &tmp_cst, inf_flag,
		       &nb_cvinters, &cvinters, &SMcurve, typesf);
  if(!(stat & (*msg) & 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMint_support\n");
    err_flag = TRUE;
    goto wrapup;
  }

  /* transform struct sfinters in a structure on surface */

  if(nb_cvinters == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR:no intersection between support and any surface\n");
    err_flag = TRUE;
    goto wrapup;
  }
  if(nb_cvinters == 1 && cvinters[0].cv_geom->phy_closed == TRUE) close_cv = 1;

  if(nb_cvinters == 1 && !close_cv)
  {
    if (OM_Gf_verbose_warning) printf("ERROR cannot create a bounded surface with an open curve\n");
    err_flag = TRUE;
    goto wrapup;
  }

  plcurve = _MALLOC(nb_cvinters, struct IGRbsp_curve *);
  if(	plcurve == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<nb_cvinters;i++) plcurve[i] = NULL;

  plcurve1 = _MALLOC(nb_cvinters, struct IGRbsp_curve *);
  if(	plcurve1 == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<nb_cvinters;i++) plcurve1[i] = NULL;

  for(i=0;i<nb_cvinters;i++) plcurve[i] = cvinters[i].cv_geom ;

  if(close_cv)
  {
    if(elem_type == COMP_SF)
    {
      /* -------------------------------------------------------
	 We approximate the support with a plane (point and normal):
	 Compute the minimum distance between each curve and its
	 successor and get the barycenter of these approximative
	 intersection points in order to have a point in the area
	 we want to extract, the plane taken will be the tangent plane
	 to the support at this point.
	 ---------------------------------------------------------- */
      ex$message(msgnumb = SM_S_CstPrjPl);

      for(k=0;k<nb_cvinters;k=k+1) plcurve[k] = cvinters[k].cv_geom;

      stat = SMGetDummyPl(msg, nb_cvinters, plcurve,ordered,
			  &lc_obj[0], range,elem_type, &const_pl);
      if(!(stat & (*msg) & 1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR SMGetDummyPl\n");
	err_flag = TRUE;
	goto wrapup;
      }

      plan1 = &const_pl;
    }
    else plan1 = NULL;

    if(elem_type == COMP_SF || cvinters[0].cvint_id.objid == NULL_OBJID)
    {
      tmp_cst = (*cst);
      tmp_cst.geometry = (char *)plcurve[0];

      prj_comp.osnum = tmp_cst.env_info->md_id.osnum;
      prj_comp.objid = NULL_OBJID;

      stat = om$construct(msg = message GRgraphics.GRconstruct(
							       &tmp_cst),
			  classid = OPP_GRbcsubbc_class_id,
			  p_objid  = &(prj_comp.objid),
			  osnum  = prj_comp.osnum);

      as$status(sts=stat);
      if (!(stat&1))
      {
	if (OM_Gf_verbose_warning) printf("GRbcsubbc.GRconstruct failed\n");
	err_flag = TRUE;
	goto wrapup;
      }

      final_curve.located_obj = prj_comp;
    }
    else	final_curve.located_obj = cvinters[0].cvint_id;

    final_curve.module_info = *(cst->env_info);

    tmp_cst = (*cst);
    ex$message(msgnumb = SM_S_CrtBndSf);

    stat = SMCreatBndSurf(msg, &final_curve, (struct IGRbsp_curve *)NULL,
			  1, &final_curve, act_env, &tmp_cst, elem_type,
			  &lc_obj[0], plan1,bnd_id);

    if(!(stat & (*msg) & 1) )
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMCreatBndSurf\n");
      err_flag = TRUE;
      goto wrapup;
    }

    goto wrapup;
  }

  ex$message(msgnumb = SM_S_CmpIntCv);

  stat = SMint_curves(nb_cvinters, plcurve, ordered, &nb_ptinters, &ptinters);
  if(!(stat & (*msg) & 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMint_curves\n");
    err_flag = TRUE;
    goto wrapup;
  }

  if(nb_ptinters == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR , No curve Intersections\n");
    err_flag = TRUE;
    goto wrapup;
  }

  /* transform struct inters in a structure on curve */

  stat = SMSortCvIntpts(nb_cvinters, nb_ptinters, ptinters, SMcurve);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMSortCvIntpts\n");
    err_flag = TRUE;
    goto wrapup;
  }

  IntPts = NULL;
  IntPts = _MALLOC(nb_ptinters, struct SMExactInt);
  if(IntPts == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<nb_ptinters;i++)
    for(k=0;k<3;k++) IntPts[i].surf[k].geom = NULL;

  /* get the exact intersection points */

  stat = SMGetSfintpt( nb_ptinters, ptinters, cvinters, lc_obj, typesf, IntPts);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMGetSfintpt\n");
    err_flag = TRUE;
    goto wrapup;
  }
  stat = SMChgInters(nb_ptinters, ptinters, cvinters,IntPts);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMChgInters\n");
    err_flag = TRUE;
    goto wrapup;
  }

  nb_elt_in_graph = 0;
  SMGraphDescr(nb_cvinters, SMcurve, NULL, ptinters,&nb_elt_in_graph, &graph);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMGraphDescr\n");
    err_flag = TRUE;
    goto wrapup;
  }

  if(nb_elt_in_graph == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR No graph defined\n");
    err_flag = TRUE;
    goto wrapup;
  }

  ex$message(msgnumb = SM_S_GetLpGrp);

  stat = SMGetLoopInGraph(nb_elt_in_graph, graph, ptinters, &loops.nb_loop, &loops.one_loop);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMGetLoopInGraph\n");
    err_flag = TRUE;
    goto wrapup;
  }

  if(loops.nb_loop == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, No Possible loop \n");
    err_flag = TRUE;
    goto wrapup;
  }

  sl_arc = _MALLOC(nb_alloc_arc, struct sl_arc);
  if(sl_arc == NULL)
  {
    if (OM_Gf_verbose_warning) printf("bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  loop_on_surf.nb_loop = loops.nb_loop;
  loop_on_surf.one_loop = _MALLOC(loop_on_surf.nb_loop, struct one_loop);
  if(loop_on_surf.one_loop == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(k=0;k<loop_on_surf.nb_loop;k=k+1)
  {
    loop_on_surf.one_loop[k].nb_edge = 0;
    loop_on_surf.one_loop[k].edge = NULL;
  }

  for(k=0;k<loops.nb_loop;k=k+1)
  {
    numedge = loops.one_loop[k].nb_edge - 1; /* don't repeat last pt */

    wrk_arc = NULL;
    wrk_arc = _MALLOC(numedge, struct sl_arc);
    if(wrk_arc == NULL)
    {
      if (OM_Gf_verbose_warning) printf("Bad allocation \n");
      err_flag = TRUE;
      goto wrapup;
    }

    loop_on_surf.one_loop[k].nb_edge = numedge;
    loop_on_surf.one_loop[k].edge = _MALLOC(loop_on_surf.one_loop[k].nb_edge, int);
    if(loop_on_surf.one_loop[k].edge == NULL)
    {
      if (OM_Gf_verbose_warning) printf("Bad allocation \n");
      err_flag = TRUE;
      goto wrapup;
    }

    stat = SMget_sl_arc(msg, loops.one_loop[k], graph, wrk_arc);
    if(!(stat & (*msg) &1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMget_sl_arc\n");
      err_flag = TRUE;
      goto wrapup;
    }

    if(nb_alloc_arc <= numedge)
    {
      nb_alloc_arc = nb_alloc_arc + numedge + 1;
      sl_arc = _REALLOC(sl_arc, nb_alloc_arc, struct sl_arc );
      if(sl_arc == NULL)
      {
	if (OM_Gf_verbose_warning) printf("bad reallocation\n");
	err_flag = TRUE;
	goto wrapup;
      }
    }
    for(l=0;l<numedge;l=l+1)
    {
      if(! SMIsEltInSlArc(&wrk_arc[l], nb_slarc, sl_arc, ptinters,
			  &sl_index) )
      {
	loop_on_surf.one_loop[k].edge[l] = nb_slarc;
	sl_arc[nb_slarc] = wrk_arc[l];
	nb_slarc = nb_slarc + 1;
      }
      else loop_on_surf.one_loop[k].edge[l] = sl_index;
    }

    _FREE(wrk_arc);
  }

  /* choice of loop */

  by_track = by_first = FALSE;

  if(loop_on_surf.nb_loop > 1)
  {
    /* take loops that contains the max nb of surfaces */

    ex$message(msgnumb = SM_S_GetLpMx);

    loop_index = NULL;
    nb_maxloop = 0;
    stat = SMGetMaxSfLoop(&loop_on_surf, sl_arc, cvinters, NULL,
			  &nb_maxloop, &loop_index);
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMGetMaxSfLoop\n");
      err_flag = TRUE;
      goto wrapup;
    }

    if(nb_maxloop > 1)
    {
      if(lc_track->located_obj.objid != NULL_OBJID)
      {
	as$any_give_structure(go_grid = lc_track->located_obj,
			      inst = &ret_st,
			      mod_env = &lc_track->module_info);

	for(i=0;i<3;i++)
	  track_point[i] = ret_st.var.point_st.pt[i];

	/* choose loop closest than track element */

	by_track = TRUE;
	comp_curve = _MALLOC(nb_maxloop, struct IGRbsp_curve *);
	if(comp_curve == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	for(i=0;i<nb_maxloop;i++) comp_curve[i] = NULL;

	comp_loop = _MALLOC(nb_maxloop, struct GRid);
	if(comp_loop == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	trackdist = _MALLOC(nb_maxloop, IGRdouble);
	if(trackdist == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	mindist = -1;
	part_id = NULL;
	part_id = _MALLOC(nb_maxloop, struct GRlc_info *);
	if(part_id == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	for(i=0;i<nb_maxloop;i++) part_id[i] = NULL;

	for(i=0;i<nb_maxloop;i++)
	{
	  tmp_cst = (*cst);

	  stat = SMCrtPartCv(nb_cvinters,
			     plcurve,
			     nb_ptinters,
			     ptinters,
			     &loop_on_surf.one_loop[loop_index[i]],
			     sl_arc,
			     &tmp_cst,
			     &part_id[i],
			     NULL);
	  if(stat != 1)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR SMCrtPartCv\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }

	  stat = SMCreatCompCv(
			       loop_on_surf.one_loop[loop_index[i]].nb_edge,
			       part_id[i],
			       &tmp_cst,
			       &comp_loop[i],
			       &comp_curve[i]);
	  if(stat != 1)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR SMCreatCompCv\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }

	  /* compute dist between track point and curve */

	  (void)BSmdistptcv(comp_curve[i],
			    track_point,
			    &n_int,
			    &n_par,
			    &par1,
			    &trackdist[i],
			    &par2,
			    &rc);
	    if(rc != BSSUCC )
	    {
	      if (OM_Gf_verbose_warning) printf(" ERROR in BSmdistptcv\n");
	      err_flag = TRUE;
	      goto wrapup;
	    }

	    if(i == 0 || mindist > trackdist[i])
	    {
	      mindist = trackdist[i];
	      min_loopindex = i;
	    }
	}
	comp_id = comp_loop[min_loopindex];
	cvgeom = comp_curve[min_loopindex];
	nb_curves = loop_on_surf.one_loop[loop_index[min_loopindex]].nb_edge;
	curves = part_id[i];
      }
    }
    if(loop_taken == -1) {by_first = TRUE; loop_taken = loop_index[0];}
  }
  else loop_taken = 0;

  if(by_track == TRUE) {ex$message(msgnumb = SM_S_LpDpTrk);}
  else if(by_first == TRUE) {ex$message(msgnumb = SM_S_TkFstLp);}

  if(comp_id.objid == NULL_OBJID)
  {
    ex$message(msgnumb = SM_S_CrtCmpCv);

    tmp_cst = (*cst);
    compcv = NULL;
    part_cv = NULL;
    stat = SMCrtPartCv(nb_cvinters,
		       plcurve,
		       nb_ptinters,
		       ptinters,
		       &loop_on_surf.one_loop[loop_taken],
		       sl_arc,
		       &tmp_cst,
		       &part_cv,
		       NULL);
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMCrtPartCv\n");
      err_flag = TRUE;
      goto wrapup;
    }

    stat = SMCreatCompCv(
			 loop_on_surf.one_loop[loop_taken].nb_edge,
			 part_cv,
			 &tmp_cst,
			 &comp_id,
			 &compcv);
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMCreatCompCv\n");
      err_flag = TRUE;
      goto wrapup;
    }
    nb_curves = loop_on_surf.one_loop[loop_taken].nb_edge;
    curves = part_cv;
    cvgeom = compcv;
  }

  __printf ("comp_id: [%d,%d]", `comp_id.osnum, comp_id.objid` );

  if (VDcomment)  stat = dp$display ( msg = msg, oids = &comp_id );

  final_curve.located_obj = comp_id;
  final_curve.module_info = *(cst->env_info);

  tmp_cst = (*cst);
  projcv = NULL;

  if( elem_type == COMP_SF)
  {
    /* -------------------------------------------------------
       We approximate the support with a plane (point and normal):
       Compute the minimum distance between each curve and its
       successor and get the barycenter of these approximative
       intersection points in order to have a point in the area
       we want to extract, the plane taken will be the tangent plane
       to the support at this point.
       ---------------------------------------------------------- */

    ex$message(msgnumb = SM_S_CstPrjPl);

    stat = SMGetDummyPl(msg, 1, &compcv, ordered, &lc_obj[0], range,
			elem_type, &const_pl);
    if(!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMGetDummyPl\n");
      err_flag = TRUE;
      goto wrapup;
    }

    sprintf(running,"%s","Project curve on dummy plane" );
    UI_status(running);

    (void)BSalloccv(compcv->order,
		    compcv->num_poles,
		    compcv->rational,
		    compcv->num_boundaries,
		    &projcv,
		    &rc);
    if(rc != BSSUCC && rc!=BSNULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
      err_flag = TRUE;
      goto wrapup;
    }
    (IGRboolean)BSprj_cv_pl(&rc, compcv,
			    &const_pl.point[0], &const_pl.normal[0],
			    const_pl.normal, projcv);
      if(rc!=BSSUCC)
      {
	if (OM_Gf_verbose_warning) printf("ERROR BSprj_cv_pl: no projection curve\n");
	err_flag = TRUE;
	goto wrapup;
      }
      plan1 = &const_pl;
      tmp_cst = (*cst);
      tmp_cst.geometry = (char *)projcv;
      prj_comp.osnum = tmp_cst.env_info->md_id.osnum;
      prj_comp.objid = NULL_OBJID;
      cvgeom = projcv;
      stat = om$construct(msg = message GRgraphics.GRconstruct(
							       &tmp_cst),
			  classid = OPP_GRbcsubbc_class_id,
			  p_objid  = &(prj_comp.objid),
			  osnum  = prj_comp.osnum);

      as$status(sts=stat);
      if (!(stat&1))
      {
	if (OM_Gf_verbose_warning) printf("GRbcsubbc.GRconstruct failed\n");
	err_flag = TRUE;
	goto wrapup;
      }
      final_curve.located_obj = prj_comp;
      final_curve.module_info = *(cst->env_info);

  }
  else plan1 = NULL;

  if(cvgeom != NULL && cvgeom->phy_closed != TRUE)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, constructed curve is not closed\n");
    err_flag = TRUE;
    goto wrapup;
  }

  ex$message(msgnumb = SM_S_CrtBndSf);
  tmp_cst = (*cst);
  stat = SMCreatBndSurf(msg, &final_curve, cvgeom, nb_curves, curves,
			act_env, &tmp_cst, elem_type,
			&lc_obj[0], plan1,bnd_id);

  if(!(stat & (*msg) & 1) )
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMCreatBndSurf\n");
    err_flag = TRUE;
    goto wrapup;
  }

wrapup:

  UI_message("");
  UI_status("");

  if(IntPts != NULL)
  {
    for(i=0;i<nb_ptinters;i++)
      for(k=0;k<3;k++) SMFreeSfGeom( &IntPts[i].surf[k]);
    _FREE(IntPts);
  }

  if( om$is_objid_valid(osnum = prj_comp.osnum,	objid = prj_comp.objid) & 1
      && VDcomment == 0 /* DEBUG */ )	// VDcomment == 0 : DON'T delete the objects ....
  {
    om$send(msg = message GRgraphics.GRdelete(msg, cst->env_info),
	    senderid = NULL_OBJID,
	    targetid = prj_comp.objid ,
	    targetos = prj_comp.osnum);
    prj_comp.objid = NULL_OBJID;
  }

  if(part_cv != NULL)
  {
    for(i=0;i<loop_on_surf.one_loop[loop_taken].nb_edge; i++)
    {
      if( om$is_objid_valid(osnum = part_cv[i].located_obj.osnum,
			    objid = part_cv[i].located_obj.objid) & 1 && VDcomment == 0 /* DEBUG */ )
      {
	stat = om$send(	msg = message GRgraphics.GRdelete(msg,
							  cst->env_info),
			senderid = NULL_OBJID,
			targetid = part_cv[i].located_obj.objid ,
			targetos = part_cv[i].located_obj.osnum);
	as$status(sts=stat);
	part_cv[i].located_obj.objid = NULL_OBJID;
      }
    }
    _FREE(part_cv);
  }

  if(part_id !=NULL)
  {
    for(i=0;i<nb_maxloop; i++)
    {
      if(om$is_objid_valid(osnum = part_id[i]->located_obj.osnum,
			   objid = part_id[i]->located_obj.objid) & 1 && VDcomment == 0 /* DEBUG */ )
      {
	stat = om$send(	msg = message GRgraphics.GRdelete(msg,
							  cst->env_info),
			senderid = NULL_OBJID,
			targetid = part_id[i]->located_obj.objid ,
			targetos = part_id[i]->located_obj.osnum);
	as$status(sts=stat);
	part_id[i]->located_obj.objid = NULL_OBJID;
      }
      _FREE(part_id[i]);
    }
    _FREE(part_id);

  }
  if(sfloop != NULL)
  {
    for(i=0;i<nb_maxloop; i++)
      _FREE(sfloop[i]);
    _FREE(sfloop);
  }
  _FREE(par1);
  _FREE(par2);
  _FREE(pt1);
  _FREE(pt2);
  if(comp_loop != NULL)
  {
    for(i=0;i<nb_maxloop;i++)
    {
      if(om$is_objid_valid(osnum = comp_loop[i].osnum,
			   objid = comp_loop[i].objid) & 1)
      {
	om$send(	msg = message GRgraphics.GRdelete(msg, cst->env_info),
			senderid = NULL_OBJID,
			targetid = comp_loop[i].objid ,
			targetos = comp_loop[i].osnum);
	comp_loop[i].objid = NULL_OBJID;
      }
    }
    _FREE(comp_loop);
  }
  _FREE(surfgeom);
  _FREE(trackdist);
  _FREE(compcv);
  if(comp_curve != NULL)
  {
    for(i=0;i<nb_maxloop; i++)
    {
      _FREE(comp_curve[i]);
    }
    _FREE(comp_curve);
  }
  _FREE(typesf);
  _FREE(nb_sfloop);
  _FREE(sl_arc);
  _FREE(wrk_arc);
  if(plcurve1 != NULL)
  {
    for(i=0;i<nb_cvinters;i=i+1)
    {
      if(plcurve1[i] != NULL )
	(IGRboolean)BSfreecv(&rc, plcurve1[i]); plcurve1[i] = NULL;

    }
    _FREE(plcurve1);
  }
  _FREE(plcurve);
  if(projcv != NULL ){(IGRboolean)BSfreecv(&rc, projcv); projcv = NULL;}

  _FREE(ptinters);
  if(SMcurve != NULL)
  {
    for(i=0;i<nb_cvinters;i=i+1)
      _FREE(SMcurve[i].pt_index);
    _FREE(SMcurve);
  }
  if(cvinters != NULL)
  {
    for(i=0;i<nb_cvinters; i=i+1)
    {
      /* don't delete input curve */

      if(cvinters[i].sf1 == -1 || cvinters[i].sf2 == -1) continue;
      if( om$is_objid_valid(osnum = cvinters[i].cvint_id.osnum,
			    objid = cvinters[i].cvint_id.objid) & 1 && VDcomment == 0 /* DEBUG */ )
      {
	om$send(	msg = message GRgraphics.GRdelete(msg, cst->env_info),
			senderid = NULL_OBJID,
			targetid = cvinters[i].cvint_id.objid ,
			targetos = cvinters[i].cvint_id.osnum);
	cvinters[i].cvint_id.objid = NULL_OBJID;
      }
      if(cvinters[i].cv_geom!=NULL)
      {
	if(cvinters[i].alloc_flag == FALSE)
	{
	  _FREE ( cvinters[i].cv_geom );
	}
	else
	{
	  (IGRboolean)BSfreecv(&rc, cvinters[i].cv_geom);
	}
	cvinters[i].cv_geom = NULL;
      }
    }
    _FREE(cvinters);
  }
  _FREE(graph);
  if(loops.one_loop != NULL )
  {
    for(k=0;k<loops.nb_loop;k=k+1)
      _FREE(loops.one_loop[k].edge);
    _FREE(loops.one_loop);
  }
  if(loop_on_surf.one_loop != NULL )
  {
    for(k=0;k<loop_on_surf.nb_loop;k=k+1)
      _FREE(loop_on_surf.one_loop[k].edge);
    _FREE(loop_on_surf.one_loop);
  }
  _FREE(loop_index);

  if(om$is_objid_valid(osnum = comp_id.osnum,
		       objid = comp_id.objid) & 1 && VDcomment == 0 )	// VDcomment == 0 : DON'T delete the objects ....
  {
    om$send(	msg = message GRgraphics.GRdelete(msg, cst->env_info),
		senderid = NULL_OBJID,
		targetid = comp_id.objid ,
		targetos = comp_id.osnum);
    comp_id.objid = NULL_OBJID;
  }

#ifdef	DEBUG
  printf("don't delete the objects ........\n");

  if(err_flag == TRUE)
  {
    if( bnd_id->objid != NULL_OBJID)
    {
      om$send(msg      = message GRgraphics.GRdelete(msg,cst->env_info),
	      senderid = NULL_OBJID,
	      targetid = bnd_id->objid,
	      targetos = bnd_id->osnum );
      bnd_id->objid = NULL_OBJID;
    }
    return(0);
  }
  else return(1);

#endif

  if(err_flag == TRUE)
  {
    if( bnd_id->objid != NULL_OBJID)
    {
      om$send(msg      = message GRgraphics.GRdelete(msg,cst->env_info),
	      senderid = NULL_OBJID,
	      targetid = bnd_id->objid,
	      targetos = bnd_id->osnum );
      bnd_id->objid = NULL_OBJID;
    }
    __exit_error_Function ( name = "SMSurfBnd" );

    return(0);
  }
  else
  {
    __exitFunction ( name = "SMSurfBnd" );
    return(1);
  }
}

/*13 ====================== SMCreatBndVol ==========================

	Function that creates a volume from surfaces.
	(cf macro SMboundvol)

	Algorithm:

		- compute all surface intersections (intcv)
		- compute all curve (intcv) intersections (intpt)
		- detect all possible loops on each surface
		- detect all possible volumes with these loops
		- construct the choosen volume :
			- construct the composite (loop) on each surface
			- Create each bounded surface
			- make a composite of these bounded surfaces

	return(1) if ok.
	else return(0).

*/

int	SMCreatBndVol(msg, num_ent, act_env, lc_obj, lc_track, inf_flag,
		ordered, cst, bnd_id)
long			*msg;       /* (O) completion code */
int			num_ent;    /* (I) nb input objects */
struct GRmd_env		*act_env;   /* (I) act mod env */
struct GRlc_info	*lc_obj;    /* (I) input closed curve */
struct GRlc_info	*lc_track;  /* (I) the track elt (NULL_OBJID if not) */
char			*inf_flag;  /* (I) infinite flag */
int			ordered;    /* (I) 1 for ordered surface input */
struct GRvg_construct   *cst;	    /* (I) construction list
					(md_env.md_id = NULL_OBJID)*/
struct	GRid		*bnd_id;    /* (O) constructed vol */

/*.SMCreatBndVol*/
{

  int			i,k,l,nb_SMsfinters,nb_elt_in_graph,
			nb_SMsurf, nb_SMinters, *elem_type, numedge,
			nb_slarc, nb_alloc_arc, nb_alloc_sloop,
			sl_index, loop_index, surf_index, nb_curves,
			nb_maxvol, *maxvol, vol_index;

  IGRdouble		basis_tol, plane_space[12];

  long			nput, nret, stat;

  struct gr_arc		**graph;

  struct GRlc_info      **part_id, closed_cv, *curves;

  struct IGRbsp_curve	**int_curve, *comp_cv, *proj_cv, *cvgeom;

  struct GRid		*comp_id, OBJ, prj_comp, bnd[2], *bndsurf;

  IGRboolean		err_flag;

  struct SMsfinters	*SMsfinters;
  struct SMinters	*SMinters;
  struct SMsurf		*SMsurf;
  struct SMcurve	*SMcurve;
  struct SMExactInt	*IntPts;

  struct GRvg_construct tmp_cst;

  BSrc			rc;

  struct sl_arc		*sl_arc, *wrk_arc;
  struct loop_on_surf	*loop_on_surf, *loops;
  int			nb_vol;
  struct one_solid	*all_vol;
  struct IGRplane	const_pl, *plane;
  IGRushort	makecs_opt ;
  GRobjid		*comps;
  struct GRid	   TMP, active_id, top_lm_id;
  char			new_class[256];

  if(num_ent == 0 || act_env == NULL || lc_obj == NULL || inf_flag == NULL
     || cst == NULL || bnd_id == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Invalid Argument\n");
    return(0);
  }
  __enterFunction ( name = "SMCreatBndVol" );

  if(msg != NULL) *msg = MSSUCC;
  err_flag = FALSE;

  const_pl.point  = &plane_space[0];
  const_pl.normal = &plane_space[3];

  bnd_id->objid = NULL_OBJID;
  bnd_id->osnum = act_env->md_id.osnum;

  IntPts		= NULL;
  curves		= NULL;
  part_id		= NULL;
  cvgeom		= NULL;
  maxvol		= NULL;
  proj_cv		= NULL;
  comp_id		= NULL;
  comp_cv		= NULL;
  plane			= NULL;
  comps			= NULL;
  elem_type		= NULL;
  bndsurf		= NULL;
  nb_vol		= 0;
  all_vol		= NULL;
  sl_arc		= NULL;
  wrk_arc		= NULL;
  SMsfinters		= NULL;
  SMinters		= NULL;
  SMsurf		= NULL;
  SMcurve		= NULL;
  int_curve		= NULL;
  loops			= NULL;
  graph			= NULL;
  nb_SMsurf		= 0;
  nb_slarc		= 0;
  nb_alloc_arc		= 100;
  nb_alloc_sloop	= 10;
  nb_SMsfinters		= 0;
  nb_SMinters		= 0;
  nb_curves		= 0;
  vol_index		= -1;

  k = 0;
  loop_on_surf	 = NULL;
  prj_comp.objid = NULL_OBJID;
  OBJ.objid = NULL_OBJID;

  nput = sizeof(basis_tol);

  gr$get_basis_tolerance(msg    = msg,
			 sizbuf = &nput,
			 buffer = &basis_tol,
			 nret   = &nret);

  if(!((*msg)&1))
  {
    if (OM_Gf_verbose_warning) printf("error gr$get_basis_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }

  tmp_cst = (*cst);

  elem_type = _MALLOC( num_ent, int);
  if(elem_type == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR  bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  ex$message(msgnumb = SM_S_IntAlSf);

  stat = SMint_surfaces(msg, num_ent, lc_obj, &tmp_cst, inf_flag,
			&nb_SMsfinters, &SMsfinters, &SMcurve, elem_type);
  if(!(stat & (*msg) & 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR  SMint_surfaces\n");
    err_flag = TRUE;
    goto wrapup;
  }

  if(nb_SMsfinters == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR No surface Intersections\n");
    err_flag = TRUE;
    goto wrapup;
  }
  if(nb_SMsfinters == 1)
  {
    if (SMsfinters[0].cv_geom->phy_closed != TRUE)
    {
      if (OM_Gf_verbose_warning) printf("ERROR cannot construct a volume with open surfaces\n");
      err_flag = TRUE;
      goto wrapup;
    }

    for(i=0;i<2; i=i+1)
    {
      if(i == 0)	surf_index = SMsfinters[0].sf1;
      else		surf_index = SMsfinters[0].sf2;

      if(elem_type[surf_index] == COMP_SF)
      {
	stat = SMBndBool(msg, act_env, lc_obj,
			 inf_flag, cst, &bnd[i]);
	if(!(stat & (*msg) & 1))
	{
	  if (OM_Gf_verbose_warning) printf("ERROR SMBndBool\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	continue;
      }
      else
      {
	plane = NULL;
	if(SMsfinters[0].cvint_id.objid == NULL_OBJID)
	{
	  tmp_cst = (*cst);
	  tmp_cst.geometry = (char *)SMsfinters[0].cv_geom;

	  SMsfinters[0].cvint_id.osnum = tmp_cst.env_info->md_id.osnum;
	  stat = om$construct(msg = message GRgraphics.GRconstruct(&tmp_cst),
			      classid = OPP_GRbcsubbc_class_id,
			      p_objid = &(SMsfinters[0].cvint_id.objid),
			      osnum   =   SMsfinters[0].cvint_id.osnum);

	  as$status(sts=stat);
	  if (!(stat&1))
	  {
	    if (OM_Gf_verbose_warning) printf("GRbcsubbc.GRconstruct failed\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }

	}
	closed_cv.located_obj = SMsfinters[0].cvint_id;
      }

      tmp_cst = (*cst);
      closed_cv.module_info = *(cst->env_info);
      nb_curves = 1;
      curves = &closed_cv;

      stat = SMCreatBndSurf(msg, &closed_cv, SMsfinters[0].cv_geom,
			    nb_curves,
			    curves,
			    tmp_cst.env_info ,
			    &tmp_cst,
			    elem_type[surf_index],
			    &(lc_obj[surf_index]),
			    plane, &bnd[i]);
      if(!( stat & (*msg) &1 ))
      {
	if (OM_Gf_verbose_warning) printf("ERROR SMCreatBndSurf\n");
	err_flag = TRUE;
	goto wrapup;
      }
    }

    comps = _MALLOC(2, GRobjid);
    if(comps == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad dynamic allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<2;i++) comps[i] = bnd[i].objid;

    tmp_cst = (*cst);
    makecs_opt = NULL;

    stat = om$construct(msg  = message EMSsfstitch.EMmake_comp( msg,
								2,
								comps,
								act_env,
								NULL,
								NULL,
								0,
								NULL,
								makecs_opt),

			classid = OPP_EMSsfstitch_class_id,
			p_objid = &(bnd_id->objid),
			osnum   = bnd_id->osnum);

    as$status(sts=stat, action = RET_STATUS);
    if( !(stat & (*msg) & 1) )
    {
      if (OM_Gf_verbose_warning) printf("ERROR EMSsfstitch.EMmake_comp\n");
      err_flag = TRUE;
      goto wrapup;
    }
    goto wrapup;
  }

  stat = SMSortSfIntCvs( nb_SMsfinters, SMsfinters, &nb_SMsurf, &SMsurf);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMSortSfIntCvs\n");
    err_flag = TRUE;
    goto wrapup;
  }

  if(nb_SMsurf == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR No surface with Intersection curves on it\n");
    err_flag = TRUE;
    goto wrapup;
  }

  int_curve = _MALLOC(nb_SMsfinters, struct IGRbsp_curve *);
  if(int_curve == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<nb_SMsfinters;i=i+1) int_curve[i] = SMsfinters[i].cv_geom;

  ex$message(msgnumb = SM_S_IntAlCv);

  stat = SMint_curves(nb_SMsfinters, int_curve, ordered, &nb_SMinters, &SMinters);
  if(!(stat & (*msg) & 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMint_curves\n");
    err_flag = TRUE;
    goto wrapup;
  }

  if(nb_SMinters == 0)
  {
    for(i=0;i<nb_SMsfinters;i=i+1)
    {
      if(int_curve[i] == NULL) continue;
      if(int_curve[i]->phy_closed != TRUE)
      {
	if (OM_Gf_verbose_warning) printf("ERROR No curve Intersections\n");
	err_flag = TRUE;
	goto wrapup;
      }
    }
    if (OM_Gf_verbose_warning) printf("ERROR No curve Intersections\n");
    err_flag = TRUE;
    goto wrapup;

    /* create the bounded surfaces and stitch them to create the volume */

/** TO BE CONTINUED

    bndsurf = _MALLOC(nb_SMsurf, struct GRid);
    if(bndsurf == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad allocation \n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<nb_SMsurf;i++)
    {
      stat = SMCreatBndSurf(msg, &closed_cv, SMsfinters[0].cv_geom,
			    nb_curves,
			    curves,
			    tmp_cst.env_info ,
			    &tmp_cst,
			    elem_type[surf_index],
			    &(lc_obj[surf_index]),
			    plane, &bnd[i]);
      if(!( stat & (*msg) &1 ))
      {
	if (OM_Gf_verbose_warning) printf("ERROR SMCreatBndSurf\n");
	err_flag = TRUE;
	goto wrapup;
      }
    }

*****/

  }

  /* transform struct SMinters in a structure of curve */

  stat = SMSortCvIntpts(nb_SMsfinters,nb_SMinters, SMinters, SMcurve);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMSortCvIntpts\n");
    err_flag = TRUE;
    goto wrapup;
  }

  IntPts = NULL;
  IntPts = _MALLOC(nb_SMinters, struct SMExactInt);
  if(IntPts == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<nb_SMinters;i++)
    for(k=0;k<3;k++) IntPts[i].surf[k].geom = NULL;

  /* get the exact intersection points */

  stat = SMGetSfintpt( nb_SMinters, SMinters, SMsfinters, lc_obj, elem_type,
		       IntPts);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMGetSfintpt\n");
    err_flag = TRUE;
    goto wrapup;
  }
  stat = SMChgInters(nb_SMinters, SMinters, SMsfinters,IntPts);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMChgInters\n");
    err_flag = TRUE;
    goto wrapup;
  }

  ex$message(msgnumb = SM_S_CmpLpSf);

  sl_arc = _MALLOC(nb_alloc_arc, struct sl_arc);
  if(sl_arc == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }

  loop_on_surf = _MALLOC(nb_SMsurf, struct loop_on_surf);
  if(loop_on_surf == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<nb_SMsurf;i=i+1)
  {loop_on_surf[i].nb_loop = 0;loop_on_surf[i].one_loop = NULL;}

  loops = _MALLOC(nb_SMsurf, struct loop_on_surf);
  if(loops == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<nb_SMsurf;i=i+1)
  {loops[i].nb_loop = 0;loops[i].one_loop = NULL;}

  graph = _MALLOC(nb_SMsurf, struct gr_arc *);
  if(graph == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<nb_SMsurf;i=i+1) graph[i] = NULL;

  for(i=0;i<nb_SMsurf;i=i+1)
  {
    wrk_arc = NULL;
    graph[i] = NULL;

    nb_elt_in_graph = 0;

    stat = SMGraphDescr(SMsurf[i].nb_intcv, SMcurve,
			SMsurf[i].cv_index, SMinters, &nb_elt_in_graph,
			&graph[i]);
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMGraphDescr\n");
      err_flag = TRUE;
      goto wrapup;
    }
    if(nb_elt_in_graph == 0)
    {
      if (OM_Gf_verbose_warning) printf("ERROR no elts in graph\n");
      err_flag = TRUE;
      goto wrapup;
    }

    stat = SMGetLoopInGraph(nb_elt_in_graph,
			    graph[i],
			    SMinters,
			    &(loops[i].nb_loop),
			    &(loops[i].one_loop));
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMGetLoopInGraph\n");
      err_flag = TRUE;
      goto wrapup;
    }
    if(loops[i].nb_loop == 0) continue;
    loop_on_surf[i].nb_loop = loops[i].nb_loop;
    loop_on_surf[i].one_loop = _MALLOC(
				       loop_on_surf[i].nb_loop, struct one_loop);
    if(loop_on_surf[i].one_loop == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(k=0;k<loop_on_surf[i].nb_loop;k=k+1)
    {
      loop_on_surf[i].one_loop[k].nb_edge = 0;
      loop_on_surf[i].one_loop[k].edge = NULL;
    }

    for(k=0;k<loops[i].nb_loop;k=k+1)
    {
      numedge = loops[i].one_loop[k].nb_edge - 1; /* don't repeat last pt */
      wrk_arc = NULL;
      wrk_arc = _MALLOC(numedge, struct sl_arc);
      if(wrk_arc == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad allocation \n");
	err_flag = TRUE;
	goto wrapup;
      }
      loop_on_surf[i].one_loop[k].nb_edge = numedge;
      loop_on_surf[i].one_loop[k].edge = _MALLOC(
						 loop_on_surf[i].one_loop[k].nb_edge, int);
      if(loop_on_surf[i].one_loop[k].edge == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad allocation \n");
	err_flag = TRUE;
	goto wrapup;
      }
      stat = SMget_sl_arc(msg, loops[i].one_loop[k],
			  graph[i], wrk_arc);
      if(!(stat & (*msg) &1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR SMget_sl_arc\n");
	err_flag = TRUE;
	goto wrapup;
      }
      if(nb_alloc_arc <= numedge)
      {
	nb_alloc_arc = nb_alloc_arc + numedge + 1;
	sl_arc = _REALLOC(sl_arc,
			  nb_alloc_arc, struct sl_arc );
	if(sl_arc == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
      }

      for(l=0;l<numedge;l=l+1)
      {
	if(! SMIsEltInSlArc(&wrk_arc[l], nb_slarc, sl_arc,
			    SMinters, &sl_index) )
	{
	  loop_on_surf[i].one_loop[k].edge[l] = nb_slarc;
	  sl_arc[nb_slarc] = wrk_arc[l];
	  nb_slarc = nb_slarc + 1;
	}
	else loop_on_surf[i].one_loop[k].edge[l] = sl_index;
      }

      _FREE(wrk_arc);
    }
  }

  ex$message(msgnumb = SM_S_FndAlVol);

  stat = SMfind_all_vol(loop_on_surf,nb_SMsurf, nb_slarc,&all_vol,&nb_vol);
  if(!(stat &1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMfind_all_vol\n");
    err_flag = TRUE;
    goto wrapup;
  }

  /*print_sol(all_vol,nb_vol);*/

  if(nb_vol < 1)
  {
    if (OM_Gf_verbose_warning) printf("No volume defined\n");
    err_flag = TRUE;
    goto wrapup;
  }

  stat = SMGetMaxSfVol(nb_vol, all_vol, &nb_maxvol, &maxvol);
  if(!(stat &1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMGetMaxSfVol\n");
    err_flag = TRUE;
    goto wrapup;
  }

  /*** TO IMPLEMENT ===> USE TRACK POINT **************/

  if (vol_index == -1) vol_index = maxvol[0];

  ex$message(msgnumb = SM_S_CrBndSfVl);

  /* make each bounded surfaces to create the first solid */

  bndsurf = _MALLOC(all_vol[vol_index].nb_surf, struct GRid);
  if(bndsurf == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation \n");
    err_flag = TRUE;
    goto wrapup;
  }
  comp_id = _MALLOC(all_vol[vol_index].nb_surf, struct GRid);
  if(comp_id == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation \n");
    err_flag = TRUE;
    goto wrapup;
  }
  tmp_cst = (*cst);
  for(i=0;i< all_vol[vol_index].nb_surf; i=i+1)
  {
    comp_id[i].objid = NULL_OBJID;
    comp_id[i].osnum = tmp_cst.env_info->md_id.osnum;
  }
  part_id = NULL;
  part_id = _MALLOC(all_vol[vol_index].nb_surf, struct GRlc_info *);
  if(part_id == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<all_vol[vol_index].nb_surf;i++) part_id[i] = NULL;

  for(i=0;i< all_vol[vol_index].nb_surf; i=i+1)
  {
    cvgeom = NULL;
    tmp_cst = (*cst);

    loop_index = all_vol[vol_index].loop_index[i];
    surf_index = all_vol[vol_index].surf_index[i];

    /* APRES must be changed to not in RTREE
       comp_id[i].osnum = tmp_cst.env_info->md_id.osnum ;*/

    comp_id[i].objid = NULL_OBJID;
    comp_id[i].osnum = tmp_cst.env_info->md_id.osnum;
    comp_cv = NULL;

    stat = SMCrtPartCv(nb_SMsfinters,
		       int_curve,
		       nb_SMinters,
		       SMinters,
		       &loop_on_surf[surf_index].one_loop[loop_index],
		       sl_arc,
		       &tmp_cst,
		       &part_id[i],
		       NULL);
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMCrtPartCv\n");
      err_flag = TRUE;
      goto wrapup;
    }

    stat = SMCreatCompCv(
			 loop_on_surf[surf_index].one_loop[loop_index].nb_edge,
			 part_id[i],
			 &tmp_cst,
			 &comp_id[i],
			 &comp_cv);
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMCreatCompCv\n");
      err_flag = TRUE;
      goto wrapup;
    }
    cvgeom = comp_cv;
    if(elem_type[i] == COMP_SF)
    {

      ex$message(msgnumb = SM_S_CstPrjPl);
      stat = SMGetDummyPl(msg, 1, &comp_cv, ordered, &lc_obj[i], NULL,
			  elem_type[i], &const_pl);
      if(!(stat & (*msg) & 1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR SMGetDummyPl\n");
	err_flag = TRUE;
	goto wrapup;
      }
      plane = &const_pl;

      /* project comp_id on the plane */
      proj_cv = NULL;
      (void)BSalloccv(	comp_cv->order,
			comp_cv->num_poles,
			comp_cv->rational,
			comp_cv->num_boundaries,
			&proj_cv,
			&rc);
      if(rc != BSSUCC && rc!=BSNULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
	err_flag = TRUE;
	goto wrapup;
      }
      (IGRboolean)BSprj_cv_pl(&rc, comp_cv, &const_pl.point[0],
			      &const_pl.normal[0], const_pl.normal, proj_cv);
	if(rc!=BSSUCC)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR BSprj_cv_pl: no projection curve\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	tmp_cst = (*cst);
	tmp_cst.geometry = (char *)proj_cv;
	prj_comp.osnum = tmp_cst.env_info->md_id.osnum;
	prj_comp.objid = NULL_OBJID;

	stat = om$construct(msg = message GRgraphics.GRconstruct(
								 &tmp_cst),
			    classid = OPP_GRbcsubbc_class_id,
			    p_objid  = &(prj_comp.objid),
			    osnum  = prj_comp.osnum);

	as$status(sts=stat);
	if (!(stat&1))
	{
	  if (OM_Gf_verbose_warning) printf("GRcompcurve.GRconstruct failed\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	stat = om$send(	msg = message GRgraphics.GRdelete(msg,
							  tmp_cst.env_info),
			senderid = NULL_OBJID,
			targetid = comp_id[i].objid ,
			targetos = comp_id[i].osnum);
	comp_id[i] = prj_comp;
	cvgeom = proj_cv;
	_FREE(comp_cv);
    }
    else plane = NULL;

    closed_cv.module_info = *(tmp_cst.env_info);
    closed_cv.located_obj = comp_id[i];
    nb_curves = loop_on_surf[surf_index].one_loop[loop_index].nb_edge;
    curves = part_id[i];

    if(cvgeom != NULL && cvgeom->phy_closed != TRUE)
    {
      if (OM_Gf_verbose_warning) printf("ERROR, constructed curve is not closed\n");
      err_flag = TRUE;
      goto wrapup;
    }
    stat = SMCreatBndSurf(msg, &closed_cv, cvgeom, nb_curves, curves,
			  tmp_cst.env_info , &tmp_cst,
			  elem_type[i], &(lc_obj[i]),
			  plane, &bndsurf[i]);
    if(!( stat & (*msg) &1 ))
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMCreatBndSurf\n");
      err_flag = TRUE;
      goto wrapup;
    }
  }

  makecs_opt = NULL;
  comps = _MALLOC(all_vol[vol_index].nb_surf, GRobjid);
  if(comps == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad dynamic allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }

  for(i=0;i<all_vol[vol_index].nb_surf;i++) comps[i] = bndsurf[i].objid;

  tmp_cst = (*cst);

  stat = om$construct(msg  = message EMSsfstitch.EMmake_comp( msg,
							      all_vol[vol_index].nb_surf,
							      comps,
							      act_env,
							      NULL,
							      NULL,
							      0,
							      NULL,
							      makecs_opt),

		      classid = OPP_EMSsfstitch_class_id,
		      p_objid  = &(bnd_id->objid),
		      osnum  = bnd_id->osnum);

  as$status(sts=stat, action = RET_STATUS);
  if( !(stat & (*msg) & 1) )
  {
    if (OM_Gf_verbose_warning) printf("ERROR EMSsfstitch.EMmake_comp\n");
    err_flag = TRUE;
    goto wrapup;
  }

wrapup:

  UI_status("");
  stat = om$send(msg = message EMSsfdpr.EMgetsolidclass(msg, new_class),
		 senderid = NULL_OBJID,
		 targetid = bnd_id->objid,
		 targetos = bnd_id->osnum) ;
  as$status(sts=stat);
  if( !(stat & (*msg) & 1) )
  {
    if (OM_Gf_verbose_warning) printf("ERROR EMSsfdpr.EMgetsolidclass\n");
    err_flag = TRUE;
    goto wrapup;
  }

  stat = om$change_class(	 objid = bnd_id->objid,
				  osnum = bnd_id->osnum,
				  classname = new_class) ;
  if( !(stat & 1) )
  {
    if (OM_Gf_verbose_warning) printf("ERROR om$change_class\n");
    err_flag = TRUE;
    goto wrapup;
  }

  stat = om$send(msg = message EMSsolid.EMorient_yourself
		 (msg, NULL, act_env),
		 senderid = NULL_OBJID,
		 targetid = bnd_id->objid,
		 targetos = bnd_id->osnum) ;
  if( !(stat & (*msg) & 1) )
  {
    if (OM_Gf_verbose_warning) printf("ERROR EMSsolid.EMorient_yourself\n");
    err_flag = TRUE;
    goto wrapup;
  }
  stat = om$send(msg = message EMSsurface.EMgetactiveid(
							msg,
							&active_id,
							&top_lm_id ),
		 senderid = NULL_OBJID,
		 targetid = bnd_id->objid,
		 targetos = bnd_id->osnum);
  if(!(stat & *msg & 1))
  {
    if (OM_Gf_verbose_warning) printf("Warning getting the top dpr\n");
    active_id = *bnd_id;
  }

  stat = om$send(msg = message EMSdpr.EMmake_primitive1(
							msg,
							cst->env_info,
							&TMP ),
		 senderid = NULL_OBJID,
		 targetid = active_id.objid,
		 targetos = active_id.osnum);

  as$status(sts=stat);
  if(!(stat & *msg & 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR EMSdpr.EMmake_primitive1\n");
    err_flag = TRUE;
    goto wrapup;
  }

  bnd_id->objid = TMP.objid;

  if(part_id !=NULL)
  {
    for(i=0;i<all_vol[vol_index].nb_surf; i++)
    {
      if(om$is_objid_valid(osnum = part_id[i]->located_obj.osnum,
			   objid = part_id[i]->located_obj.objid) & 1)
      {
	stat = om$send(	msg = message GRgraphics.GRdelete(msg,
							  cst->env_info),
			senderid = NULL_OBJID,
			targetid = part_id[i]->located_obj.objid ,
			targetos = part_id[i]->located_obj.osnum);
	as$status(sts=stat);
	part_id[i]->located_obj.objid = NULL_OBJID;
      }
      _FREE(part_id[i]);
    }
    _FREE(part_id);
  }

  if(comp_id != NULL)
  {
    for(i=0;i<all_vol[vol_index].nb_surf;i++)
    {
      if(om$is_objid_valid(osnum = comp_id[i].osnum,
			   objid = comp_id[i].objid) & 1)
      {
	om$send(	msg = message GRgraphics.GRdelete(msg, cst->env_info),
			senderid = NULL_OBJID,
			targetid = comp_id[i].objid ,
			targetos = comp_id[i].osnum);
	comp_id[i].objid = NULL_OBJID;
      }
    }
    _FREE(comp_id);
  }
  if(om$is_objid_valid(osnum = prj_comp.osnum,
		       objid = prj_comp.objid) & 1)
  {
    om$send(msg = message GRgraphics.GRdelete(msg, cst->env_info),
	    senderid = NULL_OBJID,
	    targetid = prj_comp.objid ,
	    targetos = prj_comp.osnum);
    prj_comp.objid = NULL_OBJID;
  }
  _FREE(maxvol);
  _FREE(comp_cv);
  _FREE(proj_cv);
  _FREE(elem_type);
  _FREE(comps);
  _FREE(bndsurf);
  _FREE(sl_arc);
  _FREE(wrk_arc);
  SMfree_all_vol(all_vol,nb_vol);
  if(SMsurf != NULL)
  {
    for(i=0;i<nb_SMsurf;i=i+1)
      _FREE(SMsurf[i].cv_index);
    _FREE(SMsurf);
  }
  if(SMcurve != NULL)
  {
    for(i=0;i<nb_SMsfinters;i=i+1)
      _FREE(SMcurve[i].pt_index);
    _FREE(SMcurve);
  }

  _FREE(SMinters);
  if(SMsfinters!= NULL)
  {
    for(i=0;i<nb_SMsfinters;i=i+1)
    {
      /* don't delete input curve */

      if(SMsfinters[i].sf1 == -1 || SMsfinters[i].sf2 == -1) continue;
      if(om$is_objid_valid(osnum = SMsfinters[i].cvint_id.osnum,
			   objid = SMsfinters[i].cvint_id.objid) & 1)
      {

	om$send(	msg = message GRgraphics.GRdelete(
							  msg, cst->env_info),
			senderid = NULL_OBJID,
			targetid =SMsfinters[i].cvint_id.objid ,
			targetos = SMsfinters[i].cvint_id.osnum);
	SMsfinters[i].cvint_id.objid = NULL_OBJID;
      }
      if(SMsfinters[i].cv_geom != NULL)
      {
	if(SMsfinters[i].alloc_flag == TRUE)
	  (IGRboolean)BSfreecv(&rc, SMsfinters[i].cv_geom);
	else _FREE(SMsfinters[i].cv_geom);
	SMsfinters[i].cv_geom = NULL;
      }
    }
    _FREE(SMsfinters);
  }
  if(loop_on_surf != NULL)
  {
    for(i=0;i<nb_SMsurf;i=i+1)
    {
      if(loop_on_surf[i].one_loop != NULL)
	for(k=0;k<loop_on_surf[i].nb_loop;k=k+1)
	  _FREE(loop_on_surf[i].one_loop[k].edge);
    }
    _FREE(loop_on_surf);
  }
  if(loops != NULL)
  {
    for(i=0;i<nb_SMsurf;i=i+1)
    {
      if(loops[i].one_loop != NULL)
	for(k=0;k<loops[i].nb_loop;k=k+1)
	  _FREE(loops[i].one_loop[k].edge);
    }
    _FREE(loops);
  }

  if(graph != NULL)
  {
    for(i=0;i<nb_SMsurf;i=i+1)_FREE(graph[i]);
    _FREE(graph);
  }

  _FREE(int_curve);
  if(err_flag == TRUE)
  {
    if(bnd_id->objid != NULL_OBJID)
    {
      om$send(msg      = message GRgraphics.GRdelete(msg,act_env),
	      senderid = NULL_OBJID,
	      targetid = bnd_id->objid,
	      targetos = bnd_id->osnum );
      bnd_id->objid = NULL_OBJID;
    }
    __exit_error_Function ( name = "SMCreatBndVol" );
    return(0);
  }
  else
  {
    __exitFunction ( name = "SMCreatBndVol" );
    return(1);
  }
}

/*14 ====================== SMGetDummyPl ==========================

	Function that return a plane to approximate a surface,
	if given nb_cv on the surfaces.
	Algo:

	Compute the barycenter of the intersection points of the curves,
	in order to have a point in the area we want to extract,
	the plane taken will be the tangent plane
	to the support at this point.

	return(1) if ok.
	else return(0).

*/

int	SMGetDummyPl(msg, nb_curves, curves, ordered, surf, sf_range, surf_type, plane)
long			*msg;	     /* (O) completion code */
int			nb_curves;   /* (I) nb input curves */
struct IGRbsp_curve	**curves;    /* (I) input curves */
int			ordered;     /* (I) 1 for ordered surface input */
struct GRlc_info	*surf;       /* (I) input surface */
IGRdouble		*sf_range;   /* (I) range of surface (can be NULL) */
int			surf_type;   /* (I) surf_type */
struct IGRplane		*plane;      /* (O) output plane */

/*.SMGetDummyPl*/
{
  int			i,k,stat, nb_ptinters;
  IGRboolean		planar, world, err_flag, defined, coplanar;
  IGRdouble		test_pt[3], range[6], fact, norm[3], plnorm[3],
			baryctr[3], pt[9];
  struct SMinters	*ptinters;
  BSrc			rc;

  ptinters		= NULL;

  if(nb_curves == 0 || curves == NULL || surf == NULL || plane == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid Argument\n");
    return(0);
  }
  if(msg != NULL) *msg = MSSUCC;
  err_flag = FALSE;

  defined = FALSE;

  if(nb_curves == 1)
  {
    (void)BStst_plan(curves[0]->num_poles, curves[0]->poles,
		     curves[0]->weights, &planar, plane->normal, &rc);

    if(rc != BSSUCC)
    {
      if (OM_Gf_verbose_warning) printf("ERROR BStst_plan\n");
      err_flag = TRUE;
      goto wrapup;
    }
    if(planar == TRUE)
    {
      for(i=0;i<3;i++) plane->point[i] = curves[0]->poles[i];
      defined = TRUE;
    }
    else
    {
      (IGRboolean)BSavgpts(&rc, curves[0]->num_poles, curves[0]->poles,
			   curves[0]->weights, baryctr);
    }
  }
  else
  {
    nb_ptinters = 0;

    /* test if the curves are coplanar */

    planar = TRUE;

    for(i=0;i<nb_curves;i++)
      if(curves[i]->planar == FALSE){planar = FALSE; break;}

    if(planar == TRUE)
    {
      coplanar = TRUE;
      for(i=0;i<3;i++) pt[i] = 0.;
      for(i=0;i<nb_curves - 1;i=i+2)
      {
	planar = FALSE;
	planar = (IGRboolean)BScvcoplan(&rc, curves[i],	curves[i+1], norm);
	if(rc != BSSUCC)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR BScvcoplan\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	if(planar == FALSE)
	{coplanar = FALSE;break;}
	for(i=0;i<3;i++) pt[3+i] = norm[i];

	if(i == 0)
	{
	  for(i=0;i<3;i++)
	  {
	    plnorm[i] = norm[i];
	    pt[6+i] = plnorm[i];
	  }
	}
	else
	{
	  stat = (IGRboolean)BScollin(&rc, &pt[0], &pt[3], &pt[6]);
	  if(rc != BSSUCC)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR BScvcoplan\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }
	  if(stat == FALSE)
	  {coplanar = FALSE;break;}
	}
	if(coplanar == TRUE)
	{
	  for(i=0;i<3;i++)
	  {
	    plane->point[i] = curves[0]->poles[i];
	    plane->normal[i] = plnorm[i];
	  }
	  defined = TRUE;
	}
      }
    }
    if(defined == FALSE)
    {
      stat = SMint_curves(nb_curves, curves, ordered, &nb_ptinters, &ptinters);
      if(!(stat & (*msg) & 1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR SMint_curves\n");
	err_flag = TRUE;
	goto wrapup;
      }
      for(k=0;k<3;k=k+1) baryctr[k] = 0.;
      for(k=0;k<3;k=k+1)
      {
	for(i=0;i<nb_ptinters; i=i+1)
	  baryctr[k] = baryctr[k] + ptinters[i].pt[k];
      }
      if(nb_ptinters == 0)
	for(k=0;k<3;k=k+1) baryctr[k] = curves[0]->poles[k];
      else
	for(k=0;k<3;k=k+1) baryctr[k] = baryctr[k]/nb_ptinters;
    }
  }

  if(defined == FALSE)
  {
    stat = VDget_tangent_plane(surf_type, &surf->located_obj,
			       NULL, &surf->module_info, baryctr, plane);
    if (stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR fct VDget_tangent_plane\n");
      err_flag = TRUE;
      goto wrapup;
    }
  }

  /* we must mv the plan totaly above or below the support */
  if(sf_range == NULL)
  {
    world = TRUE;
    stat = om$send( msg = message GRgraphics.GRgetrang(msg,
						       &surf->module_info.md_env.matrix_type,
						       surf->module_info.md_env.matrix,
						       &world, range),
		    senderid = NULL_OBJID,
		    targetid = surf->located_obj.objid,
		    targetos = surf->located_obj.osnum );

    as$status(sts=stat);
    if (!((*msg)&stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRgetrang\n" );
      err_flag = TRUE;
      goto wrapup;
    }
  }
  else
    for(i=0;i<6;i++) range[i] = sf_range[i];

  fact = 1.1 ;
  test_pt[0] = plane->point[0] - fact *plane->normal[0];
  test_pt[1] = plane->point[1] - fact *plane->normal[1];
  test_pt[2] = plane->point[2] - fact *plane->normal[2];

  while( test_pt[0] > range[0] && test_pt[1] > range[1] &&
	 test_pt[2] > range[2] && test_pt[0] < range[3] &&
	 test_pt[1] < range[4] && test_pt[2] < range[5])
  {

    fact = 2*fact;
    test_pt[0] = test_pt[0] - fact *plane->normal[0];
    test_pt[1] = test_pt[1] - fact *plane->normal[1];
    test_pt[2] = test_pt[2] - fact *plane->normal[2];
  }

  plane->point[0] = test_pt[0];
  plane->point[1] = test_pt[1];
  plane->point[2] = test_pt[2];

wrapup:

  _FREE(ptinters);

  if(err_flag == TRUE) return(0);
  else return(1);

}

/*15 ====================== SMImpBndSf ==========================

	Function that impose the input curves on the given
	surface to make a bounded surface.
	The comp_id is the composite curve made with the input curves
	(approximate composite to find the point in area).

	return(1) if ok.
	else return(0).

*/

int	SMImpBndSf(msg, comp_id, comp_geom, nb_curves, curves_id,
			surf_id, surf_geom, cst)
long			*msg;	       /* (O) completion code */
struct GRlc_info	*comp_id;      /* (I) composite curve */
struct IGRbsp_curve     *comp_geom;    /* (I) composite geom (can be NULL) */
int			nb_curves;     /* (I) nb of input curves */
struct GRlc_info	*curves_id;    /* (I) input curve */
struct GRlc_info	*surf_id;      /* (I/O) input surface output bounded*/
struct IGRbsp_surface   *surf_geom;    /* (I) surf geom (can be NULL) */
struct GRvg_construct   *cst;	       /* (I) construction list */

/*.SMImpBndSf*/
{
  int			stat;
  IGRlong		number_of_points,number_of_bad_curves,
			bad_curve_indices[50];
  struct GRid		obj, impbnd;
  IGRboolean		onsurf,err_flag;
  IGRdouble		water_mark, area_pt[2];

  IGRpoint		*points;

  IGRushort		map_options, imp_options;
  struct GRid	   TMP1, active_id, top_lm_id;

  points	 = NULL;

  if(comp_id == NULL || nb_curves == 0 || curves_id == NULL || surf_id == NULL
      || cst == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid Argument\n");
    return(0);
  }

  __enterFunction ( name = "SMImpBndSf" );

  if(msg != NULL) *msg = MSSUCC;

  err_flag = FALSE;

  impbnd.osnum = surf_id->located_obj.osnum;

  stat = om$send(msg = message GRgraphics.GRcopy(msg,
						 &surf_id->module_info,
						 &surf_id->module_info,
						 &(impbnd.objid)),
		 senderid = NULL_OBJID,
		 targetid = surf_id->located_obj.objid,
		 targetos = surf_id->located_obj.osnum);
  as$status(sts=stat);
  if (!((*msg)&stat&1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRcopy \n");
    err_flag = TRUE;
    goto wrapup;
  }

  stat = om$send (msg = message EMSsurface.EMputLsIfNotThere
		  (	msg,
			&cst->env_info->md_env,
			NULL,
			NULL,
			0,
			NULL),
		  senderid = NULL_OBJID,
		  targetid = impbnd.objid,
		  targetos = impbnd.osnum);
  as$status(sts=stat);
  if(!(stat & (*msg) & 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR EMSsurface.EMputLsIfNotThere\n");
    err_flag = TRUE;
    goto wrapup;
  }

  stat = SMGetPtInArea(msg, comp_id, comp_geom, surf_id, surf_geom,
		       NULL, NULL,&area_pt[0], &area_pt[1], &onsurf);
  if (!((*msg)&stat&1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMGetPtInArea\n");
    err_flag = TRUE;
    goto wrapup;
  }

  map_options = EMMapBnd_WantStatMsg | EMMapBnd_WantBadCurves |
    EMMapBnd_StrokeIfNeeded;

  imp_options = EMImpBnd_WantStatMsg;

  number_of_points = 0;
  number_of_bad_curves = 0;
  points = NULL;

  ex$message(msgnumb = SM_S_ImpBndSf);

  obj.objid = NULL_OBJID;
  obj.osnum = impbnd.osnum;

  stat = om$send(msg = message EMSsurface.EMimpose_boundaries(
							      msg,
							      nb_curves,
							      NULL,
							      curves_id,
							      area_pt,
							      onsurf,
							      cst->env_info,
							      &number_of_points,
							      &points,
							      &number_of_bad_curves,
							      bad_curve_indices,
							      NULL,
							      NULL,
							      NULL,
							      NULL,
							      map_options,
							      imp_options,
							      /*&obj.objid*/NULL),
		 senderid = NULL_OBJID,
		 targetid = impbnd.objid,
		 targetos = impbnd.osnum);
  as$status (sts= stat);
  if (!(stat&1) || (*msg) == EMS_I_NoMoreLoops)
  {
    /*	  (void)EFmsgReport(0,(*msg) ,"return msg EMimpose_bnd");*/
    if (OM_Gf_verbose_warning) printf("ERROR EMSsurface.EMimpose_boundaries\n");
    err_flag = TRUE;
    goto wrapup;
  }

  stat = om$send(msg = message EMSsurface.EMgetactiveid(
							msg,
							&active_id,
							&top_lm_id ),
		 senderid = NULL_OBJID,
		 targetid = impbnd.objid,
		 targetos = impbnd.osnum);
  if(!(stat & *msg & 1))
  {
    if (OM_Gf_verbose_warning) printf("Warning getting the top dpr\n");
    active_id = impbnd;
  }

  stat = om$send(msg = message EMSdpr.EMmake_primitive1(
							msg,
							cst->env_info,
							&TMP1 ),
		 senderid = NULL_OBJID,
		 targetid = active_id.objid,
		 targetos = active_id.osnum);

  as$status(sts=stat);
  water_mark	= 0;

  stat = om$send(msg = message EMSsubbs.EMreduce_range(msg,
						       cst->env_info,
						       &TMP1.objid,
						       water_mark),
		 senderid = NULL_OBJID,
		 targetid = TMP1.objid,
		 targetos = TMP1.osnum);

  if (!((*msg)&stat&1))
    if (OM_Gf_verbose_warning) printf("Warning range not reduced \n");

  surf_id->located_obj.objid = TMP1.objid;

wrapup:
  UI_status("");
  _FREE(points);

  if(err_flag == TRUE)
  {
    __exit_error_Function ( name = "SMImpBndSf" );
    return(0);
  }
  else
  {
    __exitFunction ( name = "SMImpBndSf" );
    return(1);
  }
}

/*16 ====================== SMGetPtInArea ==========================

	Function that return a point on a surface and indicate
	if that point is inside the area of the closed input curve.
	(For impose bnd)

	return(1) if ok.
	else return(0).

*/

int	SMGetPtInArea(msg, curve_id, curve_geom, surf_id, surf_geom,
		cht, point,upar, vpar, in_area)
long			*msg;	/* (O) completion code */
struct GRlc_info	*curve_id;      /* (I) input curve */
struct IGRbsp_curve	*curve_geom;	/* (I) curve geom (can be NULL) */
struct GRlc_info	*surf_id;       /* (I) input surface */
struct IGRbsp_surface   *surf_geom;	/* (I) surf geom (can be NULL) */
IGRdouble		*cht;		/* (I) cht (NULL if not known) */
IGRdouble		*point;		/* (O) output point */
IGRdouble		*upar;		/* (O) param u of point on surf */
IGRdouble		*vpar;		/* (O) param v of point on surf */
IGRboolean		*in_area;	/* (O) TRUE if point is inside curve */
/*.SMGetPtInArea*/
{
  int			i,stat, n_int0;
  IGRboolean		onsurf,tst_plan, err_flag;
  long			nput, size, nret;
  struct IGRbsp_curve	*part_line, *line, *comp_cv;
  struct IGRbsp_surface *bspsf;
  IGRdouble		value[2], parr1, par, d_par,*p_par10,*p_par20, tol,
			dist1,cht_tol,basis_tol, base[3], center[3];
  IGRshort		opt, order;
  IGRpoint		*int_pts0,*int_pts1;
  BSrc			rc;

  p_par10  = NULL;
  p_par20  = NULL;
  int_pts0 = NULL;
  int_pts1 = NULL;
  part_line	= NULL;
  line = NULL;
  comp_cv= NULL;
  bspsf = NULL;
  tol = 0.;

  if(msg != NULL) *msg = MSSUCC;
  err_flag = FALSE;

  nput = sizeof(basis_tol);

  gr$get_basis_tolerance(	msg    = msg,
				sizbuf = &nput,
				buffer = &basis_tol,
				nret   = &nret);

  if(!((*msg)&1))
  {
    if (OM_Gf_verbose_warning) printf("error gr$get_basis_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }

  if(cht == NULL)
  {
    nput = sizeof(cht_tol);

    gr$get_chord_height_tolerance(	msg    = msg,
					sizbuf = &nput,
					buffer = &cht_tol,
					nret   = &nret);

    if(!((*msg)&1))
    {
      if (OM_Gf_verbose_warning) printf("error gr$get_chord_height_tolerance\n");
      err_flag = TRUE;
      goto wrapup;
    }
  }
  else cht_tol = *cht;

  /* change basis_tol because composite curve is made with 2*cht_tol */
  /*
    tol = cht_tol;
    nput = sizeof(tol);

    gr$put_basis_tolerance
    (msg    = msg,
    sizbuf = &nput,
    buffer = &tol);

    if(!((*msg)&1))
    {
    if (OM_Gf_verbose_warning) printf("error gr$put_basis_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
    }
    */
  /* we must always keep cht = 1000 basis */

  tol = 1000*tol;
  nput = sizeof(tol);
/*
  gr$put_chord_height_tolerance
    (msg    = msg,
     sizbuf = &nput,
     buffer = &tol);

  if(!((*msg)&1))
  {
    if (OM_Gf_verbose_warning) printf("error gr$put_chord_height_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }

*/
  /* line is the isocurve (v constant) from the center */

  if(curve_geom == NULL)
  {
    size = 0;
    stat = om$send(msg = message GRvg.GRgetsize(msg,
						&curve_id->module_info.md_env.matrix_type,
						curve_id->module_info.md_env.matrix,
						&size ),
		   senderid = NULL_OBJID,
		   targetid = curve_id->located_obj.objid,
		   targetos = curve_id->located_obj.osnum );
    as$status(sts = stat);
    if (!((*msg) & stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetsize\n");
      err_flag = TRUE;
      goto wrapup;
    }
    comp_cv = NULL;
    comp_cv = (struct IGRbsp_curve *)_MALLOC(size, char);
    if(comp_cv == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
      err_flag = TRUE;
      goto wrapup;
    }
    stat = om$send(msg = message GRvg.GRgetgeom(msg,
						&curve_id->module_info.md_env.matrix_type,
						curve_id->module_info.md_env.matrix,
						(char *) comp_cv),
		   senderid = NULL_OBJID,
		   targetid = curve_id->located_obj.objid,
		   targetos = curve_id->located_obj.osnum );
    as$status(sts = stat);
    if (!((*msg)&stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR  GRvg.GRgetgeom\n");
      err_flag = TRUE;
      goto wrapup;
    }
  }
  else comp_cv = curve_geom;
  nput = sizeof(basis_tol);
/*
  gr$put_basis_tolerance
    (msg    = msg,
     sizbuf = &nput,
     buffer = &basis_tol);

  if(!((*msg)&1)) if (OM_Gf_verbose_warning) printf("error gr$put_basis_tolerance\n");

  nput = sizeof(cht_tol);

  gr$put_chord_height_tolerance
    (msg    = msg,
     sizbuf = &nput,
     buffer = &cht_tol);

  if(!((*msg)&1)) if (OM_Gf_verbose_warning) printf("error gr$put_chord_height_tolerance\n");
*/
  if(surf_geom == NULL)
  {
    stat = om$send(msg = message GRvg.GRgetsize(msg,
						&surf_id->module_info.md_env.matrix_type,
						surf_id->module_info.md_env.matrix,
						&size ),
		   senderid = NULL_OBJID,
		   targetid = surf_id->located_obj.objid,
		   targetos = surf_id->located_obj.osnum );
    as$status(sts = stat);
    if (!((*msg)&stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetsize\n");
      err_flag = TRUE;
      goto wrapup;
    }
    bspsf = NULL;
    bspsf = (struct IGRbsp_surface *)_MALLOC(size, char);
    if(bspsf == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
      err_flag = TRUE;
      goto wrapup;
    }
    stat = om$send(msg = message GRvg.GRgetgeom(msg,
						&surf_id->module_info.md_env.matrix_type,
						surf_id->module_info.md_env.matrix,
						(char *) bspsf),
		   senderid = NULL_OBJID,
		   targetid = surf_id->located_obj.objid,
		   targetos = surf_id->located_obj.osnum );
    as$status(sts = stat);
    if (!((*msg)&stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR  GRvg.GRgetgeom\n");
      err_flag = TRUE;
      goto wrapup;
    }
  }
  else bspsf = surf_geom;

  (IGRboolean)BSavgpts(&rc, comp_cv->num_poles, comp_cv->poles, comp_cv->weights, center);

  (IGRboolean)BSmdistptsf(&rc, bspsf, center, &value[0], &value[1], center,
			  &dist1);
  if(rc != BSSUCC )
  {
    if (OM_Gf_verbose_warning) printf("ERROR BSmdistptsf\n");
    err_flag = TRUE;
    goto wrapup;
  }

  line = NULL;
  opt = 2;

  (void)BSalloccv(bspsf->u_order, bspsf->u_num_poles,
		  bspsf->rational, 0,  &line, &rc);
  if(rc != BSSUCC && rc!=BSNULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
    err_flag = TRUE;
    goto wrapup;
  }
  /* extract the constant param curve (v constant )from bspsf */

  (IGRboolean)BSconstprcv(&rc,bspsf,&opt,&value[1],&tst_plan,line);
  if(rc != BSSUCC)
  {
    if (OM_Gf_verbose_warning) printf("ERROR  BSconstprcv: %d\n",rc);
    err_flag = TRUE;
    goto wrapup;
  }

  /* take part of line from center */

  part_line = NULL;
  order = line->order;
  (void) BSalloccv(order, line->num_poles + 2 * order - 1, line->rational,
	    line->num_boundaries,
	    &part_line, &rc);
  if(rc != BSSUCC && rc!=BSNULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation\n ");
    err_flag = TRUE;
    goto wrapup;
  }
  (void) BSmdstptcv(line, center, &parr1, base, &dist1, &rc);
  if(rc != BSSUCC )
  {
    if (OM_Gf_verbose_warning) printf("ERROR BSmdstptcv\n");
    err_flag = TRUE;
    goto wrapup;
  }
  par = 1;
  d_par = (parr1 + par)/2.;
  (IGRboolean)BSpartofcv(&rc, line, parr1, d_par, par, part_line);
  if(rc != BSSUCC)
  {
    if (OM_Gf_verbose_warning) printf("surf_int, Bad BSpartofcv\n");
    err_flag = TRUE;
    goto wrapup;
  }

  (void)BSmdistcvcv(part_line,comp_cv, &n_int0, &p_par10, &p_par20 , &int_pts0,
	      &int_pts1, &dist1, &rc);

  if(rc != BSSUCC )
  {
    if (OM_Gf_verbose_warning) printf(" ERROR in BSmdistcvcv\n");
    err_flag = TRUE;
    goto wrapup;
  }

  tol = 2*cht_tol;
  if(dist1 > tol) n_int0 = 0;
  if(n_int0 % 2 == 0) onsurf = FALSE;
  else		 onsurf = TRUE;

  if(point != NULL)
  {
    for(i=0;i<3;i++) point[i] = center[i];
  }
  if(upar != NULL) *upar = value[0];
  if(vpar != NULL) *vpar = value[1];
  if(in_area ! = NULL) *in_area = onsurf;

wrapup:

  nput = sizeof(basis_tol);
/*
  gr$put_basis_tolerance
    (msg    = msg,
     sizbuf = &nput,
     buffer = &basis_tol);

  if(!((*msg)&1)) if (OM_Gf_verbose_warning) printf("error gr$put_basis_tolerance\n");

  nput = sizeof(cht_tol);

  gr$put_chord_height_tolerance
    (msg    = msg,
     sizbuf = &nput,
     buffer = &cht_tol);

  if(!((*msg)&1)) if (OM_Gf_verbose_warning) printf("error gr$put_chord_height_tolerance\n");
*/

  _FREE(p_par10);
  _FREE(p_par20);
  _FREE(int_pts0);
  _FREE(int_pts1);
  if(part_line != NULL) {(IGRboolean)BSfreecv(&rc, part_line)   ;part_line    = NULL;}
  if(line      != NULL) {(IGRboolean)BSfreecv(&rc, line)     ;line       = NULL;}

  if(comp_cv != NULL && curve_geom == NULL) _FREE( comp_cv) ;
  if(bspsf != NULL && surf_geom == NULL) _FREE( bspsf) ;

  if(err_flag == TRUE) return(0);
  else return(1);

}

/*17 ======================  SMGetSfNotInLoop ======================

	Function that return, for the given loop, the surfaces
	(or input curves) that are not taken into account.
	surfs are allocated by the function and must be deallocated
	by the user.

	return(1) if ok.
	else return(0).

*/

int	SMGetSfNotInLoop(msg, loop, sl_arc, SMsfinters, nb_surf,
			nb_sfloop, sfloop)
long			*msg;		/* (O) completion code */
struct one_loop		*loop;		/* (I) input loop (=sl_arc index) */
struct sl_arc		*sl_arc;	/* (I) sl_arc definition */
struct SMsfinters	*SMsfinters;	/* (I) surf intersection def */
int			nb_surf;	/* (I) nb surf or input curve */
int			*nb_sfloop;	/* (O) nb of returned surface index */
int			**sfloop;	/* (O) returned surface index*/
/*.SMGetSfNotInLoop*/
{
  int		i,k, stat;
  int		nb_tmp, *ind_tmp, nb_curve, *curve_index, nbsf, *surfindex;
  IGRboolean	err_flag, found;

  ind_tmp = NULL;
  curve_index = NULL;
  surfindex = NULL;
  nb_tmp = 0;

  if(loop == NULL || sl_arc == NULL || nb_surf == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }

  if(msg != NULL) *msg = MSSUCC;
  err_flag = FALSE;

  if(sfloop != NULL) *sfloop = NULL;

  ind_tmp = _MALLOC(nb_surf, int);
  if(ind_tmp == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }

  /* get all curves index in the loop */

  nb_curve = 0;
  stat = SMGetNbCurves(loop, sl_arc, &nb_curve, &curve_index);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMGetNbCurves\n");
    err_flag = TRUE;
    goto wrapup;
  }
  /* get all surfaces index from these curves */

  nbsf = 0;
  stat = SMGetNbSurfs(nb_curve, curve_index, SMsfinters, &nbsf, &surfindex);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMGetNbSurfs\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<nb_surf;i++)
  {
    found = FALSE;
    for(k=0;k<nbsf;k++)
      if(i == surfindex[k] || i == -surfindex[k])

      {found = TRUE; break;}

    if(found == FALSE)
    {
      ind_tmp[nb_tmp] = i;
      nb_tmp ++;
    }
  }

  if(nb_sfloop != NULL) *nb_sfloop = nb_tmp;

  if(sfloop != NULL && nb_tmp != 0)
  {
    *sfloop = _MALLOC(nb_tmp, int);
    if(*sfloop == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<nb_tmp;i++) (*sfloop)[i] = ind_tmp[i];
  }

wrapup:
  _FREE(surfindex);
  _FREE(curve_index);
  _FREE(ind_tmp);
  if(err_flag == TRUE)
  {
    if(sfloop!= NULL && (*sfloop) != NULL)_FREE(*sfloop);
    return(0);
  }
  else return(1);

}

/*18 ======================  SMBndBool ======================

	Function that create the bounded surface in the
	particular case of only 2 surfaces and the support
	composite.
	It makes a boolean difference between the 2 surfaces.

	return(1) if ok.
	else return(0).

*/

int	SMBndBool(msg, act_env, lc_obj, inf_flag, cst, bnd_id)
long			*msg;	    /* (O) completion code */
struct GRmd_env		*act_env;   /* (I) act mod env */
struct GRlc_info	*lc_obj;    /* (I) input surfaces (2) */
char			*inf_flag;  /* (I) infinite flag (extend plane)*/
struct GRvg_construct   *cst;	    /* (I) construction list */
struct	GRid		*bnd_id;    /* (O) constructed bounded surface */
/*.SMBndBool*/
{
  IGRint		i,k,stat, type;
  IGRdouble		dist, range[6], fact, plane_space[6], vec1[3],
			vec2[3],  center[3];
  IGRpoint		pt[3];
  IGRboolean		planar, world, err_flag;
  IGRushort		option;
  struct GRid		cp_obj[2];
  GRclassid		sfid_class;
  BSrc			rc;
  struct IGRplane	plane;
  IGRuchar		props;
  struct GRid	   active_id, top_lm_id;

  plane.point  = &plane_space[0];
  plane.normal = &plane_space[3];

  if(act_env == NULL || lc_obj == NULL || inf_flag == NULL
     || cst == NULL || bnd_id == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Invalid Argument\n");
    return(0);
  }
  __enterFunction ( name = "SMBndBool" );

  if(msg != NULL) *msg = MSSUCC;

  err_flag = FALSE;

  planar = FALSE;
  bnd_id->objid = NULL_OBJID;
  bnd_id->osnum = act_env->md_id.osnum;

  cst->env_info = act_env; /* in RTREE */

  if(inf_flag[1] == 'y')
  {
    stat = om$get_classid (objid = lc_obj[1].located_obj.objid,
			   osnum = lc_obj[1].located_obj.osnum,
			   p_classid = &sfid_class);
    stat = om$is_ancestry_valid (subclassid = sfid_class,
				 superclassid = OPP_EMSplane_class_id);
    if (stat == OM_S_SUCCESS) planar = TRUE;
  }

  for(i=0;i<2;i++)
  {
    cp_obj[i].osnum = lc_obj[i].located_obj.osnum;

    if(i == 1 && planar == TRUE)
    {
      /* extend plane to support range */

      world = TRUE;
      stat = om$send( msg = message GRgraphics.GRgetrang(msg,
							 &lc_obj[0].module_info.md_env.matrix_type,
							 lc_obj[0].module_info.md_env.matrix,
							 &world, range),
		      senderid = NULL_OBJID,
		      targetid = lc_obj[0].located_obj.objid,
		      targetos = lc_obj[0].located_obj.osnum );

      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRgetrang\n" );
	err_flag = TRUE;
	goto wrapup;
      }
      stat = om$send (msg = message GRvg.GRdetplane(msg,
						    &lc_obj[1].module_info.md_env.matrix_type,
						    lc_obj[1].module_info.md_env.matrix,
						    &plane),
		      senderid = NULL_OBJID,
		      targetid = lc_obj[1].located_obj.objid,
		      targetos = lc_obj[1].located_obj.osnum );
      as$status(sts = stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in  GRvg.GRdetplane\n");
	err_flag = TRUE;
	goto wrapup;
      }

      (void)BSorthovec( &rc, plane.normal, vec1 );
      if(rc != BSSUCC)
      {
	if (OM_Gf_verbose_warning) printf("ERROR BStagsort\n");
	err_flag = TRUE;
	goto wrapup;
      }

      (void)BScrossp( &rc, plane.normal, vec1, vec2 );
      if(rc != BSSUCC)
      {
	if (OM_Gf_verbose_warning) printf("ERROR BStagsort\n");
	err_flag = TRUE;
	goto wrapup;
      }

      for(k=0;k<3;k++)
	center[k] = (range[k] + range[k+3])/2.;

	dist = 2 * (IGRdouble)BSdistptpt(&rc, center, plane.point);

      fact =	dist + 2 * (IGRdouble)BSdistptpt(&rc, range, &(range[3])) ;

      if(rc != BSSUCC)
      {
	if (OM_Gf_verbose_warning) printf("ERROR BSdistptpt,\n");
	err_flag = TRUE;
	goto wrapup;
      }

      for(k=0;k<3;k++)
      {
	pt[0][k] = plane.point[k] - vec1[k] * fact - (vec2[k] * fact/2.);
	pt[1][k] = plane.point[k] + vec1[k] * fact - (vec2[k] * fact/2.);
	pt[2][k] = plane.point[k] + vec2[k] * fact;
      }
      type = 0; /* rectangular plane */

      stat = om$construct( msg = message EMSplane.EMplane(
						    (IGRint *)msg,cst,pt,type),
			   osnum = cp_obj[i].osnum,
			   p_objid = &cp_obj[i].objid,
			   classid = OPP_EMSplane_class_id);
      as$status(sts = stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in  EMSplane.EMplane\n");
	err_flag = TRUE;
	goto wrapup;
      }
      stat = om$send (  msg = message EMSsubbs.EMget_props(msg, &props),
			senderid = NULL_OBJID,
			targetid = lc_obj[1].located_obj.objid,
			targetos = lc_obj[1].located_obj.osnum );

      as$status(sts=stat);
      if (!(stat&1)) props = 0x00;

      stat = om$send (	msg = message EMSsubbs.EMset_props ( msg,
							  props,
							  EMS_O_SET),
			senderid = NULL_OBJID,
			targetid = cp_obj[i].objid,
			targetos = cp_obj[i].osnum);
      as$status(sts=stat);
    }
    else
    {
      stat = om$send(msg = message GRgraphics.GRcopy(msg,
						     &lc_obj[i].module_info, act_env,
						     &(cp_obj[i].objid)),
		     senderid = NULL_OBJID,
		     targetid = lc_obj[i].located_obj.objid,
		     targetos = lc_obj[i].located_obj.osnum);
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRcopy \n");
	err_flag = TRUE;
	goto wrapup;
      }
    }
    stat = om$send (msg = message EMSsurface.EMputLsIfNotThere
					    (	msg,
						&cst->env_info->md_env,
						NULL,
						NULL,
						0,
						NULL),
		    senderid = NULL_OBJID,
		    targetid = cp_obj[i].objid,
		    targetos = cp_obj[i].osnum);
    as$status(sts=stat);
    if(!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR EMSsurface.EMputLsIfNotThere\n");
      err_flag = TRUE;
      goto wrapup;
    }
  }
  ex$message(msgnumb = SM_S_BoolDif);

  option = /*EMSsfbool_opt_display | */EMSsfbool_opt_retryDisjoint |
    EMSsfbool_opt_HandleStop ;
  stat = om$construct( msg = message EMSsfboolean.EMboolean(
							    msg,
							    &lc_obj[0].module_info.md_env.matrix_type,
							    lc_obj[0].module_info.md_env.matrix,
							    cp_obj[0].objid,
							    1,
							    &cp_obj[1].objid,
							    cst,
							    EMSbool_difference,
							    option,
							    NULL,
							    NULL,
							    NULL,
							    NULL,
							    NULL ),
		       classid = OPP_EMSsfboolean_class_id,
		       p_objid = &bnd_id->objid,
		       osnum = bnd_id->osnum  );

  as$status(sts=stat);
  if(!(stat & (*msg) & 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR EMSsfboolean.EMboolean\n");
    err_flag = TRUE;
    goto wrapup;
  }

  stat = om$send(msg = message EMSsurface.EMgetactiveid(
							msg,
							&active_id,
							&top_lm_id ),
		 senderid = NULL_OBJID,
		 targetid = bnd_id->objid,
		 targetos = bnd_id->osnum);
  if(!(stat & *msg & 1))
  {
    if (OM_Gf_verbose_warning) printf("Warning getting the top dpr\n");
    active_id = *bnd_id;
  }
  stat = om$send(msg = message EMSdpr.EMmake_primitive1(
							msg,
							cst->env_info,
							bnd_id ),
		 senderid = NULL_OBJID,
		 targetid = active_id.objid,
		 targetos = active_id.osnum);

  as$status(sts=stat);
  if(!(stat & *msg & 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR EMSdpr.EMmake_primitive1\n");
    err_flag = TRUE;
    goto wrapup;
  }

wrapup:

  UI_message("");
  UI_status ("");
  for(i=0;i<2;i++)
  {
    if( cp_obj[i].objid != NULL_OBJID)
    {
      om$send(msg      = message GRgraphics.GRdelete(msg,
						     &lc_obj[0].module_info),
	      senderid = NULL_OBJID,
	      targetid =  cp_obj[i].objid,
	      targetos =  cp_obj[i].osnum );
      cp_obj[i].objid = NULL_OBJID;
    }
  }
  if( err_flag == TRUE)
  {
    if( bnd_id->objid != NULL_OBJID)
    {
      om$send(msg      = message GRgraphics.GRdelete(msg,cst->env_info),
	      senderid = NULL_OBJID,
	      targetid = bnd_id->objid,
	      targetos = bnd_id->osnum );
      bnd_id->objid = NULL_OBJID;
    }
    __exit_error_Function ( name = "SMBndBool" );
    return(0);
  }
  else
  {
    __exitFunction ( name = "SMBndBool" );
    return(1);
  }
}

/* -----------------------
 * TR179701987 Moved to SMspace_int1.I
 * This file is too big
 */
#ifdef PRE_243
/*19 ====================== SMCrtSfBnd ==========================

	Function that creates the bounded surface if given the
	templates.

	Call SMSurfBnd.

	return(1) if ok.
	else return(0).

*/

int	SMCrtSfBnd(msg, nb_sf, surfs, infinite,  offset, ordered, rev_sup,
			track_id,md_env,  cst, bnd_id)
long			*msg;       /* (O) completion code */
int			nb_sf;      /* (I) nb input objects */
struct GRid		*surfs;     /* (I) input surfaces */
unsigned int		infinite;   /* (I) infinite info (bit0 for surf0)*/
IGRdouble		offset;	    /* (I) offset */
IGRint			ordered;    /* (I) 1 for ordered input surface */
IGRint			rev_sup;    /* (I) 1 for reverse orient */
struct	GRid		*track_id;  /* (I) the track elt (NULL_OBJID if not) */
struct GRmd_env		*md_env;    /* (I) mod env */
struct GRvg_construct   *cst;	    /* (I) construction list */
struct	GRid		*bnd_id;    /* (O) constructed bounded surface */

/*.SMCrtSfBnd*/

{
  IGRint		stat, i,ssize, count;
  struct GRlc_info	*lc_info, track_info;
  struct GRid		*list, obj;
  char			*inf_flag;
  IGRboolean		is_natural_normal;
  IGRshort		option;
  struct GRmd_env	act_env;
  IGRlong		sizebuf, nret;
  GRclassid		sfid_class;

  IGRuchar		props;

  if(msg == NULL || nb_sf == 0 || surfs == NULL || track_id == NULL ||
     md_env == NULL || cst == NULL || bnd_id == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  __enterFunction ( name = "SMCrtSfBnd" );

  *msg = MSSUCC;

  list = NULL;
  lc_info  = NULL;
  inf_flag = NULL;
  track_info.module_info = *md_env;
  track_info.located_obj.objid = NULL_OBJID;
  track_info.located_obj.osnum = md_env->md_id.osnum;

  bnd_id->osnum = md_env->md_id.osnum;
  bnd_id->objid = NULL_OBJID;

  lc_info = _MALLOC(nb_sf, struct GRlc_info);
  if(lc_info == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    *msg = MSFAIL;
    goto wrapup;
  }
  inf_flag = _MALLOC(nb_sf, char);
  if(inf_flag == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    *msg = MSFAIL;
    goto wrapup;
  }

  sizebuf = sizeof(struct GRmd_env);
  gr$get_module_env(msg     = msg,
		    sizbuf  = &sizebuf,
		    buffer  = &act_env,
		    nret    = &nret);

  /* get md_env and matrix of each surface and fill inf_flag */

  for(i=0;i<nb_sf;i++)
  {
    lc_info[i].module_info = *md_env;
    stat = om$send( msg = message ASnode.ASreturn_go(
						     &lc_info[i].located_obj,
						     &lc_info[i].module_info.md_env.matrix_type,
						     lc_info[i].module_info.md_env.matrix),
		    senderid = NULL_OBJID,
		    targetid = surfs[i].objid,
		    targetos = surfs[i].osnum );
    if (!(stat&1)) lc_info[i].located_obj = surfs[i];

  }
  if(track_id->objid != NULL_OBJID)
  {
    stat = om$send( msg = message ASnode.ASreturn_go(
						     &track_info.located_obj,
						     &track_info.module_info.md_env.matrix_type,
						     track_info.module_info.md_env.matrix),
		    senderid = NULL_OBJID,
		    targetid = track_id->objid,
		    targetos = track_id->osnum );
    if (!(stat&1)) track_info.located_obj = *track_id;
  }
  SMGetInfFrmMask(nb_sf, infinite, inf_flag);

#ifdef	DEBUG
  printf("set env_info to 21,2 to be in range tree........\n");
  cst->env_info->md_id.objid = 21;
#endif

  stat = SMSurfBnd( msg, nb_sf, &act_env, lc_info, &track_info, inf_flag,
		    ordered, rev_sup, cst, &obj);
  if(!(stat & (*msg )& 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMSurfBnd\n");
    *msg = MSFAIL;
    goto wrapup;
  }

  stat = om$send( msg = message EMSsubbs.EMget_props(msg, &props),
		  senderid = NULL_OBJID,
		  targetid = obj.objid,
		  targetos = obj.osnum );

  as$status(sts=stat);

  if (!((*msg)&stat&1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR in .EMget_props\n");
    *msg = MSFAIL;
    goto wrapup;
  }

  bnd_id->objid = obj.objid; /* in case no offset done */

  if(fabs(offset) > 0.000001)
  {

#ifdef	OFF_DEBUG
    printf("offset = %lf \n",offset);
#endif

    /*
     * test the object offset normal - adz 09/14/94
     */

    {
      if( offset < 0 )
      {
	is_natural_normal = FALSE;
	offset = fabs( offset );
      }
      else	is_natural_normal = TRUE ;

#ifdef	OFF_DEBUG
      printf("is_natural_normal = %d\n",is_natural_normal);
#endif

      if(props & EMSIS_NRML_REVERSED)
      {
	if(is_natural_normal) is_natural_normal = FALSE;
	else		      is_natural_normal = TRUE;
      }

#ifdef	OFF_DEBUG
      printf("props = %d set is_natural_normal = %d\n",props,is_natural_normal);
#endif

    }

    /*
     * offset the bounded surf
     */

    /* PL sept 94 need to set the option otherwise EMoffset does not take*/
    /* the boundaries.							*/

#ifdef	OFF_DEBUG
    printf("call EMoffset with offset = %lf, is_natural_normal = %d\n",offset,is_natural_normal);
    printf("obj to offset: %d, %d  \n", obj.objid, obj.osnum);
#endif

    bnd_id->objid =  NULL_OBJID;
    option = EMS_opt_offsetS_copy_topology ;

    stat = om$send( msg = message EMSsurface.EMoffset(
						      msg,
						      option,
						      &md_env->md_env.matrix_type,
						      md_env->md_env.matrix,
						      cst,
						      is_natural_normal,
						      offset,
			      /** new arguments ..	*/
						      0,
						      NULL,
						      NULL,

						      0,
						      NULL,
						      NULL,
						      &bnd_id->objid,
						      NULL ),
		    senderid = NULL_OBJID,
		    targetid = obj.objid,
		    targetos = obj.osnum );
    as$status(sts=stat);
    if (!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR  EMSsurface.EMoffset \n");
      *msg = MSFAIL;
      goto wrapup;
    }
  }

  if(props & EMSIS_NRML_REVERSED)
  {
    stat = om$send(msg = message EMSsubbs.EMset_props(msg,
						      EMSIS_NRML_REVERSED, EMS_O_ON),
		   senderid = NULL_OBJID,
		   targetid = bnd_id->objid,
		   targetos = bnd_id->osnum);
    as$status(sts = stat);
    if(!((*msg)&stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR in EMSsubbs.EMset_props\n" );
      *msg = MSFAIL;
      goto wrapup;
    }
  }

  /* reverse normal */

  if(rev_sup)
  {
    stat = om$get_classid (objid = bnd_id->objid,
			   osnum = bnd_id->osnum,
			   p_classid = &sfid_class);
    if (!(stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR  om$get_classid \n");
      *msg = MSFAIL;
      goto wrapup;
    }

    stat = om$is_ancestry_valid (subclassid = sfid_class,
				 superclassid = OPP_EMSsubbs_class_id);

    if (stat == OM_S_SUCCESS)
    {
      stat = om$send(msg = message EMSsubbs.EMset_props(msg,
							EMSIS_NRML_REVERSED,
							EMS_O_TOGGLE),
		     senderid = NULL_OBJID,
		     targetid = bnd_id->objid,
		     targetos = bnd_id->osnum);
      as$status(sts=stat);
    }
    else
    {
      stat = om$send( msg = message GRowner.GRget_number_components
		      (msg, &ssize),
		      senderid = NULL_OBJID,
		      targetid =  bnd_id->objid,
		      targetos =  bnd_id->osnum );
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRowner.GRget_number_components\n");
	*msg = MSFAIL;
	goto wrapup;
      }
      list = _MALLOC(ssize, struct GRid);
      if(list == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
	*msg = MSFAIL;
	goto wrapup;
      }
      count = 0;
      stat = om$send(msg = message GRowner.GRget_components(
							    msg,
							    &act_env,
							    list,
							    ssize,
							    &count,
							    0,
							    OM_K_MAXINT),
		     senderid = NULL_OBJID,
		     targetid = bnd_id->objid,
		     targetos = bnd_id->osnum);
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in  GRowner.GRget_components \n");
	*msg = MSFAIL;
	goto wrapup;
      }
      for (i=0;i<ssize;i=i+1)
      {
	stat = om$send(msg = message EMSsubbs.EMset_props(msg,
							  EMSIS_NRML_REVERSED,
							  EMS_O_TOGGLE),
		       senderid = NULL_OBJID,
		       targetid = list[i].objid,
		       targetos = list[i].osnum);
	as$status(sts=stat);
      }
    }
  }

  _FREE(list);

  /* don't delete obj if no offset done */

  if(obj.objid != NULL_OBJID && fabs(offset) > 0.000001  )
  {
    stat = om$send(msg      = message GRgraphics.GRdelete(msg,
							  md_env),
		   senderid = NULL_OBJID,
		   targetid = obj.objid,
		   targetos = obj.osnum );
    as$status(sts=stat);
    obj.objid = NULL_OBJID;
  }

wrapup:

  _FREE(list);
  if (!(*msg)&1)
  {
    om$send(msg      = message GRgraphics.GRdelete(msg, &act_env),
	    senderid = NULL_OBJID,
	    targetid = bnd_id->objid,
	    targetos = bnd_id->osnum );
    bnd_id->objid = NULL_OBJID;
  }
  _FREE(lc_info);
  _FREE(inf_flag);

  __exitFunction ( name = "SMCrtSfBnd" );

  return OM_S_SUCCESS;

}
#endif

/*20 ====================== SMGetInfFrmMask ==========================

	Function that return the flags infinite if given mask

	infinite must be allocated of nb_surf.

	always return(1) .

*/

int	SMGetInfFrmMask(nb_surf, mask, infinite)
int			nb_surf;      /* (I) nb input objects */
unsigned int		mask;	      /* (I) infinite info (bit0 for surf0)*/
IGRchar			*infinite;    /* (O) infinite flag ('Y' or 'N') */
/*.SMGetInfFrmMask*/
{
  int		i;
  unsigned int	inf_mask;

  for(i=0;i<nb_surf;i++)
  {
    inf_mask = 0x0001 << i;
    if(mask & inf_mask) infinite[i] = 'Y';
    else infinite[i] = 'N';
  }

  return(1);
}

/*21 ====================== SMGetMaskFrmInf ==========================

	Function that return the mask if given the infinite flags

	always return(1) .

*/

int	SMGetMaskFrmInf(nb_surf, infinite, mask)
int			nb_surf;      /* (I) nb input objects */
IGRchar			*infinite;    /* (I) infinite flag ('Y' or 'N') */
unsigned int		*mask;	      /* (O) infinite info (bit0 for surf0)*/
/*.SMGetMaskFrmInf*/
{
  int		i;
  unsigned int	inf_mask;

  *mask = 0x0000;

  for(i=0;i<nb_surf;i++)
  {
    if(infinite[i] == 'Y' || infinite[i] == 'y')
    {
      inf_mask =  0x0001 << i;
      *mask = (*mask) | inf_mask;
    }
  }

  return(1);
}

/*22 ====================== SMCrtVolBnd ==========================

	Function that creates the bounded surface if given the
	templates.

	Call SMCreatBndVol.

	return(1) if ok.
	else return(0).

*/

int	SMCrtVolBnd(msg, nb_sf, surfs, infinite, ordered, track_id, md_env,
			cst, bnd_id)
long			*msg;       /* (O) completion code */
int			nb_sf;      /* (I) nb input objects */
struct GRid		*surfs;     /* (I) input surfaces */
unsigned int		infinite;   /* (I) infinite info (bit0 for surf0)*/
int			ordered;    /* (I) 1 for ordered surface input */
struct GRid		*track_id;  /* (I) track point (NULL_OBJID if not) */
struct GRmd_env		*md_env;    /* (I) mod env */
struct GRvg_construct   *cst;	    /* (I) construction list */
struct	GRid		*bnd_id;    /* (O) constructed bounded volume */

/*.SMCrtVolBnd*/
{
  IGRint		stat, i;
  struct GRlc_info	*lc_info, track_info;
  char			*inf_flag;
  struct GRmd_env	act_env;
  IGRlong		sizebuf, nret;

  if(msg == NULL || nb_sf == 0 || surfs == NULL || track_id == NULL ||
     md_env == NULL || cst == NULL || bnd_id == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  __enterFunction ( name = "SMCrtVolBnd" );

  *msg = MSSUCC;

  lc_info  = NULL;
  inf_flag = NULL;
  track_info.module_info = *md_env;
  track_info.located_obj.objid = NULL_OBJID;
  track_info.located_obj.osnum = md_env->md_id.osnum;

  bnd_id->osnum = md_env->md_id.osnum;
  bnd_id->objid = NULL_OBJID;

  lc_info = _MALLOC(nb_sf, struct GRlc_info);
  if(lc_info == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    *msg = MSFAIL;
    goto wrapup;
  }
  inf_flag = _MALLOC(nb_sf, char);
  if(inf_flag == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    *msg = MSFAIL;
    goto wrapup;
  }

  sizebuf = sizeof(struct GRmd_env);
  gr$get_module_env(msg     = msg,
		    sizbuf  = &sizebuf,
		    buffer  = &act_env,
		    nret    = &nret);

  /* get md_env and matrix of each surface and fill inf_flag */

  for(i=0;i<nb_sf;i++)
  {
    lc_info[i].module_info = *md_env;
    stat = om$send( msg = message ASnode.ASreturn_go(
						     &lc_info[i].located_obj,
						     &lc_info[i].module_info.md_env.matrix_type,
						     lc_info[i].module_info.md_env.matrix),
		    senderid = NULL_OBJID,
		    targetid = surfs[i].objid,
		    targetos = surfs[i].osnum );
    if (!(stat&1)) lc_info[i].located_obj = surfs[i];
  }
  if(track_id->objid != NULL_OBJID)
  {
    stat = om$send( msg = message ASnode.ASreturn_go(
						     &track_info.located_obj,
						     &track_info.module_info.md_env.matrix_type,
						     track_info.module_info.md_env.matrix),
		    senderid = NULL_OBJID,
		    targetid = track_id->objid,
		    targetos = track_id->osnum );
    if (!(stat&1)) track_info.located_obj = *track_id;
  }

  SMGetInfFrmMask(nb_sf, infinite, inf_flag);

  if(ordered)
    stat = SMOrdBndVol(msg, nb_sf, &act_env, lc_info, &track_info,inf_flag,
		       cst, bnd_id);
  else
    stat = SMCreatBndVol( msg, nb_sf, &act_env, lc_info, &track_info,
			  inf_flag, ordered, cst, bnd_id);

  if(!(stat & (*msg )& 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMCreatBndVol\n");
    *msg = MSFAIL;
    goto wrapup;
  }

wrapup:
  _FREE(lc_info);
  _FREE(inf_flag);
  __exitFunction ( name = "SMCrtVolBnd" );

  return OM_S_SUCCESS;

}

/*23 ====================== SMOrdBndVol ==========================

	Function that creates a volume from top, bottom and limits

	return(1) if ok.
	else return(0).

*/

int	SMOrdBndVol(msg, num_ent, act_env, lc_obj, lc_track, inf_flag,
			cst, bnd_id)
long			*msg;       /* (O) completion code */
int			num_ent;    /* (I) nb input objects */
struct GRmd_env		*act_env;   /* (I) act mod env */
struct GRlc_info	*lc_obj;    /* (I) input surfaces */
struct GRlc_info	*lc_track;  /* (I) the track elt (NULL_OBJID if not) */
char			*inf_flag;  /* (I) infinite flag */
struct GRvg_construct   *cst;	    /* (I) construction list
					(md_env.md_id = NULL_OBJID)*/
struct	GRid		*bnd_id;    /* (O) constructed vol */

/*.SMOrdBndVol*/
{

  int			i,j,k, stat, nb_surfs, rev_sup, ordered;
  IGRboolean		err_flag;
  struct GRlc_info      *surfs, sf_track;
  struct GRid		*bndsurf;
  IGRushort		makecs_opt ;
  GRobjid		*comps;
  struct GRvg_construct tmp_cst;
  char			new_class[256];
  struct GRid	   TMP, active_id, top_lm_id;

  if(num_ent == 0 || act_env == NULL || lc_obj == NULL || inf_flag == NULL
     || cst == NULL || bnd_id == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Invalid Argument\n");
    return(0);
  }
  __enterFunction ( name = "SMOrdBndVol" );

  if(msg != NULL) *msg = MSSUCC;
  err_flag = FALSE;

  surfs = NULL;
  bndsurf = NULL;
  comps = NULL;

  bnd_id->objid = NULL_OBJID;
  bnd_id->osnum = act_env->md_id.osnum;

  /* make each bounded surfaces to create the solid */

  bndsurf = _MALLOC(num_ent, struct GRid);
  if(bndsurf == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation \n");
    err_flag = TRUE;
    goto wrapup;
  }

  for(k=0;k<num_ent;k++)
  {
    nb_surfs = 0;
    surfs = _MALLOC(num_ent, struct GRlc_info);
    if(surfs == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad allocation \n");
      err_flag = TRUE;
      goto wrapup;
    }

    surfs[0] = lc_obj[k]; /* the support */

    /* top and bottom */

    if(k==0 || k==1)
    {
      nb_surfs = num_ent-1;
      j=2;
      for(i=1;i<nb_surfs;i++)
      {
	surfs[i] = lc_obj[j];
	j++;
      }
    }
    else
    {
      nb_surfs = 5;
      surfs[1] = lc_obj[0];
      if(k == 2)		surfs[2] = lc_obj[num_ent-1];
      else			surfs[2] = lc_obj[k-1];
      surfs[3] = lc_obj[1];
      if(k == num_ent-1)	surfs[4] = lc_obj[2];
      else			surfs[4] = lc_obj[k+1];
    }
    tmp_cst = (*cst);
    ordered = 1;
    rev_sup = 0;

    sf_track.located_obj.objid = NULL_OBJID;

    stat = SMSurfBnd(msg, nb_surfs, act_env, surfs, &sf_track,
		     inf_flag, ordered, rev_sup, cst, &bndsurf[k]);
    if(!(stat & *msg &1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR creating bndsurf %d\n",k);
      err_flag = TRUE;
      goto wrapup;
    }
    _FREE(surfs);
  }

  comps = _MALLOC(num_ent, GRobjid);
  if(comps == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad dynamic allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }

  for(i=0;i<num_ent;i++) comps[i] = bndsurf[i].objid;

  tmp_cst = (*cst);

  makecs_opt = NULL;

  stat = om$construct(msg  = message EMSsfstitch.EMmake_comp( msg,
							      num_ent,
							      comps,
							      act_env,
							      NULL,
							      NULL,
							      0,
							      NULL,
							      makecs_opt),

		      classid = OPP_EMSsfstitch_class_id,
		      p_objid  = &(bnd_id->objid),
		      osnum  = bnd_id->osnum);

  as$status(sts=stat);
  if( !(stat & (*msg) & 1) )
  {
    if (OM_Gf_verbose_warning) printf("ERROR EMSsfstitch.EMmake_comp\n");
    err_flag = TRUE;
    goto wrapup;
  }

  stat = om$send(msg = message EMSsfdpr.EMgetsolidclass(msg, new_class),
		 senderid = NULL_OBJID,
		 targetid = bnd_id->objid,
		 targetos = bnd_id->osnum) ;
  as$status(sts=stat);
  if( !(stat & (*msg) & 1) )
  {
    if (OM_Gf_verbose_warning) printf("ERROR EMSsfdpr.EMgetsolidclass\n");
    err_flag = TRUE;
    goto wrapup;
  }

  stat = om$change_class(	 objid = bnd_id->objid,
				  osnum = bnd_id->osnum,
				  classname = new_class) ;
  if( !(stat & 1) )
  {
    if (OM_Gf_verbose_warning) printf("ERROR om$change_class\n");
    err_flag = TRUE;
    goto wrapup;
  }

  stat = om$send(msg = message EMSsolid.EMorient_yourself
		 (msg, NULL, act_env),
		 senderid = NULL_OBJID,
		 targetid = bnd_id->objid,
		 targetos = bnd_id->osnum) ;
  if( !(stat & (*msg) & 1) )
  {
    if (OM_Gf_verbose_warning) printf("ERROR EMSsolid.EMorient_yourself\n");
    err_flag = TRUE;
    goto wrapup;
  }

  stat = om$send(msg = message EMSsurface.EMgetactiveid(
							msg,
							&active_id,
							&top_lm_id ),
		 senderid = NULL_OBJID,
		 targetid = bnd_id->objid,
		 targetos = bnd_id->osnum);
  if(!(stat & *msg & 1))
  {
    if (OM_Gf_verbose_warning) printf("Warning getting the top dpr\n");
    active_id = *bnd_id;
  }

  stat = om$send(msg = message EMSdpr.EMmake_primitive1(
							msg,
							cst->env_info,
							&TMP ),
		 senderid = NULL_OBJID,
		 targetid = active_id.objid,
		 targetos = active_id.osnum);

  as$status(sts=stat);
  if(!(stat & *msg & 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR EMSdpr.EMmake_primitive1\n");
    err_flag = TRUE;
    goto wrapup;
  }

  bnd_id->objid = TMP.objid;

wrapup:

  UI_status("");

  _FREE(surfs);

  _FREE(comps);
  _FREE(bndsurf);
  if(err_flag == TRUE)
  {
    if(bnd_id->objid != NULL_OBJID)
    {
      om$send(msg      = message GRgraphics.GRdelete(msg,act_env),
	      senderid = NULL_OBJID,
	      targetid = bnd_id->objid,
	      targetos = bnd_id->osnum );
      bnd_id->objid = NULL_OBJID;
    }
    __exit_error_Function ( name = "SMOrdBndVol" );
    return(0);
  }
  else
  {
    __exitFunction ( name = "SMOrdBndVol" );
    return(1);
  }
}

/*24 ====================== SMOrdBndSf ==========================

	Function that creates a bounded surface from a support
	and ordered limits

	return(1) if ok.
	else return(0).

*/

int	SMOrdBndSf(msg, num_ent, act_env, lc_obj, inf_flag, cst, bnd_id)
long			*msg;       /* (O) completion code */
int			num_ent;    /* (I) nb input objects */
struct GRmd_env		*act_env;   /* (I) act mod env */
struct GRlc_info	*lc_obj;    /* (I) input surfaces */
char			*inf_flag;  /* (I) infinite flag */
struct GRvg_construct   *cst;	    /* (I) construction list
					(md_env.md_id = NULL_OBJID)*/
struct	GRid		*bnd_id;    /* (O) constructed vol */

/*.SMOrdBndSf*/
{
  struct IGRbsp_curve	**plcurve, **plcurve1, *cvgeom, *compcv, *projcv;
  struct IGRplane	plane[2], const_pl, *plan1;
  struct GRlc_info      *curves, **part_id, final_curve, *part_cv;

  struct GRvg_construct tmp_cst;
  struct GRid		prj_comp, comp_id;

  struct SMsfinters	*cvinters;
  struct SMinters	*ptinters;
  struct SMcurve	*SMcurve;

  struct SMExactInt	*IntPts;

  IGRdouble		range[6], *pt1, *pt2, *par1, *par2,
			basis_tol, cht_tol, tol,
			plane_space[12], pl_space[6];

  IGRboolean		world, err_flag;

  char			running[DI_PATH_MAX];

  long			stat, nput, nret;

  IGRint		type_flag,elem_type, *typesf, nb_cvinters, nb_ptinters,
			nb_sf1, nb_curves, ordered,
			close_cv,  i,  k;

  BSrc			rc;

  if(num_ent == 0 || act_env == NULL || lc_obj == NULL || inf_flag == NULL
     || cst == NULL || bnd_id == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Invalid Argument\n");
    return(0);
  }
  __enterFunction ( name = "SMOrdBndSf" );

  if(msg != NULL) *msg = MSSUCC;
  pt1 = pt2 = par1 = par2 = NULL;

  IntPts		= NULL;
  curves		= NULL;
  part_cv		= NULL;
  part_id		= NULL;

  typesf		= NULL;
  compcv		= NULL;
  cvgeom		= NULL;
  plan1			= NULL;
  plcurve		= NULL;
  plcurve1		= NULL;
  cvinters		= NULL;
  nb_cvinters		= 0;
  ptinters		= NULL;
  SMcurve		= NULL;
  projcv		= NULL;
  nb_curves		= 0;
  nb_cvinters		= 0;

  prj_comp.objid = NULL_OBJID;
  comp_id.objid = NULL_OBJID;

  close_cv = 0;

  const_pl.point  = &pl_space[0];
  const_pl.normal = &pl_space[3];

  plane[0].point  = &plane_space[0];
  plane[0].normal = &plane_space[3];
  plane[1].point  = &plane_space[6];
  plane[1].normal = &plane_space[9];

  err_flag = FALSE;

  bnd_id->objid = NULL_OBJID;
  bnd_id->osnum = act_env->md_id.osnum;

  nput = sizeof(basis_tol);

  gr$get_basis_tolerance(msg    = msg,
			 sizbuf = &nput,
			 buffer = &basis_tol,
			 nret   = &nret);

  if(!((*msg)&1))
  {
    if (OM_Gf_verbose_warning) printf("error gr$get_basis_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }
  nput = sizeof(cht_tol);

  gr$get_chord_height_tolerance(msg    = msg,
				sizbuf = &nput,
				buffer = &cht_tol,
				nret   = &nret);

  if(!((*msg)&1))
  {
    if (OM_Gf_verbose_warning) printf("error gr$get_chord_height_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }
  tol = cht_tol ;

  world = TRUE;
  stat = om$send( msg = message GRgraphics.GRgetrang(msg,
						     &lc_obj[0].module_info.md_env.matrix_type,
						     lc_obj[0].module_info.md_env.matrix,
						     &world, range),
		  senderid = NULL_OBJID,
		  targetid = lc_obj[0].located_obj.objid,
		  targetos = lc_obj[0].located_obj.osnum );

  as$status(sts=stat);
  if (!((*msg)&stat&1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRgetrang\n" );
    err_flag = TRUE;
    goto wrapup;
  }

  nb_sf1 = 0;
  if (inf_flag[0] != 'y' && inf_flag[0] != 'Y') type_flag = SURF;
  else				      type_flag = PLAN;

  stat = SMelem_(type_flag, &(lc_obj[0].located_obj),
		 lc_obj[0].module_info.md_env.matrix_type,
		 lc_obj[0].module_info.md_env.matrix,
		 &elem_type, &plane[0], NULL, NULL, &nb_sf1);
  if (!(stat&1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR fonction SMelem_\n");
    err_flag = TRUE;
    goto wrapup;
  }

  if(elem_type != PLAN)
  {
    stat = om$send (msg = message EMSsurface.EMputLsIfNotThere
		    (	msg,
			&lc_obj[0].module_info.md_env,
			NULL,
			NULL,
			0,
			NULL),
		    senderid = NULL_OBJID,
		    targetid = lc_obj[0].located_obj.objid,
		    targetos = lc_obj[0].located_obj.osnum);
    as$status(sts=stat);
    if (!((*msg)&stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR in EMSsurface.EMputLsIfNotThere\n");
      err_flag = TRUE;
      goto wrapup;
    }
    lc_obj[0].module_info = (*act_env);
    lc_obj[0].located_obj = lc_obj[0].located_obj;
  }

  /* SPECIAL CASE FOR SUPPORT COMPOSITE AND ONLY ONE LIMITATING SURFACE
     (hull and plane) we directly make support boolean diff with object */

  if(num_ent == 2 && elem_type == COMP_SF)
  {
    stat = SMBndBool(msg, act_env, lc_obj,
		     inf_flag, cst, bnd_id);
    if(!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMBndBool\n");
      err_flag = TRUE;
      goto wrapup;
    }

    goto wrapup;
  }

  /* -----------------------------------------------------------------------

     we have (num_ent) objects that will give (num_ent-1) intersection cv
     we make intersection between support and surface i and create the
     intersection curve => INT_CURVE[i-1] (geom curve[i-1] )

     ----------------------------------------------------------------------- */

  typesf = _MALLOC(num_ent, int);
  if(typesf == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }

  tmp_cst = (*cst);
  stat = SMint_support1(msg, num_ent, lc_obj, &tmp_cst, inf_flag,
			&nb_cvinters, &cvinters, &SMcurve, typesf);
  if(!(stat & (*msg) & 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMint_support1\n");
    err_flag = TRUE;
    goto wrapup;
  }

  /* transform struct sfinters in a structure on surface */

  if(nb_cvinters == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR:no intersection between support and any surface\n");
    err_flag = TRUE;
    goto wrapup;
  }
  if(nb_cvinters == 1 && cvinters[0].cv_geom->phy_closed == TRUE) close_cv = 1;

  if(nb_cvinters == 1 && !close_cv)

  {
    if (OM_Gf_verbose_warning) printf("ERROR cannot create a bounded surface with an open curve\n");
    err_flag = TRUE;
    goto wrapup;
  }

  plcurve = _MALLOC(nb_cvinters, struct IGRbsp_curve *);
  if(	plcurve == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<nb_cvinters;i++) plcurve[i] = NULL;

  plcurve1 = _MALLOC(nb_cvinters, struct IGRbsp_curve *);
  if(	plcurve1 == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<nb_cvinters;i++) plcurve1[i] = NULL;

  for(i=0;i<nb_cvinters;i++) plcurve[i] = cvinters[i].cv_geom ;

  if(close_cv)
  {
    if(elem_type == COMP_SF)
    {
      /* -------------------------------------------------------
	 We approximate the support with a plane (point and normal):
	 Compute the minimum distance between each curve and its
	 successor and get the barycenter of these approximative
	 intersection points in order to have a point in the area
	 we want to extract, the plane taken will be the tangent plane
	 to the support at this point.
	 ---------------------------------------------------------- */

      ex$message(msgnumb = SM_S_CstPrjPl);

      for(k=0;k<nb_cvinters;k=k+1) plcurve[k] = cvinters[k].cv_geom;

      ordered = 1;
      stat = SMGetDummyPl(msg, nb_cvinters, plcurve, ordered,
			  &lc_obj[0], range,
			  elem_type, &const_pl);
      if(!(stat & (*msg) & 1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR SMGetDummyPl\n");
	err_flag = TRUE;
	goto wrapup;
      }

      plan1 = &const_pl;
    }
    else plan1 = NULL;

    if(elem_type == COMP_SF || cvinters[0].cvint_id.objid == NULL_OBJID)
    {
      tmp_cst = (*cst);
      tmp_cst.geometry = (char *)plcurve[0];

      prj_comp.osnum = tmp_cst.env_info->md_id.osnum;
      prj_comp.objid = NULL_OBJID;

      stat = om$construct(msg = message GRgraphics.GRconstruct(
							       &tmp_cst),
			  classid = OPP_GRbcsubbc_class_id,
			  p_objid  = &(prj_comp.objid),
			  osnum  = prj_comp.osnum);

      as$status(sts=stat);
      if (!(stat&1))
      {
	if (OM_Gf_verbose_warning) printf("GRbcsubbc.GRconstruct failed\n");
	err_flag = TRUE;
	goto wrapup;
      }

      final_curve.located_obj = prj_comp;
    }
    else	final_curve.located_obj = cvinters[0].cvint_id;

    final_curve.module_info = *(cst->env_info);

    tmp_cst = (*cst);

    ex$message(msgnumb = SM_S_CrtBndSf);

    stat = SMCreatBndSurf(msg, &final_curve, (struct IGRbsp_curve *)NULL,
			  1, &final_curve, act_env, &tmp_cst, elem_type,
			  &lc_obj[0], plan1,bnd_id);

    if(!(stat & (*msg) & 1) )
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMCreatBndSurf\n");
      err_flag = TRUE;
      goto wrapup;
    }

    goto wrapup;
  }

  ex$message(msgnumb = SM_S_CmpIntCv);

  stat = SMint_ordercurves(nb_cvinters, plcurve, &nb_ptinters, &ptinters);
  if(!(stat & (*msg) & 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMint_curves\n");
    err_flag = TRUE;
    goto wrapup;
  }

  if(nb_ptinters == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR , No curve Intersections\n");
    err_flag = TRUE;
    goto wrapup;
  }

  /* transform struct inters in a structure on curve */

  stat = SMSortCvIntpts(nb_cvinters, nb_ptinters, ptinters, SMcurve);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMSortCvIntpts\n");
    err_flag = TRUE;
    goto wrapup;
  }

  IntPts = NULL;
  IntPts = _MALLOC(nb_ptinters, struct SMExactInt);
  if(IntPts == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<nb_ptinters;i++)
    for(k=0;k<3;k++) IntPts[i].surf[k].geom = NULL;

  /* get the exact intersection points */

  stat = SMGetSfintpt( nb_ptinters, ptinters, cvinters, lc_obj, typesf, IntPts);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMGetSfintpt\n");
    err_flag = TRUE;
    goto wrapup;
  }
  stat = SMChgInters(nb_ptinters, ptinters, cvinters,IntPts);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMChgInters\n");
    err_flag = TRUE;
    goto wrapup;
  }

  /* creates the partof curves */

  if(comp_id.objid == NULL_OBJID)
  {
    ex$message(msgnumb = SM_S_CrtCmpCv);

    tmp_cst = (*cst);
    compcv = NULL;
    part_cv = NULL;
    stat = SMCrtPartCv1(nb_cvinters,
			plcurve,
			nb_ptinters,
			ptinters,
			&tmp_cst,
			&part_cv,
			NULL);
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMCrtPartCv\n");
      err_flag = TRUE;
      goto wrapup;
    }

    stat = SMCreatCompCv(
			 nb_cvinters,
			 part_cv,
			 &tmp_cst,
			 &comp_id,
			 &compcv);
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMCreatCompCv\n");
      err_flag = TRUE;
      goto wrapup;
    }
    nb_curves = nb_cvinters;
    curves = part_cv;
    cvgeom = compcv;
  }

  final_curve.located_obj = comp_id;
  final_curve.module_info = *(cst->env_info);

  tmp_cst = (*cst);
  projcv = NULL;

  if(elem_type == COMP_SF)
  {
    /* -------------------------------------------------------
       We approximate the support with a plane (point and normal):
       Compute the minimum distance between each curve and its
       successor and get the barycenter of these approximative
       intersection points in order to have a point in the area
       we want to extract, the plane taken will be the tangent plane
       to the support at this point.
       ---------------------------------------------------------- */

    ex$message(msgnumb = SM_S_CstPrjPl);

    ordered = 1;
    stat = SMGetDummyPl(msg, 1, &compcv,ordered,  &lc_obj[0], range,
			elem_type, &const_pl);
    if(!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMGetDummyPl\n");
      err_flag = TRUE;
      goto wrapup;
    }

    sprintf(running,"%s","Project curve on dummy plane" );
    UI_status(running);

    (void)BSalloccv(compcv->order,
		    compcv->num_poles,
		    compcv->rational,
		    compcv->num_boundaries,
		    &projcv,
		    &rc);
    if(rc != BSSUCC && rc!=BSNULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
      err_flag = TRUE;
      goto wrapup;
    }
    (IGRboolean)BSprj_cv_pl(&rc, compcv,
		&const_pl.point[0], &const_pl.normal[0],
		const_pl.normal, projcv);
    if(rc!=BSSUCC)
    {
      if (OM_Gf_verbose_warning) printf("ERROR BSprj_cv_pl: no projection curve\n");
      err_flag = TRUE;
      goto wrapup;
    }
    plan1 = &const_pl;
    tmp_cst = (*cst);
    tmp_cst.geometry = (char *)projcv;
    prj_comp.osnum = tmp_cst.env_info->md_id.osnum;
    prj_comp.objid = NULL_OBJID;
    cvgeom = projcv;
    stat = om$construct(msg = message GRgraphics.GRconstruct(
							     &tmp_cst),
			classid = OPP_GRbcsubbc_class_id,
			p_objid  = &(prj_comp.objid),
			osnum  = prj_comp.osnum);

    as$status(sts=stat);
    if (!(stat&1))
    {
      if (OM_Gf_verbose_warning) printf("GRbcsubbc.GRconstruct failed\n");
      err_flag = TRUE;
      goto wrapup;
    }
    final_curve.located_obj = prj_comp;
    final_curve.module_info = *(cst->env_info);
  }
  else plan1 = NULL;

  if(cvgeom != NULL && cvgeom->phy_closed != TRUE)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, constructed curve is not closed\n");
    err_flag = TRUE;
    goto wrapup;
  }

  ex$message(msgnumb = SM_S_CrtBndSf);

  tmp_cst = (*cst);
  stat = SMCreatBndSurf(msg, &final_curve, cvgeom, nb_curves, curves,
			act_env, &tmp_cst, elem_type,
			&lc_obj[0], plan1,bnd_id);

  if(!(stat & (*msg) & 1) )
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMCreatBndSurf\n");
    err_flag = TRUE;
    goto wrapup;
  }

wrapup:

  UI_message("");
  UI_status("");

  if(IntPts != NULL)
  {
    for(i=0;i<nb_ptinters;i++)
      for(k=0;k<3;k++) SMFreeSfGeom( &IntPts[i].surf[k]);
    _FREE(IntPts);
  }
  if(om$is_objid_valid(osnum = prj_comp.osnum,
		       objid = prj_comp.objid) & 1)
  {
    om$send(msg = message GRgraphics.GRdelete(msg, cst->env_info),
	    senderid = NULL_OBJID,
	    targetid = prj_comp.objid ,
	    targetos = prj_comp.osnum);
    prj_comp.objid = NULL_OBJID;
  }
  if(part_cv != NULL)
  {
    for(i=0;i<nb_cvinters; i++)
    {
      if(om$is_objid_valid(osnum = part_cv[i].located_obj.osnum,
			   objid = part_cv[i].located_obj.objid) & 1)
      {
	stat = om$send(	msg = message GRgraphics.GRdelete(msg,
							  cst->env_info),
			senderid = NULL_OBJID,
			targetid = part_cv[i].located_obj.objid ,
			targetos = part_cv[i].located_obj.osnum);
	as$status(sts=stat);
	part_cv[i].located_obj.objid = NULL_OBJID;
      }
    }
    _FREE(part_cv);
  }
  if(part_id !=NULL)
  {
    for(i=0;i<nb_cvinters; i++)
    {
      if(om$is_objid_valid(osnum = part_id[i]->located_obj.osnum,
			   objid = part_id[i]->located_obj.objid) & 1)
      {
	stat = om$send(	msg = message GRgraphics.GRdelete(msg,
							  cst->env_info),
			senderid = NULL_OBJID,
			targetid = part_id[i]->located_obj.objid ,
			targetos = part_id[i]->located_obj.osnum);
	as$status(sts=stat);
	part_id[i]->located_obj.objid = NULL_OBJID;
      }
      _FREE(part_id[i]);
    }
    _FREE(part_id);

  }
  _FREE(par1);
  _FREE(par2);
  _FREE(pt1);
  _FREE(pt2);
  _FREE(compcv);
  _FREE(typesf);
  if(plcurve1 != NULL)
  {
    for(i=0;i<nb_cvinters;i=i+1)
    {
      if(plcurve1[i] != NULL )
	(IGRboolean)BSfreecv(&rc, plcurve1[i]); plcurve1[i] = NULL;
    }
    _FREE(plcurve1);
  }
  _FREE(plcurve);
  if(projcv != NULL )
  {(IGRboolean)BSfreecv(&rc, projcv); projcv = NULL;}

  _FREE(ptinters);
  if(SMcurve != NULL)
  {
    for(i=0;i<nb_cvinters;i=i+1)
      _FREE(SMcurve[i].pt_index) ;
    _FREE(SMcurve);
  }
  if(cvinters != NULL)
  {
    for(i=0;i<nb_cvinters; i=i+1)
    {
      /* don't delete input curve */

      if(cvinters[i].sf1 == -1 || cvinters[i].sf2 == -1) continue;
      if(om$is_objid_valid(osnum = cvinters[i].cvint_id.osnum,
			   objid = cvinters[i].cvint_id.objid) & 1)
      {
	om$send(	msg = message GRgraphics.GRdelete(
							  msg, cst->env_info),
			senderid = NULL_OBJID,
			targetid = cvinters[i].cvint_id.objid ,
			targetos = cvinters[i].cvint_id.osnum);
	cvinters[i].cvint_id.objid = NULL_OBJID;
      }
      if(cvinters[i].cv_geom!=NULL)
      {
	if(cvinters[i].alloc_flag == FALSE)
	{
	  _FREE ( cvinters[i].cv_geom );
	}
	else
	{
	  (IGRboolean)BSfreecv(&rc, cvinters[i].cv_geom);
	}
	cvinters[i].cv_geom = NULL;
      }
    }
    _FREE(cvinters);
  }

  if(om$is_objid_valid(osnum = comp_id.osnum,
		       objid = comp_id.objid) & 1)
  {
    om$send(	msg = message GRgraphics.GRdelete(msg, cst->env_info),
		senderid = NULL_OBJID,
		targetid = comp_id.objid ,
		targetos = comp_id.osnum);
    comp_id.objid = NULL_OBJID;
  }

  if(err_flag == TRUE)
  {
    if( bnd_id->objid != NULL_OBJID)
    {
      om$send(msg      = message GRgraphics.GRdelete(msg,cst->env_info),
	      senderid = NULL_OBJID,
	      targetid = bnd_id->objid,
	      targetos = bnd_id->osnum );
      bnd_id->objid = NULL_OBJID;
    }
    __exit_error_Function ( name = "SMOrdBndSf" );
    return(0);
  }
  else
  {
    __exitFunction ( name = "SMOrdBndSf" );
    return(1);
  }
}

/*25 ====================== SMCrtOrdSfBnd ==========================

	Function that creates the ordered bounded surface if given the
	templates.

	Call SMOrdBndSf

	return(1) if ok.
	else return(0).

*/

int	SMCrtOrdSfBnd(msg, nb_sf, surfs, infinite, offset, md_env,
			cst, bnd_id)
long			*msg;       /* (O) compl<etion code */
int			nb_sf;      /* (I) nb input objects */
struct GRid		*surfs;     /* (I) input surfaces */
unsigned int		infinite;   /* (I) infinite info (bit0 for surf0)*/
IGRdouble		offset;	    /* (I) offset */
struct GRmd_env		*md_env;    /* (I) mod env */
struct GRvg_construct   *cst;	    /* (I) construction list */
struct	GRid		*bnd_id;    /* (O) constructed bounded surface */

/*.SMCrtOrdSfBnd*/
{
  IGRint		stat, i;
  struct GRlc_info	*lc_info;
  struct GRid		obj;
  char			*inf_flag;
  IGRboolean		is_natural_normal;
  IGRshort		option;
  struct GRmd_env	act_env;
  IGRlong		sizebuf, nret;
  IGRuchar		props;

  lc_info  = NULL;
  inf_flag = NULL;

  *msg = MSSUCC;
  
  __enterFunction ( name = "SMCrtOrdSfBnd" );

  if(nb_sf == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR no input surfaces\n");
    *msg = MSFAIL;
    goto wrapup;
  }
  bnd_id->osnum = md_env->md_id.osnum;
  bnd_id->objid = NULL_OBJID;

  lc_info = _MALLOC(nb_sf, struct GRlc_info);
  if(lc_info == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    *msg = MSFAIL;
    goto wrapup;
  }
  inf_flag = _MALLOC(nb_sf, char);
  if(inf_flag == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    *msg = MSFAIL;
    goto wrapup;
  }

  sizebuf = sizeof(struct GRmd_env);
  gr$get_module_env(msg     = msg,
		    sizbuf  = &sizebuf,
		    buffer  = &act_env,
		    nret    = &nret);

  /* get md_env and matrix of each surface and fill inf_flag */

  for(i=0;i<nb_sf;i++)
  {
    lc_info[i].module_info = *md_env;
    stat = om$send( msg = message ASnode.ASreturn_go(
						     &lc_info[i].located_obj,
						     &lc_info[i].module_info.md_env.matrix_type,
						     lc_info[i].module_info.md_env.matrix),
		    senderid = NULL_OBJID,
		    targetid = surfs[i].objid,
		    targetos = surfs[i].osnum );
    if (!(stat&1)) lc_info[i].located_obj = surfs[i];
  }

  SMGetInfFrmMask(nb_sf, infinite, inf_flag);

  stat = SMOrdBndSf( msg, nb_sf, &act_env, lc_info, inf_flag, cst, &obj);
  if(!(stat & (*msg )& 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMOrdBndSf\n");
    *msg = MSFAIL;
    goto wrapup;
  }

  stat = om$send( msg = message EMSsubbs.EMget_props(msg, &props),
		  senderid = NULL_OBJID,
		  targetid = obj.objid,
		  targetos = obj.osnum );
  as$status(sts=stat);

  if (!((*msg)&stat&1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR in .EMget_props\n");
    *msg = MSFAIL;
    goto wrapup;
  }

  bnd_id->objid = obj.objid; /* in case no offset done */

  if(fabs(offset) > 0.000001)
  {
    /*
     * test the object offset normal - adz 09/14/94
     */
    {
#ifdef	OFF_DEBUG
      printf("offset = %lf \n",offset);
#endif

      if( offset < 0 )
      {
	is_natural_normal = FALSE;
	offset = fabs( offset );
      }
      else	is_natural_normal = TRUE ;

#ifdef	OFF_DEBUG
      printf("is_natural_normal = %d\n",is_natural_normal);
#endif

      if(props & EMSIS_NRML_REVERSED)
      {
	if(is_natural_normal) is_natural_normal = FALSE;
	else		      is_natural_normal = TRUE;
      }

#ifdef	OFF_DEBUG
      printf("props = %d set is_natural_normal = %d\n",props,is_natural_normal);
#endif
    }
    /*
     * offset the bounded surf
     */

    /* PL sept 94 need to set the option otherwise EMoffset does not take	*/
    /* the boundaries.							*/

#ifdef	OFF_DEBUG
    printf("call EMoffset with offset = %lf, is_natural_normal = %d\n",offset,is_natural_normal);
    printf("obj to offset: %d, %d  \n", obj.objid, obj.osnum);
#endif

    bnd_id->objid =  NULL_OBJID;
    option = EMS_opt_offsetS_copy_topology;

    stat = om$send( msg = message EMSsurface.EMoffset(
						      msg,
						      option,
						      &md_env->md_env.matrix_type,
						      md_env->md_env.matrix,
						      cst,
						      is_natural_normal,
						      offset,
						      /** new arguments ..	*/
						      0,
						      NULL,
						      NULL,

						      0,
						      NULL,
						      NULL,
						      &bnd_id->objid,
						      NULL ),
		    senderid = NULL_OBJID,
		    targetid = obj.objid,
		    targetos = obj.osnum );
    as$status(sts=stat);
    if (!(stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR  EMSsurface.EMoffset \n");
      *msg = MSFAIL;
      goto wrapup;
    }
  }

  /* don't delete obj if no offset done */

  if(obj.objid != NULL_OBJID && fabs(offset) > 0.000001)
  {
    stat = om$send(msg      = message GRgraphics.GRdelete(msg,
							  md_env),
		   senderid = NULL_OBJID,
		   targetid = obj.objid,
		   targetos = obj.osnum );
    as$status(sts=stat);
    obj.objid = NULL_OBJID;
  }

wrapup:

  _FREE(lc_info);
  _FREE(inf_flag);

  __exitFunction ( name = "SMCrtOrdSfBnd" );

  return OM_S_SUCCESS;

}

end implementation Root;
