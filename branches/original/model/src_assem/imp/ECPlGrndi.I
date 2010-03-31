class implementation ECPlGrnd;

#include "igetypedef.h"
#include "igrtypedef.h"
#include "tools.h"
#include "FI.h"
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <igr.h>
#include <gr.h>
#include <igrdp.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include <go.h>
#include "DIdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "refdef.h"

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

#define FINISHED        -1
#define START            0
#define GET_INST         1
#define PLACE_GRND       3
#define OVER_CONSTRAINED 4

/* Gadgets for conflicting constraints form */
#define CNSTR_MCF	11
#define DEL_BUTTON	16

#define CONSTR	0
#define PART1	1
#define PART2	2

from EMinstance import EMupdatebasis;
from EMconstr   import EMprocess_constr_addition;
from EMconstr   import EMgetpart;
from EMconstr   import EMget_ftrs_with_env;

method init(int type; char *str_ptr)
{

    me->state = START;
    me->fp = NULL;
    me->currow = me->curcol = -1;

    return( OM_S_SUCCESS );
}

method wakeup( int pos )
{
    if( me->fp )
        FIf_display( me->fp );

    ex$message( msgnumb = EM_M_PlGrnd );
    ex$message( msgnumb = EMS_S_ClearStatusField );

    return( OM_S_SUCCESS );
}

method sleep( int pos )
{
    if( me->fp )
        FIf_erase( me->fp );

    return( OM_S_SUCCESS );
}

method delete( int pos )
{
    long sts;
    if( me->fp )
        FIf_delete( me->fp );
    
    sts = om$send( mode      = OM_e_wrt_message,    
                   msg       = message COpara.delete(1),     
                   targetid  = my_id);

    return( OM_S_SUCCESS );
}

IGRint EMchk_grounded ( msg, select_args, usdata )
IGRlong *msg;
struct LC_select_args *select_args ;
IGRchar *usdata ;
{
IGRint  sts, mode ;
struct GRid part_grid ;
struct GRmd_env mod_info ;

    usdata = NULL; /* silence compiler */
    /*
     * Check if the object located has a ground
     */
    part_grid = select_args -> stack ->  entry[0].located_obj ; 
    mod_info = select_args -> stack  -> entry[0].module_info ;

    sts = EMis_part_grounded( msg, &part_grid );

    if( sts )
    {
        UI_status( "Part is grounded" );
        sts = 0;
        goto quit;
    }

    mode = GRhd;
    sts = EMhighlight_obj( &part_grid, &mod_info, mode );

    if( !(sts & 1))
        goto quit;

    /* Now invoke lc$select to do accept/reject */
    sts = lc$select(msg = msg, args = select_args );

    mode = GRhe;
    sts = EMhighlight_obj( &part_grid, &mod_info, mode );

quit:
    return(sts);
}

IGRint EMis_part_grounded( IGRlong *msg, struct GRid *part )
{
int om_msg, cnt = 0, i, flg, type;
struct GRid cnstrid;

    om_msg = asm$get_constraints_count( msg = msg,
                                       in_out = 0,
                                       part_id = part,
                                       count = &cnt );
    if( !(om_msg & *msg & 1) || !cnt )
        return( 0 );

    for( i = 0; i < cnt; i++ )
    {
        type = 0;
        om_msg = asm$get_constraint( msg = msg,
                                     part_id = part,
                                     index = i,
                                     in_out = &flg,
                                     type = &type,
                                     cnstrid = &cnstrid );
        if ( !(om_msg & *msg & 1 ) )
            continue;

        if( type == GROUND )
            return( 1 );
    }
    return(0);
}


