/* $Id: VLbendFunk.I,v 1.2 2001/02/20 01:04:24 build Exp $  */

/*************************************************************************
* I/LOFT
*
* File:        /src/bend/VLbendFunk.I
*
* Description: control line methods.
*
* Dependencies:
*
* Revision History:
*      $Log: VLbendFunk.I,v $
*      Revision 1.2  2001/02/20 01:04:24  build
*      Replaced v_dbgmacros.h with product specific dbgmacros.h
*
*      Revision 1.1.1.1  2001/01/04 21:11:22  cvs
*      Initial import to CVS
*
# Revision 1.3  2000/03/30  22:31:48  pinnacle
# Replaced: src/bend/VLbendFunk.I for:  by impd252 for loft
#
# Revision 1.2  1999/05/17  19:26:42  pinnacle
# Manoj's fix for roll lines.
#
*
* History:
*      MM/DD/YY   AUTHOR       DESCRIPTION
*      03/31/99   manoj        modified for TR#179900389
*************************************************************************/

/*f
	VLbendFunk.I contains a set of functions use to evaluate
	the Bending line curves.

01-june-1993, JLL: add function VLcnstOneFib() to construct inverse
		   bending line for stiffeners.
21-july-1994, JLL: modify VLcnstOneFib() to see the inverse bending curve
	           on the correct side depending web____l or web____r.
		   add the argument yOffset to be able to place have the
		   coordinate system in the lower left corner rather than
		   having it at the left neutral fiber position.
*/

class implementation Root;


#include <stdio.h>
#include <math.h>
#include "vlprototype.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igrdp.h"
#include "igr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "godef.h"
#include "gr.h"
#include "growner.h"
#include "dp.h"
#include "go.h"
#include "bserr.h"
#include "maerr.h"
#include "bs.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "EMSssprops.h"
#include "EMSdpb.h"
#include "grmacros.h"
#include "dpezmac.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsmiscmacros.h"
#include "vldbgmacros.h"
#include "vlrolline.h"
#include "vssectiondef.h"
#include "bsdotp.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "bsmdstptcv.h"
#include "bsxtractpar.h"
#include "bsdistptpt.h"
#include "bscvcv_int.h"

#define alpha_resol 		0.75	  /* coef de relaxation */
#define MAXITER     		50	  /* nb d'iteration maxi */
#define PRECISION   		0.001
#define NB_POINT_TEST		11
#define ANGULAR_TOLERANCE	0.000175  /* 0.01 deg */
#define MYMAXITER		50

from	EMSsubbs	import	EMproject_curve_onto_surface;
from	EMSsubbs	import	EMisoparcvs;
from	GRgraphics	import	GRdelete, GRaltconstruct, GRgetrang;
from    GRcurve		import  GRendpts;
from    EMSsurface	import	EMintplane_notrim;
from	EMSsubbs        import  GRgenabsg;
from	GRvg		import	GRputsymb;
from	EMSloopset	import	EMget_loops;
from	EMSboundary	import	EMcount_edges;
from	EMSboundary	import	EMget_edges;
from	EMSedge		import	EMget_bcxyz_geom;
from	EMSgenbs	import	EMruled_surface;
from	GRcurve	        import	GRmidpoint;
from    NDnode          import  ASreturn_go;

extern GRclassid	OPP_GR3dlinestr_class_id;
extern GRclassid	OPP_EMScylindr_class_id;
extern GRclassid	OPP_EMScone_class_id;
extern GRclassid        OPP_EMSpcylindr_class_id; /* Added for TR#179900389 */
extern GRclassid        OPP_ACpretendin_class_id; /* Added for TR#179900389 */

extern  IGRint          GRabsg_del_by_objid();
extern  IGRchar		*memcpy();
extern  void		BScveval(), BSsfevaln();

/** DEBUG should always be after includes !!	*****************************/
/*	Some of these function would be better served by dbg	**/

/*
#ifndef DEBUG
#define DEBUG 1
#endif
*/

/********************* end DEBUG ********************************************/
/*============================================================================*/


IGRdouble VLf( cv, par, n, msg)

/*d Calcul de la val	x = (pPos+pNeg)/2.0;
    Finalement cette fonction evalue le cosinus de l' angle forme
    par la normale en un point donne de la surface et la derivee de la
    courbe au parametre par  */

struct IGRbsp_curve 	*cv;      	/*I courbe 1  */
       IGRdouble	par;		/*I parametre sur la courbe 1  */	
       IGRdouble	*n;		/*I normale au plan de recherche  */
       IGRlong		*msg;		/*O MSSUCC or MSFAIL  */	
{

 IGRdouble	eval1[6];
 IGRdouble	cosNDV;

 BScveval( cv, par, 1, eval1, msg );
 if (*msg!=BSSUCC) {
	#ifdef DEBUG
	printf(" F BScveval Fail\n");
	#endif
	*msg = MSFAIL;  
	return 0.0;
 }


 #ifdef DEBUG
{
 IGRdouble	v1[3];
 v1[0] = eval1[3] +eval1[0];
 v1[1] = eval1[4] +eval1[1];
 v1[2] = eval1[5] +eval1[2];
 printf("par : %lf %lf %lf\n",eval1[0],eval1[1],eval1[2]);
/* gr$place_line(point1=eval1,point2=v1);*/
}
 #endif


 BSnorvec( msg, &(eval1[3]) );
 if (*msg!=BSSUCC) {
	#ifdef DEBUG
	printf(" F BSnorvec deriv1 Fail\n");
	#endif
	*msg = MSFAIL;
	return 0.0;
 }

 /*d evaluation of cosine between n and derivate */

 cosNDV = BSdotp( msg, n, &(eval1[3]) );

 *msg = MSSUCC;

 return ( cosNDV ) ;
 
}

/******************************************************************************/
/*  F1 : derive 1 / p1 du critere de developpabilite			      */
/*  ret =  MSSUCC si ok , MSFAIL sinon   				      */
/******************************************************************************/

IGRdouble VLfPrim( cv, CvPa, n, cht, ret )

struct IGRbsp_curve 	*cv;   	/*I courbe sur laquelle on itere  */
	IGRdouble	CvPa;	/*I parametre sur la courbe 1  */	
	IGRdouble	*n;	/*I normale au plan de recherche  */
	IGRdouble	cht;   	/*I cht */
	IGRlong		*ret;	/*O return code  */	

{

 IGRint		i;
 IGRint		iterator=0;		/* iterator to check for divergence*/
 IGRdouble	h,alpha;
 IGRdouble	eval1[3];
 IGRdouble	eval2[3];
 IGRdouble	vect[3];
 BSrc		rc;
 IGRdouble 	p11,f1,f2,fprime;

#ifdef DEBUG
printf("entering VLfPrim\n"); 
#endif
 h = 0.05 * cht;

 BScveval( cv, CvPa, 0, eval1, &rc );
 if (rc!=BSSUCC) {
	#ifdef DEBUG
	printf(" F12 BScveval CvPa =%lf : fail : %d\n",CvPa,rc);
/*	gr$place_point (point1=eval1);*/
	#endif
	goto wrapup;
 }

 do{

   	p11 = CvPa + h;
 
	if ( (CvPa+h>1.0) && (CvPa<=1.0) ) h = -h;

	rc=BSFAIL;
	BScveval( cv, p11, 0, eval2, &rc );
 	if (rc!=BSSUCC) {
		#ifdef DEBUG
		printf(" F12 BScveval CvPa : p2 = %lf h = %lf Fail\n",CvPa,h);
/*		gr$place_point (point1 =eval2);*/
		#endif
		goto wrapup;
	}

	alpha = 0.0;
	for(i=0;i<3;i++){
		vect[i] = eval2[i] - eval1[i];
		alpha += vect[i]*vect[i];
	}
	
#ifdef DEBUG
printf("VLfPrim alpha %E\n", alpha); 
#endif
	alpha = sqrt(alpha);

 	if (alpha>cht) h= h / 2.0;
 	if (alpha<0.1*cht) h= h * 2.0;
	iterator++;
	if ( iterator > 50 ){ 
		goto wrapup; 
#ifdef DEBUG
		printf(" not within %d steps, so forget it!\n",iterator);
#endif
	}
 } while ( (alpha<0.1*cht) || (alpha>cht) );




 f1=VLf( cv, p11, n, ret );
 if (*ret!=MSSUCC) { 
	#ifdef DEBUG
	printf(" F1 F Fail\n");
	#endif
	  goto wrapup; 
 }
 
 f2=VLf( cv, CvPa, n, ret );
 if (*ret!=MSSUCC) {
	#ifdef DEBUG
	 printf(" F1 F Fail\n"); 
	#endif
	goto wrapup; 
 }


 if ( fabs(h) == 1.0E-12 ) {
	#ifdef DEBUG
	 printf(" F12 h=0\n"); 
	#endif
	goto wrapup; 
 }

 fprime = (f1-f2) / h;
 #ifdef DEBUG
  printf("f1 = %f, f2 = %f, fp = %f\n", f1, f2, fprime);
 #endif

#ifdef DEBUG
printf("exiting VLfPrim\n"); 
#endif
 *ret=MSSUCC;
 return( fprime );


wrapup:
	*ret = MSFAIL;  
#ifdef DEBUG
printf("exiting VLfPrim\n"); 
#endif
	return( 0.0 ); 
 
}

/*==========================================================================*/

IGRlong VLresol( Cv, PaCv, n, precision, cht )

struct IGRbsp_curve 	*Cv;      	/*I courbe  */
IGRdouble		*PaCv;		/*O parametre sur la courbe 1  */	
IGRdouble		*n;		/*I normale au plan de recherche  */
IGRdouble		precision;	/*I precision */
IGRdouble		cht;    	/*I cht */

{
 IGRdouble 	x11,f1,f;
 IGRint 	i,iMin=0,iMinPos=0,iMaxNeg=0;
 IGRlong	ret;
 IGRint 	iter;
 IGRdouble 	pPos,pNeg;
 IGRdouble 	FMin,FMinPos,FMaxNeg,tF[NB_POINT_TEST],x;
 IGRdouble	chtMprec;

#ifdef DEBUG
printf("entering VLresol\n"); 
#endif

FMin = 2.0;
FMinPos = 2.0;
FMaxNeg = -2.0;
chtMprec = cht * precision;

/*c test si 0.5 est solution  */

x = 0.5;
if (fabs(VLf(Cv,x,n,&ret))<=chtMprec) {
	*PaCv = x;
	return MSSUCC ; 
}


/*c 
   teste sur NB_POINT_TEST points 
   on cherche le mini positif, le maxi negatif et le mini absolu
*/



for (i=0;i<NB_POINT_TEST;i++) {


	x = ((double)i)/((double)(NB_POINT_TEST-1));
	tF[i] = VLf(Cv,x,n,&ret);

	#ifdef DEBUG
 		printf(" x = %lf  F = %lf\n",x,fabs(tF[i])); 
	#endif

 	if (ret!=MSSUCC) {
		#ifdef DEBUG
		printf(" resol F x=%lf  : Fail\n",x); 
		#endif
		return MSFAIL;}

        if (fabs(tF[i])<FMin) {
		FMin = fabs(tF[i]);
		iMin = i;
		}
        if ((tF[i]>0) && (tF[i]<FMinPos)) {
		FMinPos = tF[i];
		iMinPos = i;
		}
        if ((tF[i]<0) && (tF[i]>FMaxNeg)) {
		FMaxNeg = tF[i];
		iMaxNeg = i;
		}
}

#ifdef DEBUG
 	printf(" FMin = %lf  imin = %d\n",FMin,iMin); 
 	printf(" FMinPos = %lf  iMinPos = %d\n",FMinPos,iMinPos); 
 	printf(" FMAxNeg = %lf  iMaxNeg = %d\n",FMaxNeg,iMaxNeg); 
#endif

/* 
 * Si FMinPos<=1.0 et FMaxNeg>=-1.0
 *        on fait un dichotomie
 */

 if ((FMinPos<=1.0) && ( FMaxNeg>=-1.0)) {
	iter = 0;
 	pPos= (double)iMinPos/(double)(NB_POINT_TEST-1);
 	pNeg= (double)iMaxNeg/(double)(NB_POINT_TEST-1);
	f1 =  1.0;

	while ((fabs(f1)>ANGULAR_TOLERANCE)&&(iter<MAXITER)) {
		iter = iter + 1;
		x = (pPos+pNeg)/2.0;

		#ifdef DEBUG
 		printf(" pPos = %lf  pNeg = %lf x = %lf\n",pPos,pNeg,x); 
		#endif

		f1 =VLf(Cv,x,n,&ret);
		if (f1>0.0) pPos = x;
		 else pNeg = x; 
	}
 
	#ifdef DEBUG
	printf(" F = %lf  x = %lf\n",f1,x); 
	#endif

	if (iter==MAXITER){

		#ifdef DEBUG
		printf(" Dicho not resolved\n");
		#endif

		goto newton;
	}

	*PaCv = x;

 }/*d end dichotomie */

 else {

 newton :

       *PaCv= (IGRdouble)iMin / (IGRdouble)(NB_POINT_TEST-1);

	#ifdef DEBUG
	printf(" pi Ini = %lf\n",*PaCv); 
	#endif

	iter = 0;
 	x11 = *PaCv;

 	do {   
		*PaCv=x11;
		f1 =VLfPrim(Cv,*PaCv,n,cht,&ret);
 		if (ret!=MSSUCC) {
			#ifdef DEBUG
			printf(" resol VLfPrim PaCv=%lf : Fail\n",*PaCv);
			#endif
 			*PaCv= (double)iMin/(double)(NB_POINT_TEST-1);
			return MSFAIL;
		}

		if ( fabs(f1) > 0.0 ) {
			f =VLf(Cv,*PaCv,n,&ret) ;
 			if (ret!=MSSUCC) {
				#ifdef DEBUG
				printf(" resol F PaCv=%lf  : Fail\n",*PaCv); 
				#endif
				return MSFAIL;
			}
			x11= *PaCv-f/f1;
			x11= (1-alpha_resol)*(*PaCv)+alpha_resol*x11;
		}
 		else {	
			#ifdef DEBUG
			printf(" resol : VLfPrim = 0 : Fail\n");  
			#endif
 			*PaCv= (double)iMin/(double)(NB_POINT_TEST-1);
			return MSFAIL;
		}
 	
		#ifdef DEBUG
		write("x1 = ",x11,'\n');
		#endif

 		iter = iter+1;

 	} while (   (iter < MAXITER) &&
		    ( (fabs(x11-*PaCv) > chtMprec) || (f > chtMprec) )   );

	*PaCv = x11;

  	if ((x11>5)|| (x11<=-5)) {
		#ifdef DEBUG
		printf(" resol F PaCv=%lf  hors du domaine: Fail\n",*PaCv); 
		#endif
		return MSFAIL;
	}

	#ifdef DEBUG
 	printf("resol : iter = %d\n",iter);
	#endif
  	if (iter>=MAXITER) return MYMAXITER;

 }/*d end newton method */

  return MSSUCC ;

}

