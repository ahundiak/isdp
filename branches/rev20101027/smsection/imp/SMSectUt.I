/* $Id: SMSectUt.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsection/imp / SMSectUt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSectUt.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/09/20  19:10:22  pinnacle
# Replaced: smsection/imp/SMSectUt.I for:  by jwfrosch for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/29  09:04:02  pinnacle
# Replaced: smsection/imp/SMSectUt.I for:  by ksundar for vds.240
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
 *
 * -------------------------------------------------------------------*/

class implementation SMsection;

#include "math.h"
#include "OMmacros.h"
#include "OMindex.h"

#include "bsparameters.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsconic.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "emsedgedef.h"
#include "emsmapdef.h"
#include "emssfintdef.h"
#include "emsimpdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "EMS.h"
#include "EMScmacros.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSssprops.h"
#include "EMSconstruct.h"

#include "msdef.h"
#include "exmacros.h"

#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "csdef.h"
#include "csmacros.h"
#include "nddef.h"

#include "acdef.h"
#include "asbox.h"
#include "asdef.h"
#include "SMsection.h"
#include "VDmem.h"

#include "AS_status.h"

/* Prototypes */


#include "mainvmx.h"
#include "matypemx.h"
#include "maoptsxfo.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bscollin.h"
#include "bsmkvec.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bscvnormal.h"
#include "bstrans2.h"
#include "bscvoton.h"
#include "bscveval.h"
#include "bspt_in_cv.h"

#define SM_FAST_PROJ 1

from GRcoords 	import GRcvt_to_lcl_coords;
from EMSplane	import EMplane;
from GRcurve	import GRarea, GRrevparm;
from SMfrm_syst	import SMfind_frame_objid,SMcvt_frm_to_wld;
from SMframe	import SMgive_rel_position,SMfind_frm_syst;

/* ====================== SMSectSolPos  =============================

	function which determine first pos and incr if given solid,
	cs, nb_pos.
	(I)	struct GRmd_env	*cur_md_env	current md_env 
	(I)	struct GRvg_construct 	*cst;   construction list
	(I)	struct GRobj_env*coord_s 	coordinate system
	(I)	struct GRobj_env*solid 		solid
	(I)	char		axis		axis of cs to be ortho to plane
	(I)	IGRint		nb_pos		nb_pos for plane
	(O)	IGRdouble	*first_pos	firts pos on axis for plane
	(O)	IGRdouble	*last_pos	lst pos on axis for plane
	(O)	struct  SMsectdef *out_struct	returned structure
	(O)	IGRdouble	*AxisDir	axis direction
	(O)	long		*msg	    	completion code
	
	
===================================================================== */
int SMSectSolPos(msg, cst, cur_md_env, coord_s, solid, axis, nb_pos, 
		 first_pos, last_pos, out_struct, AxisDir)
IGRlong			*msg;
struct GRvg_construct 	*cst;
struct GRmd_env		*cur_md_env;
struct GRobj_env	*coord_s;
struct GRobj_env	*solid;
char			axis;
int			nb_pos;
IGRdouble		*first_pos;
IGRdouble		*last_pos;
IGRdouble		*AxisDir;
struct  SMsectdef 	*out_struct;
{
 IGRlong		num_pts, sts, loc_msg;
 IGRint			i;
 IGRboolean		world;
 struct IGRlbsys 	*p_geom;
 IGRshort		order, mat_type;
 IGRmatrix		invmat;
 IGRdouble		out_range[6], range[6], csrange[6], matrix[16], incr;

if(msg == NULL || cur_md_env == NULL || coord_s == NULL || solid == NULL ||
   first_pos == NULL || last_pos == NULL || out_struct == NULL || nb_pos < 2)
 {
	if(msg != NULL) *msg = EMS_E_InvalidArg;
	return(0);
 }

 *msg = MSFAIL;

 UI_status("Find the extremities\n");

 sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg, &coord_s->mod_env.md_env.matrix_type, 
				coord_s->mod_env.md_env.matrix,  (char **)&p_geom ),
		   senderid = NULL_OBJID,
	  	   targetid = coord_s->obj_id.objid,
	  	   targetos = coord_s->obj_id.osnum );
 as$status(sts=sts);  	   
 if (!(sts&(loc_msg)&1))
  { 
   printf("ERROR genabsg\n");
   goto wrapup;
  } 

 /* Fill the cs matrix */

 for(i=0;i<16;i++) matrix[i] = (* p_geom).matrix[i];

 world = TRUE;
 sts = om$send( msg = message GRgraphics.GRgetrang(&loc_msg, 
	&solid->mod_env.md_env.matrix_type, solid->mod_env.md_env.matrix, &world, range),
		  senderid = NULL_OBJID,
		  targetid = solid->obj_id.objid,
		  targetos = solid->obj_id.osnum );

 as$status(sts=sts);
 if(!(sts & (loc_msg) &1 ))
  {
   printf("ERROR getrange\n");
   goto wrapup;
  }

 sts = SMSectRange(msg, cst, cur_md_env, solid, matrix, axis, range, out_range, AxisDir);
 if(!(sts & (*msg) &1 ))
  {
   printf("ERROR SMSectRange\n");
   goto wrapup;
  }

 /* Transform range in our cs */

  order = 4;
  if(!MAinvmx(&loc_msg, &order, matrix, invmat)){
	printf("ERROR invert matrix \n"); 
	goto wrapup;
  }
  MAtypemx(&loc_msg, invmat, &mat_type);
  num_pts = 2;
  MAoptsxform(&loc_msg, &num_pts, &mat_type, invmat, out_range, csrange);
  

 incr = 0;
 if(axis == 'x' || axis == 'X') 
  {
   *first_pos 	= csrange[0];
   *last_pos 	= csrange[3];
   incr 	= (csrange[3]-csrange[0]) / (nb_pos-1);
  }
 else if(axis == 'y' || axis == 'Y') 
  {
   *first_pos 	= csrange[1];
   *last_pos 	= csrange[4];
   incr 	= (csrange[4]-csrange[1]) / (nb_pos-1);
  }
 else if(axis == 'z' || axis == 'Z') 
  {
   *first_pos 	= csrange[2];
   *last_pos 	= csrange[5];
   incr 	= (csrange[5]-csrange[2]) / (nb_pos-1);
  }

 /*| fill out_struct */

 out_struct->coord_syst = *coord_s;
 out_struct->solid 	= *solid;
 out_struct->axis 	= axis;
 out_struct->first_pos 	= *first_pos;
 out_struct->incr 	= incr;
 out_struct->nb_pos 	= nb_pos;
 out_struct->last_pos 	= *last_pos;

 *msg = MSSUCC;
 return OM_S_SUCCESS;

 wrapup:

  return OM_W_ABORT;
}



