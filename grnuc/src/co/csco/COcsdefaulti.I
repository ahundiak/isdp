/*
Name
        COcsdefault

Description
        This command object services two commands namely,
        to set a default coord system and to define a contruction
        plane from a coord system. The subtype is 

Notes
        COMMAND TABLE entries for COcsdefault
        -------------------------------------------------
        command                 str_ptr         cmd_flag
        -------------------------------------------------
        set default coord sys   COcsdefault        1
        -------------------------------------------------
        def const pl from cs    COcsdefault        2
        -------------------------------------------------

History 
        Kumar Talluri   10/15/86 :  Design date and Implementation.
        vasu            08/12/87    Message file used to extract messages
        mrm             09/03/87    use current module space for sends
        dhm             08/08/91    added display of cs type
*/

class implementation COcsdefault;

#include "coimport.h"
#include "msdef.h"
#include "grmessage.h"
#include "msmacros.h"
#include "csdef.h"
#include "csmacros.h"
#include "msdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "lcdef.h"
#include "lcmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ex.h"
#include "grio.h"
#include "griomacros.h"
#include "OMminimum.h"

#define DEFAULT      1
#define DEF_CONST_PL 2
#define MATRIXTYPE   acc_event.located_object[0].module_info.md_env.matrix_type
#define MATRIX       acc_event.located_object[0].module_info.md_env.matrix

