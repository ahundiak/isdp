#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include "cpp.h"
#include "opp.h"
#include "cppout.h"

/* globals */
int cur_out_line = 1;
int last_line = -1;
char *last_file = 0;

int emit_lines;

#if defined(NT)
char	*convert_filename(char	*name)
{
	static	char	path[_MAX_PATH * 2];
	int		i;
	int		j;
	
	for (i = 0, j = 0; name[i]; ++i)
	{
		/*	Escape all backslashes	*/
		if ('\\' == name[i])
			path[j++] = '\\';
		path[j++] = name[i];
	}
	path[j] = 0;

	return path;
}
#endif

void get_to_line (oppout, line, name)
 FILE *oppout;
 int line;
 char *name;
 {
  if (!last_file || (last_file != name && strcmp (last_file, name)))
   {
    last_file = name;
    last_line = line;
    MARKIT;
   }
  else if (last_line != line)
   {
    int i;

    i = line - last_line;
    last_line = line;
    if ((i > 16) || (i < 0))
     {
      MARKIT;
     }
    else
     while (i--)
      {
       putc ('\n',oppout);
       cur_out_line++;
      }
   }
 } /* get_to_line */


void output_tok (oppout,ta)
FILE *oppout;
struct cpp_token *ta;
 {
  get_to_line (oppout, ta->line_no, ta->filename);
  PITS (oppout,ta->constr);
  putc (' ',oppout);
 } /* output_tok */


void oat (oppout)
FILE *oppout;
 {
  get_to_line (oppout, active_stream->tok.line_no, active_stream->tok.filename);
  PITS (oppout,active_stream->yytext);
  putc (' ',oppout);
 } /* oat */


void fdumpitf (FILE *oppout, char *fmt, ...)
 {
  va_list args;
  char liner[256];
  
  va_start(args, fmt);

  if (!last_file || (last_file != oppout_name && strcmp (last_file, oppout_name)))
   {
    last_file = oppout_name;
    last_line = cur_out_line+2;
    MARKIT;
   }
  vsprintf (liner,fmt,args);
  PITS (oppout,liner);
  va_end(args);
 } /* fdumpitf */



void rdumpitf(char *filename, int line_no, FILE *oppout, char *fmt, ...)
 {
  va_list args;
  char liner[256];

  va_start (args, fmt);
  
  get_to_line (oppout, line_no, filename);
  vsprintf (liner,fmt,args);
  PITS (oppout,liner);
  va_end(args);
 } /* rdumpitf */

static int save_cur_out_line = 1;
static int save_last_line = -1;
static char *save_last_file = 0;


void suspend ()
 {
  save_cur_out_line = cur_out_line;
  save_last_line = last_line;
  save_last_file = last_file;

  cur_out_line = 1;
  last_line = -1;
  last_file = 0;
 }

void restore ()
 {
  cur_out_line = save_cur_out_line;
  last_line = save_last_line;
 }

void merge (filea,fileb)
FILE *filea,*fileb;
 {
  int (c);

  last_file = save_last_file;
  c = getc (filea);
  while (1)
   {
    switch (c)
     {
      case '#' :
       {
        char liner[80];
        int j;
        putc ('#',fileb);
        fscanf (filea,"%s",liner);
        PITS (fileb,liner);
        if (strcmp(liner,"line")) /* liner != "line" */
         {
          c = getc (filea);
          break;
         }
        fscanf (filea,"%d %s\n",&j,liner);
        if (!strcmp(liner,oppout_name))
         {
          fprintf (fileb," %d %s\n",++cur_out_line,liner);
          last_line = cur_out_line;
          c = getc (filea);
          break;
         }
        fprintf (fileb," %d %s\n",j,liner);
        cur_out_line++;
        last_line = j;
        c = getc (filea);
        break;
       }
      case '\n' :
       last_line++;
       cur_out_line++;
      default :
       putc (c,fileb);
       c = getc (filea);
       break;
      case EOF:
       return;
     }
   }
 }
