/*
  ABSTRACT

  This file contains the implementation of the GRprint and GRread messages
  that print and read from a file. In this implementation the flag to
  print/read super-class information and the flag to print/read full-format
  are ignored. 
*/

class implementation GRgraphics;

#include <string.h>
#include "godef.h"

#define Error(cond) \
  if (cond) \
  { \
    stat_OM = OM_E_ABORT; \
    goto wrapup; \
  }

#define STRING_MATCH 0

method GRprint
(
  FILE *file;
  IGRint num_indent;
  IGRboolean print_super_class;
  IGRboolean print_full_format; 
)
{
  IGRchar space=' ', indent[GR_MAX_CHAR+1];
  IGRshort props, level;
  IGRlong stat_OM=OM_S_SUCCESS;

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  props = ME.GRgraphics->properties;
  level = ME.GRgraphics->level;

  /*
   * Print the graphics Properties
   */

  fprintf (file, "%sGraphics Properties:\n", indent);

  fprintf (file, "%s ", indent);
  if (!(props & GRIS_PLANAR))
    fprintf (file, "Non-");
  fprintf (file, "Planar | ");

  if (!(props & GR_RIGID_RELATIONSHIP))
    fprintf (file, "Not ");
  fprintf (file, "Rigidly Owned | ");

  if (!(props & GRIS_LOCATABLE))
    fprintf (file, "Not ");
  fprintf (file, "Locatable | ");

  if (!(props & GRIS_DISPLAYABLE))
    fprintf (file, "Not ");
  fprintf (file, "Displayable |\n");

  fprintf (file, "%s ", indent);
  if (!(props & GRIS_ASSOCIATIVE))
    fprintf (file, "Not ", indent);
  fprintf (file, "Associative | ");

  if (!(props & GRHAS_EXTERNAL_CONSTRAINT))
    fprintf (file, "Not ");
  fprintf (file, "Externally Constrained | ");

  if (!(props & GRIS_VE_CURVE))
    fprintf (file, "Not ");
  fprintf (file, "Visi Edge | ");

  if (!(props & GRIS_POST220_OBJECT))
    fprintf (file, "Not ");
  fprintf (file, "Post 220 |\n");

  /*
   * Print the Level
   */

  fprintf (file, "%sLevel:\n", indent);

  fprintf (file, "%s %d\n", indent, level);

  return (stat_OM);
}



method GRread
(
  FILE *file;
  IGRboolean read_super_class;
  IGRboolean read_full_format; 
)
{
  IGRboolean done=FALSE;
  IGRchar *fstat=NULL, line[GR_MAX_CHAR+1], *p_line, *token;
  IGRshort props, props_mask;
  IGRint i, int_level;
  IGRlong stat_OM=OM_S_SUCCESS;

  /*
   * Search the file line-by-line where "Graphics" occurs as the first
   * field. This indicates that what is to follow is this class's formatted
   * data.
   */

  while (!done && fgets (line, GR_MAX_CHAR, file))
  {
    token = strtok (line, " ");
    if (strcmp (token, "Graphics") == STRING_MATCH)
    {
      /*
       * The followin line is expected to contain the concerned
       * properties
       */

      props_mask = GRIS_PLANAR | GR_RIGID_RELATIONSHIP | 
                   GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_ASSOCIATIVE | 
                   GRHAS_EXTERNAL_CONSTRAINT | GRIS_VE_CURVE | 
                   GRIS_POST220_OBJECT;
      props = props_mask;

      fstat = fgets (line, GR_MAX_CHAR, file);
      Error (!fstat);
      p_line = strtok (line, " ");

      for (i=0; i<4; i++)
      {
        token = strtok (i ? NULL : p_line, "|");
        if (i == 0 && toupper (token[0]) == 'N')
          props &= ~GRIS_PLANAR;
        if (i == 1 && toupper (token[0]) == 'N')
          props &= ~GR_RIGID_RELATIONSHIP;
        if (i == 2 && toupper (token[0]) == 'N')
          props &= ~GRIS_LOCATABLE;
        if (i == 3 && toupper (token[0]) == 'N')
          props &= ~GRIS_DISPLAYABLE;
      }

      fstat = fgets (line, GR_MAX_CHAR, file);
      Error (!fstat);
      p_line = strtok (line, " ");

      for (i=0; i<4; i++)
      {
        token = strtok (i ? NULL : p_line, "|");
        if (i == 0 && toupper (token[0]) == 'N')
          props &= ~GRIS_ASSOCIATIVE;
        if (i == 1 && toupper (token[0]) == 'N')
          props &= ~GRHAS_EXTERNAL_CONSTRAINT;
        if (i == 2 && toupper (token[0]) == 'N')
          props &= ~GRIS_VE_CURVE;
        if (i == 3 && toupper (token[0]) == 'N')
          props &= ~GRIS_POST220_OBJECT;
      }

      ME.GRgraphics->properties &= ~props_mask;
      ME.GRgraphics->properties |= props;
    }

    else if (strcmp (line, "Level:") == STRING_MATCH)
    {
      /*
       * The following line is expected to contain the level of
       * this object
       */

      fstat = fgets (line, GR_MAX_CHAR, file);
      Error (!fstat);

      sscanf (line, "%d", &int_level);
      if (int_level > 1023)
        int_level = 1023;
      else if (int_level < 0)
        int_level = 0;

      ME.GRgraphics->level = int_level;
     
      done = TRUE;
    }
  }

  /*
   * The instance data could not be read through EOF
   */

  if (!done)
    stat_OM = OM_E_ABORT;

wrapup:
  return (stat_OM);
}

end implementation GRgraphics;
