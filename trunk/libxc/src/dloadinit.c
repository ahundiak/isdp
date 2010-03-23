#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include "malloc.h"
#include "error.h"
#include "hash.h"
#define OBJFD void
#define OBJINFO void
#include "dloadpvt.h"

#define  MAPADDRESS  0xc0c00000
#define  Malloc      malloc
#define  Realloc     realloc

extern char *stralloc   ();

/********************************************/
/* ERROR RECOVERY AND REPORTING INFORMATION */
/********************************************/

#define  INTERNAL  &errinfo,  1
#define  OUTOFMEM  &errinfo,  2
#define  OPENFAIL  &errinfo,  3
#define  CLOSFAIL  &errinfo,  4
#define  SEEKFAIL  &errinfo,  5
#define  READFAIL  &errinfo,  6
#define  RITEFAIL  &errinfo,  7
#define  UNEXPEOF  &errinfo,  8
#define  BADMAGIC  &errinfo,  9
#define  NOSYMBOL  &errinfo, 10
#define  INVLDMAP  &errinfo, 11
#define  NODLSECT  &errinfo, 12
#define  ALDYINIT  &errinfo, 13
#define  MUSTBEXE  &errinfo, 14
#define  INFOMSG   &errinfo, 15


static char *msgtable[] = {

  "",
  "INTERNAL, Internal error:  %s, contact support.\n",
  "OUTOFMEM, Out of memory:  could not allocate %d bytes.\n",
  "OPENFAIL, \"%s\":  Unable to open file for input.\n",
  "CLOSFAIL, \"%s\":  Unable to close file.\n",
  "SEEKFAIL, \"%s\":  Seek failure.\n",
  "READFAIL, \"%s\":  Read failure.\n",
  "RITEFAIL, \"%s\":  Write failure.\n",
  "UNEXPEOF, \"%s\":  Unexpected end of file.\n",
  "BADMAGIC, \"%s\":  Bad magic  --  file is not an object file.\n",
  "NOSYMBOL, \"%s\":  File does not have a symbol table.\n",
  "INVLDMAP, Invalid address mapping for symbol table.\n",
  "NODLSECT, \"%s\":  No .dload section  --  cannot continue.\n",
  "ALDYINIT, \"%s\":  File has already been initialized.\n",
  "MUSTBEXE, \"%s\":  File must be executable for this operation.\n",
  "\t%s\n"
};


static ERRDESCR errinfo = {

  {  ERR_DFLT,    ERR_DFLT,    ERR_DFLT,     ERR_DFLT   },
  {     0,       "%DLOAD-W-", "%DLOAD-E-", "%DLOAD-F-" },
     msgtable
};


static void report_errno ()
{
  extern int   errno;
  extern char *sys_errlist[];

  report_error (INFOMSG, ERR_INFO, 0, sys_errlist[errno]);
}

static FD *Open (path, oflag, mode)

char *path;
int   oflag;
int   mode;
{
  FD  *fildes;
  int  ret = open (path, oflag, mode);

  if (ret == -1) {
    report_error (OPENFAIL, ERR_FATAL, report_errno, path);
    return 0;
  }
  fildes = (FD *)Malloc ((int)&((FD *)0)->name[strlen (path) + 1]);
  fildes->fileno = ret;
  strcpy (fildes->name, path);
  return fildes;
}


static int Close (fildes)

FD *fildes;
{
  int ret = close (fildes->fileno);

  if (ret == -1)
    report_error (CLOSFAIL, ERR_FATAL, report_errno, fildes->name);
  free (fildes);
  return ret;
}


static long Seek (fildes, offset, whence)

FD   *fildes;
uint  offset;
int   whence;
{
  long ret = lseek (fildes->fileno, offset, whence);

  if (ret == -1)
    report_error (SEEKFAIL, ERR_FATAL, report_errno, fildes->name);
  return ret;
}


static int Write (fildes, buf, nbyte)

FD   *fildes;
void *buf;
uint  nbyte;
{
  int ret = write (fildes->fileno, buf, nbyte);

  if (ret == -1)
    report_error (RITEFAIL, ERR_FATAL, report_errno, fildes->name);
  return ret;
}


