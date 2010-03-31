
/****************************************************************************
 * Name:     ECexpldassyi.I                                                 *
 *                                                                          *
 * Description: Explode Assembly command object                             *
 *                                                                          *
 * Remarks:                                                                 *
 *                                                                          *
 * History:                                                                 *
 *           creation     Krishnakumar     15/11/93                         *
 *           13-Dec-93    scw              fixed syntax error on line 650   *
 *           17-May-94    dkk              option for disabling cnstrs      *
 *           21-Dec-96    bbkr             Added action handler             * 
 *           14-Mar-97    Balamurugan      Added delete for stacking        *
 *                                         problem                          *
 ****************************************************************************/

class implementation ECexpldassy;

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
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "nddef.h"
#include "AS_status.h"
#include "expression.h"
#include "expmacros.h"

#include "ndmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "refdef.h"
#include "EMSasnuc.h"
#include "EMSsfparms.h"
#include "emssfdef.h"

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"
#include "assemconstr.h"

#include "tabledef.h"
#include "table.h"

#include "ECcmd.h"
#include "ECmsg.h"

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

extern OMuword OPP_EMSrevol_class_id;
extern OMuword OPP_EMSparamvc_class_id;
extern OMuword OPP_EMconstr_class_id;
extern OMuword OPP_EMinstance_class_id;

extern double BSdistptpt();

#define FINISHED       -1
#define START           0
#define GET_PART        1
#define EXPLD_ASSY	2
#define SAVECONFIG      3
#define CLEANUP         5

/* Gadget labels on Explode options form */
#define EXPLD_DEPTH     12 /* Not using at present */
#define EXPLD_OFFSET    13
#define EXPLD_STATE     23
#define ST_NUM_TXT      15
#define ST_NUMBER       16
#define TOGL_CNSTR_TXT  17
#define TOGL_CNSTR      14

#define MATE_EXPLD_OFF       5.0
#define ALIGN_EXPLD_OFF      5.0

#define SUBASSY     1
#define WHOLEASSY   0

#define EM_EXPLODED 0x10000000

from EMinstance import EMgivebasis, EMget_incident_constr;
from EMconstr   import EMset_offset, EMget_offset;
from GRtable    import GRnum_rows, GRadd_column, GRget_row, GRrun_row, GRnum_columns;
from GRreffile  import GRgetenvironment;
from GRtable    import GRget_expression;
from EMdescribe      import EMget_memb ;

from EMconstr     import EMget_ftrs_with_env;
from EMSparameter import EMgetdimgeom;
from EMSsurface   import EMget_params;
from GRgraphics   import GRchgprops;


method init(int type; char *str_ptr)
{
    me->state = START;
    me->fp = NULL;

    me->statenum = 0;
    me->newstate = 1;
    me->disable_cnstr = 1;
    me->depth = 1;
    me->offset = MATE_EXPLD_OFF;
    me->tableid.objid = NULL_OBJID;

    return( OM_S_SUCCESS );
}

