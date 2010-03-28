class implementation COswapcopy;



#define SWAP 0
#define COPY 1

#include "stdio.h"
#include "OMerrordef.h"
#include "msdef.h"

#include "igr.h"

#include "fontdef.h"
#include "font.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "godef.h"

#include "msdef.h"
#include "msmacros.h"

#include "griodef.h"
#include "griomacros.h"

#include "grmessage.h"

%safe
#include "DPsetpersp.h"
#include "DPunpersp.h"
#include "DPsetinq.h"
#include "DPgetggid.h"
#include "dpmacgenupd.h"
%endsafe


from IGEgragad import DPcal;


#define _start 0
#define _get_window1 1
#define _get_window2 2

method load_window_prompt ( IGRint *sts; IGRint which_one )
{
  int		  status = OM_S_SUCCESS;

	IGRint message_no;

	*sts = OM_S_SUCCESS;

	switch( me->mytype )
	   {
	   case SWAP :

	      if ( which_one == 0 )
	         message_no = GR_P_IdWin1;
	      else
	         message_no = GR_P_IdWin2;
	      break;

	   case COPY :

	      if ( which_one == 0 )
	         message_no = GR_P_IdFrWin;
	      else
	         message_no = GR_P_IdToWin;
	      break;

	   default:

	     /* should never happen */
	     message_no = 0;
	   }  /* end: switch */

	ex$message( msgnumb = message_no, buff = me->prompt );

	return( OM_S_SUCCESS );

	quit:
  return OM_S_SUCCESS;
}

method get_selected_window ( IGRint *sts; IGRint which_one )
{
  int		  status = OM_S_SUCCESS;

	IGRlong      msg;
	IGRint       total_found;
	IGRint       num_ids;
	struct GRid  window_ids[40];

	*sts = OM_S_SUCCESS;

	if ( me->event1.response == EX_DATA )
	   {
	   /* user hit a data button in a window */
	   me->ids[which_one].objid = me->event1.event.button.objid;
	   me->ids[which_one].osnum = me->event1.event.button.osnum;
	   }
	else
	   {
	   /* user keyed in a window name */
	   num_ids = 0;

	   /* get the window id(s) from the string, but */
	   /* only select windows that are ON           */
	   dp$get_gragad_id( msg         = &msg,
	                     name        = me->event1.event.keyin,
                             array_size  = 40,
                             total_num   = &total_found,
	                     numberofids = &num_ids,
	                     found_GRids = window_ids,
	                     type_gragad = (ALL_GG_CLASSES | GG_WIN_ON) );

	   if ( num_ids == 0 )
	      {
	      /* Invalid window */
	      *sts = OM_W_WARNING;
	      ex$message( msgnumb = GR_E_WinNotFnd );
	      }
	   else if ( num_ids == 1 )
	      {
	      me->ids[which_one] = window_ids[0];
	      }
	   else
	      {
              *sts = OM_W_WARNING;
	      ex$message( msgnumb = GR_E_AmbNme );
	      }

	   }  /* end: else */

	/* if the window chosen was valid and the second window, check to see 
	   if it is the same window as the first window */

	if ((which_one == 1) && (*sts == OM_S_SUCCESS))
	   {
	   if ((me->ids[1].objid == me->ids[0].objid) && 
			(me->ids[1].osnum == me->ids[0].osnum))
	      {
	      *sts = OM_W_WARNING;
	      ex$message( msgnumb = GR_E_ErrSamWin );
	      }
	   }  /* end if */

	quit:
  return OM_S_SUCCESS;
}

method get_or_set_instance_data ( IGRint get0_set1; IGRint which_id; IGRint which_instance; )
{
  int		  status = OM_S_SUCCESS;

	struct var_list	inq_list[2];
	IGRlong         msg;
	IGRlong         ret_bytes;
	IGRlong         which_error;
	IGRlong         sts;
	struct GRid     *id;

	id = &me->ids[which_id];

	/* get/set wireframe instance */
	inq_list[0].bytes_returned = &ret_bytes;
	if ( get0_set1 == 0 )
	   {
	   inq_list[0].var            = GRAGAD_INST_STRUCT;
	   inq_list[0].var_ptr        = (IGRchar *) &me->wireframe_inst[which_instance];
	   inq_list[0].num_bytes      = sizeof( struct gragad_inst );
	   }
	else
	   {
	   inq_list[0].var            = GRAGAD_STRUCT;
	   inq_list[0].var_ptr        = (IGRchar *) &me->wireframe_inst[which_instance].gragad;
	   inq_list[0].num_bytes      = sizeof( struct DPgra_gad );
	   }


	inq_list[1].var = END_PARAM;

	sts = dp$inq_set_gragad( msg          = &msg,
	                         inq0_set1    = get0_set1,
	                         osnum        = id->osnum,
	                         gragad_objid = id->objid,
	                         which_error  = &which_error,
	                         var_list     = inq_list );
	
	if ( !(sts & 1))
	   {
#ifdef DEBUG
	   fprintf( stderr, "COswapcopy: dp$inq_set_gragad failed\n");
	   om$report_error(sts = sts);
#endif
	   return( OM_W_WARNING );
	   }

	return( OM_S_SUCCESS );

	quit:
  return OM_S_SUCCESS;
}

