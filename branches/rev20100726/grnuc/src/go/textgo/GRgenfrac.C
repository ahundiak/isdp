/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRgen_fraction
 
     Abstract:  This routine generates a fraction string from the character
                string.
-----
%SC%

     VALUE =  GRgen_fraction(msg,string,fraction,num_chars)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                   DESCRIPTION
     ----------   ------------     -------------------------------------
     *string      IGRuchar         character string (not yet fraction)
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -------------------------------------
     *msg         IGRlong        Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
     *fraction    IGRuchar       string with fraction code
     *num_chars   IGRshort       number of chars in fraction string

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
        
        DEK  03/24/88 : Design date.
        DEK  03/24/88 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
    This routine generates a fraction string from the character 
string. A change font escape sequence begins the fraction string, 
changing to the active fraction font. The fraction is derived from 
the character string and the appropriate character code is inserted. 
Then a pop to previous font escape sequence ends the fraction string.
----*/
/*EH*/

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "ex.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "gotextdef.h"
#include "OMmacros.h"
#include "grimport.h"

IGRboolean GRgen_fraction(msg,string,fraction,num_chars)

IGRlong            *msg;            /* completion code                      */
IGRuchar           *string;         /* character string                     */
IGRuchar           *fraction;       /* string containing fraction code      */
IGRshort           *num_chars;      /* number of chars in fraction string   */
{
   IGRint             numerator;          /* numerator of fraction        */
   IGRint             denominator;        /* denominator of fraction      */
   IGRuchar           fraction_id;        /* character code of fraction   */
   IGRlong            nbytes_in_buffer;
   IGRlong            nbytes_transferred;
   struct GRdpb_text_symb  text_symbology;

   *msg = MSSUCC;
   fraction_id = 0x00;

   numerator = denominator = 0; /* purify fix */

   /*
    * extract the fraction from the character string
    */

   sscanf((IGRchar *)string,"%d/%d",&numerator,&denominator);

   /*
    * get the active fraction font
    */

   nbytes_in_buffer = sizeof(struct GRdpb_text_symb);

   gr$get_text_symb(msg = msg,
                    sizbuf = &nbytes_in_buffer,
                    buffer = &text_symbology,
                    nret = &nbytes_transferred);

   if (text_symbology.Active_fraction_font == -1)
   {
      /*
       * an active fraction font is not available
       */

      *msg = MSFAIL;
   }
   else
   {
      if (denominator == 2)
      {
         if (numerator == 1)
         {
            fraction_id = 0x20;
         }
         else
         {
            *msg = MSINARG;
         }
      }
      else if (denominator == 4)
      {
         if (numerator == 1)
         {
            fraction_id = 0x21;
         }
         else if (numerator == 3)
         {
            fraction_id = 0x22;
         }
         else
         {
            *msg = MSINARG;
         }
      }
      else if (denominator == 8)
      {
         if (numerator == 1)
         {
            fraction_id = 0x23;
         }
         else if (numerator == 3)
         {
            fraction_id = 0x24;
         }
         else if (numerator == 5)
         {
            fraction_id = 0x25;
         }
         else if (numerator == 7)
         {
            fraction_id = 0x26;
         }
         else
         {
            *msg = MSINARG;
         }
      }
      else if (denominator == 16)
      {
         if (numerator == 1)
         {
            fraction_id = 0x27;
         }
         else if (numerator == 3)
         {
            fraction_id = 0x28;
         }
         else if (numerator == 5)
         {
            fraction_id = 0x29;
         }
         else if (numerator == 7)
         {
            fraction_id = 0x2a;
         }
         else if (numerator == 9)
         {
            fraction_id = 0x2b;
         }
         else if (numerator == 11)
         {
            fraction_id = 0x2c;
         }
         else if (numerator == 13)
         {
            fraction_id = 0x2d;
         }
         else if (numerator == 15)
         {
            fraction_id = 0x2e;
         }
         else
         {
            *msg = MSINARG;
         }
      }
      else if (denominator == 32)
      {
         if (numerator == 1)
         {
            fraction_id = 0x2f;
         }
         else if (numerator == 3)
         {
            fraction_id = 0x30;
         }
         else if (numerator == 5)
         {
            fraction_id = 0x31;
         }
         else if (numerator == 7)
         {
            fraction_id = 0x32;
         }
         else if (numerator == 9)
         {
            fraction_id = 0x33;
         }
         else if (numerator == 11)
         {
            fraction_id = 0x34;
         }
         else if (numerator == 13)
         {
            fraction_id = 0x35;
         }
         else if (numerator == 15)
         {
            fraction_id = 0x36;
         }
         else if (numerator == 17)
         {
            fraction_id = 0x37;
         }
         else if (numerator == 19)
         {
            fraction_id = 0x38;
         }
         else if (numerator == 21)
         {
            fraction_id = 0x39;
         }
         else if (numerator == 23)
         {
            fraction_id = 0x3a;
         }
         else if (numerator == 25)
         {
            fraction_id = 0x3b;
         }
         else if (numerator == 27)
         {
            fraction_id = 0x3c;
         }
         else if (numerator == 29)
         {
            fraction_id = 0x3d;
         }
         else if (numerator == 31)
         {
            fraction_id = 0x3e;
         }
         else
         {
            *msg = MSINARG;
         }
      }
      else if (denominator == 64)
      {
         if (numerator == 1)
         {
            fraction_id = 0x3f;
         }
         else if (numerator == 3)
         {
            fraction_id = 0x40;
         }
         else if (numerator == 5)
         {
            fraction_id = 0x41;
         }
         else if (numerator == 7)
         {
            fraction_id = 0x42;
         }
         else if (numerator == 9)
         {
            fraction_id = 0x43;
         }
         else if (numerator == 11)
         {
            fraction_id = 0x44;
         }
         else if (numerator == 13)
         {
            fraction_id = 0x45;
         }
         else if (numerator == 15)
         {
            fraction_id = 0x46;
         }
         else if (numerator == 17)
         {
            fraction_id = 0x47;
         }
         else if (numerator == 19)
         {
            fraction_id = 0x48;
         }
         else if (numerator == 21)
         {
            fraction_id = 0x49;
         }
         else if (numerator == 23)
         {
            fraction_id = 0x4a;
         }
         else if (numerator == 25)
         {
            fraction_id = 0x4b;
         }
         else if (numerator == 27)
         {
            fraction_id = 0x4c;
         }
         else if (numerator == 29)
         {
            fraction_id = 0x4d;
         }
         else if (numerator == 31)
         {
            fraction_id = 0x4e;
         }
         else if (numerator == 33)
         {
            fraction_id = 0x4f;
         }
         else if (numerator == 35)
         {
            fraction_id = 0x50;
         }
         else if (numerator == 37)
         {
            fraction_id = 0x51;
         }
         else if (numerator == 39)
         {
            fraction_id = 0x52;
         }
         else if (numerator == 41)
         {
            fraction_id = 0x53;
         }
         else if (numerator == 43)
         {
            fraction_id = 0x54;
         }
         else if (numerator == 45)
         {
            fraction_id = 0x55;
         }
         else if (numerator == 47)
         {
            fraction_id = 0x56;
         }
         else if (numerator == 49)
         {
            fraction_id = 0x57;
         }
         else if (numerator == 51)
         {
            fraction_id = 0x58;
         }
         else if (numerator == 53)
         {
            fraction_id = 0x59;
         }
         else if (numerator == 55)
         {
            fraction_id = 0x5a;
         }
         else if (numerator == 57)
         {
            fraction_id = 0x5b;
         }
         else if (numerator == 59)
         {
            fraction_id = 0x5c;
         }
         else if (numerator == 61)
         {
            fraction_id = 0x5d;
         }
         else if (numerator == 63)
         {
            fraction_id = 0x5e;
         }
         else
         {
            *msg = MSINARG;
         }
      }
      else
      {
         *msg = MSINARG;
      }
   }

   if (*msg == MSSUCC)
   {
      fraction[0] = ESC;
      fraction[1] = 'f';

      OM_BLOCK_MOVE(&text_symbology.Active_fraction_font,&fraction[2],2);

      fraction[4] = fraction_id;
      fraction[5] = ESC;
      fraction[6] = 'p';
      fraction[7] = POP_FONT;

      *num_chars = 8;
   }
   else
   {
      strcpy((IGRchar *)fraction,(IGRchar *)string);
      *num_chars = strlen((IGRchar *)string);
   }

   return(TRUE);
}