method execute( int *response; char *response_data; int pos )
{
IGRint                  i,om_msg, sizbuf;
IGRlong			msg, locate_display;
IGRlong                 mask1,mask2;
struct GRevent          event, locev;
struct GRmd_env         mod_env;
OM_S_CLASSLIST          elig_classes;
OMuword                 classes[5];
IGRchar                 buffer[256];

struct GRlc_locate      lc_attribs;
struct GRlc_stack       lc_stack;

int			num_rows;
GRtable_row_info        row;

IGRlong  Expld_Assy_action_handler();

IGRboolean aflag = 0;

    if(aflag =  pwIsActivationOn() )
    {
     ex$message (in_buff="Deactivate the activated part",
                 field=ERROR_FIELD);
     *response = TERMINATE;
     return (OM_S_SUCCESS);
    }

    ex$message(msgnumb = EM_M_ExpldAssy);

    om_msg = OM_S_SUCCESS;
    msg = MSSUCC;

    /*
     * Get the current module environment.
     */	
    sizbuf = sizeof( struct GRmd_env );
    gr$get_module_env(msg = &msg,
                      sizbuf = &sizbuf,
                      buffer = &mod_env );
    /*
     * Settings for locate part ...
     */
    lc_attribs.properties = LC_LC_ONLY | LC_DP_ONLY | LC_PLANAR_NON_PLANAR;
    lc_attribs.owner_action = LC_RIGID_COMP    | LC_FLEX_COMP   |
                            LC_NO_REF_HEADER | LC_REF_OBJECTS |
                            LC_ASSOCIATIVE |
                            LC_EXTERN_CONSTRAINED ;

    locate_display  =  ALL_WINDOWS | NO_PROJ_ACCEPT_POINT | ELEM_HILIGHT |
                       ACC_REJ_CYCLE | RELOCATE |
                       LC_ERASE_ALL | LC_ACCEPT_CURSOR ;

    om$get_classid(classname = "EMinstance",
			p_classid = &classes[0]);

    elig_classes.w_count = 1;
    elig_classes.p_classes = classes;
    elig_classes.w_flags = OM_CLST_subclass;

    mask1 = mask2  = GRm_DATA | GRm_STRING |GRm_RESET | GRm_BACK_UP|
                   GRm_SPECIFIED_OBJ|GRm_FORM_FINISHED;

    switch (me->state)
    {
        /*
         * (Re)initialize the command.
         */
        case START:
            me->state = GET_PART;
	    *response = RESET;
            break;

        case GET_PART:

    	    lc_stack.number_located = 0;
            lc_stack.num_entries = 0;

            lc$locate(rc           = &msg,
                 event1            = &locev,
                 event2            = &event,
                 mask1             = mask1,
                 mask2             = mask2,
                 display_flag      = locate_display,
                 attributes        = &lc_attribs,
                 response          = response, 
                 response_data     = response_data,
                 locate_prompt     = "Select Part to Explode/Move On",
                 acc_prompt        = "Accept/Reject",
                 relocate_prompt   = "Part not found",
                 stack             = &lc_stack,
                 eligible_classes  = &elig_classes,
                 act_handler       = Expld_Assy_action_handler,
                 act_args = &mod_env.md_id.osnum);

            switch( *response )
            {
                case EX_DATA: /* Explode selected part */
    		    /* Erase highlight of located element */
		    dp$display(
        	        msg = &msg,
                	oids = &lc_stack.entry[0].located_obj ,
	                mode = GRhe
        	       );

                  /* commented to restrict the assemly explode to only first 
                   * level parts and sub_assemblies.
                    om_msg = EMget_part_with_env( &msg, 
                                            &lc_stack.entry[0].located_obj,
                                            &me->partid, &me->partenv);

                    if( !(om_msg & msg & 1 ))
                    {
#ifdef DEBUG
                        printf("EMget_part_with_env failed\n");
#endif
                        *response = TERMINATE;
                    }
		     *
                     * Check if the returned partid is same as located partid
                     * use the located part env
                     *
                    if((me->partid.objid == lc_stack.entry[0].located_obj.objid ) &&
                       (me->partid.osnum == lc_stack.entry[0].located_obj.osnum ))
                    {
                        me->partenv = lc_stack.entry[0].module_info;
                    }
                   */

                    me->partid = lc_stack.entry[0].located_obj;
                    me->partenv = lc_stack.entry[0].module_info;

                    break;

                case EX_RJT_MOVEON: /* Explode the whole Assy */

                    om_msg = asm$get_file_part (msg = &msg,
                                mod_env = &mod_env,
                                part_id = &me->partid);

                    if( !( om_msg & msg & 1 ))
                    {
			/*
			 * KLUDGE: create the filepart definition??
			 */
                        *response = TERMINATE;
                        ex$message( msgnumb = EMS_S_NoPrtDef ); /*"Assembly File is not defined as a Part" */
                    }
		    me->partenv = mod_env;
                    break;

                case EX_BACK_UP:
                    break;
            }

	    if( *response == EX_DATA || *response == EX_RJT_MOVEON )
            {
                om_msg = om$send( msg = message ECexpldassy.EMsetup_optform(
                                                                  &msg,
                                                                  &me->partid,
                                                                  &me->partenv),
                                        targetid = my_id );
                if( !( om_msg & msg & 1 ))
                    *response = TERMINATE;
                else
                {
                    me->state = EXPLD_ASSY;
                    *response = RESET;
                }
            }
            break;

        case EXPLD_ASSY:
            /* Display the options form and wait */
            if( me->fp )
                FIf_display( me->fp );

            strcpy( buffer, "Enter Form Data");
            om_msg = co$getevent( msg = &msg,
	                     event_mask = ( GRm_FORM_FINISHED | GRm_RJT_MOVEON |  GRm_STRING ),
	                     prompt = buffer,
               		     response = response,
                	     response_data = response_data,
        	             event = &event );

            if( event.response == EX_FORM_FINISHED )
            {
		/* if it is unexplode, send the filepart id */
		if( !me->newstate )	
		{
                    om_msg = asm$get_file_part (msg = &msg,
                                mod_env = &mod_env,
                                part_id = &me->partid);
		}
		
                /* If the form is accepted, Explode the Assembly */
	        om_msg = om$send( msg = message ECexpldassy.EMexpld_assy( &msg,
						&me->partid,
						&me->partenv,
						me->depth,
                                                me->offset,
						me->statenum),
				targetid = my_id );

                if( !( om_msg & msg & 1 ) || !me->newstate )
                    *response = TERMINATE;
                else
    	            me->state = SAVECONFIG;
            }
            else if( event.response == EX_RJT_MOVEON )
                *response = TERMINATE;

            break;

        case SAVECONFIG:
            /* Enquire the user if the configuration needs to be saved, if yes,
               get the new values for the values of expressions and add a row 
               to the table.
            */
            strcpy( buffer, "Store this Exploded State ? [y]");
            om_msg = co$getevent( msg = &msg,
	                     event_mask = GRm_STRING|GRm_RJT_MOVEON,
	                     prompt = buffer,
               		     response = response,
                	     response_data = response_data,
        	             event = &event );

            if( ( event.response != EX_STRING ) &&
                    ( event.response != EX_RJT_MOVEON ))
            {
                break;
            }
	    else if( event.response == EX_RJT_MOVEON )
                event.event.keyin[0] = 0;

            if( !strlen(event.event.keyin) || 
                    !strcmp( event.event.keyin, "y") ||
                    !strcmp( event.event.keyin, "Y") )
            {
                /* save configuration */
	        ex$message( msgnumb = EMS_S_SvExpldSt ); /*"Saving exploded state ...\n"*/

                /* Find the number of rows in the table */
                om_msg = om$send( msg = message GRtable.GRnum_rows( &msg,
                                                        &num_rows ),
                                targetid = me->tableid.objid,
                                targetos = me->tableid.osnum );

                if( !( om_msg & msg & 1 ))
                {
#ifdef DEBUG
                    printf("GRnum_rows failed\n");
#endif
                    *response = TERMINATE;
                    break;
                }

                sprintf( row.name,"state%d",num_rows);

                om_msg = EMadd_row_with_vals ( &msg, &me->tableid,
                                               &row, num_rows );

                if( !(om_msg & msg & 1 ))
                {
#ifdef DEBUG
                    printf("add row with values failed\n");
#endif
                }
            }
            else
                ex$message( msgnumb = EMS_S_ExpldStNotSv ); /*"Exploded state not saved"*/

            *response = TERMINATE;
            me->state = FINISHED;
            break;
    }

    return( OM_S_SUCCESS );
}    


