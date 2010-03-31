#include <stdio.h>
#include <string.h>
#include <memory.h>

#include "igr_include/igrtypedef.h"
#include "igr_include/igr.h"
#include "bsprintbspc.h"
#include "bsprintbsps.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/prgmdata.h"
#include "PWapi/reqfile.h"
#include "PWapi/printerr.h"

/*
  DESCRIPTION
 
  The following functions return an ASCII string corresponding to the
  enumerated types.
*/

void pwStringCvtype
(
  enum PWcvdatatype cvtype,
  char *str
)
{
  if (cvtype == PWcvdata_pt2d)
    strcpy (str, "Point 2d");
  else if (cvtype == PWcvdata_pt)
    strcpy (str, "Point");
  else if (cvtype == PWcvdata_py2d)
    strcpy (str, "Polyline 2d");
  else if (cvtype == PWcvdata_py)
    strcpy (str, "Polyline");
  else if (cvtype == PWcvdata_bspcv)
    strcpy (str, "B-spline curve");
  else if (cvtype == PWcvdata_gmbspcv)
    strcpy (str, "Geometric curve");
  else
    strcpy (str, "Unknown");

  return;
}

void pwStringSftype 
(
  enum PWsfdatatype sftype,
  char *str
)
{
  if (sftype == PWsfdata_plane)
    strcpy (str, "Plane");
  else if (sftype == PWsfdata_bspsf)
    strcpy (str, "B-Spline surface");
  else if (sftype == PWsfdata_gmbspsf)
    strcpy (str, "Geometric surface");
  else
    strcpy (str, "Unknown");

  return;
}

void pwStringTopopos 
(
  enum PWtopopostype pos,
  char *str
)
{
  if (pos == PWtopopos_start)
    strcpy (str, "Start");
  else if (pos == PWtopopos_stop)
    strcpy (str, "Stop");
  else if (pos == PWtopopos_middle)
    strcpy (str, "Middle");
  else
    strcpy (str, "Unknown");

  return;
}

char *pwStringFeattype
(
  enum PWfeattype feattype,
  char *str
)
{
  if (feattype == PWfeat_addmaterial)
    strcpy (str, "Add Material");
  else if (feattype == PWfeat_removematerial)
    strcpy (str, "Remove Material");
  else if (feattype == PWfeat_thinwall)
    strcpy (str, "Thinwall");
  else if (feattype == PWfeat_adddraft)
    strcpy (str, "Add Draft");
  else if (feattype == PWfeat_round)
    strcpy (str, "Round");
  else if (feattype == PWfeat_boolean)
    strcpy (str, "Boolean");

  else if (feattype == PWfeat_hole)
    strcpy (str, "Hole");
  else if (feattype == PWfeat_counterbore)
    strcpy (str, "Counter Bore");
  else if (feattype == PWfeat_countersink)
    strcpy (str, "Counter Sink");
  else if (feattype == PWfeat_rib)
    strcpy (str, "Rib");
  else if (feattype == PWfeat_imposebnd)
    strcpy (str, "Impose Boundary");
  else if (feattype == PWfeat_stitch)
    strcpy (str, "Stitch");
  else if (feattype == PWfeat_unitesf)
    strcpy (str, "Unite Surface");
  else if (feattype == PWfeat_delbnd)
    strcpy (str, "Delete Boundary");

  else if (feattype == PWfeat_makeface)
    strcpy (str, "Make Face (X)");
  else if (feattype == PWfeat_liftface)
    strcpy (str, "Lift Face (X)");
  else if (feattype == PWfeat_replacesf)
    strcpy (str, "Replace Surface (X)");
  else if (feattype == PWfeat_boss)
    strcpy (str, "Boss (X)");
  else if (feattype == PWfeat_pocket)
    strcpy (str, "Pocket (X)");
  else if (feattype == PWfeat_cutout)
    strcpy (str, "Cutout (X)");
  else if (feattype == PWfeat_slot)
    strcpy (str, "Slot (X)");

  else 
    strcpy (str, "Unknown");

  return (str);
}

/*
  DESCRIPTION
  
  The following functions write curve (or a surface) definitions into a
  file. The file-pointer is input. If a specific curve (or surface) datatype
  is known, then one could use the type specific function. 'num_indent' tells 
  how many spaces to indent every line of output by. A simpler wrapper
  function that takes in just the pointer to the data-structure is also 
  defined. This mainly provides for an easy call from within a debugger.

  The function adds a geometry type record as the first line. This starts
  of with a "+", followed by the ASCII string representing the data
  enumeration. The datatype-specific definition follows.
   
  The function return TRUE on a successful write.
*/

int pwCvdata 
(
  struct PWcvdata *cvdata
)
{
  FILE *outfile;

  if (outfile = pwRequestOutFile ())
  {
    pwPrintCvdata (outfile, 0, cvdata);
    if (outfile != stderr)
      fclose (outfile);
  }
  return (TRUE);
}

void pwPrintCvdata 
(
  FILE *file,
  int num_indent,
  struct PWcvdata *cvdata
)
{
  switch (cvdata->datatype)
  {
    case PWcvdata_pt2d:
      pwPrintPt2d (file, num_indent, cvdata->data.pt2d);
      break;

    case PWcvdata_pt:
      pwPrintPt (file, num_indent, cvdata->data.pt);
      break;

    case PWcvdata_py2d:
      pwPrintPy2d (file, num_indent, &cvdata->data.py2d);
      break;
  
    case PWcvdata_py:
      pwPrintPy (file, num_indent, &cvdata->data.py);
      break;

    case PWcvdata_bspcv:
      pwPrintBspCv (file, num_indent, cvdata->data.p_bspcv);
      break;

    default:
      break;
  }
 
  return;
}