/* ====================== SMSectRange =============================
	function that return the range for the section (first and last
	intersection plane)
	(I)	struct GRmd_env	*cur_md_env	current md_env 
	(I)	struct GRobj_env*obj		the object
	(I)	struct GRvg_construct *cst;
	(I)	IGRchar		axis		normal of the planes
	(I)	IGRdouble	*in_range	EMS range of the object
	(O)	IGRdouble	*out_range	new range of the object
	(O)	IGRdouble	*AxisDir	axis direction
	(O)	long		*msg	    	completion code
	
===================================================================== */
int SMSectRange(msg, cst, cur_md_env, obj, matrix, axis, in_range, out_range, AxisDir)
IGRlong			*msg;
struct GRvg_construct 	*cst;
struct GRmd_env		*cur_md_env;
struct GRobj_env	*obj;
IGRdouble		*matrix;
IGRchar			axis;
IGRdouble		*in_range;
IGRdouble               *AxisDir;
IGRdouble		*out_range;
{
 IGRlong		sts, loc_msg;
 int			flag, type, i;
 IGRboolean		rg_flag, err_flag;
 IGRdouble		tol, lenght, normal[3], v1[3], v2[3], min_pt[3], 
			max_pt[3],pt[9];			
 struct GRid		plan_id1, plan_id2;
 struct GRobj_env	obj1;

#ifdef CLOCK
 IGRlong 		t, t1, t2;
#endif
 BSrc			rc;

 extern long		clock();

 if(msg == NULL || matrix == NULL || in_range == NULL || cur_md_env == NULL ||
	obj == NULL || out_range == NULL ){
	if(msg != NULL) *msg = EMS_E_InvalidArg;
	return(0);
}

#ifdef CLOCK
 t1 = clock();
#endif

 *msg     = MSFAIL;
 err_flag = FALSE;
 tol      = 0;


 if(axis == 'x' || axis == 'X') 
  {
   for(i=0;i<3;i++)
    {
     normal[i] 	= matrix[4*i +0];
     v1[i] 	= matrix[4*i +1];
     v2[i] 	= matrix[4*i +2];
    }
  }
 else if(axis == 'y' || axis == 'Y') 
  {
   for(i=0;i<3;i++)
    {
     normal[i] 	= matrix[4*i +1];
     v1[i]	= matrix[4*i +2];
     v2[i] 	= matrix[4*i +0];
    }
  }
 else if(axis == 'z' || axis == 'Z') 
  {
   for(i=0;i<3;i++)
    {
     normal[i] 	= matrix[4*i +2];
     v1[i] 	= matrix[4*i +0];
     v2[i] 	= matrix[4*i +1];
    }
  }

 for(i=0;i<3;i++) AxisDir[i] = normal[i];

 /* get pt of plane before min range */

 rg_flag = FALSE;

 sts = SMPlFarRange(&loc_msg, normal, in_range, rg_flag, min_pt);
 if(!(sts & (loc_msg) &1 ))
  {
   printf("ERROR SMPlFarRange\n");
   err_flag = TRUE;
   goto wrapup;
  }

 /* Get pt of plane before max range */

 rg_flag = TRUE;

 sts = SMPlFarRange(&loc_msg, normal, in_range, rg_flag, max_pt);
 if(!(sts & (loc_msg) &1 ))
  {
   printf("ERROR SMPlFarRange\n");
   err_flag = TRUE;
   goto wrapup;
  }

/* -----  
   the plane is defined bigger than range dimension and in front of
   the object. 
----- */

 lenght = 1.5 * BSdistptpt(&rc, &(in_range[0]), &(in_range[3]));
 if(rc != BSSUCC)
  {
   printf("ERROR BSdistptpt\n");
   err_flag = TRUE;
   goto wrapup;
 }
	

 /* Find the 3 pt defining the min plane */

 for(i=0;i<3;i++) pt[i]   = min_pt[i] - 10*v1[i] -10*v2[i];
 for(i=0;i<3;i++) pt[3+i] = pt[i] + lenght * v1[i];
 for(i=0;i<3;i++) pt[6+i] = pt[i] + lenght * v2[i];

 /* Construct the min plane */
 type = 0; /*rectangular plane */
 plan_id1.osnum = cst->env_info->md_id.osnum;
 plan_id1.objid = NULL_OBJID;
 
 sts = om$construct( msg = message EMSplane.EMplane((int *)&loc_msg, cst, 
						(IGRpoint *)pt,type),
                            osnum = plan_id1.osnum,
                            p_objid = &plan_id1.objid,
                            classid = OPP_EMSplane_class_id);
 as$status(sts = sts);
 if (!(sts&(loc_msg)&1))
  { 
   printf("ERROR EMSplane.EMplane\n");
   err_flag = TRUE;
   goto wrapup; 
  }

 flag = 0;


 obj1.obj_id = plan_id1;
 obj1.mod_env = *cur_md_env;

 sts = SMDist2Ele(&loc_msg, cur_md_env, obj, &obj1, pt, tol, 
		  NULL, &flag, &out_range[0], NULL);

 if (!(sts&(loc_msg)&1))
  { 
   printf("ERROR SMDist2Sf\n");
   err_flag = TRUE;
   goto wrapup; 
 }

 /* Find the 3 pt defining the max plane */

 for(i=0;i<3;i++) pt[i]   = max_pt[i] - 10*v1[i] -10*v2[i];
 for(i=0;i<3;i++) pt[3+i] = pt[i] + lenght * v1[i];
 for(i=0;i<3;i++) pt[6+i] = pt[i] + lenght * v2[i];

 /* Construct the max plane */

 type = 0; /*rectangular plane */
 plan_id2.osnum = cst->env_info->md_id.osnum;
 plan_id2.objid = NULL_OBJID;

 sts = om$construct( msg = message EMSplane.EMplane((int *)&loc_msg, cst, 
						(IGRpoint *)pt,	type),
                            osnum = plan_id2.osnum,
                            p_objid = &plan_id2.objid,
                            classid = OPP_EMSplane_class_id);
 as$status(sts = sts);
 if (!(sts&(loc_msg)&1))
  { 
   printf("ERROR EMSplane.EMplane\n");
   err_flag = TRUE;
   goto wrapup; 
 }

 flag = 0;

 obj1.obj_id = plan_id2;
 obj1.mod_env = *cur_md_env;

 sts = SMDist2Ele(&loc_msg, cur_md_env, obj, &obj1, pt, tol, 
		  NULL, &flag, &out_range[3], NULL);


 if (!(sts&(loc_msg)&1))
  { 
   printf("ERROR SMDist2Sf\n");
   err_flag = TRUE;
   goto wrapup; 
  }

wrapup:

#ifdef CLOCK
t2 = clock();
t=(t2-t1)/10000;
printf("time(*10 000): %ld \n",t);
t2=t1;
#endif

if(om$is_objid_valid(osnum = plan_id1.osnum,objid = plan_id1.objid) & 1){
	om$send(msg = message GRgraphics.GRdelete(&loc_msg,  cst->env_info),
		senderid = NULL_OBJID,
		targetid = plan_id1.objid ,
		targetos = plan_id1.osnum);
	plan_id1.objid = NULL_OBJID;
}

if(om$is_objid_valid(osnum = plan_id2.osnum,objid = plan_id2.objid) & 1){
	om$send(msg = message GRgraphics.GRdelete(&loc_msg,  cst->env_info),
		senderid = NULL_OBJID,
		targetid = plan_id2.objid ,
		targetos = plan_id2.osnum);
	plan_id2.objid = NULL_OBJID;
}

if(err_flag == TRUE)    return OM_W_ABORT;
else			return OM_S_SUCCESS;	

}




/* ====================== SMDist2Ele =============================

	function which determine the min dist between object1 and object2
	and return the points where the min happend (it is a relative min)
	
	(I)	struct GRmd_env	*md_env		current md_env 
	(I)	struct GRobj_env	*obj1 		first object
	(I)	struct GRobj_env	*obj2 		second object
	(I)	IGRdouble	*nearpt		pt where to search the min 
	(I)	IGRdouble	tol		tolerence 
	(O)	IGRdouble	*mdist		extremum dist returned
	(O)	IGRint		*flag		min = 1, max = 2,undefined=0
	(O)	IGRdouble	*pt1		minimum point on first elt 
	(O)	IGRdouble	*pt2		minimum point on second elt 
	(O)	long		*msg	    	completion code
	
	
===================================================================== */
int SMDist2Ele(msg, md_env, obj1, obj2, nearpt, tol,mdist, flag, pt1,pt2)
IGRlong			*msg;
struct GRmd_env		*md_env;	
struct GRobj_env	*obj1; 	
struct GRobj_env	*obj2; 	
IGRdouble		*nearpt;	
IGRdouble		tol;	/* not used */
IGRdouble		*mdist;	
IGRint			*flag;
IGRdouble		*pt1;	
IGRdouble		*pt2;	
{
int		stat, i, extremum, nb_time;
struct GRobj_env curr_obj; 	
IGRboolean	NOT_FOUND, err_flag;
IGRdouble	prj_tol,basis_tol, my_tol, dist, TOL, min_dist, proj_pt[3], 
		pt[3];
struct GRparms	proj_parms;
long		/* t1, t2, t, */ NumberOfBytes, BytesReceived;

extern  long	clock();

if(msg == NULL || md_env == NULL || obj1 == NULL || obj2 == NULL ||
	nearpt == NULL || tol < 0  ){
	if(msg != NULL) *msg = EMS_E_InvalidArg;
	return(0);
}


TOL = 0.1; /* hard codage de la tol */


err_flag 	= FALSE;
curr_obj 	= *obj1;
min_dist 	= 0.;
*msg 		=  EMS_S_Success;
 
NumberOfBytes = sizeof(basis_tol);
gr$get_basis_tolerance(	 msg    = msg, 
                         sizbuf = &NumberOfBytes, 
                         buffer = &basis_tol, 
                         nret   = &BytesReceived);

if(!((*msg)&1)){ 
    	printf("error gr$get_basis_tolerance\n"); 
    	err_flag = TRUE;
    	goto wrapup;
}


for(i=0;i<3;i++) pt[i] = nearpt[i];

/* 
   if the distance decrease one time the extremum will be a minimum
   if the distance increase one time the extremum will be a maximum
   if the distance is constant we can't know
   
*/

extremum = 0;
nb_time = 0;	
NOT_FOUND = TRUE;
while (NOT_FOUND){

   /* CH --> PASCALE
   /*
   /* Dans SMProjPt, tu recuperes a chaque fois the composants, tu malloc, ...
   /* Il faudrait le faire 1 fois seulement.
   /* J'ai enleve un display
   /*
   /*  */


	if(nb_time < 2) prj_tol = -1;
	else prj_tol = 1.01*min_dist; /* (dist + 1%dist) */
	prj_tol = -1; /* don't use prj_tol */

#ifdef	SM_FAST_PROJ
	stat = SMProjPt(msg, md_env, &curr_obj, pt, prj_tol, proj_pt, &dist);


    	if (!(stat&(*msg)&1)){ 
    		printf("ERROR SMproj_pt, send GRgraphics.GRptproject\n");
    		stat = om$send(msg = message GRgraphics.GRptproject(msg, 
					&curr_obj.mod_env.md_env.matrix_type, 
                                  	curr_obj.mod_env.md_env.matrix, 
					pt, proj_pt, &proj_parms),
		    senderid = NULL_OBJID,
	  	    targetid = curr_obj.obj_id.objid,
	  	    targetos = curr_obj.obj_id.osnum );
		as$status(sts=stat);
    		if (!(stat&(*msg)&1)){ 
    			printf("ERROR GRgraphics.GRptproject\n");
    			err_flag = TRUE;
    			goto wrapup; 
    		}
		MA2ptdis(msg, proj_pt, pt, &dist);
    	}
#else
	/*|project old*/
    	stat = om$send(msg = message GRgraphics.GRptproject(msg, 
					&curr_obj.mod_env.md_env.matrix_type, 
                                  	curr_obj.mod_env.md_env.matrix, 
					pt, proj_pt, &proj_parms),
		    senderid = NULL_OBJID,
	  	    targetid = curr_obj.obj_id.objid,
	  	    targetos = curr_obj.obj_id.osnum );
	as$status(sts=stat);
    	if (!(stat&(*msg)&1)){ 
    		printf("ERROR GRgraphics.GRptproject\n");
    		err_flag = TRUE;
    		goto wrapup; 
    	}
    	 
    	 
        /* Modef CH (8 Feb 92). The distance can be computed ... */
	MA2ptdis(msg, proj_pt, pt, &dist);
#endif


	if(dist< basis_tol && nb_time > 0) { 
		/*|dist nulle we have a minimum */
		extremum = 1;
		NOT_FOUND = FALSE;
		nb_time ++;
		break;
	}

	my_tol = dist - min_dist;
	
	if(nb_time == 1){
		if(my_tol > basis_tol) extremum = 2; /*normally impossible */
		else if(my_tol < basis_tol) extremum = 1;
		else extremum = 0;

	}

	my_tol = fabs(my_tol /dist);


/* CH --> PASCALE 
/*
/* Le test d'arret doit se faire sur la derive de l'evolution (comme dans
/* SMdist_2sf) c'est a dire:  (dist - previous_dist)/dist > x pour cent)
/*
/* */


	if(my_tol < TOL && nb_time > 0) {
		/*|my_tol is < TOL => end */
		NOT_FOUND = FALSE;
		nb_time ++;
		break;
	}
	if(curr_obj.obj_id.objid == obj2->obj_id.objid && 
		curr_obj.obj_id.osnum == obj2->obj_id.osnum)
			 	curr_obj = *obj1;
	else 			curr_obj = *obj2;
	min_dist = dist;
	for(i=0;i<3;i=i+1) pt[i] = proj_pt[i];
	nb_time ++;
		
}

if(flag != NULL) *flag = extremum;

/* At the end, proj_pt is on curr_obj and pt on the other */
/*|fill output arguments */
if(mdist != NULL){
	*mdist = dist;

}
if(pt1 != NULL){
	if(curr_obj.obj_id.objid == obj1->obj_id.objid && 
	curr_obj.obj_id.osnum == obj1->obj_id.osnum)
	 			for(i=0;i<3;i++) pt1[i] = proj_pt[i];
	else 			for(i=0;i<3;i++) pt1[i] = pt[i];

}		
if(pt2 != NULL){
	if(curr_obj.obj_id.objid == obj2->obj_id.objid && 
		curr_obj.obj_id.osnum == obj2->obj_id.osnum)
				for(i=0;i<3;i++) pt2[i] = proj_pt[i];
	else 			for(i=0;i<3;i++) pt2[i] = pt[i];

}		

wrapup:

if(err_flag == TRUE) 	return(0);
else			return(1);	


}




