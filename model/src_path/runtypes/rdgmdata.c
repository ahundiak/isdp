#include <stdio.h>
#include <malloc.h>
#include <string.h>

#include "PWminimum.h"
#include "PWattrib.h"
#include "PWgmdata.h"

#include "bsgeom_cvsf.h"
#include "bsreadbspc.h"
#include "bsreadbsps.h"

#include "PWapi/rdgmdata.h"
#include "PWapi/strfunc.h"


static PWboolean read_py
(
  FILE *file,
  char *in_py,
  PWboolean is_3d
);


/*
  DESCRIPTION
 
  The following functions return the corresponding enumerated type given
  an ASCII string.
*/

enum PWcvdatatype pwCvtypeFromString 
(
  char *str
)
{ 
  char str1[PW_K_MaxCharOnLine+1], str2[PW_K_MaxCharOnLine+1];
  enum PWcvdatatype cvtype=PWcvdata_null;
  
  if (sscanf (str, "%s %s", str1, str2) == 2)
  {
    if (pwFuzzyMatch (str1, "Pt") && pwFuzzyMatch (str2, "2d"))
      cvtype = PWcvdata_pt2d;
    else if (pwFuzzyMatch (str1, "Py") && pwFuzzyMatch (str2, "2d"))
      cvtype = PWcvdata_py2d;
    else if (pwFuzzyMatch (str1, "Bsp") && pwFuzzyMatch (str2, "Cv"))
      cvtype = PWcvdata_bspcv;
    else if (pwFuzzyMatch (str1, "Geom") && pwFuzzyMatch (str2, "Cv"))
      cvtype = PWcvdata_gmbspcv;
  }
  else if (sscanf (str, "%s", str1) == 1)
  {
    if (pwFuzzyMatch (str1, "Pt"))
      cvtype = PWcvdata_pt;
    else if (pwFuzzyMatch (str1, "Py"))
      cvtype = PWcvdata_py;
  }

  return (cvtype);
}

enum PWsfdatatype pwSftypeFromString
(
  char *str
)
{ 
  char str1[PW_K_MaxCharOnLine+1], str2[PW_K_MaxCharOnLine+1];
  enum PWsfdatatype sftype=PWsfdata_null;
  
  if (sscanf (str, "%s %s", str1, str2) == 2)
  {
    if (pwFuzzyMatch (str1, "Bsp") && pwFuzzyMatch (str2, "Sf"))
      sftype = PWsfdata_bspsf;
    else if (pwFuzzyMatch (str1, "Geom") && pwFuzzyMatch (str2, "Sf"))
      sftype = PWsfdata_gmbspsf;
  }
  else if (sscanf (str, "%s", str1) == 1)
  {
    if (pwFuzzyMatch (str1, "Pl"))
      sftype = PWsfdata_plane;
  }

  return (sftype);
}


/*
  DESCRIPTION
  
  The following function reads in a curve (or a surface) definition from a
  file. The file-pointer is input. If a specific curve (or surface) datatype
  is being looked for, then one could use the type specific function.

  The function looks for the first occurence in the given file (from the
  current location in the file) of a 'geometry' record that conforms to the
  relevant datatype. A 'geometry' record is denoted by a "+" as the first 
  field on a separate line. The following field, on the same line, is the
  geometry type. The lines that follow that go to define the geometry are
  then well known and the read will stop soon after the last line of the
  definition is read. Thus, a second invocation of this can be used to search
  for the next occurrence of similar geometry.
   
  The function returns TRUE if could find a geometry record and has
  successfully read it into the output. The memory in the output, if 
  applicable, is malloced as a single pointer.
*/

