/*******************************************************************************
*									       *
* File:   ECmngcnstri.I							       *
*									       *
* Description:								       *
*                                                                              *
*     This file contains implementation of the Manage constraints command      *
*     object   								       *
*									       *
*									       *
* Dependencies:								       *
*                                                                              *
* Notes:							               *
*                                                                              *
* History:
*     08/09/93  Krishna Kumar    creation date
*     08/13/94  scw              Clarified sleep method
*******************************************************************************/

class implementation ECmngcnstr;
#include "stdio.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "tools.h"
#include "FI.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <gr.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "griodef.h"
#include "asbox.h"
#include "asmacros.h"
#include "griomacros.h"
#include "refdef.h"
#include "EMSasnucdef.h"

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"
#include "assemconstr.h"

#include "ECcmd.h"
#include "ECmsg.h"

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

/*#define DEBUG*/

#define FINISHED      -1
#define START         0
#define UPDATE_FORM   1
#define ADD_CNSTR     2
#define EDIT_CNSTR    3

#define ASM_NO_CNSTR_PARTS  0x02

/* Gadgets on the Manage constraints form */
#define PART_NAME	11
#define CNSTR_MCF	12
#define DOF_BUTTON	17
#define EDT_BUTTON	20
#define DEL_BUTTON	21
#define STAR_TXT        18

from EMconstr   import EMgetpart;
from EMconstr   import EMget_ftrs_with_env, EMget_offset, EMset_offset;
from expression import give_formula;
from NDnode     import NDget_objects;
from GRgraphics import GRdisplay;
from GRreffile  import GRgetenvironment;
from EMdescribe import EMget_memb;

extern OMuword OPP_EMconstr_class_id;
extern OMuword OPP_EMmate_class_id;
extern OMuword OPP_EMalign_class_id;


