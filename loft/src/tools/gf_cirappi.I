/*

 
	This file contains a set of functions concerning 
	approximation of a planar Bspline or Composite curve into a series
	of lines and arcs.	

*/


class implementation Root;


#define	AS_DEBUG

#include <stdio.h>

#include "OMminimum.h"
#include "OMlimits.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "gr.h"
#include "growner.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "go.h"
#include "ex.h"
#include "bserr.h"
#include "msdef.h"
#include "emserr.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "macro.h"
#include "maerr.h"
#include "AS_status.h"
#include "vlcirapp.h"

from	GRgraphics	import	GRaltconstruct; 
from	GRgraphics	import	GRconstruct;
from	GRcompcurve	import	EMmakecomp; 
from	GRcompcurve	import	EMaddtocomp; 
from    GRcurve		import  GRendpts;
from	GRcurve		import  GRtotlength;
from    GRgraphics      import  GRcopy;
from    GRvg            import  GRputsymb;
from    GRvg            import  GRdetplane;
from    GRvg            import  GRgetsize;
from    GRvg            import  GRgetgeom;
from    GRowner		import	GRget_number_components;
from    GRowner		import  GRget_components;
from    GRlinear	import	GRgetpolyline;
from    GRconic		import	GRgetarc;

extern GRclassid	OPP_GR3dlinestr_class_id;
extern GRclassid	OPP_GR3dlineseg_class_id;
extern GRclassid	OPP_GR3dcirarc_class_id;
extern GRclassid	OPP_GR3dcircle_class_id;
extern GRclassid	OPP_GRcompcurve_class_id;

extern IGRdouble	sqrt();
extern void		GFcreArcLine();
extern IGRdouble	BSdistptpt();
extern IGRboolean	BSbx2();

#include		"bslsqptlnpl.h"

#define	TESTCOPLANAR	3		// for BSlsqptlnpl
#define	NONCOPLANAR 	4		// for BSlsqptlnpl

/*===========================================================================*/


void mypr_bscv( txt, bsp, rc )

IGRchar			*txt;
struct IGRbsp_curve 	*bsp;
IGRlong			*rc;


{

 IGRint	i, j, k;

  printf(txt);
  printf("\n");


  printf("      order = %d, num_poles = %d, num_knots = %d\n",
	  bsp->order,bsp->num_poles,bsp->num_knots);

  k = (IGRint) bsp->num_poles;
  if( !(bsp->rational) ){
	for(i=0;i<k;i++){
		j = 3*i;
		printf( "      poles[%d] = %15.3f, %15.3f, %15.3f\n",i,
		bsp->poles[j],bsp->poles[j+1],bsp->poles[j+2] );
	}
  }
  else{
	for(i=0;i<k;i++){
		j = 3*i;
		printf("      poles[%d] = %15.3f, %15.3f, %15.3f, %15.6f\n",i,
		bsp->poles[j],bsp->poles[j+1],bsp->poles[j+2],bsp->weights[i] );
	}
  }

  k = bsp->num_knots;

  for(i=0;i<k;i++) printf("      knots[%d] = %12.10f\n",i,bsp->knots[i] );
  *rc = BSSUCC;

}


/*============================================================================*/
/*									      */
void GFgetStrFromGRid( msgmsg, obj_id, type, from_env, geomData, length )
/*         	       O     , I     , I   , I       , O       , O	      */
/*				                                              */
/*============================================================================*/

IGRlong			*msgmsg;      /* return code			      */
struct GRid		obj_id;	      /* GRid of the GO to add 		      */
GRclassid		type;	      /* classid			      */
struct GRmd_env		*from_env;    /* module env of GO		      */
struct geomStruct	*geomData;    /* the composite curve GRid             */
IGRdouble		*length;      /* total length of the element	      */

{

IGRint			i;
IGRlong			sts;
IGRint			action;
struct	IGRpolyline	poly;
IGRdouble		u;
IGRdouble		tab[6];

extern	IGRdouble	sqrt();


/*--------------------------  beginning of code  ---------------------------*/


if( om$is_ancestry_valid( superclassid = OPP_GR3dlineseg_class_id,
			  subclassid   = type ) == OM_S_SUCCESS ){

	GRabsg_del_by_objid( &obj_id.objid, &obj_id.osnum );

	poly.points = tab;
	poly.num_points = 2;

   	action = 1 ; /* Get points */
   	sts = om$send(	msg = message GRlinear.GRgetpolyline(
				msgmsg,
				&from_env->md_env.matrix_type,
				from_env->md_env.matrix,
				&action,
				&poly ),
          		senderid = NULL_OBJID,
			targetid = obj_id.objid,
	 		targetos = obj_id.osnum );

	if( !(sts&(*msgmsg)&1) ){
		printf("error in GFgetStrFromGRid, GRgetpolyline Failed\n");
		goto wrapup;
	}

	geomData->type = geomLine;

	*length = 0.0;

	for(i=0;i<3;i++){
		geomData->uGeom.Line[i]   = poly.points[i];
		geomData->uGeom.Line[i+3] = poly.points[i+3];
		u = geomData->uGeom.Line[i+3] - geomData->uGeom.Line[i];
		*length += u*u;
	}

	*length = sqrt( (*length) );

}
else if( om$is_ancestry_valid( superclassid = OPP_GR3dcirarc_class_id,
			       subclassid   = type ) == OM_S_SUCCESS ){


	GRabsg_del_by_objid( &obj_id.objid, &obj_id.osnum );

	geomData->type = geomArc;

   	sts = om$send(	msg = message GRconic.GRgetarc(
				msgmsg,
				&from_env->md_env.matrix_type,
				from_env->md_env.matrix,
				(struct IGRarc *)&(geomData->uGeom.Arc) ),
          		senderid = NULL_OBJID,
			targetid = obj_id.objid,
	 		targetos = obj_id.osnum );

	if( !(sts&(*msgmsg)&1) ){
		printf("error in GFgetStrFromGRid, GRconic.GRgetarc Failed\n");
		goto wrapup;
	}

	*length = geomData->uGeom.Arc.prim_axis * 
		  ( geomData->uGeom.Arc.sweep_angle - 
		    geomData->uGeom.Arc.start_angle );

}
else{ printf("unknown elem\n");	goto wrapup;}

	*msgmsg = MSSUCC;
	return;

wrapup:
	*msgmsg = MSFAIL;
	return;

}

/*============================================================================*/
/*									      */
void GFsetLineFromBS( msg, crv, fromInd, toInd, geomData, length )
/*         	      O  , I  , I      , I    , O       , O		      */
/*									      */
/*============================================================================*/

IGRlong			*msg;         /* return code			      */
struct	IGRbsp_curve	*crv;	      /* the input curve		      */
IGRint			fromInd;      /* index of the first point	      */
IGRint			toInd;        /* index of the last point	      */
struct geomStruct	*geomData;    /* the composite curve GRid             */
IGRdouble		*length;      /* total length of the element	      */

{
 
IGRint		i;
IGRdouble	u;

extern	IGRdouble	sqrt();

	
	if( (toInd - fromInd) < 3 ) goto wrapup;

	geomData->type = geomLine;

	*length = 0.0;

        for(i=0;i<3;i++){

	 	geomData->uGeom.Line[i]   = crv->poles[fromInd+i];
		geomData->uGeom.Line[i+3] = crv->poles[toInd+i];
		u  = crv->poles[toInd+i] - crv->poles[fromInd+i];
		*length += u * u;
        }
 
	*length = sqrt( (*length) );
	*msg = MSSUCC;
	return;

wrapup:
	*msg = MSFAIL;
	return;
}



/*===========================================================================*/
/*									     */
 void GFcir_app_str( msgmsg, loccrv, locobj, tol,  newcrv, nb_arcs, 
/*                   O     , I,    , I     , I  ,  O     , O   	     	     */	
		     err_max, min_len )
/*		     O	      O					     	     */
/*===========================================================================*/

IGRlong			*msgmsg;      /* return code			     */
				      /* MSSUCC or MSFAIL		     */
struct	IGRbsp_curve	*loccrv;
struct	GRobj_env	*locobj;      /* the object to approximate	     */ 
				      /* and his module env		     */
IGRdouble		tol;          /* approximation tol		     */
struct  geomStruct	**newcrv;     /* array of element solution 	     */
IGRint			*nb_arcs;     /* number of arcs			     */
IGRdouble		*err_max;     /* maximun error			     */
IGRdouble		*min_len;     /* minimun length created		     */


