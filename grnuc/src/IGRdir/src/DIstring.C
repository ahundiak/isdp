/* #######################    APOGEE COMPILED   ######################## */
/*
   This file contains some string functions with a variable number of
   arguments.  These functions may be used to build a pathname out of
   several components.
   
   
   HISTORY : HGB : 09/19/1988 - Creation Date
   =======
   

             Note that the minimum number of arguments is 2 : s1 and NULL
*/

#define	__APVA__
#include "coimport.h"
#include <varargs.h>

#include <string.h>
#include <stdio.h>

#include "OMminimum.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"


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
      -------
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
      -------      DIint status;
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
      -------
        {
	  DIint status;
          status = DIstmocpy ( s1, "first", "second", "third", 0, 1 );
        }

        s1 should be ":transient:first:second:third"

      Caveats and Bugs : Unpredictable results will occur if you omit the
      ----------------   NULL at the end of the list. (Some "extra"
                         argumemts may be picked up)
*/

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

  status = di$give_pathname ( osnum = osnum, pathname = s0 );
  for (i = 0; (i < nb_arg) && (status == DIR_S_SUCCESS); i++)
    status = DIstrcat ( s0, args [i] );
  
  return status;
}