int mngcnstr_notify(form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{
IGRint 		status;
IGRlong 	msg_loc;
GRobjid 	cmdobj;
GRspacenum 	cmdos;

 	status = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
 	if(status)
  		return (OM_E_ABORT);

 	status = om$send (msg = message ECmngcnstr.do_form(&msg_loc, form_label,
				                gadget_label, value),
		            senderid = NULL_OBJID, 
		            targetid = cmdobj,
		            targetos = cmdos);
	if(! (status & 1))
		 return (OM_E_ABORT);

 	return(OM_S_SUCCESS);
}

method init(int type; char *str_ptr)
{
int ret;

	/* 
	 * Initialise parent stuff 
	 */
 	ret = om$send(mode = OM_e_wrt_message,
        	       msg = message COpara.init( type, str_ptr),
            	       targetid = my_id);
	/*
	 * Initialise the instance
         */
        me->num_inst = 0;
        me->prt_list = 0;

        me->num_cnstr = 0;
        me->cnstr_list = 0;
        me->appl_prt_list = 0;

        me->cur_prt = 0;
        me->cur_cnstr = -1;
        me->cur_appl_prt = -1;

	ret = FIf_new(100, "MngCnstr", mngcnstr_notify, &me->fp);
	if(ret)
		return (OM_E_ABORT);

  	ret = FIf_set_cmd_oid_os(me->fp, my_id, OM_Gw_current_OS);
	if(ret) 
		return (OM_E_ABORT);

	me->state = START;
	me->form_displayed = 0;

	return( OM_S_SUCCESS );
}

method wakeup( int pos )
{
int  om_msg;
long msg;

        /*
         * Highlight the current constraint
         */
        if( me->cur_cnstr != -1 )
        om_msg = om$send ( msg = message ECmngcnstr.highlight_cnstr_fea(
                                                 &msg,
                                                 &me->cnstr_list[me->cur_cnstr],
                                                 GRhd ),
                                 targetid = my_id );

        if( me->cur_appl_prt != -1 )
        {
            EMHiLiteObject( &msg, 
                          &me->appl_prt_list[me->cur_appl_prt], NULL,
		          GRhd );
        }

        ex$message( msgnumb = EM_M_MngACnstr );
        ex$message( msgnumb = EMS_S_ClearStatusField );

	return( OM_S_SUCCESS );
}

method super_cmd.sleep( int pos )
{
int  sts, om_msg;
long msg;

	FIf_erase ( me->fp );
	me->form_displayed = 0;

 	sts = om$send(mode = OM_e_wrt_message,
        	       msg = message COpara.sleep( pos ),
            	       targetid = my_id);

        if( me->cur_cnstr != -1 )
        om_msg = om$send ( msg = message ECmngcnstr.highlight_cnstr_fea(
                                                 &msg,
                                                 &me->cnstr_list[me->cur_cnstr],
                                                 GRhe ),
                                 targetid = my_id );

        if( me->cur_appl_prt != -1 )
        {
            EMHiLiteObject( &msg, &me->appl_prt_list[me->cur_appl_prt], NULL,
				     GRhe );
        }

	return( OM_S_SUCCESS );
}

method delete( int pos )
{
int sts;

	if( me->fp )
		FIf_delete( me->fp );

        if( me->prt_list )
            free( me->prt_list );
        if( me->appl_prt_list )
            free( me->appl_prt_list );
        if( me->inc_flag )
            free( me->inc_flag );

  	sts = om$send(msg = message COpara.delete( pos ),
                  targetid = my_id,
                  mode = OM_e_wrt_message);

	return( sts );
}

method status_disp()
{
	return( OM_S_SUCCESS );
}

method do_form( IGRlong *rc; int form_label; int g_label; double value )
{
long    msg;
int     sf, om_msg, type;
int     row, col, i, num_rows;

    *rc = MSSUCC;

    /*
     * Erase highlight on previously selected constraint 
     */

    if( me->cur_cnstr != -1 )
    {
        FIfld_set_select (me->fp,CNSTR_MCF,me->cur_cnstr,0,0);
        om_msg = om$send ( msg = message ECmngcnstr.highlight_cnstr_fea ( 
                                                 &msg,
                                                 &me->cnstr_list[me->cur_cnstr],
                                                 GRhe ),
                              targetid = my_id );
    }

    /*
     * Erase highlight on previously selected applied_to_part 
     */
    if( me->cur_appl_prt != -1 )
    {
        FIfld_set_select (me->fp,CNSTR_MCF,me->cur_appl_prt,1,0);
        EMHiLiteObject( &msg, 
                        &me->appl_prt_list[me->cur_appl_prt], NULL,
	                GRhe );
    }

    switch( g_label )
    {
        case PART_NAME:
            /* 
             * Get the selected row in the list
             */
            FIfld_get_list_num_rows(me->fp,PART_NAME,0,&num_rows);
            for( i = 0; i < num_rows; i++ )
            {
                FIfld_get_list_select(me->fp,PART_NAME,i,0,&sf);
                if ( sf )
		{
                    me->cur_prt = i;
		    break;
                }
            }
            om_msg = om$send( msg = message ECmngcnstr.updateform_with_cur_part(
                                                                    &msg ),
                                            targetid = my_id );
            if( !( om_msg & msg & 1 ) )
                verbose(printf("update form with selected part failed\n"));

            break;

        case CNSTR_MCF:

            FIfld_get_active_row( me->fp, CNSTR_MCF, &row, &sf );
            FImcf_get_active_col( me->fp, CNSTR_MCF, &col, &sf );
            /* 
             * If col = 0, highlight the picked constraint features of the parts
             * if col = 1, highlight the part constraint is applied to.
             */
            if( col == 0 )
            {
                /*
                 * Highlight the selected constraint
                 */
                om_msg = om$send ( msg = message ECmngcnstr.highlight_cnstr_fea(
                                                 &msg,
                                                 &me->cnstr_list[row],
                                                 GRhd ),
                                        targetid = my_id );
                me->cur_cnstr = row;
    	        me->cur_appl_prt = -1 ;
            }
            else /* if col == 1 */
            {
                /*
                 * Highlight the selected appl_to_part
                 */
                EMHiLiteObject( &msg, &me->appl_prt_list[row], NULL, GRhd );

                me->cur_appl_prt = row;
                me->cur_cnstr = -1;
            }
            break;

        case DOF_BUTTON:
            /* 
             * Show the Degrees of Freedom on the selected part.
             */
	    init_dof_display();

	    om_msg = show_dof_part( &msg, &me->prt_list[me->cur_prt], GRhd );

            if( !(om_msg & msg & 1 ))
                verbose(printf("showdofpart failed\n"));

            break;

        case DEL_BUTTON:
            /*
             * Delete the Highlighted constraint
             */
            if( me->cur_cnstr == -1 )
            {
                FIg_set_text( me->fp, FI_MSG_FIELD,"Select Constraint to delete");
                break;
            }
            om_msg = asm$rem_constraint( msg = &msg,
                             constraint_id = &me->cnstr_list[me->cur_cnstr]);
            if( !( om_msg & msg & 1 ) )
            {
                verbose(printf("Delete failed on constr no. %d\n",me->cur_cnstr));
		ex$message( msgnumb = EMS_S_OpFail );
                break;
            }
            else
              me->cur_cnstr = -1;

            /*
             * Update the list in the form and in the instance
             */
            om_msg = om$send( msg = message ECmngcnstr.updateform_with_cur_part(
                                                                    &msg ),
                                            targetid = my_id );
	    if( msg == ASM_NO_CNSTR_PARTS )
	    {
                FIf_erase( me->fp );
                FIf_delete( me->fp );
                {
    	        int	 rsp = EX_FORM_FINISHED;
    	        long stat;
	
	        ex$putque(msg = &stat, response = &rsp);
	        }
                break;
            }
            FIfld_set_select (me->fp,CNSTR_MCF,me->cur_cnstr,1,0);

            if( !( om_msg & msg & 1 ) )
                verbose(printf("update form with selected part failed\n"));
                
            break;

        case EDT_BUTTON:
            /*
             * Allow editing of the offset of a mate/align constraint
             */
            if( me->cur_cnstr == -1 )
            {
                FIg_set_text( me->fp, FI_MSG_FIELD,"Select Constraint to Edit");
                break;
            }
	    EMgetconstrtype( me->cnstr_list[me->cur_cnstr], &type );
            if( type == ALIGN )
            {
                FIg_set_text( me->fp, FI_MSG_FIELD,"Offset on Align Not Possible");
                break;
            }
            FIf_erase( me->fp );

            om_msg = om$send( msg = message ECmngcnstr.edit_cnstr( &msg, me->cur_cnstr),
                                    targetid = my_id );
            if( !( om_msg & msg & 1 ) )
            {
                verbose(printf("edit constraint no. %d failed\n",row));
                ex$message( msgnumb = EMS_S_OpFail );
            }

            FIf_display( me->fp );            
            break;

        case FI_ACCEPT:
        case FI_CANCEL:
            FIf_erase( me->fp );
            FIf_delete( me->fp );
            {
    	    int	 rsp = EX_FORM_FINISHED;
	    long stat;
	
	        ex$putque(msg = &stat, response = &rsp);
	    }
            break;
    }
    return( OM_S_SUCCESS );
}

method execute( int *response; char *response_data; int pos )
{
struct GRevent  event;
int		om_msg, i;
long 		msg;
char            inst_name[50], buffer[256];

    ex$message(msgnumb = EM_M_MngACnstr); /*Manage Assembly Constraints  */

    switch( me->state )
    {
        case START:
            /*
             * Get the list of parts which have atleast one constraint,
             * filled in the command object's instance.
             */
            om_msg = om$send( msg = message ECmngcnstr.get_cnstr_prts_list(
                                                        &msg ),
                                    targetid = my_id );
            if (!(om_msg & msg & 1))
            {
                *response = TERMINATE;
                me->state = FINISHED;
                break;
            }
	    if( !( me->num_inst ))
            {
/*		UI_status("No constrained parts in assembly");*/
		ex$message( msgnumb = EMS_S_NoCnstrPrts );
                *response = TERMINATE;
                me->state = FINISHED;
                break;
            }

            *response = RESET;
            me->state = UPDATE_FORM;
            break;

        case UPDATE_FORM:
	    if( me->fp && !me->form_displayed )
	    {
		FIf_display( me->fp );
		me->form_displayed = 1;
	    }

            /*
             * Set the Parts list in the Form, only parts with constraints.
             */
            for( i = 0; i < me->num_inst; i++ )
            {
                /*
                 * get the instances' name
                 */
                om_msg = EMget_instance_name( &msg,&me->prt_list[i],inst_name );

                if( om_msg & msg & 1 )
                {
                    if( i == 0 )
                        FIg_set_text(me->fp, PART_NAME, inst_name, 0);
                    FIfld_set_list_text (me->fp,PART_NAME,i,0,inst_name,FALSE);
                }
            }
            /*
             * Update the constraints MCF 
             */
            om_msg = om$send( msg = message ECmngcnstr.updateform_with_cur_part(
                                                             &msg ),
                                    targetid = my_id );
            if( !( om_msg & msg & 1 ) )
            {
                *response = TERMINATE;
                me->state = FINISHED;
                break;
            }
            /*
             * Wait for user event
             */
            strcpy( buffer, "Enter Form Data");
            om_msg = co$getevent( msg = &msg,
	                     event_mask = ( GRm_FORM_FINISHED | GRm_STRING ),
	                     prompt = buffer,
               		     response = response,
                	     response_data = response_data,
        	             event = &event );

            if( event.response == EX_FORM_FINISHED )
            {
                *response = TERMINATE;
                me->state = FINISHED;
            }

            break;
    }
    return( OM_S_SUCCESS );
}

method updateform_with_cur_part( IGRlong *rc )
{
long msg;
int  om_msg, i, type, cnstr_cnt, oldcnt, star = 0;
char inst_name[50], temp_str[55];


    *rc = MSSUCC;       
    /*
     * Get the list of constraints on the current part
     */
    om_msg = om$send( msg = message ECmngcnstr.get_constr( &msg, 
						&me->prt_list[me->cur_prt],
                                                &cnstr_cnt,
                                                &me->cnstr_list ),
                               targetid = my_id );
    if (!(om_msg & msg & 1))
    {
	verbose(printf("get_constr failed\n"));
        *rc = MSFAIL;
        return( OM_E_ABORT );
    }

    if( cnstr_cnt == 0 )
    {
        /*
         * ReInitialise the parts list in the instance data
         */
        oldcnt = me->num_inst;
/*        ex$message( msgnumb = EMS_S_ReGenPrts );Regenerating constrained parts list */
        free( me->prt_list );
        me->prt_list = NULL;
        me->num_inst = 0;
        me->cur_prt = 0;
        /*
         * Get the list of parts which have atleast one constraint,
         * filled in the command object's instance.
         */
        om_msg = om$send( msg = message ECmngcnstr.get_cnstr_prts_list(
                                                        &msg ),
                                    targetid = my_id );
        if (!(om_msg & msg & 1) )
        {
            verbose(printf("getcnstrprts failed\n"));
            return( OM_E_ABORT );
        }
        if( !( me->num_inst ))
        {
	    *rc = ASM_NO_CNSTR_PARTS;
	    me->cur_prt = -1;
	    me->cur_cnstr = -1;
            return( OM_S_SUCCESS );
        }
        for( i = 0; i < me->num_inst; i++ )
        {
            /*
             * get the instances' name
             */
            om_msg = EMget_instance_name( &msg,&me->prt_list[i],inst_name );

            if( om_msg & msg & 1 )
            {
                if( i == 0 )
                    FIg_set_text(me->fp, PART_NAME, inst_name, 0);
                FIfld_set_list_text (me->fp,PART_NAME,i,0,inst_name,FALSE);
            }
        }
        for(; i < oldcnt; i++ )
            FIfld_set_list_text (me->fp,PART_NAME,i,0,"",FALSE);

        om_msg = om$send( msg = message ECmngcnstr.updateform_with_cur_part( 
                                                                &msg ), 
                               targetid = my_id );

        if (!(om_msg & msg & 1))
        {
       	    verbose(printf("updateform failed\n"));
            *rc = MSFAIL;
            return( OM_E_ABORT );
        }
    }
    else
        me->num_cnstr = cnstr_cnt;
    /*
     * Get the applied parts list ( list of parts the cur_part is
     * constrained to), again fill the instance data.
     */
    om_msg = om$send( msg = message ECmngcnstr.get_appl_prts_list(&msg),
                               targetid = my_id );
    if (!(om_msg & msg & 1))
    {
        *rc = MSFAIL;
        return( OM_E_ABORT );
    }

    /* 
     * (Re)Initialise the multi-column field
     */
    FIg_reset( me->fp, CNSTR_MCF );
          
    /*
     * Set the Constraints Type list in the form.
     */
    for( i = 0; i < me->num_cnstr; i++ )
    {
	EMgetconstrtype( me->cnstr_list[i], &type );
	if( type == ALIGN )
            FIfld_set_text( me->fp, CNSTR_MCF, i, 0, "ALIGN",0);
	else if( type == MATE )
	{
        IGRuint attr;
	    /*
             * Check if the mate is special align
             */
            attr = 0;
            asm$get_constraint_attrs( msg = &msg,
                                      id = &me->cnstr_list[i],
                                      attrs = &attr );

            if( attr & EM_MATE_ALIGNED )
                FIfld_set_text( me->fp, CNSTR_MCF, i, 0, "ALIGN",0);
            else
                FIfld_set_text( me->fp, CNSTR_MCF, i, 0, "MATE",0);
	}
	else if( type == GROUND )
            FIfld_set_text( me->fp, CNSTR_MCF, i, 0, "GROUND",0);
        else
        {
	    verbose(printf("Unknown constraint type\n"));
            *rc = MSFAIL;
            return( OM_E_ABORT );
        }
	/*
         * Set the parts applied to list 
         */
	if( type == GROUND )
            continue;
        /*
         * get the instances' name
         */
        om_msg = EMget_instance_name( &msg,&me->appl_prt_list[i],inst_name );

        if( !( om_msg & msg & 1 ) )
        {
	    verbose(printf("getinstancename failed\n"));
            *rc = MSFAIL;
            return( OM_E_ABORT );
        }    
        if( me->inc_flag[i] )
	{
	    /* if it is incident constraint, add "*" before it's name */
	    strcpy( temp_str, "*");
            strcat( temp_str, inst_name );
	    star = 1;
        }
        else 
            strcpy( temp_str, inst_name );

        if( star )
            FIg_display( me->fp, STAR_TXT );
        else
            FIg_erase( me->fp, STAR_TXT );

        FIfld_set_text( me->fp, CNSTR_MCF, i, 1, temp_str, 0);
    }

    return( OM_S_SUCCESS );
}

/****
  This method would get each part's environment and collect the constrained
  parts in the assembly.
****/

method get_cnstr_prts_list ( IGRlong *msg; )
{
int    om_msg = OM_S_SUCCESS, sizbuf, i;
struct GRmd_env env;
struct GRid pid;
/*
struct GRmd_env env_path;
EMmemb      memb;
int         prt_count;
*/




    /*
     * Get the current module enviroment.
     */	
    sizbuf = sizeof( struct GRmd_env );
    gr$get_module_env(msg = msg,
                      sizbuf = &sizbuf,
                      buffer = &env );

    om_msg = asm$get_file_part (msg = msg,
                                mod_env = &env,
                                part_id = &pid);

    if( !( om_msg & *msg & 1 ))
    {
/*	UI_status("Assembly file is not defined as part");*/
	ex$message( msgnumb = EMS_S_NoPrtDef );
        goto quit;
    }

    if( me->prt_list )
        free( me->prt_list );
    me->prt_list = NULL;
    me->num_inst = 0;

    i = -1;
    om_msg = EMget_cpart_list( &pid, &env, &i, 0, &me->prt_list, &me->num_inst);
/*
printf("numinst with constr = %d\n", me->num_inst );
for(i = 0; i < me->num_inst; i++)
printf(" %d. objid=%d osnum=%d\n",i+1, me->prt_list[i].objid, me->prt_list[i].osnum);
*/
    /*
     * First, get the constrained parts in the current environment

    om_msg = om$send( msg = message ECmngcnstr.get_cnstr_prts_in_env( msg,
                                                                &env ),
                            targetid = my_id );

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    om_msg = asm$part_count (msg = msg,
                             mod_env = &env,
                             type = EM_CACHED_PART,
                             count = &prt_count);
        
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
        
    for (i=0; i<prt_count; ++i)
    {

        om_msg = asm$get_part (msg = msg,
                               mod_env = &env,
                               type = EM_CACHED_PART,
                               index = i,
                               part_id = &pid);

        |*
         * Get one of the instances
         *|
        if (om_msg & *msg & 1)
        {
            om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                               NULL,
                                                               EM_INSTANCE,
                                                               0,
                                                               &memb),
                          targetid = pid.objid,
                          targetos = pid.osnum );

            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
        
            |*
             * Get the reference file.
             *|
            om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                               NULL,
                                                               EM_GRAPHIC,
                                                               0,
                                                               &memb),
                          targetid = memb.id.objid,
                          targetos = memb.id.osnum);

            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }   
        
            |*
             * Get the module for the reference file.
             *|
            om_msg = om$send (msg = message GRreffile.GRgetenvironment
                                                  (msg,
                                                   &env_path,
                                                   &env),
                          targetid = memb.id.objid,
                          targetos = memb.id.osnum);
        
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }

            om_msg = om$send( msg = message ECmngcnstr.get_cnstr_prts_in_env( 
                                                                msg,
                                                                &env ),
                            targetid = my_id );

            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
        }
        else
        {
            goto quit;
        }
    }

    */

quit:
    return( om_msg );
}

method get_cnstr_prts_in_env( IGRlong *rc; struct GRmd_env *env )
{
int             i, j, cnstr_count,prt_count, inst_count;
struct GRid     pid, iid;
int             om_msg;
long		msg;


    om_msg = asm$part_count (msg = &msg,
                             mod_env = env,
                             type = EM_CACHED_PART,
                             count = &prt_count);
        
    if (!(om_msg & msg & 1))
    {
        *rc = MSFAIL;
	verbose(printf("part count failed\n"));
        return( OM_E_ABORT );
    }
        
    for (i=0; i<prt_count; ++i)
    {

        om_msg = asm$get_part (msg = &msg,
                               mod_env = env,
                               type = EM_CACHED_PART,
                               index = i,
                               part_id = &pid);

        if (om_msg & msg & 1)
        {
            om_msg = asm$instance_count (msg = &msg,
                                     part_id = &pid,
                                     count = &inst_count);


            if (!(om_msg & msg & 1))
            {
                /* 
                 * KLUDGE: No instances for this part ???
                 *         Is this possible 
                 */
                continue;
            }
        
            for (j=0; j<inst_count; ++j)
            {
                om_msg = asm$get_instance (msg = &msg,
                                       part_id = &pid,
                                       index = j,
                                       instance_id = &iid);

                if (om_msg & msg & 1)
                {
                    /* 
                     * Check if there are any constraints on this instance
                     */
                    om_msg = om$send( msg = message ECmngcnstr.get_constr(
                                                                &msg, &iid,
                                                                &cnstr_count,
                                                                NULL ),
                                            targetid = my_id );
                    if( om_msg & msg & 1 )
                    {
                        if( cnstr_count > 0 )
                        {                    
                            /*
                             * Store the instance grid in my_id
                             */
                            if( me->prt_list == NULL )
                                me->prt_list = (struct GRid *)malloc(
                                                   sizeof( struct GRid ));
                            else
                                me->prt_list = (struct GRid *)realloc(me->prt_list,
                                                             (me->num_inst+1) * 
                                                             sizeof( struct GRid ));
                            me->prt_list[me->num_inst] = iid;
                            me->num_inst++;
                        }
                    }
                    else
                    {
                        verbose(printf("get constr count failed on %d instance\n",j));
                        continue;
                    }
                }
                else
                {
                    /* get_instance failed */
                    verbose(printf("get %d instance failed\n",j));
                    continue;
                }
            }   
        }
        else
        {
            /* get_part failed */
            verbose(printf("get %d part failed\n",i));
            continue;
        }
    }

    return( OM_S_SUCCESS );
}

method get_appl_prts_list ( IGRlong *rc )
{
long msg;
int  om_msg, i;
struct GRid prt_grid;

    *rc = MSSUCC;
    if( ! me->appl_prt_list )
    {
        me->appl_prt_list = ( struct GRid * )malloc( me->num_cnstr * 
                                                sizeof( struct GRid ));
        me->inc_flag = (int *)malloc( me->num_cnstr * sizeof(int) ) ;
    }
    else
    {
        me->appl_prt_list = ( struct GRid * )realloc( me->appl_prt_list,
                                        me->num_cnstr * sizeof( struct GRid ));
        me->inc_flag = (int *)realloc( me->inc_flag, 
                                        me->num_cnstr * sizeof( int ) ) ;
    }

    for( i = 0; i < me->num_cnstr; i++ )
    {
        om_msg = om$send( msg = message EMconstr.EMgetpart(&msg,FALSE,&prt_grid),
                            targetid = me->cnstr_list[i].objid,
                            targetos = me->cnstr_list[i].osnum);
        if( om_msg & msg & 1 )
        {
            if( (prt_grid.objid == me->prt_list[me->cur_prt].objid ) &&
                (prt_grid.osnum == me->prt_list[me->cur_prt].osnum ))
            { 
                /* 
                 * Get the other part
                 */
                om_msg = om$send( msg = message EMconstr.EMgetpart(&msg,TRUE,&prt_grid),
                            targetid = me->cnstr_list[i].objid,
                            targetos = me->cnstr_list[i].osnum);
                if( om_msg & msg & 1 )
                {
                    me->appl_prt_list[i] = prt_grid;
                    me->inc_flag[i] = 1;
                }
                else
                {
                    verbose(printf("failed to get second part\n"));
                    *rc = MSFAIL;
                    return( OM_E_ABORT );
                }
            }
            else
            {
                me->appl_prt_list[i] = prt_grid;
                me->inc_flag[i] = 0;
            }
        }
        else
        {
            verbose(printf("failed to get first incident part\n"));
            *rc = MSFAIL;
            return( OM_E_ABORT );
        }
    }

    return( OM_S_SUCCESS );
}

method get_constr( IGRlong *rc; struct GRid *inst_id; int *ocount;
					 struct GRid **cnstr_list )
{
int     cnt, om_msg, i;
struct  GRid *list;
OMuword classid;

    *rc = MSSUCC;

    cnt = 0;
    *ocount = 0;
    om_msg = om$send( msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,NULL,
                                              0,&list,0,OM_K_MAXINT,&cnt),
                     targetid = inst_id->objid,
                     targetos = inst_id->osnum);

    if (om_msg & 1)
    {
        for (i = 0; i < cnt; i++)
        {
            om$get_classid (objid = list[i].objid, 
                            osnum = list[i].osnum,
                            p_classid = &classid);

            if (om$is_ancestry_valid (subclassid = classid,
                superclassid = OPP_EMconstr_class_id) == OM_S_SUCCESS)
            {
                if( cnstr_list == NULL )
                {
                    /*
                     * Just return the count of constraints
                     */
                    *ocount = cnt;
                    return (OM_S_SUCCESS);
                }

                if( ! *cnstr_list )
                    *cnstr_list = (struct GRid *)malloc( (*ocount+1) *
                                                         sizeof(struct GRid));
                else
                    *cnstr_list = (struct GRid *)realloc( *cnstr_list, 
                                                (*ocount+1)*sizeof(struct GRid));

                (*cnstr_list)[(*ocount)++] = list[i];
            }
        }
    }
    else
    {                        
	verbose(printf("NDget_objects failed 2, inst_obj=%d\n",inst_id->objid));
        *rc = MSFAIL;
        return( OM_E_ABORT );
    }

    cnt = 0;
    om_msg = om$send( msg = message NDnode.NDget_objects(ND_CHILDREN|ND_IN_BUF,
                                        NULL,0,&list,0,OM_K_MAXINT,&cnt),
                     targetid = inst_id->objid,
                     targetos = inst_id->osnum);

    if (om_msg & 1)
    {
        for (i = 0; i < cnt; i++)
        {
            om$get_classid (objid = list[i].objid, 
                            osnum = list[i].osnum,
                            p_classid = &classid);

            if (om$is_ancestry_valid (subclassid = classid,
                superclassid = OPP_EMconstr_class_id) == OM_S_SUCCESS)
            {
                if( cnstr_list == NULL )
                {
                    /*
                     * Just return the count of constraints
                     */
                    *ocount = cnt;
                    return (OM_S_SUCCESS);
                }
                if( !*cnstr_list )
                    *cnstr_list = (struct GRid *)malloc( (*ocount+1) * 
                                                    sizeof(struct GRid));
                else
                    *cnstr_list = (struct GRid *)realloc( *cnstr_list, 
                                         (*ocount+1) * sizeof(struct GRid));

                (*cnstr_list)[(*ocount)++] = list[i];
            }
        }
    }
    else
    {                        
	verbose(printf("NDget_objects failed 3, inst_obj = %d\n", inst_id->objid ));
        *rc = MSFAIL;
        return( OM_E_ABORT );
    }
    
    return( OM_S_SUCCESS );
}

