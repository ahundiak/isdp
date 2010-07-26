#include <fcntl.h>
#include <stdio.h>
#include "error.h"
#include "hash.h"

#define  NAMETABSZ  1000	/* size of the name table               */
#define  SECTTABSZ    10        /* size and increment for section table */

/* COFF definitions */

#include <filehdr.h>
#include <scnhdr.h>
#include <syms.h>
#include <storclass.h>

#define  FHEAD  struct filehdr
#define  SHEAD  struct scnhdr
#define  STE    struct syment
#define  ASTE   union  auxent

/* types */

#define  NAME  struct namerec
NAME {
       char  *name;		/* symbol name                    */
       short  priority;		/* 1=cmd line, 0=prototype file   */
       short  keep;		/* =1 if symbol is to be retained */
};

#define  REGEXP  struct regexp
REGEXP {
         char *next;		/* pointer to entry in list       */
         char *expr;		/* compiled regular expression    */
         int   keep;		/* =1 if symbol is to be retained */
};

#define  OBJDESCR  struct objdescr
OBJDESCR {
           int    fdescr;	/* file descriptor                     */
           int    sym_next;	/* next available output symbol index  */
           int    str_next;	/* next available output string index  */
           FHEAD  fhead;	/* contents of the file header         */
           SHEAD *sections;     /* pointer to array of section headers */
           char  *symbols;      /* pointer to the symbol table         */
           char  *strings;      /* pointer to the string table         */
};

/* externs */

extern char *stralloc ();

/* globals */

HASHTABLE  *nametable;		/* hash table of explicit names */
REGEXP     *regular = 0;	/* list of regular expressions  */
char      **s_names = 0;	/* array of -s section names    */
int         s_count = 0;	/* number of names in s_names   */
int         aflag   = 0;	/* -a option active or not?     */
int         cflag   = 0;	/* -c option active or not?     */
int         lflag   = 0;	/* -l option active or not?     */
int         xflag   = 0;	/* -x option active or not?     */

/* error recovery stuff */

#define  BADREGEXPR  &errinfo, 1
#define  OPENFAIL    &errinfo, 2
#define  PROTOERR    &errinfo, 3
#define  READFAIL    &errinfo, 4
#define  BADMAGIC    &errinfo, 5
#define  HASRELOCS   &errinfo, 6
#define  NOTEXEC     &errinfo, 7
#define  UKWNOPT     &errinfo, 8
#define  KERNALBUG   &errinfo, 9

char *messages[] = {

  "unused message.\n",
  "%s:  Bad regular expression.\n",
  "%s:  Could not open.\n",
  "%s:  Syntax error.\n",
  "%s:  Unable to read file header.\n",
  "%s:  Bad magic.\n",
  "%s:  Has relocation entries -- cannot strip.\n",
  "%s:  Not an executable image -- cannot strip.\n",
  "-%c:  Unknown option.\n",
  "Must copy file due to a bug in kernals prior to r.0.1.26.  You have %s.\n"
};

ERRDESCR errinfo = { { ERR_DFLT, ERR_DFLT, ERR_DFLT, ERR_DFLT },
                     {    0    ,    0    ,    0    ,    0     },
                     messages
};

/***************************************************************************/
/* All of this stuff is for a workaround of a bug preventing us from using */
/* the ftruncate system call on a fast file system in kernals prior to     */
/* version r.0.1.26							   */
/***************************************************************************/

#include <sys/types.h>
#include <sys/utsname.h>
#include <sys/stat.h>
#include <sys/statfs.h>
#include <sys/fstyp.h>
#include <sys/fsid.h>

char           *sneakyname;
struct utsname  kernal_version;

static int ok_kernal ()
{
  int        major, minor, bugfix;
  static int ok = -1;

  if (ok != -1)
    return ok;

  /* check kernal version (bug was fixed as of r.0.1.26) */

  if (uname (&kernal_version) == -1)
    return ok = 0;
  sscanf (kernal_version.version, "%*c.%d.%d.%d", &major, &minor, &bugfix);
  if (major > 0)
    return ok = 1;
  if (minor > 1)
    return ok = 1;
  if (minor < 1)
    return ok = 0;
  return ok = bugfix > 25;
}


