/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

    CLASS  NAME:  GRtext
    METHOD NAME:  GRdpemptytext

    Abstract: This method will either display an empty text element and set
              its display and locate bits or erase an empty text element
              and clear its display and locate bits.
-----
%SC%    
        GRdpemptytext(msg,display,matrix_type,matrix)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE               DESCRIPTION
    ------------  ------------   ------------------------------------
    display       IGRboolean     - TRUE if empty text element is to
                                 be displayed and the elements locate
                                 and display bits are to be set;
                                 - FALSE if empty text element is
                                 to be erased and the elements locate
                                 and display bits are to be cleared
    *matrix_type  IGRshort       matrix type
    matrix        IGRmatrix      matrix
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg           IGRlong         completion code
                                    MSSUCC - successful completion
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

     NOTES:
        none.
-----
%CH%

     CHANGE HISTORY:
        
        WBC     03/31/88 : Design date.
        WBC     03/31/88 : Creation date.
        SCW     07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This method will either display an empty text element and set
its display and locate bits or erase an empty text element and
clear its display and locate bits.
----*/
/*EH*/

class implementation GRtext;

#include   "grimport.h"
#include   "msdef.h"
#include   "fontdef.h"
#include   "font.h"
#include   "gotextdef.h"
#include   "gotext.h"
#include   "dpmacros.h"

method GRdpemptytext(IGRlong *msg; IGRboolean display; IGRshort *matrix_type;
                     IGRmatrix matrix)
{
    *msg = MSSUCC;

    /*
     *  if the text string is empty, display or erase it
     */

    if (me^^GRtext.attr.flag & EMPTY_TEXT_FLAG)
    {
        struct   GRid    buffer;
        IGRmatrix        *matr[1];      /* matrix ptr for display  */

        buffer.objid = my_id;
        buffer.osnum = OM_Gw_current_OS;
        matr[0] = (IGRmatrix *)matrix;

        if (display)
        {
            /*
             *  must set the displayable bit in the text object's property
             *  bitmask before the text can be displayed
             */

            me^^GRgraphics.properties |= (GRIS_DISPLAYABLE | GRIS_LOCATABLE);

            dp$display(msg = msg,
                       mode = GRbd,
                       oids = &buffer,
                       mtx_type = (IGRlong *)matrix_type,
                       matrix = matr);
        }
        else
        {
            /*
             *  must display the text before the displayable bit in the text
             *  object's property bitmask is cleared
             */

            dp$display(msg = msg,
                       mode = GRbe,
                       oids = &buffer,
                       mtx_type = (IGRlong *)matrix_type,
                       matrix = matr);

            me^^GRgraphics.properties &= ~(GRIS_DISPLAYABLE | GRIS_LOCATABLE);
        }
    }
    return(OM_S_SUCCESS);
}

end implementation GRtext;
