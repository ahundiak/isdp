class implementation ECshucnstr;

#include "igetypedef.h"
#include "igrtypedef.h"
#include "tools.h"
#include "FI.h"
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <OMmacros.h>
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
#include "asdef.h"
#include "coparamac.h"

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

#define FINISHED       -1
#define START           0
#define GET_INST        1
#define SHOW_PRT_DOF	2

from EMinstance import EMgivebasis;
from EMinstance import EMget_incident_constr;
from EMconstr   import EMget_ftrs_with_env;

method init(int type; char *str_ptr)
{
    me->state = START;
    me->fp = NULL;

    me->num_prts = 0;
    init_dof_display();

    return( OM_S_SUCCESS );
}

method wakeup( int pos )
{
    if( me->fp )
        FIf_display( me->fp );

    ex$message( msgnumb = EM_M_ShUCnstr );
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
int i, om_msg;
long msg,sts;

    if( me->fp )
        FIf_delete( me->fp );
/*
    for ( i = 0; i < me->num_prts; i++ )
    {
        om_msg = show_dof_part( &msg,&me->prts_list[i], GRhe );

        if( !( om_msg & msg & 1 ) )
            printf("showdofpart %d failed\n",i );
    }
*/
     sts = om$send( mode      = OM_e_wrt_message,
                    msg       = message COpara.delete(1),
                    targetid  = my_id);
    return( OM_S_SUCCESS );
}

method execute( int *response; char *response_data; int pos )
{
IGRint                  om_msg;
IGRlong			msg, locate_display;
struct GRevent          event, locev, event3;
struct GRid             *objects;
IGRint                  i, count;
int                     full_cnstr_cnt, tot_cnt;
OM_S_CLASSLIST          elig_classes;
OMuword                 classes[2];
struct GRlc_locate      lc_attribs;
struct GRlc_stack       lc_stack;
IGRlong mask1,mask2;
char buf[256];

    ex$message(msgnumb = EM_M_ShUCnstr);/*"Show Under-Constrained Assy"*/

    /*
     * Settings for locate ...
     */
    lc_attribs.properties = LC_LC_ONLY | LC_DP_ONLY ;
    lc_attribs.owner_action = LC_RIGID_COMP    | LC_FLEX_COMP   |
                            LC_NO_REF_HEADER | LC_REF_OBJECTS |
                            LC_ASSOCIATIVE |
                            LC_EXTERN_CONSTRAINED;
    locate_display  =  ALL_WINDOWS | ELEM_HILIGHT | LC_ERASE_LOC_ELEMENT |
                       ACC_REJ_CYCLE | RELOCATE | LC_ACCEPT_CURSOR ;

    mask1 = mask2  = GRm_DATA | GRm_STRING |GRm_RESET | GRm_BACK_UP|
                   GRm_SPECIFIED_OBJ|GRm_FORM_FINISHED;

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
            
            me->state = GET_INST;
            *response = RESET;

            break;

        case GET_INST:

    	    lc_stack.number_located = 0;
            lc_stack.num_entries = 0;

            lc$locate(rc           = &msg,
                 event1            = &locev,
                 event2            = &event,
                 event3            = &event3,
                 mask1             = mask1,
                 mask2             = mask2,
                 display_flag      = locate_display,
                 attributes        = &lc_attribs,
                 response          = response, 
                 response_data     = response_data,
                 locate_prompt     = "Select Part(s)/Moveon",
                 acc_prompt        = "Accept/Reject",
                 relocate_prompt   = "Part not found",
                 stack             = &lc_stack,
                 eligible_classes  = &elig_classes);

            if( *response == EX_RJT_MOVEON )
	    {
                /*
                 * Get the list of all constrained parts, display the 
                 * dof on underconstrained parts, and show a message
                 * "XPRTS/ALLPRTS constrained; YPRTS fully constrained"
                 */
                om_msg = om$send( msg = message ECshucnstr.get_dof_assy(
                                                            &msg,
                                                            &full_cnstr_cnt,
                                                            &tot_cnt ),
                                        targetid = my_id );
                if( !( om_msg & msg & 1 ))
                {
                    verbose(printf("showdofassy failed\n"));
                }
                /* Display on the message strip */
		if( tot_cnt == full_cnstr_cnt )
	            sprintf(buf,"All the %d parts are fully constrained",
                                         			tot_cnt);
		else if( !full_cnstr_cnt )
                    sprintf(buf,"%d/%d parts constrained",
                                                  me->num_prts, tot_cnt);
                else
                    sprintf(buf,"%d/%d parts constrained, %d parts fully constrained",
                               (me->num_prts+full_cnstr_cnt), tot_cnt, full_cnstr_cnt);

	        UI_status( buf );
                me->state = SHOW_PRT_DOF;
                *response = RESET;
                break;
            }
            else if( msg == LC_OBJ_LOCATED)
            {
                as$start_fence(set = &event3.located_object[0].located_obj,
                                   nb_obj = &count,
                                   p_obj = &objects);

                om_msg = om$vla_set_dimension(varray = me->prts_list,
                                            size = count);
                if(! ( 1 & om_msg ) )
                {
                    verbose(printf("vla_set_dimension failed\n"));
                    *response = TERMINATE;
                    break;
                }
                me->num_prts = count;

                for(i =0; i < count; i++)
                {
/*
                    printf("obj%d: %d\n",i,objects[i].objid);
*/
                      me->prts_list[i] = objects[i]; 
                        /* Erase highlight */
    		    dp$display(
        	            msg = &msg,
                	    oids = &objects[i],
	                    mode = GRhe
        	       );
                }
                             
                ASend_fence();
    	        *response = RESET;
                me->state = SHOW_PRT_DOF;
                break;
            }
            break;            
/*
            switch ( *response )
            {
                case EX_DATA:
                    me->num_prts = 1;
                    om_msg = om$vla_set_dimension(varray = me->prts_list,
                                            size = me->num_prts);
                    me->prts_list[0] = lc_stack.entry[0].located_obj;

	    	    |* Erase highlight of located element - LC_ERASE_LOC 
                        not working *|
		    dp$display(
        	        msg = &msg,
                	oids = &lc_stack.entry[0].located_obj ,
	                mode = GRhe
        	       );
		    me->state = SHOW_PRT_DOF;
                    *response = RESET;
                    break;

                case SPECIFIED_OBJ:

                case EX_BACK_UP:
                    *response = RESET;
                    break;
            }
            break;
*/

        case SHOW_PRT_DOF:
            /* 
             * Display the dof on the selected parts
             */
            for ( i = 0; i < me->num_prts; i++ )
            {
                om_msg = show_dof_part( &msg, &me->prts_list[i], GRhd );

                if( !( om_msg & msg & 1 ) )
                    verbose(printf("showdofpart %d failed\n",i ));
            }
            me->state = START;
            break;
    }

    return( OM_S_SUCCESS );
}

