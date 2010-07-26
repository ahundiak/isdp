/*
Name
        GRattrLink

Description
        This file contains routines related to adding attribute data
        to IGDS elements.

History
        mrm     09/26/91    creation
                03/14/92    write data out in proper format on Sun
*/

#include "exsysdep.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "transdef.h"
#include "translate.h"
#include "msdef.h"

/*
Name
        GRaddAttrLinkage

Description
        This function will add a buffer to an IGDS element as an
        attribute linkage.  If a linkage already exists, the buffer will
        be appended to the existing linkage.

Notes
        The format used for the attribute linkage is described in an
        InterPlot document "APPENDIX (Formats for Metafile Extension)"
        dated 14-JUN-90.

                -------------------------------------------------
		|I|R|M|U|	LFC	|    	   WTF		|
                -------------------------------------------------
		|		    User ID			|
                -------------------------------------------------
                |    Attribute Type	|   Attribute Length	|
                -------------------------------------------------
		|		Attribute Data			|
		|			:			|
		|			:			|
                -------------------------------------------------
                |    Attribute Type	|   Attribute Length	|
                -------------------------------------------------
		|		Attribute Data			|
		|			:			|
		|			:			|

History
        mrm     09/26/91    creation
*/

IGRlong GRaddAttrLinkage(msg, element, buffer, buffersize)
IGRlong *msg;
IGRuchar *element;
IGRuchar *buffer;
IGRint buffersize;
{
    IGRboolean linkage_exists;
    IGRshort *linkage_ptr, *end_of_ele, *end_of_linkage;
#ifdef BIG_ENDIAN
    IGRshort swapit;
#endif
    IGRint linkage_length, added_length;      /* in words */
    struct GUcommon_header_info	*ele;
    struct IGDS_linkage *header;

    /* initialize data */
    *msg = MSSUCC;
    ele = (struct GUcommon_header_info *)element;
    end_of_ele = &ele->words_to_follow + ele->words_to_follow + 1;
    linkage_ptr = &ele->index_to_ae + ele->index_to_ae + 1;
    header = (struct IGDS_linkage *) linkage_ptr;
    added_length = buffersize / 2;

    /* check whether a linkage already exists */
    if (end_of_ele == linkage_ptr)
    {
        linkage_exists = FALSE;
        linkage_length = 2;
        end_of_linkage = (IGRshort *)header + 2;
        added_length += linkage_length;
    }
    else
    {
        linkage_exists = TRUE;
        linkage_length = header->words_to_follow + 1;
        end_of_linkage = (IGRshort *)header + header->words_to_follow + 1;
    }

    /* make sure there is room for the new data */
    linkage_length += (buffersize / 2);
    if (((linkage_length + ele->words_to_follow) > GU_MAX_DGN_SIZE) ||
        ((linkage_length - 1) > GU_MAX_ELE_LINK))
    {
        *msg = MSFAIL;
        goto finish;
    }

    /* set up the linkage header */
    if (!linkage_exists)
    {
        header->words_to_follow = 0;
        header->properties = GU_LINKAGE_PROPS;
#ifdef BIG_ENDIAN
        swapit = GU_INTERPLOT_ID;
        GRconv_short(&swapit, &header->user_id);
#else
        header->user_id = GU_INTERPLOT_ID; /* InterPlot attribute id number */
#endif
    }

    /* move the buffer into the attribute linkage */
    blkmv(buffersize, buffer, end_of_linkage);
    header->words_to_follow = linkage_length - 1;

    /* adjust entries in the element header */
    ele->properties |= IGDSAttributeData;
    ele->words_to_follow += added_length;

finish:

    return (*msg & 1);
}


/*
Name
        GRaddStyleLinkage

Description
        This routine appends an attribute linkage to an IGDS element to
        indicate to InterPlot that the element should be plotted with a
        user-defined linestyle.  The attribute linkage points to an
        attribute bundle that is assumed to have been previously
        defined.

Notes
        The format used for the attribute linkage is described in an
        InterPlot document "APPENDIX (Formats for Metafile Extension)"
        dated 14-JUN-90.

                -------------------------------------------------
		|     Att Type = 21	|    Att Length = 1	|
                -------------------------------------------------
                |  Style Index = style	|    Style Flag = 0	|
                -------------------------------------------------

        Style flag = 0 indicates that the style index is into a user-defined
        linestyle table.

History
        mrm     09/26/91    creation
*/

IGRlong GRaddStyleLinkage(msg, style, ele)
IGRlong *msg;
IGRuchar style;
IGRuchar *ele;
{
    IGRshort data[2];

    *msg = MSSUCC;

    /* fill in a buffer with the attribute linkage data */
#ifdef BIG_ENDIAN
    data[0] = 0x0115;           /* att type 21, length 1 */
    data[1] = (IGRshort)style;  /* style index, style flag 0 */
#else
    data[0] = 0x1501;           /* att type 21, length 1 */
    data[1] = style << 8;       /* style index, style flag 0 */
#endif

    /* add the linkage to the element */
    GRaddAttrLinkage(msg, ele, (IGRuchar *)data, sizeof(IGRshort) * 2);

    return(*msg & 1);
}
