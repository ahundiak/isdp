/*----
%HD%
 
     MODULE NAME FAevPtSfFa
 
     Abstract:

	The input surface is an order 2X2 surface, however it's not a
	tensor product surface. Two parameters are associated to each poles
	of this surface, so that is the reason why we pass pars that contains
	these parameters and the range of each facette.
	Giving u,v parameters relative to the original surface, this function
	finds on which facette (u,v) belong to and then return the 3D point
	defined by the original (u,v) parameters.
-----
%SC%

     FAevPtSfFa( idim, sfUnw, pars, u, v, ptSol, &rc )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	idim	  IGRshort	 dimension 2D, 3D
        *sfUnw	  IGRbsp_surface the surface from we take the four poles to
			    	  evaluate the point solution 	
        *pars     IGRdouble	 array of parameters associated to each poles,
			         and range off each facette.
				 pars should be malloc by the caller with
				 the following size.
				(idim*sfUnw->u_num_poles*sfUnw->v_num_poles +
				 4*(sfUnw->u_num_poles-1)*(sfUnw->u_num_poles-1)
				)*sizeof(IGRdouble) 
	u         IGRdouble      u parameter of a point in the space of sfUnw
	v	  IGRdouble      v parameter of a point in the space of sfUnw
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	*ptSol	   IGRdouble	the point solution
        *rc        BSrc         completion code message
                                 - always BSSUCC
  
-----
%MD%

     MODULES INVOKED: none
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 14-03-95 Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/
#include <stdio.h>
#include "bstypes.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdef.h"
#include "bserr.h"


void FAevPtSfFa( idim, sfUnw, pars, u, v, ptSol, rc )

IGRshort	idim;   /*I dimension of pars 2D,3D	*/
struct IGRbsp_surface
		*sfUnw;	/*I surface from we take the four poles to     
			    evaluate the point solution 		 */
IGRdouble	*pars;  /*I array of parameters associated to each poles */
IGRdouble	u;	/*I u parameter of a point in the space of sfUnw */
IGRdouble	v;	/*I v parameter of a point in the space of sfUnw */
IGRdouble	*ptSol; /*O point solution if BSSUCC */
BSrc		*rc;	/*O return status BSSUCC or BSFAIL */

{

extern	IGRboolean	FAfndPar();
extern  void    	FAev();
extern void		BSmdstptcv();

IGRdouble		us, vs;
IGRint			i, j, offset, offsetMiIdim, numPars, jstart, jend;
IGRboolean		fastat;
IGRdouble		*P00, *P01, *P10, *P11, *minmax, uv[3];
IGRdouble		mindist;
IGRint			numCol, numRow;
IGRdouble		umax, BASE[3];
struct	IGRbsp_curve	cv;

	numRow = sfUnw->v_num_poles - 1;
        numCol = sfUnw->u_num_poles - 1;
	numPars = idim * sfUnw->u_num_poles * ( sfUnw->v_num_poles - 1 );
	offset  = idim * sfUnw->u_num_poles;
	offsetMiIdim = offset - idim;
	minmax = pars + offset * sfUnw->v_num_poles;

	for(i=0;i<numPars;i+=offset){

		jend = i + offsetMiIdim;

		for(j=i;j<jend;j+=idim){
               
                	P00 = pars + j;
			P01 = P00  + idim;
			P10 = P00  + offset;
                	P11 = P01  + offset;
			if( u > minmax[1] ) goto cnt0;
			if( u < minmax[0] ) goto cnt0;
			if( v > minmax[3] ) goto cnt0;
			if( v < minmax[2] ) goto cnt0;

			fastat = FAfndPar( P00, P01, P10, P11, u, v, 
					   &us, &vs, rc );
			if( ( fastat == TRUE ) && ( *rc == BSSUCC ) ) goto eval;
cnt0:
			minmax+=4;			
		}
	}
	
	/*
	 *	the point (u,v) is external to the surface so, we
	 *	find the nearest poles from the contour.
	 */
/*
	printf("enter border test\n");
*/
	uv[0] = u;
	uv[1] = v;
	uv[2] = 0.0;

	jstart = idim * sfUnw->u_num_poles * sfUnw->v_num_poles +
	         4*( numRow * numCol );

	jend   = jstart + idim * 
		 ( 2*(sfUnw->u_num_poles + sfUnw->v_num_poles) - 4 );

	cv.order          = 2;
	cv.periodic       = FALSE;
	cv.non_uniform    = FALSE;
	cv.num_poles      = 2*(sfUnw->u_num_poles + sfUnw->v_num_poles) - 3;
	cv.poles          = pars + jstart;
	cv.num_knots	  = cv.num_poles + 2;
	cv.knots          = pars + jend + idim; 
	cv.rational       = FALSE;
	cv.weights        = NULL;
	cv.planar         = TRUE;
	cv.phy_closed     = TRUE;
	cv.num_boundaries = 0;
	cv.bdrys	  = NULL;


	BSmdstptcv( &cv,uv,&umax,BASE,&mindist,rc );
	if( *rc != BSSUCC ){
		/*d
		printf("Error in BSmdstptcv umax = %f\n",umax);
		d*/
		goto wrapup;
	}

	/*d
	printf("umax = %f, BASE=%f,%f\n",umax,BASE[0],BASE[1]);
	d*/

	jend = cv.num_knots - 1;
	for(j=1;j<jend;j++){
		if( cv.knots[j] > umax ) break;
	}

        j = (j-2)*idim;

	/*d
	printf(" j avant j = %d\n",j);
	d*/

	/*d test if index belongs to the first row */
	numCol *= idim;
	numRow *= idim;
	i = numCol;
	if( j < i ) goto eval0;

	/*d test if index belongs to the last colum */
	i += numRow;
	if( j < i ){
		j-= numCol;
		j = ( j / idim ) * offset + offsetMiIdim - idim;	
		goto eval0;
	}

	/*d test if index belongs to the last row */
	i += numCol;
	if( j < i ){
		j-=  numCol + numRow;
		j = numPars  - j - 2*idim;
		goto eval0;
	}
	
	/*d test if index belongs to the last row */
	i += numRow;
	if( j < i ){
		j-= numCol + numRow + numCol;
		j = numPars - (j+idim) / idim * offset;
		goto eval0;
	}

	/*d
	printf("something went wrong\n");
	d*/
	goto wrapup;

eval0:
	/*d
	printf("a la fin  j = %d, quotient = %d, rest = %d\n",
		j,(j/offset),(j%offset));
	d*/

        P00 = pars + j;
	P01 = P00  + idim;
	P10 = P00  + offset;
        P11 = P01  + offset;

	fastat = FAfndPar( P00, P01, P10, P11, u, v, &us, &vs, rc );

eval:


 	/*d
	printf("a la fin  j = %d, quotient = %d, rest = %d\n",
		j,(j/offset),(j%offset));

	printf(" in c fastat=%d, us = %16.14f, vs = %16.14f\n",fastat,us,vs);
	d*/

       	P00 = sfUnw->poles + j;
	P01 = P00  + idim;
	P10 = P00  + offset;
       	P11 = P01  + offset;

	FAev( idim, P00, P01, P10, P11, us, vs, ptSol, rc );
	return;


wrapup:
	*rc = BSFAIL;
	return;
}
