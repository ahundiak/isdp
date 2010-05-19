/* $Id: VDXtype2.C,v 1.1.1.1 2001/01/04 21:08:45 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/vdextr/func/VDXtype2.C
 *
 * Description:
 *		Support function for extract for review command.
 *
 *	VDXtype2:
 *	This utility function formats an IGDS type 2 cell incorporating
 *	type 4 or type 6 shape elements according to the boundary geometry,
 *	symbology and properties. 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXtype2.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:45  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1999/04/19  13:58:34  pinnacle
 * for dynapipe
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      04/16/99        ylong           created
 *
 ***************************************************************************/


#include <stdio.h>
#include "exsysdep.h"
#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "msdef.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "dpdls.h"


struct VDX_IGDS_cell
{
    struct GUcommon_header_info header;
    IGRshort	info[49];
};

VDXtype2( range, geometry, num_bdrys, msg, file_des, dgn_buf, ele_buf, 
	 ele_size, class_name, symbology, properties, grgroup, scale)

IGRlong			*msg;
IGRint			*file_des;
IGRchar			*dgn_buf;
struct VDX_IGDS_cell	*ele_buf;
IGRint			*ele_size;
IGRchar			class_name[];
struct IGRpolyline 	*geometry;
IGRlong			num_bdrys;
IGRdouble		range[6];
struct GRsymbology	*symbology;
IGRushort 		*properties;
IGRshort 		grgroup[];
IGRlong			scale;

