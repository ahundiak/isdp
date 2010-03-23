#define  _HASH_PVT 1
#include "hash.h"

#undef   MBLOCK
#define  MBLOCK  0x80

#define  GETRECORDS {\
\
int    asize, nbytes;\
char **ptr;\
\
asize = (table->recsize + sizeof(char*) - 1) / sizeof(char*) * sizeof(char*);\
ptr   = (char **)(table->rfree = malloc (nbytes = table->tbllength * asize));\
Vndx(table->ptrs, table->psize++) = (void *)ptr;\
while ((char *)ptr < (char *)table->rfree + (nbytes - asize))\
  ptr = (char **)(*ptr = (char *)ptr + asize);\
*ptr = 0;\
}

#define  GETHEADERS {\
\
HCHAIN *ptr;\
\
table->hfree = (HCHAIN *)malloc (table->tbllength * sizeof (HCHAIN));\
Vndx(table->ptrs, table->psize++) = (void *)(ptr = table->hfree);\
while (ptr < table->hfree + (table->tbllength - 1)) {\
  ptr->next = ptr + 1;\
  ptr++;\
}\
ptr->next = 0;\
}

#define  KEY(rec) (table->options & INDKEY ? \
       *(char **)((char *)rec + table->koffset) : (char *)rec + table->koffset)
