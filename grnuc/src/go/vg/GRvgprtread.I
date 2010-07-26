/*
  ABSTRACT

  This file contains the implementation of the GRprint and GRread messages
  that print and read from a file. In this implementation the flag to
  print/read the 'full_format' is ignored. 
*/

class implementation GRvg;

#include <stdio.h>
#include <string.h>
#include "wl.h"
#include "igecolor.h"
#include "igecolmacros.h"

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
  IGRchar space=' ', indent[GR_MAX_CHAR+1], color_name[GR_MAX_CHAR+1];
  IGRshort color;
  IGRlong stat_OM=OM_S_SUCCESS;
  struct IGRdisplay display_attr;

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  display_attr = ME.GRvg->display_attr;
  color = display_attr.color;

  fprintf (file, "%sDisplay Attributes:\n", indent);
  fprintf (file, "%s ", indent);

  /*
   * Print the display attributes
   */

  ige$get_name_from_color (color = color, name = color_name);
  fprintf (file, "Color = %s | ", color_name);

  fprintf (file, "Weight = %d | ", display_attr.weight);

  fprintf (file, "Style# = %d |\n", display_attr.style);

  /*
   * Process the request to print this object's super classes also. The
   * flags are set to take care of the multiple inheritance of GRgraphics.
   */

  if (print_super_class)
  {
    stat_OM = om$send (mode = OM_e_wrt_message, 
               msg = message GRgraphics.GRprint (file, num_indent, 
               TRUE, TRUE), targetid = my_id);
    Error (!(1&stat_OM));

    stat_OM = om$send (mode = OM_e_wrt_message, 
               msg = message GRnotify.GRprint (file, num_indent, 
               FALSE, TRUE), targetid = my_id);
    Error (!(1&stat_OM));

    stat_OM = om$send (mode = OM_e_wrt_message, 
               msg = message GRconnector.GRprint (file, num_indent, 
               FALSE, TRUE), targetid = my_id);
    Error (!(1&stat_OM));
  }

wrapup:
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
  IGRchar line[GR_MAX_CHAR+1], *token, *fstat;
  IGRshort color;
  IGRint i;
  IGRlong stat_OM=OM_S_SUCCESS;

  /*
   * Search the file line-by-line where "Display" occurs as the first
   * token. This indicates that what is to follow is this class's formatted
   * data.
   */

  while (!done && fgets (line, GR_MAX_CHAR, file))
  {
    token = strtok (line, " ");
    if (strcmp (token, "Display") == STRING_MATCH)
    {
      fstat = fgets (line, GR_MAX_CHAR, file);
      Error (!fstat);
      token = strtok (line, " ");

      /*
       * Obtain the color name as the third field
       */

      for (i=0; i<2; i++)
        token = strtok (NULL, " ");
      ige$get_color_from_name (name = token, color = &color);
      ME.GRvg->display_attr.color = color;

      /*
       * Obtain the weight as the fifth field from above
       */

      for (i=0; i<4; i++)
        token = strtok (NULL, " ");
      ME.GRvg->display_attr.weight = atoi (token);

      /*
       * Obtain the style index as the fifth field from above
       */

      for (i=0; i<4; i++)
        token = strtok (NULL, " ");
      ME.GRvg->display_attr.style = atoi (token);

      done = TRUE;
    }
  }

  /*
   * Flag an error if the line corresponding to this class was not 
   * found until EOF.
   */

  if (!done)
    stat_OM = OM_E_ABORT;

  /*
   * Process the request to read this object's super classes also. The
   * flags are set to take care of the multiple inheritance of GRgraphics.
   */

  if (read_super_class)
  {
    stat_OM = om$send (mode = OM_e_wrt_message, 
               msg = message GRgraphics.GRread (file, TRUE, TRUE), 
               targetid = my_id);
    Error (!(1&stat_OM));

    stat_OM = om$send (mode = OM_e_wrt_message, 
               msg = message GRnotify.GRread (file, FALSE, TRUE),
               targetid = my_id);
    Error (!(1&stat_OM));

    stat_OM = om$send (mode = OM_e_wrt_message, 
               msg = message GRconnector.GRread (file, FALSE, TRUE),
               targetid = my_id);
    Error (!(1&stat_OM));
  }

wrapup:
  return (stat_OM);
}

end implementation GRvg;
