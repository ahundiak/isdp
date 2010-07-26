#include "mallocdbg.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
#include <sys/param.h>

#define SEPARATOR_C	'/'
#define SEPARATOR_S	"/"
#elif defined(NT)
#include <stdlib.h>
#define SEPARATOR_C	'\\'
#define SEPARATOR_S	"\\"
#define stat _stat
#else
#error Unknown OS
#endif

char *string_malloc(a)
char *a;
 {
  char *b;
  int i;

  i = strlen (a) + 1;
  i = (i & 0xfffffffc) + 4;
  b = (char *) malloc (i);
  strcpy (b,a);
  return (b);
 }

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
static struct
 {
  char n[16];
 } fnames[32];
#elif defined(NT)
static struct
 {
  char n[_MAX_PATH];
 } fnames[32];
#else
#error Unknown OS
#endif

static void unpack (p)
char *p;
 {
  int i;
  int j;
 
  for (i=0; i<32; i++) fnames[i].n[0]=0;

  if (!p) return;
  if (!(*p)) return;

  i = 0;
  j = 0;
  if ((*p) == SEPARATOR_C)
   {
    fnames[0].n[0] = SEPARATOR_C;
    fnames[0].n[j+1] = 0;
    i = 1;
    j = 0;
    p++;
   }
  while (*p)
   {
    if ((*p) == SEPARATOR_C)
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


static void reduce ()
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


static void pack (p)
char *p;
 {
  int i;

  if (!strcmp(fnames[0].n,SEPARATOR_S))
   {
    strcpy (p,SEPARATOR_S);
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
      strcat (p,SEPARATOR_S);
      strcat (p,fnames[i].n);
     }
    i++;
   }
 }


static void reduce_pth (p)
char *p;
 {
  unpack (p);
  reduce ();
  pack (p);
 }



static int is_file (f)
char *f;
 {
  struct stat statbuff;
  int i;

  i = stat (f,&statbuff);
  if (i) return (0);
  return (1);
 }


struct dtree_node
 {
  char *fname;
  struct dtree_node *next,*dep;
 };


static struct dtree_node *filelist=0;


void ff_free()
 {
  struct dtree_node *tt;
  while (filelist)
   {
    tt = filelist->next;
    free (filelist->fname);
    free (filelist);
    filelist = tt;
   }
 }


static struct dtree_node *new_dtree_node (a)
char *a;
 {
  struct dtree_node *c;

  c = (struct dtree_node *)malloc (sizeof (struct dtree_node));
  c->fname = string_malloc (a);
  c->next = 0;
  c->dep = 0;
  return (c);
 }


void ff_add (a)
char *a;
 {
  struct dtree_node *c;
  struct dtree_node *d;

  c = new_dtree_node (a);
  if (filelist)
   {
    d = filelist;
    while (d->next) d = d->next;
    d->next = c;
   }
  else
   {
    filelist = c;
   }
  c->next = 0;
 }


static void gobble_filename (a)
char *a;
 {
  int i;

  i = strlen (a);
  while (i--)
   {
    if (a[i] == SEPARATOR_C) return;
    a[i] = 0;
   }
 }

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
static char file_name[MAXPATHLEN];
#elif defined(NT)
static char file_name[_MAX_PATH];
#else
#error Unknown OS
#endif

static int	is_absolute_path(char *path)
{
	if (path[0] == SEPARATOR_C
#if defined(NT)
		||
	(path[1] == ':' && (path[0] >= 'A' && path[0] <= 'Z' || path[0] >= 'a' && path[0] <= 'z'))
#endif
	)
		return 1;
	return 0;
}

char *find_file (mode,fn,cf)
int mode;
char *fn;
char *cf;
 {
  struct dtree_node *p;

  if (is_absolute_path(fn))
   {
    strcpy (file_name,fn);
    reduce_pth (file_name);
    if (is_file(file_name))
     return (file_name);
    else
     {
      return (0);
     }
   }
  else
   {
    if (mode == '\"')
     {
      strcpy (file_name,cf);
      gobble_filename (file_name);
      strcat (file_name,fn);
      reduce_pth (file_name);
      if (is_file(file_name))
       return (file_name);
     }
    p = filelist;
    while (p)
     {
      strcpy (file_name,p->fname);
      strcat (file_name,SEPARATOR_S);
      strcat (file_name,fn);
      reduce_pth (file_name);
      if (is_file(file_name))
       return (file_name);
      p = p->next;
     }
    return (0);
   }
 }
