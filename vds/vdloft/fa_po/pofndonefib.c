/*----
%HD%
 
     MODULE NAME POfndOneFib
 
     Abstract:
        This function evaluates a piece of control bending line for
	a stifner.
	
-----
%SC%

     POfndOneFib( cv1, cv2, midCv, norCvs, par1, par2, parSol, intPts, u, a, b, 
	          rc )


-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *sf        IGRbsp_surface   the input surface  
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *rc        BSrc         completion code message
                                 - BSSUCC or BSFAIL
  
-----
%MD%

     MODULES INVOKED: none
-----
%NB%

     NOTES:

-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 5 mai 1993,  Creation date.
	JLL    : 21 jul 1994, Put in comments the intersection between
		 the plane and the neutral fiber, to avoid overlapp 
		 situations.       
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include "v_.h"
#include "bs.h"
#include "madef.h"
#include "ma.h"
#include "bserr.h"
#include "bstypes.h"

POfndOneFib( cv1, cv2, midCv, norCvs, par1, par2, parSol, ptsSol, intPts, 
	     u, a, b, rc )

struct	IGRbsp_curve	*cv1;
struct	IGRbsp_curve	*cv2;
struct	IGRbsp_curve	*midCv;
IGRdouble		*norCvs;
IGRdouble		par1;
IGRdouble		par2;
IGRdouble		*parSol;
IGRdouble		*ptsSol;
IGRdouble		*intPts;
IGRdouble		*u;
IGRdouble		*a;
IGRdouble		*b;
IGRlong			*rc;

{

extern IGRboolean	BSnorvec();
extern void		BScveval();
extern IGRboolean	BScrossp();
extern IGRboolean 	BSpl_cv_int();
extern IGRdouble	fabs();
extern IGRint 		BSmdstptcv();
IGRboolean 		POisSpanValid();
IGRint		i;
IGRdouble       u1, u2;
IGRdouble	p1[3],  vdir[3], norPlan[3], MinDist, pt12[6];
IGRint		n_intCv1, n_intCv2, n_seg;
IGRboolean	isValid;
IGRdouble	uSE[2];
IGRint		iSE[2];

	/*
	printf("------- enter u1 = %f, u2 = %f\n",par1,par2);
	*/

	uSE[0] = 0.0;
	uSE[1] = 1.0;
	iSE[0] = -1;
	iSE[1] = -1;

	u1 = par1;
	u2 = par2;


	BScveval( midCv, u1, 0, pt12, rc );
	BScveval( midCv, u2, 0, &pt12[3], rc );

	for(i=0;i<3; i++ ) vdir[i] = pt12[3+i] - pt12[i];

	BScrossp( rc, norCvs, vdir, norPlan );
	BSnorvec( rc, norPlan );

        BSpl_cv_int(rc, cv1, pt12, norPlan, &n_intCv1,intPts, u, &n_seg, a, b);
	
	/*
	printf("n_int sur cv1 = %d\n",n_intCv1);
	for(i=0;i<n_intCv1;i++)printf("u_cv1[%d]=%f\n",i,u[i]);
	*/

	isValid =  POisSpanValid( n_intCv1, intPts, pt12, vdir, 
				  ptsSol, uSE, iSE, rc );
	/*
	printf("for CV1 isValid = %d, rc = %d\n",isValid,*rc);
	*/

	if( (*rc == BSSUCC) && (isValid == TRUE) ){
        	BSpl_cv_int( rc, cv2, pt12, norPlan, &n_intCv2,intPts, 
			     u, &n_seg, a, b);
		/*
		printf("n_int sur cv2 = %d\n",n_intCv2);
		for(i=0;i<n_intCv2;i++)printf("u_cv2[%d]=%f\n",i,u[i]);
		*/

		isValid =  POisSpanValid( n_intCv2, intPts, pt12, vdir, 
				  	  ptsSol, uSE, iSE, rc );
		/*
		printf("for CV1 isValid = %d, rc = %d\n",isValid,*rc);
		*/

		if( (*rc == BSSUCC) && (isValid == TRUE) )goto wrapup;
		else{
			u2 = 0.25*u1 + 0.75*u2;

			POfndOneFib( cv1, cv2, midCv, norCvs, u1, u2, 
			     parSol, ptsSol, intPts, u, a, b, rc );
			return;
		}
	}
	else{
		u2 = 0.25*u1 + 0.75*u2;

		POfndOneFib( cv1, cv2, midCv, norCvs, u1, u2, 
			     parSol, ptsSol, intPts, u, a, b, rc );
		return;
	}	