/* ====================== SMProjPt =============================

	function which project a point onto the object (faster than
	GRptproject if composite): If obj is composite, pt is projected
	only on component surfaces nearest from this point (GRptproject on 
	all components of the composite is too long).

	Nearest: if the 2 points defining the range of the component surface
	are out of a tolerence, pt is not project on this surface. 

	The tolerence is taken as the distance between pt and ptlim. 

	ptlim is the point on the segment range[0]-range[3] at a quarter 
	from range that is the nearest from pt.

	
	
	(I)	struct GRmd_env	*md_env		md_env 
	(I)	struct GRobj_env *obj 		object where to project
	(I)	IGRdouble	*pt		pt where to search the min 
	(I)	IGRdouble	user_tol	tol to project  
	(O)	IGRdouble	*proj_pt	projected point 
	(O)	IGRdouble	*min_dist	dist to project point 
	(O)	long		*msg	    	completion code
	
	
===================================================================== */
int SMProjPt(msg, md_env, obj, pt, user_tol,proj_pt,min_dist)
IGRlong			*msg;
struct GRmd_env		*md_env;	
struct GRobj_env 	*obj; 	
IGRdouble		*pt;	
IGRdouble		user_tol;	
IGRdouble		*proj_pt;	
IGRdouble		*min_dist;	
{
int		nb_sf,nb_retsf, stat, j,k,nb_time;
IGRboolean	world, err_flag;
IGRdouble	cmp_range[6], sav_pt[3],
		tol, prj_dist, sav_dist, min, max, *dist,dist1,dist2;
struct GRparms	proj_parms;
struct GRid	*compsf;
GRclassid	obj_classid;
BSrc		rc;


if(msg == NULL || md_env == NULL || obj == NULL || pt == NULL ||
	proj_pt == NULL ){
	if(msg != NULL) *msg = EMS_E_InvalidArg;
	return(0);
}


err_flag 	= FALSE;
*msg 		=  EMS_S_Success;

compsf = NULL;
dist = NULL;
min = max = -1;


stat = om$get_classid(osnum     = obj->obj_id.osnum, 
		      objid     = obj->obj_id.objid, 
		      p_classid = &obj_classid);
if( om$is_ancestry_valid(subclassid   = obj_classid,
			 superclassid = OPP_GRowner_class_id)
			        		!= OM_S_SUCCESS ){
	/*|object is not an owner, just send it GRgraphics.GRptproject	*/
	stat=om$send( msg = message GRgraphics.GRptproject(
						msg, 
						&obj->mod_env.md_env.matrix_type, 
                                		obj->mod_env.md_env.matrix, 
						pt, 
						proj_pt, 
						&proj_parms),
			senderid = NULL_OBJID,
                   	targetid = obj->obj_id.objid,
                   	targetos = obj->obj_id.osnum);
	as$status(sts=stat);
	if(!(stat & (*msg) &1 )){
		printf("ERROR GRgraphics.GRptproject\n");
		err_flag = TRUE;
		goto wrapup;
	}
	*min_dist = BSdistptpt(&rc, pt, proj_pt);
	goto wrapup;
}			       
  


nb_sf = 0;

stat = om$send(msg = message GRowner.GRget_number_components(
 							msg, &nb_sf),
		senderid = NULL_OBJID,
		targetid = obj->obj_id.objid,
		targetos = obj->obj_id.osnum );
as$status(sts = stat); 
if(!(stat & (*msg) &1 )){
	printf("ERROR GRowner.GRget_number_components\n");
	err_flag = TRUE;
	goto wrapup;
}

compsf = _MALLOC(nb_sf, struct GRid);
if(compsf == NULL){
	UI_status("Bad Memory allocation");
	err_flag = TRUE;
	goto wrapup;
}
dist = _MALLOC(nb_sf, IGRdouble);
if(dist == NULL){
	UI_status("Bad Memory allocation");
	err_flag = TRUE;
	goto wrapup;
}
nb_retsf = 0;
stat = om$send(msg = message GRowner.GRget_components(msg, 
					   &obj->mod_env, 
					   compsf,
					   nb_sf,
					   &nb_retsf,
					   0,
					   MAXINT),
		senderid = NULL_OBJID,
		targetid = obj->obj_id.objid,
		targetos = obj->obj_id.osnum );
as$status(sts = stat); 
if(!(stat & (*msg) &1 )){
	printf("ERROR GRowner.GRget_components\n");
	err_flag = TRUE;
	goto wrapup;
}


for(k=0;k<nb_sf;k=k+1){

 	world = TRUE;
	stat = om$send( msg = message GRgraphics.GRgetrang(msg, 
      					&obj->mod_env.md_env.matrix_type,
                                              obj->mod_env.md_env.matrix, 
                                              &world, 
                                              cmp_range),
		senderid = NULL_OBJID,
  		targetid = compsf[k].objid,
  		targetos = compsf[k].osnum );
	as$status(sts=stat);
	if(!(stat & (*msg) &1 )){
		printf("ERROR getrange\n");
		err_flag = TRUE;
		goto wrapup;
	}
	
	dist1 = BSdistptpt(&rc, pt, &(cmp_range[0]));
	dist2 = BSdistptpt(&rc, pt, &(cmp_range[3]));
	if(dist1<dist2) dist[k] = dist1;
	else dist[k] = dist2;
	if(min == -1 || dist[k] < min) min = dist[k];
	if(max == -1 || dist1 > max) max = dist1;
	if(max == -1 || dist2 > max) max = dist2;
	
}

tol = (max - min)*.2 +min;
if(user_tol > 0) tol = user_tol;

PROJECT:

sav_dist = max * 1.5; /* CH to take into account that the range is not  */
		      /* the exact position				*/
nb_time = 0;

for(k=0;k<nb_sf;k=k+1){
	if(dist[k]> tol) continue;

        nb_time ++; 
	stat=om$send( msg = message GRgraphics.GRptproject(
						msg, 
						&obj->mod_env.md_env.matrix_type, 
                                		obj->mod_env.md_env.matrix, 
						pt, 
						proj_pt, 
						&proj_parms),
			senderid = NULL_OBJID,
                   	targetid = compsf[k].objid,
                   	targetos = compsf[k].osnum);
	as$status(sts=stat);
	if(!(stat & (*msg) &1 )){
		printf("ERROR GRgraphics.GRptproject\n");
		err_flag = TRUE;
		goto wrapup;
	}
	prj_dist = BSdistptpt(&rc, pt, proj_pt);
	
	/* in case of problem init sav_pt if nb_time == 1 */

	if(prj_dist <= sav_dist || nb_time == 1){
		for(j=0;j<3;j=j+1) sav_pt[j] = proj_pt[j];
		sav_dist = prj_dist;
	}
	
}
for(j=0;j<3;j=j+1) proj_pt[j] = sav_pt[j];
*min_dist = sav_dist;

if(nb_time == 0){
		printf("WARNING,No component of composite are kept, increase tol tol\n");
		tol = tol * 1.5;
		goto PROJECT;
}

wrapup:


_FREE(compsf) ;
_FREE(dist) ;
if(err_flag == TRUE) 	return(0);
else			return(1);	
}


/* ====================== SMPlFarRange =============================

	function which return a plane out of the range of the object
	(on side given by min or max range) far enough to consider
	the min dist to the object as absolute. (pl_pt = translation 
	of range_pt along normal)

	(I)	IGRdouble	*normal		normal of the plane
	(I)	IGRdouble	*range		range of the object
	(I)	IGRboolean	rg_flag		0 = min 1 = max (side of rg)
	(O)	IGRdouble	*pl_pt		point defining plane 
	(O)	long		*msg	    	completion code
	
===================================================================== */
int SMPlFarRange(msg, normal, range, rg_flag, pl_pt)
IGRlong		*msg;
IGRdouble	*normal;	
IGRdouble	*range;	
IGRboolean	rg_flag;	
IGRdouble	*pl_pt	;
{
int			i;
IGRboolean		err_flag;
IGRdouble		side_rg[3], coef;

if(msg == NULL || normal == NULL || range == NULL || pl_pt == NULL ){
	if(msg != NULL) *msg = EMS_E_InvalidArg;
	return(0);
}


*msg = EMS_S_Success;
err_flag = FALSE;

if(rg_flag == FALSE)
	for(i=0;i<3;i++) side_rg[i] = range[i];
else 	
	for(i=0;i<3;i++) side_rg[i] = range[3+i];


/* CH dist_rg never used ... so comments */
/* dist_rg = BSdistptpt(&rc, &(range[0]), &(range[3]));
/* if(rc != BSSUCC){
/*	printf("ERROR BSdistptpt\n");
/*	err_flag = TRUE;
/*	goto wrapup;
/* }
/* */

coef = 1E7;	/* hardcodage */
for(i=0;i<3;i++)
	if(rg_flag == FALSE) 	pl_pt[i] = side_rg[i] - coef*normal[i];
	else 			pl_pt[i] = side_rg[i] + coef*normal[i];
	


if(err_flag == TRUE) return(0);
else		     return(1);	

}


