class implementation COwndmnpl;



#include <stdio.h>
#include <string.h>

%safe
#include "GRicvtalfn.h"
%endsafe

#include "dperr.h"
#include "griodef.h"
#include "griomacros.h"
#include "OMmacros.h"
#include "dp.h"
#include "dpstruct.h"
#include "igewindow.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "igewinerr.h"
#include "exmacros.h"
#include "execmsg.h"
#include "csdef.h"
#include "csmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

%safe
/* prototype files */
#include "dpexbell.h"
#include "numstr.h"
#include "DPactivate.h"
#include "HSref_plane.h"
#include "DPsetinq.h"
#include "DPgetggid.h"
#include "DPviewvol.h"
%endsafe

#define  MOVE_WIN 55
#if defined ( ENV5 )
#define WIN_ORIG   0.0882353
#else
#define WIN_ORIG   0.0848416
#endif

static GRobjid win_id;

from IGEgadget import add_gadget, activate;
from IGEgragad import gragad_cons,DPset,DPinquire;
from IGEgragad import DPcenter,DPwnarea,DPscroll;
from IGEwindow import clear,DPset,DPinquire;
from IGEdisplay import DPupdate;



method wakeup_act ( long * sts )
{
  int		  status = OM_S_SUCCESS;


    if (me->mytype == 10)
    {
 	ex$message ( msgnumb = GRC_M_WinOn);
    }
    else if(me->mytype == 11)
    {
	ex$message ( msgnumb = GRC_M_WinOff);
    }
    else if (me->mytype == 6)
    {
	ex$message ( msgnumb = GRC_M_DpDpDep);
    }
    else if (me->mytype == 5)
    {
	ex$message ( msgnumb = GRC_M_DpActDep);
    }
    else if (me->mytype == 7)
    {
	ex$message ( msgnumb = GRC_M_DpVwVol);
    }
quit:
  return OM_S_SUCCESS;
}

method get_act_dep ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	    *sts = OM_S_SUCCESS;

            if ( me->event1.response == EX_VALUE )
            {
               if (me->event1.subtype != GRst_DEFAULT)
               {
		  me->send_flags = 0;
                  me->act_z[2] = me->event1.event.value;
               }
            }
            else  if ( me->event1.response == EX_DATA )
            {
	       me->send_flags = NONABS_Z;
               me->act_z[0] = me->event1.event.button.x;
               me->act_z[1] = me->event1.event.button.y;
               me->act_z[2] = me->event1.event.button.z;
            }

quit:
  return OM_S_SUCCESS;
}

method get_wnd ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRint i;
    IGRlong msg;
    IGRshort num_alias;
    IGRshort ret_flags;
    IGRshort field_size = sizeof(IGRchar) * DP_MAX_ALIAS_SIZE;
    IGRdouble new_active_z;
    IGRchar cvt_list[DP_MAX_ALIAS_SIZE];

	    *sts = OM_S_SUCCESS;

            for( i = 0; i < me->num_id; i++)
            {

		me->send_flags =  me->send_flags | ACTIVE_Z_EDGE | WORLD_COOR | SETIN;	

		status = dp$view_vol ( msg = &msg, in_flags = me->send_flags, 
				ret_flags = &ret_flags, gg_id = &me->ggid[i], 
				active_z = me->act_z,
			 	new_active_z = &new_active_z);
 		if (!(status & 1))
		{
#ifdef DEBUG
               	    printf("\nin COwnactive z error\n");
#endif
		    om$report_error(sts = status);
		    *sts = status;
		    goto quit;
		}
		  num_alias = 1;
		  status = co$cvt_imp_to_alias (msg = &msg,
			     unit_type = GRIO_DISTANCE, 
			     osnum = me->ggid[i].osnum,
			     working_units = &new_active_z, 
			     num_alias = &num_alias, 
			     inverse_scale_flag=GRIO_Z_SCALE,
			     field_size = &field_size,
			     cvt_list = (IGRchar **)cvt_list);
 		if (!(status & 1))
		{
#ifdef DEBUG
               	    printf("\nin COwnactz  cvt error\n");
#endif
		    om$report_error(sts = status);
		    *sts = status;
		    goto quit;
		}
		    if(ret_flags & ACT_Z_FRONT || ret_flags & ACT_Z_BACK )
		    {
		     ex$message ( msgnumb = GR_I_ActDepSetDpDep , 
		     type = "%s", var = `cvt_list`, justification = LEFT_JUS);
		    }
		    else if (ret_flags & ACTIVE_Z_MIDDLE)
		    {
			ex$message(msgnumb = GR_I_ZDpSMDp);
		    }

		    else
		    {
		      ex$message ( msgnumb = GR_I_ActDepEq , 
		      type = "%s", var = `cvt_list`, justification = LEFT_JUS);
		    }

              }   /* end of For */
quit:
  return OM_S_SUCCESS;
}

method idnt_wnd1 ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRint i;
    IGRlong msg;
    IGRdouble wld_vol[6];

	    *sts = OM_S_SUCCESS;

            for ( i = 0; i < me->num_id; i++)
            {
		OM_BLOCK_MOVE(me->pts,wld_vol,sizeof(IGRdouble)*6);
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
		    *sts = status;
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

quit:
  return OM_S_SUCCESS;
}

