/* Command definition section */
options			"t"
product_name		"$GRNUC"
class			COviewmnpl
super_class		COwindow
start_state 		terminate

/* Specification section .. code for .S file */

specification

#include "dpsavevw.h"
#include "dpstruct.h"

instance 
{
    
    struct GRevent event11;
    struct GRevent event22;
    IGRchar name[32];
    IGRlong return_bytes;
    IGRdouble zoom_factor;
    GRspacenum sv_osnum;
    struct GRid sv_grid;
    IGRint	action;

    struct  GRid  vwid1[32];
    struct  GRid  vwid2[32];
   
    IGRdouble  rotation[4][4];

    IGRdouble wld_volume[6];

    struct IGRpolyline	  line;
    struct DPele_header       element;
    struct IGRespy            LineSpecific;
    struct GRevent events[2];
    struct IGRdisplay display_info;	
    IGRdouble angle1;
    IGRdouble   temp_pts1[6];
    IGRdouble	angles[3];
    IGRint	bufr_def;

    /*  for the retrieve saved view command */

    IGRint           row_selected;
    struct sv_info   *save_vw;
}

/* implementation section - code for .I file */

implementation

#define     SAVE_VIEW_FORM   0
#define     SAVE_EXIT_BTN    1
#define     EXIT_BTN         4
#define     CVT_TO_WINDOW    5
#define     SAVVW_MESSAGE_FIELD 10
#define     SAVVW_NAME_DESCRIPT 12

#define     ANGLE1	0
#define     ANGLE2	1
#define	    ANGLE3	2
#define	    ID_VIEW     3
#define     dyn_in_vwrotn  4

#include <string.h>
#include <stdio.h>
#include <FI.h>

#include "OMerrordef.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrdef.h"
#include "dp.h"
#include "dperr.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "DPedtsv.h"
#include "msdef.h"
#include "ma.h"

from IGEgragad import DPupdate, DProtate;
from IGEgragad import DPinquire;
from IGEsavedvw import savedvw_cons;
from IGEgragad import DPzoom;

#if defined(__STDC__) || defined(__cplusplus)
struct DYline_params 
{
    IGRlong                 msg;
    struct GRevent         *events[2];
    IGRshort                NumberOfEvents;
    struct DPele_header    *line;
};
#endif

%safe
#include "DYlinear.h"
#include "DPsvrecall.h"
#include "dpexbell.h"
#include "dpsetvw.h"
#include "DPviewvol.h"
#include "DPsvinquire.h"
#include "DPsavvwcons.h"
#include "DPsetinq.h"
#include "DPgetsavvwid.h"
#include "DPtotnumvw.h"
#include "GRdpbfunc.h"
#include "dpdisplay.h"

#include "mainvmx.h"
#include "maptsxfor.h"
#include "malncbcli.h"
#include "marotmx.h"
#include "mamulmx.h"
#include "ma3protmx.h"
#include "maidmx.h"
%endsafe

action my_delete
   {

   /*  for the 'retrieve save view' command, if the save_vw has been */
   /*  allocated, free it */

   if( me->save_vw ) free( me->save_vw );
   }

action init_act
{
    IGRlong msg = MSSUCC;
    GRobjid mod_id;
    GRspacenum  mod_osnum;
    IGRlong	total;

    /*  for the 'retrieve save view' command, initialize the save_vw  */
    /*  instance data variable to NULL */

    me->save_vw = NULL;

    if(me->mytype == 0 || me->mytype == 3)
    {
    	status = ex$get_cur_mod( id=&mod_id, 	
		osnum=&me->sv_osnum);
	if (!( 1 & status))
	{
#ifdef DEBUG
	    printf("Error in get_cur_mod");
#endif
	}
    	me->action = 0;
     }

     if (me->mytype == 1 || me->mytype == 2 || me->mytype == 3)
     {

  /*find number of saved views*/
    	status = ex$get_cur_mod( id=&mod_id, 	
		osnum=&mod_osnum);

	if (!( 1 & status))
	{
#ifdef DEBUG
	    printf("Error in get_cur_mod");
#endif
	}

	status = dp$total_num_saved_vw ( msg = &msg,
				osnum=&mod_osnum,
                        total_num = &total);

	 if ((!( 1 & status)) || ( !total))
	 {
            if (( msg == DPVWSMNODEF ) || (!total))
            {
		ex$message ( msgnumb = GR_E_NoSavedViewsDef );
		me->state = _terminate;
	        status = OM_I_STOP_SENDING;
		goto quit;
            }
	

         }
     }

     if (me->mytype == 6 || me->mytype == 7)
     {
	me->zoom_factor = 2.0;
     }
     if(me->mytype == 8)
     {
      me->bufr_def = FALSE;

/*	dp$display (msg = &msg,
		mode = GRhd,
		osnum = me->events[0].event.button.osnum,
		buffer = &me->element);
*/
     } 
}

