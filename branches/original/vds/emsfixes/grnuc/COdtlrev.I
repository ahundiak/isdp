/* #######################    APOGEE COMPILED   ######################## */
class implementation COdetail;

#include <coimport.h>
#include <stdio.h>
#include <FI.h>
#include <refdef.h>
#include <ref.h>
#include <grgsmacros.h>
#include <DIdef.h>
#include <DItypedef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <DImacros.h>
#include <OMlimits.h>
#include <exmacros.h>
#include <grmessage.h>

from GRdrawview   import   GRcomponent_pass, GRget_drawview_description,
                           GRget_drawview_scale, GRget_drawview_label,
                           GRget_alignment_count, GRget_alignment_objects;
from GRdvattach   import   GRget_drawing_view_id;
from GRgrset      import   GSstart_transition, GSend_transition;
from GRvg         import   GRgetname;
from GRvg         import   GRgetsymb;
from Super_rfmgr  import   GRget_channel_count;
from GRgraphics   import   GRgetprops;

extern IGRint     GRgs_locate_action();

static void write_reffiles(Form form, IGRint gadget);

/*
 * The following routines handle the nested list of reference
 * file nodes.
 * These routines are to be used when the review reference file
 * form can be written to in 2.0.0.
 */


/*
 * add_data : adds a list of data to the specified node.
 */
/*
%safe
static char * add_data (node, data, size)
    struct ref_node * node;
    char ** data;
    int size;
{
    register int i, len;
    register char * p;

    for (i=0, len=0; i<size; ++i) len += strlen(data) + 1; 
    ++len;

    if (node->data = (char *)malloc (len))
    {
        p = node->data;
        for (i=0; i<size; ++i) 
        {
            len = strlen(data[i]) + 1;
            memcpy(p, data[i], len);
            p += len;
        }
        *p = EOD;
    }

    return(node->data);
}
*/
/*
 * return_item : returns the item'th data from the 
 *               specified node.
 */
/*
static char * return_item (node, item)
    struct ref_node * node;
    int                item;
{
    register char * p;
    register int i;

    if (p = node->data)
    {
        for (i=0; i<item; i++)
        {
            if (*p==EOD) return(0);
            while (*p++);
        }
    }

    return(p);
}
*/
/*
 * add_node : adds a node to the end of the specified
 *            list.
 */
/*
static struct ref_node * add_node (list, depth)
    struct ref_node ** list;
    int    depth;
{
    register struct ref_node * np, *p;

    np = (struct ref_node *)malloc ( sizeof(struct ref_node) );
    np->next = NULL;

    if (p = list)
    {
        while ( p->next ) p = p->next;
        p->next = np;
    }
    else *list = np;
                
    np->depth = depth;
    np->data = NULL;

    return (np);   
}
*/
/*
 * del_list : deletes a list of nodes.
 */
/*
static char * del_list (list)
    char * list;
{
    register struct ref_node * p, * np;

    p = list;

    while (p)
    {
        np = p->next;
        free(p->data);
        free(p);
        p = np;
    }
    
    return (1);
}
%endsafe
*/

#argsused
extern int COrevref_output ( msg, num, depth, requests, info )
    IGRint * msg;
    IGRint num;
    IGRint depth;
    struct GRinquire_list * requests;
    struct COform_info * info;
{
 /*   struct nest_node * cn; */
    IGRchar *data[10], line[BUFSIZ], name[DI_PATH_MAX];
    IGRchar internal_name[OM_K_MAXINTOSNAME_LEN],msgbuff[200];
    IGRint col, req;
    OM_p_DUPINTOS   dup;
    struct GRid ref_id;
    IGRulong *ref_properties;
    IGRlong sts,msg1;
    IGRshort disp_props;
    IGRchar onbuff[DI_PATH_MAX];
    IGRchar offbuff[DI_PATH_MAX];

    /* New stuff for layer */
    struct GRsymbology symb;
    IGRchar layer[8];
    
    disp_props = 0;
    sts = OM_S_SUCCESS;
    msg1 = OM_S_SUCCESS;
    /*  
     * Blank out the data incase one of the requests
     * fails.
     */
    for (col=0; col<9; ++col) data[col] = "";

