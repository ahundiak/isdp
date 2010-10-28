#include <stdio.h>
#include <ctype.h>


int fread_infile (str,infile)
 char *str;
 FILE *infile;
 {
     int i = 0, c;

     while (1)
      {
          c = fgetc (infile);
          if (c == '#')
             while ((c != '\n') || (c == EOF)) c = fgetc (infile);
          if (c == EOF) return (0);
          if (isgraph(c)) break;
      }

    while (1)
     {
          if ((c == '#') || (c == EOF) || (isspace (c)))
           {
                ungetc (c, infile);
                str [i] = 0;
                return (1);
           }
          str[i] = (char) c;
          c = fgetc (infile);
          i++;
     }
 }
