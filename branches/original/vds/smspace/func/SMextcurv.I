/* $Id: SMextcurv.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/func / SMextcurv.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMextcurv.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/01/08  16:56:08  pinnacle
# tr179802488
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/29  09:12:04  pinnacle
# Replaced: smspace/func/SMextcurv.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/09/99  ah      tr179802488, Added debug statements, fixed MALLOC problem
 *                   fixed _FREE problem causing core dump on Solaris 2.6
 * -------------------------------------------------------------------*/

/*             File SMextcurv.I                                            */
/*   Author : Jean Jasinczuk (ISDC)                                        */
/*   Creation date: 28 october 1992                                        */
/*                                                                         */
/*   Purpose : Given a curve and a range,  function SMExtToRange extend    */
/*   the curve  to the range                                               */  
/*   In this implementation, the curve must be in Oxy plan                 */

class implementation Root;

#include "math.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "growner.h"
#include "VDmem.h"

#include "bstypes.h"
#include "bserr.h"

#include "bsparameters.h"

/* PROTOTYPE */
#include "bsrgbxint.h"
#include "bsalloccv.h"
#include "bscv_copy.h"
#include "bslininter.h"
#include "bscvarrevt.h"
#include "bsprptoncv.h"
#include "bscveval.h"

#include "AS_status.h"

#define AS_DEBUG 1

#define DEBUG 1 

// #define vdsDEBUG 1
#include "v_dbgmacros.h"
            
from GRcurve import GRptextend,GRendpts,EMcrvslfint,EMpartofcv;            
from GRowner import GRget_number_components,GRget_components;            
from GRgraphics import GRconstruct,GRcopy,GRaltconstruct,
                       GRptproject,GRdelete,GRgetrang;
from GRvg  import  GRgetsize,GRgetgeom,GRgenabsg,GRpostabsg,GRputsymb;
from GRcompcurve import EMmakecomp,EMaddtocomp;

extern GRclassid OPP_GRlineseg_class_id,OPP_GRcompcurve_class_id;
extern GRclassid OPP_GR3dlineseg_class_id,OPP_GR3dlinestr_class_id;
extern GRclassid OPP_GRbcsubbc_class_id;

/* State of the two extreme point on the curve */
#define ON_CONTOUR 1
#define OUT_CONTOUR 2
#define IN_CONTOUR  3

#define EPSILON 0.000001

#ifndef	MAXFLOAT
#define	MAXFLOAT ((float)3.40282346638528860e+38)
#endif

/* ------------------ static int CurveInRange ------------------ */
/* Return TRUE if range of the curve intersect parameter range   */
/* Don't take care of z coordinate                               */

static int CurveInRange(curve,range,md_env)
struct GRid *curve;           /* [I] Curve */
IGRdouble range[];            /* [I] Range for test the curve */
struct GRmd_env *md_env;       /*[I] */
{
  IGRboolean world = TRUE,rg_flag;
  IGRdouble cvRange[6] ;
  IGRdouble dummy_rg[6];
  IGRlong status,msg;
  BSrc rc;
  
  status = om$send(msg = message GRgraphics.GRgetrang
		   (&msg,&md_env->md_env.matrix_type,
		    md_env->md_env.matrix, &world, cvRange ),
		   senderid = NULL_OBJID,
		   targetid= curve->objid,
		   targetos= curve->osnum );
  if(!(status & msg & 1))
   {
     printf("Error get range of curve %d %d\n",curve->objid,curve->osnum);
     return 0;
   }
  
  /* Don't take care of z range for curve */
  cvRange[2] = (range[2] + range[5])/2.0;
  cvRange[5] = (range[2] + range[5])/2.0;
  
  /* Range of the volume intersect range of the curve ? */
  BSrgbxint(&cvRange[0], &cvRange[3], &range[0], &range[3],
	    &rg_flag, &dummy_rg[0], &dummy_rg[3], &rc);
  if(rc != BSSUCC) { printf("Error intersect range\n"); return 0;}
  
  return rg_flag;
}

/* ------------------ static int GetCurvGeom ------------------ */
/* Get geometry of a curve  and the two endpoint                    */

static int GetCurvGeom(curve,md_env,geom,extrm_pt)
struct GRid *curve;
struct GRmd_env *md_env;
struct IGRbsp_curve **geom;
IGRdouble extrm_pt[];
{
  IGRlong status,msg;
  IGRlong size;
  struct IGRbsp_curve *tmp_geom = NULL;
  BSrc rc;

  /* Found  extremities points of the curve */
  status = om$send(msg = message GRcurve.GRendpts
		   (&msg,
		    &(md_env->md_env.matrix_type),  
		    md_env->md_env.matrix,
		    &extrm_pt[0],&extrm_pt[3]),
		   senderid = NULL_OBJID,
		   targetid = curve->objid,
		   targetos = curve->osnum );
  as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);

  status = om$send(msg = message GRvg.GRgetsize
		   (&msg, 
		    &md_env->md_env.matrix_type,  
		    md_env->md_env.matrix, 
		    &size ),
		   senderid = NULL_OBJID,
		   targetid = curve->objid,
		   targetos = curve->osnum );
  as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
 
  //tmp_geom = _MALLOC(size, struct IGRbsp_curve ); TR179802488
  tmp_geom = (struct IGRbsp_curve*)_MALLOC(size, IGRchar );
  if(tmp_geom == NULL) 
   {printf("ERROR, Bad dynamic allocation \n"); return 0;}
  
  status = om$send(msg = message GRvg.GRgetgeom
		   (&msg, 
		    &md_env->md_env.matrix_type, 
		    md_env->md_env.matrix, 
		    (char *)(tmp_geom)),
		   senderid = NULL_OBJID,
		   targetid = curve->objid,
		   targetos = curve->osnum );
  as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
  
  BSalloccv(tmp_geom->order,tmp_geom->num_poles,
	    tmp_geom->rational,tmp_geom->num_boundaries,
	    geom,&rc);
  if(rc != BSSUCC)
   {printf("Error alloc BS\n");goto wrapup;}
  
  /* Copy new curve geometry to old curv geometry */
  BScv_copy(&rc,tmp_geom,*geom);
  if(rc != BSSUCC) {printf("Error copy BS\n");return 0;}
  
  _FREE(tmp_geom);
  return 1;

 wrapup:
  _FREE(tmp_geom);
  return 0;
}

