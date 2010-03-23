#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <setjmp.h>
#include <string.h>
#include <fcntl.h>
#include <stdarg.h>
#ifndef SunOS_4x
#include <stdlib.h>
#endif
#include <stdio.h>
#include "errordef.h"
#include "error.h"
#include "xcmisc.h"
#include "hash.h"
#include "objaccess.h"
#include "dloadpvt.h"
#include "dload.h"
#if CLIX
#include <sys/pioctl.h>
extern char *tempnam (char *, char *);
extern void *mmap    (void *, int, int, int, int, off_t);
#endif
#if SunOS
#include <link.h>
#endif
#if IRIX_4x
#include <sys/cachectl.h>
#endif
#if IRIX_5x
#include <sys/cachectl.h>
#include <obj.h>
#endif

#define  SYMTBL_MAIN   0
#define  SYMTBL_DYNAM  0
#define  SYMTBL_PEND   1

#define  MAXPATHLEN  1024
#define  MAXFILELEN    14

static jmp_buf    errorloc;
static HASHTABLE *symtab[2];
static HASHTABLE *filehash;
static HASHTABLE *taghash;
static REGION    *regionlist = 0;
static SLOTTBL   *slottables = 0;
static uint       pagesz;
static uint       grabsz;
static int        procfile;
static int        zero;
static char      *zeroname;
static int        G_options = 0;
static OBJINFO    nullinfo;
static SRE       *Rsaved_new = 0;
static SRE       *Rsaved = 0;
static HANDLE    *F_pending;
static HANDLE    *F_loaded;
static HANDLE    *active;
static ALIGNDEF   aligner[] = ADDRALIGN;
static int        initialized = 0;

/* debugger support */

volatile int dload__DBG_active   = 0;
static   int dload__DBG_retrocnt = 0;
static  void process_DBG (HANDLE *handle);	/* forward */
void dload__DBG_notify (void *debuginfo);	/* forward */
void dload__DBG_unload (void *debuginfo);	/* forward */

/* Some symbols (esp those in shared libraries) require special treatment in
   order to be processed correctly */

struct spclsym {
    char *name;		/* name of special symbol        */
    int   flags;	/* flags to set when encountered */
};

static struct spclsym special[] = {
#if SunOS_4x
  { "_etext",			SYM_GLOB | SYM_TEXT | SYM_LAB | SYM_HIDE },
  { "_edata",			SYM_GLOB | SYM_DATA | SYM_LAB | SYM_HIDE },
  { "_end",			SYM_GLOB | SYM_BSS  | SYM_LAB | SYM_HIDE },
  { "__GLOBAL_OFFSET_TABLE_",	SYM_GLOB | SYM_DATA | SYM_VAR | SYM_HIDE },
#endif
#if SunOS_5x
  { "_etext",			SYM_GLOB | SYM_TEXT | SYM_LAB | SYM_HIDE },
  { "_edata",			SYM_GLOB | SYM_DATA | SYM_LAB | SYM_HIDE },
  { "_end",			SYM_GLOB | SYM_BSS  | SYM_LAB | SYM_HIDE },
  { "etext",			SYM_GLOB | SYM_TEXT | SYM_LAB | SYM_HIDE },
  { "edata",			SYM_GLOB | SYM_DATA | SYM_LAB | SYM_HIDE },
  { "end",			SYM_GLOB | SYM_BSS  | SYM_LAB | SYM_HIDE },
  { "_PROCEDURE_LINKAGE_TABLE_",SYM_GLOB | SYM_DATA | SYM_VAR | SYM_HIDE },
  { "_GLOBAL_OFFSET_TABLE_",	SYM_GLOB | SYM_DATA | SYM_VAR | SYM_HIDE },
  { "_DYNAMIC",			SYM_GLOB | SYM_DATA | SYM_VAR | SYM_HIDE },
#endif
#if IRIX_5x
  { "_gp_disp",			SYM_GLOB | SYM_DATA | SYM_LAB | SYM_HIDE },
  { "_procedure_string_table",  SYM_GLOB | SYM_DATA | SYM_LAB | SYM_HIDE },
  { "_procedure_table",		SYM_GLOB | SYM_DATA | SYM_LAB | SYM_HIDE },
  { "_procedure_table_size",	SYM_GLOB | SYM_ABS  | SYM_LAB | SYM_HIDE },
#endif
  { 0, 0 }
};

static void check_special (SYMBOL *sym)
{
  struct spclsym *spcl;

  for (spcl = special; spcl->name; spcl++)
    if (0 == strcmp (spcl->name, sym->name)) {
      sym->whatis = spcl->flags;
      break;
    }
}

/********************************************/
/* ERROR RECOVERY AND REPORTING INFORMATION */
/********************************************/

#define  DL_F_UNPORTED  &errinfo,  0, ERR_FATAL, 0
#define  DL_F_INTERNAL  &errinfo,  1, ERR_FATAL, 0
#define  DL_F_OUTOFMEM  &errinfo,  2, ERR_FATAL, 0
#define  DL_E_UNRESOLV  &errinfo,  3, ERR_ERROR, list_unresolves
#define  DL_W_LOADURES  &errinfo,  4, ERR_WARNING, list_unresolves
#define  DL_E_OPENFAIL  &errinfo,  5, ERR_ERROR, report_errno
#define  DL_W_CLOSFAIL  &errinfo,  6, ERR_WARNING, report_errno
#define  DL_E_SEEKFAIL  &errinfo,  7, ERR_ERROR, report_errno
#define  DL_E_READFAIL  &errinfo,  8, ERR_ERROR, report_errno
#define  DL_E_RITEFAIL  &errinfo,  9, ERR_ERROR, report_errno
#define  DL_E_UNEXPEOF  &errinfo, 10, ERR_ERROR, 0
#define  DL_E_RELOCFMT  &errinfo, 11, ERR_ERROR, 0
#define  DL_E_BADMAGIC  &errinfo, 12, ERR_ERROR, 0
#define  DL_E_NOSYMTAB  &errinfo, 13, ERR_ERROR, 0
#define  DL_E_NOSYMBOL  &errinfo, 14, ERR_ERROR, 0
#define  DL_W_NOSYMBOL  &errinfo, 14, ERR_WARNING, 0
#define  DL_E_NORELOCS  &errinfo, 15, ERR_ERROR, 0
#define  DL_W_MULTIDEF  &errinfo, 16, ERR_WARNING, 0
#define  DL_W_SIZEDIFF  &errinfo, 17, ERR_WARNING, 0
#define  DL_W_COMREDEF  &errinfo, 18, ERR_WARNING, 0
#define  DL_W_COMREMAP  &errinfo, 19, ERR_WARNING, 0
#define  DL_E_ILLRDEFF  &errinfo, 20, ERR_ERROR, 0
#define  DL_E_ILLRDEFV  &errinfo, 21, ERR_ERROR, 0
#define  DL_W_REDEFFCN  &errinfo, 22, ERR_WARNING, 0
#define  DL_W_REDEFVAR  &errinfo, 23, ERR_WARNING, 0
#define  DL_W_SPECLDEF  &errinfo, 24, ERR_WARNING, 0
#define  DL_F_IOERROR   &errinfo, 25, ERR_FATAL, report_errno
#define  DL_F_MMAPFAIL  &errinfo, 26, ERR_FATAL, report_errno
#define  DL_F_MODIFIED  &errinfo, 27, ERR_FATAL, 0
#define  DL_E_DISABLED  &errinfo, 28, ERR_ERROR, 0
#define  DL_E_ALDYLOAD  &errinfo, 29, ERR_ERROR, 0
#define  DL_E_LOADCMPL  &errinfo, 30, ERR_ERROR, 0
#define  DL_E_NOFILES   &errinfo, 31, ERR_ERROR, 0
#define  DL_W_MEMPROT   &errinfo, 32, ERR_WARNING, 0
#define  DL_E_RELOCOVFL &errinfo, 33, ERR_ERROR, 0
#define  DL_F_NOPATCH   &errinfo, 34, ERR_FATAL, report_errno
#define  DL_E_BADHANDLE &errinfo, 35, ERR_ERROR, 0
#define  DL_F_NOHELPER  &errinfo, 36, ERR_FATAL, 0
#define  DL_E_TAGEXIST  &errinfo, 37, ERR_ERROR, 0
#define  DL_E_TAGNOTFND &errinfo, 38, ERR_ERROR, handle_reactive
#define  DL_F_RLDABORT  &errinfo, 39, ERR_FATAL, 0
#define  DL_I_INFOMSG   &errinfo, 40, ERR_INFO, 0
#define  DL_I_SYMINIT   &errinfo, 41, ERR_INFO, 0
#define  DL_I_LOADED    &errinfo, 42, ERR_INFO, 0
#define  DL_I_INCRLOAD  &errinfo, 43, ERR_INFO, 0
#define  DL_I_LOADCMPL  &errinfo, 44, ERR_INFO, 0


static char *msgtable[] = {

  "UNPORTED, Loader not correctly ported for this environment.\n",
  "INTERNAL, Internal error:  %s, contact support.\n",
  "OUTOFMEM, Out of memory:  could not allocate %d bytes.\n",
  "UNRESOLV, File not loaded due to %d unresolved symbols.\n",
  "LOADURES, Loading with %d unresolved symbols - mapped to address 0x%.8x.\n",
  "OPENFAIL, \"%s\":  Unable to open file for input.\n",
  "CLOSFAIL, \"%s\":  Unable to close file.\n",
  "SEEKFAIL, \"%s\":  Seek failure.\n",
  "READFAIL, \"%s\":  Read failure.\n",
  "RITEFAIL, \"%s\":  Write failure.\n",
  "UNEXPEOF, \"%s\":  Unexpected end of file.\n",
  "RELOCFMT, \"%s\":  Unsupported relocation format (%d).\n",
  "BADMAGIC, \"%s\":  Bad magic  --  file is not an object file.\n",
  "NOSYMTAB, \"%s\":  Failure mapping pre-defined symbol table.\n",
  "NOSYMBOL, \"%s\":  File does not have a symbol table.\n",
  "NORELOCS, \"%s\":  Relocation entries have been stripped.\n",
  "MULTIDEF, \"%s\":  Common \"%s\" is multiply-defined.\n",
  "SIZEDIFF, \"%s\":  Common \"%s\" has more than one size (larger taken).\n",
  "COMREDEF, \"%s\":  Common \"%s\" mapped to a definition from this file.\n",
  "COMREMAP, \"%s\":  Common \"%s\" mapped to an existing definition.\n",
  "ILLREDEF, \"%s\":  Illegal redefinition of global function \"%s\".\n",
  "ILLREDEF, \"%s\":  Illegal redefinition of global variable \"%s\".\n",
  "REDEFFCN, \"%s\":  Redefining global function \"%s\".\n",
  "REDEFVAR, \"%s\":  Redefining global variable \"%s\".\n",
  "SPECLDEF, \"%s\":  Redefining special symbol \"%s\" may yield unexpected results.\n",
  "IOERROR:  Unrecoverable I/O error.\n",
  "MMAPFAIL:  Fatal error trying to memory map a file.\n",
  "MODIFIED, \"%s\":  File was modified during loader processing!\n",
  "DISABLED:  %s disabled in this release due to not being ready.\n",
  "ALDYLOAD, \"%s\":  File has already been loaded.\n",
  "LOADCMPL, \"%s\":  LOADCMPL already done for this file.\n",
  "NOFILES:  LOADCMPL attempted with zero incrementally loaded files.\n",
  "MEMPROT:  Error %s writes to memory at 0x%.8x.\n",
  "RELOCOVFL:  Overflow of %d-bit relocation field at 0x%.8x.\n",
  "NOPATCH:  Could not patch text at 0x%.8x.\n",
  "BADHANDLE:  Bad handle passed to \"%s\".\n",
  "NOHELPER:  Could not start helper process \"/usr/bin/dlhelper\".\n",
  "TAGEXIST:  Reactive load tag \"%s\" already exists.\n",
  "TAGNOTFND, \"%s\":  Reactive load tag \"%s\" not found.\n",
  "RLDABORT, \"%s\":  Fatal reactive load abort.\n",
  "\t%s\n",
  "%%DLOAD-I-SYMINIT:  Initializing symbol table from \"%s\".\n",
  "%%DLOAD-I-LOADED:  Successful load of file \"%s\".\n",
  "%%DLOAD-I-INCRLOAD:  Incrementally loaded file \"%s\".\n",
  "%%DLOAD-I-LOADCMPL:  Successful completion of load for \"%s\".\n"
};


