/* Command definition section */

options			"t"
product_name		"$GRNUC"
class			COgrid
super_class		COwindow
start_state       	terminate
		
		

/* OPP section */
/* Specification section .. code for .S file */

specification


instance 
{
   
    IGRdouble          refer_cross[2];
    IGRint             grids[2];

    IGRint             fit_flag;

    struct GRunit_lock unit_lock;
    IGRlong            size;
}

/* implementation section - code for .I file */

implementation

%safe
/* prototype file needed for macro files */
#include "GRdpbfunc.h"
#include "GRicvtalfn.h"
%endsafe

#include <string.h>
#include <stdio.h>

#include "grdpbmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grmessage.h"

%safe
#include "DPgetggid.h"
#include "DPsetinq.h"
#include "dpexbell.h"
#include "numstr.h"
%endsafe

#define NAME_LENG 20

#define XUNITS 0
#define YUNITS 1
#define SET_REF 0
#define SET_GRID 1
#define DISPLAY_REF 2
#define DISPLAY_GRID 3

#define MstPosNum	666
#define MstInt		667

from IGEgragad import DPgridlock, DPgridonoff, DPinquire;
from IGEgragad import DPfit;

action wakeup_act
{
	*sts = OM_S_SUCCESS;


	if (me->mytype == SET_REF)
	{
	    ex$message ( msgnumb = GRC_M_SetDstBetwRefGrd );
	}
	else if (me->mytype == SET_GRID)
	{
	    ex$message ( msgnumb = GRC_M_SetNumGrdPerRefGrd );
	}
	else if (me->mytype == DISPLAY_REF)
	{
	    ex$message ( msgnumb = GRC_M_DpDstBetwRefGrd );
	}
	else if (me->mytype == DISPLAY_GRID)
	{
	    ex$message ( msgnumb = GRC_M_DpNumGrdPerRefGrd );
	}
        else if (me->mytype == 6)
        {
   	    me->fit_flag = 1;
	    ex$message ( msgnumb = GRC_M_Fit );
        }
        else if (me->mytype == 7)
        {
 	    me->fit_flag = 0;
	    ex$message ( msgnumb = GRC_M_FstFit );
        }
	else if ( me->mytype  == 8) /*turn off unit lock*/
  	{
    		ex$message ( msgnumb = GRC_M_UnitLockOff );
  	}
	else if ( me->mytype  == 9) /*turn on unit lock*/
  	{
    		ex$message ( msgnumb = GRC_M_UnitLockOn );
  	}
	else if(me->mytype == 10)
  	{
    		ex$message ( msgnumb = GRC_M_UnitLockDef );
  	}
}

action setref(IGRint  flag)
{

	            if ( me->event1.response == VALUE )
	            {
	               if(me->event1.subtype ==  GRst_DEFAULT)
	               {
	                 me->refer_cross[flag] = -1;
	               }
	               else 
  	               {
			  if ( me->event1.event.value > 0)
			  {
	                      me->refer_cross[flag]=
				      me->event1.event.value;
			  }
			  else
			  {
				ex$message ( msgnumb = GR_E_MstPosNum );
				EX_bell();
				me->ret = MstPosNum;
				goto quit;
			  }
	     
	               }
	            }
	            else if ( me->event1.response == EX_RJT_MOVEON)
	            {
	                 me->refer_cross[flag] = -1;
	            }

}  /* end of action set_ref   */

action setgrd(IGRint  flag)
{

	            if ( me->event1.response == VALUE )
	            {
	               if(me->event1.subtype == GRst_DEFAULT)
	               {
	                   me->grids[flag] = -1;
	               }
	               else 
	               {
			  if ( me->event1.event.value > 0)
			  {
 	                     	me->grids[flag]= me->event1.event.value;
				/* checking to see if value is an integer */
				if (me->grids[flag] != me->event1.event.value)
				{
				    ex$message ( msgnumb = GR_E_MstInt );
				    EX_bell();
				    me->ret = MstInt;
				}
 	     		  }
			  else
			  {
				ex$message ( msgnumb = GR_E_MstPosNum );	
				EX_bell();
				me->ret = MstPosNum;
			  }
	               } /* close for else if msg == MSSUCC */
	            }
	            else if ( me->event1.response == EX_RJT_MOVEON)
	            {
	                   me->grids[flag] = -1;
	            }

 }  /* end of action     */