PWboolean pwReadCvdata 
(
  FILE *file,
  struct PWcvdata *cvdata
)
{
  char line[PW_K_MaxCharOnLine+1], token[PW_K_MaxCharOnLine+1];
  int inx, filepos;
  PWboolean is_success=FALSE, record_found=FALSE;;

  while (filepos = ftell (file), fgets (line, PW_K_MaxCharOnLine, file))
  {
    if (pwNumFields (line) < 2)
      continue;

    pwFieldInStr (FIRST, line, token);
    if (strcmp (token, "+") == STRING_MATCH)
    {
      fseek (file, filepos, 0);
      inx = pwGetInxOfField (FIRST, line);
      switch (cvdata->datatype = pwCvtypeFromString (&line[inx+1]))
      {
        case PWcvdata_pt2d:
          is_success = pwReadPt2d (file, cvdata->data.pt2d);
          record_found = TRUE;
          break;

        case PWcvdata_pt:
          is_success = pwReadPt (file, cvdata->data.pt);
          record_found = TRUE;
          break;

        case PWcvdata_py2d:
          is_success = pwReadPy2d (file, &cvdata->data.py2d);
          record_found = TRUE;
          break;
  
        case PWcvdata_py:
          is_success = pwReadPy (file, &cvdata->data.py);
          record_found = TRUE;
          break;

        case PWcvdata_bspcv:
          cvdata->data.p_bspcv = NULL;
          cvdata->data.p_bspcv = (struct IGRbsp_curve *) 
                                 malloc (sizeof (struct IGRbsp_curve));
          if (cvdata->data.p_bspcv)
          {
            is_success = pwReadBspCv (file, cvdata->data.p_bspcv);
          }
          record_found = TRUE;
          break;

        default:
          break;
      }
    }
    
    if (record_found)
      break;
  }

  return (is_success);
}

PWboolean pwReadPy2d
(
  FILE *file,
  struct PWpoly2d *py
)
{
  return (read_py (file, (char *) py, FALSE));
}

PWboolean pwReadPy 
(
  FILE *file,
  struct PWpoly *py
)
{
  return (read_py (file, (char *) py, TRUE));
}


PWboolean pwReadBspCv 
(
  FILE *file,
  struct IGRbsp_curve *bspcv
)
{
  char line[PW_K_MaxCharOnLine+1];
  char token[PW_K_MaxCharOnLine+1];
  int inx, filepos;
  FILE *intfile;
  PWboolean is_success = FALSE;

  while (fgets (line, PW_K_MaxCharOnLine, file))
  {
    if (pwNumFields (line) < 2)
      continue;

    inx = pwGetInxOfField (FIRST, line);
    pwFieldInStr (FIRST, line, token);
    if (strcmp (token, "+") == STRING_MATCH &&
        pwCvtypeFromString (&line[inx+1]) == PWcvdata_bspcv)
    {
      filepos = ftell (file);

      if (!fgets (line, PW_K_MaxCharOnLine, file))
        break;

      sscanf (line, "%s", token);
      if (strcmp (token, "BScurve") != STRING_MATCH)
      {
        if (intfile = fopen (token, "r"))
        {
          is_success = pwReadBspCv (intfile, bspcv);
          fclose (intfile);
        }
      }
      else
      {
        fseek (file, filepos, 0);
        bspcv->poles = NULL;
        bspcv->knots = NULL;
        bspcv->weights = NULL;
        bspcv->bdrys = NULL;
        is_success = BSreadbspc (file, bspcv);
      }
      break;
    }
  }

  return (is_success);
}

PWboolean pwReadSfdata 
(
  FILE *file,
  struct PWsfdata *sfdata
)
{
  char line[PW_K_MaxCharOnLine+1], token[PW_K_MaxCharOnLine+1];
  int inx=0, filepos=0;
  PWboolean is_success=FALSE, record_found=FALSE;;

  while (filepos = ftell (file), fgets (line, PW_K_MaxCharOnLine, file))
  {
    if (pwNumFields (line) < 2)
      continue;

    pwFieldInStr (FIRST, line, token);
    if (strcmp (token, "+") == STRING_MATCH)
    {
      fseek (file, filepos, 0);
      inx = pwGetInxOfField (FIRST, line);
      switch (sfdata->datatype = pwSftypeFromString (&line[inx+1]))
      {
        case PWsfdata_plane:
          record_found = TRUE;
          break;

        case PWsfdata_bspsf:
          sfdata->data.p_bspsf = NULL;
          sfdata->data.p_bspsf = (struct IGRbsp_surface *) 
                                 malloc (sizeof (struct IGRbsp_surface));
          if (sfdata->data.p_bspsf)
          {
            is_success = pwReadBspSf (file, sfdata->data.p_bspsf);
          }
          record_found = TRUE;
          break;

        case PWsfdata_gmbspsf:
          sfdata->data.p_gmbspsf = NULL;
          /*
          sfdata->data.p_gmbspsf = (struct BSgeom_bsp_surf *) 
                                 malloc (sizeof (struct BSgeom_bsp_surf));
          */
          record_found = TRUE;
          break;

        default:
          break;
      }
    }
    
    if (record_found)
      break;
  }

  return (is_success);
}

