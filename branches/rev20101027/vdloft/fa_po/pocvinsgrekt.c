/*----
%HD%
 
     MODULE NAME POcvInsGreKt
 
     Abstract:
        This function inserts knots at Greville parameters until the length
	of the poles reachs a relative ratio with the "true" length of the
	curve. If we do not get the requested accuracy after maxIt, The 
	function gives back is best result.
-----
%SC%

     POcvInsGreKt( cv, relativeErr, maxIt, cvsol, itSol, ratioSol, rc )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *cv	    IGRbsp_curve  input curve
        relativeErr IGRdouble     relative error requested 
	maxIt	    IGRint        maximun number of iterations
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	**cvsol	   IGRbsp_curve	 curve solution
	*itsol	   IGRint	 number of iterations used to reach 
				 the tolerance 
	*ratioSol  IGRdouble     relative error reached

        *rc        BSrc          BSSUCC or BSFAIL
  
-----
%MD%

     MODULES INVOKED: none
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 8 March 1993 Creation date.
      
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
#include "vdloft.h"

/*
# ifndef DEBUG
# define DEBUG 0
# endif
*/

POcvInsGreKt( cv, relativeErr, maxIt, cvsol, itSol, ratioSol, rc )

struct	IGRbsp_curve	*cv;		/*I input curve 		    */
	IGRdouble	relativeErr;    /*I relative error requested        */
	IGRint		maxIt;	        /*I number of maximun iterations    */
struct	IGRbsp_curve	**cvsol;	/*O curve solution		    */
	IGRint		*itSol;		/*O number of iteration used to 
					    reach the tolerance             */
	IGRdouble	*ratioSol;	/*O relative error reached          */
	BSrc		*rc;		/*O BSSUCC or BSFAIL		    */

