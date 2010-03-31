class implementation ECPlAlign;
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
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

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
#define GET_INST1        1
#define GET_INST2        2
#define SHOW_DIR  	 3
#define GET_OFFSET	 4
#define PLACE_ALIGN      5
#define OVER_CONSTRAINED 6
#define COMPUTE_CONSTR   7

/* Gadgets for conflicting constraints form */
#define CNSTR_MCF	11
#define DEL_BUTTON	16

#define CONSTR	0
#define PART1	1
#define PART2	2

from EMconstr   import EMgetpart, EMget_ftrs_with_env, EMprocess_constr_addition;
from GRgraphics import GRdisplay;
from EMinstance import EMupdatebasis, EMcompute_xform_matrix;
from EMdescribe import EMget_memb;

extern OMuword  OPP_EMSparamvc_class_id;
extern OMuword  OPP_EMSplane_class_id;
extern OMuword  OPP_EMSdatpln_class_id;
extern OMuword  OPP_EMSrevol_class_id;
extern OMuword  OPP_GR3dlineseg_class_id;

method init(int type; char *str_ptr)
{

    me->state = START;
    me->fp = NULL;

    me->currow = me->curcol = -1;
    me->ids = NULL;

    me->cnstr_deleted = 0;

    return( OM_S_SUCCESS );
}

