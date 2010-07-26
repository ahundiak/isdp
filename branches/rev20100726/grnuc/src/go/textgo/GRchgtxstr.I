/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

    CLASS  NAME:  GRtext
    METHOD NAME:  GRchgtxstring

    Abstract: This method processes a text string and returns the updated
            extents of the text string.  The text string and text length
            (of the text object) may be changed.  The number of displayable
            characters is also updated.
-----
%SC%    
        GRchgtxstring(msg,text_symb,font_info,num_positions,
                      positions,text_extents)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE               DESCRIPTION
    - ----------  ------------   ------------------------------------
    *text_symb    struct GRdpb_text_symb     text symbology
    *font_info    struct vfont_entry         font information
    num_positions IGRint                     # of positions to update
    *positions[]  IGRshort                   positions in the text
                                             string to update (NULL
                                             pointer if num_positions
                                             == 0)
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg           IGRlong         completion code
                                    MSSUCC - successful completion
                                    MSFAIL - failure
    *positions[]  IGRshort                   updated positions in
                                             the text string
    *text_extents struct extents             updated extents of the
                                             text object
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  GRjust_string
               GRnum_disp_char
     Methods:
-----
%RL%

     RELATIONS REFERENCED:
        none.
-----
%NB%

     NOTES:
        none.
-----
%CH%

     CHANGE HISTORY:
        
        WBC     09/03/86 : Design date.
        WBC     09/03/86 : Creation date.
        WBC     01/01/87 : Changed to update the number of
                           displayable characters.
        WBC     11/17/87 : Changed to use font server.
        SCW     07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This method changes the text object's length and text string (if
necessary) to make the correct justification moves.  It also returns
the updated extents of the text object.  The number of displayable
characters is also updated.
----*/
/*EH*/

class implementation GRtext;

#include   "msdef.h"
#include   "fontdef.h"
#include   "font.h"
#include   "gotext.h"
#include   "OMmacros.h"
#include   "grimport.h"

method GRchgtxstring(IGRlong *msg; struct GRdpb_text_symb *text_symb;
                     struct vfont_entry *font_info; IGRint num_positions;
                     IGRshort *positions[]; struct extents *text_extents)
{
    extern IGRboolean GRjust_string();/* justifies text string (inserts or  */
                                      /* deletes justifications moves) and   */
                                      /* returns the extents                 */
    IGRuchar          *string;        /* ptr to malloced memory text string  */
    IGRlong           temp_msg;       /* temporary message                   */
    IGRshort          text_buf_size;  /* amount of memory allocate for string*/

    *msg = MSSUCC;

    if (me^^GRtext.attr.text_length)
    {
        /*
         * copy the instance data text string into malloced memory
         * since GRjust_string may reallocate memory for the string
         */

        string = (IGRuchar *)om$malloc(size = me^^GRtext.attr.text_length);

        if (string)
        {
            OM_BLOCK_MOVE(me^^GRtext.text_string,string,
                          (IGRint)me^^GRtext.attr.text_length);
        }
        else  /* failure allocating memory */
        {
           *msg = MSFAIL;
        }
    }
    else  /* text length is zero; don't need to allocate any memory */
    {
        string = NULL;
    }

    if (*msg == MSSUCC)
    {
        /*
         *  justify (update) text string
         */

        text_buf_size = me^^GRtext.attr.text_length;

        GRjust_string(&temp_msg,&string,&me^^GRtext.attr.text_length,
                      &text_buf_size,font_info,&me^^GRvg.display_attr,
                      text_symb,0,NULL,text_extents);

        /*
         * allocate memory in the text object for the justified text string
         */

        om$vla_set_dimension(varray = me^^GRtext.text_string,
                             size = (IGRint)me^^GRtext.attr.text_length);

        /*
         *  update the number of displayable characters in the text object
         */

        GRnum_disp_char(&temp_msg,string,&me^^GRtext.attr.text_length,
                        me^^GRtext.attr.font,font_info->flags,
                        &me^^GRtext.attr.num_char);

        /*
         * if the string pointer is not NULL (text object is not empty),
         * copy the justified text string back into the instance data vla and
         * deallocate the memory used by string
         */

        if (string)
        {
            OM_BLOCK_MOVE(string,me^^GRtext.text_string,
                          (IGRint)me^^GRtext.attr.text_length);

            om$dealloc(ptr = string);
        }
    }

    return(OM_S_SUCCESS);
}

end implementation GRtext;
