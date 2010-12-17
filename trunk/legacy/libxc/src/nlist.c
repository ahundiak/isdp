#include <fcntl.h>

#define  NULL      (char *)0

#define  SYMBUFSZ    500        /* number of symbols to be buffered         */
#define  STRBUFSZ  20000        /* size of the string table buffer          */
#define  F_SYMSIZE    18        /* symbol table entry size before alignment */
#define  SYMSIZE      20        /* symbol table entry size after alignment  */

#define  MIN(x,y)  (((x) < (y)) ? (x) : (y))

#define  myread(descr,buf,num) \
\
if ((nbytes = read (descr, buf, num)) != (num))\
  goto errorret;

#define  myseek(descr,off,whence) \
\
if (lseek (descr, off, whence) == -1)\
  goto errorret;

#define  ushort  unsigned short

/* magic numbers */

#define NS32WRMAGIC	0524	/* NS32000 -- writeable text segments      */
#define NS32ROMAGIC	0524	/* NS32000 -- readonly shareable text segs */
#define CLIPPERMAGIC    0577    /* CLIPPER -- all types                    */

/* structure for the file header */

typedef struct {
                 ushort f_magic;  /* magic number                           */
                 ushort f_nscns;  /* number of section headers              */
                 long   f_timdat; /* time & date stamp - from time function */
                 long   f_symptr; /* file pointer to start of symbol table  */
                 long   f_nsyms;  /* number of entries in the symbol table  */
                 ushort f_opthdr; /* number of bytes in optional header     */
                 ushort f_flags;  /* flags                                  */

               } FILHDR;

#define FILHSZ sizeof( FILHDR )

/* defines to allow direct access to the symbol entry by field name */

#define n_name     n2.n2_name
#define n_zeros    n2.n3.n3_zeros
#define n_offset   n2.n3.n3_offset
#define n_value    n1_value
#define n_scnum    n1_scnum
#define n_type     n1_type
#define n_sclass   n1_sclass
#define n_numaux   n1_numaux

#define C_EXT      2          /* storeage class of external symbol */

/* structure for a symbol table entry */

typedef struct {
  union {
    char         n2_name[8];  /* symbol name if not in string table      */
    struct {
      long       n3_zeros;    /* zero indicates name is in string table  */
      long       n3_offset;   /* offset into string table                */
    } n3;
  } n2;
  long           n1_value;    /* symbol value - depends on storage class */
  short          n1_scnum;    /* section number of symbol                */
  ushort         n1_type;     /* basic and derived type specification    */
  ushort         n1_sclass:8; /* storage class of symbol                 */
  ushort         n1_numaux:8; /* number of auxiliary entries             */

} symentry;

/* nlist structure */

struct nlist {
               char  *name;
               long   value;
               short  scnum;
               ushort type;
               char   sclass;
               char   numaux;
             };

extern char *memcpy();
extern char *calloc();
extern void  free  ();
extern int   hashc ();

int nlist (filename, nl)

char         *filename;
struct nlist *nl;
{
  FILHDR         filehead;
  symentry      *entryptr;
  symentry       symbuffer[SYMBUFSZ];
  char           strbuffer[STRBUFSZ];
  char           special[9];
  char          *symend;
  char          *laststr;
  char          *nameptr;
  struct nlist **hashtab = NULL;
  struct nlist  *ptr;
  long           strindex = 0;
  long           strstart;
  long           symleft;
  long           strsize;
  int            strdescr;
  int            symdescr;
  int            maxhash;
  int            nbytes;
  int            index;

  /* count the number of nlist structs in the given array and zero out all the
     fields initially */

  for (index = 0, ptr = nl; ptr->name != NULL; index++, ptr++) {
    ptr->value  = 0;
    ptr->scnum  = 0;
    ptr->type   = 0;
    ptr->sclass = 0;
    ptr->numaux = 0;
  }

  /* open the file, read the fileheader, and verify the magic number */

