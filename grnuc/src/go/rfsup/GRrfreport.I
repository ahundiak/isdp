/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    	GRreffile_reports - This is a generic reporting function for 
                reference files.
Synopsis

    IGRint GRreffile_reports ( msg, env, report_mask, report_info, pass )
        IGRlong * msg;                       MSSUCC/MSFAIL message
        struct GRmd_env * env;               module to begin reporting in
        unsigned IGRint report_mask;         info requested
        struct GRreport_info * report_info;  info needed by output function
        IGRboolean pass;                     pass to nested spaces ?

Description

    The report mask should be contructed by or'ing in the required 
    properties defined in refdef.h. The GRinquireref message will be 
    sent to each reference file in the module enviroment defined in 
    the env struct. If pass is set to true the GRinquireref message 
    will be sent to nested reference files. The report_info structure
    defined in ref.h contains an output function and a pointer 
    to any info needed by that output function. If provided 
    the output function will be called for every reference 
    file which receives the GRinquireref message. The arguments
    for this function are

        (*(report_info->output_function))(msg, num, depth, requests, fp)
            IGRint * msg;
            IGRint   num;    line number
            IGRint   depth;  nesting indicator
            struct GRinquire_list * requests;  ref info
            char *   info;  info used by output func

    If a GRreport_info structure is not provided a default output
    function will be called. This function GRreffile_report_output
    sends a report to standard out.

    If a GRreport_info structure is provided but the output func
    pointer is set to NULL, the info is assumed to be a pointer 
    to a file pointer. The default output function will be called
    and the output will be sent to the file instead of standard 
    out.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - invalid args passed in
Notes
    This is generalization of the Report_writ function developed by
    Ann Smitherman.

History
        jhw     08/05/89    Creation date.
        jhw     01/04/89    Added support for duplicate osname.
\*/

class implementation Root;

#include <grimport.h>
#include <stdio.h>
#include <OMminimum.h>
#include <OMindex.h>
#include <igrtypedef.h>
#include <igetypedef.h>
#include <igr.h>
#include <gr.h>
#include <msdef.h>
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <ref.h>
#include <refdef.h>
#include <DIdef.h>

%safe
static IGRint depth = 0;
static IGRint line = 0;
%endsafe

from Super_rfmgr import Super_passon;

