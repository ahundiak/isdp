/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

    CLASS  NAME:  GRtext
    METHOD NAME:  GRgettxattr

    Abstract: This method returns the text specific attributes of a
              text object, the text length (in bytes) and the text string.
-----
%SC%    
        GRgettxattr(msg,text_attr,text_length,text_string)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE               DESCRIPTION
      -----------  ------------   ------------------------------------

-----
%EX%
     ON EXIT:

        NAME        DATA TYPE                      DESCRIPTION
     ----------    ------------   -----------------------------------
     *msg          IGRlong        completion code
                                  MSSUCC - successful completion
                                  MSFAIL - couldn't allocate memory
     *text_attr    struct IGRestx text specific information; if a
                                  NULL pointer is sent the structure
                                  is not returned
     *text_length  IGRshort       text string length (in bytes); if
                                  a NULL pointer is sent the length
                                  is not returned
     **text_string IGRuchar       text string; if a NULL pointer is
                                  sent the string is not returned
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
     Methods:
-----
%RL%

     RELATIONS REFERENCED:
        none.
-----
%NB%

     NOTES:   Memory for the text string will be allocated by this routine.
              The caller of this routine is responsible for deallocating
              this memory when they are through with it.
-----
%CH%

     CHANGE HISTORY:
        
        WBC     09/03/86 : Design date.
        WBC     09/03/86 : Creation date.
        WBC     10/09/87 : Modified to return text length
        WBC     09/20/88 : Modified to allocate memory for the
                           text string.
        SCW     07/21/92 : Ansi conversion
-----
%PD%
----------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
----------------------------------------------------------------------
   This method returns the text specific attributes, text length (in
bytes) or the text string of a text object.
----*/
/*EH*/

class implementation GRtext;

#include "msdef.h"
#include "gotextdef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "grimport.h"

method GRgettxattr(IGRlong *msg; struct IGRestx *text_attr;
                   IGRshort *text_length; IGRuchar **text_string)
{
    /*
     * assign the text specific attributes to the input structure if requested
     */

    *msg = MSSUCC;

    if (text_attr)
    {
        *text_attr = ME.GRtext->attr;

        /*
         * if this is an empty text object, set text length to zero although
         * the text string will contain the the text object's name (if it's
         * named) and the text length will be the length of that name
         */

        if (ME.GRtext->attr.flag & EMPTY_TEXT_FLAG)
        {
            text_attr->text_length = 0;
        }
    }

    /*
     * assign the text length to the text length argument if requested
     */

    if (text_length)
    {
        /*
         * if this is an empty text object, set text length to zero although
         * the text string will contain the the text object's name (if it's
         * named) and the text length will be the length of that name
         */

        if (ME.GRtext->attr.flag & EMPTY_TEXT_FLAG)
        {
            *text_length = 0;
        }
        else
        {
            *text_length = ME.GRtext->attr.text_length;
        }
    }

    /*
     * allocate memory for and assign the text string to the
     * text string argument if requested
     */

    if (text_string)
    {
        /*
         * if this is an empty text object, set text string pointer to NULL
         * although the text string will contain the the text object's name
         * (if it's named)
         */

        if (ME.GRtext->attr.flag & EMPTY_TEXT_FLAG)
        {
            *text_string = NULL;
        }
        else
        {
            if (*text_string = (IGRuchar *)om$malloc(
                                size = (IGRint)ME.GRtext->attr.text_length))
            {
                OM_BLOCK_MOVE(ME.GRtext->text_string,*text_string,
                              ME.GRtext->attr.text_length);
            }
            else
            {
                /*
                 * no memory was allocated; if text length is greater than
                 * zero, om$malloc failed
                 */

                if (ME.GRtext->attr.text_length)
                {
                    *msg = MSFAIL;
                }
            }
        }
    }

    return(OM_S_SUCCESS);
}

end implementation GRtext;
