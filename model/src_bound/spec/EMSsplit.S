/* ###################   APOGEE COMPILED   ################## */
class specification EMSsplit (1:1) of EMSbd_owner;

#include "EMS.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emserr.h"
#include "EMSmsgdef.h"

/*
Abstract

        This class represents split points on edges during surface boundary
        operations.

Notes

        Objects of this class are temporary, and should not exist at
        the end of an operation.
        This class is entirely for internal topological implementations
        and should not be put to any other use. 

History
        DLB     07/10/91    Disable tagging.
	SM	24-Aug-89	Added EMremove message. This message is useful
				in making a OS pass and removing all split
				objects which are hanging in space. 
        PP      12/20/87        Removed GRgraphics override
        SM      14-Oct-87       1.1 Genesis
*/

not_taggable;


/* 
Following message when sent to the EMSsplit object, will delete the object
if it is not attatched to any edge.
option - currently ignored.
*/
message EMremove(IGRlong *EMmsg; IGRushort option);

end specification EMSsplit;