IGRint GRreffile_reports ( msg, env, report_mask, report_info, pass )
    IGRlong * msg;
    struct GRmd_env * env;
    IGRuint report_mask;
    struct GRreport_info * report_info;
    IGRboolean pass;
{
    extern IGRint GRreffile_report();
    IGRint i = 0, nest;
    IGRlong msg1, sts;
    IGRchar ref_saved_view[40], ref_file_name[256], ref_name[DI_PATH_MAX];
    IGRchar reference_type[40];
    IGRlong ref_file_access;
    unsigned long ref_props;
    IGRboolean ref_file_found;
    IGRint which_error;
    OM_S_MESSAGE GRinquire_msg;
    struct GRref_instance_data ref_instance;
    struct GRmd_env ref_env;
    struct GRid ref_id;
    struct GRinquire_args_struct GRinquireref_args;
    struct GRid refmgr;
    struct GRinquire_list requests[11];
    struct GRinfo_processor processor;
    OM_p_DUPINTOS ref_file_dupos;

    depth = 0;
    line = 0;

    msg1 = MSSUCC;

    /*
     * Get the specified module's reference file manager id.
     */
    sts = ex$get_super ( mod_id = env->md_id.objid,
                         mod_osnum = env->md_id.osnum,
                         super_name = "Ref Mgr",
                         super_class = "Super_rfmgr",
                         create = 1,
                         super_id = &refmgr.objid,
                         super_osnum = &refmgr.osnum );

    if ( !(sts & 1) )
    {
        *msg = MSFAIL;
        goto quit;
    }

    /*
     * Fill in the request buffers.
     */
    if ( report_mask & GR_saved_view_name )
    {
        requests[i].var = SAVED_VIEW_NAME;
        requests[i].var_ptr = ref_saved_view;
        requests[i++].num_requested = 40;
    }

    if ( report_mask & GR_reference_file_name )
    {
        requests[i].var = REFERENCE_FILE_NAME;
        requests[i].var_ptr = ref_file_name;
        requests[i++].num_requested = 256;
    }

    if ( report_mask & GR_reference_instance_data )
    {
        requests[i].var = REFERENCE_INSTANCE_DATA;
        requests[i].var_ptr = (char *)&ref_instance;
        requests[i++].num_requested = sizeof(struct GRref_instance_data);
    }

    if ( report_mask & GR_file_access_protection )
    {
        requests[i].var = FILE_ACCESS_PROTECTION;
        requests[i].var_ptr = (char *)&ref_file_access;
        requests[i++].num_requested = sizeof(IGRint);
    }

    if ( report_mask & GR_file_properties )
    {
        requests[i].var = FILE_PROPERTIES;
        requests[i].var_ptr = (char *)&ref_props;
        requests[i++].num_requested = sizeof(unsigned short);
    }

    if ( report_mask & GR_environment_info )
    {
        requests[i].var = ENVIRONMENT_INFO;
        requests[i].var_ptr = (char *)&ref_env;
        requests[i++].num_requested = sizeof(struct GRmd_env);
    }

    if ( report_mask & GR_reference_id )
    {
        requests[i].var = REFERENCE_ID;
        requests[i].var_ptr = (char *)&ref_id;
        requests[i++].num_requested = sizeof(struct GRid);
    }

    if ( report_mask & GR_reference_name )
    {
        requests[i].var = REFERENCE_NAME;
        requests[i].var_ptr = ref_name;
        requests[i++].num_requested = DI_PATH_MAX;
    }

    if ( report_mask & GR_reference_file_found )
    {
        requests[i].var = REFERENCE_FILE_FOUND;
        requests[i].var_ptr = (char *)&ref_file_found;
        requests[i++].num_requested = sizeof(IGRboolean);
    }

    if ( report_mask & GR_reference_file_duposname )
    {
        requests[i].var = REFERENCE_FILE_DUPOSNAME;
        requests[i].var_ptr = (char *)&ref_file_dupos;
        requests[i++].num_requested = sizeof(OM_p_DUPINTOS);
    }
        
    if ( report_mask & GR_reference_type )
    {
        requests[i].var = REFERENCE_TYPE;
        requests[i].var_ptr = reference_type;
        requests[i++].num_requested = 40;
    }

    requests[i].var = END_REPORT_REQUEST;
    requests[i].var_ptr = NULL;
    requests[i].num_requested = 0;

    processor.processor_function = GRreffile_report;
    processor.info = (IGRchar *)report_info;

    GRinquireref_args.msg = msg;
    GRinquireref_args.env = env;
    GRinquireref_args.inquire_requests = requests;
    GRinquireref_args.which_error = &which_error;
    GRinquireref_args.pass_to_other_spaces = &pass;
    GRinquireref_args.processor = &processor;

    /*
     * Make an inquire reference file message.
     */
    sts = om$make_message ( classname = "GRreffile",
                            methodname = "GRinquireref",
                            size = sizeof ( struct GRinquire_args_struct ),
                            p_arglist = &GRinquireref_args,
                            p_msg = &GRinquire_msg );
    if ( !(sts & 1) ) 
    {
        *msg = MSFAIL;
        goto quit;
    }

    /*
     * Pass the GRinquireref message to all reference files
     * in this object space. The GRinquireref will take care of 
     * passing the message to nested spaces if requested.
     */
    sts = om$send ( msg = message Super_rfmgr.Super_passon
                                    ( &msg1,
                                      &GRinquire_msg ),
                    senderid = NULL_OBJID,
                    targetid = refmgr.objid,
                    targetos = refmgr.osnum );

    if ( !(sts & msg1 & 1) ) 
    {
        *msg = MSFAIL;
        goto quit;
    }

    /*
     * Reset the report function.
     */
    nest = END_FUNCTION;
    GRreffile_report(msg, NULL, NULL, &nest);

quit:

    return(*msg & 1);
}

IGRint GRreffile_report ( msg, requests, report_info, nest )
    IGRlong * msg;
    struct GRinquire_list * requests;
    struct GRreport_info * report_info;
    IGRint * nest;
{
    extern IGRint GRreffile_report_output();
    IGRint (*output_func)();
    IGRint i,flag;
    *msg = MSSUCC;
    i = 0;
    flag = 1;

    switch( *nest )
    {
    case BEGIN_TRANSITION :
        ++depth;
        break;

    case PROCESS_LEVEL :
        /*
         * Determine the report output function to call.
         * If there is not a report output function provided use
         * the default (output to stdout).
         *
         * NOTE: TWEAK!! If you provide a report info structure
         *       without a report output function the info is 
         *       assumed to be a pointer to a file pointer. This 
         *       can be used to output the reference file report
         *       to a file instead of standard out.
         */
        output_func = ( !report_info || !report_info->output_func ) ?
                      GRreffile_report_output : report_info->output_func;

        for(i = 0; requests[i].var != END_REPORT_REQUEST; ++i)
        {
	   if(requests[i].var == REFERENCE_TYPE )
	     flag = strcmp(requests[i].var_ptr,"nodisplay");
        }
    
        if(flag != 0)
        output_func( msg, 
                     line++, 
                     depth, 
                     requests, 
                     (report_info) ? report_info->info : NULL );

        break;

    case END_TRANSITION :
        --depth;
        break;

    case END_FUNCTION :
        depth = 0;
        line = 0;
        break;

    default :
        *msg = MSFAIL;
        break;
    } 

    return (1);
}

