/* ---------------------------- get_escape ------------------------------*/
#include <sli.h>

int get_escape ( fp )
  FILE	* fp ;
{
  int	val;
  int	j;
  char	ch;

  ch = getc ( fp );
  switch ( ch )
    {
      case 'b':
        ch = '\b';
        break;
      case 'f':
        ch = '\f';
        break;
      case 'n':
        ch = '\n';
        break;
      case 'r':
        ch = '\r';
        break;
      case 't':
        ch = '\t';
        break;
      case 'v':
        ch = '\v';
        break;
      case '\n':
        ch = 0;
        break;
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
        val = ch - '0';
        for ( j = 0; j < 2; ++ j )
          {
            ch = getc ( fp );
            switch ( ch )
              {
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                  val = ( val << 3 ) + ch - '0';
                  break;
                default:
                  ungetc ( ch, fp );
                  return val;
              }
          }
        return val;
        /*break;*/
    }
  return ch;
} /* get_escape */