/* --------------------------------- SMProjRange ----------------------------- */
/* Project the figure determined by range on the plan defined by the Vz vector */
/* On this implementation, the Vz vector is supposed to be colinear to z axis  */

SMProjRange(range,Vz,Pt,prj_pts)
IGRdouble  range[];          /* [I] The range to project */
IGRvector Vz;                /* [I] The vector of projection */
IGRpoint  Pt;                /* [I] Point belonging to the plane */
IGRdouble prj_pts[];         /* [O] The projected figure */ 
{
  /* Verify the curve is on the (Oxy) plan  */
  if(fabs(Vz[0]) > EPSILON || fabs(Vz[1]) > EPSILON)
   {printf("Sorry: Not implemented when curve is not in (Oxy) plan\n");
    return 0;} 
  
  /* project the intersection on the surface */
  prj_pts[0] = range[0]; prj_pts[1] = range[1]; prj_pts[2] = Pt[2];
  prj_pts[3] = range[3]; prj_pts[4] = range[1]; prj_pts[5] = Pt[2];
  prj_pts[6] = range[3]; prj_pts[7] = range[4]; prj_pts[8] = Pt[5];
  prj_pts[9] = range[0]; prj_pts[10] = range[4]; prj_pts[11] = Pt[5];
  prj_pts[12] = prj_pts[0]; prj_pts[13] = prj_pts[1]; prj_pts[14] = prj_pts[2];  
  
  return 1;
}

/* ------------------ SMCrtBsFromRange ------------------ */
/* Create a closed linestring  from the projected range   */

static int CrtBsFromRange(proj_range,contour)
IGRdouble *proj_range;   /* [I] Figure determined by the projected range */
struct IGRbsp_curve **contour; /* [O] BS constructed */
{
  BSrc	rc;
  IGRint num_pts;
  IGRvector nvec;
  
  num_pts = 5;
  BSalloccv((IGRshort)2,num_pts,FALSE,0,contour,&rc);
  if(rc != BSSUCC || contour == NULL)
   {printf("Error alloc memory for contour curve\n"); return 0;}
  
  BSlininter( &rc,&num_pts, proj_range, *contour, nvec);
  if(rc != BSSUCC)
   {printf("Error construct contour\n"); return 0;}
  
  return 1;
}

/* ------------------ static int FindExtPt -------------------   */
/* Given geometry of curve,look for a point to extend lineary this  */
/* curve so it will go beyond the contour                           */

static int FindExtPt(range,contour,curv_geom,point,inter_pt)
IGRdouble range[];              /* [I] range of the contour */
struct IGRbsp_curve *contour;   /* [I] The contour to intersect */
struct IGRbsp_curve *curv_geom; /* [I] The planar curv_geom */
IGRpoint point;                 /* [I] Point of the curve to extend from */
IGRpoint inter_pt;              /* [O] New intersection point */
{
  BSrc rc;
  IGRpoint tgt_pts[1][2];
  IGRvector tgt_vec;
  IGRdouble pars,dis_fact; 
  IGRdouble *int_pts = NULL ,*par1 = NULL, *par2 = NULL;
  IGRdouble *over0 = NULL, *over1 = NULL, *end_pts = NULL; 
  IGRlong n_over;
  IGRint n_int;
  IGRboolean on_curve;
  struct IGRbsp_curve *line = NULL; 
 
  /* Find the value of the parameter corresponding to the point */
  BSprptoncv( &rc, curv_geom, point, &pars, &on_curve );
  if(rc != BSSUCC || !on_curve) return 0;
  
  /* Find the tangent at the point on the curve */
  dis_fact = 1.0; /* scale factor for tangent */
  BScvarrevt(curv_geom,&pars,1,dis_fact,tgt_pts,&rc);
  if(rc != BSSUCC)
   {printf("In FindExtPt error evaluate tangent\n");return 0;}

  /* If parameter is 0 , tangent is inverse sens */
  if(fabs(pars) < EPSILON)
    BSmkvec(&rc,tgt_vec,tgt_pts[0][1],tgt_pts[0][0]);
  else
    BSmkvec(&rc,tgt_vec,tgt_pts[0][0],tgt_pts[0][1]);
  
  /* create a line (starting at point) which intersect the contour */
  
  BSalloccv((IGRshort)2,4,FALSE,0,&line,&rc);
  if(rc != BSSUCC || line == NULL)
   {printf("Error alloc memory for line curve\n"); return 0;}
  
  BSmklnintbx(point,tgt_vec,&range[0],&range[3],FALSE,line,&rc); 
  if(rc !=  BSSUCC) { printf("Error construct line \n");return 0;}

  /* Find intersection point between line and contour  */
  BScvcv_int(&rc, contour,line, &n_int, 
	     &int_pts, &par1, &par2, &n_over, &end_pts,  
	     &over0, &over1);
  if(rc != BSSUCC )
   {printf("Error intersection of line and contour\n");return 0;} 
	
  inter_pt[0] = int_pts[0]; inter_pt[1] = int_pts[1]; inter_pt[2] = int_pts[2];

  if(line != NULL) BSfreecv(&rc,line);
  _FREE(par1);
  _FREE(par2);
  _FREE(int_pts);
  _FREE(over0);
  _FREE(over1);
  _FREE(end_pts);

  return 1;
}  


/* --------------------- static int SplitContour ---------------------- */
/* Split the contour in two curves determines by the two points   */

static int SplitContour(contour,pts,curve1,curve2)
struct IGRbsp_curve *contour;          /* [I] Contour to split */
IGRdouble pts[];                       /* [I] Points where to split contour */
struct IGRbsp_curve **curve1,**curve2; /* [O] BS constructed */ 
{
  BSrc rc;
  IGRshort order;
  IGRlong num_poles;
  IGRdouble Max;
  IGRdouble par1,par2;
  IGRboolean on_curve;
 
  order = contour->order;
  num_poles = contour->num_poles + 2 * order -1;
  
  BSalloccv(order,num_poles,contour->rational,contour->num_boundaries,
	    curve1,&rc);
  if(rc != BSSUCC){printf("Not enough memory\n"); return 0;}
  
  BSalloccv(order,num_poles,contour->rational,contour->num_boundaries,
	    curve2,&rc);
  if(rc != BSSUCC){printf("Not enough memory\n"); return 0;}
  
