/*******************************************************************************
*									       *
* File:   ECDfLPrti.I							       *
*									       *
* Description:								       *
*                                                                              *
*     This file contains implementation of the Define local part command       *
*									       *
*									       *
* Dependencies:								       *
*                                                                              *
* Notes:							               *
*                                                                              *
* History:         09/02/94   Krishna Kumar    creation date                   *
*******************************************************************************/

class implementation ECDfLPrt;

#include "stdio.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "tools.h"
#include "FI.h"
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <gr.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include "griodef.h"
#include "griomacros.h"
#include "msdef.h"
#include "growner.h"
#include "grgsdef.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "grsymdef.h"
#include "grsym.h"
#include <grerr.h>
#include "grsymmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

#include "ECcmd.h"
#include "ECmsg.h"

#define FINISHED       -1
#define START           0
#define GET_PART_INFO   1
#define CLEANUP         5

#define PART_FORM   2

#define SEED_PART   18
#define SEARCH_PART 24
#define PART_ATTRS  12
#define INST_ATTRS  15
#define FROM_LAYER  32
#define TO_LAYER    36
#define ON_LAYERS   38
#define TEXT        25
#define DIMENSION   26
#define CONSTRAINT  27
#define REFPLANE    28
#define WIREFRAME   29
#define SOLIDS      30
#define MESSAGE     10
#define TITLE       11

#define ATTR_MAX_LEN   15

from EMlocalpart import EMset_layers;

form_update ( Form form_ptr )
{
IGRlong first_layer, last_layer;
IGRlong msg, om_msg;
IGRchar buffer[256];
EMattr  itattr;

    FIfld_set_text (form_ptr, SEED_PART, 0, 0, "", FALSE);

    FIg_set_state (form_ptr, TEXT,       TRUE);
    FIg_set_state (form_ptr, DIMENSION,  TRUE);
    FIg_set_state (form_ptr, CONSTRAINT, TRUE);
    FIg_set_state (form_ptr, REFPLANE,   TRUE);
    FIg_set_state (form_ptr, WIREFRAME,  TRUE);
    FIg_set_state (form_ptr, SOLIDS,     TRUE);

    FIg_reset (form_ptr, PART_ATTRS);
    FIg_reset (form_ptr, INST_ATTRS);
    FIg_reset (form_ptr, ON_LAYERS);
    
    FIfld_set_text (form_ptr, PART_ATTRS, 0, 0, "number", FALSE);
    FIfld_set_text (form_ptr, PART_ATTRS, 0, 1, "Part Number", FALSE);
    FIfld_set_text (form_ptr, PART_ATTRS, 0, 2, "", FALSE);

    FIfld_set_text (form_ptr, PART_ATTRS, 1, 0, "revision‚", FALSE);
    FIfld_set_text (form_ptr, PART_ATTRS, 1, 1, "Part Revision", FALSE);
    FIfld_set_text (form_ptr, PART_ATTRS, 1, 2, "", FALSE);

    FIfld_set_text (form_ptr, PART_ATTRS, 2, 0, "description", FALSE);
    FIfld_set_text (form_ptr, PART_ATTRS, 2, 1, "Part Description", FALSE);
    FIfld_set_text (form_ptr, PART_ATTRS, 2, 2, "", FALSE);

    FIfld_set_text (form_ptr, INST_ATTRS, 0, 0, "itemno", FALSE);
    FIfld_set_text (form_ptr, INST_ATTRS, 0, 1, "Item Number", FALSE);
    om_msg = EMnext_itemno_attribute (&msg, NULL, &itattr );
    if( om_msg & 1 )
    {
        sprintf( buffer, "\"%s\"", itattr.value.syntax );
        FIfld_set_text (form_ptr, INST_ATTRS, 0, 2, buffer, FALSE);
    }
    FIfld_set_text (form_ptr, INST_ATTRS, 1, 0, "quantity", FALSE);
    FIfld_set_text (form_ptr, INST_ATTRS, 1, 1, "Quantity", FALSE);
    FIfld_set_text (form_ptr, INST_ATTRS, 1, 2, "1", FALSE);

    if (EMnext_part_layer_set (&msg, 20, &first_layer, &last_layer, NULL) & 1)
    {
        sprintf(buffer, "%d", first_layer);
        
        FIfld_set_text (form_ptr, FROM_LAYER, 0, 0, buffer, FALSE);
        
        sprintf(buffer, "%d", last_layer);
        
        FIfld_set_text (form_ptr, TO_LAYER, 0, 0, buffer, FALSE);
    }
    return( 1 );
}
            
