/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              GRfm 
     METHOD NAME:             GRphy_search
 
     Abstract:
                This routine searches the virtual font library for a
                specified physical font. If the specified font is found,
                its virtual font name will be returned.
-----
%SC%

   VALUE = GRphy_search(IGRlong *msg; IGRuchar *fontfile;
                        IGRuchar *vfont_name)
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
    *msg           IGRlong           completion code
    *vfont_name    IGRuchar  virtual font name

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
        
        DEK  10/28/87 : Design date.
        DEK  10/28/87 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This method searches the vitual font table for a specified font.
If the specified font is found, its virtual font name will be 
returned.

----*/
/*EH*/

class implementation GRfm;

#include  "grimport.h"
#include  "OMerrordef.h"

method GRphy_search(IGRlong *msg; IGRuchar *fontfile;
                    IGRuchar *vfont_name)
{
    IGRshort i;

    *msg = MSFAIL;

    /*
     *  Search the virtual font table for the the specified font.
     */

    for (i=0; i < me^^GRfm.num_entries; ++i)
    {
        if (((me^^GRfm.vfont[i].def_flag == defined) ||
             (me^^GRfm.vfont[i].def_flag == reserved)) &&
            (strcmp((char *)fontfile,
                    (char *)(me^^GRfm.vfont[i].fontfile)) == 0))
        {
           strcpy((char *)vfont_name,(char *)(me^^GRfm.vfont[i].vfontname));
           *msg = MSSUCC;
           break;
        }
    }
    return(OM_S_SUCCESS);
}

end implementation GRfm;
