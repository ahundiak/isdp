#define XFB_VERSION "01.02.06.03"
#define XFB_DATE "Wed Nov 30 13:21:11 CST 1994"

#include <stdio.h>
FBprint_version(void)
{
  fprintf (stderr, "XFB Version %s, built %s\n", XFB_VERSION, XFB_DATE);

  fprintf ( stderr, "Copyright 1994 Intergraph Corporation\n");
  fprintf ( stderr,
	"All Rights Reserved, Including Application Programs,\n");
  fprintf ( stderr, "File Formats, and Visual Displays.\n\n");
}