    ex$message(msgnumb = GR_I_On, buff = onbuff);
    ex$message(msgnumb = GR_I_Off, buff = offbuff);
    /*
     * Set up the data pointers. 
     * 
     * Attach Name, Type, File Name, Description, Saved View, Scale
     */
    for (req=0; req<9; ++req)
    {
        switch (requests[req].var)
        {
        case REFERENCE_FILE_FOUND:
            data[0] = (*(( IGRboolean *) requests[req].var_ptr)) ? "" : "*";
            break;
        case REFERENCE_FILE_DUPOSNAME:
            /* 
             * If there is a duplicate.
             */
            if ( *(requests[req].var_ptr) ) 
            {
                dup = *((OM_p_DUPINTOS *)requests[req].var_ptr);

                /*
                 * Get the internal os name.
                 */
                om$os_number_to_internal_name ( osnum = dup->osnum,
                                                osname = internal_name );
                /*
                 * If the internal os name is different from the
                 * original internal osname.
                 */
                if ( strcmp(internal_name, dup->orig_intname) )
                {
                    data[0] = "**";
                }
            }
            break;
        case REFERENCE_NAME:
            di$split ( pathname = requests[req].var_ptr,
                       name = name );
            sprintf(line,
                    "%*s",
                    strlen(name) + depth,
                    name);
            data[1] = line;
            break;
        case REFERENCE_TYPE:
             if(!strcmp(requests[req].var_ptr,"write"))
               data[2] = onbuff;
             else
               data[2] = offbuff;
             break;
        case FILE_PROPERTIES:
             ref_properties = (IGRulong *)(requests[req].var_ptr);
             if(*ref_properties & GRRF_BACKGROUND)
               data[3] = offbuff;
             else
               data[3] = onbuff;
             if(*ref_properties & GRRF_SHRINK_WRAP)
               data[4] = offbuff;
             else
               data[4] = onbuff;
             break;
        case REFERENCE_ID:
             ref_id.objid = ((struct GRid *)(requests[req].var_ptr))->objid;
             ref_id.osnum = ((struct GRid *)(requests[req].var_ptr))->osnum;

             sts = om$send(msg = message GRgraphics.GRgetprops(&msg1,
                                                         &disp_props),
                           senderid = NULL_OBJID,
                           targetid = ref_id.objid,
                           targetos = ref_id.osnum);

             if(disp_props & GRIS_DISPLAYABLE)
               data[5] = onbuff;
             else
               data[5] = offbuff;

	     /* ----------------------------------
	      * 30 Nov 2001 
	      * Also store the attached layer
	      */
	     symb.level = 9999;
             sts = om$send(msg = message GRvg.GRgetsymb(&msg1,&symb),
                           senderid = NULL_OBJID,
                           targetid = ref_id.objid,
                           targetos = ref_id.osnum);
	     sprintf(layer,"%d",symb.level);
	     data[9] = layer;
             break;
        case REFERENCE_FILE_NAME:
            data[6] = requests[req].var_ptr; 
            break;
        case SAVED_VIEW_NAME:
            data[7] = requests[req].var_ptr; 
            break;
        case REFERENCE_INSTANCE_DATA:
            data[8] = ((struct GRref_instance_data *)
                       (requests[req].var_ptr))->scale;
            break;
        }
     }
/*            
    if (*(info->list)) 
    {
        cn = add_node(*(info->list),depth);
    }
    else 
    {
        *(info->list) = cn = add_node(NULL,depth);
    }
    add_data(cn, data, 5);
*/

    /*
     * If this depth is displayed.
     */
    if (depth <= info->depth)
    {
        /*
         * Display the rows.
         */
        for (col=0; col<10; ++col)
        {
            FIfld_set_text (info->form,
                            info->label,
                            info->row,
                            col,
                            data[col],
                            0);
        }

        /*
         * If there was a problem with the attachment display the 
         * appropriate error message.
         */
        if ( *data[0] != '\0' )
        {
            /*
             * If the file was not found or max_modules exceeded.
             */
            if ( !strcmp(data[0], "*") )
            {
                ex$message(msgnumb = GR_I_RefAttWithNoFile,
                           buff = msgbuff);

                FIfld_set_text (info->form,
                                CO_msg,
                                0, 0,
				msgbuff,
                                0);
            }
            /*
             * Else there is a duplicate osname.
             */
            else 
            {
                ex$message(msgnumb = GR_I_AttWithInvIntFileID,
                           buff = msgbuff);

                FIfld_set_text (info->form,
                                CO_msg,
                                1, 0,
				msgbuff,
                                0);
            }
        }

        /*
         * Update the next row.
         */
        ++(info->row);
    }