static void errortrap (char *msg, int severity)
{
  if (severity != ERR_WARNING || !(G_options & NOWARNING))
    fputs (msg, stderr);
}


/* Error recovery and reporting functions */

static void recover ()
{
  /***** Invoke memory cleanup here !!!! *****/

  if (initialized)
    longjmp (errorloc, 1);
}


static ERRDESCR errinfo = {

  {  ERR_DFLT,    ERR_DFLT,    recover,     ERR_DFLT   },
  {     0,       "%DLOAD-W-", "%DLOAD-E-", "%DLOAD-F-" },
     msgtable
};


static void report_errno ()
{
  extern int   errno;
  extern char *sys_errlist[];

  report_error (DL_I_INFOMSG, sys_errlist[errno]);
}


static void list_unresolves ()
{
  SYMBOL *sym;
  int     cnt;

  if (active == F_pending) {
    while (sym = hashnext (symtab[1]))
      if (sym->whatis & SYM_EXT)
        report_error (DL_I_INFOMSG, sym->name);
    return;
  }

  for (sym = active->symtab, cnt = active->nsyms; cnt--; sym++)
    if (!(sym->whatis & SYM_ALIAS) && sym->whatis & SYM_EXT)
      report_error (DL_I_INFOMSG, sym->name);
}


static void xcerror (char *text)
{
  switch (XC_errno) {
    case INTERNAL: report_error (DL_F_INTERNAL, text);
    case INVLDARG: report_error (DL_F_INTERNAL, "Invalid argument");
    case OUTOFMEM: report_error (DL_F_OUTOFMEM, XC_erraux);
    case IOERROR : report_error (DL_F_IOERROR);
    case OPENFAIL: report_error (DL_E_OPENFAIL, text);
    case CLOSFAIL: report_error (DL_W_CLOSFAIL, text);
    case SEEKFAIL: report_error (DL_E_SEEKFAIL, text);
    case READFAIL: report_error (DL_E_READFAIL, text);
    case RITEFAIL: report_error (DL_E_RITEFAIL, text);
    case UNEXPEOF: report_error (DL_E_UNEXPEOF, text);
    case NOTANOBJ: report_error (DL_E_BADMAGIC, text);
    case NOSYMTAB: report_error (DL_E_NOSYMBOL, text);
    default:       report_error (DL_F_INTERNAL, "This should not happen");
  }
}

static long Seek (fildes, offset, whence)

OBJFD *fildes;
uint   offset;
int    whence;
{
  long ret = lseek (fildes->fileno, offset, whence);

  if (ret == -1)
    report_error (DL_E_SEEKFAIL, fildes->name);
  return ret;
}


static int Reads (fildes, buf, nbyte)

OBJFD *fildes;
void  *buf;
uint   nbyte;
{
  int ret = read (fildes->fileno, buf, nbyte);

  if (ret == -1)
    report_error (DL_E_READFAIL, fildes->name);
  else if (ret != nbyte)
    report_error (DL_E_UNEXPEOF, fildes->name);
  return ret;
}


static void *Malloc (uint nbytes)
{
  void *ptr;

  if (!(ptr = malloc (nbytes)))
    report_error (DL_F_OUTOFMEM, nbytes);
  return ptr;
}


static void *Calloc (uint nbytes)
{
  void *ptr;

  if (!(ptr = calloc (1, nbytes)))
    report_error (DL_F_OUTOFMEM, nbytes);
  return ptr;
}

/* ARGSUSED */
static int protect (ADDR addr, uint size)
{
#if (SVR4 || SunOS)
  void *page = (void *)TRUNC (addr, pagesz);

  if (0 == mprotect (page, size + (addr - (ADDR)page), PROT_READ | PROT_EXEC))
    return 1;
  report_error (DL_W_MEMPROT, "disabling", page);
  return 0;
#else
  return 1;
#endif
}


/* ARGSUSED */
static int unprotect (ADDR addr, uint size)
{
#if (SVR4 || SunOS)
  void *page = (void *)TRUNC (addr, pagesz);

  if (0 == mprotect (page, size + (addr - (ADDR)page), PROT_READ | PROT_WRITE | PROT_EXEC))
    return 1;
  report_error (DL_W_MEMPROT, "enabling", page);
  return 0;
#else
  return 1;
#endif
}

static ADDR Map (int fd, int off, int size, ADDR addr)
{
  caddr_t mapaddr = mmap ((caddr_t)addr, (size_t)size,
#if IRIX_4x
                                PROT_READ | PROT_WRITE | PROT_EXECUTE,
#else
                                PROT_READ | PROT_WRITE | PROT_EXEC,
#endif
                                MAP_PRIVATE | (addr ? MAP_FIXED : 0),
                                                        fd, (off_t)off);
  if (mapaddr == (caddr_t)-1)
    report_error (DL_F_MMAPFAIL);
  return (ADDR)mapaddr;
}


static void openzero ()
{
#if !defined(NOMAPPING)
#if defined(ZEROFILE)

  /* open "zero" file which is used as a source of zeroed memory via memory
     mapping */

  zeroname = ZEROFILE;
  if (!(zero = open (zeroname, O_RDONLY, 0)))
    report_error (DL_E_OPENFAIL, zeroname);
#else

  /* on systems which do not support the "zero" device file we create a void
     file (does not consume disk space) to simulate it */

  zeroname = tempnam ("/usr/tmp", "ZERO.");
  if (-1 == (zero = open (zeroname, O_RDWR | O_CREAT | O_TRUNC, 0666)))
    report_error (DL_E_OPENFAIL, zeroname);
  unlink (zeroname);
#endif
#endif
}


static ADDR getzeromem (uint size)
{
#if defined(NOMAPPING)
#error  Support for NOMAPPING parameter not implemented!
#else

#if !defined(ZEROFILE)
  static int zerosize = 0;

  if (size > zerosize) {
    zerosize = ALIGN (size, grabsz);
    if (-1 == lseek (zero, zerosize - 1, 0))
      report_error (DL_E_SEEKFAIL, zeroname);
    if (-1 == write (zero, "", 1))
      report_error (DL_E_RITEFAIL, zeroname);
  }
#endif
  return Map (zero, 0, size, 0);
#endif
}


static void reopen (OBJFD *fd)
{
  struct stat info;

  if (-1 == (fd->fileno = open (fd->name, O_RDONLY, 0)))
    report_error (DL_E_OPENFAIL, fd->name);
  fstat (fd->fileno, &info);
  if (fd->tstamp != info.st_mtime)
    report_error (DL_F_MODIFIED, fd->name);
}

/* ARGSUSED */
static REGION *init_region (ADDR area_in)
{
  REGION *new = Malloc (sizeof (REGION));

#if defined(REGIONSZ)
  new->addr = TRUNC (area_in, REGIONSZ);
#else
  new->addr = 0;
#endif

  /* allocate a new region descriptor and add it to the front of the region
     list */

  new->avail  = Calloc (sizeof (MEMHDR *) *
				(MAXMEMNDX + 1 + 2 * (pagesz / FRAGGRAIN)));
  new->tfrags = &new->avail[MAXMEMNDX + 1];
  new->dfrags = &new->tfrags[pagesz / FRAGGRAIN];
  new->next   = regionlist;
  return (regionlist = new);
}


#if defined(REGIONSZ)
static REGION *find_region (ADDR address)
{
  REGION *tmp;

  for (tmp = regionlist; tmp; tmp = tmp->next)
    if (address >= tmp->addr && address < tmp->addr + REGIONSZ)
      return tmp;
  return 0;
}
#else
#define  find_region(addr)  regionlist
#endif


static MEMHDR *memsearch (MEMHDR **avail, MEMHDR **frags, uint size)
{
  int     ndx;
  MEMHDR *pmem, *mem;

  /* fragment allocation */

  if (size < pagesz) {
    for (ndx = (pagesz - size) / FRAGGRAIN; ndx--;)
      if (mem = frags[ndx]) {
        frags[ndx] = mem->next;
        return mem;
      }
  }

  /* avail (whole pages) allocation */

  if ((ndx = MAXMEMNDX - size / (MEMGRAIN * pagesz)) < 0)
    ndx = 0;
  do {
    for (mem = (MEMHDR *)&avail[ndx]; mem = (pmem = mem)->next;)
      if (mem->size >= size) {
        pmem->next = mem->next;
        return mem;
      }
  } while (ndx--);

  /* memory not available */

  return 0;
}


static void memrelease (MEMHDR **avail, MEMHDR **frags, ADDR start, uint size)
{
  int     ndx;
  uint    fragsz = size % pagesz;
  MEMHDR *Fmem   = (MEMHDR *)start;
  MEMHDR *Amem   = (MEMHDR *)(start + fragsz);

  /* possible fragment at start of memory area */

  if (fragsz) {
    Fmem->next = frags[ndx = (pagesz - fragsz) / FRAGGRAIN - 1];
    Fmem->size = fragsz;
    frags[ndx] = Fmem;
  }

  /* remainder is an area of whole pages */

  if (size -= fragsz) {
    if ((ndx = MAXMEMNDX - size / (MEMGRAIN * pagesz)) < 0)
      ndx = 0;
    Amem->next = avail[ndx];
    Amem->size = size;
    avail[ndx] = Amem;
  }
}


static void seg_alloc (uint tsize, uint dsize, ADDR *tptr, ADDR *dptr)
{
  REGION *region;
  ADDR    tmem, dmem;
  uint    text_got, data_got;

  for (region = regionlist; region; region = region->next) {

    /* allocate text segment */

    if (!tsize)
      text_got = 0;
    else if (tmem = (ADDR)memsearch (region->avail, region->tfrags, tsize)) {
      text_got = ((MEMHDR *)tmem)->size;
/*    if ((text_got = ((MEMHDR *)tmem)->size) < pagesz)
        unprotect (tmem, text_got);	*/
    }
    else continue;

    /* allocate data segment */

    if (!dsize)
      data_got = 0;
    else if (dmem = (ADDR)memsearch (region->avail, region->dfrags, dsize))
      data_got = ((MEMHDR *)dmem)->size;
    else {

      /* if here the only way we'd be able to do the allocation from
         this region is if it is available from the memory obtained
         for the text; and this can only be done if the size is larger
         than a page as text and data cannot occupy the same page of
         memory.  If the allocation cannot be done we must re-install
         the text area into the avail (or fragment) list and go on to
         check other regions. */

      if (text_got >= ALIGN (tsize, pagesz) + dsize)
        goto carve;
      memrelease (region->avail, region->tfrags, tmem, text_got);
/*    if (text_got < pagesz)
        protect (tmem, text_got);	*/
      continue;
    }

    /* if we got here then memory has been found */

    goto found;
  }

  /* here we have to allocate more memory from the system */

#if defined(GRABSZ)
  text_got = ALIGN (dsize + ALIGN (tsize, pagesz), grabsz);
#else
  text_got = ALIGN (tsize, pagesz) + ALIGN (dsize, pagesz);
#endif
  tmem = getzeromem (text_got);
#if defined(REGIONSZ)
  if (tmem / REGIONSZ != (tmem + text_got - 1) / REGIONSZ)
    report_error (DL_F_INTERNAL, "Allocated memory crosses region boundary");
#endif
  if (!(region = find_region (tmem)))
    region = init_region (tmem);

  /* here we have a page-aligned chunk of memory out of which we can carve
     space for the data section */

carve:
  dmem      = tmem + ALIGN (tsize, pagesz);
  data_got  = text_got - (dmem - tmem);
  text_got -= data_got;

  /* return unused portions of memory to the region and the allocated portions
     to the caller */

found:
  if (tsize) {
    memrelease (region->avail, region->tfrags, tmem + tsize, text_got - tsize);
    *tptr = tmem;
  }
  if (dsize) {
    memrelease (region->avail, region->dfrags, dmem + dsize, data_got - dsize);
    *dptr = dmem;
  }
}

