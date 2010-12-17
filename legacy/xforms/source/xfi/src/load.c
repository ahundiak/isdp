#include "FImin.h"

#include "FIread.h"
#include <stdio.h>
#include <setjmp.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

static FILE *FIfile;
static jmp_buf *FIenv;

static int FIstrlen = -1;	/* next string length */

#define CHAR_SIZE	 (sizeof (char))
#define INT_SIZE	 (sizeof (int))
#define SHORT_SIZE	 (sizeof (short))
#define DOUBLE_SIZE	 (sizeof (double))
#define FLOAT_SIZE       (sizeof (float))


int FI_read_int (FILE *file,
                 int  *value)
{
/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   int ii;
   int temp;
   char *tp, *vp;
#endif
#endif
   if (fread (value, INT_SIZE, 1, file) != 1)
     {
	  return (FI_FORM_FILE_READ_ERROR);
     }

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   for ( ii = 0 , vp = (char *)value , tp = (char *) &temp + INT_SIZE - 1; ii < INT_SIZE; ii++ , vp++ , tp--)
     {
	  *tp = *vp;
     }
   *value = temp;

#endif
#endif

   return (FI_SUCCESS);
}

int FI_read_float (FILE  *file,
                   float *value)
{

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   int ii;
   float temp;
   char *tp, *vp;
#endif
#endif

   if (fread (value, FLOAT_SIZE, 1, file) != 1)
     {
	  return (FI_FORM_FILE_READ_ERROR);
     }

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   for ( ii = 0 , vp = (char *) value , tp = (char *) &temp + FLOAT_SIZE - 1; ii < FLOAT_SIZE; ii++ , vp++ , tp--)
     {
	  *tp = *vp;
     }
   *value = temp;

#endif
#endif

   return (FI_SUCCESS);
}



int FI_read_short (FILE  *file,
                   short *value)
{

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   int ii;
   short temp;
   char *tp, *vp;
#endif
#endif

   if (fread (value, SHORT_SIZE, 1, file) != 1)
     {
	  return (FI_FORM_FILE_READ_ERROR);
     }

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   for (ii = 0 , vp = (char *) value , tp = (char *) &temp + SHORT_SIZE - 1; ii < SHORT_SIZE; ii++ , vp++ , tp--)
     {
	  *tp = *vp;
     }
   *value = temp;
#endif
#endif

   return (FI_SUCCESS);
}

int FI_read_double (FILE   *file,
                    double *value)
{

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   int ii;
   double temp;
   char *tp, *vp;
#endif
#endif

   if (fread (value, DOUBLE_SIZE, 1, file) != 1)
     {
	  longjmp (*FIenv, FI_FORM_FILE_READ_ERROR );
     }

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   for (ii = 0 , vp = (char *) value , tp = (char *) &temp + DOUBLE_SIZE - 1; ii < DOUBLE_SIZE; ii++ , vp++ , tp--)
     {
	  *tp = *vp;
     }
   *value = temp;
#endif
#endif

   return (FI_SUCCESS);
}

/*-------------------------------------------------------------------------*/
/* int num;	** number of bytes to read */
/* char *str;	** place for bytes */

void _FI_read_bytes (int   num,
                     char *str)
{
   if (fread (str, num, 1, FIfile) != 1)
    {
	  longjmp (*FIenv, FI_FORM_FILE_READ_ERROR );
    }
}


char _FI_read_char (void)
{
   char value;

   if (fread (&value, CHAR_SIZE, 1, FIfile) != 1)
     {
	  longjmp (*FIenv, FI_FORM_FILE_READ_ERROR );
     }

   return (value);
}

int _FI_read_int (void)
{
   int value;
/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   int ii;
   int temp;
   char *tp, *vp;
#endif
#endif

   if (fread (&value, INT_SIZE, 1, FIfile) != 1)
     {
	  longjmp (*FIenv, FI_FORM_FILE_READ_ERROR );
     }

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)

   for ( ii = 0 , vp = (char *) &value , tp = (char *) &temp + INT_SIZE - 1; ii < INT_SIZE; ii++ , vp++ , tp--)
     {
	  *tp = *vp;
     }
   return (temp);
