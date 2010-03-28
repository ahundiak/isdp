/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              GRfm 
     METHOD NAME:             GRduplicate_font
 
     Abstract:
                This routine searches the virtual font library for a
                specified physical font. If the specified font is found,
                its virtual font number will be returned.
-----
%SC%

   VALUE = GRduplicate_font(IGRlong *msg; IGRuchar *fontfile;
                            IGRshort *vfont_num)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------
    *fontfile     IGRuchar  font file name
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
    ----------     -------------- -------------------------------------------
    *msg           IGRlong        completion code
    *vfont_name    IGRshort       virtual font number

    VALUE (IGRlong) =   MSSUCC  - if successful
                        MSFAIL  - if failure (font not found)
-----
%MD%

     MODULES AND METHODS INVOKED:

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  02/01/88 : Design date.
        DEK  02/01/88 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This method searches the vitual font table for a specified font.
If the specified font is found, its virtual font number will be 
returned.

----*/
/*EH*/

class implementation GRfm;

#include  "grimport.h"
#include  "OMerrordef.h"

method GRduplicate_font(IGRlong *msg; IGRuchar *fontfile;
                        IGRshort *vfont_number)
{
    IGRshort i;

    *msg = MSFAIL;

    /*
     *  Search the virtual font table for the the specified font.
     */

    for (i=0; i < me^^GRfm.num_entries; ++i)
    {
        if ((me^^GRfm.vfont[i].def_flag != undefined) &&
            (strcmp((char *)fontfile,
                    (char *)(me^^GRfm.vfont[i].fontfile)) == 0))
        {
           *vfont_number = i;
           *msg = MSSUCC;
           break;
        }
    }
    return(OM_S_SUCCESS);
}

end implementation GRfm;
