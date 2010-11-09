/* ===============================================================
 * SOL10 09 Nov 2010
 * This is used by the ppl processor, still not really sure why or what exactly it does
 * This in turn need the .s file to call XC_init which in turn needs xcsyscall
 *
 * Trace through some time
 */
#if defined(__sparc__)
#include <sys/utsname.h>
static struct utsname info;
#endif

char        **envstart;    /* points to environ (set by XC_init) */
static int    S_argc = 0;
static char **S_argv = 0;
static char **S_envp = 0;

#if SVR4 && SunOS
extern int  libxc_init;
static int *forceref = &libxc_init;

void getargs (int *argc_p, char ***argv_p, char ***envp_p)
{
  if (!S_argv) {
    int *ptr = (int *)envstart - 1;
    int  cnt = 0;

    while (*--ptr != cnt)
      cnt++;
    S_argc = *ptr;
    S_argv = (char **)(ptr + 1);
    S_envp = envstart;
  }

  /* copy argument values */

  *argc_p = S_argc;
  *argv_p = S_argv;
  *envp_p = S_envp;
}
#else

void getargs (argc_p, argv_p, envp_p)

int    *argc_p;
char ***argv_p;
char ***envp_p;
{
  int *ptr;
  int  cnt;

  if (!S_argv) {

    /* initialize "ptr" to bottom of stack depending on machine type */

#if defined(__clipper__)
    ptr = (int *)0xbffffffc;
#elif defined(__sparc__)
    uname (&info);
    if (strncmp (info.machine, "sun4c", 5) == 0)
      ptr = (int *)0xf7fffffc;
    else if (strncmp (info.machine, "sun4m", 5) == 0)
      ptr = (int *)0xeffffffc;
    else {
      printf ("getargs:  Unknown \"sparc\" machine type!\n");
      return;
    }
#elif defined(__mips__)
    { extern int    __Argc;
      extern char **__Argv;

      *argc_p = S_argc = __Argc;
      *argv_p = S_argv = __Argv;
      *envp_p = S_envp = (char **)(__Argv + __Argc + 1);
      return;
    }
#else
#error getargs.c:  Unknown machine type
#endif
#if !defined(__mips__)

    /* look for the name list (4 null words in a row implies empty case) */

    for (cnt = 0; !*ptr; ptr--)
      if (++cnt == 4)
        goto found;

    /* find the null word that terminates the environment array (if there is
       no environment then we have actually found argv) */

    while (*ptr)
      ptr--;
    while (!*ptr)
      ptr--;

    /* next find the null that terminates the argument array (if we find a
       word whose value is equal to the number of non-null words in this array
       then we will presume that this is argc) */

    for (cnt = 0; *ptr; cnt++, ptr--)
      if (*ptr == cnt)
        goto found;

    /* finally search for argc */

    for (cnt = 0; *--ptr != cnt; cnt++);

    /* save values for fast retrieval the next time we are called */

found:
    S_argc = *ptr;
    S_argv = (char **)(ptr + 1);
    S_envp = (char **)(ptr + 2 + S_argc);
#endif
  }

  /* copy argument values */

  *argc_p = S_argc;
  *argv_p = S_argv;
  *envp_p = S_envp;
}
#endif
