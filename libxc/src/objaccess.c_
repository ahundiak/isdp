#if CLIX
#define  _INGR_EXTENSIONS
#endif
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <string.h>
#include <fcntl.h>
#include "xcmisc.h"
#include "errordef.h"
#include "vla.h"
#include "malloc.h"
#include "objaccess.h"
#include "objpvt.h"

/* need a "xcsyscall.h" include file for this later */

extern void *XC_mmap ();

/* input files whose symbol/relocation info exceeds this limit will be memory-
   mapped if possible; this allows us to return those pages to the system */

#define  MINMAP  0x40000

/* minimum of two values */

#define  MIN(a,b)  ((a) < (b) ? (a) : (b))

/* truncate to a boundary */

#define  TRUNC(v,b)  ((uint)(v) / (b) * (b))

/* The following macros allow for handling of various errors */

#define  Seek(d,o,w)   if (-1 == XC_seek ((d), (o), (w))) goto error; else
#define  Read(d,b,n)   if (-1 == XC_read ((d), (b), (n))) goto error; else
#define  Reads(d,b,n)  if (-1 == XC_reads ((d), (b), (n))) goto error; else
#define  Write(d,b,n)  if (-1 == XC_write ((d), (b), (n))) goto error; else

/* The following macros and function make it easier to handle out-of-memory
   conditions. */

#define  Alloc(p,s)    if (!((p) = space ((s), 0))) goto error; else
#define  Zalloc(p,s)   if (!((p) = space ((s), 1))) goto error; else
#define  Free_space()  while (pndx) free (alloced[--pndx])
#define  Keep_space()  pndx = 0

static void *alloced[20];
static int   pndx = 0;

static void *space (unsigned int nbytes, int clear)
{
  void *ptr = (clear ? calloc (1, nbytes) : malloc (nbytes));

  if (ptr)
    alloced[pndx++] = ptr;
  else {
    XC_errno  = OUTOFMEM;
    XC_erraux = nbytes;
  }
  return ptr;
}


static SECTION *find_outscn_by_addr (struct objpriv *pfd, unsigned int addr)
{
  SECTION *scn = pfd->info->scnptr;
  int      cnt = pfd->info->nsects;

  for (; cnt--; scn++)
    if (addr >= scn->vaddr && addr < scn->vaddr + scn->size)
      return scn;
  return 0;
}


#if SVR4
#define pagesz 4096    /* this is temporary!! */

static void *getdata (int fno, uint off, uint size, int map)
{
  char *buffer;

  /* attempt to memory-map the data if it is "large" */

  if (map && size >= MINMAP) {
    uint  m_off  = TRUNC (off, pagesz);
    uint  m_size = size + off - m_off;

    buffer = XC_mmap (0, m_size, PROT_READ, MAP_PRIVATE, fno, m_off);
    if (buffer != (char *)-1)
      return (void *)(buffer + (off - m_off));
  }

  /* otherwise use normal read */

  Seek (fno, off, 0);
  Alloc (buffer, size);
  Reads (fno, buffer, size);

  return (void *)buffer;
error:
  return 0;
}
#endif


static int make_auxseg (SEGMENT *seg, int type, STE *aux)
{
  int      Scnt, Acnt = 0;
  SECTION *scn;

  if (seg) {
    for (scn = seg->scnptr, Scnt = seg->nscns; Scnt--; scn++) {
      if (scn->flags & SCN_NRES)
        continue;
      aux->whatis = type;
      aux->name   = scn->name;
      aux->value  = scn->vaddr;
      aux->type   = 0;
      scn->auxsym = aux++;
      Acnt++;
    }
  }

  return Acnt;
}


static int make_aux (OBJINFO *info)
{
  STE *auxsym;

  /* allocate array of auxiliarly symbols */

  Alloc (auxsym, (info->nsects + 1) * sizeof (STE));
  info->auxsym = auxsym;

  /* generate ".shbase" symbol for shared libraries */

  if (info->flags & OBJ_SLIB) {
    auxsym->name   = ".shbase";
    auxsym->whatis = SYM_TEXT | SYM_STAT;   /* shlib base always text? */
    auxsym->value  = info->base;
    auxsym->type   = 0;
    auxsym++;
  }

  /* generate symbols for references relative to segments */

  auxsym += make_auxseg (info->text, SYM_TEXT | SYM_STAT, auxsym);
  auxsym += make_auxseg (info->data, SYM_DATA | SYM_STAT, auxsym);
  auxsym += make_auxseg (info->bss,  SYM_BSS  | SYM_STAT, auxsym);
  info->naux = auxsym - info->auxsym;

  return 1;
error:
  return 0;
}

/*****************************************************************************/
/*									     */
/*  Machines:	Intergraph workstations/servers     Processor:  Clipper	     */
/*									     */
/*  Operating System:  CLIX						     */
/*									     */
/*****************************************************************************/
#if CLIX

static int is_archive (struct objpriv *pfd)
{
  return 0;
}


static int get_map_params (struct objpriv *pfd)
{
  static uint pagesz = 0;
  uint        mapoff;
  uint        mapsize;

  /* determine map offset */

  if (pfd->reloc_off)
    mapoff = pfd->reloc_off;
  else if (pfd->line_off)
    mapoff = pfd->line_off;
  else if (pfd->fhead->f_symptr)
    mapoff = pfd->fhead->f_symptr;
  else return 0;

  /* determine map size */

  if (!pagesz)
    pagesz = getpagesize ();
  mapoff = TRUNC (pfd->fd.base + mapoff, pagesz) - pfd->fd.base;
  if ((mapsize = pfd->fsize - mapoff) < MINMAP)
    return 0;
  pfd->mapoff  = mapoff;
  pfd->mapsize = mapsize;
  return 1;
}


static struct scnhdr *find_scn_by_name (struct objpriv *pfd, char *name)
{
  struct scnhdr *scn = pfd->shead;
  int            cnt = pfd->fhead->f_nscns;

  for (; cnt--; scn++)
    if (0 == strncmp (scn->s_name, name, 8))
      return scn;
  return 0;
}


static struct scnhdr *find_scn_by_addr (struct objpriv *pfd, unsigned int addr)
{
  struct scnhdr *scn = pfd->shead;
  int            cnt = pfd->fhead->f_nscns;

  for (; cnt--; scn++)
    if (addr >= scn->s_vaddr && addr < scn->s_vaddr + scn->s_size)
      return scn;
  return 0;
}


static struct ingr_sec *find_xingr (struct objpriv *pfd, char *name)
{
  struct ingr_sec *info = pfd->xingr->i_data;
  int              cnt  = pfd->xingr->i_numsecs;

  while (cnt--) {
    if (strncmp (info->sname, name, 8) == 0)
      return info;
    info++;
  }
  return 0;
}


static int get_obj_info (struct objpriv *pfd)
{
  int            fileno = pfd->fd.fileno;
  int            cnt;
  struct scnhdr *INscn;
  OBJINFO       *info;

  /* read in the file header and verify magic */

  Alloc (pfd->fhead, sizeof (struct filehdr));
  if (   (-1 == XC_reads (fileno, pfd->fhead, sizeof (*pfd->fhead)))
      || pfd->fhead->f_magic != CLIPPERMAGIC                         ) {
    XC_errno = NOTANOBJ;
    goto error;
  }
#ifdef DISPLAY
  printf ("*** FILE HEADER ***\n\n");
  printf ("f_magic    0x%.4x\n", pfd->fhead->f_magic);
  printf ("f_nscns    %d\n",     pfd->fhead->f_nscns);
  printf ("f_timdat   %d\n",     pfd->fhead->f_timdat);
  printf ("f_symptr   0x%.8x\n", pfd->fhead->f_symptr);
  printf ("f_nsyms    %d\n",     pfd->fhead->f_nsyms);
  printf ("f_opthdr   0x%.4x\n", pfd->fhead->f_opthdr);
  printf ("f_flags    0x%.4x\n", pfd->fhead->f_flags);
#endif

  /* read in the system header */

  if (pfd->fhead->f_opthdr) {
    Alloc (pfd->ohead, sizeof (struct aouthdr));
    Reads (fileno, pfd->ohead, sizeof (*pfd->ohead));
#ifdef DISPLAY
    printf ("\n\n\n*** SYSTEM HEADER ***\n\n");
    printf ("magic        0x%.4x\n", pfd->ohead->magic);
    printf ("vstamp       %d\n",     pfd->ohead->vstamp);
    printf ("tsize        0x%.8x\n", pfd->ohead->tsize);
    printf ("dsize        0x%.8x\n", pfd->ohead->dsize);
    printf ("bsize        0x%.8x\n", pfd->ohead->bsize);
    printf ("entry        0x%.8x\n", pfd->ohead->entry);
    printf ("text_start   0x%.8x\n", pfd->ohead->text_start);
    printf ("data_start   0x%.8x\n", pfd->ohead->data_start);
#endif
  }

  /* read in the section headers */

  Alloc (pfd->shead, pfd->fhead->f_nscns * sizeof (struct scnhdr));
  Reads (fileno, pfd->shead, pfd->fhead->f_nscns * sizeof (*pfd->shead));

#ifdef DISPLAY
  { int ndx, cnt = pfd->fhead->f_nscns;
    printf ("\n\n\n*** SECTION HEADERS ***\n\n");
    printf ("  s_name      s_paddr    s_scnptr    s_relptr   s_lnnoptr\n");
    printf ("  s_flags     s_vaddr    s_size      s_nreloc   s_nlnno\n\n");
    for (ndx = 0; ndx < cnt; ndx++) {
      printf ("\n%-8s    0x%.8x  0x%.8x  0x%.8x  0x%.8x\n",
               pfd->shead[ndx].s_name,
               pfd->shead[ndx].s_paddr,
               pfd->shead[ndx].s_scnptr,
               pfd->shead[ndx].s_relptr,
               pfd->shead[ndx].s_lnnoptr
             );
      printf ("0x%.8x  0x%.8x  0x%.8x  %5d       %5d\n",
               pfd->shead[ndx].s_flags,
               pfd->shead[ndx].s_vaddr,
               pfd->shead[ndx].s_size,
               pfd->shead[ndx].s_nreloc,
               pfd->shead[ndx].s_nlnno
             );
    }
  }
#endif

  /* get the .xingr section if present */

  { struct scnhdr *ingrscn = find_scn_by_name (pfd, ".xingr");
    if (ingrscn) {
      Alloc (pfd->xingr, ingrscn->s_size);
      Seek (pfd->fd.fileno, pfd->fd.base + ingrscn->s_scnptr, 0);
      Reads (pfd->fd.fileno, pfd->xingr, ingrscn->s_size);
    }
  }

  /* determine file offset to the relocation entries and line numbers */

  for (INscn = pfd->shead, cnt = pfd->fhead->f_nscns; cnt--; INscn++) {
    if (!pfd->reloc_off && INscn->s_relptr)
      pfd->reloc_off = INscn->s_relptr;
    if (!pfd->line_off && INscn->s_lnnoptr)
      pfd->line_off = INscn->s_lnnoptr;
  }

  /* allocate an info structure and fill in stuff from headers (this is
     returned by a subsequent call to OBJread) */

  Zalloc (info, sizeof (OBJINFO));
  pfd->info       = info;
  info->timestamp = pfd->fhead->f_timdat;
  if (pfd->ohead) {
    info->entry = pfd->ohead->entry;
    if (pfd->fhead->f_flags & F_EXEC)
      info->flags |= (pfd->ohead->magic == LIBMAGIC ? OBJ_SLIB : OBJ_EXE);
  }
  if (!pfd->fhead->f_symptr)
    info->flags |= OBJ_NSYM;
  if (pfd->fhead->f_flags & F_RELFLG)
    info->flags |= OBJ_NRELOC;
  if (!pfd->ohead)
    info->flags |= OBJ_IMPURE;
  else switch (pfd->ohead->magic) {
    case OMAGIC  : info->flags |= OBJ_IMPURE; break;
    case NMAGIC  : info->flags |= OBJ_SHARED; break;
    case ZMAGIC  :
    case LIBMAGIC: info->flags |= OBJ_DEMAND; break;
    default      : XC_errno     = NOTANOBJ;   goto error;
  }

  /* segment information */

  for (cnt = pfd->fhead->f_nscns, INscn = pfd->shead; cnt--; INscn++) {
    SEGMENT *seg;

    INscn->s_flags &= 0xffff;  /* clear bogus flags! */
    if (INscn->s_flags & ~(STYP_TEXT | STYP_DATA | STYP_BSS) || !INscn->s_size)
      continue;
    Alloc (seg, sizeof (SEGMENT));
    seg->size   = INscn->s_size;
    seg->faddr  = INscn->s_scnptr;
    seg->vaddr  = INscn->s_vaddr;
    seg->nscns  = 0;
    seg->scnptr = 0;
    if (INscn->s_flags == STYP_TEXT)
      info->text = seg;
    else if (INscn->s_flags == STYP_DATA)
      info->data = seg;
    else if (INscn->s_flags == STYP_BSS)
      info->bss = seg;
  }

  /* ZMAGIC (demand paged) objects need an adjustment to the segment
     information because the file offsets as given are not page-aligned */

  if (info->flags & OBJ_DEMAND) {
    if (info->text) {
      int pad = info->text->faddr & 0xfff;
      info->text->faddr -= pad;
      info->text->vaddr -= pad;
      info->text->size  += pad;
    }
    if (info->data) {
      int pad = info->data->faddr & 0xfff;
      info->data->faddr -= pad;
      info->data->vaddr -= pad;
      info->data->size  += pad;
    }
  }

  /* return success/failure here */

  return 1;
error:
  return 0;
}


