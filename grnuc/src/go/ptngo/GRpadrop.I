/* #######################    APOGEE COMPILED   ######################## */
 
/*
Name
        GRpa.GRdrop

Description
            This method creates a graphic group from the pattern elements
	and a simple element from the patterned element. The pattern header
	is deleted.

Notes
        
History
        jhw     08/18/88    creation date
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

from GRmodule import GRmdremove;

#include "grimport.h"
#include "msdef.h"
#include "igrdef.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grptn.h"
#include "lcmacros.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "gocmacros.h"
#include "grownerdef.h"

#define STACK_BUF_SIZE  300

extern IGRint   GRconnect_object();

method GRdrop (IGRlong  * msg; struct GRmd_env * mod_env)
{
    IGRshort                action, props;  /* args to GRchgprops */
    IGRlong                 sts; /* return codes */
    IGRint                  i;
    OMuint                  count;
    OM_S_OBJECT_LINKAGE     buf[STACK_BUF_SIZE],*lnk_buf, *p;
    struct GRvg_construct   const_args;
    OM_S_CHANSELECT         to_comp;
    OM_S_OBJID              grgrp_oid;
    struct GRid             owners_id;
    GRrange                 range;
    IGRboolean              world;

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;

    /*
     *  Get the channel to the pattern element and patterned elements.
     */
    sts = om$make_chanselect ( channame = "GRcmpowner.to_components",
                               p_chanselect = &to_comp);

    if (!(sts & 1)) goto finish;

    /*
     *  Get the objids of the patterned element and the pattern elements
     */

    sts = om$get_channel_count ( object = me,
                                 p_chanselect = &to_comp,
                                 count = &count );

    if (!(sts & 1)) goto finish;

    /*
     * Malloc a chunk of memory for the object linkages if needed, 
     * otherwise use the stack buffer.
     */
    if ( count > STACK_BUF_SIZE ) {
        if ( !(lnk_buf = (OM_S_OBJECT_LINKAGE *)
            om$malloc(size = (sizeof(OM_S_OBJECT_LINKAGE) * count))) ) {
            sts = OM_E_ABORT;
            goto finish;
        }
    }
    else lnk_buf = buf;

    /*
     * Put the channel object ids in the linkage buffer.
     */
    sts = om$get_channel_objects ( object = me,
                                   p_chanselect = &to_comp,
                                   list = lnk_buf,
                                   size = count,
                                   count = &count );

    if (!(sts & 1)) goto finish;
 
    /*
     * Disconnect all the objects from the channel and delete the 
     * pattern header. 
     */
    sts = om$send ( mode = OM_e_wrt_message,
                    msg = message GRowner.GRdrop(msg, mod_env),
                    targetid = my_id );

    if (!(sts & *msg & 1)) goto finish;

    /* 
     * Remove the pattern header's range from the rtree.
     *
     * NOTE: The patterned elements range is added twice to the rtree
     *       upon creation of the pattern. Once with the patterned 
     *       element's objid and once with the pattern header's objid.
     */
    world = FALSE;
    sts = om$send ( msg = message GRgraphics.GRgetrang ( 
                                                msg,
                                                &mod_env->md_env.matrix_type,
                                                mod_env->md_env.matrix,
                                                &world,
                                                range ),

                    targetid = lnk_buf->S_objid );
    
    if (!(sts & *msg & 1)) goto finish;

    sts = om$send ( msg = message GRmodule.GRmdremove ( msg,
                                                        range,
                                                        &my_id),
                    targetid = mod_env->md_id.objid );

    if (!(sts & *msg & 1)) goto finish;

    /*
     * Create a graphic group header.
     */
    const_args.msg = msg;
    const_args.env_info = mod_env; 
    const_args.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_NEW;
    const_args.name = NULL;
    sts = om$construct ( osnum = mod_env->md_id.osnum,
                         classname = "GRgrgrp",
                         p_objid = &grgrp_oid,
                         msg = message GRgraphics.GRconstruct(&const_args) );

    if (!(sts & 1)) goto finish;

    /*
     * Add range of all cells/syms to rtree, make them locatable and connect 
     * them to the graphic group header. 
     * 
     * NOTE: Count is the total of all cells and symbols plus the 
     *       patterned element. The lnk_buf points to the patterned
     *       element which is already added so it needs to be bumped
     *       up to point to the first cell/sym.
     */
    owners_id.osnum = mod_env->md_id.osnum;
    owners_id.objid = grgrp_oid;
    p = lnk_buf + 1;
    --count;
    action = 1;     /* set these properties */
    props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

    for ( i=0; i<count; p++, i++) {
        /*
         * Have object add its range to the rtree.
         */
        sts = om$send (targetid = p->S_objid,
                       targetos = p->osnum,
                       msg = message GRgraphics.GRaddwrng(msg, mod_env));

        if (!(sts & *msg & 1)) goto finish;

        /*
         *  Make sure the object is locatable and displayable
         */
        sts = om$send (msg = message GRgraphics.GRchgprops(msg, 
                                                           &action, 
                                                           &props),
                       targetid = p->S_objid,
                       targetos = p->osnum);

        if (!(sts & *msg & 1)) goto finish;

        /*
         * Connect the object to the graphic group header.
         */
        sts = GRconnect_object ( msg, 
                                 mod_env->md_id.osnum, 
                                 p->S_objid,
                                 &owners_id,                              
                                 GR_FLEXIBLE, 
                                 GR_NO_OVERRIDE,
                                 OM_K_MAXINT,
                                 OM_K_MAXINT );

        if (!(sts & 1)) goto finish;
    }

finish:

#ifdef DEBUG
    if (!(sts & *msg & 1)) {
        printf ("GRpa.GRdrop failed\nmsg = %#x\n", *msg);
        om$report_error (sts = sts);
    }
#endif

    return (sts);
}

end implementation GRpa;
    
