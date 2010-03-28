/* #######################    APOGEE COMPILED   ######################## */
/* Command definition section */

options			"t"
product_name		"$GRNUC"
class			COcnstrpl
super_class		COwindow
start_state       	terminate


/* OPP section */
/* Specification section .. code for .S file */

specification

instance 
{
}

/* implementation section - code for .I file */

implementation

#include <stdio.h>

#include "dp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "exmacros.h"
#include "ma.h"

%safe
#include "DPsetinq.h"
#include "dpexbell.h"
#include "GRdpbfunc.h"

#include "ma3protmx.h"
#include "marotmx.h"
#include "mamulmx.h"

%endsafe

from IGEgragad import DPupdate, DPcal, DPset, DPinquire;

action idnt_wnd1
{
    IGRshort j;			/* loop control variable	*/
    IGRint flags[2];
    struct var_list var_list[3];
    IGRlong error;
    IGRlong num_bytes;
    IGRlong msg;
    IGRdouble  rotate_mtx[4][4];

	*sts = OM_S_SUCCESS;

	          if ( !MA3protmx(&msg,&me->pts[0],&me->pts[3],&me->pts[6],
				(IGRdouble *)rotate_mtx))
       	  	  {
                        *sts = FunFail;
                        goto quit;
       	  	  }  
	          rotate_mtx[0][3] = me->pts[0];
	          rotate_mtx[1][3] = me->pts[1];
	          rotate_mtx[2][3] = me->pts[2];


		var_list[0].var = GRAGAD_FLAGS;
		var_list[0].var_ptr = (IGRchar *)flags;
		var_list[0].num_bytes = sizeof(IGRint)*2;
		var_list[0].bytes_returned = &num_bytes;

		var_list[1].var = CONSTRUCT_PLANE;
		var_list[1].var_ptr = (IGRchar *)rotate_mtx;
		var_list[1].num_bytes = sizeof(IGRdouble) * 16;
		var_list[1].bytes_returned = &num_bytes;

		var_list[2].var = END_PARAM;

		flags[0] = CONST_PL_DEF | CONST_PLANE_ON | VALID_ALT_INV;
		flags[1] = flags[0];

                for(j=0;j < me->num_id;j++)
                {
	          status = dp$inq_set_gragad (msg=&msg,
					      inq0_set1=1,
					      which_error= &error,
					      var_list= var_list,
					      osnum = me->ggid[j].osnum,
					      gragad_objid = me->ggid[j].objid,
					      calc_info=1,
					      update=1);
                    if ( !(status & 1))
		    {
#ifdef DEBUG
                     	printf("\nin COconstplan  dp$set failed\n");
			om$report_error(sts = status);
#endif
			*sts = status;
			goto quit;
                     }
           	}  /* end of for */

 }   /* end of action idn_wnd   */

action pln_onoff
{
    IGRshort j;
    struct var_list var_list[2];
    IGRint set_flags[2];
    IGRint inq_flags;
    IGRlong error;
    IGRlong msg;
    IGRlong num_bytes;

	*sts = OM_S_SUCCESS;

	    	var_list[0].var = GRAGAD_FLAGS;
	    	var_list[0].bytes_returned = &num_bytes;

	    	var_list[1].var = END_PARAM;

	    	for( j = 0; j < me->num_id ; j++)
	    	{         
	    	    var_list[0].var_ptr = (IGRchar *)&inq_flags;
		    var_list[0].num_bytes = sizeof(IGRint);

	            status = dp$inq_set_gragad (msg=&msg,
					gragad_objid = me->ggid[j].objid,
					which_error = &error, 
					var_list=var_list);
                    if ( !(status & 1))
                    {
#ifdef DEBUG
                      	printf("\nin COconstplanof  DPinquire failed\n");
			om$report_error(sts = status);
#endif
			*sts = status;
			goto quit;
                    }		

			/* if const. plane on.  Turn it off. */	

		    if ( inq_flags & CONST_PLANE_ON)
		    {
		    	set_flags[0] = CONST_PLANE_ON | VALID_ALT_INV;
		    	set_flags[1] = 0;
			ex$message ( msgnumb = GR_I_CnsPlOff);
		    	sleep (3);
		    }
		    else /* if construction plane off.  Turn it on.  */
		    {
		    	if(!( inq_flags & CONST_PL_DEF))
		    	{
			    EX_bell();
			    ex$message ( msgnumb = GR_E_CnsPlNotDnf);
			    sleep (4);
   			    ex$message (msgnumb = EX_S_Clear);

		    	}
		    	else
		    	{
		    	    set_flags[0] = CONST_PLANE_ON | VALID_ALT_INV;
		    	    set_flags[1] = set_flags[0];
			    ex$message ( msgnumb = GR_I_CnsPlOn );
		    	    sleep (3);
  		    	}
		    } /* close for const. plane off */
               if((inq_flags & CONST_PL_DEF))
               {
		    var_list[0].var_ptr = (IGRchar *)set_flags;
		    var_list[0].num_bytes = sizeof(IGRint) * 2;
	            status = dp$inq_set_gragad (msg=&msg,
					inq0_set1=1,
					which_error= &error,
					var_list= var_list,
					gragad_objid = me->ggid[j].objid,
					calc_info=1,
					update=1);
                    if ( !(status & 1))
                    {
#ifdef DEBUG
                     	printf("\nin COconstplof  dp$set failed\n");
			om$report_error(sts = status);
#endif
			*sts = status;
			goto quit;
                    }
              } /* end of if(inq_flags & CONST_PL_DEF)   */
 	     }  /* close for "for num_id" */

}    /* end of action pln_onoff  */


