#define  NULL  (char *)0
#if defined(__STDC__) && defined(__mips__)
#define  environ  _environ
#endif

extern char **environ;     /* pointer to environment used by getenv          */
extern char  *strcpy  ();  /* copy a string                                  */
extern char  *strcat  ();  /* concatenate two strings                        */
extern char  *strchr  ();  /* find a character within a string               */
extern char  *getcwd  ();  /* returns name of current working directory      */
extern char  *getenv  ();  /* returns value of an environment variable       */
extern void   getargs ();  /* determines argc, argv, and envp (args to main) */
static char   file[256];   /* buffer for constructing absolute file name     */

/* finite state data used to parse out "." and ".." path components */

#define NOCAT   0   /* do not concatenate this character */
#define CONCAT  1   /* concatenate this character        */
#define DOT     2   /* convert "/./" to "/"              */
#define DOTDOT  3   /* convert "/<name>/../" to "/"      */

static struct {
                short nextstate;
                short action;    } fsm[4][4] = {

/*                   '.'          '/'         other        '\0'         */

/* state 0 */ {  {1, CONCAT}, {0, NOCAT }, {3, CONCAT}, {4, NOCAT}  },
/* state 1 */ {  {2, CONCAT}, {0, DOT   }, {3, CONCAT}, {4, NOCAT}  },
/* state 2 */ {  {3, CONCAT}, {0, DOTDOT}, {3, CONCAT}, {4, NOCAT}  },
/* state 3 */ {  {3, CONCAT}, {0, CONCAT}, {3, CONCAT}, {4, NOCAT}  }   };


char *whence (name, workdir)

char *name, *workdir;
{
  char  *path;       /* value of directory search path */
  char  *ptr;        /* temporary                      */
  char  *temp;       /* temporary                      */
  short  found  = 0; /* to make sure we found it       */
  short  freeit = 0; /* set to 1 to free workdir       */
  int    state;      /* current state                  */
  int    index;      /* loop with                      */

  /* get the working directory and search path.  If workdir is non-NULL, the
     caller wishes us to use this value instead of the actual working
     directory. */

  if (workdir == NULL) {
    workdir = getcwd (NULL, 256);
    freeit = 1;
  }
  path = getenv ("PATH");

  /* if the file name contains a slash ('/'), PATH is not searched */

  if (strchr (name, '/') != NULL) {
    if (name[0] == '/')
      strcpy (file, name);
    else {
      strcpy (file, workdir);
      strcat (file, "/");
      strcat (file, name);
    }
    if (access (file, 0) != 0)
      return NULL;
  }

  /* otherwise, we must search the PATH */

  else {
    temp = path = strcpy (malloc (strlen (path) + 2), path);
    ptr  = strchr (path, '\0');
    ptr[0] = ':';
    ptr[1] = '\0';

    while ((ptr = strchr (path, ':')) != NULL) {

      /* construct file name from PATH component */

      *ptr = '\0';
      switch (*path) {
        case '\0': strcpy (file, workdir); break;
        case '/' : strcpy (file, path);    break;
        default  : strcpy (file, workdir);
                   strcat (file, "/");
                   strcat (file, path);
      }
      strcat (file, "/");
      strcat (file, name);

      /* see if such a file exists */

      if (access (file, 0) == 0) {
        found = 1;
        break;
      }
      else path = ptr + 1;
    }

    /* free the space we allocated and see if we found the file */

    free (temp);
    if (freeit)
      free (workdir);
    if (!found)
      return NULL;
  }

  /* parse out "/./" and "/<name>/../" pathname components */

  state = 0;
  temp  = ptr = &file[1];

  while (state != 4) {
    switch (*temp) {
      case '.' : index = 0; break;
      case '/' : index = 1; break;
      case '\0': index = 3; break;
      default  : index = 2; break;
    }
    switch (fsm[state][index].action) {
      case CONCAT: *ptr = *temp;
                   ptr++;
      case NOCAT : break;
      case DOT   : ptr--;
                   break;
      case DOTDOT: if ((ptr - 3) > file) {
                     for (ptr -= 4; *ptr != '/'; ptr--);
                     ptr++;
                   }
                   else ptr = &file[1];
    }
    state = fsm[state][index].nextstate;
    temp++;
  }
  *ptr = '\0';

  return file;
}