static int Read (fildes, buf, nbyte)

FD   *fildes;
void *buf;
uint  nbyte;
{
  int ret = read (fildes->fileno, buf, nbyte);

  if (ret == -1)
    report_error (READFAIL, ERR_FATAL, report_errno, fildes->name);
  return ret;
}


static int Reads (fildes, buf, nbyte)

FD   *fildes;
void *buf;
uint  nbyte;
{
  int ret = read (fildes->fileno, buf, nbyte);

  if (ret == -1)
    report_error (READFAIL, ERR_FATAL, report_errno, fildes->name);
  else if (ret != nbyte)
    report_error (UNEXPEOF, ERR_FATAL, 0, fildes->name);
  return ret;
}

/*****************************************************************************/
/*									     */
/*                          FILE BUFFERING ROUTINES                          */
/*									     */
/*****************************************************************************/


static BUFFER *openbuffer (file, psize, lbase, lsize)

FD   *file;
uint  psize;
uint  lbase;
uint  lsize;
{
  BUFFER *buff = Space (1, BUFFER);

  buff->file  = file;
  buff->lsize = lsize;
  buff->lbase = lbase;
  buff->pbase = 0;
  buff->rbase = 0;
  buff->strsz = 0;
  buff->data  = Malloc (buff->psize = MIN (psize, lsize));
  Seek (file, lbase, 0);
  Reads (file, buff->data, buff->psize);

  return buff;
}


static BUFFER *closebuffer (buff)

BUFFER *buff;
{
  if (buff) {
    free (buff->data);
    free (buff);
  }
  return 0;
}


static void *getdata (buff, offset, size, rflag)

BUFFER *buff;
uint    offset;
uint    size;
int     rflag;
{
  int poffset;

  /* Get buffer offset and check for end of data. */

  if (rflag)
    offset += buff->rbase;
  if (offset >= buff->lsize)
    return 0;

  /* Request for null-terminated string when size is zero. */

  if (!size && !(size = buff->strsz)) {
    char *temp = buff->data + MIN (buff->psize, buff->lsize - buff->pbase);
    for (size = 1; *--temp; size++);
    buff->strsz = size;
  }

  /* Determine physical buffer offset and if outside the physical buffer, fill
     from the file (assumes size <= buff->psize). */

  poffset = offset - buff->pbase;
  if (poffset < 0 || poffset + size > buff->psize) {
    uint nbytes = MIN (buff->psize, buff->lsize - offset);

    Seek (buff->file, buff->lbase + offset, 0);
    Reads (buff->file, buff->data, nbytes);
    buff->pbase = offset;
    buff->strsz = 0;
    poffset     = 0;
  }

  /* Return data address. */

  buff->rbase = offset + size;
  return buff->data + poffset;
}

/*****************************************************************************/
/*									     */
/*                           OBJECT FILE ROUTINES                            */
/*									     */
/*****************************************************************************/

static OBJFILE *object_ropen (descr, base)

FD  *descr;
int  base;
{
  int      size;
  OBJFILE *obj = Space (1, OBJFILE);

  obj->fdescr  = descr;
  obj->fbase   = base;
  obj->symbuff = 0;
  obj->strbuff = 0;
  obj->relbuff = 0;
  obj->lnobuff = 0;

  /* Read the file header and check magic. */

  Seek (descr, base, 0);
  size = Read (descr, (void *)&obj->fhead, sizeof (obj->fhead));
  if (size < sizeof (obj->fhead) || !OBJECTMAGIC (obj->fhead.f_magic))
    report_error (BADMAGIC, ERR_FATAL, 0, descr->name);

  /* Read section headers. */

  obj->sections = Space (obj->fhead.f_nscns, SCNHDR);
  Seek (descr, obj->fhead.f_opthdr, 1);
  Reads (descr, (void *)obj->sections, obj->fhead.f_nscns * sizeof (SCNHDR));

  /* Return the object descriptor. */

  return obj;
}


