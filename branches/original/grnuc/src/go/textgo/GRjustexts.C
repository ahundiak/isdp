/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME    GRjust_extents
 
     Abstract:

            This function justifies (adjusts) the extents of a text string
        relative to the text justification.
-----
%SC%

     VALUE =  GRjust_extents(message,text_just,num_lines,
                             text_extents,just_extents)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   -------------------------------------
     text_just    IGRshort       justification code
     num_lines    IGRshort       number of lines in the text string
     *text_extents struct extents extents of text string
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   -----------------------------------
     *message     IGRlong        completion code
                                  - MSSUCC     if successful
                                  - MSFAIL     if failure
     *just_extents struct extents justified extents of the text string

     VALUE (IGRboolean) = TRUE         - if successful
                          FALSE        - if failure
-----
%MD%

     FUNCTIONS INVOKED: 
-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:

        DEK  02/10/86 : Design date.
        DEK  02/17/86 : Creation date.
        WBC  07/09/86 : Updated for justifications.
        WBC  11/10/87 : Updated for use with font server
        SCW  07/22/92 : Removed copyright header
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
  This function justifies (adjusts) the extents of a text string
relative to the text justification.
----*/
/*EH*/

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "igrdp.h"
#include "gotext.h"
#include "grimport.h"

IGRboolean GRjust_extents(message,text_just,num_lines,
                          text_extents,just_extents)

IGRlong          *message;          /* completion code                   */
IGRshort         text_just;         /* justification code                */
IGRshort         num_lines;         /* number of lines in hte text string*/
struct extents   *text_extents;     /* extents of text string            */
struct extents   *just_extents;     /* justified extents of text string  */
{
   IGRboolean    value;             /* return value                      */
   IGRdouble     temp_origin[3];    /* temp storage while calculating    */
                                    /* origin                            */

   /*
    *  initialize return codes
    */

   value = TRUE;
   *message = MSSUCC;
   
   /*
    *  horizontal justifications
    */

   switch (text_just / 5)
   {
      case 0:                      /* left justification               */

         temp_origin[0] = text_extents->left;
         break;

      case 1:                 /* center justification             */

         temp_origin[0] = (text_extents->left + text_extents->right)/2;
         break;

      case 2:                 /* right justification              */

         temp_origin[0] = text_extents->right;
         break;

      default:                          /* invalid justificaion             */

         value = FALSE;
         *message = MSFAIL;
         break;
   }                        /* end horizontal justification switch */

   /*
    *  vertical justifications
    */

   switch (text_just % 5)
   {
      case 0:                 /* bottom justification        */

         temp_origin[1] = text_extents->bottom;
         break;

      case 1:                 /* baseline justification      */

         temp_origin[1] = text_extents->base;
         break;

      case 2:                 /* center justification        */

         if (num_lines > 1)    /*     multi-line text      */
         {
            temp_origin[1] = (text_extents->bottom + text_extents->top)/2;
         }
         else                             /*     single line text     */
         {
             temp_origin[1] = (text_extents->base + text_extents->cap)/2;
         }
         break;

      case 3:                 /* cap justification           */

         temp_origin[1] = text_extents->cap;
         break;

      case 4:                 /* top justification           */

         temp_origin[1] = text_extents->top;
         break;

      default:                /* invalid justification       */

         value = FALSE;
         *message = MSFAIL;
         break;
   }                /* end vertical justification switch */

   /* negate temp_origin */

   temp_origin[0] = 0 - temp_origin[0];
   temp_origin[1] = 0 - temp_origin[1];
   temp_origin[2] = 0;

   /* update text extents */

   just_extents->left = text_extents->left + temp_origin[0];
   just_extents->right = text_extents->right + temp_origin[0];
   just_extents->bottom = text_extents->bottom + temp_origin[1];
   just_extents->base = text_extents->base + temp_origin[1];
   just_extents->cap = text_extents->cap + temp_origin[1];
   just_extents->top = text_extents->top + temp_origin[1];

   return(value);
}
