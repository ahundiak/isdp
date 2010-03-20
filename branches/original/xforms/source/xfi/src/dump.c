#include "FImin.h"

#include <stdio.h>
#include <setjmp.h>
#include "FIread.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

static FILE *FIfile;
static jmp_buf *FIenv;


int FI_write_int (FILE  *file,
                  int    value)
{
/* dmb:08/20/92: Changed for yap (yet another port */
#if !defined(i86pc)
#if defined (sparc) || defined (sun) || defined (mips) || defined (hp9000)
  int ii;
  int temp;
  char *tp, *vp;

  for ( ii = 0 , vp = (char *) &value ,
		tp = (char *) &temp + sizeof(int) - 1;
			ii < sizeof(int); ii++ , vp++ , tp--)
    {
	  *tp = *vp;
    }
  value = temp;
#endif
#endif

  if ( fwrite (&value, sizeof(int), 1, file ) != 1 )
    {
	  return ( FI_FORM_FILE_SAVE_ERROR );
    }
  else
    {
         return ( FI_SUCCESS);
    }
}


/* dmb:10/06/92:Changed float to double for ANSI */
int FI_write_float_ANSI (FILE   *file,
                         float   value)
{
/* dmb:08/20/92: Changed for yap (yet another port */
#if !defined(i86pc)
#if defined (sparc) || defined (sun) || defined (mips) || defined (hp9000)
  int ii;
  int temp;
  char *tp, *vp;

  for ( ii = 0 , vp = (char *) &value ,
		tp = (char *) &temp + sizeof(float) - 1;
			ii < sizeof(float); ii++ , vp++ , tp--)
    {
	  *tp = *vp;
    }
  value = temp;
#endif
#endif

  if ( fwrite (&value, sizeof(float), 1, file ) != 1 )
    {
	  return ( FI_FORM_FILE_SAVE_ERROR );
    }
  else
    {
         return ( FI_SUCCESS);
    }
}


/* 10/06/92:Added for ANSI */
int FI_write_float (FILE   *file,
                    double  value)
{
  return ( FI_write_float_ANSI(file, (float) value));
}

/* dmb:10/06/92:Changed float to double for ANSI */
int FI_write_short_ANSI (FILE  *file,
                         short  value)
{
/* dmb:08/20/92: Changed for yap (yet another port */
#if !defined(i86pc)
#if defined (sparc) || defined (sun) || defined (mips)  || defined (hp9000)
  int ii;
  short temp;
  char *tp, *vp;

  for (ii = 0 , vp = (char *) &value ,
		tp = (char *) &temp + sizeof(short) - 1;
			ii < sizeof(short); ii++ , vp++ , tp--)
    {
	  *tp = *vp;
    }
  value = temp;
#endif
#endif

  if ( fwrite (&value, sizeof(short), 1, file ) != 1 )
    {
	  return ( FI_FORM_FILE_SAVE_ERROR );
    }
  else
    {
         return ( FI_SUCCESS);
    }
}

/* 10/06/92:Added for ANSI */
int FI_write_short (FILE   *file,
                    int     value)
{
  return ( FI_write_short_ANSI(file, (short) value));
}


int FI_write_double (FILE   *file,
                     double  value)
{
/* dmb:08/20/92: Changed for yap (yet another port */
#if !defined(i86pc)
#if defined (sparc) || defined (sun) || defined (mips)  || defined (hp9000)
  int ii;
  double temp;
  char *tp, *vp;

  for (ii = 0 , vp = (char *) &value ,
		tp = (char *) &temp + sizeof(double ) - 1;
			ii < sizeof(double ); ii++ , vp++ , tp-- )
    {
	  *tp = *vp;
    }
  value = temp;
#endif
#endif

  if ( fwrite (&value, sizeof(double ), 1, file ) != 1 )
    {
	  return ( FI_FORM_FILE_SAVE_ERROR );
    }
  else
    {
         return ( FI_SUCCESS);
    }
}


