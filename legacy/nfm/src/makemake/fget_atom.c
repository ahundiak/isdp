
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include <stdio.h>
#include <ctype.h>

static int fga_line_pos=0;
int atomic_line_position=0;


int fget_atom (atom,infile)
char *atom;
FILE *infile;
 {
  int i;
  int c;
  int nc;

  while (1)
   {
    c = getc (infile);
    if (c == EOF) return (0);
    if (isgraph(c)) break;
    fga_line_pos++;
    if (c == '\n')
     fga_line_pos=0;
   }
  atomic_line_position = fga_line_pos;
  i = 0;
  if ((c == '#') || (isalnum(c)) || (c == '_') || (c=='.'))
   {
    while ((c == '#') || (isalnum(c)) || (c == '_') || (c=='.'))
     {
      atom[i] = c;
      i++;
      c = getc (infile);
      fga_line_pos++;
      if (c == '\n')
       fga_line_pos=0;
      if (c==EOF)
       {
        atom[i] = 0;
        return (1);
       }
     }
    ungetc (c,infile);
    fga_line_pos--;
    atom[i] = 0;
   }
  else
   {
    if (c == '\"')
     {
      c = fgetc (infile);
      if (c == EOF)
       {
        atom[i] = 0;
        return (0);
       }
      while (c != '\"')
       {
        c = fgetc (infile);
        if (c == EOF)
         {
          atom[i] = 0;
          return (0);
         }
       }
     }
    else if (c == '/')
     {
      nc = getc (infile);
      fga_line_pos++;
      if (nc == '\n')
       fga_line_pos=0;
      if (nc == '*')
       {   /* inside comment */
        c = getc (infile);
        fga_line_pos++;
        if (c == '\n')
         fga_line_pos=0;
        while (1)
         {
          if (c == '*')
           {
            c = getc (infile);
            fga_line_pos++;
            if (c == '\n')
             fga_line_pos=0;
            if (c == '/')
             return (fget_atom(atom,infile));
           }
          else
           {
            c = getc (infile);
            fga_line_pos++;
            if (c == '\n')
             fga_line_pos=0;
           }
         }
       }
      else
       {
        ungetc (nc,infile);
        fga_line_pos--;
       }
     }
    atom[i] = c;
    atom[i+1] = 0;
   }
  return (1);
 }