int onfastfilesys (descr)

int descr;
{
  struct statfs fs_stat;
  char          fs_type[FSTYPSZ];

  if (fstatfs (descr, &fs_stat, sizeof (fs_stat), 0) == -1)
    return 0;
  if (sysfs (GETFSTYP, fs_stat.f_fstyp, fs_type) == -1)
    return 0;
  return strcmp (fs_type, FFS) == 0;
}


int truncfile (descr, len)

int descr, len;
{
  int         copy;
  struct stat f_stat;

  /* see if the kernal has the fix for ftruncate */

  if (!ok_kernal ()) {
    if (!onfastfilesys (descr))
      return !ftruncate (descr, len);
    report_error (KERNALBUG, ERR_WARNING, 0, kernal_version.version);
  }
  else return !ftruncate (descr, len);

  /* do it the hard way for buggy kernals */

  if (fstat (descr, &f_stat) == -1)
    return 0;
  if (len >= f_stat.st_size)
    return 1;

  /* create empty file of same name, owner, etc */

  if (unlink (sneakyname) == -1)
    return 0;
  copy = open (sneakyname, fcntl (descr, F_GETFL) | O_CREAT | O_TRUNC,
                                                               f_stat.st_mode);
  if (copy == -1 || chown (sneakyname, f_stat.st_uid, f_stat.st_gid) == -1)
    return 0;

  /* copy the data */

  { char buff[50000];
    int  bytes;
    int  offset = lseek (descr, 0, 1);

    if (offset == -1 || lseek (descr, 0, 0) == -1)
      return 0;
    while (len) {
      bytes = (len < sizeof (buff) ? len : sizeof (buff));
      if (read (descr, buff, bytes) == -1 || write (copy, buff, bytes) == -1)
        return 0;
      len -= bytes;
    }

    lseek (copy, offset, 0);
  }

  /* finagle file descriptors */

  close (descr);
  if (fcntl (copy, F_DUPFD, descr) != descr)
    return 0;
  close (copy);
  return 1;
}
/***************************************************************************/
/***************************************************************************/

void add_section (name)

char *name;
{
  static int alloc = 0;

  if (s_count >= alloc)
    s_names = (char **) realloc (s_names, (alloc += SECTTABSZ) * sizeof (char *));
  s_names[s_count++] = name;
}


REGEXP *insert_after (loc, new)

REGEXP *loc;
REGEXP *new;
{
  new->next = loc->next;
  return ((REGEXP *) (loc->next = (char *) new));
}


void add_name (name, priority, keep)

char *name;
int   priority;
int   keep;
{
  static REGEXP *last_low  = 0;   /* end of low priority list  */
  static REGEXP *last_high = 0;   /* end of high priority list */

  /* '%' at start of name denotes a regular expression */

  if (name[0] == '%') {
    REGEXP *new = (REGEXP *) malloc (sizeof (REGEXP));

    /* compile regular expression */

    if (!(new->expr = (char *) regcmp (name + 1, 0)))
      report_error (BADREGEXPR, ERR_FATAL, 0, name + 1);
    new->keep = keep;

    /* insert at high priority? */

    if (priority)
      if (last_high)
        last_high = insert_after (last_high, new);
      else {
        new->next = (char *) regular;
        regular   = last_high = new;
      }

    /* insert at low priority? */

    else if (regular)
      last_low = insert_after (last_low ? last_low : last_high, new);
    else (regular = last_low = new)->next = 0;
  }

  /* literal name */

  else {
    NAME new, *dup;

    new.name     = name;
    new.priority = priority;
    new.keep     = keep;

    if (!hashadd (nametable, &new, &dup))
      if (priority > dup->priority)
        hashrpl (nametable, &new);
      else dup->keep = keep || dup->keep;
  }
}


void read_proto (name)