method crt_window ( long * sts )
{
  int		  status = OM_S_SUCCESS;


    GRobjid gragad_id;
    IGRlong msg;
    IGRint y_ht;
    IGRdouble mv_factor;
    GRobjid mod_id;
    GRspacenum osnum;
    int sts1;

     	*sts = OM_S_SUCCESS;
     	/* make sure that window is still valid. (i.e. enter Window1, invoke
     	   another create window with name Window1 and create it, pop off 
     	   stack to first Window1 and it would create 2 Window1 windows*/
        status = om$send(mode = OM_e_wrt_object,
                           	msg = message 
                           	     COwndmnpl.verify_window_name(&sts1,1),
                           	senderid = my_id,
                           	targetid = my_id);
        *sts=sts1;

	if (*sts != SrchFlt)
	{
    	  	ex$get_cur_mod ( id = &mod_id, osnum = &osnum);

		/** first construct the gragad **//** TR 90N2000 **/
           	status = om$construct(osnum = osnum, 
				classname = "IGEgragad",
				obj_osnum = osnum, 
				p_objid = &gragad_id,
				msg = message IGEgragad.gragad_cons(&msg,
				me->long_name,0,0,1.0,1.0), 
				neighbor = OM_GS_NULL_NEIGHBOR);

          	if (!(1 & status))
          	{/* invalid name might not be the problem but probably is */
			ex$message(msgnumb = GR_E_InvNme);
	      		*sts = status;
              		goto cleanup1;
          	}
                ige$inq_term_info(y_extent=&y_ht);
                mv_factor= (1.0 * MOVE_WIN / y_ht);
		/** now construct the window **/
	  	status = ige$construct_win (	msg = &msg,
						win_class = "GRwindow",  
						screen = CURRENT_SCREEN,
						win_objid = &win_id,
						mod_id = mod_id,
						mod_osnum = osnum,
						min_x = 0.004222973,
						min_y = WIN_ORIG+mv_factor,
						max_x = 0.4131,
						max_y = 0.47512+mv_factor);
          	if (!(1 & status))
          	{
	      		*sts = status;
              		goto cleanup;
          	}

		/** add gadget to the window **/
          	status = om$send(mode = OM_e_wrt_object,
                           	msg = message IGEgadget.add_gadget(&msg,
			   		&gragad_id,1),
                           	senderid = my_id,
                           	targetid = win_id,
                           	targetos = osnum);

          	if (!(1 & status))
          	{
	      		*sts = status;
	      		goto cleanup;
          	} 

		/** activate the gragad 
		    Do not update because the orientation selected will
		    do an update and only want to update once **/
		DPactivate_update(FALSE);
		status = om$send(mode = OM_e_wrt_object,
			msg = message IGEgadget.activate((IGRlong *)sts, 0),
			senderid = my_id,
			targetid = win_id,
			targetos = osnum);
		DPactivate_update(TRUE);

		if (!(1 & status))
		{
			if (*sts == IGENOCREWIN)
			{
				EX_bell();
				ex$message ( msgnumb = GR_E_MaxNumWin);
				sleep(2);
			}
			else
			{
#ifdef DEBUG
				printf("COwncre - Execute: Error in activating window\n");
#endif
				om$report_error(sts = status);
				*sts = status;
			}
		}
		else
		{
			/* Setup ref. plane information for this window.  This     */
			/* functionality has to be implemented in MODEL because of */
			/* problems with MODEL classes.  A stub is provided in     */
			/* $GRNUC/src/stubs in case GRNUC is linked w/out MODEL    */
			HSsetup_ref_plane_for_window( gragad_id, osnum );
		}
	
		if (!(1 & status))
		{
	
		cleanup:
			status = om$send(mode = OM_e_wrt_object,
	                           msg = message Root.delete(1),
	                           senderid = my_id,
	                           targetid = win_id,
	                           targetos = osnum);
	          	if (!(1 & status))
	          	{
#ifdef DEBUG
			    printf("COwncre error sending to window delete\n");
#endif
		            om$report_error(sts = status);
		      	    *sts = status;
			}
	
		cleanup1:
			    *sts = SrchFlt;
			status = om$send(mode = OM_e_wrt_object,
	                           msg = message Root.delete(1),
	                           senderid = my_id,
	                           targetid = gragad_id,
	                           targetos = osnum);
	          	if (!(1 & status))
	          	{
#ifdef DEBUG
			    printf("COwncre error sending to window delete\n");
#endif
		            om$report_error(sts = status);
		      	    *sts = status;

			}
	
		}
		else
		{
			/* store window info */
			me->num_id=1;
			me->ggid[0].objid=gragad_id;
			me->ggid[0].osnum=osnum;
		}
       	}/* end !SrchFlt (not already a window that name) */
quit:
  return OM_S_SUCCESS;
}

method get_wndctr ( long * sts )
{
  int		  status = OM_S_SUCCESS;


    IGRint i;
    IGRlong msg;
    IGRdouble temp[3];

	    *sts = OM_S_SUCCESS;

            for( i = 0; i < me->num_id; i++)
            {
		temp[0] = me->pts[0];
		temp[1] = me->pts[1];
		temp[2] = me->pts[2];
		
	        status = om$send(mode = OM_e_wrt_object,
                                 msg = message IGEgragad.DPcenter(&msg, temp,
				 (IGRboolean)TRUE),
                                 senderid = my_id,
                                 targetid = me->ggid[i].objid,
                                 targetos = me->ggid[i].osnum);
                if ( ! (1 & status) )
	        {
#ifdef DEBUG
	            printf("\nIN COwnctr Error send to window DPcenter\n");
#endif
	            om$report_error(sts = status);
		    *sts = status;
		    goto quit;
	        } 
	
		if (msg == DPDGNEDGE)
		{
		    ex$message ( msgnumb = GR_I_EdgDgnFl);
		    EX_bell();
		    sleep(2);
		}
		else if (msg == DPDGNLIMIT)
		{
		    ex$message ( msgnumb = GR_I_MaxWin);
		    EX_bell();
		    sleep(1);
		}
             }  /* end for  */

quit:
  return OM_S_SUCCESS;
}