    return(1);
}


#argsused
int COdetail_review_notify (form_label, gadget_label, value, form_ptr)
    int     form_label;
    int     gadget_label;
    double  value;
    Form    form_ptr;
{
    if ( gadget_label == FI_ACCEPT ) FIf_delete (form_ptr);
    return (1);
}

method review_notify ( int form_label; 
                       int gadget_label; 
                       double value; 
                       char * form_ptr )
{
    IGRlong  msg = MSSUCC;

    switch ( gadget_label )
    {
    case FI_CVT_TO_PERM_WIN:
        /*
         * Make the form permanent.
         */
        FIf_set_notification_routine ( form_ptr,
                                       COdetail_review_notify );
        /*
         * Make COB think there are no forms to free on delete.
         * Making the form persistent will not work since I do
         * not want the form to come up if there are no reffiles or
         * drawing views to display. A persistent form automatically
         * comes up.
         */
        me->number_of_forms = 0;

    case FI_ACCEPT:     

        /*
         * Push a form finished on the queue.
         */
        {
        IGRint           rsp; 
        IGRlong          siz;
        struct EX_button btn;

        rsp = FORM_FINISHED;
        siz = sizeof(struct EX_button);

        ex$putque(msg = &msg,
                  response = &rsp,
                  byte = &siz,
                  buffer = (IGRchar *)&btn);
        if ( gadget_label == FI_ACCEPT )
          FIf_erase( form_ptr );
        }
        break;

      case 22:
	write_reffiles(form_ptr,12);
	break;
    }
    
    return (OM_S_SUCCESS);
}

method review_elements_exist ()
{
    IGRlong     om_msg;
    IGRlong     ret_msg;

    om_msg = OM_S_SUCCESS;
    ret_msg = me->ret = MSSUCC;

    if ( me->mytype == CO_drawsheet )
    {
        IGRint num = 0;

        ret_msg = MSFAIL;
        om_msg = gr$get_num_sheets( msg = &ret_msg,
                                    num_sheets = &num );

        if ( !(ret_msg & om_msg & 1) || !num ) me->ret = MSFAIL;
    }
    else if ( me->mytype == CO_revref )
    {
        OM_S_OBJID super_objid = NULL_OBJID;
	OMuword super_osnum;
        IGRulong properties;
        IGRshort nested;
        IGRlong  count;

        properties = nested = count = 0;
        /*
         * See if there are any reference files on the 
         * reference file manager's to_context channel.
         */ 
        ex$get_super ( mod_id = me->ModuleInfo.md_id.objid,
                       mod_osnum = me->ModuleInfo.md_id.osnum,
                       super_name = "Ref Mgr",
                       super_class = "Super_rfmgr",
                       super_id = &super_objid,
                       super_osnum = &super_osnum );

        if ( super_objid != NULL_OBJID )
        {
            om_msg = om$send ( msg = message Super_rfmgr.GRget_channel_count
                                                            ( &me->ret,
                                                              &properties,
                                                              &nested,
                                                              &count ),
                               targetid = super_objid,
                               targetos = super_osnum );
        }    

        if ( !count || !(om_msg & me->ret & 1) ) me->ret = MSFAIL;

    }
    else if ( me->mytype == CO_revdv )
    {
        IGRlong                 count;
        IGRint                  properties;
        GRclassid               classid;
        OM_S_CLASSLIST          locate_eligible;
        struct GRlc_locate      attributes;
        struct GRlc_classes     classinfo;
        struct EX_button        button;
        struct GRid             args[2];
        struct GRid             sv_id;
        struct GRid             temp_id;

        /*
         *  Create a graphics set and connect it to the located
         *  graphics channel.
         */
        temp_id.osnum = me->ModuleInfo.md_id.osnum;
        om_msg = gr$gsinit ( msg = &ret_msg, 
                             flag = 2, 
                             p_objid = &temp_id.objid,
                             osnum = me->ModuleInfo.md_id.osnum,  
                             p_chanselect = &me->located_chansel);
        
        /*
         *  Start a transition for the graphics set. 
         */
        properties = 0;
        om_msg = om$send ( msg = message GRgrset.GSstart_transition 
                                                ( &ret_msg, 
                                                  &me->ModuleInfo, 
                                                  &properties, 
                                                  NULL, 
                                                  &sv_id ),
                          targetid = temp_id.objid,
                          targetos = temp_id.osnum);
    
        /*
         *  Build the attributes structure.
         */
        attributes.owner_action =  LC_FLEX_COMP;
        attributes.properties = IGN_RW_BIT  |
                                IGN_DP_BIT  |
                                IGN_MOD_BIT |
                                IGN_PLANAR_BIT;

        /*
         *  Build class list.
         */
        om_msg = om$get_classid ( classname = "GRdrawview",
                                  p_classid = &classid );
        locate_eligible.w_count = 1;
        locate_eligible.w_flags = 0;
        locate_eligible.p_classes = &classid;
        classinfo.rtree_classes = NULL;
        classinfo.eligible_classes = &locate_eligible;
        button.objid = NULL_OBJID;
        button.osnum = me->ModuleInfo.md_id.osnum;
    
        /*
         *  Query all objects looking for drawing views.
         */
        args[0] = temp_id;
        args[1] = sv_id;
        om_msg = GRgsquery_all ( &ret_msg, 
                                 &me->ModuleInfo, 
                                 &attributes, 
                                 &classinfo, 
                                 NULL, 
                                 &button, 
                                 GRgs_locate_action, 
                                 args );
        /*
         *  Send the GSend_transition message.
         */
        om_msg = om$send ( msg = message GRgrset.GSend_transition ( &ret_msg, 
                                                                    NULL ),
                           targetid = temp_id.objid,
                           targetos = temp_id.osnum);

        count = 0;
        om_msg = gr$gsinqcount ( msg = &ret_msg, 
                                 count = &count,
                                 p_chanselect = &me->located_chansel );
    
        if ( !(om_msg & ret_msg & 1) || !count ) me->ret = MSFAIL;
    }   

    return (OM_S_SUCCESS);
}

