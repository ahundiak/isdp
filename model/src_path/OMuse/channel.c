/*
  OVERVIEW

    This file contains functions which enquire about the objects on the 
    channels. 

  NOTES 

    None
*/

/* Includes */

#include <stdio.h>              /* System */
#include <alloca.h>

#include "OMminimum.h"          /* OM */
#include "OMerrordef.h"           

#include "PWminimum.h"          /* Pathway */
#include "PWerror.h"

/* Prototypes */

#include "channel.h"


/* External Functions */

extern int som_get_channel_count (OMuword osnum, OM_S_OBJID objid,
                OM_p_OBJECTHDR p_object, OM_p_CHANSELECT p_chanselect,
                OMuint *count);

extern int som_get_channel_objects (OMuword osnum, OM_S_OBJID objid,
                OM_p_OBJECTHDR p_object, OM_p_CHANSELECT p_chanselect,
                OM_S_OBJECT_LINKAGE list[], OMuint size, OMuint *count);

/*
  ABSTRACT

    Returns the number of objects sitting on the given channel. If any error
    or the channel is not a valid one for this object it returns zero.

  NOTES

    A zero return does not necessarily mean that, it is a invalid channel.
    But, it only suggests that this particular object does not  have  any
    objects on this channel.

*/

int omNumObjsOnChannel
(
  PWobjid obj,
  PWosnum os,
  OM_S_CHANSELECT *p_channel
)
{
  long OMsts=OM_S_SUCCESS;
  unsigned int count=0;

  OMsts = som_get_channel_count (os, obj, (OM_p_OBJECTHDR)NULL, p_channel, 
                                 &count);
  if (!(1&OMsts))
    return 0;
  else
    return count;
}


/*
  ABSTRACT

    Gets all the objects on a given channel and returns the number of objects.
    If any error or the channel is not a valid one for this object it returns
    zero.

  NOTES

    A zero return does not necessarily mean that, it is a invalid channel.
    But, it only suggests that this particular object does not have any
    objects on this channel.

*/

int omGetObjsOnChannel
(
  PWobjid obj,
  PWosnum os,
  OM_S_CHANSELECT *p_channel,
  PWobjid *p_outobjs
)
{
  int i=0;
  long OMsts=OM_S_SUCCESS;
  unsigned int count=0;

  count = omNumObjsOnChannel (obj, os, p_channel);

  if (count)
  {
    OM_S_OBJECT_LINKAGE *p_list=NULL;

    p_list = (OM_S_OBJECT_LINKAGE *) alloca (count * 
                                             sizeof (OM_S_OBJECT_LINKAGE));
    if (!p_list)
      return 0;

    OMsts = som_get_channel_objects (os, obj, (OM_p_OBJECTHDR)NULL, p_channel,
                                     p_list, count, &count);
    if (!(1&OMsts))
      return 0;

    for (i=0; i<count; i++)
      p_outobjs[i] = p_list[i].S_objid;
  }

  return (int) count;
}
