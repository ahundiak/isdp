class implementation COcpparal;



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


#define _locate_object 0
#define _get_distance 1
#define _get_direction 2

method store_event (int f, t)
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method use_events ()
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method store_original ()
{
  int		  status = OM_S_SUCCESS;

    me->original = me->event1.located_object[0];
quit:
  return OM_S_SUCCESS;
}

method restore_original ()
{
  int		  status = OM_S_SUCCESS;

    /*
     *  stuff the original's info into the located object event and reconnect
     */

    me->cpevents[0].located_object[0] = me->original;

    lc$connect (go_objid = me->original.located_obj.objid,
                go_osnum = me->original.located_obj.osnum,
                p_chanselect = &me->located_chansel);
quit:
  return OM_S_SUCCESS;
}

method dynamics ( int dynamics ; int * sts )
{
  int		  status = OM_S_SUCCESS;

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

method setup_locate ()
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

end implementation COcpparal;