char *name;
{
  FILE *proto;
  char  option;
  char  symname[512];

  /* open the prototype file */

  if (strcmp (name, "-") == 0)
    proto = stdin;
  else if (!(proto = fopen (name, "r")))
    report_error (OPENFAIL, ERR_FATAL, 0, name);

  while (1) {
    int code = fscanf (proto, " -%c %s%*[^\n]", &option, symname);

    if (code == EOF)
      break;
    if (code != 2)
      report_error (PROTOERR, ERR_FATAL, 0, name);

    switch (option) {
      case 'n':
        add_name (stralloc (symname), 0, 0);
        break;

      case 'k':
        add_name (stralloc (symname), 0, 1);
        break;

      default:
        report_error (PROTOERR, ERR_FATAL, 0, name);
    }
  }

  if (proto != stdin)
    fclose (proto);
}


OBJDESCR *read_object (name)

char *name;
{
  int       size;
  OBJDESCR *obj = (OBJDESCR *) malloc (sizeof (OBJDESCR));

  if ((obj->fdescr = open (name, O_RDWR, 0)) == -1) {
    report_error (OPENFAIL, ERR_ERROR, 0, name);
    goto error;
  }

  if (read (obj->fdescr, &obj->fhead, sizeof (FHEAD)) != sizeof (FHEAD)) {
    report_error (READFAIL, ERR_ERROR, 0, name);
    goto error;
  }

  if (obj->fhead.f_magic != CLIPPERMAGIC) {
    report_error (BADMAGIC, ERR_ERROR, 0, name);
    goto error;
  }

  if (!(obj->fhead.f_flags & F_RELFLG)) {
    report_error (HASRELOCS, ERR_ERROR, 0, name);
    goto error;
  }

  if (!(obj->fhead.f_flags & F_EXEC)) {
    report_error (NOTEXEC, ERR_ERROR, 0, name);
    goto error;
  }

  /* read section headers */

  size = obj->fhead.f_nscns * sizeof (SHEAD);
  lseek (obj->fdescr, obj->fhead.f_opthdr, 1);
  read (obj->fdescr, obj->sections = (SHEAD *) malloc (size), size);

  /* read symbol table */

  size = obj->fhead.f_nsyms * SYMESZ;
  lseek (obj->fdescr, obj->fhead.f_symptr, 0);
  read (obj->fdescr, obj->symbols = malloc (size), size);

  /* read string table */

  if (read (obj->fdescr, &size, 4) == 4)
    read (obj->fdescr, (obj->strings = malloc (size)) + 4, size - 4);
  else obj->strings = 0;

  /* save file name in case of old kernal */

  sneakyname = name;

  /* finish up */

  obj->sym_next = 0;
  obj->str_next = 4;
  return obj;
error:
  if (obj->fdescr != -1)
    close (obj->fdescr);
  free (obj);
  return 0;
}


void write_object (obj)

OBJDESCR *obj;
{
  SHEAD *libsect = 0;
  SHEAD *sect    = obj->sections;
  int    cnt     = obj->fhead.f_nscns;
  int    choploc = 0;

  /* adjust section headers and determine chop location (includes twit to
     allow .lib section to follow the symbol table) */

  for (; cnt; cnt--, sect++) {
    sect->s_lnnoptr = 0;
    sect->s_nlnno   = 0;
    if ( sect->s_scnptr > obj->fhead.f_symptr &&
         strncmp (sect->s_name, ".lib", 4) == 0  )
      libsect = sect;
    else if (sect->s_scnptr >= choploc)
      choploc = sect->s_scnptr + sect->s_size;
  }

  /* twit for .lib section after the symbol table */

  if (libsect) {
    char *buffer = malloc (libsect->s_size);

    lseek (obj->fdescr, libsect->s_scnptr, 0);
    read  (obj->fdescr, buffer, libsect->s_size);
    lseek (obj->fdescr, libsect->s_scnptr = choploc, 0);
    write (obj->fdescr, buffer, libsect->s_size);
    choploc += libsect->s_size;
  }

  /* truncate the file at the chop location */

  truncfile (obj->fdescr, choploc);

  /* write new symbol and string tables */

  if (obj->sym_next) {
    lseek (obj->fdescr, obj->fhead.f_symptr = choploc, 0);
    write (obj->fdescr, obj->symbols, obj->sym_next * SYMESZ);
    memcpy (obj->strings, &obj->str_next, sizeof (obj->str_next));
    write (obj->fdescr, obj->strings, obj->str_next);
  }

  /* update file header */

  if (!(obj->fhead.f_nsyms = obj->sym_next))
    obj->fhead.f_symptr = 0;
  lseek (obj->fdescr, 0, 0);
  write (obj->fdescr, &obj->fhead, sizeof (obj->fhead));

  /* update section headers */

  lseek (obj->fdescr, sizeof (FHEAD) + obj->fhead.f_opthdr, 0);
  write (obj->fdescr, obj->sections, obj->fhead.f_nscns * sizeof (SHEAD));

  /* free up space and close file */

  close (obj->fdescr);
  if (obj->sections)
    free (obj->sections);
  if (obj->symbols)
    free (obj->symbols);
  if (obj->strings)
    free (obj->strings);
  free (obj);
}


