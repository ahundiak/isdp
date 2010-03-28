/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRcp_sd_to_asl

Description
        This routine will copy the objects on the command object to
        graphics set channel into the the active symbol library in the
        form of a symbol definition. 

Synopsis
        IGRlong         *msg            completion code
        IGRmatrix       symbol_matrix   Contains the translation to local
                                        symbol coordinates.
        struct GRmd_env *asl_env        target environment
        struct GRid     *sdh            symbol def header objid & osnum
        GRobjid         objid           command object id
        GRspacenum      osnum           command osnum
        OM_p_CHANSELECT chansel         command to graphics set channel.

Algorithm
        This method will copy the components of the sd to the specified
        space, transform them to the symbol definiton coordinate system,
        and generate the geometry of symbol definition header. 

        This method assumes that the symbol definition header has been
        constructed in the asl space and that it has been given extents
        of zero. 

        This method also assumes that the command object only owns
        graphics sets who in return owns save sets. 

Algorithm
        Send the GRto_cpx message to the graphics sets.  This method
        allows each graphics object to define the way in which it
        connects. 

        Call the gr$gscopy macro for the graphics sets.  This method
        allows for each graphics set to perform the neccessary post
        processing on the copied objects.  (This method must not add the
        object to any index objects).  The object will also lose all
        relations with other objects.  Then they will be transformed to
        the symbol definition coordinates. 

        Add all of the objects to the symbol definition.

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure

History
        HGW     06/23/86    Design date
        HGW     08/14/86    Changed terminology
        HGW     09/29/86    Convert to 4.0
        HGW     12/10/86    Convert to use graphics sets.
        HGW     11/16/87    Changes for version 1.1
        HGW     12/14/87    Rewrote using GRadd_components method.
        mrm     07/07/89    Clear fence off channel; this allows
                            GRsvset.GRto_cpx to use override to reconnect.
                            Allows using rigidly owned objects to define
			    a symbol definition.
        scw     07/07/92    ANSI conversion
*/

class implementation Root;

#include "coimport.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "growner.h"
#include "grgs.h"
#include "msdef.h"
#include "grsymdef.h"
#include "grgsmacros.h"

from GRgrset import GSto_cpx;
from GRowner import GRadd_components;

IGRint GRcp_sd_to_asl (msg, symbol_matrix, asl_env, sdh, objid, osnum, chansel)
IGRlong              *msg;
IGRmatrix            symbol_matrix;
struct GRmd_env      *asl_env;
struct GRid          *sdh;
GRobjid              objid;
GRspacenum           osnum;
OM_p_CHANSELECT      chansel;
{
    IGRlong           om_msg;
    IGRshort          four = 4;
    IGRint            count;
    IGRint            buffer_size;
    IGRchar           *buffer;
    IGRmatrix         matrix;
    struct GRmd_env   temp_asl_env;

    *msg = MSSUCC;
    buffer = (IGRchar *)NULL;

    /* 
     *  Build a temporary module environment with a NULL_OBJID in the
     *  module id to specify not to add the object to any index
     *  objects.
     */

    temp_asl_env = *asl_env;
    temp_asl_env.md_id.objid = NULL_OBJID;

    /*
     *  remove the fence from the graphic set channel
     */

    om_msg = gr$gsremove_fence (msg = msg,
                                senderid = objid,
                                p_chanselect = chansel);

    /*
     *  Send the GRto_cpx message to the graphics sets.  This method
     *  allows each objects to define the way in which it connects.
     */

    om_msg = om$send (msg = message GRgrset.GSto_cpx (msg),
                      senderid = objid,
                      p_chanselect = chansel);

    if (om_msg & *msg & 1)
    {
        /*
         *  Send the GRcopy message to the graphics sets.  This method
         *  allows for each grahpics set to perform the neccessary
         *  post processing on the copied objects.  (This method 
         *  must not add the object to any index objects). The object will
         *  also lose all relations with other objects. Use the temp_asl_env
         *  which contains a NULL_OBJID for the module id to signify do not
         *  add to index objects. GRcopy transforms the object by the 
         *  inverse of the original matrix times the new matrix.  Therefore  
         *  the object is in asl coordinates.    Then transform from asl 
         *  coordinates to symbol definition coordinate system (This method
         *  must not add the object to any index objects). 
         */

        MAinvmx (msg, &four, symbol_matrix, matrix);   
        MAmulmx (msg, &four, &four, &four, matrix, asl_env->md_env.matrix,
                 temp_asl_env.md_env.matrix);
        MAtypemx(msg, temp_asl_env.md_env.matrix, 
                 &temp_asl_env.md_env.matrix_type);

        om_msg = gr$gscopy (msg = msg, 
                            target_env = &temp_asl_env,
                            senderid = objid, 
                            senderos = osnum, 
                            p_chanselect = chansel);

        /* 
         *  Allow for the GRPSDNOTUNIQUE message to be returned.
         */

        if (om_msg & *msg & 1)
        {
            /*
             *  Get the number of objects owned by the graphics sets.
             */

            om_msg = gr$gsinqcount (msg = msg,
                                    count = &count,
                                    senderid = objid, 
                                    senderos = osnum,
                                    p_chanselect = chansel);

            if (om_msg & *msg & 1)
            {
                if (count)
                {
                    buffer_size = sizeof (struct GRobj_env) * count;
                    buffer = om$malloc (size = buffer_size);

                    if (buffer)
                    {
                        /*
                         *  Get the objects owned by the graphics set.
                         */

                        om_msg = gr$gsget_objects (msg = msg,
                                                   array = buffer,
                                                   size = buffer_size, 
                                                   count = &count, 
                                                   senderid = objid, 
                                                   senderos = osnum,
                                                   p_chanselect = chansel);
         
                        if (om_msg & *msg & 1)
                        {
                            om_msg = om$send
                                       (msg = message GRowner.GRadd_components
                                             (msg, 
                                             &temp_asl_env, 
                                             &count, 
                                              (struct GRobj_env *)buffer, 
                                              NULL, 
                                              NULL),
                                        senderid = objid,
                                        targetid = sdh->objid,
                                        targetos = sdh->osnum);
                        }
                    }
                    else
                    {
                        *msg = MSFAIL;
                        om_msg = OM_E_ABORT;
                    }
                }
            }
        }
    }
    if (buffer) om$dealloc (ptr = buffer);
    return (om_msg);
}
end implementation Root;
