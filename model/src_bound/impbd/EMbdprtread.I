/*
  ABSTRACT

  This file contains the implementation of the GRprint and GRread messages
  that print and read from a file. In this implementation the flag to
  print/read the 'full_format' is ignored. 
*/

class implementation EMSboundary;

#include <string.h>

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
  IGRlong stat_OM=OM_S_SUCCESS;

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  fprintf (file, "%sCreator Object:\n", indent);
  fprintf (file, "%s Id = %d", indent, ME.EMSboundary->creator_id);

  /*
   * Process the request to print this object's super classes also. 
   */

  if (print_super_class)
  {
    stat_OM = om$send (mode = OM_e_wrt_message, 
               msg = message GRnotify.GRprint (file, num_indent, TRUE, TRUE),
               targetid = my_id);
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
  IGRint i;
  IGRlong stat_OM=OM_S_SUCCESS;

  /*
   * Search the file line-by-line where "Creator" occurs as the first
   * token. This indicates that what is to follow is this class's formatted
   * data.
   */

  while (!done && fgets (line, GR_MAX_CHAR, file))
  {
    token = strtok (line, " ");
    if (strcmp (token, "Creator") == STRING_MATCH)
    {
      fstat = fgets (line, GR_MAX_CHAR, file);
      Error (!fstat);
      token = strtok (line, " ");

      /*
       * Obtain the id in the third field
       */

      for (i=0; i<2; i++)
        token = strtok (NULL, " ");
      ME.EMSboundary->creator_id = atoi (token);

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
   * Process the request to read this object's super classes also. 
   */

  if (read_super_class)
  {
    stat_OM = om$send (mode = OM_e_wrt_message, 
               msg = message GRnotify.GRread (file, TRUE, TRUE), 
               targetid = my_id);
    Error (!(1&stat_OM));
  }

wrapup:
  return (stat_OM);
}

end implementation EMSboundary;