action nme_savvw
{        
    IGRlong num_vw;
    IGRlong msg;

	me->ret = OM_S_SUCCESS;
	me->event11 = me->event1;

	status = dp$get_saved_vw_id(msg=&msg,
				   name=me->event1.event.keyin,
			    numberofids=&num_vw,
			    found_GRids=me->vwid2);

	if(! (1 & status))
	{
#ifdef DEBUG
	   printf("error in DPgetvwid ... COrenamevwi.I ");
#endif
	   *sts = status;
	   goto quit;
	}
	
	if (num_vw != 0)
	{
	   EX_bell();
	   ex$message ( msgnumb = GR_E_DupNme );
	   me->ret = SrchFlt;
	   goto quit;
	}		     


	if (me->action ==1)
        {
	   me->ret = Cnstr;
        }
	else 
        {
	   me->ret = Descr;
        }
}

action descr
{
	*sts = OM_S_SUCCESS;
	if (me->event1.response == EX_RJT_MOVEON)
	{
	    me->event1.event.keyin[0] = '\0';
	}
	me->event22 = me-> event1;
}
action origin
{

    IGRlong msg;
    IGRlong error;
    IGRlong num_points = 1;
    IGRdouble wld_to_view[16];
    IGRdouble view_to_wld[16];
    IGRlong return_bytes;
    IGRshort   n = 4 ;
    struct var_list var_list[4];
    IGRdouble   vw_volume[6];
	
	    *sts = OM_S_SUCCESS;
	    num_points = 1;
 
	    var_list[0].var = GRAGAD_NAME;
    	    var_list[0].var_ptr = me->name;
    	    var_list[0].num_bytes = sizeof(IGRchar) * 32;
    	    var_list[0].bytes_returned = &me->return_bytes;
	    var_list[1].var = VW_VOLUME;
	    var_list[1].var_ptr = (IGRchar *)vw_volume;
	    var_list[1].num_bytes = sizeof(IGRdouble)*6;
	    var_list[1].bytes_returned = &return_bytes;
	    var_list[2].var = WLD_TO_VIEW;
	    var_list[2].var_ptr = (IGRchar *)wld_to_view;
	    var_list[2].num_bytes = sizeof(IGRdouble)*16;
	    var_list[2].bytes_returned = &return_bytes;    
	    var_list[3].var = END_PARAM;
	
	    dp$inq_set_gragad (msg =&msg, which_error = &error, 
			      var_list = var_list, 
			      gragad_objid = me->ggid[0].objid,
                              osnum =  me->ggid[0].osnum);
            if ( !(status & 1))
            {
#ifdef DEBUG
               	printf("\nin COsavevw  DPinquire failed\n");
#endif
		om$report_error(sts = status);
		*sts = status;
		goto quit;
            }

   	    switch (me->event1.response)
	    {
		case EX_RJT_MOVEON:
		case EX_STRING:
			if (!MAinvmx(&msg, &n, wld_to_view, view_to_wld))
			{
			    *sts = FunFail;
			    goto quit;
			}
			me->pts[0] = (vw_volume[0] +
						  vw_volume[3]) / 2.0;
			me->pts[1] = (vw_volume[1] +
						  vw_volume[4]) / 2.0;
			me->pts[2] = (vw_volume[2] +
						  vw_volume[5]) / 2.0;
						
			if (!MAptsxform (&msg, &num_points, view_to_wld, 
				me->pts, me->pts))
			{
			    *sts = FunFail;
			    goto quit;
			}
			me->action = 1;
		break;
		case EX_DATA:

		    me->pts[0] = me->event1.event.button.x;
		    me->pts[1] = me->event1.event.button.y;
		    me->pts[2] = me->event1.event.button.z;
		    me->action = 1;		
		break;		
	    } /* close for switch on response */
	
}

action cnstr
{
    IGRlong msg;

	*sts = OM_S_SUCCESS;
	status =dp$savvw_cons(msg=&msg,
			osnum=&me->sv_osnum,
			vw_name=me->event11.event.keyin,
			gg_id=&me->ggid[0], 
			descript=me->event22.event.keyin, 
			origin=me->pts );
	if ( !(status & 1))
        {
	    if (msg == DPDUPLICNM)
	    {
		EX_bell();
		ex$message ( msgnumb = GR_E_DupNme );
		*sts = SrchFlt;
		goto quit;
	    }
	    else
	    {
#ifdef DEBUG
		printf("\nin COsavevw  DPsavevw_cons failed\n");
#endif
		om$report_error(sts = status);
		goto quit;
            }
    	}			
	else
	{
	    /* save the view also for the command "restore original view" */
            msg = DPvd_mark_view(TRUE, &me->ggid[0], NULL);
	    
	    ex$message( field = ERROR_FIELD,
			msgnumb = GR_E_ViewSaved);

	    me->action = 0;
	}

}  /* end of action cnstrct  */


