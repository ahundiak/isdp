class implementation Root;
#include <stdio.h>
#include <ctype.h>
#include <string.h>

   void EMtofloat(char *char_array, double *number)
   {

   int multiplier=1;
   float divider=.10;
   int jj,kk,neg_flag=0;

   *number = 0.0; 

     for(jj=0; char_array[jj] != '.'; jj++)
         ;
         
         for(kk=jj-1; kk > 0; kk-- )
           {
            if (isdigit(char_array[kk]))
              *number += (char_array[kk]-48)* multiplier;
            else
              break;
            multiplier *= 10;
           }

         if (char_array[kk] == '-')
           neg_flag=1;

         for(kk=jj+1; char_array[kk] != '\0'; kk++ )
            {
            if (isdigit(char_array[kk]))
              *number += (char_array[kk]-48)* divider;
            else
              break;
            divider /= 10;
            }

         if(neg_flag ==1)
            *number= 0.0 - *number;
          
}
            
            
end  implementation Root;