method EMexpld_assy( IGRlong *rc; struct GRid *partid; struct GRmd_env *env; 
                   IGRint depth; IGRdouble offval; IGRint state )
{
IGRlong msg;
IGRdouble offset;
IGRchar off_exp[150], expname[DI_PATH_MAX];
int i, j, k, prt_count, om_msg, num_inc, type, alflg;
struct GRid *prt_list, table_id;
struct GRid inc_cnstr[MAX_INCIDENT_CONSTR], expid, ftids[2];
struct GRmd_env envs[2];
IGRuint basis;
int num_rows, num_columns, number, column_size = 0;
IGRdouble aloff[2], tempoff;
int  exploded = 0;

GRtable_column_info * columns = NULL;
GRtable_row_info      row;
GRtable_cell_info   * cells = NULL;


    *rc = MSSUCC;
    om_msg = OM_S_SUCCESS;

    /*
     * Check the type of the located part
     */
    om_msg = asm$get_part_type( msg = &msg,
                                part_id = partid,
                                type = &type );

    if (type == EM_FILE_PART)
    {
        om_msg = EMget_cpart_list( partid, 
                               env, 
                               &depth,
                               INQ_PRT_WITH_INC_CNSTR, /* only parts with incident constr */
                               &prt_list, 
                               &prt_count );

        if( prt_count == 0 )
        {
	    *rc = MSFAIL;
            ex$message( msgnumb = EMS_S_PrtNotSAssy); /*"Part is not a subassembly"*/
            return( OM_S_SUCCESS );
        }
    }
    else
    {
        prt_list = partid;
        prt_count = 1;
    }
    for( i = 0; i < prt_count; i++ )
    {
    IGRuint props;
    IGRshort action;
    IGRshort props1 = GRIS_ASSOCIATIVE | GRHAS_EXTERNAL_CONSTRAINT;
            
        props = 0;
    	/* Reset the property of the part */
        asm$set_application_props( msg = &msg,
                                   id = &prt_list[i],
                                   props = props );

        /* Disallow the part to be located for move/rotate */
        action = 1;
        om_msg = om$send (msg = message GRgraphics.GRchgprops (&msg,
                                                              &action,
                                                              &props1),
                                      targetid = prt_list[i].objid,
                                      targetos = prt_list[i].osnum );
        if( !( om_msg & msg & 1 ))
        {
            verbose(printf("GRchgprops failed\n"));
        }
    }

    /*
     * Set up the global flag to indicate for GRxform of ref file
     */

    if( !me->newstate )    /* Move to a saved state */
    {
        om_msg = om$send( msg = message GRtable.GRget_row( &msg,
                                                           &state,
                                                           NULL,
                                                           NULL ),
                                targetid = me->tableid.objid,
                                targetos = me->tableid.osnum );

        if( !( om_msg & msg & 1 ))
        {
            ex$message( msgnumb = EMS_S_NoSuchSt );/*"No such state exists"*/
            goto quit;
        }

        om_msg = om$send( msg = message GRtable.GRrun_row( &msg,
                                                           &state,
                                                            NULL ),
                                targetid = me->tableid.objid,
                                targetos = me->tableid.osnum );

        if( !( om_msg & msg & 1 ))
        {
#ifdef DEBUG
	    printf("run row failed\n");
#endif
            goto quit;
        }
        return( om_msg );
    }


    /*
     * Now, Inside the assembly file, look for a GRtable object. 
     * If it does not exist, create it and a row with default values for the
     * expressions participating in the explode.
     */

    if( me->tableid.objid == NULL_OBJID ) /* No table found */
    {
        om_msg = EMcreate_default_table( &msg, env, &table_id);


        if( !( om_msg & msg & 1 ))
        {
#ifdef DEBUG
            printf("creating default table failed\n");
#endif
            goto quit;
        }
    }
    else
        table_id = me->tableid;

    /* Find the number of rows in the table */
    om_msg = om$send( msg = message GRtable.GRnum_rows( &msg,
                                                        &num_rows ),
                                targetid = table_id.objid,
                                targetos = table_id.osnum );
    if( !( om_msg & msg & 1 ))
    {
#ifdef DEBUG
	printf("GRnum_rows failed\n");
#endif
        goto quit;
    }

    column_size = 20;
    columns = (GRtable_column_info *)malloc( column_size * 
                                            sizeof(GRtable_column_info));
    if( num_rows == 0 )
    {
        cells = (GRtable_cell_info *)malloc( column_size *
                                            sizeof(GRtable_cell_info));
        strcpy( row.name, "Initial");
    }

    num_columns = 0;

    for( i = 0; i < prt_count; i++ )
    {
        om_msg = om$send( msg = message EMinstance.EMgivebasis ( &msg,
                                                             &basis ),
                        targetid = prt_list[i].objid,
                        targetos = prt_list[i].osnum );

        if( !(om_msg & msg & 1 ))
        {
#ifdef DEBUG
	    printf("EMgivebasis failed\n");
#endif
            goto quit;
        }
        om_msg = om$send( msg = message EMinstance.EMget_incident_constr( &msg,
                                                            &num_inc,
                                                            inc_cnstr),
                        targetid = prt_list[i].objid,
                        targetos = prt_list[i].osnum );

        if( !(om_msg & msg & 1 ))
        {
#ifdef DEBUG
	    printf("EMget_incident_constr failed\n");
#endif
            goto quit;
        }

        switch( basis )
        {
        case GROUND_ONE_CONSTR:   /* Donot Move the Part */
	case ALIGN_ONE_CONSTR:
        case MATE_ALIGN_ANG:	
        case ALIGN_ALIGN_PERP:
        case ALIGN_ALIGN_ANG:	
                break;

        case MATE_ALIGN_PERP:
        case ALIGN_ALIGN_PAR:
            exploded = 1;
            for( j = 0; j < num_inc; j++ )
            {
                EMgetconstrtype( inc_cnstr[j], &type );
                if( type == MATE )
                    continue;

                /* Get the max length of the axes of the constraining parts */
                offval = 0.0;
                alflg = EMget_max_axis_len( &inc_cnstr[j], &tempoff );
                if( alflg & 1 )
                    offval = tempoff;

                om_msg = EMget_exp_info( &msg, &inc_cnstr[j], &offset, expname,
                                                                 &expid );
                if( !(om_msg & msg & 1))
		    continue;

                if( num_columns == column_size )
                {
                    columns = (GRtable_column_info *)realloc( columns,
                              (column_size+20)*sizeof(GRtable_column_info));

                    if( num_rows == 0 )
                    cells = (GRtable_cell_info *)realloc( cells,
                              (column_size+20)*sizeof(GRtable_cell_info));
                    column_size += 20;
                }
                columns[num_columns].expression_id = expid;
                sprintf( columns[num_columns].name,"%s_%d",expname,expid.osnum);

                if( num_rows == 0 ) /* Store the default configuration */
                    cells[num_columns].d = offset;          

                num_columns++;
                offset += offval;

	        sprintf( off_exp, "%lf", offset );            
                om_msg = exp$modify( exp_id = expid.objid,
                            osnum  = expid.osnum,
                            exp_syntax = off_exp );

                if( !(om_msg & 1))
		{
		    verbose(printf("exp$modify failed\n"));
                    goto quit;
		}
            }
            break;

        case MATE_ONE_CONSTR:    /* Change the offset on the Mate */
        case MATE_MATE_PERP: 
        case MATE_MATE_ANG:  
        case MATE_MATE_MATE_PERP_PERP_PERP:
        case MATE_MATE_MATE_PERP_PERP_ANG:
        case MATE_MATE_MATE_PERP_ANG_ANG:
        case MATE_MATE_MATE_ANG_ANG_ANG:
            exploded = 1;

            for( j = 0; j < num_inc; j++ )
            {
                om_msg = EMget_exp_info( &msg, &inc_cnstr[j], &offset, expname,
                                                                 &expid );
                if( !(om_msg & msg & 1))
		    continue;

                if( num_columns == column_size )
                {
                    columns = (GRtable_column_info *)realloc( columns,
                              (column_size+20)*sizeof(GRtable_column_info));

                    if( num_rows == 0 )
                    cells = (GRtable_cell_info *)realloc( cells,
                              (column_size+20)*sizeof(GRtable_cell_info));
                    column_size += 20;
                }
                columns[num_columns].expression_id = expid;
                sprintf( columns[num_columns].name,"%s_%d",expname,expid.osnum);

                if( num_rows == 0 ) /* Store the default configuration */
                    cells[num_columns].d = offset;          

                num_columns++;
                offset += offval;

	        sprintf( off_exp, "%lf", offset );            
                om_msg = exp$modify( exp_id = expid.objid,
                            osnum  = expid.osnum,
                            exp_syntax = off_exp );

                if( !(om_msg & 1))
		{
		    verbose(printf("exp$modify failed\n"));
                    goto quit;
		}
            }

            break;

        case MATE_ALIGN_PAR: 
        case MATE_ALIGN_ALIGN_PAR_PAR_PAR:
                        /* Get the Max. of align axes lengths and
                           explode by the max. */
            exploded = 1;
            aloff[0] = aloff[1] = 0.0;
            for( j = 0,k = 0; k < num_inc; k++ )
            {
                EMgetconstrtype( inc_cnstr[k], &type );
                if( type == MATE )
                {
                    om_msg = EMget_exp_info( &msg, &inc_cnstr[k], &offset, 
                                                        expname, &expid );
                    if( !(om_msg & msg & 1))
                        goto quit;
                }
                else
                {
    	            alflg = EMget_max_axis_len( &inc_cnstr[k], &tempoff );
                    if( alflg & 1 )
                        aloff[j++] = tempoff;
		}
            }
            if( num_inc == 2 ) 
            {
                if ( aloff[0] > offval )
                    offval = aloff[0];
            }
            else 
            {
                tempoff = 0.;
                if( j == 2 ) 
                    tempoff = ( aloff[0] > aloff[1] ) ? aloff[0] : aloff[1];
                else if( j == 1 )
                    tempoff = aloff[0];

		if( tempoff > offval )
		    offval = tempoff;
            }

            if( num_columns == column_size )
            {
                columns = (GRtable_column_info *)realloc( columns,
                          (column_size+20)*sizeof(GRtable_column_info));

                    if( num_rows == 0 )
                    cells = (GRtable_cell_info *)realloc( cells,
                              (column_size+20)*sizeof(GRtable_cell_info));
                    column_size += 20;
            }
            columns[num_columns].expression_id = expid;
            sprintf( columns[num_columns].name,"%s_%d",expname,expid.osnum);

            if( num_rows == 0 ) /* Store the default configuration */
                cells[num_columns].d = offset;          

            num_columns++;
            offset += offval;

	    sprintf( off_exp, "%lf", offset );            
            om_msg = exp$modify( exp_id = expid.objid,
                            osnum  = expid.osnum,
                            exp_syntax = off_exp );
            break;

        case MATE_MATE_ALIGN_PERP_PERP_PAR:
            /* KLUDGE:
             * Find the Mate that is parallel to the align and offset it
             */
	
	    break;
        }
    }

    if( me->disable_cnstr )
    {
        nd$exec_batch(); /* Let the exp$modify() take effect */

        for( i = 0; i < prt_count; i++ )
        {
        IGRuint props;
        IGRshort action;
        IGRshort props1 = GRIS_ASSOCIATIVE | GRHAS_EXTERNAL_CONSTRAINT;

            props = EM_EXPLODED;
    	    /* Set the property of the part to EM_EXPLODED */
            asm$set_application_props( msg = &msg,
                                        id = &prt_list[i],
                                     props = props );

            /* Allow the part to be located for move/rotate */
            action = 0;
            om_msg = om$send (msg = message GRgraphics.GRchgprops (&msg,
                                                              &action,
                                                              &props1),
                                      targetid = prt_list[i].objid,
                                      targetos = prt_list[i].osnum );

            if( !( om_msg & msg & 1 ))
            {
               verbose(printf("GRchgprops failed\n"));
            }
        }
    }

    if( num_rows == 0 )
        EMadd_def_row( &msg, &table_id, columns, &row, cells, num_columns );
    else
    {
        /* If a column does not exist, add it to the table */
        for( i = 0; i < num_columns; i++ )
        { 
            om_msg = om$send( msg = message GRtable.GRadd_column ( &msg,
                                                          &columns[i],
                                                          &number),
                                targetid = table_id.objid,
                                targetos = table_id.osnum );
        }
    }    

    /*
     * Do a fit on all/last window ??
     */

    if( exploded )
    {
        ex$message(msgnumb = EMS_S_AssyExplded); /*("Assembly Exploded" */
    }
    else
    {
        ex$message(msgnumb = EMS_S_InsuffCnstr);
        om_msg = OM_E_ABORT;
    }

    /* Store the tableid in the command object instance */
    me->tableid = table_id;

quit:
    if( columns )
        free( columns );
    if( cells )
        free( cells );

    return( om_msg );

}