method execute( int *response; char *response_data; int pos )
{
IGRint                  i, om_msg, sizbuf, inc, type, type1;
IGRlong			msg, locate_display, num_bytes;
struct GRevent          event, locev;
struct GRmd_env         mod_env, lc_mod_env_1, lc_mod_env_2;
struct GRid             geom1_id, geom2_id, cnstrid, tmpid, tmp1id;
IGRchar                 buffer[256];
IGRint                  batch_mode;
OM_S_CLASSLIST          elig_classes;
OMuword                 classes[5], classid;

struct GRlc_locate      lc_attribs;
struct GRlc_stack       lc_stack;

extern IGRint 		EMspl_highlight();

IGRmatrix		matrix;

IGRchar                 lprtname[DI_PATH_MAX];
EMmemb                  memb;

struct  GRid            cntxt_id;

   IGRboolean aflag;
   if(aflag =  pwIsActivationOn() )
    {
     ex$message (in_buff="Deactivate the activated part",
                 field=ERROR_FIELD);

     *response = TERMINATE;
     return (OM_S_SUCCESS);
    }

    ex$message(msgnumb = EM_M_PlAlign);/*"Place Part ALIGN Constraint"*/

    /*
     * Get the current module environment.
     */	
    sizbuf = sizeof( struct GRmd_env );
    gr$get_module_env(msg = &msg,
                      sizbuf = &sizbuf,
                      buffer = &mod_env );
    /*
     * Settings for locate graphics ...
     */
    lc_attribs.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW | LC_PLANAR_NON_PLANAR;
    lc_attribs.owner_action = LC_RIGID_COMP    | LC_FLEX_COMP   |
                            LC_NO_REF_HEADER | LC_REF_OBJECTS |
                            LC_ASSOCIATIVE |
                            LC_EXTERN_CONSTRAINED | LC_HANDLES;

    locate_display  =  ALL_WINDOWS | NO_PROJ_ACCEPT_POINT | ELEM_HILIGHT |
                       ACC_REJ_CYCLE | RELOCATE |
                       LC_ERASE_ALL | LC_ACCEPT_CURSOR ;

    switch (me->state)
    {
        /*
         * (Re)initialize the command.
         */
        case START:
            me->currow = me->curcol = -1;
            me->cnstr_deleted = 0;

            me->inst1_id.objid = NULL_OBJID;

            geom1_id.objid = NULL_OBJID;
            geom2_id.objid = NULL_OBJID;

            me->spcl_flag = 0;
            me->feature_1.grid.objid = NULL_OBJID;
            me->feature_2.grid.objid = NULL_OBJID;
            me->constraint_id.objid = NULL_OBJID;

            if( me->ids )
                free( me->ids );
            me->ids = NULL;
            me->num_ids = 0;
            
            me->state = GET_INST1;
            *response = RESET;

            break;

        case GET_INST1:

    	    lc_stack.number_located = 0;
            lc_stack.num_entries = 0;

            om$get_classid(classname = "EMSparamvc",
			p_classid = &classes[0]);
            om$get_classid(classname = "EMSplane",
			p_classid = &classes[1]);
            om$get_classid(classname = "EMAdatpln",
			p_classid = &classes[2]);
            om$get_classid(classname = "GR3dlineseg",
			p_classid = &classes[3]);
            om$get_classid(classname = "EMSrevol",
			p_classid = &classes[4]);

            elig_classes.w_count = 5;
            elig_classes.p_classes = classes;
            elig_classes.w_flags = OM_CLST_subclass;

            lc$locate(rc           = &msg,
                 event1            = &locev,
                 event2            = &event,
                 display_flag      = locate_display,
		 select            = EMspl_highlight,
                 attributes        = &lc_attribs,
                 response          = response, 
                 response_data     = response_data,
                 locate_prompt     = "Select 1st Part with element to Align",
                 acc_prompt        = "Accept w/element to Align to/Reject",
                 relocate_prompt   = "Element not found",
                 stack             = &lc_stack,
                 eligible_classes  = &elig_classes);

            switch (*response)
            {
            case EX_DATA:
                /*
                 * Get the geom id from the stack
                 */
                geom1_id  = lc_stack.entry[0].located_obj;
                lc_mod_env_1 = lc_stack.entry[0].module_info;

		/* Erase highlight of located element */
		dp$display(
        	        msg = &msg,
                	oids = &lc_stack.entry[0].located_obj ,
	                mode = GRhe
        	       );

		/*
		 * Put the second datapoint on the queue 
		 */
		num_bytes = sizeof( event.event ) + sizeof(IGRint);
		ex$putque (msg=&msg, response=response, byte=&num_bytes,
					buffer= (char *)&event.event );

                om_msg = asm$get_feature_instance (msg = &msg,
                                                   feature_loc_env = &lc_mod_env_1,
                                                   feature_id = &geom1_id,
                                                   instance_id = &tmpid);
                if (om_msg & msg & 1)
                {
                    cntxt_id.objid = NULL_OBJID;
                    om_msg = GRfindcontext(&msg,
                               &lc_mod_env_1.md_env.matrix_type,
                               lc_mod_env_1.md_env.matrix,
                               &geom1_id.osnum,
                               &cntxt_id);

		    om_msg = EMget_first_level_part( &msg,
                                                     &tmpid,
						     &cntxt_id,
                                                     &me->inst1_id );
                    if( !(om_msg & msg & 1) )
                    {
                        UI_status("Failed to get first level part");
                        *response = RESET;
                        break;
                    }
                    me->feature_1.grid = geom1_id;  
                    me->feature_1.lc_env = lc_mod_env_1;
                    me->state = GET_INST2;
                }
                else
                {
                    *response = RESET;
                    ex$message ( msgnumb = EMS_S_PrtNotDef );
                }
                break;
                
            case EX_RJT_MOVEON:
                *response = RESET;
                break;

            case EX_BACK_UP:
                *response = RESET;
                break;
            }
            break;

        case GET_INST2:

    	    lc_stack.number_located = 0;
            lc_stack.num_entries = 0;
            me->state = SHOW_DIR;
	    /*
             *  check the superclass of INST1 and allow locate of
             *  its subclasses alone ( elig_classes ) - 22/12/93
             */
            om$get_classid( objid = me->feature_1.grid.objid,
                            osnum = me->feature_1.grid.osnum,
                            p_classid = &classid );

            if(om$is_ancestry_valid(superclassid = OPP_EMSparamvc_class_id,
			      subclassid = classid) == OM_S_SUCCESS)
                classes[0] = OPP_EMSparamvc_class_id;
            else if(om$is_ancestry_valid(superclassid = OPP_EMSplane_class_id,
			      subclassid = classid) == OM_S_SUCCESS)
            {
                classes[0] = OPP_EMSplane_class_id;
                me->state = GET_OFFSET;
            }
            else if(om$is_ancestry_valid(superclassid = OPP_EMSdatpln_class_id,
			      subclassid = classid) == OM_S_SUCCESS)
            {
                classes[0] = OPP_EMSdatpln_class_id;
                me->state = GET_OFFSET;
            }
            else if(om$is_ancestry_valid(superclassid = OPP_GR3dlineseg_class_id,
			      subclassid = classid) == OM_S_SUCCESS)
                classes[0] = OPP_GR3dlineseg_class_id;
            else if(om$is_ancestry_valid(superclassid = OPP_EMSrevol_class_id,
			      subclassid = classid) == OM_S_SUCCESS)
                classes[0] = OPP_EMSrevol_class_id;

            elig_classes.w_count = 1;
            elig_classes.p_classes = classes;
            elig_classes.w_flags = OM_CLST_subclass;

            strcpy( buffer,"Select 2nd Part with Element to Align");

            lc$locate(rc           = &msg,
                 event1            = &locev,
                 event2            = &event,
                 display_flag      = locate_display,
		 select            = EMspl_highlight,
                 attributes        = &lc_attribs,
                 response          = response, 
                 response_data     = response_data,
                 locate_prompt     = buffer,
                 acc_prompt        = "Accept/Reject",
                 relocate_prompt   = "Element not found",
                 stack             = &lc_stack,
                 eligible_classes  = &elig_classes);

            switch (*response)
            {
            case EX_DATA:
                /*
                 * Get the geom id from the stack
                 */
                geom2_id  = lc_stack.entry[0].located_obj;
                lc_mod_env_2 = lc_stack.entry[0].module_info;

		/* Erase highlight of located element */
		dp$display(
        	        msg = &msg,
                	oids = &lc_stack.entry[0].located_obj ,
	                mode = GRhe
        	       );

                om_msg = asm$get_feature_instance(msg = &msg,
                                                  feature_loc_env = &lc_mod_env_2,
                                                  feature_id = &geom2_id,
                                                  instance_id = &tmp1id);
                if (!(om_msg & msg & 1))
                {
                    *response = RESET;
                    me->state = GET_INST2;
                    ex$message ( msgnumb = EMS_S_PrtNotDef );
                    break;
                }
                cntxt_id.objid = NULL_OBJID;
                om_msg = GRfindcontext(&msg,
                               &lc_mod_env_2.md_env.matrix_type,
                               lc_mod_env_2.md_env.matrix,
                               &geom2_id.osnum,
                               &cntxt_id);

	        om_msg = EMget_first_level_part( &msg,
                                                 &tmp1id,
                                                 &cntxt_id,
                                                 &tmpid );
                if( !(om_msg & msg & 1) )
                {
                    UI_status("Failed to get first level part");
                    *response = RESET;
                    me->state = GET_INST2;
                    break;
                }
                me->feature_2.grid = geom2_id;  
                me->feature_2.lc_env = lc_mod_env_2;
    	        /*
                 * check the parttypes
                 */
                om_msg = asm$get_part_type( msg = &msg,
                                       part_id = &me->inst1_id,
                                       type = &type );
                if( om_msg & msg & 1 )
                {
                    om_msg = asm$get_part_type( msg = &msg,
                                               part_id = &tmpid,
                                               type = &type1 );
                    if( om_msg & msg & 1 )
                    {
                        if((type == EM_LOCAL_PART) && (type1 == EM_LOCAL_PART))
                        {
                            UI_status("Cannot place constraint between two local parts");
                            *response = RESET;
                            me->state = GET_INST2;
                            break;
                        }
                        if((type != EM_LOCAL_PART) && (type1 != EM_LOCAL_PART))
                        {
                            if ((me->inst1_id.objid == tmpid.objid) &&
                                (me->inst1_id.osnum == tmpid.osnum))
                            {
                                ex$message ( msgnumb = EMS_S_SamePrt ); 
                                *response = RESET;
	                        me->state = GET_INST2;
                                break;
                            }
                            me->inst2_id = tmpid;
                            *response = RESET;
                            break;
                        }
                        if( type == EM_LOCAL_PART )
                        {
                            me->inst2_id = tmpid;
                            tmpid = me->inst1_id;   
                        }
                        strcpy(lprtname,"DmyInst");
                        om_msg = om$send( msg = message EMdescribe.EMget_memb( 
                                                                    &msg,
                                                                    lprtname,
                                                                    -1,
                                                                    -1,
                                                                    &memb),
                                            targetid = tmpid.objid,
                                            targetos = tmpid.osnum);
                        if( om_msg & msg & 1 )
                        {
                            if( type == EM_LOCAL_PART )
                                me->inst1_id = memb.id;
                            else
                                me->inst2_id = memb.id;
                            *response = RESET;
                            break;
                        }
                    }
                }
                if( !(om_msg & msg & 1))
                    *response = TERMINATE;
                break;
                
            case EX_RJT_MOVEON:
	        me->state = GET_INST2;
                *response = RESET;
                break;

            case EX_BACK_UP:
                *response = RESET;
                me->state = GET_INST1;                
                break;

	    default:
                me->state = GET_INST2;
                break;
            }
            break;

	case SHOW_DIR:

	    /* Check the incident constraints on inst2 and if a mate is acting
               donot show axes directions
            */
            sizbuf = 0;
            om_msg = asm$get_constraints_count( msg = &msg,
                                        part_id = &me->inst2_id,
                                        in_out = 0,
                                        count = &sizbuf );

            if( (om_msg & msg & 1) && sizbuf )
            {
                for( i = 0; i < sizbuf; i++ )
                {
                    om_msg = asm$get_constraint( msg = &msg,
                                         part_id = &me->inst2_id,
                                         index = i,
                                         in_out = &inc,
                                         type = &type,
                                         cnstrid = &cnstrid );

                    if( om_msg & msg & 1 )
                        if( type == MATE )
                        {
                            me->state = PLACE_ALIGN;
                            break;
                        }
                }
            }
	    if ( me->state == PLACE_ALIGN )
	    {
                break;
            }

            init_dof_display();
            display_trans_vec( &me->feature_1.grid, &me->feature_1.lc_env, GRhd );
            display_trans_vec( &me->feature_2.grid,
                                 &me->feature_2.lc_env, GRhd );

/*            ex$message( msgnumb = EMS_P_RvrsDir, buff =  buffer );*/
            strcpy( buffer, "Accept/Moveon to reverse align");
            om_msg = co$getevent( msg = &msg,
                                  event_mask = GRm_STRING,
                                  prompt = buffer,
                                  response = response,
                       	          response_data = response_data,
       	                          event = &event );

            display_trans_vec( &me->feature_1.grid, &me->feature_1.lc_env, GRhe );
            display_trans_vec( &me->feature_2.grid, 
                                &me->feature_2.lc_env, GRhe );

            if( *response == RESET )
                me->spcl_flag = EM_ALIGN_REVERSE;

	    if ( *response == RESET || *response == DATA )
            {
                me->state = PLACE_ALIGN;
            }

	    break;

	case GET_OFFSET:/* valid for align of Planes only */
	    strcpy( me->offset, "0.0");
            strcpy( buffer,"Enter Align offset [0.0]" );
            om_msg = co$getevent( msg = &msg,
	                     event_mask = GRm_STRING|GRm_RJT_MOVEON,
	                     prompt = buffer,
               		     response = response,
                	     response_data = response_data,
        	             event = &event );

            /* an expression */
            if((event.response == EX_STRING) && strlen(event.event.keyin))
                strcpy( me->offset, event.event.keyin );

	    if((event.response == EX_STRING) || (event.response == EX_RJT_MOVEON))
            {
                me->state = PLACE_ALIGN;
                *response = RESET;
            }
            break;

        case PLACE_ALIGN:
	    /*
	     * Check if the type of features aligned is planar
	     */
	    om$get_classid( objid = me->feature_1.grid.objid,
	                    osnum = me->feature_1.grid.osnum,
                            p_classid = &classid );

            if((om$is_ancestry_valid(superclassid = OPP_EMSplane_class_id,
		      subclassid = classid) == OM_S_SUCCESS) ||
               (om$is_ancestry_valid(superclassid = OPP_EMSdatpln_class_id,
		      subclassid = classid) == OM_S_SUCCESS) )
	    {
	    IGRuint attrs = 0;

                om_msg = asm$add_constraint (msg = &msg,
                       	                 type = EM_MATE,
                               	         instance1_id = &me->inst1_id,
                                       	 instance2_id = &me->inst2_id,
	                                 feature_1 = &me->feature_1,
                                         feature_2 = &me->feature_2,
					 offset = me->offset,
               	                         constraint_id = &me->constraint_id,
                       	                 num_ids = &me->num_ids,
                               	         ids = &me->ids);

                if( (om_msg & msg & 1) || (msg == ASM_E_OVERCONSTRAINED) )
                {
                IGRlong msg1;

                    asm$get_constraint_attrs(msg = &msg1,
               	    		        id = &me->constraint_id,
               			        attrs = &attrs);

               	    attrs |= EM_MATE_ALIGNED;
			 
                    asm$set_constraint_attrs(msg = &msg1,
                      		        id = &me->constraint_id,
              		                attrs = attrs);
                }
	    }
            else
            {
                om_msg = asm$add_constraint (msg = &msg,
                                             type = EM_ALIGN,
                                             instance1_id = &me->inst1_id,
                                             instance2_id = &me->inst2_id,
                                             feature_1 = &me->feature_1,
                                             feature_2 = &me->feature_2,
                                             constraint_id = &me->constraint_id,
                                             num_ids = &me->num_ids,
                                             ids = &me->ids);
            }
            if( !(om_msg & msg & 1 ) )
            {
                if( msg == ASM_E_OVERCONSTRAINED )
                {
                    me->state = OVER_CONSTRAINED;
#ifdef DEBUG
                    printf("numids = %d\n",me->num_ids );
                    for(i=0;i<me->num_ids;i++)
                        printf("id[%d]=%d\n",i,me->ids[i].objid);
#endif
                }
                else if( msg != ASM_E_STRONGCOMP )
                {
                    ex$message( msgnumb = EMS_S_RESTART ); 
                    me->state = START;
                }
            }
            else
            {
                me->state = COMPUTE_CONSTR;
            }
            *response = RESET;
            break;

        case OVER_CONSTRAINED:
            ex$message( msgnumb = EMS_S_OverCnstrPart ); 

            /* 
             * Display the conflicting constraints in the Form
             */
            if((me->num_ids) && (me->fp == NULL))
	    om_msg = om$send( msg = message ECPlAlign.show_over_cnstr(
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
                          ex$message( msgnumb = EMS_S_OpFail );
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
                me->state = COMPUTE_CONSTR;
                *response = RESET;
            }
            break;

        case COMPUTE_CONSTR:

	    if( me->constraint_id.objid != NULL_OBJID )
	    {
		struct GRid instid;

                /* 
                 * If the align axis is reversed, set the attr_flg in
                 * constraint instance to EM_ALIGN_REVERSE
                 */
                if( me->spcl_flag & EM_ALIGN_REVERSE )
                {
		IGRuint attrs = 0;

                    asm$get_constraint_attrs(msg = &msg,
                    			     id = &me->constraint_id,
                    			     attrs = &attrs);

               	    attrs |= EM_ALIGN_REVERSE;
			 
                    asm$set_constraint_attrs(msg = &msg,
                        		     id = &me->constraint_id,
              			             attrs = attrs);
                }

                /*
                 * update the basis in the all affected instances
                 */
                om_msg = om$send( msg = message EMinstance.EMupdatebasis(&msg),
                                    targetid = me->inst2_id.objid,
                                    targetos = me->inst2_id.osnum );
                if( !(om_msg & msg & 1 ))
                {   
                    verbose(printf("EMupdatebasis failed\n"));            
                    me->state = START;
                    *response = RESET;
                    break;
                }
		/*
		 * Get the part grid on which this constraint is acting
		 */
		om_msg = om$send( msg = message EMconstr.EMgetpart( &msg, TRUE,
								    &instid ),
					targetid = me->constraint_id.objid,
					targetos = me->constraint_id.osnum);

		if( om_msg & msg & 1 )
		{
    		    om_msg = om$send(msg= message EMinstance.EMcompute_xform_matrix(
	    							    &msg,
								    NULL,
								    0,
								    matrix),
        					targetid = instid.objid,
	        				targetos = instid.osnum);

            	    if( !( om_msg & msg & 1 ))
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
                }

                nd$wait_batch(
	        	type = GR_GEOM_POSTED, 
		        l_object = &me->constraint_id, 
	        	nb_obj   = 1 );

                nd$mod_batch (request = ND_INQ, 
                              p_ret_mode = &batch_mode);
                
                if (batch_mode == ND_IMMEDIATE)
                {
                    nd$exec_batch ();
                }
            }

            me->state = GET_INST2;

            *response = RESET;
            break;
    }
    return( OM_S_SUCCESS );
}

int conf_cnstr_notify1(form_label, gadget_label, value, form_ptr)
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

 	status = om$send (msg = message ECPlAlign.do_form(&msg_loc, form_label,
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
    ret = FIf_new(100, "EMConfCnstr", conf_cnstr_notify1, &me->fp);
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
        {
        IGRuint attr;

            /*
             * Check if the mate is special align
             */
            attr = 0;
            asm$get_constraint_attrs( msg = &msg,
                                      id = &me->ids[i],
                                      attrs = &attr );

            if( attr & EM_MATE_ALIGNED )
                FIfld_set_text(me->fp, CNSTR_MCF, i, 0,"ALIGN",0);
            else
                FIfld_set_text(me->fp, CNSTR_MCF, i, 0, "MATE",0);
        }
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
                om_msg = om$send( msg = message ECPlAlign.hilite_element
                                                ( &msg, me->currow, me->curcol,
                                                 GRhe ),
                                targetid = my_id );

                om_msg = om$send( msg = message ECPlAlign.hilite_element
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
                om_msg = om$send( msg = message ECPlAlign.hilite_element
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
                me->fp = NULL;
                {
    	        int	 rsp = EX_FORM_FINISHED;
    	        long stat;
	
	        ex$putque(msg = &stat, response = &rsp);
	        }
                break;
            case FI_ACCEPT:
            case FI_CANCEL:
                if( me->currow != -1 && me->curcol != -1 )
                om_msg = om$send( msg = message ECPlAlign.hilite_element
                                                ( &msg, me->currow, me->curcol,
                                                 GRhe ),
                                targetid = my_id );
                FIf_erase( me->fp );
                FIf_delete( me->fp );
                me->fp = NULL ;
                {
    	        int	 rsp = EX_FORM_FINISHED;
    	        long stat;
	
	        ex$putque(msg = &stat, response = &rsp);
	        }
                break;
        }
	return( OM_S_SUCCESS );
}

/* If column number == 
 *        1. Highlight/erase picked constraint's features,
 *        2. highlight/erase the incident part ( cnstr's child ),
 *        3. highlight/erase the part constraint is applied to ( parent ).
 */
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

method wakeup( int pos )
{
    if( me->fp )
        FIf_display( me->fp );

    ex$message( msgnumb = EM_M_PlAlign );
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

end implementation ECPlAlign;