/* ====================== SMSetSectDef =============================

	function fill the structure SMsectdef
	
	(I)	struct GRid		*coord_s 	coordinate system
	(I)	struct GRobj_env	*solid 		solid of section
	(I)	char			axis		axis of cs to be ortho to plane
	(I)	IGRdouble		first_pos	pos on axis for plane
	(I)	IGRdouble		incr		incr on axis for plane
	(I)	IGRint			nb_pos		nb_int on axis for plane
	(O)	struct  SMsectdef	*out_struct	returned structure
	(O)	long			*msg	    	completion code
	
	
===================================================================== */
int SMSetSectDef(msg, coord_s, solid, axis, first_pos, incr, nb_pos, out_struct)
IGRlong			*msg;
struct GRobj_env	*solid;
struct GRobj_env	*coord_s;
char			axis;
IGRdouble		first_pos;
IGRdouble		incr;
IGRint			nb_pos;
struct SMsectdef	*out_struct;
{
IGRboolean	err_flag;

if(msg == NULL || solid == NULL || coord_s == NULL || out_struct == NULL ){
	if(msg != NULL) *msg = EMS_E_InvalidArg;
	return(0);
}

if(axis != 'x' && axis != 'X' && axis != 'y' && axis != 'Y' 
	&& axis != 'z' && axis != 'Z'){
	if(msg != NULL) *msg = EMS_E_InvalidArg;
	return(0);
}

*msg = EMS_S_Success;
err_flag = FALSE;

/*| fill out_struct */

(*out_struct).coord_syst = *coord_s;
(*out_struct).solid = *solid;
(*out_struct).axis = axis;
(*out_struct).first_pos = first_pos;
(*out_struct).incr = incr;
(*out_struct).nb_pos = nb_pos;
(*out_struct).last_pos = first_pos + (nb_pos-1)*incr;


if(err_flag == TRUE) 	return(0);
else			return(1);	
}

/* ====================== SMCreateSection =============================

	function which create the curve section (intersect plane and solid) and 
	compute the area curve. (Fill the structure SMsect_int of the section
	at the given index ).
	
	Arguments:

(I)	struct  SMVolSect	*sections	sections 
(I)	struct  GRmd_env	*cur_md_env	module env.
(I)	IGRint			index		index of the curve to create
(I)	IGRdouble		pos_pl		position of plane to intersect
(O)	long			*msg	    	completion code
(I)	IGRboolean		area_comp       TRUE if area computation
	
	
===================================================================== */
int SMCreateSection(msg, cst, cur_md_env, sections, index, pos_pl, area_comp)
IGRlong			*msg;
struct GRvg_construct   *cst;
struct GRmd_env		*cur_md_env;
struct  SMVolSect	*sections;
IGRint			index;
IGRdouble		pos_pl;
IGRboolean		area_comp;
{
  int			start_index, ret, i, j,k,stat, num_inter;
  IGRdouble     	area, p[3], w[3];  
  struct IGRplane	plane;
  struct GRid		*OBJ;
  IGRboolean 		err_flag;
  struct GRlc_info	lc_obj;
  char			running[DI_PATH_MAX];
  struct GRmd_env	*sav_env;

if(msg == NULL || sections == NULL || cur_md_env == NULL){
	if(msg != NULL) *msg = EMS_E_InvalidArg;
	return(0);
}

OBJ = NULL;
*msg = EMS_S_Success;
err_flag = FALSE;

sections->sect_int[index].nb_cv = 0;

plane.point  = p;
plane.normal = w;


stat = SMPlFrmCs(msg, &(sections->sectdef.coord_syst),
		   sections->sectdef.axis, pos_pl, &plane);

if(!(stat & (*msg) &1)){
	printf("ERROR SMpl_frm_cs\n");
	err_flag = TRUE;
	goto wrapup;
}

		
/*| intersect volume and plane */
		
	
lc_obj.module_info = sections->sectdef.solid.mod_env;
lc_obj.located_obj = sections->sectdef.solid.obj_id;

		
num_inter = 0;

/*|send  GRvg.EMintplane*/

/* UTILISATION de EMintersect_surfaces .....  */


/* The section must be created with the cur_mod_env (macro mod env) */

sav_env = cst->env_info;
cst->env_info = cur_md_env;
stat = om$send(msg = message GRvg.EMintplane(cst, &plane, &lc_obj, &num_inter,
                                             &OBJ, &ret ),
                 senderid = NULL_OBJID,
                 targetid = lc_obj.located_obj.objid,
                 targetos = lc_obj.located_obj.osnum );
cst->env_info = sav_env;
as$status(sts=stat);
if (!(ret&stat&1))
 {
  printf("ERROR GRvg.EMintplane\n");
  err_flag = TRUE;
  goto wrapup;
 }

sections->sect_int[index].cv_area = 0;

if(area_comp == TRUE)
 {
  for(j=0;j<num_inter;j++)
   {
    /*|compute cv_area */
    area = 0;

    stat = om$send( msg      = message GRcurve.GRarea(msg,
                                             &cst->env_info->md_env.matrix_type,
                                             cst->env_info->md_env.matrix,
                                             &area ),
                        senderid = NULL_OBJID,
                        targetid = OBJ[j].objid,
                        targetos = OBJ[j].osnum );
    if (!((*msg)&stat&1))
     {
      sprintf(running,"%s%d%s","WARNING: intersection with plan ",index," not Closed");

      om$send(msg = message GRgraphics.GRdelete(msg, cst->env_info),
			senderid = NULL_OBJID,
			targetid = OBJ[j].objid ,
			targetos = OBJ[j].osnum);
      start_index = -1;
      for(k=0;k<sections->nb_alloc;k++){
		if(index == sections->tab[k]){
			start_index = k;
			break;
		}
      }
      for(k=start_index; k < sections->nb_planes - 1;k++) sections->tab[k] = sections->tab[k+1];
      sections->nb_planes = sections->nb_planes -1;
      goto wrapup; 
     }

    sections->sect_int[index].cv_area = sections->sect_int[index].cv_area + area;
   }
 }

sections->sect_int[index].pos_on_axis = pos_pl;
sections->sect_int[index].nb_cv       = num_inter;


sections->sect_int[index].curves = NULL;

if(num_inter < 1)
 {
  sprintf(running,"%s%d","Error: No intersection with plan: ",index);
  UI_status(running);		

  start_index = -1;
  for(k=0;k<sections->nb_alloc;k++){
		if(index == sections->tab[k]){
			start_index = k;
			break;
		}
  }
  for(k=start_index; k < sections->nb_planes - 1;k++) 
			sections->tab[k] = sections->tab[k+1];
   sections->nb_planes = sections->nb_planes -1;

  /* 
     PASCALE 20 JULY 93: if the solid is a disjoint union (compart) there are
     some planes that cannot intersect the solid without being an error.
     we must go on and not go out 
   */
 }

if(sections->sect_int[index].nb_cv)
 {
	
  sections->sect_int[index].curves = _MALLOC
		(sections->sect_int[index].nb_cv, struct GRid);
  if(sections->sect_int[index].curves == NULL)
   {
    *msg = EMS_E_DynamicMemoryAllocated;
    err_flag = TRUE;
    goto wrapup;
   }
 }

for(j=0;j<sections->sect_int[index].nb_cv;j++)
 {
  sections->sect_int[index].curves[j].objid = OBJ[j].objid;
  sections->sect_int[index].curves[j].osnum = OBJ[j].osnum;
 }
		
wrapup:

if(err_flag == TRUE) 
 {
  /*|delete curve objects */

  for(i=0;i<num_inter;i++)
   {
    om$send(msg = message GRgraphics.GRdelete(msg, cur_md_env),
			senderid = NULL_OBJID,
			targetid = OBJ[i].objid ,
			targetos = OBJ[i].osnum);
   }
  if(OBJ != NULL && num_inter > 0) _FREE( OBJ ) ;
  /* SMFreeComptInt(sections->sect_int[index]);
  /* */
  return(0);
 }

if(OBJ != NULL && num_inter > 0) _FREE(OBJ);
return(1);



}


/* ====================== SMPlFrmCs =============================

	function which returns a plane orthogonal to the given axis
	of the given coordinate system and at a given pos on this axis.
	
	(I)	struct GRobj_env*coord_s 	coordinate system
	(I)	char		axis		axis of cs to be ortho to plane
	(I)	IGRdouble	pos_on_axis	pos on axis for plane
	(O)	struct IGRplane *plane		returned plane
	(O)	long		*msg	    	completion code
	
	
===================================================================== */
int SMPlFrmCs(msg, coord_s, axis, pos_on_axis, plane)
IGRlong			*msg;
struct GRobj_env	*coord_s;
char			axis;
IGRdouble		pos_on_axis;
struct IGRplane 	*plane;
{
int		stat, i;
IGRboolean	err_flag;
struct IGRlbsys *p_geom;
IGRdouble	pt[3], x_col[3], y_col[3], z_col[3];


if(msg == NULL || coord_s == NULL || plane == NULL ){
	if(msg != NULL) *msg = EMS_E_InvalidArg;
	return(0);
}

if(axis != 'x' && axis != 'X' && axis != 'y' && axis != 'Y' 
	&& axis != 'z' && axis != 'Z'){
	if(msg != NULL) *msg = EMS_E_InvalidArg;
	return(0);
}

*msg = EMS_S_Success;
err_flag = FALSE;

/*|send GRgenabsg */

stat = om$send(msg = message GRvg.GRgenabsg(msg, &coord_s->mod_env.md_env.matrix_type, 
			coord_s->mod_env.md_env.matrix, (char **)&p_geom ),
		   senderid = NULL_OBJID,
	  	   targetid = coord_s->obj_id.objid,
	  	   targetos = coord_s->obj_id.osnum );
as$status(sts=stat);  	   
if (!(stat&(*msg)&1)){ 
	printf("ERROR genabsg\n");
	err_flag = TRUE; 
	goto wrapup; 
} 



/*|egalite with p_geom */
for(i=0;i<3;i++){
	x_col[i]	= (* p_geom).matrix[4*i+0];
	y_col[i] 	= (* p_geom).matrix[4*i+1];
	z_col[i] 	= (* p_geom).matrix[4*i+2];
	pt[i] 		= (* p_geom).matrix[4*i+3];
	
}

/*|fill  plane */

switch(axis){
	case 'x':
	case 'X': 	for(i=0;i<3;i++) pt[i] = pt[i] + pos_on_axis * x_col[i];
			for(i=0;i<3;i++) (*plane).point[i] = pt[i];
			for(i=0;i<3;i++) (*plane).normal[i] = x_col[i];
			break;
	
	case 'y':
	case 'Y': 	for(i=0;i<3;i++) pt[i] = pt[i] + pos_on_axis * y_col[i];
			for(i=0;i<3;i++) (*plane).point[i] = pt[i];
			for(i=0;i<3;i++) (*plane).normal[i] = y_col[i];
			break;
	case 'z':
	case 'Z': 	for(i=0;i<3;i++) pt[i] = pt[i] + pos_on_axis * z_col[i];
			for(i=0;i<3;i++) (*plane).point[i] = pt[i];
			for(i=0;i<3;i++) (*plane).normal[i] = z_col[i];
			break;
}


wrapup:

if(err_flag == TRUE) 	return(0);
else			return(1);	

}

