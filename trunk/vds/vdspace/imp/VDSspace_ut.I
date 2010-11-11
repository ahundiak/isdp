/* $Id: VDSspace_ut.I,v 1.1.1.1 2001/01/04 21:09:15 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdspace/imp / VDSspace_ut.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSspace_ut.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:15  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
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

/*
	
     PL       7 may 1991  : Design date

ABSTRACT : 

	Implements Functions used for the space management product.

	- SMelem_
	- VDint
	- VDcomposite_int
	- VDSorder_curves
	- VDSorder_pt
	- reverse_pt
	- VDSlns_curve (no longer used)
	- VDSfill_curve
	- VDSfree
        - VDSdist2
	- VDSadj_pt
	- VDclose_bnd
*/

class implementation Root;

#include <stdio.h>
#include <math.h>
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "parametric.h"
#include "AS_status.h"

#include "bstypes.h"
#include "bserr.h"
#include "bsconic.h"
#include "bsgeom_cvsf.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VDSutil_def.h"
#include "AS_status.h"
#include "EMSssprops.h"

/* include prototypes */

#include "bssfsfint.h"
#include "bssur_sur.h"
#include "bspl_pl.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bsmergarrcv.h"
#include "bsrev_cv.h"
#include "bsconstprcv.h"
#include "bspartofcv.h"
#include "bsprptonsf.h"
#include "bsdotp.h"
#include "bscrossp.h"
#include "bssfeval.h"
#include "maunitvc.h"


#define  AS_DEBUG 1
#define	 MAXINT	20

/*#define  DEBUG2 1*/

#define	ORDER	2

#define INCR	3

extern GRclassid	OPP_EMSplane_class_id, OPP_EMSsurface_class_id, 
			OPP_GRcurve_class_id,OPP_EMScompsurf_class_id,
			OPP_EMSsfimpbnd_class_id;


from GRvg        import GRdetplane, GRgetsize, GRgetgeom, GRgeomprops;
from GRowner     import GRget_number_components,GRget_components;
from EMSsfimpbnd import EMget_subbs;

from GRvg      import GRgenabsg;
from EMSsubbs  import EMget_props;




/* ------------------------------------------------------------------- 

   SMelem_: This function fills the apropriate structure with the geometry 
            of the given object ( curve, plane or surface).
      
   The structures bsp_sf and bsp_cv are allocated by the function and must
   be deallocated by the user: 
      ( VDSfree(nb_sf,&bsp_sf) and free(bsp_cv) )
  
   nb_sf is the number of surfaces returned in bsp_sf.
   nb_sf = 1 for not composite surface

   type_flag indicates what structure is to be filled:

		 	0	-> take elt as given by classe
		 	SURF	-> even if plan, we take elt as surface
		 	PLAN	-> if surface & planar we take elt as plan

   type is the return type of the element (SURF, PLAN, CURV, COMP)
   ------------------------------------------------------------------- */

SMelem_(type_flag, element, mat_type, matrix, type, plane, bsp_sf, bsp_cv, nb_sf)
int			type_flag; 
struct 	GRid	 	*element;  /* I  element id			*/
short			 mat_type; /* I  matrix type 			*/
IGRdouble			*matrix;   /* I  matrix of the element		*/
int		 	*type;	   /* O  type of element (PLAN, ..)	*/
struct	IGRplane 	*plane;	   /* O  */
struct 	IGRbsp_surface	***bsp_sf; /* O  allocated in the function */
struct 	IGRbsp_curve	**bsp_cv;  /* O  allocated in the function */
int  			*nb_sf;    /* O  */
/*.SMelem */
{
 long 			msg, status;
 GRclassid		obj_classid;
 long			size;
 struct GRid		*compsf,obj;
 int			k,nb_retsf;
 struct GRprops	 	properties;
 struct GRmd_env 	md_env;   
 IGRlong		NumberOfBytes;
 IGRlong		BytesReceived;

 compsf = NULL;
 if(nb_sf == NULL || type == NULL )
  {UI_status("SMelem_ : Invalid argument");return 0;}

 if(bsp_cv != NULL) *bsp_cv = NULL;
 if(bsp_sf != NULL) *bsp_sf = NULL;
 *nb_sf   = 0;
 *type    = E_ERROR;

 /*" obj: %d, %d\n", element->objid,element->osnum */
 /*"type_flag: %d\n",type_flag */

 status = om$get_classid(osnum     = element->osnum, 
			 objid     = element->objid, 
			 p_classid = &obj_classid);

 status = om$send(msg = message GRvg.GRgeomprops(&msg, &mat_type, matrix,
						 &properties),
		    senderid = NULL_OBJID,
	  	    targetid = element->objid,
	  	    targetos = element->osnum );
 as$status(action = RET_STATUS); 

 if( om$is_ancestry_valid(subclassid   = obj_classid,
			  superclassid = OPP_EMSplane_class_id )
			   == OM_S_SUCCESS )
  {         	
   /*| This is a plane classe */
   if(type_flag == SURF)  *type = SURF;
   else			  *type = PLAN;
  }
 else if( om$is_ancestry_valid( subclassid   = obj_classid,
			         superclassid = OPP_GRcurve_class_id )
			                              == OM_S_SUCCESS )
   {
   /*| This is a curve classe */
     *type = CURV;
   /*| geom ............CURV*/
   if(bsp_cv == NULL) return 1;

   status = om$send(msg = message GRvg.GRgetsize(&msg, &mat_type, matrix, &size ),
		   senderid = NULL_OBJID,
	  	   targetid = element->objid,
	  	   targetos = element->osnum );
   as$status(action = RET_STATUS);   

   /*| Alloc of the bsp_cv */
   *bsp_cv = (struct IGRbsp_curve *) malloc(size);

   if(*bsp_cv == NULL) 
    {
     UI_status("Bad dynamic allocation ");
     goto wrapup;
    }

   status = om$send(msg = message GRvg.GRgetgeom(&msg, &mat_type, 
                                  matrix, (char *) (*bsp_cv)),
		    senderid = NULL_OBJID,
	  	    targetid = element->objid,
	  	    targetos = element->osnum );
   as$status(action = RET_STATUS);
   /*"cv_num_poles: %d\n",(*bsp_cv)->num_poles*/  
   *nb_sf = 1;

   }
 else if( om$is_ancestry_valid(subclassid   = obj_classid,
			       superclassid = OPP_EMSsfimpbnd_class_id)
			        == OM_S_SUCCESS )
  {         	
   /*| This is a sfimpbnd classe */
   status = om$send(msg = message EMSsfimpbnd.EMget_subbs(&msg, &obj.objid),
		    senderid = NULL_OBJID,
	  	    targetid = element->objid,
	  	    targetos = element->osnum );
   as$status(action = RET_STATUS); 
   element->objid = obj.objid;
   if(type_flag == PLAN && properties.planar == TRUE ) 	*type = PLAN;
   else 		 				*type = SURF;

  }
 else if( om$is_ancestry_valid(subclassid   = obj_classid,
			       superclassid = OPP_EMScompsurf_class_id)
			        == OM_S_SUCCESS )
  {         	
   /*| This is a compsurf classe */
   /*| geom ............COMP_SF*/
   *type = COMP_SF;
   if(bsp_sf == NULL) return 1;
   status = om$send(msg = message GRowner.GRget_number_components(&msg, nb_sf),
		    senderid = NULL_OBJID,
	  	    targetid = element->objid,
	  	    targetos = element->osnum );
   as$status(action = RET_STATUS); 
   /*"nb_sf: %d\n",*nb_sf*/
   compsf = (struct GRid *) malloc(*nb_sf*sizeof(struct GRid));
   nb_retsf = 0;
   /*|get_module_env */
   NumberOfBytes = sizeof(md_env);
   gr$get_module_env( msg    = &msg,
		      sizbuf = &NumberOfBytes,
		      buffer = &md_env,
		      nret   = &BytesReceived);
   if(!(msg&1)) {printf("error gr$get_module_env\n"); goto wrapup;}

   /*"md_env: %d, %d\n",md_env.md_id.objid,md_env.md_id.osnum */

   status = om$send(msg = message GRowner.GRget_components(&msg, 
							   &md_env, 
							   compsf,
							   *nb_sf,
							   &nb_retsf,
							   0,
							   MAXINT),
		    senderid = NULL_OBJID,
	  	    targetid = element->objid,
	  	    targetos = element->osnum );
   as$status(action = RET_STATUS); 
   if(nb_retsf != *nb_sf) 
     {
       UI_status("error in GRowner.GRget_component");
       goto wrapup; 
     }
   for(k=0;k< *nb_sf;k++)
    {/*"compsf[k]: %d, %d\n",compsf[k].objid,compsf[k].osnum*/}
   /*| First we have to allocate the structure */
   *bsp_sf = (struct IGRbsp_surface **) malloc(*nb_sf * sizeof (struct IGRbsp_surface *));

   if(*bsp_sf == NULL) 
    {
     UI_status("Bad dynamic allocation ");
     goto wrapup;
    }
   for(k=0;k< *nb_sf;k++) (*bsp_sf)[k] = NULL;
   for(k=0;k< *nb_sf;k++)
    {
     status = om$send(msg = message GRvg.GRgetsize(&msg, &mat_type, matrix, &size ),
		   senderid = NULL_OBJID,
	  	   targetid = compsf[k].objid,
	  	   targetos = compsf[k].osnum );
     as$status(action = RET_STATUS);   
     /*| Alloc of the bsp_suf */
     (*bsp_sf)[k] = (struct IGRbsp_surface *) malloc(size);

     if((*bsp_sf)[k] == NULL) 
      {
       UI_status("Bad dynamic allocation ");
       goto wrapup;
      }
     /*"get geom de obj: %d, %d\n",compsf[k].objid,compsf[k].osnum */
     status = om$send(msg = message GRvg.GRgetgeom(&msg, &mat_type, 
                                  matrix, (char *) (*bsp_sf)[k]),
		    senderid = NULL_OBJID,
	  	    targetid = compsf[k].objid,
	  	    targetos = compsf[k].osnum );
     as$status(action = RET_STATUS);   

   }
  if(compsf ! = NULL) {free(compsf);compsf=NULL;}
   
  }
 else if( om$is_ancestry_valid(subclassid   = obj_classid,
				superclassid = OPP_EMSsurface_class_id )
				== OM_S_SUCCESS )
  { 
   /*| This is a surface classe */
   if(type_flag == PLAN && properties.planar == TRUE ) 	*type = PLAN;
   else 		 				*type = SURF;
  }
 else
  {
   *type = E_ERROR;
   UI_status ( "SMelem_: neither plane, surfaces or composite ");
   goto wrapup;
  }

if(*type == PLAN)
  {
   /*| geom ............PLAN*/
   if(plane == NULL) return 1;

   status = om$send (msg = message GRvg.GRdetplane(&msg, &mat_type, matrix, plane),
			 senderid = NULL_OBJID,
			 targetid = element->objid,
			 targetos = element->osnum );
        
   as$status(action = RET_STATUS);   
   *nb_sf = 1;
  }
else if(*type == SURF)
  {
   /*| geom ............SURF*/
   if(bsp_sf == NULL) return 1;

   status = om$send(msg = message GRvg.GRgetsize(&msg, &mat_type, matrix, &size ),
		   senderid = NULL_OBJID,
	  	   targetid = element->objid,
	  	   targetos = element->osnum );
   as$status(action = RET_STATUS);   

   /*| First we have to allocate the structure */
   *bsp_sf = (struct IGRbsp_surface **) malloc(sizeof (struct IGRbsp_surface *));

   if(*bsp_sf == NULL) 
    {
     UI_status("Bad dynamic allocation ");
     goto wrapup;
    }
   (*bsp_sf)[0] = NULL;
   /*| Alloc of the bsp_suf */
   (*bsp_sf)[0] = (struct IGRbsp_surface *) malloc(size);

   if((*bsp_sf)[0] == NULL) 
    {
     UI_status("Bad dynamic allocation ");
     goto wrapup;
    }

   status = om$send(msg = message GRvg.GRgetgeom(&msg, &mat_type, 
                                  matrix, (char *) (*bsp_sf)[0]),
		    senderid = NULL_OBJID,
	  	    targetid = element->objid,
	  	    targetos = element->osnum );
   as$status(action = RET_STATUS);   
   *nb_sf = 1;
  }

 return (1);
wrapup:
 /*|wrapup */

 if(bsp_cv != NULL && *bsp_cv != NULL) {free(*bsp_cv);*bsp_cv=NULL;}
 if(bsp_sf   != NULL && *bsp_sf != NULL)  VDSfree(*nb_sf,bsp_sf);
 if(compsf  ! = NULL){free(compsf);compsf=NULL;}
 return 0;

}



/* ------------------------------------------------------------------- 

   VDint: This function computes the intersection between two surfaces 
          that can be general surface, plane or composite surface.
      
   Call the function VDcomposite_int if one of the surface is composite.

   nb_sf is the number of surfaces in bsp_sf (1 if not composite).

   Type1 and type2 are the type of the surface (PLAN, SURF, COMP). 

   nb_pts and pts, p_par1, p_par2 are allocated by the function and must 
   be deallocated by the user: 

     ( VDSfree(nb_int,&pts),VDSfree(nb_int,&p_par1),VDSfree(nb_int,&p_par2), 
       free(nb_pts) )

   p_par1 is the param on the first surface and p_par2 on the second. 

   NOTES: p_par is NULL (not allocated for plane and composite)
   ------------------------------------------------------------------- */

VDint(type1, bsp_sf1, plane1, nb_sf1, type2, bsp_sf2, plane2, nb_sf2,
            nb_int, nb_pts, pts, p_par1,p_par2)
int			type1;		/* (I) surf1 type		      */
struct IGRbsp_surface   **bsp_sf1;	/* (I)geom of surf1 (NULL if not)     */
struct IGRplane		*plane1;	/* (I)plane def of surf1 (NULL if not)*/
int			nb_sf1;		/* (I)number of surf1 (if composite)  */
int			type2;		/* (I)surf2 type		      */
struct IGRbsp_surface   **bsp_sf2;	/* (I)geom of surf2 (NULL if not)     */
struct IGRplane		*plane2;	/* (I)plane def of surf2 (NULL if not)*/
int			nb_sf2;		/* (I)number of surf2 (if composite)  */
int			*nb_int;	/* (O)number of intersections	      */
int			**nb_pts;	/* (O)number of intersection points   */
IGRdouble	***pts;		  /* (O)pointeur on array[][] of points */
IGRdouble	***p_par1;	/* (O)pointeur on array[][] of params */
IGRdouble	***p_par2;	/* (O)pointeur on array[][] of params */
/*.VDint */
{
 IGRint				sts,i,int_flag, numgrps,tnb_int, *num_int,
 				*tnb_pts;
 BSrc				rc;
 IGRpoint			**tpts;
 BSpair				**tp_par1, **tp_par2;
 IGRdouble			chrdht_tol,
 				calc_tol;
 IGRshort			cvscode;
 struct BSgeom_bsp_curve	*xyz_cvs, *uv_cvs1, *uv_cvs2;
 struct BSgeom_bsp_surf  	pl_geom, sf_geom;
 
 tnb_int	= 0;
 numgrps	= 0;
 num_int	= NULL;
 tnb_pts	= NULL;
 tpts		= NULL;
 tp_par1	= NULL;		/* intermediate var for intersections */
 tp_par2	= NULL;
 xyz_cvs = NULL;
 uv_cvs1 = NULL;
 uv_cvs2 = NULL;



 if(type1 == SURF)
  {
   if(bsp_sf1 == NULL) {UI_status("VDint: Invalid argument"); goto error;}

   if(type2 == PLAN)
    {
      /*|surf / plan ...*/
      if(plane2 == NULL) {UI_status("VDint: Invalid argument"); goto error;}
      
     
      pl_geom.geom_prop = TRUE;
      pl_geom.bounded = FALSE;
      pl_geom.type = BSINF_PLANE;
      for(i=0;i<3;i=i+1) pl_geom.pt1[i] = plane2->point[i];
      for(i=0;i<3;i=i+1) pl_geom.vec1[i] = plane2->normal[i];

      sf_geom.type = BSGEN_BSP_SF;
      sf_geom.geom_prop = FALSE;
      sf_geom.bounded = TRUE;
      sf_geom.bspsf = bsp_sf1[0];
      sf_geom.urange[0] = bsp_sf1[0]->u_knots[bsp_sf1[0]->u_order-1];
      sf_geom.urange[1] = bsp_sf1[0]->u_knots[bsp_sf1[0]->u_num_poles];
      sf_geom.vrange[0] = bsp_sf1[0]->v_knots[bsp_sf1[0]->v_order-1];
      sf_geom.vrange[1] = bsp_sf1[0]->v_knots[bsp_sf1[0]->v_num_poles];
    
   
      (void)BSsfsfint(&sf_geom, &pl_geom, &numgrps,
        	&num_int,&tnb_pts,&tpts, &tp_par1, &tp_par2,&cvscode, &xyz_cvs,
        	&uv_cvs1, &uv_cvs2, &rc);
      if(rc != BSSUCC){
      	printf("ERROR BSsfsfint rc= %d\n",rc);
      	goto error;
      }
      tnb_int = 0;
      for(i=0;i<numgrps;i++) tnb_int = tnb_int + num_int[i];
    }
   else if(type2 == SURF)
    {
      /*|surf / surf ...*/
     if(bsp_sf2 == NULL) {UI_status("VDint: Invalid argument"); goto error;}
     
      BSsur_sur(&rc, bsp_sf1[0], bsp_sf2[0], &chrdht_tol, &calc_tol,
  	        &tnb_int, &tnb_pts, &tpts, &tp_par1, &tp_par2 );
      if(rc != BSSUCC){
      	printf("ERROR BSsur_sur rc= %d\n",rc);
      	goto error;
      }
     }
    else if(type2 == COMP_SF)
     {
       /*|appel VDcomposite surf / compsf ...*/
       sts = VDcomposite_int(SURF, bsp_sf1, NULL, 1, COMP_SF, bsp_sf2, NULL,
			     nb_sf2, &tnb_int, &tnb_pts, (IGRdouble ***)&tpts, 
			     (IGRdouble ***)&tp_par1, 
			     NULL);

       if(sts == 0){UI_status("VDint: error fct VDcomposite_int");goto error;}
     }
    else
     {
      UI_status("VDint: Invalid type for the second surface");
      goto error;
     }
   }
  else if(type1 == PLAN)
   {
    if(plane1 == NULL) {UI_status("VDint: Invalid argument"); goto error;}

    if(type2 == PLAN)
     {
      double u[3], q[3];
       /*|plan / plan ...*/

      if(plane2 == NULL) {UI_status("VDint: Invalid argument"); goto error;}
      BSpl_pl(plane1->point, plane1->normal, plane2->point, plane2->normal,
	      &int_flag, q, u, &rc);
      if(rc != BSSUCC){
      	printf("ERROR BSpl_pl rc= %d\n",rc);
      	goto error;
      }
      if (int_flag == BSCINTERSECTING) tnb_int = 1; /* To do as the others */
      else {/*^printf("no plane plane intersection\n"); */goto success;}

      /*| Alloc of nb_pts */
      tnb_pts = (int *) malloc(1*sizeof(int));

      if(tnb_pts == NULL)
          {
           UI_status("Bad dynamic allocation ");
	   goto error;
          }
      (tnb_pts)[0] = 2; 

      /*| alloc of pts */

      tpts = (IGRpoint **) malloc(tnb_int*sizeof(IGRpoint *)); 
      if(tpts == NULL)
       {
        UI_status("Bad dynamic allocation ");
	goto error;
       }
       for(i=0;i<tnb_int;i++) tpts[i] = NULL;
      (*tpts)=(IGRpoint *)malloc((tnb_pts)[0] * sizeof(IGRpoint));
      if((*tpts) == NULL)
       {
        UI_status("Bad dynamic allocation ");
	goto error;
       }

      for(i=0;i<3;i++) 
       {
	/*"u: %lf, q: %lf\n", u[i], q[i] */
        (*tpts)[0][i]   = q[i]; 
        (*tpts)[1][i] = q[i] + u[i]; 
       }
     }
    else if(type2 == SURF)
     {
       /*|plan / surf ...*/
      if(bsp_sf2 == NULL) {UI_status("VDint: Invalid argument"); goto error;}

      pl_geom.geom_prop = TRUE;
      pl_geom.bounded = FALSE;
      pl_geom.type = BSINF_PLANE;
      for(i=0;i<3;i=i+1) pl_geom.pt1[i] = plane1->point[i];
      for(i=0;i<3;i=i+1) pl_geom.vec1[i] = plane1->normal[i];

      sf_geom.type = BSGEN_BSP_SF;
      sf_geom.geom_prop = FALSE;
      sf_geom.bounded = TRUE;
      sf_geom.bspsf = bsp_sf2[0];
      sf_geom.urange[0] = bsp_sf2[0]->u_knots[bsp_sf2[0]->u_order-1];
      sf_geom.urange[1] = bsp_sf2[0]->u_knots[bsp_sf2[0]->u_num_poles];
      sf_geom.vrange[0] = bsp_sf2[0]->v_knots[bsp_sf2[0]->v_order-1];
      sf_geom.vrange[1] = bsp_sf2[0]->v_knots[bsp_sf2[0]->v_num_poles];
    
   
      (void)BSsfsfint(&pl_geom, &sf_geom, &numgrps,
        	&num_int,&tnb_pts,&tpts, &tp_par1, &tp_par2,&cvscode, &xyz_cvs,
        	&uv_cvs1, &uv_cvs2, &rc);
      if(rc != BSSUCC){
      	printf("ERROR BSsfsfint rc= %d\n",rc);
      	goto error;
      }
      tnb_int = 0;
      for(i=0;i<numgrps;i++) tnb_int = tnb_int + num_int[i];
     }
    else if(type2 == COMP_SF)
     {
       /*|appel VDcomposite plan / compsf ...*/

       sts = VDcomposite_int(PLAN, NULL, plane1, 1, COMP_SF, bsp_sf2, NULL, 
			     nb_sf2, &tnb_int, &tnb_pts, (IGRdouble ***)&tpts, 
				NULL, NULL);

       if(sts == 0){UI_status("VDint: error VDcomposite_int");goto error;}
     } 
   } 
 else if(type1 == COMP_SF)
  {
   if(bsp_sf1 == NULL) {UI_status("VDint: Invalid argument"); goto error;}

   if(type2 == PLAN)
    {
       /*|appel VDcomposite compsf / plan ...*/
       sts = VDcomposite_int(COMP_SF, bsp_sf1, NULL, nb_sf1, PLAN, NULL, 
			     plane2, 1, &tnb_int, &tnb_pts, 
				(IGRdouble ***)&tpts, NULL, 
			     NULL);

       if(sts == 0){UI_status("VDint: error VDcomposite_int");goto error;}
     }
   else if(type2 == SURF)
    {
       /*|appel VDcomposite compsf / surf ...*/
       sts = VDcomposite_int(COMP_SF, bsp_sf1, NULL, nb_sf1, SURF, bsp_sf2, 
			     NULL, 1, &tnb_int, &tnb_pts,(IGRdouble ***) &tpts, 
			     NULL, 
			     (IGRdouble ***)&tp_par2);

       if(sts == 0){UI_status("VDint: error VDcomposite_int");goto error;}
     }
    else if(type2 == COMP_SF)
     {
       /*|appel VDcomposite compsf / compsf ...*/
       sts = VDcomposite_int(COMP_SF, bsp_sf1, NULL, nb_sf1, COMP_SF, bsp_sf2,
			     NULL, nb_sf2, &tnb_int, &tnb_pts, 
				(IGRdouble ***)&tpts, NULL,
			     NULL);

       if(sts == 0){UI_status("VDint: error VDcomposite_int");goto error;}
     }
    else
     {
      UI_status("VDint: Invalid type for the second surface");
      goto error;
     }
   }
  else
   {
    UI_status("VDint: Invalid type for the surface");
    goto error;
   }
 if(tnb_int < 1) 
  {
   /*|surf_int:  (nb_int<1)no intersection found */
   goto success;
  }


/**/
/*
/*         load output variables or free local variables          */
/**/


  
  if(nb_int != NULL) 
   {
    *nb_int = tnb_int;
    /*"returned nb_int: %d\n",*nb_int*/
   }

  if(nb_pts == NULL) {if(tnb_pts != NULL){free(tnb_pts);tnb_pts= NULL;}}
  else
   {
    *nb_pts = tnb_pts;
    /*"returned nb_pts[0]: %d\n",(*nb_pts)[0]*/
   }

  if(pts == NULL) 
    {
     /*|pts = NULL, dealloc tpts */
     VDSfree(tnb_int,&tpts);
    }
  else
   {
    *pts = (IGRdouble **)tpts;

/*^
   for(i=0;i<tnb_int;i++)
    {
      printf("groupe    : %d\n",i );
      for(k=0;k<tnb_pts[i];k++) 
       printf("returned VDint (BSinters) pts: %lf, %lf, %lf\n",(*pts)[i][3*k],(*pts)[i][3*k+1],(*pts)[i][3*k+2]);
    }
*/
   }

  if(p_par1 == NULL) 
    {
     /*|p_par1 = NULL, dealloc tp_par1*/
      VDSfree(tnb_int,&tp_par1);
    }
  else
   {
    *p_par1 = (IGRdouble **)tp_par1;

/*^
   for(i=0;i<tnb_int;i++)
    {
      printf("groupe: %d\n",i);
      for(k=0;k<tnb_pts[i];k++) 
       printf("returned VDint (BSinters) par1: %lf, %lf\n",(*p_par1)[i][2*k],(*p_par1)[i][2*k+1]);
    }
*/
   }

  if(p_par2 == NULL) 
    {
     /*|p_par2 = NULL, dealloc par2*/
     VDSfree(tnb_int,&tp_par2);
    }
  else
   {
    *p_par2 = (IGRdouble **)tp_par2;

/*^
   for(i=0;i<tnb_int;i++)
    {
      printf("groupe: %d\n",i);
      for(k=0;k<tnb_pts[i];k++) 
       printf("returned VDint (BSinters) par2: %lf, %lf\n",(*p_par2)[i][2*k],(*p_par2)[i][2*k+1]);
    }
*/
   }

goto success;

success:

 if(xyz_cvs != NULL){
 	for(i=0;i<tnb_int;i++){
 		if(xyz_cvs[i].array1 != NULL){
 			free(xyz_cvs[i].array1);
 			xyz_cvs[i].array1=NULL;
 		}
 		if(xyz_cvs[i].bspcv != NULL){
                	BSfreecv(&rc, xyz_cvs[i].bspcv);
	        	xyz_cvs[i].bspcv = NULL;
 		}
 	}
 	free(xyz_cvs);xyz_cvs = NULL;
 }
 if(uv_cvs1 != NULL){
 	for(i=0;i<tnb_int;i++){
 		if(uv_cvs1[i].array1 != NULL){
 			free(uv_cvs1[i].array1);
 			uv_cvs1[i].array1=NULL;
 		}
 		if(uv_cvs1[i].bspcv != NULL){
                	BSfreecv(&rc, uv_cvs1[i].bspcv);
	        	uv_cvs1[i].bspcv = NULL;
 		}
 	}
 	free(uv_cvs1);uv_cvs1 = NULL;
 }
 if(uv_cvs2 != NULL){
 	for(i=0;i<tnb_int;i++){
 		if(uv_cvs2[i].array1 != NULL){
 			free(uv_cvs2[i].array1);
 			uv_cvs2[i].array1=NULL;
 		}
 		if(uv_cvs2[i].bspcv != NULL){
                	BSfreecv(&rc, uv_cvs2[i].bspcv);
	        	uv_cvs2[i].bspcv = NULL;
 		}
 	}
 	free(uv_cvs2);uv_cvs2 = NULL;
 }
 if(num_int   != NULL) 		{ free(num_int);   num_int = NULL; }
 return 1;

error:

 /*| ERROR  ................  Free param if necessary */

 if(xyz_cvs != NULL){
 	for(i=0;i<tnb_int;i++){
 		if(xyz_cvs[i].array1 != NULL){
 			free(xyz_cvs[i].array1);
 			xyz_cvs[i].array1=NULL;
 		}
 		if(xyz_cvs[i].bspcv != NULL){
                	BSfreecv(&rc, xyz_cvs[i].bspcv);
	        	xyz_cvs[i].bspcv = NULL;
 		}
 	}
 	free(xyz_cvs);xyz_cvs = NULL;
 }
 if(uv_cvs1 != NULL){
 	for(i=0;i<tnb_int;i++){
 		if(uv_cvs1[i].array1 != NULL){
 			free(uv_cvs1[i].array1);
 			uv_cvs1[i].array1=NULL;
 		}
 		if(uv_cvs1[i].bspcv != NULL){
                	BSfreecv(&rc, uv_cvs1[i].bspcv);
	        	uv_cvs1[i].bspcv = NULL;
 		}
 	}
 	free(uv_cvs1);uv_cvs1 = NULL;
 }
 if(uv_cvs2 != NULL){
 	for(i=0;i<tnb_int;i++){
 		if(uv_cvs2[i].array1 != NULL){
 			free(uv_cvs2[i].array1);
 			uv_cvs2[i].array1=NULL;
 		}
 		if(uv_cvs2[i].bspcv != NULL){
                	BSfreecv(&rc, uv_cvs2[i].bspcv);
	        	uv_cvs2[i].bspcv = NULL;
 		}
 	}
 	free(uv_cvs2);uv_cvs2 = NULL;
 }
  VDSfree(tnb_int,&tpts);
  VDSfree(tnb_int,&tp_par1);
  VDSfree(tnb_int,&tp_par2);

 if(tnb_pts   != NULL) 		{ free(tnb_pts);   nb_pts = NULL; }
 if(num_int   != NULL) 		{ free(num_int);   num_int = NULL; }

 return 0;

}


