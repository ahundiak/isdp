class implementation GRcompcurve;

#include "EMScc.h"
#include "msdef.h"
#include "go.h"
#include "gr.h"
#include "ma.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"

method GRtotlength(
	IGRlong 	*msg; 		/* completion code */
        IGRshort        *mat_type;
        IGRmatrix        matrix;
        IGRdouble        *tot_length)
/*
NOTES

	Upon exit the completion code will be one of

		- MSSUCC if successful
		- MSFAIL(severe) if failure

History
	
	pwd	7/15/87 : Creation date
	dhm 12/21/87 : converted to 1.1

Abstract
        This method returns the total length of a composite curve.

*/		

{

  IGRchar	errmsg[EMMAXERRMSG_LEN];
  IGRint       count;			/* number of components	*/
  IGRint 	i;			/* index		*/
  IGRlong  	OM_stat;		/* om return status 	*/
  IGRlong  	mthd_stat;		/* method return code	*/
  IGRdouble     arclength,length;

  OM_S_CHANSELECT composite_chan;	/* channel definition	*/


       /*
	* Initialize messages
        */

	*msg = MSSUCC;
  	OM_stat = OM_S_SUCCESS;
	strcpy (errmsg, "GRcompcurve.GRtotlength");

        composite_chan.type = OM_e_addr;
        composite_chan.u_sel.addr = &ME.GRcmpowner->to_components;
	
        /*  
           determine number of segments in composite curve
        */
	OM_stat = om$send(msg = message GRowner.GRget_number_components(
                            &mthd_stat, &count),
                   targetid = my_id);
	EMomerr_hndlr(OM_stat, wrapup, errmsg);
	EMerr_hndlr(EMis_error(mthd_stat), *msg, MSFAIL, wrapup);

        arclength = 0.0;

        /*
             get arclength for each component curve and sum them 
        */

	for (i = 0; (i <  count) ; ++i)
	{
                length = 0.0;
		OM_stat = om$send(msg = message GRcurve.GRtotlength
						(&mthd_stat,
                                                  mat_type,
                                                  matrix,
                                                  &length),
				    senderid = my_id,
				    p_chanselect = &composite_chan,
				    from = i,
				    to = i);
		EMomerr_hndlr(OM_stat, wrapup, errmsg);
        EMerr_hndlr(EMis_error(mthd_stat), *msg, MSFAIL, wrapup);

                arclength += length;

          }    /* for i = 0 to count  */

          *tot_length = arclength;


wrapup:

	return(OM_stat);
}

end implementation GRcompcurve;

