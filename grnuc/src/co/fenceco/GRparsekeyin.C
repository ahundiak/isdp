/* #######################    APOGEE COMPILED   ######################## */

/*\
Name
   GRparse_multiple_entry_keyin

Description
   This function will take a string and parse the string.  The string
   can be any sequence of numbers between low and high.  The number may
   be seperated by commas or by hyphens (inclussion of all the numbers
   between the numbers seperated by the hyphen).

   string[]             IGRchar           The string to be parsed.
   buffer[]             IGRchar unsigned  The buffer to contain the 
                                          parsed string.  Each bit in
                                          the buffer represents that
                                          number.
   (*conversion_func)() IGRint            The function to convert an
                                          ascii string to a number.
   alpha                IGRint            If FALSE allows only numbers,
                                          if TRUE allows alphanumeric
   low                  IGRint            The lowest allowable number
   high                 IGRint            The highest allowable number + 1
   osnum                OMuword           Object space number

History
   Gray Winn   07/02/87    Creation date
   scw         07/10/92    ansi conversion
\*/

#include "coimport.h"
#include <ctype.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "wl.h"
#include "igecolor.h"
#include "igecolmacros.h"

#define gen_bit_set(addr,bit_no)  *(((char *) (addr))+((bit_no)/8)) |= \
                                    ( 1 << ((bit_no)%8))

#define gen_bit_clear(addr,bit_no) *(((char *) (addr))+((bit_no)/8)) &= \
                                    ~( 1 << ((bit_no)%8))

GRparse_multiple_entry_keyin (string, buffer, conversion_func, alpha,
                              low, high, osnum)
IGRchar           string[];
IGRuchar          buffer[];
IGRint            (*conversion_func)();
IGRint            alpha;
IGRint            low;
IGRint            high;
OMuword           osnum;
{
IGRchar  temp1[80];
IGRchar  temp2[80];
IGRint   i,j;
IGRint   length;
IGRint   start;
IGRint   end_number;
IGRint   start_number;

   /*
    *  Clear all the bits in the buffer.
    */

   for (i = low; i < high; ++i)
   {
      gen_bit_clear(buffer, i);
   }

   length = strlen(string);
   if (!length) return(0);

   for (i = 0, start = 0; i < length; ++i)
   {
      /* 
       *  The characters have been validated.
       */

      if (start > i) continue;

      if (string[i] == ',')
      {
         if (start >= i) return(0);
         for (j=start; j < i; ++j) temp1[j - start] = string[j];
         temp1[j - start] = '\0';

         if (conversion_func(temp1, &start_number, low, high, osnum))
         {
            gen_bit_set(buffer,start_number);
            start = i + 1;
         }else
         {
            return(0);
         }
      }else if (string[i] == '-')
      {
         if (start >= i) return(0);
         for (j=start; j < i; ++j) temp1[j - start] = string[j];
         temp1[j - start] = '\0';

         for (j=i+1, start = length; j < length; ++j)
         {
            if ((alpha && !isalnum(string[j])) ||
                (!alpha && !isdigit(string[j])))
            {
               /*
                *  A comma is the only allowable character.
                */

               if (string[j] == ',')
               {
                  if (j + 1 >= length) return(0);
                  start = j + 1;
               }else if (j != '\0')
               {
                  return(0);
               }
               break;    
            }
            temp2[j - (i + 1)] = string[j];
         }
         temp2[j - (i + 1)] = '\0';

         if (conversion_func(temp1, &start_number, low, high, osnum) &&
             conversion_func(temp2, &end_number, low, high, osnum))
         {
            if (end_number - start_number >= 0)
            {
               for (j=start_number; j <= end_number; ++j)
               {
                   gen_bit_set(buffer,j);
               }
            }else
            {
               for (j=end_number; j <= start_number; ++j)
               {
                   gen_bit_set(buffer,j);
               }
            }
         }else
         {
            return(0);
         }
      }else if (alpha)
      {
         if (!isalnum(string[i])) return(0);
      }else
      {
         if (!isdigit(string[i])) return(0);
      }
   }

   if (start < length)
   {
      if (conversion_func(&string[start], &start_number, low, high, osnum))
      {
         gen_bit_set(buffer, start_number);
      }else
      {
         return(0);
      }
   }
   return(1);
}

/*\
Name
   GRnumber_conversion

Description
   This function will take a string which should contain an ascii number 
   and convert the it to a numeric value.

   string[]             IGRchar           The string to be parsed.
   *number              IGRint            The numeric value of the string.
   low                  IGRint            The lowest allowable number
   high                 IGRint            The highest allowable number + 1
   osnum                OMuword           Object space number

History
   Gray Winn   07/02/87    Creation date
\*/


#argsused
IGRint GRnumber_conversion (string, number, low, high, osnum)
IGRchar  string[];
IGRint   *number;
IGRint   low;
IGRint   high;
OMuword  osnum;
{
IGRint   status;

   if (status = sscanf(string, "%d", number))
   {
      if ((*number >= low) && (*number < high))
      {
         return(status);
      }else
      {
         return(0);
      }
   }
   return(status);
}
 
/*\
Name
   GRcolor_conversion

Description
   This function will take a string which should contain an ascii number
   and convert it to a number which represents a color.

   string[]             IGRchar           The string to be parsed.
   *number              IGRint            The number representing a color
   low                  IGRint            The lowest allowable number
   high                 IGRint            The highest allowable number + 1
   osnum                OMuword           Object space number

History
   Gray Winn   07/02/87    Creation date
\*/
IGRint GRcolor_conversion (string, number, low, high, osnum)
IGRchar  string[];
IGRint   *number;
IGRint   low;
IGRint   high;
OMuword  osnum;
{
IGRint   status;
IGRint   length;
IGRint   i;
IGRshort temp;

   status = ige$get_color_from_name( name = string, color = &temp,
            mod_osnum = osnum);

   *number = (IGRint)temp;
   if (!(status & 1))
   {
      /*
       *  Insure that the string is composed of only digits.
       */

      length = strlen(string);
      for (i=0; i < length; ++i) if (!isdigit(string[i])) return(0);

      if (status = sscanf(string, "%d", number))
      {
         if ((*number >= low) && (*number < high))
         {
            return(status);
         }else
         {
            return(0);
         }
      }
   }
   return(status);
}