/* ------------------------------------------------------------------- 

   VDcomposite_int: This function computes the intersection of one 
   		    composite surface with any other type of surface 
		    and returns a set of intersections. 
      
   nb_sf is the number of surfaces in bsp_sf (1 if not composite)

   Type1 and type2 are the type of the surface (PLAN, SURF, COMP). 

   nb_pts and pts, p_par1, p_par2 are allocated by the function and must 
   be deallocated by the user (if not NULL):  

    ( VDSfree(nb_int,&pts),VDSfree(nb_int,&p_par1),VDSfree(nb_int,&p_par2), 
       free(nb_pts) )

   ------------------------------------------------------------------- */


VDcomposite_int(type1, bsp_sf1, plane1, nb_sf1, type2, bsp_sf2, plane2, nb_sf2,
            nb_int, nb_pts, pts, p_par1,p_par2)
int			type1;		/* (I)surf1 type		      */
struct IGRbsp_surface   **bsp_sf1;	/* (I)geom of surf1 (NULL if not)     */
struct IGRplane		*plane1;	/* (I)plane def of surf1 (NULL if not)*/
int			nb_sf1;		/* (I)number of surf1 (if composite)  */
int			type2;		/* (I)surf2 type		      */
struct IGRbsp_surface   **bsp_sf2;	/* (I)geom of surf2 (NULL if not)     */
struct IGRplane		*plane2;	/* (I)plane def of surf2 (NULL if not)*/
int			nb_sf2;		/* (O)number of surf2 (if composite)  */
int			*nb_int;	/* (O)number of intersections	      */
int			**nb_pts;	/* (O)number of intersection points   */
IGRdouble			***pts;		/* (O)pointeur on array[][] of points */
IGRdouble			***p_par1;	/* (O)pointeur on array[][] of params */
IGRdouble			***p_par2;	/* (O)pointeur on array[][] of params */
/*.VDcomposite_int*/
{
 IGRint			sts,i,j, k, l, comp_nb_int, *comp_nb_pts,
			tnb_int, *tnb_pts, nb_sf;
 IGRdouble		**comp_pts,**comp_par1,**comp_par2, **tpts, **tp_par1,
			**tp_par2;
 int			size_ptr,index_ptr;


 nb_sf          = 0;
 size_ptr	= 0;
 index_ptr	= 0;
 tnb_int	= 0;
 tnb_pts	= NULL;
 tpts		= NULL;
 tp_par1	= NULL;		/* intermediate var for intersections */
 tp_par2	= NULL;

 comp_nb_int 	= 0;
 comp_nb_pts	= NULL;
 comp_pts	= NULL;
 comp_par1	= NULL;
 comp_par2	= NULL;

 sts = 0;

if(type1 != COMP_SF && type2 != COMP_SF)
 {
   UI_status("VDcomposite_int: Invalid surface type");
   return 0;
 }

 if     (type1 == COMP_SF && type2 == PLAN)
   { 
	/*| compsf / plan */ 
	if(bsp_sf1 == NULL) 
	    {UI_status("VDcomposite_int: Invalid argument"); goto error;}
	if(plane2 == NULL) 
	    {UI_status("VDcomposite_int: Invalid argument"); goto error;}
	
	nb_sf = nb_sf1; 
   }

 else if(type1 == COMP_SF && type2 == SURF)
   { 
	/*| compsf / surf */  
	if(bsp_sf1 == NULL) 
	    {UI_status("VDcomposite_int: Invalid argument"); goto error;}
	if(bsp_sf2 == NULL) 
	    {UI_status("VDcomposite_int: Invalid argument"); goto error;}
	nb_sf = nb_sf1; 
   }

 else if(type1 == COMP_SF && type2 == COMP_SF)
   { 
	/*|compsf / compsf */  
	if(bsp_sf1 == NULL)
	    {UI_status("VDcomposite_int: Invalid argument"); goto error;}
	if(bsp_sf2 == NULL) 
	    {UI_status("VDcomposite_int: Invalid argument"); goto error;}
	nb_sf = nb_sf1; 
   }

 else if(type1 == PLAN    && type2 == COMP_SF)
   { 
	/*| plan / compsf  */  
	if(plane1 == NULL) 
	    {UI_status("VDcomposite_int: Invalid argument"); goto error;}
	if(bsp_sf2 == NULL) 
	    {UI_status("VDcomposite_int: Invalid argument"); goto error;}
	nb_sf = nb_sf2; 
   }

 else if(type1 == SURF    && type2 == COMP_SF)
   { 
	/*| surf / compsf */  
	if(bsp_sf1 == NULL)
	    {UI_status("VDcomposite_int: Invalid argument"); goto error;}
	if(bsp_sf2 == NULL)
	    {UI_status("VDcomposite_int: Invalid argument"); goto error;}
	nb_sf = nb_sf2; 
   }

 for(k=0;k<nb_sf;k++)
  {
    /*" ............... composite boucle: %d\n",k*/
    comp_nb_int           	 = 0;
    comp_nb_pts 		 = NULL;
    comp_pts    		 = NULL;
    comp_par1   		 = NULL;
    comp_par2   		 = NULL;

    if     (type1 == COMP_SF && type2 == PLAN)
     	sts = VDint(SURF, &bsp_sf1[k], (struct IGRplane *)NULL, 1, PLAN, 
     		    (struct IGRbsp_surface **)NULL, plane2, 1, 
                    &comp_nb_int, &comp_nb_pts, &comp_pts, (IGRdouble ***)NULL,
                    (IGRdouble ***) NULL);

    else if(type1 == COMP_SF && type2 == SURF)
        sts = VDint(SURF, &bsp_sf1[k], (struct IGRplane *)NULL, 1, SURF, 
        	    &bsp_sf2[0],(struct IGRplane *)NULL,  1, 
                    &comp_nb_int, &comp_nb_pts, &comp_pts, (IGRdouble ***)NULL,
		    &comp_par2);

    else if(type1 == COMP_SF && type2 == COMP_SF)
        sts = VDcomposite_int(SURF, &bsp_sf1[k], (struct IGRplane *)NULL, 1, 
        		      COMP_SF, bsp_sf2, (struct IGRplane *)NULL, 
        		      nb_sf2, &comp_nb_int, &comp_nb_pts, 
			      &comp_pts, (IGRdouble ***)NULL,(IGRdouble ***)NULL);

    else if(type1 == PLAN    && type2 == COMP_SF)
        sts = VDint(PLAN, (struct IGRbsp_surface **)NULL, plane1, 1, SURF, 
        	&bsp_sf2[k], (struct IGRplane *)NULL, 1,
                    &comp_nb_int, &comp_nb_pts, &comp_pts, (IGRdouble ***)NULL, 
		    (IGRdouble ***)NULL);
	   
    else if(type1 == SURF    && type2 == COMP_SF)
        sts = VDint(SURF, &bsp_sf1[0], (struct IGRplane *)NULL, 1, SURF, 
        	&bsp_sf2[k], (struct IGRplane *)NULL, 1,
                    &comp_nb_int, &comp_nb_pts, &comp_pts, &comp_par1, 
		    (IGRdouble ***)NULL);

    /*| ........................................return VDint */

    if(sts == 0){UI_status("VDcomposite_int: error VDint");goto error;}
    if(comp_nb_int == 0) 
      {	/*"no int with comp_surf[%d]\n",k*/   
   	if(comp_nb_pts != NULL) {free(comp_nb_pts);comp_nb_pts = NULL;}
   	VDSfree(comp_nb_int,&comp_pts);
   	VDSfree(comp_nb_int,&comp_par1);
   	VDSfree(comp_nb_int,&comp_par2);
	continue;
      }
    tnb_int = tnb_int + comp_nb_int;
/*^
    printf("comp_nb_int: %d\n",comp_nb_int);
    for(i=0;i<comp_nb_int;i++) printf("comp_nb_pts: %d\n",comp_nb_pts[i]);
    printf("tnb_int: %d\n",tnb_int);
    printf("size_ptr: %d\n",size_ptr);
*/
    if(tnb_int >= size_ptr)
     {
       if(size_ptr == 0)
        {
          /*|alloc tnb_pts */
          tnb_pts = (int *) malloc (INCR *sizeof(int));
          if(tnb_pts == NULL)
            {
              UI_status("Bad dynamic allocation ");
              goto error;
            }
          /*|alloc tpts */
          tpts = (double **) malloc(INCR * sizeof(double *)); 
          if(tpts == NULL)
             {
               UI_status("Bad dynamic allocation ");
               goto error;
             }
	  for(i=0;i<INCR;i++) tpts[i] = NULL;
          if(comp_par1 != NULL)
           {
	     /*|alloc tp_par1 */
	     tp_par1 = (double **) malloc(INCR * sizeof(double *)); 
	     if(tp_par1 == NULL)
   	      {
     	        UI_status("Bad dynamic allocation ");
     	        goto error;
   	      }
	      for(i=0;i<INCR;i++) tp_par1[i] = NULL;
            }
          if(comp_par2 != NULL)
           {
	     /*|alloc tp_par2 */
	     tp_par2 = (double **) malloc(INCR * sizeof(double *)); 
	     if(tp_par2 == NULL)
   	      {
     	        UI_status("Bad dynamic allocation ");
     	        goto error;
   	      }
	      for(i=0;i<INCR;i++) tp_par2[i] = NULL;
            }
	 size_ptr = INCR; 
        }
       else
        {
          tnb_pts = (int *) realloc((char *)tnb_pts, 
                                       (tnb_int + INCR) *sizeof(int));
          if(tnb_pts == NULL)
           {
             UI_status("Bad dynamic allocation ");
	     goto error;
           }
          tpts = (double **) realloc((char **)tpts, 
                                       (tnb_int + INCR) *sizeof(double *));
          if(tpts == NULL)
           {
             UI_status("Bad dynamic allocation ");
	     goto error;
           }
	  for(i=size_ptr;i< (tnb_int + INCR);i++) tpts[i] = NULL;
          if(comp_par1 != NULL)
           {
             tp_par1 = (double **) realloc((char **)tp_par1, 
                                       (tnb_int + INCR) *sizeof(double *));
             if(tp_par1 == NULL)
              {
                UI_status("Bad dynamic allocation ");
	        goto error;
              }
	      for(i=size_ptr;i< (tnb_int + INCR);i++) tp_par1[i] = NULL;
           }
          if(comp_par2 != NULL)
           {
             tp_par2 = (double **) realloc((char **)tp_par2, 
                                       (tnb_int + INCR) *sizeof(double *));
             if(tp_par2 == NULL)
              {
                UI_status("Bad dynamic allocation ");
	        goto error;
              }
	      for(i=size_ptr;i< (tnb_int + INCR);i++) tp_par2[i] = NULL;
           }
          size_ptr = tnb_int + INCR;
        }
     } /* tnb_int >= size_ptr */

    /*"index_ptr: %d\n",index_ptr*/
    for(l=0,i=index_ptr;i<index_ptr + comp_nb_int;i++,l++)
     { 
	/*"index l: %d, comp_nb_pts to load: %d\n",l,comp_nb_pts[l]*/
        tnb_pts[i] = comp_nb_pts[l];
        /*"nb_pts: %d\n", tnb_pts[i] */
        /*|alloc *tpts */
      	tpts[i]=(double *)malloc(3*tnb_pts[i] * sizeof(double));
      	if(tpts[i] == NULL)
       	 {
           UI_status("Bad dynamic allocation ");
	   goto error;
       	 }
        if(comp_par1 != NULL)
         {
           /*|alloc *tp_par1 */
      	   tp_par1[i]=(double *)malloc(2*tnb_pts[i] * sizeof(double));
      	   if(tp_par1[i] == NULL)
       	    {
              UI_status("Bad dynamic allocation ");
	      goto error;
       	    }
         }
        if(comp_par2 != NULL)
         {
            /*|alloc *tp_par2 */
      	    tp_par2[i]=(double *)malloc(2*tnb_pts[i] * sizeof(double));
      	    if(tp_par2[i] == NULL)
       	     {
               UI_status("Bad dynamic allocation ");
	       goto error;
       	     }
         }
        for(j= 0;j< tnb_pts[i];j++)
         {

           tpts[i][3*j]   =  comp_pts[l][3*j];
           tpts[i][3*j+1] =  comp_pts[l][3*j+1];
           tpts[i][3*j+2] =  comp_pts[l][3*j+2];

           if(comp_par1 != NULL)
            {
              tp_par1[i][2*j]   =  comp_par1[l][2*j];
              tp_par1[i][2*j+1] =  comp_par1[l][2*j+1];
             }


           if(comp_par2 != NULL)
            {
              tp_par2[i][2*j]   =  comp_par2[l][2*j];
              tp_par2[i][2*j+1] =  comp_par2[l][2*j+1];
             }
         }
     }  
   index_ptr = index_ptr + comp_nb_int;
   if(comp_nb_pts != NULL) {free(comp_nb_pts);comp_nb_pts = NULL;}
   VDSfree(comp_nb_int,&comp_pts);
   VDSfree(comp_nb_int,&comp_par1);
   VDSfree(comp_nb_int,&comp_par2);

 }/*| end boucle k */
/*^    
printf("total result ::::::::::::::::::::::::::::::::::\n");
printf("tnb_int: %d\n",tnb_int);
for(i=0;i<tnb_int;i++) 
 {
   printf("nb_pts: %d .........\n",tnb_pts[i]);
   if(tp_par1 == NULL) printf("tp_par1 == NULL\n");
   if(tp_par2 == NULL) printf("tp_par2 == NULL\n");
   for(k=0;k<tnb_pts[i];k++)
    {
      printf("VDcomposite int pts: %lf, %lf, %lf\n",tpts[i][3*k],tpts[i][3*k+1],tpts[i][3*k+2]);
      if(tp_par1 != NULL)
	printf("VDcomposite int par1: %lf, %lf\n",tp_par1[i][2*k],tp_par1[i][2*k+1]);
      if(tp_par2 != NULL)
      	printf("VDcomposite int par2: %lf, %lf\n",tp_par2[i][2*k],tp_par2[i][2*k+1]);
    }
 }
*/

 if(tnb_int < 1) 
  {
   /*|VDcomposite_int:  (nb_int<1)no intersection found */
   goto success;
  }
/**/
/*
/*         ordonner les groupes de points          */
/**/

  sts = VDSorder_pt(tnb_int, tnb_pts, tpts, tp_par1, tp_par2, nb_int, nb_pts,
		    pts, p_par1, p_par2);
  if(!(sts & 1))
     {UI_status("VDcomposite_int: ERROR VDSorder_pts"); goto error;}

  goto success;

  success:

 /*|SUCCESS free param if necessary ....................*/
  VDSfree(size_ptr,&tpts);
  VDSfree(size_ptr,&tp_par1);
  VDSfree(size_ptr,&tp_par2);
  VDSfree(comp_nb_int,&comp_pts);
  VDSfree(comp_nb_int,&comp_par1);
  VDSfree(comp_nb_int,&comp_par2);

  if(tnb_pts != NULL)      { free(tnb_pts);tnb_pts = NULL;}
  if( comp_nb_pts  != NULL){ free(comp_nb_pts);  comp_nb_pts  = NULL; }

 return 1;

error:

 /*| ERROR  ................  Free param if necessary */

  VDSfree(size_ptr,&tpts);
  VDSfree(size_ptr,&tp_par1);
  VDSfree(size_ptr,&tp_par2);
  VDSfree(comp_nb_int,&comp_pts);
  VDSfree(comp_nb_int,&comp_par1);
  VDSfree(comp_nb_int,&comp_par2);

  if(tnb_pts != NULL)       { free(tnb_pts);tnb_pts = NULL;}
  if( comp_nb_pts  != NULL) { free(comp_nb_pts);  comp_nb_pts  = NULL; }


 return 0;


}/* end VDcomposite_int */



