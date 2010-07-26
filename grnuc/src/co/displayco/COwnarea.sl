/*      declaration section      */

command_object           GRC_M_WinAr,0,GRCVAr
class                    COwnarea
product_name             "$GRNUC"
super_class              COwndmnpl
start_state              get_fence1

/*      specification section    */

specification

#include <stdio.h>
#include <FI.h>

#include "OMmacros.h"
#include "exdef.h"
#include "msdef.h"
#include "exmacros.h"
#include "msmacros.h"

#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "igrdef.h"
#include "igrdp.h"

instance
{
   struct GRevent       first_event;
   struct GRevent       *events[2];
   struct GRid		src_window;   /* the window fence is on */
				     /* display can be on other windows */

   struct DPele_header  element; 
   struct IGRpolyline	fence; 
   IGRdouble		fence_p[15];  /* for 5 points, (wld) */

   IGRint		fence_exists;     /* TRUE or FALSE */

   IGRdouble		wld_to_view[16];  
   IGRdouble		view_to_wld[16];

   IGRint		ref_plane_lock_mode;
}

/*      implementation section    */

implementation

#include <FI.h>
#include "OMmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "exmacros.h"
#include "grdpbmacros.h"
#include "exdef.h"
#include "dpstruct.h"
#include "dpcomacros.h"
#include "grmsg.h"
#include "EMdtmacros.h"
#include "EMSdatumdef.h"

%safe
/* include for DYblock.h prototypes */
struct block_st
  { 
    struct DPele_header          elem;
    IGRdouble                    pts[3];
    IGRdouble                    dirv[3];
  };

#include "DPsetinq.h"
#include "dpexbell.h"
#include "DYblock.h"

#ifdef CLIX
#include "EFrefpln.h"
#endif

#include "dpdisplay.h"
#include "dpmacerahil.h"

#include "mainvmx.h"
#include "maptsxfor.h"
#include "mamulmx.h"
#include "maidmx.h"
%endsafe

from IGEgragad import DPerase_hilite,DPwnarea;


/*       state table section       */

state_table

#include "grcmd.h"
#include "grmsg.h"
#include "codpdef.h"

#define DRAW_FENCE 101

state *
	on EX_RESTART     state get_fence1
	on EX_BACK_UP     state -

at init
   do my_init

at wakeup
   do my_wakeup

at sleep
   do my_sleep

state get_fence1
   message_key			 GRC_M_WinAr
   prompt_key			 GR_P_EntFstDiaPt
   execute			 erase_fence()
   filter                            get_event

   on EX_DATA                        do store_fence1()
                                     state get_fence2

state get_fence2
   prompt_key			GR_P_EntSecDiaPt
   dynamics			DRAW_FENCE
   filter                            get_event

   on EX_DATA                        do store_fence2()
				     state get_window

state get_window
   prompt_key			 GR_P_SelWin
   filter                            get_event

   on EX_DATA or TEXT_VALUE  do get_graphic_gadget(DstGGid,MAX_WINDOW,ExstGG)
                                       on SrchFlt state get_window
                                       on SUCCESS do fence_zoom()
                                                    on ERROR  state terminate
			               		  state get_window
			          state get_window

   on EX_RJT_MOVEON		     state get_fence1	


/*      action declaration section      */


/*----- dynamics ------------------------------------------------------*/

action dynamics	/* (int dynamics; int *sts) */

	{
	DYrbblock( me->events, &me->ActiveDisplay );
	}

action erase_fence()
{
    IGRlong msg;

    if( me->fence_exists )
    {

       om$send(msg = message IGEgragad.DPerase_hilite(&msg),
		targetid =  me->src_window.objid,
		targetos = me->src_window.osnum);

       me->fence_exists = FALSE;
    }
}

action store_fence1()
{
     struct DPgra_gad   gg;
     struct var_list    inq_array[2];      /* which vars to inquire      */
     IGRlong            error_var;
     IGRlong            nbytes_ret;
     IGRlong            msg;
     IGRdouble          trans[4][4];
     IGRshort           four=4;


   me->src_window.objid = me->event1.event.button.objid;
   me->src_window.osnum = me->event1.event.button.osnum;

   /* store first event in case user does something other */
   /* than a DATA point while in dynamics which will      */
   /* overwrite me->event1 resulting in problems when we  */
   /* try to re-enter dynamics                            */
   me->first_event = me->event1;

   me->events[0] = &me->first_event;

   /*
    * save the wld point 
    */

   me->fence_p[0] = me->event1.event.button.x;
   me->fence_p[1] = me->event1.event.button.y;
   me->fence_p[2] = me->event1.event.button.z;

   me->fence_p[12] = me->event1.event.button.x;
   me->fence_p[13] = me->event1.event.button.y;
   me->fence_p[14] = me->event1.event.button.z;

   /*
    *  calculate the matrix for dp_fence() use 
    */

    inq_array[0].var = GRAGAD_STRUCT;
    inq_array[0].var_ptr = (IGRchar *)&gg;
    inq_array[0].num_bytes = sizeof(struct DPgra_gad);
    inq_array[0].bytes_returned = &nbytes_ret;
    inq_array[1].var = END_PARAM;

    status = dp$inq_set_gragad(msg = &msg,
                      gragad_objid = me->src_window.objid,
                             osnum = me->src_window.osnum,
                       which_error = &error_var,
                          var_list = inq_array);

    if (gg.flags & IS_PERSP)
    {
    	MAidmx(&msg,(IGRdouble *)trans);
    	trans[0][3] = -gg.eye_pt[0];
    	trans[1][3] = -gg.eye_pt[1];
    	trans[2][3] = -gg.eye_pt[2];
    	MAmulmx(&msg,&four,&four,&four,(IGRdouble *)gg.rotation,
                (IGRdouble *)trans,me->wld_to_view);
	
    }
    else
    {
	OM_BLOCK_MOVE(gg.wld_to_view, me->wld_to_view, sizeof(IGRdouble)*16);
    }

    MAinvmx(&msg,&four,me->wld_to_view,me->view_to_wld);

}

