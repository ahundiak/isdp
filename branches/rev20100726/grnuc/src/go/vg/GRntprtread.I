/*
  ABSTRACT

  This file contains the implementation of the GRprint and GRread messages
  that print and read from a file. In this implementation the flag to
  print/read the 'full_format' is ignored. 
*/

class implementation GRnotify;

#include <string.h>
#include <alloca.h>

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
  OMuint num_objects=0, dum_count=0;
  IGRlong stat_OM=OM_S_SUCCESS;
  OM_S_CHANSELECT chan_to_notify;
  OM_S_OBJECT_LINKAGE *objs;

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  fprintf (file, "%sNotification Objects:\n", indent);

  /*
   * Get and print all connected objects on the notification channel. 
   */

  om$make_chanselect (p_chanselect = &chan_to_notify, 
   channame = "GRnotify.notification");

  om$get_channel_count (p_chanselect = &chan_to_notify, object = me,
   count = &num_objects);

  fprintf (file, "%s Number of Objects = %d\n", indent, num_objects);

  if (num_objects)
  {
    objs = (OM_p_OBJECT_LINKAGE) alloca (num_objects * 
            sizeof (OM_S_OBJECT_LINKAGE));
    om$get_channel_objects (p_chanselect = &chan_to_notify, object = me,
     count = &dum_count, size = num_objects, list = objs);
    Error (dum_count != num_objects);

    stat_OM = GRprint_channel_objlinks (file, num_indent, num_objects, objs, 
               my_id, OM_Gw_current_OS, &chan_to_notify);
    Error (!stat_OM);
  }

  /*
   * If the print of the super class is requested send the message
   * on high
   */

  if (print_super_class)
  {
    stat_OM = om$send (mode = OM_e_wrt_message, 
               msg = message GRgraphics.GRprint (file, num_indent,
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
  IGRboolean done=FALSE, make_tagged_connect=FALSE;
  IGRchar line[GR_MAX_CHAR+1], *token, *fstat;
  IGRint i, *conninx, num_objects;
  IGRlong msg, stat_OM=OM_S_SUCCESS;
  GRobjid *objs;
  GRspacenum os=OM_Gw_current_OS;
  struct GRid grid;
  OM_S_CHANSELECT chan_to_notify;

  /*
   * Search the file line-by-line where "Notification" occurs as the first
   * token. This indicates that what is to follow is this class's formatted
   * data.
   */

  while (!done && fgets (line, GR_MAX_CHAR, file))
  {
    token = strtok (line, " ");
    if (strcmp (token, "Notification") == STRING_MATCH)
    {
      fstat = fgets (line, GR_MAX_CHAR, file);
      Error (!fstat);

      token = strtok (line, " ");
      for (i=0; i<4; i++)
        token = strtok (NULL, " ");
      num_objects = atoi (token);

      om$make_chanselect (p_chanselect = &chan_to_notify, 
       channame = "GRnotify.notification");

      stat_OM = om$send (msg = message Root.wild_disconnect (chan_to_notify),
                 targetid = my_id);
      Error (!(1&stat_OM));

      if (!num_objects)
      {
        done = TRUE;
        break;
      }

      objs = (GRobjid *) alloca (num_objects * sizeof (GRobjid));
      conninx = (IGRint *) alloca (num_objects * sizeof (IGRint));

      stat_OM = GRread_channel_objects (file, num_objects, objs, conninx);
      Error (!stat_OM);

      grid.osnum = OM_Gw_current_OS;
      for (i=0; i<=num_objects; i++)
      {
        grid.objid = objs[i];
        stat_OM = om$send (msg = message GRnotify.GRntfyconn (&msg, &grid,
                   &chan_to_notify, &conninx[i], &make_tagged_connect, &os),
                   targetid = my_id);
        Error (!(1&stat_OM));
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
    stat_OM = om$send (mode = OM_e_wrt_message, msg = message GRgraphics.GRread
               (file, TRUE, TRUE), targetid = my_id);
    Error (!(1&stat_OM));
  }

wrapup:
  return (stat_OM);
}

end implementation GRnotify;