/* ------------------------------------------------------------------- 

   VDSorder_curves: function that gather all input curves that are 
		    adjacents. Return the nb of output curves and the
		    array of output curves.

   merges is allocated by the function and must be deallocated by the 
   user:
     ( for k=0 to nb_merge BSfreecv(&rc, merges[k]) )
   ------------------------------------------------------------------- */

VDSorder_curves(nb_cv, curves, nb_merge, merges)
int			nb_cv;     /* (I) nb of input curves */
struct IGRbsp_curve	**curves;  /* (I) input curves       */
int			*nb_merge; /* (O) nb of ouput curves */
struct IGRbsp_curve	***merges; /* (O) ouput curves       */
/*.VDSorder_curves */
{
int			close,i,j,k,l,nb;
double			tol;
BSrc			rc;
int			wrk_end, wrk_adj;
int			*nb_index, **cv_index;
struct IGRbsp_curve	**bsp_cv, **t_merge; 
struct curve_info	*end_pt;
struct pt_info		current, **pt_info;
long			nput, nret, msg;

end_pt		= NULL;
pt_info 	= NULL;
cv_index        = NULL;
nb_index	= NULL;
t_merge         = NULL;
bsp_cv	        = NULL;
close		= 0;

if(nb_merge == NULL)
 {UI_status("VDSorder_curves : Invalid argument");goto wrapup;}


*nb_merge 	= 0;

nput = sizeof(tol);
gr$get_basis_tolerance(msg = &msg, sizbuf = &nput, buffer = &tol, nret = &nret);
/*"tol: %lf\n",tol*/
end_pt = (struct curve_info *) malloc(nb_cv * sizeof(struct curve_info));
if(end_pt == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}

cv_index = (int **)malloc(nb_cv * sizeof(int *));
if(cv_index == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}

nb_index = (int *)malloc(nb_cv * sizeof(int ));
if(nb_index == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}

pt_info = (struct pt_info **) malloc(nb_cv * sizeof(struct pt_info *));
if(pt_info == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}

for(i=0;i<nb_cv;i++)
 {
   cv_index[i] = NULL;
   pt_info[i] = NULL;
 }
for(i=0;i<nb_cv;i++)
 {
  pt_info[i] = (struct pt_info *) malloc(2 * sizeof(struct pt_info ));
  if(pt_info[i] == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}
 }

/*|end point for each point gpe */

for(i=0;i<nb_cv;i++)
 {
  end_pt[i].pt1[0] = curves[i]->poles[0];
  end_pt[i].pt1[1] = curves[i]->poles[1];
  end_pt[i].pt1[2] = curves[i]->poles[2];

  end_pt[i].pt2[0] = curves[i]->poles[3*(curves[i]->num_poles-1)];
  end_pt[i].pt2[1] = curves[i]->poles[3*(curves[i]->num_poles-1)+1];
  end_pt[i].pt2[2] = curves[i]->poles[3*(curves[i]->num_poles-1)+2];

  /*"gp %d\n",i */
  /*"end0: %lf, %lf, %lf\n",end_pt[i].pt1[0],end_pt[i].pt1[1],end_pt[i].pt1[2]*/
  /*"end1:%lf, %lf, %lf\n",end_pt[i].pt2[0],end_pt[i].pt2[1],end_pt[i].pt2[2]*/
  
 }

/*|init adjacent info for each end_pt */

for(i=0;i<nb_cv;i++)
 {
  pt_info[i][0].index_adj = -1;
  pt_info[i][0].index_end = -1;
  pt_info[i][1].index_adj = -1;
  pt_info[i][1].index_end = -1;
 }

/*|fill adjacent info for each end pt */

for(i=0;i<nb_cv;i++)
 {
  /*"index ..............: %d\n",i*/
  /*"adj0: %d\n",pt_info[i][0].index_adj*/
  if(VDSadj_pt(end_pt[i].pt1,end_pt[i].pt2,tol))
       {
          /*^printf("probleme les 2 end_pts du gp %d sont idem\n",i);*/
	  /* les index resteront a -1 => gpe a part*/
          continue;
       }
  if(pt_info[i][0].index_adj == -1 )
   {
    for(j=0;j<nb_cv;j++)
     {
      
      if(j == i) continue;
      if(VDSadj_pt(end_pt[i].pt1,end_pt[j].pt1,tol))
        {
  	  pt_info[i][0].index_adj = j;
  	  pt_info[i][0].index_end = 0;
  	  pt_info[j][0].index_adj = i;
  	  pt_info[j][0].index_end = 0;
          /*"pt1 is adj to pt1 of pt: %d\n", j*/
          break;
        }/* end VDSadj_pt =1 */
      if(VDSadj_pt(end_pt[i].pt1,end_pt[j].pt2,tol))
        {
  	  pt_info[i][0].index_adj = j;
  	  pt_info[i][0].index_end = 1;
  	  pt_info[j][1].index_adj = i;
  	  pt_info[j][1].index_end = 0;
          /*"pt1 is adj to pt2 of pt: %d\n", j*/
          break;
        }/* end VDSadj_pt =1 */
     /*"adj1: %d\n",pt_info[i][1].index_adj */

     }/* end loop j */
   }/* end of info[i][0].index_adj = -1 */
  if(pt_info[i][1].index_adj == -1 )
   {
    for(j=0;j<nb_cv;j++)
     {
      if(j == i) continue;
      if(VDSadj_pt(end_pt[i].pt2,end_pt[j].pt1,tol))
        {
  	  pt_info[i][1].index_adj = j;
  	  pt_info[i][1].index_end = 0;
  	  pt_info[j][0].index_adj = i;
  	  pt_info[j][0].index_end = 1;
          /*"pt2 is adj to pt1 of pt: %d\n", j*/
          break;
        }/* end VDSadj_pt =1 */
      if(VDSadj_pt(end_pt[i].pt2,end_pt[j].pt2,tol))
        {
  	  pt_info[i][1].index_adj = j;
  	  pt_info[i][1].index_end = 1;
  	  pt_info[j][1].index_adj = i;
  	  pt_info[j][1].index_end = 1;
          /*"pt2 is adj to pt2 of pt: %d\n", j*/
          break;
        }/* end VDSadj_pt =1 */

     }/* end loop j */
   }/* end of info[i][0].index_adj = -1 */

 }/* end of loop for i */

*nb_merge = 0;
for(i=0;i<nb_cv;i++)
 {
  if(pt_info[i][0].index_adj == -1) *nb_merge = *nb_merge + 1;
  if(pt_info[i][1].index_adj == -1) *nb_merge = *nb_merge + 1;
 }
*nb_merge = *nb_merge/2;
if(*nb_merge == 0)
  {
    /*|we have only 1 gp */
    *nb_merge= 1;
    close = 1;
  }
/*^printf("*nb_merge: %d\n",*nb_merge);*/
t_merge = NULL;
t_merge = (struct IGRbsp_curve **)malloc((*nb_merge)*sizeof( struct IGRbsp_curve *));
if(t_merge == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}
for(i=0;i<*nb_merge;i++) (t_merge)[i] = NULL;

k = 0;
if(close == 1)
 {
       /*| close curve */
       for(i=0;i<nb_cv;i++) cv_index[i] = NULL;
       nb = 0;
       nb_index[0] = nb_cv;

      /*"adj0: %d, adj1: %d\n",pt_info[0][0].index_adj,pt_info[0][1].index_adj*/
 
       cv_index[0] = (int *)malloc(nb_index[0] * sizeof(int ));
       if(cv_index[0] == NULL)
         {UI_status("Bad dynamic allocation ");goto wrapup;}
       cv_index[0][nb] = 0;
       nb = nb + 1;
       current.index_adj = pt_info[0][1].index_adj;
       current.index_end = pt_info[0][1].index_end;
       wrk_end = 1 - current.index_end;
       wrk_adj = current.index_adj;
       /*"wrk_end: %d\n",wrk_end */
       /*"wrk_adj: %d\n",wrk_adj */
       /*|boucle while */

       while (current.index_adj != 0)
        {
          cv_index[0][nb]= wrk_adj;
          nb = nb +1;
	   current.index_end = pt_info[wrk_adj][wrk_end].index_end;
	   current.index_adj = pt_info[wrk_adj][wrk_end].index_adj;
           wrk_end = 1 - current.index_end;
           wrk_adj = current.index_adj;
           /*"wrk_end: %d\n",wrk_end */
           /*"wrk_adj: %d\n",wrk_adj */
	   /*"cur adj: %d, cur end: %d\n",current.index_adj,current.index_end*/

        }/* end while */
     
 }/* end close */
else
 {
   for(i=0;i<nb_cv;i++)
    {
      /*| not close curve */
      nb = 0;
      cv_index[i] = NULL;

      /*"boucle sur le remplissage des gp i: %d\n",i*/
      /*"adj0: %d, adj1: %d\n",pt_info[i][0].index_adj,pt_info[i][1].index_adj*/

      if(pt_info[i][0].index_adj == -1 && pt_info[i][1].index_adj == -1 )
       {
         /*|/////////pt_info[i][0] = -1 & pt_info[i][1]= -1 */
         nb_index[i] = 1;     
         cv_index[i] = (int *)malloc(nb_index[i] * sizeof(int ));
         if(cv_index[i] == NULL)
            {UI_status("Bad dynamic allocation ");goto wrapup;}
         cv_index[i][nb] = i;
         nb = nb + 1;
       }/* end adj0 -1, adj1 -1 */ 
      else if (pt_info[i][0].index_adj == -1 )
       {
         /*|//////////////pt_info[i][0] = -1 */
         cv_index[i] = (int *)malloc(nb_cv * sizeof(int ));
         if(cv_index[i] == NULL)
            {UI_status("Bad dynamic allocation ");goto wrapup;}
         cv_index[i][nb] = i;
         nb = nb + 1;
         /*"pt1 of pt %d is a beginning of gp\n",i*/
          current.index_adj = pt_info[i][1].index_adj;
          current.index_end = pt_info[i][1].index_end;
          wrk_end = 1 - current.index_end;
          wrk_adj = current.index_adj;
          /*"wrk_end: %d\n",wrk_end */
          /*"wrk_adj: %d\n",wrk_adj */
          /*|boucle while */

          while (current.index_adj != -1)
           {
             cv_index[i][nb]= wrk_adj;
             nb = nb +1;
             if(pt_info[wrk_adj][wrk_end].index_adj == -1)
              {
                /*| set adj to 0 not to be taken as an other gp */
                pt_info[wrk_adj][wrk_end].index_adj = 0;
                break;
              }
	      current.index_adj = pt_info[wrk_adj][wrk_end].index_adj;
	      current.index_end = pt_info[wrk_adj][wrk_end].index_end;
              wrk_end = 1 - current.index_end;
              wrk_adj = current.index_adj;
              /*"wrk_end: %d\n",wrk_end */
              /*"wrk_adj: %d\n",wrk_adj */

           }/* end while */
          /*"nb end while: %d\n",nb */
          nb_index[i] = nb;
          /*^for(l=0;l<nb;l++) printf("cv_index[%d][%d]: %d\n",i,l,cv_index[i][l]);*/
          k = k + 1;
       }/* end adj0 -1, adj1 qcq */ 
     else if(pt_info[i][1].index_adj == -1 )
      {
        /*|//////////////pt_info[i][1] = -1 */
         cv_index[i] = (int *)malloc(nb_cv * sizeof(int ));
         if(cv_index[i] == NULL)
            {UI_status("Bad dynamic allocation ");goto wrapup;}
         cv_index[i][nb] = i;
         nb = nb + 1;
         /*"pt1 of pt %d is a beginning of gp\n",i*/
          current.index_adj = pt_info[i][0].index_adj;
          current.index_end = pt_info[i][0].index_end;
          wrk_end = 1 - current.index_end;
          wrk_adj = current.index_adj;
          /*"wrk_end: %d\n",wrk_end */
          /*"wrk_adj: %d\n",wrk_adj */
          /*|boucle while */

          while (current.index_adj != -1)
           {
             cv_index[i][nb]= wrk_adj;
             nb = nb +1;
             if(pt_info[wrk_adj][wrk_end].index_adj == -1)
              {
                /*| set adj to 0 not to be taken as an other gp */
                pt_info[wrk_adj][wrk_end].index_adj = 0;
                break;
              }
	      current.index_adj = pt_info[wrk_adj][wrk_end].index_adj;
	      current.index_end = pt_info[wrk_adj][wrk_end].index_end;
              wrk_end = 1 - current.index_end;
              wrk_adj = current.index_adj;
              /*"wrk_end: %d\n",wrk_end */
              /*"wrk_adj: %d\n",wrk_adj */

           }/* end while */
          /*"nb end while: %d\n",nb */
          nb_index[i] = nb;
          /*^for(l=0;l<nb;l++) printf("cv_index[%d][%d]: %d\n",i,l,cv_index[i][l]);*/
          k = k + 1;

       }/* end adj0 qcq, adj1 -1 */ 

    }/* end boucle i */
 }
/* fill bsp_cv and merges*/

l=0;
for(i=0;i<nb_cv;i++)
 {
   if(cv_index[i] != NULL)
    {
      /*"nb_index[i]: %d\n",nb_index[i]*/
      bsp_cv = NULL;
      bsp_cv = (struct IGRbsp_curve **)
                   malloc(nb_index[i]*sizeof( struct IGRbsp_curve *));
      if(bsp_cv == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}
      for(k=0;k<nb_index[i];k++) bsp_cv[k] = NULL;
      for(k=0;k<nb_index[i];k++)
       {
         bsp_cv[k] = curves[cv_index[i][k]];
         /*^
	    printf("bsp_cv num_poles: %d\n",bsp_cv[k]->num_poles);
            for (j=0;j <bsp_cv[k]->num_poles; j=j+1)
		printf("poles : %lf, %lf, %lf\n",bsp_cv[k]->poles[3*j],
		bsp_cv[k]->poles[3*j+1],bsp_cv[k]->poles[3*j+2]);
	  */
       }
      BSmergarrcv(nb_index[i],&bsp_cv[0], &t_merge[l], &rc);
      l=l+1;
      if(rc != BSSUCC){printf("ERROR in merge cv : %d\n",rc);goto wrapup;}
      if(bsp_cv != NULL) {free(bsp_cv);bsp_cv = NULL;}
    }
 }

if(merges != NULL)
 {
  *merges = &t_merge[0];
/*^  for(i=0;i< *nb_merge; i++)
    printf("merges.num_poles: %d\n",(*merges)[i]->num_poles);
*/
 }
else
 {
  if(t_merge != NULL)
   {
    for(i=0;i<*nb_merge;i++)
      if(t_merge[i] != NULL){BSfreecv(&rc, t_merge[i]); t_merge[i] = NULL;}
    if(t_merge != NULL) {free(t_merge);t_merge = NULL;}
   }
 }
VDSfree(nb_cv, &cv_index);
if(nb_index != NULL){free(nb_index);nb_index = NULL;}
if(bsp_cv != NULL) {free(bsp_cv);bsp_cv = NULL;}
if(end_pt != NULL) {free(end_pt); end_pt = NULL;}
VDSfree(nb_cv,&pt_info);
return 1;

wrapup:

 if(t_merge != NULL)
  {
    for(i=0;i<*nb_merge;i++)
      if(t_merge[i] != NULL){ BSfreecv(&rc, t_merge[i]); t_merge[i] = NULL;}
    if(t_merge != NULL) {free(t_merge);t_merge = NULL;}
  }
 VDSfree(nb_cv, &cv_index);
 if(nb_index != NULL){ free(nb_index);nb_index = NULL;}
 if(bsp_cv != NULL) {free(bsp_cv);bsp_cv = NULL;}
 if(end_pt != NULL) {free(end_pt); end_pt = NULL;}
 VDSfree(nb_cv,&pt_info);
 return 0;

}


/* ------------------------------------------------------------------- 

   VDSorder_pt: function that gather all gpe of points that are 
		adjacents. Return the nb of output grpe, the nb of point 
		by gpe, the points and par in each gpe.
  
   snb_pts,spts, sp_par1, sp_par2 are allocated by the function and must
   be deallocated by the user (if not NULL):
 
    ( free(snb_pts), VDSfree(snb_int,&spts), VDSfree(snb_int,&sp_par1),
       VDSfree(snb_int,&sp_par2) )
   ------------------------------------------------------------------- */

VDSorder_pt(nb_int, nb_pts, pts, p_par1, p_par2, snb_int, snb_pts,spts,
	    sp_par1, sp_par2)