static int get_section_info (struct objpriv *pfd)
{
  int            cnt   = pfd->fhead->f_nscns;
  OBJINFO       *info  = pfd->info;
  struct scnhdr *INscn = pfd->shead;
  SECTION       *OUTscn;

  Zalloc (OUTscn, cnt * sizeof (SECTION));
  info->nsects = cnt;
  info->scnptr = OUTscn;
  pfd->done   |= OBJ_SCN;

  for (; cnt--; INscn++, OUTscn++) {
    OUTscn->name     = stralloc (INscn->s_name);   /* later:  use name-cache */
    OUTscn->size     = INscn->s_size;
    OUTscn->faddr    = INscn->s_scnptr;
    OUTscn->vaddr    = INscn->s_vaddr;
    if (INscn->s_flags == STYP_TEXT) {
      if (info->text) {
        info->text->scnptr = OUTscn;
        info->text->nscns++;
      }
      OUTscn->flags = SCN_TEXT | SCN_READ | SCN_EXE;
    }
    else if (INscn->s_flags == STYP_DATA) {
      if (info->data) {
        info->data->scnptr = OUTscn;
        info->data->nscns++;
      }
      OUTscn->flags = SCN_DATA | SCN_READ | SCN_WRITE;
    }
    else if (INscn->s_flags == STYP_BSS) {
      if (info->bss) {
        info->bss->scnptr = OUTscn;
        info->bss->nscns++;
      }
      OUTscn->flags = SCN_BSS | SCN_READ | SCN_WRITE;
    }
    else OUTscn->flags = SCN_INFO | SCN_NRES;
  }

  /* return success/failure here */

  return 1;
error:
  return 0;
}


static int mapped_symbols (struct objpriv *pfd)
{
  int nsyms;

  if (nsyms = pfd->fhead->f_nsyms) {
    pfd->symtab  = (struct syment *)
                         (pfd->mapaddr + (pfd->fhead->f_symptr - pfd->mapoff));
    pfd->extname = (char *)pfd->symtab + (nsyms * SYMESZ);
  }
  return nsyms;
}


static int read_symbols (struct objpriv *pfd)
{
  struct syment *symtab;
  char          *names;
  int            nsyms;
  int            strsz;

  if (nsyms = pfd->fhead->f_nsyms) {
    Seek (pfd->fd.fileno, pfd->fd.base + pfd->fhead->f_symptr, 0);
    Alloc (symtab, nsyms * SYMESZ);
    Reads (pfd->fd.fileno, symtab, nsyms * SYMESZ);
    switch (XC_read (pfd->fd.fileno, &strsz, sizeof (strsz))) {
      default:
        Alloc (names, strsz);
        Reads (pfd->fd.fileno, names + sizeof (strsz), strsz - sizeof (strsz));
        *(int *)names = strsz;
        pfd->extname  = names;
      case  0:
        pfd->symtab = symtab;
        break;
      case -1:
        goto error;
    }
  }

  return nsyms;
error:
  return -1;
}


static struct syment *get_symbol (struct objpriv *pfd, int ndx)
{
  struct syment       *symbol;
  static struct syment aligned;

  symbol = (struct syment *)((char *)pfd->symtab + SYMESZ * ndx);
  if (!ALIGNED (symbol, struct syment))
    symbol = (struct syment *)memcpy (&aligned, symbol, SYMESZ);
  return symbol;
}


static int get_global_symbols (struct objpriv *pfd)
{
  int            nsyms, ngsyms, ndx;
  char          *names;
  void          *ncache;
  struct scnhdr *scn;
  struct syment *symtab, *INsym;
  char           tmpname[9];            /* for 8-byte symbol names */
  STE           *OUTsym;

  /* read symbol table if I haven't already done so */

  if (pfd->symtab)
    nsyms = pfd->fhead->f_nsyms;
  else switch (nsyms = (pfd->mapaddr ? mapped_symbols : read_symbols)(pfd)) {
    case -1: goto error;
    case  0: return 1;
    default: break;
  }
  symtab = pfd->symtab;
  names  = pfd->extname;

#ifdef DISPLAY
#endif

  /* count number of global symbols in order to save on memory allocation (we
     can ignore alignment since the "n_sclass" and "n_numaux" fields are
     chars) */

  for (ngsyms = ndx = 0; ndx < nsyms; ndx += INsym->n_numaux + 1) {
    INsym = (struct syment *)((char *)symtab + ndx * SYMESZ);
    if (INsym->n_sclass == C_EXT)
      ngsyms++;
  }

  /* allocate space for the output symbol table and symbol map then update
     information */

  Alloc (OUTsym, ngsyms * sizeof (STE));
  Zalloc (pfd->symmap, nsyms * sizeof (STE *));
  ncache            = namecache_init (28 * ngsyms, 0);
  pfd->done        |= OBJ_GSYM;
  pfd->info->nsyms  = ngsyms;
  pfd->info->symptr = OUTsym;

  /* process global symbols and construct the symbol map */

  tmpname[8] = '\0';
  for (ndx = 0; ndx < nsyms; ndx += INsym->n_numaux + 1) {
    INsym = get_symbol (pfd, ndx);
    if (INsym->n_sclass != C_EXT)
      continue;
    OUTsym->value = INsym->n_value;
    OUTsym->type  = 0;

    /* symbol name */

    if (INsym->n_zeroes)
      if (INsym->n_name[7])
        OUTsym->name = (char *)namecache_add
                                 (ncache, strncpy (tmpname, INsym->n_name, 8));
      else OUTsym->name = (char *)namecache_add (ncache, INsym->n_name);
    else OUTsym->name= (char *)namecache_add (ncache, names + INsym->n_offset);

    /* symbol flags */

    switch (INsym->n_scnum) {
      case -1: OUTsym->whatis = SYM_GLOB | SYM_ABS;
               if (scn = find_scn_by_addr (pfd, INsym->n_value))
                 if (scn->s_flags & STYP_TEXT)
                   OUTsym->whatis |= SYM_FUNC;
                 else if (scn->s_flags & STYP_DATA)
                   OUTsym->whatis |= SYM_VAR;
      case -2: break;
      case  0: if (INsym->n_value)
                 OUTsym->whatis = SYM_COMM | SYM_VAR;
               else OUTsym->whatis = SYM_EXT;
               break;
      default: scn = &pfd->shead[INsym->n_scnum - 1];
               if (scn->s_flags & STYP_TEXT)
                 OUTsym->whatis = SYM_GLOB | SYM_TEXT | SYM_FUNC;
               else if (scn->s_flags & STYP_DATA)
                 OUTsym->whatis = SYM_GLOB | SYM_DATA | SYM_VAR;
               else if (scn->s_flags & STYP_BSS)
                 OUTsym->whatis = SYM_GLOB | SYM_BSS | SYM_VAR;
               else OUTsym->whatis = SYM_GLOB;
               break;
    }

    pfd->symmap[ndx] = OUTsym++;
  }

  /* adjust symbol names to the proper pointers */

  pfd->info->nametbl = namecache_fini (ncache);
  for (OUTsym = pfd->info->symptr; ngsyms--; OUTsym++)
    OUTsym->name = pfd->info->nametbl + (int)OUTsym->name;

  /* return success/failure here */

  return 1;
error:
  return 0;
}


static int mapped_relocs (struct objpriv *pfd, struct reloc **relptr)
{
  int relsize;

  /* determine size of relocation table */

  if (!pfd->reloc_off)
    return 0;
  if (pfd->line_off)
    relsize = pfd->line_off - pfd->reloc_off;
  else if (pfd->fhead->f_nsyms)
    relsize = pfd->fhead->f_symptr - pfd->reloc_off;
  else relsize = pfd->fsize - pfd->reloc_off;

  /* return info */

  *relptr = (struct reloc *)(pfd->mapaddr + (pfd->reloc_off - pfd->mapoff));
  return (relsize / RELSZ);
}


static int read_relocs (struct objpriv *pfd, struct reloc **relptr)
{
  struct reloc *relbuff;
  int           relsize;

  /* determine size of relocation table */

  if (!pfd->reloc_off)
    return 0;
  if (pfd->line_off)
    relsize = pfd->line_off - pfd->reloc_off;
  else if (pfd->fhead->f_nsyms)
    relsize = pfd->fhead->f_symptr - pfd->reloc_off;
  else relsize = pfd->fsize - pfd->reloc_off;

  /* read the relocation table */

  Alloc (relbuff, relsize);
  Seek (pfd->fd.fileno, pfd->fd.base + pfd->reloc_off, 0);
  Reads (pfd->fd.fileno, relbuff, relsize);

  /* return info */

  *relptr = relbuff;
  return (relsize / RELSZ);
error:
  return -1;
}


static int get_reloc_info (struct objpriv *pfd)
{
  OBJINFO       *info = pfd->info;
  int            nrelocs;
  int            Scnt, Rcnt, ndx;
  struct reloc  *relbuff;
  struct reloc  *INreloc;
  struct reloc   aligned;	/* for non-aligned relocs */
  RLOCENT       *OUTreloc;

  /* read the relocation entries */

  nrelocs = (pfd->mapaddr ? mapped_relocs : read_relocs)(pfd, &relbuff);
  switch (nrelocs) {
    case -1: goto error;
    case  0: return 1;
    default: break;
  }

  /* generate auxiliary symbols used for internal relocs */

  if (!make_aux (info))
    goto error;

  /* construct relocation table to return */

  Alloc (info->relocptr, (info->nrelocs = nrelocs) * sizeof (RLOCENT));
  OUTreloc = info->relocptr;
  INreloc  = relbuff;
  for (ndx = 0, Scnt = 0; Scnt < info->nsects; Scnt++) {
    struct ingr_sec *ingrinfo;

    /* determine number relocs for current section (must check .xingr section
       if present for overflowed "s_nreloc" field) and update section info */

    if (pfd->xingr && (ingrinfo = find_xingr (pfd, pfd->shead[Scnt].s_name)))
      Rcnt = ingrinfo->nreloc;
    else Rcnt = pfd->shead[Scnt].s_nreloc;
    if (!Rcnt)
      continue;
    info->scnptr[Scnt].relocptr = OUTreloc;
    info->scnptr[Scnt].nrelocs  = Rcnt;

    /* process relocs for this section */
    
    for (; Rcnt--; OUTreloc++, ndx++) {
      INreloc = (struct reloc *)((char *)relbuff + RELSZ * ndx);
      if (!ALIGNED (INreloc, struct reloc))
        INreloc = (struct reloc *)memcpy (&aligned, INreloc, RELSZ);
      OUTreloc->addr = INreloc->r_vaddr;
      if (!(OUTreloc->symbol = pfd->symmap[INreloc->r_symndx])) {
        struct syment *sym = get_symbol (pfd, INreloc->r_symndx);
        OUTreloc->symbol   = info->scnptr[sym->n_scnum - 1].auxsym;
      }
      if (OUTreloc->symbol->whatis & SYM_COMM)
        OUTreloc->addend = 0;
      else OUTreloc->addend = - OUTreloc->symbol->value;
      switch (OUTreloc->rtype = INreloc->r_type) {  /* handle pc-relative */
        case R_CLIP_PCRWORD:
        case R_CLIP_PCRLONG: OUTreloc->addend += OUTreloc->addr;
        default            : break;
      }
    }
  }

  /* return success/failure here */

  pfd->done |= OBJ_RELOC;
  if (!pfd->mapaddr)
    free (relbuff);
  return 1;
error:
  return 0;
}

static int free_machine_data (struct objpriv *pfd)
{
  if (pfd->fhead)  free (pfd->fhead);
  if (pfd->ohead)  free (pfd->ohead);
  if (pfd->shead)  free (pfd->shead);
  if (pfd->xingr)  free (pfd->xingr);
  if (pfd->symmap) free (pfd->symmap);
  if (pfd->mapaddr)
    XC_munmap (pfd->mapaddr, pfd->mapsize);
  else {
    if (pfd->symtab)  free (pfd->symtab);
    if (pfd->extname) free (pfd->extname);
  }

  return 1;
}
#endif

/*****************************************************************************/
/*									     */
/*  Machines:	SparcStation 2			Processor:  Sparc	     */
/*		SparcStation 10						     */
/*									     */
/*  Operating System:  SunOS 4.1.2, SunOS 4.1.3 (Solaris 1.1)		     */
/*									     */
/*****************************************************************************/
#if (SunOS && BSD)

static int is_archive (struct objpriv *pfd)
{
  char archeck[SARMAG];

  /* do I want to read in any archive headers here? */

  if (   (read (pfd->fd.fileno, archeck, SARMAG) == SARMAG)
      && (strncmp (archeck, ARMAG, SARMAG) == 0)            ) {
    return pfd->fd.arch = 1;
  }
  return 0;
}


