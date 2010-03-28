/*
Name
        GRrtutil.I - Range Tree Utilities

Description
        This file contains code to dump the contents of the Rtree.  It is
        intended exclusively for debugging purposes.

History
        mrm     04/15/93        creation
*/

class implementation GRgraphics;

#include <stdio.h>
#include <bsvalues.h>
#include "exmacros.h"

from OMrtree import pass, find_key;

%safe
static int rtree_count = 0;
%endsafe

/*
Name
        GRdump_rtree_function

Description
        This function is used as a callback from the GRdump_rtree_by_osnum
        function defined below to print out the contents of the rtree.
*/

int GRdump_rtree_function(int *msg, struct GRid *obj, double *range)
{
    int sts;
    char classname[32];

    rtree_count++;

    sts = om$get_classname(osnum = obj->osnum,
                           objid = obj->objid,
                           classname = classname);

    printf("%d, %3d %-12s %8.3f, %8.3f, %8.3f; %8.3f, %8.3f, %8.3f\n",
           obj->osnum, obj->objid, classname,
           range[0], range[1], range[2], range[3], range[4], range[5]);

    return(*msg = TRUE);
}

/*
Name
        GRdump_rtree_by_osnum(OMuword osnum)

Description
        This function dumps the contents of the rtree in the specified object
        space.
*/

int GRdump_rtree_by_osnum(OMuword osnum)
{
    IGRlong msg;
    int sts, ret;
    double search_range[6], target_range[6];
    OM_S_OBJID mod;
    OM_S_KEY_DESC select_key, target_key;
    OM_S_CHANSELECT primary;

    // get the module id
    sts = ex$get_modid(mod_osnum = osnum, mod_id = &mod);
    if (!(sts & 1))
    {
        printf("Failed to find module id: %#x", sts);
        return(FALSE);
    }

    // get the channel from the module to the rtree
    sts = om$make_chanselect(channame = "module.primary",
                             p_chanselect = &primary);
    if (!(sts & 1))
    {
        printf("Failed to get primary channel: %#x", sts);
        return(FALSE);
    }

    // set up for the nested message sends
    search_range[0] = -MAXDOUBLE;
    search_range[1] = -MAXDOUBLE; 
    search_range[2] = -MAXDOUBLE;
    search_range[3] = MAXDOUBLE;
    search_range[4] = MAXDOUBLE; 
    search_range[5] = MAXDOUBLE;
    select_key.type = KEY_3D_DBL;
    select_key.key.p_3ddbl = (DB_3D_DBL_BOX *)search_range;
    target_key.type = KEY_3D_DBL;
    target_key.key.p_3ddbl = (DB_3D_DBL_BOX *)target_range;
    rtree_count = 0;

    // pass the GRfunction message through GRmodule & GRrtree
    sts = om$send(msg = message OMrtree.pass
                  (message GRgraphics.GRfunction(&msg,
                                                 GRdump_rtree_function,
                                                 (IGRchar *)target_range),
                   &select_key,
                   NULL,
                   &target_key,
                   NULL,
                   &ret),
                  senderid = mod,
                  targetos = osnum,
                  p_chanselect = &primary);

    if (!(sts & 1) || ret)
    {
        printf("OMrtree.pass failed: %#x, %d\n", sts, ret);
        om$report_error(sts = sts);
        return(FALSE);
    }

    printf("Rtree pass complete, %d objects encountered\n", rtree_count);

    return(TRUE);
}

/*
Name
        GRdump_rtree()

Description
        This function dumps the contents of the rtree in the active object
        space.
*/

int GRdump_rtree()
{
    int sts;
    OMuword osnum;
    OM_S_OBJID mod;

    // get the module id
    sts = ex$get_cur_mod(osnum = &osnum, id = &mod);
    if (!(sts & 1))
    {
        printf("Failed to find current module id/osnum: %#x", sts);
        return(FALSE);
    }

    // dump the rtree in the active file
    sts = GRdump_rtree_by_osnum(osnum);
    return(sts);
}

/*
Name
        GRrtree_range

Description
        This function determines whether an object is in the rtree and, if so,
        optionally returns its range.
*/

int GRrtree_range(OMuword osnum, OM_S_OBJID objid, double *range)
{
    int sts, msg;
    double search_range[6], rtree_range[6];
    OM_S_OBJID mod;
    OM_S_CHANSELECT primary;
    OM_S_KEY_DESC select_key, target_key;

    // get the module id
    sts = ex$get_modid(mod_osnum = osnum, mod_id = &mod);
    if (!(sts & 1))
        return(FALSE);

    // get the channel from the module to the rtree
    sts = om$make_chanselect(channame = "module.primary",
                             p_chanselect = &primary);
    if (!(sts & 1))
        return(FALSE);

    // initialize search range & method arguments
    search_range[0] = -MAXDOUBLE;
    search_range[1] = -MAXDOUBLE; 
    search_range[2] = -MAXDOUBLE;
    search_range[3] = MAXDOUBLE;
    search_range[4] = MAXDOUBLE; 
    search_range[5] = MAXDOUBLE;
    select_key.type = KEY_3D_DBL;
    select_key.key.p_3ddbl = (DB_3D_DBL_BOX *)search_range;
    target_key.type = KEY_3D_DBL;
    target_key.key.p_3ddbl = (DB_3D_DBL_BOX *)(range ? range : rtree_range);

    // scan the entire rtree for the object
    sts = om$send(msg = message OMrtree.find_key(&select_key, &objid, 
                                                 &target_key, 0, &msg),
                  senderid = mod,
                  targetos = osnum,
                  p_chanselect = &primary);

    if (!(sts & 1) || msg)
        return(FALSE);

    return(TRUE);
}

/*
Name
        GRin_rtree

Description
        This function determines whether an object is in the rtree.
*/

int GRin_rtree(OMuword osnum, OM_S_OBJID objid)
{
    return(GRrtree_range(osnum, objid, NULL));
}

/*
Name
        GRprint_rtree_range

Description
        This function determines whether an object is in the rtree and, if so,
        prints its range.
*/

void GRprint_rtree_range(OMuword osnum, OM_S_OBJID objid)
{
    double range[6];

    if (GRrtree_range(osnum, objid, range))
    {
        printf("(%d, %d) %g, %g, %g; %g, %g, %g", osnum, objid,
               range[0], range[1], range[2], range[3], range[4], range[5]);
    }
    else
    {
        printf("Object %d, %d is not in the rtree\n");
    }
}

end implementation GRgraphics;