int		nb_int;   	/* input nb gpe 	*/
int		*nb_pts;	/* input nb_pts / gpe 	*/
IGRdouble **pts;		  /* pts of gpe		*/
IGRdouble **p_par1;   /* par1 of gpe		*/
IGRdouble **p_par2;  	/* par2 of gpe		*/
int		     *snb_int;	/* out nb gpe		*/
int		    **snb_pts;	/* out nb_pts / gpe 	*/
IGRdouble ***spts;	  /* pts of gpe		*/
IGRdouble ***sp_par1;	/* par1 of gpe		*/
IGRdouble ***sp_par2;	/* par2 of gpe		*/
/*.VDSorder_pt */
{
int			close,tnb_int,i,j,k,l,nb,*tnb_pts;
double			**tpts, **tp_par1,**tp_par2,**rpar1, **rpar2,tol;
int			wrk_end, wrk_adj, size_ptr, index_ptr;
struct curve_info	*end_pt;
struct pt_info		current, **pt_info;
long			nput, nret, msg;

nb 		= 0;
end_pt		= NULL;
pt_info 	= NULL;
size_ptr	= 0;
index_ptr	= 0;
tnb_int		= 0;
tnb_pts		= NULL;
tpts		= NULL;
tp_par1		= NULL;
tp_par2		= NULL;
rpar1		= NULL;
rpar2		= NULL;
close           = 0;

if(nb_int == 0 || nb_pts == NULL || pts == NULL)
 {UI_status("VDSorder_pt : Invalid argument");goto error;}

/*^
printf("VDSorder_pt input\n");
printf("nb_int: %d\n",nb_int);
for(i=0;i<nb_int;i++) printf("nb_pts[%d]: %d\n",i,nb_pts[i]);
for(i=0;i<nb_int;i++)
 {
   for(k=0;k<nb_pts[i] ;k++) printf("pts[%d]: %lf, %lf, %lf\n",i,pts[i][3*k],
				pts[i][3*k+1],	pts[i][3*k+2]);	  
 }
if(p_par1 != NULL) printf("p_par1 != NULL\n");
if(p_par2 != NULL) printf("p_par2 != NULL\n");
*/

nput = sizeof(tol);
gr$get_basis_tolerance(msg = &msg, sizbuf = &nput, buffer = &tol, nret = &nret);
/*"tol :%lf\n",tol */
end_pt = (struct curve_info *) malloc(nb_int * sizeof(struct curve_info));
if(end_pt == NULL){UI_status("Bad dynamic allocation ");goto error;}

pt_info = (struct pt_info **) malloc(nb_int * sizeof(struct pt_info *));
if(pt_info == NULL){UI_status("Bad dynamic allocation ");goto error;}
for(i=0;i<nb_int;i++)  pt_info[i] = NULL;


for(i=0;i<nb_int;i++)
 {
  pt_info[i] = (struct pt_info *) malloc(2 * sizeof(struct pt_info ));
  if(pt_info[i] == NULL){UI_status("Bad dynamic allocation ");goto error;}
 }

/*|end point for each point gpe */

for(i=0;i<nb_int;i++)
 {
  end_pt[i].pt1[0] = pts[i][0];
  end_pt[i].pt1[1] = pts[i][1];
  end_pt[i].pt1[2] = pts[i][2];

  end_pt[i].pt2[0] = pts[i][3*(nb_pts[i]-1)];
  end_pt[i].pt2[1] = pts[i][3*(nb_pts[i]-1)+1];
  end_pt[i].pt2[2] = pts[i][3*(nb_pts[i]-1)+2];

  /*"gp %d\n",i */
  /*"end0: %lf, %lf, %lf\n",end_pt[i].pt1[0],end_pt[i].pt1[1],end_pt[i].pt1[2]*/
  /*"end1:%lf, %lf, %lf\n",end_pt[i].pt2[0],end_pt[i].pt2[1],end_pt[i].pt2[2]*/
  
 }

/*|init adjacent info for each end_pt */

for(i=0;i<nb_int;i++)
 {
  pt_info[i][0].index_adj = -1;
  pt_info[i][0].index_end = -1;
  pt_info[i][1].index_adj = -1;
  pt_info[i][1].index_end = -1;
 }

/*|fill adjacent info for each end pt */

for(i=0;i<nb_int;i++)
 {
  /*"index ..............: %d\n",i*/
  /*"adj0: %d\n",pt_info[i][0].index_adj*/
  if(VDSadj_pt(end_pt[i].pt1,end_pt[i].pt2,tol))
       {
          /*"probleme les 2 end_pts du gp %d sont idem\n",i*/
	  /* les index resteront a -1 => gpe a part*/
         continue;
       }
  if(pt_info[i][0].index_adj == -1 )
   {
    for(j=0;j<nb_int;j++)
     {
      
      if(j == i) continue;
      if(VDSadj_pt(end_pt[i].pt1,end_pt[j].pt1,tol))
        {
	  if(pt_info[j][0].index_adj  != -1 ) 
		{
		  UI_status("ERROR VDSorder_pt: one end pt is adjacent to several pts");
		  continue;
		}
  	  pt_info[i][0].index_adj = j;
  	  pt_info[i][0].index_end = 0;
  	  pt_info[j][0].index_adj = i;
  	  pt_info[j][0].index_end = 0;
          /*"pt1 is adj to pt1 of pt: %d\n", j*/
          break;
        }/* end VDSadj_pt =1 */
      if(VDSadj_pt(end_pt[i].pt1,end_pt[j].pt2,tol))
        {
	  if(pt_info[j][1].index_adj  != -1 ) 
		{
		  UI_status("ERROR VDSorder_pt: one end pt is adjacent to several pts");
		  continue;
		}
  	  pt_info[i][0].index_adj = j;
  	  pt_info[i][0].index_end = 1;
  	  pt_info[j][1].index_adj = i;
  	  pt_info[j][1].index_end = 0;
          /*"pt1 is adj to pt2 of pt: %d\n", j*/
          break;
        }/* end VDSadj_pt =1 */

     }/* end loop j */
   }/* end of info[i][0].index_adj = -1 */
  /*"adj1: %d\n",pt_info[i][1].index_adj */
  if(pt_info[i][1].index_adj == -1 )
   {
    for(j=0;j<nb_int;j++)
     {
      if(j == i) continue;
      if(VDSadj_pt(end_pt[i].pt2,end_pt[j].pt1,tol))
        {
	  if( pt_info[j][0].index_adj != -1 ) 
		{
		  UI_status("ERROR VDSorder_pt: one end pt is adjacent to several pts");
		  continue;
		}
  	  pt_info[i][1].index_adj = j;
  	  pt_info[i][1].index_end = 0;
  	  pt_info[j][0].index_adj = i;
  	  pt_info[j][0].index_end = 1;
          /*"pt2 is adj to pt1 of pt: %d\n", j*/
          break;
        }/* end VDSadj_pt =1 */
       if(VDSadj_pt(end_pt[i].pt2,end_pt[j].pt2,tol))
        {
	  if( pt_info[j][1].index_adj != -1 ) 
		{
		  UI_status("ERROR VDSorder_pt: one end pt is adjacent to several pts");
		  continue;
		}
  	  pt_info[i][1].index_adj = j;
  	  pt_info[i][1].index_end = 1;
  	  pt_info[j][1].index_adj = i;
  	  pt_info[j][1].index_end = 1;
          /*"pt2 is adj to pt2 of pt: %d\n", j*/
          break;
        }/* end VDSadj_pt =1 */

     }/* end loop j */
   }/* end of info[i][0].index_adj = -1 */

 }/* end of loop for i */

for(i=0;i<nb_int;i++)
 {
  if(pt_info[i][0].index_adj == -1) tnb_int = tnb_int + 1;
  if(pt_info[i][1].index_adj == -1) tnb_int = tnb_int + 1;
 }
/*"tnb_int: %d\n",tnb_int*/
tnb_int = tnb_int/2;
if(tnb_int == 0){/*|we have only 1 gp */tnb_int = 1;close = 1;}

tpts =(double **)malloc(tnb_int *sizeof(double *));
if(tpts == NULL)
 {
  UI_status("Bad dynamic allocation ");
  goto error;
 }
for(i=0;i<tnb_int;i++) tpts[i] = NULL;
if(p_par1 != NULL)
 {
  /*" Alloc of tp_par1 of: %d\n", tnb_int */
  tp_par1 = (double **)malloc(tnb_int *sizeof(double *));
  if(tp_par1 == NULL)
   {
     UI_status("Bad dynamic allocation ");
    goto error;
   }
  for(i=0;i<tnb_int;i++) tp_par1[i] = NULL;
 }
if(p_par2 != NULL)
 {
  tp_par2 = (double **)malloc(tnb_int *sizeof(double *));
  if(tp_par2 == NULL)
   {
    UI_status("Bad dynamic allocation ");
    goto error;
   }
  for(i=0;i<tnb_int;i++) tp_par2[i] = NULL;
 }
/*^
for(i=0;i<nb_int;i++)
   {
     printf("adj0: %d, end0: %d\n",pt_info[i][0].index_adj,pt_info[i][0].index_end);
     printf("adj1: %d, end1: %d\n",pt_info[i][1].index_adj,pt_info[i][1].index_end);
   }
*/

k=0;
tnb_pts = (int *)malloc(nb_int*sizeof(int));
if(tnb_pts == NULL)
 {
  UI_status("Bad dynamic allocation ");
  goto error;
 }

if(tnb_int == 1 && close == 1)
 {
      /*|all gp are adjacent => closed curve */
      /*"adj0: %d, adj1: %d\n",pt_info[0][0].index_adj,pt_info[0][1].index_adj*/
       nb = 0;
       /*|pt1 of pt 0 is a beginning of a gp */
       tpts[0] = (double *)malloc(3*nb_pts[0]*sizeof(double ));
       if(tpts[0] == NULL)
        {
         UI_status("Bad dynamic allocation ");
         goto error;
        }
       /*|remplit les tpts */
       
       for(l=0;l<nb_pts[0];l++)
        {
	  tpts[0][3*l]   = pts[0][3*l];
	  tpts[0][3*l+1] = pts[0][3*l+1];
	  tpts[0][3*l+2] = pts[0][3*l+2];
        }
       if(p_par1 != NULL)
        {
	 tp_par1[0] = (double *)malloc(2*nb_pts[0]*sizeof(double ));
         if(tp_par1[0] == NULL)
          {
           UI_status("Bad dynamic allocation ");
           goto error;
          }
         /*|remplit tp_par1 */

          for(l=0;l<nb_pts[0];l++)
           {
	    tp_par1[0][2*l]   = p_par1[0][2*l];
	    tp_par1[0][2*l+1] = p_par1[0][2*l+1];
           }
         }
       if(p_par2 != NULL)
        {
	 tp_par2[0] = (double *)malloc(2*nb_pts[0]*sizeof(double ));
         if(tp_par2[0] == NULL)
          {
           UI_status("Bad dynamic allocation ");
           goto error;
          }
         /*|remplit tp_par2 */

          for(l=0;l<nb_pts[0];l++)
           {
	    tp_par2[0][2*l]   = p_par2[0][2*l];
	    tp_par2[0][2*l+1] = p_par2[0][2*l+1];
           }
         }
       /*"nb_pts[0]: %d\n",nb_pts[0]*/
       nb = nb + nb_pts[0];
       current.index_adj = pt_info[0][1].index_adj;
       current.index_end = pt_info[0][1].index_end;
       wrk_end = 1 - current.index_end;
       wrk_adj = current.index_adj;
       /*"wrk_end: %d\n",wrk_end */
       /*"wrk_adj: %d\n",wrk_adj */
       /*|boucle while */
       while (current.index_adj != 0)
        {
    	  /*"while......nb: %d,index_adj: %d,index_end: %d\n",nb,current.index_adj,current.index_end*/
	  if(current.index_end == 1)
           {
       	     /*|reverse_pt */
             rpar1 = NULL;
	     rpar2 = NULL;
	     if(p_par1 != NULL && p_par1[wrk_adj]!= NULL)
		rpar1 = &p_par1[wrk_adj];
	     if(p_par2 != NULL && p_par2[wrk_adj]!= NULL)
		rpar2 = &p_par2[wrk_adj];
             if(!reverse_pt(&pts[wrk_adj],nb_pts[wrk_adj],
			    rpar1,rpar2))
		{
		  UI_status("VDSorder_pt: error fct reverse_pts");
		  goto error;
		}
            }/* end current end = 1 */
           tpts[0] = (double *)realloc((char *)tpts[0],
					  3*(nb+nb_pts[wrk_adj]-1)*sizeof(double ));
           if(tpts[0] == NULL)
              {
               UI_status("Bad dynamic allocation ");
               goto error;
              }
	   /*|continue a remplir les tpts (pas le 1er qui est le meme) */
	   for(l=0;l<nb_pts[wrk_adj]-1;l++)
	      {
		tpts[0][3*nb+3*l]   = pts[wrk_adj][3*(l+1)];
		tpts[0][3*nb+3*l+1] = pts[wrk_adj][3*(l+1)+1];
		tpts[0][3*nb+3*l+2] = pts[wrk_adj][3*(l+1)+2];
	      }
/*^
	   for(l=0;l<nb_pts[wrk_adj]-1 && l<10 ;l++)
		printf("tpts: %lf, %lf, %lf\n",tpts[0][3*nb+3*l],tpts[0][3*nb+3*l+1],
			tpts[0][3*nb+3*l+2]);
*/
	   if(p_par1 != NULL)
              {
                tp_par1[0] = (double *)realloc((char *)tp_par1[0],
					  2*(nb+nb_pts[wrk_adj]-1)*sizeof(double ));
                if(tp_par1[0] == NULL)
                 {
                  UI_status("Bad dynamic allocation ");
                  goto error;
                 }
	        /*|continue a remplir les tp_par1 (pas le 1er qui est le meme) */
	        for(l=0;l<nb_pts[wrk_adj]-1;l++)
	         {
		   tp_par1[0][2*nb+2*l]   = p_par1[wrk_adj][2*(l+1)];
		   tp_par1[0][2*nb+2*l+1] = p_par1[wrk_adj][2*(l+1)+1];
	         }
              }
	   if(p_par2 != NULL)
              {
                tp_par2[0] = (double *)realloc((char *)tp_par2[0],
					  2*(nb+nb_pts[wrk_adj]-1)*sizeof(double ));
                if(tp_par2[0] == NULL)
                 {
                  UI_status("Bad dynamic allocation ");
                  goto error;
                 }
	        /*|continue a remplir les tp_par2 (pas le 1er qui est le meme) */
	        for(l=0;l<nb_pts[wrk_adj]-1;l++)
	         {
		   tp_par2[0][2*nb+2*l]   = p_par2[wrk_adj][2*(l+1)];
		   tp_par2[0][2*nb+2*l+1] = p_par2[wrk_adj][2*(l+1)+1];
	         }
              }
	   nb = nb + nb_pts[wrk_adj] - 1;
/*^
	   printf("nb: %d\n",nb);
           printf("index_end: %d\n",current.index_end);
	   printf(" adj: %d, end: %d\n",
                pt_info[wrk_adj][wrk_end].index_adj,
		pt_info[wrk_adj][wrk_end].index_end);

*/
	   current.index_end = pt_info[wrk_adj][wrk_end].index_end;
	   current.index_adj = pt_info[wrk_adj][wrk_end].index_adj;
           wrk_end = 1 - current.index_end;
           wrk_adj = current.index_adj;
           /*"wrk_end: %d\n",wrk_end */
           /*"wrk_adj: %d\n",wrk_adj */
	   /*"cur adj: %d, cur end: %d\n",current.index_adj,current.index_end*/

        }/* end while */
       /*"nb end while: %d\n",nb */
       tnb_pts[0] = nb;
/*^
	printf("tnb_pts[0]: %d\n",tnb_pts[0]);
        for(l=0;l<tnb_pts[0] && l<10 ;l++)
            printf("pts: %lf, %lf, %lf\n",tpts[0][3*l],tpts[0][3*l+1],tpts[0][3*l+2]);
*/
}/*end tnb_int = 1 */
else
{
  k=0;
  /*|not close curve */
  for(i=0;i<nb_int;i++)
   {
     /*"boucle sur le remplissage des gp i: %d, k: %d\n",i,k*/
     /*"adj0: %d, adj1: %d\n",pt_info[i][0].index_adj,pt_info[i][1].index_adj*/
     if(pt_info[i][0].index_adj == -1 && pt_info[i][1].index_adj == -1 )
      {
        /*|/////////pt_info[i][0] = -1 & pt_info[i][1]= -1 */
         tpts[k] = (double *)malloc(3*nb_pts[i]*sizeof(double ));
         if(tpts[k] == NULL)
          {
           UI_status("Bad dynamic allocation ");
           goto error;
          }
         /*|remplit les tpts */
       
         for(l=0;l<nb_pts[i];l++)
          {
	    tpts[k][3*l]   = pts[i][3*l];
	    tpts[k][3*l+1] = pts[i][3*l+1];
	    tpts[k][3*l+2] = pts[i][3*l+2];
          }
         if(p_par1 != NULL)
          {
	   /*" Alloc tp_par1 index: %d of: %d\n", k, 2*nb_pts[i] */
	   tp_par1[k] = (double *)malloc(2*nb_pts[i]*sizeof(double ));
           if(tp_par1[k] == NULL)
            {
             UI_status("Bad dynamic allocation ");
             goto error;
            }
           /*|remplit tp_par1 */

            for(l=0;l<nb_pts[i];l++)
             {
	      tp_par1[k][2*l]   = p_par1[i][2*l];
	      tp_par1[k][2*l+1] = p_par1[i][2*l+1];
             }
           }
         if(p_par2 != NULL)
          {
	   tp_par2[k] = (double *)malloc(2*nb_pts[i]*sizeof(double ));
           if(tp_par2[k] == NULL)
            {
             UI_status("Bad dynamic allocation ");
             goto error;
            }
           /*|remplit tp_par2 */

            for(l=0;l<nb_pts[i];l++)
             {
	      tp_par2[k][2*l]   = p_par2[i][2*l];
	      tp_par2[k][2*l+1] = p_par2[i][2*l+1];
             }
           }
         tnb_pts[k] = nb_pts[i];
         /*"tnb_pts[%d]: %d\n",k,tnb_pts[k]*/
/*^
         for(l=0;l<tnb_pts[k] && l<10 ;l++)
         printf("pts: %lf, %lf, %lf\n",tpts[k][3*l], tpts[k][3*l+1],tpts[k][3*l+2]);    
*/
       k= k+ 1;

      }/* end if pt_info[0] = -1 & pt-info[1] =-1 */
     else if (pt_info[i][0].index_adj == -1 )
     {
        /*|////////////pt_info[i][0] = -1 */
      nb = 0;
      /*"pt1 of pt %d is a beginning of gp\n",i*/
      tpts[k]= (double *)malloc(3* nb_pts[i] *sizeof(double));
         if(tpts[k] == NULL)
          {
           UI_status("Bad dynamic allocation ");
           goto error;
          }
         /*|remplit les tpts */
       
         for(l=0;l<nb_pts[i];l++)
          {
	    tpts[k][3*l]   = pts[i][3*l];
	    tpts[k][3*l+1] = pts[i][3*l+1];
	    tpts[k][3*l+2] = pts[i][3*l+2];
          }
      
         if(p_par1 != NULL)
          {
	   tp_par1[k] = (double *)malloc(2*nb_pts[i]*sizeof(double ));
           if(tp_par1[k] == NULL)
            {
             UI_status("Bad dynamic allocation ");
             goto error;
            }
           /*|remplit tp_par1 */

            for(l=0;l<nb_pts[i];l++)
             {
	      tp_par1[k][2*l]   = p_par1[i][2*l];
	      tp_par1[k][2*l+1] = p_par1[i][2*l+1];
             }
           }
         if(p_par2 != NULL)
          {
	   tp_par2[k] = (double *)malloc(2*nb_pts[i]*sizeof(double ));
           if(tp_par2[k] == NULL)
            {
             UI_status("Bad dynamic allocation ");
             goto error;
            }
           /*|remplit tp_par2 */

            for(l=0;l<nb_pts[i];l++)
             {
	      tp_par2[k][2*l]   = p_par2[i][2*l];
	      tp_par2[k][2*l+1] = p_par2[i][2*l+1];
             }
           }
         /*"nb_pts[%d]: %d\n",i,nb_pts[i]*/
         nb = nb + nb_pts[i];
         current.index_adj = pt_info[i][1].index_adj;
         current.index_end = pt_info[i][1].index_end;
         wrk_end = 1 - current.index_end;
         wrk_adj = current.index_adj;
         /*"wrk_end: %d\n",wrk_end */
         /*"wrk_adj: %d\n",wrk_adj */
         /*|boucle while */
         while (current.index_adj != -1)
          {
           
    	    /*"while......nb: %d,index_adj: %d,index_end: %d\n",nb,current.index_adj,current.index_end*/
	    if(current.index_end == 1)
             {
       	       /*|reverse_pt */
               rpar1 = NULL;
	       rpar2 = NULL;
	       if(p_par1 != NULL && p_par1[wrk_adj]!= NULL)
		  rpar1 = &p_par1[wrk_adj];
	       if(p_par2 != NULL && p_par2[wrk_adj]!= NULL)
		  rpar2 = &p_par2[wrk_adj];
               if(!reverse_pt(&pts[wrk_adj],nb_pts[wrk_adj],
			    rpar1,rpar2))
		  {
		    UI_status("VDSorder_pt: error reverse_pts");
		    goto error;
		  }
              }/* end current end = 1 */
             tpts[k] = (double *)realloc((char *)tpts[k],
					  3*(nb+nb_pts[wrk_adj]-1)*sizeof(double ));
             if(tpts[k] == NULL)
                {
                  UI_status("Bad dynamic allocation ");
                  goto error;
                }
	     /*|continue a remplir les tpts (pas le 1er qui est le meme) */
	     for(l=0;l<nb_pts[wrk_adj]-1;l++)
	      {
		tpts[k][3*nb+3*l]   = pts[wrk_adj][3*(l+1)];
		tpts[k][3*nb+3*l+1] = pts[wrk_adj][3*(l+1)+1];
		tpts[k][3*nb+3*l+2] = pts[wrk_adj][3*(l+1)+2];
	      }
/*^
	     for(l=0;l<nb_pts[wrk_adj]-1 && l<10 ;l++)
		printf("tpts: %lf, %lf, %lf\n",tpts[k][3*nb+3*l],tpts[k][3*nb+3*l+1],
			tpts[k][3*nb+3*l+2]);
*/
	     if(p_par1 != NULL)
              {
                tp_par1[k] = (double *)realloc((char *)tp_par1[k],
					  2*(nb+nb_pts[wrk_adj]-1)*sizeof(double ));
                if(tp_par1[k] == NULL)
                 {
                  UI_status("Bad dynamic allocation ");
                  goto error;
                 }
	        /*|continue a remplir les tp_par1 (pas le 1er qui est le meme) */
	        for(l=0;l<nb_pts[wrk_adj]-1;l++)
	         {
		   tp_par1[k][2*nb+2*l]   = p_par1[wrk_adj][2*(l+1)];
		   tp_par1[k][2*nb+2*l+1] = p_par1[wrk_adj][2*(l+1)+1];
	         }
              }
	     if(p_par2 != NULL)
              {
                tp_par2[k] = (double *)realloc((char *)tp_par2[k],
					  2*(nb+nb_pts[wrk_adj]-1)*sizeof(double ));
                if(tp_par2[k] == NULL)
                 {
                  UI_status("Bad dynamic allocation ");
                  goto error;
                 }
	        /*|continue a remplir les tp_par2 (pas le 1er qui est le meme) */
	        for(l=0;l<nb_pts[wrk_adj]-1;l++)
	         {
		   tp_par2[k][2*nb+2*l]   = p_par2[wrk_adj][2*(l+1)];
		   tp_par2[k][2*nb+2*l+1] = p_par2[wrk_adj][2*(l+1)+1];
	         }
              }
	     nb = nb + nb_pts[wrk_adj] - 1;
/*^
	     printf("nb: %d\n",nb);
	     printf("adj: %d, end: %d\n",pt_info[wrk_adj][wrk_end].index_adj,
					pt_info[wrk_adj][wrk_end].index_end);

*/
      if(pt_info[wrk_adj][wrk_end].index_adj == -1)
       {
         /*| set adj to 0 not to be taken as an other gp */
         pt_info[wrk_adj][wrk_end].index_adj = 0;
         break;
       }
	   current.index_adj = pt_info[wrk_adj][wrk_end].index_adj;
	   current.index_end = pt_info[wrk_adj][wrk_end].index_end;
           wrk_end = 1 - current.index_end;
           wrk_adj = current.index_adj;
           /*"wrk_end: %d\n",wrk_end */
           /*"wrk_adj: %d\n",wrk_adj */

        }/* end while */
       /*"nb end while: %d\n",nb */
       tnb_pts[k] = nb;
/*^
	printf("tnb_pts[%d]: %d\n",k,tnb_pts[k]);
        for(l=0;l<tnb_pts[k] && l<10 ;l++)
            printf("pts: %lf, %lf, %lf\n",tpts[k][3*l],tpts[k][3*l+1],tpts[k][3*l+2]);
*/
       k = k + 1;

     }/*end if pt_info[0] = -1 */
    else if(pt_info[i][1].index_adj == -1 )
     {
       /*|//////////////pt_info[i][1] = -1 */
       /*|reverse_pt */
      rpar1 = NULL;
      rpar2 = NULL;
      if(p_par1 != NULL && p_par1[i]!= NULL)
	rpar1 = &p_par1[i];
      if(p_par2 != NULL && p_par2[i]!= NULL)
	rpar2 = &p_par2[i];
      if(!reverse_pt(&pts[i],nb_pts[i],rpar1,rpar2))
	{
	  UI_status("VDSorder_pt: error reverse_pts");
	  goto error;
	}
      nb = 0;
      /*"pt2 of pt %d is a beginning of gp\n",i*/
      tpts[k]= (double *)malloc(3* nb_pts[i] *sizeof(double));
       if(tpts[k] == NULL)
        {
         UI_status("Bad dynamic allocation ");
         goto error;
        }
       /*|remplit les tpts */
       
       for(l=0;l<nb_pts[i];l++)
        {
	  tpts[k][3*l]   = pts[i][3*l];
	  tpts[k][3*l+1] = pts[i][3*l+1];
	  tpts[k][3*l+2] = pts[i][3*l+2];
        }
      
       if(p_par1 != NULL)
        {
	 tp_par1[k] = (double *)malloc(2*nb_pts[i]*sizeof(double ));
         if(tp_par1[k] == NULL)
          {
           UI_status("Bad dynamic allocation ");
           goto error;
          }
         /*|remplit tp_par1 */

          for(l=0;l<nb_pts[i];l++)
           {
	    tp_par1[k][2*l]   = p_par1[i][2*l];
	    tp_par1[k][2*l+1] = p_par1[i][2*l+1];
           }
         }
       if(p_par2 != NULL)
        {
	 tp_par2[k] = (double *)malloc(2*nb_pts[i]*sizeof(double ));
         if(tp_par2[k] == NULL)
          {
           UI_status("Bad dynamic allocation ");
           goto error;
          }
         /*|remplit tp_par2 */

          for(l=0;l<nb_pts[i];l++)
           {
	    tp_par2[k][2*l]   = p_par2[i][2*l];
	    tp_par2[k][2*l+1] = p_par2[i][2*l+1];
           }
         }
       /*"nb_pts[%d]: %d\n",i,nb_pts[i]*/
       nb = nb + nb_pts[i];
       current.index_adj = pt_info[i][0].index_adj;
       current.index_end = pt_info[i][0].index_end;
       wrk_end = 1 - current.index_end;
       wrk_adj = current.index_adj;
       /*"wrk_end: %d\n",wrk_end */
       /*"wrk_adj: %d\n",wrk_adj */
    
        /*|boucle while */
       while (current.index_adj != -1)
        {
           
    	  /*"while......nb: %d,index_adj: %d,index_end: %d\n",nb,current.index_adj,current.index_end*/
	  if(current.index_end == 1)
           {
       	     /*|reverse_pt */
             rpar1 = NULL;
	     rpar2 = NULL;
	     if(p_par1 != NULL && p_par1[wrk_adj]!= NULL)
		rpar1 = &p_par1[wrk_adj];
	     if(p_par2 != NULL && p_par2[wrk_adj]!= NULL)
		rpar2 = &p_par2[wrk_adj];
             if(!reverse_pt(&pts[wrk_adj],nb_pts[wrk_adj],
			    rpar1,rpar2))
		{
		  UI_status("VDSorder_pt: error reverse_pts");
		  goto error;
		}
            }/* end current end = 1 */
           tpts[k] = (double *)realloc((char *)tpts[k],
					  3*(nb+nb_pts[wrk_adj]-1)*sizeof(double ));
           if(tpts[k] == NULL)
              {
               UI_status("Bad dynamic allocation ");
               goto error;
              }
	   /*|continue a remplir les tpts (pas le 1er qui est le meme) */
	   for(l=0;l<nb_pts[wrk_adj]-1;l++)
	      {
		tpts[k][3*nb+3*l]   = pts[wrk_adj][3*(l+1)];
		tpts[k][3*nb+3*l+1] = pts[wrk_adj][3*(l+1)+1];
		tpts[k][3*nb+3*l+2] = pts[wrk_adj][3*(l+1)+2];
	      }
/*^
	   for(l=0;l<nb_pts[wrk_adj]-1 && l<10 ;l++)
		printf("tpts: %lf, %lf, %lf\n",tpts[k][3*nb+3*l],tpts[k][3*nb+3*l+1],
			tpts[k][3*nb+3*l+2]);
*/
	   if(p_par1 != NULL)
              {
                tp_par1[k] = (double *)realloc((char *)tp_par1[k],
					  2*(nb+nb_pts[wrk_adj]-1)*sizeof(double ));
                if(tp_par1[k] == NULL)
                 {
                  UI_status("Bad dynamic allocation ");
                  goto error;
                 }
	        /*|continue a remplir les tp_par1 (pas le 1er qui est le meme) */
	        for(l=0;l<nb_pts[wrk_adj]-1;l++)
	         {
		   tp_par1[k][2*nb+2*l]   = p_par1[wrk_adj][2*(l+1)];
		   tp_par1[k][2*nb+2*l+1] = p_par1[wrk_adj][2*(l+1)+1];
	         }
              }
	   if(p_par2 != NULL)
              {
                tp_par2[k] = (double *)realloc((char *)tp_par2[k],
					  2*(nb+nb_pts[wrk_adj]-1)*sizeof(double ));
                if(tp_par2[k] == NULL)
                 {
                  UI_status("Bad dynamic allocation ");
                  goto error;
                 }
	        /*|continue a remplir les tp_par2 (pas le 1er qui est le meme) */
	        for(l=0;l<nb_pts[wrk_adj]-1;l++)
	         {
		   tp_par2[k][2*nb+2*l]   = p_par2[wrk_adj][2*(l+1)];
		   tp_par2[k][2*nb+2*l+1] = p_par2[wrk_adj][2*(l+1)+1];
	         }
              }
	   nb = nb + nb_pts[wrk_adj] - 1;
/*^
	   printf("nb: %d\n",nb);
	   printf("adj: %d, end: %d\n",pt_info[wrk_adj][wrk_end].index_adj,
					pt_info[wrk_adj][wrk_end].index_end);

*/
      if(pt_info[wrk_adj][wrk_end].index_adj == -1)
       {
         /* set adj to 0 not to be taken as an other gp */
         pt_info[wrk_adj][wrk_end].index_adj = 0;
         break;
       }
	   current.index_adj = pt_info[wrk_adj][wrk_end].index_adj;
	   current.index_end = pt_info[wrk_adj][wrk_end].index_end;
           wrk_end = 1 - current.index_end;
           wrk_adj = current.index_adj;
           /*"wrk_end: %d\n",wrk_end */
           /*"wrk_adj: %d\n",wrk_adj */

        }/* end while */
       /*"nb end while: %d\n",nb */
       tnb_pts[k] = nb;
/*^
	printf("tnb_pts[%d]: %d\n",k,tnb_pts[k]);
        for(l=0;l<tnb_pts[k] && l<10 ;l++)
            printf("pts: %lf, %lf, %lf\n",tpts[k][3*l],tpts[k][3*l+1],tpts[k][3*l+2]);
*/
       k = k + 1;
  
   }/*end if pt_info[1] = -1 */
 }
}



/*^
 printf("tnb_int at the end of the function: %d\n",tnb_int);
 for(i=0;i<tnb_int;i++)
  {
   printf("tnb_pts: %d\n",tnb_pts[i]);
   for(k=0;k<tnb_pts[i] && k<10 ;k++)
    printf("pts: %lf, %lf, %lf\n",tpts[i][3*k],tpts[i][3*k+1],tpts[i][3*k+2]);
  }
*/

/**/
/*
/*         load output variables or free local variables          */
/**/

  if(snb_int != NULL) 
   {
    *snb_int = tnb_int;
    /*"returned nb_int: %d\n",*snb_int*/
   }

  if(snb_pts == NULL) {if(tnb_pts != NULL) {free(tnb_pts);tnb_pts = NULL;}}
  else
   {
    *snb_pts = tnb_pts;
/*^
    for(i=0;i<tnb_int;i++) printf("snb_pts[%d]: %d\n",i,(*snb_pts)[i]);
*/
   }

  if(spts == NULL) 
    {
     /*|spts = NULL, dealloc tpts */
      VDSfree(tnb_int,&tpts);
    }
  else
   {
    *spts = tpts;

/*^
   printf("nb groupe: %d\n",tnb_int);
   for(i=0;i<tnb_int;i++)
    {
      printf("groupe    : %d\n",i );
      for(k=0;k<tnb_pts[i];k++) 
       printf("returned pts: %lf, %lf, %lf\n",(*spts)[i][3*k],(*spts)[i][3*k+1],(*spts)[i][3*k+2]);
    }
*/
   }

  /*| CH modif */
  /* if(p_par1 == NULL || sp_par1 == NULL)  instead of if(sp_par1 == NULL) */
  if(p_par1 == NULL || sp_par1 == NULL) 
    {
     /*|p_par1 = NULL || sp_par1 = NULL , dealloc tp_par1*/
     VDSfree(tnb_int,&tp_par1);
    }
  else
   {
    *sp_par1 = tp_par1;

/*^
   for(i=0;i<tnb_int;i++)
    {
      printf("* -- memory fault ??? \n");
      printf("* There is here a memory fault when debug on when:\n");
      printf("*   - Intersection plan / compsurf\n");
      printf("*   - Two curves are found but no adjacantcy found\n");
      printf("*   boum but I did not find why ....  Good luck Pascale\n");
      printf("*   Come from a confusion between sp_par & p_par\n");
      printf("* *\n");
      printf("groupe: %d\n",i);
      for(k=0;k<tnb_pts[i];k++) 
       printf("returned par1: %lf, %lf\n",(*sp_par1)[i][2*k],(*sp_par1)[i][2*k+1]);
    }
*/
   }

  /* CH old:  if(sp_par2 == NULL)  */
  if(p_par2 == NULL || sp_par2 == NULL) 
    {
     /*| p_par2 = NULL || sp_par2 = NULL, dealloc par2*/
     VDSfree(tnb_int,&tp_par2);
    }
  else
   {
    *sp_par2 = tp_par2;

/*^
   for(i=0;i<tnb_int;i++)
    {
      printf("groupe: %d\n",i);
      for(k=0;k<tnb_pts[i];k++) 
       printf("returned par2: %lf, %lf\n",(*sp_par2)[i][2*k],(*sp_par2)[i][2*k+1]);
    }
*/
   }
if(end_pt != NULL) {free(end_pt); end_pt = NULL;}
VDSfree(nb_int,&pt_info);

return 1;

error:

if(end_pt != NULL) {free(end_pt); end_pt = NULL;}
VDSfree(nb_int ,&pt_info);
VDSfree(tnb_int,&tpts);
VDSfree(tnb_int,&tp_par1);
VDSfree(tnb_int,&tp_par2);

if(tnb_pts != NULL ){free(tnb_pts);tnb_pts = NULL;}
return 0;

}