static int get_map_params (struct objpriv *pfd)
{
  static uint pagesz = 0;
  uint        mapoff;
  uint        mapsize;

  /* determine map offset */

  if (pfd->ldyn)
    if (pfd->ldyn->ld_hash - pfd->ldyn->ld_rel)
      mapoff = pfd->ldyn->ld_rel;
    else mapoff = pfd->ldyn->ld_stab;
  else if (pfd->fhead->a_trsize + pfd->fhead->a_drsize)
    mapoff = N_TRELOFF (*pfd->fhead);
  else if (pfd->fhead->a_syms)
    mapoff = N_SYMOFF (*pfd->fhead);
  else return 0;

  /* determine map size */

  if (!pagesz)
    pagesz = getpagesize ();
  mapoff = TRUNC (pfd->fd.base + mapoff, pagesz) - pfd->fd.base;
  if (pfd->ldyn) {
    if ((mapsize = N_DATOFF (*pfd->fhead) - mapoff) < MINMAP)
      return 0;
  }
  else if ((mapsize = pfd->fsize - mapoff) < MINMAP)
    return 0;
  pfd->mapoff  = mapoff;
  pfd->mapsize = mapsize;
  return 1;
}


static int get_obj_info (struct objpriv *pfd)
{
  int      fileno = pfd->fd.fileno;
  OBJINFO *info;

  /* read in the file header and verify magic */

  Alloc (pfd->fhead, sizeof (struct exec));
  if (   (-1 == XC_reads (fileno, pfd->fhead, sizeof (*pfd->fhead)))
      || N_BADMAG (*pfd->fhead)                                      ) {
    XC_errno = NOTANOBJ;
    goto error;
  }
#ifdef DISPLAY
  printf ("*** FILE HEADER ***\n\n");
  printf ("a_dynamic       %d\n", pfd->fhead->a_dynamic);
  printf ("a_toolversion   %d\n", pfd->fhead->a_toolversion);
  printf ("a_machtype      %d\n", pfd->fhead->a_machtype);
  printf ("a_magic         0x%.4x\n", pfd->fhead->a_magic);
  printf ("a_text          0x%.8x\n", pfd->fhead->a_text);
  printf ("a_data          0x%.8x\n", pfd->fhead->a_data);
  printf ("a_bss           0x%.8x\n", pfd->fhead->a_bss);
  printf ("a_syms          0x%.8x\n", pfd->fhead->a_syms);
  printf ("a_entry         0x%.8x\n", pfd->fhead->a_entry);
  printf ("a_trsize        0x%.8x\n", pfd->fhead->a_trsize);
  printf ("a_drsize        0x%.8x\n", pfd->fhead->a_drsize);
#endif

  /* get object's link dynamic if it has one */

  if (pfd->fhead->a_dynamic) {
    int offset = pfd->fd.base + N_DATOFF (*pfd->fhead) +
                       sizeof (struct link_dynamic) + sizeof (struct ld_debug);

    Seek (pfd->fd.fileno, offset, 0);
    Alloc (pfd->ldyn, sizeof (struct link_dynamic_2));
    Reads (pfd->fd.fileno, pfd->ldyn, sizeof (*pfd->ldyn));
  }
#ifdef DISPLAY
  printf ("\n\n\n*** LINK DYNAMIC ***\n\n");
#endif

  /* allocate an info structure and fill in stuff from headers (this is
     returned by a subsequent call to OBJread) */

  Zalloc (info, sizeof (OBJINFO));
  pfd->info       = info;
  info->timestamp = pfd->fd.tstamp;
  info->entry     = pfd->fhead->a_entry;
  if (pfd->fhead->a_magic == ZMAGIC)
    info->flags |= (pfd->fhead->a_entry >= PAGSIZ ? OBJ_EXE : OBJ_SLIB);
  if (info->flags & OBJ_SLIB)
    info->flags |= OBJ_ADJSEG;
  if (pfd->ldyn && pfd->ldyn->ld_need)
    info->flags |= OBJ_DYN;
  if (!pfd->fhead->a_syms)
    info->flags |= OBJ_NSYM;
/*if (!(pfd->fhead->a_trsize + pfd->fhead->a_drsize)) */
  if (info->flags & OBJ_EXE)
    info->flags |= OBJ_NRELOC;
  switch (pfd->fhead->a_magic) {
    case OMAGIC: info->flags |= OBJ_IMPURE; break;
    case NMAGIC: info->flags |= OBJ_SHARED; break;
    case ZMAGIC: info->flags |= OBJ_DEMAND; break;
    default    : XC_errno     = NOTANOBJ;   goto error;
  }

  /* text segment info */

  if (pfd->fhead->a_text) {
    Alloc (info->text, sizeof (SEGMENT));
    if (info->flags & OBJ_EXE)
      info->text->vaddr = N_TXTADDR (*pfd->fhead);
    else info->text->vaddr = 0;
    info->text->size   = pfd->fhead->a_text;
    info->text->faddr  = N_TXTOFF (*pfd->fhead);
    info->text->nscns  = 0;
    info->text->scnptr = 0;
  }

  /* data segment info */

  if (pfd->fhead->a_data) {
    Alloc (info->data, sizeof (SEGMENT));
    if (info->flags & OBJ_EXE)
      info->data->vaddr = N_DATADDR (*pfd->fhead);
    else info->data->vaddr = pfd->fhead->a_text;
    info->data->size   = pfd->fhead->a_data;
    info->data->faddr  = N_DATOFF (*pfd->fhead);
    info->data->nscns  = 0;
    info->data->scnptr = 0;
  }

  /* bss segment info */

  if (pfd->fhead->a_bss) {
    Alloc (info->bss, sizeof (SEGMENT));
    if (info->flags & OBJ_EXE)
      info->bss->vaddr = N_BSSADDR (*pfd->fhead);
    else info->bss->vaddr = pfd->fhead->a_text + pfd->fhead->a_data;
    info->bss->size   = pfd->fhead->a_bss;
    info->bss->faddr  = 0;
    info->bss->nscns  = 0;
    info->bss->scnptr = 0;
  }

  /* return success/failure here */

  return 1;
error:
  return 0;
}


static int get_section_info (struct objpriv *pfd)
{
  SECTION *sect;
  OBJINFO *info  = pfd->info;
  int      nscns = !!info->text + !!info->data + !!info->bss;

  Zalloc (sect, nscns * sizeof (SECTION));
  info->nsects = nscns;
  info->scnptr = sect;

  /* text section */

  if (info->text) {
    sect->name         = ".text";
    sect->size         = info->text->size;
    sect->vaddr        = info->text->vaddr;
    sect->faddr        = info->text->faddr;
    sect->flags        = SCN_TEXT | SCN_READ | SCN_EXE;
    info->text->nscns  = 1;
    info->text->scnptr = sect++;
  }

  /* data section */

  if (info->data) {
    sect->name         = ".data";
    sect->size         = info->data->size;
    sect->vaddr        = info->data->vaddr;
    sect->faddr        = info->data->faddr;
    sect->flags        = SCN_DATA | SCN_READ | SCN_WRITE;
    info->data->nscns  = 1;
    info->data->scnptr = sect++;
  }

  /* bss section */

  if (info->bss) {
    sect->name        = ".bss";
    sect->size        = info->bss->size;
    sect->vaddr       = info->bss->vaddr;
    sect->faddr       = info->bss->faddr;
    sect->flags       = SCN_TEXT | SCN_READ | SCN_WRITE;
    info->bss->nscns  = 1;
    info->bss->scnptr = sect;
  }

  /* return success/failure here */

  return 1;
error:
  return 0;
}


static int mapped_symbols (struct objpriv *pfd)
{
  int symsz;

  /* object file with a _DYNAMIC */

  if (pfd->ldyn) {
    if (symsz = pfd->ldyn->ld_symbols - pfd->ldyn->ld_stab) {
      pfd->symtab  = (struct nlist *)
                           (pfd->mapaddr + (pfd->ldyn->ld_stab - pfd->mapoff));
      pfd->extname = (char *)pfd->symtab + symsz;
    }
  }

  /* normal object file */

  else if (symsz = pfd->fhead->a_syms) {
    pfd->symtab  = (struct nlist *)
                       (pfd->mapaddr + (N_SYMOFF (*pfd->fhead) - pfd->mapoff));
    pfd->extname = (char *)pfd->symtab + symsz;
  }

  return (pfd->nsyms = symsz / sizeof (struct nlist));
}


static int read_symbols (struct objpriv *pfd)
{
  struct nlist *symtab;
  char         *names;
  int           symsz;
  int           strsz;

  /* object file with a _DYNAMIC */

  if (pfd->ldyn) {
    if (symsz = pfd->ldyn->ld_symbols - pfd->ldyn->ld_stab) {
      Seek (pfd->fd.fileno, pfd->fd.base + pfd->ldyn->ld_stab, 0);
      Alloc (symtab, symsz);
      Alloc (names, pfd->ldyn->ld_symb_size);
      Reads (pfd->fd.fileno, symtab, symsz);
      Reads (pfd->fd.fileno, names, pfd->ldyn->ld_symb_size);
      pfd->symtab  = symtab;
      pfd->extname = names;
    }
  }

  /* normal object file */

  else if (symsz = pfd->fhead->a_syms) {
    Seek (pfd->fd.fileno, pfd->fd.base + N_SYMOFF (*pfd->fhead), 0);
    Alloc (symtab, symsz);
    Reads (pfd->fd.fileno, symtab, symsz);
    Reads (pfd->fd.fileno, &strsz, sizeof (strsz));
    Alloc (names, strsz);
    Reads (pfd->fd.fileno, names + sizeof (strsz), strsz - sizeof (strsz));
    *(int *)names = strsz;
    pfd->symtab   = symtab;
    pfd->extname  = names;
  }

  return (pfd->nsyms = symsz / sizeof (struct nlist));
error:
  return -1;
}


static int get_global_symbols (struct objpriv *pfd)
{
  int           nsyms, ngsyms, ndx;
  char         *names;
  void         *ncache;
  struct nlist *symtab, *INsym;
  STE          *OUTsym;

  /* read symbol table if I haven't already done so */

  if (pfd->symtab)
    nsyms = pfd->nsyms;
  else switch (nsyms = (pfd->mapaddr ? mapped_symbols : read_symbols)(pfd)) {
    case -1: goto error;
    case  0: return 1;
    default: break;
  }
  symtab = pfd->symtab;
  names  = pfd->extname;

#ifdef DISPLAY
  { int ndx, cnt = nsyms;
    printf ("\n\n\n*** SYMBOL TABLE ***\n\n");
    printf ("\tn_strx  n_type  n_other  n_desc  n_value\n\n");
    for (ndx = 0; ndx < cnt; ndx++)
      printf ("%d\t%d\t0x%.2x\t0x%.2x\t 0x%.4x  0x%.8x  %s\n",
               ndx,
               symtab[ndx].n_un.n_strx,
               symtab[ndx].n_type,
               symtab[ndx].n_other,
               symtab[ndx].n_desc,
               symtab[ndx].n_value,
               names + symtab[ndx].n_un.n_strx
             );
  }
#endif

  /* count number of global symbols in order to save on memory allocation */
  /**** counts may need doing in read_symbols & mapped_symbols in future ****/

  for (ngsyms = 0, ndx = nsyms, INsym = symtab; ndx--; INsym++)
    if (INsym->n_type & N_EXT)
      ngsyms++;
#if 0
    else if (INsym->n_type & N_STAB)
      if (INsym->n_type == N_SLINE)
           { /* count line number   */ }
      else { /* count debug symbol  */ }
    else   { /* count static symbol */ }
#endif

  /* allocate space for the output symbol table and symbol map then update
     information */

  Alloc (OUTsym, ngsyms * sizeof (STE));
  Zalloc (pfd->symmap, nsyms * sizeof (STE *));
  ncache            = namecache_init (28 * ngsyms, 0);
  pfd->done        |= OBJ_GSYM;
  pfd->info->nsyms  = ngsyms;
  pfd->info->symptr = OUTsym;

  /* process global symbols and construct the symbol map */

  for (ndx = 0, INsym = symtab; ndx < nsyms; INsym++, ndx++) {
    if (INsym->n_type & N_EXT) {
      OUTsym->name= (char *)namecache_add (ncache, names + INsym->n_un.n_strx);
      OUTsym->value = INsym->n_value;
      OUTsym->type  = 0;
      switch (INsym->n_type & ~N_EXT) {
        case N_UNDF: OUTsym->whatis = (INsym->n_value ? SYM_COMM : SYM_EXT);
                     break;
        case N_ABS : OUTsym->whatis = SYM_GLOB | SYM_ABS;             break;
        case N_TEXT: OUTsym->whatis = SYM_GLOB | SYM_TEXT | SYM_FUNC; break;
        case N_DATA: OUTsym->whatis = SYM_GLOB | SYM_DATA | SYM_VAR;  break;
        case N_BSS : OUTsym->whatis = SYM_GLOB | SYM_BSS  | SYM_VAR;  break;
      }
      pfd->symmap[ndx] = OUTsym++;
    }
  }

  /* adjust symbol names to the proper pointers */

  pfd->info->nametbl = namecache_fini (ncache);
  for (OUTsym = pfd->info->symptr; ngsyms--; OUTsym++)
    OUTsym->name = pfd->info->nametbl + (int)OUTsym->name;

  /* return success/failure here */

  return 1;
error:
  return 0;
}


