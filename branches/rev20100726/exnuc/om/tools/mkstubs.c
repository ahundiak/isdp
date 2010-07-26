#include <sys/types.h>
#include <dirent.h>
#define _INGR_EXTENSIONS
#include <stdio.h>
#include "vla.h"
#include "hash.h"

#define  MAXPERLINE  10    /* number of bytes per .byte directive */

#define  COMMON  struct common
COMMON {
         char *name;
         long  value;
};

extern char *strchr ();
extern char *strrchr ();
extern char *stralloc ();
extern void  strfree ();

HASHTABLE  *globs;
HASHTABLE  *comms;
vla(char *) fcnlist;
vla(char *) clslist;
FILE       *output_file  = 0;
char       *output_name  = "stubs.s";
char       *product_name = 0;
char       *subdir_path  = 0;
int         prod_label   = 0;
int         file_label   = 0;
int         new_product  = 0;


char *basename (file)

char *file;
{
  char *ptr = strrchr (file, '/');

  if (ptr)
    return ptr + 1;
  return file;
}


int is_class (func)

char *func;
{
  int len = strlen (func);

  return (len > 14 && strcmp (func + len - 14, "_OM_class_init") == 0);
}


void gen_string (str)

char *str;
{
  int cnt = MAXPERLINE;

  fputs ("\t.byte\t", output_file);
  while (1) {
    fprintf (output_file, "%d", *str);
    if (!*str)
      break;
    if (--cnt)
      fputs (", ", output_file);
    else {
      fputs ("\n\t.byte\t", output_file);
      cnt = MAXPERLINE;
    }
    str++;
  }
  fputc ('\n', output_file);
}


void gen_stub_file (file)

char *file;
{
  FILE *nm_out;
  char  command[1024];
  char  symname[1024];
  char  value[9];
  char  type;
  int   numfcns    = 0;
  int   numclasses = 0;
  int   gwarn      = 1;
  int   cnt;

  /* check for product name (required input) */

  if (!product_name) {
    fputs ("No product name specified.\n", stderr);
    exit (14);
  }

  /* initialize output file if not already so */

  if (!output_file) {
    if (!(output_file = fopen (output_name, "w"))) {
      perror ("could not open output file");
      exit (24);
    }
    fprintf (output_file, "\t.file\t\"%s\"\n", basename (output_name));
  }

  /* generate label and data for the product name if changed */

  fprintf (output_file, "\t.data\n");
  if (new_product) {
    new_product = 0;
    fprintf (output_file, ".P%d:", ++prod_label);
    gen_string (product_name);
    gen_string (subdir_path);
  }

  /* generate label and data for the file name */

  fprintf (output_file, ".F%d:", ++file_label);
  gen_string (basename (file));

  /* open pipe to 'nm' command */

  sprintf (command, "nm -p %s", file);
  if (!(nm_out = (FILE *) popen (command, "r"))) {
    perror ("could not execute 'nm'");
    exit (34);
  }

  /* read output stream from the 'nm' command and process symbols according
     to their type */

  while (fscanf (nm_out, "%9c%c%s%*c", value, &type, symname) != EOF)
    switch (type) {

      /* global text symbol:  save the name in the function list and also in
                              the class list (if a class init function) for
                              stub generation after we know the type of file
                              this is */

      case 'T':
        Vndx(fcnlist,numfcns++) = stralloc (symname);
        if (is_class (symname))
          Vndx(clslist,numclasses++) = Vdat(fcnlist)[numfcns - 1];

      /* external reference:  these must exist in the stub file to ensure that
                              the application links correctly */

      case 'U':
        if (!hashlookup (globs, symname))
          hashadd (globs, stralloc (symname), NULL);
        break;

      /* common (unitialized global):  must be duplicated in the stub file for
                                       proper links - dynamic loader will map
                                       commons in the real file to this one */

      case 'C': {
        COMMON  temp;
        COMMON *sym;

        value[8] = '\0';
        cnt      = atol (value);
        if (sym = hashlookup (comms, symname)) {
          if (sym->value != cnt) {
            fprintf (stderr, "WARNING:  Common (%s) has multiple sizes - larger assumed.\n", symname);
            if (cnt > sym->value)
              sym->value = cnt;
          }
        }
        else {
          temp.name  = stralloc (symname);
          temp.value = cnt;
          hashadd (comms, &temp, NULL);
        }
        break;
      }

      /* global data:  generates a warning since reactive loading is not
                       generally possible without EXTREME care */

      case 'D':
        if (gwarn) {
          fprintf (stderr, "WARNING:  Global data in file %s\n", file);
          gwarn = 0;
        }
    }

  /* close the pipe to 'nm' */

  pclose (nm_out);

  /* generate stubs for class case here */

  if (numclasses) {
    fprintf (stderr, "WARNING:  Class definition in file %s\n", file);
    fprintf (stderr, "          Not supported in this version of EXNUC!\n");
    fprintf (output_file, ".C%d:\t.long\t.F%d\n", file_label, file_label);
    for (cnt = 0; cnt < numclasses; cnt++)
      fprintf (output_file, "\t.long\t%s\n", Vdat(clslist)[cnt]);
    fputs ("\t.long\t0\n\t.text\n\t.align\t2\n\n", output_file);
    for (cnt = 0; cnt < numfcns; cnt++) {
      fprintf (output_file, "%s:\n", Vdat(fcnlist)[cnt]);
      fprintf (output_file, "\tmovw\t$.P%d,r2\n", prod_label);
      fprintf (output_file, "\tmovw\t$.C%d,r3\n", file_label);
      fprintf (output_file, "\tcall\tsp,Rload_cls\n");
      fprintf (output_file, "\tb\t%s\n\n", Vdat(fcnlist)[cnt]);
      strfree (Vdat(fcnlist)[cnt]);
    }
  }

  /* generate stubs for normal case here */

  else if (!numfcns)
    fprintf (stderr, "WARNING:  No functions in file %s\n", file);
  else {
    fputs ("\t.text\n\t.align\t2\n\n", output_file);
    for (cnt = 0; cnt < numfcns; cnt++) {
      fprintf (output_file, "%s:\n", Vdat(fcnlist)[cnt]);
      fprintf (output_file, "\tmovw\t$.P%d,r2\n", prod_label);
      fprintf (output_file, "\tmovw\t$.F%d,r3\n", file_label);
      fprintf (output_file, "\tcall\tsp,Rload\n");
      fprintf (output_file, "\tb\t%s\n\n", Vdat(fcnlist)[cnt]);
      strfree (Vdat(fcnlist)[cnt]);
    }
  }
}