  /* Find the value of the parameter coresponding to  point 1*/
  BSprptoncv( &rc, contour, &pts[0], &par1, &on_curve );
  if(rc != BSSUCC || !on_curve)
   {printf("Error SplitContour find value of parameter point 1\n");return 0;}
  
  /* Find the value of the parameter coresponding to point 2 */
  BSprptoncv( &rc, contour, &pts[3], &par2, &on_curve );
  if(rc != BSSUCC || !on_curve)
     {printf("Error SplitContour find value of parameter point 2\n");return 0;}
  
  /* Split and keep interior parts  */
  BSpartofcv(&rc,contour,par1,(par1+par2)/2.0,par2,*curve1);
  if(rc != BSSUCC)
   { printf("Echec BSpartofcv 1\n"); return 0; }
  
  Max = par1 > par2 ? par1 : par2;
  
  /*  Split and keep exterior parts [Max/2 + 0.5 is superior to Max ] */
  BSpartofcv(&rc,contour,par1,Max/2.0 + 0.5,par2,*curve2);
  if(rc != BSSUCC)
   { printf("Echec BSpartofcv 2\n"); return 0;}
  
  return 1;
}

/* ------------------ static int IsValidPoints ----------------------  */
/* This function determine the state of points of curve relatively     */
/* to contour. If the point are on the contour or ouside, intersection */
/* with curve is returned. If point are inside contour,a point of      */
/* extension to the contour is return                                  */
/* It return 0 if some particular case: curves intersect contour more  */
/* than 2 times, etc ..                                                */

static int IsValidPoints(contour,range,curv_geom,extrm_pt,
			 inter_pt,state_pt)
struct IGRbsp_curve *contour;   /* [I] Contour defined by range */
IGRdouble range[];              /* [I] Range of contour */
struct IGRbsp_curve *curv_geom; /* [I] Geometrie of curve  */
IGRdouble extrm_pt[] ;         /* [I] Extreme point of curve */
IGRdouble inter_pt[];    /* [O] Intersection pts between curve and contour */
IGRshort state_pt[];     /* [O] Array for state of point (ON_CONTOUR ...)  */ 
{
  BSrc rc ;
  IGRdouble *int_pts = NULL ,*par1 = NULL, *par2 = NULL;
  IGRdouble *over0 = NULL, *over1 = NULL, *end_pts = NULL;
  IGRdouble pars,par_ext[2];
  IGRlong n_over;
  IGRint n_int = 0;
  int i,out_cont,on_cont,i_inter,nb_out = 0, nb_on = 0;
  IGRboolean on_curve,on_contour;
  
  /* Test if point is on contour or out contour */
  for(i=0;i<2;i++)
   {
     /* Find the value of the parameter coresponding to each point */
     BSprptoncv( &rc, contour,&extrm_pt[3*i], &par_ext[i], &on_contour );
     if(rc != BSSUCC){printf("Error with BSprptoncv\n");return 0;}
     
     if(on_contour) /* Point belong to the contour : copy point */
      {
	nb_on++;
	state_pt[i] = ON_CONTOUR;
	inter_pt[3*i] = extrm_pt[3*i];
	inter_pt[3*i+1] = extrm_pt[3*i+1];
	inter_pt[3*i+2] = extrm_pt[3*i+2];
      }
     else
       if(extrm_pt[3*i] < range[0] || extrm_pt[3*i+1] < range[1] ||
	  extrm_pt[3*i] > range[3] || extrm_pt[3*i+1] > range[4])
	{ /* Point is outside contour */
	  state_pt[i] = OUT_CONTOUR;
	  nb_out++;
	}
       else /* Point is inside contour */
	{
	  state_pt[i] = IN_CONTOUR;
	  /* Find extension of curve and beyond contour */
	  if(!FindExtPt(range,contour,curv_geom,
			&extrm_pt[3*i],&inter_pt[3*i]))
	   { printf("Error find extend points\n"); return 0; }
	}
   } 

  if(nb_out > 0)
   {
     /* Find intersection point between  curve and contour  */
     BScvcv_int(&rc, contour,curv_geom, &n_int, 
		&int_pts, &par1, &par2, &n_over, &end_pts,  
		&over0, &over1);
     if(rc != BSSUCC )
      {printf("Error intersection of line and contour\n");return 0;}
     
     /* The curve must split the contour exactly two times */
     switch(nb_out)
      {
      case 2:
	/* Not allowed when curve intersect contour on other side */
	if(n_int != 2) return 0; 
     
	/* Return the two intersections points */
	/* Return corresponding inter pt to extrm pt (see with parameter) */
	if(fabs(par_ext[0] - par2[0]) < fabs(par_ext[0] - par2[1]))
	  for(i=0;i<6;i++) inter_pt[i] = int_pts[i];
	else
	 {
	   for(i=0;i<3;i++) inter_pt[i] = int_pts[i+3];
	   for(i=0;i<3;i++) inter_pt[i+3] = int_pts[i]; 
	 }
	break;
	
      case 1:
	switch(nb_on)
	 { 
	 case 0:/* The other point is inside */
	   if(n_int != 1) return 0;    
	   out_cont = (state_pt[0] == OUT_CONTOUR) ? 0 : 1;
	   inter_pt[3*out_cont] = int_pts[0];
	   inter_pt[3*out_cont+1] = int_pts[1];
	   inter_pt[3*out_cont+2] = int_pts[2];
	   break;

	 case 1:
	   if(n_int != 2) return 0; /* Incoherence ! */ 
	   /* One point outside and one point on curve ==> two intersections */
	   on_cont = state_pt[0] == ON_CONTOUR ? 0 : 1;
	   out_cont = state_pt[0] == OUT_CONTOUR ? 0 : 1;
	   
	   /* Search indice of intersection point corresponding to point */
	   /* outside of curve. I compare parameter at epsilon because diff */
	   /* way to retreives them */

	   BSprptoncv( &rc, contour, &extrm_pt[3*on_cont], &pars, &on_curve );
	   if(rc != BSSUCC || !on_curve)
	    {printf("Error with BSprptoncv\n");return 0;}

	   i_inter = (fabs(pars - par1[0]) > EPSILON) ? 0 : 1;

	   inter_pt[3*out_cont] = int_pts[3*i_inter];
	   inter_pt[3*out_cont+1] = int_pts[3*i_inter+1];
	   inter_pt[3*out_cont+2] = int_pts[3*i_inter+2];
	   break;
	 } 
      }
   }
  
  _FREE(par1);
  _FREE(par2);
  _FREE(int_pts);
  _FREE(over0);
  _FREE(over1);
  _FREE(end_pts);
  
  return 1;
}

