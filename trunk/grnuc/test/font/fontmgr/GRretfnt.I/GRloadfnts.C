/* #######################    APOGEE COMPILED   ######################## */
/*----
 
     Abstract:    This is a test function which will retrieve the fonts
                specified in input/fontlist file.  If there is an error, an
                appropriate error message will be printed out to stderr.

----*/

#include  "OMminimum.h"
#include  "igetypedef.h"
#include  "igrtypedef.h"
#include  "grmessage.h"
#include  "OMerrordef.h"
#include  "exmacros.h"
#include  "msdef.h"
#include  "codef.h"
#include  "fontdef.h"
#include  "fontmacros.h"
#include  <stdio.h>

main()
{
    FILE     *file_ptr;
    IGRlong  msg;
    IGRint   sts;
    IGRshort font_flags,
             font_position;
    IGRchar  font_name[64],
             user_name[64];

    /* read each entry in the file input/filelist and attempt to retrieve the
     * specified font
     */

    if (file_ptr = fopen("input/fontlist", "r"))
    {
        while (fscanf(file_ptr, "%s%s%hd", font_name, user_name, &font_flags) != EOF)
        {
            sts = font$retrieve(msg = &msg,
                                font = font_name,
                                local_font_name = user_name,
                                font_flags = font_flags,
                                font_position = &font_position);

            if (! (1 & sts & msg))
            {
                if (msg == GR_E_MxNoFtLdd)
                {
                    fprintf(stderr, "Maximum number of fonts have been retrieved\n");
                }
                else if (msg == GR_E_FtNotFnd)
                {
                    fprintf(stderr, "Font %s was not found\n", font_name);
                }
                else if ((msg == GR_E_FtNmeLdd) ||
                         (msg == GR_E_FtLdd))
                {
                    /* these cases aren't really errors */
                }
                else
                {
                    fprintf(stderr, "Error retrieving font %s\n", font_name);
                }
            }
        }

        fclose(file_ptr);
    }
    else  /* could not open file input/fontlist */
    {
        fprintf(stderr, "Could not open input/fontlist\n");
    }
}