/*==========================================================================*/


IGRlong VLresolAlg1 ( Cv1, ExCv1, Cv2, ExCv2, BendingLine, prec, cht, msg )

/*d This function evaluates the bending with the alogorithm 1. */

struct IGRbsp_curve	*Cv1;
struct IGRbsp_curve	*ExCv1;
struct IGRbsp_curve	*Cv2;
struct IGRbsp_curve	*ExCv2;
struct BendingLineInfo  *BendingLine;
IGRdouble		prec;
IGRdouble		cht;
IGRlong			*msg;

{

IGRlong		rc;
IGRdouble	par,dist1,dist2;
IGRpoint	base;


 rc = VLresol( ExCv1, &par, BendingLine->normal, prec, cht );
 if (rc!=MSSUCC) {
	#ifdef DEBUG	
 	printf("VLresol : FAIL \n");
	#endif
	goto wrapup;
 }
 #ifdef DEBUG
 else{
 	printf("VLresol : Ok \n");
 }
 #endif
 		
 BScveval (ExCv1, par, 0, BendingLine->point1, msg );
 if (*msg!=BSSUCC) {
	#ifdef DEBUG
	printf(" BScveval Fail\n");
	#endif
	goto wrapup;
 }
 #ifdef DEBUG
	else 	{
 		printf("BScveval : Ok \n");
		}
 #endif


 /*c because we evaluate the parameter solution on the extended geometry */

 BSmdstptcv(Cv1,BendingLine->point1,&BendingLine->par1,base,&dist1,msg);
 if (*msg!=BSSUCC) {
	#ifdef DEBUG
	printf(" BSmdstptcv Fail\n");
	#endif
	goto wrapup;
 }
 #ifdef DEBUG
	else 	{
 		printf("BSmdstptcv : Ok \n");
		}
 #endif

 rc = VLresol( ExCv2, &par, BendingLine->normal, prec, cht );
 if (rc!=MSSUCC) {
	#ifdef DEBUG	
 	printf("VLresol : FAIL \n");
	#endif
	goto wrapup;
 }
 #ifdef DEBUG
	else 	{
 		printf("VLresol : Ok \n");
		}
 #endif

 BScveval( ExCv2, par, 0, BendingLine->point2, msg );
 if (*msg!=BSSUCC) {
	#ifdef DEBUG
	printf(" BScveval Fail\n");
	#endif
	goto wrapup;
 }
 #ifdef DEBUG
	else 	{
 		printf("BScveval : Ok \n");
		}
 #endif

 BSmdstptcv(Cv2,BendingLine->point2,&BendingLine->par2,base,&dist2,msg);
 if (*msg!=BSSUCC) {
	#ifdef DEBUG
	printf(" BSmdstptcv Fail\n");
	#endif
	goto wrapup;
 }
 #ifdef DEBUG
 printf("dist1 = %lf   dist2 = %lf\n",dist1,dist2);
 printf("ResAlg1: cht*cht is %f d*d is %f\n", cht*cht,dist1*dist2);
 #endif

 /** used to just set 
		BendingLine->goodToDraw = FALSE;
     if dist was more than square of chord height, instead now return
     fail to prevent bad vector being passed on. PW
  **********/

 if ( (dist1*dist2)< (cht*cht)) {
	BendingLine->goodToDraw = TRUE;
	BendingLine->resolved = TRUE;
	*msg = MSSUCC;
	return MSSUCC;
 }



wrapup:
	BendingLine->goodToDraw = FALSE;
	BendingLine->resolved   = FALSE;
	*msg = MSFAIL;
	return MSFAIL;
}

/*==========================================================================*/

