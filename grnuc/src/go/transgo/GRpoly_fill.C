/*
Name
        GRpoly_fill

Description
        This subroutine adds information to the user data linkage of an
        element formatted for plotting.  It sets the A-bit in the common
        header info to indicate that attribute data is present.  It updates
        the value of words_to_follow in the common header and sets it in the
        new attribute linkage.

        The write to the element starts at the address determined by an
        offset, from the common header info, of words to follow + 1.  These
        values are written to the new user data linkage: the u-bit is set to
        1, user_id is set to 65, attribute length to 5, color flag to 0, and
        user_type to 8.  Attribute length is set to 5 because the linkage is
        padded with 0's (nulls) and the metafile interpreter needs to identify
        the end of the attribute linkage.  The first byte for fill color is
        set to whatever color was read in as the translated element's border
        color.

History
        mrm     02/26/92    replaced GU_ATTR_PROPS with IGDSAttributeData
*/

#include	"grimport.h"
#include	"igrtypedef.h"
#include	"igr.h"
#include	"transmacros.h"
#include	"msdef.h"
/*
#include	"OMmacros.h"
*/
#include	"transdef.h"
#include	"translate.h"


IGRboolean GRpoly_fill(msg, fill_bit, ele_buf)

IGRlong		*msg;
IGRboolean	*fill_bit;
IGRchar		*ele_buf;

{
    struct GUcommon_header_info	*ele;
    struct GUpolyfill_linkage	*linkage;
    IGRboolean			status = TRUE;
    IGRshort			data[3];

    if (*fill_bit != TRUE)
    {
        status = FALSE;
        goto wrap_up;
    }
  
    /*  Get common header info and set a pointer to the end of the element.
     *  Null characters are written to fill up the last 4-word block
     *  of the data linkage.
     */
    ele = (struct GUcommon_header_info *) ele_buf;
    linkage = (struct GUpolyfill_linkage *)(&ele->words_to_follow +
                                             ele->words_to_follow + 1);

    if ((ele->words_to_follow + 8) > GU_MAX_DGN_SIZE)
    {
        *msg = MSFAIL;
        status = FALSE;
        goto wrap_up;
    }

    *msg = MSSUCC;
    linkage->header.words_to_follow = 7;
    ele->words_to_follow += 8;

    /*  Set  the properties word bit mask which is the 16th
     *  word in the common header info.
     */
    ele->properties |= IGDSAttributeData;

    /*  Linkage data fields and bit masks are set.  Refer to the IGDS
     *  Application Software Interface Document, appendix C, for complete
     *  descriptions of the linkage data structure.
     */
    linkage->header.properties = 0;
    linkage->header.properties |= GU_LINKAGE_PROPS;
    linkage->header.user_id = GU_FILLPOLY_TYPE;
    linkage->length = 5;
    linkage->type = 8;
    linkage->color_flag = 1;
    linkage->fill_color = ((unsigned short)(ele->symbology & 0xFF00) >> 8);

    /*   Zero out memory to the end of the linkage so that the
     *   4 word boundry has null characters in remaining unused bytes.
     */
    data[0] = 0;
    data[1] = 0;
    data[2] = 0;
    blkmv(6, (IGRchar *) data, (IGRchar *) &linkage->data_ptr);

wrap_up:

    return(status);
}