/* ------------------------------------------------------------------- 

   reverse_pt:  function which which reverse the arrays pts ,par1,par2
 		(if pts-> pt1, pt2, pt3... new pts-> ..pt3, pt2,pt1

   ------------------------------------------------------------------- */

reverse_pt(pts, nb, par1,par2)
IGRdouble 		**pts;
int		nb;
IGRdouble 		**par1;
IGRdouble 		**par2;
/*.reverse_pt*/
{
double 		*tpts,*tpar1,*tpar2;
int		i;

tpts = NULL;
tpar1 = NULL;
tpar2 = NULL;
if(par1 != NULL)
 {
  /*|visu des par1*/
  for(i=0;i<nb;i++){/*"i: %d, par1: %lf, %lf\n",i,(*par1)[2*i],(*par1)[2*i+1]*/}
 }
if(pts != NULL)
 {
  tpts = (double *)malloc(3*nb*sizeof(double ));
  if(tpts == NULL)
   {
     UI_status("Bad dynamic allocation ");
    goto error;
   }
  for (i=0;i<nb;i++)
   {
    tpts[3*i]   = (*pts)[3*nb-3*(i+1)];
    tpts[3*i+1] = (*pts)[3*nb-3*(i+1)+1];
    tpts[3*i+2] = (*pts)[3*nb-3*(i+1)+2];
   }
  for (i=0;i<3*nb;i++)(*pts)[i] = tpts[i];
  for (i=0;i<nb;i++)
   {/*"reverse pts %d: %lf, %lf, %lf\n",i,(*pts)[3*i],(*pts)[3*i+1],(*pts)[3*i+2]*/}
 }
if(par1 != NULL)
 {
  for (i=0;i<nb;i++){/*"i: %d, par1: %lf, %lf\n",i,(*par1)[2*i],(*par1)[2*i+1]*/}
  tpar1 = (double *)malloc(2*nb*sizeof(double ));
  if(tpar1 == NULL)
   {
    UI_status("Bad dynamic allocation ");
    goto error;
   }
  for (i=0;i<nb;i++)
   {
    tpar1[2*i]   = (*par1)[2*nb-2*(i+1)];
    tpar1[2*i+1] = (*par1)[2*nb-2*(i+1)+1];
    /*"i: %d, tpar1: %lf, %lf\n",i,tpar1[2*i],tpar1[2*i+1]*/
   }
  for (i=0;i<2*nb;i++) (*par1)[i] = tpar1[i];
  for (i=0;i<nb;i++)
   {/*"reverse par1 %d: %lf, %lf\n",i,(*par1)[2*i],(*par1)[2*i+1]*/}
 }
if(par2 != NULL)
 {
  tpar2 = (double *)malloc(2*nb*sizeof(double ));
  if(tpar2 == NULL)
   {
    UI_status("Bad dynamic allocation ");
    goto error;
   }
  for (i=0;i<nb;i++)
   {
    tpar2[2*i]   = (*par2)[2*nb-2*(i+1)];
    tpar2[2*i+1] = (*par2)[2*nb-2*(i+1)+1];
    /*"i: %d, tpar2: %lf, %lf\n",i,tpar2[2*i],tpar2[2*i+1]*/
   }
  for (i=0;i<2*nb;i++)(*par2)[i] = tpar2[i];
  for (i=0;i<nb;i++)
   {/*"reverse par2 %d:  %lf, %lf\n",i,(*par2)[2*i],(*par2)[2*i+1]*/}
 }

goto success;
success:
  /*|success */
  if(tpts != NULL){free(tpts);tpts = NULL;}
  if(tpar1 != NULL){free(tpar1);tpar1 = NULL;}
  if(tpar2 != NULL){free(tpar2);tpar2 = NULL;}

return 1;
error:

if(tpts != NULL){free(tpts);tpts = NULL;}
if(tpar1 != NULL){free(tpar1);tpar1 = NULL;}
if(tpar2 != NULL){free(tpar2);tpar2 = NULL;}
return 0;

}



/* ------------------------------------------------------------------- 
  
   VDSlns_curve:  Given an array of points (>=2) allocates the memory
  		  of a bspline curve of order 2 an fills it. The user 
		  will have to free the curve. (BSfreecv(&rc, curve) )
  		  Return TRUE if OK else FALSE.

   ------------------------------------------------------------------- */


#define ORDER	2

VDSlns_curve(num_pts, pts, curve)
int 		num_pts;	/* I  Number of points 		*/
IGRdouble		*pts;		/* I  Array of points		*/
struct IGRbsp_curve **curve;	/* O  bspline curve		*/
/*.VDSlns_curve */
{
 BSrc 		rc;
 int		k;

 /*"num_pts: %d\n",num_pts*/
 if(num_pts < 2)
  {
   /*|Not enought points */
   return 0;
  }

 /*| Dynamic allocation of the curve */
 BSalloccv(ORDER, num_pts, 0, 0, curve, &rc);
 if(rc != BSSUCC&& rc!=BSNULL) 
  { 
   UI_status("Bad dynamic allocation ");
   return 0;
  }

 /*| Fill the structure for the bspline */
 (*curve)->order     = ORDER;
 (*curve)->num_poles = num_pts;
 (*curve)->num_knots = num_pts + 2 * (ORDER - 1);

 /*| knots, poles, ... */
 for(k=0;k<num_pts;k=k+1)
  {
   (*curve)->poles[3*k]   = pts[3*k]; 
   (*curve)->poles[3*k+1] = pts[3*k+1]; 
   (*curve)->poles[3*k+2] = pts[3*k+2]; 

   (*curve)->knots[k+1]   = (double) k/ (num_pts-1);
  }

 /* WARNING, OK only if order == 2 */
 (*curve)->knots[0]         = 0;
 (*curve)->knots[num_pts+1] = 1;

 /*^
 for(k=0;k<num_pts && k<10;k=k+1)
    printf("pts: %lf, %lf, %lf\n", 
          (*curve)->poles[3*k],(*curve)->poles[3*k+1],(*curve)->poles[3*k+2]);
    
  for(k=0;k<num_pts+ORDER && k<10;k=k+1) printf("knot: %lf\n",(*curve)->knots[k]);
  */
 return 1;
}




/* ------------------------------------------------------------------- 
  
   VDSfill_curve: Given an array of points (>=2) or an array of param
  		  allocates the memory of a bspline curve of order 2 an 
		  fills it. The user will have to free the curve:
  			(BSfreecv(&rc, curve) )		  

                  Return TRUE if OK else FALSE.

   ------------------------------------------------------------------- */


VDSfill_curve(num_pts, pts, par, curve)
int 			num_pts;	/* I  Number of points 		  */
IGRdouble			*pts;		/* I  Array of points		  */
IGRdouble			*par;		/* I  Array of param (on surface) */
struct IGRbsp_curve 	**curve;	/* O  bspline curve		  */
/*.VDSfill_curve */
{
 BSrc 		rc;
 int		k;

 /*"num_pts: %d\n",num_pts*/
 if(num_pts < 2)
  {
   /*|Not enought points */
   return 0;
  }
 if(pts == NULL && par == NULL)
  {
    UI_status("VDSfill_curve : Invalid argument");
    return 0;
  }
 if(pts != NULL && par != NULL)
  {
    UI_status("VDSfill_curve : Invalid argument");
    return 0;
  }

 /*| Dynamic allocation of the curve */
 BSalloccv(ORDER, num_pts, 0, 0, curve, &rc);
 if(rc != BSSUCC && rc!=BSNULL) 
  { 
   UI_status("Bad dynamic allocation ");
   return 0;
  }

 /*| Fill the structure for the bspline */
 (*curve)->order     = ORDER;
 (*curve)->num_poles = num_pts;
 (*curve)->num_knots = num_pts + 2 * (ORDER - 1);

 /*| knots, poles, ... */
 if(pts != NULL)
  {
    /*|define by points */
    for(k=0;k<num_pts;k=k+1)
      {
       (*curve)->poles[3*k]   = pts[3*k]; 
       (*curve)->poles[3*k+1] = pts[3*k+1]; 
       (*curve)->poles[3*k+2] = pts[3*k+2]; 

       (*curve)->knots[k+1]   = (double) k/ (num_pts-1);
      }
  }
 if(par != NULL)
  {
    /*|define by param */   
    for(k=0;k<num_pts;k=k+1)
      {
       (*curve)->poles[3*k]   = par[2*k]; 
       (*curve)->poles[3*k+1] = par[2*k+1]; 
       (*curve)->poles[3*k+2] = 0;

       (*curve)->knots[k+1]   = (double) k/ (num_pts-1);
      }
  }

 /* WARNING, OK only if order == 2 */
 (*curve)->knots[0]         = 0;
 (*curve)->knots[num_pts+1] = 1;

/*^
 for(k=0;k<num_pts && k<10;k=k+1)
    printf("pts: %lf, %lf, %lf\n", 
          (*curve)->poles[3*k],(*curve)->poles[3*k+1],(*curve)->poles[3*k+2]);
    
  for(k=0;k<num_pts+ORDER && k<10;k=k+1) printf("knot: %lf\n",(*curve)->knots[k]);
  */
 return 1;
}



/* ------------------------------------------------------------------- 

   VDSfree: free the array of nb_ptr ptr and set the ptr to NULL.

   ------------------------------------------------------------------- */


VDSfree(nb_ptr, ptr)
int	nb_ptr;
char	***ptr;
/*.VDSfree*/
{
int i;
  if(*ptr != NULL) 
    {
     /*|ptr != NULL */
     for(i=0;i<nb_ptr;i++)
       if((*ptr)[i] != NULL) {free((*ptr)[i]);(*ptr)[i] = NULL;}
     if(*ptr != NULL){ free(*ptr);*ptr = NULL;}
    }
return 1;
}

/* ------------------------------------------------------------------- 

   VDSdist2: function that returns the square of dist between the 2 
	     given points.

   ------------------------------------------------------------------- */

VDSdist2(pt1, pt2)
IGRdouble		pt1[3];
IGRdouble		pt2[3];
/*.VDSdist2*/
{
 double      dx, dy, dz, dist;
/*"pt1: %lf, %lf, %lf\n", pt1[0],pt1[1],pt1[2]*/
/*"pt2: %lf, %lf, %lf\n", pt2[0],pt2[1],pt2[2]*/

 dx = pt2[0] - pt1[0];
 dy = pt2[1] - pt1[1];
 dz = pt2[2] - pt1[2];

dist = dx*dx + dy*dy +dz*dz;
/*"dist: %lf\n",dist */

return(dist);

}

/* ------------------------------------------------------------------- 

   VDSadj_pt: function which returns 1 if pt1 and pt2
                are adjacents (in the tolerance tol)

   ------------------------------------------------------------------- */ 


VDSadj_pt(pt1,pt2,tol)
IGRdouble		*pt1; 
IGRdouble		*pt2; 
IGRdouble		tol; 
/*.VDSadj_pt*/
{
IGRdouble       tol2,dist,dx,dy,dz;    

/*"pt1: %lf, %lf, %lf\n",pt1[0],pt1[1],pt1[2]*/
/*"pt2: %lf, %lf, %lf\n",pt2[0],pt2[1],pt2[2]*/

dx = pt2[0] - pt1[0];
dy = pt2[1] - pt1[1];
dz = pt2[2] - pt1[2];

/*"dx: %lf, dy: %lf, dz: %lf\n",dx,dy,dz*/

dist = dx*dx + dy*dy + dz*dz;

/*| KLUDDGE CH, use the basis tol * 10 to avoid computation problem */
/*tol = tol * 10.;*/

/*"tol: %lf\n",tol*/
/*"dist: %lf\n",dist */
tol2 = tol*tol;
/*"tol2: %lf\n",tol2*/
if(dist < tol*tol) return 1;
else return 0;
}

/* ------------------------------------------------------------------- 

   VDSorder_gpe: function that order all input curves that are 
		 adjacents in gpe of curves. Return the nb of gpe , the
		 nb of curves in each gpe and the ordered array of curves.

   nb_cv is allocated by the function and must be deallocated by the user.
   array is allocated by the function and must be deallocated by the 
   user as free(array).(array[i] is deallocated by curves[i]).
   ------------------------------------------------------------------- */

