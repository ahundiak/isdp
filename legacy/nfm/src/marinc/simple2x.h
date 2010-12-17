#ifndef SHINDEXSTRUDEFINED
#define SHINDEXSTRUDEFINED
struct shindexstru {
  unsigned short whichshape;
  unsigned long  fileloc;
} ;
#endif

extern struct shindexstru simpindptr[];
extern unsigned char simpfontstrs[34][128];