IGRlong VLfindNewBendLine(

struct GRobj_env	*SurfObj,    /*I the base surface */
struct GRvg_construct	*cst,	     /*I construction list */
IGRboolean		direction,   /*I direction to define extraction of iso
					 curve in u or v direction.
					 direction = TRUE -> extract iso v,
					 direction = FALSE ->extract iso u */
IGRint			*nb_bend_line, /*I Bending line's number */
IGRvector		shipsAxis,    /*I The ships axis */
struct BendingLineInfo  *BendingLine,/*O bending lines information */
struct GRobj_env	*bendObj,    /*O bending line objects or NUL_OBJID*/
IGRlong			*msg	     /*O MSSUCC or MSFAIL */
)
{
int			count,ii,jj;
long			sts,loc_sts;
struct GRlc_info 	grEdge1,grEdge2;
struct GRid		grEdge[VLRolNumFeet];
struct GRid		ruled_surf,*list = NULL;
struct IGRbsp_curve	edge_cv,*cv=NULL;
IGRboolean		reverse_curve_1,reverse_curve_2,option_flag;
long			numCurves;
GRobjid			*curvesObjId;
BSrc			bsrc;
struct IGRbsp_surface	*sf;
int			nb_int = 0; 
long			n_over;
struct IGRplane		plane[2];
IGRdouble		*int_pts,*par1,*par2,*end_pts,*over0,*over1;
IGRdouble		eval[24],t_plan[12];
IGRdouble		dist[VLRolNumFeet];
IGRpoint		curve_end_points[2];
IGRpoint		curve_1_points[1],curve_2_points[1];
IGRdouble   		uv[VLRolNumFeet];
IGRboolean 		Planar[2];
IGRdouble        	vect1[4],vect2[4],vect3[4];
IGRdouble		dot1,dot2,dot3;

  *msg = MSFAIL;

  /* if check added for TR#179900389 */
  if(vs$is_ancestry_valid( object   = &(SurfObj->obj_id),
			      classid = OPP_ACpretendin_class_id ) ) 
  {
  		sts = om$send( msg      = message NDnode.ASreturn_go(
                                     &(grEdge1.located_obj),
                                     &(grEdge1.module_info.md_env.matrix_type),
                                     grEdge1.module_info.md_env.matrix),
                senderid = NULL_OBJID,
                targetid = SurfObj->obj_id.objid,
                targetos = SurfObj->obj_id.osnum );
   } 
   else 
   {
	/* This else condition added for TR#179900389 */
	        grEdge1.located_obj.osnum = SurfObj->obj_id.osnum ;
		grEdge1.located_obj.objid = SurfObj->obj_id.objid ;
   }

/* Block added for TR#179900389 */
  if(vs$is_ancestry_valid( object   = &(SurfObj->obj_id),
		      classid = OPP_EMSpcylindr_class_id ) ) {

	      goto pc; // TR#179900389
                      // partial cylindrs end in problems while related to feet
	              //  Hence, treat it differently.
										      }
/* Block ends */

/* commented for TR#179900389
  if (
      (vs$is_ancestry_valid( object   = &(grEdge1.located_obj),
                            classid = OPP_EMScone_class_id )
                == TRUE) ||
      (vs$is_ancestry_valid( object   = &(grEdge1.located_obj),
                            classid = OPP_EMScylindr_class_id )
                == TRUE)
     )
*/
if(1) //#179900389  // The algo will work not only for cones and cylinder
		    // but any ruled surface where the roll lines are
		    // generator of the ruled surface.
		    // We usually deal with developable surfaces which is a
		    // special case of ruled surface.
		    // Hence always try the algo.

  {

    direction = !direction ; //TR 179900389

    for (ii=0; ii< *nb_bend_line; ii++)
      uv[ii] = (ii+1)/((IGRdouble) ( *nb_bend_line+1));

    sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
                                        &loc_sts,
                                        &(SurfObj->mod_env.md_env.matrix_type),
                                        SurfObj->mod_env.md_env.matrix,
                                        cst,
                                        FALSE,
                                         *nb_bend_line,
                                        uv,
                                        direction,
                                        &numCurves,
                                        &curvesObjId),
        senderid  = NULL_OBJID,
        targetid  = SurfObj->obj_id.objid,
        targetos  = SurfObj->obj_id.osnum );
     if (!(sts&loc_sts&1)) {
       printf("EMSsubbs.EMisoparcvs Failed\n");
       goto quit;
     }
     if (numCurves !=  *nb_bend_line) {
       *nb_bend_line = numCurves;
     }

     sts = om$send(msg = message GRvg.GRgenabsg(&loc_sts,
                                    &SurfObj->mod_env.md_env.matrix_type,
                                    SurfObj->mod_env.md_env.matrix,
                                   (IGRchar **)&sf),
                  senderid = NULL_OBJID,
                  targetid = SurfObj->obj_id.objid,
                  targetos = SurfObj->obj_id.osnum );
     if (!(loc_sts&sts&1)) {
       goto quit;
     }
     for (ii=0;ii<numCurves;ii++)
     {
       bendObj[ii].obj_id.objid = curvesObjId[ii];
       bendObj[ii].obj_id.osnum = cst->env_info->md_id.osnum;
       bendObj[ii].mod_env = *(cst->env_info);
       if (direction == TRUE)
       BSsfevaln(sf,uv[ii],0.5,1,&jj,vect1,BendingLine[ii].normal,&bsrc);
       else 
       BSsfevaln(sf,0.5,uv[ii],1,&jj,vect1,BendingLine[ii].normal,&bsrc);
     }
     // we dont need curvesObjId any more, we free it
     free(curvesObjId);

     *msg = MSSUCC;
     goto quit;
  }

  pc: /* Added for TR#179900389 */

  if ( *nb_bend_line == 1) {
    sts  = VLfindBendLineAlg1(  SurfObj,
                                cst,
                                direction,
                                BendingLine,
                                &loc_sts );

    CheckRC( sts, loc_sts ) ;

    if ( !(loc_sts&1&sts) ) {  //if default direction doesn't work try opposing
        if ( direction )    direction = FALSE;
        else                direction = TRUE;

        __DBGpr_int( "Bend: trying Alg1 with dir ", direction );

        sts  = VLfindBendLineAlg1(    SurfObj,
                                      cst,
                                      direction,
                                      BendingLine,
                                      &loc_sts );

        CheckRC( sts, loc_sts ) ;

        if ( !(loc_sts&1&sts) ) {         // if this hasn't worked try Alg2

               __DBGpr_com( "Bend: trying Alg2" );

                sts = VLfindBendLineAlg2(
                                             SurfObj,
                                             cst,
                                             shipsAxis,
                                             BendingLine,
                                             bendObj,
                                             &loc_sts );
                if (!(sts&loc_sts&1)) {
#ifdef DEBUG
                  printf("Bend: Alg2 failed\n");
#endif
                  goto quit;
                }
        }
        else {
                __DBGpr_com( "Bend: 2nd alg1 worked" );
                bendObj->obj_id.objid     =       NULL_OBJID;
        }
    }
    else {
          __DBGpr_com( "Bend: 1st alg1 worked" );
          bendObj->obj_id.objid     =       NULL_OBJID;
    }

    *msg = MSSUCC;
    goto quit;
  }
  
  direction = !direction;  // to have the same logic with the
                           // case of nb_bend_line==1.
  // find surface contour edges
  sts = vs$get_surface_edges( msg         = &loc_sts,
                              sfId        = &SurfObj->obj_id,
                              sfEnv       = &SurfObj->mod_env,
                              edgeType    = VS_K_CONTOUR_EDGES,
                              edCount     = &count,
                              edList      = &list ) ;

  if( !( sts & 1 & loc_sts ) ) {
#ifdef DEBUG
    printf( "~~~~~~~~~~ERROR in vs$get_surface_edges\n" ) ;
#endif
    goto quit;
  }
  // find two edges with minimum curvature
  for (ii=0;ii<count;ii++)
  {
    sts = vs$get_graphic_edge( msg    = &loc_sts,
                               edId   = &list[ii],
                               edEnv  = cst->env_info,
                              // edEnv  = &SurfObj->mod_env,
                               copy   = FALSE,
                               copyEnv   = NULL,
                               grEdge = &(grEdge[ii])) ;
    if( !( sts & 1 & loc_sts) ) {
#ifdef DEBUG
      printf( "~~~~~~~~~~ERROR in vs$get_graphic_edge\n" ) ;
#endif
      goto quit;
    }
    sts = om$send ( msg      = message GRcurve.GRmidpoint (
                                       &loc_sts,
                                       &SurfObj->mod_env.md_env.matrix_type,
                                       SurfObj->mod_env.md_env.matrix,
                                       NULL,
                                       vect3 ),
                      senderid = NULL_OBJID,
                      targetid = grEdge[ii].objid,
                      targetos = grEdge[ii].osnum );
    if( !( sts & 1 & loc_sts) ) {
#ifdef DEBUG
      printf( "~~~~~~~~~~ERROR in GRmidpoint\n" ) ;
#endif
      goto quit;
    }
    sts = om$send( msg = message GRcurve.GRendpts(
                                      &loc_sts,
                                      &SurfObj->mod_env.md_env.matrix_type,
                                      SurfObj->mod_env.md_env.matrix,
                                      vect1,vect2),
                          targetid = grEdge[ii].objid,
                          targetos = grEdge[ii].osnum,
                          senderid = NULL_OBJID);
    if( !( sts & 1 & loc_sts) ) {
#ifdef DEBUG
      printf( "~~~~~~~~~~ERROR in GRendpts\n" ) ;
#endif
      goto quit;
    }
    // find the midpoint of the line segment between vect1 and vect2
    vect1[0] = (vect1[0] + vect2[0])/2.;
    vect1[1] = (vect1[1] + vect2[1])/2.;
    vect1[2] = (vect1[2] + vect2[2])/2.;
    dist[ii] = ((vect1[0]- vect3[0])*(vect1[0]-vect3[0]) +
                (vect1[1]- vect3[1])*(vect1[1]-vect3[1]) +
                (vect1[2]- vect3[2])*(vect1[2]-vect3[2]));
  }
   // sorting edges
  for (ii=0;ii<count;ii++)
  {
    for (jj=ii+1;jj<count;jj++)
    {
      if (dist[ii] > dist[jj]) {
        grEdge1.located_obj    = grEdge[ii];
        grEdge[ii] = grEdge[jj];
        grEdge[jj] = grEdge1.located_obj;
        dot1 = dist[ii];
        dist[ii] = dist[jj];
        dist[jj] = dot1;
      }
    }
  }

  grEdge1.module_info = grEdge2.module_info = SurfObj->mod_env;
  grEdge1.located_obj = grEdge[0];

 // the two choosen edges with minimum curvature must not intersect 
  sts = om$send(msg =       message GRvg.GRgenabsg(
                                &loc_sts,
                                &grEdge1.module_info.md_env.matrix_type,
                                grEdge1.module_info.md_env.matrix,
                                (IGRchar **) &cv),
                senderid = NULL_OBJID,
                targetid = grEdge1.located_obj.objid,
                targetos = grEdge1.located_obj.osnum) ;
  if (!(sts&loc_sts&1))
    goto quit;
  
  edge_cv = *cv;
  edge_cv.poles = edge_cv.knots = edge_cv.weights = NULL;
  edge_cv.poles = (double *)
                       om$malloc( size = 3*cv->num_poles*sizeof(double));
  if (edge_cv.poles == NULL) goto quit;
  for (jj=0; jj<3*cv->num_poles;jj++) edge_cv.poles[jj]=cv->poles[jj];
  edge_cv.knots = (double *)
                           om$malloc( size = cv->num_knots*sizeof(double));
  if (edge_cv.knots == NULL) goto quit;
  for (jj=0; jj<cv->num_knots;jj++) edge_cv.knots[jj]=cv->knots[jj];
  if (cv->rational) {
    edge_cv.weights = (double *)
                           om$malloc( size = cv->num_knots*sizeof(double));
    if (edge_cv.weights == NULL) goto quit;
    for (jj=0; jj<cv->num_knots;jj++)
      edge_cv.weights[jj]=cv->weights[jj];
  }
  nb_int = 0; int_pts = par1 = par2 = end_pts = over0 = over1 = NULL;
  for (ii=1;ii<count;ii++)
  {
    sts = om$send(msg =       message GRvg.GRgenabsg(
                                &loc_sts,
                                &(SurfObj->mod_env.md_env.matrix_type),
                                SurfObj->mod_env.md_env.matrix,
                                (IGRchar **) &cv),
                senderid = NULL_OBJID,
                targetid = grEdge[ii].objid,
                targetos = grEdge[ii].osnum) ;
    if (!(sts&loc_sts&1))
      goto quit;

    // if grEdge1 intersecte grEdge[ii], take another edge than grEdge[ii]
    BScvcv_int(&bsrc,&edge_cv,cv,&nb_int,&int_pts,&par1,&par2,
               &n_over,&end_pts,&over0,&over1);
    if (nb_int==0) {
      grEdge2.located_obj = grEdge[ii];
      break;
    }
    if (int_pts) {om$dealloc(ptr= int_pts ); int_pts = NULL;}
    if (par1) {om$dealloc(ptr= par1 ); par1 = NULL;}
    if (par2) {om$dealloc(ptr= par2 ); par2 = NULL;}
    if (end_pts) {om$dealloc(ptr= end_pts ); end_pts = NULL;}
    if (over0) {om$dealloc(ptr= over0 ); over0 = NULL;}
    if (over1) {om$dealloc(ptr= over1 ); over1 = NULL;}
    nb_int = 0; 
  }
  if (ii == count) grEdge2.located_obj = grEdge[1];
  if (int_pts) {om$dealloc(ptr= int_pts ); int_pts = NULL;}
  if (par1) {om$dealloc(ptr= par1 ); par1 = NULL;}
  if (par2) {om$dealloc(ptr= par2 ); par2 = NULL;}
  if (end_pts) {om$dealloc(ptr= end_pts ); end_pts = NULL;}
  if (over0) {om$dealloc(ptr= over0 ); over0 = NULL;}
  if (over1) {om$dealloc(ptr= over1 ); over1 = NULL;}

  // are poles coplanars ?
  BStst_plan(cv->num_poles,cv->poles,cv->weights, &Planar[0],
             &(t_plan[3]),&bsrc);
  memcpy( (IGRchar *) &t_plan[0],(IGRchar *)&(cv->poles[0]),
             (IGRint) (3 * sizeof(IGRdouble)) );
  plane[0].point  = &t_plan[0] ;
  plane[0].normal = &t_plan[3] ;

  BStst_plan(edge_cv.num_poles,edge_cv.poles,edge_cv.weights, 
             &Planar[1], &(t_plan[9]),&bsrc);
  memcpy( (IGRchar *) &t_plan[6],(IGRchar *)&(edge_cv.poles[0]),
             (IGRint) (3 * sizeof(IGRdouble)) );
  plane[1].point  = &t_plan[6] ;
  plane[1].normal = &t_plan[9] ;

  // find if we should inverse curves before making the ruled surface

    BScveval(&edge_cv,0.0,1,&eval[0],&bsrc);
    if (bsrc != BSSUCC) goto quit;
    BScveval(&edge_cv,1.0,1,&eval[6],&bsrc);
    if (bsrc != BSSUCC) goto quit;

   BScveval(cv,0.0,1,&eval[12],&bsrc);
   if (bsrc != BSSUCC) goto quit;
   BScveval(cv,1.0,1,&eval[18],&bsrc);
   if (bsrc != BSSUCC) goto quit;

   reverse_curve_1 = FALSE;
   memcpy( (IGRchar *) &curve_end_points[0][0],(IGRchar *)&eval[0],
         (IGRint) (3 * sizeof(IGRdouble)) );

   dot1 = BSdotp(&bsrc, &(eval[3]), &(eval[15]));
   if (bsrc != BSSUCC) goto quit;
   dot2 = BSdotp(&bsrc, &(eval[9]), &(eval[21]));
   if (bsrc != BSSUCC) goto quit;
   #ifdef DEBUG
   printf(" dot1 =%f, dot2 = %f\n",dot1,dot2);
   #endif

   if( (dot1 < 0.0) && (dot2 < 0.0) ){
                reverse_curve_2 = TRUE;
                grEdge2.geom_parms.polygon_inx = 1;
                memcpy((IGRchar *) &curve_end_points[1][0],(IGRchar *)&eval[18],
                       (IGRint) (3 * sizeof(IGRdouble)) );

   }
   else{
                memcpy((IGRchar *) &curve_end_points[1][0],(IGRchar *)&eval[12],
                       (IGRint) (3 * sizeof(IGRdouble)) );

                reverse_curve_2 = FALSE;
                grEdge2.geom_parms.polygon_inx = 1;
   }

  if (edge_cv.poles) {om$dealloc(ptr= edge_cv.poles ); edge_cv.poles = NULL;}
  if (edge_cv.knots) {om$dealloc(ptr= edge_cv.knots ); edge_cv.knots = NULL;}
  if (edge_cv.weights) {om$dealloc(ptr= edge_cv.weights ); 
                        edge_cv.weights = NULL;}

  /* check if the two curves are coplanar and belong the same plane       
     then build a regular surface                                           */

   option_flag = 2;
   if( ( Planar[0] == 0 ) && ( Planar[1] == 0 ) ){

        for(jj=0;jj<3;jj=jj+1) 
          vect2[jj] = plane[0].point[jj] - plane[1].point[jj];

        BScrossp(&bsrc, plane[0].normal, plane[1].normal, vect1);
        if (bsrc != BSSUCC) goto quit;
        dot3 = BSdotp(&bsrc,vect1,vect1);
        if (bsrc != BSSUCC) goto quit;

        dot1 = BSdotp(&bsrc, vect2, plane[0].normal);
        if (bsrc != BSSUCC) goto quit;
        dot2 = BSdotp(&bsrc, vect2, plane[1].normal);
        if (bsrc != BSSUCC) goto quit;

        if( (fabs(dot1) < 1.0E-10) &&
            (fabs(dot2) < 1.0E-10) &&
            (fabs(dot3) < 1.0E-10) )    option_flag = 0;
   }

  ruled_surf.osnum = cst->env_info->md_id.osnum;
  ruled_surf.objid = NULL_OBJID;
  sts = om$construct( classid = OPP_EMSsubbs_class_id, 
	              p_objid = &ruled_surf.objid,
         	      osnum   = ruled_surf.osnum);
  sts = om$send(msg= message EMSgenbs.EMruled_surface(
                                                NULL,
                                                &grEdge1,
                                                NULL,
                                                &grEdge2,
                                                0,
                                                curve_1_points,
                                                curve_2_points,
                                                curve_end_points,
                                                TRUE,
                                                reverse_curve_1,
                                                reverse_curve_2,
                                                option_flag,
                                                FALSE,
                                                cst,
                                                &loc_sts ),

           senderid = NULL_OBJID,
           targetid = ruled_surf.objid,
           targetos = ruled_surf.osnum );
  if (!(sts&loc_sts&1)) {
    if (option_flag == 0) {
      printf("We can't construct Ruled Surface sts=%d msg = %d\n",sts,loc_sts);
      om$report_error(sts = sts);
      goto quit;
    }

   om$send( msg      = message GRgraphics.GRdelete
                                              ( &loc_sts, cst->env_info),
	                       senderid = NULL_OBJID,
                               targetid = ruled_surf.objid,
	                       targetos = ruled_surf.osnum);
  option_flag = 0; 
  ruled_surf.osnum = cst->env_info->md_id.osnum;
  ruled_surf.objid = NULL_OBJID;
  sts = om$construct( classid = OPP_EMSsubbs_class_id, 
	              p_objid = &ruled_surf.objid,
         	      osnum   = ruled_surf.osnum);

    //GRabsg_del_by_objid(&ruled_surf.objid,&ruled_surf.osnum);

    sts = om$send(msg= message EMSgenbs.EMruled_surface(
                                                NULL,
                                                &grEdge1,
                                                NULL,
                                                &grEdge2,
                                                0,
                                                curve_1_points,
                                                curve_2_points,
                                                curve_end_points,
                                                TRUE,
                                                reverse_curve_1,
                                                reverse_curve_2,
                                                option_flag,
                                                FALSE,
                                                cst,
                                                &loc_sts ),
                 senderid = NULL_OBJID,
                 targetid = ruled_surf.objid,
                 targetos = ruled_surf.osnum );
    if (!(sts&loc_sts&1)) {
      printf("Can't construct Ruled Surface sts=%d msg = %d\n",sts,loc_sts);
      om$report_error(sts = sts);
      goto quit;
    }
  }