action del_view
{
    IGRlong  num_vw;
    IGRshort i;			/* loop control variable	*/
    IGRlong  msg;

*sts = OM_S_SUCCESS;

		    status = dp$get_saved_vw_id(msg=&msg,
				name=me->event1.event.keyin,
				numberofids=&num_vw,
				found_GRids=me->ggid);

		    if(! (1 & status))
		    {
#ifdef DEBUG
			printf("error in dp$get_saved_vw_id ..COdeletevwi.I ");
#endif
			*sts = status;
			goto quit;
		    }
		    if (msg == DPVWSMNODEF || msg == DPVWSNODEF)
		    {
			EX_bell();
			ex$message ( msgnumb = GR_E_NoSavVwDfn);
			*sts = SrchFlt;
			goto quit;
		    }	
		    else if (num_vw == 0)
		    {
			EX_bell();
			ex$message ( msgnumb = GR_E_NoSavVwNme );
			*sts = SrchFlt;
			goto quit;
		    }	
		    else
		    {
			for (i=0; i < num_vw; i++)
			{
			    status = om$send( msg = message Root.delete(1),
      				     targetid = me->ggid[i].objid,
			             targetos = me->ggid[i].osnum );
		    	    if(! (1 & status))
		    	    {
#ifdef DEBUG
			       printf("error in DPgetvwid ... COdeletevwi.I ");
#endif
			       *sts = SrchFlt;
			       goto quit;
		    	    }
			}
			ex$message( field = ERROR_FIELD,
				    msgnumb = GR_E_ViewDeleted);
		    }	

} /* end action del_view */


action ky_vw
{
    IGRlong msg;
    IGRlong total_num;
    GRspacenum osnum;
    GRobjid mod_id;
    IGRlong num_ids;

    msg = MSSUCC;
	
		*sts = OM_S_SUCCESS;

		status = ex$get_cur_mod(id = &mod_id, osnum = &osnum);

		status = dp$get_saved_vw_id(msg=&msg,
					 osnum = osnum,
					   name= me->event1.event.keyin,
				   numberofids = &num_ids,
				     total_num = &total_num,
				    array_size = 1,
				   found_GRids = &me->sv_grid);

		me->num_id = num_ids;

		if (total_num != 1)
		{
		    EX_bell();
		    if(total_num == 0)
		    {

		    	if (msg == DPVWSMNODEF || msg == DPVWSNODEF)
		    	{
			    ex$message ( msgnumb = GR_E_NoSavVwDfn );
		    	}	
		    	else
		    	{
			    ex$message ( msgnumb = GR_E_NoSavVwNme );
		        }
		    }
		    else if(total_num > 1)
		    {
			ex$message ( msgnumb = GR_E_AmbNme );
		    }
		    *sts = SrchFlt;
		}
 }    /* end of action ky_vw   */

action idn_wnd
{
    IGRlong msg;

		msg = MSSUCC;
		*sts = OM_S_SUCCESS;
		    if ( me->num_id !=0 )
		    {
/*

		    	savedvw_recall (msg = &msg, in_flag = DP_UPDATE,
				array_size = me->num_id, wn_ids = me->ggid, 
				vw_grid = &me->sv_grid );

*/
		    	savedvw_recall ( &msg, DP_UPDATE, me->num_id, me->ggid, 
				&me->sv_grid);

		    }
		    else
		    {
		    	ex$message ( msgnumb = GR_E_WinNotFnd);
			*sts = SrchFlt;
			goto quit;
 		    }		   
}   /* end of action idn_wnd  */

action id_vw
{
    IGRlong msg;
    IGRlong num_vw;

		msg = MSSUCC;
		*sts = OM_S_SUCCESS;

		    status = dp$get_saved_vw_id(msg=&msg,
				osnum = me->sv_osnum,
				name= me->event1.event.keyin,
				numberofids=&num_vw,
				found_GRids=me->vwid1);

		    if(! (1 & status))
		    {
#ifdef DEBUG
			printf("error in DPgetvwid ... COrenamevwi.I ");
#endif
			*sts=status;	
			goto quit;
		    }
		    if (msg == DPVWSMNODEF || msg == DPVWSNODEF)
		    {
			EX_bell();
			ex$message ( msgnumb = GR_E_NoSavVwDfn );
			*sts = SrchFlt;
			goto quit;
		    }	
		    else if (num_vw == 0)
		    {
			EX_bell();
			ex$message ( msgnumb = GR_E_NoSavVwNme );
			*sts = SrchFlt;
			goto quit;
		    }	
		    else if (num_vw > 1)
		    {
			EX_bell();
			ex$message ( msgnumb = GR_E_AmbNme );
			*sts = SrchFlt;
			goto quit;
		    }
	
}   /* end of ction id_vw  */