int pwPoly2d 
(
  struct PWpoly2d *py
)
{
  FILE *outfile;

  if (outfile = pwRequestOutFile ())
  {
    pwPrintPy2d (outfile, 0, py);
    if (outfile != stderr)
      fclose (outfile);
  }
  return (TRUE);
}

void pwPrintPy2d 
(
  FILE *file,
  int num_indent,
  struct PWpoly2d *py
)
{
  char space=' ', indent[PW_K_MaxCharOnLine+1], str[PW_K_MaxCharOnLine+1];
  int i;

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';
  
  pwStringCvtype (PWcvdata_py2d, str);
  fprintf (file, "%s+ %s\n", indent, str);
  fprintf (file, "%d\n", py->num_pts);
  for (i=0; i<py->num_pts; i++)
    fprintf (file, "%s%7.12lf %7.12lf\n", 
     indent, py->p_pts[i][X], py->p_pts[i][Y]);

  return;
}


int pwPoly
( 
  struct PWpoly *py
)
{
  FILE *outfile;

  if (outfile = pwRequestOutFile ())
  {
    pwPrintPy (outfile, 0, py);
    if (outfile != stderr)
      fclose (outfile);
  }
  return (TRUE);
}

void pwPrintPy 
(
  FILE *file,
  int num_indent,
  struct PWpoly *py
)
{
  char space=' ', indent[PW_K_MaxCharOnLine+1], str[PW_K_MaxCharOnLine+1];
  int i;

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';
  
  pwStringCvtype (PWcvdata_py, str);
  fprintf (file, "%s+ %s\n", indent, str);
  fprintf (file, "%d\n", py->num_pts);
  for (i=0; i<py->num_pts; i++)
    fprintf (file, "%s%7.12lf %7.12lf %7.12lf\n", 
     indent, py->p_pts[i][X], py->p_pts[i][Y], py->p_pts[i][Z]);

  return;
}


int pwBspcurve 
(
  struct IGRbsp_curve *cv
)
{
  FILE *outfile;

  if (outfile = pwRequestOutFile ())
  {
    pwPrintBspCv (outfile, 0, cv);
    if (outfile != stderr)
      fclose (outfile);
  }
  return (TRUE);
}

void pwPrintBspCv 
(
  FILE *file,
  int num_indent,
  struct IGRbsp_curve *bspcv
)
{
  char space=' ', indent[PW_K_MaxCharOnLine+1], str[PW_K_MaxCharOnLine+1];

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';
  
  pwStringCvtype (PWcvdata_bspcv, str);
  fprintf (file, "%s+ %s\n", indent, str);
  BSprintbspc (file, NULL, bspcv, FALSE);

  return;
}

int pwSfdata 
(
  struct PWsfdata *sfdata
)
{
  FILE *outfile=NULL;

  if (outfile = pwRequestOutFile ())
  {
    pwPrintSfdata (outfile, 0, sfdata);
    if (outfile != stderr)
      fclose (outfile);
  }
  return (TRUE);
}

void pwPrintSfdata
(
  FILE *file,
  int num_indent,
  struct PWsfdata *sfdata
)
{
  switch (sfdata->datatype)
  {
    case PWsfdata_plane :
      break;

    case PWsfdata_bspsf :
      pwPrintBspSf (file, num_indent, sfdata->data.p_bspsf);
      break;

    case PWsfdata_gmbspsf :
      break;
  }

  return;
}

int pwBspsurface
(
  struct IGRbsp_surface *bspsf
)
{
  FILE *outfile;

  if (outfile = pwRequestOutFile ())
  {
    pwPrintBspSf (outfile, 0, bspsf);
    if (outfile != stderr)
      fclose (outfile);
  }
  return (TRUE);
}

void pwPrintBspSf 
(
  FILE *file,
  int num_indent,
  struct IGRbsp_surface *bspsf
)
{
  char space=' ', indent[PW_K_MaxCharOnLine+1], str[PW_K_MaxCharOnLine+1];

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  pwStringSftype (PWsfdata_bspsf, str);
  fprintf (file, "%s+ %s\n", indent, str);

  BSprintbsps (file, NULL, bspsf, FALSE);

  return;
}

/*
   DESCRIPTION

   The following function prints the PWcvpt structure. 'num_indent' tells how
   many spaces to indent every line of input by. A simpler wrapper function 
   that takes in just the pointer to the data-structure is also defined. 
   This mainly provides for an easy call from within a debugger.
*/     

int pwCvpt 
(
  struct PWcvpt *cvpt
)
{
  FILE *outfile;

  if (outfile = pwRequestOutFile ())
  {
    pwPrintCvpt (outfile, 0, cvpt);
    if (outfile != stderr)
      fclose (outfile);
  }
  return (TRUE);
}

void pwPrintCvpt 
(
  FILE *outfile,
  int num_indent,
  struct PWcvpt *cvpt
)
{
  char space=' ', indent[PW_K_MaxCharOnLine+1], str[PW_K_MaxCharOnLine+1];

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  pwStringTopopos (pwGetTopoposCvpt (cvpt), str);
  fprintf (outfile, "%s%s position\n", indent, str);
  pwPrintPt (outfile, num_indent, cvpt->pt);
  fprintf (outfile, "%sSpan = %d, Param = %7.12lf\n", indent,
   cvpt->cvparam.spaninx, cvpt->cvparam.spanpar);
  fprintf (outfile, "%sCurve Id = %d\n", indent,
   cvpt->cvid);
  fprintf (outfile, "%sAttributes:\n");
  pwPrintAttrib (outfile, num_indent+2, cvpt->p_attrib);

  return;
}
