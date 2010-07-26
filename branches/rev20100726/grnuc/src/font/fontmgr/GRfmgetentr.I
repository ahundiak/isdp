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
     METHOD NAME:             GRfm_get_entries
 
     Abstract:

              This routine returns the number of defined font
              entries and a list of which ones they are.
-----
%SC%

    VALUE = GRfm_get_entries(IGRlong *msg; IGRshort *num_entries;
                             IGRshort *entries)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------

-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
     ----------     ---------------  --------------------------------------
     *msg           IGRlong          completion code
     *num_entries   IGRshort         number of defined entries in font mgr
     *entries       IGRshort         array of entries that are defined

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

     NOTES:  Entries is an array of shorts (should be MAX_FONT size to ensure
             the array is large enough). Upon exit, the first short will
             contain the virtual font number of the first defined font; the
             second short will contain the virtual font number of the next
             defined font; and so on. Entries will be valid only through 
             num_entries which is also returned.
-----

%CH%
     CHANGE HISTORY:
        
        DEK  08/04/88 : Design date.
        DEK  08/04/88 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine returns the number of defined font entries and a 
list of which ones they are.
----*/
/*EH*/

class implementation GRfm;

#include "grimport.h"
#include "OMerrordef.h"

method GRfm_get_entries(IGRlong *msg; IGRshort *num_entries; IGRshort *entries)
{
   IGRshort           i,j;            /* index counter                 */

   *msg = MSSUCC;
   *num_entries = 0;
   j = 0;

   for (i = 0; i < me^^GRfm.num_entries; ++i)
   {
      if (me^^GRfm.vfont[i].def_flag == defined)
      {
         ++(*num_entries);
         entries[j] = i;
         ++j;
      }
   }

   return(OM_S_SUCCESS);

}

end implementation GRfm;