method dspl ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRshort i;
    IGRshort num_alias;
    IGRshort field_size = sizeof(IGRchar) * DP_MAX_ALIAS_SIZE;
    struct var_list var_list[4];
    IGRlong msg;
    IGRlong ret_bytes;
    IGRlong which_error;
    IGRdouble act_z;
    IGRdouble display_depths[2];
    IGRdouble vw_volume[6];
    IGRchar cvt_list[6][DP_MAX_ALIAS_SIZE];
    IGRchar *cvt_list_ptr[6];
    IGRint  new_strlen[2];

    	    *sts = OM_S_SUCCESS;

	    var_list[0].var = WLD_VOLUME;
	    var_list[0].var_ptr = (IGRchar *)vw_volume;
   	    var_list[0].num_bytes = sizeof(IGRdouble)*6;
  	    var_list[0].bytes_returned = &ret_bytes;

	    
	    var_list[1].var = WLD_ACT_Z;
	    var_list[1].var_ptr = (IGRchar *)&act_z;
   	    var_list[1].num_bytes = sizeof(IGRdouble);
  	    var_list[1].bytes_returned = &ret_bytes;

	    var_list[2].var = WLD_DISPLAY_DEPTHS;
	    var_list[2].var_ptr = (IGRchar *)display_depths;
   	    var_list[2].num_bytes = sizeof(IGRdouble)*2;
  	    var_list[2].bytes_returned = &ret_bytes;

	    var_list[3].var = END_PARAM;

	cvt_list_ptr[0] = (IGRchar *)cvt_list;
	cvt_list_ptr[1] = &cvt_list[1][0];
	cvt_list_ptr[2] = &cvt_list[2][0];
	cvt_list_ptr[3] = &cvt_list[3][0];
	cvt_list_ptr[4] = &cvt_list[4][0];
	cvt_list_ptr[5] = &cvt_list[5][0];

          for( i = 0; i < me->num_id ; i++)
          {         
            /* get view volume and act z */

	     status = om$send(mode = OM_e_wrt_object,
                                     msg = message IGEgragad.DPinquire 
				     (&msg, &which_error, var_list),
                                     senderid = my_id,
                                     targetid = me->ggid[i].objid,
                                     targetos = me->ggid[i].osnum);
             if ( !(status & 1))
             {
#ifdef DEBUG
               	printf("\nin COwndepthd  DPinquire failed\n");
#endif
		om$report_error(sts = status);
		*sts = status;
		goto quit;
             }		
            if(me->mytype == 6)
            {
		  num_alias = 1;
		status = co$cvt_imp_to_alias (msg = &msg,
			     unit_type = GRIO_DISTANCE, 
			     osnum = me->ggid[0].osnum,
			     working_units = display_depths, 
			     num_alias = &num_alias, 
			     field_size = &field_size,
			     inverse_scale_flag=GRIO_Z_SCALE,
			     num_conversions = 2,
			     cvt_list = cvt_list_ptr);
                if ( !(status & 1))
                {
#ifdef DEBUG
               	    printf("\nin COwndepthd  cvt error\n");
#endif
		    om$report_error(sts = status);
		    *sts = status;
		    goto quit;
             	}		
		
		numstr(&msg,cvt_list_ptr,cvt_list_ptr,DP_MAX_ALIAS_SIZE,
			1,new_strlen);

		ex$message ( msgnumb = GR_I_Two , type = "%s%s", 
				var = `cvt_list_ptr[0], cvt_list_ptr[1]`,
				 justification = LEFT_JUS);

            }
            else if(me->mytype == 5)
            {
		num_alias = 1;
		status = co$cvt_imp_to_alias (msg = &msg,
			     osnum = me->ggid[0].osnum,
			     unit_type = GRIO_DISTANCE, 
			     working_units = &act_z, 
			     num_alias = &num_alias, 
			     field_size = &field_size,
			     inverse_scale_flag=GRIO_Z_SCALE,
			     cvt_list = (IGRchar **)cvt_list);
                if ( !(status & 1))
                {
#ifdef DEBUG
               	    printf("\nin COwndepthd  cvt error\n");
#endif
		    om$report_error(sts = status);
		    *sts = status;
		    goto quit;
             	}		
			ex$message ( msgnumb = GR_I_ActDepEq , 
			type = "%s", var = `cvt_list`);
            }
	    else /* type 7 display view vol */
	    {

		  num_alias = 1;
		  status = co$cvt_imp_to_alias (msg = &msg,
			     osnum = me->ggid[0].osnum,
			     unit_type = GRIO_DISTANCE, 
			     working_units = vw_volume, 
			     num_alias = &num_alias, 
			     num_conversions = 6,
			     inverse_scale_flag=GRIO_NO_SCALE,
			     field_size = &field_size,
			     cvt_list = cvt_list_ptr);
                if ( !(status & 1))
                {
#ifdef DEBUG
               	    printf("\nin COwndepthd  cvt error\n");
#endif
		    om$report_error(sts = status);
		    *sts = status;
		    goto quit;
             	}		
		numstr(&msg,cvt_list_ptr,cvt_list_ptr,DP_MAX_ALIAS_SIZE,
			2,new_strlen);
		
		if ((new_strlen[0] + new_strlen[1] + strlen(cvt_list_ptr[2]) + 3) > 42)
		{
		   ex$message ( msgnumb = GR_I_XEq, type ="%s", 
		   		var = `cvt_list_ptr[0]`, 
		   		justification = LEFT_JUS);
		   sleep(2);
		   ex$message ( msgnumb = GR_I_YEq, type ="%s", 
		   		var = `cvt_list_ptr[1]`, 
		   		justification = LEFT_JUS);
		   sleep(2);
		   ex$message ( msgnumb = GR_I_ZEq, type ="%s", 
		   		var = `cvt_list_ptr[2]`, 
		   		justification = LEFT_JUS);
		   sleep(2);
		}
		else
		{
		   ex$message ( msgnumb = GR_I_Thre, type ="%s%s%s", 
		   		var = `cvt_list_ptr[0],cvt_list_ptr[1],cvt_list_ptr[2]`, 
		   		justification = LEFT_JUS);
		   sleep(2);
		}
		numstr(&msg,&cvt_list_ptr[3],&cvt_list_ptr[3],
			DP_MAX_ALIAS_SIZE,2,new_strlen);
		
		if ((new_strlen[0] + new_strlen[1] + strlen(cvt_list_ptr[5]) + 3) > 42)
		{
		   ex$message ( msgnumb = GR_I_XEq, type ="%s", 
		   		var = `cvt_list_ptr[3]`, 
		   		justification = LEFT_JUS);
		   sleep(2);
		   ex$message ( msgnumb = GR_I_YEq, type ="%s", 
		   		var = `cvt_list_ptr[4]`, 
		   		justification = LEFT_JUS);
		   sleep(2);
		   ex$message ( msgnumb = GR_I_ZEq, type ="%s", 
		   		var = `cvt_list_ptr[5]`, 
		   		justification = LEFT_JUS);
		}
		else
		{
		   ex$message ( msgnumb = GR_I_Thre, type ="%s%s%s", 
		   		var = `cvt_list_ptr[3],cvt_list_ptr[4],cvt_list_ptr[5]`, 
		  		 justification = LEFT_JUS);
		}
	    }   /* end of else me->mytype == 7    */
          } /*end for */