/*****************************************************************************/
/*									     */
/* slot_alloc  --  MACHINE DEPENDENT CODE!  Generate an instruction that     */
/*		   causes an unconditional branch to the given destination   */
/*		   address.  If 'slot' is non-zero the instruction is placed */
/*		   at that address; otherwise a new slot is allocated for    */
/*		   the instruction.  The slot address is returned.	     */
/*									     */
/*****************************************************************************/

static ADDR slot_alloc (ADDR slot, ADDR dest)
{
  /* Allocate a new branch table slot if one not provided. */

  if (!slot) {
    if (!slottables || SLOTSIZE * (slottables->alloced + 1) >= pagesz) {
      SLOTTBL *new = Malloc (sizeof (SLOTTBL));

      seg_alloc (0, pagesz, 0, &new->addr);
      *(SLOTTBL **)new->addr = new;
      new->alloced = 1;
      new->prot    = 0;
      new->next    = slottables;
      slottables   = new;
    }
    slot = slottables->addr + (SLOTSIZE * slottables->alloced++);
  }

  /* enable writes to the slot table if currently protected */
  /* NOT IMPLEMENTED YET!! */

  /* generate a branch instruction for the given destination address */

#if defined(__clipper__)
  ((ushort *)slot)[0] = 0x4930;
  ((ushort *)slot)[1] = dest & 0xffff;
  ((ushort *)slot)[2] = dest >> 16;
#elif defined(__sparc__)
  ((ulong *)slot)[0] = 0x03000000 | (dest >> 10);     /* sethi %hi(dest),%g1 */
  ((ulong *)slot)[1] = 0x81c06000 | (dest & 0x3ff);   /* jmp   %g1+%lo(dest) */
  ((ulong *)slot)[2] = 0x01000000;                    /* nop                 */
#elif defined(__mips__)
  ((ulong *)slot)[0] = 0x3c190000 | (dest >> 16);     /* lui   $t9,{upper16} */
  ((ulong *)slot)[1] = 0x37390000 | (dest & 0xffff);  /* ori   $t9,{lower16} */
  ((ulong *)slot)[2] = 0x03200008;                    /* jr    $t9           */
  ((ulong *)slot)[3] = 0x00000000;                    /* nop                 */
#elif defined(__i386__)
  dest -= (slot + 5);
  ((ulong *)slot)[0] = 0x000000e9 | (dest << 8);
  ((char  *)slot)[4] = (dest >> 24);
#else
#error slot_alloc has not been ported for this machine!
#endif

  return slot;
}

/*************************************************************************/
/* this stuff supports a kludge needed on mips in order to write to text */
/*************************************************************************/

#if IRIX_4x
#include <sys/ipc.h>
#include <sys/msg.h>

#define  ERRORMSG  1
#define  READYMSG  2
#define  CMDMSG    3

static int qid;

static struct {
    long type;
    ADDR slotloc;
    char slot[SLOTSIZE];
} msgbuffer;


static int mips_cleanup ()
{
  msgbuffer.type    = CMDMSG;
  msgbuffer.slotloc = 0;
  msgsnd (qid, (struct msgbuf *)&msgbuffer, sizeof (msgbuffer), 0);
  return 0;
}


static void starthelper ()
{
  execl ("/usr/bin/dlhelper", "/usr/bin/dlhelper", 0);
  msgbuffer.type = ERRORMSG;
  msgsnd (qid, (struct msgbuf *)&msgbuffer, 0, 0);
  exit (1);
}
#endif

static void patch_text (ADDR slot, ADDR dest)
{
#if CLIX
  char tmpslot[SLOTSIZE];

  (void)slot_alloc ((ADDR)tmpslot, dest);
  if (   -1       == lseek (procfile, (uint)slot, 0)
      || SLOTSIZE != write (procfile, tmpslot, SLOTSIZE) )
    report_error (DL_F_NOPATCH, slot);
#endif

#if IRIX_4x
  msgbuffer.type    = CMDMSG;
  msgbuffer.slotloc = slot;
  (void)slot_alloc ((ADDR)msgbuffer.slot, dest);
  msgsnd (qid, (struct msgbuf *)&msgbuffer, sizeof (msgbuffer), 0);
  msgrcv (qid, (struct msgbuf *)&msgbuffer, sizeof (msgbuffer), -READYMSG, 0);
  if (msgbuffer.type == ERRORMSG)
    report_error (DL_F_NOPATCH, slot);
#endif

#if (SVR4 || SunOS)
#if IRIX_5x
  if ((*(uint *)slot & 0xffff0000) == 0x3c1c0000)
    slot += 12;
#endif
  unprotect (slot, SLOTSIZE);
  (void)slot_alloc (slot, dest);
  protect (slot, SLOTSIZE);
#endif
}


static void add_to_pending (HANDLE *file)
{
  (file->prev = F_pending->prev)->next = file;
  (file->next = F_pending)->prev       = file;
  F_pending->nfiles++;
}


static void add_to_loaded (HANDLE *file)
{
  HANDLE *first, *last;

  if (file == F_pending) {
    first = file->next;
    last  = file->prev;
  }
  else first = last = file;

  if (F_loaded) {
    (F_loaded->prev->next = first)->prev = F_loaded->prev;
    (F_loaded->prev = last)->next        = F_loaded;
  }
  else F_loaded = file->next = file->prev = file;
}


static HANDLE *make_handle (char *path, int options, OBJINFO *info, OBJFD *ofd)
{
  HANDLE *handle;

  if (path) {
    handle       = Calloc (sizeof (HANDLE) + strlen (path) + 1);
    handle->name = strcpy ((char *)&handle[1], path);
  }
  else handle = Calloc (sizeof (HANDLE));
  handle->auxinfo = Calloc (sizeof (AUXINFO));

  if (info) {
    handle->nsyms  = info->nsyms;
    handle->symtab = (SYMBOL *)info->symptr;
    handle->names  = info->nametbl;
    handle->auxinfo->bssneed = (info->bss ? info->bss->size : 0);
  }

  handle->magic   = DLMAGIC;
  handle->options = options;
  handle->auxinfo->unres   = 0;
  handle->auxinfo->objinfo = info;
  handle->auxinfo->objfd   = ofd;

  return handle;
}


static SYMBOL *symbol_lookup (int tblndx, char *name)
{
  SYMBOL *sym;

  do {
    if (sym = hashlookup (symtab[tblndx], name))
      return sym;
  } while (tblndx--);
  return 0;
}


static int override (HANDLE *file, SYMBOL *exist, SYMBOL *new)
{
  switch (010 * SYMTYPE (exist) + SYMTYPE (new)) {

    /* Pure external reference to existing symbol.  Keep the one we
       already have! */

    case 011:
    case 021:
    case 031:
      return 0;

    /* All "common" (uninitialized global) variables of the same name are
       mapped to the same address (unless the NOCOMMON option is enabled in
       which case they are treated as if initialized to zero). */

    case 022:
      if (!(file->options & NOCOMMON)) {
        if (new->value != exist->value)
          report_error (DL_W_SIZEDIFF, file->name, new->name);
        else report_error (DL_W_MULTIDEF, file->name, new->name);
        return (new->value > exist->value);
      }

    /* An initialized global overrides an existing "common". */

    case 023:
      if (new->whatis & SYM_FUNC)
        report_error (DL_E_ILLRDEFV, file->name, exist->name);
      report_error (DL_W_COMREDEF, file->name, new->name);
      return 1;

    /* Resolving pure external reference here.  New symbol overrides
       the existing one! */

    case 012:
    case 013:
      return 1;

    /* A "common" as input gets mapped to an existing definition unless the
       NOCOMMON option forces override. */

    case 032:
      if (exist->whatis & SYM_FUNC)
        report_error (DL_E_ILLRDEFF, file->name, exist->name);
      if (!(file->options & NOCOMMON)) {
        report_error (DL_W_COMREMAP, file->name, new->name);
        return 0;
      }

    /* Redefinition of a global symbol is occuring here.  This is the most
       dangerous thing a user can do especially with respect to data since
       existing references cannot be relocated. Text-to-text redefinition
       is relatively safe due to the branch table mechanism for
       redirection. */

    case 033:

      /* function-to-function */

      if (exist->whatis & SYM_FUNC && new->whatis & SYM_FUNC) {
        if (file->options & TEXTREDEF) {
          report_error (DL_W_REDEFFCN, file->name, new->name);
          return 1;
        }
        report_error (DL_E_ILLRDEFF, file->name, exist->name);
      }

      /* data-to-data */

      if (exist->whatis & SYM_VAR && new->whatis & (SYM_VAR | SYM_COMM)) {
        if (file->options & DATAREDEF) {
          report_error (DL_W_REDEFVAR, file->name, new->name);
          return 1;
        }
        report_error (DL_E_ILLRDEFV, file->name, exist->name);
      }

      /* function-to-variable and variable-to-function  --  SIMPLY ILLEGAL!! */

      if (exist->whatis & SYM_FUNC)
        report_error (DL_E_ILLRDEFF, file->name, exist->name);
      else report_error (DL_E_ILLRDEFV, file->name, exist->name);
  }

  return 0;
}


static SYMBOL *replace_symbol (HASHTABLE *table, SYMBOL *new)
{
  SYMBOL *exist;

  /* replace symbol in specified table */

  if (hashadd (table, new, &exist))
    return 0;
  hashrpl (table, new);

  /* decrement number of unresolved symbols if the one replaced was an
     external reference */

  if (exist->whatis & SYM_EXT) {
    if (exist->u.owner->auxinfo) {    /* if symbol undefined and pending */
      exist->u.owner->auxinfo->unres--;
      F_pending->auxinfo->unres--;
    }
  }

  /* keep same slot address */

  if (exist->whatis & SYM_FUNC)
    new->u.slot = exist->u.slot;

  /* old symbol becomes an alias to the new one */

  exist->whatis |= SYM_ALIAS;
  exist->u.alias = new;

  return exist;
}


static void symbol_resolution1 (HANDLE *file)	/* NO COMPOSITE HANDLES */
{
  SYMBOL *exist, *new;
  int     usetbl;
  int     cnt;

  /* determine the level of symbol referencing allowed by the specified
     options */

  if (file->options & (TEXTREF | DATAREF))
    if (file->options & INCRLOAD)
      usetbl = SYMTBL_PEND;
    else usetbl = SYMTBL_DYNAM;
  else usetbl = SYMTBL_MAIN;

  /* process each symbol */

  for (new = file->symtab, cnt = file->nsyms; cnt--; new++) {
    if (new->whatis == SYM_NIL)
      continue;

    /* set flags for treatment of "special" symbols */

    check_special (new);
    if (new->whatis & SYM_HIDE)
      continue;

    /* map symbols arriving as SYM_BSS to SYM_DATA because they have already
       been given addresses by the compiler or linker (SYM_BSS means that
       the symbol is defined in a dynamic loader allocated .bss section) */

    if (new->whatis & SYM_BSS) {
      new->whatis &= ~SYM_BSS;
      new->whatis |= SYM_DATA;
    }

    /* hidden symbols do not produce globally visible definitions */

    if (file->options & HIDEGLOBAL && new->whatis & (SYM_COMM | SYM_GLOB))
      if (!(file->options & DATAONLY) || !(new->whatis & SYM_FUNC)) {
        new->whatis |= SYM_HIDE;
        continue;
      }

    /* weak global symbols may only be referenced by incrementally loaded
       files while the definition is still pending (if this file is not
       being incrementally loaded, WEAKGLOBAL is the same as HIDEGLOBAL) */

    if (file->options & WEAKGLOBAL && new->whatis & (SYM_COMM | SYM_GLOB))
      if (!(file->options & DATAONLY) || !(new->whatis & SYM_FUNC))
        if (file->options & INCRLOAD)
          new->whatis |= SYM_WEAK;
        else {
          new->whatis |= SYM_HIDE;
          continue;
        }

    /* if this symbol does not superceed a previous definition then it
       becomes an alias referring to the existing definition */

    if (   (exist = symbol_lookup (usetbl, new->name))
        && !override (file, exist, new)) {
      new->whatis |= SYM_ALIAS;
      new->u.alias = exist;
    }

    /* otherwise this symbol will become the definition:  count total
       number of external references and remember defining file for these
       and commons */

    else if (new->whatis & SYM_EXT) {
      new->u.owner = file;
      file->auxinfo->unres++;
      if (file->options & INCRLOAD)
        F_pending->auxinfo->unres++;
    }
  }
}


