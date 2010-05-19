/* $Id: VDXclr_tbl.C,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/vdextr/func/VDXclr_tbl.C
 *
 * Description:
 *		Support function for extract for review command.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXclr_tbl.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1999/04/19  13:58:34  pinnacle
 * for dynapipe
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/16/99        ylong           created
 *
 ***************************************************************************/


#include <stdio.h>
#include <fcntl.h>
#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igewindef.h" 
#include "igewindow.h"
#include "exsysdep.h"      /*** EXNUCDP ****/

#include "igecolordef.h"
#include "wl.h"
#include "igecolor.h"
#include "igewinmacros.h"
#include "igecolmacros.h"
#include "transdef.h"
#include "translate.h"
#include "VDXmsg.h"
#include "exmacros.h"
#include "v_dbgmacros.h"

/*****************************************************************************
 *                                                                           *
 *  This routine will read the active EMS color table and write out an       *
 *  IGDS color table.                                                        *
 *                                                                           *
 *****************************************************************************/

VDXotype5lv1( msg , file_name, file_des, dgn_buf, ele_buf, ele_size )

IGRlong 	*msg;          /* O */ 
IGRchar		*file_name;    /* name of file to write color table out to */
IGRint		*file_des;     /* O */
IGRchar		*dgn_buf;      /* I/O */
struct IGDS_color_table	*ele_buf; /* O */
IGRint		*ele_size;        /* O */