VDSorder_gpe(nb_cv, curves, nb_gpe, nb_cvgp, array)
int			nb_cv;     /* (I) nb of input curves 		*/
struct IGRbsp_curve	**curves;  /* (I) input curves       		*/
int			*nb_gpe;   /* (O) nb of ouput gpe 		*/
int			**nb_cvgp;   /* (O) nb of curve of each gpe 	*/
struct IGRbsp_curve	***array;  /* (O) ouput array of curves       	*/
/*.VDSorder_gpe */
{
int			nb_time, *t_nbcv, close,i,j,k,l,m, nb;
double			tol;
BSrc			rc;
int			wrk_end, wrk_adj;
int			*nb_index, **cv_index;
struct IGRbsp_curve	**bsp_cv; 
struct curve_info	*end_pt;
struct pt_info		current, **pt_info;
long			nput, nret, msg;

if(nb_gpe == NULL)
  {UI_status("VDSorder_gpe : Invalid argument");return(0);}
if(nb_cvgp == NULL)
  {UI_status("VDSorder_gpe : Invalid argument");return(0);}


end_pt		= NULL;
pt_info 	= NULL;
cv_index        = NULL;
nb_index	= NULL;
bsp_cv		= NULL;
*nb_gpe 	= 0;
t_nbcv 		= NULL;
close   	= 0;

nput = sizeof(tol);
gr$get_basis_tolerance(msg = &msg, sizbuf = &nput, buffer = &tol, nret = &nret);
/*"tol: %lf\n",tol*/
end_pt = (struct curve_info *) malloc(nb_cv * sizeof(struct curve_info));
if(end_pt == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}

cv_index = (int **)malloc(nb_cv * sizeof(int *));
if(cv_index == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}
for(i=0;i<nb_cv;i++) cv_index[i] = NULL;

nb_index = (int *)malloc(nb_cv * sizeof(int ));
if(nb_index == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}

pt_info = (struct pt_info **) malloc(nb_cv * sizeof(struct pt_info *));
if(pt_info == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}
for(i=0;i<nb_cv;i++) pt_info[i] = NULL;

for(i=0;i<nb_cv;i++)
  {
  pt_info[i] = (struct pt_info *) malloc(2 * sizeof(struct pt_info ));
  if(pt_info[i] == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}
 }

/*|end point for each point gpe */

for(i=0;i<nb_cv;i++)
  {
  end_pt[i].pt1[0] = curves[i]->poles[0];
  end_pt[i].pt1[1] = curves[i]->poles[1];
  end_pt[i].pt1[2] = curves[i]->poles[2];

  end_pt[i].pt2[0] = curves[i]->poles[3*(curves[i]->num_poles-1)];
  end_pt[i].pt2[1] = curves[i]->poles[3*(curves[i]->num_poles-1)+1];
  end_pt[i].pt2[2] = curves[i]->poles[3*(curves[i]->num_poles-1)+2];

  /*"gp %d\n",i */
  /*"end0: %lf, %lf, %lf\n",end_pt[i].pt1[0],end_pt[i].pt1[1],end_pt[i].pt1[2]*/
  /*"end1:%lf, %lf, %lf\n",end_pt[i].pt2[0],end_pt[i].pt2[1],end_pt[i].pt2[2]*/
  
 }

/*|init adjacent info for each end_pt */

for(i=0;i<nb_cv;i++)
  {
  pt_info[i][0].index_adj = -1;
  pt_info[i][0].index_end = -1;
  pt_info[i][1].index_adj = -1;
  pt_info[i][1].index_end = -1;
 }

/*|fill adjacent info for each end pt */
i=0;
nb_time = 0;
while(nb_time <nb_cv)
  {
  /*"index : %d, nb_time: %d ...................\n",i,nb_time*/
  /*"adj0: %d\n",pt_info[i][0].index_adj*/
  /*"adj1: %d\n",pt_info[i][1].index_adj*/
  if(VDSadj_pt(end_pt[i].pt1,end_pt[i].pt2,tol))
       {
          /*^printf("probleme les 2 end_pts du gp %d sont idem\n",i);*/
	  /* les index resteront a -1 => gpe a part*/
          i++;
          nb_time ++;
          continue;
       }
  if(pt_info[i][1].index_adj == -1 )
   {
    /*"on a -1 on pt2 a index : %d, nb_time: %d \n",i,nb_time*/
    j=0;
    while(j<nb_cv)
     {
      /*"index i %d, j %d , nb_time %d --- \n",i,j,nb_time*/      
      if(j == i) {j++;continue;}

      if(VDSadj_pt(end_pt[i].pt2,end_pt[j].pt1,tol))
        {
          /*"pt2 is adj to pt1 of pt: %d\n", j*/
  	  pt_info[i][1].index_adj = j;
  	  pt_info[i][1].index_end = 0;
  	  pt_info[j][0].index_adj = i;
  	  pt_info[j][0].index_end = 1;
          i=j;
          break;
        }/* end VDSadj_pt =1 */
      if(VDSadj_pt(end_pt[i].pt2,end_pt[j].pt2,tol))
        {
          /*"pt2 is adj to pt2 of pt: %d\n", j*/
          /*"reverse curve: %d\n",j*/
          BSrev_cv(&rc, curves[j]);
          if(rc != BSSUCC) 
           { 
            printf("surf_int, ERROR cannot reverse the curve\n");
            goto wrapup;
           }
          end_pt[j].pt1[0] = curves[j]->poles[0];
          end_pt[j].pt1[1] = curves[j]->poles[1];
          end_pt[j].pt1[2] = curves[j]->poles[2];

          end_pt[j].pt2[0] = curves[j]->poles[3*(curves[j]->num_poles-1)];
          end_pt[j].pt2[1] = curves[j]->poles[3*(curves[j]->num_poles-1)+1];
          end_pt[j].pt2[2] = curves[j]->poles[3*(curves[j]->num_poles-1)+2];
  	  /*"gp %d\n",j */
  	  /*"new end0: %lf, %lf, %lf\n",end_pt[j].pt1[0],end_pt[j].pt1[1],end_pt[j].pt1[2]*/
  	  /*"new end1: %lf, %lf, %lf\n",end_pt[j].pt2[0],end_pt[j].pt2[1],end_pt[j].pt2[2]*/

  	  pt_info[i][1].index_adj = j;
  	  pt_info[i][1].index_end = 0;
  	  pt_info[j][0].index_adj = i;
  	  pt_info[j][0].index_end = 1;
          i=j;
          break;
        }/* end VDSadj_pt =1 */
      j++;
     }/* end loop j */
   }/* end of info[i][0].index_adj = -1 */
  else
   {
    /*|info[i][0].index_adj != -1, passe au suivant*/
    i++;
   }
  nb_time ++; /* CORRECTION PL 23-06-92 ******/
 }/* end of loop while i */

*nb_gpe = 0;
for(i=0;i<nb_cv;i++)
  {
  if(pt_info[i][0].index_adj == -1) *nb_gpe = *nb_gpe + 1;
  if(pt_info[i][1].index_adj == -1) *nb_gpe = *nb_gpe + 1;
 }
*nb_gpe = *nb_gpe/2;
if(*nb_gpe == 0)
  {
    /*|we have only 1 gp */
    *nb_gpe= 1;
    close = 1;
  }
/*^printf("*nb_gpe: %d\n",*nb_gpe);*/

t_nbcv = NULL;
t_nbcv = (int *)malloc((*nb_gpe)*sizeof(int));
if(t_nbcv == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}

k = 0;
if(close == 1)
  {
       /*| close curve */
       for(i=0;i<nb_cv;i++) cv_index[i] = NULL;
       nb = 0;
       nb_index[0] = nb_cv;

      /*"adj0: %d, adj1: %d\n",pt_info[0][0].index_adj,pt_info[0][1].index_adj*/
 
       cv_index[0] = (int *)malloc(nb_index[0] * sizeof(int ));
       if(cv_index[0] == NULL)
         {UI_status("Bad dynamic allocation ");goto wrapup;}
       cv_index[0][nb] = 0;
       nb = nb + 1;
       current.index_adj = pt_info[0][1].index_adj;
       current.index_end = pt_info[0][1].index_end;
       wrk_end = 1 - current.index_end;
       wrk_adj = current.index_adj;
       /*"wrk_end: %d\n",wrk_end */
       /*"wrk_adj: %d\n",wrk_adj */
       /*|boucle while */

       while (current.index_adj != 0)
        {
          cv_index[0][nb]= wrk_adj;
          nb = nb +1;
	   current.index_end = pt_info[wrk_adj][wrk_end].index_end;
	   current.index_adj = pt_info[wrk_adj][wrk_end].index_adj;
           wrk_end = 1 - current.index_end;
           wrk_adj = current.index_adj;
           /*"wrk_end: %d\n",wrk_end */
           /*"wrk_adj: %d\n",wrk_adj */
	   /*"cur adj: %d, cur end: %d\n",current.index_adj,current.index_end*/

        }/* end while */
     
 }/* end close */
else
  {
   for(i=0;i<nb_cv;i++)
    {
      /*| not close curve */
      nb = 0;
      cv_index[i] = NULL;

      /*"boucle sur le remplissage des gp i: %d\n",i*/
      /*"adj0: %d, adj1: %d\n",pt_info[i][0].index_adj,pt_info[i][1].index_adj*/

      if(pt_info[i][0].index_adj == -1 && pt_info[i][1].index_adj == -1 )
       {
         /*|/////////pt_info[i][0] = -1 & pt_info[i][1]= -1 */
         nb_index[i] = 1;     
         cv_index[i] = (int *)malloc(nb_index[i] * sizeof(int ));
         if(cv_index[i] == NULL)
            {UI_status("Bad dynamic allocation ");goto wrapup;}
         cv_index[i][nb] = i;
	 printf("cv_index[i][nb]: %d\n",cv_index[i][nb]);
         nb = nb + 1;
       }/* end adj0 -1, adj1 -1 */ 
      else if (pt_info[i][0].index_adj == -1 )
       {
         /*|//////////////pt_info[i][0] = -1 */
         cv_index[i] = (int *)malloc(nb_cv * sizeof(int ));
         if(cv_index[i] == NULL)
            {UI_status("Bad dynamic allocation ");goto wrapup;}
         cv_index[i][nb] = i;
         nb = nb + 1;
         /*"pt1 of pt %d is a beginning of gp\n",i*/
          current.index_adj = pt_info[i][1].index_adj;
          current.index_end = pt_info[i][1].index_end;
          wrk_end = 1 - current.index_end;
          wrk_adj = current.index_adj;
          /*"wrk_end: %d\n",wrk_end */
          /*"wrk_adj: %d\n",wrk_adj */
          /*|boucle while */

          while (current.index_adj != -1)
           {
             cv_index[i][nb]= wrk_adj;
             nb = nb +1;
             if(pt_info[wrk_adj][wrk_end].index_adj == -1)
              {
                /*| set adj to 0 not to be taken as an other gp */
                pt_info[wrk_adj][wrk_end].index_adj = 0;
                break;
              }
	      current.index_adj = pt_info[wrk_adj][wrk_end].index_adj;
	      current.index_end = pt_info[wrk_adj][wrk_end].index_end;
              wrk_end = 1 - current.index_end;
              wrk_adj = current.index_adj;
              /*"wrk_end: %d\n",wrk_end */
              /*"wrk_adj: %d\n",wrk_adj */

           }/* end while */
          /*"nb end while: %d\n",nb */
          nb_index[i] = nb;
          /*^for(l=0;l<nb;l++) printf("cv_index[%d][%d]: %d\n",i,l,cv_index[i][l]);*/
          k = k + 1;
       }/* end adj0 -1, adj1 qcq */ 
     else if(pt_info[i][1].index_adj == -1 )
      {
        /*|//////////////pt_info[i][1] = -1 */
         cv_index[i] = (int *)malloc(nb_cv * sizeof(int ));
         if(cv_index[i] == NULL)
            {UI_status("Bad dynamic allocation ");goto wrapup;}
         cv_index[i][nb] = i;
         nb = nb + 1;
         /*"pt1 of pt %d is a beginning of gp\n",i*/
          current.index_adj = pt_info[i][0].index_adj;
          current.index_end = pt_info[i][0].index_end;
          wrk_end = 1 - current.index_end;
          wrk_adj = current.index_adj;
          /*"wrk_end: %d\n",wrk_end */
          /*"wrk_adj: %d\n",wrk_adj */
          /*|boucle while */

          while (current.index_adj != -1)
           {
             cv_index[i][nb]= wrk_adj;
             nb = nb +1;
             if(pt_info[wrk_adj][wrk_end].index_adj == -1)
              {
                /*| set adj to 0 not to be taken as an other gp */
                pt_info[wrk_adj][wrk_end].index_adj = 0;
                break;
              }
	      current.index_adj = pt_info[wrk_adj][wrk_end].index_adj;
	      current.index_end = pt_info[wrk_adj][wrk_end].index_end;
              wrk_end = 1 - current.index_end;
              wrk_adj = current.index_adj;
              /*"wrk_end: %d\n",wrk_end */
              /*"wrk_adj: %d\n",wrk_adj */

           }/* end while */
          /*"nb end while: %d\n",nb */
          nb_index[i] = nb;
          /*^for(l=0;l<nb;l++) printf("cv_index[%d][%d]: %d\n",i,l,cv_index[i][l]);*/
          k = k + 1;

       }/* end adj0 qcq, adj1 -1 */ 

    }/* end boucle i */
 }
/* fill bsp_cv and array*/

nb = 0;
l=0;
m=0;
bsp_cv = NULL;
bsp_cv = (struct IGRbsp_curve **)
		malloc(nb_cv*sizeof( struct IGRbsp_curve *));
if(bsp_cv == NULL){UI_status("Bad dynamic allocation ");goto wrapup;}
for(k=0;k<nb_cv;k++) bsp_cv[k] = NULL;

for(i=0;i<nb_cv;i++)
  {
   if(cv_index[i] != NULL)
    {
      /*"nb_index[i]: %d\n",nb_index[i]*/
      nb = nb + nb_index[i];
      for(k=0;k<nb_index[i];k++)
       {
         /*"index i: %d, l: %d, m: %d\n",i,l,m*/
	 /*" bsp index: %d, curve index: %d\n",l,cv_index[i][k]*/
         bsp_cv[l] = curves[cv_index[i][k]];
         /*^
	    printf("bsp_cv num_poles: %d\n",bsp_cv[l]->num_poles);
            for (j=0;j <bsp_cv[l]->num_poles; j=j+1)
		printf("poles : %lf, %lf, %lf\n",bsp_cv[l]->poles[3*j],
		bsp_cv[l]->poles[3*j+1],bsp_cv[l]->poles[3*j+2]);
	  */
         l = l + 1;
       }
      t_nbcv[m] = nb_index[i];
      /*"t_nbcv[%d]: %d\n",m,t_nbcv[m]*/
      m = m + 1;
    }
 }

*nb_cvgp = &t_nbcv[0];
if(array != NULL)
  {
  *array = &bsp_cv[0];
/*^  for(i=0;i< nb_cv; i++)
    printf("array.num_poles: %d\n",(*array)[i]->num_poles);
*/
 }
else
  {
    if(bsp_cv != NULL) {free(bsp_cv);bsp_cv = NULL;}
 }
VDSfree(nb_cv, (char ***)&cv_index);
if(nb_index != NULL){free(nb_index);nb_index = NULL;}
if(end_pt != NULL) {free(end_pt); end_pt = NULL;}
VDSfree(nb_cv,(char ***)&pt_info);
return 1;

wrapup:
 VDSfree(nb_cv, (char ***)&cv_index);
 if(nb_index != NULL){ free(nb_index);nb_index = NULL;}
 if(bsp_cv != NULL) {free(bsp_cv);bsp_cv = NULL;}
 if(end_pt != NULL) {free(end_pt); end_pt = NULL;}
 VDSfree(nb_cv,(char ***)&pt_info);
 return 0;

}



/* ------------------------------------------------------------------- 

   VDadd_cv_to_close: given param (u,v) of the first and the last end 
		      point on the surface bsp_surf, this function 
		      link these two points with the border of the 
		      surface (isoparametric curves  u/v = 0/1). 
		      The output curves are given from end_par2 to end_par1.
	curves is allocated by the function and must be deallocated by the
	user: for(i=0;i< nb_cv;i++) BSfreecv(&rc, curves[i]) and free(curves)

   ------------------------------------------------------------------- */