IGRint EMget_max_axis_len( inc_cnstr, length )
struct GRid *inc_cnstr;
IGRdouble *length;
{
int om_msg = OM_S_SUCCESS, i;
IGRlong msg = MSSUCC;
struct GRid ft_ids[2];
struct GRmd_env ft_envs[2];
OMuword classid;
IGRdouble len[2];

    /* Now check if the aligning features are either EMSrevol/EMSparamvc
           and then get the length of the longest axes.
     */
    om_msg = om$send( msg = message EMconstr.EMget_ftrs_with_env( &msg,
                                                                  ft_ids,    
                                                                  ft_envs ),
                                targetid = inc_cnstr->objid,
                                targetos = inc_cnstr->osnum,
                                senderid = NULL_OBJID );
    if( !(om_msg & msg & 1 ))
    {
#ifdef DEBUG
        printf("getftrswithenv failed\n");
#endif
	goto quit;
    }

    for( i = 0; i < 2; i ++ )
    {
        len[i] = 0.0;
        om$get_classid( objid = ft_ids[i].objid,
                        osnum = ft_ids[i].osnum,
                        p_classid = &classid );
 
        if (om$is_ancestry_valid (subclassid = classid,
                superclassid = OPP_EMSrevol_class_id) == OM_S_SUCCESS)
        {
            /* Find the length of the axis */
        IGRushort typ;
        struct EMsurface_params params;
        IGRpoint axis[2];

    	    om_msg = om$send( msg = message EMSsurface.EMget_params( &msg,
								NULL,
								&ft_envs[i],
								&typ,
								&params),
			 senderid = NULL_OBJID,
			 targetid = ft_ids[i].objid,
			 targetos = ft_ids[i].osnum );

            if( !(om_msg & msg & 1) )
            {
#ifdef DEBUG
                printf("EMget_params failed\n");
#endif
                goto quit;
            }
	    if( !EMgetcenterline( &params, typ, axis ))
            {
                verbose(printf("EMgetcenterline failed\n"));
                goto quit;
            }
            len[i] = BSdistptpt( &msg, axis[0], axis[1] );
        }
        else if (om$is_ancestry_valid (subclassid = classid,
                superclassid = OPP_EMSparamvc_class_id) == OM_S_SUCCESS)
        {
            /* Find the length of the axis */
        struct EMSgeomdata geomdata;

            om_msg = om$send (msg = message EMSparameter.EMgetdimgeom (&msg,
                                                NULL,
             					&ft_envs[i].md_env.matrix_type,
						ft_envs[i].md_env.matrix,
						NULL, NULL, 
						&geomdata, NULL),
			 senderid = NULL_OBJID,
			 targetid = ft_ids[i].objid,
			 targetos = ft_ids[i].osnum );

            if( !(om_msg & msg & 1) )
            {
                verbose(printf("getdimgeom failed\n"));
                goto quit;
            }
            /*
             * The geometry returned must be a line-segment.
             */
            if( geomdata.geomtype != GEOMDATA_LINE )
            {
                verbose(printf("Illegal align Axis vector\n"));
                goto quit;
            }
            len[i] = BSdistptpt( &msg, geomdata.line.line_pt1,
                                       geomdata.line.line_pt2 );
        }
    }
    *length = ( len[0] > len[1] ) ? len[0] : len[1];    

quit:
    return ( om_msg );

}