action store_fence2()   /* diagnol point */
{
   IGRlong msg;

   me->fence_p[6] = me->event1.event.button.x;  
   me->fence_p[7] = me->event1.event.button.y;
   me->fence_p[8] = me->event1.event.button.z;

   om$send(msg = message COwnarea.dp_fence(&msg,&me->fence_p[6]),
		targetid = my_id);

   me->fence_exists = TRUE;
}


action dp_fence(IGRlong *msg; IGRdouble *point; )
{
    IGRlong   num_points;

   /*
    * calculate the other two wld points of the fence
    */

    num_points = 1;

    MAptsxform(msg,&num_points,me->wld_to_view,&me->fence_p[0],&me->fence_p[0]);
    MAptsxform(msg,&num_points,me->wld_to_view,point,&me->fence_p[6]);

    me->fence_p[3] = me->fence_p[6]; 
    me->fence_p[4] = me->fence_p[1];
    me->fence_p[5] = me->fence_p[8];

    me->fence_p[9]  = me->fence_p[0];
    me->fence_p[10] = me->fence_p[7];
    me->fence_p[11] = me->fence_p[8];
    
    num_points = 4;
    MAptsxform(msg,&num_points,me->view_to_wld,&me->fence_p[0],&me->fence_p[0]);

    dp$erase_hilite( msg = msg, osnum = me->src_window.objid );

    dp$display( msg = msg,
		buffer = &me->element,
		mode = GRhd,
	        osnum  = me->src_window.osnum,
	        objid =  me->src_window.objid);

}


action fence_zoom()
{
    IGRint i;
    IGRlong msg;
    IGRdouble wld_vol[6];  /* the two diagnal points of the fence */


   /*
    * for each window, do fence zoom 
    */

    for(i=0;i<3;i++)
    {
	wld_vol[i] = me->fence_p[i];		/* 1st point */
	wld_vol[i+3] = me->fence_p[i+6];	/* 2nd point */
    }

    for ( i = 0; i < me->num_id; i++)
    {
    	status = om$send(mode = OM_e_wrt_object,
                          msg = message IGEgragad.DPwnarea(&msg,0, 
				wld_vol, (IGRboolean)TRUE),
                                     senderid = my_id,
                                     targetid = me->ggid[i].objid,
                                     targetos = me->ggid[i].osnum);
        if ( ! (1 & status) )
       	{
#ifdef DEBUG
       	    printf("\nIN COwnarea Error DPwnarea\n");
#endif
            om$report_error(sts = status);
      	    goto quit;
    	} 
	if (msg == DPDGNSLIMIT )
    	{
	    ex$message ( msgnumb = GR_I_MinWin);
	    EX_bell();
	    sleep(2);
	    ex$message (msgnumb = EX_S_Clear);
        }
   }  /* end for */

}


action my_init
{
    me->fence_exists = FALSE;

    me->fence.points = me->fence_p;
    me->fence.num_points = 5; 

    dp$build_dis_buffer(buffer = &me->element,
		      display_att = &me->ActiveDisplay,
		      geometry = &me->fence,
		      type = IGRPY );
}


action my_wakeup
{
    IGRlong msg;

    /* turn ref plane lock off, if it is on */
    ems$ref_plane_lock(	msg = &msg,
	                options = EMS_REF_PLANE_LOCK_INQ,
	                mode = &me->ref_plane_lock_mode );

    if ( me->ref_plane_lock_mode == EMS_REF_PLANE_LOCK_ON )
        {
        ems$ref_plane_lock( msg = &msg,
	                    options = EMS_REF_PLANE_LOCK_OFF | EMS_REF_PLANE_LOCK_SET );
        }

    if ( me->fence_exists )
    {
       dp$display(   msg = &msg,
	        buffer = &me->element,
		mode = GRhd,
	        osnum  = me->src_window.osnum,
	        objid =  me->src_window.objid);
    }
}

action my_sleep
{
    IGRlong msg;

    /* turn ref plane lock back on, if required */
    if (me->ref_plane_lock_mode == EMS_REF_PLANE_LOCK_ON)
        {
        ems$ref_plane_lock( msg = &msg,
	                    options = EMS_REF_PLANE_LOCK_ON | EMS_REF_PLANE_LOCK_SET );
        }

    if ( me->fence_exists )
    {
       om$send(msg = message IGEgragad.DPerase_hilite(&msg),
		targetid =  me->src_window.objid,
		targetos = me->src_window.osnum);

    }
}
