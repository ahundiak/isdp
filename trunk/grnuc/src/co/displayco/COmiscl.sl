/* #######################    APOGEE COMPILED   ######################## */
/* Command definition section */
options			"t"
product_name		"$GRNUC"
class			COmiscl
super_class		COwindow
start_state       	terminate


/* OPP section */
/* Specification section .. code for .S file */

specification

instance 
{
    OM_S_OBJID dplvldir_id;
    GRspacenum mod_osnum;
    IGRint level_mask_buffer[32];
}
/* implementation section - code for .I file */

implementation


/* External variable declaration for dynamics */

#include <string.h>
#include <stdio.h>

#include "OMerrordef.h"
#include "exmacros.h"
#include "grdpbmacros.h"

%safe
#include "GRdpbfunc.h"
#include "dplevel.h"
%endsafe

#define   InvLy     6020
#define   DsplLvls  6021
#define   Chek_actvn  6022

from DPlvldir import convert_lev_string;

from IGEgragad import DPdelayonoff, DPinquire;

from IGEgragad import activate;

from GRreffile import GRchglevels, GRlvdisplay;

action wakeup_act
{
    if (me->mytype == 5)
    {
	ex$message ( msgnumb = GRC_M_LysOn );
    }
    else if (me->mytype == 4)
    {
	ex$message ( msgnumb = GRC_M_LysOff );
    }
}


action delay_onoff
{

    IGRint  i;
    IGRlong msg;
    struct var_list var_list[2];
    IGRint flags;
    IGRlong num_bytes;
    IGRlong which_error;

	*sts = OM_S_SUCCESS;

        for(i = 0; i < me->num_id; i++)
        {
       	    status = om$send(mode = OM_e_wrt_object,
                                      msg = message IGEgragad.DPdelayonoff
					(&msg),
                                      senderid = my_id,
                                      targetid = me->ggid[i].objid,
                                      targetos = me->ggid[i].osnum);
	            if ( !(status & 1))
	            {
#ifdef DEBUG
 	           	printf("\nin COdelay  DPdelayonoff failed\n");
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
 	           	printf("\nin COdelay  DPinquire failed\n");
			om$report_error(sts = status);
#endif
			*sts = status;
			goto quit;
	            }		

	            if (flags & DP_DELAY)
	            {
			ex$message ( msgnumb = GR_I_DlyOn );
	            }
	            else
	            {
			ex$message ( msgnumb = GR_I_DlyOff );
	            } 
              } /* close for for */


} /* EOF action  delay_onoff  */


action decode_levels
{

    OM_S_OBJID NOD_id;
    OM_S_OBJID mod_id;

    IGRboolean aflag = 0;


/* decode levels to be turned on*/

    status = ex$get_cur_mod( id=&mod_id, 
				osnum=&me->mod_osnum);

	if (!( 1 & status))
	{
#ifdef DEBUG
	    printf("Error in COlevel get_cur_mod");
#endif
	    *sts = status;
	    goto quit;
	}

    aflag = pwIsActivationOn();

    if(aflag)
    {
      struct GRmd_env rf_env;

      pwGetActiveModuleEnv(&rf_env);
      me->mod_osnum = rf_env.md_id.osnum;
      mod_id        = rf_env.md_id.objid;
    }


    status = ex$get_NOD(NODname="IGENOD",pobjid=&NOD_id,
			modid=mod_id,
			mod_osnum=me->mod_osnum);
	if (!( 1 & status))
	{
#ifdef DEBUG
	    printf("Error in COlevel get_NOD");
#endif
	    *sts = status;
	    goto quit;
	}
    status = ex$get_objid_from_NOD(NODobjid=NOD_id,
					objname="DPLVLDIR",
					pobjid=&me->dplvldir_id,
					modid=mod_id,
					mod_osnum=me->mod_osnum);
	if (!( 1 & status))
	 {
#ifdef DEBUG
          printf("Error in COlevel get_dplvldir_oid");
#endif
	  *sts = status;
	  goto quit;
         }

}  /* end of action decode_levels   */

action err_msg
{
   ex$message ( msgnumb = GR_E_InvLy);
}

