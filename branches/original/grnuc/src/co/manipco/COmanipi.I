class implementation COmanip;



#include "msdef.h"
#include "lc.h"
#include "dpmacros.h"
#include "comndef.h"
#include "comn.h"
#include "comnindex.h"
#include "comnmacros.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "grmessage.h"

extern IGRint (*CO_GA_manip[])();      /* function pointer array */


/*
Action
        store_event (int f, t)

Description
        This action store user input into COmanip instance data.  The
        argument "f" signals which CEO event to store; "t" specifies
        which COmanip event in which to store the data.

Notes
        The from argument "f" should be 1, 2 or 3; the to argument "t" can
        range from 0 to the max number of COmanip args.
*/



method store_event (int f, t)
{
  int		  status = OM_S_SUCCESS;

    struct GRevent *e;

    if (f > 0 && f < 4 && t >= 0 && t < MNEVENTS)
    {
        me->ret = MSSUCC;
        if (f == 1)
            e = &me->event1;
        else if (f == 2)
            e = &me->event2;
        else
            e = &me->event3;
        me->mnevents[t] = *e;
    }
    else
    {
        me->ret = MSFAIL;
    }
quit:
  return OM_S_SUCCESS;
}

method get_matrix ()
{
  int		  status = OM_S_SUCCESS;

    struct GRevent *events[6];

    me->ret = MSSUCC;

    events[0] = &me->mnevents[0];
    events[1] = &me->mnevents[1];
    events[2] = &me->mnevents[2];
    events[3] = &me->mnevents[3];
    events[4] = &me->mnevents[4];
    events[5] = &me->mnevents[5];

    status = CO_GA_manip[me->mytype] (&me->ret, my_id, OM_Gw_current_OS,
                                      events, me->tmatrix);

#ifdef DEBUG
    if (!(status & me->ret & 1)) printf ("COmanip.get_matrix: noninteractive function failed\n");
    if (!(me->ret & 1)) printf ("COmanip.get_matrix: me->ret = %x\n", me->ret);
    if (!(status & 1)) om$report_error (sts = status);
#endif
quit:
  return OM_S_SUCCESS;
}

method transform ()
{
  int		  status = OM_S_SUCCESS;

    status = co$tform (msg = &me->ret,
                       module = &me->ModuleInfo,
                       matrix = me->tmatrix,
                       gschan = &me->located_chansel);
#ifdef DEBUG
    if (!(status & me->ret & 1)) printf ("COmanip.transform: co$tform failed\n");
    if (!(me->ret & 1)) printf ("COmanip.transform: me->ret = %x\n", me->ret);
    if (!(status & 1)) om$report_error (sts = status);
#endif
quit:
  return OM_S_SUCCESS;
}

method transform_copy ()
{
  int		  status = OM_S_SUCCESS;

    status = co$cptform (msg = &me->ret,
                         module = &me->ModuleInfo,
                         matrix = me->tmatrix,
                         gschan = &me->located_chansel);
#ifdef DEBUG
    if (!(status & me->ret & 1)) printf ("COmanip.transform_copy: co$cptform failed\n");
    if (!(me->ret & 1)) printf ("COmanip.transform_copy: me->ret = %x\n", me->ret);
    if (!(status & 1)) om$report_error (sts = status);
#endif
quit:
  return OM_S_SUCCESS;
}

method copy_events (int f, t)
{
  int		  status = OM_S_SUCCESS;

    if (f < MNEVENTS && t < MNEVENTS)
    {
        me->ret = MSSUCC;
        me->mnevents[t] = me->mnevents[f];
    }
    else
    {
        me->ret = MSFAIL;
    }
quit:
  return OM_S_SUCCESS;
}

method store_value (int i; double x)
{
  int		  status = OM_S_SUCCESS;

    if (i < MNEVENTS)
    {
        me->ret = MSSUCC;
        me->mnevents[i].event.value = x;
    }
    else
    {
        me->ret = MSFAIL;
    }
quit:
  return OM_S_SUCCESS;
}

method check_planarity (int a, b, c)
{
  int		  status = OM_S_SUCCESS;

    extern IGRboolean   MAdetplane ();
    IGRlong             i;
    IGRdouble           tol = 0.3, pts[9];
    IGRpoint            plpt;
    IGRvector           plvec;
    struct IGRplane     plane;    

    pts[0] = me->mnevents[a].event.button.x;
    pts[1] = me->mnevents[a].event.button.y;
    pts[2] = me->mnevents[a].event.button.z;
    pts[3] = me->mnevents[b].event.button.x;
    pts[4] = me->mnevents[b].event.button.y;
    pts[5] = me->mnevents[b].event.button.z;
    pts[6] = me->mnevents[c].event.button.x;
    pts[7] = me->mnevents[c].event.button.y;
    pts[8] = me->mnevents[c].event.button.z;

    i = 3;
    plane.point = plpt;
    plane.normal = plvec;

    if (MAdetplane (&me->ret, pts, &i, &tol, &plane))
    {
        me->ret = MSSUCC;
    }
    else
    {
        me->ret = MSFAIL;
    }
quit:
  return OM_S_SUCCESS;
}

method setup_lcdyn (int cmd)
{
  int		  status = OM_S_SUCCESS;

    extern IGRint DYmirror();

    switch (cmd)
    {
        case COmn_mirrorv:
        case COmn_mirrorh:
            me->ret = MSSUCC;
            if (cmd == COmn_mirrorv || cmd == COmn_cp_mirrorv)
                me->dynargs.flags = 1 | 16;
            else
                me->dynargs.flags = 1;
            me->dynargs.caller.objid = my_id;
            me->dynargs.caller.osnum = OM_Gw_current_OS;
            me->dynargs.curr_mod = &me->ModuleInfo;
            me->dynargs.gschan = &me->located_chansel;
            me->dynargs.event = NULL;
            me->lcdyn.GRlc_dyn = DYmirror;
            me->lcdyn.add_info = (IGRchar *)&me->dynargs;
            me->dyn = &me->lcdyn;

        default:
            me->ret = MSFAIL;
            break;
    }
quit:
  return OM_S_SUCCESS;
}