method process_windows ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRlong           msg;
	IGRint            i;
	IGRint            persp_flag;
	IGRint            start;
	IGRint            temp_id;
	IGRboolean        flag0, flag1;

	/* get the instance data for both windows */
	*sts = om$send( msg      = message COswapcopy.get_or_set_instance_data( 0, 0, 0 ),
	                targetid = my_id );

	if ( *sts != OM_S_SUCCESS )
	    return( *sts );

	*sts = om$send( msg      = message COswapcopy.get_or_set_instance_data( 0, 1, 1 ),
	                targetid = my_id );

	if ( *sts != OM_S_SUCCESS )
	    return( *sts );

	persp_flag = 0;
	if ( me->wireframe_inst[0].gragad.flags & IS_PERSP ) 
	   persp_flag |= 1;
	if ( me->wireframe_inst[1].gragad.flags & IS_PERSP ) 
	   persp_flag |= 2;

	/* fix the screen flags in the instance data */
	flag0 = me->wireframe_inst[0].gragad.flags & DPLEFT_SCREEN;
	flag1 = me->wireframe_inst[1].gragad.flags & DPLEFT_SCREEN;
	if ( me->mytype == SWAP )
	   {
	   if ( flag0 )
	      me->wireframe_inst[1].gragad.flags |= DPLEFT_SCREEN;
	   else
	      me->wireframe_inst[1].gragad.flags &= ~DPLEFT_SCREEN;
	   }

	if ( flag1 )
	   me->wireframe_inst[0].gragad.flags |= DPLEFT_SCREEN;
	else
	   me->wireframe_inst[0].gragad.flags &= ~DPLEFT_SCREEN;

	/* fix the collapsed (ACTIVE/INACTIVE) flags in the instance data   */
	/* don't need to fix the WIN_ON flags because only windows that are */
	/* ON could have been selected                                      */
	flag0 = me->wireframe_inst[0].gragad.flags & IS_ACTIVE;
	flag1 = me->wireframe_inst[1].gragad.flags & IS_ACTIVE;
	if ( me->mytype == SWAP )
	   {
	   if ( flag0 )
	      me->wireframe_inst[1].gragad.flags |= IS_ACTIVE;
	   else
	      me->wireframe_inst[1].gragad.flags &= ~IS_ACTIVE;
	   }

	if ( flag1 )
	   me->wireframe_inst[0].gragad.flags |= IS_ACTIVE;
	else
	   me->wireframe_inst[0].gragad.flags &= ~IS_ACTIVE;

	/* swap gpipe ids */
	temp_id = me->wireframe_inst[0].gragad.gpipe_id;
	me->wireframe_inst[0].gragad.gpipe_id = me->wireframe_inst[1].gragad.gpipe_id;
	me->wireframe_inst[1].gragad.gpipe_id = temp_id;

	/* save instance data in windows */
	if ( me->mytype == SWAP )
	   {
	   /* set instance data of window 1 into window 0 */
	   *sts = om$send( msg      = message COswapcopy.get_or_set_instance_data( 1, 0, 1 ),
	                   targetid = my_id );
	   }

	/* set instance data of window 0 into window 1 */
	*sts = om$send( msg      = message COswapcopy.get_or_set_instance_data( 1, 1, 0 ),
	                targetid = my_id );


	start = (me->mytype == SWAP) ? 0 : 1;

	/* have windows re-calculate their data */
	for ( i = start; i < 2; i++ )
	   {
	   *sts = om$send( msg      = message IGEgragad.DPcal( &msg ),
	                   targetid = me->ids[i].objid,
	                   targetos = me->ids[i].osnum );
	   }


	/* fix perspective mode of the windows */
	if ( persp_flag == 1 )
	   {
	   /* window 0 was perspective and window 1 wasn't */
	   if ( me->mytype == SWAP )
	      {
	      dp$un_persp( msg = &msg, gg_id = &me->ids[0] );
	      }

	   dp$set_persp( msg = &msg, gg_id = &me->ids[1], in_flags = DP_CVT_WN_ONLY );
	   }
	else if ( persp_flag == 2 )
	   {
	   /* window 1 was perspective and window 0 wasn't */
	   dp$un_persp( msg = &msg, gg_id = &me->ids[1] );

	   if ( me->mytype == SWAP )
	      {
	      dp$set_persp( msg = &msg, gg_id = &me->ids[0], in_flags = DP_CVT_WN_ONLY );
	      }
	   }
	   
	/* update windows */
	for ( i = start; i < 2; i++ )
	   {
	   dp$gen_update( msg = &msg, objid = me->ids[i].objid, osnum = me->ids[i].osnum );
	   }

	return( OM_S_SUCCESS );

	quit:
  return OM_S_SUCCESS;
}

end implementation COswapcopy;