/* ====================== SMFreeSection =============================

	function which free the structure SMVolSect.
	
	Arguments:

(I)	struct  SMVolSect	p_struct;
	
	
===================================================================== */
int SMFreeSection(p_struct)
struct  SMVolSect	*p_struct;

{
int	i;

if(p_struct->sect_int != NULL)
 {
  for(i=0;i<p_struct->nb_alloc;i++)
    {
     if(p_struct->sect_int[i].curves != NULL) 
      {
       free(p_struct->sect_int[i].curves);
       p_struct->sect_int[i].curves = NULL;
      }
    }
   free(p_struct->sect_int); p_struct->sect_int = NULL;
  }

if(p_struct->tab != NULL) 
 {
  free(p_struct->tab);
  p_struct->tab = NULL;
 }

return(1);
}


/* ====================== SMFreeComptInt =============================

	function which free the structure SMsect_int.
	
	Arguments:

(I)	struct  SMsect_int	p_struct;
	
	
===================================================================== */
int	SMFreeComptInt(p_struct)
struct  SMsect_int	p_struct;
{
 if( p_struct.curves != NULL)
  {
   _FREE(p_struct.curves);
   p_struct.curves = NULL;
  }
 return(1);
}


/* ====================== SMPrintSection =============================

	function which print the structure SMVolSect.
	
	Arguments:

(I)	struct  SMVolSect	p_struct;
	
	
===================================================================== */
SMPrintSection(p_struct)
struct  SMVolSect	p_struct;
{
int	i;

printf("\n ............ SMVolSect ............\n");
SMPrintSectDef(p_struct.sectdef);
printf("nb_alloc: %d\n",p_struct.nb_alloc);
printf("nb_planes: %d\n",p_struct.nb_planes);
if(p_struct.tab != NULL){
  for(i=0;i<p_struct.nb_alloc;i++)
	printf("tab: %d\n",p_struct.tab[i]);
	
}
if(p_struct.sect_int != NULL) {
  for(i=0;i<p_struct.nb_alloc;i++){
	SMPrintComptInt(p_struct.sect_int[i]);
  }
	
}
printf("......................................\n\n");

return(1);

}

/* ====================== SMPrintComptInt =============================

	function which print the structure SMsect_int.
	
	Arguments:

(I)	struct  SMsect_int	p_struct;
	
	
===================================================================== */
SMPrintComptInt(p_struct)
struct  SMsect_int	p_struct;
{
int	i;

printf("\n ............ SMSectInt ............\n");
printf("pos_on_axis: %lf\n",p_struct.pos_on_axis);
printf("cv_area: %lf\n",p_struct.cv_area);
printf("nb_cv: %d\n",p_struct.nb_cv);
if(p_struct.curves != NULL){ 
	for(i=0;i<p_struct.nb_cv;i++)
		printf("curves: %d, %d\n",p_struct.curves[i].objid, p_struct.curves[i].osnum);
}
printf("......................................\n\n");

return(1);

}

/* ====================== SMPrintSectDef =============================

	function which print the structure SMsectdef.
	
	Arguments:

(I)	struct  SMsectdef	p_struct;
	
	
===================================================================== */
SMPrintSectDef(p_struct)
struct  SMsectdef	p_struct;
{

printf("\n ............ SMSectDef ............\n");
printf("coord_syst: %d, %d\n", p_struct.coord_syst.obj_id.objid, 
			       p_struct.coord_syst.obj_id.osnum);
printf("solid_obj: %d, %d\n", p_struct.solid.obj_id.objid, 
			       p_struct.solid.obj_id.osnum);
/*printf("solid_envid: %d, %d\n", p_struct.solid.mod_env.md_id.objid, 
/*			       p_struct.solid.mod_env.md_id.osnum);
/* */
printf("axis: %c\n",p_struct.axis);
printf("first_pos: %lf\n",p_struct.first_pos);
printf("incr: %lf\n",p_struct.incr);
printf("nb_pos: %d\n",p_struct.nb_pos);
printf("last_pos: %lf\n",p_struct.last_pos);

printf("......................................\n\n");

return(1);

}
/* ============================================================ */
 
#define SM_MAX_CAL_SECT_CV  100

SMSetSectFeet2(nb_feet, feet_list, sect_int, mod_env, AxisDir)
IGRint		  *nb_feet;	/* Number of feet		(I/O)	*/
struct GRid	  *feet_list;	/* Feet array			(I/O)	*/
struct SMsect_int *sect_int;	/* Object to test		 (I)	*/
struct GRmd_env   *mod_env;	/* Current module env		 (I) 	*/
IGRdouble         *AxisDir;     /* Axis direction                (I)    */
{
 IGRlong	    sts, loc_msg;
 GRclassid	    obj_classid;
 extern GRclassid   OPP_GRgrgrp_class_id;
 IGRint		    count, i, j, nb_cv;
 struct GRid	    curves[SM_MAX_CAL_SECT_CV];
 IGRdouble          OrientPt[3];
 IGRboolean         cv_area[SM_MAX_CAL_SECT_CV], BelongTo[SM_MAX_CAL_SECT_CV], rev;
 BSrc		    rc;
 struct GRprops     GRprops ;

 /* Expand all the curves */
 nb_cv = 0; 
 for(j=0;j<sect_int->nb_cv;j++)
  {
   om$get_classid(osnum     = sect_int->curves[j].osnum, 
		  objid     = sect_int->curves[j].objid, 
		  p_classid = &obj_classid);

   if(om$is_ancestry_valid(subclassid   = obj_classid,
			   superclassid = OPP_GRgrgrp_class_id) == OM_S_SUCCESS)
    {
     /* Get its components */
     sts = om$send(msg = message GRowner.GRget_number_components(&loc_msg, &count),
			senderid = NULL_OBJID,
			targetid = sect_int->curves[j].objid, 
			targetos = sect_int->curves[j].osnum);
     as$status(sts = sts, action = RET_STATUS);

     if(count < 1)
      {
       /* Empty group !!!! */
       continue;
      }

     if(count + nb_cv > SM_MAX_CAL_SECT_CV)
      {
       printf("Too many calculation sections\n");
       count = SM_MAX_CAL_SECT_CV - nb_cv;
      }

     sts = om$send(msg = message GRowner.GRget_components(&loc_msg, mod_env,
                          &curves[nb_cv], count, &count, 0, count),
			senderid = NULL_OBJID,
			targetid = sect_int->curves[j].objid, 
			targetos = sect_int->curves[j].osnum);
     as$status(sts = sts, action = RET_STATUS);
    
     nb_cv += count;

     /* Delete the group object */
     sts = om$send(msg = message GRowner.GRdelete_owner(&loc_msg, mod_env),
			senderid = NULL_OBJID,
			targetid = sect_int->curves[j].objid, 
			targetos = sect_int->curves[j].osnum);
     as$status(sts = sts);
    }
   else
    {
     curves[nb_cv++] = sect_int->curves[j];
    }
  }

 if(nb_cv < 0) 
  {
   /* No calculation section ??? */
   return 0;
  }

 /* verify that the curve are planar and closed */
 for(i=0;i<nb_cv;i++)
  {
   if(curves[i].objid == NULL_OBJID) continue;
   sts = om$send( msg = message GRvg.GRgeomprops(&loc_msg,
              &mod_env->md_env.matrix_type,  mod_env->md_env.matrix, &GRprops),
                        senderid = NULL_OBJID,
                        targetid = curves[i].objid,
                        targetos = curves[i].osnum );
     if (!((loc_msg)&sts&1))
      {
       /* Error getting Calculation section info (remove it) */
       printf("Error getting Calculation section info (remove it)\n");
       curves[i].objid = NULL_OBJID;
      }
     if(!GRprops.planar) 
      {
       /* Warning; Calculation section, curve not planar (remove it) */
       printf("Warning; Calculation section (feet #: %d), curve not planar readjust) \n", *nb_feet);
       /* curves[i].objid = NULL_OBJID; */
      }

     if(!GRprops.phy_closed)
      {
       /* Warning; Calculation section, curve not closed (remove it) */
       printf("Warning; Calculation section (feet #: %d), curve not closed, readjust\n", *nb_feet);
       /* curves[i].objid = NULL_OBJID; */
       /* Get the end points */
       
       /* dist < cht */
       
       /* modify end points */
       /* curves[i].objid = NULL_OBJID; */
      }
    }

 if(!(SMFdEnCrv(nb_cv, curves, mod_env, cv_area, BelongTo) & 1))
  {
   printf("Error finding inclosed curved\n");
   return 0;
  }

 for(i=0;i<nb_cv;i++)
  {
   if(curves[i].objid == NULL_OBJID) continue;
   if(SMGetOrientPt(&curves[i], mod_env, OrientPt) == 0) return 0;
    
   rev = FALSE;
   if(cv_area[i] == TRUE)
    {
     /* Area, Must be clockwise (AxisDir) */
     if(BSdotp(&rc, AxisDir, OrientPt) < 0) rev = TRUE;
    }
   else 
    {
     /* Hole, Must be counter clockwise */
     if(BSdotp(&rc, AxisDir, OrientPt) > 0) rev = TRUE;
    }

   if(rev == TRUE)
    {
     /* Reverse the curve */
     sts = om$send( msg = message GRcurve.GRrevparm(&loc_msg, mod_env),
                            senderid = NULL_OBJID,
			    targetid = curves[i].objid,
			    targetos = curves[i].osnum);
     if (!((loc_msg)&sts&1)) return 0;
    }

   feet_list[(*nb_feet)++] = curves[i];
  }
 return 1;
}