quit:
  return OM_S_SUCCESS;
}

method init_depths ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	    me->send_flags = 0;
            me->def_depths[0] = 0;
	    me->def_depths[1] = 0;
quit:
  return OM_S_SUCCESS;
}

method pntdepths (IGRint  flag)
{
  int		  status = OM_S_SUCCESS;


            if ( me->event1.response == VALUE )
            {
               if(me->event1.subtype == GRst_DEFAULT)
               {
                 	if(flag == FrstPt)
                 	{
                      		me->def_depths[0] = 1;
		 	}
                 	else 
                 	{
                      		me->def_depths[1] = 1;
		      		if(me->def_depths[0] == 1)
                          	ex$message(msgnumb = GR_I_DpDepNoCh);
                 	}
                 
               }
               else 
               {
                 	if(flag == FrstPt)
                     		me->pts[2] = me->event1.event.value;
                 	else
                     		me->pts[5] = me->event1.event.value;
               }
            }
	    else if (me->event1.response == EX_RJT_MOVEON )
	    {
                 if(flag == FrstPt)
		 {
                 	me->def_depths[0] = 1;
		 }
		 else  
		 {
                 	me->def_depths[1] = 1;
		        if(me->def_depths[0] == 1)
                          ex$message(msgnumb = GR_I_DpDepNoCh);
		 }
	    }

quit:
  return OM_S_SUCCESS;
}

method init_vwvols ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRint      i;

	    me->send_flags = 0;
	    for (i=0; i < 3; i++)
	    {
            	me->defaults[i] = 0;
            	me->defaults[i+3] = 0;
	    }
quit:
  return OM_S_SUCCESS;
}

method vwvols (IGRint  flag)
{
  int		  status = OM_S_SUCCESS;


/* IGRlong status; */

          if ( me->event1.response == VALUE )
          {
               if(me->event1.subtype == GRst_DEFAULT)
               {
                      me->defaults[flag] = 1;
               }
               else 
               {
                  	me->pts[flag] = me->event1.event.value;

               }
          }
          else if (me->event1.response == EX_RJT_MOVEON )
	  {
                me->defaults[flag] = 1;
	  }

quit:
  return OM_S_SUCCESS;
}

method storepnts (IGRint  index)
{
  int		  status = OM_S_SUCCESS;

	IGRint	ind =0;

	if(index == FrstPt) 
        {
	   ind = 0;
           if(me->mytype == 8)
	       me->send_flags |= NONABS_DD1;
	}
        else if (index == ScndPt)
        {
           ind = 3;
           if(me->mytype == 8)
              me->send_flags |= NONABS_DD2;
	}
	me->pts[ind] = me->event1.event.button.x;
	me->pts[ind+1] = me->event1.event.button.y;
	me->pts[ind+2] = me->event1.event.button.z;
quit:
  return OM_S_SUCCESS;
}