method highlight_cnstr_fea( IGRlong *rc; struct GRid *cnstr_id; IGRint mode )
{
int om_msg, i, type;
long msg;
struct GRid fea_ids[2], prt_grid;
struct GRmd_env envs[2];

    *rc = MSSUCC;
    EMgetconstrtype( *cnstr_id, &type );
    if( type == GROUND ) 
    {
        /* Get the Part Grid */
        om_msg = om$send( msg = message EMconstr.EMgetpart(&msg,
                                                        1, &prt_grid),
                            targetid = cnstr_id->objid,
                            targetos = cnstr_id->osnum);

        if( !(om_msg & msg & 1) )
        {
            verbose(printf("getpart for ground failed\n"));
            return( OM_E_ABORT );
        }
        EMHiLiteObject( &msg, &prt_grid, NULL, mode );

        return( OM_S_SUCCESS );
    }

    om_msg = om$send( msg = message EMconstr.EMget_ftrs_with_env( &msg, fea_ids,
                                                                envs ),
                                        targetid = cnstr_id->objid,
                                        targetos = cnstr_id->osnum );
    if( om_msg & msg & 1 )
    {
        for( i = 0; i < 2; i++ )
        {
            /*
             * Highlight display/erase the feature graphics
             */
            EMHiLiteObject( &msg, &fea_ids[i], &envs[i], mode );
        }
    }
    else
    {
        verbose(printf("failed to get constraint feature ids\n"));
        return( OM_E_ABORT );
    }

    return( OM_S_SUCCESS );
}

