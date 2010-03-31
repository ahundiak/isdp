/*
  ABSTRACT

  This file contains the implementation of the GRprint and GRread messages
  that print and read from a file. In this implementation the flag to
  print/read the 'full_format' is ignored. 
*/

class implementation EMSedge;

#include <string.h>
#include <alloca.h>
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
  IGRchar space=' ', indent[GR_MAX_CHAR+1], str[GR_MAX_CHAR+1];
  IGRushort props;
  IGRint num_objs;
  IGRlong stat_OM=OM_S_SUCCESS;
  GRobjid commobj, *objs;
  OM_S_CHANSELECT chan_to_owners, chan_to_common, chan_to_comps;
  unsigned int count = 0;
  OM_S_OBJECT_LINKAGE *p_list=NULL,*p1_list = NULL;
  int cnt = 0;

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  fprintf (file, "%sEdge Properties:\n", indent);

  /*
   * Print the Edge Properties
   */

  props = ME.EMSedge->ed_props;

  fprintf (file, "%s ", indent);
  if (!(props & EMED_OPEN))
    fprintf (file, "Not ");
  fprintf (file, "Open in UV | ");

  if (!(props & EMED_ISO))
    fprintf (file, "Not ");
  fprintf (file, "Isopar | ");

  if (!(props & EMED_REVERSED))
    fprintf (file, "Not ");
  fprintf (file, "Reversed | ");

  if (!(props & EMED_NATURAL))
    fprintf (file, "Not ");
  fprintf (file, "Natural |\n");

  fprintf (file, "%s ", indent);
  if (!(props & EMED_DEGENERATE))
    fprintf (file, "Not ");
  fprintf (file, "Degenerate in XYZ | ");

  if (!(props & EMED_XYZ_CLOSED))
    fprintf (file, "Not ");
  fprintf (file, "Closed in XYZ | ");

  if (!(props & EMED_TANGENT))
    fprintf (file, "Not ");
  fprintf (file, "Tangent |\n");

  fprintf (file, "%s ", indent);
  if (!(props & EMED_REVERSE_CONNECT))
    fprintf (file, "Not ");
  fprintf (file, "Reverse Connected | ");

  if (!(props & EMED_SEAM))
    fprintf (file, "Not ");
  fprintf (file, "Seam | ");

  if (!(props & EMED_SUBORDINATE))
    fprintf (file, "Not ");
  fprintf (file, "Subordinate | ");

  if (!(props & EMED_MSCEXISTS))
    fprintf (file, "No ");
  fprintf (file, "MSC Exists |\n");

  /*
   * Print the model space curve type of this edge
   */

  fprintf (file, "%sCurve Type in XYZ:\n", indent);
  EFget_string_for_edge_type (ME.EMSedge->curve_type, str);
  fprintf (file, "%s %s\n", indent, str);

  /*
   * Print the common edge
   */

  fprintf (file, "%sCommon Edge:\n", indent);
  
  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);
  stat_OM = om$get_channel_count(objid = my_id,
                                 osnum = OS,
                                 p_chanselect = &chan_to_common,
                                 count = &count);
  Error (!(1 & stat_OM)) ;
  num_objs = count;
  if (num_objs)
  {
    p_list = (OM_S_OBJECT_LINKAGE *) alloca ( sizeof (OM_S_OBJECT_LINKAGE));
    Error (!p_list);
    stat_OM = om$get_channel_objects (list = p_list,
                                    size = 1,
                                    count = &count,
                                    objid = my_id,
                                    osnum = OS,
                                    p_chanselect = &chan_to_common);
    commobj = p_list[0].S_objid;
  }

/*
  num_objs = omGetObjsOnChannel (my_id, OS, &chan_to_common, &commobj);
*/
  if (num_objs)
    fprintf (file, "%s Id = %d\n", indent, commobj);
  else
    fprintf (file, "%s None\n", indent);

  /*
   * Print all the owners of this edge
   */

  fprintf (file, "%sOwners of Edge:\n", indent);

  EMmake_chanselect (EMSedge_to_owner, &chan_to_owners);
