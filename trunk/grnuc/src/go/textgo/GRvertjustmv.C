/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME    GRvertical_just_mv
 
     Abstract:

          This function calculates the vertical justification move
        necessary to get from the justification point to the vertical
        stroke start point.
-----
%SC%

     VALUE =  GRvertical_just_mv(message,text_just,text_height,
                                 text_extents,v_move)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   ------------------------------------
     text_just     IGRshort       justification code
     text_height   IGRdouble      text height
     *text_extents struct extents unjustified extents of text string
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                  DESCRIPTION
     ----------   ------------   -----------------------------------
     *message     IGRlong        completion code
                                  - MSSUCC     if successful
                                  - MSFAIL     if failure
     *v_move      IGRdouble      vertical justification move

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
   This function calculates the vertical justification move
necessary to get from the justification point to the vertical
stroke start point.
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

extern IGRdouble     fabs();     /* returns the absolute value of a   */
                                 /* double                            */

IGRboolean GRvertical_just_mv(message,text_just,text_height,
                              text_extents,v_move)

IGRlong          *message;          /* completion code                   */
IGRshort         text_just;         /* justification code                */
IGRdouble        text_height;       /* text height                       */
struct extents   *text_extents;     /* unjustified extents of text string*/
IGRdouble        *v_move;           /* vertical justification move       */
{
   IGRboolean    value;             /* return code                       */

   /*
    *  initialize return codes
    */

   value = TRUE;
   *message = MSSUCC;
   *v_move = 0;                     /* initialize vertical move         */

   /*
    *  vertical justifications
    */

   switch (text_just % 5)
   {
      case 0:                 /* bottom justification        */

         *v_move = text_extents->bottom;
         break;

      case 1:                 /* baseline justification      */

         *v_move = text_extents->base;
         break;

      case 2:                 /* center justification        */

         *v_move = text_extents->top - 
                   ((text_extents->top - text_extents->bottom) / 2);

         /*
          *  if *v_move / text_height is smaller than a certain tolerance,
          *   set it equal to zero (because of machine precision error)
          */

         if (fabs(*v_move / text_height) < MAETA)
         {
            *v_move = 0;
         }
         break;

      case 3:                 /* cap justification           */

         *v_move = text_extents->cap;
         break;

      case 4:                 /* top justification           */

         *v_move = text_extents->top;
         break;

      default:                /* invalid justification       */

         value = FALSE;
         *message = MSFAIL;
         break;
   }                /* end vertical justification switch */

   /* calculate vertical move to stroke start point */

   *v_move /= text_height;

   return(value);
}