EMHiLiteObject( rc, obj, env, mode  )
IGRlong *rc;
struct GRid *obj;
struct GRmd_env *env;
IGRint mode;
{
struct GRmd_env mod_env;
int om_msg, olweight;
long msg, sizbuf;
struct GRid modid;
struct IGRdisplay act_disp;

    *rc = MSSUCC;
    if( env == NULL )
    {
        /*
         * Get the current module enviroment.
         */	
        sizbuf = sizeof( struct GRmd_env );
        gr$get_module_env(msg = &msg,
                      sizbuf = &sizbuf,
                      buffer = &mod_env );
    }
    else mod_env = *env;

    ex$get_cur_mod( id = &modid.objid, osnum = &modid.osnum );

    {
        gr$get_active_display( buffer = &act_disp );
        olweight = act_disp.weight;
        act_disp.weight = 2;

        om_msg = om$send(msg = message GRgraphics.GRdisplay(&msg, 
					&mod_env.md_env.matrix_type, 
					mod_env.md_env.matrix, 
					(enum GRdpmode * )(&mode), &modid), 
                  senderid = obj->objid,					
        	  targetid = obj->objid, 
	          targetos = obj->osnum);

        act_disp.weight = olweight;	          
        gr$put_active_display( buffer = &act_disp );
    }

    return( OM_S_SUCCESS );
}