/*--------------------------------------------------------------------*/

void _FI_dump_char (char value)
{
  if ( fwrite (&value, sizeof(char), 1, FIfile ) != 1 )
    {
	  longjmp (*FIenv, FI_FORM_FILE_SAVE_ERROR );
    }
}



void _FI_dump_int (int value)
{
/* dmb:08/20/92: Changed for yap (yet another port */
#if !defined(i86pc)
#if defined (sparc) || defined (sun) || defined (mips) || defined (hp9000)
  int ii;
  int temp;
  char *tp, *vp;

  for ( ii = 0 , vp = (char *) &value ,
		tp = (char *) &temp + sizeof(int) - 1; ii < sizeof(int);
				ii++ , vp++ , tp--)
    {
	  *tp = *vp;
    }
  value = temp;
#endif
#endif

  if ( fwrite (&value, sizeof(int), 1, FIfile ) != 1 )
    {
	  longjmp (*FIenv, FI_FORM_FILE_SAVE_ERROR );
    }
}


void _FI_dump_short (short value)
{
/* dmb:08/20/92: Changed for yap (yet another port */
#if !defined(i86pc)
#if defined (sparc) || defined (sun) || defined (mips) || defined (hp9000)
  int ii;
  short temp;
  char *tp, *vp;

  for ( ii = 0 , vp = (char *) &value ,
		tp = (char *) &temp + sizeof(short) - 1;
			ii < sizeof(short); ii++ , vp++ , tp-- )
    {
      *tp = *vp;
    }
  value = temp;
#endif
#endif

  if ( fwrite (&value, sizeof(short), 1, FIfile ) != 1 )
    {
      longjmp (*FIenv, FI_FORM_FILE_SAVE_ERROR );
    }
}


void _FI_dump_double (double value)
{
/* dmb:08/20/92: Changed for yap (yet another port */
#if !defined(i86pc)
#if defined (sparc) || defined (sun) || defined (mips) || defined (hp9000)
  int ii;
  double temp;
  char *tp, *vp;

  for (ii = 0 , vp = (char *) &value ,
		tp = (char *) &temp + sizeof(double ) - 1;
			ii < sizeof(double ); ii++ , vp++ , tp--)
    {
	  *tp = *vp;
    }
  value = temp;
#endif
#endif

  if ( fwrite (&value, sizeof(double ), 1, FIfile ) != 1 )
    {
	  longjmp (*FIenv, FI_FORM_FILE_SAVE_ERROR );
    }
}


void _FI_dump_string (char *string)
{
  short nl;
  short temp;

/* dmb:08/20/92: Changed for yap (yet another port */
#if !defined(i86pc)
#if defined (sparc) || defined (sun) || defined (mips) || defined (hp9000)
  int ii;
  char *tp, *vp;
#endif
#endif

  if (string)
    {
	  nl = strlen (string);
    }
  else
    {
	  nl = 0;
    }

  temp = nl;

/* dmb:08/20/92: Changed for yap (yet another port */
#if !defined(i86pc)
#if defined (sparc) || defined (sun) || defined (mips) || defined (hp9000)

  for ( ii = 0, vp = (char *) &nl,
		tp = (char *) &temp + sizeof(short) - 1;
			ii < sizeof(short); ii++ , vp++ , tp-- )
    {
	  *tp = *vp;
    }
#endif
#endif

  if ( fwrite (&temp, sizeof(short), 1, FIfile ) != 1 )
    {
	  longjmp (*FIenv, FI_FORM_FILE_SAVE_ERROR );
    }

  if ( nl )
    {
      if ( fwrite (string, nl, 1, FIfile ) != 1 )
	{
	  longjmp (*FIenv, 5);
	}
    }
}



void _FI_dump_enter (FILE     *fp,
                     jmp_buf   env)
{
  FIfile = fp;
  FIenv = (jmp_buf *) env;
} 