int gen_stub_dir (dirname)

char *dirname;
{
  DIR           *dir;
  struct dirent *dirent;
  char           path[512];
  char          *base;
  int            len;

  if (!(dir = opendir (dirname)))
    return 0;
  strcpy (path, dirname);
  strcat (path, "/");
  base = path + strlen (path);

  while (dirent = readdir (dir))
    if ((len = strlen (dirent->d_name)) > 2 &&
                                strcmp (dirent->d_name + len - 2, ".o") == 0) {
      strcpy (base, dirent->d_name);
      gen_stub_file (path);
    }

  closedir (dir);
  return 1;
}


int main (argc, argv)

int    argc;
char **argv;
{
  COMMON *sym;
  char   *ptr;

  /* initialize hash tables to track commons and external references */

  globs = hashinit (NAKED(char), 5000, hashc, strcmp, NAKEDKEY, VLREC | NOMEM);
  comms = hashinit (COMMON, 500, hashc, strcmp, name, INDKEY);

  /* initialize vlas to track functions and classes */

  Vinit (fcnlist, 25, 25);
  Vinit (clslist, 25, 25);

  /* process arguments */

  for (++argv; *argv; ++argv) {
    if ((*argv)[0] != '-') {
      if (!gen_stub_dir (*argv))
        gen_stub_file (*argv);
    }
    else switch ((*argv)[1]) {

      case 'o':
        if (output_file)
          fputs ("-o ignored:  too late in command line.\n", stderr);
        else output_name = ((*argv)[2] ? &(*argv)[2] : *++argv);
        break;

      case 'p':
        product_name = ((*argv)[2] ? &(*argv)[2] : *++argv);
        new_product  = 1;
        if (subdir_path = strchr (product_name, ':')) {
          *subdir_path = '\0';
          if (*++subdir_path)
            break;
        }
        subdir_path = ".";
        break;

      default:
        goto usage;
    }
  }

  if (!output_file) {
usage:
    fputs ("usage: mkstubs [-o outfile]\n", stderr);
    fputs ("                -p product[:subdir]\n", stderr);
    fputs ("                filename(s)\n", stderr);
    exit (22);
  }

  /* write out directives for commons */

  while (sym = hashnext (comms))
    fprintf (output_file, "\t.comm\t%s,%d\n", sym->name, sym->value);

  /* write out directives for external references */

  while (ptr = hashnext (globs))
    fprintf (output_file, "\t.globl\t%s\n", ptr);

  fclose (output_file);
}