// find if the ruled surface has the same orientation as the original surface

  uv[0]=0.5;
  sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
                                      &loc_sts,
                                      &(cst->env_info->md_env.matrix_type),
                                      cst->env_info->md_env.matrix,
                                      cst,
                                      FALSE,
                                       1,
                                      uv,
                                      TRUE,
                                      &numCurves,
                                      &curvesObjId),
        senderid  = NULL_OBJID,
        targetid  = ruled_surf.objid,
        targetos  = ruled_surf.osnum );
   if (!(sts&loc_sts&1)) {
     printf("EMSsubbs.EMisoparcvs Failed\n");
     goto quit;
   }
   sts=om$send ( msg = message GRcurve.GRendpts(
					&loc_sts, 
					&cst->env_info->md_env.matrix_type, 
					cst->env_info->md_env.matrix,
		        		vect1,vect2),
	       	      senderid = NULL_OBJID, 
		      targetid = *curvesObjId,
		      targetos = cst->env_info->md_id.osnum);
   if (!(sts&loc_sts&1)) {
     goto quit;
   }

   sts = om$send(msg = message GRvg.GRgenabsg(&loc_sts,
                                    &SurfObj->mod_env.md_env.matrix_type,
                                    SurfObj->mod_env.md_env.matrix,
                                   (IGRchar **)&sf),
                  senderid = NULL_OBJID,
                  targetid = SurfObj->obj_id.objid,
                  targetos = SurfObj->obj_id.osnum );
   if (!(sts&loc_sts&1)) {
     goto quit;
   }
   BSptnorsf( sf, vect1 , &ii ,
              &eval[0], &eval[1] ,
              vect3 , &dot1 , &bsrc ) ;
  if (bsrc != BSSUCC) goto quit;
   BSptnorsf( sf, vect2 , &ii,
              &eval[2], &eval[3] ,
              vect3 , &dot1 , &bsrc ) ;
  if (bsrc != BSSUCC) goto quit;
  if (fabs(eval[0] - eval[2]) > fabs(eval[1] - eval[3])) {
    direction = !direction;
  }
 
   om$send( msg      = message GRgraphics.GRdelete
                                              ( &loc_sts, cst->env_info),
	                       senderid = NULL_OBJID,
                               targetid = *curvesObjId,
	                       targetos = cst->env_info->md_id.osnum);
   free(curvesObjId);
   curvesObjId = NULL;

// create roll lines
  for (ii=0; ii< *nb_bend_line; ii++)
    uv[ii] = (ii+1)/((IGRdouble )( *nb_bend_line+1));

  sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
                                      &loc_sts,
                                      &(cst->env_info->md_env.matrix_type),
                                      cst->env_info->md_env.matrix,
                                      cst,
                                      FALSE,
                                       *nb_bend_line,
                                      uv,
                                      direction,
                                      &numCurves,
                                      &curvesObjId),
        senderid  = NULL_OBJID,
        targetid  = ruled_surf.objid,
        targetos  = ruled_surf.osnum );
   if (!(sts&loc_sts&1)) {
     printf("EMSsubbs.EMisoparcvs Failed\n");
     goto quit;
   }
   if (numCurves !=  *nb_bend_line) {
     *nb_bend_line = numCurves;
   }
   sts = om$send(msg = message GRvg.GRgenabsg(&loc_sts,
                                    &SurfObj->mod_env.md_env.matrix_type,
                                    SurfObj->mod_env.md_env.matrix,
                                   (IGRchar **)&sf),
                  senderid = NULL_OBJID,
                  targetid = SurfObj->obj_id.objid,
                  targetos = SurfObj->obj_id.osnum );
   if (!(sts&loc_sts&1)) {
     goto quit;
   }
   for (ii=0;ii<numCurves;ii++)
   {
     bendObj[ii].obj_id.objid = curvesObjId[ii];
     bendObj[ii].obj_id.osnum = cst->env_info->md_id.osnum;
     bendObj[ii].mod_env = *(cst->env_info);
     if (direction == TRUE)
     BSsfevaln(sf,uv[ii],0.5,1,&jj,vect1,BendingLine[ii].normal,&bsrc);
     else 
     BSsfevaln(sf,0.5,uv[ii],1,&jj,vect1,BendingLine[ii].normal,&bsrc);
   }

   // we dont need curvesObjId and ruled_surf any more, we free and delete it
   free(curvesObjId);
   sts = om$send( msg      = message GRgraphics.GRdelete
                                                ( &loc_sts, cst->env_info),
	                       senderid = NULL_OBJID,
                               targetid = ruled_surf.objid,
	                       targetos = ruled_surf.osnum);
  *msg = MSSUCC;
  quit :
  if (list) {free(list);list = NULL;}
  return *msg;
}

/*==========================================================================*/

IGRlong VLfindBendLine(

struct GRobj_env	*SurfObj,    /*I the base surface */
struct GRvg_construct	*cst,	     /*I construction list */
IGRboolean		direction,   /*I direction to define extraction of iso
					 curve in u or v direction.
					 direction = TRUE -> extract iso v,
					 direction = FALSE ->extract iso u */
IGRint			*nb_bend_line, /*I Bending line's number */
IGRvector		shipsAxis,    /*I The ships axis */
struct BendingLineInfo  *BendingLine,/*O bending lines information */
struct GRobj_env	*bendObj,    /*O bending line objects or NUL_OBJID*/
IGRlong			*msg	     /*O MSSUCC or MSFAIL */
)
{
int			count,ii,jj;
long			sts,loc_sts;
struct GRlc_info 	grEdge1,grEdge2;
struct GRid		grEdge[VLRolNumFeet];
struct GRid		ruled_surf,*list = NULL;
struct IGRbsp_curve	edge_cv,*cv=NULL;
IGRboolean		reverse_curve_1,reverse_curve_2,option_flag;
long			numCurves;
GRobjid			*curvesObjId;
BSrc			bsrc;
struct IGRbsp_surface	*sf;
int			nb_int = 0; 
long			n_over;
struct IGRplane		plane[2];
IGRdouble		*int_pts,*par1,*par2,*end_pts,*over0,*over1;
IGRdouble		eval[24],t_plan[12];
IGRdouble		dist[VLRolNumFeet];
IGRpoint		curve_end_points[2];
IGRpoint		curve_1_points[1],curve_2_points[1];
IGRdouble   		uv[VLRolNumFeet];
IGRboolean 		Planar[2];
IGRdouble        	vect1[4],vect2[4],vect3[4];
IGRdouble		dot1,dot2,dot3;

  *msg = MSFAIL;
  sts = om$send( msg      = message NDnode.ASreturn_go(
                                     &(grEdge1.located_obj),
                                     &(grEdge1.module_info.md_env.matrix_type),
                                     grEdge1.module_info.md_env.matrix),
                senderid = NULL_OBJID,
                targetid = SurfObj->obj_id.objid,
                targetos = SurfObj->obj_id.osnum );

  if (
      (vs$is_ancestry_valid( object   = &(grEdge1.located_obj),
                            classid = OPP_EMScone_class_id )
                == TRUE) ||
      (vs$is_ancestry_valid( object   = &(grEdge1.located_obj),
                            classid = OPP_EMScylindr_class_id )
                == TRUE)
     )
  {
    for (ii=0; ii< *nb_bend_line; ii++)
      uv[ii] = (ii+1)/((IGRdouble) ( *nb_bend_line+1));

    sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
                                        &loc_sts,
                                        &(SurfObj->mod_env.md_env.matrix_type),
                                        SurfObj->mod_env.md_env.matrix,
                                        cst,
                                        FALSE,
                                         *nb_bend_line,
                                        uv,
                                        direction,
                                        &numCurves,
                                        &curvesObjId),
        senderid  = NULL_OBJID,
        targetid  = SurfObj->obj_id.objid,
        targetos  = SurfObj->obj_id.osnum );
     if (!(sts&loc_sts&1)) {
       printf("EMSsubbs.EMisoparcvs Failed\n");
       goto quit;
     }
     if (numCurves !=  *nb_bend_line) {
       *nb_bend_line = numCurves;
     }

     sts = om$send(msg = message GRvg.GRgenabsg(&loc_sts,
                                    &SurfObj->mod_env.md_env.matrix_type,
                                    SurfObj->mod_env.md_env.matrix,
                                   (IGRchar **)&sf),
                  senderid = NULL_OBJID,
                  targetid = SurfObj->obj_id.objid,
                  targetos = SurfObj->obj_id.osnum );
     if (!(loc_sts&sts&1)) {
       goto quit;
     }
     for (ii=0;ii<numCurves;ii++)
     {
       bendObj[ii].obj_id.objid = curvesObjId[ii];
       bendObj[ii].obj_id.osnum = cst->env_info->md_id.osnum;
       bendObj[ii].mod_env = *(cst->env_info);
       if (direction == TRUE)
       BSsfevaln(sf,uv[ii],0.5,1,&jj,vect1,BendingLine[ii].normal,&bsrc);
       else 
       BSsfevaln(sf,0.5,uv[ii],1,&jj,vect1,BendingLine[ii].normal,&bsrc);
     }
     // we dont need curvesObjId any more, we free it
     free(curvesObjId);

     *msg = MSSUCC;
     goto quit;
  }

  if ( *nb_bend_line == 1) {
    sts  = VLfindBendLineAlg1(  SurfObj,
                                cst,
                                direction,
                                BendingLine,
                                &loc_sts );

    CheckRC( sts, loc_sts ) ;

    if ( !(loc_sts&1&sts) ) {  //if default direction doesn't work try opposing
        if ( direction )    direction = FALSE;
        else                direction = TRUE;

        __DBGpr_int( "Bend: trying Alg1 with dir ", direction );

        sts  = VLfindBendLineAlg1(    SurfObj,
                                      cst,
                                      direction,
                                      BendingLine,
                                      &loc_sts );

        CheckRC( sts, loc_sts ) ;

        if ( !(loc_sts&1&sts) ) {         // if this hasn't worked try Alg2

               __DBGpr_com( "Bend: trying Alg2" );

                sts = VLfindBendLineAlg2(
                                             SurfObj,
                                             cst,
                                             shipsAxis,
                                             BendingLine,
                                             bendObj,
                                             &loc_sts );
                if (!(sts&loc_sts&1)) {
#ifdef DEBUG
                  printf("Bend: Alg2 failed\n");
#endif
                  goto quit;
                }
        }
        else {
                __DBGpr_com( "Bend: 2nd alg1 worked" );
                bendObj->obj_id.objid     =       NULL_OBJID;
        }
    }
    else {
          __DBGpr_com( "Bend: 1st alg1 worked" );
          bendObj->obj_id.objid     =       NULL_OBJID;
    }

    *msg = MSSUCC;
    goto quit;
  }
  
  direction = !direction;  // to have the same logic with the
                           // case of nb_bend_line==1.
  // find surface contour edges
  sts = vs$get_surface_edges( msg         = &loc_sts,
                              sfId        = &SurfObj->obj_id,
                              sfEnv       = &SurfObj->mod_env,
                              edgeType    = VS_K_CONTOUR_EDGES,
                              edCount     = &count,
                              edList      = &list ) ;

  if( !( sts & 1 & loc_sts ) ) {
#ifdef DEBUG
    printf( "~~~~~~~~~~ERROR in vs$get_surface_edges\n" ) ;
#endif
    goto quit;
  }
  // find two edges with minimum curvature
  for (ii=0;ii<count;ii++)
  {
    sts = vs$get_graphic_edge( msg    = &loc_sts,
                               edId   = &list[ii],
                               edEnv  = cst->env_info,
                              // edEnv  = &SurfObj->mod_env,
                               copy   = FALSE,
                               copyEnv   = NULL,
                               grEdge = &(grEdge[ii])) ;
    if( !( sts & 1 & loc_sts) ) {
#ifdef DEBUG
      printf( "~~~~~~~~~~ERROR in vs$get_graphic_edge\n" ) ;
#endif
      goto quit;
    }
    sts = om$send ( msg      = message GRcurve.GRmidpoint (
                                       &loc_sts,
                                       &SurfObj->mod_env.md_env.matrix_type,
                                       SurfObj->mod_env.md_env.matrix,
                                       NULL,
                                       vect3 ),
                      senderid = NULL_OBJID,
                      targetid = grEdge[ii].objid,
                      targetos = grEdge[ii].osnum );
    if( !( sts & 1 & loc_sts) ) {
#ifdef DEBUG
      printf( "~~~~~~~~~~ERROR in GRmidpoint\n" ) ;
#endif
      goto quit;
    }
    sts = om$send( msg = message GRcurve.GRendpts(
                                      &loc_sts,
                                      &SurfObj->mod_env.md_env.matrix_type,
                                      SurfObj->mod_env.md_env.matrix,
                                      vect1,vect2),
                          targetid = grEdge[ii].objid,
                          targetos = grEdge[ii].osnum,
                          senderid = NULL_OBJID);
    if( !( sts & 1 & loc_sts) ) {
#ifdef DEBUG
      printf( "~~~~~~~~~~ERROR in GRendpts\n" ) ;
#endif
      goto quit;
    }
    // find the midpoint of the line segment between vect1 and vect2
    vect1[0] = (vect1[0] + vect2[0])/2.;
    vect1[1] = (vect1[1] + vect2[1])/2.;
    vect1[2] = (vect1[2] + vect2[2])/2.;
    dist[ii] = ((vect1[0]- vect3[0])*(vect1[0]-vect3[0]) +
                (vect1[1]- vect3[1])*(vect1[1]-vect3[1]) +
                (vect1[2]- vect3[2])*(vect1[2]-vect3[2]));
  }
   // sorting edges
  for (ii=0;ii<count;ii++)
  {
    for (jj=ii+1;jj<count;jj++)
    {
      if (dist[ii] > dist[jj]) {
        grEdge1.located_obj    = grEdge[ii];
        grEdge[ii] = grEdge[jj];
        grEdge[jj] = grEdge1.located_obj;
        dot1 = dist[ii];
        dist[ii] = dist[jj];
        dist[jj] = dot1;
      }
    }
  }

  grEdge1.module_info = grEdge2.module_info = SurfObj->mod_env;
  grEdge1.located_obj = grEdge[0];

 // the two choosen edges with minimum curvature must not intersect 
  sts = om$send(msg =       message GRvg.GRgenabsg(
                                &loc_sts,
                                &grEdge1.module_info.md_env.matrix_type,
                                grEdge1.module_info.md_env.matrix,
                                (IGRchar **) &cv),
                senderid = NULL_OBJID,
                targetid = grEdge1.located_obj.objid,
                targetos = grEdge1.located_obj.osnum) ;
  if (!(sts&loc_sts&1))
    goto quit;
  
  edge_cv = *cv;
  edge_cv.poles = edge_cv.knots = edge_cv.weights = NULL;
  edge_cv.poles = (double *)
                       om$malloc( size = 3*cv->num_poles*sizeof(double));
  if (edge_cv.poles == NULL) goto quit;
  for (jj=0; jj<3*cv->num_poles;jj++) edge_cv.poles[jj]=cv->poles[jj];
  edge_cv.knots = (double *)
                           om$malloc( size = cv->num_knots*sizeof(double));
  if (edge_cv.knots == NULL) goto quit;
  for (jj=0; jj<cv->num_knots;jj++) edge_cv.knots[jj]=cv->knots[jj];
  if (cv->rational) {
    edge_cv.weights = (double *)
                           om$malloc( size = cv->num_knots*sizeof(double));
    if (edge_cv.weights == NULL) goto quit;
    for (jj=0; jj<cv->num_knots;jj++)
      edge_cv.weights[jj]=cv->weights[jj];
  }
  nb_int = 0; int_pts = par1 = par2 = end_pts = over0 = over1 = NULL;
  for (ii=1;ii<count;ii++)
  {
    sts = om$send(msg =       message GRvg.GRgenabsg(
                                &loc_sts,
                                &(SurfObj->mod_env.md_env.matrix_type),
                                SurfObj->mod_env.md_env.matrix,
                                (IGRchar **) &cv),
                senderid = NULL_OBJID,
                targetid = grEdge[ii].objid,
                targetos = grEdge[ii].osnum) ;
    if (!(sts&loc_sts&1))
      goto quit;

    // if grEdge1 intersecte grEdge[ii], take another edge than grEdge[ii]
    BScvcv_int(&bsrc,&edge_cv,cv,&nb_int,&int_pts,&par1,&par2,
               &n_over,&end_pts,&over0,&over1);
    if (nb_int==0) {
      grEdge2.located_obj = grEdge[ii];
      break;
    }
    if (int_pts) {om$dealloc(ptr= int_pts ); int_pts = NULL;}
    if (par1) {om$dealloc(ptr= par1 ); par1 = NULL;}
    if (par2) {om$dealloc(ptr= par2 ); par2 = NULL;}
    if (end_pts) {om$dealloc(ptr= end_pts ); end_pts = NULL;}
    if (over0) {om$dealloc(ptr= over0 ); over0 = NULL;}
    if (over1) {om$dealloc(ptr= over1 ); over1 = NULL;}
    nb_int = 0; 
  }
  if (ii == count) grEdge2.located_obj = grEdge[1];
  if (int_pts) {om$dealloc(ptr= int_pts ); int_pts = NULL;}
  if (par1) {om$dealloc(ptr= par1 ); par1 = NULL;}
  if (par2) {om$dealloc(ptr= par2 ); par2 = NULL;}
  if (end_pts) {om$dealloc(ptr= end_pts ); end_pts = NULL;}
  if (over0) {om$dealloc(ptr= over0 ); over0 = NULL;}
  if (over1) {om$dealloc(ptr= over1 ); over1 = NULL;}

  // are poles coplanars ?
  BStst_plan(cv->num_poles,cv->poles,cv->weights, &Planar[0],
             &(t_plan[3]),&bsrc);
  memcpy( (IGRchar *) &t_plan[0],(IGRchar *)&(cv->poles[0]),
             (IGRint) (3 * sizeof(IGRdouble)) );
  plane[0].point  = &t_plan[0] ;
  plane[0].normal = &t_plan[3] ;

  BStst_plan(edge_cv.num_poles,edge_cv.poles,edge_cv.weights, 
             &Planar[1], &(t_plan[9]),&bsrc);
  memcpy( (IGRchar *) &t_plan[6],(IGRchar *)&(edge_cv.poles[0]),
             (IGRint) (3 * sizeof(IGRdouble)) );
  plane[1].point  = &t_plan[6] ;
  plane[1].normal = &t_plan[9] ;

  // find if we should inverse curves before making the ruled surface

    BScveval(&edge_cv,0.0,1,&eval[0],&bsrc);
    if (bsrc != BSSUCC) goto quit;
    BScveval(&edge_cv,1.0,1,&eval[6],&bsrc);
    if (bsrc != BSSUCC) goto quit;

   BScveval(cv,0.0,1,&eval[12],&bsrc);
   if (bsrc != BSSUCC) goto quit;
   BScveval(cv,1.0,1,&eval[18],&bsrc);
   if (bsrc != BSSUCC) goto quit;

   reverse_curve_1 = FALSE;
   memcpy( (IGRchar *) &curve_end_points[0][0],(IGRchar *)&eval[0],
         (IGRint) (3 * sizeof(IGRdouble)) );

   dot1 = BSdotp(&bsrc, &(eval[3]), &(eval[15]));
   if (bsrc != BSSUCC) goto quit;
   dot2 = BSdotp(&bsrc, &(eval[9]), &(eval[21]));
   if (bsrc != BSSUCC) goto quit;
   #ifdef DEBUG
   printf(" dot1 =%f, dot2 = %f\n",dot1,dot2);
   #endif

   if( (dot1 < 0.0) && (dot2 < 0.0) ){
                reverse_curve_2 = TRUE;
                grEdge2.geom_parms.polygon_inx = 1;
                memcpy((IGRchar *) &curve_end_points[1][0],(IGRchar *)&eval[18],
                       (IGRint) (3 * sizeof(IGRdouble)) );

   }
   else{
                memcpy((IGRchar *) &curve_end_points[1][0],(IGRchar *)&eval[12],
                       (IGRint) (3 * sizeof(IGRdouble)) );

                reverse_curve_2 = FALSE;
                grEdge2.geom_parms.polygon_inx = 1;
   }

  if (edge_cv.poles) {om$dealloc(ptr= edge_cv.poles ); edge_cv.poles = NULL;}
  if (edge_cv.knots) {om$dealloc(ptr= edge_cv.knots ); edge_cv.knots = NULL;}
  if (edge_cv.weights) {om$dealloc(ptr= edge_cv.weights ); 
                        edge_cv.weights = NULL;}

  /* check if the two curves are coplanar and belong the same plane       
     then build a regular surface                                           */

   option_flag = 2;
   if( ( Planar[0] == 0 ) && ( Planar[1] == 0 ) ){

        for(jj=0;jj<3;jj=jj+1) 
          vect2[jj] = plane[0].point[jj] - plane[1].point[jj];

        BScrossp(&bsrc, plane[0].normal, plane[1].normal, vect1);
        if (bsrc != BSSUCC) goto quit;
        dot3 = BSdotp(&bsrc,vect1,vect1);
        if (bsrc != BSSUCC) goto quit;

        dot1 = BSdotp(&bsrc, vect2, plane[0].normal);
        if (bsrc != BSSUCC) goto quit;
        dot2 = BSdotp(&bsrc, vect2, plane[1].normal);
        if (bsrc != BSSUCC) goto quit;

        if( (fabs(dot1) < 1.0E-10) &&
            (fabs(dot2) < 1.0E-10) &&
            (fabs(dot3) < 1.0E-10) )    option_flag = 0;
   }

  ruled_surf.osnum = cst->env_info->md_id.osnum;
  ruled_surf.objid = NULL_OBJID;
  sts = om$construct( classid = OPP_EMSsubbs_class_id, 
	              p_objid = &ruled_surf.objid,
         	      osnum   = ruled_surf.osnum);
  sts = om$send(msg= message EMSgenbs.EMruled_surface(
                                                NULL,
                                                &grEdge1,
                                                NULL,
                                                &grEdge2,
                                                0,
                                                curve_1_points,
                                                curve_2_points,
                                                curve_end_points,
                                                TRUE,
                                                reverse_curve_1,
                                                reverse_curve_2,
                                                option_flag,
                                                FALSE,
                                                cst,
                                                &loc_sts ),

           senderid = NULL_OBJID,
           targetid = ruled_surf.objid,
           targetos = ruled_surf.osnum );
  if (!(sts&loc_sts&1)) {
    if (option_flag == 0) {
      printf("We can't construct Ruled Surface sts=%d msg = %d\n",sts,loc_sts);
      om$report_error(sts = sts);
      goto quit;
    }

   om$send( msg      = message GRgraphics.GRdelete
                                              ( &loc_sts, cst->env_info),
	                       senderid = NULL_OBJID,
                               targetid = ruled_surf.objid,
	                       targetos = ruled_surf.osnum);
  option_flag = 0; 
  ruled_surf.osnum = cst->env_info->md_id.osnum;
  ruled_surf.objid = NULL_OBJID;
  sts = om$construct( classid = OPP_EMSsubbs_class_id, 
	              p_objid = &ruled_surf.objid,
         	      osnum   = ruled_surf.osnum);

    //GRabsg_del_by_objid(&ruled_surf.objid,&ruled_surf.osnum);

    sts = om$send(msg= message EMSgenbs.EMruled_surface(
                                                NULL,
                                                &grEdge1,
                                                NULL,
                                                &grEdge2,
                                                0,
                                                curve_1_points,
                                                curve_2_points,
                                                curve_end_points,
                                                TRUE,
                                                reverse_curve_1,
                                                reverse_curve_2,
                                                option_flag,
                                                FALSE,
                                                cst,
                                                &loc_sts ),
                 senderid = NULL_OBJID,
                 targetid = ruled_surf.objid,
                 targetos = ruled_surf.osnum );
    if (!(sts&loc_sts&1)) {
      printf("Can't construct Ruled Surface sts=%d msg = %d\n",sts,loc_sts);
      om$report_error(sts = sts);
      goto quit;
    }
  }

