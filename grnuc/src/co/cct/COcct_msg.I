class implementation COcctform;

/*
 *   Filename:   COcct_msg.I
 *   Programmer:   C. M. Jablonski
 *   Creation Date:   January 1989
 *
 *   This file contains the actions that manipulate the message field:
 *
 *   print_message      - prints the given string in the message field
 *
 *   clear_message_field   - clears the message field
 *
 *   History:
 */


#include <stdio.h>
#include "cct.h"

/*----- print_message --------------------------------------------------------*/
method print_message ( int form_label; int msg_num )

/*
 * ABSTRACT:   Print_message prints the given string in the message field.
 *
 * HISTORY:   01/11/89  Created.            C. M. Jablonski
 */

{
  char        buffer[100];

   ex$message( msgnumb = msg_num, buff = buffer );
   FIfld_set_text( me->forms[form_label].form_ptr, FIELD_MESSAGE, 0, 0, buffer, FALSE );

   return(OM_S_SUCCESS);
}


/*----- clear_message_field --------------------------------------------------*/

method clear_message_field ( int form_label )

/*
 * ABSTRACT:   Clear_message_field clears the message field by printing in it
 *      the null string.
 *
 * HISTORY:   01/11/89  Created.            C. M. Jablonski
 */

{
   FIfld_set_text( me->forms[form_label].form_ptr, FIELD_MESSAGE, 0, 0, "", FALSE );
            
   return( OM_S_SUCCESS );
}

end implementation COcctform;
