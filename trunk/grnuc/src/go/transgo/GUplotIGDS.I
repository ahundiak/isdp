/*
Name
        GUplot_IGDS

Description
        This function is called to create an IGDS plotting metafile
        from an object space.

History
        Created way back in the mists of time.

        mrm     07/19/91    Added kludge to allow lower-level plot
                            routines to get the id of the window being
                            plotted.
                09/12/91    Added filter args
                09/23/91    Added code to write user-defined linestyle table
*/

class implementation GRvg;

#include "exsysdep.h"
#include "grimport.h"
#include <stdio.h>
#include <fcntl.h>
#include "godef.h"
#include "transdef.h"
#include "transerr.h"
#include "translate.h"
#include "trans_ele.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "exmacros.h"
#include "gomacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msdef.h"

from module import GRmod_passon;
from IGEwinsup import pre_plot, post_plot;

extern void GUinit_symb();
extern IGRint GUprocessplot();

struct GRid GUwindow_being_plotted;

#argsused
IGRlong GUplot_IGDS(msg, file_name, dbtype, mod_info, tempid_info,
		    seedfile, view_setup, trans_limits, curve_prism,
                    filter_function, filter_data)

IGRlong			*msg;
IGRlong			*file_name;
IGRchar			*dbtype;
struct GRmd_env		*mod_info;
struct GRid		*tempid_info;
IGRchar			seedfile[];
struct GRid		view_setup[];
IGRdouble		trans_limits[];	/* world coords, view coords */
struct IGRcv_prism	*curve_prism;
IGRint                  (*filter_function)(); /* pointer to a function which
                                                 will be called prior to
                                                 placing each element in
                                                 the plotfile */
IGRchar                 *filter_data;     /* pointer to data to be passed to
                                             the filter function */

