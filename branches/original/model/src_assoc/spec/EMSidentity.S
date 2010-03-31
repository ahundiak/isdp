/* ###################   APOGEE COMPILED   ################## */

class specification EMSidentity (2:0) of NDnodein;

#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSmsgnumdef.h"

/*
 * This class serves to be the indirection object and is
 * created to get over the OM restriction of not being able
 * to have the same object connected multiple times on the
 * channel.
 *
 * History
 *   Creation : PP : 06/08/91
 */

message EMinit(IGRlong *EMmsg;
              IGRuint options;
              struct GRid *parent_GRid);

/* *************************************************************

Description
 This method initialises the identity object. It connect itself
 to the parent being passed in on the parent child channel.

Arguments
 options : Set to NULL.
 parent_GRid : Should be an object who has the parent child channel.
            
Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well.
 EMS_E_Fail : If there is failure.

  ************************************************************** */

override NDupdate,       /* Return success */
         NDs_compute_node, /* Return success */
         NDmove_to_root, /* Delete myself and send move to root message
                            to my children */
         ACbecome_macro,  /* Pass it on to my parent */
         ACcopy_to_Groot, /* Pass it on to my parent */
         ASreturn_go,     /* Pass it on to my parent */
         NDgive_structure,/* Pass it on to my parent */
         NDdisplay;       /* Pass it on to my parent */

end specification EMSidentity;