action rnm_vw
{

    IGRlong  msg;
    IGRlong  error;
    IGRlong  num_vw;
    IGRchar  stat_name[32];
    IGRlong  return_bytes;
    IGRint   vwname_len;
    struct var_list vw_list[2];

		    msg = MSSUCC;
		    *sts = OM_S_SUCCESS;
		    status = dp$get_saved_vw_id(msg=&msg,
				osnum = me->sv_osnum,
				name=me->event1.event.keyin,
				numberofids=&num_vw,
				found_GRids=me->vwid2);

		    if(! (1 & status))
		    {
#ifdef DEBUG
			printf("error in DPgetvwid ... COrenamevwi.I ");
#endif
			*sts = status;
			goto quit;
		    }
		    if (num_vw == 0)
		    {
			vwname_len = strlen(me->event1.event.keyin) +1;
			vw_list[0].var = SAV_VW_NAME;
			vw_list[0].var_ptr = me->event1.event.keyin;
			vw_list[0].num_bytes = vwname_len;
			vw_list[0].bytes_returned = &return_bytes;
			vw_list[1].var = END_PARAM;

			status = dp$inq_set_saved_view(msg=&msg,
					inq0_set1=1,
				       vw_objid= me->vwid1[0].objid,
					which_error=&error, 
					var_list=vw_list);
		    	    if(! (1 & status))
		    	    {
#ifdef DEBUG
			       printf("error in DPgetvwid ... COrenamevwi.I ");
#endif
			       *sts = status;
				goto quit;
		  	    }
			if (return_bytes < vwname_len)
			{
		  	    OM_BLOCK_MOVE( me->event1.event.keyin,
					   stat_name,
					  (return_bytes -1));
			    stat_name[return_bytes - 1] = '\0';
			    ex$message ( msgnumb = GR_I_NmeTrunc, 
				type = "%s%", var = `stat_name`, 
				justification = LEFT_JUS);
			}
			else
			{
			   ex$message( field = ERROR_FIELD,
				       msgnumb = GR_E_ViewRenamed);
			}
	            } /* close for if num_vw == 0 */
		    else
		    {
			EX_bell();
			ex$message ( msgnumb = GR_E_DupNme );
		    }		     

}   /* end of action rnm_vw  */


action get_type_view  
{
GRspacenum  osnum;
GRobjid     mod_id;

	*sts = OM_S_SUCCESS;
	me->event11 = me->event1;
    	status = ex$get_cur_mod( id=&mod_id, 	
		osnum=&osnum);
	if (!( 1 & status))
	{
#ifdef DEBUG
	    printf("Error in get_cur_mod");
#endif
	}

	DPset_view_rot( (IGRlong *)sts, osnum, (IGRdouble *)me->rotation,
                         me->event1.event.keyin);
	if (*sts == DPINVINP)
	{
	    ex$message(msgnumb = GR_E_NoSavVwNme);
	}
}	/* end of get_type_view    */


action get_wndid
{
    IGRlong msg;
    IGRshort j;			/* loop control variable	*/
    IGRshort rotate_flag;

		*sts = OM_S_SUCCESS;

		DPset_view_rot( (IGRlong *)sts, me->ggid[0].osnum, (IGRdouble *)me->rotation,
                                me->event11.event.keyin);
		if (*sts == DPINVINP)
		{
		    ex$message(msgnumb = GR_E_NoSavVwNme);
		}

		rotate_flag = ORIGIN_CENTER | REPLACE_MTX;
	        for( j = 0; j < me->num_id ; j++)
 	        {         
		    om$send( msg = message IGEgragad.DProtate
			 ( &msg, rotate_flag, NULL,(IGRdouble *)me->rotation,
			   (IGRboolean)TRUE), 
                                   senderid = my_id,
                                   targetid = me->ggid[j].objid,
                                   targetos = me->ggid[j].osnum);
                    if ( !(status & 1))
                    {
#ifdef DEBUG
                      	printf("\nin COwnsetvw  DProtate failed\n");
#endif
			*sts = status;
			goto quit;
                    }
	           /* save the view also for the command "restore original view" */
                   msg = DPvd_mark_view(TRUE, &me->ggid[j], NULL);
 	        }  /* close for "for num_id" */

}	/* end of action get_wndid   */



action wld_view
{
	IGRlong num_bytes;
	struct var_list var_list[3];
	IGRlong error;
        IGRlong msg;
	
		me->ret = OM_S_SUCCESS; 
	    	var_list[0].var = WLD_VOLUME;
	    	var_list[0].bytes_returned = &num_bytes;
	    	var_list[0].var_ptr = (IGRchar *)me->wld_volume;
		var_list[0].num_bytes = sizeof(IGRdouble)*6;
	    	var_list[1].var = END_PARAM;

	        status = dp$inq_set_gragad (msg=&msg,
				gragad_objid = me->ggid[0].objid,
				osnum = me->ggid[0].osnum,
				which_error = &error, 
				var_list=var_list);
		if(!(status & 1))
                {
#ifdef DEBUG
                        printf("\n Error: in dp$inq_set_gragad  ");
#endif
			me->ret = status;
			goto quit;
		}
}