method idnt_wnd ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;
    IGRint i;
    IGRdouble depths[6];
    IGRdouble view_vol[6];
    IGRdouble new_active_z;
    IGRshort num_alias;
    IGRshort ret_flags;
    IGRshort field_size = sizeof(IGRchar) * DP_MAX_ALIAS_SIZE;
    IGRchar cvt_list[DP_MAX_ALIAS_SIZE];

            for( i = 0; i < me->num_id; i++)
            {

		me->send_flags |= FRONT_CLIP | BACK_CLIP | 
					ACTIVE_Z_EDGE | WORLD_COOR | SETIN;
	    	if (me->mytype == 9)
		{
		    OM_BLOCK_MOVE(me->pts,view_vol,sizeof(IGRdouble)*3);
		    OM_BLOCK_MOVE(&me->pts[3],&view_vol[3],sizeof(IGRdouble)*3);				
		    status = dp$view_vol(msg = &msg,in_flags = me->send_flags, 
				ret_flags = &ret_flags, gg_id = &me->ggid[i], 
				vw_vol = view_vol, 
				defaults_vol = me->defaults,
			 	new_active_z = &new_active_z,
			 	update = TRUE);
 		    if (!(status & 1)) goto quit;
		}
		else if (me->mytype == 8)
		{
		    OM_BLOCK_MOVE(me->pts,depths,sizeof(IGRdouble)*3);
		    OM_BLOCK_MOVE(&me->pts[3],&depths[3],sizeof(IGRdouble)*3);				

		    status = dp$view_vol(msg = &msg, in_flags = me->send_flags, 
				ret_flags = &ret_flags, gg_id = &me->ggid[i], 
				display_depths = depths,
			 	def_dis_depths = me->def_depths,
			 	new_active_z = &new_active_z,
				update = TRUE);
 		    if (msg==DPFarEqNear) 
		    {
		    	ex$message(msgnumb = GR_E_ErrFarDepEqNr);
		    	goto quit;
		    }
 		    if (!(status & 1))
		    {
#ifdef DEBUG
               	    	printf("\nin COwndepthk  view volerror\n");
#endif
		    	om$report_error(sts = status);
			*sts = status;
			goto quit;
		    }
		}
		
                if(ret_flags & ACT_Z_FRONT || ret_flags & ACT_Z_BACK )
                {
		      num_alias = 1;
		      status = co$cvt_imp_to_alias (msg = &msg,
			     unit_type = GRIO_DISTANCE, 
			     osnum = me->ggid[i].osnum,
			     working_units = &new_active_z, 
			     num_alias = &num_alias, 
			     inverse_scale_flag=GRIO_Z_SCALE,
			     field_size = &field_size,
			     cvt_list = (IGRchar **)cvt_list);
 		    if (!(status & 1))
		    {
#ifdef DEBUG
               	    	printf("\nin COwndepthk  cvt error \n");
#endif
		    	om$report_error(sts = status);
			goto quit;
		    }
			ex$message ( msgnumb = GR_I_ActDepSetDpDep , 
					type = "%s", var = `cvt_list`, 
					justification = LEFT_JUS);
                }
		if (msg == DPDGNEDGE)
		{
		    ex$message ( msgnumb =GR_I_EdgDgnFl);
		    EX_bell();
		}
		else if (msg == DPDGNLIMIT)
		{
		    ex$message ( msgnumb = GR_I_MaxWin);
		    EX_bell();
		}
		else if (msg == DPDGNSLIMIT)
		{
		    ex$message ( msgnumb = GR_I_MinWin);
		    EX_bell();
		}
             }  /* end of for  */
quit:
  return OM_S_SUCCESS;
}

method wnd_off ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    struct var_list var_list[2];
    struct var_list var_list1[2];
    IGRint flags[2];
    IGRlong msg;
    IGRlong num_bytes;
    IGRlong which_error;
    IGRint  i,size;
    OMuint  count;
    OM_S_CHANNUM  chan_num;
    OM_S_CHANSELECT  chandef;
    OM_S_OBJECT_LINKAGE   list;

    	   *sts = OM_S_SUCCESS;

	    var_list[0].var = GRAGAD_FLAGS;
	    var_list[0].var_ptr = (IGRchar *)flags;
	    var_list[0].num_bytes = sizeof(IGRint)*2;
	    var_list[0].bytes_returned = &num_bytes;

	    var_list[1].var = END_PARAM;

	    var_list1[0].var = WINDOW_FLAGS;
	    var_list1[0].var_ptr = (IGRchar *)flags;
	    var_list1[0].num_bytes = sizeof(IGRint)*2;
	    var_list1[0].bytes_returned = &num_bytes;

	    var_list1[1].var = END_PARAM;
	
            for( i = 0; i < me->num_id; i++)
            {
                     	flags[0] = IS_WIN_ON;
			flags[1] = 0;

               	     	status = om$send(mode = OM_e_wrt_object,
                              msg = message IGEgragad.DPset 
			     (&msg, &which_error, var_list),
                                     senderid = my_id,
                                     targetid = me->ggid[i].objid,
                                     targetos = me->ggid[i].osnum);
	                if ( !(status & 1))
 	                {
#ifdef DEBUG
               			printf("\nin COwnonoff  DPset failed\n");
#endif
				om$report_error(sts = status);
				*sts = status;
				goto quit;
    		         }		

			status = om$get_channel_number
				(channame = "IGEgadget.to_parent",
                                   p_channum = &chan_num);
			if(! (1 & status))
			{
#ifdef DEBUG
   			    printf("om convert channame to number error in COwnonoff\n");
#endif
      			    om$report_error(sts = status);
			    *sts = status;
			    goto quit;
			}
			chandef.type = OM_e_num;
    			chandef.u_sel.number = chan_num;
			size = 1;
			status = om$get_channel_objects(osnum=me->ggid[i].osnum,
                                  objid = me->ggid[i].objid,
                                  p_chanselect = &chandef,
				  list=&list,
				  size=size,  
                                  count = &count);
			if(! (1 & status))
			{
#ifdef DEBUG
   			    printf("om get channel objects error in COwnonoff\n");
#endif
  			    om$report_error(sts = status);
			    *sts = status;
			    goto quit;
    			}
                      /* erase window */               
                      /* delete env 5 window,set win instance data bit */
                      /* erase window */


                     	flags[0] = WIN_IS_ON;
			flags[1] = 0;

               	     	status = om$send(mode = OM_e_wrt_object,
                              msg = message IGEwindow.DPset 
			     (&msg, &which_error,
                              (struct win_var_list *)var_list1),
                                     senderid = my_id,
                                     targetid = list.S_objid,
                                     targetos = me->ggid[i].osnum);
	                if ( !(status & 1))
 	                {
#ifdef DEBUG
               			printf("\nin COwnonoff  DPset failed\n");
#endif
				om$report_error(sts = status);
			        *sts = status;
			        goto quit;
    		         }		

                      status = om$send(mode = OM_e_wrt_object,
                                       msg = message IGEwindow.clear(&msg),
                                       senderid = my_id,
                                       targetid = list.S_objid,
                                       targetos = me->ggid[i].osnum);
                      if ( ! (1 & status) )
                      {
#ifdef DEBUG
                          printf("\nError COwnonoff send to clear\n");
#endif
                          om$report_error(sts = status);
			  *sts = status;
			  goto quit;
                      } 
            }/* end for */