method review_set_gadgets ()
{
    IGRlong                 om_msg;
    IGRlong                 ret_msg;
    
    if ( me->mytype == CO_revref )
    {
        struct COform_info      form_info;
        struct GRreport_info    review_info;
        me->ret = MSSUCC;
        
        /*
         * Fill in the reference file nest list.
         */
        /* me->review_list = NULL; */
        form_info.form = me->forms[0].form_ptr;
        form_info.label = CO_mcf;
        form_info.depth = 50;
        form_info.row = 0;
        form_info.list = NULL; /* &me->review_list; */
        review_info.output_func = COrevref_output;
        review_info.info = (IGRchar *)&form_info;

        GRreffile_reports ( &me->ret,
                            &me->ModuleInfo,
                            GR_reference_file_duposname | 
                            GR_reference_file_found | 
                            GR_reference_name | GR_reference_file_name | 
                            GR_reference_instance_data | GR_saved_view_name |
                            GR_reference_type | GR_file_properties |
                            GR_reference_id,
                            &review_info,
                            TRUE );
    }
    else if ( me->mytype == CO_revdv )
    {
        IGRlong                 count;
        IGRboolean              zero = FALSE;
        IGRlong                 i,j,k,col;
        IGRint                  temp;
        IGRint                  align_count;
        IGRint                  number;
        IGRint                  array_size;
        IGRchar *               data[3];
        IGRchar *               processed = NULL;
        struct GRobj_env *      objects = NULL;
        struct GRid *           align_objects = NULL;
        IGRchar                 buffer[BUFSIZ];
        IGRchar                 name[BUFSIZ];
        IGRchar                 desc[BUFSIZ];
        IGRchar                 scale[BUFSIZ];
        IGRchar                 saved_view[BUFSIZ];   
        IGRchar                 orientation[BUFSIZ];   
        GRname                  element_name;   
        OM_S_MESSAGE            inq_msg;
        struct GRinquire_list   list[3];
        struct
        {
            IGRlong                 *msg;
            struct GRmd_env         *env;
            struct GRinquire_list   *inquire_requests;
            IGRint                  *which_error; 
            IGRboolean              *pass_to_other_spaces;
            struct GRinfo_processor *processor;
        } GRreffile_temp;

        number = 0;

        /* 
         * Find out how many drawing views there are.
         */    
        count = 0;
        om_msg = gr$gsinqcount ( msg = &ret_msg, 
                                 count = &count,
                                 p_chanselect = &me->located_chansel );
    
        array_size = count * sizeof(struct GRobj_env);
        objects = (struct GRobj_env *) om$malloc ( size = array_size );
   
        om_msg = gr$gsget_objects ( msg = &ret_msg, 
                                    array = objects,
                                    size = array_size, 
                                    count = &count, 
                                    p_chanselect = &me->located_chansel );

        processed = (IGRchar *)om$malloc (size = count);

        for (i=0; i < count; ++i) processed[i] = FALSE;

        if (om_msg & 1)
        {      
            list[0].var = REFERENCE_FILE_NAME;
            list[0].var_ptr = name;
            list[0].num_requested = BUFSIZ;

            list[1].var = SAVED_VIEW_NAME;
            list[1].var_ptr = saved_view;
            list[1].num_requested = BUFSIZ;

            list[2].var = END_PARAM;
            list[2].var_ptr = NULL;
            list[2].num_requested = NULL;
         
            GRreffile_temp.msg = &ret_msg;
            GRreffile_temp.env = &objects[i].mod_env;
            GRreffile_temp.inquire_requests = list;
            GRreffile_temp.which_error = &temp; 
            GRreffile_temp.pass_to_other_spaces = &zero;
            GRreffile_temp.processor = NULL;

            om_msg = om$make_message ( classname = "GRreffile",
                                       methodname = "GRinquireref", 
                                       size = sizeof(GRreffile_temp),
                                       p_arglist = &GRreffile_temp, 
                                       p_msg = &inq_msg );
    
            /*
             * For all drawing views.
             */
            for (i=0; i < count; ++i)
            {
                /*
                 * If the drawing view has not been processed 
                 * already get the into.
                 *
                 * NOTE: This drawing view may have been processed
                 * by being aligned with a previously processed dv.
                 */
                if (!processed[i])
                {   
                    ex$message(msgnumb = GR_I_NoAtc, buff = name);
                    ex$message(msgnumb = GR_I_NoSavVw, buff = saved_view);
                    scale[0] = '\0';
    
                    align_count = 0;
                    om_msg = om$send ( 
                            msg = message GRdrawview.GRget_alignment_count
                                                        ( &ret_msg, 
                                                          &align_count ),
                            targetos = objects[i].obj_id.osnum,
                            targetid = objects[i].obj_id.objid );
    
                    align_objects = (struct GRid *) om$malloc 
                                ( size = align_count * sizeof(struct GRid) );

                    temp = align_count;
                    align_count = 0;
                    om_msg = om$send (
                            msg = message GRdrawview.GRget_alignment_objects
                                                        ( &ret_msg, 
                                                          temp, 
                                                          &align_count,
                                                          align_objects ),
                            targetos = objects[i].obj_id.osnum,
                            targetid = objects[i].obj_id.objid);
    

                    om_msg = om$send (
                            msg = message GRdrawview.GRcomponent_pass
                                                        ( &ret_msg,
                                                          &inq_msg, 
                                                          GR_DV_REFFILE ),
                            targetos = objects[i].obj_id.osnum,
                            targetid = objects[i].obj_id.objid);

                    om_msg = om$send (
                            msg = message GRdrawview.GRget_drawview_scale
                                                       ( &ret_msg, 
                                                         &objects[i].mod_env, 
                                                         scale, 
                                                         NULL ),
                            targetos = objects[i].obj_id.osnum,
                            targetid = objects[i].obj_id.objid);
    
                    if (om_msg & 1)
                    {
                        /*
                         * Update the form for this drawing view.
                         */
                        data[0] = name;
                        data[1] = saved_view;
                        data[2] = scale;

                        for (col=0; col<3; ++col)
                        {
                            FIfld_set_text (me->forms[0].form_ptr,
                                            CO_mcf,
                                            number,
                                            col,
                                            data[col],
                                            0);
                        }
                        number++;
                    }    
                    
                    for (j=0; j < align_count; ++j)
                    {
                        for (k=0; k < count; ++k)
                        {
                            if ((!processed[k]) &&
                                (align_objects[j].objid ==
                                 objects[k].obj_id.objid) &&
                                (align_objects[j].osnum ==
                                 objects[k].obj_id.osnum))
                            {
                                processed[k] = TRUE;
                                break;
                            }
                        }

                        element_name[0] = '\0';
                        orientation[0] = '\0';
                        desc[0] = '\0';

                        om_msg = om$send (
                            msg = message GRdrawview.GRget_drawview_description
                                                    (&ret_msg, desc),
                                  targetos = align_objects[j].osnum,
                                  targetid = align_objects[j].objid);

                        om_msg = om$send (
                            msg = message GRdrawview.GRget_drawview_label
                                                    (&ret_msg, orientation),
                                  targetos = align_objects[j].osnum,
                                  targetid = align_objects[j].objid);

                        om$send ( msg = message GRvg.GRgetname
                                                    (&ret_msg, element_name),
                                  targetos = align_objects[j].osnum,
                                  targetid = align_objects[j].objid);

                        if (om_msg & 1)
                        {
                            /*
                             * Update the form.
                             */
                            if (element_name[0] == '\0') 
                            {
                                sprintf(element_name,
                                        "  No Name (%s)",
                                        orientation);
                            }
                            else 
                            {
                                di$cvt_name_for_output ( s_path = element_name,
                                                         u_path = buffer );
                                sprintf(element_name,
                                        "  %s",
                                        buffer);
                            }

                            strcpy(buffer, desc);
                            sprintf(desc,
                                    "  %s",
                                    buffer);

                            data[0] = "  ";
                            data[1] = element_name;
                            data[2] = desc;

                            for (col=0; col<3; ++col)
                            {
                                FIfld_set_text (me->forms[0].form_ptr,
                                                CO_mcf,
                                                number,
                                                col,
                                                data[col],
                                                0);
                            }
                            number++;
                        }         
                    } /* End of for loop for all aligned dvs */
                }
            } /* End of for looop for all dvs */
        }

        gr$gsempty ( msg = &ret_msg, 
                     p_chanselect = &me->located_chansel );

        /*
         * Free all buffers.
         */
        if (processed)      om$dealloc ( ptr = processed );
        if (objects)        om$dealloc ( ptr = objects );
        if (align_objects)  om$dealloc ( ptr = align_objects );
    }   

    return (OM_S_SUCCESS);

}

