/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COcpparal

Description
        This command offsets a copy of an element by a user-defined
        distance and direction.

History
        mrm     09/12/88    creation
                10/17/89    check for rejected message
                11/07/89    remove references to COcppsel, now able to use the
                            default select handler by passing GRIO_DISTANCE
                            to locate through COB
*/

class               COcpparal
super_class         CEO_LOCATE
command_object      GRMCpEPr, COch_cp_parallel, GRCpPr
product_name        "$PLATFORM"
start_state         locate_object


specification

#include "comndef.h"
#include "comn.h"

instance
{
    struct GRlc_info original;  /* located object */
    struct GRevent cpevents[3]; /* input events */
    struct GRlc_dynamics lcdyn; /* locate dynamics info */
    struct COcppdy cppinfo;     /* info to pass to dynamics */
}


implementation

#include "coimport.h"
#include "dpmacros.h"
#include "lcmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grgsmacros.h"
#include "comn.h"

extern IGRint COcpplcdyn();             /* dynamics function */

from GRgraphics import GRdelete;
from GRvg       import GRchgprops;

state_table

#include "cochindex.h"
#include "comndef.h"
#include "grmessage.h"
#include "ASmsg.h"
#include "OMerrordef.h"

state *
    on EX_RESTART
        do erase_hilite_plane ()
        state locate_object

state locate_object
    message_key GRC_M_CpEPr
    prompt_key GR_P_IdEle
    accept_key  GR_P_AccPtDis /* 12/01/92 SRH */
    relocate_key GR_E_EleNotFnd
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    accept_mask "GRm_DATA | GRm_VALUE | GRm_RESTART"
/*
    locate_eligible "+GRcurve"
 */
    locate_eligible "+GRbspline, GRcompcurve, GAcurve"
    locate_display "MANIP_LC_DISFLAG"
    locate_properties "COPY_LC_PROPS"
    locate_owner "COPY_LC_OWNER"
    value_accept GRIO_DISTANCE
    disconnect_located 1
    execute setup_locate ()
    filter locate_noauto
        on EX_DATA or EX_DATA.GRst_REGULAR 
            do store_original ()
            do store_event (1, 0)   /* located element */
            do store_event (1, 1)   /* distance to offset */
            do store_event (1, 2)   /* direction and offset plane */
            do erase_hilite_plane ()
            do use_events ()        /* offset & connect to located channel */
                on SUCCESS
                    do display_mode GRbdhd
                    do display_located (sts)
                    state get_distance
                on RETURN_CODE = OM_W_REJECTED_METHOD
                    do status_key GR_E_InvEleType
                    state locate_object
                on WARNING or ERROR or SEVERE
                    do status_key GR_E_ErrEncCmdRst
                    state locate_object
            state get_direction
        on DISTANCE 
            do store_original ()
            do store_event (1, 0)   /* located element */
            do store_event (1, 1)   /* distance to offset */
            state get_direction

state get_distance
    prompt_key AS_P_KyInDsOrEnDstPt  /* "Keyin distance/Enter destination point" */

dynamics 1
    filter get_event
        on DISTANCE
            do store_event (1, 1)   /* distance to offset */
            state get_direction
        on EX_DATA
            do store_event (1, 1)   /* distance to offset */
            do store_event (1, 2)   /* direction and offset plane */
            do erase_hilite_plane ()
            do use_events ()        /* offset & connect to located channel */
                on SUCCESS
                    do display_mode GRbdhd
                    do display_located (sts)
                    state .
                on RETURN_CODE = OM_W_REJECTED_METHOD
                    do status_key GR_E_InvEleType
                    state locate_object
                on WARNING or ERROR or SEVERE
                    do status_key GR_E_ErrEncCmdRst
                    state locate_object
            state get_direction
        on EX_BACK_UP
            do erase_hilite_plane ()
            do disconnect_located 1
            do restore_original ()
            do display_mode GRhd
            do display_located (sts)
            state .
        on EX_RESTART or EX_RJT_MOVEON
            do erase_hilite_plane ()
            state locate_object