static void symbol_resolution2 (HANDLE *file, int usetbl)
{						     /* NO COMPOSITE HANDLES */
  SYMBOL *exist, *new;
  int     cnt;

  /* destination symbol table is SYMTBL_DYNAM - the active definitions */

  if (usetbl == SYMTBL_DYNAM) {
    for (new = file->symtab, cnt = file->nsyms; cnt--; new++) {
      if (new->whatis == SYM_NIL)
        continue;
      if (new->whatis & (SYM_HIDE | SYM_WEAK | SYM_ALIAS))
        continue;

      /* insert symbol into the symbol table and modify existing function
         to transfer calls to the new definition */

      if (exist = replace_symbol (symtab[SYMTBL_DYNAM], new))
        if (exist->whatis & SYM_FUNC) {
          new->u.slot = slot_alloc (new->u.slot, new->value);
          if (exist->whatis & SYM_MAIN)
            patch_text (exist->value, new->u.slot);
          else {
#if IRIX_5x
            if ((*(uint *)exist->value & 0xffff0000) == 0x3c1c0000)
              (void)slot_alloc (exist->value + 12, new->u.slot);
            else
#endif
            (void)slot_alloc (exist->value, new->u.slot);
          }
        }

      /* clear the common flag as processing of this symbol is now complete */

      new->whatis &= ~SYM_COMM;
    }
  }

  /* destination symbol table is SYMTBL_PEND - the pending definitions */

  else {
    for (new = file->symtab, cnt = file->nsyms; cnt--; new++) {
      if (new->whatis == SYM_NIL)
        continue;
      if (new->whatis & (SYM_HIDE | SYM_ALIAS))
        continue;

      /* insert symbol into the symbol table */

      replace_symbol (symtab[SYMTBL_PEND], new);
    }
  }
}


static SECTION *find_scn_by_name (OBJINFO *info, char *name)
{
  SECTION *scn = info->scnptr;
  int      cnt = info->nsects;

  for (; cnt--; scn++)
    if (0 == strcmp (scn->name, name))
      return scn;
  return 0;
}


static void load_segments (HANDLE *file)
{
  AUXINFO *aux  = file->auxinfo;
  OBJINFO *info = aux->objinfo;
  OBJFD   *fd   = aux->objfd;
  uint     textsz, datasz, gapsz = 0;

  /* determine segment sizes and check for empty case */

  textsz = (info->text ? info->text->size : 0);
  datasz = (info->data ? info->data->size : 0);
  if (info->flags & OBJ_DEMAND) {
    file->tsize = ALIGN (textsz, pagesz);
    file->dsize = ALIGN (datasz + aux->bssneed, pagesz);
  } else {
    file->tsize = ALIGN (textsz, FRAGGRAIN);
    file->dsize = ALIGN (datasz + aux->bssneed, FRAGGRAIN);
  }
  if (!(file->tsize + file->dsize))
    return;

  /* reopen the file if it has been closed (as for the case of incremental
     loads) */

  if (fd && fd->fileno == -1)
    reopen (fd);

  /* allocate virtual address space for the segments (relative placement of
     segments must be maintained if OBJ_ADJSEG is set) */

  if (info->flags & OBJ_ADJSEG) {   /* this implies OBJ_DEMAND as well */
    ADDR memaddr;
    if (textsz && datasz)
      gapsz = info->data->vaddr - info->text->vaddr - file->tsize;
    seg_alloc (file->tsize + file->dsize + gapsz, 0, &memaddr, 0);
    file->text   = (file->tsize ? memaddr : 0);
    file->data   = (file->dsize ? memaddr + file->tsize + gapsz: 0);
  }
  else seg_alloc (file->tsize, file->dsize, &file->text, &file->data);

  /* free up extra memory we obtained to keep relative placement of
     segments intact */

#if defined(DIRECTMAP)
  if (gapsz)
    XC_munmap (file->text + file->tsize, gapsz);
#endif

  /* map the segments directly into memory if this is possible since this is
     much more efficient than reading them (the file must be a demand-paged
     object which is not an archive member and the architecture parameter
     DIRECTMAP must be defined); also any partial page at the end of the data
     mapping must be zeroed */

#if defined(DIRECTMAP)
  if (info->flags & OBJ_DEMAND && !fd->arch) {
    if (textsz) {
      Map (fd->fileno, info->text->faddr, textsz, file->text);
      aux->textmod = file->text - info->text->vaddr;
    }
    if (datasz) {
      int zerosz;
      Map (fd->fileno, info->data->faddr, datasz, file->data);
      if (zerosz = ALIGN (datasz, pagesz) - datasz)
        memset ((void *)(file->data + datasz), '\0', zerosz);
      aux->datamod = file->data - info->data->vaddr;
    }
    else aux->datamod = file->data;
  }
  else  /* do normal processing below */
#endif

  /* read the segments into the memory just acquired */

  {
    if (textsz) {
      Seek (fd, fd->base + info->text->faddr, 0);
      Reads (fd, (void *)file->text, textsz);
      aux->textmod = file->text - info->text->vaddr;
    }
    if (datasz) {
      Seek (fd, fd->base + info->data->faddr, 0);
      Reads (fd, (void *)file->data, datasz);
      aux->datamod = file->data - info->data->vaddr;
    }
    else aux->datamod = file->data;
  }

  /* close open file (but keep data intact for now) since we may be processing
     more files than we can have open simultaneously */

  if (fd) {
    close (fd->fileno);
    fd->fileno = -1;
  }
}


static void allocate_commons (HANDLE *handle)
{
  ALIGNDEF *align;
  HANDLE   *file;
  OBJINFO  *info = handle->auxinfo->objinfo;
  SYMBOL   *sym;
  ADDR      bss_vaddr, bssaddr;
  int       fcnt, scnt;

  /* Sort type-2 symbols into lists having identical alignment requirements.
     This will allow us to pack them as tightly as possible when assigning
     addresses */

  for (fcnt = (file = handle)->nfiles + 1; fcnt--; file = file->next)
    for (sym = file->symtab, scnt = file->nsyms; scnt--; sym++)
      if (sym->whatis & SYM_COMM && !(sym->whatis & SYM_ALIAS)) {
        for (align = aligner; sym->value % align->bound; align++);
        sym->u.alias   = align->symlist;
        align->symlist = sym;
      }

  /* determine starting virtual address for commons */

  if (!info)
    bss_vaddr = 0;
  else if (info->bss)
    bss_vaddr = info->bss->vaddr + info->bss->size;
  else if (info->data)
    bss_vaddr = info->data->vaddr + info->data->size;
  else bss_vaddr = 0;
  bssaddr = ALIGN (bss_vaddr, aligner[0].bound);

  /* assign addresses and convert commons into definitions */

  for (align = aligner; 1; align++) {
    SYMBOL *next;
    ulong   size;

    for (sym = align->symlist; sym; sym = next) {
      next = sym->u.alias;
      size = sym->value;
      sym->u.owner = handle;
      sym->value   = bssaddr;
      sym->whatis |= (handle == F_pending ? SYM_BSS : SYM_DATA);
      bssaddr     += size;
    }
    align->symlist = 0;
    if (align->bound == 1)
      break;
  }

  /* save size required for section allocation */

  handle->auxinfo->bssneed += (bssaddr - bss_vaddr);
}


static void symbol_init (OBJFD *fd, ADDR base)
{
  OBJINFO *info;
  SYMBOL  *sym;
  int      cnt;

  /* verbosity if asked for */

  if (G_options & VERBOSE1)
    report_error (DL_I_SYMINIT, fd->name);

  /* get the symbol table */

  if (!(info = OBJread (fd, OBJ_GSYM))) {
    xcerror (fd->name);
    return;
  }
  if (!info->nsyms)
    report_error (DL_W_NOSYMBOL, fd->name);

  /* update symbol values by adding base address then insert in hash table */
  /*-----------------------------------------------------------------------*/
  /* NOTICE:  on sparc, type-2 symbols may require a "dlsym" call to force */
  /*          ld.so to allocate them and give me the address.              */
  /*-----------------------------------------------------------------------*/

  for (sym = (SYMBOL *)info->symptr, cnt = info->nsyms; cnt--; sym++)
    if (SYMTYPE (sym) == 3) {
      sym->whatis |= SYM_MAIN;
      sym->value  += base;
      hashadd (symtab[0], sym, 0);
    }
}


/* ARGSUSED */
static void machine_init (OBJFD *fd)
{
#if CLIX
  OBJINFO *info;
  SECTION *scn;
  char     path[16];

  /* intialize access to /proc file system which is used for text writes */

  sprintf (path, "/proc/%.5d", getpid ());
  if (-1 == (procfile = open (path, O_RDWR, 0)))
    report_error (DL_E_OPENFAIL, path);
  else ioctl (procfile, PIOCEXCLU);

  /* load symbols from target shared libraries */

  if (!(info = OBJread (fd, OBJ_SCN)))
    xcerror (fd->name);
  else if (scn = find_scn_by_name (info, ".lib")) {
    char *libbuff;
    long *shlib;

    shlib = (long *)(libbuff = Malloc (scn->size));
    Seek (fd, fd->base + scn->faddr, 0);
    Reads (fd, libbuff, scn->size);
    for (; (char *)shlib < libbuff + scn->size; shlib += shlib[0]) {
      char  *libname = (char *)(shlib + shlib[1]);
      OBJFD *libfd;

      if (!(libfd = OBJopen (libname, OBJ_OBJ)))
        xcerror (libname);
      else {
        symbol_init (libfd, 0);
        OBJclose (libfd, OBJ_GSYM);
      }
    }
    free (libbuff);
  }
#endif

#if SunOS_4x
  extern struct link_dynamic _DYNAMIC;
  struct link_map *lmp;
  OBJFD           *libfd;

  /* Get symbols from dynamic libraries */
  /*----------------------------------------------------------------*/
  /* WARNING:  In statically linked executables &_DYNAMIC is zero?? */
  /*----------------------------------------------------------------*/

  for (lmp =_DYNAMIC.ld_un.ld_2->ld_loaded; lmp; lmp = lmp->lm_next) {
    if (!(libfd = OBJopen (lmp->lm_name, OBJ_OBJ)))
      xcerror (lmp->lm_name);
    else {
      symbol_init (libfd, (ADDR)lmp->lm_addr);
      OBJclose (libfd, OBJ_GSYM);
    }
  }
#endif

#if SunOS_5x
  extern Elf32_Dyn  _DYNAMIC;
  Elf32_Dyn        *dyn;

  /* find "debug" structure which gives us access to the link maps */

  for (dyn = &_DYNAMIC; dyn->d_tag; dyn++)
    if (dyn->d_tag == DT_DEBUG) {
      struct r_debug  *dbg = (struct r_debug *)dyn->d_un.d_ptr;
      struct link_map *lmp;
      OBJFD           *libfd;

      /* Get symbols from dynamic libraries */

      for (lmp = dbg->r_map->l_next; lmp; lmp = lmp->l_next) {
        if (!(libfd = OBJopen (lmp->l_name, OBJ_OBJ)))
          xcerror (lmp->l_name);
        else {
          symbol_init (libfd, (ADDR)lmp->l_addr);
          OBJclose (libfd, OBJ_GSYM);
        }
      }

      break;
    }
#endif

#if IRIX_4x
  /* WARNING:  We are not currently loading symbol definitions from target
               shared libraries!! */

  /* on mips under IRIX 4.x we cannot write to our own /debug file so this
     kludge uses a separate process "/usr/bin/dlhelper" to do it for us;
     patch instructions are communicated via message queues */

  if (-1 == (qid = msgget ((key_t)getpid (), 0700 | IPC_CREAT | IPC_EXCL)))
    report_error (DL_F_NOHELPER);
  exitadd (mips_cleanup);
  if (-1 == (procfile = sproc ((int (*)())starthelper, 0)))
    report_error (DL_F_NOHELPER);
  msgrcv (qid, (struct msgbuf *)&msgbuffer, sizeof (msgbuffer), 0, 0);
  if (msgbuffer.type != READYMSG)
    report_error (DL_F_NOHELPER);
#endif

#if IRIX_5x
  extern struct obj_list *__rld_obj_head;
  struct obj_list        *rldlist;

  if (__rld_obj_head) {
    for (rldlist = __rld_obj_head->next; rldlist; rldlist = rldlist->next) {
      struct obj *rldobj = (struct obj *)rldlist->data;
      OBJFD      *libfd;
      OBJINFO    *info;

      if (    (libfd = OBJopen (rldobj->o_path, OBJ_OBJ))
           && (info  = OBJread (libfd, 0))                ) {
        symbol_init (libfd, (ADDR)(rldobj->o_text_start - info->base));
        OBJclose (libfd, OBJ_GSYM);
      }
      else xcerror (rldobj->o_path);
    }
  }
#endif
}