/* -----------------------------------------------
 * Just a quick and dirty way to dump a ref file list
 */
static void write_reffiles(Form form, IGRint gadget)
{
  FILE *file = NULL;
  
  IGRint row,rows;
  IGRchar buf[256];
  IGRchar fileName[128];
  
  // Open the file
  VDfrmGetgText(form,23,fileName);
  if (*fileName) file = fopen(fileName,"wt");
  else {
    file = stdout;
    strcpy(fileName,"stdout");
  }  
  if (file == NULL) {
    sprintf(buf,"Could not open %s for writing",fileName);
    VDfrmSetgText(buf);
    goto wrapup;
  }
  
  // The header
  fprintf(file,"%-1s %-20s %-4s %-4s %-4s %-4s %-20s %-12s %-5s %-5s\n",
	  "",
	  "ATTACHMENT NAME",
	  "UPD",
	  "NEST",
	  "CLIP",
	  "DISP",
	  "FILE NAME",
	  "SAVED VIEW",
	  "SCALE",
	  "LAYER");
  
  // Cycle through the list
  VDfrmGetNumRows(form,gadget,&rows,NULL,NULL);
  for(row = 0; row < rows; row++) {
    
    VDfrmGetfText(form,gadget,row,0,buf);
    fprintf(file,"%-1s ",buf);

    VDfrmGetfText(form,gadget,row,1,buf);
    fprintf(file,"%-20s ",buf);
    
    VDfrmGetfText(form,gadget,row,2,buf);
    fprintf(file,"%-4s ",buf);
    
    VDfrmGetfText(form,gadget,row,3,buf);
    fprintf(file,"%-4s ",buf);
    
    VDfrmGetfText(form,gadget,row,4,buf);
    fprintf(file,"%-4s ",buf);
    
    VDfrmGetfText(form,gadget,row,5,buf);
    fprintf(file,"%-4s ",buf);
    
    VDfrmGetfText(form,gadget,row,6,buf);
    fprintf(file,"%-20s ",buf);
    
    VDfrmGetfText(form,gadget,row,7,buf);
    fprintf(file,"%-12s ",buf);
    
    VDfrmGetfText(form,gadget,row,8,buf);
    fprintf(file,"%-5s ",buf);
    
    VDfrmGetfText(form,gadget,row,9,buf);
    fprintf(file,"%-5s\n",buf);
    
  }
  sprintf(buf,"Wrote %d rows to %s",rows,fileName);
  VDfrmSetgText(form,10,buf);
  
 wrapup:
  if (file && file != stdout) fclose(file);
  
  return;
}

end implementation COdetail;