// find if the ruled surface has the same orientation as the original surface

  uv[0]=0.5;
  sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
                                      &loc_sts,
                                      &(cst->env_info->md_env.matrix_type),
                                      cst->env_info->md_env.matrix,
                                      cst,
                                      FALSE,
                                       1,
                                      uv,
                                      TRUE,
                                      &numCurves,
                                      &curvesObjId),
        senderid  = NULL_OBJID,
        targetid  = ruled_surf.objid,
        targetos  = ruled_surf.osnum );
   if (!(sts&loc_sts&1)) {
     printf("EMSsubbs.EMisoparcvs Failed\n");
     goto quit;
   }
   sts=om$send ( msg = message GRcurve.GRendpts(
					&loc_sts, 
					&cst->env_info->md_env.matrix_type, 
					cst->env_info->md_env.matrix,
		        		vect1,vect2),
	       	      senderid = NULL_OBJID, 
		      targetid = *curvesObjId,
		      targetos = cst->env_info->md_id.osnum);
   if (!(sts&loc_sts&1)) {
     goto quit;
   }

   sts = om$send(msg = message GRvg.GRgenabsg(&loc_sts,
                                    &SurfObj->mod_env.md_env.matrix_type,
                                    SurfObj->mod_env.md_env.matrix,
                                   (IGRchar **)&sf),
                  senderid = NULL_OBJID,
                  targetid = SurfObj->obj_id.objid,
                  targetos = SurfObj->obj_id.osnum );
   if (!(sts&loc_sts&1)) {
     goto quit;
   }
   BSptnorsf( sf, vect1 , &ii ,
              &eval[0], &eval[1] ,
              vect3 , &dot1 , &bsrc ) ;
  if (bsrc != BSSUCC) goto quit;
   BSptnorsf( sf, vect2 , &ii,
              &eval[2], &eval[3] ,
              vect3 , &dot1 , &bsrc ) ;
  if (bsrc != BSSUCC) goto quit;
  if (fabs(eval[0] - eval[2]) > fabs(eval[1] - eval[3])) {
    direction = !direction;
  }
 
   om$send( msg      = message GRgraphics.GRdelete
                                              ( &loc_sts, cst->env_info),
	                       senderid = NULL_OBJID,
                               targetid = *curvesObjId,
	                       targetos = cst->env_info->md_id.osnum);
   free(curvesObjId);
   curvesObjId = NULL;

// create roll lines
  for (ii=0; ii< *nb_bend_line; ii++)
    uv[ii] = (ii+1)/((IGRdouble )( *nb_bend_line+1));

  sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
                                      &loc_sts,
                                      &(cst->env_info->md_env.matrix_type),
                                      cst->env_info->md_env.matrix,
                                      cst,
                                      FALSE,
                                       *nb_bend_line,
                                      uv,
                                      direction,
                                      &numCurves,
                                      &curvesObjId),
        senderid  = NULL_OBJID,
        targetid  = ruled_surf.objid,
        targetos  = ruled_surf.osnum );
   if (!(sts&loc_sts&1)) {
     printf("EMSsubbs.EMisoparcvs Failed\n");
     goto quit;
   }
   if (numCurves !=  *nb_bend_line) {
     *nb_bend_line = numCurves;
   }
   sts = om$send(msg = message GRvg.GRgenabsg(&loc_sts,
                                    &SurfObj->mod_env.md_env.matrix_type,
                                    SurfObj->mod_env.md_env.matrix,
                                   (IGRchar **)&sf),
                  senderid = NULL_OBJID,
                  targetid = SurfObj->obj_id.objid,
                  targetos = SurfObj->obj_id.osnum );
   if (!(sts&loc_sts&1)) {
     goto quit;
   }
   for (ii=0;ii<numCurves;ii++)
   {
     bendObj[ii].obj_id.objid = curvesObjId[ii];
     bendObj[ii].obj_id.osnum = cst->env_info->md_id.osnum;
     bendObj[ii].mod_env = *(cst->env_info);
     if (direction == TRUE)
     BSsfevaln(sf,uv[ii],0.5,1,&jj,vect1,BendingLine[ii].normal,&bsrc);
     else 
     BSsfevaln(sf,0.5,uv[ii],1,&jj,vect1,BendingLine[ii].normal,&bsrc);
   }

   // we dont need curvesObjId and ruled_surf any more, we free and delete it
   free(curvesObjId);
   sts = om$send( msg      = message GRgraphics.GRdelete
                                                ( &loc_sts, cst->env_info),
	                       senderid = NULL_OBJID,
                               targetid = ruled_surf.objid,
	                       targetos = ruled_surf.osnum);
  *msg = MSSUCC;
  quit :
  if (list) {free(list);list = NULL;}
  return *msg;
}

