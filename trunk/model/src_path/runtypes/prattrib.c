#include <stdio.h>
#include <string.h>
#include <memory.h>

#include "PWminimum.h"
#include "PWerror.h"
#include "PWattrib.h"
#include "PWattribid.h"
#include "PWapi/prattrib.h"
#include "PWapi/reqfile.h"
#include "PWapi/printerr.h"

static void get_ident_string
(
  unsigned int ident,
  char *str
);



void pwStringAttrib 
(
  enum PWattribtype attr,
  char *str
)
{
  if (attr == PWattrib_integer)
    strcpy (str, "Integer");
  else if (attr == PWattrib_double)
    strcpy (str, "Double");
  else if (attr == PWattrib_pointer)
    strcpy (str, "Pointer");
  else
    strcpy (str, "Unknown");

  return;
}

/*
  DESCRIPTION
 
  This function, given a pointer to an attribute list, prints it's
  contents to an input file-pointer. The number of spaces to consistently
  indent the output is also passed in. If the file-pointer is NULL, this
  function will print to stderr.
*/

void pwPrintAttrib 
(
  FILE *outfile,
  int num_indent,
  struct PWattrib *attrib
)
{
  char space=' ', indent[PW_K_MaxCharOnLine+1], str[PW_K_MaxCharOnLine+1];
  int i, num_nodes;
  struct PWattrib *list;

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  list = attrib;
  num_nodes = 0;
  while (list)
  {
    num_nodes++;
    list = list->p_next;
  }

  if (!num_nodes)
    fprintf (outfile, "%sNo Attributes\n", indent);
  else
    fprintf (outfile, "%sNum attributes = %d\n", indent, num_nodes);
  list = attrib;
  for (i=0; i<num_nodes; i++)
  {
    fprintf (outfile, "%s%2d) Attribute = 0x%x\n", indent, i, list);

    get_ident_string (list->ident, str);
    fprintf (outfile, "%s      %s\n", indent, str);
    pwStringAttrib (list->attribtype, str);
    if (list->attribtype == PWattrib_integer)
      fprintf (outfile, "%s      %s = %d\n", 
       indent, str, list->attrib.int_attrib);
    else if (list->attribtype == PWattrib_double)
      fprintf (outfile, "%s      %s = %7.12lf\n",
       indent, str, list->attrib.double_attrib);
    else if (list->attribtype == PWattrib_pointer)
      fprintf (outfile, "%s      %s = 0x%x\n",
       indent, str, list->attrib.gen_attrib.p_attrib);
    else
      fprintf (outfile, "%s      %s type\n",
       indent, str);

    list = list->p_next;
  }

  return;
}

/*---------------- STATIC FUNCTIONS --------------------------------------*/

static void get_ident_string 
(
  unsigned int ident,
  char *str
)
{
  char tmp_str[PW_K_MaxCharOnLine+1], codestr[PW_K_MaxCharOnLine+1];

  pwGetSubsysString (ident, tmp_str);
  strcpy (str, tmp_str);

  switch (GetCode (ident))
  { 
    case PW_K_SurfaceIdAttr:
      strcpy (codestr, "SurfaceId");
      break;

    case PW_K_LoopIdAttr:
      strcpy (codestr, "LoopId");
      break;

    case PW_K_EdgeIdAttr:
      strcpy (codestr, "EdgeId");
      break;

    case PW_K_ToleranceAttr:
      strcpy (codestr, "Tolerance");
      break;

    case PW_K_DistanceAttr:
      strcpy (codestr, "Distance");
      break;

    default:
      strcpy (codestr, "Unknown");
  }
  sprintf (tmp_str, " - %s attribute (inx = %d)", 
   codestr, GetCodeType (ident));
  strcat (str, tmp_str);

  return;
}
