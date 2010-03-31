/*
  ABSTRACT

  This file contains the implementation of the GRprint and GRread messages
  that print and read from a file. 
*/

class implementation EMSlinedge;

#include <string.h>
#include <alloca.h>
#include "OMmacros.h"
#include "PWminimum.h"

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
  IGRint i, numpts;
  IGRlong stat_OM=OM_S_SUCCESS;
  PWpoint2d *fpt, *ept, *pt;

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  fprintf (file, "%s+ Linear Edge -- [%d, %d]\n", indent, my_id, OS);

  /*
   * Print the number of points. If full format is enabled then also
   * print out all the points, else print only the first and the last.
   */

  numpts = ME.EMSlinedge->num_points;
  fprintf (file, "%s   Number of Points = %d\n", indent, numpts);

  if (!print_full_format)
  {
    fpt = (PWpoint2d *) ME.EMSlinedge->points;
    ept = (PWpoint2d *) &ME.EMSlinedge->points[(numpts-1)*2];
    fprintf (file, "%s   Start (as stored):\n", indent);
    for (i=0; i<2; i++)
      fprintf (file, "%s    %7.12lf %7.12lf\n", indent, fpt[0][0], fpt[0][1]);
    fprintf (file, "%s   End (as stored):\n", indent);
    for (i=0; i<2; i++)
      fprintf (file, "%s    %7.12lf %7.12lf\n", indent, ept[0][0], ept[0][1]);
  }
 
  else
  {
    pt = (PWpoint2d *) ME.EMSlinedge->points;
    for (i=0; i<numpts; i++)
      fprintf (file, "%s    %7.12lf %7.12lf\n", indent, pt[i][0], pt[i][1]);
  }

  /*
   * If the print of the super class is requested send the message
   * on high
   */

  if (print_super_class)
  {
    stat_OM = om$send (mode = OM_e_wrt_message, 
               msg = message EMSboundary.GRprint (file, num_indent+3, TRUE, 
               TRUE), targetid = my_id);
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
  IGRchar line[GR_MAX_CHAR+1], *token, *subtoken, *fstat;
  IGRint i, j, numpts;
  IGRlong stat_OM=OM_S_SUCCESS;
  PWpoint2d *pts;

  /*
   * Search the file line-by-line where "+" occurs as the first
   * token, followed by "Linear". This indicates that what is to follow is 
   * this class's formatted data.
   */

  while (!done && fgets (line, GR_MAX_CHAR, file))
  {
    token = strtok (line, " ");
    subtoken = strtok (NULL, " ");
    if (strcmp (token, "+") == STRING_MATCH && 
        strcmp (subtoken, "Linear") == STRING_MATCH)
    {
      fstat = fgets (line, GR_MAX_CHAR, file);
      Error (!fstat);
      token = strtok (line, " ");
      for (i=0; i<4; i++)
        token = strtok (NULL, " ");

      numpts = atoi (token);
      if (read_full_format)
      {
        /*
         * 'numpts' number of lines are expected, each holding two doubles
         * corresponding to the U and V value of the point. These then
         * replace the existing points, if any.
         */

        stat_OM = om$vla_set_dimension (size = numpts * 2, 
                   varray = ME.EMSlinedge->points);
        Error (!stat_OM);
        pts = (PWpoint2d *) ME.EMSlinedge->points;

        for (i=0; i<numpts; i++)
        {
          fstat = fgets (line, GR_MAX_CHAR, file);
          Error (!fstat);
          
          token = strtok (line, " ");
          pts[i][0] = atof (token);
          token = strtok (NULL, " ");
          pts[i][1] = atof (token);
        }
        ME.EMSlinedge->num_points = numpts;
      }

      else
      {
        /*
         * The next line contains the declaration that what follows is
         * start point. Similarly, followed by the declaration of the
         * end point and then the end point itself. These are appropriately
         * read into the respective locations. The "numpts" read in above 
         * is ignored. The existing "numpts" of the edge is used to index
         * to the last (end) point.
         */

        pts = (PWpoint2d *) ME.EMSlinedge->points;
        numpts = ME.EMSlinedge->num_points;
        for (i=START, j=0; i<=END; i++, j=numpts-1)
        {
          fstat = fgets (line, GR_MAX_CHAR, file);
          Error (!fstat);
          fstat = fgets (line, GR_MAX_CHAR, file);        
          Error (!fstat);

          token = strtok (line, " ");
          pts[j][0] = atoi (token);
          token = strtok (NULL, " ");
          pts[j][1] = atoi (token);
        }
      }

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
   * Process the request to read this object's super classes also
   */

  if (read_super_class)
  {
    stat_OM = om$send (mode = OM_e_wrt_message, 
               msg = message EMSboundary.GRread (file, TRUE,
               read_full_format), targetid = my_id);
    Error (!(1&stat_OM));
  }

wrapup:
  return (stat_OM);
}

end implementation EMSlinedge;