IGRint EMexpldoptsnotify( f_label, g_label, value, fp )
IGRint f_label, g_label;
IGRdouble value;
Form  fp;
{
IGRint 		status;
IGRlong 	msg_loc;
GRobjid 	cmdobj;
GRspacenum 	cmdos;

 	status = FIf_get_cmd_oid_os (fp, &cmdobj, &cmdos);
 	if(status)
  		return (OM_E_ABORT);

 	status = om$send (msg = message ECexpldassy.do_form(&msg_loc,
                                                            f_label,
				                            g_label,
                                                            value),
		            senderid = NULL_OBJID, 
		            targetid = cmdobj,
		            targetos = cmdos);

	if(! (status & 1))
		 return (OM_E_ABORT);

 	return(OM_S_SUCCESS);

}


method status_disp( )
{
    return( OM_S_SUCCESS );
}

/* This method would display the Explode options form, wherein you have
   the explode offset, explode depth and the state num to move to, and an
   option to Disable constraints after exploding to a new state.
*/

method EMsetup_optform(IGRlong *msg; struct GRid *partid; struct GRmd_env *env )
{
int om_msg = OM_S_SUCCESS, maxdepth, i;
int num_rows, type, num_cols, num_deleted;
GRtable_row_info row;
struct GRid expid;

    *msg = MSSUCC;
    if(me->fp == NULL)
    {
        FIf_new( 101, "EMExpldPrts", EMexpldoptsnotify, &me->fp );
        if(me->fp == NULL)
        {
            verbose(printf("Failed to find form -> EMExpldPrts\n"));
            om_msg = OM_E_ABORT;
            goto quit;
        }

        FIf_set_cmd_oid_os(me->fp,my_id,OM_Gw_current_OS);

        FIg_set_value( me->fp, EXPLD_OFFSET, me->offset );
    }

    /*
     * Check the type of the located part
     */
    om_msg = asm$get_part_type( msg = msg,
                                part_id = partid,
                                type = &type );
    if( type == EM_FILE_PART )
    {
        /* Get the Max Depth of the identified file_part */
        om_msg = EMget_cpart_list( partid, 
                               env, 
                               &maxdepth,
                               INQ_MAX_DEPTH,
                               NULL, 
                               NULL );

        if( !( om_msg & 1 ) )
        {
            verbose(printf("getting maxdepth failed\n"));
            goto quit;
        }

        /* Get the number of saved states for the file_part */
        om_msg = EMget_table ( msg, partid, &me->tableid);
    }
    else if( type == EM_REFERENCE_PART )
    {
    struct GRid locpart;

        maxdepth = 1;
        FIg_disable( me->fp, EXPLD_DEPTH );

        om_msg = asm$get_file_part( msg = msg,
                                    mod_env = &me->partenv,
                                    part_id = &locpart );
        if(!( om_msg & *msg & 1 ))
        {
            verbose(printf("getfilepart failed\n"));
            goto quit;
        }
        /* Get the table in the corresponding file_part where the reference
         * part is present 
         */
        om_msg = EMget_table( msg, &locpart, &me->tableid );
    }

    /* Set the max value of depth slider */
    FIg_set_high_value( me->fp, EXPLD_DEPTH, (double)maxdepth );
    FIg_set_low_value( me->fp, EXPLD_DEPTH, 1.0 );
    FIg_set_value( me->fp, EXPLD_DEPTH, (double)maxdepth );

    if( !(om_msg & *msg & 1) ) /* No table found */
    {
         /* Freeze the State toggle to NEW */
        FIg_disable( me->fp, EXPLD_STATE );
        me->tableid.objid = NULL_OBJID;
        om_msg = OM_S_SUCCESS;
        *msg = MSSUCC;
    }
    else
    {
        FIg_set_value( me->fp, ST_NUMBER, me->statenum );

	/* Check if there are valid columns */
        om_msg = om$send( msg = message GRtable.GRnum_columns( msg,
                                                        &num_cols ),
                                   targetid = me->tableid.objid,
                                   targetos = me->tableid.osnum );

        if( !( om_msg & *msg & 1 ) || num_cols == 0 )
        {
            /* Freeze the State toggle to NEW */
            FIg_disable( me->fp, EXPLD_STATE );
            om_msg = OM_S_SUCCESS;
            *msg = MSSUCC;
	    goto quit;
	}

	for( i = 0, num_deleted = 0; i < num_cols; i++ )
	{
            om_msg = om$send( msg = message GRtable.GRget_expression( msg, i,
                                                                  &expid ),
                                   targetid = me->tableid.objid,
                                   targetos = me->tableid.osnum );
	    
            if( !( om_msg & *msg & 1 ) )
                num_deleted++;

            om_msg = OM_S_SUCCESS;
            *msg = MSSUCC;
	}

        if( num_deleted == num_cols )
        {
            /* Freeze the State toggle to NEW */
            FIg_disable( me->fp, EXPLD_STATE );
            om_msg = OM_S_SUCCESS;
            *msg = MSSUCC;
	    goto quit;
	}

        /* Set the Associated list with the row names */
        om_msg = om$send( msg = message GRtable.GRnum_rows( msg,
                                                        &num_rows ),
                                   targetid = me->tableid.objid,
                                   targetos = me->tableid.osnum );

        if( !( om_msg & *msg & 1 ) || num_rows == 0 )
        {
            /* Freeze the State toggle to NEW */
            FIg_disable( me->fp, EXPLD_STATE );
            om_msg = OM_S_SUCCESS;
            *msg = MSSUCC;
        }
        else
        {
             for( i = 0; i < num_rows; i++ )
             {
                  om_msg = om$send( msg = message GRtable.GRget_row( 
                                                                msg,
                                                                &i,
                                                                NULL,
                                                                &row ),
                                        targetid = me->tableid.objid,
                                        targetos = me->tableid.osnum );

                  FIfld_set_list_text(me->fp,ST_NUMBER,i,0,row.name,FALSE);
             }
        }
    }

quit:
    return( om_msg );
}