static OBJFILE *object_open (name)

char *name;
{
  return object_ropen (Open (name, O_RDONLY, 0), 0);
}


static void object_close (obj)

OBJFILE *obj;
{
  Close (obj->fdescr);
  closebuffer (obj->symbuff);
  closebuffer (obj->strbuff);
  closebuffer (obj->relbuff);
  closebuffer (obj->lnobuff);
  free (obj->sections);
  free (obj);
}


static SCNHDR *find_shead_by_name (obj, name)

OBJFILE *obj;
char    *name;
{
  SCNHDR *section = obj->sections;
  int     cnt     = obj->fhead.f_nscns;

  for (; cnt--; section++)
    if (strncmp (section->s_name, name, sizeof (section->s_name)) == 0)
      return section;
  return 0;
}


static void *read_section (obj, sect)

OBJFILE *obj;
SCNHDR  *sect;
{
  void *data = Malloc (sect->s_size);

  Seek (obj->fdescr, obj->fbase + (uint)sect->s_scnptr, 0);
  Reads (obj->fdescr, data, (uint)sect->s_size);
  return data;
}


static void symbol_init (obj)

OBJFILE *obj;
{
  int size;
  int strsz;

  /* The string table follows the symbol table.  An int at start gives the
     total size including the int.  There may not be a string table present. */

  if (size = SYMESZ * obj->fhead.f_nsyms) {
    obj->symbuff = openbuffer (obj->fdescr, SYMESZ * SYMBUFFSZ,
				 obj->fbase + (uint)obj->fhead.f_symptr, size);
    Seek (obj->fdescr, obj->fbase + (uint)obj->fhead.f_symptr + size, 0);
    if (Read (obj->fdescr, (void *)&strsz, sizeof (strsz)) == sizeof (strsz))
      obj->strbuff = openbuffer (obj->fdescr, STRBUFFSZ,
			 obj->fbase + (uint)obj->fhead.f_symptr + size, strsz);
  }
}


static SYMENT *get_symbol (obj, skip)

OBJFILE *obj;
int      skip;
{
  static SYMENT align;
  SYMENT       *sym;

  /* Get symbol and if out of range return 0. */

  if (!(sym = getdata (obj->symbuff, SYMESZ * skip, SYMESZ, 1))) {
    obj->symbuff = closebuffer (obj->symbuff);
    obj->strbuff = closebuffer (obj->strbuff);
    return 0;
  }

  /* Align symbol table entry if required. */

  if (!ALIGNED (sym, SYMENT)) {
    memcpy (&align, sym, SYMESZ);
    sym = &align;
  }

  /* Return symbol. */

  return sym;
}


static char *get_symbol_name (obj, sym)

OBJFILE *obj;
SYMENT  *sym;
{
  static char name[9];

  /* Get symbol name. */

  if (sym->n_zeroes)
    if (sym->n_name[7])
      return (char *)memcpy (name, sym->n_name, 8);
    else return sym->n_name;
  else return getdata (obj->strbuff, (uint)sym->n_offset, 0, 0);
}

static int load_initial_symbols (obj, hashtab, bufptr)

OBJFILE   *obj;
HASHTABLE *hashtab;
SHORTSYM **bufptr;
{
  SHORTSYM *buffer;
  SHORTSYM *new;
  SYMENT   *coff;
  char     *name;
  int       cnt;

  /* make sure there is a symbol table */

  if (!obj->fhead.f_nsyms) {
    report_error (NOSYMBOL, ERR_WARNING, 0, obj->fdescr->name);
    *bufptr = 0;
    return 0;
  }

  /* Initialize buffer for worst case (will free unused portion later) */

  buffer = new = Space (obj->fhead.f_nsyms, SHORTSYM);

  /* For each global symbol save name and address. */

  symbol_init (obj);
  coff = get_symbol (obj, 0);
  for (; coff; coff = get_symbol (obj, coff->n_numaux))
    if (coff->n_sclass == C_EXT) {
      name = get_symbol_name (obj, coff);
      if (!hashtab || !hashlookup (hashtab, name)) {
        new->n_value = coff->n_value;
        new->name    = stralloc (name);
        if (hashtab) hashadd (hashtab, new, 0);
        new++;
      }
    }

  /* Free any unused space at end of buffer and return number of symbols */

  cnt     = new - buffer;
  *bufptr = Resize (buffer, cnt, SHORTSYM);
  return cnt;
}


