#include <sys/types.h>
#include <dirent.h>
#include <string.h>
#include <stdio.h>
#include "xcmisc.h"
#include "vla.h"
#include "hash.h"
#include "objaccess.h"
#include "dload.h"

extern char *getcwd (char *, int);

#if defined(__clipper__)
#define  COMMENT    "#\n# Begin stubs for:  %s\n#\n"
#define  TAGLABEL   ".T%d:"
#define  FILELABEL  "\t.align\t4\n.F%d:\t.long\t0x%.8x\n"
#define  TEXTSEG    "\t.text\n"
#define  DATASEG    "\t.data\n"
#define  COMMALLOC  "\t.comm\t%s,%d\n"
#define  GLOBALLOC  "\t.globl\t%s\n"
#endif
#if defined(__sparc__)
#define  COMMENT    "!\n! Begin stubs for:  %s\n!\n"
#define  TAGLABEL   "LT%d:"
#define  FILELABEL  "\t.align\t4\nLF%d:\t.word\t0x%.8x\n"
#define  TEXTSEG    "\t.seg\t\"text\"\n"
#define  DATASEG    "\t.seg\t\"data\"\n"
#define  COMMALLOC  "\t.common\t%s,%d\n"
#define  GLOBALLOC  "\t.global\t%s\n"
#endif
#if defined(__mips__)
#define  COMMENT    " #\n # Begin stubs for:  %s\n #\n"
#define  TAGLABEL   "$T%d:"
#define  FILELABEL  "$F%d:\t.word\t0x%.8x\n"
#define  TEXTSEG    "\t.text\n"
#define  DATASEG    "\t.data\n"
#define  COMMALLOC  "\t.comm\t%s,%d\n"
#define  GLOBALLOC  "\t.globl\t%s\n"
#endif

#define PATHMAX  1024

typedef struct common COMMON;
struct common {
   char *name;
   long  value;
};

HASHTABLE  *globs;
HASHTABLE  *comms;
FILE       *output_file   = 0;
char       *output_name   = "stubs.s";
char       *tagname       = 0;
char       *subdir_path   = 0;
char       *currdir       = 0;
int         tag_label     = 0;
int         file_label    = 0;
int         load_options  = TEXTREF | DATAREF | TEXTREDEF;
int         absolute_mode = 1;
int         newtag        = 0;


/******************************/
/* return base name of a file */
/******************************/

char *basename (char *file)
{
  char *ptr = strrchr (file, '/');

  if (ptr)
    return ptr + 1;
  return file;
}


/**********************************/
/* return absolute name of a file */
/**********************************/

char *absname (char *file)
{
  static char path[PATHMAX];

  if (file[0] == '/')
    return file;
  strcpy (path, currdir);
  strcat (path, "/");
  strcat (path, file);
  return path;
}


/*************************************/
/* allocate a null-terminated string */
/*************************************/

void gen_string (char *str)
{
#if defined(__clipper__)
  int cnt;

  fprintf (output_file, "\t.byte\t%d", *str);
  for (cnt = 1; *str; cnt++)
    fprintf (output_file, (cnt % 10 ? ", %d" : "\n\t.byte\t%d"), *++str);
  fputc ('\n', output_file);
#endif
#if defined(__sparc__)
  fprintf (output_file, "\t.asciz\t\"%s\"\n", str);
#endif
#if defined(__mips__)
  fprintf (output_file, "\t.asciiz\t\"%s\"\n", str);
#endif
}


/****************************/
/* generate a stub function */
/****************************/

