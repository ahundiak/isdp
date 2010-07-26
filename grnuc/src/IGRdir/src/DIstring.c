/*
   This file contains some string functions with a variable number of
   arguments.  These functions may be used to build a pathname out of
   several components.


             HGB : 11/01/1993 - Mother of all kludges for DIstmocpy on IRIX
             JSD : 10/06/1993 - Added workaround for DIstmocpy for IRIX
   HISTORY : HGB : 09/19/1988 - Creation Date
   =======


             Note that the minimum number of arguments is 2 : s1 and NULL
*/

#define	__APVA__
#include "coimport.h"
#if defined ( __STDC__ ) && defined ( SUNOS ) && defined ( XYXYX )
#include <stdarg.h>
#else
#include <varargs.h>
#endif

#include <string.h>
#include <stdio.h>

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"


#define  MAXARG 100	/* that should be enough	*/


/*
   This function performs a DIstrcpy with a variable number of argument.
The minimum number of arguments is 2 (same behaviour as DIstrcpy).  Note
that this primitive offers the advantage of beeing independent of the
character used to represent root.

      Return status :
      -------------
                      DIR_S_SUCCESS : successful operation
                      DIR_E_OVFLOW  : overflow in name

      Argument description :
      --------------------

        DIchar s0 [PATH_MAX] 	: The target string	   		(OUT)
        DIchar *s1		: The first string to copy   		(IN)
        DIchar *s2		: The second string to copy   		(IN)
        ...
	NULL			: Termination of the list		(IN)

      Example :
      ------
	{
           DIint status;
           status = DIstmcpy ( s1, "first", "second", "third", 0 );
        }

        s1 should be "first:second:third"

      Caveats and Bugs : Unpredictable results will occur if you omit the
      ----------------   NULL at the end of the list. (Some "extra"
                         argumemts may be picked up)
*/

DIstmcpy ( va_alist )
           va_dcl
{
  va_list ap;
  DIchar  *args [MAXARG], *s0;
  DIint   i, status, nb_arg = 0;

  va_start ( ap );
  s0 = va_arg ( ap, DIchar * );
  while ((args [nb_arg++] = va_arg ( ap, char * )) != (DIchar *) NULL);
  nb_arg--;
  va_end ( ap );

  status = DIstrcpy ( s0, args [0] );
  for (i = 1; (i < nb_arg) && (status == DIR_S_SUCCESS); i++)
    status = DIstrcat ( s0, args [i] );

  return status;
}


/*
   This function performs a DIstrcat with a variable number of argument.
The minimum number of arguments is 2 (same behaviour as DIstrcat).  Note
that this primitive offers the advantage of beeing independent of the
character used to represent root.

      Return status :
      -------------
                      DIR_S_SUCCESS : successful operation
                      DIR_E_OVFLOW  : overflow in name

      Argument description :
      --------------------

        DIchar s0 [PATH_MAX] 	: The target string	   		(IN/OUT)
        DIchar *s1		: The first string to copy   		(IN)
        DIchar *s2		: The second string to copy   		(IN)
        ...
	NULL			: Termination of the list		(IN)

      Example :
      ------
	{
          DIint status;
          strcpy ( s1, "first" );
          status = DIstmcat ( s1, "second", "third", 0 );
        }

        s1 should be "first:second:third"

      Caveats and Bugs : Unpredictable results will occur if you omit the
      ----------------   NULL at the end of the list. (Some "extra"
                         argumemts may be picked up)
*/

