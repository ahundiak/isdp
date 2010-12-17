
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

static struct
 {
  char n[16];
 } fnames[32];


static unpack (p)
char *p;
 {
  int i;
  int j;
 
  for (i=0; i<32; i++) fnames[i].n[0]=0;

  if (!p) return;
  if (!(*p)) return;

  i = 0;
  j = 0;
  if ((*p) == '/')
   {
    fnames[0].n[0] = '/';
    fnames[0].n[j+1] = 0;
    i = 1;
    j = 0;
    p++;
   }
  while (*p)
   {
    if ((*p) == '/')
     {
      fnames[i].n[j] = 0;
      i++;
      j = 0;
     }
    else
     {
      fnames[i].n[j] = *p;
      j++;
     }
    p++;
   }
  fnames[i].n[j] = 0;
 }


static int previous (i)
int i;
 {
  int j;

  j = i-1;
  while (1)
   {
    if (j == -1) return (j);
    if (fnames[j].n[0] != 0) return (j);
    j--;
   }
 }


static reduce ()
 {
  int i;
  int j;

  i = 0;
  while (i < 32)
   {
    if (!strcmp(fnames[i].n,".."))
     {
      j = previous (i);
      if (j != -1)
       {
        if (!strcmp(fnames[j].n,".."))
         {
         }
        else if (!strcmp(fnames[j].n,"."))
         {
          fnames[j].n[0] = 0;
         }
        else
         {
          fnames[i].n[0] = 0;
          fnames[j].n[0] = 0;
         }
       }
     }
    else if (!strcmp(fnames[i].n,"."))
     {
/*
      j = previous (i);
      if (j != -1)
*/
       fnames[i].n[0] = 0;
     }
    i++;
   }
 }


static pack (p)
char *p;
 {
  int i;

  if (!strcmp(fnames[0].n,"/"))
   {
    strcpy (p,"/");
    i = 1;
   }
  else
   {
    *p = 0;
    i = 0;
   }
  while (i<32)
   {
    if (fnames[i].n[0] != 0)
     {
      strcat (p,fnames[i].n);
      break;
     }
    i++;
   }
  i++;
  while (i<32)
   {
    if (fnames[i].n[0] != 0)
     {
      strcat (p,"/");
      strcat (p,fnames[i].n);
     }
    i++;
   }
 }


reduce_pth (p)
char *p;
 {
  unpack (p);
  reduce ();
  pack (p);
 }
