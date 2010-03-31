#include <stdio.h>
#include <alloca.h>
#include <math.h>
#include <memory.h>
#include <malloc.h>
#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/memfunc.h"

static void SwapMem
(
  char *m1,
  char *m2,
  int size
);


/*
  DESCRIPTION

  The following functions swap the contents of memory that represents
  different data types.
*/

void pwSwapDouble 
(
  double *d1,
  double *d2
)
{
  SwapMem ((char *) d1, (char *) d2, sizeof (double));
  return;
}

void pwSwapInt 
(
  int *i1,
  int *i2
)
{
  SwapMem ((char *) i1, (char *) i2, sizeof (int));
  return;
}

void pwSwapPt2d
(
  PWpoint2d pt1,
  PWpoint2d pt2
)
{
  SwapMem ((char *) pt1, (char *) pt2, sizeof (PWpoint2d));
  return;
}

void pwSwapPt
(
  PWpoint pt1,
  PWpoint pt2
)
{
  SwapMem ((char *) pt1, (char *) pt2, sizeof (PWpoint));
  return;
}

static void SwapMem
(
  char *m1,
  char *m2,
  int size
)
{
  char *tmp_m=NULL;

  tmp_m = (char *) alloca (size);
  memcpy (tmp_m, m1, size);
  memcpy (m1, m2, size);
  memcpy (m2, tmp_m, size);

  return;
}

/*
  DESCRIPTION

  The following functions increase (or decrease) the dimension of points,
  working on the Z dimension as the expendable one (Z=0.0). The input and 
  output pointers for the 3dTo2d function CAN be the same, whereas, the memory
  for the 2dTo3d must point to separate memory. All of the output memory
  must be pre-allocated by the caller.
*/

void pwCnvt3dTo2d 
(
  int numpts,
  PWpoint *pts,
  PWpoint2d *pts2d
)
{
  int i, j, inxlim, blksize;
  double *a, *b;

  blksize = 2 * sizeof (double);
  a = (double *) pts;
  b = (double *) pts2d;
  inxlim = numpts * 3;
  for (i=0, j=0; i<inxlim; i+=3, j+=2)
    memmove (&b[j], &a[i], blksize);
  
  return;
}


void pwCnvt2dTo3d 
(
  int numpts,
  PWpoint2d *pts2d,
  PWpoint *pts
)
{
  int i, j, inxlim, blksize;
  double *a, *b;

  blksize = 2 * sizeof (double);
  a = (double *) pts2d;
  b = (double *) pts;
  inxlim = numpts * 2;
  for (i=0, j=0; i<inxlim; i+=2, j+=3)
  {
    memmove (&b[j], &a[i], blksize);
    b[j+2] = 0.0;
  }

  return;
}


/*
  DESCRIPTION

  This function takes in an address of a pointer to memory that needs to
  be malloced or realloced to accomodate 'num_objs'. The mallocing (or the
  reallocing) if required, is done in 'chunk_size', where chunk_size is
  specified in terms of number of objects. The 'obj_size' specifies the 
  number of  bytes per object. The function returns FALSE if the memory could 
  not be allocated.  


  NOTE 

  It is assumed that any  memory allocation has been done solely
  by this function and without changes to 'chunks' and 'obj_size' across
  the calls.
*/

PWresult pwMemInChunks
(
  int num_objs,
  void **p_objs,
  int obj_size,
  int chunk_size
)
{
  int curr_num_objs;
  PWresult result=PW_K_Success;

  if (num_objs)
  {
    curr_num_objs = num_objs-1;
    if (! (curr_num_objs % chunk_size))
    {
      if (!curr_num_objs)
      {
        *p_objs = (void *) malloc (obj_size * 
                     chunk_size);
      }
      else
      {
        *p_objs = (void *) realloc (*p_objs, obj_size * 
                     (curr_num_objs + chunk_size));
      }
      OnErrorState (!*p_objs, result, SetError (PW_K_Pathway, PW_K_Memory),
       wrapup);
    }
  }

wrapup:
  PW_Wrapup (result, "pwMemInChunks");
  return (result);
}


/* 
    Description:  The following api is provided to free the memory allocated
                  by any function/method in miniems 
*/

void pwFree
(
  void *ptr
)
{

  if(NULL != ptr)
  {
    free(ptr);
  }
  return;
}

