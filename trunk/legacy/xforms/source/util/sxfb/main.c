#include <stdio.h>




void main(argc, argv)
int argc;
char *argv[];
{
  char startup_file[256];
  FILE *sfile;

  if (argc < 2 || argc > 3)
  {
	fprintf(stderr, "Usage:  sxfb form_defaults_file [startup_file]\n");
    fprintf(stderr, "        where\n");
    fprintf(stderr, "             form_defaults_file was saved from xfb\n");
    fprintf(stderr, "             startup_file to be generated (xfb.startup by default)\n\n\n");
	exit(1);
  }
  sfile = NULL; 
  if (argc == 2)
  {
	strcpy(startup_file, "fb.startup");
  }
  else 
  {
	strcpy(startup_file, argv[2]);
  }

  sfile = fopen(startup_file, "w");
  if (sfile == NULL)
  {
    fprintf(stderr, "%s cannot be created; using /usr/tmp/fb.startup instead\n");
    strcpy(startup_file, "/usr/tmp/fb.startup");

	sfile = fopen(startup_file, "w");
  }
  
  fprintf(sfile, ":DPB:\n\"%s\"\n", argv[1]);
  fclose(sfile);
}