{

    IGRint		i;			/* lcv 			*/
    IGRint		j;      		/* lcv 			*/
    IGRint		m;			/* lcv 			*/
    IGRint		num_ele;
    IGRint		num_last;
    IGRint		block_ptr;
    IGRint		byte_ptr;
    IGRshort		type;			/* igds element type 	*/
    IGRshort		write_mode;		/* mode for writing 	*/
    IGRshort		num_points;
    IGRlong		point[303];
    IGRlong		brc = TRUE;		/* return status 	*/
    IGRlong		name_msg;		/* add ele name	status	*/
    IGRboolean		flatten = FALSE;
    IGRboolean		shape = FALSE;
    IGRushort		words_in_descript;
    IGRushort		tmp;
    short                  xx;
    struct VDX_IGDS_cell   *cell;
    struct IGDS_complex		*cpxstring;
    struct IGDS_linestring	*linestring;


    	*msg = GUsuccess;

    	/* scale the range */

    	for(m=0;m<6;m++) range[m] *= scale;

	/* format and create a cell header */

	type = 2;

    	/*
     	 * call function to load header data.
    	 */

	
    	GUload_IGDSheader( msg, class_name, &type, symbology, properties,
		       	   range, ele_buf );

	if ( *msg != GUsuccess )
    	{
	    brc = FALSE;
	    goto wrap_up;
    	}

	words_in_descript = 0;

	for(i = 0; i < num_bdrys; i++)
	{

		if( geometry[i].num_points < 101 )
		{
			words_in_descript += ( geometry[i].num_points * 6 + 19);
		}
		else
		{
			num_ele = (geometry[i].num_points - 1)/100;
     			if ( (geometry[i].num_points-1)%100 > 0 )
			{
			    num_ele++;
			}
 	
			num_last = geometry[i].num_points % 100;
			if ( num_last == 0 )
			{
			    num_last = 100;
			}
			else if ( num_last == 1 )
			{
			    num_last = 101;
			}

			words_in_descript += ((num_ele-1)*(((101*3)*2)+19)) +
				   ((num_last*3)*2+19) + 1;

			words_in_descript += 4;
		}
	}
	
	words_in_descript += 43;
/*
	level = (IGRushort)cell->header.level;
*/
	if(num_bdrys == 1) goto skip_cell;

	cell = (struct VDX_IGDS_cell *) ele_buf;
	cell->header.properties |= 0x8000;
	cell->header.properties |= 0x4000;
	cell->header.level = 0;
	cell->header.words_to_follow = 60;
	cell->header.graphic_group = (IGRshort) grgroup[3];
	cell->header.index_to_ae = 46;

	tmp = 0;
	for(xx=0;xx<44;xx++)
	{
	    memcpy( (IGRchar *)&cell->info[xx], 
			(IGRchar *) &tmp, sizeof(IGRshort) );
	}

    	/* words in description */
	memcpy( (IGRchar *)&cell->info[0], 
			(IGRchar *) &words_in_descript, sizeof(IGRshort) );

    	/* level indicators */
	tmp = 1;
	memcpy( (IGRchar *)&cell->info[4], 
			(IGRchar *) &tmp, sizeof(IGRshort) );

    	/* bit map indicators */
	tmp = 1;
	memcpy( (IGRchar *)&cell->info[3], 
			(IGRchar *) &tmp, sizeof(IGRshort) );

	/* identity matrix */
        tmp = 1;
	memcpy( (IGRchar *)&cell->info[20], 
			(IGRchar *) &tmp, sizeof(IGRshort) );

        tmp = 1;
	memcpy( (IGRchar *)&cell->info[28], 
			(IGRchar *) &tmp, sizeof(IGRshort) );

	tmp = 1; 
	memcpy( (IGRchar *)&cell->info[36], 
			(IGRchar *) &tmp, sizeof(IGRshort) );



    	GRadd_dmrs_to_buf(&name_msg, grgroup, ele_buf);

	*ele_size = (ele_buf->header.words_to_follow + 2) * 2;

	write_mode = GUWRITE;

	brc = GUwrite_element(	msg, dgn_buf, 
				ele_buf, 
				&type,
				ele_size, file_des, 
				&write_mode, &block_ptr,
				&byte_ptr );

    /*  
     *  Check the number of points that make up the shape.
     *  If it is greater than 101 then the shape will be
     *  broken down into linestrings and a complex shape 
     *  will be formed from them.  Otherwise an IGDS shape
     *  element will be formatted.
     */

skip_cell:

  for(tmp=0; tmp<num_bdrys; tmp++)
  {
    shape = TRUE;
    if ( geometry[tmp].num_points > 101 )
    {
	/*
	 *  Calculate the number of elements required to
	 *  complete the IGE object.
	 */

	num_ele = (geometry[tmp].num_points - 1)/100;
     	if ( (geometry[tmp].num_points-1)%100 > 0 )
	{
	    num_ele++;
	}
	
	/*
	 *  Calculate the number of points in the last line
	 *  string required to complete the IGE object.
	 */
 	
	num_last = geometry[tmp].num_points % 100;
	if ( num_last == 0 )
	{
	    num_last = 100;
	}
	else if ( num_last == 1 )
	{
	    num_last = 101;
	}

	/* 
	 *  IGDS headers have 16 bits to store the value of wds_in_
	 *  descript.  If that value is larger than 65536, then	
	 *  the element must be flattened into individual line strings.
	 */

	words_in_descript = ((num_ele-1)*(((101*3)*2)+19)) +
			   ((num_last*3)*2+19) + 1;
	
	/* 	A dummy attribute linkage of 4 words has to be added 
	 *  to complex headers, inorder to meet some IGDS minimum 
	 *  element size requirements. The words_in_descript, ele_size
	 *  and words_to_follow are adjusted accordingly.
	 */

	words_in_descript += 4;

	if ( words_in_descript > 65535 )
	{
		flatten = TRUE;
	}
	
	/*
	 *  Format a complex string header element.
	 */


       if ( !flatten )
       {

	shape = FALSE;

	type = 14;

    	/*
     	 * call function to load header data.
    	 */

    	GUload_IGDSheader( msg, class_name, &type, symbology, properties,
		       	   range, ele_buf );

	if ( *msg != GUsuccess )
    	{
	    brc = FALSE;
	    goto wrap_up;
    	}	    


	cpxstring = (struct IGDS_complex *) ele_buf;
	cpxstring->header.words_to_follow = 18 + 4;
	cpxstring->header.graphic_group = (IGRshort) grgroup[3];
	
	if( num_bdrys > 1)
	{
		cpxstring->header.level |= 0x80; /* set complex bit */
	}
	cpxstring->header.index_to_ae = 4;

	if( tmp > 0)
		cpxstring->header.properties |= 0x8000; /* set hole bit */

	cpxstring->wds_in_descript = (IGRushort) words_in_descript;
	cpxstring->num_elements = num_ele;
	cpxstring->dummy_linkage = 0;

	/*
	 *  Write the complex shape header element to the file.
	 */
	// TR179900152 comment out the if so holes get the attributes
	//if( num_bdrys == 1)
	//{
		cpxstring->header.words_to_follow = 18;
	    	GRadd_dmrs_to_buf(&name_msg, grgroup, ele_buf);
		//}
	*ele_size = 48;
	write_mode = GUWRITE;

	brc = GUwrite_element(	msg, dgn_buf, 
				ele_buf, 
				&type,
				ele_size, file_des, 
				&write_mode, &block_ptr,
				&byte_ptr );
      }

    }
    else
    {
	num_ele = 1;
	num_last = geometry[tmp].num_points;
    }

    /*
     *  Format the line string elements which will make
     *  up the complex string element.
     */

	if(shape == TRUE)
	{
		type = 6;
    	}
    	else
    	{
		type = 4;
    	}

    i = 0;

    while ( num_ele >= 1 )
    {
        GUload_IGDSheader( msg, class_name, &type, symbology, 
			   properties, range, ele_buf );
	if ( *msg != GUsuccess )
  	{
	    brc = FALSE;
	    goto wrap_up;
    	}	    

        /*
	 *  Set the number of points which will make up
	 *  this particular line string.
	 */

        if ( num_ele > 1 )
	{
	    num_points = 101;
	}
	else
	{
	    num_points = num_last;
	}

	/*
	 *  Calculate and set up some header information.
	 */

	linestring = (struct IGDS_linestring *) ele_buf;

	if(num_bdrys > 1) 
		linestring->header.level |= 0x80; /* set complex bit */

	if( tmp > 0)
		linestring->header.properties |= 0x8000; /* set hole bit */

	linestring->header.type = type;
	linestring->header.words_to_follow = 17 + 2*(num_points*3);
	linestring->header.index_to_ae = 
			linestring->header.words_to_follow - 14;
	linestring->header.graphic_group = (IGRshort) grgroup[3];
	linestring->lnstr.num_points = num_points;

	/*
	 *  Get the points out of the linestring object.
	 */
	    for ( j = 0; j < num_points*3; j ++ )
	    {
		point[j] = GUnint ( geometry[tmp].points[i]*scale);
		GUswapint ( &point[j], &point[j] );
		i++;
	    }

	    i -= 3;

	memcpy(&(linestring->lnstr.pnts_ptr), (char *)point,
               num_points*3*4 );

        /* check whether a user-defined linestyle is present */
        if (symbology->display_attr.style >= BUILTIN_STYLES)
            GRaddStyleLinkage(&name_msg, symbology->display_attr.style,
                              ele_buf);

        /*
         *  Write the element out to the file.
         */

	// TR179900152 comment out the if so holes get the attributes
	//if( num_bdrys == 1 && type == 6)
	//{
	    	GRadd_dmrs_to_buf(&name_msg, grgroup, ele_buf);
		//}

	*ele_size = (ele_buf->header.words_to_follow+2) * 2;

	write_mode = GUWRITE;

	brc = GUwrite_element( msg, dgn_buf, ele_buf, &type, ele_size,
	    		       file_des, &write_mode, &block_ptr,
			       &byte_ptr );
	num_ele--;

    }

 } /* end of for(tmp) */
	
wrap_up:

	return(brc);

} /* end VDXtype2 */