action vw_view
{
    IGRshort i;
    IGRlong  msg;

	me->ret = OM_S_SUCCESS;
	for(i=0;i < me->num_id; i++)
	{
	    status = dp$view_vol(msg = &msg, 
					in_flags = WORLD_COOR | SETIN, 
					gg_id = &me->ggid[i],
					vw_vol = me->wld_volume,
					update = TRUE); 
		if(!(status & 1))
                {
#ifdef DEBUG
                        printf("\n Error: in dp$view_vol  ");
#endif
			me->ret = status;
			goto quit;
		}
	    if (msg == DPDGNEDGE)
	    {
		ex$message ( msgnumb = GR_I_EdgDgnFl);
		EX_bell();
	    }
	    else if (msg == DPDGNLIMIT)
	    {
		ex$message ( msgnumb = GR_I_MaxWin);
		EX_bell();
	    }
	    else if (msg == DPDGNSLIMIT)
	    {
		ex$message ( msgnumb = GR_I_MinWin );
		EX_bell();
	    }
	}
}


action zoom_factor
{
	*sts = OM_S_SUCCESS;
	me->zoom_factor = me->event1.event.value;
}
action zoom_inout 
{
    IGRshort i;
    IGRlong msg;
    IGRdouble temp[3];
    IGRint    local_type = 0;

	*sts = OM_S_SUCCESS;

	if(me->mytype == 6)
	{	
		local_type = 0;
        }
	else if(me->mytype == 7)
	{	
		local_type = 1;
        }
	if ( me->event1.response == EX_DATA )
	{
            temp[0] = me->event1.event.button.x;
            temp[1] = me->event1.event.button.y;
            temp[2] = me->event1.event.button.z;

        }
          /* doing actual zoom in/out */

          for( i = 0; i < me->num_id ; i++)
          {         

            if ( me->event1.response == STRING)
            {
	    		status = om$send(mode = OM_e_wrt_object,
                        msg = message IGEgragad.DPzoom(&msg,local_type,NULL,
							me->zoom_factor,
							(IGRboolean)TRUE ),
                             senderid = my_id,
                             targetid = me->ggid[i].objid,
                             targetos = me->ggid[i].osnum);

	    		if ( ! (1 & status) )
            		{
#ifdef DEBUG
                	  printf("\nIN COwnzoom Error send to DPzoom\n");
#endif
                	  om$report_error(sts = status);
			  *sts = status;
			  goto quit;
            		} 
	    }
	    else  /* if me->event1.response ..   */
	    {
	    		status = om$send(mode = OM_e_wrt_object,
                        msg = message IGEgragad.DPzoom(&msg,local_type,temp,
							me->zoom_factor,
							(IGRboolean)TRUE ),
                             senderid = my_id,
                             targetid = me->ggid[i].objid,
                             targetos = me->ggid[i].osnum);

	    		if ( ! (1 & status) )
            		{
#ifdef DEBUG
                	  printf("\nIN COwnzoom Error send to DPzoom\n");
#endif
                	  om$report_error(sts = status);
			  *sts = status;
			  goto quit;
            		} 
	    }	
	    if (msg == DPDGNEDGE)
	    {
	    	ex$message ( msgnumb = GR_I_EdgDgnFl);
		EX_bell();
	    }
	    else if (msg == DPDGNLIMIT)
	    {
		ex$message ( msgnumb = GR_I_MaxWin );
		EX_bell();
	    }
	    else if (msg == DPDGNSLIMIT)
	    {
		ex$message ( msgnumb = GR_I_MinWin );
		EX_bell();
	    }
          }/* end for num_id */

}  /* end of action zoom_inout	   */



action dspl_bufrs
{
   IGRlong      msg;

     if(me->mytype == 8 && me->bufr_def)
     {
	dp$display (msg = &msg,
		mode = GRhd,
		osnum = me->events[0].event.button.osnum,
		buffer = &me->element);
     }
}

action erase_bufrs
{
	IGRlong	   msg;

     if(me->mytype == 8 && me->bufr_def)
     {
    	dp$display (msg = &msg,
		mode = GRhe,
		osnum = me->events[0].event.button.osnum,
		buffer = &me->element);
     }
}

action reset_flag
{
	me->bufr_def = FALSE;
}

action get_ax_pt1
{

		me->events[0] = me->event1;
} 

action dynamics
{
    IGRint sizbuf;
    IGRint nret;
    IGRint msg;
    struct GRevent *ptr_events[1];
		
      if(dynamics == dyn_in_vwrotn)
      {
		sizbuf = sizeof(struct IGRdisplay);
		gr$get_active_display(msg = &msg,
				   sizbuf = &sizbuf,
				   buffer = (IGRchar *)&me->display_info,
				     nret = &nret);
		ptr_events[0] = me->events;
		DYrblinear(ptr_events, &me->display_info);
      }

}

