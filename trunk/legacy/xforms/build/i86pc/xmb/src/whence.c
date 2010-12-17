#include <stdio.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

/* IIwhence.c - A file originally written by Gordon Cross,	     */
/*		and slightly adapted for I/Interface by Jeff Johnson */
/* ----------------------------------------------------------------- */

/* #define  NULL  (char *)0 */

extern char **environ;     /* pointer to environment used by getenv  */
extern char  *strcpy  ();  /* copy a string                          */
extern char  *strcat  ();  /* concatenate two strings                */
extern char  *strchr  ();  /* find a character within a string       */
extern char  *getcwd  ();  /* returns name of current working dir    */
extern char  *getenv  ();  /* returns value of an environment var    */
extern void   getargs ();  /* determines argc, argv, and envp ( args */
			   /*   to main )			     */
static char   file[256];   /* buffer for making absolute file name   */
static char   buffer[256]; /* buffer to store symbolic link into     */

/* finite state data used to parse out "." and ".." path components */

#define NOCAT   0   /* do not concatenate this character */
#define CONCAT  1   /* concatenate this character        */
#define DOT     2   /* convert "/./" to "/"              */
#define DOTDOT  3   /* convert "/<name>/../" to "/"      */

static struct
{
  short nextstate;
  short action;
} fsm[4][4] = {

/*                   '.'          '/'         other        '\0'       */

/* state 0 */ {  {1, CONCAT}, {0, NOCAT }, {3, CONCAT}, {4, NOCAT}  },
/* state 1 */ {  {2, CONCAT}, {0, DOT   }, {3, CONCAT}, {4, NOCAT}  },
/* state 2 */ {  {3, CONCAT}, {0, DOTDOT}, {3, CONCAT}, {4, NOCAT}  },
/* state 3 */ {  {3, CONCAT}, {0, CONCAT}, {3, CONCAT}, {4, NOCAT}  } };


char * IIwhence (char *name,
                 char *workdir)
{
  char  *path;       /* value of directory search path */
  char  *ptr;        /* temporary                      */
  char  *temp;       /* temporary                      */
  short  found  = 0; /* to make sure we found it       */
  short  freeit = 0; /* set to 1 to free workdir       */
  int    state;      /* current state                  */
  int    index;      /* loop with                      */

  /* First check the name to see if this file */
  /* Get the working directory and search path.  If workdir is	*/
  /* non-NULL, the caller wishes us to use this value instead	*/
  /* of the actual working directory.				*/

  if ( workdir == NULL )
  {
      workdir = getcwd ( NULL, 256 );
      freeit = 1;
  }

  path = getenv ("PATH");

  /* if the file name contains a slash ('/'), PATH is not searched */

  if ( strchr ( name, '/' ) != NULL )
  {
      if ( name[0] == '/' )
		strcpy ( file, name );
      else
      {
	  strcpy (file, workdir);
	  strcat (file, "/");
	  strcat (file, name);
      }

      if ( access ( file, 0 ) != 0 )
        return NULL;
  }
  else  /* otherwise, we must search the PATH */
  {
      temp = path = strcpy ( malloc (strlen (path) + 2), path );
      ptr  = strchr (path, '\0');
      ptr[0] = ':';
      ptr[1] = '\0';

      while ( ( ptr = strchr (path, ':') ) != NULL )
      {
	  /* construct file name from PATH component */

	  *ptr = '\0';

	  switch ( *path )
          {
	      case '\0':
		strcpy (file, workdir);
		break;

              case '/':
		strcpy (file, path);
		break;

              default:
		strcpy (file, workdir);
		strcat (file, "/");
		strcat (file, path);
		break;
         }

	  strcat (file, "/");
	  strcat (file, name);

	  /* see if such a file exists */

	  if ( access (file, 0) == 0 )
          {
	      found = 1;
              break;
          }
	  else
	    path = ptr + 1;
    }

    /* free the space we allocated and see if we found the file */

    _FB_free ( (void *) temp );

    if ( freeit )
      _FB_free ( (void *) workdir );

    if ( !found )
      return NULL;
  }

  /* parse out "/./" and "/<name>/../" pathname components */

  state = 0;
  temp  = ptr = &file[1];

  while (state != 4)
  {
      switch ( *temp )
      {
	  case '.' :
		index = 0;
		break;

	  case '/' :
		index = 1;
		break;

	  case '\0':
		index = 3;
		break;

	  default  :
		index = 2;
		break;
    }

    switch ( fsm[state][index].action )
    {
	  case CONCAT:
		*ptr = *temp;
                ptr++;
	  case NOCAT :
		break;

	  case DOT   :
		ptr--;
                break;

	  case DOTDOT:
		if ( (ptr - 3) > file )
		  {
                     for ( ptr -= 4; *ptr != '/'; ptr-- );
                     ptr++;
                  }
                else
		  ptr = &file[1];
    }
      state = fsm[state][index].nextstate;
      temp++;
  }

  *ptr = '\0';
 
  /* See if the path is a symbolic link until not one */

  for (;;)
  {
  int length;

      length = readlink ( file, buffer, 255 );
      if ( length > -1 )
	{
		/*** make it be NULL terminated ***/
	  buffer [ length ] = '\0';
	  strcpy ( file, buffer );
	}
      else
	break;
  }

  return file;
}
