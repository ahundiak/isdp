/* $Revision: 1.1 $ */
#include "dba.ext"
#include "script.def"
#include "dmalloc.def"

/*
#define MALLOC_TRACE
*/

#if defined (MALLOC_TRACE)
typedef struct dmalloc_block {
  void *addr;
  int old:1;
  int acct:1;
  unsigned long size, desc;
  struct dmalloc_block *nblock, *pblock;
  char *file;
  int line;
} dmalloc_block;

static dmalloc_block *dba_fblock[256], *dba_lblock[256];
static dmalloc_block *dba_str_fblock[256], *dba_str_lblock[256];
static long freecnt[MAX_DESC], alloccnt[MAX_DESC];
static long str_freecnt[MAX_DESC], str_alloccnt[MAX_DESC];
static long dba_whoops;
#endif

#if defined(MALLOC_TRACE)
void dba_dmalloc_bad_description (n)
unsigned long n;
{
  dba_printf ("Malloc Debugger: Illegal description value: %d\n", n);
}
#endif


/*
    Function:	dba_dmalloc_ex
    Author:	Tim A. Thompson
    Date:	15-JUN-91

    Revisions:
	8-23-93  -- Added "file" and "line".
*/

/* ARGSUSED */
void *dba_dmalloc_ex (size, desc, file, line)
unsigned long size;
unsigned long desc;
char *file;
int line;
{
/*  void *malloc();*/
#if defined(MALLOC_TRACE)
  void *tmp;
  long hash;
  dmalloc_block *tblock;

  if (desc <1 || desc >MAX_DESC)
    dba_dmalloc_bad_description (desc);
  tmp = (void *) malloc (size);
  if (tmp) {
    tblock = (dmalloc_block *) calloc (sizeof (dmalloc_block), 1);
    tblock->addr = tmp;
    tblock->size = size;
    tblock->desc = desc;
    tblock->file = file;
    tblock->line = line;
    tblock->nblock = 0;
    alloccnt[desc-1]++;
    hash = ((long) tmp >> 4)%256;
    if (!dba_fblock[hash])
      dba_fblock[hash] = tblock;
    else
    {
      dba_lblock[hash]->nblock = tblock;
      tblock->pblock = dba_lblock[hash];
    }
    dba_lblock[hash] = tblock;
  }
  return (tmp);
#else
#ifdef __WIN16__
  return ((void *) dba_malloc (size));
#else
  return ((void *) malloc (size));
#endif
#endif
}

/*
    Function:	dba_dcalloc_ex
    Author:	Tim A. Thompson
    Date:	15-JUN-91

    Revisions:
	8-23-93  -- Added "file" and "line".
*/

/* ARGSUSED */
void *dba_dcalloc_ex (size, num, desc, file, line)
unsigned long size;
unsigned long num;
unsigned long desc;
char *file;
int line;
{
/*  void *calloc();*/
#if defined(MALLOC_TRACE)
  void *tmp;
  long hash;
  dmalloc_block *tblock;

  if (desc <1 || desc >MAX_DESC)
    dba_dmalloc_bad_description (desc);
  tmp = (void *) calloc (size, num);
  if (tmp) {
    tblock = (dmalloc_block *) calloc (sizeof (dmalloc_block), 1);
    tblock->addr = tmp;
    tblock->size = size * num;
    tblock->desc = desc;
    tblock->file = file;
    tblock->line = line;
    tblock->nblock = 0;
    alloccnt[desc-1]++;
    hash = ((long) tmp >> 4)%256;
    if (!dba_fblock[hash])
      dba_fblock[hash] = tblock;
    else
    {
      dba_lblock[hash]->nblock = tblock;
      tblock->pblock = dba_lblock[hash];
    }
    dba_lblock[hash] = tblock;
  }
  return (tmp);
#else
  return ((void *) calloc (size, num));
#endif
}

/*
   Function:	dba_drealloc
   Author:	Tim A. Thompson
   Date:	15-JUN-91
#endif
*/