int deflprt_notify (form_label, gadget_label, value, form_ptr)
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

 	status = om$send (msg = message ECDfLPrt.do_form(&msg_loc, form_label,
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

    ret = FIf_new(100, "EMDfLocPrt", deflprt_notify, &me->fp);
    if(ret)
	return (OM_E_ABORT);

    ret = FIf_set_cmd_oid_os(me->fp, my_id, OM_Gw_current_OS);
    if(ret) 
	return (OM_E_ABORT);

    me->state = START;

    return( OM_S_SUCCESS );
}

method wakeup( int pos )
{
int form_displayed ;

    if( me->fp )
    {
        FIf_is_displayed( me->fp, &form_displayed );

        if(!form_displayed)
            FIf_display( me->fp );
    }
    return( OM_S_SUCCESS );
}

method sleep( int pos )
{
int sts;

	FIf_erase ( me->fp );

 	sts = om$send(mode = OM_e_wrt_message,
        	       msg = message COpara.sleep( pos ),
            	       targetid = my_id);

	return( OM_S_SUCCESS );
}


method delete( int pos )
{
int sts;

	if( me->fp )
		FIf_delete( me->fp );

        me->fp = NULL;
  	sts = om$send(msg = message COpara.delete( pos ),
                  targetid = my_id,
                  mode = OM_e_wrt_message);

	return( sts );
}
    
method execute( int *response; char *response_data; int pos )
{
IGRint                  om_msg, count;
IGRlong                 msg;
struct GRevent          event;
struct GRmd_env         mod_env;
struct GRid             file_part_id;
    
    ex$message( msgnumb = EM_M_DfLocPrt );/* "Define Local Part"*/

    /*
     * Get the current module enviroment.
     */	
    gr$get_module_env( buffer = &mod_env );

    /*
     * Goto the appropriate state.
     */                
    switch (me->state)
    {
        /*
         * (Re)initialize the command.
         */
        case START:
            om_msg = OM_S_SUCCESS;
            msg = MSSUCC;
            
            /*
             * Get the file part.
             */
            om_msg = asm$get_file_part (msg = &msg, 
                                        mod_env = &mod_env,
                                        part_id = &file_part_id);
                
            /*
             * If the file part for this file doesn't already
             * exits create a default part.
             */
            if (!(om_msg & msg & 1))
            {
                om_msg = asm$create_file_part (msg = &msg,
                                               mod_env = &mod_env,
                                               number = "new_part",
                                               revision = "a",
                                               part_id = &file_part_id);
                    
                if (!(om_msg & msg & 1))
                {
                    UI_status ("Could not define active file as a part.");
                    *response = TERMINATE;
                    break;
                }
            }
            else
            {
                form_update ( me->fp );
                om_msg = asm$part_count (msg = &msg,
                                 type = EM_LOCAL_PART,
                                 count = &count);

                if (!(om_msg & msg & 1) || !count)
                {
                    FIg_disable(me->fp,SEARCH_PART);
                }
                
                me->state = GET_PART_INFO;
            }
	    *response = RESET;
            break;

        case GET_PART_INFO:

            /*
             * Wait for the user to input the part
             * attributes on the form.
             */
            om_msg = co$getevent( msg = &msg,
	                     event_mask = ( GRm_FORM_FINISHED | GRm_STRING ),
	                     prompt = "Enter part info on form",
               		     response = response,
                	     response_data = response_data,
        	             event = &event );

            if( event.response == EX_FORM_FINISHED )
	    {
		me->state = FINISHED;
		*response = TERMINATE;
	    }

            break;
    }
    return( OM_S_SUCCESS );
}

method do_form( IGRlong *rc; int form_label; int g_label; double value )
{
IGRlong msg = MSSUCC;
IGRint  om_msg = OM_S_SUCCESS, count,i,ii,j,sts;
IGRint  part_row,inst_row;
struct  GRid part_id;
EMattr  attr1,attr2,attr3;
IGRchar **loc_parts = NULL, buffer[256], layers[256];
IGRint  num_attrs, num_part_attrs, num_inst_attrs;
EMattr  * attrs = NULL;
IGRint  sel, pos, gadget_state;
IGRint  act_row, act_col, num_rows;
IGRint  display_props;
Form    form_ptr;
IGRlong onlayers[32];
IGRchar number[MAX_VALUE], revision[MAX_VALUE];

    *rc = MSSUCC;
    form_ptr = me->fp;

    FIg_set_text( me->fp, MESSAGE, "");
    switch ( g_label )
    {
    case SEARCH_PART:

        om_msg = asm$part_count (msg = &msg,
                                 type = EM_LOCAL_PART,
                                 count = &count);

        if( !(om_msg & msg & 1 ))
            break;

        loc_parts = (IGRchar **)malloc(sizeof(char *) * count);

        for (i=0; i<count; i++)
        {
            om_msg = asm$get_part (msg = &msg,
                                   type = EM_LOCAL_PART,
                                   index = i,
                                   part_id = &part_id);

            if (!(om_msg & msg & 1))
            {
#ifdef DEBUG
                printf("get_part failed\n");
#endif
                break;
            }
          
            loc_parts[i] = (IGRchar *)malloc(sizeof(char) * DI_PATH_MAX);

            om_msg = asm$get_part_identity (msg = &msg,
                                            part_id = &part_id,
                                            number = &attr1,
                                            revision = &attr2);

            if(!(om_msg & msg & 1)) 
            {
#ifdef DEBUG
                printf("get_part_identity failed\n");
#endif
                break;
            }

            strcpy(loc_parts[i],attr1.value.data.s);

	    for( ii = strlen( loc_parts[i] ); ii < ATTR_MAX_LEN; ii++ )
		strcat( loc_parts[i]," " );

            strcat(loc_parts[i],"|");
	    strcat(loc_parts[i]," ");
            strcat(loc_parts[i],attr2.value.data.s);

            om_msg = asm$get_attribute(msg = &msg,
                                       id = &part_id,
                                       name = "description",
                                       attribute = &attr3);
	    if( om_msg & msg & 1 )
	    {
	        for(ii = strlen( attr2.value.data.s );ii < ATTR_MAX_LEN;ii++)
		    strcat( loc_parts[i]," " );

                strcat(loc_parts[i],"|");
	        strcat(loc_parts[i]," ");
                strcat(loc_parts[i],attr3.value.data.s);
            }
	    else
	    {
                om_msg = OM_S_SUCCESS;
                msg = MSSUCC;
            }
        }

	if( om_msg & msg & 1 )
	{
            pull_main (form_label, me->fp, SEED_PART, 0, 0, loc_parts,
                           count, 0, 0, 10, &sts, &i);
            if( sts )
            {
                /* Free the memory of the strings */
                for(j = 0; j < count; j = j + 1)
                    free(loc_parts[j]);
                free(loc_parts); 

                FIg_reset (form_ptr, PART_ATTRS);
                FIg_reset (form_ptr, INST_ATTRS);

                om_msg = asm$get_part (msg = &msg,
                                  type = EM_LOCAL_PART,
                                  index = i,
                                  part_id = &part_id);

                om_msg = asm$attribute_count(msg = &msg,
                                        id = &part_id,
                                        count = &count);

                om_msg = asm$get_attribute(msg = &msg,
                                       id = &part_id,
                                       name = "number",
                                       attribute = &attr1);

                FIfld_set_text (me->fp,SEED_PART,0,0,attr1.value.data.s, FALSE);

                part_row = 0;
                inst_row = 0;
                for(j=0; j < count; j = j + 1)
                {
                    om_msg = asm$get_attribute(msg = &msg,
                                          id = &part_id,
                                          index = j,
                                          attribute = &attr1);
                    if(!(om_msg & msg & 1))
                        break;

                    if(attr1.info.type & EM_PART_ATTR)
                    {
                        FIfld_set_text(me->fp,PART_ATTRS,part_row,0,attr1.info.name,
                                                              FALSE);
                        FIfld_set_text(me->fp,PART_ATTRS,part_row,1,attr1.info.desc,
                                                              FALSE);

                        if (strcmp(attr1.info.name, "number") != 0 && 
                            strcmp(attr1.info.name, "revision") != 0 )
                        {
                            if( attr1.value.type == EM_STRING )
                                sprintf( buffer, "\"%s\"", attr1.value.syntax );
                            else
                                EMrem_syntax_lhs( attr1.value.syntax, buffer);
                            FIfld_set_text(form_ptr,PART_ATTRS,part_row,2,
                                                buffer,FALSE);
                        }
                        part_row = part_row + 1;
                    }
                    else if((attr1.info.type & EM_INSTANCE_ATTR) ||
                            (attr1.info.type & EM_COMMON_ATTR))
                    {
                        FIfld_set_text(me->fp,INST_ATTRS,inst_row,0,attr1.info.name,
                                                              FALSE);
                        FIfld_set_text(me->fp,INST_ATTRS,inst_row,1,attr1.info.desc,
                                                              FALSE);
                        if( !strcmp( attr1.info.name, "itemno" ))
                        {
                            om_msg = EMnext_itemno_attribute (&msg, 
                                                          NULL,
                                                          &attr2);
                            if((om_msg & msg & 1))
                                sprintf( buffer, "\"%s\"", attr2.value.syntax);
                        }
                        else
                        {
                            if( attr1.value.type == EM_STRING )
                                sprintf( buffer, "\"%s\"", attr1.value.syntax );
                            else
                                EMrem_syntax_lhs( attr1.value.syntax, buffer);
                        }
                        FIfld_set_text(form_ptr,INST_ATTRS,inst_row,2,
                                                buffer,FALSE);
                        inst_row = inst_row + 1;
                    }
                }
            }
        }
        else
            FIg_set_text( me->fp, MESSAGE,"Failed to get parts");

        break;

    case FI_EXECUTE:
    case FI_ACCEPT:
        msg = MSSUCC;
        
        /*
         * Build the layers string.
         */
        FIfld_get_text (form_ptr, FROM_LAYER, 0, 0, 256, buffer, &sel, &pos);
        strcpy (layers, buffer);
        FIfld_get_text (form_ptr, TO_LAYER, 0, 0, 256, buffer, &sel, &pos);
        strcat (layers, "-");
        strcat (layers, buffer);

        /* 
         * Get the on layers.
         */
        FIfld_get_text(form_ptr, ON_LAYERS, 0, 0, 256, buffer, &sel,&pos);

        if(buffer[0] != '\0')
        {
            EMconvert_layer_string_to_mask(&msg,buffer,onlayers);
        }
        else
        {
            EMconvert_layer_string_to_mask(&msg,layers,onlayers);
        }
        /*
         * Get the display properties.
         */
        display_props = EM_GRAPHIC_DISPLAYED;
        
        FIg_get_state (form_ptr, TEXT, &gadget_state);
        
        if (gadget_state)
        {
            display_props = display_props | EM_TEXT_DISPLAYED;
        }
        
        FIg_get_state (form_ptr, DIMENSION, &gadget_state);
        
        if (gadget_state)
        {
            display_props = display_props | EM_DIMENSION_DISPLAYED;
        }
        
        FIg_get_state (form_ptr, CONSTRAINT, &gadget_state);
        
        if (gadget_state)
        {
            display_props = display_props | EM_CONSTRAINT_DISPLAYED;
        }
        
        FIg_get_state (form_ptr, REFPLANE, &gadget_state);
        
        if (gadget_state)
        {
            display_props = display_props | EM_REFPLANE_DISPLAYED;
        }
        
        FIg_get_state (form_ptr, WIREFRAME, &gadget_state);
        
        if (gadget_state)
        {
            display_props = display_props | EM_WIREFRAME_DISPLAYED;
        }
        
        FIg_get_state (form_ptr, SOLIDS, &gadget_state);
        
        if (gadget_state)
        {
            display_props = display_props | EM_SOLIDSURF_DISPLAYED;
        }
        
        /*
         * Get the number of attributes.
         */
        FIfld_get_num_rows( form_ptr, PART_ATTRS,  &num_part_attrs );
        FIfld_get_num_rows( form_ptr, INST_ATTRS, &num_inst_attrs );
        num_attrs = num_part_attrs + num_inst_attrs; 

        attrs = (EMattr *)om$malloc (size = num_attrs * sizeof(EMattr));
        
        /*
         * Get all the part attributes.
         */
        num_attrs = 0;
        
        for (i=0; i<num_part_attrs; i=i+1)
        {
            attrs[num_attrs].info.type = EM_PART_ATTR;
            
            FIfld_get_text (form_ptr,
                            PART_ATTRS,
                            i, 0, MAX_VALUE,
                            attrs[num_attrs].info.name,
                            &sel, &pos);

            if (attrs[num_attrs].info.name[0] != '\0')
            {
                FIfld_get_text (form_ptr,
                                PART_ATTRS,
                                i, 1, MAX_VALUE,
                                attrs[num_attrs].info.desc,
                                &sel, &pos);
                
                FIfld_get_text (form_ptr,
                                PART_ATTRS,
                                i, 2, MAX_VALUE,
                                attrs[num_attrs].value.syntax,
                                &sel, &pos);

                if(remove_quotes( attrs[num_attrs].value.syntax ))
		    attrs[num_attrs].value.type = EM_STRING;
                
                if (!strcmp(attrs[num_attrs].info.name, "number"))
                {
                    strcpy (number, attrs[num_attrs].value.syntax);
                }
                else if (!strcmp(attrs[num_attrs].info.name, "revision"))
                {
                    strcpy (revision, attrs[num_attrs].value.syntax);
                }
                    
                num_attrs = num_attrs + 1;
            }
        }

        /*  
         * Get all the instance attributes.
         */
        for (i=0; i<num_inst_attrs; i=i+1)
        {
            attrs[num_attrs].info.type = EM_INSTANCE_ATTR;

            FIfld_get_text (form_ptr,
                            INST_ATTRS,
                            i, 0, MAX_VALUE,
                            attrs[num_attrs].info.name,
                            &sel, &pos);
            
            if (attrs[num_attrs].info.name[0] != '\0')
            {
                FIfld_get_text (form_ptr,
                                INST_ATTRS,
                                i, 1, MAX_VALUE,
                                attrs[num_attrs].info.desc,
                                &sel, &pos);
                
                FIfld_get_text (form_ptr,
                                INST_ATTRS,
                                i, 2, MAX_VALUE,
                                attrs[num_attrs].value.syntax,
                                &sel, &pos);

                if(remove_quotes( attrs[num_attrs].value.syntax ))
		    attrs[num_attrs].value.type = EM_STRING;

                if( !strcmp( attrs[num_attrs].info.name, "itemno") )
		{
    	            attrs[num_attrs].info.type = EM_COMMON_ATTR; /* itemno */
    	            attrs[num_attrs].value.type = EM_STRING;
		}
                num_attrs = num_attrs + 1;
            }
        }

        if (msg & 1)
        {
        int  type;

	    /*
             * Check if a part with the given number and rev exists in 
             * the active assembly and if that is a local part, get 
             * confirmation to overwrite that definition.
             */
            part_id.objid = NULL_OBJID;
            om_msg = asm$get_part( msg = &msg,
                                   number = number,
                                   revision = revision,
                                   part_id = &part_id );

            if((om_msg & msg & 1) && part_id.objid != NULL_OBJID )
            {
                /* KLUDGE:
                 *        Until we find a way to get this confirmation
                 *        we would not accept the duplicate part number
                 *        revision
                 */
                FIg_set_text (form_ptr, MESSAGE, "Part number/revision should be unique");
                UI_status("Part not created");
                if(g_label == FI_ACCEPT)
                    FIg_set_state_off(form_ptr, FI_ACCEPT);
                break;
                /*
                om_msg = asm$get_part_type( msg = &msg,
                                            part_id = &part_id,
                                            type = &type );
                if( om_msg & msg & 1 )
                {

                    if(type == EM_LOCAL_PART)
                    {
                        |* Get confirmation to overwrite using a warning
                           box
                        *|
                    }
                    else
                    {
                    }
                }
                */
            }
            /*
             * Create the part.
             */
            om_msg = asm$create_local_part (msg = &msg,
                                            display = display_props,
                                            number = number,
                                            revision = revision,
                                            num_attributes = num_attrs,
                                            attributes = attrs,
                                            layers_string = layers,
                                            part_id = &part_id);
        }
        
        if (om_msg & msg & 1)
        {
        IGRint olsysmod;
	    /*
	     * Update the display properties of the part 
	     */
            om_msg = asm$set_display_props (msg = &msg,
                        		    id = &part_id,
		                            display = &display_props,
					    layers = onlayers,
					    update = TRUE );
#ifdef DEBUG
		    if( !(om_msg & msg & 1 ) )
			printf("Couldn't set display props\n");
#endif
            om_msg = om$send(msg = message EMlocalpart.EMset_layers(
								&msg,
                                                                NULL,
                      						onlayers,
                      						NULL),
					targetid = part_id.objid,
					targetos = part_id.osnum);
#ifdef DEBUG
		    if( !(om_msg & msg & 1 ) )
			printf("Couldn't set on layers\n");
#endif
            olsysmod = EMdesc_set_system_mode(TRUE);
	    for( i = 0; i < 2; i ++ )/* Update number, revision */
            {
            	om_msg = asm$mod_attribute (msg = &msg,
                                    	id = &part_id,
					name = attrs[i].info.name,
					attribute = &attrs[i]);
            }
            EMdesc_set_system_mode(olsysmod);
              
            if (g_label == FI_ACCEPT)
            {
        	int	rsp = EX_FORM_FINISHED;
	        long 	stat;

                FIf_erase (me->fp);
                ex$putque(msg = &stat, response = &rsp);
            }
            else
            {
                form_update ( me->fp );
                FIg_enable( me->fp, SEARCH_PART );
            }
            FIfld_set_text (form_ptr, MESSAGE, 0, 0, "Part created", FALSE);
        }
        else
        {
            FIfld_set_text (form_ptr, MESSAGE, 0, 0, 
                            "Couldn't create part", FALSE);
        }
        
        msg = MSSUCC;
        break;

    case FI_CANCEL:
        FIf_erase (form_ptr);

	{
	int	rsp = EX_FORM_FINISHED;
	long 	stat;

            ex$putque(msg = &stat, response = &rsp);
	}
        break;

    case PART_ATTRS:
    case INST_ATTRS:
        FIfld_get_active_row (form_ptr, g_label, &act_row, &pos );
	FImcf_get_active_col (form_ptr, g_label, &act_col, &pos );
	/*
	 * If an attribute name is removed, delete the row
         */
        buffer[0] = 0;
	if( act_col == 0 )
	
	{
            FIfld_get_text (form_ptr, g_label, act_row,0, 
              		                 256, buffer, &sel, &pos);
            /* description and quantity attribute names also should not
               be allowed for editing -- TR# 119420313 -- Satya **/
	    if( act_row == 0 )
            {
                if((g_label == PART_ATTRS) && strcmp( buffer,"number"))
                    FIfld_set_text( form_ptr, g_label, 0, 0, "number", 0 );
                if((g_label == INST_ATTRS) && strcmp( buffer,"itemno"))
                    FIfld_set_text( form_ptr, g_label, 0, 0, "itemno", 0 );
                break;
            }
            else if( act_row == 1)
            {
                if((g_label == PART_ATTRS) && strcmp( buffer,"revision"))
                    FIfld_set_text( form_ptr, g_label, 1, 0, "revision", 0 );
                if((g_label == INST_ATTRS) && strcmp( buffer,"quantity"))
                    FIfld_set_text( form_ptr, g_label, 1, 0, "quantity", 0 );
                break;
            }
            else if(act_row == 2 && g_label == PART_ATTRS)
            {
                if( strcmp( buffer,"description") )
                    FIfld_set_text( form_ptr, g_label, 2, 0, "description", 0 );
                break;
            }
            if( buffer[0] == 0 )
	    {
                FIfld_get_num_rows(form_ptr,g_label,&num_rows);
                
	        for (i=act_row; i<num_rows-1; i=i+1)
                {
                    for (j=0; j<3; j=j+1)
                    {
                    	FIfld_get_text (form_ptr, g_label, i+1, j, 256, buffer, &sel, &pos);
                        FIfld_set_text (form_ptr, g_label, i, j, buffer, FALSE);
       		    }       
                }
                for (i=0; i<3; i=i+1)
		    FIfld_set_text (form_ptr,g_label, num_rows-1, i, "", FALSE);
  	    }
        }
	else if ((act_col == 2) && (act_row == 0) && (g_label == INST_ATTRS))
	{
            FIfld_get_text (form_ptr, g_label, 0, 2, 
              		                 256, buffer, &sel, &pos);
	    /* Validate the itemno keyed in */
            if (!EMitem_string_unique (buffer))
            {
                FIg_set_text (form_ptr, MESSAGE, "Itemno not unique");
                om_msg = EMnext_itemno_attribute (&msg, NULL, &attr2);
                if((om_msg & msg & 1))
                    sprintf( buffer, "\"%s\"", attr2.value.syntax);
                FIfld_set_text (form_ptr, INST_ATTRS, 0, 2, buffer, FALSE);
            }
        }
        break;
    }
    return( om_msg );
}

end implementation ECDfLPrt;


