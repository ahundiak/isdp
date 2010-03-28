class implementation COwindow;



#include <stdio.h>
#include <string.h>

#include "dpstruct.h"

%safe
#include "dpsetvw.h"
#include "dpmacgenupd.h"
#include "DPsetpersp.h"
#include "DPsetinq.h"
#include "DPgetggid.h"
%endsafe

#define  NAME_LENG  20
from IGEgragad import DProtate, DPcal;



method get_graphic_gadget ( IGRint flag ; IGRint num_wnds ; IGRint err_flg)
{
  int		  status = OM_S_SUCCESS;

	
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
			found_GRids = me->ggid);

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

quit:
  return OM_S_SUCCESS;
}

method get_dt_pt (IGRint index)
{
  int		  status = OM_S_SUCCESS;

	IGRint      ind;
 	me->ret = OM_S_SUCCESS;

		ind = index * 3;
		me->pts[ind] = me->event1.event.button.x;
		me->pts[ind+1] = me->event1.event.button.y;
		me->pts[ind+2] = me->event1.event.button.z;

quit:
  return OM_S_SUCCESS;
}

method init_kyin ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRlong msg;
	IGRchar buf[256];
	IGRint cre_num;
	
	*sts = OM_S_SUCCESS;
	me->event1.event.keyin[0] = '\0';

        me->num_id=-1;
        cre_num=1;
        while (me->num_id != 0)
	{
	    	ex$message(buff=buf,msgnumb=GR_I_Window);
		sprintf(me->long_name,"%s%d\0",buf,cre_num); 

		/* find out if default name exist */
		dp$get_gragad_id(msg = &msg,
			name = me->long_name,
			numberofids = &me->num_id, 
			found_GRids = me->ggid);

		if(me->num_id != 0)/* name exists */
			cre_num += 1;          
	}

    	ex$message(buff=buf,msgnumb=GR_P_KyWinNme);
	sprintf(me->prompt,"%s [%s]",buf,me->long_name);
quit:
  return OM_S_SUCCESS;
}

method get_type_view (IGRint *sts;IGRint use_default)
{
  int		  status = OM_S_SUCCESS;

	GRspacenum osnum;
    	GRobjid mod_id;
        IGRlong sts1;


	*sts = OM_S_SUCCESS;

    	status = ex$get_cur_mod( id=&mod_id, osnum=&osnum);
	if (!( 1 & status)) 
	{
#ifdef DEBUG
		printf("Error in get_cur_mod");
#endif
	}
	if ((me->event1.event.keyin[0]==0)||use_default) 
		strcpy(me->event1.event.keyin,"top");
	me->event11=me->event1;
	DPset_view_rot( &sts1, osnum, (IGRdouble *)me->rotation,
                       me->event1.event.keyin);
        *sts = sts1;

quit:
  return OM_S_SUCCESS;
}

method get_wndid ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong msg;
    IGRshort j;		
    IGRshort rotate_flag;


	*sts = OM_S_SUCCESS;

	DPset_view_rot((IGRlong *)sts, me->ggid[0].osnum,
                            (IGRdouble *)me->rotation,me->event11.event.keyin);

	rotate_flag = ORIGIN_CENTER | REPLACE_MTX;
        if (*sts==MSSUCC)
        {
		for( j = 0; j < me->num_id ; j++)
 	        {         
			status=om$send( msg = message IGEgragad.DProtate
				 ( &msg, rotate_flag, NULL, 
                                  (IGRdouble *)me->rotation,(IGRboolean)TRUE), 
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
			/* save the view information for restore view */
                        msg = DPvd_mark_view(TRUE, &me->ggid[j], NULL);


		}
	}
quit:
  return OM_S_SUCCESS;
}

method copy_window ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	struct var_list	inq_list[2];
	IGRlong         ret_bytes;
	IGRlong         which_error;
	IGRlong           msg;
	IGRint            temp_id;
	IGRboolean        flag1;
	struct gragad_inst wireframe_inst[2];

	/* 0=newly created window 1=copy from */
	me->ggid[1].objid = me->event1.event.button.objid;
	me->ggid[1].osnum = me->event1.event.button.osnum;
	inq_list[0].bytes_returned = &ret_bytes;
	inq_list[0].var            = GRAGAD_INST_STRUCT;
	inq_list[0].var_ptr        = (IGRchar *) &wireframe_inst[1];
	inq_list[0].num_bytes      = sizeof( struct gragad_inst );
	inq_list[1].var = END_PARAM;
	status = dp$inq_set_gragad( msg       = &msg,
	                         inq0_set1    = 0,
	                         osnum        = me->ggid[1].osnum,
	                         gragad_objid = me->ggid[1].objid,
	                         which_error  = &which_error,
	                         var_list     = inq_list );

	inq_list[0].var_ptr        = (IGRchar *) &wireframe_inst[0];
	status = dp$inq_set_gragad( msg       = &msg,
	                         inq0_set1    = 0,
	                         osnum        = me->ggid[0].osnum,
	                         gragad_objid = me->ggid[0].objid,
	                         which_error  = &which_error,
	                         var_list     = inq_list );

	
	if ( status != OM_S_SUCCESS ) return( *sts );

	/* fix the screen flags in the instance data */
	flag1 = wireframe_inst[1].gragad.flags & DPLEFT_SCREEN;

	if ( flag1 )
	   wireframe_inst[0].gragad.flags |= DPLEFT_SCREEN;
	else
	   wireframe_inst[0].gragad.flags &= ~DPLEFT_SCREEN;

	/* switch the gpipe ids*/
	temp_id = wireframe_inst[0].gragad.gpipe_id;
	wireframe_inst[0].gragad.gpipe_id = wireframe_inst[1].gragad.gpipe_id;
	wireframe_inst[1].gragad.gpipe_id = temp_id;

	/* set instance data of window 1 into window 0 */
	inq_list[0].var            = GRAGAD_STRUCT;
	inq_list[0].num_bytes      = sizeof( struct DPgra_gad );
	inq_list[0].var_ptr        = (IGRchar *) &wireframe_inst[1].gragad;
	status = dp$inq_set_gragad( msg       = &msg,
	                         inq0_set1    = 1,
	                         osnum        = me->ggid[0].osnum,
	                         gragad_objid = me->ggid[0].objid,
	                         which_error  = &which_error,
	                         var_list     = inq_list );

	status = om$send( msg      = message IGEgragad.DPcal( &msg ),
	                   targetid = me->ggid[0].objid,
	                   targetos = me->ggid[0].osnum );

	/* fix perspective mode of the windows */
	if ( wireframe_inst[1].gragad.flags & IS_PERSP ) 
	{
	   dp$set_persp( msg = &msg, gg_id = &me->ggid[0], in_flags = DP_CVT_WN_ONLY );
	}
	   
	dp$gen_update(msg=&msg,objid=me->ggid[0].objid,osnum=me->ggid[0].osnum);

        msg = DPvd_mark_view(TRUE, &me->ggid[0], NULL);

	return( OM_S_SUCCESS );

quit:
  return OM_S_SUCCESS;
}

end implementation COwindow;