action get_ax_pt2
{

    IGRlong msg;
    IGRdouble temp_pts[6];
    IGRdouble design_min[3];
    IGRdouble design_max[3];
    struct IGRline org_line;
    struct IGRline_seg ext_line;
    IGRshort i;

    		*sts = OM_S_SUCCESS;

                me->events[1] = me->event1;

    		me->LineSpecific.is_closed = FALSE;

		for (i=0; i < 3; i++)
		{
		    temp_pts[i] = me->pts[i];
		    temp_pts[i+3] = me->pts[i+3];
		}

		me->line.num_points = 2;
		me->line.points = me->temp_pts1;

		org_line.point1 = temp_pts;
		org_line.point2 = &temp_pts[3];

		ext_line.beg_point = me->temp_pts1;
		ext_line.end_point = &me->temp_pts1[3];

	design_min[0] = design_min[1] = design_min[2] = GRDGNLIMITS_MIN_D;
	design_max[0] = design_max[1] = design_max[2] = GRDGNLIMITS_MAX_D;

		if ( MAlncbclip(&msg,&org_line,design_min,design_max,&ext_line))
		{
    		    dp$build_dis_buffer(
			type = IGRPY,
                    	buffer = &me->element,
                    	display_att = &me->display_info,
                    	geometry = &me->line,
                    	ele_spec_att = &me->LineSpecific );
			

		    dp$display (msg = &msg,
			mode = GRhd,
			osnum = me->events[0].event.button.osnum,
			buffer = &me->element);

		    me->bufr_def = TRUE;

		}
		else
		{
		    ex$message(msgnumb = GR_E_InvInp);
		    EX_bell();
		    *sts = InvInp;
		    goto quit;
		}

}  /* EOF action get_ax_pt2   */
	
action get_angle
{

    	*sts = OM_S_SUCCESS;

	    me->angle1 = me->event1.event.value;

} /* EOF action get_angle   */



action get_id_view
{
    IGRlong msg;
    IGRdouble wld_to_view[4][4];
    IGRdouble view_pts[6];
    IGRdouble view_axis[3];
    IGRshort j;			/* loop control variable	*/
    IGRshort rotate_flag;
    IGRlong num_bytes;
    IGRlong num_points;
    IGRlong error;		/* these 4 variables are used in the 
					IGEgragad.aram call 	*/
    struct var_list var_list[2];


    		*sts = OM_S_SUCCESS;

       		for( j = 0; j < me->num_id ; j++)
 	        {         
		    var_list[0].var = WLD_TO_VIEW;
		    var_list[0].var_ptr = (IGRchar *)wld_to_view;
		    var_list[0].num_bytes = sizeof(IGRdouble)*16;
		    var_list[0].bytes_returned = &num_bytes;

		    var_list[1].var = END_PARAM;

	            status = dp$inq_set_gragad(msg=&msg,
					which_error= &error,
					var_list= var_list,
					osnum = me->ggid[j].osnum,
					gragad_objid = me->ggid[j].objid);
                    if ( !(status & 1))
                    {
#ifdef DEBUG
                     	printf("\nin COrotvwax dp$set failed\n");
#endif
			om$report_error(sts = status);
			*sts = status;
			goto quit;
                     }
		     num_points = 2;
		     if (!MAptsxform (&msg, &num_points, (IGRdouble *)wld_to_view,
                                        me->pts,view_pts))
		     {
			*sts = FunFail;
			goto quit1;
		     }
		    view_axis[0] = view_pts[3] - view_pts[0];
		    view_axis[1] = view_pts[4] - view_pts[1];
		    view_axis[2] = view_pts[5] - view_pts[2];

	            if ( !MArotmx( &msg, view_axis, &me->angle1,
                                        (IGRdouble *)me->rotation))
      		    {
			*sts = FunFail;
			goto quit1;
             	    }   
		    rotate_flag = LEFT_MULT;
		    status = om$send(mode = OM_e_wrt_object,
                                   msg = message IGEgragad.DProtate
					(&msg,rotate_flag,
					me->pts,
					(IGRdouble *)me->rotation,
			   		(IGRboolean)TRUE), 					
                                   senderid = my_id,
                                   targetid = me->ggid[j].objid,
                                   targetos = me->ggid[j].osnum);
                    if ( !(status & 1))
                    {
#ifdef DEBUG
                  	   printf("\nin COrotvwax  DProtate failed\n");
#endif
			   *sts = status;
                  	   goto quit1;
                    }	
		    dp$display (msg = &msg,
 			mode = GRhd,
			osnum = me->ggid[j].osnum,
			objid = me->ggid[j].objid,
			buffer = &me->element);

 	     }  /* close for "for me->num_id" */
             goto quit;
 quit1:
	    	dp$display (msg = &msg,
			mode = GRhe,
			osnum = me->events[0].event.button.osnum,
			buffer = &me->element);

}   /* EOF action get_id_view     */

action get_angles  (IGRint  index)

{
		me->ret = OM_S_SUCCESS;

		if (me->event1.subtype == GRst_DEFAULT)
		{
		    me->angles[index] = 0;
	   	}
		else 
		{
		    me->angles[index] = me->event1.event.value;
		}

} /* End Of action get_angles      */

