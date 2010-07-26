/*
Name
        COcvigdsige.cvt_type17

Description
        This function converts an IGDS text element to an OSA text
        object.  The new object will be added to the R-tree.

History
        Older than the hills (at least the ones by the InterLake)

        mrm     03/26/92    added dimension arg to GRswap_type717_ele
*/

class implementation COcvigdsige;

#include "exsysdep.h"
#include "coimport.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "gotextdef.h"
#include "gotext.h"
#include "igrdp.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "madef.h"
#include "exlocaledef.h"
#include "exlocale.h"

/*
 *   This constant is derived using the following formula - 
 * text_width = (length_mult * ((bodysize - descent)/bodysize) )/ 10
 * descent was found to be .2364583333 times the bodysize for all fonts,
 * so it reduced to text_width = length_mult * PLOTNUMBER
 */


#define PLOTNUMBER 0.07635416667


/* ---------------------------------------------- */
/*    Added by Mohan                              */
/* ---------------------------------------------- */

extern double MAasin(), MAsin(), MAcos(), MAatan();
from GRfm import GRfm_retdata, GRphy_search, GRvirt_search, GRmake_entry;
from GRgraphics import GRchgprops;


method cvt_type17 (IGRlong *msg; struct GRid *object_info)
{
    IGRboolean		maret;
    IGRuchar 		*text_ptr;
    IGRchar		typeface[15];
    IGRchar		charmap[15];
    IGRchar		name[257];              /* element's name	     */
    IGRchar		prim_fontfile[100];
    IGRchar		vfont_name[40];
    IGRchar		prim_vfont_name[40];
    IGRchar		fontpath[100];
    IGRchar		class_name[80];	        /* class name for object     */
    IGRchar		fnum_string[81];
    IGRchar		*class_attr;
    IGRchar		*internal_pntr;
    IGRchar		text_string[1048];      /* 255 characters +
                                                   768 for worst case of
                                                   changing to/from
                                                   fraction font +
                                                   extra pad		     */
    IGRshort		start_char;
    IGRshort		end_char;
    IGRshort		prim_vfont_num = 0;
    IGRshort		text_buf_size = 280;
    IGRshort		set = 1;
    IGRshort		props;
    unsigned short      text_properties;
    IGRint		has_link;
    IGRint  		i;                      /* loop counter		     */
    IGRint		num_chars;
    IGRint		prim_font_flags;
    IGRint		num_positions = 0;
    IGRlong		status;
    IGRlong		tempdummy;
    IGRlong		text_array[9];
    IGRlong		temp_int;
    IGRdouble		length_mult;
    IGRdouble		height_mult;
    IGRdouble		quaternions[4];
    IGRdouble		origin[3];
    IGRdouble		rot_angle;
    IGRdouble		old_height;
    IGRdouble		new_height;
    IGRdouble           theta, value;           /* Added by Mohan            */
    IGRvector		vector;
    IGRmatrix		rot_matrix;
    GRobjid		font_id;
    GRobjid		mod_id;
    struct extents	text_extents;
    struct IGRlbsys	lbs_geom;
    struct IGResintx	text_attr;
    struct IGRestx	text_info;
    struct IGRdisplay	disattr;
    struct GRdpb_text_symb	text_symbology;
    struct vfont_entry	        fontinfo;
    struct IGDS_text_ele	*igdstext;
    struct EX_fonts		font_parameters;
    struct EX_locale_var	var_list[2];

    igdstext = (struct IGDS_text_ele *) me->cvt_bufs.ele_buf;

#ifdef BIG_ENDIAN
    GRswap_type717_ele(me->cvt_bufs.ele_buf, me->IGDS_file_type);
#endif

    ex$get_modid ( mod_osnum = object_info->osnum, mod_id = &mod_id);

    ex$get_super ( mod_id = mod_id,
                  mod_osnum = object_info->osnum,
                  super_name = "GRFONTMGR",
                  create = 1,
                  super_class = "GRfm",
                  super_id = &font_id );

    /*
     *  initialize pointer to text element 
     *  specific data.
     */

    if (me->IGDS_file_type == GU_2I)
    {
        /*
         *  2-D text
         */

        strcpy ( class_name, "GR3dtext" );

        internal_pntr = &(igdstext->text_data);

        OM_BLOCK_MOVE( internal_pntr, text_array, 20 );

        internal_pntr += 20;

        /*
         *  Set up OSA text element specific attributes.
         */

        text_attr.estx = &text_info;
        text_attr.estx->just = igdstext->justification;
        GUswapint(&text_array[0], &tempdummy);
        text_attr.estx->width = 6.0 * ((IGRdouble)text_array[0]) / 1000;
        length_mult = ((IGRdouble)text_array[0]);
        GUswapint(&text_array[1], &tempdummy);
        text_attr.estx->height = 6.0 * ((IGRdouble)text_array[1]) / 1000;
        height_mult = ((IGRdouble)text_array[1]);
        text_attr.estx->flag = 0;
        text_attr.estx->num_char = (IGRuchar ) *internal_pntr;
        internal_pntr += 2;
        text_attr.estx->line_spac = 1;
        text_attr.estx->char_spac = 1;
        text_attr.estx->text_length = text_attr.estx->num_char;
        text_attr.text_string = text_string;

        /*
         *  Set up text string from IGDS text element.
         */

        strncpy ( &(text_string[0]), internal_pntr, text_attr.estx->num_char );
        text_string[text_attr.estx->num_char] = '\0';

        /*
         *  Set up origin, then set z to active z value.
         */

        for ( i = 0; i < 2; i++ )
        {
            GUswapint ( &(text_array[3+i]), &tempdummy);
            origin[i] = (IGRdouble) tempdummy;
        }

        origin[2] = GUACT_Z_2D;

        GUswapint ( &(text_array[2]), &temp_int);
        if ( temp_int < 0 )
        {
            temp_int  = - (0x7fffffff & temp_int );
        }

        /*
         *  convert to radians 
         */
        rot_angle = (temp_int / 360000.0) * (PI / 180.0);

        vector[0] = 0;
        vector[1] = 0;
        vector[2] = 1;

        /*
         * convert rotation angle to rotation matrix
         */

        maret = MArotmx ( msg, vector, &rot_angle, rot_matrix);

        if ( ! (maret & 1) )
        {
            /*
             *  error creating rotation matrix
             *  exit
             */
        }
    }
    else
    {
        strcpy ( class_name, "GR3dtext" );

        internal_pntr = &(igdstext->text_data);

        OM_BLOCK_MOVE( internal_pntr, text_array, 36 );

        internal_pntr += 36;

        /*
         *  Set up OSA text element specific attributes.
         */

        text_attr.estx = &text_info;
        text_attr.estx->just = igdstext->justification;
        GUswapint(&text_array[0], &tempdummy);
        text_attr.estx->width = 6.0 * ((IGRdouble)text_array[0]) / 1000;
        length_mult = ((IGRdouble)text_array[0]);
        GUswapint(&text_array[1], &tempdummy);
        text_attr.estx->height = 6.0 * ((IGRdouble)text_array[1]) / 1000;
        height_mult = ((IGRdouble)text_array[1]);
        text_attr.estx->flag = 0;
        text_attr.estx->num_char = (IGRuchar ) *internal_pntr;
        internal_pntr += 2;
        text_attr.estx->line_spac = 1;
        text_attr.estx->char_spac = 1;
        text_attr.estx->text_length = text_attr.estx->num_char;
        text_attr.text_string = text_string;


        /*
         *  Set up text string from IGDS text element.
         */

        strncpy ( &(text_string[0]), internal_pntr, text_attr.estx->num_char );
        text_string[text_attr.estx->num_char] = '\0';

        /*
         *  Set up origin.
         */

        for ( i = 0; i < 3; i++ )
        {
            GUswapint ( &(text_array[6+i]), &tempdummy);
            origin[i] = (IGRdouble)tempdummy;
        }

        for ( i = 0; i < 4; ++i )
        {
            GUswapint ( &(text_array[2+i]), &tempdummy);
            quaternions[i] = (IGRdouble)tempdummy;
        }
    
        /*
         *  convert quaternions to rotation matrix
         */

        GUquat_to_rotmx ( quaternions, rot_matrix );
    }

    if ((igdstext->font == 126) & (text_string[0] == 'F'))
    {
        igdstext->font = 102;
        text_string[0] = 'Z';
    }

    /*
     *  Process (download) the primary (starting) font.
     */

    /*
     *  Primary font is a text font.
     */


    prim_font_flags = TEXT_FONT;
    strcpy ( prim_vfont_name, "font" );

    sprintf ( fnum_string, "%d", igdstext->font );
 
    if ( igdstext->font == 1 )
    {
        /*
         *  This is the default font and it has a
         *	special logical name.
         */

        strcpy ( prim_fontfile, "default" );
    }
    else
    {
        strcpy ( prim_fontfile, fnum_string );
    }



    /*  Check attribute linkage for the user data types */

    has_link = GUattr_link (msg, &igdstext->header, name, 
                            &igdstext->header.symbology, typeface, charmap);

    /*
     *  Checks to see if it was a plot file, and calls a macro to get
     * the logical font name for that typeface and charmap
     */

    if (has_link & HAS_FONT_TYPE)
    {
        /*
         * the following function call gets the slant angle and the properties
         * of the font user data linkage; this functionality should be
         * incorporated into the fuction GUattr_link (called above) but was
         * not done so for version 1.4.2 to minimize impact on other code
         */

        GUattr_font_link(msg, &igdstext->header, NULL, &text_properties);

        strcat (typeface, ".tf");
        strcat (charmap, ".cm");

        var_list[0].var = EX_font_parameters;
        var_list[0].var_ptr = (IGRchar *) &font_parameters;
        var_list[1].var_ptr = charmap;

        ex$inq_locale (msg = msg, 
                       var = var_list, 
                       flags = EX_Text | EX_Typeface_Charmap,
                       identifier = typeface);

        if ( *msg & 1)
        {
            strcpy (prim_fontfile, font_parameters.name);
	 
        }

        /*
         * Recalculates the text width and height if the file being
         * translated is a plot file;  only need to adjust the text size if the
         * font linkage's version number is zero
         */

        if (! (text_properties & GU_FS_LINK_VER_ALL))
        {
            text_attr.estx->width = length_mult * PLOTNUMBER;
            text_attr.estx->height = height_mult * PLOTNUMBER;
        }
    }                           /* end if has_link */

    strcat ( prim_vfont_name, prim_fontfile );


    /*
     *  Check to see if the physical font has been previously
     *  downloaded to virtual memory, and if so, retrieve the 
     *  virtual font number.
     */

    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRfm.GRphy_search ( msg, 
                                                     (IGRuchar *)prim_fontfile,
                                                     (IGRuchar *)vfont_name ),
                     senderid = my_id,
                     targetid = font_id,
                     targetos = object_info->osnum );

    if ( !(status & 1) )
    {
        text_attr.estx->font = 0;
    }
    else
    {
        if ( *msg == MSSUCC )
        {
            /*
             *  Retrieve the virtual font number.
             */

            prim_vfont_num = -1;
 
            status = om$send( mode = OM_e_wrt_object,
                             msg = message GRfm.GRvirt_search
                             ( msg, (IGRuchar *)vfont_name, &prim_vfont_num ),
                             senderid = my_id,
                             targetid = font_id,
                             targetos = object_info->osnum );

            if ( !(1 & status) )
            {
                text_attr.estx->font = 0;
                prim_vfont_num = 0;
            }
            else
            {
                text_attr.estx->font = prim_vfont_num;
            }

        }
        else 
        {
            num_chars = strlen ( prim_fontfile );

            if ( !GRisitfnt ( msg, prim_fontfile, &num_chars, fontpath ) )
            {
                text_attr.estx->font = 0;
                prim_vfont_num = 0;
            }
            else
            {		
                prim_vfont_num = -1;

                /*
                 *  Font was not found in virtual memory, download the font
                 *  at this time.
                 */

                status = om$send( mode = OM_e_wrt_object,
                                 msg = message GRfm.GRmake_entry
                                 ( msg, (IGRuchar *)prim_fontfile, 
                                   (IGRuchar *)prim_vfont_name,
                                  prim_font_flags, &prim_vfont_num ),
                                 senderid = my_id,
                                 targetid = font_id,
                                 targetos = object_info->osnum );

                if ( (!(1 & status)) || (*msg != MSSUCC) )
                {
                    text_attr.estx->font = 0;
                    prim_vfont_num = 0;
                }
                else
                {
                    text_attr.estx->font = prim_vfont_num;
                }

            }                   /* end else GRisitfnt */

        }                       /* end else msg */

    }                           /* end else status */

    /*
     *  Get font data of the font.
     */

    status = om$send ( mode = OM_e_wrt_object,
                      msg = message GRfm.GRfm_retdata
                      ( msg, &(text_attr.estx->font), &fontinfo ),
                      senderid = my_id,
                      targetid = font_id,
                      targetos = object_info->osnum );

    if ( !(status & 1) )
    {
        goto wrapup;
    }

    /*
     *       Calculate the text extents. The variables start_char and 
     *  end_char determine the portion of the text_string for which
     *  the extents are calculated.
     *       Text has to be scaled to EMS values by scaling
     *  the text height and width instead of scaling the rotation matrix. 
     */

    text_attr.estx->width /= me->scale_factor;
    text_attr.estx->height /= me->scale_factor;


    disattr.color = 
        (((unsigned short)(igdstext->header.symbology & 0xff00) >> 8) + 1);
    disattr.weight = ((IGRuchar)(igdstext->header.symbology & 0x00f8) >> 3);
    disattr.style = igdstext->header.symbology & 0x0007;

    start_char = 0;
    end_char = text_attr.estx->text_length - 1;


    GRtx_extents ( msg, text_string, &text_attr.estx->text_length, &fontinfo,
                  &disattr,
                  text_attr.estx->char_spac, text_attr.estx->line_spac,
                  text_attr.estx->width, text_attr.estx->height, prim_vfont_num,
                  start_char, end_char, &text_extents );


    if ((igdstext->font == 102) & (text_string[0] == 'Z'))
    {
        if (text_attr.estx->width != text_attr.estx->height)
        {
            if (text_attr.estx->height < 0)
            {
                text_attr.estx->height = 
                    (MAabsolute(text_attr.estx->width) * -1);
            }
            else
            {
                text_attr.estx->height = MAabsolute(text_attr.estx->width);
            }
            old_height = text_extents.cap - text_extents.base;
            GRtx_extents (msg, text_string, &text_attr.estx->text_length, 
                          &fontinfo, &disattr, text_attr.estx->char_spac,
                          text_attr.estx->line_spac, text_attr.estx->width,
                          text_attr.estx->height, prim_vfont_num, start_char,
                          end_char, &text_extents );
            new_height = text_extents.cap - text_extents.base;

            /* ------------------------------------------------------------- */
            /*								     */
            /*  The following piece  of code is added by Mohan to solve      */
            /*  the alignment problem of the arrow-head with dimension line. */
            /*					                             */
            /* ------------------------------------------------------------- */
            if ( rot_matrix[0] != 0.0 )
            {
                value = rot_matrix[4]/rot_matrix[0];
                theta = MAatan( msg, &value );
            }
            else
            {
                value = 1 / sqrt( 1.0 + ( (rot_matrix[0] * rot_matrix[0])
                                         /( rot_matrix[4] * rot_matrix[4]) ) ) ;
                theta = MAasin (msg, &value);
            }
            if ( rot_matrix[0] < 0.0 )
            {
                origin[1] += MAcos(msg, &theta) * (((new_height - old_height) / 2 ) * me->scale_factor);
            }
            else
            {
                origin[1] -= MAcos(msg, &theta) * (((new_height - old_height) / 2 ) * me->scale_factor);
            }
            if ( rot_matrix[4] < 0.0 )
            {
                origin[0] -= MAsin( msg, &theta ) * (((new_height - old_height) / 2 ) * me->scale_factor);
            }
            else
            {
                origin[0] += MAsin( msg, &theta ) * (((new_height - old_height) / 2 ) * me->scale_factor);
            }

            /* ------------------------------------------------------------- */
            /* These two lines of code also will solve the problem of */
            /* alignment of arrow-head with the dimension line, provided  */
            /* there is no scale-factor associated with the rotation matrix. */
            /* ------------------------------------------------------------- */
            /*
              origin[0] += rot_matrix[4] * (((new_height - old_height) / 2 ) * me->scale_factor);
              origin[1] -= rot_matrix[0] * (((new_height - old_height) / 2 ) * me->scale_factor);
              */
            /* ------------------------------------------------------------- */

        }
    }


    /*
     *  Map IGDS text justification to the proper
     *  IGE text justification.
     */

    status = GUitxtjust ( msg, &text_attr.estx->just, origin, &text_extents, 
                         rot_matrix, &me->scale_factor );
    if ( !(1 & status) )
    {
        text_attr.estx->just = LEFT_BASE;
    }

    /*
     *  Set up to calculate the stroke start point for the text string.
     */

    text_symbology.Active_font = text_attr.estx->font;
    text_symbology.Active_just = text_attr.estx->just;
    text_symbology.Active_width = text_attr.estx->width;
    text_symbology.Active_height = text_attr.estx->height;
    text_symbology.Active_charspac = text_attr.estx->char_spac;
    text_symbology.Active_linespac = text_attr.estx->line_spac;

    text_ptr = (IGRuchar *) text_string;
    status = GRjust_string(msg, &text_ptr, &text_attr.estx->text_length, 
                           &text_buf_size, &fontinfo, &disattr,
                           &text_symbology, num_positions, NULL,
                           &text_extents );
    text_attr.text_string = (char *) text_ptr;


    /* Since the scaling to EMS values is accomplished by scaling
     * the text parameters, the scaling of the rotation matrix in 
     * GUconstruct has to be compensated by multiplying the 
     * rotation matrix by the scale factor.
     */

    for ( i=0; i<15; i++ )
    {
	rot_matrix[i] *= me->scale_factor;
    }


    /*
     *  Create lbs geometry.
     */

    rot_matrix[3] = origin[0];
    rot_matrix[7] = origin[1];
    rot_matrix[11] = origin[2];

    for ( i = 0; i < 16; i++ )
    {
        lbs_geom.matrix[i] = rot_matrix[i];
    }

    lbs_geom.diag_pt1[0] = text_extents.left;
    lbs_geom.diag_pt1[1] = text_extents.bottom;
    lbs_geom.diag_pt1[2] = 0;
    lbs_geom.diag_pt2[0] = text_extents.right;
    lbs_geom.diag_pt2[1] = text_extents.top;
    lbs_geom.diag_pt2[2] = 0;

    class_attr = (IGRchar *) &text_attr;


    /*
     *  Construct an OSA object.
     */

    status = GUconstruct((IGRchar *)&lbs_geom, object_info, 
                         class_name, (IGRchar *)&igdstext->header.level,
                         (IGRshort *)&igdstext->header.symbology,
                         (IGRshort *)&igdstext->header.properties, class_attr,
                         &me->scale_factor, &me->current_env);


    if ((has_link & HAS_FILLED_TYPE) ||
        ((has_link & HAS_FONT_TYPE) && (text_properties & GU_FILLED_FONT)))
    {
        props = GRFILLED_DISPLAY;
        status = om$send (msg = message GRgraphics.GRchgprops
                               (msg, &set, &props),
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

  wrapup: return (status);

}


struct EMSuserdata
{
    unsigned char wtf;
    unsigned char type;
    unsigned short data;
};

IGRint GUattr_font_link(msg, element, slant_angle, font_properties)

IGRlong *msg;				/* output - completion code     */
struct GUcommon_header_info *element;	/* input - IGDS element	ptr	*/
IGRdouble *slant_angle;
unsigned short *font_properties;
{
    IGRint status;
    IGRlong vax_float[2];
    IGRchar *c;
    unsigned char props;            /* |i|r|m|u|linkage family class| */
    unsigned short *end_of_ele;     /* end of IGDS element */
    unsigned short *attr_data;      /* data packet within an EMS udp */
    unsigned short *end_of_data;    /* end of an EMS user data packet */
    unsigned short *linkage;        /* points to beginning of a linkage */
    unsigned short *data;           /* points to data */
    struct EMSuserdata *emsdata;    /* user data written by EMS */
    struct IGDS_linkage *userdata;  /* IGDS user data linkage structure */

    status = FALSE;
    *msg = MSSUCC;
    linkage = (unsigned short *)&element->index_to_ae + element->index_to_ae + 1;
    end_of_ele = (unsigned short *)element + element->words_to_follow + 2;

    while (linkage < end_of_ele)
    {
        props = *linkage >> 8;
        if (!(props & GU_LINKAGE_PROPS))
        {
            /* DMRS or other type of fixed-length attribute linkage */

            linkage += 4;
        }
        else
        {
            userdata = (struct IGDS_linkage *)linkage;
            if ((userdata->user_id == GU_LINKAGE_ID) ||
                (userdata->user_id == GU_FILLPOLY_TYPE))
            {
                attr_data = linkage + 2;
                end_of_data = linkage + userdata->words_to_follow + 1;
                while (attr_data < end_of_data)
                {
                    emsdata = (struct EMSuserdata *)attr_data;
                    data = (unsigned short *)&emsdata->data;

                    if ((emsdata->type == GU_FONT_TYPE) &&
                        (slant_angle || font_properties))
        	    {
                        c = (IGRchar *)data;
                        if (font_properties)
		            blkmv(2, c, (char *) font_properties);
                        if (slant_angle)
                        {
                            c += 2;
                            blkmv (8, c, (char *) vax_float);  /* data alignment */
                            fltvax_to_flt32(1, vax_float, slant_angle);
                        }
                        status = TRUE;
                        break;
                    }

                    /* increment to the next attribute type */

                    attr_data += emsdata->wtf + 1;

                } /* end while (attr_data < end_of_data) */

            } /* end if GU_LINKAGE_ID */

            /* increment to the next user data linkage */

            linkage += userdata->words_to_follow + 1;
        }
    }
    return(status);
}

end implementation COcvigdsige;