/* ---------------- static int ExtGeomToInterPt -----------------  */
/* Modify the geometry of curve to extend lineary to intersection  */
/* between contour and point (Modify in fact the pointer to point  */
/* to new geometry)                                                */

static int ExtGeomToInterPt(curv_geom,extrm_pt,inter_pt)
struct IGRbsp_curve **curv_geom; /* [I/O] The planar curv_geom */
IGRpoint extrm_pt;               /* [I] Point of the curve to extend from */
IGRpoint inter_pt;               /* [O] New intersection point */
{
  BSrc rc;
  struct IGRbsp_curve *geo_curv,*extcurv; 
 
  geo_curv = *curv_geom; /* To have simplest notation ! */

  /* Allocated memory for extend curve */ 
  if(geo_curv->order > 2)
    BSalloccv(geo_curv->order,2 * (geo_curv->order - 2) + geo_curv->num_poles,
	      geo_curv->rational,geo_curv->num_boundaries,&extcurv,&rc);
  else
    BSalloccv(geo_curv->order, geo_curv->num_poles + 1,
	      geo_curv->rational,geo_curv->num_boundaries,&extcurv,&rc);
  if(rc != BSSUCC)
    {printf("In ExtToInterPt error not enough memory\n");return 0;}


  /* Extend curve to the intersection point */
  BSlnxttpt(&rc,geo_curv,extrm_pt,inter_pt,extcurv);
  if(rc != BSSUCC)
    {printf("In ExtToInterPt error extend curve to inter pt\n");return 0;}

  /* Copy new curve geometry to old curve geometry (in fact copy pointer) */
  BSfreecv(&rc,*curv_geom);
  (*curv_geom) = extcurv;

  return 1;
}


/* ------------------ static int DelGeomToInterPt ------------------ */
/* Delete the specified segment (with to point) of the curve    */
/* Modify in fact the pointer to point  to new geometry)        */

static int DelGeomToInterPt(curv_geom,extrm_pt,inter_pt)
struct IGRbsp_curve **curv_geom;    /* [I/O]  The planar curv_geom */
IGRpoint extrm_pt;                  /* [I] */
IGRpoint inter_pt;                  /* [I] */
{
  BSrc	rc;
  struct IGRbsp_curve *split_curv = NULL,*dummy_curv = NULL;
  struct IGRbsp_curve *geo_curv; 
  IGRshort order;
  IGRlong num_poles;
  IGRdouble par1,par2,par3;
  IGRboolean on_curve;
  IGRint  num_cv;

  geo_curv = *curv_geom; /* To have simplest notation ! */
  
  order = geo_curv->order;
  num_poles = geo_curv->num_poles + 2 * order -1;
  
  BSalloccv(order,num_poles,geo_curv->rational,geo_curv->num_boundaries,
	    &split_curv,&rc);
  if(rc != BSSUCC){printf("Not enough memory\n"); return 0;}
  
  BSalloccv(order,num_poles,geo_curv->rational,geo_curv->num_boundaries,
	    &dummy_curv,&rc);
  if(rc != BSSUCC){printf("Not enough memory\n"); return 0;}
  
  /* Find the value of the parameter coresponding to each point */
  BSprptoncv( &rc, geo_curv, &extrm_pt[0], &par1, &on_curve );
  if(rc != BSSUCC || !on_curve){printf("Error point not on curve\n");return 0;}
  
  /* Find the value of the parameter coresponding to point 2 */
  BSprptoncv( &rc, geo_curv, &inter_pt[0], &par3, &on_curve );
  if(rc != BSSUCC || !on_curve)
   {printf("Error DelToInterPt find value of parameter point 2\n");return 0;}
  
  par2 = (par1 + par3)/2;
  
  /* Delete the part of the curve */
  BSpardelcv(geo_curv,par1,par2,par3,&num_cv,split_curv,dummy_curv,&rc);
  if(rc != BSSUCC)
   {printf("Error delete part of curve");return 0;}
  
  /* Copy new curve geometry to old curv geometry (in fact copy pointer) */
  BSfreecv(&rc,*curv_geom);
  (*curv_geom) = split_curv;
  
  if(dummy_curv) BSfreecv(&rc,dummy_curv);
  return 1;
}


/* ------------------ static int DelSelfInter -------------------------  */
/* This function look if curve self intersect                            */
/* If curve self intersect in only one point, keep part of curve between */
/* this two points.                                                      */
/* If the curve is close return curve itself                             */
/* If curve self intersect in more than 1 point return 0                 */

