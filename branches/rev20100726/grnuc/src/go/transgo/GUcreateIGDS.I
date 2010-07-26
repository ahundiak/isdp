/*
Name
        GUcreate_IGDSfile

Description
        This function creates an IGDS 8.8 design file from an IGE object
        space.

History
        ???     ??/??/8?    creation
        mrm     02/14/92    added calls to set target file conversion type
*/

class implementation GRvg;

#include "exsysdep.h"
#include "grimport.h"
#include <fcntl.h>
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "OMindex.h"
#include "exmacros.h"

from module import GRmod_passon;
extern void GUcpxinit();
extern void GUinit_symb();

#argsused
IGRlong GUcreate_IGDSfile ( msg, file_name, dbtype, mod_info, 
			    command_id, seedfile, view_setup, trans_limits )

IGRlong			*msg;
IGRlong			*file_name;
IGRchar			*dbtype;
struct GRmd_env		*mod_info;
GRobjid			*command_id;
IGRchar			seedfile[];
struct GRid		view_setup[];
IGRdouble		trans_limits[];
{
    IGRboolean		read_status;
    IGRboolean		ext_type_nine = FALSE;
    IGRboolean		view_overflow = FALSE;
    IGRshort		write_mode = GUWRITE;
    IGRshort		write_init = GUWRITE_INIT;
#ifdef BIG_ENDIAN
    IGRshort            swapped_value;
#endif
    IGRint		block_ptr;
    IGRint		byte_ptr;
    IGRint		i;
    IGRlong		status;
    IGRlong		read_msg;
    IGRlong		IGDS_filedesc;
    IGRlong		num_bytes_read;
    IGRlong		begin_index;
    IGRlong		end_index;
    IGRdouble		scale_factor;
    IGRdouble		max_abs_overflow = 0;
    struct GUcvt_bufs	cvt_buffers;	
    DB_3D_DBL_BOX	range_box;
    OM_S_MESSAGE	pass_message;
    OM_S_KEY_DESC	select_key;
    OM_S_KEY_DESC	target_key;
    OM_p_MESSAGE	pass_addr;
    OM_S_MESSAGE	gofmt_msg;
    OM_p_MESSAGE	message_addr;
    DB_3D_DBL_BOX       target_rng_bx;

    struct format_element_args
    {
        IGRlong		*internal_msg;
        struct GRmd_env *md_env;
        IGRchar		*design_buffer;
        IGRchar		*object_buffer;
        IGRchar		*element_buffer;
        IGRlong		*element_size;
        IGRlong		*file_descriptor;
        IGRdouble	*max_overflow;
        IGRdouble       *scale_factor;
    } format_element;

    struct Rtree_passon_args
    {
        OM_p_MESSAGE	gofmt_msg;
        OM_p_KEY_DESC	p_select_key;
        IGRchar		*p_criteria;
        OM_p_KEY_DESC	p_target_key;
        IGRlong		( *user_compare)();
        IGRlong		*return_status;
    } Rtree_passon;
        

    status = OM_S_SUCCESS;

    GUcpxinit();
    GUinit_symb();

    /*
     *  open proper seed file with read only access
     *  CURRENTLY NO SUPPORT FOR OPENING A 2-D SEEDFILE
     */

    if ( strlen (seedfile) == 0 )
    {
        /*
         *  use the default seed file
         */

        for ( i = 0; (1 & status); i++ )
        {
            if (status = ex$get_path(index = i,
                                     path= seedfile,
                                     len = 80))
            {
                strcat ( seedfile, "config/seed3d.dgn" );
                cvt_buffers.file_des = open ( seedfile, GUREAD_ONLY );
	
                if ( cvt_buffers.file_des != -1 )
                {
                    break;
                }
            }
        }
        if ( cvt_buffers.file_des == -1 )
        {
            *msg = GUNOSEEDFILE;
            status = FALSE;
            goto wrapup;
        }
    }
    else
    {
        /*
         *  user has specified seed file
         */
	
        cvt_buffers.file_des = open ( seedfile, GUREAD_ONLY );
	
        if ( cvt_buffers.file_des == -1 )
        {
            *msg = GUNOSEEDFILE;
            status = FALSE;
            goto wrapup;
        }
    }

    cvt_buffers.ele_type = -1;

    /* store the target file type for use by lower level routines */

    GRset_conversion_type(GRIGDS);

    /*
     *  create the IGDS design file
     *
     *  the 'creat' function CANNOT be used because it
     *  does not allow read privileges to the new file
     */
   
    IGDS_filedesc = open( (char *)file_name, O_CREAT | O_RDWR, GUACCESS_MODE );
	  
    if ( IGDS_filedesc == -1 )
    {
        *msg = GUNOFILE;
        status = FALSE;
        goto wrapup;
    }
    else
    {
        /*
         * reset the i/o pointers for multiple translations
         */

        status = GUwrite_element ( msg, cvt_buffers.dgn_buf, 
                                  cvt_buffers.ele_buf, &cvt_buffers.ele_type,
                                  &cvt_buffers.ele_size, &IGDS_filedesc,
                                  &write_init, &block_ptr, &byte_ptr );

        read_status = TRUE;
        cvt_buffers.ele_type = -1;
		
        while ( read_status == TRUE )
        {

            read_status = GUget_next_ele ( &read_msg, &cvt_buffers );
		
            if ( read_msg != GULAST_ELEMENT )
            {
		    
                /*
                 *  Check for type 9 and set up the view information
                 *  and active parameters.
                 */

#ifdef BIG_ENDIAN
                GRconv_short(cvt_buffers.ele_buf,&swapped_value);
                if ( ((swapped_value & 0x7f00) >>8) == 9) 
#else
                    if ( (((*((IGRshort *)cvt_buffers.ele_buf))
                           & 0x7f00) >>8) == 9) 
#endif
                    {
                        if ( !ext_type_nine )
                        {
                            GUotype9 ( msg, cvt_buffers.ele_buf, 
                                      view_setup, &scale_factor , NULL );
                            if ( *msg == GUVIEW_OVERFLOW )
                            {
                                view_overflow = TRUE;
                            }
                            ext_type_nine = TRUE;
                        }
                    }


                status = GUwrite_element ( msg, cvt_buffers.dgn_buf, 
                                          cvt_buffers.ele_buf,
                                          &cvt_buffers.ele_type, 
                                          &cvt_buffers.ele_size,
                                          &IGDS_filedesc,
                                          &write_mode, 
                                          &block_ptr,
                                          &byte_ptr );
            }
        }

        if ( read_msg != GULAST_ELEMENT )
        {
            /*
             *  read error has occurred
             *  abort this function
             */

            status = FALSE;
            *msg = GUREAD_ERROR;
            goto wrapup;
        }

        /*
         *  Set up named views for each view in the 
         *  IGE object space.
         */

        status = GUonamedvws ( msg, &IGDS_filedesc, 
                              cvt_buffers.dgn_buf,
                              cvt_buffers.ele_buf,
                              mod_info, &scale_factor );

        if ( (!(1 & status)) && (*msg == GUVIEW_OVERFLOW) )
        {
            view_overflow = TRUE;
        }

        status = GUotype5lv3 (msg, &IGDS_filedesc,
                              cvt_buffers.dgn_buf,
                              cvt_buffers.ele_buf,
                              mod_info, &scale_factor );

        /*
         *  make two messages:
         *  
         *	1.  translate each object to an element
         *   	2.  instruct the R-tree to "passon" the above message
         */

        format_element.internal_msg = msg;
        format_element.md_env = mod_info;
        format_element.design_buffer = cvt_buffers.dgn_buf;
        format_element.object_buffer = cvt_buffers.bs_buf;
        format_element.element_buffer = cvt_buffers.ele_buf;
        format_element.element_size = (IGRlong *)&cvt_buffers.ele_size;
        format_element.file_descriptor = &IGDS_filedesc;
        format_element.max_overflow = &max_abs_overflow;
        format_element.scale_factor = &scale_factor;

        Rtree_passon.gofmt_msg = &gofmt_msg;
        message_addr = Rtree_passon.gofmt_msg;

        status = om$make_message(classname = "GRvg",
                                 methodname = "GRformatele",
                                 size = sizeof (struct format_element_args),
                                 p_arglist = &format_element,
                                 p_msg = message_addr );

        if (! (1 & status) )
        {
            /*
             *  error creating message to
             *  format element
             */

            *msg = GUMAKE_MESSAGE_ERROR;
            goto wrapup;

        }

        pass_addr = &pass_message;
        Rtree_passon.p_select_key = &select_key;
        Rtree_passon.p_criteria = NULL;
        Rtree_passon.p_target_key = &target_key;
        Rtree_passon.user_compare = 0;
        Rtree_passon.return_status = msg;

        Rtree_passon.p_select_key->key.p_3ddbl = &range_box;
        Rtree_passon.p_target_key->key.p_3ddbl = &target_rng_bx;
	
        /*
         *  fill in select key using design file limits
         */

        Rtree_passon.p_select_key->type = KEY_3D_DBL;
        Rtree_passon.p_select_key->key.p_3ddbl->xmin = trans_limits[0];
        Rtree_passon.p_select_key->key.p_3ddbl->ymin = trans_limits[1];
        Rtree_passon.p_select_key->key.p_3ddbl->zmin = trans_limits[2];
        Rtree_passon.p_select_key->key.p_3ddbl->xmax = trans_limits[3];
        Rtree_passon.p_select_key->key.p_3ddbl->ymax = trans_limits[4];
        Rtree_passon.p_select_key->key.p_3ddbl->zmax = trans_limits[5];

        status = om$make_message(classname = "OMrtree",
                                 methodname = "pass",
                                 size = sizeof (struct Rtree_passon_args),
                                 p_arglist = &Rtree_passon,
                                 p_msg = pass_addr );

        if ( ! (1 & status) )
        {
            *msg = GUMAKE_MESSAGE_ERROR;
            goto wrapup;
        }

        begin_index = 0;
        end_index = GRDGNLIMITS_MAX_I;

        status = om$send(mode = OM_e_wrt_object,
                         msg = message module.GRmod_passon(msg,
                                                           pass_addr,
                                                           "module.primary",
                                                           (IGRint *)&begin_index,
                                                           (IGRint *)&end_index),
                         senderid = *command_id,
                         targetid = mod_info->md_id.objid,
                         targetos = mod_info->md_id.osnum);

        if ( 1 & status )
        {
            /*
             *  Insert color table type 5's into design
             *	file and create IGDS color table file.
             */
		
            GUotype5lv1 ( msg, file_name, &IGDS_filedesc,
                         cvt_buffers.dgn_buf, cvt_buffers.ele_buf, 
                         &cvt_buffers.ele_size );
		
            /*
             *  write the end-of-file into
             *  the IGDS design file
             */

            num_bytes_read = 2;
            cvt_buffers.ele_buf[0] = 0xFF;
            cvt_buffers.ele_buf[1] = 0xFF;
            cvt_buffers.ele_type = -1;

            status = GUwrite_element ( msg, cvt_buffers.dgn_buf, 
                                      cvt_buffers.ele_buf, 
                                      cvt_buffers.ele_type,
                                      &num_bytes_read, &IGDS_filedesc,
                                      &write_mode, &block_ptr,
                                      &byte_ptr );

            /*
             *  flush the buffer containing
             *  the end-of-file before closing
             *  the IGDS file
             */

            write_mode = GUFLUSH;
            status = GUwrite_element ( msg, cvt_buffers.dgn_buf, 
                                      cvt_buffers.ele_buf, 
                                      cvt_buffers.ele_type,
                                      &num_bytes_read, &IGDS_filedesc,
                                      &write_mode, &block_ptr,
                                      &byte_ptr );
            /*
             *  Increase the size of the IGDS design file.
             */

            write_mode = GUINCREASE;
            cvt_buffers.ele_size = 10;
            status = GUwrite_element ( msg, cvt_buffers.dgn_buf, 
                                      cvt_buffers.ele_buf, 
                                      cvt_buffers.ele_type,
                                      &cvt_buffers.ele_size, 
                                      &IGDS_filedesc,
                                      &write_mode, &block_ptr,
                                      &byte_ptr );

            /*
             *	If views caused overflow, set msg.
             */

            if ( view_overflow )
            {
                *msg = GUVIEW_OVERFLOW;
                status = FALSE;
            }

            /*
             *  Check to see if elements were skipped due to
             *	overflow error.  Element overflow takes 
             *	precedence over view overflow.
             */

            if ( max_abs_overflow != 0 )
            {
                *msg = GUELEMENT_OVERFLOW;
                status = FALSE;
            }
        }
    }

  wrapup:

    /*
     *  close the seed file and the new IGDS file
     */

    close ( cvt_buffers.file_des );

    close ( IGDS_filedesc );

    /* reset the target file type to indicate that conversion is finished */

    GRset_conversion_type(GRNoConversionInProgress);

    return (status);
}

end implementation GRvg;
