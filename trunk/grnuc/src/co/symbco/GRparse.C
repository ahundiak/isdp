/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRparse

Description
   This routine takes a char string keyed in as a symbol name, symbol
   description and splits the name and description into different buffers.

   *msg           IGRlong        completion code
   *input_strptr  IGRchar        Pointer to a char string.
   *symbol_name   IGRchar        pointer to a buffer for symbol name
   *name_len      IGRint         Number of character in symbol name
   *symbol_desc   IGRchar        pointer to a buffer for symbol desc
   *desc_len      IGRint         Number of character in symbol desc

Return Values
   MSSUCC   if successful
   MSFAIL   if failure

History
   BC  06/17/86  : Design date and Creation date.
   HGW 08/14/86  : Header and changed terminology.
   HGW 11/17/87  : Changes for version 1.1
\*/

#include "coimport.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "grsymdef.h"

IGRint GRparse( msg, input_strptr, symbol_name, name_len, symbol_desc,
                 desc_len)
IGRlong        *msg;
IGRchar        *input_strptr;
IGRchar        *symbol_name;
IGRint         *name_len;
IGRchar        *symbol_desc;
IGRint         *desc_len;
{
IGRint        index = 0,j = 0,num_blanks = 0;
IGRshort       char_found = 0;

   *msg = MSSUCC;

   while (input_strptr[index] != ',' &&
          input_strptr[index] != '\0')
   {
       *name_len = j - num_blanks;
       
       if (*name_len == MAX_SYMBOL_DEF_NAME - 1)
       {
           break;
       }
       
      if (input_strptr[index] == ' ') 
      {
         if (char_found ) 
         {
            ++num_blanks;
            symbol_name[j++] = input_strptr[index++];
         }else
         {
            ++index;
         }
      }else                /* valid text ,put in name buffer */
      {
         symbol_name[j++] = input_strptr[index++];
         char_found = 1;
         num_blanks = 0;                /* leave blanks embedded */
      }
   }  /* end while */

   if (num_blanks)
   {
      j = j - num_blanks;   /* backup symbol name to last 
                               char (remove trail blanks)*/
   }
   symbol_name[j++] = '\0'; /* null after last char        */        
   *name_len = j;           /* len + null */

/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
/*            if no comma keyed in, skip description    */
/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

   if (input_strptr[index] == '\0')
   {
      symbol_desc[0] = '\0';
      desc_len = 0;
      goto exit;
   }
    
   index++; /* inc past comma */
   j = 0;
   num_blanks = 0;
   char_found = 0;
   while (input_strptr[index] != '\0')
   {
       *desc_len = j - num_blanks;
       
       if (*desc_len == MAX_SYMBOL_DEF_DESC - 1)
       {
           break;
       }
       
      if (input_strptr[index] == ' ') 
      {
         if (char_found )        /* test for blanks at end */
                                 /* but leave embedded blanks */
         {
            num_blanks++;
            symbol_desc[j++] = input_strptr[index++];
         }else    /* no text yet ,pop past blank*/
         {
            index++;
         }
      }else    /* valid text copy to description buff*/
      {
         symbol_desc[j++] = input_strptr[index++];
         char_found = 1;
         num_blanks = 0;
      }
   }                /*   end while        */

   if (num_blanks)
   {
      j = j - num_blanks;  /* backup symbol name to last 
                              char (remove trail blanks)*/
   }
   symbol_desc[j++] = '\0';   /* null after last char        */        
   *desc_len = j;             /* len + null                  */

exit:
   return(1);
}

