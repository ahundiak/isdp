#include "FImin.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/**********************************************************************
This routine which byte a character starts in the string given the
character's position in the string.  The string can have either 16-bit
or 7-bit characters mixed together.
**********************************************************************/

/*  int	cpos;   ** INPUT - Character position		**/
/*  char	*s;	** INPUT - NULL terminated string	**/

int _FI_locate_16bit_start_byte (int  cpos,
                                 char *s)
{
  int	index = 0, ii;

  if ( cpos < 1 )
    {
	return 0;		/** assumed zero **/
    }

  for ( ii = 0; ii < cpos; ii++ )
    {
      if( !s[index] )
	{
	  return (-1);
	}

      if( !sbitset(s[index]) )
	{
	  index++;
	}
      else
	{
	  index += 2;
	}
    }

  return ( index );
}
