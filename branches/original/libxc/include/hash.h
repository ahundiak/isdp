#ifndef _HASH_H
#define _HASH_H 1

#include "vla.h"

extern int _hashblk;

/* defines for hashing options */

#define  INDKEY    0x01   /* key field is a pointer to actual key           */
#define  VLREC     0x02   /* records are varying length                     */
#define  DUPS      0x04   /* allows addition of records with duplicate keys */
#define  NOMEM     0x08   /* disables hash record memory management         */
#define  MALLOC    0x10   /* allocate fixed length records individually     */
#define  KEEP      0x20   /* don't free records after removal from table    */
#define  FREE      0x40   /* free records upon removal with NOMEM option    */

#define  MBLOCK(x) (_hashblk = (x), 0x80)   /* keep all hash table data in  */
                                            /* a contiguous BLOCK of memory */
                                            /* (hashed records could move!) */
                                            /* ignored unless compiled with */
                                            /* the EMALLOC switch           */

typedef struct h_chain {
                         struct h_chain *next;    /* next collision    */
                         void           *record;  /* ptr to the record */

                       } HCHAIN;

typedef struct {
                 short       options;      /* options for this table         */
                 short       koffset;      /* record offset of key field     */
                 short       recsize;      /* record size (0 for var length) */
                 char        linear;       /* =1 when linear traversal active*/
                 char        delete;       /* =1 when delete in linear mode  */
                 int         blkno;        /* block number if MBLOCK option  */
                 int         tbllength;    /* current length of the table    */
                 int       (*hashfn) ();   /* function to generate hash index*/
                 int       (*compfn) ();   /* function to compare keys       */
                 HCHAIN     *hfree;        /* list of free chain headers     */
                 void       *rfree;        /* list of free records (fix len) */
                 vla(void *) ptrs;         /* array of allocated ptrs        */
                 int         psize;        /* number of ptrs in "ptrs"       */
                 int         c_index;      /* hash index of "current" entry  */
                 HCHAIN     *c_chain;      /* chain header of "current" entry*/
                 HCHAIN     *body[1];      /* ptrs to collision chains       */

               } HASHTABLE;


/* Macros for hash records of "naked" types (ie. the whole hash record is the
   hash key) */

#define  NAKEDKEY     _KEY_field
#define  NAKED(type)  struct { type _KEY_field; }

/* Function macros */

#define  hashinit(rtype,tsize,hashfn,compfn,kfield,opts) \
\
_hashinit (tsize, hashfn, compfn, (int)&((rtype *)0)->kfield, \
							sizeof (rtype), opts)

#if defined(__STDC__) || defined(__cplusplus)
#define  hashinfo(table)  _hashinfo (table, #table)
#else
#define  hashinfo(table)  _hashinfo (table, "table")
#endif

/* routines */

#if defined(__cplusplus)
extern "C" {
#endif
#if (defined(__STDC__) || defined(__cplusplus)) && !defined(_HASH_PVT)
extern int        strcmp     (const char *, const char *);
extern int        hashc      (const char *string, int tablesize);
extern HASHTABLE *_hashinit  (int tsize, int (*hashfn)(), int (*compfn)(),
                                          int koffset, int rsize, int options);
extern void       _hashinfo  (HASHTABLE *table, const char *name);
extern void      *hashadd    (HASHTABLE *table, void *record,
							    void *dupptr, ...);
extern void      *hashlookup (HASHTABLE *table, void *keyptr);
extern int        hashdlookup (HASHTABLE *table, void *keyptr, void *arrayptr);
extern void      *hashnext   (HASHTABLE *table);
extern void      *hashrpl    (HASHTABLE *table, void *record, ...);
extern int        hashdel    (HASHTABLE *table);
extern int        hashdelrec (HASHTABLE *table, void *record);
extern void       hashfree   (HASHTABLE *table);
#else  /* K&R "C" */
extern int        strcmp      ();
extern int        hashc       ();
extern HASHTABLE *_hashinit   ();
extern void       _hashinfo   ();
extern void      *hashadd     ();
extern void      *hashlookup  ();
extern int        hashdlookup ();
extern void      *hashnext    ();
extern void      *hashrpl     ();
extern int        hashdel     ();
extern int        hashdelrec  ();
extern void       hashfree    ();
#endif
#if defined(__cplusplus)
}
#endif

#endif
