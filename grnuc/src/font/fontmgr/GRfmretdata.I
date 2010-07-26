/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              GRfm 
     METHOD NAME:             GRfm_retdata
 
     Abstract:

              This routine returns the instance data contained
              in the virtual font entry of the requested font.
-----
%SC%

    VALUE = GRfm_retdata(IGRlong *msg; IGRshort *vfont_num;
                         struct vfont_entry *vfont)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------
    *vfont_num    IGRshort          virtual font number
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
     ----------     ---------------  --------------------------------------
     *msg           IGRlong          completion code
     *vfont         struct vfont_entry  instance data of virtual font entry

     VALUE (IGRlong) =    MSSUCC   - if successful
                          MSFAIL   - if failure
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
        
        WBC  02/05/86 : Design date.
        WBC  02/05/86 : Creation date.
        DEK  11/10/87 : Changed for font server.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This routine returns the instance data contained in the virtual 
font entry of the requested font.

----*/
/*EH*/

class implementation GRfm;

#include "grimport.h"
#include "OMerrordef.h"
#include "OMmacros.h"

method GRfm_retdata(IGRlong *msg; IGRshort *vfont_num; struct vfont_entry *vfont)
{
    if (me^^GRfm.vfont[me^^GRfm.fast_font].def_flag == defined)
    {
        if (*vfont_num < me^^GRfm.num_entries )
        {
           *msg = MSSUCC;

           strcpy((char *)((*vfont).fontfile),
                  (char *)(me^^GRfm.vfont[*vfont_num].fontfile));
           strcpy((char *)((*vfont).vfontname),
                  (char *)(me^^GRfm.vfont[*vfont_num].vfontname));
           (*vfont).fontid = me^^GRfm.vfont[*vfont_num].fontid;
           (*vfont).bodysize = me^^GRfm.vfont[*vfont_num].bodysize;
           (*vfont).descent = me^^GRfm.vfont[*vfont_num].descent;
           (*vfont).flags = me^^GRfm.vfont[*vfont_num].flags;
           (*vfont).def_flag = me^^GRfm.vfont[*vfont_num].def_flag;
        }
        else
        {
           *msg = MSINARG;

           strcpy((char *)((*vfont).fontfile),
                  (char *)(me^^GRfm.vfont[me^^GRfm.fast_font].fontfile));
           strcpy((char *)((*vfont).vfontname),
                  (char *)(me^^GRfm.vfont[me^^GRfm.fast_font].vfontname));
           (*vfont).fontid = me^^GRfm.vfont[me^^GRfm.fast_font].fontid;
           (*vfont).bodysize = me^^GRfm.vfont[me^^GRfm.fast_font].bodysize;
           (*vfont).descent = me^^GRfm.vfont[me^^GRfm.fast_font].descent;
           (*vfont).flags = me^^GRfm.vfont[me^^GRfm.fast_font].flags;
           (*vfont).def_flag = me^^GRfm.vfont[me^^GRfm.fast_font].def_flag;

        }

    }
    else
    {
        *msg = MSFAIL;  /* fast font is not downloaded */
    }
    return(OM_S_SUCCESS);

}

end implementation GRfm;
