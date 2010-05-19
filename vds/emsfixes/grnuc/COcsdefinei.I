/* $Id: COcsdefinei.I,v 1.2 2001/01/13 00:22:49 hans Exp $ */
/***************************************************************************
 * I/VDS
 *
 * File:        vds/emsfixes/grnuc/
 *
 * Description:
 *              Duplicate element names
 *
 * Revision History:
 *	$Log: COcsdefinei.I,v $
 *	Revision 1.2  2001/01/13 00:22:49  hans
 *	SP16 modifications
 *	
 *
 * Dependencies:
 *              GRNUCSRC/src/co/csco/
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/07/00        Jayadev         changes for CR179901459
 ***************************************************************************/
/*
Name
        COcsdefine

Description
        This command object services all three of the Define Coordinate System
        commands:
            o Define coordinate system by 3 points
            o Define coordinate system by view alignment
            o Define coordinate system by element plane

Notes
        COMMAND TABLE entries for COcsdefault
        -------------------------------------------------
        command                   str_ptr       cmd_flag
        =================================================
        def cs by 3 points      COcsdefine        1
        -------------------------------------------------
        def cs by view alignm   COcsdefine        2
        -------------------------------------------------
        def cs by elem plane    COcsdefine        3
        -------------------------------------------------

        The logical flow for this command object is as follows:

        a. Form a rotation matrix depending on the type of
           command. i.e: 3pt, view or elem plane.
        b. Get the Name of the coordinate system.
        c. Get the description of the coordinate system.
        d. construct the coordinate system as apecified

History
        Kumar Talluri   10/15/86    Design date and Implementation.
                        10/25/86    added define cs by 3 pts command.
                        11/08/86    added define cs by elem plane command.
        vasu            08/11/87    Message file used to extract messages
        mrm             03/07/88    change from GRcsmgr.GRconstruct_new_cs
                                    to om$construct
                        01/20/89    add backup support
        dhm             08/08/91    add cs type to cs_args
        scw             01/07/92    changed the inrot call to dp$inq_set_gragad
*/

class implementation COcsdefine;

#include "coimport.h"
#include "msdef.h"
#include "grmessage.h"
#include "msmacros.h"
#include "grcoordsys.h"
#include "csdef.h"
#include "csmacros.h"
#include "msdef.h"
#include "lcdef.h"
#include "lcmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "grdpbmacros.h"
#include "ex.h"
#include "grio.h"
#include "griomacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#define CS_3PNT         1
#define CS_VIEW         2
#define CS_PLANAR       3
#define INITIAL_STATE   1
#define POINT1          1
#define POINT2          2
#define POINT3          3
#define MATRIXTYPE acc_event.located_object[0].module_info.md_env.matrix_type
#define MATRIX     acc_event.located_object[0].module_info.md_env.matrix

