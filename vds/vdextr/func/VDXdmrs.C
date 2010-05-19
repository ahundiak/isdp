/* $Id: VDXdmrs.C,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/vdextr/func/VDXdrms.C
 *
 * Description:
 *              GRadd_dmrs_to_buf
 *              Support function for extract for review command.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXdmrs.C,v $
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


#include 	"grimport.h"
#include	"igrtypedef.h"
#include	"igr.h"
#include	"transmacros.h"
#include	"msdef.h"
#include	"transdef.h"
#include	"translate.h"
#include 	"exsysdep.h"

extern IGRchar DIR_G_car_dir;

IGRboolean GRadd_dmrs_to_buf(msg, id, ele_buf)
IGRlong		*msg;
IGRshort	id[];
IGRchar		*ele_buf;
{
    IGRshort			my[8], size;
    IGRboolean			status = TRUE;
    IGRshort			*linkage_ptr;
    IGRchar			*header1;
    struct GUcommon_header_info	*ele;

    ele = (struct GUcommon_header_info *) ele_buf;
    linkage_ptr = &ele->index_to_ae + ele->index_to_ae + 1;
    header1 = (IGRchar *) linkage_ptr;

    /*  Set  the properties word bit mask which is the 16th
     *  word in the common header info.
     */

    ele->properties |= IGDSAttributeData;

    ele->words_to_follow += 4;

    /* this is the type description */
/*
	my[0] = 0x8000;
	my[1] = (id[0] >> 16);
	my[2] = id[0];
	if( my[2] < 0) my[2] -= 0xffff0000;
	my[3] = id[1];
*/
	my[0] = 0;
	my[1] = id[2];
	my[2] = id[0];
	if( my[2] < 0) my[2] -= 0xffff0000;
	my[3] = id[1];

	size = 4 * sizeof(IGRushort);

/*
	printf("dmrs\ninput dec { %d %d %d}\nhex { %x %x %x}\noutput\ndec { %d %d %d %d } \nhex { %x %x %x %x }\n",
		id[0],id[1], id[2],
		id[0],id[1], id[2],
		my[0], my[1],my[2],my[3],
		my[0], my[1],my[2],my[3]);
*/

    memcpy( (IGRuchar *)&header1[0], (IGRuchar *) my, size );
    *msg = MSSUCC;
    return(status);
}