{

#define RATIO			10
#define ZERO			1.0E-10
#define TOL2			1.0E-12
#define SIZEMAL			100

IGRint			isi;		/* loop on single span */
IGRint			ic;		/* loop on each component */
IGRint			i,j,jjj;
IGRlong			rcPO;		/* internal return code */
IGRlong			size;		/* size of the current component */
struct	IGRplane	plane;		/* plane of the original crv */
IGRdouble		pointnor[6];
IGRdouble  	        *infl_pts;	/* the inflexion points */
IGRdouble		*infl_par;	/* the inflexion parameters */
IGRdouble		*pars;		/* the multiple knots */
IGRint			*index;         /* index of multiple knots */
GRclassid		loc_obj_cl;     /* classid of locobj	*/
struct GRid             *cmp_lst;       /* list of components */
IGRint			num_comp;	/* nb of components in the comp_crv */
IGRdouble		dv1[6];        
IGRdouble		dv2[6];
IGRdouble		matx[9];	/* local matrix where I evaluate arc */
IGRdouble		tol1;
IGRdouble		par_cou;
IGRdouble		par_pre;
IGRlong			cnvfitmsg;
IGRdouble		dist;
IGRdouble		udist;
IGRint			num_mkt;
IGRshort		num_bound;
IGRint			max_arcs;
struct	geomStruct	*newcrvptr;
IGRshort		planarity;
IGRboolean		enough_memory;
IGRboolean		LineStr;
struct IGRbsp_curve     *bsp, *bsp_orig;
IGRshort		isAnArc;
IGRdouble		locTol;
IGRpoint		minpt, maxpt;


extern IGRlong		POcircnvfit();
extern		        POspancv();
extern			POarepolaln();
extern			POchkCirArc();
extern IGRboolean       BSfindmkts(),
                        BSxtractpar(),
                        BSadd_kt2r(),
			BScv_copy(),
	                BSfreecv(),
			BScrossp(),
			BSnorvec();
extern  void		BScveval(),
			BStst_plan();
extern			GRabsg_del_by_objid();
extern IGRchar		*malloc(),
			*realloc();
extern IGRlong		POchkArcIsLn();
extern IGRdouble	fabs();



/*---------------------- Beginning of code -------------------------------*/


	newcrvptr  = NULL;
	bsp        = NULL;
	bsp_orig   = NULL;
	pars       = NULL;
	index      = NULL;
    	infl_par   = NULL;
    	infl_pts   = NULL;
	cmp_lst    = NULL;
	max_arcs   = 0;
   	*min_len   = 1.0E30;
	tol1       = 1.0E-12;
  	*nb_arcs   = 0;
  	*err_max   = -1.0;
	num_comp   = 1;
	enough_memory = FALSE;

/*=========================================================================*/
/* 	check if the curve is planar and the new referential and get the   */
/*      start and end point of the located element                         */
/*=========================================================================*/

  	plane.point  = &pointnor[0];
  	plane.normal = &pointnor[3];

	if( loccrv == NULL ){

		/*--- the curve to approximate is given as GRobj_env ---*/
		/*--- check if the curve is planar ---*/


  		om$send( msg = message  GRvg.GRdetplane( 
				msgmsg,
			       	&locobj->mod_env.md_env.matrix_type,
			       	locobj->mod_env.md_env.matrix,
                                &plane),
                	 senderid = NULL_OBJID,
			 targetid = locobj->obj_id.objid,
			 targetos = locobj->obj_id.osnum );

		if( *msgmsg == MANONPLANAR ){
#ifdef DEBUG
			printf(" in GFcir_app curve not planar \n");
#endif
			return;
        	}

		if( *msgmsg == MSFAIL ){
			printf(" in GF cir_app severe failure, bad curve \n");
			return;
        	}
  
		/*--- retrieve all the components if we got a comp curve ---*/


     		om$get_classid(	osnum	  = locobj->obj_id.osnum,	
				objid	  = locobj->obj_id.objid,
				p_classid = &loc_obj_cl );

       		if(om$is_ancestry_valid(  
				superclassid  = OPP_GRcompcurve_class_id,
			 	subclassid    = loc_obj_cl ) == OM_S_SUCCESS ){

			num_comp = 0;
			om$send( msg = message GRowner.GRget_number_components( 
						msgmsg,	&num_comp ),
                 	 	senderid = NULL_OBJID,
	  	 	 	targetid = locobj->obj_id.objid,
	  	 	 	targetos = locobj->obj_id.osnum );

     			cmp_lst = (struct GRid *)
			om$malloc( size = num_comp * sizeof(struct GRid ));
			if( cmp_lst == NULL ){
				printf("Error in malloc cmp_lst 0 \n");
				goto wrapup;
			}		
			om$send( msg = message GRowner.GRget_components( 
							msgmsg,
							&(locobj->mod_env),
							cmp_lst,
							num_comp,
							&i,
			     				(IGRint) 0,
							(IGRint)OM_K_MAXINT ),

                 	 	senderid = NULL_OBJID,
	  	 	 	targetid = locobj->obj_id.objid,
	  	 	 	targetos = locobj->obj_id.osnum );


     		}
     		else{
			num_comp = 1;
     			cmp_lst = (struct GRid *)
			om$malloc( size = num_comp * sizeof(struct GRid ));
			if( cmp_lst == NULL ){
				printf("Error in malloc cmp_lst 1 \n");
				goto wrapup;
			}		
			 cmp_lst[0].osnum = locobj->obj_id.osnum;
			 cmp_lst[0].objid = locobj->obj_id.objid;
			 ic = 0;

     		}         



		/*^for(i=0;i<num_comp;i++) 
		   printf(" cmp_lst = %d\n", cmp_lst[i].objid);  */
     



/*=========================================================================*/
/* 	retrieve the geometry as Bspline			           */
/*=========================================================================*/



  		om$send( msg = message GRvg.GRgetsize( 
					msgmsg,
			     		&locobj->mod_env.md_env.matrix_type,
			     		locobj->mod_env.md_env.matrix,
			     		&size ),
                	 senderid = NULL_OBJID,
	  		 targetid = locobj->obj_id.objid,
	  		 targetos = locobj->obj_id.osnum );


		bsp_orig = (struct IGRbsp_curve *) om$malloc( size = size );
		if( bsp_orig == NULL ){
			printf("Not enought memory for bsp_orig 1\n");
			goto wrapup;
		}

  		om$send( msg = message GRvg.GRgetgeom( 
					msgmsg,
			     		&locobj->mod_env.md_env.matrix_type,
			     		locobj->mod_env.md_env.matrix,
			     		(IGRchar *)bsp_orig ),
                	 senderid = NULL_OBJID,
	  		 targetid = locobj->obj_id.objid,
	  		 targetos = locobj->obj_id.osnum );

	}/* end case if objet passed in argument */


	else{

		/*--- the curve to approximate is given as IGRbsp_curve ---*/

    		num_bound = 0;

    		BSalloccv(  (IGRshort ) loccrv->order,
			    (IGRlong) loccrv->num_poles,
			    (IGRshort)loccrv->rational,
			    num_bound,
			    &bsp_orig,
			    &rcPO );
    		if( rcPO != BSSUCC ){
		   printf("in GFcir_app no enougth memory to allocate bsp_orig \n");
		   goto wrapup;
    		}

		BScv_copy( &rcPO, loccrv, bsp_orig ); 

		plane.normal[0] = plane.normal[1] = plane.normal[2] = 0.0;
		planarity = TRUE;
		BStst_plan( (IGRint) loccrv->num_poles,
			    loccrv->poles, loccrv->weights,
			    &planarity, &plane.normal[0],&rcPO);

		if( planarity == FALSE ){
		   IGRdouble negtol = -tol ;
				/* sometimes fails even if planar ?  So if 
				   there is a non-zero normal, carry on.*/
		   if (	( plane.normal[0] < tol && plane.normal[0] > negtol) &&
		 	( plane.normal[1] < tol && plane.normal[1] > negtol) &&
			( plane.normal[2] < tol && plane.normal[2] > negtol) ){
		
#ifdef DEBUG
			printf("curve not planar\n");
#endif
			goto wrapup; 
		   }
	     #ifdef vsDEBUG
		   else {  /* else it really did find a normal */
		 	printf( "normal to plane %f %f %f\n",
		 	       plane.normal[0],plane.normal[1],plane.normal[2]);
		   }
	     #endif
		}	/* if no planarity */
	
	}/* end case if structure passed in argument */


  
  	size = 2 * ( bsp_orig->num_knots + 1 );

  	infl_pts = (IGRdouble *)om$malloc( size = 3 * size * sizeof(IGRdouble));
	if( infl_pts == NULL ){
		printf("Not enought memory for infl_pts\n");
		goto wrapup;
	}

  	infl_par = (IGRdouble *)om$malloc(size =  size * sizeof(IGRdouble) );
	if( infl_par == NULL ){
		printf("Not enought memory for infl_par\n");
		goto wrapup;
	}

  	pars     = (IGRdouble *) om$malloc( size = size * sizeof(IGRdouble) );
	if( pars == NULL ){
		printf("Not enought memory for pars \n");
		goto wrapup;
	}

  	index    = (IGRint *) om$malloc( size = size * sizeof(IGRint) );
	if( index == NULL ){
		printf("Not enought memory for index\n");
		goto wrapup;
	}

	newcrvptr = (struct geomStruct *)
		    om$malloc( size = SIZEMAL * sizeof(struct geomStruct) );
	if( newcrvptr == NULL ){
		printf("Not enought memory for newcrvptr \n");
		goto wrapup;
	}

/*=========================================================================*/
/* 	define new basis to compute later something in 2D 		   */
/*=========================================================================*/


	BScveval ( bsp_orig , 0.0, 1, dv1, &rcPO);
        BSnorvec(&rcPO,&(dv1[3]));
	BScrossp(&rcPO,&(plane.normal[0]),&(dv1[3]),dv2);

	for(i=0;i<3;i++){
		matx[i]   = dv1[i+3];
               	matx[i+3] = dv2[i];
               	matx[i+6] = plane.normal[i];
	}


/*=========================================================================*/
/* 	general loop on each component			 		   */
/*=========================================================================*/


  for(ic=0;ic<num_comp;ic++){

   LineStr = FALSE;

   if( loccrv == NULL ){
   
     	om$get_classid(	osnum	  = cmp_lst[ic].osnum,	
			objid	  = cmp_lst[ic].objid,
			p_classid = &loc_obj_cl ) ;


     	if(
	    (om$is_ancestry_valid( superclassid = OPP_GR3dlineseg_class_id,
			        subclassid   = loc_obj_cl ) == OM_S_SUCCESS ) ||

	    (om$is_ancestry_valid( superclassid = OPP_GR3dcirarc_class_id,
			        subclassid   = loc_obj_cl ) == OM_S_SUCCESS ) ){


	    	/*--- it's a lineseg or a line or an arc ----  */

		GFgetStrFromGRid( msgmsg, cmp_lst[ic], loc_obj_cl, 
				  &(locobj->mod_env), &newcrvptr[*nb_arcs], 
				  &dist );

		if( *msgmsg == MSSUCC ){

			 *nb_arcs += 1;
			 if( (*nb_arcs+3) >=  max_arcs ){
				max_arcs = max_arcs + SIZEMAL;
				newcrvptr = ( struct geomStruct * )om$realloc( 
				size = max_arcs * sizeof(struct geomStruct),
			    	ptr  = (char *)newcrvptr );
			 }

			 if( dist < *min_len ) *min_len = dist;
		}

		goto endloop;

     	}
	else if( (om$is_ancestry_valid( 
			superclassid = OPP_GR3dlinestr_class_id,
			subclassid   = loc_obj_cl ) == OM_S_SUCCESS ) ){

		LineStr = TRUE;

		if( num_comp > 1 ){

			if(bsp_orig != NULL){ 
				om$dealloc( ptr = bsp_orig ); 
				bsp_orig = NULL ; 
			}

     			GRabsg_del_by_objid( &cmp_lst[ic].objid,
					     &cmp_lst[ic].osnum );

       			om$send( msg = message GRvg.GRgetsize( 
					msgmsg,
			     		&locobj->mod_env.md_env.matrix_type,
			     		locobj->mod_env.md_env.matrix,
			     		&size ),
                	 	senderid = NULL_OBJID,
	  	 	 	targetid = cmp_lst[ic].objid,
	  	 	 	targetos = cmp_lst[ic].osnum );

			bsp_orig = 
			(struct IGRbsp_curve *)om$malloc( size = size );
			if( bsp_orig == NULL ){
				printf("Not enought memory for bsp_orig 2\n");
				goto wrapup;
			}
	
  			om$send( msg = message GRvg.GRgetgeom( 
					msgmsg,
			     		&locobj->mod_env.md_env.matrix_type,
			     		locobj->mod_env.md_env.matrix,
			     		(IGRchar *)bsp_orig ),
                		 senderid = NULL_OBJID,
	  			 targetid = cmp_lst[ic].objid,
	  			 targetos = cmp_lst[ic].osnum );
		}


        	POarepolaln(bsp_orig,ZERO,&rcPO);
        	if( rcPO == BSSUCC ){

		    GFsetLineFromBS( msgmsg, bsp_orig, (IGRint)0, 
				     (IGRint)(3*(bsp_orig->num_poles-1)), 
				     &newcrvptr[*nb_arcs], &dist );

		    if( *msgmsg == MSSUCC ){
		    	*nb_arcs += 1;
		    	if( dist < *min_len ) *min_len = dist;

			if( (*nb_arcs+3) >=  max_arcs ){
				max_arcs = max_arcs + SIZEMAL;
				newcrvptr = ( struct geomStruct * )om$realloc( 
				    size = max_arcs * sizeof(struct geomStruct),
				    ptr  = (char *)newcrvptr );
			}
		    }

		}/* line string was a line */

		else{
			if( (*nb_arcs + bsp_orig->num_poles + 2) >= max_arcs  ){
				max_arcs += SIZEMAL +  bsp_orig->num_poles + 2;
				newcrvptr = ( struct geomStruct * )om$realloc( 
				   size = max_arcs * sizeof(struct geomStruct),
				   ptr  = (char *)newcrvptr );
			}

			
			isi = 3 * (bsp_orig->num_poles-1);

			for( j=0;j<isi;j+=3){

		    		GFsetLineFromBS( msgmsg, bsp_orig, (IGRint)j, 
				   (IGRint)(j+3), &newcrvptr[*nb_arcs], &dist );
				
				if( *msgmsg == MSSUCC ){ 
			 		*nb_arcs += 1;
			 		if( dist < *min_len ) *min_len = dist;
				}
			}

		}/* convert the linestring in a serie of lines */

		goto endloop;
		
        }/* it was a line string  */



     	if( (num_comp > 1) && ( LineStr == FALSE ) ){

		if(bsp_orig != NULL){ 
			om$dealloc( ptr = bsp_orig ); 
			bsp_orig = NULL ; 
		}

     		GRabsg_del_by_objid(&cmp_lst[ic].objid,&cmp_lst[ic].osnum);

       		om$send( msg = message GRvg.GRgetsize( 
					msgmsg,
			     		&locobj->mod_env.md_env.matrix_type,
			     		locobj->mod_env.md_env.matrix,
			     		&size ),
                	 senderid = NULL_OBJID,
	  	 	 targetid = cmp_lst[ic].objid,
	  	 	 targetos = cmp_lst[ic].osnum );

		bsp_orig = (struct IGRbsp_curve *)om$malloc( size = size );
		if( bsp_orig == NULL ){
			printf("Not enought memory for bsp_orig 3\n");
			goto wrapup;
		}
	
  		om$send( msg = message GRvg.GRgetgeom( 
					msgmsg,
			     		&locobj->mod_env.md_env.matrix_type,
			     		locobj->mod_env.md_env.matrix,
			     		(IGRchar *)bsp_orig ),
                	 senderid = NULL_OBJID,
	  		 targetid = cmp_lst[ic].objid,
	  		 targetos = cmp_lst[ic].osnum );
     	}


     }/* if loccrv NULL */


/*=========================================================================*/
/* added the 23th of Feb 94 to test if the curve is a line or an arc       */
/*=========================================================================*/

        POarepolaln(bsp_orig,ZERO,&rcPO);

        if( rcPO == BSSUCC ){

		GFsetLineFromBS( msgmsg, bsp_orig, (IGRint)0, 
				 (IGRint)(3*(bsp_orig->num_poles-1)), 
				 &newcrvptr[*nb_arcs], &dist );

		if( *msgmsg == MSSUCC ){
		    	*nb_arcs = *nb_arcs + 1;
		    	if( dist < *min_len ) *min_len = dist;

			if((*nb_arcs+3) >=  max_arcs ){
				max_arcs = max_arcs + SIZEMAL;
				newcrvptr = ( struct geomStruct * )om$realloc( 
				    size = max_arcs * sizeof(struct geomStruct),
				    ptr  = (char *)newcrvptr );
			}
		}

	   	goto endloop;

        }/* end if I found a lineseg */


   	POchkCirArc( bsp_orig->poles, 
		     bsp_orig->weights, 
		     (IGRint)bsp_orig->num_poles,
		     tol,
		     (struct IGRarc *)&newcrvptr[*nb_arcs].uGeom.Arc,
		     &isAnArc,
		     &rcPO );

	if( rcPO == BSSUCC ){

		
		dist = newcrvptr[*nb_arcs].uGeom.Arc.prim_axis * 
		       newcrvptr[*nb_arcs].uGeom.Arc.sweep_angle;
	
	   	if( isAnArc == TRUE )
			newcrvptr[*nb_arcs].type = geomArc;
           	else
			newcrvptr[*nb_arcs].type = geomCircle;


	   	*nb_arcs += 1;	   

	   	if( (*nb_arcs+3) >=  max_arcs ){
			max_arcs = max_arcs + SIZEMAL;
			newcrvptr = ( struct geomStruct * )om$realloc( 
				    size = max_arcs * sizeof(struct geomStruct),
			    	    ptr  = (char *)newcrvptr );
	   	}


	   	if( dist < *min_len ) *min_len = dist;

	   	goto endloop;

	}


/*=========================================================================*/
/* 	evaluate the number of knots with multiplicity order -1            */
/*=========================================================================*/

   index[0] = 0;   
   num_mkt = 0;

   BSfindmkts( &rcPO,
               &(bsp_orig->order),
               &(bsp_orig->num_poles),
               &(bsp_orig->knots[0]),
               &tol1,
               &num_mkt,
               pars,
	       index );


   pars[num_mkt] = 1.0;
   index[num_mkt] = bsp_orig->num_knots - bsp_orig->order;

/*=========================================================================*/
/*	malloc the curve that will contain the span			   */
/*=========================================================================*/


    num_bound = 0;

    BSalloccv(  (IGRshort ) bsp_orig->order,
		(IGRlong) bsp_orig->num_poles,
		(IGRshort)bsp_orig->rational,
		num_bound,
		&bsp,
		&rcPO );

    if( rcPO != BSSUCC ){
	printf(" in GFcir_app no enougth memory to allocate bsp \n" );
	goto wrapup;
    }


/*=========================================================================*/
/*	general loop to evaluate arcs for each curve beetwen multiple      */
/*      with multiplicity equal to order -1 				   */
/*=========================================================================*/


    for( isi=0; isi<= num_mkt; isi++ ){

	POspancv(bsp_orig,isi,num_mkt,pars,index,bsp,&rcPO);

        POarepolaln(bsp,ZERO,&rcPO);
	
        if( rcPO == BSSUCC )
        {

		GFsetLineFromBS( msgmsg, bsp, (IGRint)0, 
				 (IGRint)(3*(bsp->num_poles-1)), 
				 &newcrvptr[*nb_arcs], &dist );

		if( *msgmsg == MSSUCC ){
		    	*nb_arcs = *nb_arcs + 1;
		    	if( dist < *min_len ) *min_len = dist;

			if( (*nb_arcs+3) >=  max_arcs ){
				max_arcs = max_arcs + SIZEMAL;
				newcrvptr = ( struct geomStruct * )om$realloc( 
				    size = max_arcs * sizeof(struct geomStruct),
				    ptr  = (char *)newcrvptr );
			}
		}
		else printf("Error in GFsetLineFromBS\n");

        	goto step1;

        }/* end if I found a lineseg */

        par_cou = 1.0;
        par_pre = 0.0;
    
        BScveval ( bsp , par_pre, 1, dv1, &rcPO);
        jjj = 0;

/*=========================================================================*/
/*	for each piece beetwen multiple knots evaluate the arcs which      */
/*      approximate the curve		 				   */
/*=========================================================================*/
  
	BSbx2( &rcPO, &bsp->num_poles, bsp->poles, bsp->weights, minpt, maxpt );
	if( rcPO == BSSUCC ){
		locTol = BSdistptpt(&rcPO, minpt, maxpt );
		if( (tol/locTol) < 0.01 ) locTol = tol;
		else locTol = tol / 10.0;
	}
	else locTol = tol;  

        while(1)
	{
	   jjj = jjj + 1;

	   BScveval ( bsp , par_cou, 1, dv2, &rcPO);


  	   rcPO =  POcircnvfit( bsp,  &(dv1[0]), &(dv1[3]), &(dv2[0]), 
			        &(dv2[3]), locTol, matx,&newcrvptr[*nb_arcs], 
				&newcrvptr[*nb_arcs+1], 
				&dist, &udist, min_len, &cnvfitmsg );

           if( rcPO == BSSUCC ){

              	if( dist > *err_max ) *err_max = dist;

	      	/*--- just one arc or line constructed --- */

	      	if( (cnvfitmsg == 0) || (cnvfitmsg == 1) ) *nb_arcs += 1;

		/*--- end of construct of the two arcs ---*/

	      	else	*nb_arcs += 2;

	      	if((*nb_arcs+3) >=  max_arcs ){
			max_arcs = max_arcs + SIZEMAL;
			newcrvptr = ( struct geomStruct * )om$realloc( 
				    size = max_arcs * sizeof(struct geomStruct),
				    ptr  = (char *)newcrvptr );
	      	}

		if( (1.0 - par_cou) < tol1  ) goto step1;

                   par_pre = par_cou;
                   par_cou = 1.0;

	           for(j=0;j<6;j++) dv1[j] = dv2[j];
 
	   } /* end of action if rcPO == BSSUCC */

           else	
		par_cou =  0.7*par_cou + 0.3*par_pre ;



  	   /* printf("par_pre =%12.8f, par_cou =%12.8f\n", par_pre, par_cou);*/


	} /* end of while */

step1: continue;


     } /* end loop on variable isi means loop on single BSparc */

endloop:
	if( bsp != NULL ) { BSfreecv(&rcPO,bsp); bsp = NULL; }


}/* end loop on variable ic means loop on each component */

	if( *err_max < TOL2 ) *err_max = 0.0;

wrapup:

/*|		----- enter at wrapup level -----			*/


	*newcrv = newcrvptr;
	
	if( bsp      != NULL ) { BSfreecv(&rcPO,bsp); bsp      = NULL; }
	if( bsp_orig != NULL ) { 
		if( loccrv == NULL ){
			om$dealloc( ptr = bsp_orig);      bsp_orig = NULL; }
		else{
			BSfreecv(&rcPO,bsp_orig);         bsp_orig  = NULL; }
	}
	if( pars     != NULL ) { om$dealloc( ptr = pars);     pars     = NULL; }
	if( index    != NULL ) { om$dealloc( ptr = index);    index    = NULL; }
    	if( infl_par != NULL ) { om$dealloc( ptr = infl_par); infl_par = NULL; }
    	if( infl_pts != NULL ) { om$dealloc( ptr = infl_pts); infl_pts = NULL; }
	if( cmp_lst  != NULL ) { om$dealloc( ptr = cmp_lst);  cmp_lst  = NULL; }


}