/*
  num_objs = omNumObjsOnChannel (my_id, OS, &chan_to_owners);
*/
 count = 0;
 stat_OM = om$get_channel_count(objid = my_id,
                                osnum = OS,
                                p_chanselect = &chan_to_owners,
                                count = &count);
 Error (!(1 &stat_OM)) ;
 num_objs = count;
  fprintf (file, "%s Number of owners = %d\n", indent, num_objs);

  if (num_objs)
  {
    OM_S_OBJECT_LINKAGE *p1_list = NULL;
    int cnt = 0;
    objs = (GRobjid *) alloca (num_objs * sizeof (GRobjid));
 
    p1_list = (OM_S_OBJECT_LINKAGE *) alloca (count *
                                             sizeof (OM_S_OBJECT_LINKAGE));
    Error (!p1_list);
    stat_OM = om$get_channel_objects (list = p1_list,
                                    size = count,
                                    count = &count,
                                    objid = my_id,
                                    osnum = OS,
                                    p_chanselect = &chan_to_owners);
    for (cnt=0; cnt<count; cnt++)
      objs[cnt] = p1_list[cnt].S_objid;

/*
    num_objs = omGetObjsOnChannel (my_id, OS, &chan_to_owners, objs);
*/

    EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_comps);
    stat_OM = GRprint_channel_objects (file, num_indent, num_objs, objs,
            my_id, OS, &chan_to_comps);
    Error (!stat_OM);
  }

  /*
   * If the print of the super class is requested send the message
   * on high
   */

  if (print_super_class)
  {
    stat_OM = om$send (mode = OM_e_wrt_message, 
               msg = message EMSboundary.GRprint (file, num_indent, 
               TRUE, TRUE), targetid = my_id);
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
  IGRchar line[GR_MAX_CHAR+1], *p_line, *token, *fstat;
  IGRushort props, props_mask;
  IGRint i, num_objs, *conninx;
  IGRlong stat_OM=OM_S_SUCCESS;
  GRobjid *objs, commed;
  OM_S_CHANSELECT chan_to_owners, chan_to_common, chan_to_comps;

  /*
   * Search the file line-by-line where "Edge" occurs as the first
   * token. This indicates that what is to follow is this class's formatted
   * data.
   */

  while (!done && fgets (line, GR_MAX_CHAR, file))
  {
    token = strtok (line, " ");
    if (strcmp (token, "Edge") == STRING_MATCH)
    {
      /*
       * The following 3 lines of data contain the edge properties.
       * Extract them and post them in the instance data.
       */

      props_mask = EMED_OPEN | EMED_ISO | EMED_REVERSED | EMED_NATURAL |
                   EMED_DEGENERATE | EMED_XYZ_CLOSED | EMED_TANGENT | 
                   EMED_REVERSE_CONNECT | EMED_SEAM | EMED_SUBORDINATE | 
                   EMED_MSCEXISTS;
      props = props_mask;

      fstat = fgets (line, GR_MAX_CHAR, file);
      Error (!fstat);
      p_line = strtok (line, " ");

      for (i=0; i<4; i++)
      {
        token = strtok (i ? NULL : p_line, "|");
        if (i == 0 && toupper (token[0]) == 'N')
          props &= EMED_OPEN;
        else if (i == 1 && toupper (token[0]) == 'N')
          props &= EMED_ISO;
        else if (i == 2 && toupper (token[0]) == 'N')
          props &= EMED_REVERSED;
        else if (i == 3 && toupper (token[0]) == 'N' &&
                           toupper (token[1]) == 'O')
          props &= EMED_NATURAL;
      }

      fstat = fgets (line, GR_MAX_CHAR, file);
      Error (!fstat);
      p_line = strtok (line, " ");

      for (i=0; i<3; i++)
      {
        token = strtok (i ? NULL : p_line, "|");
        if (i == 0 && toupper (token[0]) == 'N')
          props &= EMED_DEGENERATE;
        else if (i == 1 && toupper (token[0]) == 'N')
          props &= EMED_XYZ_CLOSED;
        else if (i == 2 && toupper (token[0]) == 'N')
          props &= EMED_TANGENT;
      }

      fstat = fgets (line, GR_MAX_CHAR, file);
      Error (!fstat);
      p_line = strtok (line, " ");

      for (i=0; i<3; i++)
      {
        token = strtok (i ? NULL : p_line, "|");
        if (i == 0 && toupper (token[0]) == 'N')
          props &= EMED_REVERSE_CONNECT;
        else if (i == 1 && toupper (token[0]) == 'N')
          props &= EMED_SEAM;
        else if (i == 2 && toupper (token[0]) == 'N')
          props &= EMED_SUBORDINATE;
        else if (i == 3 && toupper (token[0]) == 'N')
          props &= EMED_MSCEXISTS;
      }
    }

    else if (strcmp (token, "Curve") == STRING_MATCH)
    {
      /*
       * The following line of data contains the curve type for this
       * edge in XYZ.
       */

      fstat = fgets (line, GR_MAX_CHAR, file);
      Error (!fstat);
      token = strtok (line, " ");
      
      EFget_edge_type_for_string (token, &ME.EMSedge->curve_type);
    }

    else if (strcmp (token, "Common") == STRING_MATCH)
    {
      /*
       * The following line of data contains the common edge to connect
       * to.
       */

      fstat = fgets (line, GR_MAX_CHAR, file);
      Error (!fstat);
      token = strtok (line, " ");

      EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);
      stat_OM = om$send (msg = message Root.wild_disconnect (chan_to_common),
                 targetid = my_id);
      Error (!stat_OM);

      if (!isalpha (token[0]))
      {
        commed = atoi (token);
        stat_OM = om$send (msg = message Root.connect (chan_to_common, 0,
                   my_id, OS, chan_to_common, 0), targetid = commed);
        Error (!stat_OM);
      }
    }

    else if (strcmp (token, "Owners") == STRING_MATCH)
    {
      /*
       * The following line of data contains the objects (loops and part-edges)
       * which own this edge. 
       */

      fstat = fgets (line, GR_MAX_CHAR, file);
      Error (!fstat);
      token = strtok (line, " ");
      for (i=0; i<4 ; i++)
        token = strtok (NULL, " ");

      num_objs = atoi (token);
      objs = (GRobjid *) alloca (num_objs * sizeof (GRobjid));
      conninx = (IGRint *) alloca (num_objs * sizeof (GRobjid));
      stat_OM = GRread_channel_objects (file, num_objs, objs, conninx);
      Error (!stat_OM);

      EMmake_chanselect (EMSedge_to_owner, &chan_to_owners);
      stat_OM = om$send (msg = message Root.wild_disconnect (chan_to_owners),
                 targetid = my_id);
      Error (!stat_OM);

      EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_comps);
      for (i=0; i<num_objs; i++)
      {
        stat_OM = om$send (msg = message Root.connect (chan_to_comps, i,
                   my_id, OS, chan_to_owners, conninx[i]), targetid = objs[i]);
        Error (!stat_OM);
      }
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
               msg = message EMSboundary.GRread (file, TRUE, TRUE),
               targetid = my_id);
    Error (!(1&stat_OM));
  }

wrapup:
  return (stat_OM);
}

end implementation EMSedge;