method execute( int *response; char *response_data; int pos )
{
IGRint                  om_msg, sizbuf;
IGRlong			msg, locate_display;
struct GRevent          event, locev;
struct GRmd_env         mod_env;
IGRint                  count;
OM_S_CLASSLIST          elig_classes;
OMuword                 classes[2];
struct GRlc_locate      lc_attribs;
struct GRlc_stack       lc_stack;
IGRchar                 buffer[256];
/*
IGRint                  batch_mode;
IGRint                  part_type;
*/

    IGRboolean aflag = 0;
    if(aflag = pwIsActivationOn() )
    {
     ex$message (in_buff="Deactivate the activated part",
                 field=ERROR_FIELD);
     *response = TERMINATE;
     return (OM_S_SUCCESS);
    }

    ex$message(msgnumb = EM_M_PlGrnd);/*"Place Part Ground Constraint"*/

    /*
     * Get the current module environment.
     */	
    sizbuf = sizeof( struct GRmd_env );
    gr$get_module_env(msg = &msg,
                      sizbuf = &sizbuf,
                      buffer = &mod_env );
    /*
     * Settings for locate ...
     */
    lc_attribs.properties = LC_LC_ONLY | LC_DP_ONLY ;
    lc_attribs.owner_action = LC_RIGID_COMP    | LC_FLEX_COMP   |
                            LC_NO_REF_HEADER | LC_REF_OBJECTS |
                            LC_ASSOCIATIVE |
                            LC_EXTERN_CONSTRAINED;

    locate_display  =  ALL_WINDOWS | ELEM_HILIGHT |
                       ACC_REJ_CYCLE | RELOCATE | LC_ACCEPT_CURSOR ;

    om$get_classid(classname = "EMinstance",
			p_classid = &classes[0]);

    elig_classes.w_count = 1;
    elig_classes.p_classes = classes;
    elig_classes.w_flags = OM_CLST_subclass;

    switch (me->state)
    {
        /*
         * (Re)initialize the command.
         */
        case START:
            me->inst_id.objid = NULL_OBJID;
            me->constraint_id.objid = NULL_OBJID;
            if( me->ids )
                free( me->ids );
            me->ids = NULL;
            me->num_ids = 0;
	    me->fp = NULL;            
            me->state = GET_INST;
            me->currow = me->curcol = -1;
            me->cnstr_deleted = 0;

            *response = RESET;

            break;

        case GET_INST:

    	    lc_stack.number_located = 0;
            lc_stack.num_entries = 0;

            lc$locate(rc           = &msg,
                 event1            = &locev,
                 event2            = &event,
                 display_flag      = locate_display,
                 attributes        = &lc_attribs,
		 select            = EMchk_grounded,
                 response          = response, 
                 response_data     = response_data,
                 locate_prompt     = "Select Part to Ground",
                 acc_prompt        = "Accept/Reject",
                 relocate_prompt   = "Part not found",
                 stack             = &lc_stack,
                 eligible_classes  = &elig_classes);

            switch (*response)
            {
            case EX_DATA:
                /*
                 * Get the inst id from the stack
		 * and Erase highlight of located part 
		 */
		dp$display(
        	        msg = &msg,
                	oids = &lc_stack.entry[0].located_obj ,
	                mode = GRhe
        	       );

		me->inst_id = lc_stack.entry[0].located_obj;
/*
 * KLUDGE: Temporary:
 * check if the located part has any constraints coming in, ie., if it has
 * any constraints as root, and if so, disqualify the part for grounding.
 */
		om_msg = asm$get_constraints_count( msg = &msg,
						in_out = 0,
						part_id = &me->inst_id,
						count = &count );
        	if ( (om_msg & 1) && count )
        	{
                    if( count > 1 )
                    {
                        ex$message( msgnumb = EMS_S_ILLGRND );
                        me->state = START;
                        break;
                    }
	            else if( count == 1 ) 
       		        me->state = PLACE_GRND;
                }
                else                    
        	    me->state = PLACE_GRND;

		*response = RESET;
                break;
                
            case EX_RJT_MOVEON:
                *response = RESET;
                break;

            case EX_BACK_UP:
                *response = RESET;
                break;
            }
            break;

        case PLACE_GRND:
            om_msg = asm$add_constraint (msg = &msg,
                                         instance2_id = &me->inst_id,
                                         constraint_id = &me->constraint_id,
                                         num_ids = &me->num_ids,
                                         ids = &me->ids);
            if( !( om_msg & msg & 1 ))
            {
                if( msg == ASM_E_OVERCONSTRAINED )
                {
                    me->state = OVER_CONSTRAINED;
                    *response = RESET;
                    break;
                }
                else
                {
		    ex$message( msgnumb = EMS_S_OpFail );
    		    verbose(printf("Place ground failed\n"));
                }
            }
	    else
	    {
		/*
		 * update the basis in the two instances
		 */
		om_msg = om$send( msg = message EMinstance.EMupdatebasis(&msg),
                                        targetid = me->inst_id.objid,
                                        targetos = me->inst_id.osnum );
                if( !(om_msg & msg & 1 ))
                    verbose(printf("EMupdatebasis 1 failed\n"));            
	    }
	    me->state = START;
	    *response = RESET;
            break;

        case OVER_CONSTRAINED:
            ex$message( msgnumb = EMS_S_OverCnstrPart ); 

            /* 
             * Display the conflicting constraints in the Form
             */
            if((me->num_ids) && (me->fp == NULL))
                om_msg = om$send( msg = message ECPlGrnd.show_over_cnstr(
                                                            &msg ),
                                 targetid = my_id );

            /*
             * Wait for User Response 
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
                /*
                 * If none of the conflicting constraints is deleted,
                 * delete the current constraint and restart.
                 */
                if( !me->cnstr_deleted )
                {
                     om_msg = asm$rem_constraint (msg = &msg,
                                     constraint_id = &me->constraint_id);

                     if( !(om_msg & msg & 1 ) )
                     {
                          verbose(printf("Delete constraint failed\n"));
                          *response = TERMINATE;
                          break;
                     }
                }
                else if( me->constraint_id.objid != NULL_OBJID )
		{
		    /* 
                     * If some other constraint is deleted
                     */
                    me->num_ids = 0;
                    free( me->ids );
		    me->ids = NULL;
                    om_msg = om$send (msg = message EMconstr.EMprocess_constr_addition
                                                    (&msg, &me->num_ids,
                                                      &me->ids),
                                 targetid = me->constraint_id.objid,
                                 targetos = me->constraint_id.osnum);
                    if( !(om_msg & msg & 1) )
                    {
                         verbose(printf("Process Constraint failed\n"));
                         *response = TERMINATE;
                         break;
                    }
		}
    	        me->state = START;
                *response = RESET;
            }
            break;

    }

    return( OM_S_SUCCESS );
}