action getgragad
{
    struct var_list var_list[6];
    IGRlong msg;
    IGRint i;
    IGRlong error;
    IGRlong num_bytes;
    IGRint inq_grid[2];
    IGRshort num_alias;
    IGRshort field_size = sizeof(IGRchar) * DP_MAX_ALIAS_SIZE;
    IGRchar cvt_list[2][DP_MAX_ALIAS_SIZE];
    IGRchar *cvt_list_ptr[2];
    IGRint  new_strlen;
    IGRdouble  inq_ref[2];
    IGRdouble vv_scale;
    IGRdouble grid_delta_x;
    IGRdouble grid_delta_y;


		for ( i = 0; i < me->num_id; i++)
		{
		    var_list[0].var = UOR_PER_REF_X;
		    var_list[0].var_ptr = (IGRchar *)&inq_ref[0];
		    var_list[0].num_bytes = sizeof(IGRdouble);
		    var_list[0].bytes_returned = &num_bytes;
		    var_list[1].var = UOR_PER_REF_Y;
		    var_list[1].var_ptr = (IGRchar *)&inq_ref[1];
		    var_list[1].num_bytes = sizeof(IGRdouble);
		    var_list[1].bytes_returned = &num_bytes;

		    var_list[2].var = GRID_PER_REF_X;
		    var_list[2].var_ptr = (IGRchar *)&inq_grid[0];
		    var_list[2].num_bytes = sizeof(IGRint);
		    var_list[2].bytes_returned = &num_bytes;
		    var_list[3].var = GRID_PER_REF_Y;
		    var_list[3].var_ptr = (IGRchar *)&inq_grid[1];
		    var_list[3].num_bytes = sizeof(IGRint);
		    var_list[3].bytes_returned = &num_bytes;

		    var_list[4].var = VVOL_VIEWPORT_SCALE;
		    var_list[4].var_ptr = (IGRchar *)&vv_scale;
		    var_list[4].num_bytes = sizeof(IGRdouble);
		    var_list[4].bytes_returned = &num_bytes;

		    var_list[5].var = END_PARAM;
				    		    
	            status = dp$inq_set_gragad(msg=&msg,
					which_error= &error,
					var_list= var_list,
					gragad_objid = me->ggid[i].objid,
					osnum = me->ggid[i].osnum);

                    if ( !(status & 1))
                    {
#ifdef DEBUG
                     	printf("\nin COsetgrid  dp$inquire failed\n");
			om$report_error(sts = status);
#endif
			me->ret = status;
			goto quit;
                     }
		    switch(me->mytype)
		    {
			case DISPLAY_REF:
			    num_alias = 3;
  			    cvt_list_ptr[0] = (IGRchar *)cvt_list;
			    cvt_list_ptr[1] = &cvt_list[1][0];

			    status = co$cvt_imp_to_alias (msg = &msg,
			     		osnum = me->ggid[0].osnum,
			     		unit_type = GRIO_DISTANCE, 
			     		working_units = &inq_ref[0], 
			     		num_alias = &num_alias, 
				        inverse_scale_flag=GRIO_X_SCALE,
					field_size = &field_size,
			     		cvt_list = (IGRchar **)cvt_list );
			    if (!(status & 1)) goto quit;

			    status = co$cvt_imp_to_alias (msg = &msg,
			     		osnum = me->ggid[0].osnum,
			     		unit_type = GRIO_DISTANCE, 
			     		working_units = &inq_ref[1], 
			     		num_alias = &num_alias, 
				        inverse_scale_flag=GRIO_Y_SCALE,
					field_size = &field_size,
			     		cvt_list = (IGRchar **)&cvt_list[1][0] );
			    if (!(status & 1)) goto quit;

			    numstr(&msg,cvt_list_ptr,cvt_list_ptr,
				DP_MAX_ALIAS_SIZE,1,&new_strlen);

			    ex$message ( msgnumb = GR_I_XDstYDst , 
			    type ="%s%s", var =`cvt_list_ptr[0],cvt_list_ptr[1]`, 
			    justification = LEFT_JUS);
			break;

			case DISPLAY_GRID:
			    ex$message ( msgnumb = GR_I_GrdPerRefXY, 
			    type = "%.1d%.1d", var =`inq_grid[0], inq_grid[1]`, 
			    justification = LEFT_JUS);
			break;

			case SET_REF:

			    if (me->refer_cross[0] == -1)
			    {
			    	me->refer_cross[0] = inq_ref[0];
			    }
			    var_list[0].var_ptr= (IGRchar *)&me->refer_cross[0];
			    if (me->refer_cross[1] == -1)
			    {
			    	me->refer_cross[1] = inq_ref[1];
			    }

			    var_list[1].var_ptr= (IGRchar *)&me->refer_cross[1];
		    	    var_list[2].var = END_PARAM;
			    /****** NOTE there is NO BREAK HERE FOR A REASON */

			case SET_GRID:
			    if (me->mytype == SET_GRID)
			    {
			    	var_list[0].var = GRID_PER_REF_X;
			    	var_list[0].var_ptr = (IGRchar *)&inq_grid[0];
			    	var_list[0].num_bytes = sizeof(IGRint);
			    	var_list[0].bytes_returned = &num_bytes;

			    	var_list[1].var = GRID_PER_REF_Y;
			    	var_list[1].var_ptr = (IGRchar *)&inq_grid[1];
			    	var_list[1].num_bytes = sizeof(IGRint);
			    	var_list[1].bytes_returned = &num_bytes;
			    	var_list[2].var = END_PARAM;

					if (me->grids[0] == -1)
					{
					    me->grids[0] = inq_grid[0];
					}
			    	var_list[0].var_ptr = (IGRchar *)&me->grids[0];
					if (me->grids[1] == -1)
					{
				 	   me->grids[1] = inq_grid[1];
					}
			    	var_list[1].var_ptr = (IGRchar *)&me->grids[1];
			    }
		
            	status = dp$inq_set_gragad (msg=&msg,
					inq0_set1=1,
					which_error= &error,
					var_list= var_list,
					gragad_objid = me->ggid[i].objid,
					osnum = me->ggid[i].osnum);


               	if ( !(status & 1))
               	{
#ifdef DEBUG
               	    printf("\nin COsetgrid  dp$set failed\n");
		    om$report_error(sts = status);
#endif
		    me->ret = status;
              	}

				/*
				 * Fix for TR 91N3287
				 *  dhm   11/15/91
				 */

				if ( me->mytype == SET_REF )
				{
			        grid_delta_x = (me->refer_cross[0]) * vv_scale;

			        grid_delta_y = (me->refer_cross[1]) * vv_scale;

			        if ((grid_delta_x < MIN_REF_DELTA) && 
			            (grid_delta_y < MIN_REF_DELTA) )
					{
					    ex$message( msgnumb = GR_I_GrdTooSmlDsp); 
					}
				}

			break;
		    } /* close for switch on type */
          }  /* end of for  */
}   /* end of action getgragad   */