/*============================================================================*/
/*									      */
void GFcopyGRid( msgmsg, obj_id, from_env, cst, COMP, length )
/*         	 O     , I     , I       , I  , O   , O
/*				                                              */
/*============================================================================*/

IGRlong			*msgmsg;      /* return code			      */
struct GRid		obj_id;	      /* GRid of the GO to add 		      */
struct GRmd_env		*from_env;    /* module env of GO		      */
struct GRvg_construct   *cst;	      /* cnst list to create the composite    */
struct GRid		*COMP;	      /* the composite curve GRid             */
IGRdouble		*length;      /* total length of the element	      */

{


IGRlong			status;
struct GRsymbology	symb;


/*--------------------------  beginning of code  ---------------------------*/



	symb.display_attr = *(cst->display);
	symb.level	  = cst->level;

  	status = om$send( msg	   = message GRgraphics.GRcopy(  
						msgmsg,
						from_env,
                                             	cst->env_info,
						&COMP->objid ),
                 	senderid = NULL_OBJID,
                  	targetid = obj_id.objid,
	          	targetos = obj_id.osnum  );

	COMP->osnum = cst->env_info->md_id.osnum;

  	if( !( status & 1 ) ){
		*msgmsg = MSFAIL;
  		printf( "GRgraphics.GRcopy error\n" ) ;
		return;
	}

	om$send( msg	   = message GRvg.GRputsymb( msgmsg,
						     &symb ),
                 senderid = NULL_OBJID,
                 targetid = COMP->objid,
	         targetos = COMP->osnum  );


	*length = 0.0;

   	om$send(msg= message GRcurve.GRtotlength( 
					msgmsg,
					&cst->env_info->md_env.matrix_type,
					cst->env_info->md_env.matrix,
					length),
                 	senderid = NULL_OBJID,
             		targetid = COMP->objid,
			targetos = COMP->osnum );
	if( *msgmsg != MSSUCC ){
/*^  		printf( "GRcurve.GRtotlength error\n" ) ; */
	}

}

