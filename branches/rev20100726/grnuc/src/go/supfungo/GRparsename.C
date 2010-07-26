/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRparse_name_desc

Description
   This routine takes a char string keyed in as a "name,description"
   and splits the name and description into different buffers.

   *msg           IGRlong     Completion code
   *input_strptr  IGRchar     Pointer to a char string.
   *name          IGRchar     Pointer to a buffer for symbol name
   *name_len      IGRint      Number of character in symbol name
   *desc          IGRchar     Pointer to a buffer for symbol desc
   *desc_len      IGRint      Number of character in symbol desc


Return Values
   MSSUCC   if successful
   MSFAIL   if failure

History
   BC  06/17/86  : Design and Creation date.
   HGW 08/14/86  : Header and changed terminology.
\*/

#include "grimport.h"
#include "igrtypedef.h"
#include "msdef.h"

IGRint GRparse_name_desc(msg, input_strptr, name, name_len, desc, desc_len)
IGRlong        *msg;
IGRchar        *input_strptr;
IGRchar        *name;
IGRint         *name_len;
IGRchar        *desc;
IGRint         *desc_len;
{
IGRint        index = 0,j = 0,num_blanks = 0;
IGRint        char_found = 0;

   *msg = MSSUCC;

   while (input_strptr[index] != ',' &&
          input_strptr[index] != '\0')
   {
      if (input_strptr[index] == ' ') 
      {
         if (char_found ) 
         {
            ++num_blanks;
            name[j++] = input_strptr[index++];
         }else
         {
            ++index;
         }
      }else                /* valid text ,put in name buffer */
      {
         name[j++] = input_strptr[index++];
         char_found = 1;
         num_blanks = 0;                /* leave blanks embedded */
      }
   }  /* end while */

   if (num_blanks)
   {
      j = j - num_blanks;   /* backup symbol name to last 
                               char (remove trail blanks)*/
   }
   name[j++] = '\0'; /* null after last char        */        
   *name_len = j;           /* len + null */

/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
/*            if no comma keyed in, skip description    */
/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

   if (input_strptr[index] == '\0')
   {
      desc[0] = '\0';
      desc_len = 0;
      goto exit;
   }
    
   index++; /* inc past comma */
   j = 0;
   num_blanks = 0;
   char_found = 0;
   while (input_strptr[index] != '\0')
   {
      if (input_strptr[index] == ' ') 
      {
         if (char_found )        /* test for blanks at end */
                                 /* but leave embedded blanks */
         {
            num_blanks++;
            desc[j++] = input_strptr[index++];
         }else    /* no text yet ,pop past blank*/
         {
            index++;
         }
      }else    /* valid text copy to description buff*/
      {
         desc[j++] = input_strptr[index++];
         char_found = 1;
         num_blanks = 0;
      }
   }                /*   end while        */

   if (num_blanks)
   {
      j = j - num_blanks;  /* backup symbol name to last 
                              char (remove trail blanks)*/
   }
   desc[j++] = '\0';   /* null after last char        */        
   *desc_len = j;             /* len + null                  */

exit:
   return(1);
}

