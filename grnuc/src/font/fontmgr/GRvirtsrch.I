/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              GRfm 
     METHOD NAME:             GRvirt_search
 
     Abstract:
                This routine searches the virtual font library for a specified
                virtual font name or number and returns the name or position 
                of the virtual font.  If searching for the virtual font number,
                the virtual font number should be set to -1 on entry.
-----
%SC%

    VALUE = GRvirt_search(IGRlong *msg; IGRuchar *vfont_name;
                          IGRshort *position)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------
    *vfont_name   IGRuchar  virtual font name
    *vfont_number  IGRshort          virtual font number
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
     ----------     -------------- -------------------------------------------
     *msg           IGRlong           completion code
     *vfont_name    IGRuchar  virtual font name
     *vfont_number  IGRshort          virtual font number

     VALUE (IGRlong) =    MSSUCC   - if successful
                          MSFAIL   - if failure (font not found)
                          MSINARG  - if invalid virtual font number
-----
%MD%

     MODULES AND METHODS INVOKED:

     modules:

     methods:

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  10/28/87 : Design date.
        DEK  10/28/87 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This method searches the vitual font table for a specified font
using the font's virtual name or number.  The font's position or 
local list name is returned if found.  If searching for the virtual 
font number, the virtual font number should be set to -1 on entry.

----*/
/*EH*/

class implementation GRfm;

#include  "grimport.h"
#include  "OMerrordef.h"

method GRvirt_search(IGRlong *msg; IGRuchar *vfont_name;
                     IGRshort *vfont_num)
{
    IGRshort   i;

    *msg = MSFAIL;

    /*
     *  Search the virtual font table for the the specified font.
     */

    if (*vfont_num == -1)
    {
        for (i=0; i < me^^GRfm.num_entries; ++i)
        {
            if ((me^^GRfm.vfont[i].def_flag != undefined) &&
                (strcmp((char *)vfont_name,
                        (char *)(me^^GRfm.vfont[i].vfontname)) == 0))
            {
                *vfont_num = i;
                *msg = MSSUCC;
                break;
            }
        }
    }
    else
    {
        if ((*vfont_num >= 0) && (*vfont_num < me^^GRfm.num_entries))
        {
            if (me^^GRfm.vfont[*vfont_num].def_flag != undefined)
            {
                strcpy((char *)vfont_name,
                       (char *)(me^^GRfm.vfont[*vfont_num].vfontname));
                *msg = MSSUCC;
            }
        }
        else
        {
            *msg = MSINARG;
        }
    }
    return(OM_S_SUCCESS);
}

end implementation GRfm;