{



struct	cvGrePa		*grePa;
IGRint			i, j, k;
IGRdouble		u, v, trueLen, curLen, prevLen, ratioCou=0.0;
IGRdouble		*poleLen;
IGRint			numMaxPoles;
IGRint			numPoles,  startIndex, index;
IGRint			indexGrePa, ktsIndex;
IGRint			numPolToMov, numKtsToMov, startBloss, startPole;
IGRint			sizeDouble, size3Double, deg;
IGRboolean		boolStat;


extern  void		BSalloccv();
extern  IGRboolean	BSfreecv();
extern	void		BSblkmv();
extern	IGRboolean	BSarclength();
extern	void		__DBGpr_double();
extern  IGRboolean      BSfindspn();
extern	IGRchar		*memcpy();


 sizeDouble  = sizeof(IGRdouble);
 size3Double = 3 * sizeDouble;
 deg         = cv->order - 1;

 /*c set to NULL all the pointers */

 *cvsol = NULL;
 poleLen = NULL;
 grePa  = NULL;

 /*c evaluate the true length of the curve */

 u = 0.0;
 v = 1.0;
 BSarclength( rc, cv, &u, &v, &trueLen );
 if( *rc != BSSUCC ){
	printf("Error in POcvInsGreKts\n");
	printf("BSarclength : Failed\n");
	goto wrapup;
 }


 /*c malloc the curve solution; to avoid multiple realloc, I decided to
     malloc only one time the that is not the best in term of memory
     used in reality  */
 

 numMaxPoles = cv->num_poles + maxIt;
 
 BSalloccv( (IGRshort)   cv->order,
	    (IGRlong)    numMaxPoles,
	    (IGRboolean) cv->rational,
	    (IGRshort)   cv->num_boundaries,
	    cvsol,
	    rc );
 if( *rc != BSSUCC ){
	printf("Error in POcvInsGreKts\n");
	printf("BSalloccv : Failed\n");
	goto wrapup;
 }

 (*cvsol)->order	  = cv->order;
 (*cvsol)->periodic       = cv->periodic;
 (*cvsol)->non_uniform    = TRUE;
 (*cvsol)->rational       = cv->rational;
 (*cvsol)->planar         = cv->planar;
 (*cvsol)->phy_closed     = cv->phy_closed;
 (*cvsol)->num_boundaries = cv->num_boundaries;
 /*c boundaries need to be handle !!!!*/


 /*c malloc  the Greville structure to store parameter and square distance 
     between the pole and his image on the curve at the Greville parameter */

 grePa = (struct cvGrePa *) malloc( numMaxPoles*sizeof(struct cvGrePa) );
 if( grePa == NULL ){
	printf("Error in POcvInsGreKts\n");
	printf("malloc : Failed for grePa\n");
	goto wrapup;
 }

 /*c malloc the poleLen array store the length between each pole. To optimize
     the process, I just reevaluate the length that are affected by the
     knot insertion */

 poleLen = (IGRdouble *) malloc( numMaxPoles * sizeDouble );
 if( poleLen == NULL ){
	printf("Error in POcvInsGreKts\n");
	printf("malloc : Failed for poleLen\n");
	goto wrapup;
 }


 /*c we do here a memcpy of the poles, knots, weights from cv to cvsol */

 memcpy((IGRchar *)(*cvsol)->poles,(IGRchar *)cv->poles,
	(IGRint) ( cv->num_poles * size3Double ) );

 memcpy((IGRchar *)(*cvsol)->knots,(IGRchar *)cv->knots,
	(IGRint) ( cv->num_knots * sizeDouble ) );

 if( cv->rational )
 memcpy((IGRchar *)(*cvsol)->weights,(IGRchar *)cv->weights,
	(IGRint) ( cv->num_poles * sizeDouble ) );
 
 (*cvsol)->num_poles = cv->num_poles;
 (*cvsol)->num_knots = cv->num_knots;
 
 

 startIndex = 0;
 startPole  = 0;
 numPoles = cv->num_poles;


 /*c evaluate and store all GREVILLE abscissia and distance */
 	
 POcvevGreAbs( cv, (*cvsol), (IGRboolean)TRUE, 0, 
		     (IGRint) cv->num_poles, grePa, rc );

 /*c evaluate the length between each poles and the totalLenght */	

 POevPoleLen( (*cvsol), (IGRboolean) TRUE, 0, numPoles, poleLen, &curLen, rc );

 prevLen = curLen;

 for(i=0;i<maxIt;i++){

	ratioCou = curLen / trueLen;

	#ifdef DEBUG
	printf("/************* it = %d ****************\n",i);

	__DBGpr_double("AVANT poles", (*cvsol)->poles, 3, 
				(IGRint)3*(*cvsol)->num_poles );
	__DBGpr_double("AVANT knots", (*cvsol)->knots, 1, 
				(IGRint)(*cvsol)->num_knots );
        for(j=0;j<(*cvsol)->num_poles;j=j+1)
	printf("AVANT grePa[%d] = %f,%f\n",j,grePa[j].pa,grePa[j].dist);

	__DBGpr_double("AVANT poleLen", poleLen, 1,
			(IGRint)((*cvsol)->num_poles - 1));

	printf("trueLen = %f,curLen = %f,ratioCou = %f\n",
		trueLen,curLen,ratioCou );
	#endif


	/*c check the current ratio */

	if( ratioCou < relativeErr ){
		*itSol = i;
 		*rc = BSSUCC;
		goto bestSol;
	}

	/*c search index for max deviation */

	POfndMaxDist(  grePa, (IGRint)(*cvsol)->num_poles, &indexGrePa, rc );
	if( *rc != BSSUCC ){
		printf("Error in POcvInsGreKts\n");
 		printf("POfindMaxDist : Failed\n");
		goto wrapup;
	}

	#ifdef DEBUG
		printf("indexGrePa = %d\n",indexGrePa);
	#endif

	POfndKtInd( cv->order, (*cvsol)->knots, grePa[indexGrePa].pa , 
		    indexGrePa, &ktsIndex, rc );
	if( *rc != BSSUCC ){
		printf("Error in POcvInsGreKts\n");
		printf("POfndKtsInd : Failed\n");
		goto wrapup;
	}


	/*c evaluate what to move, the start index for poles, knots, weights
	    and move everything necessary */


        numKtsToMov = (*cvsol)->num_knots - ktsIndex;
	numPolToMov = numKtsToMov - cv->order + 1;
        startPole   = ktsIndex - 1;


	#ifdef DEBUG
	printf("from POfndKtsInd  ktsIndex = %d\n",ktsIndex);
	printf("numPolToMov = %d, numKtsToMov =%d\n",numPolToMov,numKtsToMov);
	printf(" index du 1ier pole a deplacer startPole = %d\n",startPole);
	#endif

	BSblkmv( (IGRint) ( numPolToMov * size3Double),
	         (IGRchar *) &((*cvsol)->poles[3*startPole]),
		 (IGRchar *) &((*cvsol)->poles[3*(startPole+1)]) );

	if(cv->rational)
	BSblkmv( (IGRint) ( numPolToMov * sizeDouble),
	         (IGRchar *) &((*cvsol)->weights[startPole]),
		 (IGRchar *) &((*cvsol)->weights[(startPole+1)]) );

	BSblkmv( (IGRint) ( numKtsToMov * sizeDouble),
	         (IGRchar *) &((*cvsol)->knots[ktsIndex]),
		 (IGRchar *) &((*cvsol)->knots[(ktsIndex+1)]) );

        (*cvsol)->poles[3*startPole]   = -1;
        (*cvsol)->poles[3*startPole+1] = -1;
        (*cvsol)->poles[3*startPole+2] = -1;
	(*cvsol)->knots[ktsIndex]      = grePa[indexGrePa].pa;
	if(cv->rational)(*cvsol)->weights[startPole]   = -1;

	BSblkmv( (IGRint) ( numPolToMov * sizeof(struct cvGrePa) ),
	         (IGRchar *) &grePa[startPole],
		 (IGRchar *) &grePa[(startPole+1)]);

	grePa[startPole].pa = -1;
	grePa[startPole].dist = -1;

	BSblkmv( (IGRint) ( numPolToMov * sizeDouble),
	         (IGRchar *) &poleLen[startPole-1],
 		 (IGRchar *) &poleLen[startPole] );

	poleLen[startPole-1] = -1;

	(*cvsol)->num_poles = (*cvsol)->num_poles + 1;
	(*cvsol)->num_knots = (*cvsol)->num_knots + 1;



        startBloss  = ktsIndex - cv->order + 2;
        startPole   = startBloss - 1;

	#ifdef DEBUG
	printf(" startBloss  = %d, startPole = %d\n",startBloss, startPole);
	printf(" knot value = %f\n",(*cvsol)->knots[ktsIndex] );
/*
	__DBGpr_double("APRES poles", (*cvsol)->poles, 3, 
				(IGRint)3*(*cvsol)->num_poles );
	__DBGpr_double("APRES knots", (*cvsol)->knots, 1, 
				(IGRint)(*cvsol)->num_knots );
        for(j=0;j<(*cvsol)->num_poles;j=j+1)
	printf("APRES grePa[%d] = %f,%f\n",j,grePa[j].pa,grePa[j].dist);

	__DBGpr_double("APRES poleLen", poleLen, 1,
			(IGRint)((*cvsol)->num_poles - 1));
*/
	#endif


	/*c this function defines in which intervalle belongs the Greville
	    parameter I want to insert but relatively to the original
	    curve cv */

	boolStat = BSfindspn( rc, &cv->order, &cv->num_poles, 
			      cv->knots, &(*cvsol)->knots[ktsIndex], &index);
        if( !boolStat ){
		printf("Error BSfindspn\n");
		goto wrapup;
	}


	/* We now perform the evaluation of the deg new poles, using the
	   Blossoming technique */


	if( cv->rational ){
	    for(j=0;j<deg;j++){
		k = startPole + j;
		POcvevpgbind( (IGRshort) 3, cv,
			      &((*cvsol)->knots[startBloss +j]), 
		      	      index, &((*cvsol)->poles[3*k]), 
		              &((*cvsol)->weights[k]), rc );
	    }
	}
	else{
	    for(j=0;j<deg;j++){
		POcvevpgbind( (IGRshort) 3, cv, 
			      &((*cvsol)->knots[startBloss +j]), 
		      	      index, &((*cvsol)->poles[3*(startPole + j)]), 
		              NULL, rc );
	    }
	}


 	/*c evaluate and store Greville abscissia and square distance. 
	    For each iteration you must evaluate deg poles, Greville
	    abscissia and square distance.*/
	/*  startPole is relative to the pole index for cvsol; we use
	    cv to evaluate efficiently the Greville image of the pole on the 
	    curve. */

 	POcvevGreAbs( cv, (*cvsol), (IGRboolean)TRUE, startPole, 
		     (IGRint) deg, grePa, rc );

	#ifdef DEBUG
        for(j=0;j<(*cvsol)->num_poles;j=j+1)
	printf("YYY grePa[%d] = %f,%f\n",j,grePa[j].pa,grePa[j].dist);
	#endif


 	/*c evaluate the length between each poles and the totalLenght */	

	startIndex = startPole - 1;
	
	#ifdef DEBUG
	printf("startIndex index pour longueur = %d\n",startIndex);
 	#endif

	POevPoleLen( (*cvsol), (IGRboolean) TRUE, startIndex, 
		     (IGRint)(cv->order+1), poleLen, &curLen, rc );

	if( curLen < prevLen ) prevLen = curLen;
	else{
		*itSol = i;
		*rc    = BSSUCC;
		goto bestSol;		
	}
 }


 /* We did not reach the requested relative error, we just give our best
    solution, the return code should not be BSSUCC in this but a warning */

 *itSol = maxIt;
 *rc    = BSSUCC;


bestSol:

 *ratioSol = ratioCou;
 if( grePa )    { free(grePa); grePa = NULL; }
 if( poleLen )  { free(poleLen); poleLen = NULL; }

 return;


	
wrapup:
	if( (*cvsol) ) { BSfreecv( rc, (*cvsol) );  *cvsol = NULL; }
	if( grePa )    { free(grePa); grePa = NULL; }
 	if( poleLen )  { free(poleLen); poleLen = NULL; }
	*rc = BSFAIL;
	return;
}