quit:
  return OM_S_SUCCESS;
}

method wnd_on ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    struct var_list var_list[2];
    struct var_list var_list1[2];
    IGRint flags[2];
    IGRlong msg;
    IGRlong num_bytes;
    IGRlong which_error;
    IGRint  i,size;
    OMuint  count;
    OM_S_CHANNUM  chan_num;
    OM_S_CHANSELECT  chandef;
    OM_S_OBJECT_LINKAGE   list;

    	   *sts = OM_S_SUCCESS;

		    var_list[0].var = GRAGAD_FLAGS;
		    var_list[0].var_ptr = (IGRchar *)flags;
		    var_list[0].num_bytes = sizeof(IGRint)*2;
		    var_list[0].bytes_returned = &num_bytes;

		    var_list[1].var = END_PARAM;

		    var_list1[0].var = WINDOW_FLAGS;
		    var_list1[0].var_ptr = (IGRchar *)flags;
		    var_list1[0].num_bytes = sizeof(IGRint)*2;
		    var_list1[0].bytes_returned = &num_bytes;

		    var_list1[1].var = END_PARAM;
		        
                   for( i = 0; i < me->num_id; i++)
                   {
			status = om$get_channel_number
				(channame = "IGEgadget.to_parent",
                                   p_channum = &chan_num);
			if(! (1 & status))
			{
#ifdef DEBUG
   			    printf("om convert channame to number error in COwnonoff\n");
#endif
      			    om$report_error(sts = status);
			    *sts = status;
		            goto quit;
			}
			chandef.type = OM_e_num;
    			chandef.u_sel.number = chan_num;
			size = 1;
			status = om$get_channel_objects(osnum=me->ggid[i].osnum,
                                  objid = me->ggid[i].objid,
                                  p_chanselect = &chandef,
				  list=&list,
				  size=size,  
                                  count = &count);
			if(! (1 & status))
			{
#ifdef DEBUG
   			    printf("om get channel objects error in COwnonoff\n");
#endif
  			    om$report_error(sts = status);
			    *sts = status;
		            goto quit;
    			}

            	     	status = om$send(mode = OM_e_wrt_object,
                              msg = message IGEwindow.DPinquire 
			     (&msg, &which_error, (struct win_var_list *)var_list1),
                                     senderid = my_id,
	                             targetid = list.S_objid,
                                     targetos = me->ggid[i].osnum);
	                if ( !(status & 1))
 	                {
#ifdef DEBUG
               			printf("\nin COwnonoff  DPset failed\n");
#endif
				om$report_error(sts = status);
			        *sts = status;
		                goto quit;
    		         }		
			if (!( flags[0] & WIN_IS_ON ))
			{
                      	    flags[0] = IS_WIN_ON;
  			    flags[1] = flags[0];

                            /* set gragad flags            */
            	     	    status = om$send(mode = OM_e_wrt_object,
                                     msg = message IGEgragad.DPset 
			                   (&msg, &which_error, var_list),
                                     senderid = my_id,
                                     targetid = me->ggid[i].objid,
                                     targetos = me->ggid[i].osnum);
	                    if ( !(status & 1))
 	                    {
#ifdef DEBUG
               			printf("\nin COwnonoff  DPset failed\n");
#endif
				om$report_error(sts = status);
			        *sts = status;
		                goto quit;
    		             }		

                      	    flags[0] = WIN_IS_ON;
  			    flags[1] = flags[0];

                             /* set  win flags            */
            	     	     status = om$send(mode = OM_e_wrt_object,
                              msg = message IGEwindow.DPset 
					(&msg, &which_error, 
					(struct win_var_list *)var_list1),
                                     senderid = my_id,
	                             targetid = list.S_objid,
                                     targetos = me->ggid[i].osnum);
	                    if ( !(status & 1))
 	                    {
#ifdef DEBUG
               			printf("\nin COwnonoff  DPset failed\n");
#endif
				om$report_error(sts = status);
			        *sts = status;
		                goto quit;
    		    	    }		

                             status = om$send(mode = OM_e_wrt_object,
                                          msg = message 
					      IGEwindow.activate(&msg,0),
                                              senderid = my_id,
	                                       targetid = list.S_objid,
                                     	      targetos = me->ggid[i].osnum);
	     		    if (msg == IGENOCREWIN)
	     		    {
				EX_bell();
				ex$message ( msgnumb = GR_E_MaxNumWin);
				sleep(2);
				*sts = status;
				goto quit;
	     		     }
			     else if ( ! (1 & status) )
                             {
#ifdef DEBUG
                                 printf("\nError send to window activate\n");
#endif
                                 om$report_error(sts = status);
			         *sts = status;
		                 goto quit;
                             } 
                     } /* if( !(flags  ...   */
                  }/* end for */

quit:
  return OM_S_SUCCESS;
}

method get_wnd_name ( long * sts )
{
  int		  status = OM_S_SUCCESS;


	*sts = OM_S_SUCCESS;

	me->event0 = me->event1;

quit:
  return OM_S_SUCCESS;
}

method rnm_wnd ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;
    OMuint  count;
    IGRlong return_bytes;
    IGRlong which_error;
    IGRlong name_len;
    IGRint  win_no;
    struct var_list var_list[2];
    struct var_list inq_no_list[2];
    OM_S_CHANSELECT chandef;
    OM_S_OBJECT_LINKAGE list;	
    int dj=0;
    *sts = OM_S_SUCCESS;


    /** check whether the given name is a regular exp **/

