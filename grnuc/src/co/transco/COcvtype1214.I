/* #######################    APOGEE COMPILED   ######################## */
class implementation COcvigdsige;

#include "coimport.h"
#include "godef.h"
#include "grdpbmacros.h"

from GRconnector import GRflexconn;
from GRgraphics import GRconstruct;
from GRgraphics import GRchgprops;

method cvt_type1214 (IGRlong *msg; struct GRid *object_info)
{

    struct IGDS_complex		*igdscpx;
    IGRint			i;
    IGRlong			status;
    IGRlong			construct_msg;
    IGRlong			nbytes_in_buffer;
    IGRlong			nbytes_transferred;
    IGRshort			count;
    IGRshort			flag;
    IGRlong			sav_ele_size;
    IGRlong			index = OM_K_MAXINT;
    struct GRid			header;
    short unsigned		properties;
    struct GRvg_construct 	const_list;
    struct GRmd_env		mod_environ;
    OM_S_CHANNUM		header_chan_num;
    OM_S_CHANSELECT		header_channel;
    struct GUcommon_header_info element;	/* GUgetname info	     */
    IGRint			has_link;
    IGRchar			name[257];	/* element's name	     */
    IGRshort			set = 1;
    IGRshort			props;
    IGRchar			*typeface = NULL;
    IGRchar			*charmap = NULL;

    /*
     *  Get necessary data from IGDS complex
     *  shape header element.
     */

    igdscpx = (struct IGDS_complex *) me->cvt_bufs.ele_buf;
    sav_ele_size = me->cvt_bufs.ele_size;

    nbytes_in_buffer = sizeof(mod_environ);
    gr$get_module_env ( msg = msg,
			sizbuf = &nbytes_in_buffer,
		        buffer = &mod_environ,
		        nret = &nbytes_transferred );

    const_list.msg = &construct_msg;    
    const_list.env_info = &mod_environ;
    const_list.newflag = FALSE;
    const_list.level = igdscpx->header.level & 0x3f;

    /*
     *  Set up properties word.
     */

    properties = 0;

    if ( igdscpx->header.properties & 0x2000 )
    {
	properties |= GRIS_PLANAR;
    }
    if ( igdscpx->header.properties & 0x0200 )
    {
	properties |= GRIS_NEW;
    }
    if ( igdscpx->header.properties & 0x0400 )
    {
	properties |= GRIS_MODIFIED;
    }
    properties |= GRIS_LOCATABLE;
    properties |= GRIS_DISPLAYABLE;

    const_list.properties = properties;

    const_list.geometry = NULL;
    const_list.display = NULL;
    const_list.class_attr = NULL;
    const_list.name = NULL;

   /*
       Check the user data linkage for an element name.
    */

	element = igdscpx->header;
	has_link = GUattr_link (msg, &igdscpx->header, name,
				&igdscpx->header.symbology, typeface, charmap);

    /*
     *  Construct the complex header object and store
     *  its id and osnum.
     */

        status = om$construct(osnum = object_info->osnum,
                              classname = "GRgrgrp",
                              p_objid = &(object_info->objid),
                              msg = message GRgraphics.GRconstruct
				    ( &const_list ) );

	if (has_link & HAS_FILLED_TYPE)
	{
	   props = 0;
	   props |= GRFILLED_DISPLAY;
	   status = om$send (msg = message GRgraphics.GRchgprops (msg, &set,
								&props),
			     targetid = object_info->objid,
			     targetos = object_info->osnum);
	}

     /* 
      *  Enter the IGDS element's name into the translated element's
      *  data structure.
      */

	if (has_link & HAS_NAME_TYPE)
	{
	  GUputname(msg, name, object_info, &me->current_env);
 	}
 

    if ( !(1 & status) )
    {
	goto wrap_up;
    }

    header.osnum = object_info->osnum;
    header.objid = object_info->objid;

    status = om$get_channel_number(channame = "GRcmpowner.to_components",
                                   p_channum = &header_chan_num );

    if ( !(1 & status) )
    {
	goto wrap_up;
    }

    header_channel.type = OM_e_num;
    header_channel.u_sel.number = header_chan_num;

    /*
     *  Construct each of the component elements and add it
     *  to the complex grouping.
     */

    count = igdscpx->num_elements;

    for ( i = 0; i < count; i++ )
    {
	status = om$send ( mode = OM_e_wrt_object, 
			   msg = message COcvigdsige.cvt_next_ele ( msg, 
						object_info ), 
			   senderid = my_id, 
			   targetid = my_id );
       
      	status = om$send(mode = OM_e_wrt_object,
                       	 msg = message GRconnector.GRflexconn
			   ( msg, (IGRlong *) &flag, &header, &index, &index ),
                         senderid = NULL,
                         targetid = object_info->objid,
			 targetos = object_info->osnum );

	sav_ele_size += me->cvt_bufs.ele_size;
    }

    object_info->osnum = header.osnum;
    object_info->objid = header.objid;
    me->cvt_bufs.ele_size = sav_ele_size;

    wrap_up:
	return status;

}

end implementation COcvigdsige;
