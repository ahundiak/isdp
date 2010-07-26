class implementation IGEgragad;

#include <stdlib.h>
#include <stdio.h>

#include "exmacros.h"
#include "grimport.h"
#include "dpdef.h"
#include "dperr.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

#include "wl.h"
#include "dl.h"

/* prototype files */
%safe
#include "DPcvtpersp.h"
#include "DPphigsord.h"
#include "DPordphigs.h"

#include "mainvmx.h"
%endsafe

#define FIR_PERSP 1
#define DPCURPARAL 0x08078104
#define DPCURPERSP 0x0807810C

int DPcvtpersp(msg, gg_id,in_flags)

IGRlong *msg;
struct GRid *gg_id;
IGRint in_flags;

{
IGRint status;
 
status = OM_S_SUCCESS;
 
*msg = MSSUCC;

    status = om$send(mode = OM_e_wrt_object,
          msg = message IGEgragad.DPcvt_persp(msg, in_flags),
                               senderid = NULL_OBJID,
                               targetid = gg_id->objid,
                               targetos = gg_id->osnum);

    	    if(!(1 & status) && status != OM_E_ABORT)
    	    {
#ifdef DEBUG
            	printf("om send persp\n");
            	om$report_error(sts = status);
#endif
    	    } 
return (status);
}

method DPcvt_persp (IGRlong *msg; IGRint in_flags)

{
IGRboolean  update_all = FALSE;
IGRint status = OM_S_SUCCESS;	
IGRdouble act_z_stub;
IGRshort four = 4;
IGRdouble view_to_wld[4][4];
IGRdouble pnear;
IGRdouble pfar;


*msg = MSSUCC;

if (in_flags & DP_CVT_TO_PERSP)
{
   if (ME.IGEgragad->gragad.flags & IS_PERSP)
   {
	status = OM_E_ABORT;
	*msg = DPCURPERSP;
	goto fini;
   }
   else
   {

      status = om$send(mode = OM_e_wrt_object,
                       msg = message IGEgragad.DPfit(msg, 0),
                       senderid = NULL_OBJID,
                       targetid = my_id );

    	if(!MAinvmx(msg, &four, (IGRdouble *)ME.IGEgragad->gragad.wld_to_view,
			(IGRdouble *)view_to_wld))
    	{
    		goto fini;
    	}
        DPordphigs(msg,1,ME.IGEgragad->gragad.vw_volume,
		&ME.IGEgragad->gragad.act_z,
		 (IGRdouble *)ME.IGEgragad->gragad.wld_to_view,
		 ME.IGEgragad->gragad.vrp, ME.IGEgragad->gragad.vpn,
		 ME.IGEgragad->gragad.vup, ME.IGEgragad->gragad.eye_pt,
		 ME.IGEgragad->gragad.coi, &ME.IGEgragad->gragad.vw_angle,
		 &pnear, &pfar, &act_z_stub);
	ME.IGEgragad->gragad.vw_volume[2] = pnear;
	ME.IGEgragad->gragad.vw_volume[5] = pfar;
	ME.IGEgragad->gragad.act_z = act_z_stub;
    	ME.IGEgragad->gragad.flags |= IS_PERSP;  
    	ME.IGEgragad->gragad.flags |= FRONT_CLIP;  
    	ME.IGEgragad->gragad.flags |= BACK_CLIP;  
    	ME.IGEgragad->gragad.flags &= ~GRID_ON;

	if (!(ex$is_batch()))
	{
	    	if ( DLdelete_drawing_pipeline( ME.IGEgragad->gragad.gpipe_id ) != DL_SUCCESS )
	    	{
#ifdef DEBUG
		    printf("error in pipe id");
#endif
		    goto fini;
	    	}

	    	if ( DLcreate_drawing_pipeline( DL_PERSP_PIPE, ME.IGEgadget->win_no,
                               &ME.IGEgragad->gragad.gpipe_id ) != DL_SUCCESS )
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
	}
    }
}
else
{
   if (!(ME.IGEgragad->gragad.flags & IS_PERSP))
   {
	status = OM_E_ABORT;
	*msg = DPCURPARAL;
	goto fini;
   }
   else
   {
    	status = DPphigsord ( msg,1,ME.IGEgragad->gragad.vrp,
				ME.IGEgragad->gragad.vpn,
				ME.IGEgragad->gragad.vup,
				ME.IGEgragad->gragad.eye_pt,
				ME.IGEgragad->gragad.coi,
				&ME.IGEgragad->gragad.vw_angle,
				&ME.IGEgragad->gragad.vw_volume[2],
				&ME.IGEgragad->gragad.vw_volume[5],
				ME.IGEgragad->gragad.vw_volume,
				&act_z_stub,
				(IGRdouble *)ME.IGEgragad->gragad.rotation,
				ME.IGEgragad->gragad.origin);

    	ME.IGEgragad->gragad.flags = ME.IGEgragad->gragad.flags & ~ IS_PERSP;

	if (!(ex$is_batch()))
	{
	    	if ( DLdelete_drawing_pipeline( ME.IGEgragad->gragad.gpipe_id ) != DL_SUCCESS )
	    	{
#ifdef DEBUG
		    printf("error in pipe id");
#endif
		    goto fini;
	    	}

	    	if ( DLcreate_drawing_pipeline( DL_ORTHO_PIPE, ME.IGEgadget->win_no,
                        &ME.IGEgragad->gragad.gpipe_id ) != DL_SUCCESS )
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
	}
    }
}
if (( in_flags & DP_CAL) || (in_flags & DP_CVT_UPDATE))
{
    status = om$send(mode = OM_e_wrt_object,
                 msg = message IGEgragad.DPcal ( msg ),
                 senderid = my_id,
                 targetid = my_id);
    if ( !(status & 1))
    {
        if (*msg != DPVUPPRLVPN)
        {
#ifdef DEBUG
            printf("\nin DPcvt_persp:  DPcal send failed\n");
            om$report_error(sts = status);
#endif
        }
    }
}

if (in_flags & DP_CVT_UPDATE)
{
   if (!(ME.IGEgragad->gragad.flags & DP_DELAY))
   {
        status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPupdate(msg,NULL,
						&update_all),
                             senderid = my_id,
                             targetid = my_id);

	      	   if ( ! (1 & status) )
            	   {
#ifdef DEBUG
                	printf("\nIN DProtate Error send to window DPupdate\n");
                	om$report_error(sts = status);
#endif
                	goto fini;	  
            	    } 
    }
    else
    {
   	ex$message( msgnumb = GR_I_DlyOn);
    }
}
fini:
return(status);
}
end implementation IGEgragad;