method do_form( IGRlong *rc; IGRint f_label,g_label; IGRdouble value )
{
IGRint sts;
IGRdouble val;
int i, num_rows, sf;

    sts = OM_S_SUCCESS;
    *rc = MSSUCC;

    switch(g_label)
    {
        case EXPLD_STATE:
            if( me->newstate )
            {
                 me->newstate = 0;
                 FIg_set_state_on( me->fp, EXPLD_STATE );
                 FIg_erase( me->fp, TOGL_CNSTR_TXT );
                 FIg_erase( me->fp, TOGL_CNSTR );
                 FIg_display( me->fp, ST_NUM_TXT );
                 FIg_display( me->fp, ST_NUMBER );
                 FIg_set_value( me->fp, ST_NUMBER, (double)me->statenum );
                 me->disable_cnstr = 0;
		 FIg_disable( me->fp, EXPLD_OFFSET);
		 FIg_disable( me->fp, EXPLD_DEPTH);
            }
            else
            {
                 me->newstate = 1;
                 FIg_set_state_off( me->fp, EXPLD_STATE );
                 FIg_erase( me->fp, ST_NUM_TXT );
                 FIg_erase( me->fp, ST_NUMBER );
                 FIg_display( me->fp, TOGL_CNSTR_TXT );
                 FIg_display( me->fp, TOGL_CNSTR );
		 FIg_enable( me->fp, EXPLD_OFFSET);
		 FIg_enable( me->fp, EXPLD_DEPTH);
            }
            break;

	case ST_NUMBER:
            
            FIfld_get_list_num_rows(me->fp,ST_NUMBER,0,&num_rows);
            for( i = 0; i < num_rows; i++ )
            {
                FIfld_get_list_select(me->fp,ST_NUMBER,i,0,&sf);
                if ( sf )
		{
		    FIg_set_value( me->fp, ST_NUMBER, (double)i );
		    break;
                }
            }
	    break;

	case TOGL_CNSTR:
            if( me->disable_cnstr )
                 me->disable_cnstr = 0;
            else
                 me->disable_cnstr = 1;
            break;
    
        case FI_ACCEPT :
            /* Read the values into the command object instance data */
           /* Removed depth Btn for restricting explode to first level
            * parts and sub_assemblies  
            FIg_get_value( me->fp, EXPLD_DEPTH, &val );
	    me->depth = (int) val;
            */
            FIg_get_value( me->fp, EXPLD_OFFSET, &me->offset );
            if( !me->newstate )
	    {
                FIg_get_value( me->fp, ST_NUMBER, &val );
	        me->statenum = (int) val;
            }

            FIf_erase(me->fp);
	    FIf_delete(me->fp);
            me->fp = NULL;
            {
    	        int	 rsp = EX_FORM_FINISHED;
    	        long stat;
	
	        ex$putque(msg = &stat, response = &rsp);
	    }

            break;

        case FI_CANCEL:
            FIf_erase(me->fp);
            {
    	        int	 rsp = EX_RJT_MOVEON;
    	        long stat;
	
	        ex$putque(msg = &stat, response = &rsp);
	    }

            break;
    }

    return(sts);
}