STE *get_symbol (obj, index, nameptr)

OBJDESCR *obj;
int       index;
char    **nameptr;
{
  static char name[9];
  static STE  align;
  STE        *sym;

  /* get aligned symbol table entry */

  sym = (STE *)(obj->symbols + (index * SYMESZ));
  if ((unsigned long)sym % 4) {
    memcpy (&align, sym, SYMESZ);
    sym = &align;
  }

  /* get symbol name */

  if (sym->n_zeroes)
    if (sym->n_name[7])
      memcpy (*nameptr = name, sym->n_name, 8);
    else *nameptr = sym->n_name;
  else *nameptr = obj->strings + sym->n_offset;

  return sym;
}


void put_symbol (obj, sym, name)

OBJDESCR *obj;
STE      *sym;
char     *name;
{
  int namelen = strlen (name);

  if (namelen > 8) {
    sym->n_offset = obj->str_next;
    memcpy (obj->strings + obj->str_next, name, namelen + 1);
    obj->str_next += namelen + 1;
  }
  memcpy (obj->symbols + SYMESZ * obj->sym_next++, sym, SYMESZ);
}


int keep_it (obj, symbol, name)

OBJDESCR *obj;
STE      *symbol;
char     *name;
{
  NAME   *by_name;
  REGEXP *by_regexp;

  switch (symbol->n_sclass) {
    case C_FILE:  return xflag;
    case C_EXT :  break;
    case C_STAT:  if (xflag) break;
    default    :  return 0;
  }

  /* ignore leading underscore if cflag set */

  if (cflag && *name == '_')
    name++;

  /* explicit name */

  if (by_name = hashlookup (nametable, name))
    return by_name->keep;

  /* regular expression */

  for (by_regexp = regular; by_regexp; by_regexp = (REGEXP *) by_regexp->next)
    if (regex (by_regexp->expr, name))
      return by_regexp->keep;

  /* remove anything not explicitly kept if aflag set */

  if (aflag)
    return 0;

  /* shared library */

  if (lflag && symbol->n_scnum == N_ABS) {
    SHEAD *sect = obj->sections;
    int    cnt  = obj->fhead.f_nscns;

    for (; cnt--; sect++)
      if ( symbol->n_value >= sect->s_vaddr                &&
           symbol->n_value <  sect->s_vaddr + sect->s_size &&
           sect->s_flags & STYP_NOLOAD                     &&
           strncmp (sect->s_name, ".fk", 3) == 0              )
        return 0;
  }

  /* section name */

  if (symbol->n_scnum > 0) {
    SHEAD *sect = obj->sections + symbol->n_scnum - 1;
    int    index;

    for (index = 0; index < s_count; index++)
      if (strcmp (s_names[index], sect->s_name) == 0)
        return 0;
  }

  /* when nothing else applies, keep it */

  return 1;
}


void create_dummy (obj)