PWboolean pwReadBspSf
(
  FILE *file,
  struct IGRbsp_surface *bspsf
)
{
  char line[PW_K_MaxCharOnLine+1];
  char token[PW_K_MaxCharOnLine+1];
  int inx, filepos;
  FILE *intfile;
  PWboolean is_success = FALSE;

  while (fgets (line, PW_K_MaxCharOnLine, file))
  {
    if (pwNumFields (line) < 2)
      continue;

    inx = pwGetInxOfField (FIRST, line);
    pwFieldInStr (FIRST, line, token);
    if (strcmp (token, "+") == STRING_MATCH &&
        pwSftypeFromString (&line[inx+1]) == PWsfdata_bspsf)
    {
      filepos = ftell (file);

      if (!fgets (line, PW_K_MaxCharOnLine, file))
        break;

      sscanf (line, "%s", token);
      if (strcmp (token, "BSsurface") != STRING_MATCH)
      {
        if (intfile = fopen (token, "r"))
        {
          is_success = pwReadBspSf (intfile, bspsf);
          fclose (intfile);
        }
      }
      else
      {
        fseek (file, filepos, 0);
        bspsf->poles = NULL;
        bspsf->u_knots = NULL;
        bspsf->v_knots = NULL;
        bspsf->weights = NULL;
        bspsf->bdrys = NULL;
        is_success = BSreadbsps (file, bspsf);
      }
      break;
    }
  }

  return (is_success);
}


/*--------------------- STATIC FUNCTIONS --------------------------------*/

static PWboolean read_py 
(
  FILE *file,
  char *in_py,
  PWboolean is_3d
)
{
  char line[PW_K_MaxCharOnLine+1], filename[PW_K_MaxCharOnLine+1];
  char token[PW_K_MaxCharOnLine+1];
  int i, j, inx, dim, num_pts;
  double *ptr;
  FILE *intfile;
  PWboolean is_success = FALSE;
  struct PWpoly2d *py2d=NULL;
  struct PWpoly *py=NULL;

  if (is_3d)
    py = (struct PWpoly *) in_py;
  else
    py2d = (struct PWpoly2d *) in_py;

  while (fgets (line, PW_K_MaxCharOnLine, file))
  {
    if (pwNumFields (line) < 2)
      continue;

    inx = pwGetInxOfField (FIRST, line);
    pwFieldInStr (FIRST, line, token);
    if (strcmp (token, "+") == STRING_MATCH &&
        pwCvtypeFromString (&line[inx+1]) == 
         (is_3d ? PWcvdata_py : PWcvdata_py2d))
    {
      if (!fgets (line, PW_K_MaxCharOnLine, file))
        break;

      if (!sscanf (line, "%d", &num_pts))
      {
        sscanf (line, "%s", filename);
        if (intfile = fopen (filename, "r"))
        {
          is_success = read_py (intfile, in_py, is_3d);
          fclose (intfile);
        }
      }
      else
      {
        if (ptr = (double *) malloc (num_pts * 
                          (is_3d ? sizeof (PWpoint) : sizeof (PWpoint2d))))
        {
          if (is_3d)
          {
            py->num_pts = num_pts;
            py->p_pts = (PWpoint *) ptr;
          }
          else
          {
            py2d->num_pts = num_pts;
            py2d->p_pts = (PWpoint2d *) ptr;
          }

          dim = is_3d ? 3 : 2;
          for (i=0, j=0; i<num_pts; i++, j+=dim)
          {
            if (is_3d ? 
                 (fscanf (file, "%lf %lf %lf", 
                   &ptr[j], &ptr[j+1], &ptr[j+2]) != 3) :
                 (fscanf (file, "%lf %lf", 
                   &ptr[j], &ptr[j+1]) != 2))
              break;
          }
        is_success = (i == num_pts);
        }
      }
      break;
    }
  }

  return (is_success);
}