void gen_stub_fcn (char *name)
{
  fputc ('\n', output_file);
  fprintf (output_file, GLOBALLOC, name);

#if defined(__clipper__)
  fprintf (output_file, "%s:\n", name);
  if (absolute_mode)
    fputs ("\tloadi\t$0,r2\n", output_file);
  else fprintf (output_file, "\tmovw\t$.T%d,r2\n", tag_label);
  fprintf (output_file, "\tmovw\t$.F%d,r3\n", file_label);
  fprintf (output_file, "\tcall\tsp,Rload\n");
  fprintf (output_file, "\tb\t%s\n", name);
#endif
#if defined(__sparc__)
  fprintf (output_file, "%s:\n", name);
  fprintf (output_file, "\tsave\t%%sp,-96,%%sp\n");
  if (absolute_mode)
    fputs ("\tmov\t0,%o0\n", output_file);
  else fprintf (output_file, "\tset\tLT%d,%%o0\n", tag_label);
  fprintf (output_file, "\tset\tLF%d,%%o1\n", file_label);
  fprintf (output_file, "\tcall\tdload_reactive,2\n");
  fprintf (output_file, "\tnop\n");
  fprintf (output_file, "\tba\t%s\n", name);
  fprintf (output_file, "\trestore\n");
#endif
#if defined(__mips__)
  fprintf (output_file, "\t.ent\t%s\n", name);
  fprintf (output_file, "%s:\n", name);
  fprintf (output_file, "\tmove\t$8,$31\n");
  if (absolute_mode)
    fputs ("\tli\t$9,0\n", output_file);
  else fprintf (output_file, "\tla\t$9,$T%d\n", tag_label);
  fprintf (output_file, "\tla\t$10,$F%d\n", file_label);
  fprintf (output_file, "\tjal\tRload\n");
  fprintf (output_file, "\tnop\n");
  fprintf (output_file, "\tb\t%s\n", name);
  fprintf (output_file, "\tnop\n");
  fprintf (output_file, "\t.end\n");
#endif
}


/*************************************/
/* generate stubs for the given file */
/*************************************/

void gen_stubs_from_file (file)

char *file;
{
  OBJFD   *objfd;
  OBJINFO *info;
  STE     *sym;
  int      cnt;

  /* initialize output file if not already so */

  if (!output_file) {
    if (!(output_file = fopen (output_name, "w"))) {
      perror ("could not open output file");
      exit (24);
    }
#if defined(__clipper__)
    fprintf (output_file, "\t.file\t\"%s\"\n", basename (output_name));
#endif
#if defined(__mips__)
    fputs ("\t.set\tnoreorder\n", output_file);
#endif
  }

  /* open the input file and ignore it if not an object */

  if (!(objfd = OBJopen (file, OBJ_OBJ)))
    return;
  info = OBJread (objfd, OBJ_GSYM);
  if (info->flags & OBJ_EXE) {
    OBJclose (objfd, 0);
    return;
  }

  /* output a comment to indicate start of a new file */

  fprintf (output_file, COMMENT, file);

  /* generate label and data for the reactive load tag if changed */

  fprintf (output_file, DATASEG);
  if (newtag) {
    newtag = absolute_mode = 0;
    fprintf (output_file, TAGLABEL, ++tag_label);
    gen_string (tagname);
    gen_string (subdir_path);
  }

  /* generate label and data for the file name */

  fprintf (output_file, FILELABEL, ++file_label, load_options);
  gen_string ((absolute_mode ? absname : basename)(file));
  fprintf (output_file, TEXTSEG);

  for (sym = info->symptr, cnt = info->nsyms; cnt--; sym++) {

    /* global symbol:  generate a stub for functions and issue a warning
                       for data */

    if (sym->whatis & SYM_GLOB) {
#if defined(__sparc__)
      if (info->flags & OBJ_SLIB)
        if (   0 == strcmp (sym->name, "_etext")
            || 0 == strcmp (sym->name, "_edata")
            || 0 == strcmp (sym->name, "_end")
            || 0 == strcmp (sym->name, "__GLOBAL_OFFSET_TABLE_")) {
          continue;
        }
#endif
      if (sym->whatis & SYM_TEXT)
        gen_stub_fcn (sym->name);
      else
        fprintf (stderr, "\"%s\":  WARNING:  Global variable %s\n", file, sym->name);
    }

    /* external reference:  these must exist in the stub file to ensure that
                            the application links correctly */

    else if (sym->whatis & SYM_EXT) {
      if (!hashlookup (globs, sym->name))
        hashadd (globs, stralloc (sym->name), 0);
    }

    /* common (unitialized global):  must be duplicated in the stub file for
                                     proper links - dynamic loader will map
                                     commons in the real file to this one */

    else if (sym->whatis & SYM_COMM) {
      COMMON  temp;
      COMMON *exist;

      if (exist = hashlookup (comms, sym->name)) {
        if (exist->value != sym->value) {
          fprintf (stderr, "\"%s\":  WARNING:  Common (%s) has multiple sizes - larger assumed.\n", file, sym->name);
          if (sym->value > exist->value)
            exist->value = sym->value;
        }
      }
      else {
        temp.name  = stralloc (sym->name);
        temp.value = sym->value;
        hashadd (comms, &temp, 0);
      }
    }
  }

  OBJclose (objfd, 0);
}