static int DelSelfInter(cst,curve,md_env,new_curv,destroy_old)
struct GRvg_construct *cst;  /* [I] Construction list */
struct GRid *curve;          /* [I] Curve to delete self intersect */
struct GRmd_env *md_env;     /* [I] Mod env of the object  */
struct GRid *new_curv;       /* [O] Curve obtain after delete self intersect */
IGRboolean destroy_old;      /* [I] If TRUE destroy old curve if new created */
{
  IGRlong status,msg;
  struct GRparms start_parm, mid_parm, end_parm;
  IGRlong pnt_slots  = 0,grand_num_pnt = 0,crv_slots = 0,grand_num_crv = 0;
  struct GRparms *my_pnt_inters = NULL;
  int return_flag = 0;
  struct IGRbsp_curve *curv_geom; 

  new_curv->objid = NULL_OBJID;
  new_curv->osnum = cst->env_info->md_id.osnum;

  /* If the curve is closed, return a copy of the curve */
  status = om$send(msg=message GRvg.GRgenabsg
		   (&msg, &md_env->md_env.matrix_type,
		    md_env->md_env.matrix,
		    (IGRchar **)&curv_geom),
		   senderid = NULL_OBJID,
		   targetid = curve->objid,
		   targetos = curve->osnum);
  as$status(sts = (status & msg),action = GOTO_VALUE,value = cleanup);
  
  if(curv_geom->phy_closed)
   { 
     new_curv->osnum = cst->env_info->md_id.osnum;
     status = om$send( msg = message GRgraphics.GRcopy
		      (&msg, md_env, cst->env_info,
		       &(new_curv->objid)),
		      senderid = NULL_OBJID,
		      targetid = curve->objid,
		      targetos = curve->osnum);
     as$status(sts = (status & msg),action = GOTO_VALUE,value = cleanup);
     return_flag = 1;
     goto cleanup;
   }
  
  /* Look if curve self intersect */
  status = om$send( msg = message GRcurve.EMcrvslfint
		   (
		    &msg,
		    cst,
		    &md_env->md_env,
		    &pnt_slots,      /* 0 slots allocated for inter info */
		    &grand_num_pnt,  /* number of intersections found */
		    NULL,            /* Point not required */
		    &my_pnt_inters, /* Params of intersection points */
		    NULL,           /* No XYZ of Point required */
		    &crv_slots,     /* 0 slot for overlapp curve */
		    &grand_num_crv, /* Number of overlapp curve */
		    NULL,           /* No overlapp Curve id required */
		    NULL            /* No Parameter of curve required */),
		   senderid = NULL_OBJID,
		   targetid = curve->objid,
		   targetos = curve->osnum);
  as$status(sts = (status & msg),action = GOTO_VALUE,value = cleanup);

  switch(grand_num_pnt)
   {
   case 0:
      return_flag = 1;goto cleanup;
    case 1:
      start_parm = my_pnt_inters[0];
      end_parm   = my_pnt_inters[1];
      mid_parm.u   = (end_parm.u + start_parm.u) / 2.0;
     
      status =  om$send (msg = message GRcurve.EMpartofcv
			(&msg,
			 &cst->env_info->md_env.matrix_type,
			 cst->env_info->md_env.matrix,
			 cst,
			 &start_parm, &mid_parm, &end_parm,
			 &new_curv->objid),
			 senderid = NULL_OBJID,
			 targetid = curve->objid,
			 targetos = curve->osnum);
      as$status(sts = (status & msg),action = GOTO_VALUE,value = cleanup);	
      return_flag = 1;
      break;
    default:
      printf("Curve intersect itself too much times\n");break;
    }

 cleanup:
 if(new_curv->objid != NULL_OBJID && return_flag && destroy_old)
  {
    status = om$send(msg = message GRgraphics.GRdelete(&msg,md_env),
		     senderid = NULL_OBJID,
		     targetid = curve->objid,
		     targetos = curve->osnum);
    as$status();
  }
  
  if(my_pnt_inters) om$dealloc(ptr = my_pnt_inters);
  return return_flag;
}


/* ------------------ static int ConstObjCurve --------------------- */
/* Construct two composite curves objects if split_contour is given  */
/* If split_cont[0] == NULL, construct simply a curve with curv_geom */

static int ConstObjCurve(cst,curve,md_env,split_cont,cv1,cv2)
struct GRvg_construct *cst;      /* [I] Construction list */
struct GRid *curve;              /* [I] Curve to extend to range  */
struct GRmd_env *md_env;         /* [I] Mod env of the object     */
struct IGRbsp_curve *split_cont[]; /* [I] Geometry of the 2 split contours */
struct GRid *cv1;                  /* [O] Composite curve returned */
struct GRid *cv2;                  /* [O] Composite curve returned */
{
  IGRlong status,msg;
  struct GRvg_construct tmp_cst;
  IGRlong comp_so_far,rotten_one;
  struct GRlc_info curv1_id[2],curv2_id[2];
  int i;
  BSrc rc ;
  IGRdouble dist_tol;

  for(i=0;i<2;i++)
   {
     curv1_id[i].located_obj.objid = NULL_OBJID;
     curv2_id[i].located_obj.objid = NULL_OBJID;
   }
 
  if(split_cont[0] == NULL) 
    /* No contour to split return curve */
   {
     *cv1 = *curve;
     return 1;
   }
  
  /* Construct a curve with first split contour  */
  tmp_cst = (*cst);
  tmp_cst.geometry = (char *)split_cont[0];
  curv1_id[1].located_obj.osnum = cst->env_info->md_id.osnum;
  curv1_id[1].module_info = *(cst->env_info);
  
  status = om$construct(msg = message GRgraphics.GRconstruct
			(&tmp_cst),
			classid = OPP_GR3dlinestr_class_id, 
			p_objid  = &curv1_id[1].located_obj.objid,
			osnum   = curv1_id[1].located_obj.osnum);
  as$status(action = GOTO_VALUE,value = wrapup);

  /* Construct a curve with split contour 2 */
  tmp_cst = (*cst);
  tmp_cst.geometry = (char *)split_cont[1];
  curv2_id[1].located_obj.osnum = cst->env_info->md_id.osnum;
  curv2_id[1].module_info = *(cst->env_info);
  
  status = om$construct(msg = message GRgraphics.GRconstruct
			(&tmp_cst),
			classid = OPP_GR3dlinestr_class_id, 
			p_objid  = &curv2_id[1].located_obj.objid,
			osnum   = curv2_id[1].located_obj.osnum);
  as$status(action = GOTO_VALUE,value = wrapup);

  if(SMIsKindOf(curve,OPP_GRcompcurve_class_id))
   {
     IGRdouble dummy_pt[6];

     *cv1 = *curve;

     cv2->osnum = cst->env_info->md_id.osnum;

     /* Contruct a copy of curve  */
     status = om$send( msg = message GRgraphics.GRcopy
		      (&msg, md_env, cst->env_info,
		       &(cv2->objid)),
		      senderid = NULL_OBJID,
		      targetid = curve->objid,
		      targetos = curve->osnum);
     as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);

     BSEXTRACTPAR(&rc, BSTOLLENVEC, dist_tol);
     if(rc != BSSUCC) {printf("Error dist_tol\n"); return 0;}

     comp_so_far = 0;
     status = om$send (msg = message GRcompcurve.EMaddtocomp
		       (
			&msg,
			curv1_id[1].located_obj,
			cst->env_info,
			cst->env_info,
			TRUE,       /* inter_allowed */
			MAXFLOAT,   /* search_tol */
			dist_tol,   /* connect_tol */
			FALSE,      /* no valid_end_pnt */
			&dummy_pt[0],
			&dummy_pt[3],
			&comp_so_far
			),
		       senderid = NULL_OBJID,
		       targetid = cv1->objid,
		       targetos = cv1->osnum);
     as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
     