action grd_lk
{
    IGRint i;
    IGRlong  msg;
    IGRlong num_bytes;
    IGRlong which_error;
    struct var_list var_list[2];
    IGRint flags;

	*sts = OM_S_SUCCESS;

        for( i = 0; i < me->num_id; i++)
        {
	    status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPgridlock(&msg),
                             senderid = my_id,
			     targetos = me->ggid[i].osnum,
                             targetid = me->ggid[i].objid);
            if (! (1 & status))
            {
#ifdef DEBUG
               printf("Error in COgridlock send to DPgridlock\n");
#endif
		goto quit;
            }
       	    /* get win flags */

     	    var_list[0].var = GRAGAD_FLAGS;
	    var_list[0].var_ptr = (IGRchar *)&flags;
	    var_list[0].num_bytes = sizeof(IGRint);
	    var_list[0].bytes_returned = &num_bytes;

	    var_list[1].var = END_PARAM;
	
            status = om$send(mode = OM_e_wrt_object,
                              msg = message IGEgragad.DPinquire 
			     (&msg, &which_error, var_list),
                                     senderid = my_id,
                                     targetid = me->ggid[i].objid,
                                     targetos = me->ggid[i].osnum);
            if ( !(status & 1))
            {
#ifdef DEBUG
            	printf("\nin COgrlock  DPinquire failed\n");
		om$report_error(sts = status);
#endif
		goto quit;
            }		

            if (flags & GRID_LOCK)
            {
		ex$message ( msgnumb = GR_I_GrdLkOn );
            }
            else
            {
		ex$message ( msgnumb = GR_I_GrdLkOff );
            } 
	}/*END FOR */

}		/* end action grd_lk  */