void *dba_drealloc (ptr, size)
void *ptr;
unsigned long size;
{
/*  void *realloc();*/
  void *tmp;
#if defined(MALLOC_TRACE)
  long ohash, nhash;
  dmalloc_block *tblock;

  if (!ptr)
    return ((void *) dba_dmalloc (size, DM_MEMBER));

  ohash = ((long) ptr >> 4)%256;
  tmp = (void *) realloc (ptr, size);
  if (tmp) {
    for (tblock=dba_fblock[ohash]; tblock; tblock=tblock->nblock)
      if (tblock->addr == ptr)
        break;
    if (!tblock) {
      dba_printf ("FATAL ERROR:  Attempted to realloc memory not allocated!\n");
      return (tmp);
    }
    tblock->size = size;
    if (tmp != ptr) {
      nhash = ((long) tmp >> 4)%256;
      tblock->addr = tmp;
      if (tblock == dba_fblock[ohash])
        dba_fblock[ohash] = tblock->nblock;
      else
        tblock->pblock->nblock = tblock->nblock;
      if (tblock == dba_lblock[ohash])
        dba_lblock[ohash] = tblock->pblock;
      else
        tblock->nblock->pblock = tblock->pblock;
      tblock->pblock = tblock->nblock = 0;
      if (!dba_fblock[nhash])
        dba_fblock[nhash] = tblock;
      else
      {
        dba_lblock[nhash]->nblock = tblock;
        tblock->pblock = dba_lblock[nhash];
      }
      dba_lblock[nhash] = tblock;
    }
  }
  return (tmp);
#else
#ifdef __WIN16__
  if (!ptr)
    return ((void *) dba_malloc (size));
  else
    return ((void *) dba_realloc (ptr, size));
#else
  if (!ptr)
    { tmp = (void *) malloc (size);
    memset (tmp, 0, size);
    return (tmp); }
  else
    return ((void *) realloc (ptr, size));
#endif
#endif
}

/*
   Function:	dba_dstrdup_ex
   Author:	Tim A. Thompson
   Date:	15-JUN-91

   Revisions:
       4-21-94  -- Change from strdup to malloc and strcpy to keep Bounds
                   Checker happy.
*/

/* ARGSUSED */
char *dba_dstrdup_ex (str, desc, file, line)
char *str;
unsigned long desc;
char *file;
int line;
{
#if defined(MALLOC_TRACE)
  char *tmp;
  long hash;
  dmalloc_block *tblock;

  if (desc <1 || desc >MAX_DESC)
    dba_dmalloc_bad_description (desc);
  tmp = (char *) malloc (strlen (str)+1);
  if (tmp) {
    strcpy (tmp, str);
    tblock = (dmalloc_block *) calloc (sizeof (dmalloc_block), 1);
    tblock->addr = (void *) tmp;
    tblock->size = strlen (str)+1;
    tblock->desc = desc;
    tblock->file = file;
    tblock->line = line;
    tblock->nblock = 0;
    alloccnt[desc-1]++;
    hash = ((long) tmp >> 4) % 256;
    if (!dba_fblock[hash])
      dba_fblock[hash] = tblock;
    else
    {
      dba_lblock[hash]->nblock = tblock;
      tblock->pblock = dba_lblock[hash];
    }
    dba_lblock[hash] = tblock;
  }
  return (tmp);
#else
  void *tmp;

  tmp = (char *) malloc (strlen (str)+1);
  if (!tmp)
    return (char *) 0;
  strcpy (tmp, str);
  return (char *) tmp;
/*
  Can't use strdup with BoundsChecker32 -- it'll tell you you're passing an
  invalid argument to free() when you free it :-(
  
  return ((char *) strdup (str));
*/
#endif
}

/*
   Function:	dba_dfree
   Author:	Tim A. Thompson
   Date:	15-JUN-91
*/

void dba_dfree (ptr)
void *ptr;
{
#if defined(MALLOC_TRACE)
  long hash;
  dmalloc_block *tblock;

  hash = ((long) ptr >> 4) % 256;
  for (tblock=dba_fblock[hash]; tblock; tblock=tblock->nblock)
    if (tblock->addr == ptr)
      break;
  if (!tblock) {
    dba_printf ("FATAL ERROR:  Attempted to free memory not allocated!\n");
    free (ptr);
    return;
  }
  if (tblock == dba_fblock[hash])
    dba_fblock[hash] = tblock->nblock;
  else
    tblock->pblock->nblock = tblock->nblock;
  if (tblock == dba_lblock[hash])
    dba_lblock[hash] = tblock->pblock;
  else
    tblock->nblock->pblock = tblock->pblock;
  freecnt[tblock->desc-1]++;
  free (tblock);
#endif
  free (ptr);
}


