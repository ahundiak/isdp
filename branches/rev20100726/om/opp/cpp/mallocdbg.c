#include <stdio.h>
#include <stdlib.h>

struct memory_hunk
 {
  void *address;
  long int size;
  int line;
  char *filename;
  struct memory_hunk *next;
 };


static struct memory_hunk *active_list;
static struct memory_hunk *free_list;

static int free_count=0,malloc_count=0;
static void *breakpoint=0;


void *dbg_malloc (s,l,f)
int l;
char *f;
long int s;
 {
  struct memory_hunk *t;

  malloc_count++;
  if (free_list)
   {
    t = free_list;
    free_list = t->next;
   }
  else
   t = (struct memory_hunk *) malloc (sizeof(struct memory_hunk));
  t->next = active_list;
  active_list = t;
  t->address = malloc (s);
  t->size = s;
  t->line = l;
  t->filename = f;
  if (breakpoint) if (breakpoint == t->address) abort();
  return (t->address);
 }


void dbg_free (a,l,f)
int l;
char *f;
void *a;
 {
  struct memory_hunk *t,*lt;

  free_count++;
  t = active_list;
  lt = 0;
  while (t)
   {
    if (t->address == a)
     {
      if (lt)
       lt->next = t->next;
      else
       active_list = t->next;
      free(a);
      t->next = free_list;
      free_list = t;
      return;
     }
    lt = t;
    t = t->next;
   }
  fprintf (stderr,"freedom of non-malloced address\n");
  fprintf (stderr,"file: %s, line: %d/n",l,f);
  abort();
 }


void malloc_debug_summary()
 {
  struct memory_hunk *t,*t1;
  int ts=0;

  if (malloc_count!=free_count)
   fprintf (stderr,"call count: malloc:%d, free:%d\n",malloc_count,free_count);
  if (active_list)
   {
    fprintf (stderr,"unresolved mallocs\n");
    t = active_list;
    while (t)
     {
      ts += t->size;
      t1 = active_list;
      while (t1!=t)
       {
        if ((!strcmp(t1->filename,t->filename))&&(t->line==t1->line))
         break;
        t1 = t1->next;
       }
      if (t1==t)
       {
        fprintf (stderr," file:%s, line:%d, add:%d\n",t->filename,t->line,t->address);
       }
      t = t->next;
     }
    fprintf (stderr,"%d bytes not deallocated\n");
   }
 }