     comp_so_far = 0;
     status = om$send (msg = message GRcompcurve.EMaddtocomp
		       (
			&msg,
			curv2_id[1].located_obj,
			cst->env_info,
			cst->env_info,
			TRUE,       /* inter_allowed */
			MAXFLOAT,   /* search_tol */
			dist_tol,   /* connect_tol */
			FALSE,      /* no valid_end_pnt */
			&dummy_pt[0],
			&dummy_pt[3],
			&comp_so_far
			),
		       senderid = NULL_OBJID,
		       targetid = cv2->objid,
		       targetos = cv2->osnum);
     as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
   }
  else
   {
     /* Copy the extend  curve so construct will be independant */
     
     curv1_id[0].module_info = *(cst->env_info);
     curv1_id[0].located_obj = *curve;

     curv2_id[0].located_obj.osnum = cst->env_info->md_id.osnum;
     curv2_id[0].module_info = *(cst->env_info);
     
     status = om$send( msg = message GRgraphics.GRcopy
		      ( &msg, md_env, cst->env_info,
		       &(curv2_id[0].located_obj.objid)),
		      senderid = NULL_OBJID,
		      targetid = curv1_id[0].located_obj.objid,
		      targetos = curv1_id[0].located_obj.osnum);
     as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);

     rotten_one = 0;
     cv1->osnum = cst->env_info->md_id.osnum;
     status = om$construct(msg = message GRcompcurve.EMmakecomp
			   (&msg,
			    cst->env_info, 
			    2,
			    curv1_id,
			    &rotten_one),
			   classid = OPP_GRcompcurve_class_id,
			   p_objid  = &cv1->objid,
			   osnum  = cv1->osnum );
     as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
     
     rotten_one = 0;
     cv2->osnum = cst->env_info->md_id.osnum;
     status = om$construct(msg = message GRcompcurve.EMmakecomp
			   (&msg,
			    cst->env_info,
			    2,
			    curv2_id,
			    &rotten_one),
			   classid = OPP_GRcompcurve_class_id,
			   p_objid  = &cv2->objid,
			   osnum  = cv2->osnum );
     as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
   }

  return 1;

 wrapup:
  /* Destroy intermediate object */
  for(i=0; i < 2 ; i++)
   {
     if(curv1_id[i].located_obj.objid != NULL_OBJID)
      {
	status = om$send(msg = message GRgraphics.GRdelete(&msg,cst->env_info),
			 senderid = NULL_OBJID,
			 targetid = curv1_id[i].located_obj.objid,
			 targetos = curv1_id[i].located_obj.osnum);
	as$status();
      }
     
     
     if(curv2_id[i].located_obj.objid != NULL_OBJID)
      {
	status = om$send(msg = message GRgraphics.GRdelete(&msg,cst->env_info),
			 senderid = NULL_OBJID,
			 targetid = curv2_id[i].located_obj.objid,
			 targetos = curv2_id[i].located_obj.osnum);
	as$status();
      }
   }
  
  return 0;
}

/* ------------------ static int AdjustCurve ---------------------- */
/* Copy the original curve and extend the copy beyond the contour   */ 

static int AdjustCurve(cst,curve,md_env,contour, range,extrm_pt,
		       inter_pt,ext_curve)
struct GRvg_construct *cst;     /* [I] Construction list */
struct GRid *curve;             /* [I] Curve to extend to range  */
struct GRmd_env *md_env;        /* [I] Mod env of the object     */
struct IGRbsp_curve *contour;   /* [I] Contour defined by range */
IGRdouble range[];              /* [I] range of curves */
IGRdouble extrm_pt[] ;          /* [I] Extreme point of curve */
IGRdouble inter_pt[];           /* [O] Intersection point of curve and contour */
struct GRid *ext_curve;         /* [O] The curve extend beyond range  */
{
  IGRlong status,msg,sts;
  BSrc rc ;
  IGRpoint newend;
  IGRboolean state_pt[2];
  int i,j;
  struct GRvg_construct tmp_cst;
  IGRdouble dummy_pt[6];
  struct IGRbsp_curve *curv_geom = NULL,*leaf_geom = NULL;
  struct GRparms proj_parms;
  struct GRid *curv_id = NULL;
  struct GRlc_info *comp_id = NULL;
  IGRlong rotten_one;
  IGRint count = 0;
  struct GRsymbology symb;

  __DBGpr_com("AdjustCurve Entered");
  
  if(!GetCurvGeom(curve,md_env,&curv_geom,extrm_pt)) return 0;
    __DBGpr_com("AdjustCurve GetCurvGeom");
  
  if(!IsValidPoints(contour,range,curv_geom,extrm_pt,inter_pt,state_pt)) {
    
    __DBGpr_com("AdjustCurve IsValidPoint wrapup");
    goto wrapup;
  }
  __DBGpr_com("AdjustCurve IsValidPoint");
  