DIstmcat ( va_alist )
           va_dcl
{
  va_list ap;
  DIchar  *args [MAXARG], *s0;
  DIint   i, status, nb_arg = 0;

  va_start ( ap );
  s0 = va_arg ( ap, DIchar * );
  while ((args [nb_arg++] = va_arg ( ap, char * )) != (DIchar *) NULL);
  nb_arg--;
  va_end ( ap );

  for (status = DIR_S_SUCCESS, i = 0;
       (i < nb_arg) && (status == DIR_S_SUCCESS); i++)
    status = DIstrcat ( s0, args [i] );

  return status;
}
/*
   This function performs a DIstrcpy with a variable number of argument.
The minimum number of arguments is 2 (same behaviour as DIstrcpy).  Note
that this primitive offers the advantage of beeing independent of the
character used to represent root.  The pathname to the specified object
space is added at the beginning of the target string.

      Return status :
      -------------
                      DIR_S_SUCCESS : successful operation
                      DIR_E_INVARG  : invalid object space
                      DIR_E_OVFLOW  : overflow in name

      Argument description :
      --------------------

        DIchar s0 [PATH_MAX] 	: The target string	   		(OUT)
        DIchar *s1		: The first string to copy   		(IN)
        DIchar *s2		: The second string to copy   		(IN)
        ...
	NULL			: Termination of the list of strings	(IN)
        DIspacenum osnum	: The object space number		(IN)

      Example :
      ------
	{
          DIint status;
          status = DIstmocpy ( s1, "first", "second", "third", 0, 1 );
        }

        s1 should be ":transient:first:second:third"

      Caveats and Bugs : Unpredictable results will occur if you omit the
      ----------------   NULL at the end of the list. (Some "extra"
                         argumemts may be picked up)
*/

#if defined(IRIX)
DIstmocpy (
  DIchar     *s1,
  DIchar     *arg1,
  DIchar     *arg2,
  DIchar     *arg3,
  DIchar     *arg4,
  DIchar     *arg5,
  DIchar     *arg6,
  DIchar     *arg7,
  DIchar     *arg8,
  DIchar     *arg9,
  DIchar     *arg10)

{
  DIint      status = DIR_S_SUCCESS;
  DIchar     s0[120];
  DIspacenum osnum;

  s0[0] = 0;

  if (arg1 && (status == DIR_S_SUCCESS))
  {
    status = DIstrcat ( s0,arg1 );

  if (arg2 && (status == DIR_S_SUCCESS))
  {
    status = DIstrcat ( s0,arg2 );

  if (arg3 && (status == DIR_S_SUCCESS))
  {
    status = DIstrcat ( s0,arg3 );

  if (arg4 && (status == DIR_S_SUCCESS))
  {
    status = DIstrcat ( s0,arg4 );

  if (arg5 && (status == DIR_S_SUCCESS))
  {
    status = DIstrcat ( s0,arg5 );

  if (arg6 && (status == DIR_S_SUCCESS))
  {
    status = DIstrcat ( s0,arg6 );

  if (arg7 && (status == DIR_S_SUCCESS))
  {
    status = DIstrcat ( s0,arg7 );

  if (arg8 && (status == DIR_S_SUCCESS))
  {
    status = DIstrcat ( s0,arg8 );

  if (arg9 && (status == DIR_S_SUCCESS))
  {
    status = DIstrcat ( s0,arg9 );

  if (arg10)
  {
    printf ("Too many arguments being passed to DIstmocpy\n");
    status = 0;
  }
  }
  else osnum = (DIspacenum) arg10;
  }
  else osnum = (DIspacenum) arg9;
  }
  else osnum = (DIspacenum) arg8;
  }
  else osnum = (DIspacenum) arg7;
  }
  else osnum = (DIspacenum) arg6;
  }
  else osnum = (DIspacenum) arg5;
  }
  else osnum = (DIspacenum) arg4;
  }
  else osnum = (DIspacenum) arg3;
  }
  else osnum = (DIspacenum) arg2;

  if (status & 1)
  {
    status = DIgive_pathname ( osnum, s1 );
    if (status & 1)
      status = DIstrcat( s1, s0 [0] == ':' ? &s0 [1] : s0 );
  }

  return status;
}
#else
DIstmocpy ( va_alist )
           va_dcl
{
  va_list    ap;
  DIchar     *args [MAXARG], *s0;
  DIint      i, status, nb_arg = 0;
  DIspacenum osnum;

  va_start ( ap );
  s0 = va_arg ( ap, DIchar * );
  while ((args [nb_arg++] = va_arg ( ap, char * )) != (DIchar *) NULL);
  nb_arg--;
  osnum = va_arg ( ap, DIspacenum );
  va_end ( ap );

  status = DIgive_pathname ( osnum, s0 );
  for (i = 0; (i < nb_arg) && (status == DIR_S_SUCCESS); i++)
    status = DIstrcat ( s0, args [i] );

  return status;
}
#endif