#if defined(MALLOC_TRACE)
void dba_struct_allocate_mark (addr, file, line)
void *addr;
char *file;
int line;
{
  long hash;
  dmalloc_block *tblock;

  if (addr) {
    tblock = (dmalloc_block *) calloc (sizeof (dmalloc_block), 1);
    tblock->addr = addr;
    tblock->desc = (unsigned long) file;
    tblock->size = line;
    hash = ((unsigned long) addr >> 4)%256;
    if (!dba_str_fblock[hash])
      dba_str_fblock[hash] = tblock;
    else
    {
      dba_str_lblock[hash]->nblock = tblock;
      tblock->pblock = dba_str_lblock[hash];
    }
    dba_str_lblock[hash] = tblock;
  }
}
#endif

#if defined (MALLOC_TRACE)
void dba_struct_allocate_unmark (addr)
void *addr;
{
  long hash;
  dmalloc_block *tblock;

  hash = ((unsigned long) addr >> 4) % 256;
  for (tblock=dba_str_fblock[hash]; tblock; tblock=tblock->nblock)
    if (tblock->addr == addr)
      break;
  if (!tblock) {
    dba_printf ("FATAL ERROR:  Attempted to unmark structure block not marked!\n");
    return;
  }
  if (tblock == dba_str_fblock[hash])
    dba_str_fblock[hash] = tblock->nblock;
  else
    tblock->pblock->nblock = tblock->nblock;
  if (tblock == dba_str_lblock[hash])
    dba_str_lblock[hash] = tblock->pblock;
  else
    tblock->nblock->pblock = tblock->pblock;
  free (tblock);
}
#endif