/* ARGSUSED */
static void machine_preload (OBJINFO *info)
{
#if (SVR4 || SunOS)
  if (!(info->flags & OBJ_SLIB))
    report_error (DL_E_DISABLED, "loading other than *.so files");
#endif
}


/* ARGSUSED */
static void flush_data_cache (ADDR addr, uint nbytes)
{
#if CLIX
  exedata ();
#endif

#if IRIX
  cacheflush ((void *)addr, nbytes, DCACHE);
#endif
}


/* ARGSUSED */
static void machine_postload (HANDLE *handle)
{
#if CLIX
  exedata ();			/* flush caches */
#endif

#if IRIX
  HANDLE  *file;
  SLOTTBL *slottbl;
  int      cnt;

  /* flush data cache for all areas corresponding to modified text regions */

  for (cnt = (file = handle)->nfiles + 1; cnt--; file = file->next)
    if (file->tsize && !file->prot)
      cacheflush ((void *)file->text, file->tsize, DCACHE);
  for (slottbl = slottables; slottbl; slottbl = slottbl->next)
    if (!slottbl->prot)
      cacheflush ((void *)slottbl->addr, pagesz, DCACHE);
#endif
}


static void dload_startup ()
{
  char  *main = exefile ();
  OBJFD *mainfd;
  int    ndx;

  trap_errors (errortrap);
  pagesz          = XC_getpagesz ();
  F_pending       = make_handle (0, 0, &nullinfo, 0);
  F_pending->next = F_pending->prev = F_pending;

  /* check for environment variables */

  if (getenv ("DLOAD_DEBUGMODE"))
    G_options |= DEBUGMODE;
  if (getenv ("DLOAD_VERBOSE1"))
    G_options |= VERBOSE1;
  if (getenv ("DLOAD_VERBOSE2"))
    G_options |= VERBOSE2;
  if (getenv ("DLOAD_RETRODBG"))
    G_options |= RETRODBG;
  if (getenv ("DLOAD_NOWARNING"))
    G_options |= NOWARNING;
  if (getenv ("DLOAD_FCNSAFE"))
    G_options |= FCNSAFE;

#if defined(GRABSZ)
  { char *value;
    if (value = getenv ("DLOAD_REGION"))
      grabsz = pagesz * strtol (value, (char **)0, 0);
    else grabsz = GRABSZ;
  }
#endif

  /* initialize hash tables */

  taghash = hashinit (RLTAG, TAGHASHSZ, hashc, strcmp, tagname, INDKEY|NOMEM);
  filehash  = hashinit (HANDLE, FILEHASHSZ, hashc, strcmp, name, INDKEY|NOMEM|DUPS);
  symtab[0] = hashinit (SYMBOL, MAINHASHSZ, hashc, strcmp, name, INDKEY|NOMEM);
  symtab[1] = hashinit (SYMBOL, PENDHASHSZ, hashc, strcmp, name, INDKEY|NOMEM);

  /* open main program file, initialize the symbol table, and perform other
     machine-specific initializations */

  openzero ();
  if (!(mainfd = OBJopen (main, OBJ_OBJ)))
    xcerror (main);
  else {
    symbol_init (mainfd, 0);
    machine_init (mainfd);
    OBJclose (mainfd, OBJ_GSYM);
  }

  initialized = 1;
}


/* ARGSUSED */
static OBJFD *open_armem (OBJFD *arch, char *memname)
{
  report_error (DL_E_DISABLED, "loads from archives");
  return 0;
}


/* ARGSUSED */
static HANDLE *archive_search (OBJFD *arch)
{
  report_error (DL_E_DISABLED, "archive searches");
  return 0;
}


static void save_reloc (RLOCENT *reloc, long *where, long Rvalue)
{
  static SRE *Rsaved_end = 0;
  SRE        *new        = Malloc (sizeof (SRE));

  new->next   = 0;
  new->sym    = (SYMBOL *)reloc->symbol;
  new->where  = where;
  new->rvalue = Rvalue;
  new->rtype  = reloc->rtype;
  new->addend = reloc->addend;

  if (Rsaved_new)
    Rsaved_end = Rsaved_end->next = new;
  else Rsaved_new = Rsaved_end = new;
}


static long R_extract (long *where, uint rtype)
{
  switch (rtype) {
#if CLIX
    case R_CLIP_PCRLONG:
    case R_CLIP_ABSLONG:
      return ((ushort *)where)[0] | ((ushort *)where)[1] << 16;

    case R_CLIP_PCRWORD:
      return *(short *)where;
#endif
#if SunOS_4x
    case R_SPARC_JMP_SLOT:
      return 0;

    case R_SPARC_RELATIVE:
      return (where[0] << 10) + (where[1] & 0x3ff);

    case R_SPARC_LO10:
    case R_SPARC_BASE10:
      return *where & 0x3ff;

    case R_SPARC_DISP8:
    case R_SPARC_8:
      return *where & 0xff;

    case R_SPARC_BASE13:
    case R_SPARC_13:
      return *where & 0x1fff;

    case R_SPARC_DISP16:
    case R_SPARC_16:
      return *where & 0xffff;

    case R_SPARC_22:
    case R_SPARC_BASE22:
      return *where & 0x3fffff;

    case R_SPARC_HI22:
      return (*where << 10) & 0x3fffff;

    case R_SPARC_WDISP22:	/* pc-relative */
      return (*where & 0x3fffff);

    case R_SPARC_WDISP30:	/* pc-relative */  /* CONFIRMED */
      return (*where & 0x3fffffff);

    case R_SPARC_DISP32:
    case R_SPARC_32:
    case R_SPARC_GLOB_DAT:
      return *where;
#endif
#if SunOS_5x
#if __i386__
    case R_I386_GLOB_DAT:
    case R_I386_JMP_SLOT:
      return 0;

    case R_I386_32:
    case R_I386_RELATIVE:
      return *where;
#else
    case R_SPARC_DISP32:
    case R_SPARC_32:
    case R_SPARC_GLOB_DAT:
    case R_SPARC_JMP_SLOT:
      return 0;

    case R_SPARC_RELATIVE:
      return *where;
#endif
#endif
#if IRIX_4x
    case R_MIPS_REFHALF:
      return *(short *)where;

    case R_MIPS_REFWORD:
      return *where;

    case R_MIPS_JMPADDR:
      return (*where & 0x3ffffff) << 2;

    case R_MIPS_REFHI: {
      static long whatHI;
      whatHI = *where << 16;
      return 0;

    case R_MIPS_REFLO:
      return whatHI + ((short *)where)[1];
    }

    case R_MIPS_GPREL:  /* should not occur in dynamically loaded code */
#endif
#if IRIX_5x
    case R_MIPS_REL32:
      return *where;

    case R_MIPS_EXTGOT:
      return 0;
#endif
    default:
      return 0;
  }
}


static int R_install (long *where, long what, uint rtype)
{
  switch (rtype) {
#if CLIX
    case R_CLIP_PCRLONG:
      what -= (long)where;
    case R_CLIP_ABSLONG:
      ((ushort *)where)[0] = what & 0xffff;
      ((ushort *)where)[1] = (uint)what >> 16;
      break;

    case R_CLIP_PCRWORD:
      what -= (long)where;
      if (what & 0xffff0000)
        report_error (DL_E_RELOCOVFL, 16, where);
      *(short *)where = what;
      break;
#endif
#if SunOS_4x
    case R_SPARC_JMP_SLOT:
      slot_alloc ((ADDR)where, (ADDR)what);
      break;

    case R_SPARC_RELATIVE:
      *where = (*where & ~0x3fffff) | ((what >> 10) & 0x3fffff);
      where++;

    case R_SPARC_LO10:
    case R_SPARC_BASE10:
      *where = (*where & ~0x3ff) | (what & 0x3ff);
      break;

    case R_SPARC_DISP8:
      what -= (long)where;
    case R_SPARC_8:
      *where = what;
      break;

    case R_SPARC_BASE13:
    case R_SPARC_13:
      *where = (*where & ~0x1fff) | (what & 0x1fff);
      break;

    case R_SPARC_DISP16:
      what -= (long)where;
    case R_SPARC_16:
      *(short *)where = what;
      break;

    case R_SPARC_22:
    case R_SPARC_BASE22:
      *where = (*where & ~0x3fffff) | (what & 0x3fffff);
      break;

    case R_SPARC_HI22:
      *where = (*where & ~0x3fffff) | ((what >> 10) & 0x3fffff);
      break;

    case R_SPARC_WDISP22:	/* pc-relative */
      what  -= (long)where;
      what >>= 2;
      *where = (*where & ~0x3fffff) | (what & 0x3fffff);
      break;

    case R_SPARC_WDISP30:	/* pc-relative */  /* CONFIRMED */
      what  -= (long)where;
      what >>= 2;
      *where = (*where & ~0x3fffffff) | (what & 0x3fffffff);
      break;

    case R_SPARC_DISP32:
      what -= (long)where;
    case R_SPARC_32:
    case R_SPARC_GLOB_DAT:
      *where = what;
      break;
#endif
#if SunOS_5x
#if __i386__
    case R_I386_32:
    case R_I386_GLOB_DAT:
    case R_I386_JMP_SLOT:
    case R_I386_RELATIVE:
      *where = what;
      break;
#else
    case R_SPARC_DISP32:
      what -= (long)where;
    case R_SPARC_32:
    case R_SPARC_GLOB_DAT:
    case R_SPARC_RELATIVE:
      *where = what;
      break;

    case R_SPARC_JMP_SLOT:
      slot_alloc ((ADDR)where, (ADDR)what);
      break;
#endif
#endif
#if IRIX_4x
    case R_MIPS_REFHALF:
      if (what & 0xffff0000)
        report_error (DL_E_RELOCOVFL, 16, where);
      *(short *)where = (short)what;
      break;

    case R_MIPS_REFWORD:
      *where = what;
      break;

    case R_MIPS_JMPADDR:
      what >>= 2;
      *where = (*where & 0xfc000000) | what;
      break;

    case R_MIPS_REFHI: {
      static long *whereHI;
      static long  whatHI;

      whatHI = *(whereHI = where) << 16;
      break;

    case R_MIPS_REFLO:
      *where = (*where & 0xffff0000) | (what & 0xffff);
      if (whereHI) {
        *whereHI = (*whereHI & 0xffff0000) | (what >> 16) + ((what >> 15) & 1);
        whereHI = 0;
      }
      break;
    }

    case R_MIPS_GPREL:  /* should not occur in dynamically loaded code */
#endif
#if IRIX_5x
    case R_MIPS_REL32:
    case R_MIPS_EXTGOT:
      *where = what;
      break;
#endif
    default:
      return 0;   /* unknown relocation format */
  }

  return 1;
}