method edit_cnstr( IGRlong *rc; int cnstr_num )
{
int  om_msg, response, batch_mode;
long msg;
char buffer[158], response_data[256], offset[128];
struct GRevent event;
double  offsetval;

    *rc = MSSUCC;
    if( (cnstr_num >= 0) && (cnstr_num < me->num_cnstr) )
    {
    	om_msg = om$send( msg = message EMconstr.EMget_offset( &msg, &offsetval, NULL ),
                                targetid = me->cnstr_list[cnstr_num].objid,
                                targetos = me->cnstr_list[cnstr_num].osnum);
	if( !(om_msg & msg & 1 ))
	{
	        verbose(printf("get_offset failed\n" ));
		return( OM_E_ABORT );
	}
    }
	
    /*
     * Show the current offset to the user and get new offset value
     */
    sprintf( buffer,"Enter new offset [%f]", offsetval );
    sprintf( offset, "%f", offsetval );
    om_msg = co$getevent( msg = &msg,
	                     event_mask = GRm_STRING|GRm_RJT_MOVEON,
	                     prompt = buffer,
               		     response = &response,
                	     response_data = response_data,
        	             event = &event );
    /* an expression */
    if( (event.response == EX_STRING) && strlen(event.event.keyin))
	strcpy( offset, event.event.keyin );
    om_msg = om$send( msg = message EMconstr.EMset_offset( &msg, offset ),
                                targetid = me->cnstr_list[cnstr_num].objid,
                                targetos = me->cnstr_list[cnstr_num].osnum);

    if( !(om_msg & msg & 1 ) )
    {
        verbose(printf("set_offset failed\n"));
        return( OM_E_ABORT );
    }

    /*
     * Run the batch if necessary.
     */
    nd$mod_batch (request = ND_INQ, p_ret_mode = &batch_mode);
   
    if (batch_mode == ND_IMMEDIATE)
    {
        nd$exec_batch ();
    }


    return( OM_S_SUCCESS );    
}


end implementation ECmngcnstr;
