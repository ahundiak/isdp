#include <memory.h>

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

#include "PWapi/inspts.h"

static void InsertPts
(
  int dim,
  int numinspts,
  double *p_inspts,
  int atinx,
  int numpts,
  double *p_pts
);

void pwInsertDouble
(
  int numinspts,
  double *p_inspts,
  int atinx, 
  int numpts,
  double *p_pts
)
{
  InsertPts (1, numinspts, p_inspts, atinx, numpts, p_pts);
  return;
}
  
void pwInsertPts2d 
(
  int numinspts,
  PWpoint2d *p_inspts,
  int atinx,
  int numpts,
  PWpoint2d *p_pts
)
{
  InsertPts (2, numinspts, (double *) p_inspts, atinx, numpts, 
            (double *) p_pts);
  return;
}

void pwInsertPts
(
  int numinspts,
  PWpoint *p_inspts,
  int atinx,
  int numpts,
  PWpoint *p_pts
)
{
  InsertPts (3, numinspts, (double *) p_inspts, atinx, numpts, 
            (double *) p_pts);
  return;
}

static void InsertPts 
(
  int dim,
  int numinspts,
  double *p_inspts,
  int atinx,
  int numpts,
  double *p_pts
) 
{
  int blksize=0;

  blksize = (numpts - atinx) * dim * sizeof (IGRdouble);
  memmove (&p_pts[(atinx + numinspts) * dim], &p_pts[atinx * dim], blksize);

  blksize = numinspts * dim * sizeof (IGRdouble);
  memcpy (&p_pts[atinx * dim], p_inspts, blksize);

  return;
}
