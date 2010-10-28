#include <string.h>
#include <stdio.h>

find_decimals (str, no)
  char *str;
  int  no;
  {
    char i_str[81];
    char str1[81], str2[81], str3[81]; 
    int  i = 0, j =0, k = 0;
    int  value;
   
    sscanf (str, "%80s", i_str);
    while (i <= no)
      {
        if (i_str[i] == '.')
         {
           k++; 
           j = 0;
         }
        else
         {
           if (k == 0) 
             str1[j] = i_str[i];
           if (k == 1)
             str2[j] = i_str[i];
           if (k == 2)
             str3[j] = i_str[i];
           j++;
         }
         i++;
      }
    if (k >= 0 ) 
      sscanf (str1, "%d", &value);
    if (k >= 1) 
      {
        i = value;
        sscanf (str2, "%d", &j);
        value = j + (i * 256);
      }
    if (k >= 2)
      {
        sscanf (str3, "%d", &value);  
        value = value + (j * 256) + (i * 4096);
      }
    return (value);
  }

convert_version (str)
  char *str;
  
  {
    int   len_str, out_val;
   
    len_str = strlen (str);
    out_val = find_decimals (str, len_str);
    return (out_val);
  }
