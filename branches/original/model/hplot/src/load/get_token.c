/* get_token.c */
/* get a token from file */

#include "odi.h"
#include <ctype.h>
#include <stdio.h>

int get_token (token_string, fp, line)
  char	  token_string [];	/* the chars read */
  FILE  * fp;			/* file to read from */
  int	* line;			/* line counter for input file */

  /* function value:	*/
  /*	EOF	end of file fp */
  /*	i	integer */
  /*	f	floating */
  /*	e	e format floating (eg. 1.0e6) */
  /*	w	alphanumeric or _ word -- does not need to start with alpha */
  /*	x	hex integer */
  /*	'	'string' */
  /*	"	"string" */
  /*	else	the first char of token_string */
{
  int	  token;		/* the token to return */
  int	  c;			/* current char */
  int	  i;			/* current token length */
  int	  j, jj;		/* counters */
  char	  sign_ok = 0;		/* signed number ok here */

  i = 0;
  token = NULL;
  token_string [0] = NULL;

/* leading white space */
  do
    {
      c = getc (fp);
      if (c == '\n') ++ * line;
    }
  while (isspace (c));

  if (isdigit (c))
    {
/* numeric (maybe) */
      token = 'i';
numeric:
      for (;;)
        {
          token_string [i++] = c;
          c = getc (fp)
            ;
          if (isdigit (c))
            ;
          else if (isalpha (c))
            {
              if (isxdigit (c) && token == 'x')
                ;
              else if (c == 'x' && token == 'i' && i == 1 &&
                  token_string [0] == '0')
                token = 'x';
              else if ((c == 'e' || c == 'E') && (token == 'i' || token == 'f'))
                {
                  token = 'e';
                  sign_ok = 1;
                  continue;
                }
              else token = 'w';
            }
          else if (c == '_')
            token = 'w';
          else if (c == '.' && token == 'i')
            token = 'f';
          else if ((c == '-' || c == '+') && sign_ok)
            ;
          else break;
          sign_ok = 0;
        }
      ungetc (c, fp);
    }
  else if (isalpha (c) || c == '_')
    {
/* word */
      token = 'w';
      for (;;)
        {
          token_string [i++] = c;
          c = getc (fp);
          if (! isalnum (c) && c != '_') break;
        }
      ungetc (c, fp);
    }
  else
    {
      token = c;
      switch (c)
        {
/* 'string' and "string" */
          case '\'':
          case '"':
            for (;;)
              {
                c = getc (fp);
                if (c == token || c == '\n') break;
                if (c == '\\')
                  {
                    c = getc (fp);
                    switch (c)
                      {
                        case 'b':
                          c = '\b';
                          break;
                        case 'f':
                          c = '\f';
                          break;
                        case 'n':
                          c = '\n';
                          break;
                        case 'r':
                          c = '\r';
                          break;
                        case 't':
                          c = '\t';
                          break;
                        case 'v':
                          c = '\v';
                          break;
                        case '0':
                        case '1':
                        case '2':
                        case '3':
                        case '4':
                        case '5':
                        case '6':
                        case '7':
                          jj = 0;
                          for (j = 0; j < 3; ++ j)
                            {
                              jj = (jj << 3) + (c - '0');
                              c = getc (fp);
                              if (c < '0' || c > '7')
                                {
                                  ungetc (c, fp);
                                  break;
                                }
                            }
                          c = jj;
                          break;
                        default:
                          break;
                      }
                  }
                token_string [i++] = c;
              }
            if (c == '\n') ++ * line;
            break;
/* end of file */
          case EOF:
            token_string [i++] = c;
            break;
/* paired brackets and terminators */
          case '(':
          case ')':
          case '{':
          case '}':
          case '[':
          case ']':
          case ';':
            token_string [i++] = c;
            break;
/* . or .fraction */
          case '.':
            token_string [i++] = c;
            c = getc (fp);
            if (isdigit (c))
              {
                token = 'f';
                goto numeric;
              }
            ungetc (c, fp);
            break;
/* other, get to next non-special case */
          default:
            for (;;)
              {
                token_string [i++] = c;
                c = getc (fp);
                if (! ispunct (c)) break;
                if (c == '_' ||
                    c == '(' ||
                    c == ')' ||
                    c == '{' ||
                    c == '}' ||
                    c == '[' ||
                    c == ']' ||
                    c == ';' ||
                    c == '"' ||
                    c == '\'') break;
              }
            if (c == '\n') ++ * line;
            if (! isspace (c)) ungetc (c, fp);
            break;
        }
    }
  token_string [i] = NULL;
  return token;
} /* get_token */
