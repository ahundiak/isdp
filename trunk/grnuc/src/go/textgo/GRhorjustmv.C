/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME    GRhorizontal_just_mv
 
     Abstract:

            This function calculates the horizontal justification move
        necessary to get from the justification point to the stroke
        start point.
-----
%SC%

     VALUE =  GRhorizontal_just_mv(message,text_just,text_width,
                                   just_info,h_move)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   ------------------------------------
     text_just    IGRshort         justification code
     text_width   IGRdouble        text_width
     *just_info   struct just_info justification information
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   -----------------------------------
     *message     IGRlong        completion code
                                  - MSSUCC     if successful
                                  - MSFAIL     if failure
     *h_move      IGRdouble      horizontal justification move

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

#define MAETA 1.0e-15

extern IGRdouble fabs();         /* returns the absolute value of a   */
                                 /* double                            */

IGRboolean GRhorizontal_just_mv(message,text_just,text_width,
                                just_info,h_move)

IGRlong          *message;          /* completion code                   */
IGRshort         text_just;         /* justification code                */
IGRdouble        text_width;        /* text width                        */
struct just_info *just_info;        /* justification information         */
IGRdouble        *h_move;           /* horizontal justification move     */
{
   IGRboolean       value;          /* return code                       */

   /*
    *  initialize return codes
    */

   value = TRUE;
   *message = MSSUCC;
   *h_move = 0;                     /* initialize horizontal move       */

   /*
    *  horizontal justifications
    */

   switch (text_just / 5)
   {
      case 0:                      /* left justification               */

         *h_move = -(just_info->cur_line_left);

         break;

      case 1:                 /* center justification             */

         *h_move = -(just_info->cur_line_right + just_info->cur_line_left) / 2;

         /*
          *  if *h_move / text_width is smaller than a certain tolerance,
          *  set it equal to zero (because of machine precision error)
          */

         if (fabs(*h_move / text_width) < MAETA)
         {
            *h_move = 0;
         }
         break;

      case 2:                 /* right justification              */

         *h_move =  -(just_info->cur_line_right);

         break;

      default:                          /* invalid justificaion             */

         value = FALSE;
         *message = MSFAIL;
         break;
   }                        /* end horizontal justification switch */

   /* calculate horizontal move to stroke start point */

   *h_move /= text_width;

   return(value);
}