action get_string
{
	IGRshort  j;
	IGRint    msg;
	IGRshort  level;
	IGRint    size;
        IGRint    nret;
        IGRshort  nlevels;
        IGRshort  active_level;
        IGRlong   i;
        IGRboolean aflag=0;  

        aflag = pwIsActivationOn();

         for ( i = 0 ; i < 32 ; i++ )
           {
           me->level_mask_buffer[i] = 0;
           }

           status = om$send ( mode = OM_e_wrt_object,
			      msg = message DPlvldir.convert_lev_string
			                    ( &msg,
                                              me->response_data,
			                      &nlevels,
                                              &level,
                                              (IGRlong *)me->level_mask_buffer),
			      senderid = my_id,
			      targetos = me->mod_osnum,
			      targetid = me->dplvldir_id);
	   if ( !status || ! ( 1 & msg ) )
	   {
	   	ex$message ( msgnumb = GR_E_InvLy );
		me->ret = InvLy;
		goto quit;
	   }
	  /*if string all input set mask*/
          if ( msg == DPINVINP && !strcmp ("all",me->response_data) )
		{
	           for ( j = 0 ; j <= 1023 ; j++ )
		       {
			me->level_mask_buffer[j/32] |= (1<<(j % 32));
		       }					 
		   if ( me->mytype == 4 )
		    {
       	            ex$message ( msgnumb = GR_I_ActLayNTurOff );
                    }
                   if(aflag)
                     me->ret = Chek_actvn;
                   else
		     me->ret =  DsplLvls;
		   goto quit;
		}
           
           if ( me->mytype == 4 )/*layers off*/
            {
             size = sizeof( IGRshort );
             gr$get_active_level ( msg = &msg,
                                   sizbuf = &size,
                                   nret = &nret,
                                   buffer = (IGRchar *)&active_level);

             if ( me->level_mask_buffer[active_level/32] & 
                            ( 1 << (active_level % 32)) ) 	
                {
   	        ex$message ( msgnumb = GR_I_ActLayNTurOff );
                if ( nlevels ==1 ) 	
                  {
	          if ( active_level == level )
	           {
  		    me->ret = InvLy;
		    goto quit;
		   }
                  }
                 else
                  {
                   if(aflag)
                    {
                     if ( active_level == level )
                        me->ret = InvLy;
                     else
                        me->ret = Chek_actvn;
                    }
                   else
		     me->ret =  DsplLvls;			
		    goto quit;		
                  }
                }
              }/*end if level off*/

             if(aflag)
               me->ret = Chek_actvn;

}   /* end of action get_string  */

action display_levels
{
	IGRshort    i;
	IGRlong   msg, mesg;
        IGRint  local_type = 0;
        IGRshort flag;
        IGRboolean aflag = 0;
        struct     GRid rf_id;	
        struct     GRmd_env mod_env;

    UI_status ( "  ");

	if(me->mytype == 4)
        {
		local_type = 0;
	}
	else if(me->mytype == 5)
        {
		local_type = 1;
	}

        aflag = pwIsActivationOn();

      if(aflag)
      {
        enum GRdpmode disp_mode; 
        IGRshort   act_lvl;
        int      num_bits = sizeof(IGRint)*8; 


        pwGetActiveRefHeader(&rf_id);
        flag = local_type;
        disp_mode = flag?GRbd:GRbe;
        //disp_mode = GRbd;
        gr$get_module_env(buffer = (char*)&mod_env);
        gr$get_active_level(buffer = (char*)&act_lvl);

        me->level_mask_buffer[act_lvl/num_bits] &= ~((IGRint)(1 << (act_lvl %num_bits)));

      if(!flag)
       {
        om$send(msg = message GRreffile.GRlvdisplay(
                                                 &mesg,
                                                 &mod_env.md_env.matrix_type,
                                                 mod_env.md_env.matrix,
                                                 &disp_mode,
                                                 &mod_env.md_id,
                                                 me->level_mask_buffer),
                                      senderid = NULL_OBJID,
                                      targetid = rf_id.objid,
                                      targetos = rf_id.osnum);
       }

        om$send(msg = message GRreffile.GRchglevels(&mesg, &flag,
                              me->level_mask_buffer),
                              senderid=NULL_OBJID,
                              targetid=rf_id.objid,
                              targetos=rf_id.osnum);

      if(flag)
       {
        om$send(msg = message GRreffile.GRlvdisplay(
                                                 &mesg,
                                                 &mod_env.md_env.matrix_type,
                                                 mod_env.md_env.matrix,
                                                 &disp_mode,
                                                 &mod_env.md_id,
                                                 me->level_mask_buffer),
                                      senderid = NULL_OBJID,
                                      targetid = rf_id.objid,
                                      targetos = rf_id.osnum);
       }
      }
      else
      {
          /* doing actual levels on/off */
        for( i = 0; i < me->num_id ; i++)
        {         
	   status = dp$levels_on_off ( msg = &msg,
			       levels_mask = me->level_mask_buffer,
			       on_off_flag = local_type,
			       objid = me->ggid[i].objid,
			       osnum = me->ggid[i].osnum);

           if ( !(status & 1))
           {
#ifdef DEBUG
                printf("\nin COlevel  DPlevel failed\n");
#endif
		me->ret = status;
		goto quit;
           }
        }		
      }

}/* end of action display_levels */