{
    IGRint		i;
    IGRint		index;
    IGRint		status;
    IGRint		byte_ptr;
    IGRint		block_ptr;
    IGRint		num_chars;
    IGRint		ct_file_desc;
    IGRchar		ct_filename[81];
    IGRshort		type = 5;
    IGRshort		num_colors = 512;
    IGRshort		sav_num_colors;
    IGRshort		write_mode = GUWRITE;
    IGRboolean		found = FALSE;
    IGRboolean		tableflag = TRUE;
    struct IGEvlt	igecolor[512];
#ifdef BIG_ENDIAN
    IGRshort            swapped_short;
#endif

    SetProc( VDXotype5lv1  ); Begin

    status = TRUE;
    *msg = VDX_S_SUCCESS;

    ct_file_desc = - 1;

    /*
     *  Initialize header info, file name, and
     *	screen selector in the type 5 color
     *  table element.
     */

    *ele_size = 872;
    ele_buf->header.level = 1;
    ele_buf->header.type = 5;
    ele_buf->header.words_to_follow = 434;

#ifdef BIG_ENDIAN
    GRconv_short(&ele_buf->header.words_to_follow,&swapped_short);
    ele_buf->header.words_to_follow = swapped_short;
#endif
    ele_buf->header.range[0] = 0x00000000;
    ele_buf->header.range[1] = 0x00000000;
    ele_buf->header.range[2] = 0x00000000;
    ele_buf->header.range[3] = 0xffffffff;
    ele_buf->header.range[4] = 0xffffffff;
    ele_buf->header.range[5] = 0xffffffff;
    ele_buf->header.graphic_group = 0;
    ele_buf->header.index_to_ae = 420;

#ifdef BIG_ENDIAN
    GRconv_short(&ele_buf->header.index_to_ae,&swapped_short);
    ele_buf->header.index_to_ae = swapped_short;
#endif
    ele_buf->header.properties = 0;
    ele_buf->header.symbology = 0;
    
    ele_buf->screen_select = 0; /* right screen color table */

    strcpy ( ct_filename, file_name );
    num_chars = strlen ( ct_filename );
    if ( num_chars > 60 )
    {
	num_chars = 60;
	ct_filename[60] = '\0';
    }

    i = num_chars - 1;
    while ( (i >= 0)  && (ct_filename[i] != '/') )
    {
	if ( (ct_filename[i] == '.')  &&  (!found) )
	{
	    found = TRUE;
	    strcpy ( &ct_filename[i+1], "tbl" );
	}
	i--;
    }

    if ( !found )
    {
	strcat ( ct_filename, ".tbl" );
    }
    num_chars = strlen ( &ct_filename[i+1] );

    if ( num_chars > 10 )
    {
	if ( strncmp ( &ct_filename[i+11], ".tbl", 4 ) == 0 )
	{
	    tableflag = FALSE;
	    num_chars = 0;
	}
	else
	{
	    if (num_chars > 14 )
	    {
	    	ct_filename[i+11] = '\0';
	    	strcat ( ct_filename, ".tbl" );
	    	num_chars = 14;
	    }
	}
    }

    ele_buf->num_chars = (IGRshort) num_chars;

#ifdef BIG_ENDIAN
    GRconv_short(&ele_buf->num_chars,&swapped_short);
    ele_buf->num_chars = swapped_short;
#endif
    strncpy ( &ele_buf->filename[0], &ct_filename[i+1], num_chars );

    /*
     *	Read the color table (Only the first 256 Entries).
     */

    status = ige$read_color_table ( num_colors = &num_colors, 
			     	    colors = (IGRchar *) igecolor );
    if( !status ){
	*msg = VDX_S_SUCCESS;
	goto wrapup;
    }
    sav_num_colors = num_colors;

    /*
     *  Get the number of active colors for this workstation.
     */


    if( ! ex$is_batch()){
      status = ige$get_num_active_colors ( num_colors = &num_colors );
      if ( !status ){
	*msg = VDX_S_SUCCESS;
	  __DBGpr_com("GUplotctb: error getting number of active colors." );
	num_colors = sav_num_colors;
      }
    }

    /*
     *  Shift the color values to the higher order n bits
     *  of the longword.
     */

    if ( num_colors == 0 )
    {
	num_colors = sav_num_colors;
    }

    for ( i = 1; i < 255; i++ )
    {
	index = (i-1) % num_colors;
	
	ele_buf->color[i].red = (IGRuchar ) (igecolor[index].red >> 8);
	ele_buf->color[i].green = (IGRuchar ) (igecolor[index].green >> 8);
	ele_buf->color[i].blue = (IGRuchar ) (igecolor[index].blue >> 8);
    }

    /*
     *  Read the reserved colors.
     */

    status = ige$read_reserved_colors ( bgcolor = (IGRchar *) &igecolor[0], 
				        hilite_color = (IGRchar *) &igecolor[1] );

    ele_buf->color[0].red = (IGRuchar ) (igecolor[0].red >> 8);
    ele_buf->color[0].green = (IGRuchar ) (igecolor[0].green >> 8);
    ele_buf->color[0].blue = (IGRuchar ) (igecolor[0].blue >> 8);
    ele_buf->color[255].red = (IGRuchar ) (igecolor[1].red >> 8);
    ele_buf->color[255].green = (IGRuchar ) (igecolor[1].green >> 8);
    ele_buf->color[255].blue = (IGRuchar ) (igecolor[1].blue >> 8);


    /*
     *	Write both right and left screen color tables to the file.
     */

    status = GUwrite_element ( msg, dgn_buf, ele_buf, &type, ele_size, 
			       file_des, &write_mode, &block_ptr,
			       &byte_ptr );
    if ( !status )
    {
	*msg = VDX_S_SUCCESS;;
	goto wrapup;
    }

    /*
     *  Switch to left screen color table element.
     */

#ifdef BIG_ENDIAN
    ele_buf->screen_select = 0x0080;
#else
    ele_buf->screen_select = 0x8000;
#endif
    status = GUwrite_element ( msg, dgn_buf, ele_buf, &type, ele_size, 
			       file_des, &write_mode, &block_ptr,
			       &byte_ptr );
    if ( !status )
    {
	*msg = VDX_S_SUCCESS;
	goto wrapup;
    }

    /*
     *  Write out the associated IGDS color table file.
     */

    __DBGpr_str(" Create Color Table ", ct_filename );

    ct_file_desc = open ( ct_filename, O_CREAT | O_RDWR, GUACCESS_MODE );
    if ( ct_file_desc == -1 )
    {
	*msg = VDX_S_SUCCESS;
	goto wrapup;
    }    

    __DBGpr_str(" Write Color Table ", ct_filename );

    if ( (status = write ( ct_file_desc, &ele_buf->color[0], 768)) != 768 )
    {
	*msg = VDX_S_SUCCESS;
    }

    /*** Close the IGDS color table file ***/


wrapup:

	if ( ct_file_desc != -1 ){
		__DBGpr_str(" Close Color Table ", ct_filename );
		close (ct_file_desc); 
	}

	End
	//return;
}