IGRlong VLfindBendLineAlg1 (

struct GRobj_env	*SurfObj,    /*I the base surface */
struct GRvg_construct	*cst,	     /*I construction list */
IGRboolean		direction,   /*I direction to define extraction of iso
					 curve in u or v direction.
					 direction = TRUE -> extract iso v,
					 direction = FALSE ->extract iso u */
struct BendingLineInfo  *BendingLine,/*O bending line information */
IGRlong			*msg	     /*O MSSUCC or MSFAIL */
)

/*d This function evaluates the bending with the alogorithm 1. */

/*h 22/october/92 JLL creation date */

/*c Beginning of function */

{
 BSrc			rc;
 IGRint 		numNormals,i;
 IGRlong		loc_msg,numCurves;
 IGRint			nbNFLine,nbLine;
 IGRlong		sts, ret;
 IGRdouble		uv01[2],uI,vI;
 IGRdouble		du,dv;
 IGRdouble		cht;
 double			minMidPar,midPar;
 GRobjid		*curvesObjId;
 struct GRobj_env	curveId;
 struct BendingLineInfo bendingLineList[20];
 struct IGRbsp_surface	*bspSf;
 struct IGRbsp_curve	*bspCv1;
 struct IGRbsp_curve	*bspCv2;
 struct IGRbsp_curve	*bspExCv1;
 struct IGRbsp_curve	*bspExCv2;
 IGRpoint		ptI ;
 IGRint			SizeGRmd_env;

 /*c Retrieve the avtive cht. */ 

 *msg = MSFAIL;
 BSxtractpar( &rc, BSTOLCHRDHT, &cht );

 uv01[0] = 0.0;
 uv01[1] = 1.0;

 bspSf	  = NULL;
 bspCv1   = NULL;
 bspExCv1 = NULL; 
 bspCv2   = NULL;
 bspExCv2 = NULL; 
 
 #ifdef DEBUG
	printf("cht = %f\n",cht);
	printf(  "surface ID %d/%d\n",SurfObj->obj_id.objid,
				      SurfObj->obj_id.osnum);
 #endif

 cst->geometry = NULL;

 sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
					&loc_msg,
					&SurfObj->mod_env.md_env.matrix_type,
					SurfObj->mod_env.md_env.matrix,
					cst,
					FALSE,
					2,
					uv01,
					direction,
					&numCurves,
					&curvesObjId),
	senderid  = NULL_OBJID,
	targetid  = SurfObj->obj_id.objid,
	targetos  = SurfObj->obj_id.osnum );
 if (!(sts&loc_msg&1)) {
   goto quit;  
 }

 SizeGRmd_env = sizeof( struct GRmd_env );

 /*c retrieve geometry of iso 1 */

 curveId.obj_id.objid	= curvesObjId[0];
 curveId.obj_id.osnum	= cst->env_info->md_id.osnum;
 memcpy( (IGRchar *)&curveId.mod_env, (IGRchar *)cst->env_info, SizeGRmd_env );
 ret = VLgetGeometry( &curveId, (IGRboolean)FALSE, 
		       NULL_OBJID, (IGRchar **)&bspCv1, &sts );
 if (!(ret&sts&1)) {
	#ifdef DEBUG
 	printf(" Error VLgetGeometry 1 \n");
	#endif
	goto quit;
 }

 /*c retrieve the extented geometry of iso 1 */

 ret = VLgetExGeometry( &curveId, NULL_OBJID, (IGRchar **)&bspExCv1, &sts );
 if (!(ret&sts&1)) {
	#ifdef DEBUG	
 	printf("  Error VLgetExGeometry 1 \n");
	#endif
	goto quit;
 }

 /*c retrieve geometry of iso 2 */

 curveId.obj_id.objid	= curvesObjId[1];
 curveId.obj_id.osnum	= cst->env_info->md_id.osnum;
 memcpy( (IGRchar *)&curveId.mod_env, (IGRchar *)cst->env_info, SizeGRmd_env );

 ret = VLgetGeometry( &curveId, (IGRboolean)FALSE, 
		       NULL_OBJID, (IGRchar **)&bspCv2, &sts );
 if (!(ret&sts&1)) {
	#ifdef DEBUG	
 	printf(" Error VLgetGeometry 2 \n");
	#endif
        goto quit;
 }

 /*c retrieve the extented geometry of iso 2 */

 ret = VLgetExGeometry( &curveId, NULL_OBJID, (IGRchar **)&bspExCv2, &sts );
 if (!(ret&sts&1)) {
	#ifdef DEBUG	
 	printf("  Error VLgetExGeometry 1 \n");
	#endif
	goto quit;
 }

 /*c Depending if we extract iso curves in u or v direction, set up 
     the incrementation direction.*/

 if ( direction == FALSE ){

	#ifdef DEBUG
		printf(  "courbure en u extract iso u\n");
	#endif

	du = 1.0;
	dv = 0.0;
 }
 else {

	#ifdef DEBUG
		printf(  "courbure en v extract iso v\n");
	#endif

	du = 0.0;
	dv = 1.0;
 }

 nbLine	  = 0;
 nbNFLine = 5;
 du 	  = du / (IGRdouble) (nbNFLine+1);
 dv 	  = dv / (IGRdouble) (nbNFLine+1);
 uI 	  = 0.0;
 vI 	  = 0.0;

 if ( fabs(du) < 0.00001 )	uI 	= 0.5; 
 if ( fabs(dv) < 0.00001 )	vI 	= 0.5; 

 /*c retrieve the BSsurface definition. */

 ret = VLgetGeometry( SurfObj, (IGRboolean)FALSE, NULL_OBJID, 
		       (IGRchar **)&bspSf, &loc_msg );
 if ( !(ret & loc_msg & 1) ){	
	#ifdef DEBUG
 	printf(" Error VLgetGeometry for the surface \n");
	#endif
	goto quit;
 }

 for(i=0;i<nbNFLine;i++){

	uI	= uI + du;	  
	vI	= vI + dv;	  

 	BSsfevaln(	bspSf,
			uI,
			vI,
			1,
			&numNormals,
			ptI,
			BendingLine->normal,
			&rc 	);
	
	#ifdef DEBUG 
	printf("numNormals = %d, tangente en uv = %lf %lf\n",numNormals,uI,vI);
	#endif 

 	if(rc!=BSSUCC){
		#ifdef DEBUG	
 		printf("BSsfevaln : FAIL \n");
		#endif
	}
	else{

		ret = VLresolAlg1( bspCv1,bspExCv1,
				   bspCv2,bspExCv2,
				   BendingLine,
				   0.001,
				   cht, &loc_msg );

        	if( (ret==MSSUCC) && ( BendingLine->resolved == TRUE) ) {
			bendingLineList[nbLine] = *BendingLine;
			nbLine = nbLine + 1;
		}

		#ifdef DEBUG 
		printf("resolAlg1[%d] rc = %d \n",i,rc);
		#endif 
	
	}

 }


 minMidPar = 1.0;

 for(i=0;i<nbLine;i++) {

	midPar = fabs( ( bendingLineList[i].par1 + 
			 bendingLineList[i].par2 ) / 2.0 - 0.5);
	if(midPar<minMidPar) {
		*BendingLine = bendingLineList[i];
 		minMidPar = midPar;
	}


	#ifdef DEBUG
		printf("bendingLineList[%d] : par1 = %lf  par2 = %lf\n",
			i,bendingLineList[i].par1,bendingLineList[i].par2);
	#endif
 }

 #ifdef DEBUG
 printf("nbLine = %d\n",nbLine);
 printf("BendingLine : par1 = %lf  par2 = %lf\n",
			BendingLine->par1,BendingLine->par2);
 #endif



 if (nbLine) *msg = MSSUCC;

quit :
 /*c delete the iso two iso curves */
 if(curvesObjId)
 {
    if( curvesObjId[0] != NULL_OBJID )
    {
    	sts = om$send( msg     = message GRgraphics.GRdelete( &loc_msg, 
							       cst->env_info),
	        senderid = NULL_OBJID,
                targetid = curvesObjId[0],
	        targetos = cst->env_info->md_id.osnum );
    }

    if( curvesObjId[1] != NULL_OBJID )
    {
   	sts = om$send( msg     = message GRgraphics.GRdelete( &loc_msg, 
							      cst->env_info),
	        senderid = NULL_OBJID,
                targetid = curvesObjId[1],
	        targetos = cst->env_info->md_id.osnum );
    }
 }
 if( bspCv1   != NULL ) om$dealloc(ptr=bspCv1);
 if( bspCv2   != NULL ) om$dealloc(ptr=bspCv2);
 if( bspExCv1 != NULL ) om$dealloc(ptr=bspExCv1);
 if( bspExCv2 != NULL ) om$dealloc(ptr=bspExCv2);
 if( bspSf    != NULL ){
	if( bspSf->bdrys ) { 
		om$dealloc( ptr = bspSf->bdrys ); 
		bspSf->bdrys = NULL;
		bspSf->num_boundaries = 0; 
	}
	om$dealloc(ptr = bspSf);
	bspSf = NULL;
 }

  return *msg;
}


/*=========================================================================*/

IGRlong VLfindBendLineAlg2( SurfObj, cst, shipAxis, bendingLine,  
			     BendLineObj, msg )


/* Evaluation of the Bending line:
	The idea is to find a bending line which is planar such that the
	normal of this plane will be given by the 2 end points comming
	from the intersetion of the surface and the shipAxis at an
	average point of the surface */

struct GRobj_env	*SurfObj;	/*I the surface */
struct GRvg_construct	*cst;		/*I construction list */
IGRdouble		*shipAxis;	/*I ship axis */
struct BendingLineInfo  *bendingLine;	/*O bending line output */
struct GRobj_env	*BendLineObj;	/*O the bending line curve lying the
					    surface */
IGRlong			*msg;		/*O MSSUCC or MSfail */

