#include <stdio.h>
#include <string.h>
#include <memory.h>

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWapi/prgmint.h"
#include "PWapi/reqfile.h"
#include "PWapi/printerr.h"

/*
  DESCRIPTION
 
  The following functions return an ASCII string corresponding to the
  enumerated types.
*/

void pwStringContain 
(
  enum PWcontaintype cont,
  char *str
)
{
  if (cont == PWcontain_in)
    strcpy (str, "In");
  else if (cont == PWcontain_on)
    strcpy (str, "On");
  else if (cont == PWcontain_out)
    strcpy (str, "Out");
  else
    strcpy (str, "Unknown");

  return;
}

/*
   DESCRIPTION

   The following function prints the PWcvintpt structure. 'num_indent' tells
   how many spaces to indent every line of input by. A simpler wrapper 
   function that takes in just the pointer to the data-structure is also 
   defined. This mainly provides for an easy call from within a debugger.
*/     

int pwCvintpt 
(
  struct PWcvintpt *cvintpt
)
{
  FILE *outfile;

  if (outfile = pwRequestOutFile ())
  {
    pwPrintCvintpt (outfile, 0, cvintpt);
    if (outfile != stderr)
      fclose (outfile);
  }
  return (TRUE);
}

void pwPrintCvintpt 
(
  FILE *outfile,
  int num_indent,
  struct PWcvintpt *cvintpt
)
{
  char space=' ', indent[PW_K_MaxCharOnLine+1], str[PW_K_MaxCharOnLine+1];

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  fprintf (outfile, "%sProperties:\n", indent);
  pwStringContain (pwGetContainCvintpt (cvintpt, LEFT), str);
  fprintf (outfile, "%s  Left - %s", indent, str);
  pwStringContain (pwGetContainCvintpt (cvintpt, RIGHT), str);
  fprintf (outfile, ", Right - %s\n", str);
  if (pwIsNoSiblingCvintpt (cvintpt))
    fprintf (outfile, "%s  No Sibling\n", indent);
  else
    fprintf (outfile, "%s  Sibling Present\n", indent);

  fprintf (outfile, "%sCurve Point:\n", indent);
  pwPrintCvpt (outfile, num_indent+2, &cvintpt->cvpt);
  fprintf (outfile, "%sSibling Point:\n", indent);
  pwPrintCvpt (outfile, num_indent+2, &cvintpt->sibling);
  fprintf (outfile, "%sAttributes:\n", indent);
  pwPrintAttrib (outfile, num_indent+2, cvintpt->p_attrib);

  return;
}


/*
   DESCRIPTION

   The following function prints the entire list of PWcvintpt_list nodes.
   'num_indent' tells how many spaces to indent every line of input by. 
   A simpler wrapper function that takes in just the pointer to the 
   data-structure is also defined. This mainly provides for an easy call 
   from within a debugger.
*/     

int pwCvintpt_list 
(
  struct PWcvintpt_list *cvintpt_list
)
{
  FILE *outfile;

  if (outfile = pwRequestOutFile ())
  {
    pwPrintCvintptList (outfile, 0, cvintpt_list);
    if (outfile != stderr)
      fclose (outfile);
  }
  return (TRUE);
}

void pwPrintCvintptList 
(
  FILE *outfile,
  int num_indent,
  struct PWcvintpt_list *cvintpts
)
{
  char space=' ', indent[PW_K_MaxCharOnLine+1], str[PW_K_MaxCharOnLine+1];
  int i, j, num_nodes;
  struct PWcvintpt_list *list;

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  list = cvintpts;
  num_nodes = 0;
  while (list)
  {
    num_nodes++;
    list = list->p_next;
  }

  fprintf (outfile, "%sNum points in list = %d\n", indent, num_nodes);
  list = cvintpts;
  for (i=0; i<num_nodes; i++)
  {
    fprintf (outfile, "\n");
    if (list->p_next && list->p_next->p_prev != list)
      strcpy (str, "INVALID prev pointer to this node");
    else
      strcpy (str, "Node");
    fprintf (outfile, "%s%2d) %s = 0x%x, (next = 0x%x, prev = 0x%x)\n",
     indent, i, str, list, list->p_next, list->p_prev);

    fprintf (outfile, "\n");
    fprintf (outfile, "%s    Properties:\n");
    pwStringContain (pwGetContainCvintptList (list, LEFT), str);
    fprintf (outfile, "%s      Left - %s", indent, str);
    pwStringContain (pwGetContainCvintptList (list, RIGHT), str);
    fprintf (outfile, ", Right - %s\n", str);
    if (pwIsArbSeqCvintptList (list))
      fprintf (outfile, "%s      Arbitrary Sequence\n", indent);
    else 
      fprintf (outfile, "%s      Not Arbitrary Sequenced\n", indent);
    
    for (j=PREV; j<=NEXT; j++)
    {
      if (j == PREV)
        strcpy (str, "previous");
      else
        strcpy (str, "next");
      if (pwIsCoincCvintptList (list, j))
        fprintf(outfile, "%s      Coincident with %s node\n", indent, str);
      else 
        fprintf(outfile, "%s      Not coincident with %s node\n", indent, str);
    }

    if (pwIsInfoNodeCvintptList (list))
      fprintf (outfile, "%s      Informational Node\n", indent);
    else
      fprintf (outfile, "%s      Not Informational Node\n", indent);

    fprintf (outfile, "\n");
    fprintf (outfile, "%s    Intersection Point:\n", indent);
    pwPrintCvintpt (outfile, num_indent+6, &list->intpt);

    fprintf (outfile, "\n");
    fprintf (outfile, "%s    Attributes:\n", indent);
    pwPrintAttrib (outfile, num_indent+6, list->p_attrib);

    list = list->p_next;
  }

  return;
}