#else
 return(value);
#endif
#else
  return(value);
#endif

}



short _FI_read_short (void)
{
   short value;

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   int ii;
   short temp;
   char *tp, *vp;
#endif
#endif

   if (fread (&value, SHORT_SIZE, 1, FIfile) != 1)
     {
	  longjmp (*FIenv, FI_FORM_FILE_READ_ERROR );
     }

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   for (ii = 0 , vp = (char *) &value , tp = (char *) &temp + SHORT_SIZE - 1; ii < SHORT_SIZE; ii++ , vp++ , tp--)
     {
	  *tp = *vp;
     }
   return (temp);
#else
 return(value);
#endif
#else
 return(value);
#endif

}

double _FI_read_double (void)
{
   double value;

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   int ii;
   double temp;
   char *tp, *vp;
#endif
#endif

   if (fread (&value, DOUBLE_SIZE, 1, FIfile) != 1)
     {
	  longjmp (*FIenv, FI_FORM_FILE_READ_ERROR );
     }

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   for (ii = 0 , vp = (char *) &value , tp = (char *) &temp + DOUBLE_SIZE - 1; ii < DOUBLE_SIZE; ii++ , vp++ , tp--)
     {
	  *tp = *vp;
     }
   return (temp);
#else
 return(value);
#endif
#else
  return(value);
#endif
}

/* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

char *_FI_read_string (int   size,
                       char *string)
{
   char buf[256];	/* CHUNN there should not be a limit ?? */
   short value;

   if (FIstrlen == -1)
   {
	  if (fread (&value, SHORT_SIZE, 1, FIfile) != 1)
	    {
		 longjmp (*FIenv, FI_FORM_FILE_READ_ERROR );
	    }
   }
   else
   {
	  value = FIstrlen;
   }

   FIstrlen = -1;

   if (value > size)
     {
	  longjmp (*FIenv, FI_FORM_FILE_READ_ERROR );
     }

   if (! string)
   {
	  if (! value)
            {
		 return (_FI_s_new ( (char *) 0));
            }

	  string = buf;
   }

   if (value)
   {
	  if (fread (string, value, 1, FIfile) != 1)
	     {
		 longjmp (*FIenv, FI_FORM_FILE_READ_ERROR );
	     }
   }

   if (size > value)
     {
	  *(string + value) = 0;
     }

   return (string);
}


/* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

char *_FI_reada_string (void)
{
   char *str;
   int ii;

   ii = _FI_read_strlen ();

   if (ii)
   {
	  ii ++;
	  str = (char *) malloc (ii);
   }
   else
     {
	  str = 0;
     }

   str = _FI_read_string (ii, str);

   return (str);
}




int _FI_read_strlen (void)
{
   short value;

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)
   int ii;
   short temp;
   char *tp, *vp;
#endif
#endif

   if (FIstrlen == -1)
   {
	  if (fread (&value, SHORT_SIZE, 1, FIfile) != 1)
	     {
		 longjmp (*FIenv, FI_FORM_FILE_READ_ERROR );
	     }

/* dmb:08/20/92: Changed for yap (yet another port */
/* sml,dmb:08-25-94: added guard for TD solaris (i86pc and sun) */
#if !defined(i86pc)
#if defined(sparc) || defined (sun) || defined (mips) || defined(__hpux)

	  for (ii = 0 , vp = (char *) &value , tp = (char *) &temp + SHORT_SIZE - 1; ii < SHORT_SIZE; ii++ , vp++ , tp--)
	    {
		 *tp = *vp;
	    }
	  FIstrlen = temp;

#else

 FIstrlen = value;

#endif
#else
  FIstrlen = value;
#endif

   }

   return (FIstrlen);
}




void _FI_read_enter (FILE    *fp,
                     jmp_buf  env)
{
   FIfile = fp;
   FIenv = (jmp_buf *) env;
} 