/******************************************************/
/* generate stubs for all object files in a directory */
/******************************************************/

int gen_stubs_from_dir (dirname)

char *dirname;
{
  DIR           *dir;
  struct dirent *dirent;
  char           path[PATHMAX];
  char          *base;

  if (!(dir = opendir (dirname)))
    return 0;
  strcpy (path, dirname);
  strcat (path, "/");
  base = path + strlen (path);

  while (dirent = readdir (dir)) {
    strcpy (base, dirent->d_name);
    gen_stubs_from_file (path);
  }

  closedir (dir);
  return 1;
}


int main (int argc, char **argv)
{
  COMMON *sym;
  char   *ptr;

  /* get current working directory for absolute mode */

  currdir = getcwd (0, PATHMAX);

  /* initialize hash tables to track commons and external references */

  globs = hashinit (NAKED(char), 5000, hashc, strcmp, NAKEDKEY, VLREC | NOMEM);
  comms = hashinit (COMMON, 500, hashc, strcmp, name, INDKEY);

  /* process arguments */

  for (++argv; *argv; ++argv) {
    if ((*argv)[0] != '-') {
      if (!gen_stubs_from_dir (*argv))
        gen_stubs_from_file (*argv);
    }
    else switch ((*argv)[1]) {

      /* specify output file name */

      case 'o':
        if (output_file)
          fputs ("-o ignored:  too late in command line.\n", stderr);
        else output_name = ((*argv)[2] ? &(*argv)[2] : *++argv);
        break;

      /* specify absolute mode */

      case 'a':
        absolute_mode = 1;
        break;

      /* specify reactive load tag */

      case 'p':
        fputs ("-p is obsolete (but accepted); use -t instead.\n", stderr);
      case 't':
        tagname = ((*argv)[2] ? &(*argv)[2] : *++argv);
        newtag  = 1;
        if (subdir_path = strchr (tagname, ':')) {
          *subdir_path = '\0';
          if (*++subdir_path)
            break;
        }
        subdir_path = ".";
        break;

      /* specify reactive load options */
#if 0
      case 'O': {
        char *optname = ((*argv)[2] ? &(*argv)[2] : *++argv);
      }
#endif

      default:
        goto usage;
    }
  }

  if (!output_file) {
usage:
    fputs ("usage: mkstubs [-o outfile]\n", stderr);
    fputs ("               [-t tagname[:subdir]]\n", stderr);
    fputs ("               [-a]\n", stderr);
    fputs ("                filename(s)\n", stderr);
    exit (22);
  }
  fputc ('\n', output_file);

  /* write out directives for commons */

  while (sym = hashnext (comms))
    fprintf (output_file, COMMALLOC, sym->name, sym->value);

  /* write out directives for external references */

  while (ptr = hashnext (globs))
    fprintf (output_file, GLOBALLOC, ptr);
#if defined(__mips__)
  fputs ("\n\t.data\n", output_file);
  while (ptr = hashnext (globs))
    fprintf (output_file, "\t.word\t%s\n", ptr);
#endif

  fclose (output_file);
  exit (0);
}