action mv_cnspl
{
    IGRshort i;			/* loop control variable	*/
    IGRlong msg;
    IGRdouble matrix[4][4];
    IGRint    inq_flags;
    struct var_list  var_list[3];
    IGRlong	num_bytes;
    IGRlong	error;

		*sts = OM_S_SUCCESS;

           for ( i = 0; i < me->num_id; i++)
           {
		var_list[0].var = CONSTRUCT_PLANE;
		var_list[0].var_ptr = (IGRchar *)matrix;
		var_list[0].num_bytes = sizeof(IGRdouble) * 16;
		var_list[0].bytes_returned = &num_bytes;

	    	var_list[1].var = GRAGAD_FLAGS;
		var_list[1].var_ptr = (IGRchar *)&inq_flags;
		var_list[1].num_bytes = sizeof(IGRint);
	    	var_list[1].bytes_returned = &num_bytes;

/*		var_list[2].var = END_PARAM;  moved down into for loop*/

		    var_list[2].var = END_PARAM;
	            status = dp$inq_set_gragad (msg=&msg,
					which_error= &error,
					var_list= var_list,
					osnum = me->ggid[i].osnum,
					gragad_objid = me->ggid[i].objid);

                    if ( !(status & 1))
                    {
#ifdef DEBUG
                     	printf("\nin COmvcnspl  dp$inquire failed\n");
			om$report_error(sts = status);
#endif
			*sts = status;
			goto quit;
                     }

		    if(!( inq_flags & CONST_PL_DEF))
		    {
		    	EX_bell();
		    	ex$message ( msgnumb = GR_E_CnsPlNotDnf);
			sleep (1);
			ex$message (msgnumb = EX_S_Clear);
	    	    }
	   if(( inq_flags & CONST_PL_DEF))
           {
		     matrix[0][3] = me->pts[0];
		     matrix[1][3] = me->pts[1];
		     matrix[2][3] = me->pts[2];

		     var_list[1].var = END_PARAM; 
	             status = dp$inq_set_gragad (msg=&msg,
					inq0_set1=1,
					which_error= &error,
					var_list= var_list,
					osnum = me->ggid[i].osnum,
					gragad_objid = me->ggid[i].objid,
					calc_info=1,
					update=1);
                    if ( !(status & 1))
                    {
#ifdef DEBUG
                     	printf("\nin COmvcnstpl  dp$inquire failed\n");
			om$report_error(sts = status);
#endif
			*sts = status;
			goto quit;
                    }

            }   /* end of if(inq_flags & CONST_PLN_DEF)   */

   	   	}  /* end of for  */

}  /* end of action mv_cnspl   */



action  idnt_wnd2
{
    IGRshort i;			/* loop control variable	*/
    IGRlong msg;
    struct var_list var_list[3];
    IGRlong error;
    IGRlong num_bytes;
    IGRdouble matrix[4][4];
    IGRint  inq_flags;
    IGRdouble     delta[3];

		*sts = OM_S_SUCCESS;

		delta[0] = me->pts[3] - me->pts[0];
		delta[1] = me->pts[4] - me->pts[1];
		delta[2] = me->pts[5] - me->pts[2];

		var_list[0].var = CONSTRUCT_PLANE;
		var_list[0].var_ptr = (IGRchar *)matrix;
		var_list[0].num_bytes = sizeof(IGRdouble) * 16;
		var_list[0].bytes_returned = &num_bytes;

	    	var_list[1].var = GRAGAD_FLAGS;
		var_list[1].var_ptr = (IGRchar *)&inq_flags;
		var_list[1].num_bytes = sizeof(IGRint);
	    	var_list[1].bytes_returned = &num_bytes;

/*		var_list[2].var = END_PARAM; moved into for loop */

            	for ( i = 0; i < me->num_id; i++)
            	{
		    var_list[2].var = END_PARAM;
	            status = dp$inq_set_gragad (msg=&msg,
					which_error= &error,
					var_list= var_list,
					osnum = me->ggid[i].osnum,
					gragad_objid = me->ggid[i].objid);

                    if ( !(status & 1))
                    {
#ifdef DEBUG
                     	printf("\nin COmvdltacns  dp$inquire failed\n");
			om$report_error(sts = status);
#endif
			*sts = status;
                        goto quit;
                     }
		    if(!( inq_flags & CONST_PL_DEF))
		    {
		    	EX_bell();
		    	ex$message ( msgnumb = GR_E_CnsPlNotDnf);
			sleep (1);
			ex$message (msgnumb = EX_S_Clear);
			break;
	    	    }

		     matrix[0][3] += delta[0];
		     matrix[1][3] += delta[1];
		     matrix[2][3] += delta[2];

		     var_list[1].var = END_PARAM; 
	            status = dp$inq_set_gragad (msg=&msg,
					inq0_set1=1,
					which_error= &error,
					var_list= var_list,
					osnum = me->ggid[i].osnum,
					gragad_objid = me->ggid[i].objid,
					calc_info=1,
					update=1);
                    if ( !(status & 1))
                    {
#ifdef DEBUG
                     	printf("\nin COmvcnstpl  dp$inquire failed\n");
			om$report_error(sts = status);
#endif
			*sts = status;
                        goto quit;
                    }
		} /* close for for */

}   /* end of action idnt_wnd    */