action get_view
{
    IGRlong msg;
    IGRdouble matrix[4][4];	
    IGRdouble rotate_mtx[4][4];
    IGRdouble old_rotate[4][4];
    IGRdouble new_origin[3];
    IGRdouble axis[3];
    IGRshort i;			/* loop control variable	*/
    IGRshort j;			/* loop control variable	*/
    IGRshort rows1 = 4;
    IGRshort col1_rows2 = 4;
    IGRshort col2 = 4;
    IGRshort rotate_flag;


	*sts = OM_S_SUCCESS;

	if(me->event1.response == EX_DATA)
	{
	        new_origin[0] = me->event1.event.button.x;
        	new_origin[1] = me->event1.event.button.y;
          	new_origin[2] = me->event1.event.button.z;
			
	} 
		MAidmx(&msg, (IGRdouble *)old_rotate);		
                     for ( i = 0; i < 3; ++i)
                     {	
                     	if (me->angles[i] != 0.0)
                     	{		 
                            axis[0] = 0;
                            axis[1] = 0;
                            axis[2] = 0;
	                    axis[i] = 1;

                            if ( !MArotmx(&msg,axis,&me->angles[i],
                                           (IGRdouble *)matrix))
                            {
				*sts = FunFail;
                             	goto quit;
                            }   
                            if ( !MAmulmx(&msg,&rows1,&col1_rows2,&col2,
				          (IGRdouble *)matrix,
                                          (IGRdouble *)old_rotate,
                                          (IGRdouble *)rotate_mtx))
                            {
				*sts = FunFail;
                             	goto quit;
                            }  
                            OM_BLOCK_MOVE( rotate_mtx,
                                           old_rotate,
                                           sizeof(IGRdouble)*16);
                        } /* close for if angle */
		    } /* close for the for i */
       		for( j = 0; j < me->num_id ; j++)
 	        {         
                    if ( me->event1.response == STRING)
    	            {
			rotate_flag = ORIGIN_CENTER | LEFT_MULT;
                  	status = om$send(mode = OM_e_wrt_object,
                                   msg = message IGEgragad.DProtate
					(&msg,rotate_flag, NULL,
					(IGRdouble *)old_rotate,
					(IGRboolean)TRUE),
                                   senderid = my_id,
                                   targetid = me->ggid[j].objid,
                                   targetos = me->ggid[j].osnum);
                  	if ( !(status & 1))
                  	{
#ifdef DEBUG
                  	   printf("\nin COwnrot  DProtate failed\n");
#endif
			   *sts = status;
                  	   goto quit;
                  	}	
		    } /* end of ( if STRING ) */
		    else
		    {
                  	status = om$send(mode = OM_e_wrt_object,
                                   msg = message IGEgragad.DProtate
					(&msg,LEFT_MULT,new_origin,
					(IGRdouble *)old_rotate,
					(IGRboolean)TRUE),
                                   senderid = my_id,
                                   targetid = me->ggid[j].objid,
                                   targetos = me->ggid[j].osnum);
                  	if ( !(status & 1))
                  	{
#ifdef DEBUG
                  	   printf("\nin COwnrot  DProtate failed\n");
#endif
			   *sts = status;
                  	   goto quit;
                  	}	
		    }
 	     }  /* close for "for num_id" */

}		/* end of action get_view*/


action get_id_view1
{
    IGRlong msg = MSSUCC;
    IGRshort  j;			/* loop control variable	*/
	
	  *sts = OM_S_SUCCESS;


  	  if ( !MA3protmx(&msg,&me->pts[0],&me->pts[3],&me->pts[6],
				(IGRdouble *)me->rotation))
       	  {
	      *sts = FunFail;
       	      goto quit;
       	  }   
	 for( j=0; j < me->num_id; j++)
	 {
             status = om$send(mode = OM_e_wrt_object,
                                   msg = message IGEgragad.DProtate
				   (&msg,REPLACE_MTX,&me->pts[0],
				   (IGRdouble *)me->rotation,(IGRboolean)TRUE),
                                   senderid = my_id,
                                   targetid = me->ggid[j].objid,
                                   targetos = me->ggid[j].osnum);
                  if ( !(status & 1))
                  {
#ifdef DEBUG
                     printf("\nin COwnrot3pt  DProtate failed\n");
#endif
		     *sts = status;
		     goto quit;
                  }	
	  }  /* close for for loop */

}   /* end of action get_id_view */

