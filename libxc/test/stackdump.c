#include <ctype.h>

void main (argc, argv, envp)

int    argc;
char **argv;
char **envp;
{
  char *c_addr;
  long *l_addr = (long *)argv - 1;
  int   col    = 0;

  { int    G_argc;
    char **G_argv, **G_envp;

    getargs (&G_argc, &G_argv, &G_envp);
    printf ("         PASSED     GETARGS\n\n");
    printf ("argc = %10d  %10d\n",     argc, G_argc);
    printf ("argv = 0x%.8x  0x%.8x\n", argv, G_argv);
    printf ("envp = 0x%.8x  0x%.8x\n", envp, G_envp);
  }
  printf ("\nStack dump follows:\n");

  for (; *envp; envp++);
  for (c_addr = (char *)(envp + 1); l_addr < (long *)c_addr; l_addr++, col--) {
    if (!col) {
      printf ("\n0x%.8x:  ", l_addr);
      col = 4;
    }
    printf ("0x%.8x   ", *l_addr);
  }
  putchar ('\n');
  col = 0;

  for (; c_addr < (char *)0xc0000000; c_addr++, col--) {
    if (!col) {
      printf ("\n0x%.8x:  ", c_addr);
      col = 16;
    }
    if (isascii (*c_addr) && isprint (*c_addr))
      printf ("'%c' ", *c_addr);
    else printf ("%3u ", (int)*(unsigned char *)c_addr);
  }
  putchar ('\n');
}
