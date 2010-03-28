/* #######################    APOGEE COMPILED   ######################## */
/*  This subroutine adds Bitstream font information to the user data linkage
    of an IGDS element, sets the A-bit in word 17 of the common
    header info, and updates words_to_follow in the common header
    info and in the attribute linkage.

    New values are written to the user data linkage: the u-bit is set
    to 1, user_id is set to 25, and user_type to 0.  Null characters are
    written to the linkage's end, if necessary, filling up the last
    4-byte memory block allocated for that user data linkage.
*/

#include    "exsysdep.h"
#include    "grimport.h"
#include    "OMminimum.h"
#include    "igrtypedef.h"
#include    "igetypedef.h"
#include    "igr.h"
#include    "transmacros.h"
#include    "msdef.h"
/*
#include    "OMmacros.h"
*/
#include    "transdef.h"
#include    "translate.h"
#include    "fontdef.h"
#include    "font.h"
#include    "fontmacros.h"
#include    "exlocaledef.h"
#include    "exlocale.h"

extern    int     strcmp();
extern    char    *strrchr();

IGRboolean GRfont_user_linkage(msg,font_parameters,slant_angle,
                               filled_text,ele_buf)

IGRlong         *msg;
struct EX_fonts *font_parameters;  /* locale parameters  */
IGRdouble       *slant_angle;
IGRint          filled_text;
IGRchar         *ele_buf;

{
    struct GUcommon_header_info  *ele;
    struct GUfont_linkage        *linkage;
    int                          num_chars, nulls, i;
    IGRboolean                   status;
    char                         *ext_ptr;
    IGRuchar 			 cm_name_length;
    IGRuchar 			 tf_name_length;
    IGRulong 			 vax_slant[2];
#ifdef BIG_ENDIAN
    IGRulong 			 swapped_int;
#endif

    status = TRUE;
    *msg = MSSUCC;

    /* Get common header info and set a pointer to the beginning of the
     * attribute linkage.  Then the length of the typeface and
     * character mapping names are used to determine how many null
     * characters must be written to fill up the last 4-word block of
     * the data linkage and to make sure the maximum element size is
     * not exceeded.
     */

    ele = (struct GUcommon_header_info *) ele_buf;
    linkage = (struct GUfont_linkage *) (&ele->words_to_follow +
    ele->words_to_follow + 1);

    /*
     * remove the .tf and .cm extensions from the typeface and
     * character mapping file names, respectively (if they have them)
     */

    if ((ext_ptr = strrchr(font_parameters->tf,'.')) &&
        (strcmp(ext_ptr,".tf") == 0))
    {
        ext_ptr[0] = '\0';
    }

    if ((ext_ptr = strrchr(font_parameters->cm,'.')) &&
        (strcmp(ext_ptr,".cm") == 0))
    {
        ext_ptr[0] = '\0';
    }

    /*
     * The number of words occupied by the user data linkage must be
     * a muliple of 4.  The linkage header contains 2 words, and this
     * user data has its own header which is 2 words long. The next
     * data item is a double which is 4 words long, which makes 8 words
     * so far. Since this is a multiple of 4, we only have to worry
     * about making the file names and their lengths a multiple of 4
     * words.  Words are 2 bytes and we are working with string lengths
     * in bytes, so we use modulus 8 instead of 4.
     */

    tf_name_length = strlen(font_parameters->tf);
    cm_name_length = strlen(font_parameters->cm);
    num_chars = tf_name_length + cm_name_length + 2;
    nulls = (i = (num_chars % 8)) ? 8 - i : 0;
    i = (num_chars + nulls)/2 + 7;

    if (((i + ele->words_to_follow + 1) <= GU_MAX_DGN_SIZE ) &&
        (i <= GU_MAX_ELE_LINK))
    {
        /*  Set  the properties word bit mask (which is the 17th
         *  word in the common header info) so the u-bit is set
         *  and increment the words_to_follow by the size of the
         *  user data linkage
         */

        linkage->header.words_to_follow = i;
        ele->properties |= IGDSAttributeData;
        ele->words_to_follow += linkage->header.words_to_follow + 1;

        /* Linkage data fields and bit masks are set.  Refer to the
         * IGDS Application Software Interface Document, appendix C,
         * for detailed descriptions of the linkage data structure.
         */

        linkage->header.properties = GU_LINKAGE_PROPS;
        linkage->header.user_id = GU_FILLPOLY_TYPE;
        linkage->length = i - 2;
        linkage->type = GU_FONT_TYPE;

		if (filled_text)
		{
	        linkage->properties = GU_FILLED_FONT;
		}
		else
		{
	        linkage->properties = 0;
		}

        if (font_parameters->properties & EX_Sixteen_Bit)
        {
            linkage->properties |= GU_SIXTEEN_BIT_FONT;
        }

        /*
         * 04/17/91 - the four high order bits in the properties word are
         * now being used as a version number; in version number 1 the
         * text size is the IGDS text size, and since that's how we are
         * going to write out the text size, set the version number to 1
         */

        linkage->properties |= GU_FS_LINK_VERSION;

        /*
         * insert the slant_angle, the typeface name length, the typeface
         * name, the character mapping name length and the character
         * mapping name into the user date region
         */

        flt32_to_fltvax(1,slant_angle,vax_slant);
#ifdef BIG_ENDIAN
	GRconv_int(&vax_slant[0],&swapped_int);
	vax_slant[0] = swapped_int;
	GRconv_int(&vax_slant[1],&swapped_int);
	vax_slant[1] = swapped_int;
#endif
        blkmv(8,vax_slant,(IGRchar * )&linkage->data_ptr);
        blkmv(1,&tf_name_length,(IGRchar *) &linkage->data_ptr + 8);
        blkmv(tf_name_length,font_parameters->tf,(IGRchar *) &linkage->data_ptr + 9);
        blkmv(1,&cm_name_length,(IGRchar *) &linkage->data_ptr + tf_name_length + 9);
        blkmv(cm_name_length,font_parameters->cm,
        (IGRchar *) &linkage->data_ptr + tf_name_length + 10);

        if (nulls)
        {
            IGRchar   null_buf[7];

            for (i = 0; i < nulls; ++i)
            {
                null_buf[i] = '\0';
            }
            blkmv(nulls,null_buf,&linkage->data_ptr +
                  tf_name_length + cm_name_length + 10);
        }
    }
    else  /* the user data linkage or text element exceeded limits */
    {
        *msg = MSFAIL;
        status = FALSE;
    }

    return(status);
}