OBJDESCR *obj;
{
  STE    symbol;
  ASTE   auxsym;
  SHEAD *sect;
  int    cnt;

  /* .file */

  memset (&symbol, 0, sizeof (symbol));
  memset (&auxsym, 0, sizeof (auxsym));
  symbol.n_scnum  = -2;
  symbol.n_sclass = C_FILE;
  symbol.n_numaux = 1;
  strcpy (symbol.n_name, ".file");
  strcpy (&auxsym, ".aoxomoxoa");
  put_symbol (obj, &symbol, "");
  put_symbol (obj, (STE *) &auxsym, "");

  /* sections */

  for (sect = obj->sections, cnt = obj->fhead.f_nscns; cnt--; sect++)
    if ( sect->s_flags == STYP_TEXT || sect->s_flags == STYP_DATA
                                    || sect->s_flags == STYP_BSS  ) {

      memset (&symbol, 0, sizeof (symbol));
      memset (&auxsym, 0, sizeof (auxsym));
      symbol.n_value  = sect->s_vaddr;
      symbol.n_scnum  = sect - obj->sections + 1;
      symbol.n_sclass = C_STAT;
      symbol.n_numaux = 1;
      auxsym.x_scn.x_scnlen = sect->s_size;
      strncpy (symbol.n_name, sect->s_name, 8);
      put_symbol (obj, &symbol, "");
      put_symbol (obj, (STE *) &auxsym, "");
    }
}


void strip_it (filename)

char *filename;
{
  OBJDESCR *obj;
  STE      *symbol;
  char     *name;
  int       symindex = 0;
  int       symcnt   = 0;
  int       lastfile = -1;
  int       firstextern = 0;

  /* read the pertinate info from the file to be stripped */

  if (!(obj = read_object (filename)))
    return;

  /* for each symbol, decide if we should keep it */

  while (symindex < obj->fhead.f_nsyms) {
    symbol    = get_symbol (obj, symindex, &name);
    symindex += symbol->n_numaux + 1;
    if (keep_it (obj, symbol, name)) {
      switch (symbol->n_sclass) {

        case C_EXT:
          if (lastfile == -1) {
            lastfile = obj->sym_next;
            create_dummy (obj);
          }
          if (!firstextern)
            firstextern = obj->sym_next;

        case C_STAT:
          if (*name == '.') {
            put_symbol (obj, symbol, name);
            symbol = get_symbol (obj, symindex - 1, &name);
            break;
          }

        default:
          symbol->n_numaux = 0;
          symbol->n_type   = 0;
          symcnt++;
          break;

        case C_FILE:
          if (lastfile != -1)
            if (!symcnt)
              obj->sym_next = lastfile;
            else memcpy (&((STE *)(obj->symbols + lastfile * SYMESZ))->n_value,
                                                 &obj->sym_next, sizeof (int));
          lastfile    = obj->sym_next;
          firstextern = 0;
          symcnt      = 0;
          put_symbol (obj, symbol, name);
          symbol = get_symbol (obj, symindex - 1, &name);
          break;
      }

      put_symbol (obj, symbol, name);
    }
  }

  if (lastfile != -1)
    memcpy (&((STE *)(obj->symbols + lastfile * SYMESZ))->n_value,
                                                   &firstextern, sizeof (int));
  write_object (obj);
}


void main (argc, argv)

int    argc;
char **argv;
{
  nametable = hashinit (NAME, NAMETABSZ, hashc, strcmp, name, INDKEY);

  /* handle options */

  for (argv++; --argc && argv[0][0] == '-'; argv++) {
    switch (argv[0][1]) {

      case 'a':
        aflag = 1;
        continue;

      case 'c':
        cflag = 1;
        continue;

      case 'l':
        lflag = 1;
        continue;

      case 'x':
        xflag = 1;
        continue;

      case 's':
        add_section (argv[1]);
        break;

      case 'n':
        add_name (argv[1], 1, 0);
        break;

      case 'k':
        add_name (argv[1], 1, 1);
        break;

      case 'p':
        read_proto (argv[1]);
        break;

      default:
        report_error (UKWNOPT, ERR_FATAL, 0, argv[0][1]);
    }

    /* compensate for option argument */

    argc--;
    argv++;
  }

  /* process each file given */

  for (; argc--; argv++)
    strip_it (*argv);
  exit (0);
}