{

IGRint			numNormals,i;
IGRlong			sts, numObjOut;
struct IGRbsp_surface	*bspSf;
BSrc			rc;
IGRpoint		point,normal,startPoint,endPoint;
struct GRid		*intObject;
struct GRlc_info	surfInfo;
struct IGRbsp_bdry_pts  *bdry;
IGRdouble		AverageU, AverageV;
IGRdouble		*bd_pts;
IGRint			NumPts;
IGRdouble		buff[6];
struct 	IGRpolyline	line;
struct 	GRlc_info	lineID;
OM_S_OBJID		*ObjOut;
IGRdouble		rng[6];
IGRboolean		world;
IGRdouble		length;
IGRdouble		dir[3];
IGRint			SizeGRmd_env;

	intObject = NULL;
	ObjOut	  = NULL;
	bspSf     = NULL;
	world     = FALSE;

	/*d Retrieve the surface geometry with boundaries to evaluate an
	    average point. */

	sts =  VLgetGeometry(  SurfObj, (IGRboolean)TRUE,
				(OM_S_OBJID)NULL_OBJID,(IGRchar **)&bspSf,msg);
	if( !(sts&(*msg)&1)){
		printf("Error in VLgetGeometry\n");
		goto wrapup;
	}
	#ifdef DEBUG
	printf("bspSf->num_boundaries = %d\n",bspSf->num_boundaries);
	#endif

	
	if( bspSf->num_boundaries == 0 ){ 
		/*d If the surface as no boundaryy then We take the arbitrary
		    point at parameter 0.5 0.5 of the surface. */

		AverageU = 0.5; AverageV = 0.5; 
	}
	else{
		/* Else We evaluate the COG of the first loop in parametric
		   space. */
		
		AverageU = 0.0;
		AverageV = 0.0;
		bdry   = &bspSf->bdrys[0];
		NumPts = bdry->num_points;
		for(i=0;i<NumPts;i++){
			bd_pts = &bdry->points[2*i];
			AverageU += bd_pts[0]; 
			AverageV += bd_pts[1];
		}
 
		AverageU = AverageU / NumPts;
		AverageV = AverageV / NumPts;
	}
	#ifdef DEBUG
	printf("AverageU = %f, AverageV = %f\n",AverageU,AverageV);
 	#endif

	/*d  Evaluate point and normale at the average parameters in u and v */

 	BSsfevaln(	bspSf,
			AverageU,
			AverageV,
			1,
			&numNormals,
			point,
			bendingLine->normal,
			&rc );
	
	/*d We do not need any more the Bspline surface, memory is free. */
	if( bspSf ){
		if( bspSf->bdrys ) { 
			om$dealloc( ptr = bspSf->bdrys ); 
			bspSf->bdrys = NULL;
			bspSf->num_boundaries = 0; 
		}
		om$dealloc(ptr = bspSf);
		bspSf = NULL;
	}

	/*d Now we will create a line orthogonal to the ship axis.
	    For that we need to evaluate:
		- the range of the surface.
	    	- the length of the diagonal of the box. 
		- the direction of my orthogonal length .*/

 	SizeGRmd_env = sizeof( struct GRmd_env );		

 	memcpy( (IGRchar *)&surfInfo.module_info, (IGRchar *)&SurfObj->mod_env, 
	 	SizeGRmd_env );

	surfInfo.located_obj = SurfObj->obj_id;

	sts=om$send ( msg = message GRgraphics.GRgetrang (
					msg,
					&SurfObj->mod_env.md_env.matrix_type,
					SurfObj->mod_env.md_env.matrix,
					&world,
					rng ),
	       	      senderid = NULL_OBJID, 
	    	      targetid = SurfObj->obj_id.objid,
	    	      targetos = SurfObj->obj_id.osnum);
	if( !(sts&(*msg)&1) ){
		printf("Error in GRgraphics.GRgetrang\n");
		goto wrapup;
	}
	
	length = BSdistptpt(&rc,rng,&rng[3]);
	BScrossp ( &rc, bendingLine->normal, shipAxis, dir);
	BSnorvec ( &rc, dir);

        line.num_points	= 2;
        line.points	= buff;

	for(i=0;i<3;i++){
		buff[i]   = point[i] - length * dir[i];
		buff[i+3] = point[i] + length * dir[i];
	}

	/*d perform the construction of my line */

        lineID.located_obj.objid = NULL_OBJID;
        lineID.located_obj.osnum = cst->env_info->md_id.osnum;
	 memcpy( (IGRchar *)&lineID.module_info, (IGRchar *)cst->env_info, 
		 SizeGRmd_env );

	cst->geometry	= (char*) &line;

  	sts = om$construct( classid = OPP_GR3dlinestr_class_id, 
	                    p_objid = &lineID.located_obj.objid, 
         	            osnum   = lineID.located_obj.osnum,
			    msg     = message GRgraphics.GRaltconstruct(cst) );
	cst->geometry   = NULL;
  	if ( !( sts & (*cst->msg) & 1 ) ){
		#ifdef DEBUG
		printf (" GR3dlineseg.GRaltconstruct  excurve1 : Failed\n");
		#endif
		goto wrapup;
	}

	/*d Intersection of the surface by the plane defined as follow:
		. plane containing my line.
	   	. normal of the plane orthogonal to the ship axis and
		  the direction of the line.*/

	BScrossp ( &rc, shipAxis, dir, normal );
	BSnorvec ( &rc, normal);

	#ifdef DEBUG
	printf("EMproject_curve_onto_surface 1\n");
	#endif
	numObjOut = 0;
 	sts = om$send ( msg = message EMSsubbs.EMproject_curve_onto_surface(
				 		&lineID,
 				 		&surfInfo,
				 		cst,
				 		normal,
				 		(IGRboolean) FALSE,
				 		(IGRboolean)TRUE,
				 		&numObjOut,
				 		&ObjOut,
				 		msg ),
	       	      senderid = NULL_OBJID, 
	    	      targetid = surfInfo.located_obj.objid,
	    	      targetos = surfInfo.located_obj.osnum);

  	if( !(sts & (*msg) & 1) ){
		printf("ERROR in VLfindBendLineAlg2, EMproject_curve_onto_surface\n");
		goto wrapup;
  	}
	
	if( numObjOut == 0 ){
		printf("ERROR in VLfindBendLineAlg2, EMproject_curve_onto_surface\n");
		goto wrapup;
	}

	/*d We do not need any more this line Object so we delete it */

	 sts = om$send(msg = message GRgraphics.GRdelete( msg,
							  cst->env_info ),
	       	       senderid = NULL_OBJID, 
        	       targetid = lineID.located_obj.objid,
		       targetos = lineID.located_obj.osnum );
	lineID.located_obj.objid = NULL_OBJID;


	#ifdef DEBUG
	printf("numObjOut = %d\n",numObjOut);
	#endif

	/*d From this intersection curve, we retrieve the end points
	    to evaluate the mid point of the chord . */

	if( numObjOut == 1 )
	sts=om$send ( msg = message GRcurve.GRendpts(
					msg, 
					&cst->env_info->md_env.matrix_type, 
					cst->env_info->md_env.matrix,
		        		startPoint,endPoint),
	       	      senderid = NULL_OBJID, 
		      targetid = ObjOut[0],
		      targetos = cst->env_info->md_id.osnum);
	else
	sts=om$send ( msg = message GRcurve.GRendpts(msg, 
			&cst->env_info->md_env.matrix_type, 
			cst->env_info->md_env.matrix,
		        point,endPoint),
	       	      senderid = NULL_OBJID, 
		      targetid = ObjOut[numObjOut-1],
		      targetos = cst->env_info->md_id.osnum);


	/*d Delete the intersection curves and dealloc memory. */

	for (i=0;i<numObjOut;i++)
	 sts = om$send(msg      = message GRgraphics.GRdelete( msg,
							       cst->env_info ),
	       	       senderid = NULL_OBJID, 
		       targetid = ObjOut[i],
		       targetos = cst->env_info->md_id.osnum);

 	if( ObjOut != NULL ) om$dealloc( ptr = ObjOut );
	numObjOut = 0;
	ObjOut    = NULL;


	/*d Now we are ready to evaluate our Bending line which is the
	   intesection of the surface with the plane orthogonal to
	   my previous line passing by the mid point. 


	   We evaluate the mid point and the direction of the line
	   passing thrue these end points. */

	
	point[0] = (startPoint[0] + endPoint[0]) * 0.5;
	point[1] = (startPoint[1] + endPoint[1]) * 0.5;
	point[2] = (startPoint[2] + endPoint[2]) * 0.5;
	normal[0] = startPoint[0] - endPoint[0];
	normal[1] = startPoint[1] - endPoint[1];
	normal[2] = startPoint[2] - endPoint[2];

	/*d normalise this direction vector. */
	BSnorvec ( &rc, normal);

	/*d to perform this intersection, We construct first a line
	    which will be projected on to the surface, taking into account
	    the boundaries .*/

	BScrossp ( &rc, normal, bendingLine->normal, dir);
	BSnorvec ( &rc, dir);

	for(i=0;i<3;i++){
		buff[i]   = point[i] - length * dir[i];
		buff[i+3] = point[i] + length * dir[i];
	}

	/*d Evaluate the projection vector. */
	   
	BScrossp ( &rc, normal, dir, rng );
	BSnorvec ( &rc, rng);

        lineID.located_obj.objid = NULL_OBJID;
        lineID.located_obj.osnum = cst->env_info->md_id.osnum;
	memcpy( (IGRchar *)&lineID.module_info, (IGRchar *)cst->env_info, 
		 SizeGRmd_env );

	cst->geometry	= (char*) &line;

  	sts = om$construct( classid = OPP_GR3dlinestr_class_id, 
	                    p_objid = &lineID.located_obj.objid, 
         	            osnum   = lineID.located_obj.osnum,
			    msg     = message GRgraphics.GRaltconstruct(cst) );

	cst->geometry   = NULL;

  	if ( !( sts & (*cst->msg) & 1 ) ){
		#ifdef DEBUG
		printf (" GR3dlineseg.GRaltconstruct  excurve1 : Failed\n");
		#endif
		goto wrapup;
	}

 	sts = om$send ( msg = message EMSsubbs.EMproject_curve_onto_surface(
				 		&lineID,
 				 		&surfInfo,
				 		cst,
				 		rng,
				 		(IGRboolean) FALSE,
				 		(IGRboolean)TRUE,
				 		&numObjOut,
				 		&ObjOut,
				 		msg ),
	       	      senderid = NULL_OBJID, 
	    	      targetid = surfInfo.located_obj.objid,
	    	      targetos = surfInfo.located_obj.osnum);

  	if( !(sts & (*msg) & 1) ){
		printf("ERROR in VLfindBendLineAlg2, EMproject_curve_onto_surface\n");
		goto wrapup;
  	}

	 sts = om$send(msg = message GRgraphics.GRdelete( msg, cst->env_info ),
	       	       senderid = NULL_OBJID, 
        	       targetid = lineID.located_obj.objid,
		       targetos = lineID.located_obj.osnum );
	lineID.located_obj.objid = NULL_OBJID;

	#ifdef DEBUG
	printf("numObjOut2 = %d\n",numObjOut);
	#endif

	/*d We retrieve the 2 end points of the intersection. */

	if( numObjOut == 1 )
	sts=om$send ( msg = message GRcurve.GRendpts(
					msg, 
					&cst->env_info->md_env.matrix_type, 
					cst->env_info->md_env.matrix,
		        		bendingLine->point1,
					bendingLine->point2 ),
	       	      senderid = NULL_OBJID, 
		      targetid = ObjOut[0],
		      targetos = cst->env_info->md_id.osnum);
	else
	sts=om$send ( msg = message GRcurve.GRendpts(
					msg, 
					&cst->env_info->md_env.matrix_type, 
					cst->env_info->md_env.matrix,
		        		point,
					bendingLine->point2),
	       	      senderid = NULL_OBJID, 
		      targetid = ObjOut[numObjOut-1],
		      targetos = cst->env_info->md_id.osnum);

	BendLineObj->obj_id.objid = ObjOut[0];
	BendLineObj->obj_id.osnum = cst->env_info->md_id.osnum;
	BendLineObj->mod_env      = *(cst->env_info);

 	if( ObjOut != NULL ) om$dealloc( ptr = ObjOut );
	ObjOut = NULL;

 	*msg = MSSUCC;
  	return MSSUCC;


wrapup:

 if( lineID.located_obj.objid != NULL_OBJID )
	 sts = om$send(msg = message GRgraphics.GRdelete( msg, cst->env_info ),
	       	       senderid = NULL_OBJID, 
        	       targetid = lineID.located_obj.objid,
		       targetos = lineID.located_obj.osnum );

  if (ObjOut != NULL ) {
    for (i=0;i<numObjOut;i++)
	 sts = om$send(msg = message GRgraphics.GRdelete( msg, cst->env_info ),
	       	       senderid = NULL_OBJID, 
		       targetid = ObjOut[i],
		       targetos = cst->env_info->md_id.osnum);

 	om$dealloc( ptr = ObjOut );
	ObjOut = NULL;
	numObjOut = 0;
  }

	if( bspSf ){
		if( bspSf->bdrys ) { 
			om$dealloc( ptr = bspSf->bdrys ); 
			bspSf->bdrys = NULL;
			bspSf->num_boundaries = 0; 
		}
		om$dealloc(ptr = bspSf);
		bspSf = NULL;
	}


 *msg = MSFAIL;
 return MSFAIL;

}

/*=========================================================================*/

IGRlong VLsimpleControLine( SurfObj, cst, ShipAxis, controlLine,  
			     ControlObj, msg )


	/* SimpleControLine is a function which take as input a surface
	bounded on 4 edges and a axial direction (ShipAxis).  The
	midpoints of each edge are evaluated and line between the two
	mid points closest to the required axis is returned. 
	This 1st release assumes the edges are in geometric order in the edge
	set. ********/
	
