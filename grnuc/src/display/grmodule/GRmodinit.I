/*
Name
        GRmodule.mod_init

History
        ht      07/21/86    add cell btree named object
        rc      07/28/86    removed queries from named objects
        mrm     04/14/93    create the rtree first to avoid problems with
                            creating objects during the IGEgragad construction
                            (like the base coordinate system).
        scw     08/23/94    added str argument for check_error
*/

class implementation GRmodule;


#include <stdio.h>

#include "OMindex.h"
#include "igetypedef.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "exmacros.h"

from GRrtree import GRrtconn, OMrtree_constr;         
from IGEgadget      import   add_gadget;
from IGEgragad      import   gragad_cons;

#define MOVE_WIN 55

#define check_error(sts, s);                                              \
        if (!(sts & 1))                                                   \
        {                                                                 \
            fprintf(stderr, "Error: GRmodule.mod_init: %s: %#x\n",s, sts);  \
            return(OM_E_ABORT);                                           \
        }

extern char CS_path_name[];    

method mod_init( int mod_type; char *cmdsvr; int numof_supers;
                 char *listof_supers; int vis_flag)
{
    OM_S_OBJID dummy_id;
    OM_S_OBJID gragad_id;
    char os_name[OM_K_MAXOSNAME_LEN];
    int status,rc;
    long rc_long;
    IGRint y_ht;
    IGRdouble mv_factor;
    IGRlong msg;
    GRobjid objid;
    struct GRid ds_id;
    IGRushort dschan;
    struct constr_arg_str
    {
        short key_type;
        int ret;
    };
    struct constr_arg_str constr_arg;

    // pass initialization message up to parent

    status = om$send(mode = OM_e_wrt_message,
                     msg = message module.mod_init(mod_type, cmdsvr,
                                                   numof_supers,
                                                   listof_supers, vis_flag),
                     targetid = my_id);
    check_error(status, "module.mod_init");

    // get the os name

    status = om$os_number_to_name(osnum = OM_Gw_current_OS,
                                  osname = os_name);
    check_error(status, "om$os_number_to_name");

    // construct the rtree

    constr_arg.key_type = RTREE_3D_DBL;
    status = om$construct(osname = os_name,
                          classname = "GRrtree",
                          p_objid = &objid,
                          neighbor = OM_GS_NULL_NEIGHBOR);
    check_error(status, "om$construct: GRrtree");

    status = om$send(msg = message GRrtree.OMrtree_constr(constr_arg.key_type,
                                                          &rc),
                     targetid = objid);

    check_error(status, "GRrtree.OMrtree_constr");

    // connect the rtree to the module object

    dschan = 0;
    ds_id.objid = my_id;
    ds_id.osnum = OM_Gw_current_OS;

    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRrtree.GRrtconn(&rc_long, 
                                                    &ds_id, &dschan),
                     senderid = my_id,
                     targetid = objid);
    check_error(status, "GRrtree.GRrtconn");
    check_error(rc_long, "GRrtree.GRrtconn: rc_long");

    // construct gadget object

    status = om$construct(osname = os_name,
                          classname = "IGEgragad",
                          p_objid = &gragad_id,
                          msg = message IGEgragad.gragad_cons(&msg, "window",
                                                              0.0,0.0,1.0,1.0),
                          neighbor = OM_GS_NULL_NEIGHBOR);
    check_error(status, "om$construct: IGEgragad");

    // initialize gadget

    ige$inq_term_info(y_extent=&y_ht);
    mv_factor= (1.0 * MOVE_WIN / y_ht);
    status = ige$construct_win(msg= &msg,
                               win_class = "GRwindow",
                               win_objid = &dummy_id,
                               mod_id = my_id,
                               screen = CURRENT_SCREEN, 
                               min_x = 0.004222973,
                               min_y = 0.0848416 + mv_factor, 
                               max_x =0.8319256,
                               max_y = 0.9276018 + mv_factor);
    check_error(status, "ige_construct_win");

    // add window to gadget

    status = om$send(mode = OM_e_wrt_object,
                     msg = message IGEgadget.add_gadget(&msg,&gragad_id,1),
                     senderid = my_id,
                     targetid = dummy_id);
    check_error(status, "IGEgadget.add_gadget");

    return(OM_S_SUCCESS);
}

end implementation GRmodule;