method wakeup( int pos )
{
    if( me->fp )
        FIf_display( me->fp );

    ex$message( msgnumb = EM_M_ExpldAssy );
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

    me->fp = NULL;
    ex$message( msgnumb = EMS_S_ClearStatusField );

    sts = om$send( mode      = OM_e_wrt_message,    
                   msg       = message COpara.delete(1),   
                   targetid  = my_id);
    return( OM_S_SUCCESS );
}

IGRint EMget_part_with_env( msg, inst_id, part_id, part_env )
struct GRid *inst_id, *part_id;
struct GRmd_env *part_env;
IGRlong *msg;
{
int om_msg = OM_S_SUCCESS, count;
EMmemb memb;
struct GRmd_env env_path;

    *msg = MSSUCC;

    /*
     * Get the reference file id of the instance.
     */
    om_msg = om$send (msg = message EMdescribe.EMget_memb 
                                                 (msg,
                                                  "reffile",
                                                  EM_GRAPHIC,
                                                  0,
                                                  &memb),
                      senderid = NULL_OBJID,
                      targetid = inst_id->objid,
                      targetos = inst_id->osnum);

    if( !(om_msg & *msg & 1 ))
        goto quit;

    /*
     * Get the ref. file environment ( part's env ) 
     */

    om_msg = om$send( msg = message GRreffile.GRgetenvironment( msg,
                                                                &env_path,
                                                                part_env ),
                                senderid = NULL_OBJID,
                                targetid = memb.id.objid,
                                targetos = memb.id.osnum);

    if( !(om_msg & *msg & 1 ))
        goto quit;

    /*
     * Check if there are parts in this environment (check if this is a
     * subassembly), if not return the input partid itself, otherwise return
     * the filepart id of the subassembly -      change done on 05/16/94
     */
    count = 0;
    om_msg = asm$part_count( msg = msg,
                             mod_env = part_env,
                             type = EM_LOCAL_PART | EM_REFERENCE_PART,
                             count = &count );

    if((om_msg & *msg & 1) && count > 0)
    {
        om_msg = asm$get_file_part( msg = msg,
                                    mod_env = part_env,
                                    part_id = part_id );

        if( !(om_msg & *msg & 1 ))
            goto quit;
    }
    else
    {
	part_id->objid = inst_id->objid;
	part_id->osnum = inst_id->osnum;
    }
#ifdef DEBUG
    printf("partid = %d (os=%d)\n", part_id->objid, part_id->osnum );
#endif

quit:

    return( om_msg );

}

