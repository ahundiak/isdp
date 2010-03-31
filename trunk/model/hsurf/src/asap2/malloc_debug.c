
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

#include <stdio.h>

unsigned int total_malloc_bytes  = 0;
unsigned int total_calloc_bytes  = 0;
unsigned int total_realloc_bytes = 0;
unsigned int total_free_bytes    = 0;
unsigned int alloc_high_water    = 0;
unsigned int largest_alloc_sz[3] = {0, 0, 0};

#define GETSIZE(p)  ((*(int *)((char *)p -16))& (~1))
#define FREE(p)     ((*(int *)((char *)p -16))& (1))
#define ALLOCSIZE(size)  (((size + 15) & ~15) +16)

char *Malloc (size)
  unsigned int size;
{
  char *p;

  p = (char *) calloc (1, size);
  if (p == NULL)
    alloc_error_print ("Malloc", 0, size, alloc_high_water);
  else
    total_malloc_bytes += ALLOCSIZE(size);
  check_largest (size);
  return p;
}

char *Calloc (count, size)
  unsigned int count;
  unsigned int size;
{
  char *p;

  p = (char *) calloc (count, size);
  if (p == NULL)
    alloc_error_print ("Calloc", count, size, alloc_high_water);
  else
    total_calloc_bytes += (size * count);
  check_largest (size);
  return p;
}

char *Realloc (ptr, size)
  char *ptr;
  unsigned int size;
{
  char *p;
  unsigned int oldsize = GETSIZE(ptr);

  p = (char *) realloc (ptr, size);
  if (p == NULL)
    alloc_error_print ("Realloc", 0, size, alloc_high_water);
  else
    total_realloc_bytes += (size - oldsize);
  check_largest (size);
  return p;
}

void Free(ptr)
   char *ptr;
{
  if (ptr == NULL)
    {
    fprintf (stderr, "Freeing NULL ptr returning NULL\n");
    alloc_statistics_print (alloc_high_water);
    }
  else if (FREE(ptr))
    {
    fprintf (stderr, "Free ptr (0x%x) already free\n", ptr);
    alloc_statistics_print (alloc_high_water);
    }
  else
    total_free_bytes += GETSIZE(ptr);

  free(ptr);
}

alloc_statistics_print (where)
  unsigned int where;
{
  fprintf (stderr, "total malloc   %u\n", total_malloc_bytes);
  fprintf (stderr, "total calloc   %u\n", total_calloc_bytes);
  fprintf (stderr, "total realloc  %u\n", total_realloc_bytes);
  fprintf (stderr, "total free     %u\n", total_free_bytes);
  fprintf (stderr, "alloc high mk  %u\n", alloc_high_water);
  fprintf (stderr, "largest allocs %u\n", largest_alloc_sz[0]);
  fprintf (stderr, "               %u\n", largest_alloc_sz[1]);
  fprintf (stderr, "               %u\n", largest_alloc_sz[2]);
  if (where)
    fprintf (stderr, "called from    0x%x\n", where);
}

static alloc_error_print (which, count, size, where)
  char *which;
  unsigned int count, size, where;
{
  if (count)
    fprintf (stderr, "%s (%d, %d) returning NULL\n", which, count, size);
  else
    fprintf (stderr, "%s (%d) returning NULL\n", which, size);
  alloc_statistics_print (where);
}

static check_largest (size)
  unsigned int size;
{
  unsigned int x;

  if (size > largest_alloc_sz[0])
  {
    largest_alloc_sz[2] = largest_alloc_sz[1];
    largest_alloc_sz[1] = largest_alloc_sz[0];
    largest_alloc_sz[0] = size;
  }
  else if (size > largest_alloc_sz[1] && size < largest_alloc_sz[0])
  {
    largest_alloc_sz[2] = largest_alloc_sz[1];
    largest_alloc_sz[1] = size;
  }
  else if (size > largest_alloc_sz[2] && size < largest_alloc_sz[1])
    largest_alloc_sz[2] = size;
  x = total_malloc_bytes + total_calloc_bytes + total_realloc_bytes
      - total_free_bytes;
  if (x > alloc_high_water)
    alloc_high_water = x;
}