struct GRobj_env	*SurfObj;	/*I the surface */
struct GRvg_construct	*cst;		/*I construction list */
IGRdouble		*ShipAxis;	/*I ship axis */
struct BendingLineInfo  *controlLine;	/*O control line output */
struct GRobj_env	*ControlObj;	/*O the control line curve */
IGRlong			*msg;		/*O MSSUCC or MSfail */
{
struct GRid     grEdge,*list=NULL;
int             count,ii,i;
IGRlong         loc_msg,sts;
struct IGRbsp_curve *cv = NULL;
struct IGRpolyline    geom;                   
IGRvector             vec1;
IGRdouble             dotp1;                 
IGRvector             vec2;                 
IGRdouble             dotp2;               
struct  IGRbsp_surface  *sf = NULL;
IGRlong               num;
IGRpoint              point;
IGRdouble             midpar;                
IGRdouble             midpts[12];             
BSrc		      bsrc;
OMuword               point_cl,edge_cl;

  *msg = MSFAIL;
  om$get_classid ( classname = "GR3dpoint",      p_classid = &point_cl );
  ControlObj = NULL;
  sts = vs$get_surface_edges( msg         = &loc_msg,
                              sfId        = &SurfObj->obj_id,
                              sfEnv       = &SurfObj->mod_env,
                              edgeType    = VS_K_CONTOUR_EDGES,
                              edCount     = &count,
                              edList      = &list ) ;
  if( !( sts & 1 & loc_msg ) ) {
    goto quit;
  }

  if (count != 4) goto quit;

  for (ii=0; ii<count; ii++)
  {
    sts = vs$get_graphic_edge( msg    = &loc_msg,
                               edId   = &list[ii],
                               edEnv  = &SurfObj->mod_env,
                               grEdge = &grEdge) ;

    if( !( sts & 1 & loc_msg) ) {
      goto quit;
    }
    om$get_classid ( osnum     = grEdge.osnum,
                     objid     = grEdge.objid,
                     p_classid = &edge_cl ) ;

        // if an edge is a point, we prefer to use the second algorithme
    if (om$is_ancestry_valid( superclassid = point_cl,
                            subclassid   = edge_cl ) == OM_S_SUCCESS )
      goto quit;

    sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
					&(cst->env_info->md_env.matrix_type),
					cst->env_info->md_env.matrix,
                                        (IGRchar **)&cv),
                  senderid = NULL_OBJID,
                  targetid = grEdge.objid,
                  targetos = grEdge.osnum );
                   /* find mid points off opposing edges */
    if ( ii == 0 || ii == 2 )
      BScvmidpt( cv,&midpar,&midpts[(ii==0)?0:3],&bsrc);
    else
      BScvmidpt( cv,&midpar,&midpts[(ii==1)?6:9],&bsrc);

      if ( bsrc != BSSUCC ) goto quit;
    }
            /* got the mid points, now find the line between opposing edges 
               and compute alignment degree with Ship Axis*/
  vec1[0] = midpts[3] - midpts[0];
  vec1[1] = midpts[4] - midpts[1];
  vec1[2] = midpts[5] - midpts[2];
  BSnorvec( &bsrc, vec1 );
  if ( bsrc != BSSUCC ) goto quit;

  dotp1 = BSdotp( &bsrc, vec1, ShipAxis);
  if ( bsrc != BSSUCC ) goto quit;

  if ( dotp1 < 0.0 ) dotp1 = -1.0 * dotp1 ;

  vec2[0] = midpts[9] - midpts[6];
  vec2[1] = midpts[10] - midpts[7];
  vec2[2] = midpts[11] - midpts[8];
  BSnorvec( &bsrc, vec2 );
  if ( bsrc != BSSUCC ) goto quit;

  dotp2 = BSdotp( &bsrc, vec2, ShipAxis);
  if ( bsrc != BSSUCC ) goto quit;

  if ( dotp2 < 0.0 ) dotp2 = -1.0 * dotp2 ;
    geom.num_points = 2;
  if (dotp2<dotp1) {    /* 1st line has better alignment */
        geom.points = &midpts[0];
  }
  else {
        geom.points = &midpts[6];
  }
                /* only need closest (aligned) to axis */
  cst->geometry = (char *)&geom;
  for (i=0; i< 3; i++ ) {
        controlLine->point1[i] =   geom.points[i];
        controlLine->point2[i] =   geom.points[i+3];
  }
  midpts[0] = (controlLine->point1[0] + controlLine->point2[0])/2.;
  midpts[1] = (controlLine->point1[1] + controlLine->point2[1])/2.;
  midpts[2] = (controlLine->point1[2] + controlLine->point2[2])/2.;
  sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                    &SurfObj->mod_env.md_env.matrix_type,
                                    SurfObj->mod_env.md_env.matrix,
                                   (IGRchar **)&sf),
                  senderid = NULL_OBJID,
                  targetid = SurfObj->obj_id.objid,
                  targetos = SurfObj->obj_id.osnum );
  if (!(loc_msg&sts&1)) {
    goto quit;
  }
  BSptnorsf( sf, midpts , &i ,
                   &dotp1, &dotp2 ,
                   &midpts[3] , &midpar , &bsrc ) ;
  if (bsrc != BSSUCC) goto quit;
  BSsfevaln(sf,dotp1,dotp2,1,&num,point,controlLine->normal,&bsrc);
  if (bsrc != BSSUCC) {
    goto quit;
  }
   
  *msg = MSSUCC;
  quit :
    return 1;
}
/*==========================================================================*/

IGRlong VLdrawBendLine( SrfObj, bendingLine, BendCrv, cst, symbology, 
			 BendObj, NumBendObj, msg )

struct	GRobj_env	*SrfObj;	/*I the surface on which we project
					    the line */
struct  BendingLineInfo	*bendingLine;   /*I data structure which contains
					    the definition of the line */
struct	GRobj_env	*BendCrv;	/*I NULL if no curve input else
					    We will use that one to create
					    an assoc element */
struct  GRvg_construct	*cst;		/*I construction list */
struct  GRsymbology     *symbology;	/*I to be able to overide the 
					    active symbology */
struct  GRid		*BendObj;	/*O the bending lines */
	IGRint		*NumBendObj;	/*O number of bending lines generated */
IGRlong			*msg;		/*O return code MSSUCC or MSSFAIL */
{
struct	GRobj_env	lineID;
struct 	IGRpolyline	line;
struct 	GRobj_env	locatedSurf;
	IGRlong		sts, sts1, msg1;
	IGRlong		NumProjCrvs;
	IGRdouble	buff[6];
	IGRboolean	CrvAlreadyProj;

if( BendCrv == NULL ){

        line.num_points	= 2;
        line.points	= buff;
	buff[0] 	= bendingLine->point1[0];
	buff[1] 	= bendingLine->point1[1];
	buff[2] 	= bendingLine->point1[2];
	buff[3] 	= bendingLine->point2[0];
	buff[4] 	= bendingLine->point2[1];
	buff[5] 	= bendingLine->point2[2];

        lineID.obj_id.objid	= NULL_OBJID;
        lineID.obj_id.osnum 	= cst->env_info->md_id.osnum;
	lineID.mod_env          = *(cst->env_info);

	cst->geometry	= (char*) &line;

  	sts = om$construct( classid = OPP_GR3dlinestr_class_id, 
	                    p_objid = &lineID.obj_id.objid, 
         	            osnum   = lineID.obj_id.osnum,
			    msg     = message GRgraphics.GRaltconstruct(cst) );

	cst->geometry   = NULL;

  	if ( !( sts & (*cst->msg) & 1 ) ){
		*NumBendObj = 0;
		*msg = MSFAIL;
		return(MSFAIL);
	}
	else {

		locatedSurf.obj_id = SrfObj->obj_id;
		locatedSurf.mod_env = SrfObj->mod_env;
		cst->geometry  = NULL;
		CrvAlreadyProj = FALSE;
	}
}
else{
	locatedSurf.obj_id = SrfObj->obj_id;
	locatedSurf.mod_env = SrfObj->mod_env;
        if (
            (vs$is_ancestry_valid( object   = &(SrfObj->obj_id),
                                   classid = OPP_EMScone_class_id )
                       == TRUE) ||
            (vs$is_ancestry_valid( object   = &(SrfObj->obj_id),
                                   classid = OPP_EMScylindr_class_id )
                       == TRUE)
           ) 
           CrvAlreadyProj = TRUE;
         else CrvAlreadyProj = FALSE;
	 lineID = *BendCrv;
}

sts =  VLcurveOnSfByVec( &locatedSurf, 
			  &lineID,
	//		  buff,
		          bendingLine->normal,
			  cst,
			  CrvAlreadyProj, 
			  (IGRboolean) FALSE,
			  (IGRboolean) TRUE,
			  (IGRboolean) FALSE,
			  symbology,
			  &NumProjCrvs,
			  BendObj,
			  msg);

if( lineID.obj_id.objid ! = BendObj->objid )
{
sts1 = om$send( msg      = message GRgraphics.GRdelete( &msg1, cst->env_info),
		senderid = NULL_OBJID,
                targetid = lineID.obj_id.objid,
		targetos = lineID.obj_id.osnum  );
}

if( !(sts&(*msg)&1) ){
	*NumBendObj = 0;
	*msg = MSFAIL;
	return(MSFAIL);
}
else{
	*NumBendObj = (IGRint) NumProjCrvs;
	*msg = MSSUCC;
	return(MSSUCC);
}
}

/*==========================================================================*/
IGRlong VLcnstOneFib (

struct	IGRbsp_curve	*isoCrv,	/*I neutral fiber axis                */
struct	IGRbsp_curve	*CvSol,		/*O the bs bending curve after 
					    unwrap. this curve should be
					    malloc by the caller according
					    nPtSol                            */
	IGRdouble	*norRef,	/*I normal to the plane containing the
					    stiffner axis                     */
	IGRdouble	*org,		/*I origin where we will create the
					    unwraped element                  */
	IGRdouble	*xAxis,		/*I X axis of the coordinate system   */
	IGRdouble	*yAxis,		/*I Y axis of the coordinate system   */
	IGRdouble	yOffset,	/*I offset along the Y axis           */

	IGRdouble	*paPtSol,	/*I the array containing the start,
					    end parameters and the end points
					    of the straight line before 
					    unwraping.                        */
					    
	IGRint		nPtSol,		/*I number of points that should be
					    evaluated along the straight line */
struct  GRvg_construct	*cst,		/*I the cst                           */
	IGRboolean	displayWanted,  /*I flag if you want to display or not
					    the resulting curve               */
        IGRdouble       *dot,           /*I information to resolve orientaion
                                            problem */
	IGRdouble	*xAbs,		/*O variable use to avoid to recompute
					    the total lenght of the neutral
					    fiber                             */
struct	GRid		*CrvObj,	/*O the linestring solution           */
	IGRlong		*msg		/*O return code MSSUCC, MSFAIL        */
)

/*d this function evaluates the inverse stiffner bending line, giving his
    a straight line and the iso-curve at parameter 0.5 which can be 
    concidered as the neutral fiber axis of the stiffner */ 

{
extern  void		BSxlnpl();
extern	IGRboolean	BSarclength();
extern  IGRdouble	BSdotp();



	IGRint 		i, j;
	IGRdouble	t, u, v;
	IGRdouble       d, ptdv[6], dirPos[3], yAbs, vdif[3];
struct	IGRpolyline	geom;
	IGRint		stat;
	IGRpoint	ptint;

  	IGRint		size_buf;
  	IGRdouble	yy,SavedArcTol, ArcTol;

	d = nPtSol - 1;
	u = 0.0;


	size_buf = sizeof(ArcTol);
	gr$get_arclength_tolerance(	msg = msg,
        	                        sizbuf = &size_buf,
                	                buffer = &SavedArcTol,
                        	        nret = &size_buf);


	ArcTol = SavedArcTol / 20;
	gr$put_arclength_tolerance(	msg = msg,
        	                        sizbuf = &size_buf,
                	                buffer = &ArcTol);
 
	#ifdef DEBUG
	printf("ArcTol = %f\n",ArcTol);
	printf("---> nPtSol = &d, paPtSol = %f,%f\n",
		nPtSol,paPtSol[0],paPtSol[1]);
	#endif

	for(i=0;i<nPtSol;i++){
		
		t = (IGRdouble) i / d; 
		v = (1.0 - t) *  paPtSol[0] + t * paPtSol[1];
		BScveval( isoCrv, v, 1, ptdv, (BSrc *) msg );
		BSnorvec( (BSrc *) msg, &ptdv[3]);

		BSxlnpl( (BSrc *) msg, &ptdv[3], ptdv, 
		&paPtSol[2], &paPtSol[5], ptint );
		if( *msg != BSSUCC ) printf("error in BSxlnpl\n");

		for(j=0;j<3;j++) vdif[j] = ptint[j] - ptdv[j];

		#ifdef DEBUG
		printf(" %d th point v = %f\n",i,v);
		printf("ptdv = %f,%f,%f\n",ptdv[0],ptdv[1],ptdv[2]);
		printf("ptint = %f,%f,%f\n",ptint[0],ptint[1],ptint[2]);
		printf("vdif = %f,%f,%f\n",vdif[0],vdif[1],vdif[2]);
		#endif

		BScrossp( msg, norRef, &ptdv[3], dirPos );
		if( *msg != BSSUCC ) printf("error in BScrossp\n");

		yAbs = BSdotp( msg, vdif, dirPos );

                if (*dot < 0) {
                		/* the orientation surface is up to down,
                   		we should inverse yAbs's sign */
                  yAbs = -yAbs;
                }
		/* eval the curvilign abscissia */

		BSarclength( msg, isoCrv, &u, &v, xAbs );
		if( *msg != BSSUCC ) printf("error in BSarclength\n");
		
		#ifdef DEBUG
		printf("xAbs = %f, yAbs = %f \n",(*xAbs),yAbs);
		#endif

                yy = yOffset + yAbs;

                if (*dot <= 0.) {
                		/* the orientation surface is up to down,
                                   we make the graphic in the negative
                                   zone to avoid orientaion problems */
                    for(j=0;j<3;j++)
                    CvSol->poles[3*i + j] = org[j] - (*xAbs) * xAxis[j] +
                                            yy * yAxis[j];
                    for(j=0;j<3;j++)
                    CvSol->poles[3*i + j] = org[j] - (*xAbs) * xAxis[j] +
                                            yy * yAxis[j];
                }
                else {
                    for(j=0;j<3;j++)
                    CvSol->poles[3*i + j] = org[j] + (*xAbs) * xAxis[j] +
                                            yy * yAxis[j];
                    for(j=0;j<3;j++)
                    CvSol->poles[3*i + j] = org[j] + (*xAbs) * xAxis[j] +
                                            yy * yAxis[j];
                 }
	}


	gr$put_arclength_tolerance(	msg = msg,
        	                        sizbuf = &size_buf,
                	                buffer = &SavedArcTol);

	geom.num_points = nPtSol;
	geom.points	= CvSol->poles;
	cst->geometry = (char *)&geom;	

	CrvObj->objid = NULL_OBJID;
	CrvObj->osnum = cst->env_info->md_id.osnum; 



  	stat = om$construct( classid = OPP_GR3dlinestr_class_id, 
	                     p_objid = &CrvObj->objid, 
         	             osnum   = CrvObj->osnum,
			     msg     = message GRgraphics.GRaltconstruct(cst) );

	cst->geometry   = NULL;

	if( !(stat&1) ) {
		
		printf("error in VLcnstOneFib\n");
		printf("GRgraphics.GRaltconstruct FAILED\n");
		*msg = MSFAIL;
		return(MSFAIL);
	}
	else{
		 *msg = MSSUCC;
		
		if( displayWanted == TRUE )	
		gr$display_object( object_id = (struct GRid *) CrvObj, 
			   	   mode      =  GRbd	);
		return(MSSUCC);
	}

}
/*==========================================================================*/

end implementation Root;