state get_direction
    prompt_key AS_P_DfDrOrKyInDis  /* "Define direction or keyin distance" */
    dynamics 1
    filter get_event
        on DISTANCE
            do store_event (1, 1)   /* distance to offset */
            state .
        on EX_DATA
            do store_event (1, 2)   /* direction and offset plane */
            do erase_hilite_plane ()
            do use_events ()        /* offset & connect to located channel */
                on SUCCESS
                    do display_mode GRbdhd
                    do display_located (sts)
                    state .
                on RETURN_CODE = OM_W_REJECTED_METHOD
                    do status_key GR_E_InvEleType
                    state locate_object
                on WARNING or ERROR or SEVERE
                    do status_key GR_E_ErrEncCmdRst
                    state locate_object
            state .
        on EX_BACK_UP
            do erase_hilite_plane ()
            do disconnect_located 1
            do restore_original ()
            do display_mode GRhd
            do display_located (sts)
            state .
        on EX_RESTART or EX_RJT_MOVEON
            do erase_hilite_plane ()
            state locate_object


/*
Action
        store_event (int f, t)

Description
        This action store user input into instance data.  The
        argument "f" signals which CEO event to store; "t" specifies
        which instance event in which to store the data.

Notes
        The from argument "f" should be 1, 2 or 3; the to argument "t" can
        range from 0 to 2.
*/

action store_event (int f, t)
{
    struct GRevent *e;

    if (f > 0 && f < 4 && t >= 0 && t < 3)
    {
        me->ret = MSSUCC;
        if (f == 1)
            e = &me->event1;
        else if (f == 2)
            e = &me->event2;
        else
            e = &me->event3;
        me->cpevents[t] = *e;
    }
    else
    {
        me->ret = MSFAIL;
    }
}

/*
Action
        use_events

Description
        This action invokes a function to offset the located object.
*/

action use_events ()
{
    IGRboolean apparent;
    IGRint i;
    IGRlong rc, msg1;
    struct GRid fence_id, window_id;
    GRobjid new_object;
    struct GRmd_env const_mod;
    struct GRevent *events[3];
    IGRshort property = 0;
    IGRshort clear = 0;

    me->ret = MSSUCC;

    /*
     *  initialize arguments
     */

    events[0] = &me->cpevents[0];
    events[1] = &me->cpevents[1];
    events[2] = &me->cpevents[2];

    i = sizeof (struct GRmd_env);
    gr$get_construct_env (msg = &me->ret,
                          point = &events[2]->event.button,
                          sizbuf = &i,
                          buffer = &const_mod,
                          nret = &i);

    i = sizeof (IGRboolean);
    gr$get_apparent_flag (msg = &me->ret,
                          sizbuf = &i,
                          buffer = &apparent,
                          nret = &i);

    /*
     *  call a function to produce a new object
     */

    COch_cp_parallel (&me->ret, my_id, OM_Gw_current_OS,
                      &me->ModuleInfo, events, apparent, &new_object);

    if (!(me->ret & 1))
    {
#ifdef DEBUG
        printf ("COcpparal.use_events: COch_cp_parallel failed\n");
#endif
        goto finish;
    }

    property = GRIS_ASSOCIATIVE | GRHAS_EXTERNAL_CONSTRAINT;

    rc = om$send (msg = message GRvg.GRchgprops
                       (&msg1, &clear, &property),
                  targetid = new_object,
                  targetos = me->ModuleInfo.md_id.osnum);


   /*
    *  if the original object happens to be a fence, make the new object
    *  the active fence.
    */

    rc = gr$gsget_fence( msg = &msg1,
			 fence_id = &fence_id );

   if( rc & msg1 & 1 )
   {
     if( fence_id.objid == events[0]->located_object[0].located_obj.objid )
     {
	window_id.objid = events[2]->event.button.objid;
	window_id.osnum = events[2]->event.button.osnum;

	fence_id.objid = new_object;
        fence_id.osnum = const_mod.md_id.osnum;

	rc = gr$gsput_fence ( 	msg = &msg1,
				mod_env = &const_mod,
				fence_id = &fence_id,
				window_id = &window_id );

     }
   }

    /*
     *  knock the original object off the channel and connect to the new one
     */

    lc$wild_disconnect (objid = my_id,
                        osnum = OM_Gw_current_OS,
                        p_chanselect = &me->located_chansel);

    lc$connect (objid = my_id,
                osnum = OM_Gw_current_OS,
                go_objid = new_object,
                go_osnum = const_mod.md_id.osnum,
                p_chanselect = &me->located_chansel);

    /*
     *  save the new object's module information
     */

    events[0]->located_object[0].located_obj.objid = new_object;
    events[0]->located_object[0].located_obj.osnum = const_mod.md_id.osnum;
    events[0]->located_object[0].module_info = const_mod;

    /*
     *  stuff the new object's info in me->event1 so the display_located
     *  action will work
     */

    me->event1.located_object[0].module_info = const_mod;

    /* fix for TR# 11902589 -  
     * stuff the new objects info into locate_ModuleInfo so that
     * display_located will work even for reference file objects 
     */
 
    me->locate_ModuleInfo = const_mod;


finish:

#ifdef DEBUG
    if (!(me->ret & 1)) printf ("COcpparal.use_events: me->ret = %x\n", me->ret);
#endif
}