#ifdef DEBUG
printf("window_name: %s\n", me->event0.event.keyin );
#endif

    status = di$is_regexp( regexp = me->event0.event.keyin );
    if(status == DIR_S_SUCCESS){
	ex$message ( msgnumb = GR_E_InvNme);
	*sts = SrchFlt;
	goto quit;
    }

#ifdef DEBUG
printf("window_name: %s is not a regexp\n", me->event0.event.keyin );
#endif


    /** check if the given name is "." or ".." **/

    while( (me->event0.event.keyin[dj]==' ') ||
		(me->event0.event.keyin[dj]=='\t') ) dj++;

	if(me->event0.event.keyin[dj]=='.'){
		dj++;
		if (me->event0.event.keyin[dj]=='.') dj++;

		while( (me->event0.event.keyin[dj]==' ') ||
		       	(me->event0.event.keyin[dj]=='\t') ) dj++;

		if(me->event0.event.keyin[dj]=='\0'){			
			ex$message ( msgnumb = GR_E_InvNme);
			*sts = SrchFlt;
			goto quit;
		}
	}

    
    /* check if name exists */

    me->num_id = 0;
    dp$get_gragad_id(	msg = &msg,
		   	name = me->event0.event.keyin,
			numberofids = &me->num_id, 
			found_GRids = me->ggid);

    if ( me->num_id != 0){
	ex$message ( msgnumb = GR_E_DupNme);
	*sts = SrchFlt;
	goto quit;
    }

#ifdef DEBUG
printf("window_name: %s is not a duplicate name\n", me->event0.event.keyin );
#endif

          /*        if(me->event0.response == TEXT_VALUE)
                  {
          */
		    	inq_no_list[0].var = WIN_NO;
	    	    	inq_no_list[0].var_ptr = (IGRchar *)&win_no;
			inq_no_list[0].num_bytes = sizeof(IGRint);
	    		inq_no_list[0].bytes_returned = &return_bytes;
	    		inq_no_list[1].var = END_PARAM;

	                status = dp$inq_set_gragad(msg= &msg,
						osnum=me->ggid[0].osnum,
						gragad_objid= me->ggid[0].objid,
						which_error= &which_error,
						var_list=inq_no_list);

		    	if( ! (1 & status) )
	            	{
			    *sts = status;
#ifdef DEBUG
	             	    printf("\nIn rename inquire_gragad failed\n");
#endif
			    goto quit;
	            	}
	/*	    }*/ /* if (me-> event1.response .. */

		    chandef.type = OM_e_name;
		    chandef.u_sel.name = "IGEgadget.to_parent";

		    status = om$get_channel_objects (osnum=me->ggid[0].osnum,
					    objid=me->ggid[0].objid,
					    p_chanselect=&chandef,
					    list=&list,
					    size=1,
					    count=&count);
		    if( ! (1 & status) )
		    {
#ifdef DEBUG
             	        printf("\nIn rename om$get_channel_objects failed\n");
#endif
			om$report_error  (sts = status);
			*sts = status;
			goto quit;
  		    } 


		    name_len = strlen(me->event0.event.keyin) + 1;
		    var_list[0].var = GRAGAD_NAME;
	    	    var_list[0].var_ptr = me->event0.event.keyin;
		    var_list[0].num_bytes = name_len;
		    var_list[0].bytes_returned = &return_bytes;
		    var_list[1].var = END_PARAM;

                    status = dp$inq_set_gragad(msg= &msg,
						inq0_set1=1,
						osnum=me->ggid[0].osnum,
						gragad_objid=me->ggid[0].objid,
						which_error= &which_error,
						var_list=var_list);

		    if( ! (1 & status) )
	            {
#ifdef DEBUG
	               printf("\nIn rename set_gragad failed\n");
#endif
			*sts = status;
			goto quit;
	            }

		    var_list[0].var = WINDOW_NAME;
                    status = ige$inq_set_window(msg= &msg,
						inq0_set1=1,
						osnum=me->ggid[0].osnum,
						window_objid= list.S_objid,
						which_error= &which_error,
						var_list=(struct win_var_list *)var_list);

		    if( ! (1 & status) )
	            {
#ifdef DEBUG
	                printf("\nIn rename inq_set_window failed\n");
#endif
			*sts = status;
			goto quit;
	            }

quit:
  return OM_S_SUCCESS;
}

method get_pt11 ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	       *sts = OM_S_SUCCESS;

               me->ggid[0].osnum = me->event1.event.button.osnum;
               me->ggid[0].objid = me->event1.event.button.objid;
quit:
  return OM_S_SUCCESS;
}

method get_pt22 ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong vw_vol_msg;

	       	    *sts = OM_S_SUCCESS;

	            status = om$send(mode = OM_e_wrt_object,
                                     msg = message IGEgragad.DPscroll 
				     (&vw_vol_msg,me->pts,(IGRboolean)TRUE),
                                     senderid = my_id,
                                     targetid = me->ggid[0].objid,
                                     targetos = me->ggid[0].osnum);
                    if ( !(status & 1))
                    {
#ifdef DEBUG
                      	printf("\nin COwnscrolli.I DPscroll failed\n");
#endif
			om$report_error(sts = status);
			*sts = status;
			goto quit;
		    }
		if (vw_vol_msg == DPDGNEDGE)
		{
		    ex$message ( msgnumb = GR_I_EdgDgnFl);
		    EX_bell();
		    sleep(2);
		}
		else if (vw_vol_msg == DPDGNLIMIT)
		{
		    ex$message ( msgnumb = GR_I_MaxWin );
		    EX_bell();
		    sleep(1);
		}

quit:
  return OM_S_SUCCESS;
}

