/*----
%HD%

 
     MODULE NAME POcircnvfit
 
     Abstract:
        This function evaluates two contiguious and tangent arcs knowing
	two points and two tangent conditions.
-----
%SC%

   POcircnvfit( bsp_crv,  A, VA, B, VB, tol, mat,                  
                I      ,  I, I , I, I , I  , I		

                arc1 , arc2, ecmax, umax, arclen_min, rc ) 
                O    , O   , O    , O   , O	    , O  

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *bsp_crv   IGRbsp_curve  originale curve to find the maximun deviarion
        *A         IGRdouble     first interpoltion point
	*VA	   IGRdouble	 first tangent
	*B         IGRdouble	 end interpolation point
	*VB        IGRdouble	 end tangent
	tol	   IGRdouble	 accuracy requested;
	*mat       IGRdouble     transformation matrix to do the evaluation
				 in 2d
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

	*arc1	   struct geomStruct  first elem solution;
	*arc2	   struct geomStruct  second elem solution;
	*ecmax     IGRdouble          the maximun deviation
	*umax	   IGRdouble	      the parameter on the bspcurve 
				      where we get the maximun deviation
	*arclen_min IGRdouble         the length of the smallest arc	
        *rc        BSrc               completion code message

				      - return code with BSSUCC
				       rc=0 a line should be created	
                                       rc=1 only one arc created       
				       rc=2 two elem created            

				      - return code with BSFAIL
				       rc=3 end points coincident       
				       rc=4 first derivate null         
				       rc=5 second derivate null        
				       rc=6 we get an infexion          
				       rc=7 root of rac2 are'nt valid   
				       rc=8 common point not within tol 
				       rc=9 first arc not in tol        
				       rc=10 second arc not in tol      
-----
%MD%

     MODULES INVOKED: BSlenvec, BSdotp, fabs, sqrt, BSmdstptcv, BSnorvec,
		      POrac2, POcstarcstr, BSxln  
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : april 88 Creation date.
	JLL    : november 93 review code.
	      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


#include <stdio.h>
#include "v_.h"
#include "madef.h"
#include "ma.h"
#include "msdef.h"
#include "igr.h"
#include "igrdef.h"
#include "bserr.h"
#include "bsvalues.h"
#include "vdloft.h"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                                          */
/*               compute the circular interpolation                         */
/*                                                                          */
IGRlong    POcircnvfit( bsp_crv,  A, VA, B, VB, tol, mat,                  
/*                      I      ,  I, I , I, I , I  , I	  		    */
/*									    */
           	        arc1 , arc2, ecmax, umax, arclen_min, rc ) 
/*         	        O    , O   , O    , O   , O	    , O  	    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct IGRbsp_curve     *bsp_crv;   /* the curve 			*/
IGRdouble  		*A, 	    /* start interpolation point	*/
			*VA,        /* start tangent			*/
			*B,	    /* end interpolation point 		*/
                        *VB;        /* end tangent			*/
				    /*   contains the curve		*/
IGRdouble		tol;        /* approximation tol	        */
IGRdouble		*mat;       /* local basis			*/
struct geomStruct	*arc1;      /* firs arc solution                */
struct geomStruct	*arc2;      /* second arc solution		*/
IGRdouble		*ecmax;     /* maximum distance			*/
IGRdouble               *umax;      /* parametre dist max               */
IGRdouble               *arclen_min;/* minimun arc length               */

BSrc			*rc;	    /* return code with BSSUCC		*/
				    /* rc=0 a line should be created	*/
                                    /* rc=1 only one arc created        */
				    /* rc=2 two elem created            */

				    /* return code with BSFAIL          */
				    /* rc=3 end points coincident       */
				    /* rc=4 first derivate null         */
				    /* rc=5 second derivate null        */
				    /* rc=6 we get an infexion          */
				    /* rc=7 root of rac2 are'nt valid   */
				    /* rc=8 common point not within tol */
				    /* rc=9 first arc not in tol        */
				    /* rc=10 second arc not in tol      */