  /* If composite curve, modify the end parts of composite only */
  if(SMIsKindOf(curve,OPP_GRcompcurve_class_id))
   {
     __DBGpr_com("AdjustCurve IsKindOf");
     /* Contruct a copy of curve  */
     /* We make it by hand because if only one component it will delete comp cv*/
     status = om$send( msg = message GRowner.GRget_number_components
		      (&msg,&count),
		      senderid = NULL_OBJID,
		      targetid = curve->objid,
		      targetos = curve->osnum);
     as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
     __DBGpr_com("AdjustCurve IsKindOf GRowner.GRget_number_components");

     curv_id = _CALLOC(count,struct GRid);
     comp_id = _CALLOC(count,struct GRlc_info);
     if(!curv_id || !comp_id) goto wrapup;

     status = om$send( msg = message GRowner.GRget_components
		      (&msg,md_env, curv_id, count,&count,0,count+1),
		      senderid = NULL_OBJID,
		      targetid = curve->objid,
		      targetos = curve->osnum);
     as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
     __DBGpr_com("AdjustCurve IsKindOf GRowner.GRget_components");

     for(i=0;i<count;i++)
       comp_id[i].located_obj.objid = NULL_OBJID;

     /* Extend geometry of component whose extrem point is in contour */
     for(i=0;i<2;i++)
      {
       if(state_pt[i] == IN_CONTOUR)
	{
	  /* Obtain leaf id of composent to modify */
	  status = om$send (msg = message GRgraphics.GRptproject
			    (&msg,
			     &md_env->md_env.matrix_type,
			     md_env->md_env.matrix,
			     &extrm_pt[3*i],
			     dummy_pt,
			     &proj_parms),
			    senderid = NULL_OBJID,
			    targetid = curve->objid,
			    targetos = curve->osnum);

	  __DBGpr_com("AdjustCurve GRgraphics.GRptproject");
	  
	  as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);

	  /* See geometry of new component */
	  if(!GetCurvGeom(&proj_parms.leaf_id,md_env,&leaf_geom,dummy_pt))
	    return 0;
	  if(!ExtGeomToInterPt(&leaf_geom,&extrm_pt[3*i],&inter_pt[3*i]))
	    goto wrapup;
	
	
	  /* Construct new component */
	  for(j=0;j<count;j++)
	   {
	     /* Find indice of component */ 
	     if(curv_id[j].objid == proj_parms.leaf_id.objid &&
		curv_id[j].osnum == proj_parms.leaf_id.osnum)
	      {
		comp_id[j].located_obj.osnum = cst->env_info->md_id.osnum;
		comp_id[j].module_info = *(cst->env_info);

		/* 17/12/92 To avoid having a surf of proj when component is */
		/* lineseg, we simply copy and extend line in this case      */
		/* If it's general curve, construct a new object with geometry */

		if(SMIsKindOf(&proj_parms.leaf_id,OPP_GRlineseg_class_id))
		 {
		   sts = om$send( msg = message GRgraphics.GRcopy
				    (&msg, md_env, cst->env_info,
				     &comp_id[j].located_obj.objid),
				    senderid = NULL_OBJID,
				    targetid = proj_parms.leaf_id.objid,
				    targetos = proj_parms.leaf_id.osnum);
		   as$status(sts=(sts & msg),action = GOTO_VALUE,value = wrapup);

		   sts = om$send(msg = message GRcurve.GRptextend
				    (&msg,cst->env_info,&extrm_pt[3*i],
				     &inter_pt[3*i],newend),
				    senderid = NULL_OBJID,
				    targetid = comp_id[j].located_obj.objid,
				    targetos = comp_id[j].located_obj.osnum);
		   as$status(sts=(sts & msg),action = GOTO_VALUE,value = wrapup);
		 }
		else  /* Construct new component with geometry */ 
		 {
		   tmp_cst = (*cst);
		   tmp_cst.geometry = (char *)leaf_geom;
		   tmp_cst.env_info = cst->env_info;
		   sts = om$construct(msg = message GRgraphics.GRconstruct
				      (&tmp_cst),
				      classid = OPP_GRbcsubbc_class_id,
				      p_objid = &(comp_id[j].located_obj.objid),
				      osnum  = comp_id[j].located_obj.osnum);
		   as$status(sts = sts,action = GOTO_VALUE,value = wrapup);
		 }
		break;
	      }
	   }
	}
       if(leaf_geom) { BSfreecv(&rc,leaf_geom); leaf_geom = NULL;}
     }
     __DBGpr_com("AdjustCurve IsKindOf Past first loop");

     /* Copy curve not modified and construct a composite with copy */
     /* and with modified curve */
     for(i = 0; i < count; i++)
      {
	/* Put cst symbology to this copy */
	symb.display_attr = *(cst->display);
	symb.level = cst->level;

	if(comp_id[i].located_obj.objid == NULL_OBJID)
	 {
	   comp_id[i].located_obj.osnum = cst->env_info->md_id.osnum; 
	   comp_id[i].module_info = *(cst->env_info); 
	   status = om$send( msg = message GRgraphics.GRcopy
			    (&msg, md_env, cst->env_info,
			     &comp_id[i].located_obj.objid),
			    senderid = NULL_OBJID,
			    targetid = curv_id[i].objid,
			    targetos = curv_id[i].osnum);
	   as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
	
	   status = om$send(msg = message GRvg.GRputsymb
			    (&msg,&symb),
			    senderid = NULL_OBJID,
			    targetid = comp_id[i].located_obj.objid,
			    targetos = comp_id[i].located_obj.osnum);
	   as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
	 }
      }
     __DBGpr_com("AdjustCurve IsKindOf Past second loop");
     
     rotten_one = 0;
     ext_curve->osnum = cst->env_info->md_id.osnum;
     status = om$construct(msg = message GRcompcurve.EMmakecomp
			   (&msg,
			    cst->env_info, 
			    count,
			    comp_id,
			    &rotten_one),
			   classid = OPP_GRcompcurve_class_id,
			   p_objid  = &ext_curve->objid,
			   osnum  = ext_curve->osnum );
     as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);

     __DBGpr_com("AdjustCurve IsKindOf GRcompcurve.EMmakecomp");

     /* If curve extend beyond range, cut parts beyond range */
     for(i=0;i<2;i++)
       if(state_pt[i] == OUT_CONTOUR)
	{
	  status = om$send(msg = message GRcurve.GRptextend
			   (&msg,cst->env_info,
			    &extrm_pt[3*i],&inter_pt[3*i],newend),
			   senderid = NULL_OBJID,
			   targetid = ext_curve->objid,
			   targetos = ext_curve->osnum);
     __DBGpr_com("AdjustCurve IsKindOf GRcurve.GRptextend x");
	  as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
     __DBGpr_com("AdjustCurve IsKindOf GRcurve.GRptextend y");
	}
   } /* If OPP_GRcompcurve_class_id */

  else  /* It's not a composite, modify geometry */
   {
     __DBGpr_com("AdjustCurve IsKindOf Not composite, modify");

     /* Modify curve geometry to delete or extend to new point */
     for(i=0;i<2;i++)
       switch(state_pt[i])
	{
	case IN_CONTOUR:
	  if(!ExtGeomToInterPt(&curv_geom,&extrm_pt[3*i],&inter_pt[3*i]))
	    goto wrapup;
	  break;
	   case OUT_CONTOUR:
	  if(!DelGeomToInterPt(&curv_geom,&extrm_pt[3*i],&inter_pt[3*i]))
	    goto wrapup;
	  break;
	case ON_CONTOUR:
	  break;  /* Nothing to do with curve */
	}

     tmp_cst = (*cst);
     tmp_cst.geometry = (char *)curv_geom;
     tmp_cst.env_info = cst->env_info;
     ext_curve->osnum = cst->env_info->md_id.osnum;

     status = om$construct(msg = message GRgraphics.GRconstruct
			   (&tmp_cst),
			   classid = OPP_GRbcsubbc_class_id, 
			   p_objid  = &ext_curve->objid,
			   osnum   = ext_curve->osnum);
     as$status(action = GOTO_VALUE,value = wrapup);
   }

  __DBGpr_com("AdjustCurve success");
  
  _FREE(curv_id); 
  _FREE(comp_id);
  if(curv_geom) BSfreecv(&rc,curv_geom);
  return 1;
  
 wrapup:
  __DBGpr_com("AdjustCurve wrapup");
  

  if(curv_geom) BSfreecv(&rc,curv_geom); 
  if(leaf_geom) BSfreecv(&rc,leaf_geom); 

  // TR179802488 moved these to after the GRdelete
  //_FREE(curv_id);
  //_FREE(comp_id);

  __DBGpr_com("AdjustCurve wrapup geom free");

  if(ext_curve->objid != NULL_OBJID)
   {
     status = om$send(msg = message GRgraphics.GRdelete(&msg,cst->env_info),
		      senderid = NULL_OBJID,
		      targetid = ext_curve->objid,
		      targetos = ext_curve->osnum);
     as$status();
   }
  __DBGpr_com("AdjustCurve wrapup GRdelete ext_curve");

  for(i = 0; i < count; i++)
    if(comp_id[i].located_obj.objid != NULL_OBJID)
     {
       om$send(msg = message GRgraphics.GRdelete(&msg,cst->env_info),
	      senderid = NULL_OBJID,
	      targetid = comp_id[i].located_obj.objid,
	      targetos = comp_id[i].located_obj.osnum);
       /* No examination of return code : some curve may not exists anymore */
     }

  __DBGpr_com("AdjustCurve wrapup GRdelete comp_id");

  // TR179802488 moved these here
  _FREE(curv_id);
  _FREE(comp_id);
  return 0;
}


