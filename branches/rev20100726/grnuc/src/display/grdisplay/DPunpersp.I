class implementation IGEgragad;

#include <stdlib.h>
#include <stdio.h>
#include "grimport.h"
#include "dpdef.h"

#include "wl.h"
#include "igr.h"
#include "dl.h"

/* prototype files */
%safe
#include "DPunpersp.h"
%endsafe


int DPunpersp(msg,gg_id)

IGRlong *msg;
struct GRid *gg_id;
{
IGRint status;
 
status = OM_S_SUCCESS;
*msg = MSSUCC;

    status = om$send(mode = OM_e_wrt_object,
          msg = message IGEgragad.DPun_persp(msg),
                             senderid = NULL_OBJID,
                             targetid = gg_id->objid,
                             targetos = gg_id->osnum);
    	    if(! (1 & status))
    	    {
#ifdef DEBUG
            	printf("om send DPun_persp\n");
            	om$report_error(sts = status);
#endif
    	    } 
return (status);
}

method DPun_persp (IGRlong *msg)
{
	IGRint status = OM_S_SUCCESS;

	*msg = MSSUCC;

	ME.IGEgragad->gragad.flags = ME.IGEgragad->gragad.flags & ~ IS_PERSP;

	if ( DLdelete_drawing_pipeline( ME.IGEgragad->gragad.gpipe_id ) != DL_SUCCESS )
	   {
#ifdef DEBUG
	   printf("error in pipe id");
#endif
	   goto fini;
	   }

	if ( DLcreate_drawing_pipeline( DL_ORTHO_PIPE, ME.IGEgadget->win_no,
             &ME.IGEgragad->gragad.gpipe_id) != DL_SUCCESS )
	   {
#ifdef DEBUG
	   printf("error in getting pipe id");
#endif
	   goto fini;
	   }

	if ( DLset_curve_max_points( ME.IGEgragad->gragad.gpipe_id, 100 ) != DL_SUCCESS )
	   {
#ifdef DEBUG
	   printf("error in maxpts");
#endif
	   goto fini;
	   }

	status = om$send(mode = OM_e_wrt_object,
                 msg = message IGEgragad.DPcal ( msg ),
                 senderid = my_id,
                 targetid = my_id);

	if ( !(status & 1))
	   {
#ifdef DEBUG
	   printf("\nin DPset_persp:  DPcal send failed\n");
	   om$report_error(sts = status);
#endif
	   }

fini:
	return (status);

}

end implementation IGEgragad;