int conf_cnstr_notify2(form_label, gadget_label, value, form_ptr)
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

 	status = om$send (msg = message ECPlGrnd.do_form(&msg_loc, form_label,
				                gadget_label, value),
		            senderid = NULL_OBJID, 
		            targetid = cmdobj,
		            targetos = cmdos);
	if(! (status & 1))
		 return (OM_E_ABORT);

 	return(OM_S_SUCCESS);
}

method show_over_cnstr ( IGRlong *rc )
{
int  om_msg, ret, i, j, type;
long msg;
char inst_name[128];
struct GRid prt_grid;

    *rc = MSSUCC;
    ret = FIf_new(100, "EMConfCnstr", conf_cnstr_notify2, &me->fp);
    if(ret)
	return (OM_E_ABORT);

    ret = FIf_set_cmd_oid_os(me->fp, my_id, OM_Gw_current_OS);
    if(ret) 
	return (OM_E_ABORT);

    /* 
     * Get the instances connected to each of the conflicting constraint
     * and display them in the form
     */
    for( i = 0; i < me->num_ids; i++ )
    {
	EMgetconstrtype( me->ids[i], &type );
	if( type == ALIGN )
            FIfld_set_text( me->fp, CNSTR_MCF, i, 0, "ALIGN",0);
	else if( type == MATE )
            FIfld_set_text( me->fp, CNSTR_MCF, i, 0, "MATE",0);
        else if ( type == GROUND )
            FIfld_set_text( me->fp, CNSTR_MCF, i, 0, "GROUND",0);
	else
        {
            verbose(printf("Unknown constraint type\n"));
            *rc = MSFAIL;
            goto wrapup;
        }
        /*
         * Get the two instances on which the constraint is acting
         */
        for( j = 0; j < 2; j++ )
        {
            om_msg = om$send( msg = message EMconstr.EMgetpart(&msg,j,&prt_grid),
                            targetid = me->ids[i].objid,
                            targetos = me->ids[i].osnum);
            if( !(om_msg & msg & 1) )
            {
                verbose(printf("EMconstr.EMgetpart1 failed\n"));
                *rc = MSFAIL;
                goto wrapup;
            }
	    if( prt_grid.objid != NULL_OBJID ) /* case of GROUND */
	    {
            	om_msg = EMget_instance_name( &msg,&prt_grid,inst_name );

                if( !( om_msg & msg & 1 ) )
                {
                    verbose(printf("EMgetinstance1 failed\n"));
                    *rc = MSFAIL;
                    goto wrapup;
                }
                FIfld_set_text( me->fp, CNSTR_MCF, i, j+1, inst_name, 0 );
            }
        }
    }
    FIf_display( me->fp );

wrapup:
    return( OM_S_SUCCESS );
}