/* -------------------------- int SMExtToRange ----------------------------- */
/*                            MAIN FUNCTION                                  */
/* Given a range and a projected curve, this fonction contruct a curve with  */
/* part of projected range and curve                                         */
/* If the given curve is closed, a copy of this curve is return              */
/* If the given curve self intersect, return closed curve bettween self inter*/
/* return 0 if problem, else return 1                                        */

int SMExtToRange(cst,curve,md_env,range,Vz,mindist,cv1,cv2)
struct GRvg_construct *cst;  /* [I] Construction list */
struct GRid *curve;          /* [I] Curve to extend to range   */
struct GRmd_env *md_env;     /* [I] Mod env of the object      */
IGRdouble range[];           /* [I] Range (given by two points) */
IGRdouble Vz[];              /* [I] Normal to  plan determined by curve*/
IGRdouble mindist;           /* [I] Minimum distance for equality of 2 points*/ 
struct GRid *cv1;            /* [O] Composite curve returned */
struct GRid *cv2;            /* [O] Composite curve returned */
{
  BSrc	rc;
  IGRdouble extrm_pt[6];
  IGRdouble inter_pt[6];
  IGRdouble proj_range[15];  
  struct IGRbsp_curve *contour = NULL;
  struct IGRbsp_curve *split_cont[2];
  struct IGRbsp_curve *curv_geom = NULL;
  struct GRid ext_curve;

  __DBGpr_com("SMExtToRange entered...");
  
  if(cv1 == NULL || cv2 == NULL) return 0;
  
  split_cont[0] = split_cont[1] = NULL;
  
  cv1->objid = cv2->objid = NULL_OBJID;
  
  if(!CurveInRange(curve,range,md_env)) return 0;
  __DBGpr_com("SMExtToRange CurveInRange");
 
  if(!GetCurvGeom(curve,md_env,&curv_geom,extrm_pt)) return 0;
  __DBGpr_com("SMExtToRange GetCurveGeom");

  /* Check if curve self intersect : if in more than 1 point, it's an error */
  if(!DelSelfInter(cst,curve,md_env,cv1,FALSE)) return 0;
  __DBGpr_com("SMExtToRange DelSelfInter");
  
  /* If curve self intersect in one point or is closed            */
  /* return curve without self inter (or copy of curve if closed) */
  if(cv1->objid != NULL_OBJID) goto cleanup;
  
  /* Project the range on the plane defined by the two ending point */
  if(!SMProjRange(range,Vz,&extrm_pt[0],proj_range))
    return 0;

  __DBGpr_com("SMExtToRange SMProjRange");
  
  /* Create a closed bspline from figure determined by projection */
  /* of range points*/
  if(!CrtBsFromRange(proj_range,&contour))
    return 0;

  __DBGpr_com("SMExtToRange CrtBsFromRange");

  /* Create a curve which intersect exactly range */
  if(!AdjustCurve(cst,curve,md_env,
		  contour,range,extrm_pt,inter_pt,&ext_curve))
    return 0;

  __DBGpr_com("SMExtToRange AdjustCurve");
  
  /* Modify curve geometry to delete some part if self intersection */
  if(!DelSelfInter(cst,&ext_curve,cst->env_info,cv1,TRUE)) return 0;

  __DBGpr_com("SMExtToRange DelSelfInter");

  /* If curve self intersect in one point or is closed            */
  /* return curve without self inter (or copy of curve if closed) */ 
  if(cv1->objid != NULL_OBJID)  goto cleanup;
  
  /* Gener two curves from contour given intersections points */
  if(!SplitContour(contour,inter_pt,&split_cont[0],&split_cont[1]))
    goto wrapup;

  __DBGpr_com("SMExtToRange SplitContour");

  /* Contruct curve(s) objects */
  if(!ConstObjCurve(cst,&ext_curve,md_env,split_cont,cv1,cv2))
    goto wrapup;

  __DBGpr_com("SMExtToRange Cleanup");
  
 cleanup:
#if 1
  if(contour) BSfreecv(&rc,contour);
  if(curv_geom) BSfreecv(&rc,curv_geom);
  if(split_cont[0]) BSfreecv(&rc,split_cont[0]);
  if(split_cont[1]) BSfreecv(&rc,split_cont[1]);
#endif
  return 1;
  
 wrapup:
#if 1
  if(contour) BSfreecv(&rc,contour);
  if(curv_geom) BSfreecv(&rc,curv_geom);
  if(split_cont[0]) BSfreecv(&rc,split_cont[0]);
  if(split_cont[1]) BSfreecv(&rc,split_cont[1]);
#endif
  
  return 0;
}

end implementation Root;