static int mapped_relocs (struct objpriv *pfd, struct reloc_info_sparc **relptr)
{
  int relsize;

  /* object file with a _DYNAMIC */

  if (pfd->ldyn) {
    if (relsize = pfd->ldyn->ld_hash - pfd->ldyn->ld_rel)
      *relptr = (struct reloc_info_sparc *)
                            (pfd->mapaddr + (pfd->ldyn->ld_rel - pfd->mapoff));
  }

  /* normal object file */

  else if (relsize = pfd->fhead->a_trsize + pfd->fhead->a_drsize)
    *relptr = (struct reloc_info_sparc *)
                      (pfd->mapaddr + (N_TRELOFF (*pfd->fhead) - pfd->mapoff));

  /* return info */

  return (relsize / sizeof (struct reloc_info_sparc));
}


static int read_relocs (struct objpriv *pfd, struct reloc_info_sparc **relptr)
{
  struct reloc_info_sparc *relbuff;
  int                      relsize;

  /* object file with a _DYNAMIC */

  if (pfd->ldyn) {
    if (relsize = pfd->ldyn->ld_hash - pfd->ldyn->ld_rel) {
      Seek (pfd->fd.fileno, pfd->fd.base + pfd->ldyn->ld_rel, 0);
      Alloc (relbuff, relsize);
      Reads (pfd->fd.fileno, relbuff, relsize);
    }
  }

  /* normal object file */

  else if (relsize = pfd->fhead->a_trsize + pfd->fhead->a_drsize) {
    Seek (pfd->fd.fileno, pfd->fd.base + N_TRELOFF (*pfd->fhead), 0);
    Alloc (relbuff, relsize);
    Reads (pfd->fd.fileno, relbuff, relsize);
  }

  /* return info */

  *relptr = relbuff;
  return (relsize / sizeof (struct reloc_info_sparc));
error:
  return -1;
}


static int get_reloc_info (struct objpriv *pfd)
{
  OBJINFO                 *info = pfd->info;
  RLOCENT                 *OUTreloc;
  SECTION                 *OUTscn;
  struct reloc_info_sparc *relbuff, *INreloc;
  int                      nrelocs;


  /* read the relocation entries */

  nrelocs = (pfd->mapaddr ? mapped_relocs : read_relocs)(pfd, &relbuff);
  switch (nrelocs) {
    case -1: goto error;
    case  0: return 1;
    default: break;
  }
#ifdef DISPLAY
  { int ndx, cnt = relsz / sizeof (struct reloc_info_sparc);
    printf ("\n\n\n*** RELOCATION ENTRIES ***\n\n");
    printf ("r_address   r_index  r_extern  r_type  r_addend\n\n");
    for (ndx = 0; ndx < cnt; ndx++)
      printf ("0x%.8x  %d\t\t %d\t0x%.2x\t%d\t%s\n",
               relbuff[ndx].r_address,
               relbuff[ndx].r_index,
               relbuff[ndx].r_extern,
               relbuff[ndx].r_type,
               relbuff[ndx].r_addend,
               (relbuff[ndx].r_extern
                 ? pfd->extname + pfd->symtab[relbuff[ndx].r_index].n_un.n_strx
                 : "" )
             );
  }
#endif

  /* generate auxiliary symbols used for internal relocs */

  if (!make_aux (info))
    goto error;

  /* construct relocation table to return */

  Alloc (info->relocptr, (info->nrelocs = nrelocs) * sizeof (RLOCENT));
  OUTscn   = info->scnptr;
  OUTreloc = info->relocptr;
  INreloc  = relbuff;
  for (; nrelocs--; INreloc++, OUTreloc++) {

    /* adjust section information */

    while (INreloc->r_address > OUTscn->vaddr + OUTscn->size)
      OUTscn++;
    if (!OUTscn->relocptr)
      OUTscn->relocptr = OUTreloc;
    OUTscn->nrelocs++;

    /* relocation type and address */

    OUTreloc->rtype = INreloc->r_type;
    if (info->flags & (OBJ_EXE | OBJ_SLIB))
      OUTreloc->addr = INreloc->r_address;
    else OUTreloc->addr = INreloc->r_address + OUTscn->vaddr;

    /* symbol and addend (external reloc) */

    if (INreloc->r_extern) {
      OUTreloc->symbol = pfd->symmap[INreloc->r_index];
      if (OUTreloc->rtype == R_SPARC_JMP_SLOT)
        OUTreloc->addend = 0;
      else OUTreloc->addend = INreloc->r_addend;
    }

    /* symbol and addend (internal reloc) */

    else if (info->flags & OBJ_SLIB) {
      OUTreloc->symbol = info->auxsym;    /* use sym w/ value=0 always? */
      OUTreloc->addend = 0;
    }
    else {
      SECTION *refscn;
      switch (INreloc->r_index) {
        case 0     : refscn = info->scnptr;       break; /* do I need this? */
        case N_TEXT: refscn = info->text->scnptr; break;
        case N_DATA: refscn = info->data->scnptr; break;
        case N_BSS : refscn = info->bss->scnptr;  break;
        default:
          printf ("OBJread:  Unknown local reloc \"r_index\":  %d\n",
							INreloc->r_index);
          continue;
      }
      OUTreloc->symbol = refscn->auxsym;
      OUTreloc->addend = INreloc->r_addend - refscn->vaddr;
    }
  }

  /* return success/failure here */

  pfd->done |= OBJ_RELOC;
  if (!pfd->mapaddr)
    free (relbuff);
  return 1;
error:
  return 0;
}

static int free_machine_data (struct objpriv *pfd)
{
  if (pfd->fhead)   free (pfd->fhead);
  if (pfd->ldyn)    free (pfd->ldyn);
  if (pfd->symmap)  free (pfd->symmap);
  if (pfd->mapaddr)
    XC_munmap (pfd->mapaddr, pfd->mapsize);
  else {
    if (pfd->symtab)  free (pfd->symtab);
    if (pfd->extname) free (pfd->extname);
  }

  return 1;
}
#endif

/*****************************************************************************/
/*									     */
/*  Machines:	Control Data Cyber 910		Processor:  MIPS R3000       */
/*		Silicon Graphics Iris Indigo				     */
/*									     */
/*  Operating System:  IRIX						     */
/*									     */
/*****************************************************************************/
#if (IRIX && SVR3)

static int is_archive (struct objpriv *pfd)
{
  char archeck[SARMAG];

  /* do I want to read in any archive headers here? */

  if (   (read (pfd->fd.fileno, archeck, SARMAG) == SARMAG)
      && (strncmp (archeck, ARMAG, SARMAG) == 0)            ) {
    return pfd->fd.arch = 1;
  }
  return 0;
}


static int get_map_params (struct objpriv *pfd)
{
  static uint pagesz = 0;
  uint        mapoff;
  uint        mapsize;

  /* determine map offset */

  if (pfd->reloc_off)
    mapoff = pfd->reloc_off;
  else if (pfd->fhead->f_symptr)
    mapoff = pfd->fhead->f_symptr;
  else return 0;

  /* determine map size */

  if (!pagesz)
    pagesz = getpagesize ();
  mapoff = TRUNC (pfd->fd.base + mapoff, pagesz) - pfd->fd.base;
  if ((mapsize = pfd->fsize - mapoff) < MINMAP)
    return 0;
  pfd->mapoff  = mapoff;
  pfd->mapsize = mapsize;
  return 1;
}


static SECTION *find_scn_by_flags (struct objpriv *pfd, int flag)
{
  struct scnhdr *INscn = pfd->shead;
  int            cnt   = pfd->fhead->f_nscns;

  for (; cnt--; INscn++)
    if (INscn->s_flags & flag)
      return pfd->info->scnptr + (INscn - pfd->shead);
  return 0;
}


static int get_obj_info (struct objpriv *pfd)
{
  int            cnt, fileno = pfd->fd.fileno;
  uint           rawoff;
  OBJINFO       *info;
  struct scnhdr *INscn;
  
  /* read in the file header and verify magic */

  Alloc (pfd->fhead, sizeof (struct filehdr));
  if (   (-1 == XC_reads (fileno, pfd->fhead, sizeof (*pfd->fhead)))
      || pfd->fhead->f_magic != MIPSEBMAGIC                          ) {
    XC_errno = NOTANOBJ;
    goto error;
  }

  /* read in the system header */

  Alloc (pfd->ohead, sizeof (struct aouthdr));
  Reads (fileno, pfd->ohead, sizeof (*pfd->ohead));

  /* read in the section headers */
  
  Alloc (pfd->shead, pfd->fhead->f_nscns * sizeof (struct scnhdr));
  Reads (fileno, pfd->shead, pfd->fhead->f_nscns * sizeof (*pfd->shead));
  
  /* read in the symbolic header */

  if (pfd->fhead->f_symptr) {
    Alloc (pfd->symhdr, sizeof (HDRR));
    Seek (pfd->fd.fileno, pfd->fd.base + pfd->fhead->f_symptr, 0);
    Reads (pfd->fd.fileno, pfd->symhdr, sizeof (HDRR));
  }

  /* determine file offset to relocation entries and GP table */

  for (INscn = pfd->shead, cnt = pfd->fhead->f_nscns; cnt--; INscn++) {
    if (!pfd->reloc_off && INscn->s_relptr)
      pfd->reloc_off = INscn->s_relptr;
    if (!pfd->gptbl_off && INscn->s_lnnoptr)
      pfd->gptbl_off = INscn->s_lnnoptr;
  }

  /* allocate an info structure and fill in stuff from headers (this is
     returned by a subsequent call to OBJread) */

  Zalloc (info, sizeof (OBJINFO));
  pfd->info       = info;
  info->timestamp = pfd->fhead->f_timdat;
  info->entry     = pfd->ohead->entry;
  if (pfd->fhead->f_flags & F_EXEC && pfd->ohead->magic == ZMAGIC)
    info->flags |= OBJ_EXE;
  if (pfd->ohead->magic == LIBMAGIC)
    info->flags |= OBJ_SLIB;
  if (!pfd->fhead->f_symptr)
    info->flags |= OBJ_NSYM;
  if (pfd->fhead->f_flags & F_RELFLG)
    info->flags |= OBJ_NRELOC;
  switch (pfd->ohead->magic) {
    case OMAGIC  : info->flags |= OBJ_IMPURE; break;
    case NMAGIC  : info->flags |= OBJ_SHARED; break;
    case LIBMAGIC:
    case ZMAGIC  : info->flags |= OBJ_DEMAND; break;
    default      : XC_errno     = NOTANOBJ;   goto error;
  }

  /* text segment info */

  rawoff = N_TXTOFF (*pfd->fhead, *pfd->ohead);
  if (pfd->fhead->f_flags & F_EXEC && pfd->ohead->magic == OMAGIC)
    rawoff = (rawoff + 15) & 0xfffffff0;
  if (pfd->ohead->tsize) {
    Alloc (info->text, sizeof (SEGMENT));
    info->text->faddr  = rawoff;
    info->text->vaddr  = pfd->ohead->text_start;
    info->text->nscns  = 0;
    info->text->scnptr = 0;
    rawoff += (info->text->size = pfd->ohead->tsize);
  }

  /* data segment info */

  if (pfd->ohead->dsize) {
    Alloc (info->data, sizeof (SEGMENT));
    info->data->faddr  = rawoff;
    info->data->vaddr  = pfd->ohead->data_start;
    info->data->nscns  = 0;
    info->data->scnptr = 0;
    info->data->size   = pfd->ohead->dsize;
  }

  /* bss segment */

  if (pfd->ohead->bsize) {
    Alloc (info->bss, sizeof (SEGMENT));
    info->bss->faddr  = 0;
    info->bss->vaddr  = pfd->ohead->bss_start;
    info->bss->nscns  = 0;
    info->bss->scnptr = 0;
    info->bss->size   = pfd->ohead->bsize;
  }

  /* return success/failure here */

  return 1;
error:
  return 0;
}


static int get_section_info (struct objpriv *pfd)
{
  int            cnt   = pfd->fhead->f_nscns;
  OBJINFO       *info  = pfd->info;
  struct scnhdr *INscn = pfd->shead;
  SECTION       *OUTscn;

  Zalloc (OUTscn, cnt * sizeof (SECTION));
  info->nsects = cnt;
  info->scnptr = OUTscn;
  pfd->done   |= OBJ_SCN;

  for (; cnt--; INscn++, OUTscn++) {
    OUTscn->name     = stralloc (INscn->s_name);   /* later:  use name-cache */
    OUTscn->size     = INscn->s_size;
    OUTscn->faddr    = INscn->s_scnptr;
    OUTscn->vaddr    = INscn->s_vaddr;
    if (INscn->s_flags & (STYP_TEXT | STYP_INIT | STYP_FINI)) {
      if (!info->text->scnptr)
        info->text->scnptr = OUTscn;
      info->text->nscns++;
      OUTscn->flags = SCN_TEXT | SCN_READ | SCN_EXE;
    }
    else if (INscn->s_flags & (STYP_DATA | STYP_RDATA | STYP_SDATA | STYP_LIT4 | STYP_LIT8)) {
      if (!info->data->scnptr)
        info->data->scnptr = OUTscn;
      info->data->nscns++;
      if (INscn->s_flags & (STYP_RDATA | STYP_LIT4 | STYP_LIT8))
        OUTscn->flags = SCN_DATA | SCN_READ;
      else OUTscn->flags = SCN_DATA | SCN_READ | SCN_WRITE;
    }
    else if (INscn->s_flags & (STYP_BSS | STYP_SBSS)) {
      if (info->bss) {
        if (!info->bss->scnptr)
          info->bss->scnptr = OUTscn;
        info->bss->nscns++;
      }
      OUTscn->flags = SCN_BSS | SCN_READ | SCN_WRITE;
    }
    else OUTscn->flags = SCN_INFO | SCN_NRES;
  }

  /* return success/failure here */

  return 1;
error:
  return 0;
}


