#include <stdio.h>
#include <string.h>

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/prminim.h"
#include "PWapi/reqfile.h"
#include "PWapi/printerr.h"
#include "PWapi/clsid.h"

int pwPoint2d
(
  PWpoint2d pt
)
{
  FILE *outfile;

  if (outfile = pwRequestOutFile ())
  {
    pwPrintPt2d (outfile, 0, pt);
    if (outfile != stderr)
      fclose (outfile);
  }
  return (TRUE);
}

void pwPrintPt2d
(
  FILE *file,
  int num_indent,
  PWpoint2d pt
)
{
  char space=' ', indent[PW_K_MaxCharOnLine+1], str[PW_K_MaxCharOnLine+1];

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';
  
  pwStringCvtype (PWcvdata_pt2d, str);
  fprintf (file, "%s+ %s\n", indent, str);
  fprintf (file, "%s%7.12lf %7.12lf\n", indent, pt[X], pt[Y]);

  return;
}


int pwPoint 
(
  PWpoint pt
)
{
  FILE *outfile;

  if (outfile = pwRequestOutFile ())
  {
    pwPrintPt (outfile, 0, pt);
    if (outfile != stderr)
      fclose (outfile);
  }
  return (TRUE);
}

void pwPrintPt 
(
  FILE *file,
  int num_indent,
  PWpoint pt
)
{
  char space=' ', indent[PW_K_MaxCharOnLine+1], str[PW_K_MaxCharOnLine+1];

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';
  
  pwStringCvtype (PWcvdata_pt, str);
  fprintf (file, "%s+ %s\n", indent, str);
  fprintf (file, "%s%7.12lf %7.12lf %7.12lf\n", indent, pt[X], pt[Y], pt[Z]);

  return;
}

void pwPrintId
(
  FILE *file,
  int num_indent,
  PWobjid objid,
  PWosnum os
)
{
  char space=' ', indent[PW_K_MaxCharOnLine+1], classname[PW_K_MaxStringLen+1];

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  fprintf (file, "%s+ %s [%d,%d]\n", indent, 
   omClassNameFromClassid (omClassidFromObjid (objid, os), 
    os, classname), objid, os);

  return;
}