/*
 * This function checks if the given reference file is owned by a part and
 * if so, returns the superid within the file part in which this part is 
 * instanced. If not a part, returns the superid of the active OS.
 */
IGRlong EMgetctxsuper( msg, refid, superid )
IGRlong *msg;
struct  GRid *refid, *superid;
{
IGRlong OMmsg;
OM_S_CHANSELECT chan;
int     count, i;
struct  GRid part, modid;
OMuword classid;
ASM_tree *node;
struct  GRmd_env mod_env;

    OMmsg = OM_S_SUCCESS;	/* initialize return values	*/
    *msg = MSSUCC;

    modid.osnum = refid->osnum;
    ex$get_modid( mod_osnum = modid.osnum, mod_id = &modid.objid );
				/* Get Super from Named Object
				   directory			*/
    OMmsg = ex$get_objid_from_NOD(NODname = "IGENOD",
		objname = "Ref Mgr",
		pobjid = &superid->objid,
		modid = modid.objid,
		mod_osnum = modid.osnum);

    if (1 & OMmsg)
    {				/* space number same as module	*/
        superid->osnum = modid.osnum;
    }
    else
    {
	*msg = MSFAIL;
    }
    goto wrapup;

    /*
     * Check for an EMinstance on the owner's side of the ref file 
     */
    OMmsg = om$make_chanselect(channame = "GRconnector.to_owners",
				p_chanselect = &chan);

    OMmsg = om$get_channel_count(osnum = refid->osnum,
		                 objid = refid->objid,
		                 p_chanselect = &chan,
		                 count = (OMuint *)&count);

    for( i = 0; i < count; i++ )
    {
        OMmsg = om$get_objid_at_index(osnum = refid->osnum,
			          objid = refid->objid,
			          p_chanselect = &chan,
			          index = i,
			          objidaddr = &part.objid,
			          osnumaddr = &part.osnum);
        if ( 1 & OMmsg)
	{	
            om$get_classid( objid = part.objid,
                            osnum = part.osnum,
                            p_classid = &classid );

            if (om$is_ancestry_valid (subclassid = classid,
                superclassid = OPP_EMinstance_class_id) == OM_S_SUCCESS)
            {
                break;
            }
        }
    }
    if( i == count ) /* No part found */
    {
        modid.objid = EX_active_module;
        modid.osnum = EX_active_OS_num;
    }
    else
    {
        /*
         * From the partid and using the assembly_tree, 
         * get the parent file partid.
         */
        EMbom_find_node_by_id( &part, &node );

        /* Check if it is a first level part */
        if (node->parent->props & EM_FILE_PART) 
        {
            /* first level part */
            modid.objid = EX_active_module;
            modid.osnum = EX_active_OS_num;
        }
        else if (node->parent->props & EM_REFERENCE_PART) 
        {
            /* Nested part, get the parent's file_part id */
            EMget_part_mdenv( msg, &node->parent->part_id, &mod_env );

            if( *msg & 1 )
                modid = mod_env.md_id;
            else
                goto wrapup;
        }
    }

wrapup:
    return( OMmsg );
}
  
 /*
  * Action Handler to allow only first level part or sub_assembly
  * location for exploding 
  */ 

IGRlong Expld_Assy_action_handler(osn, new_entry, locate_args, action)
GRspacenum *osn;
struct  GRlc_info *new_entry;
struct  LC_action_args *locate_args;
enum    GRlocate_action *action;
{
  IGRboolean  call_action_handler = FALSE;
  IGRlong sts = OM_S_SUCCESS;

  switch(*action)
  {
      case add_all:
      case add_inside:
      case add_outside:
      case add_overlap:
      case add_nopost:
      {
         if (new_entry->located_obj.osnum != *osn)
         {
            call_action_handler = FALSE;
         }
        else
         {
            call_action_handler = TRUE;
         }
      }
      break;

      default:

      break;
  }

  /* Call the default action handler */

  if(call_action_handler)
      sts = LCptlocact(NULL, new_entry, locate_args, action);
  else
      sts = OM_S_SUCCESS;

  return(sts);
}

end implementation ECexpldassy;
