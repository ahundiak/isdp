/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              GRfm 
     METHOD NAME:             GRisitfstfnt
 
     Abstract:

     This method determines if the specified font is a fast font.
     If it is the character fast font a 1 is returned in type; if
     it is the fraction fast font a 2 is returned in type. Otherwise
     a 0 is returned in type. If a fast font is found, the return
     message is MSSUCC.  If not, it's MSFAIL.

-----
%SC%

    VALUE = GRisitfstfnt(IGRlong *msg; IGRshort *vfont_num; IGRshort *type)
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
     ----------     -------------- -------------------------------------------
     *type          IGRshort       type of fast font
     *msg           IGRlong        completion code

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
        
        WBC  05/29/86 : Design date.
        WBC  05/29/86 : Creation date.
        DEK  03/29/88 : Added check for fast fraction font.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This method determines if the specified font is a fast font.
If it is the character fast font a 1 is returned in type; if it is
the fraction fast font a 2 is returned in type. Otherwise a 0 is 
returned in type. If a fast font is found, the return message is 
MSSUCC.  If not, it's MSFAIL.
----*/
/*EH*/

class implementation GRfm;

#include  "grimport.h"
#include  "OMerrordef.h"
#include  "OMmacros.h"

method GRisitfstfnt(IGRlong *msg; IGRshort *vfont_num; IGRshort *type)
{
    *msg = MSFAIL;
    *type = 0;

    if (*vfont_num == me^^GRfm.fast_font)
    {
        *type = 1;
        *msg = MSSUCC;
    }
    else if (*vfont_num == me^^GRfm.frac_fast_font)
    {
        *type = 2;
        *msg = MSSUCC;
    }
    else if (*vfont_num == me^^GRfm.symb_fast_font)
    {
        *type = 3;
        *msg = MSSUCC;
    }
    else if (*vfont_num == me^^GRfm.sixteen_fast_font)
    {
        *type = 4;
        *msg = MSSUCC;
    }

    return(OM_S_SUCCESS);
}

end implementation GRfm;
