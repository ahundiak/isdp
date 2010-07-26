
#include <malloc.h>
#include <stdio.h>

#define MAX_COUNTER 2000

struct opp_malloc_ident
 {
  int line;
  char *file;
 };

struct memory_hunk
 {
  struct memory_hunk *flink, *blink;
  struct opp_malloc_ident *id;
  int size;
 };

static int max_fast = -1;
static int small_count = 0;

#ifdef DEBUG
static int malloced_space = 0;
static int freed_space = 0;
static struct memory_hunk *big_list = 0;
static int allo_counts[MAX_COUNTER] = {0};
static int deal_counts[MAX_COUNTER] = {0};
static struct memory_hunk *allo_lists[MAX_COUNTER] = {0};

void opp_malloc_report ()
 {
  fprintf (stderr, "\nReport of Malloced Memory Usage\n");
  fprintf (stderr, "small block size     = %d\n", max_fast);
  fprintf (stderr, "small block count    = %d\n", small_count);
  fprintf (stderr, "total malloced space = %d\n", malloced_space);
  fprintf (stderr, "total freed space    = %d\n", freed_space);
  fprintf (stderr, "net malloced space   = %d\n",
	   malloced_space - freed_space);
  fprintf (stderr, "current sbrk value   = %d\n", sbrk(0));
  fprintf (stderr, "maximum sbrk value   = %d\n", ulimit(3,0));

  fprintf (stderr, "\nSummary of Requested Byte Counts\n");
  fprintf (stderr, "       Allocated       Deallocated      Net\n");
  fprintf (stderr, " Size  Count   Bytes    Count   Bytes    Count   Bytes\n");
  {
   int i, temp;

   for (i = 0; i < MAX_COUNTER; ++i)
    if (allo_counts[i])
     fprintf (stderr, "%5d  %6d %8d  %6d %8d  %6d %8d\n", i,
	      allo_counts[i], allo_counts[i]*i,
	      deal_counts[i], deal_counts[i]*i,
	      allo_counts[i] - deal_counts[i],
	      (allo_counts[i] - deal_counts[i])*i);
  }

  fprintf (stderr, "\nSummary of Outstanding Memory by Allocation Site\n");
  fprintf (stderr, " File, line       Size  Count   Bytes \n");

  while (big_list)
  {
   int i;
   struct opp_malloc_ident *id;
   struct memory_hunk *p;
   struct memory_hunk *big_hunks = 0;
   int total = 0;
   
   for (i = 0; i < MAX_COUNTER; ++i) allo_counts[i] = 0;

   p = big_list;
   id = p->id;
 
   while (p)
    {
     struct memory_hunk *next_p = p->flink;

     if (p->id == id)
      {
       /* remove p from list */
       if (p->flink) p->flink->blink = p->blink;
       if (p->blink)
        p->blink->flink = p->flink;
       else
        big_list = p->flink;

       /* count p */
       if (p->size < MAX_COUNTER)
        ++allo_counts[p->size];
       else
	{
	 p->flink = big_hunks;
         big_hunks = p;
        }
       total += p->size;
      }
     p = next_p;
    }
     
   fprintf (stderr, "%s, %d\n", id->file, id->line);
   fprintf (stderr, "            --------  ------ %8d\n", total);
   for (i = 0; i < MAX_COUNTER; ++i)
    if (allo_counts[i])
     fprintf (stderr, "            %8d  %6d %8d\n",
      i, allo_counts[i], allo_counts[i]*i);
   for (;big_hunks; big_hunks = big_hunks->flink)
     fprintf (stderr, "            %8d  %6d %8d\n",
       big_hunks->size, 1, big_hunks->size);
  }
 
  fflush(stderr);
 }/* opp_malloc_report */

void bad_item (p)
 struct memory_hunk *p;
 {
  register struct memory_hunk *mh;
  fprintf (stderr, " - address = %d(%x) : size = %d : id = %d(%x)\n",
		     p, p, p->size, p->id, p->id);
  for (mh = big_list; mh; mh = mh->flink) if (mh->id == p->id) break;
  if (mh)
   fprintf (stderr, " - allocated at %s, %d\n", mh->id->file, mh->id->line);
  opp_malloc_report ();
  *(int *)0 = 0; /* bus error */
  exit (1);
 } /* bad_item */

void opp_free (p)
 struct memory_hunk *p;
 {
  --p;
  if (!(((int*)p)[-1] & 1))
   {
    printerr (1);
    fprintf (stderr, " internal error : attempt to free item twice\n");
    bad_item (p);
   }
  freed_space += p->size;

  if (p->size < MAX_COUNTER) ++deal_counts[p->size];
  if (p->size <= max_fast) --small_count;

  if (p->blink)
   {
    if (!(((int*)p->blink)[-1] & 1))
     {
      printerr (1);
      fprintf (stderr, " an item has been freed without opp_free\n");
      bad_item (p->blink);
     }
    p->blink->flink = p->flink;
   }
  else
   big_list = p->flink;

  if (p->flink)
   {
    if (!(((int*)p->flink)[-1] & 1))
     {
      printerr (1);
      fprintf (stderr, " an item has been freed without opp_free\n");
      bad_item (p->flink);
     }
    p->flink->blink = p->blink;
   }

  free (p);
 } /* opp_free */

char *opp_malloc (byte_count, id, line, file)
 int byte_count;
 struct opp_malloc_ident *id;
 int line;
 char *file;
 {
  register struct memory_hunk *mh;
  register int *p;
  register int i;
#ifdef DEBUG
  id->line = line;
  id->file = file;
  if (!malloced_space)
   {
    fprintf (stderr,"opp_malloc : initial sbrk value = %d\n", sbrk(0));
    fprintf (stderr,"           : maximum sbrk value = %d\n", ulimit(3,0));
   }
  mh = (struct memory_hunk *) malloc (sizeof (*mh) + byte_count);
  if (mh)
   {
    if (byte_count <= max_fast) ++small_count;
    malloced_space += byte_count;
    if (byte_count < MAX_COUNTER) ++allo_counts[byte_count];
    mh->id = id;
    mh->size = byte_count;
    mh->blink = 0;
    mh->flink = big_list;
    if (mh->flink)
     {
      if (!(((int*)mh->flink)[-1] & 1))
       {
        printerr (1);
        fprintf (stderr, " an item has been freed without opp_free\n");
	bad_item (mh->flink);
       }
      mh->flink->blink = mh;
     }
    big_list = mh;
    return (char *) (mh+1);
   }
#else
  p = malloc (byte_count);
  if (p)
   {
    if (byte_count <= max_fast) ++small_count;
    return p;
   }
#endif

  printerr (1);
  fprintf (stderr, " no available dynamic memory.\n");
  fprintf (stderr, " - requested byte count = %d\n", byte_count);

  opp_malloc_report ();

  *(char *)0 = 0; /* force bus error */
  exit (1); /* just in case it failed */
 } /* opp_malloc */
#endif

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
void opp_init_malloc_size (size)
 int size;
 {
  if (size > max_fast && !small_count)
#ifdef DEBUG
   mallopt (M_MXFAST, (max_fast = size) + sizeof (struct memory_hunk));
#else
   mallopt (M_MXFAST, max_fast = size);
#endif
 } /* opp_init_malloc_size */
#endif
