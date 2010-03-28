/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    	GRinquireref - method which returns requested information
		about a reference file attachment.  A user provided
		function will be invoked to process this information
		if one is provided. The function is optional input.

Synopsis
	GRinquireref(msg,env,inquire_requests,which_error,
		      pass_to_nested_attachments,processor)

	struct GRmd_env *env	 environment information
     	struct GRinquire_list  	*inquire_requests
		  		requests for the inquire
	IGRint *which_error	indicator of which request had an
				    error.
	IGRboolean *pass_to_nested_attachments
				indicator of whether you want your the
				requests to be passed to nested files.
	struct GRinfo_processor contains information needed for special
				processing of information if desired.
				included is:
		  		-   function to process information
				-   character pointer for any special
				    info needed.

Description

	This method accumulates requested information and places it 
	in the user provided variable length array.  

	This method calls a function provided by the user to process
	this information.  The function is optional.

	If you send a processor function, it will be called with the
	following arguments:

	    (*(processor->processor_function))(msg,inquire_requests,
			processor->info,nest_indicator);

	    IGRlong  	*msg;
	    struct GRinquire_list *inquire_requests;
	    IGRchar  	processor->info;
	    IGRint	*nest_indicator; 
			the values for the nest indicator have the
				following meaning:
			0 - process this level
			1 - begin transition to another space
			2 - end the transition from the current space

	The include file refdef.h lists the valid requests for the
	inquire.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSINARG - not enough storage given for request
	GRNOTIMPLEMENTED - the requested entry has not been 
		implemented
	MSFAIL - error

Notes
	None.
History
	MAS     12/30/86 	Design date.
	jhw	08/04/89	Added support for reference id and name.
	jhw	08/04/89	Fixed problem sending to nested spaces.
        jhw     09/20/89        Fixed looping problem in sends to other spaces.
        jhw     11/20/89        Added support for file not found.
        jhw     01/05/90        Added support for duplicate osname.
        dhm     07/06/92        ANSI conversion.
\*/

class implementation GRreffile;

#include <stdio.h>
#include "grimport.h"
#include "madef.h"
#include "godef.h"
#include "refdef.h"
#include "grerr.h"
#include "refpriv.h"
#include "msdef.h"
#include "OMmacros.h"
#include "DIdef.h"

from Super_rfmgr import Super_passon;

extern    IGRboolean    GRexpansion_valid();
extern    IGRint        GRset_expansion_mode();