{


#define EPSILON 1.0E-12
#define MINANGL 0.00174
	

	IGRint		i,j,k,l;
	IGRlong		irc, ircs;
	IGRdouble	a;
	IGRdouble	b;
	IGRdouble	c;
	IGRdouble	ro;
	IGRdouble	AB[3]; 	  /* vector AB = B - A 			    */
	IGRdouble	ABVB[3];
	IGRdouble	ABVA[3];
	IGRdouble	NORVA[3]; /* normalized vector of VA		    */
	IGRdouble	NORVB[3]; /* normalized vector of VB		    */
	IGRdouble	NVA[3];
	IGRdouble	NVB[3];
	IGRdouble	NAB[3];
	IGRdouble	pt1[3];
	IGRdouble	pt2[3];
	IGRdouble	AA[3];
	IGRdouble	BB[3];
	IGRdouble	PTC[3];
	IGRdouble	C1[3];
	IGRdouble	C2[3];
	IGRdouble	BASE[3];
	IGRdouble	ZAB[3];
	IGRdouble	ZVA[3];
	IGRdouble	ZVB[3];
	IGRdouble	VBASE[3];
	IGRdouble	l_va;
	IGRdouble	l_vb;
	IGRdouble	l_ab;
	IGRdouble	delta1;
	IGRdouble	dot_abab;
	IGRdouble	dot_vavb;
	IGRdouble	dot_vaab;
	IGRdouble	dot_vbab;
	IGRdouble	eccou0;
	IGRdouble	eccou1;
	IGRdouble	eccou2;
	IGRdouble	eccou00;
	IGRdouble	eccou10;
	IGRdouble	eccou20;
	IGRdouble	eccou30;
	IGRdouble	arclen_cou1;
	IGRdouble	arclen_cou2;
	IGRdouble	lineTol;	

extern IGRdouble	BSlenvec();
extern IGRdouble	BSdotp();
extern IGRdouble	fabs();
extern IGRdouble	sqrt();
extern void		BSmdstptcv();
extern IGRdouble	BSdistptpts();
extern IGRboolean       BSnorvec();
extern			POrac2();
extern			POcstarcstr();
extern			BSxln();
extern IGRlong		POchkArcIsLn();
extern IGRdouble	BSdistptpt();


/*--------------------------- begenning of code ---------------------------*/


	lineTol    = 0.5 * tol;
	arc1->type = geomNull;
	arc2->type = geomNull;
	*rc = 2;
        *ecmax = -1.0;

	for(i=0;i<3;i++){
		AB[i] = B[i] - A[i];
		NORVA[i] = VA[i];
		NORVB[i] = VB[i];
	}

	/*--- test if point A and point B are coincident ---*/

	dot_abab = BSdotp(&irc,AB,AB);
	if( dot_abab < EPSILON ){
		/* printf("points are coincident\n"); */
		*rc = 3;
		return BSFAIL;
	}

	/*--- test if derivate in A is NULL ---*/	
	if( BSdotp(&irc,NORVA,NORVA) < EPSILON ){
		/* printf("derivate in A is NULL\n"); */
		*rc = 4;
		return BSFAIL;
	}

	/*--- test if derivate in B is NULL ---*/
	
	if( BSdotp(&irc,NORVB,NORVB) < EPSILON ){
		/* printf("derivate in B is NULL\n"); */
		*rc = 5;
		return BSFAIL;
	}


        BSnorvec(&irc,NORVA);
	BScrossp(&irc,AB,NORVA,ABVA);
        BSnorvec(&irc,NORVB);
	BScrossp(&irc,AB,NORVB,ABVB);


	/*--- test if we get an inflexion ---*/
		
        l_ab     = sqrt(dot_abab);
	dot_vaab = BSdotp(&irc,ABVA,ABVB);
	if( dot_vaab > EPSILON ){
		/* we realy get an inflexion, exit with error */
		/* printf("we realy get an inflexion\n"); */
	  	*rc = 6;
          	return BSFAIL;
        }

	/*
	printf("NORVA=%f,%f,%f\n",NORVA[0],NORVA[1],NORVA[2]);		
	printf("NORVB=%f,%f,%f\n",NORVB[0],NORVB[1],NORVB[2]);		
	*/

	/*--- first check if curves are colinear ---*/

	for (i=0; i<3; i++){
         	pt1[i] = A[i] + 100.0 * NORVA[i];
         	pt2[i] = B[i] + 100.0 * NORVB[i];
        }

        BSxln(&irc,A,pt1,B,pt2,C1);
	if( irc != BSSUCC ){
		if( irc == BSPARALLEL ) goto testVAcolAB;

	  	if( l_ab < *arclen_min ) *arclen_min  = l_ab;
		eccou0 = 0.0;
        	if( eccou0 > *ecmax ) *ecmax = eccou0;
		arc1->type = geomLine;
		for (i=0; i<3; i++){
         		arc1->uGeom.Line[i]   = A[i];
         		arc1->uGeom.Line[i+3] = B[i];
        	}
		*rc = 0;
		return BSSUCC;			
	}

        /*--- check if the minimum distance between the intersection and
	      the chord is < to 2*tol.
	      this test is perform if A and B are not the start and end
	      point of bsp_crv ---*/

	if( ( BSdistptpts( &irc, A, bsp_crv->poles ) > EPSILON ) ||
	    ( BSdistptpts( &irc, B, &(bsp_crv->poles[3*(bsp_crv->num_poles-1)]))
	     > EPSILON ) ){

		for (i=0; i<3; i++) pt1[i] = C1[i] - A[i];
		pt2[0] = BSdotp(&irc,pt1,AB);	
		pt2[0] = pt2[0] /  dot_abab;
		pt2[1] = 0.0;
		for (i=0; i<3; i++){
			 pt1[0] = C1[i] - ( A[i] + pt2[0] * AB[i] );
			 pt2[1] = pt2[1] + pt1[0] * pt1[0];
		}
		pt2[1] = sqrt(pt2[1]);

		if( (pt2[0] < EPSILON) || (pt2[0] > 1.0) ){
	  		*rc = 6;
          		return BSFAIL;
		}	


		if( pt2[1] < 2.0 * tol ){
	  		if( l_ab < *arclen_min ) *arclen_min  = l_ab;
			eccou0 = 0.0;
        		if( eccou0 > *ecmax ) *ecmax = eccou0;
			arc1->type = geomLine;
			for (i=0; i<3; i++){
         			arc1->uGeom.Line[i]   = A[i];
         			arc1->uGeom.Line[i+3] = B[i];
        		}
			*rc = 0;
			return BSSUCC;			
		}
	}

testVAcolAB:
        
	/*--- test if VA is colinear with AB ---*/

	pt2[0] = ( BSlenvec(&irc,ABVA) ) /l_ab;
	if( pt2[0] < MINANGL ){
		/* printf("VA is colinear with AB\n"); */
	  	*rc = 6;
          	return BSFAIL;
	}	

	/*--- test if VB is colinear with AB ---*/

	pt2[0] = ( BSlenvec(&irc,ABVB) ) /l_ab;
	if( pt2[0] < MINANGL ){
		/* printf("VB is colinear with AB\n"); */
	  	*rc = 6;
          	return BSFAIL;
	}	
	

   
        dot_vavb = BSdotp(&irc,NORVA,NORVB);
	dot_vaab = BSdotp(&irc,NORVA,AB);
        dot_vbab = BSdotp(&irc,NORVB,AB);

	a = fabs(mat[8])-1.0;
	if( fabs(a) > EPSILON ){


		/*--- apply transformation in non top case ---*/


		for(j=0;j<2;j++){
			k = 3 * j;
	        	ZAB[j] = 0.0;
			ZVA[j] = 0.0;
			ZVB[j] = 0.0;
			for(i=0;i<3;i++){
				l = k + i;
				ZAB[j] = ZAB[j] + mat[l] * AB[i];
				ZVA[j] = ZVA[j] + mat[l] * NORVA[i];
				ZVB[j] = ZVB[j] + mat[l] * NORVB[i];
			}
		}

		/*
		printf("ZAB=%f,%f,%f\n",ZAB[0],ZAB[1],ZAB[2]);
		printf("ZVA=%f,%f,%f\n",ZVA[0],ZVA[1],ZVA[2]);
		printf("ZVB=%f,%f,%f\n",ZVB[0],ZVB[1],ZVB[2]);
		*/
	
		delta1 = ((ZAB[0]*ZVA[1])-(ZAB[1]*ZVA[0])) /
			 ((ZVB[0]*ZAB[1])-(ZVB[1]*ZAB[0]));

	}
	else{

		/*--- top case no transformation needed ---*/

		delta1 = ((AB[0]*NORVA[1])-(AB[1]*NORVA[0])) /
			 ((NORVB[0]*AB[1])-(NORVB[1]*AB[0]));
	}


	/*--- build the coeff of the trinome ---*/



        a = (dot_vavb - 1.0) * delta1;
        b = -1.0 * (dot_vaab + dot_vbab * delta1);
        c = dot_abab / 2.0;

	POrac2(a, b , c, 0 , &ro, &irc );
	if( irc != BSSUCC ){
	  	*rc = 7;
          	return BSFAIL;
        }



	/*--- compute the common point and test if in tol ---*/


        BScrossp(&irc,AB,ABVA,NAB);
        BSnorvec(&irc,NAB);

	if( BSdotp(&irc,NORVA,NAB) > 0.0 )
	  			for (i=0; i<3; i++) NAB[i] = -1.0 * NAB[i];

	for (i=0; i<3; i++){
         	pt1[i] = A[i] + ro * ( NORVA[i] + AB[i] / l_ab );
         	pt2[i] = pt1[i] + ro * NAB[i];
        }

        if( bsp_crv ){
		BSmdstptcv( bsp_crv,pt1,umax,BASE,&eccou0,&irc );
        	if( ( eccou0 - tol )  > EPSILON ){
	  		*rc = 8;
	  		return BSFAIL;
        	}
	}       



	/*---  compute the left arc center ---*/

        BScrossp(&irc,NORVA,ABVA,NVA);
        BScrossp(&irc,NORVB,ABVA,NVB);

	for(i=0; i<3; i++){
          AA[i] = A[i] + ro * NVA[i];
	  BB[i] = B[i] + ro * NVB[i];
        }

        BSxln(&irc,A,AA,pt1,pt2,C1);
	
	for(i=0; i<3; i++){
          AA[i] = A[i] - C1[i];
          PTC[i] = pt1[i] - C1[i];
        }

	l_va = BSlenvec(&irc,AA);
	POcstarcstr(C1,PTC,AA,l_va,&(arc1->uGeom.Arc),&arclen_cou1,&irc);
	arc1->type = geomArc;
	ircs = POchkArcIsLn(arc1,A,pt1,bsp_crv,lineTol,&eccou10,&irc);

	if( ircs == BSFAIL ){

		for(i=0; i<3; i++)  NORVA[i] = AA[i] + PTC[i];
		l_vb = BSlenvec(&irc,NORVA);
		for(i=0; i<3; i++) NORVA[i] = C1[i] + l_va * NORVA[i] / l_vb;

        	if( bsp_crv ){

        		BSmdstptcv( bsp_crv,NORVA,umax,ZVA,&eccou1,&irc );

        		if( ( eccou1 - tol ) > EPSILON ){
	  			*rc = 9;
	  			return BSFAIL;
        		}
		}

	}
	else	 eccou1 = eccou10;

	/*---  compute the right arc center ---*/

        BSxln(&irc,B,BB,pt1,pt2,C2); 

	for(i=0; i<3; i++){
          PTC[i] = pt1[i] - C2[i];
	  VBASE[i]  = B[i] - C2[i];
        }


	l_va = BSlenvec(&irc,PTC);

 	POcstarcstr(C2,VBASE,PTC,l_va,&(arc2->uGeom.Arc),&arclen_cou2,&irc);
	arc2->type = geomArc;

	for(i=0; i<3; i++)  NORVB[i] = VBASE[i] + PTC[i];
	l_vb = BSlenvec(&irc,NORVB);
	for(i=0; i<3; i++) NORVB[i] = C2[i] + l_va * NORVB[i] / l_vb;

	if( bsp_crv ){

        	BSmdstptcv( bsp_crv,NORVB,umax,ZVB,&eccou20,&irc );
        	if(  (eccou20 - tol)  > EPSILON ){
	  		*rc = 10;
	  		return BSFAIL;
        	}

		ircs = POchkArcIsLn(arc2,pt1,B,bsp_crv,lineTol,&eccou2,&irc);
		if( ircs == BSFAIL ) eccou2 = eccou20;

		/*--- check if we can replace the two arcs by only one ---*/
		/*--- evaluate the mediatrice of [AB] ---*/

		for (i=0; i<3; i++){
        		pt1[i] = ( A[i] + B[i] ) * 0.5;
        		pt2[i] = pt1[i] + ro * NAB[i];
        	}
	
        	BSxln(&irc,A,C1,pt1,pt2,AA);
        	BSxln(&irc,B,C2,pt1,pt2,BB);
 
		for(i=0; i<3; i++){
			C1[i] = ( AA[i] + BB[i] ) * 0.5;
          		AA[i] = A[i] - C1[i];
         		BB[i] = B[i] - C1[i];
        	}
		
		/*--- evaluate new radius of curvature ---*/
		ro = BSlenvec(&irc,AA);

		/*--- before to construct the single arc check if in tol ---*/
		/*--- check if the BASE point is in tol ---*/

	        eccou00 = BSdistptpt(&irc,BASE,C1) - ro;
		eccou00 = fabs(eccou00);
        	if(  (eccou00 - tol)  > EPSILON ) goto deuxarcs;

		/*--- check if the ZVA base point is in tol ---*/

	        eccou10 = BSdistptpt(&irc,ZVA,C1) - ro;
		eccou10 = fabs(eccou10);
        	if(  (eccou10 - tol)  > EPSILON ) goto deuxarcs;

		/*--- check if the ZVB base point is in tol ---*/

	        eccou20 = BSdistptpt(&irc,ZVB,C1) - ro;
		eccou20 = fabs(eccou20);
        	if(  (eccou20 - tol)  > EPSILON )goto deuxarcs;

		
		/*--- construct the new arc ---*/

		POcstarcstr(C1,AA,BB,ro,&(arc1->uGeom.Arc),&arclen_cou1,&irc);
		arc1->type = geomArc;
		ircs = POchkArcIsLn(arc1,A,B,bsp_crv,lineTol,&eccou30,&irc);
		if( (ircs == BSSUCC) && ( eccou30 > *ecmax ) )*ecmax = eccou30; 
        	if( eccou00 > *ecmax ) *ecmax = eccou00;
        	if( eccou10 > *ecmax ) *ecmax = eccou10;
        	if( eccou20 > *ecmax ) *ecmax = eccou20;
		if( arclen_cou1 < *arclen_min ) *arclen_min = arclen_cou1;

		if( arc1->type == geomArc ) *rc = 1;
		else			    *rc = 0;

		return BSSUCC;

	   }


deuxarcs:

        if( eccou0 > *ecmax ) *ecmax = eccou0;
        if( eccou1 > *ecmax ) *ecmax = eccou1;
        if( eccou2 > *ecmax ) *ecmax = eccou2;
	if( arclen_cou1 < *arclen_min ) *arclen_min = arclen_cou1;
	if( arclen_cou2 < *arclen_min ) *arclen_min = arclen_cou2;

        *rc = 2;
	return BSSUCC;

}

