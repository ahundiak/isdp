/*----
%HD%
 
     MODULE NAME POcvFndCusps 
 
     Abstract:
        This function find all the cusps on a bsp_curve. This function
	check the square distance between the pole and his greville image.
	if the square distance is bigger than a given tolerance then the
	pole is concidered as a break point.


-----
%SC%

     POcvFndCusps( cv, tol2, numCusps, cuspIndex, arePolesAlign,  rc )

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *cv  	   IGRbsp_curve      the original curve 

	tol2       IGRdouble	     the square distance to check against.


-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	
	*numCusps IGRint	     the number of cusps found.

	**cuspIndex IGRint	     the index of the pole where to break
				     the curve.

	*arePolesAlign IGRboolean    check if the poles are aligned

        *rc        BSrc              completion code message
                                 	- BSSUCC or BSFAIL

  
-----
%MD%

     MODULES INVOKED: BSdistptpts(), BScveval();
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 29 novembre 1993.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include "v_.h"
#include "madef.h"
#include "ma.h"
#include "msdef.h"
#include "bserr.h"
#include "bstypes.h"


POcvFndCusps (

struct	IGRbsp_curve	*cv,		/*I the original curve  */

IGRdouble		tol2,		/*I the square distance to check */

IGRint			*numCusps,	/*O the number of cusps found */

IGRint			**cuspIndex,	/*O the array containing the index
					    of the cusp regrading the poles */

IGRboolean		*arePolesAlign, /*O TRUE poles are aligned FALSE else*/

BSrc			*rc )		/*O BSSUCC or BSFAIL		     */