static void relocate (HANDLE *file)
{
  AUXINFO *aux  = file->auxinfo;
  OBJINFO *info = aux->objinfo;
  RLOCENT *reloc;
  int      cnt;

  if (file == F_pending)
    return;
  reloc = info->relocptr;
  for (cnt = info->nrelocs; cnt--; reloc++) {
    SYMBOL *sym = (SYMBOL *)reloc->symbol;
    long   *where;
    long    what;
    long    Rvalue;

    /* "where" is the address needing relocation */

    if (info->data && reloc->addr >= info->data->vaddr)
      where = (long *)(reloc->addr + aux->datamod);
    else where = (long *)(reloc->addr + aux->textmod);
    Rvalue = R_extract (where, reloc->rtype);

    /* "what" is the value being referenced */

    while (sym->whatis & SYM_ALIAS)
      sym = sym->u.alias;
    if (sym->whatis & SYM_FUNC) {
      if (!sym->u.slot)
        sym->u.slot = slot_alloc (0, sym->value);
      what = sym->u.slot;
    }
    else if (SYMTYPE (sym) == 1) {
      save_reloc (reloc, where, Rvalue);
      what = UNRESADDR;
    }
    else what = sym->value;
    what += (Rvalue + reloc->addend);

    /* do the relocation */

    if (!R_install (where, what, reloc->rtype))
      report_error (DL_E_RELOCFMT, file->name, reloc->rtype);
  }
}


static void relocate_saved (void)
{
  SRE *prev = (SRE *)&Rsaved;   /* first field of 'SRE' must be 'next' */
  SRE *this = Rsaved;

  while (this) {
    long    what;
    SYMBOL *sym = this->sym;

    /* see if the symbol has been resolved */

    while (sym->whatis & SYM_ALIAS)
      sym = sym->u.alias;
    if (!(sym->whatis & SYM_GLOB))
      this = (prev = this)->next;
    else {

      /* get address being referenced */

      if (sym->whatis & SYM_FUNC) {
        if (!sym->u.slot)
          sym->u.slot = slot_alloc (0, sym->value);
        what = sym->u.slot + this->rvalue;
      }
      else what = sym->value + this->rvalue;

      /* do the relocation */

      if (!R_install (this->where, what + this->addend, this->rtype))
        report_error (DL_E_RELOCFMT, "(?)", this->rtype);

      /* remove saved relocation we just handled */

      prev->next = this->next;
      free (this);
      this = prev->next;
    }
  }

  /* attach any newly saved relocs to end of resulting list */

  prev->next = Rsaved_new;
  Rsaved_new = 0;
}


static HANDLE *load_phase1 (char *path, int options)
{
  char arname[MAXPATHLEN + 1];
  char memname[MAXFILELEN + 1];
  OBJFD   *arch;
  OBJFD   *loadit;
  OBJINFO *info;
  HANDLE  *handle;

  /* load an explicit archive member */

  if (2 == sscanf (path, "%s[%s]", arname, memname)) {
    if (   !(arch   = OBJopen (path, OBJ_ARCH))
        || !(loadit = open_armem (arch, memname)))
      xcerror (path);
    OBJclose (arch, 0);
  }

  /* load simple object file (or search archive) */

  else {
    if (!(arch = OBJopen (path, OBJ_ALL)))
      xcerror (path);
    if (!arch->arch)
      loadit = arch;
    else return archive_search (arch);
  }

  /* here "loadit" is the object (or archive member) to load - read info
     needed to do it */

  if (!(info = OBJread (loadit, OBJ_GSYM | OBJ_SCN | OBJ_RELOC)))
    xcerror (path);

  /* machine-specific processing prior to continuing */

  machine_preload (info);

  /* make sure it has symbols and relocation entries */

  if (!info->nsyms)
    report_error (DL_E_NOSYMBOL, path);
  if (info->flags & OBJ_NRELOC)
    report_error (DL_E_NORELOCS, path);

  /* make the handle that identifies this file and return it */

  handle = make_handle (path, options, info, loadit);
  return handle;
}


static void symbol_adjust (AUXINFO *aux, SYMBOL *sym)
{
  SYMBOL *alias;

  /* modify common symbols in the following way:  if it was mapped to a
     definition defined elsewhere the symbol becomes an external reference;
     if it contributed to the definition the symbol becomes a global
     definition (it may still be aliased in that several commons may map to
     the same definition) */

  if (sym->whatis & SYM_COMM) {
    if (sym->whatis & SYM_ALIAS) {
      for (alias = sym->u.alias; alias->whatis & SYM_ALIAS;)
        alias = alias->u.alias;
      if (alias->whatis & SYM_COMM) {
        if (alias->u.owner)
          sym->value = alias->value + alias->u.owner->auxinfo->datamod;
        else sym->value = alias->value;
        sym->whatis |= SYM_BSS;
      } else {
        sym->whatis = SYM_EXT | SYM_COMM | SYM_ALIAS;
        sym->value  = 0;
      }
    } else {
      sym->value  += sym->u.owner->auxinfo->datamod;
      sym->u.owner = 0;
    }
  }

  /* adjust value of symbol by adding the appropiate correction factor */

  else if (sym->whatis & SYM_TEXT)
    sym->value += aux->textmod;
  else if (sym->whatis & (SYM_DATA | SYM_BSS))
    sym->value += aux->datamod;
}


static void load_phase2 (HANDLE *handle)
{
  HANDLE  *file;
  SYMBOL  *sym;
  SECTION *scn;		/*
  SLOTTBL *slottbl;	*/
  int      fcnt, scnt;

  /* allocate commons */

  allocate_commons (handle);

  /* load text and data segments into memory */

  for (fcnt = (file = handle)->nfiles + 1; fcnt--; file = file->next)
    load_segments (file);

  /* adjust symbol values by adding the appropiate correction factor */

  for (fcnt = (file = handle)->nfiles + 1; fcnt--; file = file->next) {
    AUXINFO *aux = file->auxinfo;

    for (sym = file->symtab, scnt = file->nsyms; scnt--; sym++)
      symbol_adjust (aux, sym);
    sym = (SYMBOL *)aux->objinfo->auxsym;
    for (scnt = aux->objinfo->naux; scnt--; sym++)
      symbol_adjust (aux, sym);
  }

  /* process relocations */

  for (fcnt = (file = handle)->nfiles + 1; fcnt--; file = file->next)
    relocate (file);

  /* move symbols into the primary symbol table */

  for (fcnt = (file = handle)->nfiles + 1; fcnt--; file = file->next)
    symbol_resolution2 (file, SYMTBL_DYNAM);
  relocate_saved ();

  /* machine-specific processing needed before the code can be executed */

  machine_postload (handle);

  /* notification for symbolic debuggers */

  if (dload__DBG_active || G_options & RETRODBG)
    process_DBG (handle);

  /* successful completion:  perform house-keeping such as write-protecting
     unprotected text segments and freeing no-longer needed data */

  for (fcnt = (file = handle)->nfiles + 1; fcnt--; file = file->next) {
    OBJINFO *info = file->auxinfo->objinfo;

    if (file->auxinfo->objfd)
      OBJclose (file->auxinfo->objfd, OBJ_GSYM);
    if (info != &nullinfo) {
      if (info->text) free (info->text);
      if (info->data) free (info->data);
      if (info->bss)  free (info->bss);
      free (info);
    }
    free (file->auxinfo);
    file->auxinfo = 0;
/*  if (file->text)
      file->prot = protect (file->text, file->tsize);	*/
  }
/*
  for (slottbl = slottables; slottbl; slottbl = slottbl->next)
    if (!slottbl->prot)
      slottbl->prot = protect (slottbl->addr, pagesz);
*/
}


int dload_add_opts = 0;    /* temporary kludge for option overrides */
void *dload (char *path, int options)
{
  HANDLE *newfile;

  /* perform initialization */

  options |= dload_add_opts;
  if (setjmp (errorloc))
    return 0;
  if (!initialized)
    dload_startup ();
  if (!path)
    return 0;

  /* the same file cannot be loaded twice unless the OVERLOAD option was
     specified */

  if (hashlookup (filehash, path) && !(options & OVERLOAD))
    report_error (DL_E_ALDYLOAD, path);
  newfile = active = load_phase1 (path, options);

  /* incremental load:  resolve symbols against the pending symbol table but
     do not perform relocation nor binding at this time; unresolved references
     do not cause an abort */

  if (options & INCRLOAD) {
    symbol_resolution1 (newfile);
    symbol_resolution2 (newfile, SYMTBL_PEND);
    add_to_pending (newfile);
    hashadd (filehash, newfile, 0);
    close (newfile->auxinfo->objfd->fileno);
    newfile->auxinfo->objfd->fileno = -1;
    if (G_options & VERBOSE1)
      report_error (DL_I_INCRLOAD, path);
  }

  /* normal load:  resolve symbols against the main symbol table, perform
     relocation and binding and allocate space for commons; the new code
     becomes executable */

  else {
    symbol_resolution1 (newfile);
    if (newfile->auxinfo->unres)
      if (options & ALLOWURES)
        report_error (DL_W_LOADURES, newfile->auxinfo->unres, UNRESADDR);
      else report_error (DL_E_UNRESOLV, newfile->auxinfo->unres);
    load_phase2 (newfile);
    add_to_loaded (newfile);
    hashadd (filehash, newfile, 0);
    if (G_options & VERBOSE1)
      report_error (DL_I_LOADED, path);
  }

  return newfile;
}