/* ARGSUSED */
char *dba_dmalloc_desc_string (num)
unsigned long num;
{
#if defined(MALLOC_TRACE)
  switch (num+1) {
    case DM_TMP:
      return "DM_TMP";
    case DM_DLOAD_STACK:
      return "DM_DLOAD_STACK";
    case DM_OPERATION:
      return "DM_OPERATION";
    case DM_OPERAND:
      return "DM_OPERAND";
    case DM_COMPOUNDDESC:
      return "DM_COMPOUNDDESC";
    case DM_ARG_IDX:
      return "DM_ARG_IDX";
    case DM_OPERAND_IDX:
      return "DM_OPERAND_IDX";
    case DM_COMPOUND:
      return "DM_COMPOUND";
    case DM_POINTERTYPE:
      return "DM_POINTERTYPE";
    case DM_SCR_VAR:
      return "DM_SCR_VAR";
    case DM_MEMBERTYPE:
      return "DM_MEMBERTYPE";
    case DM_INFO:
      return "DM_INFO";
    case DM_OPERAND_NAME:
      return "DM_OPERAND_NAME";
    case DM_FUNCTION_NAME:
      return "DM_FUNCTION_NAME";
    case DM_COMPOUND_NAME:
      return "DM_COMPOUND_NAME";
    case DM_ORIG_NAME:
      return "DM_ORIG_NAME";
    case DM_DLOAD_ARG:
      return "DM_DLOAD_ARG";
    case DM_DLOAD_TYPE:
      return "DM_DLOAD_TYPE";
    case DM_FUNC_LIST:
      return "DM_FUNC_LIST";
    case DM_FUNCTION:
      return "DM_FUNCTION";
    case DM_TOKENNODETYPE:
      return "DM_TOKENNODETYPE";
    case DM_JUMPNODETYPE:
      return "DM_JUMPNODETYPE";
    case DM_GENNODETYPE:
      return "DM_GENNODETYPE";
    case DM_JUMPSTACKTYPE:
      return "DM_JUMPSTACKTYPE";
    case DM_FUNC_REF_DESC:
      return "DM_FUNC_REF_DESC";
    case DM_TAG_TEXT:
      return "DM_TAG_TEXT";
    case DM_SOURCE_TEXT:
      return "DM_SOURCE_TEXT";
    case DM_OPERATION_NAME:
      return "DM_OPERATION_NAME";
    case DM_TOKEN:
      return "DM_TOKEN";
    case DM_SQLVAR:
      return "DM_SQLVAR";
    case DM_TIMESTAMP_TMP:
      return "DM_TIMESTAMP_TMP";
    case DM_DEALLOC_NAME:
      return "DM_DEALLOC_NAME";
    case DM_DEALLOC_PTR:
      return "DM_DEALLOC_PTR";
    case DM_SCR_INPUT:
      return "DM_SCR_INPUT";
    case DM_LABEL_LIST_NODE:
      return "DM_LABEL_LIST_NODE";
    case DM_UNRES_NAME:
      return "DM_UNRES_NAME";
    case DM_ARRAYNAME:
      return "DM_ARRAYNAME";
    case DM_ERR_PTR:
      return "DM_ERR_PTR";
    case DM_ERR_LINE:
      return "DM_ERR_LINE";
    case DM_ERR_COL:
      return "DM_ERR_COL";
    case DM_ERR_MSG:
      return "DM_ERR_MSG";
    case DM_ERR_TYPE:
      return "DM_ERR_TYPE";
    case DM_LINETEXT:
      return "DM_LINETEXT";
    case DM_BRK_FUNC_LIST:
      return "DM_BRK_FUNC_LIST";
    case DM_BRK_LINE_LIST:
      return "DM_BRK_LINE_LIST";
    case DM_BRK_FUNC_NAME:
      return "DM_BRK_FUNC_NAME";
    case DM_OPNUMARRAY:
      return "DM_OPNUMARRAY";
    case DM_SCRIPT_LINE:
      return "DM_SCRIPT_LINE";
    case DM_OTHER:
      return "DM_OTHER";
    case DM_OBJECT:
      return "DM_OBJECT";
    case DM_STRUCT_ALLOC:
      return "DM_STRUCT_ALLOC";
    case DM_SMM_BLOCKTYPE:
      return "DM_SMM_BLOCKTYPE";
    case DM_SMM_GENERIC_LIST:
      return "DM_SMM_GENERIC_LIST";
    case DM_CHUNK:
      return "DM_CHUNK";
    case DM_RECYCLE_SYM:
      return "DM_RECYCLE_SYM";
    case DM_STORED_SCR_NAME:
      return "DM_STORED_SCR_NAME";
    case DM_NAMEPOOL:
      return "DM_NAMEPOOL";
    case DM_DIMS:
      return "DM_DIMS";
    case DM_PP_KEY:
      return "DM_PP_KEY";
    case DM_PP_TEXT:
      return "DM_PP_TEXT";
    case DM_RPT_FIELD:
      return "DM_RPT_FIELD";
    case DM_RPT_LINE:
      return "DM_RPT_LINE";
    case DM_MEMBER:
      return "DM_MEMBER";
    case DM_GADGET:
      return "DM_GADGET";
    case DM_SCHEMA:
      return "DM_SCHEMA";
    case DM_TABLE:
      return "DM_TABLE";
    case DM_COLUMN:
      return "DM_COLUMN";
    case DM_QUERY:
      return "DM_QUERY";
    case DM_USER_VAR:
      return "DM_USER_VAR";
    case DM_REPATT:
      return "DM_REPATT";
    case DM_OUTJOIN:
      return "DM_OUTJOIN";
    case DM_RPT_KEY:
      return "DM_RPT_KEY";
    case DM_CODED_COLUMN:
      return "DM_CODED_COLUMN";
    case DM_CODE_LIST:
      return "DM_CODE_LIST";
    case DM_GLOBAL:
      return "DM_GLOBAL";
    case DM_LIBRARY:
      return "DM_LIBRARY";
    case DM_DEFATT:
      return "DM_DEFATT";
    case DM_RPT_MEMORY:
      return "DM_RPT_MEMORY";
    case DM_ARG_NAME:
      return "DM_ARG_NAME";
    case DM_STATIC:
      return "DM_STATIC";
    case DM_DLL_HINSTANCE:
      return "DM_DLL_HINSTANCE";
    case DM_APP:
      return "DM_APP";
    case DM_TEXT:
      return "DM_TEXT";
    default:
      return "<unknown>";
  }
#else
  return "<no compile>";
#endif
}

