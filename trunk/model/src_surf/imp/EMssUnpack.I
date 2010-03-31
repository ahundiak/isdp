/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#define DEBUG 0

#if DEBUG
#include "stdio.h"
#endif

#include "OMmacros.h"                   /* IF_NULL_OBJID */
#include "EMSbnddef.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "emsimpdef.h"

from EMSloopset import EMunpack, EMget_loops, EMsplityourself, EMmakeFRT;
from EMSloop import EMtreemod;

extern OMuword  OPP_EMSloopset_class_id;

method EMunpack(IGRlong *EMmsg;
                struct GRvg_construct *const_list)
{
   IGRint                       sts, depth, buf_size, count, i, num_bdrys;
   struct EMSpartolbasis        partolbasis;
   IGRboolean                   world, want_messages = FALSE;
   IGRdouble                    par_tol;
   GRobjid                      loopset, *loops;
   IGRushort            *props, imp_options;
   OM_S_CHANSELECT              to_surface, to_loopset;
   struct GRmd_env              *my_env;
   struct IGRbsp_surface	*surface;

    world = TRUE;
    sts = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;
    props = NULL;
    loops = NULL;
    my_env = const_list->env_info;
    loopset = NULL_OBJID;
    surface = (struct IGRbsp_surface *) const_list->geometry;
    num_bdrys = surface->num_boundaries;


#if DEBUG
    want_messages = TRUE;
#endif

    sts = EMmake_chanselect (EMSloopset_to_surface, &to_surface);
    EMerr_hndlr(!sts,*EMmsg,EMS_E_OMerror,wrapup);
    to_loopset.type = OM_e_addr;
    to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

    sts = EFsspbtol_by_geom(EMmsg, surface, &par_tol);
    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);

    partolbasis.tol = par_tol;
    partolbasis.in_world = TRUE;
    partolbasis.is_valid = TRUE;
    partolbasis.mattyp = &my_env->md_env.matrix_type;
    partolbasis.mat = my_env->md_env.matrix;

    loopset = NULL_OBJID;

    sts = om$construct(classid=OPP_EMSloopset_class_id,
                           p_objid = &loopset);
    EMerr_hndlr(!sts,*EMmsg,EMS_E_OMerror,wrapup);

    sts = om$send(msg = message EMSloopset.EMunpack
                      (EMmsg, &partolbasis, const_list, NULL, NULL), 
                        targetid = loopset);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
    EMerr_hndlr(*EMmsg==EMS_I_NoMoreLoops, *EMmsg, EMS_I_NoMoreLoops, wrapup);

    depth = MAXINT;
    props = (IGRushort *) om$malloc(size = num_bdrys * sizeof
                                                (IGRushort));
    EMerr_hndlr(!props, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    loops = (GRobjid *) om$malloc(size = num_bdrys * sizeof(GRobjid));
    EMerr_hndlr(!loops, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    buf_size = num_bdrys;
    count = 0;
    sts = om$send(msg = message EMSloopset.EMget_loops
                                (EMmsg, EMS_OPT_ALL, &depth, &loops, 
                                 &props, &buf_size, &count), 
                                targetid = loopset);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);

    for(i=count-1;i>=0;i--)
     {
       sts = om$send(msg = message EMSloop.EMtreemod
                                (EMmsg, NULL, EXTRACT, &partolbasis), 
                                targetid = loops[i]);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
     }

    sts = om$send(msg = message Root.delete(TRUE), 
                                        targetid = loopset);
    EMerr_hndlr(!sts,*EMmsg,EMS_E_OMerror,wrapup);
    loopset = NULL_OBJID;

    
#if DEBUG
    fprintf(stderr, "\n Making Natural bdry on surface");
#endif

    sts = om$send(msg = message EMSsubbs.EMmk_nat_bdry
                                (EMmsg, &my_env->md_env, NULL), 
                           targetid = my_id);
    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);

    imp_options = EMImpBnd_CloseRegular | 
                  (want_messages ? EMImpBnd_WantStatMsg : NULL) |
                   EMImpBnd_SplitTopology;

    sts = om$send(msg = message EMSloopset.EMsplityourself
                                (EMmsg, loops, count, NULL, NULL, NULL, 
                                 NULL, NULL,
                                 imp_options, 
                                 NULL, NULL, &partolbasis, my_env), 
                                 p_chanselect = &to_loopset);
    if(!(1&*EMmsg&sts))
     {
	sts = om$send(msg = message Root.delete(TRUE), 
			p_chanselect = &to_loopset);
	*EMmsg = EMS_E_LoopsetError;
	goto wrapup;
     }

/*************************************************
#if DEBUG
    fprintf(stderr, "\nMaking FRTs");
#endif

    sts = om$send(msg = message EMSloopset.EMmakeFRT
                                (EMmsg, my_id), p_chanselect = &to_loopset);
    if(!(1&*EMmsg&sts))
     {
	sts = om$send(msg = message Root.delete(TRUE), 
			p_chanselect = &to_loopset);
	*EMmsg = EMS_E_LoopsetError;
     }
***************************************************/

    
wrapup:
    if(loops) om$dealloc(ptr = loops);
    if(props) om$dealloc(ptr = props);
    if(!IF_NULL_OBJID(loopset))
        sts = om$send(msg = message Root.delete(TRUE), 
                                        targetid = loopset);

    EMWRAPUP(*EMmsg, sts, "In EMSsubbs.EMunpack");
    return(sts);

}
end implementation EMSsubbs;