{

IGRint		deg, i, j, jstart, jend, numPol, iM3;
IGRdouble	pt[3], pol[3], u, dist, vdif[3], lpol;
IGRint		*indexptr;
IGRdouble	*distance, distMax, distMin, unMu;
IGRdouble	mytol;

 extern		IGRdouble	BSdistptpts();
 extern		void		BScveval();
 extern         IGRchar         *malloc();
 extern         IGRint		free();	
 extern         void		BSmdstptcv();
 extern                         POarepolaln();
 extern		IGRdouble	sqrt();

 *numCusps = 0;
 *arePolesAlign = FALSE;
 (*cuspIndex) = NULL;
 distance = NULL;
 indexptr = NULL;

 /*--- In the current implementation if the order is < 3 then when exit.
       We will later create a temporary curve of order 4 to check ---*/

 if( cv->order < 3 ){
	*rc = BSFAIL;
	goto wrapup;
 }

 deg = cv->order - 1;
 *rc = BSSUCC;

 /*--- check if the poles are aligned ---*/

 POarepolaln(cv,1.0E-10,rc);
 if( *rc == BSSUCC ){
	*arePolesAlign = TRUE;
	return;
 }

 /*--- evaluate the tolerance to find the break points ---*/

 distance = (IGRdouble *) malloc( cv->num_poles*sizeof(IGRdouble) );
 if( distance == NULL ){
	printf("Error in pocvfndcusps when malloc distance\n");
	*rc = BSFAIL;
	goto wrapup;
 }
 
 distMax = -1;
 distMin = 1.E30;
 numPol = (IGRint) cv->num_poles - 2;

 for(i=0;i<numPol;i++){

	lpol = 0.0;
	u = 0.0;
	for(j=0;j<3;j++){
		pol[j] = cv->poles[3*(i+2)+j] - cv->poles[3*i+j];
		lpol += pol[j] * pol[j];
		vdif[j] = cv->poles[3*(i+1)+j] - cv->poles[3*i+j];
		u += pol[j] * vdif[j];
	}
	
	/*
	printf("u = %f\n",u);	
	*/

	if( lpol > 0.0 ) u = u / lpol;
	else u = 0.0;
	
	unMu = 1.0 - u;
	distance[i] = 0.0;

	for(j=0;j<3;j++){ 
		pt[j] = unMu * cv->poles[3*i+j] + u * cv->poles[3*(i+2)+j];
		pol[j] = pt[j]- cv->poles[3*(i+1)+j];
		distance[i] += pol[j] * pol[j];
	}

	distance[i] = sqrt(distance[i]);
	/*
	printf(" distance[%d] = %f\n",i,distance[i]); 
	*/

	if( distance[i] > distMax ) distMax = distance[i];
	if( distance[i] < distMin ) distMin = distance[i];
 }

 distMax = 0.95 * distMax + 0.05 * distMin;
 mytol = 0.0;

 for(i=0;i<numPol;i++){
	if( distance[i] > distMax ) distance[i] = 0.0;
	mytol += distance[i];
 }

 mytol = mytol / ( 2 * numPol );
 mytol = mytol * mytol;

 /* printf("avant test mytol = %f\n",mytol); */

 if( mytol > ( 500 * tol2 ) ) mytol = tol2;
 if( mytol < tol2 ) mytol = tol2;

 /* printf("mytol = %f\n",mytol); */

 /*--- malloc the array to receive the cusps ---*/

 indexptr = (IGRint *) malloc( cv->num_poles*sizeof(IGRint) );
 if( indexptr == NULL ){
	printf("Error in pocvfndcusps when malloc indexptr \n");
	*rc = BSFAIL;
	goto wrapup;
 }

 /*--- check the distance for the rational case outside of the loop
       to avoid rational test for each pole ---*/

 numPol = (IGRint) cv->num_poles-1;

 if( cv->rational ){

	for(i=1;i<numPol;i++){

		u = 0.0;
		jstart = i + 1;
		jend = jstart + deg;

		for(j=jstart;j<jend;j++) u += cv->knots[j];
		u = u / (IGRdouble) deg;
		
		BScveval( cv, u, 0, pt, rc );

		iM3 = 3 * i;
		pol[0] = cv->poles[iM3]   / cv->weights[i];
		pol[1] = cv->poles[iM3+1] / cv->weights[i];
		pol[2] = cv->poles[iM3+2] / cv->weights[i];

		dist = BSdistptpts(rc,pol,pt);
		if( dist > mytol ){
			indexptr[*numCusps+1] = i;
			(*numCusps)++;
		}			

	}

 }/* end of the rational case */

 else{

	for(i=1;i<numPol;i++){

 		u = 0.0;
		jstart = i+1;
		jend = jstart + deg;
		
		for(j=jstart;j<jend;j++) u += cv->knots[j];
		u = u / (IGRdouble) deg;
		BScveval( cv, u, 0, pt, rc );
		dist = BSdistptpts(rc,&(cv->poles[3*i]),pt);

		if( dist > mytol ){
			indexptr[*numCusps+1] = i;
			*numCusps = *numCusps + 1;
		}			
	}

 }


 if( (*numCusps) == 0 ){
	indexptr[0] = 0;
	indexptr[1] = cv->num_poles - 1;
 }
 else{
	jstart = 0;
	for(i=0;i<(*numCusps);i++){
		BSmdstptcv( cv, &cv->poles[3*indexptr[i+1]],&u,pt,&dist,rc);
		if( (dist*dist) > mytol ){
			indexptr[jstart+1] = indexptr[i+1];
			jstart++;
		}
	}

	*numCusps = jstart;
/*
 	if( (*numCusps) == 0 ){
		free( indexptr );
		indexptr = NULL;
		*rc = BSSUCC;
		goto wrapup;
 	}
*/
	indexptr[0] = 0;
	indexptr[jstart+1] = cv->num_poles - 1;
 }


 (*cuspIndex) = indexptr;

#ifdef DEBUG
	printf("numCusps = %d\n",(*numCusps));
	if( *numCusps > 0 ){
		for(i=0;i<(*numCusps+2);i++)
		printf("indexptr[%d] = %d\n",i,indexptr[i]);
	}
#endif

 if( distance ) {
	free( distance );
	distance = NULL;
 }
 
 *rc = BSSUCC;
 return;


wrapup:

	if( indexptr ){ 
		free( indexptr );
		indexptr = NULL;
	}

	if( distance ) {
		free( distance );
		distance = NULL;
	}

 	(*cuspIndex) = NULL;
	*numCusps = 0;

	return;	

}
