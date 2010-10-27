/*----
%HD%
 
     MODULE NAME POspancv
 
     Abstract:
        This function extract a curve between multiple knots of
	multiplicity order -1 
-----
%SC%

 POspancv( bsp_curve, i_span, num_mkt, tmul, index, bsp_span, &rc )
           I        , I     , I      , I   , I    , O       , O 

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *bsp_curve IGRbsp_curve	 the input curve
        i_span     IGRint	 index of the needed span
	num_mkt	   IGRint	 number of multiple knots on the original curve
	*tmul	   IGRdouble	 array of multiple knots
	*index	   IGRint	 array of index, gives the position of the
			 	 multiple knots in the original knots vector
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	*bsp_span  IGRbsp_curve the resulting span
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
        
        JLL    : Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


#include "v_.h"
#include "msdef.h"
#include "ma.h"
#include "bserr.h"
#include "bstypes.h"

POspancv( bsp_curve, i_span, num_mkt, tmul, index, bsp_span, rc )

struct 	IGRbsp_curve 	*bsp_curve;
        IGRint          i_span;
        IGRint          num_mkt;
        IGRdouble       *tmul;
        IGRint          *index;
struct	IGRbsp_curve    *bsp_span;
	BSrc	 	*rc;



{

  		IGRshort	order, num_boundaries;
		IGRint		size, k;
  		IGRint		ip, ikt, ind[2], l;
  		IGRlong		num_poles;
  		IGRdouble 	knot_val, deltau;
  		IGRboolean	rational;

	if ( !bsp_curve || !tmul || !index || !bsp_span ) goto wrapup;


  /* process to find the good range of knots parameter */
  /*===================================================*/
             
    if( (i_span == 0) || ( num_mkt == 0 ) )
    {
      ind[0] = 1;
      ind[1] = index[0];
      deltau = tmul[0];
      knot_val = 0.0;

    }
    else if( (i_span == num_mkt) && (num_mkt>0) )
    {
      ind[0] = index[num_mkt-1];
      ind[1] = bsp_curve->num_knots - bsp_curve->order;
      knot_val = tmul[num_mkt-1]; 
      deltau = 1.0 - tmul[num_mkt-1]; 

    }
    else
    {
          ind[0] = index[i_span-1];
          ind[1] = index[i_span];
          deltau = tmul[i_span] - tmul[i_span-1];
          knot_val = tmul[i_span-1];
    }
  
    /* malloc the struc for key-curve */
    /*================================*/
	 
    num_poles = ind[1] + 1 - ind[0];
    num_boundaries = 0;

    rational = bsp_curve->rational;
 
    bsp_span->order = bsp_curve->order;
    bsp_span->num_poles = num_poles;
    bsp_span->num_boundaries = num_boundaries;
    bsp_span->rational = bsp_curve->rational;
    bsp_span->num_knots = num_poles + bsp_curve->order;
    bsp_span->planar = bsp_curve->planar;


    /* set the new knots vector (internal knots only) */
    /*================================================*/

    ip=0;
    ikt=0;

    for(k=ind[0];k<=ind[1];k++){

      for(l=3*(k-1);l<3*k;l++){
        bsp_span->poles[ip] = bsp_curve->poles[l];
        ip = ip + 1;
      }
      bsp_span->knots[ikt+1] = (bsp_curve->knots[k]-knot_val) / deltau;
      if( rational>0 ) bsp_span->weights[ikt] = bsp_curve->weights[k-1];
      ikt = ikt + 1;
    }

    for(k=0;k<bsp_curve->order;k++){
      bsp_span->knots[k] = 0.0;
      bsp_span->knots[bsp_span->num_knots-1-k] = 1.0;        
    }

    /* set up the rest of the new bsp */
    /*================================*/
  
    bsp_span->periodic    = FALSE;
    bsp_span->non_uniform = TRUE;
    bsp_span->planar      = bsp_curve->planar;
    bsp_span->phy_closed  = FALSE;
    bsp_span->bdrys       = NULL;

    *rc = BSSUCC;
    return;

wrapup:
    *rc = BSFAIL;
    return;

}