/* ====================== SMUserCut =============================

	function which create the section as defined by user (nb_cut from
	begin_pos to end_pos ). 
	
	Arguments:

(I)	struct GRvg_construct	*cst		construction list
(I)	struct GRmd_env		*cur_md_env	macro occ mod env
(I)	IGRint			nb_cut		nb of cut wanted
(I)	IGRdouble		begin_pos	first pos of the cut
(I)	IGRdouble		end_pos		last pos of the cut
(I)	IGRdouble		offset		offset for end of solid
(I)	struct  SMsectdef	*vol_sect	def of section 
(O)	struct  SMVolSect	*section	returned section
(O)	long			*msg	    	completion code
(I)	IGRboolean		area_comp	TRUE if area computation
(I)	IGRint			cur_part	Current part.
(I)	IGRint			nb_parts	Number of parts.
	
===================================================================== */
int SMUserCut(msg, cst, cur_md_env, nb_cut, begin_pos ,end_pos, offset, 
	      vol_sect, section, area_comp, cur_part, nb_parts)
IGRlong			*msg;
struct GRvg_construct	*cst;
struct GRmd_env		*cur_md_env;
IGRint			nb_cut;
IGRdouble		begin_pos;
IGRdouble		end_pos;
IGRdouble		offset;
struct  SMsectdef	*vol_sect;
struct  SMVolSect	*section;
IGRboolean		area_comp;
IGRint			cur_part;
IGRint			nb_parts;
{
int		nb_curves, nb_inters,stat, i,j,k;
IGRdouble	pos_pl,basis_tol,delta1[3], delta2[3], dirvect[3],matrix[16],pos1,pos2,
 		Incr, tmp_pos;
IGRboolean	err_flag, transl1, transl2;
struct GRmd_env	act_env;
GRobjid		newobjid;
struct IGRlbsys *p_geom;
short		matrix_type;
IGRchar		tmp_string[50];
long		NumberOfBytes, BytesReceived;

if(msg == NULL || vol_sect == NULL|| section == NULL || nb_cut == 0){
	if(msg != NULL) *msg = EMS_E_InvalidArg;
	return(0);
}

*msg = EMS_S_Success;
err_flag = FALSE;

(*section).sect_int 	= NULL;
(*section).tab      	= NULL;
(*section).nb_planes 	= 0;
(*section).nb_alloc 	= 0;

NumberOfBytes = sizeof(basis_tol);
gr$get_basis_tolerance(	 msg    = msg, 
                         sizbuf = &NumberOfBytes, 
                         buffer = &basis_tol, 
                         nret   = &BytesReceived);

if(!((*msg)&1)){ 
    	printf("error gr$get_basis_tolerance\n"); 
    	err_flag = TRUE;
    	goto wrapup;
}

if(begin_pos > end_pos){

	/* exchanged begin_pos and  end_pos*/

	tmp_pos = begin_pos;
	begin_pos = end_pos;
	end_pos = tmp_pos;

}

pos1 = begin_pos;
pos2 = end_pos;
transl1 = transl2 = TRUE; /* translate if end of solid */

if((begin_pos < vol_sect->first_pos && end_pos < vol_sect->first_pos) ||
(begin_pos > vol_sect->last_pos && end_pos > vol_sect->last_pos) ){
	UI_status("ERROR, Given positions are out of the solid");
	printf("ERROR, Given positions are out of the solid\n");
	err_flag = TRUE;
	goto wrapup;
}

if(begin_pos <vol_sect->first_pos) {pos1 = vol_sect->first_pos; transl1 = TRUE;}
if(end_pos > vol_sect->last_pos) {pos2 = vol_sect->last_pos;transl2 = TRUE;}


if( fabs(pos2-pos1) < basis_tol ){
	UI_status("ERROR, Given positions are out of the solid");
	printf("ERROR, Given positions are out of the solid\n");
	err_flag = TRUE;
	goto wrapup;
	
}
Incr = (pos2 - pos1)/(nb_cut-1);


/*| get current module env */


stat = om$send(msg = message GRvg.GRgenabsg(msg, 
	   &vol_sect[0].coord_syst.mod_env.md_env.matrix_type, 
	    vol_sect[0].coord_syst.mod_env.md_env.matrix, (char **)&p_geom ),
		   senderid = NULL_OBJID,
	  	   targetid = vol_sect[0].coord_syst.obj_id.objid,
	  	   targetos = vol_sect[0].coord_syst.obj_id.osnum );
as$status(sts=stat);  	   
if (!(stat&(*msg)&1)){ 
	printf("ERROR genabsg\n");
	err_flag = TRUE; 
	goto wrapup; 
} 
if(vol_sect->axis == 'x' || vol_sect->axis == 'X') 
	for(i=0;i<3;i++) dirvect[i] = (* p_geom).matrix[4*i+0];
if(vol_sect->axis == 'y' || vol_sect->axis == 'Y') 
	for(i=0;i<3;i++) dirvect[i] = (* p_geom).matrix[4*i+1];
if(vol_sect->axis == 'z' || vol_sect->axis == 'Z') 
	for(i=0;i<3;i++) dirvect[i] = (* p_geom).matrix[4*i+2];
	

section->sectdef.coord_syst 	= vol_sect->coord_syst;
section->sectdef.solid 		= vol_sect->solid;
section->sectdef.axis 		= vol_sect->axis;
section->sectdef.first_pos 	= pos1;
section->sectdef.incr 		= Incr;
section->sectdef.nb_pos 	= nb_cut;
section->sectdef.last_pos 	= pos2;
section->nb_alloc 		= nb_cut;
section->nb_planes 		= nb_cut;
section->sect_int 		= _MALLOC
			(section->nb_alloc, struct SMsect_int);
if(section->sect_int == NULL)
 {
  *msg = EMS_E_DynamicMemoryAllocated;
  err_flag = TRUE;
  goto wrapup;
 }

section->tab = _MALLOC	(section->nb_alloc, int);
if(section->tab == NULL)
 {
  *msg = EMS_E_DynamicMemoryAllocated;
  err_flag = TRUE;
  goto wrapup;
 }
for(k=0;k<section->nb_alloc;k++)
 {
  section->tab[k] 			= k;
  section->sect_int[k].nb_cv 		= 0;
  section->sect_int[k].pos_on_axis 	= 0;
  section->sect_int[k].cv_area 		= 0;
  section->sect_int[k].curves 		= NULL;
 }
nb_curves = 0;

/******
   nb_planes is modified by SMCreateSection, nb_inters is the number
   of intersection to do 
*********/

nb_inters = nb_cut;
if(offset > Incr/2 )
 {
  /*|offset is > incr/2 take incr/50 */
  UI_status("WARNING: Offset is > incr, we take offset=incr/50");
  offset = Incr / 50;
 }
if(offset > 0 && offset < Incr/50) offset = Incr/50;  

for(k=0;k<nb_inters;k++)
 {
  /* get plane for volume */

  sprintf(tmp_string,"Compute calcul. section %d/%d, part %d/%d\n", k+1, nb_inters, cur_part+1, nb_parts);
  UI_status(tmp_string);
  pos_pl = pos1 + k * Incr;
  section->sect_int[k].pos_on_axis = pos_pl;

  /*  ----
	pour k=0 et k=nb_cut -1 
	decale pos_pl de offset pour ne pas 
	etre aux limites
		
  ------ */


  /* Set the end part offset */

  if(k == 0 && transl1) pos_pl = pos_pl + offset;
  if(k == nb_cut - 1 && transl2) pos_pl = pos_pl - offset;

  cst->geometry = NULL;
  stat = SMCreateSection(msg, cst, cur_md_env, section, k, pos_pl, area_comp);
  if (!(stat&(*msg)&1))
   { 
    printf("ERROR SMCreateSection stat= %ld, msg=%ld\n",stat,*msg);
    err_flag = TRUE; 
    goto wrapup; 
   }
  if(section->sect_int[k].nb_cv > 0) nb_curves ++;
  else printf("Warning intersection %d failed\n", k);
 }

if(nb_curves < 2)
 {
  UI_status("ERROR: Less than 2 curves constructed for a volume");
  err_flag = TRUE;
  goto wrapup;
 }

if(!transl1 && !transl2) goto wrapup;

UI_status("translate of last curves");

for(k=0;k<3;k++) delta1[k] = 0.;
for(k=0;k<3;k++) delta2[k] = 0.;

/*|compute delta1 for curves */

for(k=0;k<3;k++)
 {
  delta1[k] = -section->tab[0] * Incr * dirvect[k];
  delta2[k] = (nb_cut - 1 - section->tab[section->nb_planes-1]) * 
			Incr * dirvect[k];
 }

if(section->sectdef.axis == 'x' || section->sectdef.axis == 'X') 
 {
  if(section->tab[0] == 0) delta1[0] = delta1[0] - offset;
  if(section->tab[section->nb_planes -1] == section->nb_planes - 1) delta2[0] = delta2[0] + offset;
 }
if(section->sectdef.axis == 'y' || section->sectdef.axis == 'Y') 
 {
  if(section->tab[0] == 0) delta1[1] = delta1[1] - offset;
  if(section->tab[section->nb_planes -1] == section->nb_planes - 1) delta2[1] = delta2[1] + offset;
 }
if(section->sectdef.axis == 'z' || section->sectdef.axis == 'Z') 
 {
  if(section->tab[0] == 0) delta1[2] = delta1[2] - offset;
  if(section->tab[section->nb_planes -1] == section->nb_planes - 1) delta2[2] = delta2[2] + offset;
 }


if(transl1)
 {
  /* translate the first curve at first_pos = section->tab[0] */

  for(j=0;j<section->sect_int[section->tab[0]].nb_cv;j++)
   {

    MAtrlmx(msg, delta1, matrix);
    MAtypemx(msg, matrix, &matrix_type);
    stat = om$send(msg = message GRgraphics.GRxform(msg, cur_md_env, 
					&matrix_type, matrix, &newobjid ),
                  	senderid = NULL_OBJID,
  	   		targetid = section->sect_int[section->tab[0]].curves[j].objid,
  	   		targetos = section->sect_int[section->tab[0]].curves[j].osnum );
    as$status(sts=stat);  	   
    if (!((*msg)&stat&1))
     {
      printf("ERROR GRgraphics.GRxform\n");
      err_flag = TRUE;
      goto wrapup;
     }
   }
 }

if(transl2)
 {
  /* translate last curve at last_pos = section->tab[section->nb_planes-1] */

  for(j=0;j<section->sect_int[section->tab[section->nb_planes -1]].nb_cv;j++)
   {

    MAtrlmx(msg, delta2, matrix);
    MAtypemx(msg, matrix, &matrix_type);
    stat = om$send(msg = message GRgraphics.GRxform(msg, cur_md_env, 
					&matrix_type, matrix, &newobjid ),
                  	senderid = NULL_OBJID,
  	   		targetid = section->sect_int[section->tab[section->nb_planes -1]].curves[j].objid,
  	   		targetos = section->sect_int[section->tab[section->nb_planes -1]].curves[j].osnum );
    as$status(sts=stat);  	   
    if (!((*msg)&stat&1))
     {
      printf("ERROR GRgraphics.GRxform\n");
      err_flag = TRUE;
      goto wrapup;
     }
   }
 }

 /* Restore the end part offset */

 if(transl1) section->sect_int[section->tab[0]].pos_on_axis -= offset;
 if(transl2) section->sect_int[section->tab[section->nb_planes - 1]].pos_on_axis += offset;

wrapup:
UI_status("");
UI_message("");

if(err_flag == TRUE) 
 {
  if(section != NULL)
   {
    for(k=0;k<section->nb_planes;k++)
     {
      for(j=0;j<section->sect_int[section->tab[k]].nb_cv;j++)
       {

	if(om$is_objid_valid(osnum = section->sect_int[section->tab[k]].curves[j].osnum,
			     objid = section->sect_int[section->tab[k]].curves[j].objid) & 1)
	 {
	  om$send(msg = message GRgraphics.GRdelete(msg, &act_env),
			senderid = NULL_OBJID,
			targetid = section->sect_int[section->tab[k]].curves[j].objid ,
			targetos = section->sect_int[section->tab[k]].curves[j].osnum);
	 }
       }
     }
   SMFreeSection(section); 
   }
  return(0);
 }
else return(1);
}


