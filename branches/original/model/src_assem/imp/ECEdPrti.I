/*******************************************************************************
*									       *
* File:   ECEdPrti.I							       *
*									       *
* Description:								       *
*                                                                              *
*     This file contains implementation of the Edit part command object        *
*									       *
*									       *
* Dependencies:								       *
*                                                                              *
* Notes:							               *
*                                                                              *
* History:         01/08/93   Krishna Kumar    creation date                   *
*******************************************************************************/

class implementation ECEdPrt;
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
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
#include "nddef.h"
#include "ndmacros.h"
#include "DIdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "refdef.h"
#include "asmprtmac.h"
#include "asmfilemac.h"
#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"

#include "grmsg.h"

#define EXTERN extern
#include "asmglobals.h"

#include "ECcmd.h"
#include "ECmsg.h"

#define MAXPATHLEN 256
#define DEBUG 


#define FINISHED       	-1
#define START           0
#define NEW_GRAPHICS    1
#define UPDATE_FORM     2
#define EDIT_PART       3

#define EM_DELETED      0x01000000
#define EM_MODIFIED     0x02000000
#define EM_APPENDED     0x04000000

#define PART_ATTRS  	12
#define INST_ATTRS  	19

#define TEXT_DISP	20
#define DIMEN_DISP	21
#define CONST_DISP	26
#define REFPL_DISP	27
#define WIREF_DISP	18
#define SOLSF_DISP	17

#define RESRVD_TXT1	16
#define RESRVD_TXT2	31
#define HOMEDIR_TXT	32

#define RESRVD_LAY1	29
#define RESRVD_LAY2	30
#define HOME_DIRECT	34
#define ELEM_ON_LAY	15
#define ELEM_ON_TXT     28

from EMlocalpart import EMget_layers, EMset_layers;


