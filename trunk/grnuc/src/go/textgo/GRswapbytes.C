/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRswap_bytes
 
     Abstract:  This routine swaps the bytes in a 16-bit string because
                Font Server expects unsigned shorts.
-----
%SC%

     VALUE =  GRswap_bytes(msg,text_string,text_length,swapped_string)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                   DESCRIPTION
     ----------   ------------     -------------------------------------
     *text_string IGRuchar         character string
     text_length  IGRshort         length of text string
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -------------------------------------
     *msg         IGRlong        Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
     *swapped_string IGRuchar    string with chars swapped

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES INVOKED: 

-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
        
        DEK  06/13/88 : Design date.
        DEK  06/13/88 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine swaps the bytes in a 16-bit string because Font
Server expects unsigned shorts.
----*/
/*EH*/

#include "igrtypedef.h"
#include "msdef.h"
#include "msmacros.h"
#include "FS.h"
#include "OMmacros.h"
#include "gotextdef.h"
#include "grimport.h"

IGRboolean GRswap_bytes(msg,text_string,text_length,swapped_string)

IGRlong              *msg;
IGRuchar             *text_string;
IGRshort             text_length;
IGRuchar             *swapped_string;
{
   IGRshort            ii;              /* index counter                */
   CharId              temp_text;       /* temporay storage as a short  */
   IGRuchar            hi;              /* hi byte of short character   */
   IGRuchar            lo;              /* lo byte of short character   */

   *msg = MSSUCC;

   for (ii = 0; ii < text_length; ii++, text_string++)
   {
      hi = *text_string;
      text_string++;
      lo = *text_string;

      temp_text = (unsigned short) ( (hi << 8) + lo);

      OM_BLOCK_MOVE(&temp_text,&swapped_string[ii],2);

      ii++;
   }
   return (TRUE);
}

