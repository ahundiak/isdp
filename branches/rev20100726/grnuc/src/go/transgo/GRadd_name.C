/*
Name
        GRadd_name_to_buf

Description
        This subroutine adds an element name to the user data linkage of an
        IGDS element, sets the A-bit in word 17 of the common header info, and
        updates words_to_follow in the common header info and in the attribute
        linkage.

        It checks if an attribute linkage is already present. If it is, the
        name attribute type is appended to the aleady existing linkage.
        Otherwise, the attribute header is also written out (the u-bit is set
        to 1, user_id is set to 7, and user_type to 0).  Null characters are
        written to the linkage's end, if necessary, filling up the last 4-byte
        memory block allocated for that user data linkage.

History
        mrm     04/07/92    strip off :filename:usr:
        mrm     04/16/92    swap user id for sparc
        mrm     11/06/92    removed uid swap; everything that calls this
                            function immediately calls GRswap_name_linkage to
                            take care of all necessary swapping
*/

#include 	"grimport.h"
#include	"igrtypedef.h"
#include	"igr.h"
#include	"DItypedef.h"
#include	"DIdef.h"
#include	"DImacros.h"
#include	"transmacros.h"
#include	"msdef.h"
/*
#include	"OMmacros.h"
*/
#include	"transdef.h"
#include	"translate.h"
#include 	"exsysdep.h"

struct user_linkage
{
   IGRchar length;
   IGRchar type;
   IGRshort data;
};

extern IGRchar DIR_G_car_dir;

IGRboolean GRadd_name_to_buf(msg, has_name, name, ele_buf)
IGRlong		*msg;
IGRboolean	*has_name;
IGRchar		*name;
IGRchar		*ele_buf;
{
    IGRchar                     *p_char, *p_name;
    IGRboolean			status = TRUE;
    IGRboolean			link_exists = FALSE;
    IGRshort			name_type_len, filler;
    IGRshort			*linkage_ptr, *end_of_ele;
    IGRint			num_chars, nulls, i, linkage_len;
    struct user_linkage		*linkage;
    struct IGDS_linkage		*header;
    struct GUcommon_header_info	*ele;

    if (!*has_name)
    {
        status = FALSE;
        goto wrap_up;
    }

    /*
        Strip off the :filename:usr: part of the directory specification, for
        several reasons.  First, to maintain similar behavior to previous
        versions (specifically 1.x).  Electronics is dependent on that
        behavior.  Second, the filename portion may not necessarily match the
        current filename when the file is converted from IGDS back to EMS.
        Third, the stripped part provides little really useful information,
        and the attribute data space is very limited.

        The macro di$cvt_name_for_output used to be used here, until it
        vanished in the 2.0 release.

        The approach is to scan past the second colon, verify that the second
        component in the name is "usr", then jump past the third colon and use
        the rest of the string as the name.  This algorithm will fall apart if
        the user starts naming objects hither and yon.
    */

    p_name = p_char = name;
    if (*p_char == DIR_G_car_dir)
    {
        if (p_char = strchr(++p_char, (int)DIR_G_car_dir))
        {
            p_char++;
            if (*p_char++ == 'u' && *p_char++ == 's' && *p_char++ == 'r')
            {
                p_name = p_char;
            }
        }
    }

    /*  Get common header info and set a pointer to the beginning of the
     *  attribute linkage.  Then the length of the element name is used
     *  to determine how many null characters must be written to fill up
     *  the last 4-word block of the data linkage.
     */

    ele = (struct GUcommon_header_info *) ele_buf;
    end_of_ele = &ele->words_to_follow + ele->words_to_follow + 1;
    linkage_ptr = &ele->index_to_ae + ele->index_to_ae + 1;
    header = (struct IGDS_linkage *) linkage_ptr;

    if (end_of_ele != linkage_ptr)
    {
        link_exists = TRUE;
    }
	
    if (!link_exists)
    {
        header->words_to_follow = 0;
        header->properties = 0;
        header->properties |= GU_LINKAGE_PROPS;
        header->user_id = GU_LINKAGE_ID;
        linkage = (struct user_linkage *)(header + 1);
        filler = 6;
    }
    else
    {
        linkage = (struct user_linkage *)
            (linkage_ptr + header->words_to_follow + 1);
        filler = 2;
    }

    num_chars = strlen(p_name) ;
    nulls = 8 - ((num_chars + filler) % 8);
    if (nulls == 8)
    {
        nulls = 0;
    }
    name_type_len = (num_chars + nulls) / 2 + (filler/2);

    if (link_exists)
    {
        linkage_len = header->words_to_follow + name_type_len + 1;
    }
    else
    {
        linkage_len = name_type_len;
    }

    if (((linkage_len + ele->words_to_follow) > GU_MAX_DGN_SIZE) ||
        ((linkage_len - 1)> GU_MAX_ELE_LINK))
    {
        *msg = MSFAIL;
        status = FALSE;
        goto wrap_up;
    }

    *msg = MSSUCC;

    /*  Set  the properties word bit mask which is the 16th
     *  word in the common header info.
     */

    ele->properties |= IGDSAttributeData;


    /*  Linkage data fields and bit masks are set.  Refer to the IGDS
     *  Application Software Interface Document, appendix C, for detailed
     *  descriptions of the linkage data structure.
     */

    ele->words_to_follow += name_type_len;
    header->words_to_follow = linkage_len - 1;
    linkage->length = (num_chars + nulls) / 2;
    linkage->type = GU_NAME_TYPE;

    for (i = 0; i < nulls; i++)
    {
        p_name[num_chars + i] = '\0';
    }
    blkmv((num_chars + nulls), p_name, (IGRchar *) &linkage->data);

  wrap_up:

    return(status);
}