wrapup:

	BSmdstptcv ( midCv, ptsSol, parSol, p1, &MinDist ,rc);
	BSmdstptcv ( midCv, &ptsSol[3], &parSol[1], p1, &MinDist ,rc);

	return;


}

/*-------------------------------------------------------------------------*/

POevParOnLn( org, vdir, ptPj, uPtPj, rc )
IGRdouble	*org;
IGRdouble	*vdir;
IGRdouble	*ptPj;
IGRdouble	*uPtPj;
IGRlong		*rc;

{


IGRint i;
IGRdouble	v1, v2, v1v1, v1v2;


v1v1 = 0.0;
v1v2 = 0.0;

for(i=0;i<3;i++){
	v1 = vdir[i];
	v2 = ptPj[i] - org[i];
	v1v1 = v1v1 + v1 * v1;
	v1v2 = v1v2 + v1 * v2;
}

if( v1v1 > 0.0 ){
	*uPtPj = v1v2 / v1v1;
	*rc = BSSUCC;
}
else *rc = BSFAIL;

/*
printf(" POevParOnLn uPtPj = %f\n", (*uPtPj));
*/

}
/*-------------------------------------------------------------------------*/
IGRboolean POisSpanValid( nPts, pts, pt12, vdir, ptSE, uSE, iSE, rc )
IGRint		nPts;
IGRdouble	*pts;
IGRdouble	*pt12;
IGRdouble	*vdir;
IGRdouble	*ptSE;
IGRdouble	*uSE;
IGRint		*iSE;
IGRlong		*rc;

{

IGRint		i;
IGRdouble	u;
IGRdouble	uSES[2];
IGRint		iSES[2];

iSES[0] = iSE[0];
iSES[1] = iSE[1];
uSES[0] = uSE[0];
uSES[1] = uSE[1];

if( nPts == 0 ) goto wrapup;

for(i=0;i<nPts;i++){

	POevParOnLn( pt12, vdir, &pts[3*i], &u, rc );
	if( *rc == BSFAIL ) return(FALSE);

	if( ( u > 0.0 ) && ( u < 1.0 ) ) { *rc = BSFAIL; return(FALSE); }

	if( u < 0.0000001 ){

		if( iSE[0] == -1 ){ iSE[0] = 3*i; uSE[0] = u; }
		else if( u > uSE[0] ){ iSE[0] = 3*i; uSE[0] = u; }
	}
	else{
		if( iSE[1] == -1 ){ iSE[1] = 3*i; uSE[1] = u; }
		else if( u < uSE[1] ){ iSE[1] = 3*i; uSE[1] = u; }
	}
}

wrapup:

/*
printf("iSE[0] = %d, uSE[0] = %f, uSES[0] = %f\n",iSE[0],uSE[0],uSES[0]);
printf("iSE[1] = %d, uSE[1] = %f, uSES[1] = %f\n",iSE[1],uSE[1],uSES[1]);
*/

	if( iSE[0] == -1 )          for(i=0;i<3;i++) ptSE[i] = pt12[i];
	else if( (iSES[0] == -1) && (iSE[0] > -1) )
				    for(i=0;i<3;i++) ptSE[i] = pts[iSE[0]+i];
	else if( uSE[0] > uSES[0] ) for(i=0;i<3;i++) ptSE[i] = pts[iSE[0]+i];

	if( iSE[1] == -1 )  	    for(i=3;i<6;i++) ptSE[i]   = pt12[i];
	else if( (iSES[1] == -1) && (iSE[1] > -1) )
				    for(i=0;i<3;i++) ptSE[i+3] = pts[iSE[1]+i];
	else if( uSE[1] < uSES[1] ) for(i=0;i<3;i++) ptSE[3+i] = pts[iSE[1]+i];

	*rc = BSSUCC; 
	return( TRUE );

}