method GRinquireref(IGRlong *msg; struct GRmd_env *env;
    struct GRinquire_list *inquire_requests; IGRint  *which_error; 
    IGRboolean *pass_to_other_spaces;struct GRinfo_processor *processor)
{
    unsigned long *prop_ptr;  /** Modified short to long -- Satya **/

    IGRlong	OMmsg;		/* OM return code		*/
    IGRlong     msg1;
    IGRlong	request;
    IGRint	i,j;		/* index			*/
    IGRint	length;
    IGRuint	count;		/* channel count		*/
    IGRint	dimension;
    IGRint      nest_indicator;
    IGRint      reset;
    OMuword     osnum;
    OM_p_DUPINTOS dupos_p;
    FILE        *fet;
    IGRchar     filename[OM_K_MAXOSNAME_LEN];


    
    OM_S_CHANSELECT chandef;	/* super's channel to ref files */
    OM_S_MESSAGE inquire_msg;	/* inquire generator message	*/
    struct GRid Super_id;	/* super in reference file	*/

    struct GRref_instance_data *buffer;
    struct GRmd_env *env_ptr,md_env;
    struct  GRinquire_args_struct inquire_args;

    request = 0;
    *which_error = 0;
    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    if ( !GRexpansion_valid () ) goto wrapup;

    env_ptr = 0;

    for (i = 0; inquire_requests[i].var != END_REPORT_REQUEST; ++i)
    {
	switch (inquire_requests[i].var)
	{	
            case REFERENCE_FILE_DUPOSNAME:
            { 
                if (inquire_requests[i].num_requested >= sizeof(OM_p_DUPINTOS))
                {
                    om$os_name_to_number ( osname = me->osname,
                                           p_osnum = &osnum );

#ifdef DEBUG
{
char _int_name[80];

om$os_number_to_internal_name(osnum = osnum,osname = _int_name);

printf("OS number : %d\nOS name : %s\nInternal OS Name : %s\n",
        osnum, me->osname, _int_name );
}
#endif
                    *((OM_p_DUPINTOS *)inquire_requests[i].var_ptr) = 
                        ( om$inquire_os(osnum = osnum, pp_buf = &dupos_p) & 1) ?
                        dupos_p : NULL;
                }
		else			/* not enough space given	*/
		{
		    *msg = MSINARG;
		    *which_error = i;
		    inquire_requests[i].num_returned = 0;
		}
                break;
            }
            case REFERENCE_FILE_FOUND:
            {
		if (inquire_requests[i].num_requested >= sizeof(IGRboolean))
		{
                    if ( om$dimension_of (varray = me->osname) )
                    {
                        *((IGRboolean *)(inquire_requests[i].var_ptr)) = 
                        (IGRboolean) (om$os_name_to_number(osname = me->osname,
                                                       p_osnum = &osnum) & 1);

                    }
                    else
                    {
                        *(inquire_requests[i].var_ptr) = FALSE;
                    }

		    inquire_requests[i].num_returned = sizeof(IGRboolean);
		}
		else			/* not enough space given	*/
		{
		    *msg = MSINARG;
		    *which_error = i;
		    inquire_requests[i].num_returned = 0;
		}
                break;
            }
	    case REFERENCE_FILE_NAME:
	    {
		length = om$dimension_of(varray = me->filename);

		if (length)
		{
	    	    strncpy(inquire_requests[i].var_ptr,
                            me->filename,
                            inquire_requests[i].num_requested);
		}
		else
		{
	    	    inquire_requests[i].var_ptr[0] = '\0';
		}    
	  
		if ( length < inquire_requests[i].num_requested)	
	        {
	            inquire_requests[i].num_returned = length;
		}
		else
		{
   	            inquire_requests[i].num_returned =
		             inquire_requests[i].num_requested;
		}	

		break;
	    }
	    case SAVED_VIEW_NAME :
	    {
		length = om$dimension_of(varray = me->saved_view);

		if (length)
		{
	    	    strncpy(inquire_requests[i].var_ptr,
		       me->saved_view,inquire_requests[i].num_requested);
		}
		else
		{
	    	    inquire_requests[i].var_ptr[0] = '\0';
		}

		if ( length < inquire_requests[i].num_requested)	
	        {
	            inquire_requests[i].num_returned = length;
		}
		else
		{
   	            inquire_requests[i].num_returned =
		             inquire_requests[i].num_requested;
		}	

		break;

	    }

	    case FILE_ACCESS_PROTECTION :
	    {		
		if (inquire_requests[i].num_requested >= sizeof(IGRshort))
		{
		    *(inquire_requests[i].var_ptr) = (IGRchar)
			(me->ref_properties & GRIS_READ_ONLY ?
			   1 : 0);
		    inquire_requests[i].num_returned = sizeof(IGRshort);
		}
		else			/* not enough space given	*/
		{
		    *msg = MSINARG;
		    *which_error = i;
		    inquire_requests[i].num_returned = 0;
		}
		break;
	    }
	    case FILE_PROPERTIES :
	    {		
	        /** modified the "unsigned short *" field to "unsigned long *"
		    to take care of TR# 119424322 **/
		if (inquire_requests[i].num_requested >= sizeof(unsigned short))
		{
		    prop_ptr = (unsigned long *)inquire_requests[i].var_ptr;
		    *prop_ptr = me->ref_properties;
		}
		else			/* not enough space given	*/
		{
		    *msg = MSINARG;
		    *which_error = i;
		    inquire_requests[i].num_returned = 0;
		}
		break;
	    }

	    case REFERENCE_INSTANCE_DATA :
	    {	
		length = sizeof(struct GRref_instance_data);
		if (length <= inquire_requests[i].num_requested)
		{
		    inquire_requests[i].num_returned = length;   
		    buffer = (struct GRref_instance_data *)
			inquire_requests[i].var_ptr;
				/* special reference file properties	*/
		    buffer->ref_properties = me->ref_properties;
		    for (j=0; j<6 ; ++j)
		    {
			buffer->range[j] = me->range[j];
    			buffer->vw_volume[j] = me->vw_volume[j];
		    }
		    for (j=0; j<16; ++j)
		    {
			buffer->vw_rotation[j] = me->vw_rotation[j];
			buffer->ref_to_master_matrix[j] = 
				me->ref_to_master_matrix[j];
			buffer->master_to_ref_matrix[j] = 
				me->master_to_ref_matrix[j];
		    }
		    for (j=0; j<32; ++j)
		    {
			buffer->dp_levels[j] = me->dp_levels[j];
		    }
		    for (j=0; j<3; ++j)
		    {
			buffer->vw_origin[j] = me->vw_origin[j];
		    }
		    dimension = om$dimension_of(varray = me->description);
		    if (dimension)
		    {
	    	        strncpy(buffer->description,me->description,100);
		    }
		    dimension = om$dimension_of(varray = me->scale_factor);
		    if (dimension)
		    {
	    	        strncpy(buffer->scale,me->scale_factor,40);
		    }
		}	
		else
		{
		    *msg = MSINARG;
		    inquire_requests[i].num_returned = 0;   
		    *which_error = i;
	        }
		break;
	    }
	    case ENVIRONMENT_INFO:
	    {
		if (inquire_requests[i].num_requested >=
		    sizeof(struct GRmd_env))
		{
		    env_ptr = (struct GRmd_env *) inquire_requests[i].var_ptr;

		    OMmsg = om$send(
			msg = message GRreffile.GRgetenvironment
			    (&msg1,env,env_ptr),
			targetid = my_id);

		    if ( ! (1 & OMmsg))
		    {
			*msg = msg1;
			*which_error = i;
		    }
		    inquire_requests[i].num_returned = sizeof(struct GRmd_env);
		}
		else
		{
		    *msg = MSINARG;
		    *which_error = i;
		}
		break;
	    }
            case REFERENCE_ID:
            {
               struct GRid * grid_ptr;

		if (inquire_requests[i].num_requested >=
		    sizeof(struct GRid))
		{
                    grid_ptr = (struct GRid *)inquire_requests[i].var_ptr;

                    grid_ptr->objid = my_id;
                    grid_ptr->osnum = OM_Gw_current_OS;
                }
                break;
            }
            case REFERENCE_NAME:
            {
                if (inquire_requests[i].num_requested >= DI_PATH_MAX )
                {
                    OMmsg = om$send( msg = message GRvg.GRgetname
                                          ( &msg1, 
                                            inquire_requests[i].var_ptr ),
                                     targetid = my_id);
                    if ( ! (1 & OMmsg))
		    {
                        *msg = msg1;
                        *which_error = i;
			request = REFERENCE_NAME;
                    }
                }
                break;
            }
            case REFERENCE_TYPE:
            {
		if(inquire_requests[i].num_requested > 20)
                {
                  if(om$dimension_of(varray = me->osname))
                  {
                     if(access(me->osname,0))
                       strcpy(filename, me->filename);
                     else
                       strcpy(filename, me->osname);
                  }
                  else
                      strcpy(filename, me->filename);

	           GRis_writable(&msg1,me->filename,0,env->md_id.osnum); 
                   fet = (FILE *)fopen(filename, "r+" );
                   if((msg1 == MSSUCC) && (fet != 0))
                   {
                      fclose(fet);
                      if((me->ref_properties & GRRF_BACKGROUND) == GRRF_BACKGROUND)
                        if(env->md_id.osnum == EX_active_OS_num)
                          sprintf(inquire_requests[i].var_ptr,
                                "write");
		        else
                          sprintf(inquire_requests[i].var_ptr,"nodisplay");
                      else 
                        sprintf(inquire_requests[i].var_ptr,"write");
                   }
                   else
                   {
                      if(fet != 0)
                        fclose(fet);
                      if((me->ref_properties & GRRF_BACKGROUND) == GRRF_BACKGROUND)
                        if(env->md_id.osnum == EX_active_OS_num)
                          sprintf(inquire_requests[i].var_ptr,
                                "read");
		        else
                          sprintf(inquire_requests[i].var_ptr,"nodisplay");
                      else 
                        sprintf(inquire_requests[i].var_ptr,"read");
                   }
                }
                break;
            }
	    default:
	    {
		*msg = GRNOTIMPLEMENTED;
		*which_error = i;
		break;
	    }
	}
    }
    
    if (1 & *msg)
    {
	if (processor)
	{
	    nest_indicator = 0;
	    (*(processor->processor_function))(msg,inquire_requests,
		processor->info,&nest_indicator);
	}
	if (*pass_to_other_spaces)
	{
	    if (1 & (OMmsg = GRget_Super_info(&msg1,me->osname,
			&Super_id)))
	    {
	        OMmsg = om$make_chanselect(channame = "Super_rfmgr.mgr",
				p_chanselect = &chandef);

	        if (1 & (OMmsg = om$get_channel_count(
		    	   osnum = Super_id.osnum,
			   objid = Super_id.objid,
			   p_chanselect = &chandef,
			   count = &count)))
	    	{
	            if (count > 0)
	            {
            	    	if (1 & (OMmsg = 
		       		om$make_message(classname = "GRreffile",
                                     methodname = "GRinquireref",
                                     size = 
				sizeof(struct GRinquire_args_struct),
                                     p_arglist = &inquire_args,
                                     p_msg = &inquire_msg )))
	    	    	{
		  	    inquire_args.msg = msg;
			    inquire_args.env = &md_env;
		  	    inquire_args.inquire_requests = 
				inquire_requests;
	      		    inquire_args.which_error = which_error; 
			    inquire_args.pass_to_other_spaces =
				pass_to_other_spaces;
			    inquire_args.processor = processor;

			    if (env_ptr)/* already computed environment	*/
			    {
			    	md_env = *env_ptr;
			    }
		    	    else	/* compute environment		*/
			    {
		    	        OMmsg = om$send(
				    msg =message GRreffile.GRgetenvironment
					(msg,env,&md_env),
				    targetid = my_id);

			       	if (! (1 & OMmsg & *msg))
			      	{
				    goto wrapup;
				}
			    }

                            GRrefmode ( &msg1,
                                        &md_env.md_env.matrix_type, 
                                        md_env.md_env.matrix,
                                        &my_id, 
                                        &OM_Gw_current_OS,
                                        &reset );

                            if ( msg1 & 1 )
                            {
			        if (processor)
			        {
			       	    nest_indicator = 1;
	    	    	       	    (*(processor->processor_function))
				    	    (msg,NULL,
			    	             processor->info,&nest_indicator);
			        }

           		    	OMmsg = om$send(
                                        msg = message Super_rfmgr.Super_passon(
		        			&msg1,&inquire_msg),
		  	           	targetid = Super_id.objid,
		        	        targetos = Super_id.osnum);

                                if ( reset )
                                {
                                    reset = 1;
                                    GRset_expansion_mode(&reset);
                                }

                                if (processor)
	        		{
  	                            nest_indicator = 2;	
	                            (*(processor->processor_function))
				       	(msg,NULL,
				        processor->info,&nest_indicator);
        			}
                            }
		        }
		    }
	        }
		else
		{
		    OMmsg =  OM_S_SUCCESS;
		}
	    }
	    else
	    {
		OMmsg = OM_S_SUCCESS;
	    }
	}
    }
    else
    {
	if(request == REFERENCE_NAME)
		OMmsg = OM_W_ABORT;
	else
		OMmsg = OM_E_ABORT;
    }

wrapup:

    return(OMmsg);
}

end implementation GRreffile;
