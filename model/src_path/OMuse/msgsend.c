#include "OMminimum.h"
#include "OMerrordef.h"
#include "PWminimum.h"
#include "PWapi/msgsend.h"

/*
  ABSTRACT

  This function builds a message structure that can then be used to send
  a message to an object. The different pieces of information for the message
  have to be supplied -- 
  classname: ASCII name of the class of the object to which the message
             is being sent (eg: "OMFiledOS").
  messgname: ASCII name of the message being 
             sent (eg: "write")
  messgargs: a pointer to the C-structure containing the arguments to the
             message. This structure is defined by putting together the
             arguments of this message as the fields and in exactly the same
             sequence as they occur in the message's argument list.
  argssize:  the size of the 'messgargs' structure in bytes, obtained by 
             "sizeof".
  This function returns the message structure in "messg", which can then
  be used in a message send.
*/

PWresult omMakeMessage 
(
  char *classname,
  char *messgname,
  void *messgargs,
  int argssize,
  struct PWommsg *messg
)
{
  return (PWresult) som_make_message (classname, OM_K_NOTUSING_CLASSID, 
                     messgname, argssize, messgargs, (OM_p_MESSAGE) messg);
}


/*
  ABSTRACT

  This function takes a message structure as an argument and delivers it
  to a specified object. The object that is sending this message is also
  passed in. If the message is not originating from another object, a 
  NULL_OBJID may be passed in for 'senderid'.

  The message may be optionally be delivered such that the implementation
  of the object's parent class is invoked instead. Typically, 
  'invoke_parent_implementation' is set to FALSE.
*/

PWresult omSend
(
  struct PWommsg *messg,
  PWobjid targetid,
  PWosnum targetos,
  PWobjid senderid,
  PWboolean invoke_parent_implementation
)
{
  return (PWresult) som_send_foreign (invoke_parent_implementation ? 
                     OM_e_wrt_parent : OM_e_wrt_object,
                     messg, senderid, targetid, targetos, NULL_CHANNUM);
}