/* ============================================================ 
/*
	Description :
								- 92/05/14 -
     Given a closed planar curve, this function computes a point which 
  indicates the orientation of the encompassing plane.  More precisely,
  the point is computed so that the curve is positively oriented according
  to the normal defined from the plane to this point.

	Algorithm :

     First, we build a list of points from the poles of the curve (note : the 
  curve may be also a composite one).  If the curve is a rational one, the 
  poles are divided by their weight.
     Secondly, we get the center of gravity of our list.
     Then, the area delimited by the linestring (defined by our list) is 
  computed by a sum of cross products.  Note that the area is an oriented
  one which allows us to obtain a point defining the encompassing plane
  orientation. 	

  Copied from get_orientation_pt (AC).

 * ============================================================ */

SMGetOrientPt(curve_id, obj_env, vz)
struct GRid     	*curve_id      ; /* I */
struct GRmd_env         *obj_env       ; /* I */
IGRdouble		*vz            ; /* O */

{
IGRpoint		center ;	/* barycenter of linestring */
IGRvector		area, partial_area, vector1, vector2 ;
struct IGRbsp_curve 	*curve_geom  ;	
IGRdouble		*list     ; 	/* linestring of poles */
IGRlong			num_bytes ;
IGRlong 		msg, stat ;
BSrc			bsrc ;
IGRint			i, j, taille ;
IGRint			rc_func   ;

curve_geom = NULL ;
list       = NULL ;

/*
	1) Get points of linestring
 */

stat = om$send(	msg = message GRvg.GRgetsize(&msg,
				             &obj_env->md_env.matrix_type,
				             obj_env->md_env.matrix,
             			             &num_bytes),
                senderid = NULL_OBJID,
		targetid = curve_id->objid,
		targetos = curve_id->osnum) ;
as$status(sts = stat) ; 
if (!(stat & msg & 1)) { rc_func = 0; goto wrapup ; }

curve_geom = (struct IGRbsp_curve *) _MALLOC(num_bytes, char) ;
if (curve_geom ==  NULL) { rc_func = 0 ; goto wrapup ; }

stat = om$send( msg = message GRvg.GRgetgeom(&msg,
				             &obj_env->md_env.matrix_type,
				             obj_env->md_env.matrix,
				             (IGRchar *)curve_geom),
                senderid = NULL_OBJID,
		targetid = curve_id->objid,
		targetos = curve_id->osnum) ;
as$status(sts = stat) ; 
if (!(stat & msg & 1)) { rc_func = 0; goto wrapup ; }

taille = curve_geom->num_poles * 3 * sizeof(IGRdouble) ;
list   = _MALLOC(taille, IGRdouble) ;
if (list ==  NULL) { rc_func = 0 ; goto wrapup ; }

if (! curve_geom->rational) {
	memcpy(	(char *) list, (char *) curve_geom->poles, (int) taille) ;
	}
else {
	/* Rational B-spline curve */
	for (i = 0 ; i < curve_geom->num_poles ; i = i+1) {
	   for (j = 0 ; j < 3 ; j = j+1) {
		list[3*i+j] = curve_geom->poles[3*i+j] / curve_geom->weights[i] ;
		}
	   }
	} /* else */

/*
	2) Compute barycenter of linestring
 */

center[0] = 0 ; center[1] = 0 ; center[2] = 0 ;
for (i = 0 ; i < curve_geom->num_poles ; i = i+1) {
	for (j = 0 ; j < 3 ; j = j+1) {
		center[j] = center[j] + list[3*i+j] ;
		}
	}
for (j = 0 ; j < 3 ; j = j+1) {
	center[j] = center[j] / curve_geom->num_poles ;
	}

/*
	3) Compute oriented area, and find an orientation point
 */

area[0] = 0 ; area[1] = 0 ; area[2] = 0 ;
for (i = 0 ; i < curve_geom->num_poles-2 ; i = i+1) {

	/* 
		Start from the first pole to the last but one pole 
	 */

	BSmkvec (&bsrc, vector1, center, &list[3*i])     ;
	if (bsrc != BSSUCC) { rc_func = 0 ; goto wrapup ; }
	BSmkvec (&bsrc, vector2, center, &list[3*(i+1)]) ;
	if (bsrc != BSSUCC) { rc_func = 0 ; goto wrapup ; }

	BScrossp(&bsrc, vector1, vector2, partial_area) ;
	if (bsrc != BSSUCC) { rc_func = 0 ; goto wrapup ; }

	for (j = 0 ; j < 3 ; j = j+1) {
		area[j] = area[j] + partial_area[j] ;
		}
	} /* for */

BSnorvec(&bsrc, area) ;
if (bsrc != BSSUCC) { rc_func = 0 ; goto wrapup ; }
for (j = 0 ; j < 3 ; j = j+1) vz[j] = area[j] ;


rc_func = 1; /* success */

wrapup :

	_FREE (curve_geom) ;
	_FREE (list ) ;

	return rc_func ;
} 

 /*============================================================
  * SMFdEnvCrv: 
  *
  * To find if curve are curves position. We can have
  *
  *			- Separated curves,
  *			- Inclosed curves.
  *	The assumption of loop is taken.
  *
  * Algorithm;
  *
  *		- For each curve look at if two points (or three if strange
  *		  result) are inside or outside.
  *
  *		- Curve which does not belong to another curve or has 2 * N
  *		  dependancies is enclosing area.
  *
  *		- Curve which belong to another curve with 2 * N +1 
  *		  dependancies
  *
  *  BelongTo[i] == -1 if does not belong to somebody else it is the index
  *  of the top .
  *
  * Test with FdEnCrv.u:
  * 	Seems ok even if the curve are not in xy plane.
  *     Seems ok even if some curves are in ref file
  *     Pb if there are only an intersection (bad result of SMIsCrvInsCrv).
  *    if a part of a curve is inside an other one but not the entire
  *    curve CrvArea = 1 but BelongTo[i] = index of the curve of the top
  * ============================================================*/

SMFdEnCrv(NbCv, Crv, ModEnv, CrvArea, BelongTo)
IGRint		NbCv;		/* Number of closed curved    (I) */
struct GRid	Crv[];		/* Array of curves	      (I) */
struct GRmd_env *ModEnv;	/* Current module env	      (I) */
IGRboolean      CrvArea[];	/* True if enclosing area     (O) */
IGRboolean      BelongTo[];	/* Index to who it belongs to (O) */ 
{
 IGRlong		status, msg, size;
 IGRint			i, j, k;
 struct IGRbsp_curve 	*CurCrv,  *C2;
 IGRboolean		Ins;
 IGRdouble		TMat[3][3], TVec[3], NewZ[3], scale;
 BSrc			rc;
 
 CurCrv = NULL;
 C2 = NULL;

 if(NbCv <  1) return 0;

 for(i=0;i<NbCv;i++) 
  {
   CrvArea[i] = TRUE;
   BelongTo[i] = -1;
  }

 if(NbCv == 1) return 1;

 for(i=0;i<NbCv;i++) 
  {
   status = om$send(msg = message GRvg.GRgetsize(&msg, 
   					         &ModEnv->md_env.matrix_type, 
					         ModEnv->md_env.matrix,
						 &size),
                   	senderid = NULL_OBJID,
                   	targetid = Crv[i].objid,
                   	targetos = Crv[i].osnum);
   if(!(status & msg & 1)) return 0;

   if(size <= 0) return 0;
   CurCrv  = (struct IGRbsp_curve *) _MALLOC(size, char);
   if(CurCrv == NULL ) return 0;

   GRabsg_del_all();
   status = om$send(msg = message GRvg.GRgetgeom(&msg, 
   					         &ModEnv->md_env.matrix_type, 
					         ModEnv->md_env.matrix,
                                                 (IGRchar *) CurCrv),
                     senderid = NULL_OBJID,
                     targetid = Crv[i].objid,
                     targetos = Crv[i].osnum);
   if(!(status & msg & 1)) {
 	_FREE(CurCrv) ; 
	return 0;
   }
   /* Because I don't know a way of knowing if a point belong to a planar
    * curve.
    *     Get the rotation matrix (good for everybody).
    *     transform the curves.
    */

   /* NewZ is the unit normal vector to the planar curve */

   BScvnormal(&rc, CurCrv, NewZ) ;
   if(rc != BSSUCC) {
 	_FREE(CurCrv) ; 
	return 0;
   }

   /* TMat will be the rotation matrix to transform to a new cs with z axis
	is given by NewZ
   */

   BStrans2(NewZ, TRUE, TMat, &rc);
   if(rc != BSSUCC) {
 	_FREE(CurCrv) ;
	return 0;
   }
   TVec[0] = 0; TVec[1] = 0; TVec[2] = 0;
   scale = 1;

   /* transform the curve in the new cs (TVec,TMat,scale), now the curve
	is on xy plane */

   BScvoton(&rc, TVec, TMat, &scale, CurCrv, CurCrv);
   if(rc != BSSUCC) {
 	_FREE(CurCrv) ;
	return 0;
   }
   for(j=0;j<NbCv;j++) 
    {
     if(j==i) continue;
     GRabsg_del_all();
     status = om$send(msg = message GRvg.GRgenabsg(&msg, 
   					       &ModEnv->md_env.matrix_type, 
					       ModEnv->md_env.matrix,
                                               (IGRchar **) &C2),
                     senderid = NULL_OBJID,
                     targetid = Crv[j].objid,
                     targetos = Crv[j].osnum);
     if(!(status & msg & 1)) {
 	_FREE(CurCrv) ;
	return 0;
     }
     TVec[0] = 0; TVec[1] = 0; TVec[2] = 0;
     scale = 1;
     BScvoton(&rc, TVec, TMat, &scale, C2, C2);
     if(rc != BSSUCC) {
 	_FREE(CurCrv) ;
	return 0;
     }
     if(!(SMIsCrvInsCrv(CurCrv, C2, &Ins) & 1)) {
 	_FREE(CurCrv) ;
	return 0;
     }
     if(Ins)
      {
       if(CrvArea[i] == TRUE) CrvArea[i] = FALSE;
       else		      CrvArea[i] = TRUE;
       BelongTo[i] = j;
      }
    }
   _FREE(CurCrv) ;
  }

 /* Set Well the BelongTo index */
 for(i=0;i<NbCv;i++) 
  {
   k = BelongTo[i];
   if(k==-1) continue;

   while(1)
    {
     if(BelongTo[k] == -1)
      {
       BelongTo[i] = k;
       break;
      }
     k = BelongTo[k];
    } 
  }
 _FREE(CurCrv) ;
 return 1;
}
 
