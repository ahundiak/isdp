/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	IGEsavedvw 
	METHOD NAME:	savedvw_cons

	Abstract:
-----
%SC%

	VALUE =

-----
%EN%

	ON ENTRY:
									
	NAME       DATA TYPE      	    DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%EX%

	ON EXIT:

	NAME       DATA TYPE      	    DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%RL%

	RELATIONS REFERENCED:


-----
%NB%


	
-----
%CH%

	CHANGE HISTORY

	MAS   08/12/86	: Design date.

-----
%PD%
--------------------------------------------------------------------
		M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


class implementation IGEsavedvw;

#include <stdio.h>
#include "grimport.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "dp.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "lydef.h"

/* prototype files */
%safe
#include "DPsvrecall.h"
#include "DPcal.h"
#include "DPunpersp.h"
#include "DPsetpersp.h"
#include "DPsetinq.h"
#include "GRdpbfunc.h"
#include "dpmacgenupd.h"
%endsafe


from IGEwinsup import view_recalled;

#if defined(__STDC__) || defined(__cplusplus)
IGRint savedvw_recall ( IGRlong      *msg,
                        IGRshort     in_flag,
                        IGRlong      array_size,
                        struct GRid  *wn_grids, 
                        struct GRid  *vw_grid )
#else
IGRint savedvw_recall (msg, in_flag, array_size, wn_grids, vw_grid)

IGRlong *msg; 
IGRshort in_flag; 
IGRlong array_size; 
struct GRid *wn_grids; 
struct GRid *vw_grid; 
#endif

{

IGRlong status = OM_S_SUCCESS;

    status = om$send ( msg = message IGEsavedvw.DPsv_recall
			( msg,in_flag,array_size,wn_grids ),
			senderid = NULL_OBJID,
			targetid = vw_grid->objid,
			targetos = vw_grid->osnum );

return (status);

}
method DPsv_recall (IGRlong *msg; IGRshort in_flags; IGRlong array_size; 
			struct GRid *wn_ids)
{
    struct var_list gad_list[2];
    struct gragad_inst gadget;
    IGRlong return_bytes;
    IGRlong status = OM_S_SUCCESS;
    IGRint j;
    IGRlong error;
    IGRint old_gad_flag;
    IGRint sizebuf;
    IGRshort active_ly;
    IGRboolean upd_flag;
    OM_S_CHANSELECT chandef;

    sizebuf=sizeof(IGRshort);

    gr$get_active_level(buffer=(IGRchar *)&active_ly);

    gad_list[0].var = GRAGAD_INST_STRUCT;
    gad_list[0].var_ptr = (IGRchar *)&gadget;
    gad_list[0].num_bytes = sizeof(struct gragad_inst);
    gad_list[0].bytes_returned = &return_bytes;
    gad_list[1].var = END_PARAM;