static int mapped_symbols (struct objpriv *pfd, EXTR **symptr, char **nameptr)
{
  if (!pfd->symhdr || !pfd->symhdr->iextMax)
    return 0;

  /* external symbol table and external name table */

  *symptr  = (EXTR *)(pfd->mapaddr + (pfd->symhdr->cbExtOffset - pfd->mapoff));
  *nameptr = pfd->mapaddr + (pfd->symhdr->cbSsExtOffset - pfd->mapoff);
  return pfd->symhdr->iextMax;
}


static int read_symbols (struct objpriv *pfd, EXTR **symptr, char **nameptr)
{
  EXTR *symtab;
  char *names;
  int   nsyms;

  if (!pfd->symhdr || !(nsyms = pfd->symhdr->iextMax))
    return 0;

  /* external symbol table and external name table */

  Alloc (symtab, nsyms * sizeof (EXTR));
  Seek (pfd->fd.fileno, pfd->fd.base + pfd->symhdr->cbExtOffset, 0);
  Reads (pfd->fd.fileno, symtab, nsyms * sizeof (EXTR));
  Alloc (names, pfd->symhdr->issExtMax);
  Seek (pfd->fd.fileno, pfd->fd.base + pfd->symhdr->cbSsExtOffset, 0);
  Reads (pfd->fd.fileno, names, pfd->symhdr->issExtMax);

  *symptr  = symtab;
  *nameptr = names;
  return nsyms;
error:
  return -1;
}


static int get_global_symbols (struct objpriv *pfd)
{
  int   nsyms;
  char *names;
  EXTR *symtab, *INsym;
  STE  *OUTsym;

  /* read the global symbol table */

  nsyms = (pfd->mapaddr ? mapped_symbols : read_symbols)(pfd, &symtab, &names);
  switch (nsyms) {
    case -1: goto error;
    case  0: return 1;
    default: break;
  }

  /* namecache not needed since no other symbols are mixed with globals */

  if (pfd->mapaddr) {
    char *temp = names;
    Alloc (names, pfd->symhdr->issExtMax);
    memcpy (names, temp, pfd->symhdr->issExtMax);
  }

  /* allocate space for the output symbol table and update information */

  Alloc (OUTsym, nsyms * sizeof (STE));
  pfd->done         |= OBJ_GSYM;
  pfd->info->nsyms   = nsyms;
  pfd->info->symptr  = OUTsym;
  pfd->info->nametbl = names;

  /* process global symbols (no symbol map is needed due to one-to-one
     correspondance between input and output symbols) */

  for (INsym = symtab; nsyms--; INsym++, OUTsym++) {
    OUTsym->name  = names + INsym->asym.iss;
    OUTsym->value = INsym->asym.value;
    OUTsym->type  = 0;

    /* flags derived from symbol type */

    switch (INsym->asym.st) {
      case stNil   : OUTsym->whatis = SYM_NIL;             break;
      case stGlobal: OUTsym->whatis = SYM_GLOB | SYM_VAR;  break;
      case stLabel : OUTsym->whatis = SYM_GLOB | SYM_LAB;  break;
      case stProc  : OUTsym->whatis = SYM_GLOB | SYM_FUNC; break;
      default:
        printf ("OBJread:  Unexpected symbol type (%d) for external %s.\n",
						 INsym->asym.st, OUTsym->name);
    }

    /* flags derived from storage class */

    switch (INsym->asym.sc) {
      case scText      :
      case scInit      :
      case scFini      : OUTsym->whatis |= SYM_TEXT; break;
      case scData      :
      case scSData     :
      case scRData     : OUTsym->whatis |= SYM_DATA; break;
      case scBss       :
      case scSBss      : OUTsym->whatis |= SYM_BSS;  break;
      case scAbs       : OUTsym->whatis |= SYM_ABS;  break;
      case scCommon    : OUTsym->whatis  = SYM_COMM; break;
      case scUndefined :
      case scSUndefined: OUTsym->whatis  = SYM_EXT;  break;
      case scNil       : OUTsym->whatis  = SYM_NIL;  break;
      default:
        printf ("OBJread:  Unexpected storage class (%d) for external %s.\n",
                                                  INsym->asym.sc, OUTsym->name);
        break;
    }
  }

  /* return success/failure here */

  if (!pfd->mapaddr)
    free (symtab);
  return 1;
error:
  return 0;
}


static int mapped_relocs (struct objpriv *pfd, struct reloc **relptr)
{
  int relsize;

  /* determine size of relocation table */

  if (!pfd->reloc_off)
    return 0;
  if (pfd->gptbl_off)
    relsize = pfd->gptbl_off - pfd->reloc_off;
  else if (pfd->fhead->f_symptr)
    relsize = pfd->fhead->f_symptr - pfd->reloc_off;
  else relsize = pfd->fsize - pfd->reloc_off;

  /* return info */

  *relptr = (struct reloc *)(pfd->mapaddr + (pfd->reloc_off - pfd->mapoff));
  return (relsize / RELSZ);
}


static int read_relocs (struct objpriv *pfd, struct reloc **relptr)
{
  struct reloc *relbuff;
  int           relsize;

  /* determine size of relocation table */

  if (!pfd->reloc_off)
    return 0;
  if (pfd->gptbl_off)
    relsize = pfd->gptbl_off - pfd->reloc_off;
  else if (pfd->fhead->f_symptr)
    relsize = pfd->fhead->f_symptr - pfd->reloc_off;
  else relsize = pfd->fsize - pfd->reloc_off;

  /* read the relocation table */

  Alloc (relbuff, relsize);
  Seek (pfd->fd.fileno, pfd->fd.base + pfd->reloc_off, 0);
  Reads (pfd->fd.fileno, relbuff, relsize);

  /* return info */

  *relptr = relbuff;
  return (relsize / RELSZ);
error:
  return -1;
}


static int get_reloc_info (struct objpriv *pfd)
{
  OBJINFO       *info = pfd->info;
  int            nrelocs, Scnt, Rcnt;
  SECTION      **scnmap;
  struct reloc  *relbuff;
  struct reloc  *INreloc;
  RLOCENT       *OUTreloc;

  /* read the relocation entries */

  nrelocs = (pfd->mapaddr ? mapped_relocs : read_relocs)(pfd, &relbuff);
  switch (nrelocs) {
    case -1: goto error;
    case  0: return 1;
    default: break;
  }

  /* generate auxiliary symbols used for internal relocs */

  if (!make_aux (info))
    goto error;

  /* construct a section map for easy conversion from the section number given
     by the input reloc to the symbol we'll be using */

  Alloc (scnmap, (MAX_R_SN + 1) * sizeof (SECTION *));
  scnmap[R_SN_TEXT]  = find_scn_by_flags (pfd, STYP_TEXT);
  scnmap[R_SN_RDATA] = find_scn_by_flags (pfd, STYP_RDATA);
  scnmap[R_SN_DATA]  = find_scn_by_flags (pfd, STYP_DATA);
  scnmap[R_SN_SDATA] = find_scn_by_flags (pfd, STYP_SDATA);
  scnmap[R_SN_SBSS]  = find_scn_by_flags (pfd, STYP_SBSS);
  scnmap[R_SN_BSS]   = find_scn_by_flags (pfd, STYP_BSS);
  scnmap[R_SN_INIT]  = find_scn_by_flags (pfd, STYP_INIT);
  scnmap[R_SN_LIT8]  = find_scn_by_flags (pfd, STYP_LIT8);
  scnmap[R_SN_LIT4]  = find_scn_by_flags (pfd, STYP_LIT4);
  scnmap[R_SN_XDATA] = find_scn_by_flags (pfd, STYP_XDATA);
  scnmap[R_SN_PDATA] = find_scn_by_flags (pfd, STYP_PDATA);
  scnmap[R_SN_FINI]  = find_scn_by_flags (pfd, STYP_FINI);

  /* construct relocation table to return */

  Alloc (info->relocptr, (info->nrelocs = nrelocs) * sizeof (RLOCENT));
  OUTreloc = info->relocptr;
  INreloc  = relbuff;
  for (Scnt = 0; Scnt < info->nsects; Scnt++) {

    /* determine number relocs for current section:  if the S_NRELOC_OVFL
       flag is set in the section header, then the field "s_nreloc" has
       overflowed in which case the correct value is stored in the first
       reloc entry's "r_vaddr" field (we do not want to return these to
       the user!) */

    if (pfd->shead[Scnt].s_flags & S_NRELOC_OVFL) {
      Rcnt = (INreloc++)->r_vaddr - 1;
      info->nrelocs--;
    }
    else Rcnt = pfd->shead[Scnt].s_nreloc;
    if (!Rcnt)
      continue;
    info->scnptr[Scnt].relocptr = OUTreloc;
    info->scnptr[Scnt].nrelocs  = Rcnt;

    /* process relocs for this section */
    
    for (; Rcnt--; INreloc++, OUTreloc++) {
      if (!(OUTreloc->rtype = INreloc->r_type)) {
        info->nrelocs--;
        info->scnptr[Scnt].nrelocs--;
        OUTreloc--;
        continue;
      }
      OUTreloc->addr  = INreloc->r_vaddr;
      if (INreloc->r_extern) {
        OUTreloc->symbol = info->symptr + INreloc->r_symndx;
        OUTreloc->addend = 0;
      }
      else {
        OUTreloc->symbol = scnmap[INreloc->r_symndx]->auxsym;
        OUTreloc->addend = - OUTreloc->symbol->value;
        if (OUTreloc->rtype == R_MIPS_JMPADDR)
          OUTreloc->addend += (OUTreloc->addr & 0xf0000000);
      }
    }
  }

  /* return success/failure here */

  pfd->done |= OBJ_RELOC;
  if (!pfd->mapaddr)
    free (relbuff);
  free (scnmap);
  return 1;
error:
  return 0;
}

static int free_machine_data (struct objpriv *pfd)
{
  if (pfd->fhead)  free (pfd->fhead);
  if (pfd->ohead)  free (pfd->ohead);
  if (pfd->shead)  free (pfd->shead);
  if (pfd->symhdr) free (pfd->symhdr);
  if (pfd->mapaddr)
    XC_munmap (pfd->mapaddr, pfd->mapsize);

  return 1;
}
#endif

#if SVR4
#define  N_BADMAG(hdr)  (strncmp ((char *)(hdr).e_ident, ELFMAG, SELFMAG) != 0)

#if DISPLAY
static char *ETtype[] = {
		"ET_NONE", "ET_REL", "ET_EXEC", "ET_DYN", "ET_CORE"
};
static char *PTtype[] = {
		"PT_NULL", "PT_LOAD", "PT_DYNAMIC", "PT_INTERP",
		"PT_NOTE", "PT_SHLIB", "PT_PHDR"
#if IRIX
		,"PT_REGINFO", "PT_RTPROC"
#endif
};
static char *SHTtype[] = {
		"SHT_NULL", "SHT_PROGBITS", "SHT_SYMTAB", "SHT_STRTAB",
		"SHT_RELA", "SHT_HASH", "SHT_DYNAMIC", "SHT_NOTE",
		"SHT_NOBITS", "SHT_REL", "SHT_SHLIB", "SHT_DYNSYM"
#if IRIX
		,"SHT_LIBLIST", "SHT_MSYM", "SHT_CONFLICT", "SHT_GPTAB",
		"SHT_UCODE", "SHT_DEBUG", "SHT_REGINFO", "SHT_PACKAGE",
		"SHT_PACKSYM", "SHT_RELD", "SHT_EVENTS", "SHT_IFACE",
		"SHT_CONTENT", "SHT_OPTIONS", 0, 0, "SHT_SHDR",
		"SHT_FDESC", "SHT_EXTSYM", "SHT_DENSE", "SHT_PDESC",
		"SHT_LOCSYM", "SHT_AUXSYM", "SHT_OPTSYM", "SHT_LOCSTR",
		"SHT_LINE", "SHT_FRDESC", "SHT_DELTASYM", "SHT_DELTAINST",
		"SHT_DELTACLASS"
#endif
};
static char *DTtype[] = {
		"DT_NULL", "DT_NEEDED", "DT_PLTRELSZ", "DT_PLTGOT",
		"DT_HASH", "DT_STRTAB", "DT_SYMTAB", "DT_RELA",
		"DT_RELASZ", "DT_RELAENT", "DT_STRSZ", "DT_SYMENT",
		"DT_INIT", "DT_FINI", "DT_SONAME", "DT_RPATH",
		"DT_SYMBOLIC", "DT_REL", "DT_RELSZ", "DT_RELENT",
		"DT_PLTREL", "DT_DEBUG", "DT_TEXTREL", "DT_JMPREL"
#if IRIX_5x
		,0 ,"DT_RLD_VERSION", "DT_TIME_STAMP", "DT_ICHECKSUM",
		"DT_IVERSION", "DT_FLAGS", "DT_BASE_ADDRESS", "DT_MSYM",
		"DT_CONFLICT", "DT_LIBLIST", "DT_LOCAL_GOTNO",
		"DT_CONFLICTNO", 0, 0, 0, 0, "DT_LIBLISTNO", "DT_SYMTABNO",
		"DT_UNREFEXTNO", "DT_GOTSYM", "DT_HIPAGENO", 0,
		"DT_RLD_MAP", "DT_DELTA_CLASS", "DT_DELTA_CLASS_NO",
		"DT_DELTA_INSTANCE", "DT_DELTA_INSTANCE_NO", "DT_DELTA_RELOC",
		"DT_DELTA_RELOC_NO", "DT_DELTA_SYM", "DT_DELTA_SYM_NO", 0,
		"DT_DELTA_CLASSSYM", "DT_DELTA_CLASSSYM_NO"
#endif
#if SunOS_5x
                ,"DT_SECTION", "DT_FILTER"
#endif
};
static char *STBtype[] = { "LOCAL", "GLOBAL", "WEAK" };
static char *STTtype[] = { "NONE", "OBJECT", "FUNC", "SECTION", "FILE" };
#endif