/* ============================================================
 * SMIsCrvInsCrv:
 *
 *    Ins = TRUE if CurCrv is inside Crv.
 *
 * Notes: works only if Crv is on the xy plane, and closed.
 * Test with IsCvInCv.u: doesn't work if intersection (the point is inside
 * the curve but not all the points) But normally never happen.
 * ============================================================ */

SMIsCrvInsCrv(CurCrv, Crv, Ins)
struct IGRbsp_curve 	*CurCrv;	/* Curve structure 	   (I) */
struct IGRbsp_curve 	*Crv;		/* Other Curve structure   (I) */
IGRboolean		*Ins;
{
 IGRint			Inside; /* 1=> inside, 2 => on, 0 => outside	(O) */
 BSrc			rc;
 IGRboolean		OrientKnow, Orient;
 IGRdouble		par;
 IGRpoint               pt[1];
 /* Jean : Change for 2.2 : replace IGRdouble pt[6]  */

 /*
  * This works only on xy plane (BSpt_in_cv determines if the input point 
  *	is inside a closed, planar curve in the xy plane).
  * 
  * I don't believe it ....
  */

  /* PASCALE 20 JULY 93: Must verify first if the curves intersect =>outside 
     because in that case, a point can be in or out and that doesn't mean
     anything
   */

 par = 0.1;
 while(par<0.99)
  {
   /* Take any point on the right curve */
   
   BScveval(CurCrv, par, 0, pt, &rc);
   if(rc != BSSUCC)
    {
     printf("Error in BScveval\n");
     return 0;
    }

   OrientKnow = FALSE;
   BSpt_in_cv(Crv, pt[0], OrientKnow, &Orient, &Inside, &rc);
   if(rc != BSSUCC)
    {
     printf("Error in BSpt_in_cv\n");
     return 0;
    }
   if(Inside != 2) break;
   par = par + 0.1;
  }
 if     (Inside == 1) *Ins = TRUE; 
 else if(Inside == 0) *Ins = FALSE; 

 return 1;
}

/* ============================================================
 * verif_frame:
 *
 *	Function that verify if the given frame is on the
 *	x axis of the given cs. return 1 if it is, else 0.    
 *============================================================ */

int verif_frame(cs, md_env,frame)
struct GRid 		*cs; 
struct GRmd_env 	*md_env;
struct GRid 		*frame; 
{
 char			axis[5];
 int			i,status, count;
 struct GRid		frm_sys, frm_cs;
 BSrc			rc;
 long			msg;
 IGRdouble		my_vx[3], fr_vx[3], pt1[3], pt2[3], pt3[3],matrix[16];
 IGRshort		matrix_type, type;
 struct IGRlbsys 	*p_geom;



 
   /* verify that the frame is defined on the given coord syst */

   status =  om$send(msg = message NDnode.NDget_objects
                    (ND_ROOT,&frm_cs,1,NULL,0,0,&count),
		    senderid = NULL_OBJID,
                    targetid = frame->objid,
                    targetos = frame->osnum);
   as$status(action = RET_STATUS);

   status = om$send(msg = message NDnode.ASreturn_go(&frm_cs,
 				&matrix_type, 
 				matrix),
 	                senderid = NULL_OBJID,
 			targetid= frm_cs.objid,
 			targetos= frm_cs.osnum ) ;
   as$status(action = RET_STATUS);

   if(frm_cs.objid != cs->objid || 
		frm_cs.osnum != cs->osnum){

	/* verify if the 2 cs have the same x axis */

 	status = om$send(msg = message GRvg.GRgenabsg(&msg, 
						      &md_env->md_env.matrix_type, 
						      md_env->md_env.matrix,  
						      (char **)&p_geom ),
		   senderid = NULL_OBJID,
	  	   targetid = cs->objid,
	  	   targetos = cs->osnum );
 	as$status();  	   
 	if (!(status&(msg)&1)){
   		printf("ERROR genabsg\n");
   		return 0;
  	} 
	for(i=0;i<3;i++) my_vx[i] = (* p_geom).matrix[4*i];

 	status = om$send(msg = message GRvg.GRgenabsg(&msg, 
						      &md_env->md_env.matrix_type, 
						      md_env->md_env.matrix,  
						      (char **)&p_geom ),
		   senderid = NULL_OBJID,
	  	   targetid = frm_cs.objid,
	  	   targetos = frm_cs.osnum );
 	as$status();  	   
 	if (!(status&(msg)&1)){
   		printf("ERROR genabsg\n");
   		return 0;
  	} 
	for(i=0;i<3;i++) fr_vx[i] = (* p_geom).matrix[4*i];
	
	for(i=0;i<3;i++) pt1[i] = 0.;
	for(i=0;i<3;i++) pt2[i] = pt1[i] + my_vx[i];
	for(i=0;i<3;i++) pt3[i] = pt1[i] + fr_vx[i];
	
	if(!(BScollin(&rc, pt1,pt2,pt3)) )return 0;
   }

  /* verify that the frame is defined on the x axis */

  status = om$send(msg = message SMframe.SMfind_frm_syst(&msg,
                                                  &frm_sys),
		       senderid = NULL_OBJID,
           	       targetid = frame->objid,
           	       targetos = frame->osnum );
  as$status(action = RET_STATUS);
  if(!(status & msg &1 ) ) {
		printf("Erreur retreiving frame_syst \n");
		return 0;
  }  
  status = om$send(msg = message SMmgr.SMGetAttTxt
                   (&msg,"axis",axis,&type),
		       senderid = NULL_OBJID,
           	       targetid = frm_sys.objid,
           	       targetos = frm_sys.osnum );

  as$status();
  if(!(status & msg & 1)){
	printf("Erreur SMmgr.SMGetAttTxt\n");
	return 0;
   }

  if(axis[0] != 'x' ){
	return 0;
   }


return 1;
}


/* ============================================================
 * trans_coord
 *
 *	Function that transform coordinates from the frame syst
 *	to a local cs.   
 *============================================================ */

int trans_coord(cs, frame, md_env, pos, newpos)
struct GRid 		*cs; 
struct GRid 		*frame; 
struct GRmd_env		*md_env;
IGRdouble		pos;
IGRdouble		*newpos;
{
 int			status;
 struct GRid		go_cs, frm_sys;
 long			msg;
 IGRdouble		point[3], pt_out[3],matrix[16];
 IGRshort		matrix_type;


 *newpos = pos;

 status = om$send(msg = message NDnode.ASreturn_go(&go_cs,
 				&matrix_type, 
 				matrix),
 	                senderid = NULL_OBJID,
 			targetid= cs->objid,
 			targetos= cs->osnum ) ;

  if(!(status & 1)) go_cs = *cs;


  status = om$send(msg = message SMframe.SMfind_frm_syst(&msg,
                                                  &frm_sys),
		       senderid = NULL_OBJID,
           	       targetid = frame->objid,
           	       targetos = frame->osnum );
  as$status(action = RET_STATUS);
  if(!(status & msg &1 ) ) {
		printf("Erreur retreiving frame_syst \n");
		return 0;
  }  
  status = om$send(msg = message SMfrm_syst.SMcvt_frm_to_wld(&msg,
                                                  pos, point, &md_env->md_env.matrix_type,
						  md_env->md_env.matrix),
		       senderid = NULL_OBJID,
           	       targetid = frm_sys.objid,
           	       targetos = frm_sys.osnum );
  as$status(action = RET_STATUS);
  if(!(status & msg &1 ) ) {
		printf("Erreur retreiving frame_syst \n");
		return 0;
  }  
  status = om$send(msg = message GRcoords.GRcvt_to_lcl_coords(&msg, "rectangular",
                                          1, point, pt_out),
		   senderid = NULL_OBJID,
	  	   targetid = go_cs.objid,
	  	   targetos = go_cs.osnum );
  as$status();
  if(!(status & msg &1 ))
    {
   	printf("ERROR GRcoords.GRcvt_to_lcl_coords\n");
   	return 0;
    }

  *newpos = pt_out[0];  


return 1;
}
end implementation SMsection;