show_dof_part( rc, part_id, mode )
IGRlong *rc;
struct GRid *part_id; 
int mode ;
{
int om_msg, cnt, type, indx=0;
unsigned int basis;
long msg;
struct GRid cnstr_id[MAX_INCIDENT_CONSTR], feature_grid[2], fid;
struct GRmd_env env[2], mdenv;
IGRchar instname[80], buffer[256];

    *rc = MSSUCC;
    
    /* 
     * Get the Basis from the instance data,
     * If the basis indicates that the part is fully constrained, 
     * display a message and return otherwise,
     * get incident featureids and display dof.
     */
    cnt = 0;
    om_msg = om$send( msg = message EMinstance.EMget_incident_constr( &msg,
                                                           &cnt,
                                                           cnstr_id ),
                            senderid = part_id->objid,
                            targetid = part_id->objid,
                            targetos = part_id->osnum );

    if( !(om_msg & msg & 1 ))
    {
        verbose(printf("failed to get incident constraints for part=%d\n", part_id->objid));
        return(OM_E_ABORT);
    }
    if ( cnt == 0 )
    {
/*        UI_status("No constraints acting on selected part");*/
        ex$message( msgnumb = EMS_S_NoCnstrActing );
        return( OM_S_SUCCESS );
    }
    om_msg = om$send( msg = message EMinstance.EMgivebasis( &msg, &basis ),
                            senderid = part_id->objid,
                            targetid = part_id->objid,
                            targetos = part_id->osnum );
    if( !(om_msg & msg & 1 ) )
    {
        verbose(printf("givebasis failed\n"));
        return(OM_E_ABORT);
    }
    om_msg = EMget_instance_name( &msg, part_id, instname );

    switch( basis )
    {
        case NULL_BASIS_ID:
            verbose(printf("A part with incident constraint, has no basis ??\n"));
            break;
        case MATE_ONE_CONSTR: /* 2 ortho trans, 1 paral rot */
        case ALIGN_ONE_CONSTR:/* 1 paral trans, 1 paral rot */
            if( cnt != 1 )
            {
                verbose(printf("Error in part basis\n"));    
                return( OM_E_ABORT );
            }
            om_msg = om$send ( msg = message EMconstr.EMget_ftrs_with_env(
                                                            &msg,
                                                            feature_grid,
                                                            env ),
                            senderid = cnstr_id[0].objid,
                            targetid = cnstr_id[0].objid,
                            targetos = cnstr_id[0].osnum );
            if( !(om_msg & msg & 1 ))
            {
                verbose(printf("Error getting get_ftrs_with_env\n"));    
                return( OM_E_ABORT );
            }
            if( basis == MATE_ONE_CONSTR )
            {
                display_mate_dof( &feature_grid[1], &env[1], mode );
    	        sprintf( buffer, "%s - 2 trans, 1 rot", instname );
            }
            else
            {
                display_align_dof( &feature_grid[1], &env[1], mode, 2 );
    	        sprintf( buffer, "%s - 1 trans, 1 rot", instname );
            }
            UI_status( buffer );
            break;

        case MATE_MATE_PERP:  /* 1 ortho trans to both */
        case MATE_MATE_ANG:   /* 1 ortho trans to both */
            om_msg = om$send ( msg = message EMconstr.EMget_ftrs_with_env(
                                                            &msg,
                                                            feature_grid,
                                                            env ),
                            senderid = cnstr_id[0].objid,
                            targetid = cnstr_id[0].objid,
                            targetos = cnstr_id[0].osnum );
            if( !(om_msg & msg & 1 ))
            {
                verbose(printf("Error getting get_ftrs_with_env\n"));    
                return( OM_E_ABORT );
            }
            fid = feature_grid[1];
            mdenv = env[1];
            om_msg = om$send ( msg = message EMconstr.EMget_ftrs_with_env(
                                                            &msg,
                                                            feature_grid,
                                                            env ),
                            senderid = cnstr_id[1].objid,
                            targetid = cnstr_id[1].objid,
                            targetos = cnstr_id[1].osnum );
            if( !(om_msg & msg & 1 ))
            {
                verbose(printf("Error getting get_ftrs_with_env2\n"));    
                return( OM_E_ABORT );
            }
            feature_grid[0] = fid;
            env[0] = mdenv;
            /*
             * Get a unit vector along the line of intersection of the 
             * two mating planes, taken from each constraint.
             */
            display_mate_mate_dof( feature_grid, env, mode );
            sprintf(buffer, "%s - 1 trans", instname );
            UI_status(buffer);
            break;
        case MATE_ALIGN_PERP: /* 1 paral trans along Align */
        case MATE_ALIGN_PAR:  /* 1 paral rot on Align */
            /*
             * Get the align constraint featureid/env
             */
            EMgetconstrtype( cnstr_id[0], &type);
            if( type != ALIGN )
                indx = 1;
            om_msg = om$send ( msg = message EMconstr.EMget_ftrs_with_env(
                                                            &msg,
                                                            feature_grid,
                                                            env ),
                            senderid = cnstr_id[indx].objid,
                            targetid = cnstr_id[indx].objid,
                            targetos = cnstr_id[indx].osnum );
            if( !(om_msg & msg & 1 ))
            {
                verbose(printf("Error getting get_ftrs_with_env\n"));    
                return( OM_E_ABORT );
            }
            if( basis == MATE_ALIGN_PERP )
            {
                display_align_dof( &feature_grid[1], &env[1], mode, 0 );
                sprintf( buffer, "%s - 1 trans along align axis",instname);
            }
            else
            {
                display_align_dof( &feature_grid[1], &env[1], mode, 1 );
                sprintf( buffer, "%s - 1 rot about align axis",instname);
            }
            UI_status(buffer);
            break;
        case ALIGN_ALIGN_PAR: /* 1 paral trans to both */
            om_msg = om$send ( msg = message EMconstr.EMget_ftrs_with_env(
                                                            &msg,
                                                            feature_grid,
                                                            env ),
                            senderid = cnstr_id[0].objid,
                            targetid = cnstr_id[0].objid,
                            targetos = cnstr_id[0].osnum );
            if( !(om_msg & msg & 1 ))
            {
                verbose(printf("Error getting get_ftrs_with_env\n"));    
                return( OM_E_ABORT );
            }
            fid = feature_grid[1];
            mdenv = env[1];
            om_msg = om$send ( msg = message EMconstr.EMget_ftrs_with_env(
                                                            &msg,
                                                            feature_grid,
                                                            env ),
                            senderid = cnstr_id[1].objid,
                            targetid = cnstr_id[1].objid,
                            targetos = cnstr_id[1].osnum );
            if( !(om_msg & msg & 1 ))
            {
                verbose(printf("Error getting get_ftrs_with_env2\n"));    
                return( OM_E_ABORT );
            }
            feature_grid[0] = fid;
            env[0] = mdenv;
	    /*
             * Show the trans dof at the midpoint of the two aligns
             */
            display_align_align_dof( feature_grid, env, mode );
            sprintf(buffer, "%s - 1 trans", instname );
            UI_status(buffer);
            break;

        case GROUND_ONE_CONSTR:
        case ALIGN_ALIGN_PERP:
        case MATE_ALIGN_ANG:	
        case ALIGN_ALIGN_ANG:	
        case MATE_MATE_MATE_PERP_PERP_PERP:
        case MATE_MATE_MATE_PERP_PERP_ANG:
        case MATE_MATE_MATE_PERP_ANG_ANG:
        case MATE_MATE_MATE_ANG_ANG_ANG:
        case MATE_MATE_ALIGN_PERP_PERP_PAR:
        case MATE_ALIGN_ALIGN_PAR_PAR_PAR:
            /*
             * Part is fully constrained, no of dof = 0.
             */
            ex$message( msgnumb = EMS_S_PartFullCnstr );
/*	      UI_status("Part is Fully Constrained");*/
            
            break;
    }
    return( OM_S_SUCCESS );
}