void dba_dmalloc_str_dump ()
{
#if defined(MALLOC_TRACE)
  long hash;
  dmalloc_block *tblock;
  smm_generic_list *tlist, *nlist, *tail, *head=0;

  for (hash=0; hash<256; hash++) {
    for (tblock=dba_str_fblock[hash]; tblock; tblock=tblock->nblock) {
      for (tlist=head; tlist; tlist=tlist->next)
        if ((long) tlist->other == tblock->size &&
            !strcmp ((char *) tlist->source, (char *) tblock->desc))
          break;
      if (!tlist) {
        tlist = (smm_generic_list *) dba_dmalloc (sizeof (smm_generic_list),
            DM_TMP);
        tlist->source = dba_dstrdup ((char *) tblock->desc, DM_TMP);
        tlist->other = (void *) tblock->size;
        tlist->size = 0L;
        if (head)
          tail->next = tlist;
        else
          head = tlist;
        tail = tlist;
        tlist->next = (void *) 0;
      }
      tlist->size++;
    }
  }
  dba_printf ("\nStructures Allocated:\n\n");
  for (tlist=head; tlist; tlist=nlist) {
    dba_printf ("  File: '%s', Line: %ld, Count: %ld\n", (char *) tlist->source,
        (long) tlist->other, tlist->size);
    nlist = tlist->next;
    dba_dfree (tlist->source);
    dba_dfree (tlist);
  }
#endif
}


/*
    Function:   _dba_dmalloc_dump
    Author:     Tim A. Thompson
*/

void _dba_dmalloc_dump (detail)
int detail;
{
#if defined(MALLOC_TRACE)
  static unsigned long lcnt[MAX_DESC], lsize[MAX_DESC];
  static int init;
  static FILE *dfp;
  unsigned long i, cnt[MAX_DESC], size[MAX_DESC], max[MAX_DESC], min[MAX_DESC];
  long hash;
  dmalloc_block *tblock, *list[MAX_DESC], *lp, *nlp;

  if (!init) {
    init = 1;
    if (getenv ("DMALLOC_DUMP")) {
      dfp = fopen (getenv ("DMALLOC_DUMP"), "w");
#if !defined (__WIN32__)
      if (!dfp)
        dfp = stdout;
#endif
    }
#if !defined (__WIN32__)
    else
      dfp = stdout;
#endif
  }
  memset (list, 0, MAX_DESC * sizeof (dmalloc_block *));
  for (i=0; i<MAX_DESC; i++) {
    cnt[i] = size[i] = max[i] = 0;
    min[i] = 0xffffffff;
  }
  for (hash = 0; hash<256; hash++) {
    for (tblock=dba_fblock[hash]; tblock; tblock=tblock->nblock) {
      i = tblock->desc-1;
      cnt[i]++;
      size[i] += tblock->size;
      max[i] = max[i] > tblock->size ? max[i] : tblock->size;
      min[i] = min[i] < tblock->size ? min[i] : tblock->size;
      tblock->old = 1;
      for (lp=list[i]; lp; lp=lp->nblock)
        if ((!lp->file && !tblock->file ||
            lp->file && tblock->file && !strcmp(lp->file, tblock->file))
            && lp->line == tblock->line)
          break;
      if (!lp) {
        lp = (dmalloc_block *) calloc (1, sizeof (dmalloc_block));
        lp->file = tblock->file;
        lp->line = tblock->line;
        lp->nblock = list[i];
        list[i] = lp;
      }
      lp->size++;
    }
  }
  fprintf (dfp, "Block Type           Count  (chg) Allocs Frees Tot Size (chg)    Max Size Min Size\n");
  for (i=0; i<MAX_DESC; i++) {
    if (cnt[i]) {
      fprintf (dfp, "%20s %6d (%3d) %6d %5d %8d (%6d) %8d %4d\n",
          dba_dmalloc_desc_string(i), cnt[i], cnt[i]-lcnt[i], alloccnt[i],
          freecnt[i], size[i], size[i]-lsize[i], max[i], min[i]);
      if (i+1 == detail || detail < 0) {
        for (lp=list[i]; lp; lp=lp->nblock) {
          if (lp->file)
            fprintf (dfp, "              '%s':%d --> %d\n", lp->file, lp->line,
              lp->size);
          else
            fprintf (dfp, "              <NULL>:%d --> %d\n", lp->line, lp->size);
          nlp = lp->nblock;
          free (lp);
        }
      }
    }
    lcnt[i] = cnt[i];
    lsize[i] = size[i];
    freecnt[i] = alloccnt[i] = 0;
  }
  fflush (dfp);
#endif
}

