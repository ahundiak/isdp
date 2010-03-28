/*
Name
        GUprocessplot

Description
        This function is called from the GRfunction method during an Rtree
        pass to translate objects into IGDS picture-equivalents, with the
        intention of plotting the resulting IGDS design file.

History
        mrm     02/19/92    fixed problem with level mapping
        dhm     04/14/92    added the MSSUCC check after the
                            no_special_processing GRclip was called.
        satya   05/12/94    Fixed problem with GRclip method being called
                            for GRdvcs object, which is a rejected method.

*/

class implementation GRvg;

#include "grimport.h"
#include "grerr.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msdef.h"

#include "transdef.h"
#include "translate.h"

from GRreffile import GRplotpass;

extern OMuword OPP_GRreffile_class_id;

extern OMuword OPP_GRdvcs_class_id;

static  IGRchar *func_info_ptr;

IGRint GUprocessplot ( msg, graphics_object, func_info)

IGRlong			*msg;
struct GRid		*graphics_object;
IGRchar			*func_info;
{
    IGRboolean		no_special_processing;

    IGRshort		properties, nprisms, level;

    IGRlong		OMmsg,
			msg1,
			clip_flags;

    IGRint		i,j,k,
			beg_clip_count,
			non_clipped_index,
			prev_clipped_index,
			index1,
			index2,
			next_slot,
    			non_clipped_pieces_indexes[100],
			index_array_size,
			*index_ptr,
			*index_ptr1;
    unsigned int        pre_clip_count, post_clip_count, count;
			
    GRclassid		classid;
    OM_S_CHANSELECT	owner_chan;
    struct GRfunction_info  *function_info;
    struct GRsymbology	symbology;
    struct GUplot_element_args *plot_args;
    struct GUplot_user_info *my_info;
    struct GRmd_env	cons_env;
    struct GRid 	owner_id;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    func_info_ptr = func_info;
    function_info = (struct GRfunction_info *) func_info;
    my_info = (struct GUplot_user_info *) (function_info->info);
    plot_args = (struct GUplot_element_args *)
		    (my_info->plot_msg->p_arglist);

    MAidmx(msg,cons_env.md_env.matrix);
    cons_env.md_env.matrix_type = MAIDMX;
    cons_env.md_id.objid =  NULL_OBJID;
    cons_env.md_id.osnum = plot_args->id_info[1].osnum;

    index_ptr = non_clipped_pieces_indexes;
    index_array_size = 99;
    non_clipped_index = 0;
    prev_clipped_index = 0;

    clip_flags = GR_CLIP_NODEL | GR_CLIP_FLEXCONN | GR_CLIP_OVL_IN | GR_CLIP_FORPLOT;
    /*
     * determine if the object is displayable and if the level
     * is on before processing.
     */
	
    OMmsg = om$send (
	msg = message GRvg.GRgetsymb(msg, &symbology),
	senderid = graphics_object->objid,
	targetid = graphics_object->objid,
	targetos = graphics_object->osnum );

    if ( 1 & OMmsg & *msg)
    {
        /*
            Pick up any alternate display symbology.  Save and restore the
            level; otherwise eligible elements may be disqualified by the
            EMS->IGDS level mapping, which has already taken place in the info
            returned by GUget_symb_level.  For instance, if layer 2 is off,
            then elements on layer 191, which wraps to 2 by default, would
            incorrectly get kicked out here.
        */

        level = symbology.level;
        GUget_symb_level(msg, &symbology);
        symbology.level = level;

        om$send ( 
	   msg = message GRvg.GRgetprops ( msg, &properties ),
	   senderid = graphics_object->objid,
	   targetid = graphics_object->objid,
	   targetos = graphics_object->osnum );

    	if ( ! ( (properties & GRIS_DISPLAYABLE)  &&
	          DPlevel_check ( symbology.level, my_info->levels) ) ) 
	{
	    /* the object is not displayable or the level is not on
	     */

	    OMmsg = OM_S_SUCCESS;
	    *msg = MSSUCC;
	    goto wrapup;		
	}
    }

    /* if the object being processed is a reference file
     * object, no special processing is needed, go ahead
     * and send the GRplotyourself message.
     */

    OMmsg = om$get_classid(osnum = graphics_object->osnum,
                           objid = graphics_object->objid,
                           p_classid = &classid);

    OMmsg = om$is_ancestry_valid(subclassid = classid,
                                 superclassid = OPP_GRreffile_class_id);

    if ( OMmsg == OM_S_SUCCESS )
    {
	/* the object is a reference file object. Send the reference
	 * file object a special plot message.
	 */

     	OMmsg = om$send (
		msg =  message GRreffile.GRplotpass
			(msg,my_info->plot_msg,my_info->levels,
			 my_info->prism_array,&my_info->num_prisms,
			 my_info->filter_function, my_info->filter_data),
		senderid = graphics_object->objid,
		targetid = graphics_object->objid,
		targetos = graphics_object->osnum);

	goto wrapup;
    }
    else
    {
	OMmsg =  OM_S_SUCCESS;
    }

    /* check whether the caller really wants this element plotted */
	
    if (my_info->filter_function)
    {
        *msg = my_info->filter_function(graphics_object, plot_args->md_env, /*&cons_env,*/
                                        properties, &symbology,
                                        my_info->filter_data);
        if (*msg == GU_SKIP_ELEMENT)
        {
            *msg = MSSUCC;
            goto wrapup;
        }
        else if ((*msg == GU_TERMINATE_PLOT) || (*msg != GU_PROCESS_ELEMENT))
        {
            *msg = MSFAIL;
            return(OM_E_ERROR);
        }
    }

#ifndef IDRAW

    if ( 1 & OMmsg & *msg)
    {
	/* Tell the object to prepare for plotting.  Surfaces will
	 * construct curves to define the rule lines to be plotted.
	 * Other objects just return the error message indicating
	 * no processing was necessary. The constructed pieces are
	 * connected to the local object.
	 */

        nprisms = (IGRshort)my_info->num_prisms;

        OMmsg = om$send(
	    msg = message GRgraphics.GRplotprep
	    	(msg,plot_args->md_env,&cons_env,&nprisms,
	     	 my_info->prism_array,&plot_args->id_info[1],
		 &my_info->index1,&my_info->index2),
	    senderid = graphics_object->objid,
	    targetid = graphics_object->objid,
	    targetos = graphics_object->osnum);
    }
#else

    *msg = GRNO_PROCESSING_NEEDED;

#endif IDRAW

    if ( 1 & OMmsg)
    {
	if ( *msg == GRNO_PROCESSING_NEEDED )
	{
	    /* The object needed no special processing.
	     */

	    no_special_processing = TRUE;
	}
	else
	{
	    no_special_processing = FALSE;

	}	

	if (1 & OMmsg)
	{
            GRget_to_comp_chansel(&owner_chan);

	    /* clip the object(s) against the prism array
	     */

	    owner_id = plot_args->id_info[1];

	    om$get_channel_count(
		osnum = owner_id.osnum,
		objid = owner_id.objid,
		p_chanselect = &owner_chan,
		count = &count);

	    /* beg_clip_count is the next available index on the 
	     * channel.
	     */

	    beg_clip_count = count;
	    next_slot = beg_clip_count;
	    index1 = my_info->index1;
	    index2 = my_info->index2;

#ifdef DEBUG
	    printf("beginning count in GUprocessplot = %d\n",count);
#endif

	    for (i=0; i < my_info->num_prisms; ++i)
	    {
		/* clip the processed object(s) against all
		 * prisms in the array.
		 */

		for (j=index1; j<index2; ++j)
		{
		    /* index1 is the beginning of the processed
		     * pieces, index2 is the end.  Any thing on this
		     * channel will have been constructed in the
		     * construct environment by GRplotprep.
		     */

		    OMmsg = om$send(
			msg = message GRgraphics.GRclip
			    ( msg, &cons_env, &cons_env,
			      (IGRchar *)&my_info->prism_array[i], 
			      &owner_id, NULL, NULL, &clip_flags ),
			senderid = owner_id.objid,
			targetos = owner_id.osnum,
			p_chanselect = &owner_chan,
			to = j,
			from = j);

	    	    if ( *msg == GR_I_OBJINSIDE )
	    	    {
			/* maintain a list of indexes of inside
			 * objects to be processed by additional 
		 	 * prisms.
			 */

			IGRboolean add_entry = TRUE;

		 	for (k=0; k< non_clipped_index && add_entry;
				++k)
			{
			    if (index_ptr[k] == j)
			    {
				add_entry = FALSE;
			    }
			}
			if ( add_entry )			
			{
			    if (non_clipped_index >= index_array_size)
			    {
			        /* buffer is not large enough, allocate
			         * larger buffer.
			         */

			        index_ptr1 = (IGRint *)om$malloc
				    (size = (sizeof (IGRint) *
					 (index_array_size + 100)));
			        for (k=0; k<index_array_size; ++k)
			    	{
				    index_ptr1[k] = index_ptr[k];
			    	}
			    	if (index_array_size > 99)
			    	{
				    om$dealloc(ptr = index_ptr);
			    	}
			    	index_ptr = index_ptr1;
			    	index_array_size += 100;
			    }
			    index_ptr[non_clipped_index++] = j;
			}
		    }
		}			

		for (j=0; j < prev_clipped_index; ++j)
		{
		    /* process list of previously non-clipped pieces
		     * A value of -1 indicates a hole.
		     */

		    if (index_ptr[j] != -1)
		    {
			/* Any object on this channel will have been
			 * constructed using the construct
			 * environment.
			 */

		        OMmsg = om$send(
			    msg = message GRgraphics.GRclip
			        ( msg, &cons_env, &cons_env,
			      	  (IGRchar*)&my_info->prism_array[i], 
			      	  &owner_id, NULL, NULL, &clip_flags ),
			    senderid = owner_id.objid,
			    targetos = owner_id.osnum,
			    p_chanselect = &owner_chan,
			    to = index_ptr[j],
			    from = index_ptr[j]);
		    }
	    	    if ( *msg != GR_I_OBJINSIDE )
	    	    {
			/* if the object is no longer inside, clear the
			 * marker.
			 */

			index_ptr[j] = -1;
		    }
		}			
		prev_clipped_index = non_clipped_index;

		if (no_special_processing)
		{
		    /* if the object needed no special processing,
		     * process it now.
		     */

                    /* note the number of objects on the clipped channel */
                    om$get_channel_count(objid = owner_id.objid,
                                         osnum = owner_id.osnum,
                                         p_chanselect = &owner_chan,
                                         count = &pre_clip_count);

		    OMmsg = om$send(
			msg = message GRgraphics.GRclip
			   ( msg, plot_args->md_env, &cons_env,
			      	  (IGRchar*)&my_info->prism_array[i], 
			      	  &owner_id, NULL, NULL, &clip_flags ),
			senderid = graphics_object->objid,
			targetid = graphics_object->objid,
			targetos = graphics_object->osnum);
                   /*
                     * If the object belongs to class GRdvcs, GRclip is a
                     * rejected method, so ignore the OMmsg failure and
                     * continue processing. TR# 119417492 - Satya - 05/11/94
                     */

                    if(OMmsg == OM_W_REJECTED_METHOD)
                       OMmsg = OM_S_SUCCESS;


	    	    if (*msg != GR_I_OBJINSIDE)
	    	    {
                        if (*msg == MSSUCC)
                        {
                            /*
                                Check whether the object lied about clipping;
                                that is, whether it constructed any clipped
                                pieces.  Some objects return success, but
                                don't actually do anything (such as
                                view-independent symbols).  These objects need
                                to handled specially.
                            */
                            om$get_channel_count(objid = owner_id.objid,
                                                 osnum = owner_id.osnum,
                                                 p_chanselect = &owner_chan,
                                                 count = &post_clip_count);
                            if (pre_clip_count != post_clip_count)
                                no_special_processing = FALSE;
                        }
                        else
                            /*
                                if the object is not inside, clear the flag,
                                otherwise leave it set for additional prisms
                                in the array.
                            */
                            no_special_processing = FALSE;
                    }
		}
		
		/* find the indexes for the next prism processing
		 */

		om$get_channel_count(
		    objid = owner_id.objid,
		    osnum = owner_id.osnum,
		    p_chanselect = &owner_chan,
		    count = &count);

#ifdef DEBUG
	        printf("count in loop in GUprocessplot = %d\n",count);
#endif

		if (i != my_info->num_prisms-1)
		{
		    index1 = next_slot;
		    index2 = count;
		    next_slot = count;
		}
	    }

	    /* all pieces are now clipped, plot the elements
	     */

	    if (next_slot != count)
	    {
	    	/* plot the clipped pieces
	     	 */				

	    	OMmsg = om$send
	       	    (msg = message GRgraphics.GRplotyourself
			(msg,&cons_env,plot_args->design_buffer,
			plot_args->object_buffer,
			plot_args->element_buffer,
			(int *)plot_args->element_size,
			(int *)plot_args->file_descriptor,
			plot_args->max_overflow,
			plot_args->id_info,
			plot_args->scale_factor),
		     senderid = owner_id.objid,
		     targetos = owner_id.osnum,
		     p_chanselect = &owner_chan,
		     from = next_slot,
		     to = count);
	    }

	    /* plot the inside pieces
	     */

	    for (i=0; i<non_clipped_index; ++i)
	    {
		if ( index_ptr[i] != -1)
		{
	            OMmsg = om$send
	       	    	(msg = message GRgraphics.GRplotyourself
			    (msg,&cons_env,plot_args->design_buffer,
			    plot_args->object_buffer,
			    plot_args->element_buffer,
			    (int *)plot_args->element_size,
			    (int *)plot_args->file_descriptor,
			    plot_args->max_overflow,
			    plot_args->id_info,
			    plot_args->scale_factor),
		     	 senderid = owner_id.objid,
		     	 targetos = owner_id.osnum,
		     	 p_chanselect = &owner_chan,
		     	 from = index_ptr[i],
		      	 to = index_ptr[i]);
		}
	    }

	    if (no_special_processing)
	    {
		/* the object was not clipped or processed,
		 * plot the object.  Use the input environment info.
		 */

	    	OMmsg = om$send
	       	    (msg = my_info->plot_msg,
		     senderid = graphics_object->objid,
		     targetid = graphics_object->objid,
		     targetos = graphics_object->osnum);
	    }
	    else if ( my_info->num_prisms == 0)
	    {
		/* The objects on the channel have been constructed
		 * using the construct environment. Plot them using
		 * this environment.
		 */

	        OMmsg = om$send
	       	    (msg = message GRgraphics.GRplotyourself
			(msg,&cons_env,plot_args->design_buffer,
			plot_args->object_buffer,
			plot_args->element_buffer,
			(int *)plot_args->element_size,
			(int *)plot_args->file_descriptor,
			plot_args->max_overflow,
			plot_args->id_info,
			plot_args->scale_factor),
		    senderid = owner_id.objid,
		    targetos = owner_id.osnum,
		    p_chanselect = &owner_chan,
		     	 from = my_info->index1,
		      	 to = count);
	    }
		
	    /* delete the processed pieces of the object
	     */

	    for (i = count-1; i >= my_info->index1; --i)
	    {
		om$send(
		     msg = message GRgraphics.GRdelete
			    (&msg1,&cons_env),
		     senderid = owner_id.objid,
		     targetos = owner_id.osnum,
		     p_chanselect = &owner_chan,
		     from = i,
		     to = i);
	    }
	    my_info->index2 = my_info->index1;
	}
	if (index_array_size > 99)
	{
	    om$dealloc(ptr = index_ptr);
	}
    }

wrapup:

    /*
     *    If the GUprocessplot returns an unsuccessful message then 
     * the Rtree traversal is aborted. In order to avoid this the
     * return message is always success.
     */

    if ( !(OMmsg & 1) )
    {
       OMmsg = OM_W_ABORT;
    }
    *msg = MSSUCC;
    return (OMmsg);
}

int GUgetfunc_info(msg,ptr)

IGRlong		*msg;
IGRchar		**ptr;
{
    *msg = MSSUCC;
    *ptr = func_info_ptr;
    return(1);
}

end implementation GRvg;