static int is_archive (struct objpriv *pfd)
{
#if 0
  char archeck[SARMAG];

  /* do I want to read in any archive headers here? */

  if (   (read (pfd->fd.fileno, archeck, SARMAG) == SARMAG)
      && (strncmp (archeck, ARMAG, SARMAG) == 0)            ) {
    return pfd->fd.arch = 1;
  }
#endif
  return 0;
}


static Elf32_Dyn *find_dynamic (Elf32_Dyn *ldyn, int tag)
{
  if (ldyn)  
    for (; ldyn->d_tag; ldyn++)
      if (ldyn->d_tag == tag)
        return ldyn;
  return 0;
}


static Elf32_Shdr *find_scn_by_name (struct objpriv *pfd, char *name)
{
  Elf32_Shdr *scn = pfd->shead;
  int         cnt = pfd->fhead->e_shnum;

  for (; cnt--; scn++)
    if (0 == strcmp (pfd->scnname + scn->sh_name, name))
      return scn;
  return 0;
}


static void *loadscn (struct objpriv *pfd, Elf32_Shdr *scn)
{
  void *buffer;

  if ((scn->sh_type == SHT_NOBITS) || !scn->sh_size)
    return 0;
  buffer = getdata (pfd->fd.fileno, pfd->fd.base + scn->sh_offset,
							      scn->sh_size, 1);
  return (buffer ? buffer : (void *)-1);
}


static int load_symbols (struct objpriv *pfd)
{
  Elf32_Shdr *symscn;

  if (!(symscn = find_scn_by_name (pfd, (pfd->ldyn ? ".dynsym" : ".symtab"))))
    return 1;
  pfd->symtab  = loadscn (pfd, symscn);
  pfd->extname = loadscn (pfd, pfd->shead + symscn->sh_link);
  pfd->nsyms   = symscn->sh_size / sizeof (Elf32_Sym);

  /* symbol index translation data */

#if LOCAL_SYMS_FIRST
  pfd->globndx = symscn->sh_info;
#else
  Zalloc (pfd->symmap, pfd->nsyms * sizeof (STE *));
#endif

#if DISPLAY
  { int        cnt = pfd->nsyms;
    Elf32_Sym *sym = pfd->symtab;

    printf ("\n\n\n\t\t*** SYMBOL TABLE ***\n\n");
    printf ("\nshndx    other        info           size       value\n\n");
    for (; cnt--; sym++)
      printf ("%5d%7d%5d %-7s%-9s0x%.8x  0x%.8x  %s\n",
               sym->st_shndx,
               sym->st_other,
               sym->st_info,
               STBtype[ELF32_ST_BIND (sym->st_info)],
               STTtype[ELF32_ST_TYPE (sym->st_info)],
               sym->st_size,
               sym->st_value,
               pfd->extname + sym->st_name
             );
  }
#endif

  return 1;
error:
  return 0;
}


static int get_global_symbols (struct objpriv *pfd)
{
  int         nsyms, ngsyms, cnt;
  void       *ncache;
  char       *names;
  Elf32_Sym  *symtab, *INsym;
  STE        *OUTsym;
  OBJINFO    *info = pfd->info;

  /* read symbol table if I haven't already done so */

  if (!pfd->symtab && !load_symbols (pfd))
    goto error;
  if (!(nsyms = pfd->nsyms))
    return 1;
  symtab = pfd->symtab;
  names  = pfd->extname;

  /* count number of global symbols in order to save on memory allocation */

#if LOCAL_SYMS_FIRST
  ngsyms = cnt = nsyms - pfd->globndx;
  INsym  = symtab + pfd->globndx;
#else
  for (ngsyms = 0, cnt = nsyms, INsym = symtab; cnt--; INsym++)
    switch (ELF32_ST_BIND (INsym->st_info)) {
      case STB_WEAK  :
      case STB_GLOBAL: ngsyms++;
      default        : break;
    }
  cnt   = nsyms;
  INsym = symtab;
#endif

  /* allocate space for the output symbol table and then update information */

  Alloc (OUTsym, ngsyms * sizeof (STE));
  ncache       = namecache_init (28 * ngsyms, 0);
  pfd->done   |= OBJ_GSYM;
  info->nsyms  = ngsyms;
  info->symptr = OUTsym;

  /* construct global symbol table to return */

  for (; cnt--; INsym++) {

    /* binding attributes */

    switch (ELF32_ST_BIND (INsym->st_info)) {
      case STB_WEAK  : OUTsym->whatis = SYM_WEAK; break;
      case STB_GLOBAL: OUTsym->whatis = SYM_GLOB; break;
      default        : continue;
    }

    /* type attributes */

    switch (ELF32_ST_TYPE (INsym->st_info)) {
      case STT_OBJECT : OUTsym->whatis |= SYM_VAR;  break;
      case STT_FUNC   : OUTsym->whatis |= SYM_FUNC; break;
      default         : OUTsym->whatis |= SYM_LAB;  break;
    }

    /* allocation attributes */

    switch (INsym->st_shndx) {
      case SHN_UNDEF : OUTsym->whatis  = SYM_EXT;  break;
      case SHN_COMMON: OUTsym->whatis  = SYM_COMM; break;
      case SHN_ABS   : OUTsym->whatis |= SYM_ABS;  break;
#if IRIX_5x
      case SHN_MIPS_ACOMMON   : OUTsym->whatis |= SYM_BSS;  break;
      case SHN_MIPS_TEXT      : OUTsym->whatis |= SYM_TEXT; break;
      case SHN_MIPS_DATA      : OUTsym->whatis |= SYM_DATA; break;
      case SHN_MIPS_SCOMMON   : OUTsym->whatis  = SYM_COMM; break;
      case SHN_MIPS_SUNDEFINED: OUTsym->whatis  = SYM_EXT;  break;
#endif
      default: {
        Elf32_Shdr *scn = pfd->shead + INsym->st_shndx;

        /* determine which segment the symbol belongs to */

        if (scn->sh_flags & SHF_TEXT)
          OUTsym->whatis |= SYM_TEXT;
        else if (scn->sh_flags & SHF_DATA)
          OUTsym->whatis |= SYM_DATA;
        else if (scn->sh_flags & SHF_BSS)
          OUTsym->whatis |= SYM_BSS;
        else OUTsym->whatis |= SYM_ABS;
        break;
      }
    }

    /* name, value, and type */

    if (OUTsym->whatis & SYM_COMM)
      OUTsym->value = INsym->st_size;
    else OUTsym->value = INsym->st_value;
    OUTsym->name = (char *)namecache_add (ncache, names + INsym->st_name);
    OUTsym->type = 0;

    /* symbol map entry (if needed) */

#if !LOCAL_SYMS_FIRST
    pfd->symmap[INsym - symtab] =
#endif
    OUTsym++;
  }

  /* adjust symbol names to the proper pointers */

  pfd->info->nametbl = namecache_fini (ncache);
  for (OUTsym = pfd->info->symptr; ngsyms--; OUTsym++)
    OUTsym->name = pfd->info->nametbl + (int)OUTsym->name;

  /* return success/failure here */

  return 1;
error:
  return 0;
}

#if !RELOC_ONE_TYPE
#error Multiple ELF reloc types in one file not currently implemented!
#elif RELOC_ONE_TYPE == SHT_RELA
#define  RELOCSZ  sizeof (Elf32_Rela)
#else
#define  RELOCSZ  sizeof (Elf32_Rel)
#endif

static int load_relocs (struct objpriv *pfd)
{
#if RELOCS_GROUPED
  int         offset = 0;
#endif
  int         cnt, total = 0;
  Elf32_Shdr *Rhdr;

  /* under IRIX 5.x (Silicon Graphics) shared library relocations do not
     follow the SVR4 ABI specification and hence require special handling */

#if IRIX_5x
  if (pfd->info->flags & OBJ_SLIB) {
    Elf32_Shdr *datascn = find_scn_by_name (pfd, ".data");
    SECTION    *scn;

    if (!datascn || !(Rhdr = find_scn_by_name (pfd, ".rel.dyn")))
      return 0;
    scn           = pfd->scnmap[datascn - pfd->shead];
    scn->relocptr = loadscn (pfd, Rhdr);
    scn->nrelocs  = total = Rhdr->sh_size / RELOCSZ;
    goto display;
  }
#endif

  for (Rhdr = pfd->shead, cnt = pfd->fhead->e_shnum; cnt--; Rhdr++)
    if (Rhdr->sh_type == RELOC_ONE_TYPE) {
      int      nrelocs = Rhdr->sh_size / RELOCSZ;
      SECTION *scn     = pfd->scnmap[Rhdr->sh_info];

      total        += nrelocs;
      scn->nrelocs  = nrelocs;
#if RELOCS_GROUPED
      if (!offset)
        offset = pfd->fd.base + Rhdr->sh_offset;
#else
      scn->relocptr = loadscn (pfd, Rhdr);
#endif
    }

#if RELOCS_GROUPED
  { char *buffer = getdata (pfd->fd.fileno, offset, total * RELOCSZ, 1);

    offset = 0;
    for (Rhdr = pfd->shead, cnt = pfd->fhead->e_shnum; cnt--; Rhdr++)
      if (Rhdr->sh_type == RELOC_ONE_TYPE) {
        SECTION *scn  = pfd->scnmap[Rhdr->sh_info];
        scn->relocptr = (RLOCENT *)(buffer + offset);
        offset       += Rhdr->sh_size;
      }
  }
#endif

display:
#if DISPLAY
  { SECTION *scn = pfd->info->scnptr;
    int      cnt1, cnt2;

    printf ("\n\n\n\t\t*** RELOCATION ENTRIES ***\n\n");
    printf ("offset  type  addend  symbol\n\n");
    for (cnt1 = pfd->info->nsects; cnt1--; scn++) {
      Elf32_Rela *reloc = (Elf32_Rela *)scn->relocptr;

      printf ("%s:\n", scn->name);
      for (cnt2 = scn->nrelocs; cnt2--; ) {
        printf ( "\t0x%.8x  %3d  %11d  %s\n",
                 reloc->r_offset,
                 ELF32_R_TYPE (reloc->r_info),
#if RELOC_ONE_TYPE == SHT_RELA
                 reloc->r_addend,
#else
                 0,
#endif
                 pfd->extname + pfd->symtab[ELF32_R_SYM (reloc->r_info)].st_name
               );
        reloc = (Elf32_Rela *)((char *)reloc + RELOCSZ);
      }
    }
  }
#endif

  /* return success/failure here */

  return total;
error:
  return -1;
}