/*===========================================================================*/
/*									     */
void  GFcreArcLine( rc, geomData, cst, geomId ) 
/*                  O , I,      , I  ,  O   	     	             	     */	
/*===========================================================================*/
IGRlong			*rc;
struct 	geomStruct	*geomData;
struct 	GRvg_construct	*cst;
struct	GRid		*geomId;

{

struct	IGRpolyline	geom;
IGRlong			stat;

*rc = MSSUCC;

if( geomData->type == geomLine ){

  	geom.num_points = 2;
        geom.points  = &(geomData->uGeom.Line[0]);
  	cst->geometry = (char *)&geom;
        geomId->objid   = NULL_OBJID;
        geomId->osnum   = cst->env_info->md_id.osnum ;


	stat = om$construct( msg = message GRgraphics.GRaltconstruct(cst),
			     classid = OPP_GR3dlineseg_class_id,
			     p_objid = &geomId->objid,
			     osnum   = geomId->osnum );

	cst->geometry = (char *)NULL;

	if( !(stat&(*(cst->msg))&1) ){
	  	*rc = MSFAIL;
		printf("in GFcreArcLine Error in om$construct GR3dlineseg\n");
	}

}/*--- end of creation if Line ---*/

else if( geomData->type == geomArc ){

	cst->geometry   = (char *)&(geomData->uGeom.Arc);
        geomId->objid   = NULL_OBJID;
        geomId->osnum   = cst->env_info->md_id.osnum ;

       	stat = om$construct( msg     = message GRgraphics.GRaltconstruct(cst),
			     classid = OPP_GR3dcirarc_class_id,
	        	     p_objid = &geomId->objid,
	        	     osnum   = geomId->osnum );

	cst->geometry = (char *)NULL;

	if( !(stat&(*(cst->msg))&1) ){
		*rc = MSFAIL;
		printf("in GFcreArcLine Error in om$construct GR3dcirarc\n");
	}

}/*--- end of creation if Arc ---*/

else *rc = MSFAIL;


}

