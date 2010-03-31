/* ###################   APOGEE COMPILED   ################## */
class specification EMSpointer (2:0) of GRnotify, NDnodein, EMSpointerA;

#include "EMSkey.h"
#include "emsdef.h"
#include "REpointer.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSmsgnumdef.h"

/* ************************************************************************
Description
 This class provides for performing the indirection necessary
 for a child to be able to connect to the component of an owner.
 The component tag is stored in the instance data of this class.

History
 04/24/91 : PP : Creation
 05/14/91 : PP : Subclassing from EMSassoc instead of NDnodein to
                 support the new indexing scheme.
 06/11/91 : PP : Subclassing from EMSpointerA instead of EMSassoc. 

   ************************************************************************ */

instance EMSpointer
{
 variable IGRchar info[]; /* Information about the pointer object */
 unsigned char type;      /* Type of the pointer object */
};

message EMinit(IGRlong *EMmsg;
               IGRuint obj_type;
               struct GRid *parent_GRid;
               struct GRid *context_GRid;
               OM_S_OBJID component_objid);
/* **********************************************************
Description
 This message will initialise a pointer object.

Arguments
 Input
   options     :     Not supported
   parent_GRid :     The parent of the pointer object.
   component_objid : Objid of the component who is causing this
                     indirection. Today a valid component can be a subclass
                     of surface.
   context_GRid : context with which the component is viewed

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well.
 EMS_E_Fail: Failure.

*********************************************************** */

message EMput_pointer_info  (IGRlong *EMmsg;
                             IGRushort options;
                             IGRuint type;
                             IGRuint info_size;
                             IGRchar *info);

/* *******************************************************************

Description
 This message stores the pointer information into the vla
 defined at this class. 

Arguments
 Input
  options : Currently can be set to NULL.
  type : Type to interpret the pointer information. Even though
         an int is passed in the override stores it as an unsigned
         character to optimize storage.
  info_size : Size of the pointer information.
  info : Pointer information which needs to be
         moved into the instance data.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well
 EMS_E_Fail:    If things dont go well
  ******************************************************************* */

message EMget_pointer_info(IGRlong *EMmsg;
                           IGRushort options;
                           IGRuint *type;
                           IGRuint *info_size;
                           IGRchar **info);
/* *******************************************************************

Description
 This message gets information about the pointer. If info is NULL then
 only size of the recomputation information is returned. If *info is NULL,
 then memory is malloced at this routine and the recomputation information
 returned. If *info is not NULL then it is assumed that memory has been
 allocated by the user and *info points to the recoputation information.

Arguments
 Input
  options : Currently can be set to NULL.

Output
  info_size : Size of the pointer information
  type : Type to interpret the pointer information; Returned only
         if it is non-null.
  info : Information which needs to be moved into the instance data.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well
 EMS_E_Fail:    If things dont go well

  ******************************************************************* */

message EMpass(IGRlong *EMmsg; unsigned int options; OM_p_MESSAGE messg);

/* *******************************************************************
Description 
 This message will send the incoming message to the object that the
 pointer is pointing to.

Arguments
 *EMmsg : Completion code
 options : Currently unused
 messg: The message that has to be passed.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : If all goes well.
 EMS_E_Fail :    If there is a failure whose exact cause could not be
                 determined.
 EMS_I_Fail :    If the message could not be delivered due to a topology
                 matching failure.

************************************************************************ */

override NDupdate,       /* Compute the id based on the key that is stored
                            inside me */
         GRgetobjinfo,
         NDmove_to_root, /* Delete myself and send move to root message
                            to my children */
         NDcopy_graph,   /* Copy myself with the key */
         ACcopy_to_Groot, /* Return success */
         NDmake_source,
         ASreturn_go,    /* Return the graphic/topology object */
         NDgive_structure,
         EMstore_key_from_id,
         EMstore_id_from_key,
         NDdisplay,       /* Display the topology or graphic object */
         EMstore_id, 
         debug;

end specification EMSpointer;