    for( j = 0; j < array_size; j++)
    {         
      	status = dp$inq_set_gragad(msg = msg, which_error = &error, 
			var_list = gad_list, gragad_objid =  wn_ids[j].objid,
                          osnum = wn_ids[j].osnum);
       if ( !(status & 1))
       {
#ifdef DEBUG
       	    printf("\nin DPrecallvw  DPinquire failed\n");
	    om$report_error(sts = status);
#endif
	    break;
       	}		
	gadget.min_x_indep = me->min_x_indep;
	gadget.min_y_indep = me->min_y_indep;
	gadget.max_x_indep = me->max_x_indep;
	gadget.max_y_indep = me->max_y_indep;

	old_gad_flag = gadget.gragad.flags;

	if (!(gadget.gragad.flags & IS_ACTIVE))
	{
	    me->gragad.flags = me->gragad.flags &~IS_ACTIVE;
	    upd_flag = 0;
	}
	else
	{
	    me->gragad.flags |= IS_ACTIVE;
	    upd_flag = 1;
	}

  	gadget.gragad.flags = me->gragad.flags;

	if (!(old_gad_flag & DPLEFT_SCREEN))
	{
	    
	    gadget.gragad.flags = gadget.gragad.flags &~DPLEFT_SCREEN;
	}

   	gadget.gragad.grid_per_ref_x = me->gragad.grid_per_ref_x;
   	gadget.gragad.grid_per_ref_y = me->gragad.grid_per_ref_y;
    	gadget.gragad.uor_per_ref_x = me->gragad.uor_per_ref_x;
    	gadget.gragad.uor_per_ref_y = me->gragad.uor_per_ref_y;

	gadget.gragad.display_mode = me->gragad.display_mode;

	OM_BLOCK_MOVE( me->gragad.levels,
			 gadget.gragad.levels,
			 sizeof(me->gragad.levels));
        LYset_level_on(active_ly, gadget.gragad.levels);  /* active layer on */

    	OM_BLOCK_MOVE( me->gragad.origin,
                       gadget.gragad.origin,
                       sizeof(me->gragad.origin));

    	OM_BLOCK_MOVE( me->gragad.rotation,
                       gadget.gragad.rotation,
                       sizeof(me->gragad.rotation));

    	OM_BLOCK_MOVE( me->gragad.vw_volume,
                       gadget.gragad.vw_volume,
                       sizeof(me->gragad.vw_volume));

    	gadget.gragad.act_z = me->gragad.act_z;

    	OM_BLOCK_MOVE( me->gragad.construct_plane,
                       gadget.gragad.construct_plane,
                       sizeof(me->gragad.construct_plane));

    	OM_BLOCK_MOVE( me->gragad.eye_pt,
                       gadget.gragad.eye_pt,
                       sizeof(me->gragad.eye_pt ));

    	OM_BLOCK_MOVE( me->gragad.coi,
                       gadget.gragad.coi,
                       sizeof(me->gragad.coi ));

        gadget.gragad.vw_angle = me->gragad.vw_angle;

    	OM_BLOCK_MOVE( me->gragad.vrp,
                       gadget.gragad.vrp,
                       sizeof(me->gragad.vrp ));

    	OM_BLOCK_MOVE( me->gragad.vpn,
                       gadget.gragad.vpn,
                       sizeof(me->gragad.vpn ));

    	OM_BLOCK_MOVE( me->gragad.vup,
                       gadget.gragad.vup,
                       sizeof(me->gragad.vup ));

       	status = dp$inq_set_gragad(msg=msg,
				   inq0_set1=1,
				   which_error=&error,
				   var_list= gad_list,
                                   gragad_objid= wn_ids[j].objid,
                                   osnum = wn_ids[j].osnum);
       	if ( !(status & 1))
       	{
#ifdef DEBUG
       	    printf("\nin IGEsvrecall  dp$set failed\n");
	    om$report_error(sts = status);
#endif
	    break;
       	}		

#ifndef IDRAW

	if ((!(old_gad_flag & IS_PERSP)) && (gadget.gragad.flags & IS_PERSP))
	{
   	    status = dp$set_persp ( msg = msg,
			   	gg_id = &wn_ids[j],
		   		in_flags = DP_CVT_WN_ONLY);
	    if ( !(status & 1))
       	    {
#ifdef DEBUG
       	    	printf("\nin IGEsvrecall  dp$set_persp failed\n");
	    	om$report_error(sts = status);
#endif
	    	break;
      	    }
	}
	else if ((old_gad_flag & IS_PERSP) && !(gadget.gragad.flags & IS_PERSP))
	{
	    status = dp$un_persp (msg = msg, gg_id = &wn_ids[j]);
      	    if ( !(status & 1))
            {
#ifdef DEBUG
       	    	printf("\nin IGEsvrecall  dp$un_persp failed\n");
	    	om$report_error(sts = status);
#endif
		break;
            }
	}
	else
#endif  /* IDRAW  */

	{
	    status = dp$calc_gragad_info (msg = msg, osnum = wn_ids[j].osnum,
			gragad_objid = wn_ids[j].objid);
      	    if ( !(status & 1))
            {
#ifdef DEBUG
       	    	printf("\nin IGEsvrecall  dp$calc_gragad_info failed\n");
	    	om$report_error(sts = status);
#endif
		break;
            }

	}
	status = om$make_chanselect (channame = "IGEgragad.winsup",
					p_chanselect = &chandef);
	if (!( 1 & status))
	{
#ifdef DEBUG
	    printf("Error in channel to winsup DPsavvwcons");
	    om$report_error(sts = status);
#endif
	    break;
	}
	status = om$send (msg = message IGEwinsup.view_recalled
					(msg,&wn_ids[j],NULL),
					senderid = my_id,
					p_chanselect = &chandef);

        /* protect against unknown objects */
        if (status == OM_E_NOSUCHCLASS ) status = OM_S_SUCCESS;

	if (!( 1 & status))
	{
#ifdef DEBUG
	    printf("Error in channel to winsup DPsavvwcons");
	    om$report_error(sts = status);
#endif
	    break;
	}
/*
	if (in_flags | DP_UPDATE)
*/
	if (in_flags & DP_UPDATE)
	{
	    if (upd_flag)
	    {	
       	    	status = dp$gen_update(msg = msg, objid = wn_ids[j].objid,
                             osnum = wn_ids[j].osnum);
 	    	if ( !(status & 1))
            	{
#ifdef DEBUG
       	    	    printf("\nREcallvw : Error send to window update\n");
       	    	    om$report_error(sts = status);
#endif
	    	} 
	    } /* close for if upd */
	} /* close for update */
    } /* close for for loop*/

return(status);
} /* close for method */

end implementation IGEsavedvw;