{
    IGRchar             mapfile[256], *map;
    IGRboolean		read_status;
    IGRboolean		ext_type_nine = FALSE;
    IGRboolean		view_overflow = FALSE;
    IGRshort		write_mode = GUWRITE;
    IGRshort		write_init = GUWRITE_INIT, dim = 4;
#ifdef BIG_ENDIAN
    IGRshort            swapped_value;
#endif
    IGRlong		read_msg;
    IGRlong		IGDS_filedesc = -1;
    IGRlong		num_bytes_read;
    IGRlong		begin_index;
    IGRlong		end_index;
    IGRlong		i;
    IGRlong		OMmsg;
    IGRlong		status,
                        msg1,
                        which_error,
                        ret_bytes1;
    IGRint		block_ptr;
    IGRint		byte_ptr;
    IGRint		type5_block;
    IGRint		type5_byte;
    IGRint		count;
    IGRint		sts;
    IGRint		levels[32];
    IGRdouble		scale_factor;
    IGRdouble		max_abs_overflow = 0;
    IGRmatrix		world_to_view,
                        view_to_world;
    FILE                *fp;
    struct GUcvt_bufs	cvt_buffers,
                        in_buffers;             /* seed file */
    Trans_ele		plot_type5;
    struct GRid		id_array[2];
    struct var_list	params[2];
    OM_S_CHANSELECT	chandef, chan;
    DB_3D_DBL_BOX	range_box, target_box;
    OM_S_MESSAGE	pass_message;
    OM_S_MESSAGE	function_msg;
    OM_S_KEY_DESC	select_key;
    OM_S_KEY_DESC	target_key;
    OM_S_MESSAGE	plot_msg;
    struct GRfunction_info function_info;
    struct GUplot_element_args plot_element;
    struct GUplot_user_info my_info;
    struct Rtree_passon_args
    {
        OM_p_MESSAGE	function_msg;
        OM_p_KEY_DESC	p_select_key;
        IGRchar		*p_criteria;
        OM_p_KEY_DESC	p_target_key;
        IGRlong         (*user_compare)();
        IGRlong		*return_status;
    } Rtree_passon;
    struct GRfunction_args
    {
        IGRlong	        *msg;
        IGRint          (*user_function)();
        IGRchar 	*info;
    } func_args;


    status = OM_S_SUCCESS;
    in_buffers.file_des = -1;	

    /* initialize level mapping */

    i = 0;
    map = NULL;
    while (ex$get_path(index = i++, path = mapfile, len = sizeof(mapfile)))
    {
        strcat(mapfile, "config/plotlayermap");
        if (fp = (FILE *)fopen(mapfile, "r"))
        {
            fclose(fp);
            map = mapfile;
            break;
        }
    }

    GUinit_map(msg, map);

    /* initialize symbology */

    GUinit_symb();

    om$make_chanselect(channame = "IGEgragad.winsup",
                       p_chanselect = &chandef);

    sts = om$get_channel_count(osnum = view_setup[0].osnum,
                               objid = view_setup[0].objid,
                               p_chanselect = &chandef,
                               count = (OMuint *)&count);

    if (!(sts & 1))
    {
        om$report_error(sts = sts);
        goto wrapup;
    }

    /*
     *  open proper seed file with read only access
     *  CURRENTLY NO SUPPORT FOR OPENING A 2-D SEEDFILE
     */

    if (strlen(seedfile) == 0)
    {
        /*
         *  use the default seed file
         */

        for (i = 0; (1 & status); i++)
        {
            if (status = ex$get_path(index = i, path = seedfile, len = 80))
            {
                strcat(seedfile, "config/seed3d.dgn");
                in_buffers.file_des = open(seedfile, GUREAD_ONLY);

                if (in_buffers.file_des != -1)
                {
                    break;
                }
            }
        }
        if (in_buffers.file_des == -1)
        {
            *msg = GUNOSEEDFILE;
            status = FALSE;
            goto wrapup;
        }
    }
    else
    {
        /* user has specified seed file */

        in_buffers.file_des = open(seedfile, GUREAD_ONLY);
	
        if (in_buffers.file_des == -1)
        {
            *msg = GUNOSEEDFILE;
            status = FALSE;
            goto wrapup;
        }
    }

    /*
        Set up a global variable kludge (shudder!) to allow lower-level
        access to the id of the window being plotted.  This is needed
        by horizon edges, but the necessary info doesn't make it into
        GRplotprep.  That should eventually be added to the GRplotprep
        arglist.
    */

    GUwindow_being_plotted = view_setup[0];

    /*
        Make sure that the place where the surfaces get their view information
        is pointing to the window being plotted.  This function needs to be
        moved from MODEL to GRNUC.
    */

    EMSsubbs_put_locate_window(view_setup[0].objid, view_setup[0].osnum);

    /* store the target file type for use by lower level routines */

    GRset_conversion_type(GRPlottingMetafile);

    /*
     *  create the IGDS design file
     *
     *  the 'creat' function CANNOT be used because it does
     *  does not allow read privileges to the new file
     */
   
    IGDS_filedesc = open((char *)file_name, O_TRUNC | O_CREAT | O_RDWR, GUACCESS_MODE);
	  
    if (IGDS_filedesc == -1)
    {
        *msg = GUNOFILE;
        status = FALSE;
        goto wrapup;
    }
    else
    {
        /*
         *  reset pointers to their original values
         *  meaningful when multiple translations
         *  occur from one EMS session
         */

        status = GUwrite_element(msg, cvt_buffers.dgn_buf,
                                 cvt_buffers.ele_buf,
                                 &cvt_buffers.ele_type,
                                 &cvt_buffers.ele_size, &IGDS_filedesc, 
                                 &write_init, &block_ptr, &byte_ptr);

        read_status = TRUE;
        cvt_buffers.ele_type = -1;
        in_buffers.ele_type = -1;

        /*
         *  read the elements from the seed file
         *  and write them into the new IGDS file
         */

        while (read_status == TRUE)
        {
            read_status = GUget_next_ele(&read_msg, &in_buffers);
				
            if (read_msg != GULAST_ELEMENT)
            {
                /*
                 *  Check for type 9 and set up the view information
                 *  and active parameters.
                 */

#ifdef BIG_ENDIAN
                GRconv_short(in_buffers.ele_buf, &swapped_value);
                if ( ((swapped_value & 0x7f00) >> 8) == 9 )
#else
                if ((((*((IGRshort *)in_buffers.ele_buf)) & 0x7f00) >> 8) == 9)
#endif
                {
                    if (!ext_type_nine)
                    {
                        GUotype9(msg, in_buffers.ele_buf, view_setup,
                                 &scale_factor, trans_limits);

                        if (*msg == GUVIEW_OVERFLOW)
                        {
                            view_overflow = TRUE;
                        }
                        ext_type_nine = TRUE;
                    }
                }

                status = GUwrite_element(msg, cvt_buffers.dgn_buf, 
                                         in_buffers.ele_buf,
                                         &in_buffers.ele_type, 
                                         &in_buffers.ele_size,
                                         &IGDS_filedesc, &write_mode,
                                         &block_ptr, &byte_ptr);

#ifdef BIG_ENDIAN
                GRconv_short(in_buffers.ele_buf, &swapped_value);
                if ( ((swapped_value & 0x7f00) >> 8) == 10 )
#else
                if ((((*((IGRshort *)in_buffers.ele_buf)) & 0x7f00) >> 8)
                    == 10)
#endif
                {
                    /*
                     *  plotting type 5 must immediately follow 
                     *  the type 10, so that no graphic elements
                     *  preceed the type 5.
                     */

                    plot_type5.words_to_follow = 662;
#ifdef BIG_ENDIAN
                    plot_type5.type_level = 0x0405;
                    GRconv_short(&plot_type5.words_to_follow, &swapped_value);
                    plot_type5.words_to_follow = swapped_value;
#else
                    plot_type5.type_level = 0x0504;
#endif

                    in_buffers.ele_type = 5;
                    in_buffers.ele_size = 1328;

                    status = GUwrite_element(msg, cvt_buffers.dgn_buf,
                                             &plot_type5,
                                             &in_buffers.ele_type, 
                                             &in_buffers.ele_size,
                                             &IGDS_filedesc, &write_mode,
                                             &type5_block, &type5_byte);
                }
            }
        }
        if (read_msg != GULAST_ELEMENT)
        {
            /*
             *  read error has occurred
             *  abort this function
             */

            status = FALSE;
            *msg = GUREAD_ERROR;
            goto wrapup;
        }

        /* write the user-defined linestyle table into the metafile */
        GUotype5lv10t2(msg, &IGDS_filedesc, cvt_buffers.dgn_buf,
                       cvt_buffers.ele_buf, &cvt_buffers.ele_size);

        id_array[0] = view_setup[0];
        id_array[1] = *tempid_info;

        /*
         *  make three messages:
         *  
         *	1.  translate and plot each object to an element
         * 	2.  message to invoke a function to process each element
         *   	3.  instruct the R-tree to "passon" the above message
         */


        plot_element.internal_msg = &msg1;
        plot_element.md_env = mod_info;
        plot_element.design_buffer = cvt_buffers.dgn_buf;
        plot_element.object_buffer = cvt_buffers.bs_buf;
        plot_element.element_buffer = cvt_buffers.ele_buf;
        plot_element.element_size = (IGRlong *)&cvt_buffers.ele_size;
        plot_element.file_descriptor = &IGDS_filedesc;
        plot_element.max_overflow = &max_abs_overflow;
        plot_element.id_info = &id_array[0];
        plot_element.scale_factor = &scale_factor;

        status = om$make_message(classname = "GRvg",
                                 methodname = "GRplotyourself",
                                 size = sizeof(struct GUplot_element_args),
                                 p_arglist = &plot_element,
                                 p_msg = &plot_msg);

        if (!(1 & status))
        {
            /*
             *  error creating message to
             *  plot element
             */

            *msg = GUMAKE_MESSAGE_ERROR;
            goto wrapup;
        }

        /* fill in the Rtree pass arguments using the specified limits */

        Rtree_passon.user_compare = 0;
        Rtree_passon.return_status = msg;
        Rtree_passon.p_criteria = NULL;
        Rtree_passon.p_target_key = &target_key;
        Rtree_passon.p_target_key->key.p_3ddbl = &target_box;
        Rtree_passon.p_select_key = &select_key;
        Rtree_passon.p_select_key->type = KEY_3D_DBL;
        Rtree_passon.p_select_key->key.p_3ddbl = &range_box;
        range_box.xmin = trans_limits[0];
        range_box.ymin = trans_limits[1];
        range_box.zmin = trans_limits[2];
        range_box.xmax = trans_limits[3];
        range_box.ymax = trans_limits[4];
        range_box.zmax = trans_limits[5];

        status = om$make_message(classname = "OMrtree",
                                 methodname = "pass",
                                 size = sizeof (struct Rtree_passon_args),
                                 p_arglist = &Rtree_passon,
                                 p_msg = &pass_message);

        if (!(1 & status))
        {
            *msg = GUMAKE_MESSAGE_ERROR;
            goto wrapup;
        }
	
        Rtree_passon.function_msg = &function_msg;

        status = om$make_message(classname = "GRgraphics",
                                 methodname = "GRfunction",
                                 size = sizeof(struct GRfunction_args),
                                 p_arglist = &func_args,
                                 p_msg = Rtree_passon.function_msg);

        if (!(1 & status))
        {
            *msg = GUMAKE_MESSAGE_ERROR;
            goto wrapup;
        }

        /* Form the user info structure for GRfunction.  The 
         * module information and the pass to other spaces
         * will be handled by the GRplotyourself method on the
         * reference file class, therfore, do not tell the GRfunction
         * method to set up module info and pass the message on.
         */

        go$build_user_function_buffer(buffer = &function_info,
                                      md_env = NULL,		
                                      pass_on = 0,
                                      your_info = &my_info);

        /* set up arguments for GRfunction method */

        params[0].var = LEVELS;
        params[0].var_ptr = (IGRchar *)levels;
        params[0].num_bytes = sizeof(IGRlong)*32;
        params[0].bytes_returned = &i;

        params[1].var = END_PARAM;
        params[1].var_ptr = NULL;
        params[1].num_bytes = 0;
        params[1].bytes_returned = NULL;

        OMmsg = dp$inq_set_gragad(msg = msg,
                                  inq0_set1 = 0,
                                  osnum = plot_element.id_info[0].osnum,
                                  gragad_objid = plot_element.id_info[0].objid,
                                  which_error = &which_error,
                                  var_list = params);

        func_args.user_function = GUprocessplot;
        func_args.msg = msg;
        func_args.info = (IGRchar *)&function_info;

        /* set up information for user function to process the plotting */

        chan.u_sel.name = "GRcmpowner.to_components";
        chan.type = OM_e_name;

        om$get_channel_count(osnum = id_array[1].osnum,
                             objid = id_array[1].objid,
                             p_chanselect = &chan,
                             count = (OMuint *)&my_info.index1);

        my_info.filter_function = filter_function;
        my_info.filter_data = filter_data;
        my_info.plot_msg = &plot_msg;
        my_info.index2 = my_info.index1;
        my_info.levels = levels;
        my_info.prism_array = curve_prism;

        if (curve_prism)
        {
            my_info.num_prisms = 1;
        }
        else
        {
            my_info.num_prisms = 0;
        }

        begin_index = 0;
        end_index = GRDGNLIMITS_MAX_I;

        /*
         *  Display and hide raster objects for plotting.
         */

        if (count)
        {
            om$send(msg = message IGEwinsup.pre_plot
                         ((IGRchar *) Rtree_passon.function_msg),
		    senderid = view_setup[0].objid,
		    targetos = view_setup[0].osnum,
                               /* Targetos is the sender object space, i.e.,
                                  the module os. */
                    p_chanselect = &chandef);

            *msg = MSSUCC;
        }

        /* pass the GRfunction method to all objects in the Rtree
         * within the range set up in the pass message.
         */

        status = om$send(mode = OM_e_wrt_object,
                         msg = message module.GRmod_passon
                              (msg, &pass_message, "module.primary",
                               (IGRint *) &begin_index,(IGRint *) &end_index),
                         senderid = tempid_info->objid,
                         targetid = mod_info->md_id.objid,
                         targetos = mod_info->md_id.osnum);


        /*
         *  Unhide raster objects for plot display.
         */

        if (count)
        {
            om$send(msg = message IGEwinsup.post_plot
                         ((IGRchar *) Rtree_passon.function_msg),
		    senderid = view_setup[0].objid,
		    targetos = view_setup[0].osnum,
                               /* Targetos is the sender object space, i.e.,
                                  the module os. */
		    p_chanselect = &chandef);
        }

        /*
         * Kludge for TR 92n3118.  dhm  4/10/92.
         * The GRmod_passon was hitting some objects in a file that it didn't
         * know the class of.  This happens in displaying the file as well, 
         * but the display just stops with what it has and does not indicate 
         * that an error has occurred.  In order to make plotting consistent
         * with display, I added the check for OM_E_NOSUCHCLASS and just
         * process the file with what I have at that point.  EXNUC should 
         * fix the problem with rtree passon to just ignore unknown classes
         * and keep processing the message thru the rtree.
         */

        if ( (1 & status) || (status == OM_E_NOSUCHCLASS) )
        {

            /*
             *  Insert IGDS color table type 5's in the
             *  design file and create IGDS color table file.
             */
		
            GUotype5lv1(msg, file_name, &IGDS_filedesc, 
                        cvt_buffers.dgn_buf, cvt_buffers.ele_buf, 
                        &cvt_buffers.ele_size);
				
            /*
             *  write the end-of-file into
             *  the IGDS design file
             */

            num_bytes_read = 2;
            cvt_buffers.ele_buf[0] = -1; /*0xFF;*/
            cvt_buffers.ele_buf[1] = -1; /*0xFF;*/
            cvt_buffers.ele_type = -1;

            status = GUwrite_element(msg, cvt_buffers.dgn_buf, 
                                     cvt_buffers.ele_buf, 
                                     cvt_buffers.ele_type,
                                     &num_bytes_read, &IGDS_filedesc,
                                     &write_mode, &block_ptr,
                                     &byte_ptr);

            /*
             *  flush the buffer containing
             *  the end-of-file before closing
             *  the IGDS file
             */

            write_mode = GUFLUSH;
            status = GUwrite_element(msg, cvt_buffers.dgn_buf, 
                                     cvt_buffers.ele_buf, 
                                     cvt_buffers.ele_type,
                                     &num_bytes_read, &IGDS_filedesc,
                                     &write_mode, &block_ptr,
                                     &byte_ptr);

            /*
             *  Increase the size of the IGDS design file.
             */

            write_mode = GUINCREASE;
            cvt_buffers.ele_size = 10;
            status = GUwrite_element(msg, cvt_buffers.dgn_buf, 
                                     cvt_buffers.ele_buf, 
                                     cvt_buffers.ele_type,
                                     &cvt_buffers.ele_size, 
                                     &IGDS_filedesc, &write_mode,
                                     &block_ptr, &byte_ptr);

            cvt_buffers.file_des = IGDS_filedesc;

            /* Set view origin (trans_limits) to lower left point
             * in world coords.
             */

            /*
             *  Inquire the window parameters which will specify
             *  the view information for this view.
             */

            params[0].var		= WLD_TO_VIEW;
            params[0].var_ptr		= (IGRchar*)world_to_view;
            params[0].num_bytes		= sizeof(IGRdouble)*16;
            params[0].bytes_returned 	= &ret_bytes1;

            params[1].var 		= END_PARAM;
            params[1].var_ptr		= NULL;
            params[1].num_bytes		= 0;
            params[1].bytes_returned	= NULL;
	
            status = dp$inq_set_gragad(msg = msg, 
                                       inq0_set1 = 0, 
                                       osnum = view_setup[0].osnum, 
                                       gragad_objid = view_setup[0].objid, 
                                       which_error = &which_error, 
                                       var_list = params);
					
            if (!(status & 1))
            {
                goto wrapup;
            }

            MAinvmx(msg, &dim, world_to_view, view_to_world);

            i = 1;

            MAptsxform(msg, &i, view_to_world,
                        &trans_limits[6], &trans_limits[0]);

	    
            /*
             *  Update plotting type 5 element
             */

            status = GUplottype5(msg, &cvt_buffers, &type5_block,
                                 &type5_byte, trans_limits, &scale_factor);

            /* 
             *  If views caused overflow, set msg.
             */

            if (view_overflow)
            {
                *msg = GUVIEW_OVERFLOW;
                status = FALSE;
            }

            /*
             *  Check to see if elements were skipped due to
             *  overflow error.  Element overflow takes
             *  precedence over view overflow.
             */

            if (max_abs_overflow != 0)
            {
                *msg = GUELEMENT_OVERFLOW;
                status = FALSE;
            }
        }
    }

  wrapup:

    /* close the new IGDS file */

    if (IGDS_filedesc)
    {
        close(IGDS_filedesc);
    }

    /* close the seed file */

    if (in_buffers.file_des)
    {
        close(in_buffers.file_des);
    }

    /* invalidate the window information */

    GUwindow_being_plotted.objid = NULL_OBJID;

    /* RESET BACK THE GUget_next_ele static variables */
    read_status = GUget_next_ele(&read_msg, NULL);

    /* reset the target file type to indicate that conversion is finished */

    GRset_conversion_type(GRNoConversionInProgress);

    return(status);
}

end implementation GRvg;