/*===========================================================================*/
/*									     */
 void GFnew_cir_app( msgmsg, loccrv, locobj, tol, cst, newcrv, nb_arcs, 
/*                   O     , I,    , I     , I  , I  , O     , O   	     */	
		     err_max, min_len )
/*		     O	      O					     	     */
/*===========================================================================*/

IGRlong			*msgmsg;      /* return code			     */
				      /* MSSUCC or MSFAIL		     */
struct	IGRbsp_curve	*loccrv;
struct	GRobj_env	*locobj;      /* the object to approximate	     */ 
				      /* and his module env		     */
IGRdouble		tol;          /* approximation tol		     */
struct	GRvg_construct  *cst;         /* construction list		     */
struct  GRid		**newcrv;     /* the created composite curve 	     */
IGRint			*nb_arcs;     /* number of arcs			     */
IGRdouble		*err_max;     /* maximun error			     */
IGRdouble		*min_len;     /* minimun length created		     */


{

#define RATIO			10
#define ZERO			1.0E-10
#define TOL2			1.0E-12
#define SIZEMAL			100

IGRint			isi;		/* loop on single span */
IGRint			ic;		/* loop on each component */
IGRint			i,j,jjj;
IGRlong			rcPO;		/* internal return code */
IGRlong			size;		/* size of the current component */
struct	IGRplane	plane;		/* plane of the original crv */
IGRdouble		pointnor[6];
IGRdouble  	        *infl_pts;	/* the inflexion points */
IGRdouble		*infl_par;	/* the inflexion parameters */
IGRdouble		*pars;		/* the multiple knots */
IGRint			*index;         /* index of multiple knots */
GRclassid		loc_obj_cl;     /* classid of locobj	*/
struct GRid             *cmp_lst;       /* list of components */
IGRlong			stat;		/* an other return variable */
IGRint			num_comp;	/* nb of components in the comp_crv */
IGRdouble		dv1[6];        
IGRdouble		dv2[6];
IGRdouble		matx[9];	/* local matrix where I evaluate arc */
IGRdouble		tol1;
IGRdouble		par_cou;
IGRdouble		par_pre;
IGRlong			cnvfitmsg;
IGRdouble		dist;
struct geomStruct	arc1,arc2;
IGRdouble  		bstab[38];
IGRdouble		udist;
IGRint			num_mkt;
struct IGRpolyline      geom;
IGRshort		num_bound;
IGRint			max_arcs;
struct	GRid		*newcrvptr;
IGRint			savedColor;
IGRshort		planarity;
IGRboolean		enough_memory;
IGRboolean		LineStr;
struct IGRbsp_curve     *bsp, *bsp_orig;
IGRshort		isAnArc;
IGRdouble		locTol;
IGRpoint		minpt, maxpt;

extern IGRlong		POcircnvfit();
extern		        POspancv();
extern			POarepolaln();
extern			POchkCirArc();

extern IGRboolean       BSfindmkts(),
                        BSxtractpar(),
                        BSadd_kt2r(),
			BScv_copy(),
	                BSfreecv();

extern	IGRboolean	BScrossp(),
			BSnorvec();

extern  void		BScveval();

extern	void		BStst_plan();
extern			GRabsg_del_by_objid();
extern IGRchar		*malloc();
extern IGRchar		*realloc();
extern IGRlong		POchkArcIsLn();
extern IGRdouble	fabs();

	newcrvptr  = NULL;
	bsp        = NULL;
	bsp_orig   = NULL;
	pars       = NULL;
	index      = NULL;
    	infl_par   = NULL;
    	infl_pts   = NULL;
	cmp_lst    = NULL;
	max_arcs   = 0;
	savedColor = cst->display->color;
   	*min_len   = 1.0E30;
	tol1       = 1.0E-12;
  	*nb_arcs   = 0;
  	*err_max   = -1.0;
	num_comp   = 1;
	enough_memory = FALSE;

/*=========================================================================*/
/* 	check if the curve is planar and the new referential and get the   */
/*      start and end point of the located element                         */
/*=========================================================================*/

  	plane.point  = &pointnor[0];
  	plane.normal = &pointnor[3];

	if( loccrv == NULL ){

		/*--- the curve to approximate is given as GRobj_env ---*/
		/*--- check if the curve is planar ---*/


  		om$send( msg = message  GRvg.GRdetplane( 
				msgmsg,
			       	&locobj->mod_env.md_env.matrix_type,
			       	locobj->mod_env.md_env.matrix,
                                &plane),
                	 senderid = NULL_OBJID,
			 targetid = locobj->obj_id.objid,
			 targetos = locobj->obj_id.osnum );

		if( *msgmsg == MANONPLANAR ){
#ifdef DEBUG
			printf(" in GFcir_app curve not planar \n");
#endif
			return;
        	}

		if( *msgmsg == MSFAIL ){
			printf(" in GF cir_app severe failure, bad curve \n");
			return;
        	}
  
		/*--- retrieve all the components if we got a comp curve ---*/


     		om$get_classid(	osnum	  = locobj->obj_id.osnum,	
				objid	  = locobj->obj_id.objid,
				p_classid = &loc_obj_cl ) ;

       		if(om$is_ancestry_valid(  
				superclassid  = OPP_GRcompcurve_class_id,
			 	subclassid    = loc_obj_cl ) == OM_S_SUCCESS ){

			num_comp = 0;
			om$send( msg = message GRowner.GRget_number_components( 
						msgmsg,	&num_comp ),
                 	 	senderid = NULL_OBJID,
	  	 	 	targetid = locobj->obj_id.objid,
	  	 	 	targetos = locobj->obj_id.osnum );

     			cmp_lst = (struct GRid *)
			om$malloc( size = num_comp * sizeof(struct GRid ));
			if( cmp_lst == NULL ){
				printf("Error in malloc cmp_lst 0 \n");
				goto wrapup;
			}		
			om$send( msg = message GRowner.GRget_components( 
							msgmsg,
							&(locobj->mod_env),
							cmp_lst,
							num_comp,
							&i,
			     				(IGRint) 0,
							(IGRint)OM_K_MAXINT ),

                 	 	senderid = NULL_OBJID,
	  	 	 	targetid = locobj->obj_id.objid,
	  	 	 	targetos = locobj->obj_id.osnum );


     		}
     		else{
			num_comp = 1;
     			cmp_lst = (struct GRid *)
			om$malloc( size = num_comp * sizeof(struct GRid ));
			if( cmp_lst == NULL ){
				printf("Error in malloc cmp_lst 1 \n");
				goto wrapup;
			}		
			 cmp_lst[0].osnum = locobj->obj_id.osnum;
			 cmp_lst[0].objid = locobj->obj_id.objid;
			 ic = 0;

     		}         



		/*^for(i=0;i<num_comp;i++) 
		   printf(" cmp_lst = %d\n", cmp_lst[i].objid);  */
     



/*=========================================================================*/
/* 	retrieve the geometry as Bspline			           */
/*=========================================================================*/



  		om$send( msg = message GRvg.GRgetsize( 
					msgmsg,
			     		&locobj->mod_env.md_env.matrix_type,
			     		locobj->mod_env.md_env.matrix,
			     		&size ),
                	 senderid = NULL_OBJID,
	  		 targetid = locobj->obj_id.objid,
	  		 targetos = locobj->obj_id.osnum );


		bsp_orig = (struct IGRbsp_curve *) om$malloc( size = size );
		if( bsp_orig == NULL ){
			printf("Not enought memory for bsp_orig 1\n");
			goto wrapup;
		}

  		om$send( msg = message GRvg.GRgetgeom( 
					msgmsg,
			     		&locobj->mod_env.md_env.matrix_type,
			     		locobj->mod_env.md_env.matrix,
			     		(IGRchar *)bsp_orig ),
                	 senderid = NULL_OBJID,
	  		 targetid = locobj->obj_id.objid,
	  		 targetos = locobj->obj_id.osnum );

	} // end case if objet passed in argument

//		21 March 95 changed from BStst_plan to BSlsqptlnpl
//		per advice from D. Breden, as tst_plan only returns true
//		if points (poles) are planar and not when collinear.	PW

	else{

	   IGRdouble  FlatnessError = 0.0 ;	// deviation from a plane
	   IGRint	PtsRelation = 4   ;     // pts are not coplanar 

		//--- the curve to approximate is given as IGRbsp_curve ---


	   BSlsqptlnpl(  loccrv->num_poles ,
			 loccrv->poles ,
			 loccrv->weights ,
			 TESTCOPLANAR ,
			 &PtsRelation ,
			 plane.point ,
			 plane.normal ,
			 &FlatnessError ,
			 &rcPO ) ;


	  if ( PtsRelation == NONCOPLANAR ) {

#ifdef DEBUG
		printf( "BSlsq NOT planar %d rc %d\n\n", PtsRelation, rcPO);
#endif 
		goto wrapup ;
	  }
	  else {	// the curve is flat, so continue

#ifdef DEBUG
		printf( "BSlsq planar %d rc %d\n\n", PtsRelation, rcPO);
#endif 
		
	   num_bound = 0;

    	   BSalloccv(  (IGRshort ) loccrv->order,
			    (IGRlong) loccrv->num_poles,
			    (IGRshort)loccrv->rational,
			    num_bound,
			    &bsp_orig,
			    &rcPO );
    	   if( rcPO != BSSUCC ){
		   printf("in GFcir_app no memory to allocate bsp_orig \n");
		   goto wrapup;
    	   }

	   BScv_copy( &rcPO, loccrv, bsp_orig ); 

	 }	// else curve is flat


	}// end case if structure passed in argument 


  
  	size = 2 * ( bsp_orig->num_knots + 1 );

  	infl_pts = (IGRdouble *)om$malloc( size = 3 * size * sizeof(IGRdouble));
	if( infl_pts == NULL ){
		printf("Not enought memory for infl_pts\n");
		goto wrapup;
	}

  	infl_par = (IGRdouble *)om$malloc(size =  size * sizeof(IGRdouble) );
	if( infl_par == NULL ){
		printf("Not enought memory for infl_par\n");
		goto wrapup;
	}

  	pars     = (IGRdouble *) om$malloc( size = size * sizeof(IGRdouble) );
	if( pars == NULL ){
		printf("Not enought memory for pars \n");
		goto wrapup;
	}

  	index    = (IGRint *) om$malloc( size = size * sizeof(IGRint) );
	if( index == NULL ){
		printf("Not enought memory for index\n");
		goto wrapup;
	}

	newcrvptr = (struct GRid *)om$malloc( size = SIZEMAL * sizeof(struct GRid));
	if( newcrvptr == NULL ){
		printf("Not enought memory for newcrvptr \n");
		goto wrapup;
	}

/*=========================================================================*/
/* 	define new basis to compute later something in 2D 		   */
/*=========================================================================*/


	BScveval ( bsp_orig , 0.0, 1, dv1, &rcPO);
        BSnorvec(&rcPO,&(dv1[3]));
	BScrossp(&rcPO,&(plane.normal[0]),&(dv1[3]),dv2);

	for(i=0;i<3;i++){
		matx[i]   = dv1[i+3];
               	matx[i+3] = dv2[i];
               	matx[i+6] = plane.normal[i];
	}

	/*
	for(i=0;i<9;i=i+3)
	   printf("matx[%d] =%10.5f, matx[%d] =%10.5f, matx[%d] =%10.5f\n",
		  i,matx[i],(i+1),matx[(i+1)],(i+2),matx[(i+2)] );

	*/



/*=========================================================================*/
/* 	general loop on each component			 		   */
/*=========================================================================*/


  for(ic=0;ic<num_comp;ic++){

   LineStr = FALSE;

   if( loccrv == NULL ){


   
     	om$get_classid(	osnum	  = cmp_lst[ic].osnum,	
			objid	  = cmp_lst[ic].objid,
			p_classid = &loc_obj_cl ) ;


     	if(
	    (om$is_ancestry_valid( superclassid = OPP_GR3dlineseg_class_id,
			        subclassid   = loc_obj_cl ) == OM_S_SUCCESS ) ||

	    (om$is_ancestry_valid( superclassid = OPP_GR3dcirarc_class_id,
			        subclassid   = loc_obj_cl ) == OM_S_SUCCESS ) ){


	    	/*--- it's a linestring or a line or an arc ----  */


		GFcopyGRid( msgmsg, cmp_lst[ic], &(locobj->mod_env), cst,
			    &newcrvptr[*nb_arcs], &dist );
		if( *msgmsg == MSSUCC ){
/*
			 if( cst->display->color == savedColor )
			 	cst->display->color = savedColor + 1;
			 else cst->display->color = savedColor;
*/
			 *nb_arcs = *nb_arcs + 1;
			 if( *nb_arcs >=  max_arcs ){
				max_arcs = max_arcs + SIZEMAL;
				newcrvptr = ( struct GRid * )om$realloc( 
					size = max_arcs * sizeof(struct GRid),
			    		ptr  = (char *)newcrvptr );
			 }

			 if( dist < *min_len ) *min_len = dist;
		}
		goto endloop;

     	}
	else if( (om$is_ancestry_valid( 
			superclassid = OPP_GR3dlinestr_class_id,
			subclassid   = loc_obj_cl ) == OM_S_SUCCESS ) ){

		LineStr = TRUE;

		if( num_comp > 1 ){

			if(bsp_orig != NULL){ 
				om$dealloc( ptr = bsp_orig ); 
				bsp_orig = NULL ; 
			}

     			GRabsg_del_by_objid( &cmp_lst[ic].objid,
					     &cmp_lst[ic].osnum );

       			om$send( msg = message GRvg.GRgetsize( 
					msgmsg,
			     		&locobj->mod_env.md_env.matrix_type,
			     		locobj->mod_env.md_env.matrix,
			     		&size ),
                	 	senderid = NULL_OBJID,
	  	 	 	targetid = cmp_lst[ic].objid,
	  	 	 	targetos = cmp_lst[ic].osnum );

			bsp_orig = 
			(struct IGRbsp_curve *)om$malloc( size = size );
			if( bsp_orig == NULL ){
				printf("Not enought memory for bsp_orig 2\n");
				goto wrapup;
			}
	
  			om$send( msg = message GRvg.GRgetgeom( 
					msgmsg,
			     		&locobj->mod_env.md_env.matrix_type,
			     		locobj->mod_env.md_env.matrix,
			     		(IGRchar *)bsp_orig ),
                		 senderid = NULL_OBJID,
	  			 targetid = cmp_lst[ic].objid,
	  			 targetos = cmp_lst[ic].osnum );
		}


        	POarepolaln(bsp_orig,ZERO,&rcPO);

        	if( rcPO == BSSUCC )
        	{

			j = 3*(bsp_orig->num_poles-1);
	
                	dist = 0.0;

        		for(i=0;i<3;i++)
        		{
		    		bstab[i]   = bsp_orig->poles[i];
		    		bstab[i+3] = bsp_orig->poles[j+i];
		    		par_pre    = bstab[i+3] - bstab[i];
		    		dist       = dist + par_pre * par_pre;
        		}
 
			dist = sqrt(dist);

  			geom.num_points = 2;
        		geom.points  = bstab;
  			cst->geometry = (char *)&geom;
        		newcrvptr[*nb_arcs].objid = NULL_OBJID;
        		newcrvptr[*nb_arcs].osnum = cst->env_info->md_id.osnum ;

  			stat = om$construct( classid = OPP_GR3dlineseg_class_id,
				     p_objid   = &newcrvptr[*nb_arcs].objid,
         	        	     osnum     = newcrvptr[*nb_arcs].osnum,
				msg = message GRgraphics.GRaltconstruct(cst) );
/*
			if( cst->display->color == savedColor )
			cst->display->color = savedColor + 1;
			else cst->display->color = savedColor;
*/
			if( !stat&(*(cst->msg))&1 )
			printf("Error in om$construct GR3dlineseg\n");
			else{
		    		*nb_arcs = *nb_arcs + 1;
		    		if( dist < *min_len ) *min_len = dist;

			}

		}/* line string was a line */
		else{

			GFcopyGRid( msgmsg, cmp_lst[ic], &(locobj->mod_env),
				    cst, &newcrvptr[*nb_arcs], &dist );
			if( *msgmsg == MSSUCC ){
/*
				 if( cst->display->color == savedColor )
			 	 cst->display->color = savedColor + 1;
			 	 else cst->display->color = savedColor;
*/
			 	 *nb_arcs = *nb_arcs + 1;
			 	if( dist < *min_len ) *min_len = dist;
			}
		}


		if(*nb_arcs >=  max_arcs ){
			max_arcs = max_arcs + SIZEMAL;
			newcrvptr = ( struct GRid * )om$realloc( 
				    size = max_arcs * sizeof(struct GRid),
				    ptr  = (char *)newcrvptr );
		}

		goto endloop;

		
        }/* it was a line string  */



     	if( (num_comp > 1) && ( LineStr == FALSE ) ){

		if(bsp_orig != NULL){ 
			om$dealloc( ptr = bsp_orig ); 
			bsp_orig = NULL ; 
		}

     		GRabsg_del_by_objid(&cmp_lst[ic].objid,&cmp_lst[ic].osnum);

       		om$send( msg = message GRvg.GRgetsize( 
					msgmsg,
			     		&locobj->mod_env.md_env.matrix_type,
			     		locobj->mod_env.md_env.matrix,
			     		&size ),
                	 senderid = NULL_OBJID,
	  	 	 targetid = cmp_lst[ic].objid,
	  	 	 targetos = cmp_lst[ic].osnum );

		bsp_orig = (struct IGRbsp_curve *)om$malloc( size = size );
		if( bsp_orig == NULL ){
			printf("Not enought memory for bsp_orig 3\n");
			goto wrapup;
		}
	
  		om$send( msg = message GRvg.GRgetgeom( 
					msgmsg,
			     		&locobj->mod_env.md_env.matrix_type,
			     		locobj->mod_env.md_env.matrix,
			     		(IGRchar *)bsp_orig ),
                	 senderid = NULL_OBJID,
	  		 targetid = cmp_lst[ic].objid,
	  		 targetos = cmp_lst[ic].osnum );
     	}


     }/* if loccrv NULL */


/*=========================================================================*/
/* added the 23th of Feb 94 to test if the curve is a line or an arc       */
/*=========================================================================*/

        POarepolaln(bsp_orig,ZERO,&rcPO);

        if( rcPO == BSSUCC ){

		j = 3*(bsp_orig->num_poles-1);

                dist = 0.0;

        	for(i=0;i<3;i++)
        	{
		    bstab[i]   = bsp_orig->poles[i];
		    bstab[i+3] = bsp_orig->poles[j+i];
		    par_pre    = bstab[i+3] - bstab[i];
		    dist       = dist + par_pre * par_pre;
        	} 
		dist = sqrt(dist);

  		geom.num_points = 2;
        	geom.points  = bstab;
  		cst->geometry = (char *)&geom;
        	newcrvptr[*nb_arcs].objid   = NULL_OBJID;
        	newcrvptr[*nb_arcs].osnum   = cst->env_info->md_id.osnum ;

  		stat = om$construct( classid = OPP_GR3dlineseg_class_id,
				     p_objid   = &newcrvptr[*nb_arcs].objid,
         	        	     osnum     = newcrvptr[*nb_arcs].osnum,
			msg = message GRgraphics.GRaltconstruct(cst) );

		if( !stat&(*(cst->msg))&1 )printf("Error in om$construct GR3dlineseg\n");
		else{
		    *nb_arcs = *nb_arcs + 1;
		    if( dist < *min_len ) *min_len = dist;

		    if(*nb_arcs >=  max_arcs ){
			max_arcs = max_arcs + SIZEMAL;
			newcrvptr = ( struct GRid * )om$realloc( 
				    size = max_arcs * sizeof(struct GRid),
				    ptr  = (char *)newcrvptr );
		    }
		}

	   	goto endloop;


        }/* end if I found a lineseg */


   	POchkCirArc( bsp_orig->poles, 
		     bsp_orig->weights, 
		     (IGRint)bsp_orig->num_poles,
		     tol,
		     (struct IGRarc *)&arc1.uGeom.Arc,
		     &isAnArc,
		     &rcPO );

	if( rcPO == BSSUCC ){

	   dist = arc1.uGeom.Arc.prim_axis * arc1.uGeom.Arc.sweep_angle;
	   if((*nb_arcs+3) >=  max_arcs ){
		max_arcs = max_arcs + SIZEMAL;
		newcrvptr = ( struct GRid * )om$realloc( 
			    size = max_arcs * sizeof(struct GRid),
			    ptr  = (char *)newcrvptr );
	    }


	   if( isAnArc == TRUE ){
		arc1.type = geomArc;
		stat = POchkArcIsLn(
				&arc1,bsp_orig->poles,
				&(bsp_orig->poles[3*(bsp_orig->num_poles-1)]),
				NULL,tol,&par_pre,&rcPO);
		GFcreArcLine( &stat, &arc1, cst, &newcrvptr[*nb_arcs] ); 
	   }
           else{

	   	cst->geometry   = (char *)&arc1.uGeom.Arc;
           	newcrvptr[*nb_arcs].objid   = NULL_OBJID;
           	newcrvptr[*nb_arcs].osnum   = cst->env_info->md_id.osnum ;

       		stat = om$construct( 
				msg = message GRgraphics.GRaltconstruct(cst),
				classid = OPP_GR3dcircle_class_id,
	        	 	p_objid = &newcrvptr[*nb_arcs].objid,
	        	 	osnum = newcrvptr[*nb_arcs].osnum );
	   }

	   if( !(stat&(*(cst->msg))&1) )
		printf("Error in om$construct GR3dcirarc or GR3dcircle\n");

	   else  *nb_arcs += 1;

	   if( dist < *min_len ) *min_len = dist;


	   goto endloop;

	}

/*=========================================================================*/
/* here call function to find if inflexions exist 			   */
/*=========================================================================*/

/*=========================================================================*/
/* 		if inflexions exist at parameters value			   */
/*    place a knots with multiplicity order -1 				   */
/*=========================================================================*/

/*=========================================================================*/
/* 	evaluate the number of knots with multiplicity order -1            */
/*=========================================================================*/

   index[0] = 0;   
   num_mkt = 0;

   BSfindmkts( &rcPO,
               &(bsp_orig->order),
               &(bsp_orig->num_poles),
               &(bsp_orig->knots[0]),
               &tol1,
               &num_mkt,
               pars,
	       index );


   pars[num_mkt] = 1.0;
   index[num_mkt] = bsp_orig->num_knots - bsp_orig->order;

/*
   printf("apres insertion num_mkt =%d\n",num_mkt);
   for(i=0;i<=num_mkt;i++)
	printf("index[%d] = %d, pars[%d] = %11.8f\n",i,index[i],i,pars[i]);

   mypr_bscv("bsp_orig apres insertion",bsp_orig,&rcPO);
*/

/*=========================================================================*/
/*	malloc the curve that will contain the span			   */
/*=========================================================================*/


    num_bound = 0;

    BSalloccv(  (IGRshort ) bsp_orig->order,
		(IGRlong) bsp_orig->num_poles,
		(IGRshort)bsp_orig->rational,
		num_bound,
		&bsp,
		&rcPO );

    if( rcPO != BSSUCC ){
	printf(" in GFcir_app no enougth memory to allocate bsp \n" );
	goto wrapup;
    }


/*=========================================================================*/
/*	general loop to evaluate arcs for each curve beetwen multiple      */
/*      with multiplicity equal to order -1 				   */
/*=========================================================================*/


    for( isi=0; isi<= num_mkt; isi++ ){


	/*
	for(j=0;j<=num_mkt;j++) 
		printf(" isi = %d, pars[%d] = %12.8f, index[%d] = %d\n",
			 isi,j,pars[j],j,index[j]);
		printf(" bsp_orig->num_knots = %d, bsp_orig->num_poles = %d\n",
        		 bsp_orig->num_knots ,bsp_orig->num_poles);
	mypr_bscv("bsp_orig avant",bsp_orig,&rcPO);
	*/
	
	POspancv(bsp_orig,isi,num_mkt,pars,index,bsp,&rcPO);

        POarepolaln(bsp,ZERO,&rcPO);
	
        if( rcPO == BSSUCC )
        {
		j = 3*(bsp->num_poles-1);

                dist = 0.0;

        	for(i=0;i<3;i++)
        	{
		    bstab[i]   = bsp->poles[i];
		    bstab[i+3] = bsp->poles[j+i];
		    par_pre    = bstab[i+3] - bstab[i];
		    dist       = dist + par_pre * par_pre;
        	} 
		dist = sqrt(dist);

  		geom.num_points = 2;
        	geom.points  = bstab;
  		cst->geometry = (char *)&geom;
        	newcrvptr[*nb_arcs].objid   = NULL_OBJID;
        	newcrvptr[*nb_arcs].osnum   = cst->env_info->md_id.osnum ;

  		stat = om$construct( classid = OPP_GR3dlineseg_class_id,
				     p_objid   = &newcrvptr[*nb_arcs].objid,
         	        	     osnum     = newcrvptr[*nb_arcs].osnum,
			msg = message GRgraphics.GRaltconstruct(cst) );
/*
		if( cst->display->color == savedColor )
		cst->display->color = savedColor + 1;
		else cst->display->color = savedColor;
*/
		if( !stat&(*(cst->msg))&1 )printf("Error in om$construct GR3dlineseg\n");
		else{
		    *nb_arcs = *nb_arcs + 1;
		    if( dist < *min_len ) *min_len = dist;

		    if(*nb_arcs >=  max_arcs ){
			max_arcs = max_arcs + SIZEMAL;
			newcrvptr = ( struct GRid * )om$realloc( 
				    size = max_arcs * sizeof(struct GRid),
				    ptr  = (char *)newcrvptr );
		    }
		}

        	goto step1;

        }/* end if I found a lineseg */

        par_cou = 1.0;
        par_pre = 0.0;
    
        BScveval ( bsp , par_pre, 1, dv1, &rcPO);
        jjj = 0;

/*=========================================================================*/
/*	for each piece beetwen multiple knots evaluate the arcs which      */
/*      approximate the curve		 				   */
/*=========================================================================*/
  
	BSbx2( &rcPO, &bsp->num_poles, bsp->poles, bsp->weights, minpt, maxpt );
	if( rcPO == BSSUCC ){
		locTol = BSdistptpt(&rcPO, minpt, maxpt );
		if( (tol/locTol) < 0.01 ) locTol = tol;
		else locTol = tol / 10.0;
	}
	else locTol = tol;  

        while(1)
	{
	   jjj = jjj + 1;

	   BScveval ( bsp , par_cou, 1, dv2, &rcPO);

/*^
	printf(" ava num_poles =%d, num_knots =%d\n",bsp_orig->num_poles
					    ,bsp_orig->num_knots);
	mypr_bscv("bsp dans boucle",bsp,&rcPO);
	printf("--->par_pre = %f, par_cou = %f min_len = %f\n",par_pre,par_cou,*min_len);
*/

  	rcPO =  POcircnvfit( bsp,  &(dv1[0]), &(dv1[3]), &(dv2[0]), &(dv2[3]), 
			locTol, matx,
                   	&arc1, &arc2, &dist, &udist, min_len, &cnvfitmsg );

/*
	printf("exit POcircnvfit min_len = %f\n",*min_len);
   	printf(" exit POcircnvfit  rcPO = %d,cnvfitmsg =%d, dist =%15.6f\n",
	     	rcPO, cnvfitmsg, dist);

    	printf(" num_poles = %d, num_knots = %d\n",
		bsp_orig->num_poles,bsp_orig->num_knots);
*/

        if( rcPO == BSSUCC ){

              if( dist > *err_max ) *err_max = dist;
	      if((*nb_arcs+3) >=  max_arcs ){
			max_arcs = max_arcs + SIZEMAL;
			newcrvptr = ( struct GRid * )om$realloc( 
				    size = max_arcs * sizeof(struct GRid),
				    ptr  = (char *)newcrvptr );
	      }

	      if( (cnvfitmsg == 0) || (cnvfitmsg == 1) ){


		GFcreArcLine( &stat, &arc1, cst, &newcrvptr[*nb_arcs] ); 

		*nb_arcs += 1;

		/* printf("just one arc constructed\n");*/

	      }/*--- just one arc or line constructed --- */


	      else{

		GFcreArcLine( &stat, &arc1, cst, &newcrvptr[*nb_arcs] ); 

		*nb_arcs += 1;

		GFcreArcLine( &stat, &arc2, cst, &newcrvptr[*nb_arcs] ); 

		*nb_arcs += 1;

	     }/*--- end of construct of the two arcs ---*/


/*^
   printf("======= while num_obj = %d\n",(*nb_arcs -1 ) );
   printf("======= while par_cou = %12.8, jjj = %d\n",par_cou,jjj);
*/
                jjj = 0;
		if( bsp->knots[0] > 0.0 ){
			printf("knots destroyed\n");
			 goto wrapup;
		}		
		
		if( (1.0 - par_cou) < tol1  ) goto step1;

                   par_pre = par_cou;
                   par_cou = 1.0;

	           for(j=0;j<6;j++) dv1[j] = dv2[j];
 
	   } /* end of action if msg = 1 */

           else
           {
		par_cou =  0.7*par_cou + 0.3*par_pre ;

           }

  	   /* printf("par_pre =%12.8f, par_cou =%12.8f\n", par_pre, par_cou);*/


	} /* end of while */

step1: continue;


     } /* end loop on variable isi means loop on single BSparc */

endloop:
	if( bsp != NULL ) { BSfreecv(&rcPO,bsp); bsp = NULL; }


}/* end loop on variable ic means loop on each component */

	if( *err_max < TOL2 ) *err_max = 0.0;

wrapup:

/*|		----- enter at wrapup level -----			*/


	*newcrv = newcrvptr;
	
	if( bsp      != NULL ) { BSfreecv(&rcPO,bsp); bsp      = NULL; }
	if( bsp_orig != NULL ) { 
		if( loccrv == NULL ){
			om$dealloc( ptr = bsp_orig);      bsp_orig = NULL; }
		else {
			BSfreecv(&rcPO,bsp_orig); bsp_orig  = NULL;
		}
	}
	if( pars     != NULL ) { om$dealloc( ptr = pars);     pars     = NULL; }
	if( index    != NULL ) { om$dealloc( ptr = index);    index    = NULL; }
    	if( infl_par != NULL ) { om$dealloc( ptr = infl_par); infl_par = NULL; }
    	if( infl_pts != NULL ) { om$dealloc( ptr = infl_pts); infl_pts = NULL; }
	if( cmp_lst  != NULL ) { om$dealloc( ptr = cmp_lst);  cmp_lst  = NULL; }


}


end implementation Root;