#define FILENAME "File Name  :"
#define SAVEVIEW "Saved View : "
#define INSTANCE "Instance Data : "
#define PROPS  "Properties Word : "
#define ENVIRONMENT "Environment Information : "
#define REFID "ID : "
#define REFNAME "Name : "
#define REFFILEFOUND "Reference File Found : "
#define REFFILEDUPOS "Reference File Duplicate Object Space Name : "

#define LINE_LEN 255

	#argsused
IGRint GRreffile_report_output ( msg, num, depth, requests, fp )
    IGRint * msg;
    IGRint num;
    IGRint depth;
    struct GRinquire_list * requests;
    FILE  **fp;
{
    IGRchar indent[5], printline[LINE_LEN + 1];
    register FILE * out_fp;
    register IGRint  i, j;
    if (requests)
    {
/*        out_fp = (*fp) ? *fp : stdout;*/
        if ( fp )
          out_fp = *fp;
        else  out_fp = stdout;
        for (i=0; i<depth; ++i) indent[i] = ' ';
	indent[i] = '\0';
 
        for (i=0; requests[i].var != END_REPORT_REQUEST; ++i)
        {
            printline[0] = '\0';

            switch (requests[i].var)
            {
            case REFERENCE_FILE_NAME :
            {
                strcpy(printline,indent);
                strncat(printline,FILENAME,LINE_LEN);
                strncat(printline,requests[i].var_ptr,LINE_LEN);
                fprintf(out_fp,"%s\n",printline);
                break;
            }
            case SAVED_VIEW_NAME :
            {
                strcpy(printline,indent);
                strncat(printline,SAVEVIEW,LINE_LEN);
                strncat(printline,requests[i].var_ptr,LINE_LEN);
		fprintf(out_fp,"%s\n",printline);
                break;
            }
            case REFERENCE_INSTANCE_DATA :
            {
                struct GRref_instance_data * buffer;

                strcpy(printline,indent);
                strncat(printline,INSTANCE,LINE_LEN);
                fprintf(out_fp,"%s\n",printline);

                buffer = (struct GRref_instance_data *) requests[i].var_ptr;

                strcpy(printline,indent);
                strncat(printline,"Reference Properties",LINE_LEN);
                fprintf(out_fp,"%s\n",printline);
                fprintf(out_fp,"%s %X\n",indent,buffer->ref_properties);

                strcpy(printline,indent);
                strncat(printline,"Range for Rtree Pass",LINE_LEN);
                fprintf(out_fp,"%s\n",printline);
                for (j=0; j<2; ++j)
                {
                    fprintf(out_fp,"%s%lf %lf %lf\n",
                           indent,
                           buffer->range[j*3],
                           buffer->range[j*3+1],
                           buffer->range[j*3+2]);
                }

                strcpy(printline,indent);
                strncat(printline,"View Volume",LINE_LEN);
                fprintf(out_fp,"%s\n",printline);
                for (j=0; j<2; ++j)
                {
                    fprintf(out_fp,"%s%lf %lf %lf\n",
                           indent,
                           buffer->vw_volume[j*3],
                           buffer->vw_volume[j*3+1],
                           buffer->vw_volume[j*3+2]);
                }

                strcpy(printline,indent);
                strncat(printline,"View Origin",LINE_LEN);
                fprintf(out_fp,"%s\n",printline);
                fprintf(out_fp,"%s%lf %lf %lf\n",
                        indent,
                        buffer->vw_origin[0],
                        buffer->vw_origin[1],
                        buffer->vw_origin[2]);

                strcpy(printline,indent);
                strncat(printline,"View Rotation",LINE_LEN);
                fprintf(out_fp,"%s\n",printline);
                for (j=0; j<4; ++j)
                {
                    fprintf(out_fp,"%s%lf %lf %lf %lf\n",
                           indent,
                           buffer->vw_rotation[j*4],
                           buffer->vw_rotation[j*4+1],
                           buffer->vw_rotation[j*4+2],
                           buffer->vw_rotation[j*4+3]);
                }

                strcpy(printline,indent);
                strncat(printline,"Reference to Master Matrix",LINE_LEN);
                fprintf(out_fp,"%s\n",printline);
                for (j=0; j<4; ++j)
                {
                    fprintf(out_fp,"%s%lf %lf %lf %lf\n",
                           indent,
                           buffer->ref_to_master_matrix[j*4],
                           buffer->ref_to_master_matrix[j*4+1],
                           buffer->ref_to_master_matrix[j*4+2],
                           buffer->ref_to_master_matrix[j*4+3]);
                }
                
                strcpy(printline,indent);
                strncat(printline,"Master to Reference Matrix",LINE_LEN);
                fprintf(out_fp,"%s\n",printline);
                for (j=0; j<4; ++j)
                {
                    fprintf(out_fp,"%s%lf %lf %lf %lf\n",
                           indent,
                           buffer->master_to_ref_matrix[j*4],
                           buffer->master_to_ref_matrix[j*4+1],
                           buffer->master_to_ref_matrix[j*4+2],
                           buffer->master_to_ref_matrix[j*4+3]);
                }

                strcpy(printline,indent);
                strncat(printline,"Levels for Attachment",LINE_LEN);
                fprintf(out_fp,"%s\n",printline);
                for (j=0; j<7; ++j)
                {
                    fprintf(out_fp,"%s%d %d %d %d %d\n",
                           indent,
                           buffer->dp_levels[j*5],
                           buffer->dp_levels[j*5+1],
                           buffer->dp_levels[j*5+2],
                           buffer->dp_levels[j*5+3],
                           buffer->dp_levels[j*5+4]);
                }
                break;
            }
            case ENVIRONMENT_INFO:
            {
                struct GRmd_env * env;

                strcpy(printline,indent);
                strncat(printline,ENVIRONMENT,LINE_LEN);
                fprintf(out_fp,"%s\n",printline);

                env = (struct GRmd_env *) requests[i].var_ptr;
                strcpy(printline,indent);
                strncat(printline,"Module Information",LINE_LEN);
                fprintf(out_fp,"%s\n",printline);

                fprintf(out_fp,"%s %s %d\n",indent,"Module id = ",env->md_id.objid);
                fprintf(out_fp,"%s %s %d\n",indent,"Object Space = ",env->md_id.osnum);

                strcpy(printline,indent);
                strncat(printline,"Transformation Information",LINE_LEN);
                fprintf(out_fp,"%s\n",printline);
                fprintf(out_fp,"%s %s %d\n",
                        indent, "Environment Matrix type = ",
                        env->md_env.matrix_type);

                strcpy(printline,indent);
                strncat(printline," Environment Matrix = ",LINE_LEN);
                fprintf(out_fp,"%s\n",printline);
                for (j=0; j<4; ++j)
                {
                    fprintf(out_fp,"%s%lf %lf %lf %lf\n",
                           indent,
                           env->md_env.matrix[j*4],
                           env->md_env.matrix[j*4+1],
                           env->md_env.matrix[j*4+2],
                           env->md_env.matrix[j*4+3]);
                }

                break;
            }
            case FILE_ACCESS_PROTECTION :
            {
                strcpy(printline,indent);
                if (*requests[i].var_ptr)
                {
                    strncat(printline,"The file is Read only",LINE_LEN);
                }
                else
                {
                    strncat(printline,"The file is Read/Write",LINE_LEN);
                }
                fprintf(out_fp,"%s\n",printline);

                break;
            }
            case FILE_PROPERTIES :
            {
                IGRushort prop_word;

                strcpy(printline,indent);
                strncat(printline,PROPS,LINE_LEN);
                prop_word = (unsigned short ) *requests[i].var_ptr;
                fprintf(out_fp,"%s  %X\n",printline,prop_word);
            
                break;
            }
            case REFERENCE_ID :
            {
                struct GRid * grid_ptr;

                strcpy(printline,indent);
                strncat(printline,REFID,LINE_LEN);
                grid_ptr = (struct GRid *)requests[i].var_ptr;
                fprintf ( out_fp,
                          "%s %s = %d, %s = %d\n",
                          printline,
                          "objid", grid_ptr->objid,
                          "osnum", grid_ptr->osnum );
                break;
            }
            case REFERENCE_NAME :
            {
                strcpy(printline,indent);
                strncat(printline,REFNAME,LINE_LEN);
                fprintf ( out_fp, "%s %s\n", printline, requests[i].var_ptr );
                break;
            }
            case REFERENCE_FILE_FOUND :
            {
                strcpy(printline,indent);
                strncat(printline,REFFILEFOUND,LINE_LEN);
                fprintf ( out_fp, "%s %s\n", printline, 
                          (*requests[i].var_ptr) ? "TRUE" : "FALSE" );
                break;
            }
            case REFERENCE_FILE_DUPOSNAME :
            {
                strcpy(printline,indent);
                strncat(printline,REFFILEDUPOS,LINE_LEN);
                fprintf ( out_fp, "%s %s\n", printline, 
                          (*requests[i].var_ptr) ? "TRUE" : "FALSE" );
                break;
            }
            default :
            {
                strcpy(printline,indent);
                strncat(printline,"Error - invalid request.",LINE_LEN);
                fprintf(out_fp,"%s\n",printline);
                break;
            }
            }
        }
    }
    else *msg = MSINARG;
    return(1 & *msg);
}
 
end implementation Root;