action grd_onoff
{
    IGRlong msg;
    IGRint  i;
    struct var_list var_list[2];
    IGRint flags;
    IGRlong num_bytes;
    IGRlong which_error;

	*sts = OM_S_SUCCESS;
        for(i = 0; i < me->num_id; i++)
        {
       	    status = om$send(mode = OM_e_wrt_object,
                                      msg = message IGEgragad.DPgridonoff
					(&msg),
                                      senderid = my_id,
                                      targetid = me->ggid[i].objid,
                                      targetos = me->ggid[i].osnum);
	            if ( !(status & 1))
	            {
#ifdef DEBUG
 	           	printf("\nin COgridonoff  DPgridonoff failed\n");
			om$report_error(sts = status);
#endif
			*sts = status;
			goto quit;
	            }		
       	    /* get win flags */

     	    	    var_list[0].var = GRAGAD_FLAGS;
		    var_list[0].var_ptr = (IGRchar *)&flags;
		    var_list[0].num_bytes = sizeof(IGRint);
		    var_list[0].bytes_returned = &num_bytes;

		    var_list[1].var = END_PARAM;
	
	            status = om$send(mode = OM_e_wrt_object,
                              msg = message IGEgragad.DPinquire 
			     (&msg, &which_error, var_list),
                                     senderid = my_id,
                                     targetid = me->ggid[i].objid,
                                     targetos = me->ggid[i].osnum);
	            if ( !(status & 1))
	            {
#ifdef DEBUG
 	           	printf("\nin COgridonoff  DPinquire failed\n");
			om$report_error(sts = status);
#endif
			*sts = status;
			goto quit;
	            }		

	            if (flags & GRID_ON)
	            {
			ex$message ( msgnumb = GR_I_GrdOn );
	            }
	            else
	            {
			ex$message ( msgnumb = GR_I_GrdOff );
	            } 
              } /* close for for */

}   /* end of action grd_onoff  */

