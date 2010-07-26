/* #######################    APOGEE COMPILED   ######################## */
class implementation COcvtclsl;

#include <stdio.h>
#include "coimport.h"
#include "ex.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "lcdef.h"
#include "lc.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grdpbmacros.h"
#include "transerr.h"
#include "msmacros.h"
#include "grmessage.h"

extern CS_path_name[256];

enum states { GET_CL_NAME,
	      GET_SEED_FILE,
	      GET_SL_NAME };


/*---------------------------------------------------------------------*/
/*                      COcvtclsl init method		               */
/*---------------------------------------------------------------------*/

method init ( int type; char *string_ptr )

{
    IGRlong	msg;
    IGRlong	status;
    IGRlong 	nbytes_in_buffer;
    IGRlong	nbytes_transferred;


    status = OM_S_SUCCESS;

    nbytes_in_buffer = sizeof ( me->ModuleInfo );
    gr$get_module_env ( msg = &msg,
			sizbuf = &nbytes_in_buffer,
			buffer = &(me->ModuleInfo),
			nret = &nbytes_transferred );
    if ( !(1 & msg) )
    {
	status = OM_E_ABORT;
    }
    else
    {
	nbytes_in_buffer = MAX_DB_TYPE_SIZE;
    }

    me->state = GET_CL_NAME;
    return ( status );

}

/*---------------------------------------------------------------------*/
/*		       COcvtclsl wakeup method                         */
/*---------------------------------------------------------------------*/


/*--------------------------------------------------------------------*/
/*                     COcvtclsl execute method			      */
/*--------------------------------------------------------------------*/


method execute (int *response; char *response_data; int pos )
{

	IGRlong           		om_msg;
	IGRlong           		msg;
	IGRlong		  		mask;
	struct GRevent	  		event;
	struct GRsymbol_lib_file	asl_file;
	IGRchar           		cell_lib_name[GR_MAX_CHAR]; 
	IGRchar           		seed_file[GR_MAX_CHAR]; 
	IGRboolean			exit;
        FILE                            *fp;


	om_msg = TRUE;
	exit = FALSE;
	mask = GRm_STRING;

	ex$message (msgnumb = GRC_M_CnvIGDSCelLib);

	while ( !exit )
	{
	    switch ( me->state )
	    {

		case GET_CL_NAME:

		    /*
	     	     *  prompt for the name of the cell library
  	     	     *  to translate
	     	     */

                    co$getevent(msg = &msg,
                                event_mask = mask,
                                msgnum = GR_P_EntIGDSCelLibNme,
                                response = response,
                                response_data = response_data,
                                event = &event);

	            if ( event.response == STRING )
  	            {
			strcpy ( cell_lib_name, event.event.keyin );

			me->state = GET_SEED_FILE;
		    }
		    else
		    {
			exit = TRUE;
		    }
		    break;

		case GET_SEED_FILE:

		    /*
		     *  prompt for the name of the IGDS seed file
		     */

		    mask |= GRm_RESET;
		    
                    co$getevent(msg = &msg,
                                event_mask = mask,
                                msgnum = GR_P_EntIGDSSdflNme,
                                response = response,
                                response_data = response_data,
                                event = &event);

		    if ( event.response == STRING )
		    {
			strcpy ( seed_file, event.event.keyin );
		        me->state = GET_SL_NAME;
		    }
		    else if ( event.response == RESET )
		    {
			seed_file[0] = NULL;
			me->state = GET_SL_NAME;
		    }
		    else 
		    {
			exit = TRUE;
		    }
		    break;

		case GET_SL_NAME:

		    /*
		     *  prompt for the name of the symbol
		     *  library to create
		     */		
		
		    mask ^= GRm_RESET;
	    
                    co$getevent(msg = &msg,
                                event_mask = mask,
                                msgnum = GR_P_EntEMSCelLibNme,
                                response = response,
                                response_data = response_data,
                                event = &event);

	            if ( event.response == STRING )
  	            {

		        strcpy ( asl_file.file_name, event.event.keyin );

                        /*  TR 92n2054  -  check to see if file already
                         *  exists.  Doree  6/25/92
                         */

                        fp = NULL;   /* initialize file pointer */

                        if ( fp = fopen(asl_file.file_name, "r") )
                        {
                          fclose(fp);  /* close it.  It will be opened later */

                          /* TR 119220393  -  just tell the user the file
                           * exists and then prompt again for a cell library
                           * name.  Doree 10/14/92
                           */

                          ex$message(msgnumb = GR_E_FileExists);

                          me->state = GET_SL_NAME;
                          break;

                        }

		        om_msg = om$send ( mode = OM_e_wrt_object,
				           msg = message COcvtclsl.cvt_cellib
					         ( &msg, cell_lib_name,
					           seed_file, &asl_file ),
				           senderid = my_id,
				           targetid = my_id );
		
			me->state = GET_CL_NAME;
			if ( msg == GUNOFILE )
			{
			    ex$message (msgnumb = GR_E_CantOpnIGDSCelLib);
			}
		    	else if ( msg == GUNOT_CELLIB )
			{
			    ex$message (msgnumb = GR_E_NotIGDSCelLib);
			}
		   	else if ( msg == GUNOT_IGDS )
			{
			    ex$message (msgnumb = GR_E_NotIGDSSdfl);
			}
			else if ( ! om_msg )
		        {
			    ex$message (msgnumb = GR_E_ErrCnvIGDSCelLib);
		 	}
			else
			{
		            ex$message (msgnumb = GR_I_CnvCmpl);	    
		            exit = TRUE;
		    	    *response = TERMINATE;  
		  	}			
		    }
		    break;

	    }  /* end switch */

	} /* end while */

   return(om_msg);
}


/*---------------------------------------------------------------------*/
/*		      COcvtclsl sleep method	       		       */
/*---------------------------------------------------------------------*/


end implementation COcvtclsl;