action rot_cnspl
{

    IGRshort i,j;			/* loop control variable	*/
    IGRshort four = 4;
    IGRlong msg;
    IGRint msg1;
    struct var_list var_list[4];
    IGRdouble rot_matrix[4][4];
    IGRdouble cons_mtx[4][4];
    IGRdouble result_mtx[4][4];
    IGRdouble angle;
    IGRdouble view_axis[3];
    IGRdouble translation[3];
    IGRint  inq_flags;
    IGRlong error;
    IGRlong num_bytes;
    IGRint  num_bytes1;
    IGRint  sizbuf;

		*sts = OM_S_SUCCESS;

		var_list[0].var = CONSTRUCT_PLANE;
/*		var_list[0].var_ptr = cons_mtx; moved into for loop 	*/
		var_list[0].num_bytes = sizeof(IGRdouble) * 16;
		var_list[0].bytes_returned = &num_bytes;

	    	var_list[1].var = GRAGAD_FLAGS;
		var_list[1].var_ptr = (IGRchar *)&inq_flags;
		var_list[1].num_bytes = sizeof(IGRint);
	    	var_list[1].bytes_returned = &num_bytes;

		var_list[2].var = VW_ROT_NO_CON;
		var_list[2].var_ptr = (IGRchar *)rot_matrix;
		var_list[2].num_bytes = sizeof(IGRdouble) * 16;
		var_list[2].bytes_returned = &num_bytes;

/*		var_list[3].var = END_PARAM;  moved into for loop 	*/


            	for ( i = 0; i < me->num_id; i++)
            	{
		    var_list[0].var_ptr = (IGRchar *)cons_mtx;
		    var_list[1].var_ptr = (IGRchar *)&inq_flags;
		    var_list[3].var = END_PARAM;
	            status = dp$inq_set_gragad (msg=&msg,
					which_error= &error,
					var_list= var_list,
					osnum = me->ggid[i].osnum,
					gragad_objid = me->ggid[i].objid);

                    if ( !(status & 1))
                    {
#ifdef DEBUG
                     	printf("\nin COrotcnspl  dp$inquire failed\n");
			om$report_error(sts = status);
#endif
			*sts = status;
			goto quit;
                     }
		    if(!( inq_flags & CONST_PL_DEF))
		    {
		    	EX_bell();
		    	ex$message ( msgnumb = GR_E_CnsPlNotDnf);
			sleep (1);
			ex$message (msgnumb = EX_S_Clear);
	    	    }

	   if(( inq_flags & CONST_PL_DEF))
           {
		    sizbuf = sizeof(IGRdouble);

		    gr$get_active_angle(msg =    &msg1,
					sizbuf = &sizbuf,
					buffer = (IGRchar *)&angle,
					nret =   &num_bytes1);
		    for (j=0; j < 3; j++)
		    {
		    	view_axis[j] = rot_matrix[2][j];
		    	translation[j] = cons_mtx[j][3];
			cons_mtx[j][3] = 0;
		    }

	            if ( !MArotmx(&msg, view_axis, &angle,
                                               (IGRdouble *)rot_matrix))
      		    {
			*sts = FunFail;
			goto quit;
             	    }   
                    if ( !MAmulmx(&msg, &four, &four, &four,
                                  (IGRdouble *)rot_matrix,
                                  (IGRdouble *)cons_mtx,
                                  (IGRdouble *)result_mtx))
                    {
			*sts = FunFail;
			goto quit;
                    }
		    result_mtx[0][3] = translation[0];  
		    result_mtx[1][3] = translation[1];  
		    result_mtx[2][3] = translation[2];  

		    var_list[0].var_ptr = (IGRchar *)result_mtx;
		    var_list[1].var = END_PARAM; 

	            status = dp$inq_set_gragad (msg=&msg,
					inq0_set1=1,
					which_error= &error,
					var_list= var_list,
					osnum = me->ggid[i].osnum,
					gragad_objid = me->ggid[i].objid,
					calc_info=1,
					update=1);
                    if ( !(status & 1))
                    {
#ifdef DEBUG
                     	printf("\nin COmvcnstpl  dp$inquire failed\n");
			om$report_error(sts = status);
#endif
			*sts = status;
			goto quit;
                    }

              } /* end of (if(inq_flags & CONST_PL_DEF))   */

		}   /* end of for   */

}    /* end of action */