  if ((symdescr = open (filename, O_RDONLY)) == -1 ||
      (strdescr = open (filename, O_RDONLY)) == -1    )
    return -1;
  myread (symdescr, &filehead, FILHSZ);
  if (filehead.f_magic != CLIPPERMAGIC)
    goto errorret;

  /* allocate a hash table large enough to hold pointers to each nlist
     structure (we need to be able to search them quickly) */

  maxhash = index * 3 / 2 + 1;
  hashtab = (struct nlist **)calloc (maxhash, sizeof (struct nlist *));

  /* construct the hash table for the requested names (using linear re-hash) */

  for (ptr = nl; ptr->name != NULL; ptr++) {
    index = hashc (ptr->name, maxhash);
    while (hashtab[index] != NULL)
      if (++index == maxhash)
        index = 0;
    hashtab[index] = ptr;
  }

  /* seek the symbol table descriptor to the start of the symbol table and
     initialize symbol buffering */

  myseek (symdescr, filehead.f_symptr, 0);
  entryptr = symend = symbuffer;
  symleft  = filehead.f_nsyms * F_SYMSIZE;

  /* read the string table size and initialize string table buffering */

  myseek (strdescr, strstart = filehead.f_symptr + symleft, 0);
  if ((nbytes = read (strdescr, &strsize, 4)) != 4)
    if (nbytes == -1)
      return -1;
    else strsize = 4;
  laststr = strbuffer;

  /* process the symbols in the input file */

  while (symleft > 0 || entryptr < symend) {

    /* if we are at the end of the buffer, it must be re-filled */

    if (entryptr >= symend) {
      myread (symdescr, symbuffer, MIN (symleft, SYMBUFSZ * F_SYMSIZE));
      entryptr = symbuffer;
      symend   = (char *)&symbuffer[nbytes / F_SYMSIZE];
      symleft -= nbytes;

      /* align the symbol table to be useful as an array */

      { char *toptr, *fromptr;
        char  temp[SYMSIZE];
        int   num;

        if ((num = nbytes / F_SYMSIZE) > 0) {
          toptr   = (char *)symbuffer +  SYMSIZE  * (num - 1);
          fromptr = (char *)symbuffer + F_SYMSIZE * (num - 1);
          for (; fromptr > symbuffer; fromptr -= F_SYMSIZE, toptr -= SYMSIZE) {
            memcpy (temp,  fromptr, F_SYMSIZE);
            memcpy (toptr, temp,    F_SYMSIZE);
          }
        }
      }
    }

    /* consider external names only! */

    if (entryptr->n_sclass == C_EXT) {

      /* determine the pointer to the symbol's name */

      if (entryptr->n_zeros == 0) {
        if ((nameptr = strbuffer + (entryptr->n_offset-strindex)) >= laststr) {
          myseek (strdescr, strstart + entryptr->n_offset, 0);
          myread (strdescr, nameptr = strbuffer,
                                 MIN (strsize - entryptr->n_offset, STRBUFSZ));
          for (laststr = strbuffer +nbytes; *(laststr-1) != '\0'; laststr--);
        }
      }
      else nameptr = memcpy (special, entryptr->n_name, 8);

      /* see if this symbol is in our hash table */

      ptr = hashtab[index = hashc (nameptr, maxhash)];
      while (ptr != NULL) {
        if (strcmp (nameptr, ptr->name) == 0)
          break;
        if (++index == maxhash)
          index = 0;
        ptr = hashtab[index];
      }

      /* fill in the data if we found it */

      if (ptr != NULL) {
        ptr->value  = entryptr->n_value;
        ptr->scnum  = entryptr->n_scnum;
        ptr->type   = entryptr->n_type;
        ptr->sclass = entryptr->n_sclass;
        ptr->numaux = entryptr->n_numaux;
      }
    }

    entryptr += entryptr->n_numaux + 1;
  }

  /* close files and return success */

  close (symdescr);
  close (strdescr);
  free (hashtab);
  return 0;

errorret:
  close (symdescr);
  close (strdescr);
  if (hashtab != NULL)
    free (hashtab);
  return -1;
}