void main (argc, argv)

int    argc;
char **argv;
{
  OBJFILE   *obj;
  HASHTABLE *htab;
  SHORTSYM  *sym;
  SCNHDR    *dlsect;
  SCNHDR    *libsect;
  FD        *fdescr;
  char      *libbuff = 0;
  int        nsyms;
  int        datasz;
  int        padsz;
  int        start = 0;
  int        filesize;
  int        mapaddr = MAPADDRESS;
  int        qflag   = 0;
  int        sflag   = 0;
  int        cnt;

  /* process options */

  if (argc != 2) {
    fprintf (stderr, "usage:  dloadinit executable_file\n");
    exit (231);
  }

  /* open the file */

  fdescr = Open (argv[1], O_RDWR, 0);
  obj    = object_ropen (fdescr, 0);

  /* check to see if we can do this on this file */

  if (!(obj->fhead.f_flags & F_EXEC))
    report_error (MUSTBEXE, ERR_FATAL, 0, fdescr->name);
  if (!(dlsect = find_shead_by_name (obj, ".dload")))
    report_error (NODLSECT, ERR_FATAL, 0, fdescr->name);
  if (dlsect->s_scnptr)
    report_error (ALDYINIT, ERR_FATAL, 0, fdescr->name);
  if (!obj->fhead.f_nsyms)
    report_error (NOSYMBOL, ERR_FATAL, 0, fdescr->name);

  /* load the initial set of symbols */

  nsyms = cnt = load_initial_symbols (obj, (HASHTABLE *)0, &sym);

  /* create temporary hashtable (needed to prevent duplicate symbols from
     shared libraries) */

  htab = hashinit (SHORTSYM, cnt + cnt/2, hashc, strcmp, name, INDKEY | NOMEM);
  for (; cnt--; sym++)
    hashadd (htab, sym, 0);

  /* load symbols from any shared library targets */

  if (libsect = find_shead_by_name (obj, ".lib")) {
    long *shlib = (long *)(libbuff = read_section (obj, libsect));

    while ((char *)shlib < libbuff + libsect->s_size) {
      OBJFILE *obj = object_open ((char *)(shlib + shlib[1]));

      nsyms += load_initial_symbols (obj, htab, &sym);
      object_close (obj);
      shlib += shlib[0];
    }
  }

  /* get the file's size */

  { struct stat info;

    fstat (fdescr->fileno, &info);
    filesize = info.st_size;
  }

  /* calculate required segment size (must be 8-byte multiple) */

  datasz = sizeof (HASHTABLE) + (nsyms - 1) * sizeof (HCHAIN *) +
           nsyms * sizeof (HCHAIN) + nsyms * sizeof (SHORTSYM);
  while (sym = hashnext (htab))
    datasz += strlen (sym->name) + 1;
  datasz = (datasz + 7) & ~7;

  /* determine where to put section data (watch out for .lib section following
     the symbol table as done by "mls -q") */

  if (qflag && !sflag)
    start = (filesize + 7) & ~7;
  else {
    int     symsz;
    char   *symbuff;
    SCNHDR *scnhdr = obj->sections;

    for (cnt = obj->fhead.f_nscns; cnt--; scnhdr++) {
      if (scnhdr->s_lnnoptr > start && !sflag)
        start = scnhdr->s_lnnoptr + LINESZ * scnhdr->s_nlnno;
      if (scnhdr->s_scnptr > start && scnhdr->s_scnptr < obj->fhead.f_symptr)
        start = scnhdr->s_scnptr + scnhdr->s_size;
    }
    start = (start + 7) & ~7;

    /* read in the symbol and string tables since we will be relocating them
       (or removing with -s) */

    if (!sflag) {
      if (libsect->s_scnptr > obj->fhead.f_symptr)
        symsz = libsect->s_scnptr - obj->fhead.f_symptr;
      else symsz = filesize - obj->fhead.f_symptr;
      Seek (fdescr, (uint)obj->fhead.f_symptr, 0);
      Reads (fdescr, symbuff = malloc (symsz), symsz);
    }

    /* if the .lib section follows the symbol table, put it back where it
       belongs */

    if (libsect->s_scnptr > obj->fhead.f_symptr) {
      Seek (fdescr, start, 0);
      Write (fdescr, libbuff, (uint)libsect->s_size);
      libsect->s_scnptr = start;
      start = (start + libsect->s_size + 7) & ~7;
    }

    /* write out the symbol and string tables to the correct place */

    Seek (fdescr, (uint)(obj->fhead.f_symptr = start + datasz), 0);
    Write (fdescr, symbuff, symsz);
    free (symbuff);
  }

  /* hashtable must start at some offset from this location due to the
     requirement that the file offset must be page-aligned */

  padsz            = start & 0xfff;
  dlsect->s_paddr  = dlsect->s_vaddr = mapaddr + padsz;
  dlsect->s_size   = datasz;
  dlsect->s_scnptr = start;
  dlsect->s_flags  = STYP_DATA | STYP_COPY;

  /* get memory at the well-known address using a memory-mapped file */

  { char *filename = (char *)tempnam ("/usr/tmp", ".mem");
    FD   *descr    = Open (filename, O_RDWR | O_CREAT, 0700);

    Seek (descr, datasz + padsz - 4, 0);
    Write (descr, (void *)&datasz, 4);
    if (MAPADDRESS != mmap (MAPADDRESS, datasz + padsz, PROT_READ | PROT_WRITE,
                                MAP_PRIVATE | MAP_FIXED, descr->fileno, 0))
      report_error (INVLDMAP, ERR_FATAL, 0);
    Close (descr);
  }

  /* manually constuct the required hashtable */

  { HASHTABLE *hash  = (HASHTABLE *)(mapaddr + padsz);
    HCHAIN    *chead = (HCHAIN *)&hash->body[nsyms];
    SHORTSYM  *rec   = (SHORTSYM *)&chead[nsyms];
    char      *strtb = (char *)&rec[nsyms];

    sym = hashlookup (htab, "_hashc");
    hash->hashfn = (int (*)())sym->n_value;
    sym = hashlookup (htab, "_strcmp");
    hash->compfn = (int (*)())sym->n_value;
    hash->options   = htab->options;
    hash->koffset   = htab->koffset;
    hash->recsize   = htab->recsize;
    hash->linear    = htab->linear;
    hash->delete    = htab->delete;
    hash->blkno     = htab->blkno;
    hash->tbllength = nsyms;
    hash->hfree     = 0;
    hash->rfree     = 0;
    hash->ptrs.incr = 0;
    hash->ptrs.dim  = 0;
    hash->ptrs.body = 0;
    hash->psize     = 0;
    hash->c_index   = 0;
    hash->c_chain   = 0;
    while (nsyms--)
      hash->body[nsyms] = 0;

    while (sym = hashnext (htab)) {
      int ndx = hashc (sym->name, hash->tbllength);

      chead->record   = rec;
      chead->next     = hash->body[ndx];
      hash->body[ndx] = chead;
      chead++;
      rec->n_value = sym->n_value;
      rec->name    = strtb;
      rec++;
      strcpy (strtb, sym->name);
      strtb += strlen (strtb) + 1;
    }

    hashinfo (hash);

    /* write the section data to the file */

    Seek (fdescr, start, 0);
    Write (fdescr, (void *)hash, datasz);
  }

  /* write file and section headers since these may have changed */

  Seek (fdescr, 0, 0);
  Write (fdescr, (void *)&obj->fhead, sizeof (obj->fhead));
  Seek (fdescr, obj->fhead.f_opthdr, 1);
  Write (fdescr, (void *)obj->sections, SCNHSZ * obj->fhead.f_nscns);

  Close (fdescr);
}
