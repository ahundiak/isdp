/* ---------------------------- get_token ------------------------------*/
/* returns:
/*	EOF for eof
/*	char for single char or 'char'
/*	IDENT for identifier
/*	STRING for quoted string
/*	( KEYWORD + n ) for n-th keyword (0 first)
/* eats: space and c-style comments.
*/

#include "../sli/y.tab.h"
#include <sli.h>

int get_token ( fp, keywords, token_string )
  FILE	*  fp;
  char	** keywords;
  char	*  token_string;
{
  char		ch;
  char		str [2];
  int		j;

  * token_string = 0;
  str [1] = 0;
  while (( ch = getc (fp)) != EOF  )
    {
      if ( isalpha (ch) || ch == '_'  )
        {
          do
            {
              str [0] = ch;
              strcat ( token_string, str );
            }
          while ( isalnum ( ch = getc(fp)) || ch == '_' );
          ungetc ( ch, fp );
          if ( keywords )
            {
              j = 0;
              while ( * keywords )
                if ( !strcmp ( * keywords, token_string )) return KEYWORD + j;
                else
                  {
                    ++ keywords;
                    ++ j;
                  }
            }
          return IDENT;
        }
      else
        {
          switch (ch)
            {
              case '/':
                if (( ch = getc (fp)) == '*' )
                  {
                    do /****  eat comments  ****/
                      {
                        if ( getc (fp) == '*' )
                          if (( ch = getc (fp)) == '/' )
                            break; /* do while */
                          else
                            ungetc ( ch, fp );
                      }
                    while ( 1 );
                  }
                else
                  {
                    ungetc ( ch, fp );
                    return '/';
                  }
                break;

              case '"':
                while (( ch = getc(fp)) != '"' )
                  {
                    if ( ch == '\\' )
                      ch = get_escape ( fp );
                    str [0] = ch;
                    strcat ( token_string, str );
                  }
                return STRING;
                /*break;*/

              case '\'':
                while (( ch = getc(fp)) != '\'' )
                  {
                    if ( ch == '\\' )
                      ch = get_escape ( fp );
                    str [0] = ch;
                    strcat ( token_string, str );
                  }
                return * token_string;
                /*break;*/

              case ' ':
              case '\f':
              case '\n':
              case '\r':
              case '\t':
              case '\v':
                break;

              default:
                return ch;
                /*break;*/
            } /* end switch */
        } /* end else */
    } /* end while not eof */
  return EOF;
} /* get_token */
