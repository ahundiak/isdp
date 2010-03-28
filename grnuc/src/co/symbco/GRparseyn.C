/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRparseyn

Description
   This function returns a flag that states whether a string
   contains yes or no.  If the string does not contain either
   then MSFAIL is returned.

   *msg           IGRlong           return code 
   string[]       IGRchar           The character string.
   *flag          IGRint            Flag
                                       TRUE  -  Yes
                                       FALSE -  No

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn    02/02/87    Creation date.
   Gray Winn    11/16/87    Changes for version 1.1
\*/

#include "coimport.h"
#include "igrtypedef.h"
#include "msdef.h"

IGRint GRparseyn (msg, string, flag)
IGRlong  *msg;
IGRchar  string[];
IGRint   *flag;
{
IGRchar  ans_string[4];
IGRint   i;

   *msg = MSSUCC;
   *flag = NULL;

   /* 
    *   Accept the following keyins:  "y", "yes", "n", "no" in
    *   caps or noncaps.
    */

   for ( i = 0 ; i < 3 && string[i]; i ++ ) 
     ans_string[i] = tolower(string[i]);

    ans_string[i] = '\0';

   if ( ( (!strcmp(ans_string, "no")  && (strlen(string) == 2)) ||
        ( (ans_string[0] == 'n') )    && (strlen(string) == 1)) )
   {
      /* 
       *  A no keyin.
       */

      *flag = FALSE;      
   }else if ( ((!strcmp(ans_string,"yes") && (strlen(string) == 3)) ||
              ((ans_string[0] == 'y') )   && (strlen(string) == 1)) )
   {                  
      /*
       *  A yes keyin.
       */
      *flag = TRUE;
   }else
   {
      *msg = MSFAIL;
   }
   return(1);
}