#if defined(MALLOC_TRACE)
dmalloc_block *dba_dmalloc_find_block(ptr)
void *ptr;
{
  long hash;
  dmalloc_block *tblock;

  if (!ptr)
    return (0);
  hash = ((long) ptr >> 4) % 256;
  for (tblock=dba_fblock[hash]; tblock; tblock=tblock->nblock)
    if (tblock->addr == ptr)
      break;
  return (tblock);
}
#endif

#if defined(MALLOC_TRACE)
void dba_dmalloc_lost_token ()
{
  long hash;
  dmalloc_block *tblock;

  dba_printf ("\n");
  for (hash=0; hash<256; hash++)
    for (tblock=dba_fblock[hash]; tblock; tblock=tblock->nblock)
      if (!tblock->acct && tblock->desc == DM_TOKEN)
        dba_printf ("LOST TOKEN:  '%s'\n", (char *) tblock->addr);
  dba_printf ("\n");
}
#endif

#if defined(MALLOC_TRACE)
void dba_dmalloc_lost_function_name ()
{
  long hash;
  dmalloc_block *tblock;

  dba_printf ("\n");
  for (hash=0; hash<256; hash++)
    for (tblock=dba_fblock[hash]; tblock; tblock=tblock->nblock)
      if (!tblock->acct && tblock->desc == DM_FUNCTION_NAME)
        dba_printf ("LOST FUNCTION NAME:  '%s'\n", (char *) tblock->addr);
  dba_printf ("\n");
}
#endif

#if defined(MALLOC_TRACE_OLD)
void dba_dmalloc_lost_pointertype ()
{
  long hash;
  dmalloc_block *tblock;

  dba_printf ("\n");
  for (hash=0; hash<256; hash++)
    for (tblock=dba_fblock[hash]; tblock; tblock=tblock->nblock)
      if (!tblock->acct && tblock->desc == DM_POINTERTYPE)
        dba_printf ("LOST POINTERTYPE:  (%d) '%s' %d %d\n", tblock->addr,
            (char *) ((pointertype *)tblock->addr)->functionname,
            ((pointertype *)tblock->addr)->ptrindex,
            ((pointertype *)tblock->addr)->offset);
  dba_printf ("\n");
}
#endif

#if defined(MALLOC_TRACE)
void dba_dmalloc_lost_function ()
{
  long hash;
  dmalloc_block *tblock;

  dba_printf ("\n");
  for (hash=0; hash<256; hash++)
    for (tblock=dba_fblock[hash]; tblock; tblock=tblock->nblock)
      if (!tblock->acct && tblock->desc == DM_FUNCTION)
        dba_printf ("LOST FUNCTION:  %d '%s'\n",
            ((functiontype *)tblock->addr)->name,
            ((functiontype *)tblock->addr)->name ?
            ((functiontype *)tblock->addr)->name : 0);
  dba_printf ("\n");
}
#endif

/* ARGSUSED */
void dba_dmalloc_mark (ptr)
void *ptr;
{
#if defined(MALLOC_TRACE)
  dmalloc_block *tblock;

  tblock = dba_dmalloc_find_block (ptr);
  if (tblock)
    tblock->acct = 1;
  else
    if (ptr) {
      dba_printf ("WHOOPS!  Can't mark %x\n", ptr);
      dba_whoops = 1;
    }
#endif
}

