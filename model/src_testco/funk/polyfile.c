#include <stdio.h>
#include <math.h>
#include "igrtypedef.h"
#include "igr.h"
#include "bserr.h"
#include "bsparameters.h"

int polyfile (num_points, points)
int num_points;
double *points;
{
  char filename[20];
  int dim, funcval;
  FILE *datfile;
  int pywritefunk();

  printf ("Filename _: ");
  scanf ("%s", filename);
  datfile = fopen (filename, "w");

  if (datfile)
    {
    printf ("Dimension _: ");
    scanf ("%d", &dim);

    funcval = pywritefunk (datfile, dim, num_points, points);
  
    fclose (datfile);
    }
  else
    funcval = 0;

  return (funcval);
}



int polysfile (numgrp, numpts_grp, pts)
int numgrp, *numpts_grp;
double **pts;
{
  char filename[20];
  int i, dim, funcval;
  FILE *datfile;
  int pywritefunk();

  funcval = 1;
  printf ("Filename _: ");
  scanf ("%s", filename);
  datfile = fopen (filename, "w");
  if (datfile)
    {
    printf ("Dimension _: ");
    scanf ("%d", &dim);

    for (i=0; i<numgrp; i++)
      {
      funcval = pywritefunk (datfile, dim, numpts_grp[i], pts[i]);
      if (!funcval)
        break;
      }
    fclose (datfile);
    }
  else
    funcval = 0;
   
  return (funcval);
}


int cvpolyfile (cv)
struct IGRbsp_curve *cv;
{
  char filename[20];
  int dim, funcval;
  double tol;
  FILE *datfile;
  int pywritefunk();

  printf ("Filename _: ");
  scanf ("%s", filename);
  datfile = fopen (filename, "w");

  if (datfile)
    {
    printf ("Dimension _: ");
    scanf ("%d", &dim);

    printf ("Stroke tolerance (eg: 1e-07) _: ");
    scanf ("%lf", &tol);

    funcval = cvpywritefunk (datfile, dim, tol, cv);
  
    fclose (datfile);
    }
  else
    funcval = 0;

  return (funcval);
}


int pywritefunk (datfile, dim, num_points, points)
FILE *datfile;
int dim, num_points;
double *points;
{
  int i, funcval;
  double (*pts2d)[2], (*pts3d)[3];

  funcval = 1;
  fprintf (datfile, "%d\n", num_points);
  if (dim == 2)
    {
    pts2d = (double (*)[2])points;
    for (i=0; i<num_points; i++)
      fprintf (datfile, "%7.12lf %7.12lf\n", pts2d[i][0], pts2d[i][1]);
    }
  else if (dim == 3)
    {
    pts3d = (double (*)[3]) points;
    for (i=0; i<num_points; i++)
      fprintf (datfile, "%7.12lf %7.12lf %7.12lf\n", 
       pts3d[i][0], pts3d[i][1], pts3d[i][2]);
    }
  else
    {
    funcval = 0;
    printf ("Not supported\n");
    }

return (funcval);
}


int cvpywritefunk (datfile, dim, tol, cv)
FILE *datfile;
int dim;
double tol;
struct IGRbsp_curve *cv;
{
  int stat_func, numpts;
  long msg, bsmsg;
  double *pts=NULL, *pars=NULL, saved_cht;
  extern void BSchtptstcv(), BSchangepar();

  BSEXTRACTPAR (&msg, BSTOLCHRDHT, saved_cht);
  BSchangepar (&msg, BSTOLCHRDHT, tol);
  BSchtptstcv (cv, &numpts, &pts, &pars, &bsmsg);
  BSchangepar (&msg, BSTOLCHRDHT, saved_cht);
  if (bsmsg != BSSUCC)
    {
    fprintf (datfile, "Error on stroking curve - %d\n", bsmsg);
    stat_func = 0;
    }
  else
    {
    if (dim == 2)
      EM3dto2d (pts, numpts);
    pywritefunk (datfile, dim, numpts, pts);
    stat_func = 1;
    }

  if (pts)
    free (pts);
  if (pars)
    free (pars);
  return (stat_func); 
}


int prtmat (datfile, m, n, p)
FILE *datfile;
int m, n;
double *p;
{
  char filename[20];
  int i, j, here_file;

  here_file = 0;
  if (!datfile)
    {
    printf ("Filename _: ");
    scanf ("%s", filename);
    if (!strcmp (filename, "."))
      datfile = stderr;
    else
      {
      datfile = fopen (filename, "w");
      here_file = 1;
      }
    if (!datfile)
      {
      fprintf (stderr, "Could not open file\n");
      return (0);
      }
    }

  fprintf (datfile, "m = %d, n = %d\n", m, n);
  for (i=0; i<m; i++)
    {
    for (j=0; j<n; j++)
      fprintf (datfile, "%+20.16E\n", p[i*n + j]);
    fprintf (datfile, "\n");
    }

  if (here_file)
    fclose (datfile);

  return (1);
}

