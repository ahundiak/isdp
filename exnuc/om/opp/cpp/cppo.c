#include <stdio.h>
#include <varargs.h>

void fdumpitf (va_alist) /* ( file, fmt, ... ) */
va_dcl
 {
  va_list args;
  FILE *f;
  char *fmt;
  char liner[256];
  
  va_start(args);
  f = va_arg(args,FILE *);
  fmt = va_arg(args,char *);

  fprintf (f, "Here it comes\n");
  vfprintf (f, fmt, args);
  fprintf (f, "That was it.\n");
  va_end(args);
 } /* fdumpitf */

main (argc, argv)
 int argc;
 char *argv[];
 {
  FILE *f;
  fdumpitf (stderr, "This is a test of %d calls.\n", 3);

  if (!(f = fopen (argv[1],"w")))
   {
    printf ("open failure on %s\n", argv[1]);
    exit (1);
   }

  fdumpitf (f, "more %d testing %f.\n", 3, 3.141592653589793);
 } /* main */
