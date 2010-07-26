/*
  DESCRIPTION

  This file contains two functions (print/read) that handle the printing of
  objects connected on a channel and the reading of the same. There is another
  flavor of the print function available that inputs the objects in the
  forms of OM_S_OBJECT_LINKAGEs. These are  primarily designed for the
  messages -- GRprint and GRread.
*/

class implementation Root;

#include <stdio.h>
#include <string.h>
#include <alloca.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "griodef.h"

#define Error(cond) \
  if (cond) \
  { \
    stat = FALSE; \
    goto wrapup; \
  }

IGRboolean GRprint_channel_objects
(
  FILE *file,
  IGRint num_indent,
  IGRint num_objects,
  OM_S_OBJID *objects,
  OM_S_OBJID this_objid,
  OMuword os,
  OM_S_CHANSELECT *other_channel
)
{
  OMuint conninx;
  IGRboolean stat=TRUE, omstat=OM_S_SUCCESS;
  IGRchar space=' ', indent[GR_MAX_CHAR+1];
  IGRint i, j, inx=0, num_rows;

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  num_rows = (num_objects / 5) + 1;
  for (i=0; i<num_rows-1; i++)
  {
    fprintf (file, "%s", indent);
    for (j=0; j<5; j++)
    {
      omstat = om$get_index (objid_c = objects[inx], osnum_c = os,
                p_chanselect = other_channel, objid = this_objid, osnum2 = os,
                indexaddr = &conninx);
      Error (!(1&omstat));

      fprintf (file, " %d-%d", objects[inx++], conninx);
    }
    fprintf (file, "\n");
  }

  if (num_rows%5)
  {
    fprintf (file, "%s", indent);
    for (j=0; j<num_rows%5; j++)
    {
      omstat = om$get_index (objid_c = objects[inx], osnum_c = os,
                p_chanselect = other_channel, objid = this_objid, osnum2 = os,
                indexaddr = &conninx);
      Error (!(1&omstat));

      fprintf (file, " %d-%d", objects[inx++]);
    }
    fprintf (file, "\n");
  }

wrapup:
  if (!(1&omstat))
    stat = FALSE;
  return (stat);
}


IGRboolean GRprint_channel_objlinks
(
  FILE *file,
  IGRint num_indent,
  IGRint num_objects,
  OM_S_OBJECT_LINKAGE *objlinks,
  OM_S_OBJID this_objid,
  OMuword os,
  OM_S_CHANSELECT *other_channel
)
{
  IGRint i;
  OM_S_OBJID *objids;

  objids = (OM_S_OBJID *) alloca (num_objects * sizeof (OM_S_OBJID));
  for (i=0; i<num_objects; i++)
    objids[i] = objlinks[i].S_objid;

  return (GRprint_channel_objects (file, num_indent, num_objects, objids,
           this_objid, os, other_channel));
}




IGRboolean GRread_channel_objects
(
  FILE *file,
  IGRint num_objects,
  OM_S_OBJID *objects,
  IGRint *conninx
)
{
  IGRboolean stat=TRUE;
  IGRchar *fstat=NULL, line[GR_MAX_CHAR+1], *token;
  IGRint i, j, objinx=0, num_rows;

  num_rows = (num_objects / 5) + 1;
  for (i=0; i<num_rows-1; i++)
  {
    fstat = fgets (line, GR_MAX_CHAR, file);
    Error (!fstat);
    token = strtok (line, " -");

    for (j=0; j<5; j++)
    {
      objects[objinx] = atoi (token);
      token = strtok (NULL, " ");
      conninx[objinx] = atoi (token);
      objinx++;

      token = strtok (NULL, " -");
    }
  }

  if (num_rows%5)
  {
    fstat = fgets (line, GR_MAX_CHAR, file);
    Error (!fstat);
    token = strtok (line, " -");

    for (j=0; j<num_rows%5; j++)
    {
      objects[objinx] = atoi (token);
      token = strtok (NULL, " ");
      conninx[objinx] = atoi (token);
      objinx++;

      token = strtok (NULL, " -");
    }
  }

wrapup:
  if (!fstat)
    stat = FALSE;
  return (stat);
}

end implementation Root;
