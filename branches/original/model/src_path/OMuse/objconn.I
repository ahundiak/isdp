class implementation Root;

/* Includes */

#include "OMminimum.h"          /* OM */
#include "OMerrordef.h"           

#include "PWminimum.h"          /* Pathway */
#include "PWerror.h"

/* Prototypes */

#include "objconn.h"

/*
  ABSTRACT

  Connects an object to another object (to_object) on a channel at the given 
  index. Also connects the another object to this object (object) on a chan-
  nel at it's index.  

  ARGUMENTS

  to_object    I Object to which the object need to be connected.
  to_os        I Osnum.
  p_to_channel I Channel of the object on which the object need to be 
                 connected.
  to_index     I Index at which the object need to be connected.
 
  object       I Object which needs to be connected.
  os           I Osnum.
  p_channel    I Channel on which the object will have to_object.
  index        I Index at which the to_object is getting connected.
  
  NOTES

  None
*/

PWresult omConnectObjectAtIndex
(
  PWobjid to_object,
  PWobjid to_os,
  OM_S_CHANSELECT *p_to_channel,
  int to_index,
  PWobjid object,
  PWosnum os,
  OM_S_CHANSELECT *p_channel,
  int index
)
{
  return (PWresult) om$send (msg = message Root.connect (*p_to_channel, 
                                   to_index, to_object, to_os, *p_channel,
                                   index), 
                             senderid = PW_K_NullObjid,
                             targetid = object,
                             targetos = os); 
}


/*
  ABSTRACT

  Disconnects an object from an object given the channel info. on which the
  objects are inter-connected.

  NOTES

  None.
*/

PWresult omDisconnectObject
(
  PWobjid to_object,
  PWobjid to_os,
  OM_S_CHANSELECT *p_to_channel,
  PWobjid object,
  PWosnum os,
  OM_S_CHANSELECT *p_channel
)
{
  return (PWresult) om$send (msg = message Root.disconnect (*p_to_channel,
                                   to_object, to_os, *p_channel),
                             senderid = PW_K_NullObjid,
                             targetid = object,
                             targetos = os);
}

end implementation Root; 