void dba_dmalloc_account ()
{
#if defined(MALLOC_TRACE_OLD)
  long hash, i, idx, idx2, cnt[MAX_DESC];
  functiontype *function;
  operandtype *op;
  operationtype *operation;
  compoundtype *compound;
  infotype *info;
  compounddescriptor *element;
  struct dba_func_list *tfunc;
  dmalloc_block *tblock;

  for (hash=0; hash<256; hash++)
    for (tblock=dba_fblock[hash]; tblock; tblock=tblock->nblock)
      tblock->acct = 0;

  for (i=0; i<256; i++) {
    for (tfunc=dba_ffunc[i]; tfunc; tfunc=tfunc->nfunc) {
      dba_dmalloc_mark ((void *) tfunc);
      function = (functiontype *) tfunc->function;
      if (function != &dba_global_function)
        dba_dmalloc_mark ((void *) function);
      dba_dmalloc_mark ((void *)function->name);
      if (function->numoperands) {
        dba_dmalloc_mark ((void *)function->operands);
      }
      if (function->numoperations) {
        dba_dmalloc_mark ((void *)function->operations);
      }
      if (function->numargs) {
        dba_dmalloc_mark ((void *)function->arguments);
      }
      if (function->numcompounds) {
        dba_dmalloc_mark ((void *)function->compounds);
      }
      for (idx=0; idx<function->numoperands; idx++) {
        op = &function->operands[idx];
        dba_dmalloc_mark ((void *)op->name);
        if (!op->is_alias && op->name[0] &&
            (op->mode != SCR_EXTERN || op->mode == SCR_EXTERN
            && function->name == dba_global_function.name)) {
          dba_dmalloc_mark (op->value);
          if (op->pointer && op->value)
            dba_dmalloc_mark((void *)((pointertype *)op->value)->functionname);
        }
        for (info=op->info; info; info=info->ninfo) {
          dba_dmalloc_mark ((void *)info);
          if (info->type != INFO_HEADER && info->type != INFO_FIELD &&
              info->type != INFO_STRUCT && info->type != INFO_NUMDIM &&
              info->type != INFO_DIMSIZE) {
            dba_dmalloc_mark (info->data);
          }
          if (info->type == INFO_PRESERVE) {
            dba_dmalloc_mark ((void *)((pointertype *)info->data)->functionname);
          }
        }
      }
      for (idx=0; idx<function->numoperations; idx++) {
        operation = &function->operations[idx];
        dba_dmalloc_mark ((void *)operation->name);
        if (operation->numoperands) {
          dba_dmalloc_mark ((void *)operation->operands);
        }
        dba_dmalloc_mark ((void *)operation->descriptor);
        for (info=operation->info; info; info=info->ninfo) {
          dba_dmalloc_mark ((void *)info);
          if (info->type != INFO_HEADER && info->type != INFO_FIELD &&
              info->type != INFO_STRUCT && info->type != INFO_NUMDIM &&
              info->type != INFO_DIMSIZE) {
            dba_dmalloc_mark (info->data);
          }
          if (info->type == INFO_PRESERVE) {
            dba_dmalloc_mark ((void *)((pointertype *)info->data)->functionname);
          }
        }
      }
      for (idx=0; idx<function->numcompounds; idx++) {
        compound = &function->compounds[idx];
        dba_dmalloc_mark ((void *)compound->name);
        if (compound->numelements)
          dba_dmalloc_mark ((void *)compound->elements);
        for (idx2=0; idx2<compound->numelements; idx2++) {
          element = &compound->elements[idx2];
/*
          dba_dmalloc_mark ((void *)element->name);
*/
          op = &element->operand;
          dba_dmalloc_mark ((void *)op->name);
          for (info=op->info; info; info=info->ninfo) {
            dba_dmalloc_mark ((void *)info);
            if (info->type != INFO_HEADER && info->type != INFO_FIELD &&
                info->type != INFO_STRUCT && info->type != INFO_NUMDIM &&
                info->type != INFO_DIMSIZE) {
              dba_dmalloc_mark (info->data);
            }
            if (info->type == INFO_PRESERVE) {
              dba_dmalloc_mark ((void *)((pointertype *)info->data)->functionname);
            }
          }
        }
      }
      for (info=function->info; info; info=info->ninfo) {
        dba_dmalloc_mark ((void *)info);
        if (info->type != INFO_HEADER && info->type != INFO_FIELD &&
            info->type != INFO_STRUCT && info->type != INFO_NUMDIM &&
            info->type != INFO_DIMSIZE) {
          dba_dmalloc_mark (info->data);
        }
        if (info->type == INFO_PRESERVE) {
          dba_dmalloc_mark ((void *)((pointertype *)info->data)->functionname);
        }
      }
    }
  }
  for (i=0;i<MAX_DESC;i++)
    cnt[i] = 0;
  for (i=0;i<256;i++)
    for (tblock=dba_fblock[i];tblock;tblock=tblock->nblock)
      if (!tblock->acct)
        cnt[tblock->desc-1]++;
  dba_printf ("\nLOST BLOCKS:\n\n");
  for (i=0;i<MAX_DESC;i++)
    if (cnt[i])
      dba_printf ("%20s - %6d\n", dba_dmalloc_desc_string(i), cnt[i]);
  dba_printf ("\nDone.\n\n");
#endif
}