from GRgraphics import GRconstruct;
from GRvg       import GRdetplane;
from IGEgragad  import DPinrot;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        COcsdefine init method                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method init (int type; char *str_ptr)
{
    me->mytype = type;
    me->state = INITIAL_STATE;
    me->mx_defined = FALSE;

    /*
     *  the following is for the locate in Define cs from element plane
     */

    if (me->mytype == CS_PLANAR)
    {
        strcpy (me->loc_attr.classes, "GRgraphics");
        me->loc_attr.properties = LC_LC_ONLY | LC_RW | LC_DP_ONLY
                                | LC_NEW_MOD | LC_PLANAR_ONLY;
        me->loc_attr.owner_action = LC_FLEX_COMP | LC_RIGID_COMP
                                  | LC_REF_OBJECTS;
        me->locate_stack.num_entries = 0;
        me->size = sizeof (struct GRevent);
    }

    return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        COcsdefine wakeup method                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup (int pos)
{
    switch (me->mytype)
    {
        case CS_VIEW:
            ex$message (msgnumb = GRC_M_DfnCorVwAl);
            break;

        case CS_PLANAR:
            ex$message (msgnumb = GRC_M_DfnCorPlEle);
            break;

        case CS_3PNT:
            ex$message (msgnumb = GRC_M_DfnCor3Pt);
            break;

        default:
            break;
    }
    return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        COcsdefine execute method                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute (int *response; char *response_data; int pos)
{
    IGRchar                 exit;       /* control flag */
    IGRchar                 type_string[MAX_CS_TYPE];
    IGRshort                i;          /* index */
    IGRint                  name_len;   /* chars in coord sys name */
    IGRint                  desc_len;   /* chars in coord sys description */
    IGRlong                 sts, msg;   /* return codes */
    IGRlong                 size;       /* dpb parameter */
    IGRpoint                point;      /* on plane */
    IGRvector               normal;     /* to plane */
    GRobjid                 objid;      /* of located event */
    GRspacenum              osnum;      /* of located event */
    struct GRid             CSobj;      /* id of construct object */
    struct GRevent          event;      /* input event */
    struct GRevent          acc_event;  /* for locate */
    struct IGRlbsys         lbs_geom;   /* local bounded system geometry */
    struct IGRplane         elem_plane; /* plane of located element */
    struct GRvg_construct   cnst_lis;   /* construct argument list */
    struct GRcs_construct   cs_args;    /* cs-specific construction args */
    char current_dir[DI_PATH_MAX],full_name[DI_PATH_MAX];
    IGRint ret_type=FALSE;
    char mesg[DI_PATH_MAX];
    /*
     *  the following block of code generates the required matrix
     *  depending on mytype.
     */

    exit = FALSE;

    while (!exit)
    {
        switch (me->mytype)
        {
            case CS_3PNT:

                while (!me->mx_defined)
                {
                    switch (me->state)
                    {
                        /*
                         *      collect all the three points and form a
                         *      rotation matrix
                         */

                        case POINT1:

                            co$getevent (msg = &msg,
                                         event_mask = GRm_DATA,
                                         msgnum = GR_P_EntPt1O,
                                         response = response,
                                         response_data = response_data,
                                         event = &event);

                            if (event.response == EX_DATA)
                            {
                                me->point1[0] = event.event.button.x;
                                me->point1[1] = event.event.button.y;
                                me->point1[2] = event.event.button.z;
                                me->state = POINT2;
                            }
                            else
                            {
                                goto finish;
                            }
                            break;

                        case POINT2:

                            co$getevent (msg = &msg,
                                         event_mask = GRm_DATA | GRm_RESTART
                                                    | GRm_BACK_UP,
                                         msgnum = GR_P_EntPt2X,
                                         response = response,
                                         response_data = response_data,
                                         event = &event);

                            if (event.response == EX_DATA)
                            {
                                me->point2[0] = event.event.button.x;
                                me->point2[1] = event.event.button.y;
                                me->point2[2] = event.event.button.z;
                                me->state = POINT3;
                            }
                            else if (event.response == EX_RESTART ||
                                     event.response == EX_BACK_UP)
                            {
                                me->state = POINT1;
                            }
                            else
                            {
                                goto finish;
                            }
                            break;

                        case POINT3:

                            co$getevent (msg = &msg,
                                         event_mask = GRm_DATA | GRm_RESTART
                                                    | GRm_BACK_UP,
                                         msgnum = GR_P_EntPt3Y,
                                         response = response,
                                         response_data = response_data,
                                         event = &event);

                            if (event.response == EX_DATA)
                            {
                                MA3protmx (&msg,
                                           me->point1,
                                           me->point2,
                                           &event.event.button.x,
                                           me->matrix);
                                if (msg != MSSUCC)
                                {
                                    ex$message (msgnumb = GR_E_DgnPts);
                                    me->state = POINT1;
                                }
                                else
                                {
                                    me->origin[0] = me->point1[0];
                                    me->origin[1] = me->point1[1];
                                    me->origin[2] = me->point1[2];
                                    me->mx_defined = TRUE;
                                }
                            }
                            else if (event.response == EX_RESTART)
                            {
                                me->state = POINT1;
                            }
                            else if (event.response == EX_BACK_UP)
                            {
                                me->state = POINT2;
                            }
                            else
                            {
                                goto finish;
                            }
                            break;
                    } /* switch (me->state) */
                } /* while (!me->mx_defined) */
                break;

            case CS_VIEW:

                while (!me->mx_defined)
                {
                    /*
                     *      Identify the view and get the rotation matrix
                     *      from view
                     */

                    co$getevent (msg = &msg,
                                 event_mask = GRm_DATA,
                                 msgnum = GR_P_EntOrgCor,
                                 response = response,
                                 response_data = response_data,
                                 event = &event);

                    if (event.response == EX_DATA)
                    {
                        IGRlong         error;
                        IGRlong         num_bytes;
                        struct var_list var_list[2]; /* for gragad inquiry */

                        var_list[0].var = VW_ROT_NO_CON;
                        var_list[0].var_ptr = (IGRchar *)me->matrix;
                        var_list[0].num_bytes = sizeof(IGRdouble) * 16;
                        var_list[0].bytes_returned = &num_bytes;
                        var_list[1].var = END_PARAM;

                        sts = dp$inq_set_gragad( msg = &msg,
                                                 osnum =
                                                   event.event.button.osnum,
                                                 gragad_objid =
                                                   event.event.button.objid,
                                                 which_error = &error,
                                                 var_list = var_list );

                        me->origin[0] = event.event.button.x;
                        me->origin[1] = event.event.button.y;
                        me->origin[2] = event.event.button.z;
                        me->mx_defined = TRUE;
                    }
                    else
                    {
                        goto finish;
                    }
                }
                break;

            case CS_PLANAR:

                while (!me->mx_defined)
                {
                    /*
                     *      Identify a planar element and build a rotation
                     *      matrix from the element's plane.
                     */

                    sts = lc$locate (rc = &msg,
                                     event1 = &me->loc_event,
                                     event2 = &acc_event,
                                     mask1 = GRm_DATA | GRm_TEXT_VALUE,
                                     mask2 = GRm_DATA,
                                     eventsize = &me->size,
                                     display_flag = ALL_WINDOWS
                                                  | ELEM_HILIGHT
                                                  | NO_PROJ_ACCEPT_POINT
                                                  | ACC_REJ_CYCLE
                                                  | RELOCATE
                                                  | LC_REGULAR_HIGHLIGHT
                                                  | LC_ERASE_ALL,
                                     unhilight_mode = GRhe,
                                     locate_key = GR_P_IdEle,
                                     acc_key = GR_P_AccCorSysOrg,
                                     relocate_key = GR_E_EleNotFnd,
                                     attributes = &me->loc_attr,
                                     stack = &me->locate_stack);

                    if (!sts || !msg || (acc_event.response != EX_DATA))
                    {
                        goto finish;
                    }

                    objid = acc_event.located_object[0].located_obj.objid;
                    osnum = acc_event.located_object[0].located_obj.osnum;
                    elem_plane.point = point;
                    elem_plane.normal = normal;

                    sts = om$send (msg = message GRvg.GRdetplane
                                      (&msg, &MATRIXTYPE, MATRIX, &elem_plane),
                                   targetid = objid,
                                   targetos = osnum);

                    if (!(msg & sts & 1))
                    {
                        ex$message (msgnumb = GR_E_CantDetPl);
                        break;
                    }

                    MAzrotmx (&msg, normal, me->matrix);
                    if (msg != MSSUCC)
                    {
                        ex$message (msgnumb = GR_E_CantDetPl);
                        break;
                    }

                    me->origin[0] = acc_event.event.button.x;
                    me->origin[1] = acc_event.event.button.y;
                    me->origin[2] = acc_event.event.button.z;
                    me->mx_defined = TRUE;
                }
                break;

            default: break;
        }

        while (me->mx_defined)
        {
            /*
             *  get the name [, description] of the coordinate system
             */

            co$getevent (msg = &msg,
                         event_mask = GRm_STRING | GRm_RESTART | GRm_BACK_UP,
                         msgnum = GR_P_EntCorSysNme,
                         response = response,
                         response_data = response_data,
                         event = &event);

            if (event.response == EX_RESTART)
            {
                me->state = INITIAL_STATE;
                me->mx_defined = FALSE;
                break;
            }
            else if (event.response == EX_BACK_UP)
            {
                me->mx_defined = FALSE;
                break;  /* me->state is still set */
            }
            else if (event.response != EX_STRING)
            {
                goto finish;
            }

            /*
             *  parse string for name & description and expand name
             */

            sts = GRparse_name_desc (&msg, event.event.keyin,
                                     me->csname, &name_len,
                                     me->csdesc, &desc_len);

	 /* check for duplicate naming CR179901459*/
        di$pwd(dirname = current_dir);
        sprintf(full_name,"%s:%s",current_dir,me->csname);
        while(di$translate ( objname = full_name, p_objid = &objid, p_osnum = &osnum ) == DIR_S_SUCCESS)
        {
          sprintf(mesg,"Duplicate name %s - reEnter name",full_name);
          UI_status(mesg);
          sleep(1);

            co$getevent (msg = &msg,
                         event_mask = GRm_STRING | GRm_RESTART | GRm_BACK_UP,
                         msgnum = GR_P_EntCorSysNme,
                         response = response,
                         response_data = response_data,
                         event = &event);
            if (event.response == EX_RESTART)
            {
                me->state = INITIAL_STATE;
                me->mx_defined = FALSE;
                goto finish;
            }
            else if (event.response == EX_BACK_UP)
            {
                me->mx_defined = FALSE;
                goto finish;
            }
            else if (event.response != EX_STRING)
            {
                goto finish;
            }
            sts = GRparse_name_desc (&msg, event.event.keyin,
                                     me->csname, &name_len,
                                     me->csdesc, &desc_len);
            sprintf(full_name,"%s:%s",current_dir,me->csname);
        } /* check complete */
            di$cvt_name_from_input (u_path = me->csname);

            /*
             *  set up the local bounded system geometry for the
             *  coordinate system -- transpose the view rotation matrix, add
             *  in the origin, and give it a degenerate diagonal
             */

            i = 4;

            MAtrnmx (&msg, &i, me->matrix, lbs_geom.matrix);
            if (msg != MSSUCC)
            {
                me->state = INITIAL_STATE;
                break;
            }

            for (i = 0; i < 3; ++i)
            {
                lbs_geom.matrix[3 + (4 * i)] = me->origin[i];
                lbs_geom.diag_pt1[i] = 0;
                lbs_geom.diag_pt2[i] = 0;
            }

            /*
             *  set up the other construction parameters
             */

            size = sizeof (struct IGRdisplay);
            gr$get_active_display (msg = &msg,
                                   sizbuf = &size,
                                   buffer = &me->ActiveDisplay,
                                   nret = &size);

            size = sizeof (IGRshort);
            gr$get_active_level (msg = &msg,
                                 sizbuf = &size,
                                 buffer = &me->ActiveLevel,
                                 nret = &size);

            size = sizeof (me->ModuleInfo);
            gr$get_module_env (msg = &msg,
                               sizbuf = &size,
                               buffer = &me->ModuleInfo,
                               nret = &size);

            cs_args.desc = me->csdesc;
            cs_args.flag = CS_MAKE_ACTIVE | CS_CONNECT_TO_MGR;

            gr$get_cs_type(buffer = type_string);

            if (!strcmp(type_string, Rectangular))
              cs_args.type = RECTANGULAR;
            else if (!strcmp(type_string, Spherical))
              cs_args.type = SPHERICAL;
            else if (!strcmp(type_string, Cylindrical))
              cs_args.type = CYLINDRICAL;
            else
              cs_args.type = RECTANGULAR;

            cnst_lis.msg = &msg;
            cnst_lis.newflag = FALSE;
            cnst_lis.name = me->csname;
            cnst_lis.class_attr = (IGRchar *) &cs_args;
            cnst_lis.level = me->ActiveLevel;
            cnst_lis.display = &me->ActiveDisplay;
            cnst_lis.env_info = &me->ModuleInfo;
            cnst_lis.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
            cnst_lis.geometry = (IGRchar *)&lbs_geom;

            /*
             *  construct the new coordinate system
             */

            sts = om$construct (classname = "GRgencs",
                                msg = message GRgraphics.GRconstruct
                                         (&cnst_lis),
                                osnum = me->ModuleInfo.md_id.osnum,
                                p_objid = &CSobj.objid);
            if (sts & msg & 1)
            {
                ex$message (msgnumb = GR_I_CorSysDfn);

                /*
                 *  update the current point form
                 */

                co$update_current_point_form (msg = &msg);
            }
            else
            {
                ex$message (msgnumb = GR_E_CantDfnCor);
            }
            me->mx_defined = FALSE;
            me->state = INITIAL_STATE;
        }
    }

finish:

    return (OM_S_SUCCESS);
}

end implementation COcsdefine;