void *dload_ctrl (int cmd, ...)
{
  va_list args;

  if (setjmp (errorloc))
    return 0;
  va_start (args, cmd);
  switch (cmd) {

    case INITIAL:
      if (!initialized)
        dload_startup ();
      break;

    case LOADCMPL: {
      HANDLE *file    = va_arg (args, HANDLE *);
      int     options = va_arg (args, int);

      /* verify validity of the handle, make sure it is a pending file, and
         check for illegal symbol references */

      if (file == DLOAD_PEND) {
        if (!initialized || !F_pending->nfiles)
          report_error (DL_E_NOFILES);
        file = active = F_pending;
      } else if (file == DLOAD_MAIN || file == DLOAD_GLBL || file->magic != DLMAGIC)
        report_error (DL_E_BADHANDLE, "dload_ctrl");
      if (!file->auxinfo)
        report_error (DL_E_LOADCMPL, file->name);
      options |= dload_add_opts;		/* KLUDGE */
      file->options |= options;
      if (file->auxinfo->unres)
        if (file->options & ALLOWURES)
          report_error (DL_W_LOADURES, file->auxinfo->unres, UNRESADDR);
        else report_error (DL_E_UNRESOLV, file->auxinfo->unres);

      /* LOADCMPL on all pending files (this should be the most common) */

      if (file == F_pending) {
        HANDLE *new = F_pending;

        load_phase2 (new);
        while (hashnext (symtab[SYMTBL_PEND]))
          hashdel (symtab[SYMTBL_PEND]);
        add_to_loaded (new);
        F_pending = make_handle (0, 0, &nullinfo, 0);
        F_pending->next = F_pending->prev = F_pending;
        return new;
      }

      report_error (DL_E_DISABLED, "LOADCMPL of handles not DLOAD_PEND");
    }

    case UNLOAD: { /*
      HANDLE *file = va_arg (args, HANDLE *); */

      report_error (DL_E_DISABLED, "UNLOAD");
    }

    case GETHANDLE: {
      char *path = va_arg (args, char *);

      if (!initialized || !path)
        return 0;
      return hashlookup (filehash, path);
    }

    case GETSTATUS:
      report_error (DL_E_DISABLED, "GETSTATUS");
#if 0
    case GETSTATUS: {
      HANDLE           *file   = va_arg (args, HANDLE *);
      int              *nfiles = va_arg (args, int *);
      int               cnt    = 0;
      struct dloadstat *buff;

      if (file == DLOAD_MAIN) {
        HANDLE *tmp = F_loaded;
        do { 
        list = F_loaded;
      else if (file == DLOAD_PEND)
        list = F_pending;
      else if (file == DLOAD_GLBL)
        report_error (DL_E_DISABLED, "GETSTATUS with DLOAD_GLBL");
      else if (file->magic != DLMAGIC)
        report_error (DL_E_BADHANDLE, "dload_ctrl");
      else list = file;
    }
#endif

    case SETOPTION: {
      int options = va_arg (args, int);

      G_options |= options;
      return (void *)1;
    }

    case CLROPTION: {
      int options = va_arg (args, int);

      G_options &= ~options;
      return (void *)1;
    }

    case ENTERTAG: {
      char  *tag    = va_arg (args, char *);
      char  *dir    = va_arg (args, char *);
      void (*fcn)() = (void (*)())va_arg (args, ADDR);
      int    len    = strlen (tag) + 1;
      RLTAG *newtag = Malloc (sizeof (RLTAG) + len + strlen (dir) + 1);

      if (!initialized)
        dload_startup ();
      newtag->recover = fcn;
      strcpy (newtag->tagname = (char *)&newtag[1], tag);
      strcpy (newtag->dirname = newtag->tagname + len, dir);
      if (!hashadd (taghash, newtag, 0))
        report_error (DL_E_TAGEXIST, tag);
      return (void *)1;
    }

    default: /* ERROR CASE! */;
  }

  return 0;
}


void *dload_address_lookup (char *name)
{
  SYMBOL *sym;

  if (!initialized)
    dload_startup ();

  if (sym = symbol_lookup (0, name)) {
    if (sym->whatis & SYM_FUNC) {
      if (!sym->u.slot) {
        sym->u.slot = slot_alloc (0, sym->value);
        flush_data_cache (sym->u.slot, SLOTSIZE);
      }
      return (void *)sym->u.slot;
    }
    return (void *)sym->value;
  }
  return 0;
}


static void fillsym (struct symdef *out, SYMBOL *in)
{
  out->name  = in->name;
  out->value = (void *)in->value;
  if (in->whatis & SYM_EXT)
    out->flags = DL_UNDF;
  else {
    if (in->whatis & SYM_TEXT)
      out->flags = DL_TEXT;
    else if (in->whatis & SYM_DATA)
      out->flags = DL_DATA;
    else if (in->whatis & SYM_BSS)
      out->flags = DL_BSS;
    else if (in->whatis & SYM_ABS)
      out->flags = DL_ABS;
    if (in->whatis & SYM_ALIAS)
      out->flags |= DL_INACT;
    else if (in->whatis & SYM_HIDE)
      out->flags |= DL_HIDE;
  }
}


int dload_symbol_lookup (void *handle, char *name, struct symdef **buf)
{
  SYMBOL        *DYNsym;
  struct symdef *symtab, *RETsym;
  int            cnt;

  if (setjmp (errorloc))
    return 0;
  if (!initialized)
    dload_startup ();

  if (handle == DLOAD_MAIN)
    report_error (DL_E_DISABLED, "dload_symbol_lookup using DLOAD_MAIN");
  else if (handle == DLOAD_PEND)
    report_error (DL_E_DISABLED, "dload_symbol_lookup using DLOAD_PEND");
  else if (handle == DLOAD_GLBL)
    report_error (DL_E_DISABLED, "dload_symbol_lookup using DLOAD_GLBL");
  else {
    HANDLE *file = handle;

    /* verify the handle */

    if (!file || file->magic != DLMAGIC)
      report_error (DL_E_BADHANDLE, "dload_symbol_lookup");
    DYNsym = file->symtab;

    /* return all symbols */

    if (!name) {
      RETsym = symtab = Space (file->nsyms, struct symdef);
      for (cnt = file->nsyms; cnt--; DYNsym++) {
        if (DYNsym->whatis == SYM_NIL)
          continue;
        fillsym (RETsym, DYNsym);
        RETsym++;
      }
    }

    /* regular expression match */

    else if (name[0] == '%') {
      report_error (DL_E_DISABLED, "regular expression symbol search");
    }

    /* exact match */

    else {
      for (cnt = file->nsyms; cnt--; DYNsym++) {
        if (DYNsym->whatis == SYM_NIL)
          continue;
        if ((*DYNsym->name == *name) && (strcmp (DYNsym->name, name) == 0)) {
          RETsym = Space (1, struct symdef);
          fillsym (RETsym, DYNsym);
          *buf = RETsym;
          return 1;
        }
      }
    }
  }

  /* adjust size of symbol buffer and return count */

  *buf = realloc (symtab, (cnt = RETsym - symtab) * sizeof (struct symdef));
  return cnt;
}

/*****************************************************************************/
/* This section contains code to support reactive dynamic loading.  Code to  */
/* be reactively loaded is left out of an application and stub files created */
/* with the "mkstubs" executable is linked in instead.  Dynamic loading will */
/* automatically take place at the moment stubbed-out code is referenced.    */
/* These routines are not intended to be called by user-level programs.      */
/*****************************************************************************/

static RLTAG  globaltag;
static RLTAG *taginfo;		/* points to reactive load tag */
static char  *path;

static void handle_reactive ()
{
  if (taginfo && taginfo->recover)
    taginfo->recover (path);
  report_error (DL_F_RLDABORT, path);
}


void dload_reactive (char *tag, int *opts)
{
  char *file = (char *)&opts[1];
  char *subdir;
  char  buffer[MAXPATHLEN];

  /* untagged reactive load is simply the given file name */

  if (!tag) {
    taginfo = &globaltag;
    path    = file;
  }

  /* otherwise we build a complete path from the base directory and optional
     subdirectory specified by the tag */

  else {
    if (!(taginfo = hashlookup (taghash, tag)))
      report_error (DL_E_TAGNOTFND, path = file, tag);
    subdir = tag + strlen (tag) + 1;
    strcpy (path = buffer, taginfo->dirname);
    strcat (path, "/");
    strcat (path, subdir);
    strcat (path, "/");
    strcat (path, file);
  }

  /* load the file */

  if (!dload (path, *opts))
    handle_reactive ();
}

/*****************************************************************************/
/* This section contains code to support field diagnosis of dynamic loader   */
/* related problems.							     */
/*****************************************************************************/

static void file_details (HANDLE *file)
{
  AUXINFO *aux = file->auxinfo;
  SEGMENT *seg;
  int      cmd, len, field;

  /* file name */

  if (file->name) {
    if ((len = strlen (file->name)) >= 80)
      field = len;
    else field = (80 + len) / 2;
    printf ("%*s\n\n\n", field, file->name);
  }
  else printf ("%48s\n\n\n", "<COMPOUND HANDLE>");

  /* load options */

  printf ("Options: ");
  if (file->options & OVERLOAD)   printf (" OVERLOAD");
  if (file->options & INCRLOAD)   printf (" INCRLOAD");
  if (file->options & UNLOADABLE) printf (" UNLOADABLE");
  if (file->options & NOCOMMON)   printf (" NOCOMMON");
  if (file->options & HIDEGLOBAL) printf (" HIDEGLOBAL");
  if (file->options & WEAKGLOBAL) printf (" WEAKGLOBAL");
  if (file->options & DATAONLY)   printf (" DATAONLY");
  if (file->options & ALLOWURES)  printf (" ALLOWURES");
  if (file->options & TEXTREF)    printf (" TEXTREF");
  if (file->options & DATAREF)    printf (" DATAREF");
  if (file->options & TEXTREDEF)  printf (" TEXTREDEF");
  if (file->options & DATAREDEF)  printf (" DATAREDEF");
  if (file->options & DATAMAPNEW) printf (" DATAMAPNEW");
  if (file->options & DATAMAPOLD) printf (" DATAMAPOLD");

  /* status */

  if (aux)
    printf ("\nStatus:  PENDING\n\n");
  else printf ("\nStatus:  LOADED\n\n");

  /* text segment */

  printf ("Text segment:  ");
  if (aux) {
    if (seg = aux->objinfo->text)
      printf ("NOT ALLOCATED   (%d bytes needed)\n", seg->size);
    else printf ("NOT PRESENT\n");
  }
  else if (file->text)
    printf ("0x%.8x  %7d bytes (WRITABLE)\n", file->text, file->tsize);
  else printf ("NOT PRESENT\n");

  /* data segment */

  printf ("Data segment:  ");
  if (aux) {
    if (seg = aux->objinfo->data)
      printf ("NOT ALLOCATED   (%d bytes needed)\n", seg->size);
    else printf ("NOT PRESENT\n");
  }
  else if (file->data)
    printf ("0x%.8x  %7d bytes\n", file->data, file->dsize);
  else printf ("NOT PRESENT\n");

  /* symbols */

  if (aux)
    printf ("Symbols     :  %d (%d unresolved)\n", file->nsyms, aux->unres);
  else printf ("Symbols     :  %d (%d unresolved)\n", file->nsyms, 0);

  /* debugger status */

  if (file->dbgknows)
    printf ("\n\t*** DEBUGGER NOTIFIED ***\n\n\n\n");
  else printf ("\n\t*** DEBUGGER NOT NOTIFIED ***\n\n\n\n");

  /* menu */

  while (1) {
    printf ("\t[0] Return to main menu\n");
    printf ("\t[1] Display symbol table\n");
    printf ("\t[2] Display object information\n");
    printf ("\t[3] Display debugger information\n");
    printf ("\nWhat now? ");
    scanf ("%d", &cmd);

    switch (cmd) {
      case 0: return;
      case 1:
      case 2:
      case 3:
        printf ("NOT IMPLEMENTATED!\n"); break;
      default:
        printf ("INVALID CHOICE!\n"); break;
    }
  }
}


void dload_debug ()
{
  int cmd;

  /* menu */

  while (1) {
    printf ("\t[0] Return to application\n");
    printf ("\t[1] Loaded files\n");
    printf ("\t[2] Pending files\n");
    printf ("\t[3] Global symbol table\n");
    printf ("\t[4] Pending symbol table\n");
    printf ("\t[5] Regions and memory maps\n");
    printf ("\t[6] Slot tables\n");
    printf ("\t[7] Reactive load tags\n");
    printf ("\t[8] File details\n");
    printf ("\nEnter selection:  ");
    scanf ("%d", &cmd);

    switch (cmd) {
      case 0: return;
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
        printf ("NOT IMPLEMENTATED!\n"); break;
      case 8:
        file_details (F_loaded);
      default:
        printf ("INVALID CHOICE!\n"); break;
    }
  }
}

/*****************************************************************************/
/* This section contains code to support symbolic debugging of dynamically   */
/* loaded code where such support is available with debuggers native to a    */
/* particular environment.  The code in this section is inherently archi-    */
/* tecture dependent as it requires knowledge about the native object file   */
/* formats which is accessed via the private data structures of the OBJxxxx  */
/* family of functions.							     */
/*****************************************************************************/

#if CLIX
#include "objpvt.h"

static int   dbgfile;
static char *dbgname;
static int   ENDndx, OLDndx, NEWndx;
static char *OLDsymtbl, *NEWsymtbl;
static char *linebuff;
static int   nlines;
static int  *ndxmap;
static int  *scnmap;
static struct syment  alignsym;
static struct lineno  alignline;
static struct filehdr fhead   = { CLIPPERMAGIC };
static struct scnhdr  texthdr = { ".text", 0, 0, 0, 0, 0, 0, 0, 0, STYP_TEXT };
static struct scnhdr  datahdr = { ".data", 0, 0, 0, 0, 0, 0, 0, 0, STYP_DATA };
static struct scnhdr  bsshdr  = { ".bss",  0, 0, 0, 0, 0, 0, 0, 0, STYP_BSS  };
static struct scnhdr *scnhdrs[3];


/* ARGSUSED */
void dload__DBG_notify (void *debuginfo)
{
}


/* ARGSUSED */
void dload__DBG_unload (void *debuginfo)
{
}


static void translate_index (long *ndxptr)
{
  if (*ndxptr < OLDndx)
    *ndxptr = ndxmap[*ndxptr];
  else if (*ndxptr >= OLDndx)
    *ndxptr = NEWndx + (*ndxptr - OLDndx);
  else *ndxptr = 0;
}


static void translate_lineptr (long *offptr)
{
  if (*offptr)
    *offptr += FILHSZ + fhead.f_nscns * SCNHSZ - scnhdrs[0]->s_lnnoptr;
}


static void *get_symbol (void)
{
  void *old = OLDsymtbl + ++OLDndx * SYMESZ;
  void *new = NEWsymtbl + NEWndx * SYMESZ;

  if (OLDndx < ENDndx) {
    if (!ALIGNED (new, struct syment))
      new = &alignsym;
    (void)memcpy (new, old, SYMESZ);
    return new;
  }
  return 0;
}


static void put_symbol (void *sym)
{
  ndxmap[OLDndx] = NEWndx;
  if (sym == &alignsym)
    (void)memcpy (NEWsymtbl + NEWndx * SYMESZ, sym, SYMESZ);
  NEWndx++;
}


static void do_DBGsymbols (HANDLE *file)
{
  struct objpriv *pfd = (struct objpriv *)file->auxinfo->objfd;
  struct syment  *sym;
  void *F_loc = 0;
  int   numaux;
 
  /* initialize data for processing */

  OLDndx    = -1;
  NEWndx    =  0;
  OLDsymtbl = (char *)pfd->symtab;
  NEWsymtbl = Malloc ((ENDndx = pfd->fhead->f_nsyms) * SYMESZ);
  ndxmap    = Malloc (pfd->fhead->f_nsyms * sizeof (int *));

  while (sym = get_symbol ()) {
    switch (sym->n_sclass) {

      case C_EXT:
        if (!sym->n_scnum && !sym->n_value) {
          OLDndx += sym->n_numaux;
          continue;
        }
        if (F_loc && !ISFCN (sym->n_type)) {
          (void)memcpy (F_loc, &NEWndx, sizeof (NEWndx));
          F_loc = 0;
        }
        if (((SYMBOL *)pfd->symmap[OLDndx])->whatis & SYM_HIDE)
          sym->n_sclass = C_STAT;
      case C_STAT:
      case C_LABEL:
      case C_BLOCK:
      case C_FCN:
        if (sym->n_scnum > 0) {
          if (!(sym->n_scnum = scnmap[sym->n_scnum])) {
            OLDndx += sym->n_numaux;
            continue;
          }
          if (scnhdrs[sym->n_scnum - 1]->s_flags & STYP_TEXT)
            sym->n_value += file->auxinfo->textmod;
          else sym->n_value += file->auxinfo->datamod;
        }
        else if (sym->n_scnum == 0) {
          if (sym->n_value = ((SYMBOL *)pfd->symmap[OLDndx])->value)
            sym->n_scnum = fhead.f_nscns;
          else {
            OLDndx += sym->n_numaux;
            continue;
          }
        }
        break;

      case C_FILE:
        if (F_loc)
          (void)memcpy (F_loc, &NEWndx, sizeof (NEWndx));
        F_loc = &((struct syment *)(NEWsymtbl + NEWndx * SYMESZ))->n_value;
        break;
    }
    put_symbol (sym);

    /* update the auxiliary entry if the symbol has one */

    if (numaux = sym->n_numaux) {
      union auxent *auxsym = get_symbol ();

      switch (sym->n_sclass) {
        case C_STAT:
          if (!sym->n_type) {
            auxsym->x_scn.x_nreloc = 0;
            break;
          }
        case C_EXT:
          if (ISFCN (sym->n_type)) {
            translate_index   (&auxsym->x_sym.x_fcnary.x_fcn.x_endndx);
            translate_lineptr (&auxsym->x_sym.x_fcnary.x_fcn.x_lnnoptr);
          }
        case C_REGPARM:
        case C_ARG:
        case C_REG:
        case C_AUTO:
        case C_MOS:
        case C_MOU:
        case C_TPDEF:
          if ( BTYPE (sym->n_type) != T_STRUCT &&
               BTYPE (sym->n_type) != T_UNION  &&
               BTYPE (sym->n_type) != T_ENUM      ) break;
        case C_EOS:
          translate_index (&auxsym->x_sym.x_tagndx);
          break;
        case C_FCN:
        case C_BLOCK:
          if (sym->n_name[1] != 'b')
            break;
        case C_STRTAG:
        case C_UNTAG:
        case C_ENTAG:
          translate_index (&auxsym->x_sym.x_fcnary.x_fcn.x_endndx);
        default:
          break;
      }

      put_symbol (auxsym);
      while (--numaux)
        put_symbol (get_symbol ());
    }
  }

  /* store number of symbols in file header */

  fhead.f_nsyms = NEWndx;
}


static void do_DBGlines (HANDLE *file)
{
  int    cnt;
  OBJFD *fd = file->auxinfo->objfd;

  /* read the line numbers into memory */
  /********************************************/
  /* WARNING:  I am not handling .xingr case! */

  if (!(nlines = scnhdrs[0]->s_nlnno))
    return;
  if (fd->fileno == -1)
    reopen (fd);
  linebuff = Malloc (nlines * LINESZ);
  Seek (fd, (uint)scnhdrs[0]->s_lnnoptr, 0);
  Reads (fd, linebuff, nlines * LINESZ);
  translate_lineptr (&scnhdrs[0]->s_lnnoptr);

  /* update each line number entry */

  for (cnt = 0; cnt < nlines; cnt++) {
    struct lineno *line = (struct lineno *)(linebuff + cnt * LINESZ);

    if (!ALIGNED (line, struct lineno))
      line = memcpy (&alignline, line, LINESZ);
    if (line->l_lnno)
      line->l_addr.l_paddr += file->auxinfo->textmod;
    else {
      union auxent *auxsym;
      int           lineoff;

      translate_index (&line->l_addr.l_symndx);
      auxsym
          = (union auxent *)(NEWsymtbl + SYMESZ * (line->l_addr.l_symndx + 1));
      lineoff = scnhdrs[0]->s_lnnoptr + cnt * LINESZ;
      (void)memcpy (&auxsym->x_sym.x_fcnary.x_fcn.x_lnnoptr,
                                                   &lineoff, sizeof (lineoff));
    }
    if (line == &alignline)
      (void)memcpy (linebuff + cnt * LINESZ, line, LINESZ);
  }
}


static void process_DBG (HANDLE *handle)
{
  HANDLE *pend = 0;
  HANDLE *file;
  int     nfiles = handle->nfiles;
  int     ndx;

  /* notify debugger about files loaded prior to its becoming active */

  if (dload__DBG_retrocnt && dload__DBG_active) {
    dload__DBG_retrocnt = 0;
    file = F_loaded;
    do {
      if (file->dbginfo && !file->dbgknows && !(file->options & HIDEDEBUG)) {
        dload__DBG_notify (file->dbginfo);
        file->dbgknows = 1;
      }
    } while ((file = file->next) != F_loaded);
  }

  /* fill in bss section header */

  if (!nfiles)
    nfiles = 1;
  else if (handle->dsize) {
    handle = (pend = handle)->next;
    bsshdr.s_paddr = bsshdr.s_vaddr = pend->data;
    bsshdr.s_size  = pend->dsize;
  }
  else handle = handle->next;

  /* for each file being loaded create an output debug symbol table */

  for (file = handle; nfiles--; file = file->next) {
    struct objpriv *pfd = (struct objpriv *)file->auxinfo->objfd;
    struct scnhdr  *scn;
    int textnum, datanum, bssnum;

    /* do not process if file is hidden from debuggers */

    if (file->options & HIDEDEBUG)
      continue;

    /* open the file for the output debug symbol table */

    dbgname = tempnam ("/usr/tmp", "DL$");
    if (-1 == (dbgfile = open (dbgname, O_WRONLY | O_CREAT, 0644)))
      report_error (DL_E_OPENFAIL, dbgname);

    /* fill in stuff I know already for output section headers */

    ndx = 0;
    if (file->tsize) {
      texthdr.s_paddr = texthdr.s_vaddr = file->text;
      texthdr.s_size  = file->tsize;
      scnhdrs[ndx++]  = &texthdr;
      textnum         = ndx;
    }
    if (file->dsize) {
      datahdr.s_paddr = datahdr.s_vaddr = file->data;
      datahdr.s_size  = file->dsize;
      scnhdrs[ndx++]  = &datahdr;
      datanum         = ndx;
    }
    if (pend) {
      scnhdrs[ndx++] = &bsshdr;
      bssnum = ndx;
    }
    fhead.f_nscns = ndx;

    /* create a section map for conversion of input to output section
       numbers */

    scnmap = Calloc ((pfd->fhead->f_nscns + 1) * SCNHSZ);
    for (scn = pfd->shead, ndx = 0; ndx < pfd->fhead->f_nscns; ndx++, scn++) {
      if (scn->s_flags & STYP_TEXT && scn->s_size) {
        texthdr.s_lnnoptr = pfd->shead[ndx].s_lnnoptr;
        texthdr.s_nlnno   = pfd->shead[ndx].s_nlnno;
        scnmap[ndx + 1]   = textnum;
      }
      else if (scn->s_flags & (STYP_DATA | STYP_BSS) && scn->s_size)
        scnmap[ndx + 1] = datanum;
      else scnmap[ndx + 1] = 0;
    }

    /* update line numbers and symbols and write the file */

    do_DBGsymbols (file);
    do_DBGlines (file);
    fhead.f_symptr= FILHSZ + fhead.f_nscns * SCNHSZ + texthdr.s_nlnno * LINESZ;
    fhead.f_timdat = time (0);
    write (dbgfile, &fhead, FILHSZ);
    for (ndx = 0; ndx < fhead.f_nscns; ndx++)
      write (dbgfile, scnhdrs[ndx], SCNHSZ);
    if (nlines && (-1 == write (dbgfile, linebuff, nlines * LINESZ)))
      report_error (DL_E_RITEFAIL, dbgname);
    if (-1 == write (dbgfile, NEWsymtbl, fhead.f_nsyms * SYMESZ))
      report_error (DL_E_RITEFAIL, dbgname);
    if (pfd->extname) {
      int align;
      memcpy (&align, pfd->extname, 4);
      if (-1 == write (dbgfile, pfd->extname, align))
        report_error (DL_E_RITEFAIL, dbgname);
    } else {
      ndx = 4;
      if (-1 == write (dbgfile, &ndx, 4))
        report_error (DL_E_RITEFAIL, dbgname);
    }
    close (dbgfile);

    /* cleanup */

    free (scnmap);
    free (ndxmap);
    free (NEWsymtbl);
    if (nlines)
      free (linebuff);

    /* send notification to debuggers */

    file->dbginfo = dbgname;
    if (dload__DBG_active) {
      dload__DBG_notify (dbgname);
      file->dbgknows = 1;
    }
    else dload__DBG_retrocnt++;
  }
}

/*****************************************************************************/
/*			ALL UNIMPLEMENTED ENVIRONMENTS			     */
/*****************************************************************************/
#else

/* ARGSUSED */
void dload__DBG_notify (void *debuginfo)
{
}

/* ARGSUSED */
void dload__DBG_unload (void *debuginfo)
{
}

/* ARGSUSED */
static void process_DBG (HANDLE *handle)
{
}
#endif