action status_disp
{
   GRobjid          mod_id;
   long             total, msg, bytes_returned, which_error;
   GRspacenum       osnum;
   struct GRid      *sv_objids;
   int              i;
   struct var_list  var[3];
   char             savvw_msg[100];

   /* get current module environment */

   me->row_selected = -1;
   status = ex$get_cur_mod( id=&mod_id, osnum=&osnum );
   if( !(1 & status) )
      {
      goto fini;
      }
 
   /*  find total number of saved views */

   status = dp$total_num_saved_vw( msg = &msg,
                                   osnum = &osnum,
                                   total_num = &total );
   if( msg == DPVWSNODEF )
      {
      total = 0;
      }

   else
   if( !(1 & status) )
      {
      goto fini;
      }

   if( total )
      {

      /*  get the saved views objids */

      sv_objids = (struct GRid *)malloc( total * sizeof( struct GRid ) );
      me->save_vw = (struct sv_info *)malloc( total * sizeof( struct sv_info ) );

      status = dp$get_saved_vw_id( msg = &msg,
                                   osnum = osnum,
                                   name = "*",
                                   numberofids = &total,
                                   found_GRids = sv_objids,
                                   array_size = total,
                                   total_num = &total );

      if( !(1 & status) )
        {
        goto fini;
        }

      /*  set the maximum number of rows to be the number of saved views */
  
      FIfld_set_max_num_rows( me->status_display_form_ptr, 
                              SAVVW_NAME_DESCRIPT,
                              total );

      /*  get the name and description for each saved view and print */
      /*  it out to the form */

      var[0].var = SAV_VW_NAME;
      var[0].num_bytes = sizeof(char) * DI_PATH_MAX;
      var[0].bytes_returned = &bytes_returned;

      var[1].var = DESCRIPT;
      var[1].num_bytes = sizeof(char) * DI_PATH_MAX;
      var[1].bytes_returned = &bytes_returned;

      var[2].var = END_PARAM;

      for( i=0; i<total; i++ )
         {
         me->save_vw[i].oid.objid = sv_objids[i].objid;
         me->save_vw[i].oid.osnum = sv_objids[i].osnum;

         /*  inquire for the name and description of the saved view */

         var[0].var_ptr = me->save_vw[i].name;
         var[1].var_ptr = me->save_vw[i].descript;

         status = dp$inq_set_saved_view( msg = &msg,
                                         inq0_set1 = 0,
                                         osnum = osnum,
                                         vw_objid = me->save_vw[i].oid.objid,
                                         which_error = &which_error,
                                         var_list = var );

         if( !(1 & status) )
            {
            goto fini;
            }

         /* set the name field of the multicolumn field */

         FIfld_set_text( me->status_display_form_ptr,
                         SAVVW_NAME_DESCRIPT,
                         i,
                         0, 
                         me->save_vw[i].name,
                         FALSE );

         /* set the description field of the multicolumn field */

         FIfld_set_text( me->status_display_form_ptr,
                         SAVVW_NAME_DESCRIPT,
                         i,
                         1,
                         me->save_vw[i].descript,
                         FALSE );

         } /* for( i=0; i<total; i++ ) */

      FIfld_set_mode( me->status_display_form_ptr,
                      SAVVW_NAME_DESCRIPT,
                      0,
                      FI_SINGLE_SELECT );

      FIfld_set_mode( me->status_display_form_ptr,
                      SAVVW_NAME_DESCRIPT,
                      1,
                      FI_SINGLE_SELECT );
     

      free( sv_objids );

      } /* if( total ) */

   else
      {

      FIg_disable( me->status_display_form_ptr, SAVVW_NAME_DESCRIPT );

      ex$message( msgnumb=GR_E_NoSavVwDfn, buff=savvw_msg );

      FIfld_set_text( me->status_display_form_ptr,
                      SAVVW_MESSAGE_FIELD,
                      0,
                      0,
                      savvw_msg,
                      FALSE );

      } /* else, if( total ) */

   om$send( msg = message CEO.status_disp(),
            targetid = my_id,
            mode = OM_e_wrt_message );

fini:;
}


action form_notification
   {
   IGRint   row, pos;
   IGRint   response;
   IGRlong  msg, size;

   switch( gadget_label )
      {
      case SAVVW_NAME_DESCRIPT:
         row = (IGRint)value;

         if( row > = 0 )
            {

            /* row was selected, use num_views to save the view to recall */

            FIfld_get_active_row( form_ptr,
                                  SAVVW_NAME_DESCRIPT,
                                  &row,
                                  &pos );

            me->row_selected = row;
            }
         else
            {

            /* error, no valid row selected */

           FIfld_set_text( form_ptr,
                           SAVVW_MESSAGE_FIELD,
                           0, 0,
                           "Error, invalid selection",
                           FALSE );
            } 
         break;

      case CVT_TO_WINDOW:

         /* convert the save/restore form to a permanant form */

         FIf_cvrt_to_perm_win( form_ptr );
         break;

      case SAVE_EXIT_BTN:
         size = strlen( me->save_vw[me->row_selected].name ) + 1;
         response = EX_STRING;
 
         ex$putque( msg = &msg,
                    response = &response,
                    byte = &size,
                    buffer = me->save_vw[me->row_selected].name );

         break;

      case EXIT_BTN:
         break;

      }
   }
