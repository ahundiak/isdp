class implementation COfillobj;



#include     <stdio.h>
#include     "grdpbmacros.h"
#include     "dpmacros.h"
#include     "godef.h"
#include     "execmsg.h"
#include     "grmessage.h"

%safe
#include "GRgs_fun.h"
#include "GRdpbfunc.h"
%endsafe

from GRgraphics import GRchgprops, GRgetprops;


#define _strt_state 0
#define _locate_elem 1

method getdpb_props ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRint      msg;
	IGRint      nret;
	IGRint      sizbuf;
	unsigned short   prop_wrd;

/* Get DPB's poperties word   */

        sizbuf = sizeof(unsigned short);
	status = gr$get_active_prop(msg=&msg,
	 		   	    sizbuf=&sizbuf,
			   	    buffer=(IGRchar *)&prop_wrd,
                           	    nret=&nret);
	if((msg == MSFAIL) || (!(status & 1)))
        {
#ifdef DEBUG
		om$report_error(sts = status);
		printf("\n get_active_prop failure in COfillmode ");
#endif
	}

/* Find out if GRFILLED_DISPLAY bit is set or not and 
						output appropriate message */

	me->what_mode = ((prop_wrd & GRFILLED_DISPLAY) ? 1 : 0);

	if (!me->what_mode)
	{
	     ex$message( msgnumb = GR_I_FillModeOff, field = ERROR_FIELD );
	}
	else
	{
	     ex$message( msgnumb = GR_I_FillModeOn, field = ERROR_FIELD );	
	}
quit:
  return OM_S_SUCCESS;
}

method setfill_type ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	if (me->event1.event.keyin[1] == 'n')
	{
	    me->what_mode=1;
	}
	else
	{
	    me->what_mode=0;
	}


	if (!me->what_mode)
	{
	     ex$message( msgnumb = GR_I_FillModeOff, field = ERROR_FIELD );
	}
	else
	{
	     ex$message( msgnumb = GR_I_FillModeOn, field = ERROR_FIELD );	
	}
quit:
  return OM_S_SUCCESS;
}

method obj_fill ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRlong     msg;
	IGRshort     prop_wrd;

/* Set the bit in prop_wrd based on the what_mode */

	prop_wrd = GRFILLED_DISPLAY;


    status = gr$gsremove_fence (msg = &msg, p_chanselect = &me->located_chansel);

	if(!(status & 1))
 	{
		me->ret= status;
		om$report_error(sts = status);
	}

    status = gr$gspass (msg = &msg,
                     pass_msg = message GRgraphics.GRchgprops (&msg, &me->what_mode, &prop_wrd),
                     senderid = my_id,
                     p_chanselect = &me->located_chansel);

	if(!(status & 1))
 	{
		me->ret= status;
		om$report_error(sts = status);
	}
quit:
  return OM_S_SUCCESS;
}

end implementation COfillobj;