/*
Action
        store_original

Description
        This action stores the information about a located object.
*/

action store_original ()
{
    me->original = me->event1.located_object[0];
}

/*
Action
        restore_original

Description
        This action restores the information about a located object.
*/

action restore_original ()
{
    /*
     *  stuff the original's info into the located object event and reconnect
     */

    me->cpevents[0].located_object[0] = me->original;

    lc$connect (go_objid = me->original.located_obj.objid,
                go_osnum = me->original.located_obj.osnum,
                p_chanselect = &me->located_chansel);
}

/*
Action
        dynamics

Description
        This action is overridden to provide the appropriate dynamics.
*/

action dynamics /* (int dynamics; int *sts) */
{
    IGRboolean          dyn_on;         /* is dynamics on? */
    IGRboolean          inquire = 1;    /* inquire from DPdynflags */
    IGRint              COcppdyn();     /* dynamics function */
    IGRint              i;              /* variable */

    DPdynflags (&me->ret, &inquire, &dyn_on, NULL);
    if (!dyn_on) goto quit;

    me->cppinfo.events[0] = &me->cpevents[0];
    me->cppinfo.events[1] = &me->cpevents[1];
    me->cppinfo.events[2] = &me->cpevents[2];
    me->cppinfo.new_object.objid = NULL_OBJID;
    i = sizeof (IGRboolean);
    gr$get_apparent_flag (msg = &me->ret,
                          sizbuf = &i,
                          buffer = &me->cppinfo.apparent,
                          nret = &i);

    dp$dynamics (dyn_fun = COcppdyn, information = &me->cppinfo);

    if (me->cppinfo.new_object.objid != NULL_OBJID)
    {
        om$send (msg = message GRgraphics.GRdelete
                      (me->cppinfo.msg, &me->cppinfo.const_mod),
                 targetid = me->cppinfo.new_object.objid,
                 targetos = me->cppinfo.const_mod.md_id.osnum);
    }
}

/*
Action
        erase_hilite_plane

Description
        This action erases the highlight plane.

Note
        This action may be removed when COB adds a keyword to erase the
        highlight plane.
*/

action erase_hilite_plane ()
{
    status = dp$erase_hilite (msg = &me->ret,
                              objid = me->ModuleInfo.md_id.objid,
                              osnum = me->ModuleInfo.md_id.osnum);
}

/*
Action
        setup_locate

Description
        This action sets up the dynamics function to be called by the locate
        filter during the accep/reject cycle.  It also sets up the select
        handler which will call co$getevent with value_type set to DISTANCE.
        The special select handler call may be deleted when both lc$locate
        and COB allow the value type to be set in a simpler manner.
*/

action setup_locate ()
{
    me->cppinfo.msg = &me->ret;
    me->cppinfo.caller_id = my_id;
    me->cppinfo.caller_os = OM_Gw_current_OS;
    me->cppinfo.const_mod = me->ModuleInfo;
    me->cppinfo.const_mod.md_id.objid = NULL_OBJID;
    me->cppinfo.new_object.objid = NULL_OBJID;
    me->cppinfo.new_object.osnum = me->ModuleInfo.md_id.osnum;
    me->lcdyn.GRlc_dyn = COcpplcdyn;
    me->lcdyn.add_info = (IGRchar *)&me->cppinfo;
    me->dyn = &me->lcdyn;
}