from GRcsmgr     import GRset_active_cs;
from GRgencs     import GRgetmatrix;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        COcsdefault init method                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method init (int type; char *str_ptr)
{
    IGRlong      msg;
    IGRlong      size;

    me->state = 1;      /* wakeup state */
    me->mytype = type;  /* command type */
    me->size = sizeof (struct GRevent);
    me->locate_stack.num_entries = 0;
    me->loc_attr.properties = LC_LC_ONLY | LC_DP_ONLY;
    me->loc_attr.owner_action = LC_RIGID_COMP | LC_FLEX_COMP;
    size = sizeof (me->ModuleInfo);
    gr$get_module_env (msg = &msg,
                       sizbuf = &size, 
                       buffer = &me->ModuleInfo,
                       nret = &size);

    return (OM_S_SUCCESS);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        COcsdefault wakeup method                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup (int pos)
{
    switch (me->mytype)
    {
        case DEFAULT:
            ex$message (msgnumb = GRC_M_SetDefCorSys);
            break;

        case DEF_CONST_PL:
            ex$message (msgnumb = GRC_M_DfnCnsPlCor);
            break;
   }
   return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        COcsdefault execute method                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute (int *response; char *response_data; int pos)
{
    IGRchar         exit;           /* control flag */
    IGRchar         type[MAX_CS_TYPE];  /* CS type */
    OMuword         classid;        /* for locate */
    IGRlong         bytes_ret;      /* from gragad inquiry */
    IGRint          flags[2];       /* for gragad inquiry */
    IGRshort        i;              /* index */
    IGRlong         msg, sts;       /* return codes */
    IGRlong         error;          /* from gragad inquiry */
    IGRpoint        origin;         /* of coordinate system */
    IGRdouble       cs_matrix[16];  /* copy of cs instance matrix */
    struct GRid     coord_sys;      /* located id */
    struct GRevent  acc_event;      /* for locate */
    struct var_list varlist[3];     /* for gragad inquiry */
    OM_S_CLASSLIST  classlist;      /* locate classes */

    /*
     *  locate only objects subclassed under GRcoords
     */

    sts = om$get_classid (classname = "GRcoords", p_classid = &classid);

    if (sts & 1)
    {
        classlist.w_count = 1;
        classlist.w_flags = OM_CLST_subclass;
        classlist.p_classes = &classid;
        exit = FALSE;
    }
    else
    {
        exit = TRUE;
        *response = TERMINATE;
        ex$message (msgnumb = GR_E_ErrEncCmdTrm);
        sleep (CO_MSG_DISPLAY_TIME);
    }

    while (!exit)
    {
        sts = lc$locate (rc = &msg,
                         event1 = &me->loc_event,
                         event2 = &acc_event,
                         mask1 = GRm_DATA | GRm_TEXT_VALUE,
                         mask2 = GRm_DATA,
                         eventsize = &me->size,
                         display_flag = ALL_WINDOWS | NO_PROJ_ACCEPT_POINT
                                      | ELEM_HILIGHT,
                         unhilight_mode = GRhe,
                         locate_key = GR_P_IdCorSys,
                         acc_key = GR_P_AccCorSys,
                         relocate_key = GR_E_CorSysNotFnd,
                         eligible_classes = &classlist,
                         attributes = &me->loc_attr,
                         stack = &me->locate_stack);

        if (sts & msg & 1)
        {
            coord_sys.objid = acc_event.located_object[0].located_obj.objid;
            coord_sys.osnum = acc_event.located_object[0].located_obj.osnum;

            switch (me->mytype)
            {
                case DEFAULT:

                    /*
                     *  set the default cs
                     */

                    sts = cs$make_active (msg = &msg,
                                          objid = coord_sys.objid,
                                          module = &me->ModuleInfo,
                                          display_old = TRUE,
                                          display_new = TRUE);
                    if (!(sts & msg & 1))
                    {
                        ex$message (msgnumb = GR_E_ErrEncCmdRst);
                    }

                    /*
                     *  update current point form - don't check return
                     *  codes; it doesn't matter whether it succeeds
                     */

                    sts = co$update_current_point_form (msg = &msg);

                    /*
                     * display the active cs type to the status field
                     */

                    gr$get_cs_type(buffer = type);

                    ex$message (msgnumb = GR_I_ActCSTyp,
                                justification = LEFT_JUS,
                                type = "%s",
                                var = type);

                    break;
            
                case DEF_CONST_PL:

                    /*
                     *  LOAD all the windows with the new matrix info
                     */
        
                    sts = om$send (msg = message GRgencs.GRgetmatrix
                                        (&msg, cs_matrix),
                                   targetid = coord_sys.objid,
                                   targetos = coord_sys.osnum);
                    if (!(sts & 1))
                    {
                        ex$message (msgnumb = GR_E_ErrEncCmdRst);
                        break;
                    }

                    /*
                     *  the coordinate system's matrix is stored as 
                     *  local-to-world; save the origin, transpose the matrix,
                     *  and restore the origin
                     */

                    origin[0] = cs_matrix[3];
                    origin[1] = cs_matrix[7];
                    origin[2] = cs_matrix[11];
                    cs_matrix[3] = cs_matrix[7] = cs_matrix[11] = 0;
                    i = 4;
                    MAtrnmx (&msg, &i, cs_matrix, cs_matrix);
                    cs_matrix[3] = origin[0];
                    cs_matrix[7] = origin[1];
                    cs_matrix[11] = origin[2];

                    /*
                     *  update all the window CP information
                     *  i.e: send msg to all windows Via: exec channel
                     *  send DPcal to all windows
                     *  send update msg to all windows.i.e: send to module
                     */

                    varlist[0].var = GRAGAD_FLAGS;
                    varlist[0].var_ptr = (IGRchar *) flags;
                    varlist[0].num_bytes = sizeof (IGRint) * 2;
                    varlist[0].bytes_returned = &bytes_ret;
                    varlist[1].var = CONSTRUCT_PLANE;
                    varlist[1].var_ptr = (IGRchar *) cs_matrix;
                    varlist[1].num_bytes = sizeof (IGRmatrix);
                    varlist[1].bytes_returned = &bytes_ret;
                    varlist[2].var = END_PARAM;
                    flags[0] = CONST_PL_DEF | CONST_PLANE_ON;
                    flags[1] = flags[0];
                    sts = dp$inq_set_gragad (msg = &msg,
                                            inq0_set1 = 1,
                                            osnum = me->ModuleInfo.md_id.osnum,
                                            gragad_name = "*",
                                            calc_info = 1,
                                            update = 1,
                                            which_error = &error,
                                            var_list = varlist);
                    break;
            }
        }
        else if (acc_event.response == GR_UNKNOWN_TYPE)
        {
            exit = TRUE;
        }
    }
    return (OM_S_SUCCESS);
}

end implementation COcsdefault;
