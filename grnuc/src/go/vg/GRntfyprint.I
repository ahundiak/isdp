/*
  ABSTRACT

  This method prints the contents of this object's instance data related to
  this class. If the 'include_super_class' is set, then it also prints the
  data of it's super-class.
*/
	
class implementation GRnotify;

#include <alloca.h>

#define Error(cond) \
  if (cond) \
  { \
    stat_OM = OM_E_ABORT; \
    goto wrapup; \
  }
    
method EMprint
(
  FILE *file;
  int num_indent;
  int include_super_class;
)
{
  IGRchar space=' ', indent[80+1];
  OMuint num_objects=0, dum_count=0;
  IGRlong stat_OM=OM_S_SUCCESS;
  OM_S_CHANSELECT chan_to_notify;
  OM_S_OBJECT_LINKAGE *objs;

  om$make_chanselect (p_chanselect = &chan_to_notify, 
   channame = "GRnotify.notification");

  om$get_channel_count (p_chanselect = &chan_to_notify, object = me,
   count = &num_objects);

  if (num_objects)
  {
    IGRint i, j, num_rows, inx=0;

    if (num_indent)
      memset (indent, space, num_indent * sizeof (char));
    indent[num_indent] = '\0';

    objs = (OM_p_OBJECT_LINKAGE) alloca (num_objects * 
            sizeof (OM_S_OBJECT_LINKAGE));
    om$get_channel_objects (p_chanselect = &chan_to_notify, object = me,
     count = &dum_count, size = num_objects, list = objs);
    Error (dum_count != num_objects);

    fprintf (file, "%sNotification objects:\n", indent);
    num_rows = (num_objects / 5) + 1;
    for (i=0; i<num_rows-1; i++)
    {
      fprintf (file, "%s", indent);
      for (j=0; j<5; j++)
        fprintf (file, " %d", objs[inx++].S_objid);
      fprintf (file, "\n");
    }
    fprintf (file, "%s", indent);
    for (j=0; j<num_rows%5; j++)
    {
      fprintf (file, " %d", objs[inx++].S_objid);
    }
    fprintf (file, "\n");
  }

wrapup:
  return (stat_OM);
}

end implementation GRnotify;
