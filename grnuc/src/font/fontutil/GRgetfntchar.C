/* #######################    APOGEE COMPILED   ######################## */

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "fontdef.h"
#include "font.h"

IGRint GRgetfontchar (fontinfo, charcode, font, newcode )

struct vfont_entry	*fontinfo;
IGRuchar 	*charcode;
IGRshort		*font;
IGRuchar *newcode;

{
 
    extern int KJ_u_getfontchar();

    /*
     *  Get font number and character code for the 16 bit character.
     */

    if (fontinfo->fontfile[0] == 'k')
    {
        KJ_u_getfontchar ( charcode, font, newcode );

        if ( *font != 0 )
        {
            /*
             *  Add offset of 50 to index returned.
             *  Valid font numbers are 0 and 30 - 71.
             */

            *font += 50;
        }
    }
    else  /* assuming the text is Korean */
    {
        *font = charcode[0];
        *font &= 127;
        *newcode = charcode[1];
    }

    return(TRUE);
}