method erase_hilite_plane ()
{
  int		  status = OM_S_SUCCESS;

    status = dp$erase_hilite (msg = &me->ret,
                              objid = me->ModuleInfo.md_id.objid,
                              osnum = me->ModuleInfo.md_id.osnum);
quit:
  return OM_S_SUCCESS;
}

method dynamics ( int dynamics ; int * sts )
{
  int		  status = OM_S_SUCCESS;

    switch (dynamics)
    {
        case COmn_move:
            co$dymove (msg = &me->ret,
                       from_point = &me->mnevents[0].event.button,
                       module = &me->ModuleInfo,
                       gschan = &me->located_chansel);
            break;

        case COmn_mirrorh:
        case COmn_mirrorv:
            me->dynargs.flags = (dynamics == COmn_mirrorv) ? 16 : 0;
            co$dymirror (mirr_object = &me->mnevents[0].located_object[0].located_obj,
                         event = &me->mnevents[0],
                         add_info = &me->dynargs);
            break;

        case COmn_mirrorl:
            co$dymirrorl (msg = &me->ret,
                          point1 = &me->mnevents[0].event.button,
                          module = &me->ModuleInfo,
                          gschan = &me->located_chansel);
            break;

        case COmn_rotate_3pts:
            co$dyrotate (msg = &me->ret,
                         origin = &me->mnevents[0].event.button,
                         handle = &me->mnevents[1].event.button,
                         radius = &me->mnevents[3].event.value,
                         module = &me->ModuleInfo,
                         gschan = &me->located_chansel);
            break;

#ifndef IDRAW

        case COmn_scale_3pts:
            co$dyscale (msg = &me->ret,
                        origin = &me->mnevents[0].event.button,
                        ref_pt = &me->mnevents[1].event.value,
                        module = &me->ModuleInfo,
                        gschan = &me->located_chansel);
            break;

#endif IDRAW

        default:
            om$send (mode = OM_e_wrt_message,
                     msg = message CEO_GSLOCATE.dynamics
                          (dynamics, (int *)&me->ret),
                     targetid = my_id);
    }
quit:
  return OM_S_SUCCESS;
}

method wakeup ( int pos )
{
  int		  status = OM_S_SUCCESS;

    status = om$send (mode = OM_e_wrt_message,
                      msg = message CEO.wakeup (pos),
                      targetid = my_id);

    if (pos == EX_suspend && !ex$peek_event_queue())
    {
        me->DisplayMode = GRhd;

        status = gr$gsdisplay (msg = &me->ret,
                               dpmode = me->DisplayMode,
                               p_chanselect = &me->located_chansel);
    }
quit:
  return OM_S_SUCCESS;
}

method sleep ( int pos )
{
  int		  status = OM_S_SUCCESS;

    OMuint  objects_hilited = 0;

    status = om$send (mode = OM_e_wrt_message,
                      msg = message CEO.sleep (pos),
                      targetid = my_id);

    if (pos == EX_suspend)
    {
        status = om$get_channel_count (object = me,
                                       p_chanselect = &me->located_chansel,
                                       count = &objects_hilited);

        if (objects_hilited)
        {
            status = dp$erase_hilite (msg = &me->ret,
                                      objid = me->ModuleInfo.md_id.objid,
                                      osnum = me->ModuleInfo.md_id.osnum);
        }
    }
quit:
  return OM_S_SUCCESS;
}

method show_attribute ()
{
  int		  status = OM_S_SUCCESS;

    IGRshort            num_alias = 3;  /* number of aliases */
    IGRint              size;           /* of IGRdisplay structure */
    IGRdouble           aa;             /* active angle */
    GRIOalias_name      def_units[3];   /* default units */
    struct GRdpb_scale  scale;          /* active scale */
    IGRshort            field_size;

    switch (me->mytype)
    {
        case COmn_rotate_aa:
        case COmn_cp_rotate_aa:
        case COmn_rotate_ax:
        case COmn_cp_rotate_ax:

            size = sizeof (aa);

            gr$get_active_angle (msg = &me->ret,
                                 sizbuf = &size,
                                 buffer = &aa,
                                 nret = &size);

            field_size = sizeof(GRIOalias_name) * 3;

            co$cvt_imp_to_alias (msg = &me->ret,
                                 unit_type = "UOM_ANGLE",
                                 osnum = me->ModuleInfo.md_id.osnum,
                                 working_units = &aa,
                                 num_alias = &num_alias,
                                 field_size = &field_size,
                                 cvt_list = def_units);

            ex$message (msgnumb = GR_I_ActAng,
                        type = "%s", 
                        var = `def_units`);

            break;

        case COmn_scale_as:
        case COmn_cp_scale_as:

            size = sizeof (scale);

            gr$get_active_scale (msg = &me->ret,
                                 sizbuf = &size,
                                 buffer = &scale,
                                 nret = &size);

            ex$message (msgnumb = GR_I_XsYsZs,
                        type = "%g%g%g",
                        var = `scale.Active_xscale,
                               scale.Active_yscale,
                               scale.Active_zscale`);
            break;
    }
quit:
  return OM_S_SUCCESS;
}

end implementation COmanip;
