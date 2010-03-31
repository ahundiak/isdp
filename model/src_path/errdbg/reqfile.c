#include <stdio.h>
#include "PWminimum.h"

#define EQUAL 0

FILE *pwRequestInFile()
{
  char str[PW_K_MaxCharFilename+1];
  FILE *infile;

  fflush (stdout);
  printf ("Input Filename (. for stdin) _: ");
  scanf ("%s", str);
  if (strcmp (str, ".") == EQUAL)
  {
    infile = stdin;
  }
  else
  {
    printf ("\nOpening file %s for read...\n", str);
    if (!(infile = fopen (str, "r")))
    {
      fprintf (stderr, "Could not open file\n");
    }
  }
  return (infile);
}

FILE *pwRequestOutFile()
{
  char str[PW_K_MaxCharFilename+1];
  FILE *outfile;

  fflush (stdout);
  printf ("Output Filename (. for stderr) _: ");
  scanf ("%s", str);
  if (strcmp (str, ".") == EQUAL)
  {
    outfile = stderr;
  }
  else
  {
    printf ("\nOpening file %s for write...\n", str);
    if (!(outfile = fopen (str, "w")))
    {
      fprintf (stderr, "Could not open file\n");
    }
  }
  return (outfile);
}