static int get_reloc_info (struct objpriv *pfd)
{
  OBJINFO *info = pfd->info;
  SECTION *scn;
  RLOCENT *OUTreloc;
  int      nrelocs;
  int      cnt1, cnt2;

  /* load relocation entries from the file */

#if IRIX_5x
  if (!(nrelocs = load_relocs (pfd)) && !(info->flags & OBJ_SLIB))
#else
  if (!(nrelocs = load_relocs (pfd)))
#endif
    return 1;

  /* generate auxiliary symbols used for internal relocs */

  if (!make_aux (info))
    goto error;

  /* generate relocation entries for the Global Offset Table */

#if IRIX_5x
  if (info->flags & OBJ_SLIB) {
    Elf32_Shdr *gotscn = find_scn_by_name (pfd, ".got");
    uint        addr;
    int         ndx;

    cnt1 = (find_dynamic (pfd->ldyn, DT_MIPS_LOCAL_GOTNO))->d_un.d_val - 1;
    ndx  = (find_dynamic (pfd->ldyn, DT_MIPS_GOTSYM))->d_un.d_val;
    cnt2 = pfd->nsyms - ndx;
    nrelocs += (cnt1 + cnt2);
    Alloc (info->relocptr, (info->nrelocs = nrelocs) * sizeof (RLOCENT));

    /* local GOT relocs */

    addr = gotscn->sh_addr + 4;
    for (OUTreloc = info->relocptr; cnt1--; OUTreloc++, addr += 4) {
      OUTreloc->rtype  = R_MIPS_REL32;
      OUTreloc->addr   = addr;
      OUTreloc->symbol = info->auxsym;
      OUTreloc->addend = - info->base;
    }

    /* global GOT relocs */

    for (; cnt2--; OUTreloc++, ndx++, addr += 4) {
      OUTreloc->rtype  = R_MIPS_EXTGOT;
      OUTreloc->addr   = addr;
      OUTreloc->addend = 0;
#if LOCAL_SYMS_FIRST
      OUTreloc->symbol = info->symptr + (ndx - pfd->globndx);
#else
      OUTreloc->symbol = pfd->symmap[ndx];
#endif
    }
  }
  else
#endif
  { Alloc (info->relocptr, (info->nrelocs = nrelocs) * sizeof (RLOCENT));
    OUTreloc = info->relocptr;
  }

  /* construct relocation table to return */

  for (scn = info->scnptr, cnt1 = info->nsects; cnt1--; scn++) {
    Elf32_Rela *INreloc = (Elf32_Rela *)scn->relocptr;
    int         cnt2    = scn->nrelocs;
    int         symndx;

    for (; cnt2--; INreloc = (Elf32_Rela *)((char *)INreloc + RELOCSZ)) {
      if (!INreloc->r_info) {
        scn->nrelocs--;
        info->nrelocs--;
        continue;
      }
      scn->relocptr = OUTreloc;     /* YOU NEED TO SAVE PTR FOR FREE!!! */

      /* relocation type and address */

      OUTreloc->rtype = ELF32_R_TYPE (INreloc->r_info);
      OUTreloc->addr  = INreloc->r_offset;

      /* relocation addend */

#if RELOC_ONE_TYPE == SHT_RELA
      OUTreloc->addend = INreloc->r_addend;
#else
      OUTreloc->addend = 0;
#endif

      /* relocation symbol (shared library base) */

      if (!(symndx = ELF32_R_SYM (INreloc->r_info)))
        OUTreloc->symbol = info->auxsym;

      /* relocation symbol (global) */

#if LOCAL_SYMS_FIRST
      else if (symndx >= pfd->globndx)
        OUTreloc->symbol = info->symptr + (symndx - pfd->globndx);
      else
#else
#if IRIX_5x
      /* this is a kludge to work around a problem with data initialized with
         a pointer to an external function under IRIX 5.2 */

      else if (OUTreloc->symbol = pfd->symmap[symndx]) {
        Elf32_Sym *rawsym = &pfd->symtab[symndx];
        if (   (ELF32_ST_TYPE (rawsym->st_info) == STT_FUNC)
            && (rawsym->st_shndx == SHN_UNDEF)
            && (OUTreloc->rtype == R_MIPS_REL32) )
          OUTreloc->rtype = R_MIPS_EXTGOT;
      }
      else
#else
      else if (!(OUTreloc->symbol = pfd->symmap[symndx]))
#endif
#endif

      /* relocation symbol (local) */

      { Elf32_Sym *sym = pfd->symtab + symndx;
        SECTION   *scn;

        if (sym->st_shndx <= pfd->fhead->e_shnum)
          OUTreloc->symbol = pfd->scnmap[sym->st_shndx]->auxsym;
        else if (scn = find_outscn_by_addr (pfd, sym->st_value)) {
          OUTreloc->symbol  = scn->auxsym;
          OUTreloc->addend -= scn->vaddr;
        }
        else {
          printf ("OBJread: could not find section for relocation at 0x%.8x\n", OUTreloc->addr);
          OUTreloc->symbol = 0;
        }
      }

      /* addend adjustments */

#if IRIX_5x
      if (   OUTreloc->rtype == R_MIPS_REL32
          && !(OUTreloc->symbol->whatis & SYM_STAT) )
        OUTreloc->addend -= OUTreloc->symbol->value;
#endif

      OUTreloc++;
    }
  }

  /* return success/failure here */

  return 1;
error:
  return 0;
}


static int free_machine_data (struct objpriv *pfd)
{
  return 1;
}


/*****************************************************************************/
/* Two cases need to be considered in order to obtain segment information:   */
/*									     */
/*   (1) Program headers are present:  This is the preferred way since the   */
/*          compiler/linker has already organized the sections into their    */
/*          corresponding segments.  Although the ELF format does not        */
/*          specify any limit on the number of segments, we will assume      */
/*          (for lack of counterexamples) that there will be at most two.    */
/*          Also we will presume that the presence of the writable-segment   */
/*          flag (PF_W) identifies the data segment.  The bss segment is     */
/*          derived from the data segment using the difference between the   */
/*          "p_memsz" and "p_filesz" fields as the size of bss.		     */
/*									     */
/*   (2) Program headers are not present:  This case complicates matters     */
/*          since the ELF format allows sections to appear in any order.     */
/*          However in all files we have examined, section headers have      */
/*          appeared in the same order as their data in the file with        */
/*          loadable sections being contiguous.  Examples of relocatable     */
/*          files have been found in which some sections (such as the symbol */
/*          table) have the SHF_ALLOC flag set which is subsequently cleared */
/*          by the linker when the file is combined into an executable or    */
/*          shared object.  For this reason we will consider only sections   */
/*          of type SHT_PROGBITS or SHT_NOBITS as candidates for loadable    */
/*          sections.							     */
/*****************************************************************************/

static int get_segment_info (struct objpriv *pfd)
{
  Elf32_Shdr *shdr;
  OBJINFO    *info = pfd->info;
  SEGMENT    *seg;
  int         cnt;

  /* program headers are present */

  if (pfd->phead) {
    Elf32_Phdr *phdr = pfd->phead;

    for (cnt = pfd->fhead->e_phnum; cnt--; phdr++) {
      if (phdr->p_type != PT_LOAD)
        continue;
      Alloc (seg, sizeof (SEGMENT));

      /* write flag is data segment (which may include bss); otherwise it
         is the text segment */

      if (phdr->p_flags & PF_W) {
        int size = phdr->p_memsz - phdr->p_filesz;

        info->data = seg;
        if (size) {
          Alloc (info->bss, sizeof (SEGMENT));
          info->bss->size   = size;
          info->bss->faddr  = 0;
          info->bss->vaddr  = phdr->p_vaddr + phdr->p_filesz;
          info->bss->nscns  = 0;
          info->bss->scnptr = 0;
        }
      }
      else info->text = seg;

      /* fill in segment info from the program header */

      seg->size   = phdr->p_filesz;
      seg->faddr  = phdr->p_offset;
      seg->vaddr  = phdr->p_vaddr;
      seg->nscns  = 0;
      seg->scnptr = 0;
    }
  }

  /* program headers are not present (THIS MAY NEED MODIFICATION) */

  else {
    Elf32_Shdr *lasttext, *lastdata;
    int         bsssize = 0, vaddr = 0;

    shdr = pfd->shead;
    for (cnt = pfd->fhead->e_shnum; cnt--; vaddr += (shdr++)->sh_size) {
      if (!(shdr->sh_flags & SHF_ALLOC) || !shdr->sh_size)
        continue;
      if (shdr->sh_type == SHT_PROGBITS) {
        if (shdr->sh_flags & SHF_WRITE) {     /* DATA SECTION */
          lastdata = shdr;
          if (!info->data) {
            Alloc (info->data, sizeof (SEGMENT));
            info->data->faddr  = shdr->sh_offset;
            info->data->vaddr  = vaddr;
            info->data->nscns  = 0;
            info->data->scnptr = 0;
          }
        }
        else {                                /* TEXT SECTION */
          lasttext = shdr;
          if (!info->text) {
            Alloc (info->text, sizeof (SEGMENT));
            info->text->faddr  = shdr->sh_offset;
            info->text->vaddr  = vaddr;
            info->text->nscns  = 0;
            info->text->scnptr = 0;
          }
        }
      }
      else if (shdr->sh_type == SHT_NOBITS) {   /* BSS SECTION */
        bsssize += shdr->sh_size;
        if (!info->bss) {
          Alloc (info->bss, sizeof (SEGMENT));
          info->bss->faddr  = 0;
          info->bss->vaddr  = vaddr;
          info->bss->nscns  = 0;
          info->bss->scnptr = 0;
        }
      }
    }

    /* update segment sizes (WARNING:  we are assuming section headers for a
       particular segment appear contiguously!!) */

    if (info->text)
      info->text->size
                 = lasttext->sh_offset + lasttext->sh_size - info->text->faddr;
    if (info->data)
      info->data->size
                 = lastdata->sh_offset + lastdata->sh_size - info->data->faddr;
    if (info->bss)
      info->bss->size = bsssize;
  }

  /* set segment flags in section headers */

  for (shdr = pfd->shead, cnt = pfd->fhead->e_shnum; cnt--; shdr++) {
    if (info->text && shdr->sh_offset >= info->text->faddr
                   && shdr->sh_offset < info->text->faddr + info->text->size)
      shdr->sh_flags |= SHF_TEXT;
    if (info->data && shdr->sh_offset >= info->data->faddr
                   && shdr->sh_offset < info->data->faddr + info->data->size)
      shdr->sh_flags |= SHF_DATA;
    if (info->bss && shdr->sh_type == SHT_NOBITS
                  && shdr->sh_flags & SHF_ALLOC)
      shdr->sh_flags |= SHF_BSS;
  }

  /* OBJ_DEMAND objects need an adjustment to the segment information because
     the file offsets as given may not be page-aligned */

  if (info->flags & OBJ_DEMAND) {
    long mask = sysconf (_SC_PAGESIZE) - 1;

    if (info->text) {
      int pad = info->text->faddr & mask;
      info->text->faddr -= pad;
      info->text->vaddr -= pad;
      info->text->size  += pad;
    }
    if (info->data) {
      int pad = info->data->faddr & mask;
      info->data->faddr -= pad;
      info->data->vaddr -= pad;
      info->data->size  += pad;
    }
  }

  /* return success/failure here */

  return 1;
error:
  return 0;
}


#if !SECTIONS_ORDERED
static int compare_Shdr (Elf32_Shdr **scn1, Elf32_Shdr **scn2)
{
  if ((*scn1)->sh_offset != (*scn2)->sh_offset)
    return ((*scn1)->sh_offset - (*scn2)->sh_offset);
  if ((*scn1)->sh_flags & SHF_ALLOC)
    return -1;
  return 1;
}
#endif


static int get_section_info (struct objpriv *pfd)
{
  int         cnt   = pfd->fhead->e_shnum;
  OBJINFO    *info  = pfd->info;
  Elf32_Shdr *INscn = pfd->shead;
  SECTION    *OUTscn;

  /* sort section headers if we must */

#if !SECTIONS_ORDERED
  Elf32_Shdr **sorted;

  Alloc (sorted, cnt * sizeof (Elf32_Shdr *));
  while (cnt--) sorted[cnt] = INscn + cnt;
  qsort (sorted, cnt = pfd->fhead->e_shnum, sizeof (*sorted), compare_Shdr);
  INscn = sorted[0];
#endif

  /* allocate section map and output section header table */

  Zalloc (pfd->scnmap, cnt * sizeof (SECTION *));
  Zalloc (OUTscn, cnt * sizeof (SECTION));
  info->scnptr = OUTscn;

  while (cnt--) {
    if (INscn->sh_size) {
      pfd->scnmap[INscn - pfd->shead] = OUTscn;
      OUTscn->name  = pfd->scnname + INscn->sh_name;
      OUTscn->size  = INscn->sh_size;
      OUTscn->faddr = INscn->sh_offset;
      OUTscn->vaddr = INscn->sh_addr;

      /* section flags */

      if (!(INscn->sh_flags & SHF_ALLOC))
        OUTscn->flags = SCN_INFO | SCN_NRES;
      else if (INscn->sh_type == SHT_PROGBITS)
        if (INscn->sh_flags & SHF_EXECINSTR)
          OUTscn->flags = SCN_TEXT | SCN_READ | SCN_EXE;
        else OUTscn->flags = SCN_DATA | SCN_READ;
      else if (INscn->sh_type == SHT_NOBITS)
        OUTscn->flags = SCN_BSS | SCN_READ;
      else OUTscn->flags = SCN_INFO | SCN_READ;
      if (INscn->sh_flags & SHF_WRITE)
        OUTscn->flags |= SCN_WRITE;

      /* section a member of text segment? */

      if (INscn->sh_flags & SHF_TEXT) {
        if (!info->text->scnptr)
          info->text->scnptr = OUTscn;
        info->text->nscns++;
      }

      /* section a member of data segment? */

      if (INscn->sh_flags & SHF_DATA) {
        if (!info->data->scnptr)
          info->data->scnptr = OUTscn;
        info->data->nscns++;
      }

      /* section a member of bss segment? */

      if (INscn->sh_flags & SHF_BSS) {
        if (!info->bss->scnptr)
          info->bss->scnptr = OUTscn;
        info->bss->nscns++;
      }

      OUTscn++;
    }

#if SECTIONS_ORDERED
    INscn++;
#else
    INscn = sorted[pfd->fhead->e_shnum - cnt];
#endif
  }

  /* return success/failure here */

  info->nsects = OUTscn - info->scnptr;
  pfd->done   |= OBJ_SCN;
  return 1;
error:
  return 0;
}