VDadd_cv_to_close(msg,end_par1, end_par2, nb_cv, bsp_surf,curves)
long			*msg;
IGRdouble			*end_par1;
IGRdouble			*end_par2;
int			*nb_cv;
struct IGRbsp_surface   *bsp_surf;
struct IGRbsp_curve	***curves;
/*.VDadd_cv_to_close*/
{

IGRdouble		new_end[2],d_par, *param,par1, par2,value,coeff,
			tol;
int			i,k,close_bd,rev;
long			nput,stat, nret;
short			opt;
BSrc			rc;
IGRboolean		tst_plan,all_on_surf;
struct IGRbsp_curve	*cpcurve, **int_curve;



param 	  = NULL;
close_bd  = 0;
cpcurve   = NULL;
int_curve = NULL;


if(nb_cv == NULL) {UI_status("VDadd_cv_to_close : Invalid argument");goto wrapup;}
if(curves == NULL){UI_status("VDadd_cv_to_close : Invalid argument");goto wrapup;}

*nb_cv    = 0;


# ifdef DEBUG2
  printf("u_num_poles: %d,v_num_poles: %d\n",bsp_surf->u_num_poles,bsp_surf->v_num_poles);
# endif

nput = sizeof(tol);
gr$get_basis_tolerance(msg = msg, sizbuf = &nput, buffer = &tol, nret = &nret);

# ifdef DEBUG2
  printf("basis_tolerance: %lf\n",tol);
# endif

coeff = 0;
# ifdef DEBUG2
  printf("end_par1: %lf,  %lf\n",end_par1[0],end_par1[1]);
  printf("end_par2: %lf,  %lf\n",end_par2[0],end_par2[1]);
# endif
    for(k=0;k<2;k=k+1) 
	       coeff = coeff + fabs(end_par2[k] - end_par1[k]);

    if (coeff < tol)
	{
           close_bd = 1;
#          ifdef DEBUG2
           printf("close bd\n");
#          endif
	   *nb_cv = 0;
	   *msg = 1;
           return(1);
	}
     else
        {
#         ifdef DEBUG2
          printf("add necessary curves to close the boundary\n");
#         endif

          if (end_par1[0] != 0 && end_par1[0] !=1 &&
	      end_par1[1] != 0 && end_par1[1] != 1) 
                {
                 UI_status("VDadd_cv_to_close: error, end 0 is not on the border");
                 goto wrapup;
                }
          if (end_par2[0] != 0 && end_par2[0] !=1 &&
	      end_par2[1] != 0 && end_par2[1] != 1) 
                {
                 UI_status("VDadd_cv_to_close: error, end n is not on the border");
                 goto wrapup;
                }

          if ((end_par1[0] == end_par2[0]) &&
	       (end_par1[0] == 1|| end_par1[0] == 0)) 
             {
#               ifdef DEBUG2
                printf("x0=xn=1/0 => add curve u=x0 from yn to y0  \n");
#               endif
		opt = 1;  		/*u cst*/
		value = end_par1[0];
		tst_plan = FALSE;
		 cpcurve = NULL;
                /* alloc cpcurve of v_num_pole + v_num_knots*/
     		 BSalloccv(bsp_surf->v_order, bsp_surf->v_num_poles,
			   bsp_surf->rational, 0,  &cpcurve, &rc);
      		if(rc != BSSUCC && rc!=BSNULL) 
       		 { 
        	  UI_status("Bad dynamic allocation ");
		  goto wrapup;
		 }
    		BSconstprcv(&rc,bsp_surf,&opt,&value,&tst_plan,cpcurve);
		if(rc != BSSUCC){printf("ERROR  BSconstprcv: %d\n",rc);goto wrapup;}

#               ifdef DEBUG2
		printf("cpcurve result----\n");
		printf("nb_pole: %d\n",cpcurve->num_poles);
		for(i=0;i<cpcurve->num_poles;i++)
		  printf("poles: %lf, %lf, %lf\n",cpcurve->poles[3*i],cpcurve->poles[3*i+1],cpcurve->poles[3*i+2]);
#               endif

		/*| partof cpcurve */
		int_curve = NULL;
		int_curve = (struct IGRbsp_curve **)malloc(1*sizeof (struct IGRbsp_curve *));
   		if(int_curve == NULL) 
    		 {
     			UI_status("Bad dynamic allocation ");
     			goto wrapup;
    		 }
		 int_curve[0] = NULL;
     		 BSalloccv(cpcurve->order, cpcurve->num_poles + 2 * cpcurve->order - 1, 
			   cpcurve->rational,cpcurve->num_boundaries, 
			   &int_curve[0], &rc);
      		if(rc != BSSUCC && rc!=BSNULL) 
       		 { 
        	  UI_status("Bad dynamic allocation ");
		  goto wrapup;
		 }
		par1 = end_par2[1];
		par2 = end_par1[1];
		if(par1 > par2)	rev = 1;
		else		rev = 0;
      		d_par = (par1+par2)/2.;
                BSpartofcv(&rc, cpcurve, par1, d_par, par2, int_curve[0]);
         	if(rev)     
	  	 {
	    	   BSrev_cv(&rc, int_curve[0]);
            	   if(rc != BSSUCC) 
              		{ 
       			  printf("surf_int, ERROR cannot reverse the curve\n");
			  goto wrapup;
			}
		 }
                BSfreecv(&rc, cpcurve);
	        cpcurve=NULL;
	        if (rc !=BSSUCC && rc!=BSNULL) 
                    {printf("BSfreecv(curve) fail\n");goto wrapup;}
		
#               ifdef DEBUG2
		printf("partofcv result----\n");
		printf("nb_pole: %d\n",int_curve[0]->num_poles);
		for(i=0;i<int_curve[0]->num_poles;i++)
		  printf("poles: %lf, %lf, %lf\n",int_curve[0]->poles[3*i],int_curve[0]->poles[3*i+1],int_curve[0]->poles[3*i+2]);
#               endif

		*nb_cv = *nb_cv + 1;
	     }
	   else if ((end_par1[1] == end_par2[1] &&
	      (end_par1[1] == 1 || end_par1[1] == 0)))
             {
#               ifdef DEBUG2
                printf("y0=yn=0/1 => add curve v=y0 from xn to x0 \n");
#               endif
		opt = 2;  		/*v cst*/
		value = end_par1[1];
		tst_plan = FALSE;
		
                /* alloc cpcurve of u_num_pole + u_num_knots*/
		 cpcurve = NULL;
     		 BSalloccv(bsp_surf->u_order, bsp_surf->u_num_poles , 
			   bsp_surf->rational, 0,  &cpcurve, &rc);
      		if(rc != BSSUCC && rc!=BSNULL) 
       		 { 
        	  UI_status("Bad dynamic allocation ");
		  goto wrapup;
		 }
    		BSconstprcv(&rc,bsp_surf,&opt,&value,&tst_plan,cpcurve);
		if(rc != BSSUCC){printf("ERROR  BSconstprcv: %d\n",rc);goto wrapup;}

#               ifdef DEBUG2
		printf("cpcurve result----\n");
		printf("nb_pole: %d\n",cpcurve->num_poles);
		for(i=0;i<cpcurve->num_poles;i++)
		  printf("poles: %lf, %lf, %lf\n",cpcurve->poles[3*i],cpcurve->poles[3*i+1],cpcurve->poles[3*i+2]);
#               endif

		/*| partof cpcurve */
		int_curve = NULL;
		int_curve = (struct IGRbsp_curve **)malloc(1*sizeof (struct IGRbsp_curve *));
   		if(int_curve == NULL) 
    		 {
     			 UI_status("Bad dynamic allocation ");
     			goto wrapup;
    		 }
		 int_curve[0] = NULL;
     		 BSalloccv(cpcurve->order, cpcurve->num_poles + 2 * cpcurve->order - 1, 
			   cpcurve->rational,cpcurve->num_boundaries, 
			   &int_curve[0], &rc);
      		if(rc != BSSUCC && rc!=BSNULL) 
       		 { 
        	  UI_status("Bad dynamic allocation ");
		  goto wrapup;
		 }
		par1 = end_par2[0];
		par2 = end_par1[0];
		if(par1 > par2)	rev = 1;
		else		rev = 0;
      		d_par = (par1+par2)/2.;
                BSpartofcv(&rc, cpcurve, par1, d_par, par2, int_curve[0]);
		if(rc != BSSUCC){printf("ERROR  BSpartofcv: %d\n",rc);goto wrapup;}
         	if(rev)     
	  	 {
	    	   BSrev_cv(&rc, int_curve[0]);
            	   if(rc != BSSUCC) 
              		{ 
       			  printf("surf_int, ERROR cannot reverse the curve\n");
			  goto wrapup;
			}
		 }
                BSfreecv(&rc, cpcurve);
	        cpcurve=NULL;
	        if (rc !=BSSUCC && rc!=BSNULL) 
                    {printf("BSfreecv(curve) fail\n");goto wrapup;}
		
#               ifdef DEBUG2
		printf("partofcv result----\n");
		printf("nb_pole: %d\n",int_curve[0]->num_poles);
		for(i=0;i<int_curve[0]->num_poles;i++)
		  printf("poles: %lf, %lf, %lf\n",int_curve[0]->poles[3*i],int_curve[0]->poles[3*i+1],int_curve[0]->poles[3*i+2]);
#               endif

                *nb_cv = *nb_cv + 1;
	     }
          else if ((end_par1[0] == 0 || end_par1[0] == 1)  &&
                   (end_par2[1] == 0 || end_par2[1] == 1)) 
             {
#               ifdef DEBUG2
                printf("x0 = 0/1 & yn =0/1 => add cv v=yn from xn to x0 puis u=x0 from yn to y0 (corner)\n");
#               endif
		opt = 2;  		/*v cst*/
		value = end_par2[1];
		tst_plan = FALSE;
		
                /* alloc cpcurve of u_num_pole + u_num_knots*/
		 cpcurve = NULL;
     		 BSalloccv(bsp_surf->u_order, bsp_surf->u_num_poles, 
			   bsp_surf->rational, 0,  &cpcurve, &rc);
      		if(rc != BSSUCC && rc!=BSNULL) 
       		 { 
        	  UI_status("Bad dynamic allocation ");
		  goto wrapup;
		 }
    		BSconstprcv(&rc,bsp_surf,&opt,&value,&tst_plan,cpcurve);
		if(rc != BSSUCC){printf("ERROR  BSconstprcv: %d\n",rc);goto wrapup;}

#               ifdef DEBUG2
		printf("cpcurve result----\n");
		printf("nb_pole: %d\n",cpcurve->num_poles);
		for(i=0;i<cpcurve->num_poles;i++)
		  printf("poles: %lf, %lf, %lf\n",cpcurve->poles[3*i],cpcurve->poles[3*i+1],cpcurve->poles[3*i+2]);
#               endif

		/*| partof cpcurve */
		int_curve = NULL;
		int_curve = (struct IGRbsp_curve **)malloc(2*sizeof (struct IGRbsp_curve *));
   		if(int_curve == NULL) 
    		 {
     			UI_status("Bad dynamic allocation ");
     			goto wrapup;
    		 }
		 int_curve[0] = NULL;
		 int_curve[1] = NULL;

     		 BSalloccv(cpcurve->order, cpcurve->num_poles + 2 * cpcurve->order - 1, 
			   cpcurve->rational,cpcurve->num_boundaries, 
			   &int_curve[0], &rc);
      		if(rc != BSSUCC && rc!=BSNULL) 
       		 { 
        	  UI_status("Bad dynamic allocation ");
		  goto wrapup;
		 }
		par1 = end_par2[0];
		par2 = end_par1[0];
		if(par1 > par2)	rev = 1;
		else		rev = 0;
      		d_par = (par1+par2)/2.;
                BSpartofcv(&rc, cpcurve, par1, d_par, par2, int_curve[0]);
		if(rc != BSSUCC){printf("ERROR  BSpartofcv: %d\n",rc);goto wrapup;}
         	if(rev)     
	  	 {
	    	   BSrev_cv(&rc, int_curve[0]);
            	   if(rc != BSSUCC) 
              		{ 
       			  printf("surf_int, ERROR cannot reverse the curve\n");
			  goto wrapup;
			}
		 }
                BSfreecv(&rc, cpcurve);
	        cpcurve=NULL;
	        if (rc !=BSSUCC && rc!=BSNULL) 
                    {printf("BSfreecv(curve) fail\n");goto wrapup;}
		
#               ifdef DEBUG2
		printf("partofcv result----\n");
		printf("nb_pole: %d\n",int_curve[0]->num_poles);
		for(i=0;i<int_curve[0]->num_poles;i++)
		  printf("poles: %lf, %lf, %lf\n",int_curve[0]->poles[3*i],int_curve[0]->poles[3*i+1],int_curve[0]->poles[3*i+2]);

		printf("add the second curve u=x0 from yn to y0..........\n");
#               endif

		opt = 1;  		/*u cst*/
		value = end_par1[0];
		tst_plan = FALSE;
		 cpcurve = NULL;
                /* alloc cpcurve of v_num_pole + v_num_knots*/
     		 BSalloccv(bsp_surf->v_order, bsp_surf->v_num_poles , 
			   bsp_surf->rational, 0,  &cpcurve, &rc);
      		if(rc != BSSUCC && rc!=BSNULL) 
       		 { 
        	  UI_status("Bad dynamic allocation ");
		  goto wrapup;
		 }
    		BSconstprcv(&rc,bsp_surf,&opt,&value,&tst_plan,cpcurve);
		if(rc != BSSUCC){printf("ERROR BSconstprcv : %d\n",rc);goto wrapup;}
#               ifdef DEBUG2
		printf("cpcurve result----\n");
		printf("nb_pole: %d\n",cpcurve->num_poles);
		for(i=0;i<cpcurve->num_poles;i++)
		  printf("poles: %lf, %lf, %lf\n",cpcurve->poles[3*i],cpcurve->poles[3*i+1],cpcurve->poles[3*i+2]);
#               endif

		/*| partof cpcurve */
     		 BSalloccv(cpcurve->order, cpcurve->num_poles + 2 * cpcurve->order - 1, 
			   cpcurve->rational,cpcurve->num_boundaries, 
			   &int_curve[1], &rc);
      		if(rc != BSSUCC && rc!=BSNULL) 
       		 { 
        	  UI_status("Bad dynamic allocation ");
		  goto wrapup;
		 }
		par1 = end_par2[1];
		par2 = end_par1[1];
		if(par1 > par2)	rev = 1;
		else		rev = 0;
      		d_par = (par1+par2)/2.;
                BSpartofcv(&rc, cpcurve, par1, d_par, par2, int_curve[1]);
		if(rc != BSSUCC){printf("ERROR BSpartofcv : %d\n",rc);goto wrapup;}
         	if(rev)     
	  	 {
	    	   BSrev_cv(&rc, int_curve[1]);
            	   if(rc != BSSUCC) 
              		{ 
       			  printf("surf_int, ERROR cannot reverse the curve\n");
			  goto wrapup;
			}
		 }
                BSfreecv(&rc, cpcurve);
	        cpcurve=NULL;
	        if (rc !=BSSUCC && rc!=BSNULL) 
                    {printf("BSfreecv(curve) fail\n");goto wrapup;}
		
#               ifdef DEBUG2
		printf("partofcv result----\n");
		printf("nb_pole: %d\n",int_curve[1]->num_poles);
		for(i=0;i<int_curve[1]->num_poles;i++)
		  printf("poles: %lf, %lf, %lf\n",int_curve[1]->poles[3*i],int_curve[1]->poles[3*i+1],int_curve[1]->poles[3*i+2]);
#               endif

                *nb_cv = *nb_cv + 2;
             }
          else if ((end_par2[0] == 0 || end_par2[0] == 1)  &&
                   (end_par1[1] == 0 || end_par1[1] == 1)) 
             {
#               ifdef DEBUG2
                printf("xn = 0/1 & y0 =0/1 => add cv u=xn from yn to y0 puis v=y0 from xn to x0(corner)\n");
#               endif
		opt = 1;  		/*u cst*/
		value = end_par2[0];
		tst_plan = FALSE;
		 cpcurve = NULL;
                /* alloc cpcurve of v_num_pole + v_num_knots*/
     		 BSalloccv(bsp_surf->v_order, bsp_surf->v_num_poles , 
			   bsp_surf->rational, 0,  &cpcurve, &rc);
      		if(rc != BSSUCC && rc!=BSNULL) 
       		 { 
        	  UI_status("Bad dynamic allocation ");
		  goto wrapup;
		 }
    		BSconstprcv(&rc,bsp_surf,&opt,&value,&tst_plan,cpcurve);
		if(rc != BSSUCC){printf("ERROR BSconstprcv : %d\n",rc);goto wrapup;}

#               ifdef DEBUG2
		printf("cpcurve result----\n");
		printf("nb_pole: %d\n",cpcurve->num_poles);
		for(i=0;i<cpcurve->num_poles;i++)
		  printf("poles: %lf, %lf, %lf\n",cpcurve->poles[3*i],cpcurve->poles[3*i+1],cpcurve->poles[3*i+2]);
#               endif

		/*| partof cpcurve */
		int_curve = NULL;
		int_curve = (struct IGRbsp_curve **)malloc(2*sizeof (struct IGRbsp_curve *));
   		if(int_curve == NULL) 
    		 {
     			UI_status("Bad dynamic allocation ");
     			goto wrapup;
    		 }
		 int_curve[0] = NULL;
		 int_curve[1] = NULL;
     		 BSalloccv(cpcurve->order, cpcurve->num_poles + 2 * cpcurve->order - 1, 
			   cpcurve->rational,cpcurve->num_boundaries, 
			   &int_curve[0], &rc);
      		if(rc != BSSUCC && rc!=BSNULL) 
       		 { 
        	  UI_status("Bad dynamic allocation ");
		  goto wrapup;
		 }
		par1 = end_par2[1];
		par2 = end_par1[1];
		if(par1 > par2)	rev = 1;
		else		rev = 0;
      		d_par = (par1+par2)/2.;
                BSpartofcv(&rc, cpcurve, par1, d_par, par2, int_curve[0]);
		if(rc != BSSUCC){printf("ERROR BSpartofcv : %d\n",rc);goto wrapup;}
         	if(rev)     
	  	 {
	    	   BSrev_cv(&rc, int_curve[0]);
            	   if(rc != BSSUCC) 
              		{ 
       			  printf("surf_int, ERROR cannot reverse the curve\n");
			  goto wrapup;
			}
		 }
                BSfreecv(&rc, cpcurve);
	        cpcurve=NULL;
	        if (rc !=BSSUCC && rc!=BSNULL) 
                    {printf("BSfreecv(curve) fail\n");goto wrapup;}
		
#               ifdef DEBUG2
		printf("partofcv result----\n");
		printf("nb_pole: %d\n",int_curve[0]->num_poles);
		for(i=0;i<int_curve[0]->num_poles;i++)
		  printf("poles: %lf, %lf, %lf\n",int_curve[0]->poles[3*i],int_curve[0]->poles[3*i+1],int_curve[0]->poles[3*i+2]);

		printf("add the second curve v=y0 from xn to x0 ..........\n");
#               endif

		opt = 2;  		/*v cst*/
		value = end_par1[1];
		tst_plan = FALSE;
		
                /* alloc cpcurve of u_num_pole + u_num_knots*/
		 cpcurve = NULL;
     		 BSalloccv(bsp_surf->u_order, bsp_surf->u_num_poles, 
			   bsp_surf->rational, 0,  &cpcurve, &rc);
      		if(rc != BSSUCC && rc!=BSNULL) 
       		 { 
        	  UI_status("Bad dynamic allocation ");
		  goto wrapup;
		 }
    		BSconstprcv(&rc,bsp_surf,&opt,&value,&tst_plan,cpcurve);
		if(rc != BSSUCC){printf("ERROR BSconstprcv : %d\n",rc);goto wrapup;}

#               ifdef DEBUG2
		printf("cpcurve result----\n");
		printf("nb_pole: %d\n",cpcurve->num_poles);
		for(i=0;i<cpcurve->num_poles;i++)
		  printf("poles: %lf, %lf, %lf\n",cpcurve->poles[3*i],cpcurve->poles[3*i+1],cpcurve->poles[3*i+2]);
#               endif

		/*| partof cpcurve */
     		 BSalloccv(cpcurve->order, cpcurve->num_poles + 2 * cpcurve->order - 1, 
			   cpcurve->rational,cpcurve->num_boundaries, 
			   &int_curve[1], &rc);
      		if(rc != BSSUCC && rc!=BSNULL) 
       		 { 
        	  UI_status("Bad dynamic allocation ");
		  goto wrapup;
		 }
		par1 = end_par2[0];
		par2 = end_par1[0];
		if(par1 > par2)	rev = 1;
		else		rev = 0;
      		d_par = (par1+par2)/2.;
                BSpartofcv(&rc, cpcurve, par1, d_par, par2, int_curve[1]);
		if(rc != BSSUCC){printf("ERROR BSpartofcv : %d\n",rc);goto wrapup;}
         	if(rev)     
	  	 {
	    	   BSrev_cv(&rc, int_curve[1]);
            	   if(rc != BSSUCC) 
              		{ 
       			  printf("surf_int, ERROR cannot reverse the curve\n");
			  goto wrapup;
			}
		 }
                BSfreecv(&rc, cpcurve);
	        cpcurve=NULL;
	        if (rc !=BSSUCC && rc!=BSNULL) 
                    {printf("BSfreecv(curve) fail\n");goto wrapup;}
		
#               ifdef DEBUG2
		printf("partofcv result----\n");
		printf("nb_pole: %d\n",int_curve[1]->num_poles);
		for(i=0;i<int_curve[1]->num_poles;i++)
		  printf("poles: %lf, %lf, %lf\n",int_curve[1]->poles[3*i],int_curve[1]->poles[3*i+1],int_curve[1]->poles[3*i+2]);
#               endif

                *nb_cv = *nb_cv + 2;
             }
          else 
             {
#               ifdef DEBUG2
                printf("ajout de 3 curves aleatoirement\n");
#               endif
                if(end_par2[0] == 0 || end_par2[0] == 1)
                 {
#                  ifdef DEBUG2
                   printf("add cv u=xn from yn to 0 puis v=0 from xn to x0 puis u=x0 from 0 to y0\n");
#                  endif
		   opt = 1;  		/*u cst*/
		   value = end_par2[0];
		   tst_plan = FALSE;
		    cpcurve = NULL;
                   /* alloc cpcurve of v_num_pole + v_num_knots*/
     		    BSalloccv(bsp_surf->v_order, bsp_surf->v_num_poles , 
			      bsp_surf->rational, 0,  &cpcurve, &rc);
      		   if(rc != BSSUCC && rc!=BSNULL) 
       		    { 
        	     UI_status("Bad dynamic allocation ");
		     goto wrapup;
		    }
    		   BSconstprcv(&rc,bsp_surf,&opt,&value,&tst_plan,cpcurve);
		   if(rc != BSSUCC){printf("ERROR BSconstprcv : %d\n",rc);goto wrapup;}

#                  ifdef DEBUG2
		   printf("cpcurve result----\n");
		   printf("nb_pole: %d\n",cpcurve->num_poles);
		   for(i=0;i<cpcurve->num_poles;i++)
		     printf("poles: %lf, %lf, %lf\n",cpcurve->poles[3*i],cpcurve->poles[3*i+1],cpcurve->poles[3*i+2]);
#                  endif

		   /*| partof cpcurve */
		   int_curve = NULL;
		   int_curve = (struct IGRbsp_curve **)malloc(3*sizeof (struct IGRbsp_curve *));
   		   if(int_curve == NULL) 
    		    {
     			UI_status("Bad dynamic allocation ");
     			goto wrapup;
    		    }
		    int_curve[0] = NULL;
		    int_curve[1] = NULL;
		    int_curve[2] = NULL;
     		    BSalloccv(cpcurve->order, cpcurve->num_poles + 2 * cpcurve->order - 1, 
			   cpcurve->rational,cpcurve->num_boundaries, 
			   &int_curve[0], &rc);
      		   if(rc != BSSUCC && rc!=BSNULL) 
       		    { 
        	     UI_status("Bad dynamic allocation ");
		     goto wrapup;
		    }
		   par1 = end_par2[1];
		   par2 = end_par1[1];
		   if(par1 > par2)	rev = 1;
		   else		rev = 0;
      		   d_par = (par1+par2)/2.;
                   BSpartofcv(&rc, cpcurve, par1, d_par, par2, int_curve[0]);
		   if(rc != BSSUCC){printf("ERROR BSpartofcv : %d\n",rc);goto wrapup;}
         	   if(rev)     
	  	    {
	    	      BSrev_cv(&rc, int_curve[0]);
            	      if(rc != BSSUCC) 
              		{ 
       			  printf("surf_int, ERROR cannot reverse the curve\n");
			  goto wrapup;
			}
		    }
                   BSfreecv(&rc, cpcurve);
	           cpcurve=NULL;
	           if (rc !=BSSUCC && rc!=BSNULL) 
                    {printf("BSfreecv(curve) fail\n");goto wrapup;}
		
#                  ifdef DEBUG2
		   printf("partofcv result----\n");
		   printf("nb_pole: %d\n",int_curve[0]->num_poles);
		   for(i=0;i<int_curve[0]->num_poles;i++)
		     printf("poles: %lf, %lf, %lf\n",int_curve[0]->poles[3*i],int_curve[0]->poles[3*i+1],int_curve[0]->poles[3*i+2]);

		   printf("add the second curve v=0 from xn to x0 ..........\n");
#                  endif

		   opt = 2;  		/*v cst*/
		   value = 0.;
		   tst_plan = FALSE;
		
                   /* alloc cpcurve of u_num_pole + u_num_knots*/
		    cpcurve = NULL;
     		    BSalloccv(bsp_surf->u_order, bsp_surf->u_num_poles , 
			   bsp_surf->rational, 0,  &cpcurve, &rc);
      		   if(rc != BSSUCC && rc!=BSNULL) 
       		    { 
        	     UI_status("Bad dynamic allocation ");
		     goto wrapup;
		    }
    		   BSconstprcv(&rc,bsp_surf,&opt,&value,&tst_plan,cpcurve);
		   if(rc != BSSUCC){printf("ERROR BSconstprcv : %d\n",rc);goto wrapup;}

#                  ifdef DEBUG2
	   	   printf("cpcurve result----\n");
		   printf("nb_pole: %d\n",cpcurve->num_poles);
		   for(i=0;i<cpcurve->num_poles;i++)
		     printf("poles: %lf, %lf, %lf\n",cpcurve->poles[3*i],cpcurve->poles[3*i+1],cpcurve->poles[3*i+2]);
#                  endif

		   /*| partof cpcurve */
     		    BSalloccv(cpcurve->order, cpcurve->num_poles + 2 * cpcurve->order - 1, 
			      cpcurve->rational,cpcurve->num_boundaries, 
			      &int_curve[1], &rc);
      		   if(rc != BSSUCC && rc!=BSNULL) 
       		    { 
        	     UI_status("Bad dynamic allocation ");
		     goto wrapup;
		    }
		   par1 = end_par2[0];
		   par2 = end_par1[0];
		   if(par1 > par2)	rev = 1;
		   else		rev = 0;
      		   d_par = (par1+par2)/2.;
                   BSpartofcv(&rc, cpcurve, par1, d_par, par2, int_curve[1]);
		   if(rc != BSSUCC){printf("ERROR BSpartofcv : %d\n",rc);goto wrapup;}
         	   if(rev)     
	  	    {
	    	      BSrev_cv(&rc, int_curve[1]);
            	      if(rc != BSSUCC) 
              		{ 
       			  printf("surf_int, ERROR cannot reverse the curve\n");
			  goto wrapup;
			}
		    }
                   BSfreecv(&rc, cpcurve);
	           cpcurve=NULL;
	           if (rc !=BSSUCC && rc!=BSNULL) 
                    {printf("BSfreecv(curve) fail\n");goto wrapup;}
		
#                  ifdef DEBUG2
		   printf("partofcv result----\n");
		   printf("nb_pole: %d\n",int_curve[1]->num_poles);
		   for(i=0;i<int_curve[1]->num_poles;i++)
		     printf("poles: %lf, %lf, %lf\n",int_curve[1]->poles[3*i],int_curve[1]->poles[3*i+1],int_curve[1]->poles[3*i+2]);

		   printf("add the third curve u=x0 from 0 to y0 ............\n");
#                  endif

		   opt = 1;  		/*u cst*/
		   value = end_par1[0];
		   tst_plan = FALSE;
		    cpcurve = NULL;
                   /* alloc cpcurve of v_num_pole + v_num_knots*/
     		    BSalloccv(bsp_surf->v_order, bsp_surf->v_num_poles , 
			   bsp_surf->rational, 0,  &cpcurve, &rc);
      		   if(rc != BSSUCC && rc!=BSNULL) 
       		    { 
        	     UI_status("Bad dynamic allocation ");
		     goto wrapup;
		    }
    		   BSconstprcv(&rc,bsp_surf,&opt,&value,&tst_plan,cpcurve);
		   if(rc != BSSUCC){printf("ERROR BSconstprcv : %d\n",rc);goto wrapup;}

#                  ifdef DEBUG2
		   printf("cpcurve result----\n");
		   printf("nb_pole: %d\n",cpcurve->num_poles);
		   for(i=0;i<cpcurve->num_poles;i++)
		     printf("poles: %lf, %lf, %lf\n",cpcurve->poles[3*i],cpcurve->poles[3*i+1],cpcurve->poles[3*i+2]);
#                  endif

		   /*| partof cpcurve */
     		    BSalloccv(cpcurve->order, cpcurve->num_poles + 2 * cpcurve->order - 1, 
			   cpcurve->rational,cpcurve->num_boundaries, 
			   &int_curve[2], &rc);
      		   if(rc != BSSUCC && rc!=BSNULL) 
       		    { 
        	     UI_status("Bad dynamic allocation ");
		     goto wrapup;
		    }
		   par1 = end_par2[1];
		   par2 = end_par1[1];
		   if(par1 > par2)	rev = 1;
		   else		rev = 0;
      		   d_par = (par1+par2)/2.;
                   BSpartofcv(&rc, cpcurve, par1, d_par, par2, int_curve[2]);
		   if(rc != BSSUCC){printf("ERROR BSpartofcv : %d\n",rc);goto wrapup;}
         	   if(rev)     
	  	    {
	    	      BSrev_cv(&rc, int_curve[2]);
            	      if(rc != BSSUCC) 
              		{ 
       			  printf("surf_int, ERROR cannot reverse the curve\n");
			  goto wrapup;
			}
		    }
                   BSfreecv(&rc, cpcurve);
	           cpcurve=NULL;
	           if (rc !=BSSUCC && rc!=BSNULL) 
                    {printf("BSfreecv(curve) fail\n");goto wrapup;}
		
#                  ifdef DEBUG2
		   printf("partofcv result----\n");
		   printf("nb_pole: %d\n",int_curve[2]->num_poles);
		   for(i=0;i<int_curve[2]->num_poles;i++)
		     printf("poles: %lf, %lf, %lf\n",int_curve[2]->poles[3*i],int_curve[2]->poles[3*i+1],int_curve[2]->poles[3*i+2]);
#                  endif

                      *nb_cv = *nb_cv + 3;

                 }
                else if(end_par2[1] == 0 || end_par2[1] == 1)
                 {
#                  ifdef DEBUG2
                   printf("add cv v=yn from xn to 0 puis u=0 from yn to y0 puis v=y0 from 0 to x0\n");
#                  endif

		   opt = 2;  		/*v cst*/
		   value = end_par2[1];
		   tst_plan = FALSE;
		
                   /* alloc cpcurve of u_num_pole + u_num_knots*/
		    cpcurve = NULL;
     		    BSalloccv(bsp_surf->u_order, bsp_surf->u_num_poles , 
			   bsp_surf->rational, 0,  &cpcurve, &rc);
      		   if(rc != BSSUCC && rc!=BSNULL) 
       		    { 
        	     UI_status("Bad dynamic allocation ");
		     goto wrapup;
		    }
    		   BSconstprcv(&rc,bsp_surf,&opt,&value,&tst_plan,cpcurve);
		   if(rc != BSSUCC){printf("ERROR BSconstprcv : %d\n",rc);goto wrapup;}

#                  ifdef DEBUG2
		   printf("cpcurve result----\n");
		   printf("nb_pole: %d\n",cpcurve->num_poles);
		   for(i=0;i<cpcurve->num_poles;i++)
		     printf("poles: %lf, %lf, %lf\n",cpcurve->poles[3*i],cpcurve->poles[3*i+1],cpcurve->poles[3*i+2]);
#                  endif

		   /*| partof cpcurve */
		   int_curve = NULL;
		   int_curve = (struct IGRbsp_curve **)malloc(3*sizeof (struct IGRbsp_curve *));
   		   if(int_curve == NULL) 
    		    {
     			UI_status("Bad dynamic allocation ");
     			goto wrapup;
    		    }
		    int_curve[0] = NULL;
		    int_curve[1] = NULL;
		    int_curve[2] = NULL;
     		    BSalloccv(cpcurve->order, cpcurve->num_poles + 2 * cpcurve->order - 1, 
			   cpcurve->rational,cpcurve->num_boundaries, 
			   &int_curve[0], &rc);
      		   if(rc != BSSUCC && rc!=BSNULL) 
       		    { 
        	     UI_status("Bad dynamic allocation ");
		     goto wrapup;
		    }
		   par1 = end_par2[0];
		   par2 = 0.;
		   if(par1 > par2)	rev = 1;
		   else		rev = 0;
      		   d_par = (par1+par2)/2.;
                   BSpartofcv(&rc, cpcurve, par1, d_par, par2, int_curve[0]);
		   if(rc != BSSUCC){printf("ERROR BSpartofcv : %d\n",rc);goto wrapup;}
         	   if(rev)     
	  	    {
	    	      BSrev_cv(&rc, int_curve[0]);
            	      if(rc != BSSUCC) 
              		{ 
       			  printf("surf_int, ERROR cannot reverse the curve\n");
			  goto wrapup;
			}
		    }
                   BSfreecv(&rc, cpcurve);
	           cpcurve=NULL;
	           if (rc !=BSSUCC && rc!=BSNULL) 
                    {printf("BSfreecv(curve) fail\n");goto wrapup;}
		
#                  ifdef DEBUG2
		   printf("partofcv result----\n");
		   printf("nb_pole: %d\n",int_curve[0]->num_poles);
		   for(i=0;i<int_curve[0]->num_poles;i++)
		     printf("poles: %lf, %lf, %lf\n",int_curve[0]->poles[3*i],int_curve[0]->poles[3*i+1],int_curve[0]->poles[3*i+2]);

		   printf("add the second curve u=0 from yn to y0 ..........\n");
#                  endif

		   opt = 1;  		/*u cst*/
		   value = 0.;
		   tst_plan = FALSE;
		    cpcurve = NULL;
                   /* alloc cpcurve of v_num_pole + v_num_knots*/
     		    BSalloccv(bsp_surf->v_order, bsp_surf->v_num_poles , 
			   bsp_surf->rational, 0,  &cpcurve, &rc);
      		   if(rc != BSSUCC && rc!=BSNULL) 
       		    { 
        	     UI_status("Bad dynamic allocation ");
		     goto wrapup;
		    }
    		   BSconstprcv(&rc,bsp_surf,&opt,&value,&tst_plan,cpcurve);
		   if(rc != BSSUCC){printf("ERROR BSconstprcv : %d\n",rc);goto wrapup;}

#                  ifdef DEBUG2
		   printf("cpcurve result----\n");
		   printf("nb_pole: %d\n",cpcurve->num_poles);
		   for(i=0;i<cpcurve->num_poles;i++)
		     printf("poles: %lf, %lf, %lf\n",cpcurve->poles[3*i],cpcurve->poles[3*i+1],cpcurve->poles[3*i+2]);
#                  endif

		   /*| partof cpcurve */
     		    BSalloccv(cpcurve->order, cpcurve->num_poles + 2 * cpcurve->order - 1, 
			   cpcurve->rational,cpcurve->num_boundaries, 
			   &int_curve[1], &rc);
      		   if(rc != BSSUCC && rc!=BSNULL) 
       		    { 
        	     UI_status("Bad dynamic allocation ");
		     goto wrapup;
		    }
		   par1 = end_par2[1];
		   par2 = end_par1[1];
		   if(par1 > par2)	rev = 1;
		   else		rev = 0;
      		   d_par = (par1+par2)/2.;
                   BSpartofcv(&rc, cpcurve, par1, d_par, par2, int_curve[1]);
		   if(rc != BSSUCC){printf("ERROR BSpartofcv : %d\n",rc);goto wrapup;}
         	   if(rev)     
	  	    {
	    	      BSrev_cv(&rc, int_curve[1]);
            	      if(rc != BSSUCC) 
              		{ 
       			  printf("surf_int, ERROR cannot reverse the curve\n");
			  goto wrapup;
			}
		    }
                   BSfreecv(&rc, cpcurve);
	           cpcurve=NULL;
	           if (rc !=BSSUCC && rc!=BSNULL) 
                    {printf("BSfreecv(curve) fail\n");goto wrapup;}
		
#                  ifdef DEBUG2
		   printf("partofcv result----\n");
		   printf("nb_pole: %d\n",int_curve[1]->num_poles);
		   for(i=0;i<int_curve[1]->num_poles;i++)
		     printf("poles: %lf, %lf, %lf\n",int_curve[1]->poles[3*i],int_curve[1]->poles[3*i+1],int_curve[1]->poles[3*i+2]);

		   printf("add the third curve v=y0 from 0 to x0 ..........\n");
#                  endif

		   opt = 2;  		/*v cst*/
		   value = end_par1[1];
		   tst_plan = FALSE;
		
                   /* alloc cpcurve of u_num_pole + u_num_knots*/
		    cpcurve = NULL;
     		    BSalloccv(bsp_surf->u_order, bsp_surf->u_num_poles , 
			   bsp_surf->rational, 0,  &cpcurve, &rc);
      		   if(rc != BSSUCC && rc!=BSNULL) 
       		    { 
        	     UI_status("Bad dynamic allocation ");
		     goto wrapup;
		    }
    		   BSconstprcv(&rc,bsp_surf,&opt,&value,&tst_plan,cpcurve);
		   if(rc != BSSUCC){printf("ERROR BSconstprcv : %d\n",rc);goto wrapup;}

#                  ifdef DEBUG2
		   printf("cpcurve result----\n");
		   printf("nb_pole: %d\n",cpcurve->num_poles);
		   for(i=0;i<cpcurve->num_poles;i++)
		     printf("poles: %lf, %lf, %lf\n",cpcurve->poles[3*i],cpcurve->poles[3*i+1],cpcurve->poles[3*i+2]);
#                  endif

		   /*| partof cpcurve */
     		    BSalloccv(cpcurve->order, cpcurve->num_poles + 2 * cpcurve->order - 1, 
			   cpcurve->rational,cpcurve->num_boundaries, 
			   &int_curve[2], &rc);
      		   if(rc != BSSUCC && rc!=BSNULL) 
       		    { 
        	     UI_status("Bad dynamic allocation ");
		     goto wrapup;
		    }
		   par1 = 0.;
		   par2 = end_par1[0];
		   if(par1 > par2)	rev = 1;
		   else		rev = 0;
      		   d_par = (par1+par2)/2.;
                   BSpartofcv(&rc, cpcurve, par1, d_par, par2, int_curve[2]);
		   if(rc != BSSUCC){printf("ERROR BSpartocv : %d\n",rc);goto wrapup;}
         	   if(rev)     
	  	    {
	    	      BSrev_cv(&rc, int_curve[2]);
            	      if(rc != BSSUCC) 
              		{ 
       			  printf("surf_int, ERROR cannot reverse the curve\n");
			  goto wrapup;
			}
		    }
                   BSfreecv(&rc, cpcurve);
	           cpcurve=NULL;
	           if (rc !=BSSUCC && rc!=BSNULL) 
                    {printf("BSfreecv(curve) fail\n");goto wrapup;}
		
#                  ifdef DEBUG2
		   printf("partofcv result----\n");
		   printf("nb_pole: %d\n",int_curve[2]->num_poles);
		   for(i=0;i<int_curve[2]->num_poles;i++)
		     printf("poles: %lf, %lf, %lf\n",int_curve[2]->poles[3*i],int_curve[2]->poles[3*i+1],int_curve[2]->poles[3*i+2]);
#                  endif


                   *nb_cv = *nb_cv + 3;
                 }
                else 
                 {
                     UI_status("VDadd_cv_to_close: error point n is not on the surface");
                     goto wrapup;
                 }
             }
   
        }/* end not closed */
*curves = NULL;
*curves = (struct IGRbsp_curve **)malloc((*nb_cv)*sizeof (struct IGRbsp_curve *));
if(*curves == NULL) 
	{
     		UI_status("Bad dynamic allocation ");
     		goto wrapup;
    	}
for(i=0; i<*nb_cv ; i=i+1) (*curves)[i] = NULL;

for(i=0; i<*nb_cv ; i=i+1)
{

# ifdef DEBUG2
  printf("transform curve %d to param\n",i);
# endif

  param = NULL;
  param = (double *)malloc(2*int_curve[i]->num_poles*sizeof (double));
  if(param == NULL) 
    		    {
     			UI_status("Bad dynamic allocation ");
     			goto wrapup;
    		    }
  BSprptsonsf(int_curve[i]->num_poles,int_curve[i]->poles,bsp_surf,param,&all_on_surf,&rc);
  if(rc != BSSUCC){printf("ERROR  BSprptsonsf: %d\n",rc);goto wrapup;}

# ifdef DEBUG2
  for(k=0;k< int_curve[i]->num_poles;k++) printf("param: %lf, %lf\n",param[2*k],param[2*k+1]);
# endif

  stat = VDSfill_curve((int)int_curve[i]->num_poles, (IGRdouble *)NULL, param, 
  			&(*curves)[i]);
  if(!(stat & 1)){UI_status("VDadd_cv_to_close: ERROR VDSfill_curve");goto wrapup;}
  if(param != NULL){free(param);param = NULL;}
  if(int_curve[i] != NULL) {BSfreecv(&rc, int_curve[i]);int_curve[i] =NULL;}

}

# ifdef DEBUG2
  printf("*nb_cv: %d\n",*nb_cv );
  for(i=0; i<*nb_cv ; i=i+1)
    {
      printf("curve %d\n",i); 
      printf("nb_poles: %d\n",(*curves)[i]->num_poles );
      for(k=0;k<(*curves)[i]->num_poles;k++)
         printf("poles: %lf, %lf, %lf\n",(*curves)[i]->poles[3*k],(*curves)[i]->poles[3*k+1],(*curves)[i]->poles[3*k+2]);
    }
# endif

*msg = 1;
new_end[0] = (*curves)[*nb_cv-1]->poles[3*((*curves)[*nb_cv-1]->num_poles-1)];
new_end[1] = (*curves)[*nb_cv-1]->poles[3*((*curves)[*nb_cv-1]->num_poles-1)+1];

# ifdef DEBUG2
  printf("end_par1: %lf,  %lf\n",end_par1[0],end_par1[1]);
  printf("new_end: %lf, %lf\n",new_end[0],new_end[1]);
# endif

coeff = 0.;
for(k=0;k<2;k=k+1) 
         coeff = coeff + fabs(new_end[k] - end_par1[k]);
    if (coeff < tol)
	{
           close_bd = 1;
#          ifdef DEBUG2
           printf("close bd\n");
#          endif
	}

if(!close_bd)
 {
   UI_status("VDadd_cv_to_close: error, boundary cannot be closed");
   goto wrapup;
 }
if(int_curve != NULL) {free(int_curve);int_curve =NULL;}
if(cpcurve != NULL){BSfreecv(&rc, cpcurve); cpcurve=NULL;}
if(param != NULL){free(param);param = NULL;}
return(1);


wrapup:

	
  	if(param != NULL){free(param);param = NULL;}
       	if(cpcurve != NULL){BSfreecv(&rc, cpcurve); cpcurve=NULL;}
	for(i=0;i<*nb_cv;i++)
	 {
  	   if(int_curve[i] != NULL) 
		{BSfreecv(&rc, int_curve[i]);int_curve[i] =NULL;}
	   if((*curves)[i] != NULL)
		{BSfreecv(&rc, (*curves)[i]);(*curves)[i] =NULL;}
	 }
	if((*curves) != NULL){free(*curves);(*curves) = NULL;}
  	if(int_curve != NULL) {free(int_curve);int_curve =NULL;}
	*nb_cv = 0;
	*msg = 0;
	return (0);

}