method idntfywnd ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;
    IGRboolean flag = FALSE;
    OM_S_OBJID	  objectid;
    GRspacenum	  osnum;
    IGRint	i;

	*sts = OM_S_SUCCESS;


         for( i = 0; i < me->num_id; i++)
	    {
	    objectid = me->ggid[i].objid;
	    osnum = me->ggid[i].osnum;

            status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPupdate
						(&msg,NULL,&flag),
                            senderid = my_id,
                            targetid = objectid,
                            targetos = osnum);
	    }

         if ( ! (1 & status) )
            {
#ifdef DEBUG
            printf("\nError send to window update\n");
#endif
            om$report_error(sts = status);
            *sts = status;
            } 

quit:
  return OM_S_SUCCESS;
}

method get_all_graphic_gadgets ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	
	IGRlong		msg;
	char		str_name[20];

	me->ret = OM_S_SUCCESS;
	me->num_id = 0;
        
 	strcpy(str_name, "*"); 	

	dp$get_gragad_id(msg = &msg,
			name = str_name,
			array_size = MAX_WINDOW,
			numberofids = &me->num_id, 
			found_GRids = me->ggid);

	/* checking for existing windows succeeds if num_id = 1 or > 1 */
        if ( me->num_id == 0)
        {
	       ex$message ( msgnumb = GR_E_WinNotFnd);
	       me->ret = SrchFlt;
	       goto quit;
        }

quit:
  return OM_S_SUCCESS;
}

method check_wnd_name ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   int dj;
   *sts = OM_S_SUCCESS;

   /** check whether the given name is a regular exp **/
   status = di$is_regexp( regexp = me->event1.event.keyin );
   if(status == DIR_S_SUCCESS)
   {
	ex$message ( msgnumb = GR_E_InvNme);
	*sts = SrchFlt;
   }

   /* check for '.' or '..' they are bad because are directory */
   dj=0;
   if(me->event1.event.keyin[dj]=='.')
   {
	dj++;
	if (me->event0.event.keyin[dj]=='.') dj++;
	while( (me->event1.event.keyin[dj]==' ') ||
		(me->event1.event.keyin[dj]=='\t') ) dj++;

	if(me->event1.event.keyin[dj]=='\0')
	{			
		ex$message ( msgnumb = GR_E_InvNme);
		*sts = SrchFlt;
		goto quit;
	}
   }

   /* check for : or , (would need a \ before but would lead
      to trouble later on)  , designates as seperator and : is
      used in directory system */
   dj=0;
   while( (me->event1.event.keyin[dj]!='\0') )
   {
    	dj++;
    	if ((me->event1.event.keyin[dj]==':')
    	  ||(me->event1.event.keyin[dj]==','))
	{
		ex$message ( msgnumb = GR_E_InvNme);
		*sts = SrchFlt;
		goto quit;
	}
   }

quit:
  return OM_S_SUCCESS;
}

method verify_window_name (IGRint *sts; IGRboolean use_default)
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;

     	*sts = OM_S_SUCCESS;
     	me->num_id = -1;

        /* if keyin = null use default name */
	if ((me->event1.event.keyin[0]==0)||use_default) 
	{
          	me->num_id = 0;
	  	status = dp$get_gragad_id(msg = &msg,
				name = me->long_name,
				numberofids = &me->num_id, 
				found_GRids = me->ggid);

	  	if (!(status & 1))
	  	{
			ex$message(msgnumb = GR_E_InvNme);
		    	*sts = SrchFlt;
			goto quit;			
	   	}
          	if ( me->num_id != 0)
          	{
			ex$message ( msgnumb = GR_E_DupNme);
			*sts = SrchFlt;
			goto quit;
          	}
       	} 
       	else
       	{
		/** check if the given name is "." **/
		int dj=0;
		while( (me->event1.event.keyin[dj]==' ') ||
		       (me->event1.event.keyin[dj]=='\t') ) dj++;

		if(me->event1.event.keyin[dj]=='.')
		{
			dj++;
			if (me->event0.event.keyin[dj]=='.') dj++;
			while( (me->event1.event.keyin[dj]==' ') ||
		       		(me->event1.event.keyin[dj]=='\t') ) dj++;

			if(me->event1.event.keyin[dj]=='\0')
			{			
				ex$message ( msgnumb = GR_E_InvNme);
				*sts = SrchFlt;
				goto quit;
			}
	         }

		/** check whether the given name is a regular exp **/
#ifdef DEBUG
		printf("window_name: %s\n", me->event1.event.keyin );
#endif
	  	status = di$is_regexp( regexp = me->event1.event.keyin );
 	  	if(status == DIR_S_SUCCESS)
 	  	{
			ex$message ( msgnumb = GR_E_InvNme);
			*sts = SrchFlt;
			goto quit;
	  	}
#ifdef DEBUG
		printf("window_name: %s is not a regexp\n", me->event1.event.keyin );
#endif
          	/* check if name exists */
          	me->num_id = 0;
	  	status = dp$get_gragad_id(msg = &msg,
				name = me->event1.event.keyin,
				numberofids = &me->num_id, 
				found_GRids = me->ggid);

	  	if (!(status & 1))
	  	{
			ex$message(msgnumb = GR_E_InvNme);
		    		*sts = SrchFlt;
				goto quit;			
	   	}
          	if ( me->num_id != 0){
			ex$message ( msgnumb = GR_E_DupNme);
			*sts = SrchFlt;
			goto quit;
          	}
	  	else
			strcpy(me->long_name,me->event1.event.keyin);
#ifdef DEBUG
		printf("window_name: %s is not a duplicate name\n", me->event1.event.keyin );
#endif
		
	}
quit:
  return OM_S_SUCCESS;
}

end implementation COwndmnpl;
