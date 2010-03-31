/*
  DESCRIPTION

  The Root class from which all of EMS-classes are subclassed. It
  has the functionality to perform some generic manipulations with
  construction and channel sends on objects.


  HISTORY

  28 Aug 1992 NP  The "p_chanselect" parameter of the "send_obj" message was
  		declared as a "OM_S_CHANSELECT" instead of "OM_p_CHANSELECT".
  07 Dec 1988 jBk Added inclusions of EMStypedef.h and EMSadt.h.
                Added message EMaddSelfToList.
  Timeless    Unk Creation.
*/

class specification Rootmsg (1:0) of Root;

# include "Rootmsg.h"
# include "EMStypedef.h"
# include "EMSadt.h"

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message chan_pass
(
  OM_S_PATH_LIST path[];
  int num_levels;
  OM_p_MESSAGE msg;
);

message construct_obj
(
  char *classname;
  OMuword classid;
  OM_S_OBJID objid;
  OM_S_OBJECTHDR *object;
  OMuword obj_osnum;
  OMuword osnum;
  char *osname;
  OM_S_NEIGHBOR neighbor;
  OM_p_MESSAGE msg;
  OM_S_OBJID *p_objid;
  char *p_tag;
);

message send_obj
(
  int type;
  OM_E_WRT_FLAG mode;
  OM_p_MESSAGE msg;
  OM_S_OBJID senderid;
  OM_S_OBJID targetid;
  OMuword targetos;
  OM_p_CHANSELECT p_chanselect;
  int from_ndx;
  int to_ndx;
);

message EMaddSelfToList
(
  EMSrc *rc;
  struct EMStreeHeap *p_list;
);

#endif

end specification Rootmsg;