/*
   DESCRIPTION

   The following function prints the PWcvregion structure. 'num_indent' tells
   how many spaces to indent every line of input by. A simpler wrapper
   function that takes in just the pointer to the data-structure is also
   defined. This mainly provides for an easy call from within a debugger.
*/

int pwCvregion
( 
  struct PWcvregion *cvregion
)
{
  FILE *outfile;

  if (outfile = pwRequestOutFile ())
  {
    pwPrintCvregion (outfile, 0, cvregion);
    if (outfile != stderr)
      fclose (outfile);
  }
  return (TRUE);
}

void pwPrintCvregion
(
  FILE *outfile,
  int num_indent,
  struct PWcvregion *cvregion
)
{
  char space=' ', indent[PW_K_MaxCharOnLine+1], str[PW_K_MaxCharOnLine+1];

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  fprintf (outfile, "%sProperties:\n", indent);
  pwStringContain (pwGetContainCvregion (cvregion), str);
  fprintf (outfile, "%s  Contain - %s", indent, str);
  if (pwIsDegenCvregion (cvregion))
    fprintf (outfile, "%s  Degenerate", indent);
  else
    fprintf (outfile, "%s  Non-Degenerate", indent);
  fprintf (outfile, "\n%sRegion Bounds:\n", indent);
  fprintf (outfile, "%s  Bound1:\n", indent);
  pwPrintCvintpt (outfile, num_indent+4, &cvregion->regbounds[0]);
  fprintf (outfile, "%s  Bound2:\n", indent);
  pwPrintCvintpt (outfile, num_indent+4, &cvregion->regbounds[1]);
  fprintf (outfile, "%sAttributes:\n", indent);
  pwPrintAttrib (outfile, num_indent+2, cvregion->p_attrib);

  return;
}

/*
   DESCRIPTION

   The following function prints the entire list of PWcvregion_list nodes.
   'num_indent' tells how many spaces to indent every line of input by.
   A simpler wrapper function that takes in just the pointer to the
   data-structure is also defined. This mainly provides for an easy call
   from within a debugger.
*/

int pwCvregion_list 
(
  struct PWcvregion_list *cvregion_list
)
{
  FILE *outfile;

  if (outfile = pwRequestOutFile ())
  {
    pwPrintCvregionList (outfile, 0, cvregion_list);
    if (outfile != stderr)
      fclose (outfile);
  }
  return (TRUE);
}

void pwPrintCvregionList 
(
  FILE *outfile,
  int num_indent,
  struct PWcvregion_list *cvregions
)
{
  char space=' ', indent[PW_K_MaxCharOnLine+1], str[PW_K_MaxCharOnLine+1];
  int i, num_nodes;
  struct PWcvregion_list *list;

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  list = cvregions;
  num_nodes = 0;
  while (list)
  {
    num_nodes++;
    list = list->p_next;
  }

  fprintf (outfile, "%sNum points in list = %d\n", indent, num_nodes);
  list = cvregions;
  for (i=0; i<num_nodes; i++)
  {
    fprintf (outfile, "\n");
    if (list->p_next && list->p_next->p_prev != list)
      strcpy (str, "INVALID prev pointer to this node");
    else
      strcpy (str, "Node");
    fprintf (outfile, "%s%2d) %s = 0x%x, (next = 0x%x, prev = 0x%x)\n",
     indent, i, str, list, list->p_next, list->p_prev);

    fprintf (outfile, "\n");
    fprintf (outfile, "%s    Properties:\n");
    fprintf (outfile, "%s      None:\n");

    fprintf (outfile, "\n");
    fprintf (outfile, "%s    Curve Region:\n", indent);
    pwPrintCvregion (outfile, num_indent+6, &list->cvregion);

    fprintf (outfile, "\n");
    fprintf (outfile, "%s    Attributes:\n", indent);
    pwPrintAttrib (outfile, num_indent+6, list->p_attrib);

    list = list->p_next;
  }

  return;
}

