#define  NULL  (char *)0
#if defined(__STDC__) && defined(__mips__)
#define  environ  _environ
#endif

extern char **environ;     /* pointer to environment used by getenv          */
extern char  *getenv  ();  /* returns value of an environment variable       */
extern char  *whence  ();  /* search path for a file                         */
extern void   getargs ();  /* determines argc, argv, and envp (args to main) */


char *exefile ()
{
  int    argc;      /* argc -- parameter as passed to main                   */
  char **argv;      /* argv -- parameter as passed to main                   */
  char **envp;      /* envp -- parameter as passed to main                   */
  char **oldenv;    /* saved value of "environ"                              */
  char  *workdir;   /* working directory at time of program invocation       */
  char  *file;      /* the filename                                          */

  /* get the program parameters (argv[0] contains the name as entered on
     the command line) */

  getargs (&argc, &argv, &envp);

  /* this allows us to fake out the "getenv" function so that we can obtain
     the value of PWD and PATH as it was at program invocation (the program
     may have since modified these values) */

  oldenv  = environ;
  environ = envp;
  workdir = getenv ("PWD");
  file    = whence (argv[0], workdir);
  environ = oldenv;

  return file;
}