/* ------------------------------------------------------------------- 

   VDclose_bnd: try to close a bdry
   
   ------------------------------------------------------------------- */

VDclose_bnd(msg, bdry)
long *msg;
struct IGRbsp_bdry_pts *bdry;
/*.VDclose_bnd*/
{
int		close_bd, nb_time;
IGRdouble	coeff, tol;
int		k;


nb_time = 0;
tol = .001;
close_bd = 0;

while(close_bd != 1 && nb_time < 5)
 {
coeff = 0;
    for(k=0;k<2;k=k+1) 
         coeff = coeff + fabs(bdry->points[k] - 
                         bdry->points[2*(bdry->num_points-1 )+k]);

    if (coeff < tol)
	{
           close_bd = 1;
           /*|close bd*/
           break;
	}
     else
        {
          /*| add necessary points to close the boundary */

          if (bdry->points[0] != 0 && bdry->points[0] !=1 &&
	      bdry->points[1] != 0 && bdry->points[1] != 1) 
                {
                 UI_status("VDclose_bnd: error, point 0 is not on the border");
                 *msg = 0;
                 goto wrapup;
                }
          if (bdry->points[2*(bdry->num_points-1 )] != 0 && bdry->points[2*(bdry->num_points-1 )] !=1 &&
	      bdry->points[2*(bdry->num_points-1 )+1] != 0 && bdry->points[2*(bdry->num_points-1 )+1] != 1) 
                {
                 UI_status("VDclose_bnd: error, point n is not on the border");
                 *msg = 0;
                 goto wrapup;
                }

          if ((bdry->points[0] == bdry->points[2*(bdry->num_points-1 )] &&
	       (bdry->points[0] == 1|| bdry->points[0] == 0)) ||
	      (bdry->points[1] == bdry->points[2*(bdry->num_points-1 )+1] &&
	      (bdry->points[1] == 1 || bdry->points[1] == 0)))
             {
                /*|x0=xn=1/0 ou y0=yn=0/1 => double point de fin */
                bdry->points[2*(bdry->num_points-1 )+2] = bdry->points[0];
                bdry->points[2*(bdry->num_points-1 )+3] = bdry->points[1];
                bdry->num_points = bdry->num_points + 1;
	     }
          else if ((bdry->points[0] == 0 || bdry->points[0] == 1)  &&
                   (bdry->points[2*(bdry->num_points-1 )+1] == 0 || bdry->points[2*(bdry->num_points-1 )+1] == 1)) 
             {
                /*|x0 = 0/1 & yn =0/1 => the point to add is a corner*/

                bdry->points[2*(bdry->num_points-1 )+2] = bdry->points[0];
                bdry->points[2*(bdry->num_points-1 )+3] = bdry->points[2*(bdry->num_points-1 )+1];
                bdry->num_points = bdry->num_points + 1;
             }
          else if ((bdry->points[2*(bdry->num_points-1 )] == 0 || 
                    bdry->points[2*(bdry->num_points-1 )] == 1)  &&
                   (bdry->points[1] == 0 || bdry->points[1] == 1)) 
             {
		/*|xn = 0/1 & y0 =0/1 => the point to add is a corner*/

                bdry->points[2*(bdry->num_points-1 )+2] = bdry->points[2*(bdry->num_points-1 )];
                bdry->points[2*(bdry->num_points-1 )+3] = bdry->points[1];
                bdry->num_points = bdry->num_points + 1;
             }
          else 
             {
                /*|ajout d'un coin au hasard pour se ramener aux cas pcd*/
                if(bdry->points[2*(bdry->num_points-1 )] == 0 || 
                    bdry->points[2*(bdry->num_points-1 )] == 1)
                 {
                   bdry->points[2*(bdry->num_points-1 )+2] = bdry->points[2*(bdry->num_points-1 )];
                   bdry->points[2*(bdry->num_points-1 )+3] = 0;
                 }
                else if(bdry->points[2*(bdry->num_points-1 )+1] == 0 || 
                    bdry->points[2*(bdry->num_points-1 )+1] == 1)
                 {
                   bdry->points[2*(bdry->num_points-1 )+2] = 0;
                   bdry->points[2*(bdry->num_points-1 )+3] = bdry->points[2*(bdry->num_points-1 )+1];
                 }
                else 
                  {
                     UI_status("VDclose_bnd: error, point n is not on the surface");
                     *msg = 0;
                     goto wrapup;
                  }
                bdry->num_points = bdry->num_points + 1;
             }
   
        }/* end not closed */
/*^
  printf("num_point: %d\n",bdry->num_points );
  for(i=0; i<bdry->num_points ; i=i+1) 
      printf("point (u,v): %lf, %lf\n", bdry->points[2*i],bdry->points[2*i+1]);
*/

    nb_time = nb_time + 1;
 }/* end while */

if(!close_bd)
 {
   UI_status("VDclose_bnd: error, boundary cannot be closed");
   *msg = 0;
   goto wrapup;
 }
 
*msg = 1;

wrapup:

 return(1);

}


/***********************************************************************
/*
/*	VDget_mat:
/*  
/*  Given an object (obj) which is either a cs or a plane, the matrix 
/*  and matrix type: fill the matrix 
/*
/*  The properties (prop) allow to know if the plane has a reversed
/*  normal or not
/*
/*  return 1 if successful else 0
/*
/***********************************************************************/

VDget_mat(obj, mat_type, matrix, cs_mat, props, cs_pl)
struct GRid		*obj;		/* cs or plane id	   (I) */
IGRshort		 mat_type;	/* matrix type of obj	   (I) */
IGRdouble		*matrix;	/* matrix env of obj	   (I) */
IGRdouble		*cs_mat;	/* matrix of the plane def (O) */
IGRuchar		*props;		/* If plane properties	   (O) */
IGRshort		*cs_pl; 	/* 0 => cs, 1 => plane     (O) */
/*.VDget_mat*/
{
  IGRlong		status, msg;
  IGRint                i, index;
  IGRdouble		x_axis[3], y_axis[3], z_axis[3];
  IGRpoint		pt0, pt1;
  BSrc			rc;
  struct IGRbsp_surface *surf;
  struct IGRplane 	plane_def;
  IGRdouble		pipo[6];
  BSrc			rc2;
  IGRdouble		dotp;
  GRclassid             obj_classid;
  extern GRclassid      OPP_EMSplane_class_id, OPP_GRgencs_class_id;

  *props = 0x00;

  /*" Test if subbclass of EMSplane obj: %d, %d\n", obj->objid, obj->osnum */
  status = om$get_classid(osnum     = obj->osnum,
                          objid     = obj->objid,
                          p_classid = &obj_classid);

  if( om$is_ancestry_valid(subclassid   = obj_classid,
                           superclassid = OPP_EMSplane_class_id )
                              == OM_S_SUCCESS )
   {
     /*| Extract the matrix from the plane */
     *cs_pl = 1;

     status = om$send(msg=message GRvg.GRgenabsg(&msg, &mat_type, matrix,
					    (IGRchar **) &surf),
		     senderid = NULL_OBJID,
                     targetid = obj->objid,
                     targetos = obj->osnum);
     as$status(action = RET_STATUS);

     /*| Get the 3 points of the plane */
     BSsfeval(surf, 0., 0., 0, &pt0, &rc);
     if(rc!=BSSUCC)  return(OM_W_ABORT);
     BSsfeval(surf, 1., 0., 0, &pt1, &rc);
     if(rc!=BSSUCC)  return(OM_W_ABORT);
     for(index=0;index<3;index++) x_axis[index] = pt1[index] - pt0[index];
     MAunitvc(&rc, x_axis, x_axis);
     if(rc!=MSSUCC)  return(OM_W_ABORT);

     /*| Get the y axis */
     BSsfeval(surf, 0., 1., 0, &pt1, &rc);
     if(rc!=BSSUCC)  return(OM_W_ABORT);
     for(index=0;index<3;index++) y_axis[index]= pt1[index] - pt0[index];
     MAunitvc(&rc, y_axis, y_axis);
     if(rc!=MSSUCC)  return(OM_W_ABORT);

     /*| Compute the z axis */
     BScrossp(&rc, x_axis, y_axis, z_axis);
     if(rc!=BSSUCC)  return(OM_W_ABORT);

     /*| Recompute the y axis */
     BScrossp(&rc, z_axis, x_axis, y_axis);
     if(rc!=BSSUCC)  return(OM_W_ABORT);

     /*| Get the origine */
     BSsfeval(surf, 0.5, 0.5, 0, &pt0, &rc);
     if(rc!=BSSUCC)  return(OM_W_ABORT);

     for(i=0;i<3;i++)
      {
       cs_mat[4*i+0] = x_axis[i];
       cs_mat[4*i+1] = y_axis[i];
       cs_mat[4*i+2] = z_axis[i];
       cs_mat[4*i+3] = pt0[i];
       cs_mat[12+i]  = 0;
      }
     cs_mat[15] = 1.;

	

     status = om$send( msg = message EMSsubbs.EMget_props(&msg, props),
		     senderid = NULL_OBJID,
                     targetid = obj->objid,
                     targetos = obj->osnum);
     if(!(status & 1)) *props = 0x00;
#    ifdef DEBUG1
     if(*props & EMSIS_NRML_REVERSED) {/*| Reversed vz plane */ }
#    endif

     /* Get the normal by a GRdetplane (CH 05-05-92) */
     plane_def.point  = &pipo[0];
     plane_def.normal = &pipo[3];
     status = om$send( msg = message GRvg.GRdetplane(&msg,
				&mat_type, matrix, &plane_def),
		        senderid = NULL_OBJID,
        	        targetid = obj->objid,
 	                targetos = obj->osnum);
     as$status(action=RET_STATUS);

     dotp = BSdotp(&rc2, z_axis, plane_def.normal);

     /* Verify that the normal is good */
     if(dotp < 0)
      {
       /* There is a bad normal */

       if(*props & EMSIS_NRML_REVERSED) 
        {
	 /* Just clear the EMSIS_NRML_REVERSED props */
	 /* 12/16/92. No longer take into account the reverse properties
	 /* because it is now done in GRdetplane 
	 /* *props = *props & ~EMSIS_NRML_REVERSED; */
	}
       else
        {
	 /* We can put the props to EMSIS_NRML_REVERSED or inverted the vz */
         /* x ^ -y = -z */
	 for(i=0;i<3;i++)
          {
           cs_mat[4*i+1] = -cs_mat[4*i+1];
           cs_mat[4*i+2] = -cs_mat[4*i+2];
          }
	}
      }
    /* End modif CH 05-05-92 */
   }
  else  if( om$is_ancestry_valid(subclassid   = obj_classid,
                                 superclassid = OPP_GRgencs_class_id )
                              == OM_S_SUCCESS )
   {
    
    /*| It is a cs */
     *cs_pl = 0;

     status = om$send(msg=message GRvg.GRgenabsg(&msg, &mat_type, matrix,
					    (IGRchar **) &surf),
		     senderid = NULL_OBJID,
                     targetid = obj->objid,
                     targetos = obj->osnum);
     as$status(action = RET_STATUS);
     for(i=0;i<16;i++) cs_mat[i] = ((struct IGRlbsys *) surf)->matrix[i];

   }
  else
   {
    /*"The obj; (%d, %d) is not a coord. system or a plane\n", obj->objid, obj->osnum */
    return 0;
   }
 
  /*^ pr_mat("mat", 4, 4, cs_mat); */
  return 1;
 }


end implementation Root;