static int get_obj_info (struct objpriv *pfd)
{
  int         fileno = pfd->fd.fileno;
  Elf32_Shdr *scn;
  Elf32_Phdr *phdr;
  OBJINFO    *info;
  int         size, cnt;

  /* read in the file header and verify magic */

  Alloc (pfd->fhead, sizeof (Elf32_Ehdr));
  if (   (-1 == XC_reads (fileno, pfd->fhead, sizeof (*pfd->fhead)))
      || N_BADMAG (*pfd->fhead)                                      ) {
    XC_errno = NOTANOBJ;
    goto error;
  }
#ifdef DISPLAY
  printf ("*** FILE HEADER ***\n\n");
  printf ("e_type        %s\n",     ETtype[pfd->fhead->e_type]);
  printf ("e_machine     %d\n",     pfd->fhead->e_machine);
  printf ("e_version     %d\n",     pfd->fhead->e_version);
  printf ("e_entry       0x%.8x\n", pfd->fhead->e_entry);
  printf ("e_phoff       0x%.8x\n", pfd->fhead->e_phoff);
  printf ("e_shoff       0x%.8x\n", pfd->fhead->e_shoff);
  printf ("e_flags       0x%.8x\n", pfd->fhead->e_flags);
  printf ("e_ehsize      0x%.4x\n", pfd->fhead->e_ehsize);
  printf ("e_phentsize   0x%.4x\n", pfd->fhead->e_phentsize);
  printf ("e_phnum       %d\n",     pfd->fhead->e_phnum);
  printf ("e_shentsize   0x%.4x\n", pfd->fhead->e_shentsize);
  printf ("e_shnum       %d\n",     pfd->fhead->e_shnum);
  printf ("e_shstrndx    %d\n",     pfd->fhead->e_shstrndx);
#endif

  /* read in the program header table if present */

  if (pfd->fhead->e_phoff) {
    Seek (pfd->fd.fileno, pfd->fhead->e_phoff, 0);
    Alloc (pfd->phead, pfd->fhead->e_phnum * pfd->fhead->e_phentsize);
    Reads (pfd->fd.fileno, pfd->phead, pfd->fhead->e_phnum * pfd->fhead->e_phentsize);
  }
#if DISPLAY
  printf ("\n\n\t\t*** PROGRAM HEADERS ***\n\n");
  printf (" p_type    p_offset   p_vaddr   p_paddr\n");
  printf (" p_filesz  p_memsz    p_flags   p_align\n");
  for (cnt = 0; cnt < pfd->fhead->e_phnum; cnt++) {
    int PTndx = pfd->phead[cnt].p_type;  
    if (PTndx >= PT_LOPROC)  
      PTndx -= (PT_LOPROC - PT_NUM);
    printf ("\n%10s  0x%.8x  0x%.8x  0x%.8x\n",
                                PTtype[PTndx],
                                pfd->phead[cnt].p_offset,
                                pfd->phead[cnt].p_vaddr,
                                pfd->phead[cnt].p_paddr );
    printf ("0x%.8x  0x%.8x  0x%.8x  0x%.8x\n",
                                pfd->phead[cnt].p_filesz,
                                pfd->phead[cnt].p_memsz,
                                pfd->phead[cnt].p_flags,
                                pfd->phead[cnt].p_align );
  }
#endif

  /* read in the section headers and the section name table */

  Seek (pfd->fd.fileno, pfd->fhead->e_shoff, 0);
  Alloc (pfd->shead, size = pfd->fhead->e_shentsize * pfd->fhead->e_shnum);
  Reads (pfd->fd.fileno, pfd->shead, size);
  if (pfd->fhead->e_shstrndx) {
    pfd->scnname = loadscn (pfd, pfd->shead + pfd->fhead->e_shstrndx);
    if ((int)pfd->scnname == -1)
      goto error;
  }
#if DISPLAY
  printf ("\n\n\t\t*** SECTION HEADERS ***\n\n");
  printf (" sh_type   sh_flags   sh_addr   sh_offset      sh_name\n");
  printf (" sh_size   sh_link    sh_info   sh_addralign   sh_entsize\n");
  for (cnt = 0; cnt < pfd->fhead->e_shnum; cnt++) {
    int SHTndx = pfd->shead[cnt].sh_type;
    if (SHTndx >= SHT_LOPROC)
      SHTndx -= (SHT_LOPROC - SHT_NUM);
    printf ("\n%12s  0x%.8x  0x%.8x  0x%.8x  %s\n",
				SHTtype[SHTndx],
				pfd->shead[cnt].sh_flags,
				pfd->shead[cnt].sh_addr,
				pfd->shead[cnt].sh_offset,
				pfd->scnname + pfd->shead[cnt].sh_name );
    printf (" 0x%.8x   0x%.8x  0x%.8x  0x%.8x  0x%.8x\n",
				pfd->shead[cnt].sh_size,
				pfd->shead[cnt].sh_link,
				pfd->shead[cnt].sh_info,
				pfd->shead[cnt].sh_addralign,
				pfd->shead[cnt].sh_entsize );
  }
#endif

  /* get object's link dynamic if it has one */

  if (scn = find_scn_by_name (pfd, ".dynamic")) {
    if (-1 == (int)(pfd->ldyn = loadscn (pfd, scn)))
      goto error;
    pfd->ndyn = scn->sh_size / sizeof (Elf32_Dyn);
  }
#if DISPLAY
  printf ("\n\n\t\t*** DYNAMIC INFORMATION ***\n\n");
  printf ("   d_tag     d_val\n\n");
  for (cnt = 0; cnt < pfd->ndyn; cnt++) {
    int DTndx = pfd->ldyn[cnt].d_tag;
    if (DTndx >= DT_LOPROC)
#if IRIX_5x
      DTndx -= (DT_LOPROC - 24);
#endif
#if SunOS_5x
      DTndx -= (DT_HIPROC - 25);
#endif
    printf ("%11s  0x%.8x\n", DTtype[DTndx],
                              pfd->ldyn[cnt].d_un.d_val );
  }
#endif

  /* allocate an info structure and fill in stuff from headers (this is
     returned by a subsequent call to OBJread) */

  Zalloc (info, sizeof (OBJINFO));
  pfd->info       = info;
  info->timestamp = pfd->fd.tstamp;
  info->entry     = pfd->fhead->e_entry;
  switch (pfd->fhead->e_type) {
    case ET_REL : info->flags = OBJ_REL  | OBJ_IMPURE;              break;
    case ET_EXEC: info->flags = OBJ_EXE  | OBJ_DEMAND;              break;
    case ET_DYN : info->flags = OBJ_SLIB | OBJ_DEMAND | OBJ_ADJSEG; break;
    case ET_CORE: info->flags = OBJ_CORE;                           break;
    default     : XC_errno    = NOTANOBJ; goto error;
  }
  if (find_dynamic (pfd->ldyn, DT_NEEDED))
    info->flags |= OBJ_DYN;

#if IRIX_5x
  if (pfd->fhead->e_flags & EF_MIPS_PIC)
    info->flags |= OBJ_PIC;
  if (info->flags & (OBJ_EXE | OBJ_SLIB))
    info->base = (find_dynamic (pfd->ldyn, DT_MIPS_BASE_ADDRESS))->d_un.d_val;
#endif

  /* segment information */

  if (!get_segment_info (pfd))
    goto error;

  /* return success/failure here */

  return 1;
error:
  return 0;
}
#endif

OBJFD *OBJopen (char *name, int whence)
{
  struct objpriv *pfd;
  struct stat     status;
  int             fileno;

  /* open file for input */

  if (-1 == (fileno = XC_open (name, O_RDONLY, 0)))
    return 0;
  if (-1 == fstat (fileno, &status)) {
    XC_errno = IOERROR;
    goto error;
  }

  /* allocate a descriptor and fill in what we know */

  Zalloc (pfd, sizeof (struct objpriv) + strlen (name) + 1);
  pfd->fd.name   = strcpy ((char *)&pfd[1], name);
  pfd->fd.mode   = O_RDONLY;
  pfd->fd.fileno = fileno;
  pfd->fd.tstamp = status.st_mtime;
  pfd->fsize     = status.st_size;

  /* check to see if it is an archive */

  if (is_archive (pfd)) {
    if (!(whence & OBJ_ARCH)) {
      XC_errno = NOTANOBJ;
      goto error;
    }
  }

  /* simple object file here */

  else {
    if (!(whence & OBJ_OBJ)) {
      XC_errno = NOTARLIB;
      goto error;
    }
    Seek (pfd->fd.fileno, 0, 0);
    if (!get_obj_info (pfd))
      goto error;
  }

  /* success here */

  Keep_space ();
  pfd->fd.base = 0;
  pfd->fdmagic = FDMAGIC;
  pfd->done    = 0;
  return &pfd->fd;

  /* error here */

error:
  close (fileno);
  Free_space ();
  return 0;
}

int OBJclose (OBJFD *fd, int keep)
{
  struct objpriv *pfd  = (struct objpriv *)fd;
  OBJINFO        *info = pfd->info;

  /* adjust command bitmask to account for the fact that some items require
     others */

  if (keep & OBJ_RELOC)
    keep |= (OBJ_SCN | OBJ_GSYM);
  if (keep & OBJ_LINE)
    keep |= OBJ_FILE;
  if (keep & OBJ_DEBUG)
    keep |= (OBJ_FILE | OBJ_FCN | OBJ_LINE | OBJ_GSYM | OBJ_LSYM);

  /* verify validity of descriptor and command */

  if (keep & ~OBJ_CMDS || pfd->fdmagic != FDMAGIC) {
    XC_errno = INVLDARG;
    goto error;
  }

  /* free all memory not being kept */

  if (!(keep & OBJ_MACH))
    free_machine_data (pfd);
  if (info->scnptr && !(keep & OBJ_SCN))
    free (info->scnptr);
  if (info->symptr && !(keep & OBJ_GSYM))
    free (info->symptr);
  if (info->dbgptr && !(keep & OBJ_LSYM))
    free (info->dbgptr);
  if (info->nametbl && !(keep & (OBJ_GSYM | OBJ_LSYM)))
    free (info->nametbl);
  if (info->files && !(keep & OBJ_FILE))
    free (info->files);
  if (info->fcns && !(keep & OBJ_FCN))
    free (info->fcns);
  if (info->relocptr && !(keep & OBJ_RELOC))
    free (info->relocptr);
  if (info->auxsym && !(keep & OBJ_RELOC))
    free (info->auxsym);
  if (info->lineptr && !(keep & OBJ_LINE))
    free (info->lineptr);
  if (!keep) {
    if (info->text) free (info->text);
    if (info->data) free (info->data);
    if (info->bss) free (info->bss);
    free (info);
  }
  if (fd->fileno >= 0)
    close (fd->fileno);
  pfd->fdmagic = 0;		/* prevents bogus usage later */
  free (pfd);

  /* return success/failure here */

  return 1;
error:
  return 0;
}

OBJINFO *OBJread (OBJFD *fd, int cmd)
{
  struct objpriv *pfd = (struct objpriv *)fd;

  /* adjust command bitmask to account for the fact that some items require
     others */

  if (cmd & OBJ_RELOC)
    cmd |= (OBJ_SCN | OBJ_GSYM);
  if (cmd & OBJ_LINE)
    cmd |= OBJ_FILE;
  if (cmd & OBJ_DEBUG)
    cmd |= (OBJ_FILE | OBJ_FCN | OBJ_LINE | OBJ_GSYM | OBJ_LSYM);

  /* verify validity of descriptor and command */

  if (cmd & ~OBJ_CMDS || pfd->fdmagic != FDMAGIC) {
    XC_errno = INVLDARG;
    goto error;
  }
  cmd &= ~pfd->done;

  /* this had better be an object file */

  if (fd->arch) {
    XC_errno = NOTANOBJ;
    goto error;
  }

  /* memory map "large" files so we can return memory to the system pool after
     we are done with it */
#if !SVR4
  if (!pfd->mapaddr && get_map_params (pfd))
    pfd->mapaddr = XC_mmap (0, pfd->mapsize, PROT_READ, MAP_PRIVATE,
                                   pfd->fd.fileno, pfd->fd.base + pfd->mapoff);
#endif

  /* return section headers? */

  if (cmd & OBJ_SCN && !get_section_info (pfd))
    goto error;

  /* return global symbols? */

  if (cmd & OBJ_GSYM && !get_global_symbols (pfd))
    goto error;

  /* return relocation info? */

  if (cmd & OBJ_RELOC && !get_reloc_info (pfd))
    goto error;

#if 0
  { char  *buffer;
    int   *where, *eos;
    U4_int vaddr, faddr, size;

    if (pfd->info->text) {
      size  = pfd->info->text->size;
      vaddr = pfd->info->text->vaddr;
      faddr = pfd->info->text->faddr;
      Alloc (buffer, size);
      Seek (pfd->fd.fileno, faddr, 0);
      Reads (pfd->fd.fileno, buffer, size);
      where = (int *)buffer;
      eos   = (int *)(buffer + size);
      printf ("\n\n\n*** TEXT SEGMENT ***\n\n");
      printf ("   vaddr       faddr\n\n");
      for (; where < eos; where += 4, vaddr += 16, faddr += 16)
        printf ("0x%.8x  0x%.8x  |  0x%.8x  0x%.8x  0x%.8x  0x%.8x\n",
                 vaddr, faddr, where[0], where[1], where[2], where[3]);
    }
  }
#endif

  Keep_space ();
  return pfd->info;
error:
  Free_space ();
  return 0;
}