action get_sel_gragad( IGRint flag ; IGRint num_wnds ; IGRint err_flg; IGRint type_gragad)
{
	
	IGRlong		msg;

 me->ret = OM_S_SUCCESS;


  if(strlen(me->event1.event.keyin) > NAME_LENG)
  {
	me->event1.event.keyin[NAME_LENG-1] = '\0';
  }

  switch (me->event1.response)
  {
      case EX_DATA :

  		me->num_id = 1;
                if(flag == SrcGGid)
                {
			me->source_id.osnum = me->event1.event.button.osnum;
			me->source_id.objid = me->event1.event.button.objid;
                }
  		else if(flag == DstGGid)
                {
			me->ggid[0].osnum = me->event1.event.button.osnum;
			me->ggid[0].objid = me->event1.event.button.objid;
		}
                break;

      case EX_STRING :

 /* check for string length and quit if neccessary   */

                    if(!strlen(me->event1.event.keyin))
  		    {
	           	ex$message ( msgnumb = GR_E_AmbNme);
			me->ret = SrchFlt;
        		goto quit;
  		    }

          /* check if name exists */

           me->num_id = 0;
	   dp$get_gragad_id(msg = &msg,
			name = me->event1.event.keyin,
			array_size = MAX_WINDOW,
			numberofids = &me->num_id, 
			found_GRids = me->ggid,
			type_gragad= type_gragad);

    /* Display appr. error messages  & set the "action return code"     */

           if(err_flg == ExstGG) /* checking for existing windows  
					succeeds if num_id = 1 or > 1 */
           {
                   if ( me->num_id == 0)
                   {
	        	ex$message ( msgnumb = GR_E_WinNotFnd);
			me->ret = SrchFlt;
			goto quit;
           	   }
                   else if(me->num_id > 1)
                   {
                           /* Error only if searching for one window.
                              Command can't proceed if more then one window
                                      is returned    */
                     if(num_wnds == 1) 
                     {
	           	ex$message ( msgnumb = GR_E_AmbNme);
			me->ret = SrchFlt;
			goto quit;
		     }
           	   }
           } 
           else if(err_flg == NonExstGG)  /* Search to determine if window
                                                    already exists
					     succeeds if num_id = 0   */
           { 
                   if(me->num_id > 1)
                   {
	           	ex$message ( msgnumb = GR_E_AmbNme);
			me->ret = SrchFlt;
			goto quit;
           	   }
                   else if(me->num_id == 1)
                   {
	           	ex$message ( msgnumb = GR_E_DupNme);
			me->ret = SrchFlt;
			goto quit;
           	   }
           }
	   if(flag == SrcGGid)
           {
		     me->source_id.objid = me->ggid[0].objid;		
		     me->source_id.osnum = me->ggid[0].osnum;		
           }
       } /* end of switch  */

}
action get_sel_all_gragad( IGRint type_gragad )
{
	
  	IGRlong	msg;
  	IGRchar	str_name[20];

  	me->ret = OM_S_SUCCESS;

  	/* check if name exists */

        me->num_id = 0;
  	strcpy(str_name, "*");
	dp$get_gragad_id(msg = &msg,
			 name = str_name,
			 array_size = MAX_WINDOW,
			 numberofids = &me->num_id, 
			 found_GRids = me->ggid,
			 type_gragad= type_gragad);

    	/* Display appr. error messages  & set the "action return code"     */

        if ( me->num_id == 0)
        {
	        ex$message ( msgnumb = GR_E_WinNotFnd);
		me->ret = SrchFlt;
		goto quit;
        }
}
action fit
{
    IGRshort i;
    IGRlong  msg;

	*sts = OM_S_SUCCESS;

	    for (i=0; i < me->num_id; i++)
	    {
	    	status = om$send( msg = message IGEgragad.DPfit
					(&msg,me->fit_flag),
					 senderid = my_id,
				         targetid = me->ggid[i].objid,
				         targetos = me->ggid[i].osnum );
		if (!(status & 1))
		{
#ifdef DEBUG
		    printf("\nerror in COfit call to DPfit\n");
		    om$report_error(sts = status);
#endif
		    goto quit;
		}
	    } /* close for for */


}  /* EOF action fit  */


action set_unitlk
{
    IGRint msg;
    IGRint nret;

*sts = OM_S_SUCCESS;
me->size = sizeof ( struct GRunit_lock );
gr$get_unit_lock(
            msg = &msg,
            sizbuf = (IGRint *)&me->size,
            buffer = (IGRchar *)&me->unit_lock,
            nret =  &nret);
}

action unitlk_onoff
{
    IGRint  msg;
    IGRint  local_type = 0;

   *sts = OM_S_SUCCESS;

   if(me->mytype == 8)
       local_type = 0;
   else if(me->mytype == 9) 
       local_type = 1;

   me->unit_lock.on_off = local_type;
   gr$put_unit_lock(
            msg =    &msg,
            sizbuf = (IGRint *)&me->size,
            buffer = (IGRchar *)&me->unit_lock);
   if ( me->mytype  == 8) /*turn off unit lock*/
      {
      ex$message ( msgnumb = GR_S_UnitLockOff );
      }
   else if ( me->mytype  == 9) /*turn on unit lock*/
      {
      ex$message ( msgnumb = GR_S_UnitLockOn );
      }

}  /* end of action unitlk_onoff  */

action unitlk1
{


   *sts = OM_S_SUCCESS;

               ex$message ( msgnumb = GR_E_InvStr );
}

action unitlk2
{
    IGRint msg;

   *sts = OM_S_SUCCESS;

               me->unit_lock.round_off = me->event1.event.value;
       
               gr$put_unit_lock(
                    msg = &msg,
                    sizbuf = (IGRint *)&me->size,
                    buffer = (IGRchar *)&me->unit_lock);

}     /* end of action unitlk      */