method get_dof_assy( IGRlong *rc; int *fully_cnstr_prts; int *all_prts )
{
int  om_msg, i, j, inst_count, prt_cnt;
IGRuint basis;
long msg;
struct GRid pid, iid;

    *rc = MSSUCC;
    *fully_cnstr_prts = 0;
    me->num_prts = 0;
    *all_prts = 0;
    /*
     * Get the count & list of all the parts in the assembly ( all_prts ).
     */
    om_msg = asm$part_count (msg = &msg,
                             type = EM_REFERENCE_PART,
                             count = &prt_cnt);
        
    if (!(om_msg & msg & 1))
    {
        *rc = MSFAIL;
	verbose(printf("part count failed\n"));
        return( OM_E_ABORT );
    }

    /*
     * Looking at the basis of each part, get the count of fully & partially
     * constrained parts, and populate the instance data with underconstrianed
     * parts.
     */
    for( i = 0; i < prt_cnt; i++ )
    {
        om_msg = asm$get_part (msg = &msg,
                               type = EM_REFERENCE_PART,
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
            *all_prts += inst_count;

            for (j=0; j<inst_count; ++j)
            {
                om_msg = asm$get_instance (msg = &msg,
                                       part_id = &pid,
                                       index = j,
                                       instance_id = &iid);

	        if (om_msg & msg & 1)
        	{
	            om_msg = om$send( msg = message EMinstance.EMgivebasis(&msg,&basis),
                            targetid = iid.objid,
                            targetos = iid.osnum );
        	    if( !(om_msg & msg & 1 ) )
	            {
        	        verbose(printf("givebasis failed for prtid[%d]=%d\n",j, iid.objid));
                	return(OM_E_ABORT);
	            }
        	}

	        switch( basis )
        	{
	            case NULL_BASIS_ID:
        	        /*
                	 * No constraint acting 
	                 */
        	        break;
	            case MATE_ONE_CONSTR: /* 2 ortho trans, 1 paral rot */
        	    case ALIGN_ONE_CONSTR:/* 1 paral trans, 1 paral rot */
	            case MATE_MATE_PERP:  /* 1 ortho trans to both */
	            case MATE_MATE_ANG:   /* 1 ortho trans to both */
        	    case MATE_ALIGN_PERP: /* 1 paral trans along Align */
	            case MATE_ALIGN_PAR:  /* 1 paral rot on Align */
        	    case ALIGN_ALIGN_PAR: /* 1 paral trans to both */
                	/*
	                 * Add this part to the instance data list of parts
        	         */
	                om_msg = om$vla_set_dimension(varray = me->prts_list,
                                            size = (me->num_prts+1));
        	        if(! ( 1 & om_msg ) )
	                {
        	            verbose(printf("vla_set_dimension failed\n"));
                	    return( OM_E_ABORT );
	                }
        	        me->prts_list[me->num_prts] = iid;
                	me->num_prts++;
	                break;
    
        	    case GROUND_ONE_CONSTR:
	            case ALIGN_ALIGN_PERP:
        	    case MATE_ALIGN_ANG:	
	            case ALIGN_ALIGN_ANG:	
        	    case MATE_MATE_MATE_PERP_PERP_PERP:
	            case MATE_MATE_MATE_PERP_PERP_ANG:
        	    case MATE_MATE_MATE_PERP_ANG_ANG:
	            case MATE_MATE_MATE_ANG_ANG_ANG:
        	    case MATE_MATE_ALIGN_PERP_PERP_PAR:
	            case MATE_ALIGN_ALIGN_PAR_PAR_PAR:
        	        /*
	                 * Increment Fully constrained part count
        	         */
                	(*fully_cnstr_prts)++;                
	                break;
        	}
	    }
	}
    }


    return( OM_S_SUCCESS );
}
end implementation ECshucnstr;