method do_form( IGRlong *msg; int form_label; int g_label; double value )
{
int row, col, sf;
int om_msg;
long msg;

 	FIg_set_text( me->fp, FI_MSG_FIELD, "" );

  	switch ( g_label )
  	{
            case CNSTR_MCF:
	        FIfld_get_active_row( me->fp, CNSTR_MCF, &row, &sf );
                FImcf_get_active_col( me->fp, CNSTR_MCF, &col, &sf );
                /* Erase highlight first */
                if( me->currow != -1 && me->curcol != -1 )
                om_msg = om$send( msg = message ECPlGrnd.hilite_element
                                                ( &msg, me->currow, me->curcol,
                                                 GRhe ),
                                targetid = my_id );

                om_msg = om$send( msg = message ECPlGrnd.hilite_element
                                                ( &msg, row, col, GRhd ),
                                targetid = my_id );
                me->currow = row;
                me->curcol = col;
                break;
            case DEL_BUTTON:
                if( me->curcol != 0 )
                {
                    FIg_set_text( me->fp, FI_MSG_FIELD, "Select constraint to Delete");
                    break;
                }
                om_msg = om$send( msg = message ECPlGrnd.hilite_element
                                                ( &msg, me->currow, me->curcol,
                                                 GRhe ),
                                targetid = my_id );

                om_msg = asm$rem_constraint( msg = &msg,
                             constraint_id = &me->ids[me->currow]);
                if( !( om_msg & msg & 1 ) )
                {
                    verbose(printf("Delete failed on constr no. %d\n",me->currow));
                    break;
                }
                else
                {
	            me->cnstr_deleted = 1;
                    /* If the current constraint is deleted */
                    if((me->ids[me->currow].objid == me->constraint_id.objid)&&
                       (me->ids[me->currow].osnum == me->constraint_id.osnum))
                        me->constraint_id.objid = NULL_OBJID;
                }

                FIf_erase( me->fp );
                FIf_delete( me->fp );
                {
    	        int	 rsp = EX_FORM_FINISHED;
    	        long stat;
	
	        ex$putque(msg = &stat, response = &rsp);
	        }
                break;
            case FI_ACCEPT:
            case FI_CANCEL:
                if( me->currow != -1 && me->curcol != -1 )
                om_msg = om$send( msg = message ECPlGrnd.hilite_element
                                                ( &msg, me->currow, me->curcol,
                                                 GRhe ),
                                targetid = my_id );
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

method hilite_element( IGRlong *rc; IGRint row; IGRint col; IGRint mode )
{
int om_msg, i, sf, rp;
long msg;
struct GRid fea_ids[2], prt_grid;
struct GRmd_env envs[2];
char buff[20];

    *rc = MSSUCC;

    switch( col )
    {
        case CONSTR:
	    FIfld_get_text( me->fp, CNSTR_MCF, row, col, 20, buff, &sf, &rp );
	    if( !strcmp( buff, "GROUND" ) )
            {
                /* Get the Part Grid */
                om_msg = om$send( msg = message EMconstr.EMgetpart(&msg,
                                                        1, &prt_grid),
                            targetid = me->ids[row].objid,
                            targetos = me->ids[row].osnum);

                if( !(om_msg & msg & 1) )
                {
                    verbose(printf("getpart for ground failed\n"));
                    break;
                }
                EMhighlight_obj( &prt_grid, NULL, mode );
		break;
            }
            om_msg = om$send( msg = message EMconstr.EMget_ftrs_with_env( &msg,
                                                                fea_ids,
                                                                envs ),
                                        targetid = me->ids[row].objid,
                                        targetos = me->ids[row].osnum );
            if( om_msg & msg & 1 )
            {
                for( i = 0; i < 2; i ++ )
                {
                    /*
                     * Highlight display/erase the feature graphics
                     */
                    EMhighlight_obj( &fea_ids[i], &envs[i], mode );
                }
            }
            else
            {
                verbose(printf("failed to get constraint feature id\n"));
                return( OM_E_ABORT );
            }
            break;
            
        case PART1:
        case PART2:
            om_msg = om$send( msg = message EMconstr.EMgetpart(&msg,col-1,
                                                            &prt_grid),
                            targetid = me->ids[row].objid,
                            targetos = me->ids[row].osnum);

            if( om_msg & msg & 1 )
            {
		if( prt_grid.objid != NULL_OBJID )
                    EMhighlight_obj( &prt_grid, NULL, mode );
            }
            break;
    }
    return( OM_S_SUCCESS );
}

end implementation ECPlGrnd;