int editprt_notify (form_label, gadget_label, value, form_ptr)
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

 	status = om$send (msg = message ECEdPrt.do_form(&msg_loc, form_label,
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
int ret, om_msg;
long msg;

	/* 
	 * Initialise parent stuff 
	 */
 	ret = om$send(mode = OM_e_wrt_message,
        	       msg = message COpara.init( type, str_ptr),
            	       targetid = my_id);
	/*
	 * Initialise the instance
         */
	me->num_attrs = 0;
	me->attrs = NULL;
	me->props = 0;
	me->partid.objid = NULL_OBJID;

	ret = FIf_new(100, "EMEdFlPrtDef", editprt_notify, &me->fp);
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
	return( OM_S_SUCCESS );
}

method sleep( int pos )
{
int sts;


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

	/* If instance attrs is allocated, free the memory */
	if( me->attrs )
		free( me->attrs );

  	sts = om$send(msg = message COpara.delete( pos ),
                  targetid = my_id,
                  mode = OM_e_wrt_message);

	return( sts );
}

method execute( int *response; char *response_data; int pos )
{
IGRint                  i,om_msg, sizbuf;
IGRlong         msg, locate_display;
IGRlong                 mask1,mask2;
struct GRevent          event, locev;
struct GRmd_env         mod_env;
OM_S_CLASSLIST          elig_classes;
OMuword                 classes[5];
IGRchar                 buffer[256];

struct GRlc_locate      lc_attribs;
struct GRlc_stack       lc_stack;
IGRboolean              aflag = 0;


        if(aflag = pwIsActivationOn())
         {
          ex$message (in_buff="Deactivate the activated part",
                 field=ERROR_FIELD);
          *response = TERMINATE;
          return (OM_S_SUCCESS);
         }
           
	ex$message(msgnumb = EM_M_EditPart);/*  Edit Part */
	
	/*
     	* Get the current module enviroment.
     	*/	
    	sizbuf = sizeof( struct GRmd_env );
    	gr$get_module_env(msg = &msg,
                      sizbuf = &sizbuf,
                      buffer = &mod_env );

    	om_msg = OM_S_SUCCESS;
    	msg = MSSUCC;

    	/*
      	 * Goto the appropriate state.
     	 */                
    	switch (me->state)
    	{
        	case START:

            lc_attribs.properties = LC_LC_ONLY | LC_DP_ONLY | 
                                    LC_PLANAR_NON_PLANAR;
            lc_attribs.owner_action = LC_RIGID_COMP    | LC_FLEX_COMP   |
                                      LC_NO_REF_HEADER | LC_REF_OBJECTS |
                                      LC_ASSOCIATIVE |
                                      LC_EXTERN_CONSTRAINED ;

            locate_display  =  ALL_WINDOWS | NO_PROJ_ACCEPT_POINT | 
                               ELEM_HILIGHT |
                               ACC_REJ_CYCLE | RELOCATE |
                               LC_ERASE_ALL | LC_ACCEPT_CURSOR ;

            om$get_classid(classname = "EMinstance",
                           p_classid = &classes[0]);

            elig_classes.w_count = 1;
            elig_classes.p_classes = classes;
            elig_classes.w_flags = OM_CLST_subclass;

            mask1 = mask2  = GRm_DATA | GRm_STRING |GRm_RESET | GRm_BACK_UP|
                   GRm_SPECIFIED_OBJ|GRm_FORM_FINISHED;

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
                 locate_prompt     = "Identify File Part/Move on to Select Assembly",
                 acc_key           = GR_P_Acc,
                 relocate_key      = EMS_I_PartNotFound,
                 stack             = &lc_stack,
                 eligible_classes  = &elig_classes);

            switch( *response )
            {
                case EX_DATA:
                   dp$display(msg=&msg, 
                              oids = &lc_stack.entry[0].located_obj ,
                              mode = GRhe);

                   asm$get_instance_part(msg = &msg,
                                         instance_id = &(lc_stack.entry[0].located_obj),
                                         part_id = &me->partid);

                   om_msg = asm$get_part_type( msg = &msg,
                                  part_id = &me->partid,
                                  type = &me->type );

			       me->state = UPDATE_FORM;
			       break;

                case EX_RJT_MOVEON:
                   /*
                    * Get the active part.
                    */

                   om_msg = asm$get_active_part (msg = &msg,
                                                 part_id = &me->partid);

                   if( !(om_msg & msg & 1 ) )
                   {
                       UI_status("Error getting Active part");
                       return(OM_S_SUCCESS);
                   }

                   om_msg = asm$get_part_type( msg = &msg,
                               part_id = &me->partid,
                               type = &me->type );
			       me->state = UPDATE_FORM;
                   break;
            }
            break;

		case UPDATE_FORM:

			om_msg = om$send( msg = message ECEdPrt.form_update_attributes( &msg ),
						targetid = my_id );

			if( !( om_msg & msg & 1 ) )
			{
				me->state = FINISHED;
				*response = TERMINATE;
				break;
			}
            if (!me->form_displayed) 
			{
				FIf_display( me->fp );
				me->form_displayed = 1 ;
			}
			*response = RESET;
			me->state = EDIT_PART;
		    break;
            
        	case EDIT_PART:
            		/*
             		 * Wait for the user to input the part
             		 * attributes on the form.
             		 */

      	                strcpy( buffer, "Edit Part Definition on Form");
	                om_msg = co$getevent( msg = &msg,
		                     event_mask = ( GRm_FORM_FINISHED | GRm_STRING ),
		                     prompt = buffer,
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

method form_update_props ( IGRlong *rc )
{
IGRint om_msg;
IGRlong layers[32], active_on[32], lay[2];
IGRchar laytxt[80];
struct GRmd_env *mod_env = NULL; 

    *rc = MSSUCC;
    if ( me->partid.objid != NULL_OBJID)
    {
	    /*
	     * Get the reserved layers for the local part and display.
	     */
            if ( me->type == EM_LOCAL_PART )
	    {
                om_msg = om$send( msg = message EMlocalpart.EMget_layers ( rc,
                      						layers,
                      						NULL,
                      						NULL),
					targetid = me->partid.objid,
					targetos = me->partid.osnum);

		lay[0] = EMget_first_layer( layers );
		lay[1] = EMget_last_layer( layers );

		sprintf( laytxt, "%ld", lay[0] );
		FIg_set_text( me->fp, RESRVD_LAY1, laytxt );
		sprintf( laytxt, "%ld", lay[1] );
		FIg_set_text( me->fp, RESRVD_LAY2, laytxt );
            }

    	    /*
	     * Get the properties of the part and display in the form
	     */
            om_msg = asm$get_display_props (msg = rc,
                              		id = &me->partid,
                              		display = &me->props,
                                        layers = active_on);

 	    om_msg = EMconvert_layer_mask_to_string ( rc,
                                                      mod_env,
                                                      active_on,
                                                      laytxt );

            FIg_set_text( me->fp, ELEM_ON_LAY, laytxt );

            if( me->props & EM_TEXT_DISPLAYED )
                FIg_set_state (me->fp, TEXT_DISP, TRUE);
            if( me->props & EM_DIMENSION_DISPLAYED )
                FIg_set_state (me->fp, DIMEN_DISP, TRUE);
            if( me->props & EM_CONSTRAINT_DISPLAYED )
                FIg_set_state (me->fp, CONST_DISP, TRUE);
            if( me->props & EM_REFPLANE_DISPLAYED )
                FIg_set_state (me->fp, REFPL_DISP, TRUE);
            if( me->props & EM_WIREFRAME_DISPLAYED )
                FIg_set_state (me->fp, WIREF_DISP, TRUE);
            if( me->props & EM_SOLIDSURF_DISPLAYED )
                FIg_set_state (me->fp, SOLSF_DISP, TRUE);
    }
    return( OM_S_SUCCESS );
}
 
method form_update_attributes( IGRlong *rc)
{
IGRlong msg;
IGRint     om_msg, i;
IGRint	part_row = 0;
IGRchar newsyntax[128];

    *rc = MSSUCC;
    FIg_reset (me->fp, PART_ATTRS);
        
    if ( me->partid.objid != NULL_OBJID)
    {
        /*
         * Initialize the number of attributes to 0 and name 
         * to NULL.
         */
        me->num_attrs = 0;
        /*
         * Get all the attributes.
         */
        om_msg = asm$attribute_count (msg = &msg,
                                      id = &me->partid,
                                      count = &me->num_attrs);
        
        if (!(om_msg & msg & 1))
        {
#ifdef DEBUG
            printf ("Couldn't get the number of part attributes\n");
#endif
	    *rc = MSFAIL;
	    return( OM_E_ABORT );
        }
        else
        {
            /*
             * Get some memory.
             */
            if (me->attrs == NULL)
            {
                me->attrs = (EMattr *)malloc(me->num_attrs * sizeof(EMattr));
            }

            if ( me->attrs != NULL)
            {
                part_row = 0;
                for (i=0; i<me->num_attrs; i=i+1)
                {
                    om_msg = asm$get_attribute (msg = &msg,
                                                index = i,
                                                id = &me->partid,
                                                attribute = &me->attrs[i]);
                    if (om_msg & msg & 1)
                    {
                        if (!strcmp(me->attrs[i].info.name, "revision") ||
                            !strcmp(me->attrs[i].info.name, "filename"))
                           continue;

                        EMrem_syntax_lhs( me->attrs[i].value.syntax, newsyntax);

                        if (me->attrs[i].info.type == EM_PART_ATTR) 
                        {
                            FIfld_set_text (me->fp, PART_ATTRS, part_row, 0, 
                                            me->attrs[i].info.name, FALSE);
                            FIfld_set_text (me->fp, PART_ATTRS, part_row, 1, 
                                            me->attrs[i].info.desc, FALSE);
                            FIfld_set_text (me->fp, PART_ATTRS, part_row, 2, 
                                            newsyntax, FALSE);
                            part_row = part_row + 1;
                        }
                    }
                }

                /* Kludge to weed out revision - This is for RFA + Assembly*/
                for (i=0;i<me->num_attrs;i++)
                {
                   if (!strcmp(me->attrs[i].info.name, "revision") ||
                       !strcmp(me->attrs[i].info.name, "filename") ||
                       !( me->attrs[i].info.type == EM_PART_ATTR))
                   {
                     int j;

                     for(j=i;j<me->num_attrs - 1;j++)
                        me->attrs[j] = me->attrs[j+1];
                     me->num_attrs--;
                   }
                }
            }
            else
            {
                *rc = MSFAIL;
		        return( OM_E_ABORT );
            }
        }
    }

    return( OM_S_SUCCESS );
}


method do_form( IGRlong *rc; int form_label; int g_label; double value )
{
long msg;
int  sel, pos, indx;
int  om_msg=OM_S_SUCCESS, i, j, old_sys_mode;
int  num_part_attrs, num_rows;
int  act_row, act_col;
Form form_ptr;
char buffer[256], buff[128], name[50]="";
int  batch_mode, gadget_state;
EMattr attr;

	form_ptr = me->fp;
 	FIg_set_text( me->fp, FI_MSG_FIELD, "" );
	switch( g_label )
	{
       	case FI_ACCEPT:
        om_msg = OM_S_SUCCESS;
	    msg = MSSUCC;

		/* save system mode, and set to TRUE */
		old_sys_mode = EMdesc_set_system_mode(TRUE);
		/*
		 * Read in the values for undeleted attributes
		 */
		num_part_attrs = 0; 
	    EMget_num_rows(form_ptr,PART_ATTRS,0,&num_part_attrs);

		for(i = 0; i < num_part_attrs; i++)
		{
            indx = 0;
            for(j = 0; j < me->num_attrs; j++ )
            {
               if (me->attrs[j].info.type == EM_DELETED)
			    continue;
               if( me->attrs[j].info.type == EM_PART_ATTR )
                 if( indx++ == i )
                    break;
            }
		    if( j == me->num_attrs )
            {
               /* Add the new part attribute */
               attr.info.type = EM_PART_ATTR;
               attr.value.type = EM_CALCULATED;
       		   FIfld_get_text (form_ptr, PART_ATTRS, i,
						 0, 256, buffer, &sel, &pos);
               strcpy(attr.info.name, buffer);
       		   FIfld_get_text (form_ptr, PART_ATTRS, i,
						 1, 256, buffer, &sel, &pos);
               strcpy(attr.info.desc, buffer);
       		   FIfld_get_text (form_ptr, PART_ATTRS, i,
						 2, 256, buffer, &sel, &pos);
               if(remove_quotes(buffer))
			    attr.value.type = EM_STRING;
               strcpy(attr.value.syntax, buffer);

		       om_msg = asm$add_attribute (msg = &msg,
                                           id = &me->partid,
                                           attribute = &attr);

		       if (!(om_msg & msg & 1))
		       {
                  sprintf (buffer, "Couldn't add attribute %s",
			                           attr.info.name);
               	  FIg_set_text (form_ptr, FI_MSG_FIELD,buffer);
                  break; /* break the for loop on num_part_attrs */
               }
             }
             else
             {
               /* Modify the part attribute found */
       		   FIfld_get_text (form_ptr, PART_ATTRS, i,
						 0, 256, buffer, &sel, &pos);
               strcpy(name, me->attrs[j].info.name);
               strcpy(me->attrs[j].info.name, buffer);

       		   FIfld_get_text (form_ptr, PART_ATTRS, i,
						 1, 256, buffer, &sel, &pos);
               strcpy(me->attrs[j].info.desc, buffer);

       		   FIfld_get_text (form_ptr, PART_ATTRS, i,
						 2, 256, buffer, &sel, &pos);
               remove_quotes(buffer);

               strcpy(me->attrs[j].value.syntax, buffer);

	           om_msg = asm$mod_attribute (msg = &msg,
                                           id = &me->partid,
                                           index = me->attrs[j].info.index,
                                           attribute = &me->attrs[j]);

               if (!(om_msg & msg & 1) || !strcmp(name,"number"))
               {
	           	  om_msg = asm$mod_attribute (msg = &msg,
                                              id = &me->partid,
                                              name = name,
                                              attribute = &me->attrs[j]);
               }

	           if (!(om_msg & msg & 1))
	           {
                 sprintf (buffer, "Couldn't update attribute %s",
			                            me->attrs[j].info.name);
                 FIg_set_text (form_ptr,FI_MSG_FIELD, buffer);
                 break;
			   }
             }
        }
		if( !(om_msg & msg & 1) )
		    break;   /* break the switch */

		/* Remove the deleted attrs */
		for(i = 0; i < me->num_attrs; i++ )
		{
          if( me->attrs[i].info.type == EM_DELETED )
          {
	        om_msg = asm$rem_attribute( msg = &msg,
                                        id = &me->partid,
                                        name = me->attrs[i].info.name );
            if( !(om_msg & msg & 1))
            {
      		    sprintf (buffer, "Couldn't remove attribute %s",
	                            me->attrs[i].info.name);
           	    FIg_set_text (form_ptr,FI_MSG_FIELD, buffer);
                break;
            }
          }
        }

		/* Go back to old system mode */
		EMdesc_set_system_mode(old_sys_mode);

		if( !(om_msg & msg & 1) )
		    break;   /* break the switch */

    	/*
      	 * Update the modify batch if requested.
       	 */
       	nd$mod_batch (request = ND_INQ, p_ret_mode = &batch_mode);

       	if (batch_mode == ND_IMMEDIATE)
       	{
       		nd$exec_batch ();
       	}

		FIf_erase( form_ptr );        
		{
		int	rsp = EX_FORM_FINISHED;
		long 	stat;
	
		ex$putque(msg = &stat, response = &rsp);
		}
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

	    FIfld_get_active_row (form_ptr, g_label, &act_row, &pos );
		FImcf_get_active_col (form_ptr, g_label, &act_col, &pos );
		/*
		 * If an attribute name is removed, delete the row
	         */
               	buffer[0] = 0;
	       	FIfld_get_text (form_ptr, g_label, act_row, act_col, 
               		                 256, buffer, &sel, &pos);
		if( act_col == 0 )
		{
		    if( act_row == 0 )
            {
              if((g_label == PART_ATTRS) && strcmp( buffer,"number"))
              FIfld_set_text(form_ptr, g_label,0,0,"number",0);
              break;
            }

		    if( buffer[0] == 0 )
		    {
			/*
			 * Set the attr type to EM_DELETED 
			 */
			for(i = 0, indx = 0; i < me->num_attrs; i++ )
			{
			    if (me->attrs[i].info.type == EM_DELETED)
                                continue;
			    if (g_label == PART_ATTRS)
                {
                   if (me->attrs[i].info.type == EM_PART_ATTR)
                    if (indx++ == act_row)
                      break;
                 }
            }
			if ( i < me->num_attrs )
			{
		    	    me->attrs[i].info.type = EM_DELETED;
	            	    FIfld_get_num_rows(form_ptr,g_label,&num_rows);
               		    for (i=act_row; i<num_rows-1; i=i+1)
               	            {
                       	        for (j=0; j<3; j=j+1)
                       	        {
                      	            FIfld_get_text (form_ptr, g_label, 
                                     		i+1, j, 256, buffer, &sel,&pos);
                        
		                    FIfld_set_text (form_ptr, g_label,
                                       		i, j, buffer, FALSE);
                       	        }       
               	            }
                
    	                    for (i=0; i<3; i=i+1)
               		    {
	                        FIfld_set_text (form_ptr,g_label,
               		                    num_rows-1, i, "", FALSE);
               	            }   
                        }
               	    }
                }
 		else if(act_col == 2)
		{

                    name[0] = 0;
                    om_msg = EMget_syntax_from_input( buffer, buff, name );

                    if( om_msg )
                    {
                        FIfld_set_text( form_ptr, g_label, act_row, 2,
                                                            buff, FALSE );
                        if(strlen(name))
                       	    FIfld_set_text( form_ptr, g_label, act_row,
                                                             0, name, FALSE );
                    }
                    else om_msg = OM_S_SUCCESS;
                }
       		break;
  	}
        if( !(om_msg & msg & 1 ) && (g_label == FI_ACCEPT))
            FIg_set_state_off( form_ptr, FI_ACCEPT );

  	return(OM_S_SUCCESS);
}

end implementation ECEdPrt;
