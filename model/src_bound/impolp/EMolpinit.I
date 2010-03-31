/* ###################   APOGEE COMPILED   ################## */
/*
Notes
        This method initializes a loop. The properties bit mask should be
 sent to this method.The range box of the loop is updated.The method also
 checks whether the loop is open or closed and sets that property
 accordingly.
        This method DOES NOT set the correct loop type (P or C) of the
 loop. This should be decided by the caller and the apprpriate type passed
 in via the 'props' arguement.
        Also, making the directions of the edges consistent with the loop type
 is NOT this method's goal.

Arguments
        props           input           properties of the loop.
        partolbasis     input           parametric basis tolerance.
        make_dummy_edges input          Boolean flag indicating whether
                                        dummy edges should be constructed
                                        for each 'real' edge (except the
                                        point edge) in order that the loop
                                        appears 'closed'.
                                        For all loopset operations it is
                                        required that the open loop appear
                                        closed via such dummy edges. Also
                                        the dummy edges are necessary for
                                        detecting coincedency wherever
                                        required. Thus this flag should be
                                        TRUE unless the construction of dummy
                                        edges is done external to this
                                        method.
*/
class implementation EMSopenloop;

#include "EMS.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "bs.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emsdef.h"

from EMSedge import EMgetrange;
from EMSdumedge import EMdumedgeinit;

extern OMuword OPP_EMSptedge_class_id;

method EMolpinit(IGRlong *EMmsg;IGRushort props;
                struct EMSpartolbasis *partolbasis;
                IGRboolean make_dummy_edges)
{
  IGRlong               sts,rc,i;
  OMuint count;
  IGRboolean            EFextract_par();
  OM_S_CHANSELECT       to_edges, to_owner;
  IGRdouble             range[4],parsqtollen,begin_pt[2],end_pt[2];
  OMuword               edge_class;
  extern OM_S_OBJID     current_creator;


  ME.EMSboundary->creator_id = current_creator;

  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  
  ME.EMSloop->lp_props = props;

/* Get the proper tolerance
*/
  if(!partolbasis->is_valid)
   {
     sts = om$send(msg=message EMSboundary.EMgetsurface_info(EMmsg,NULL,
                        partolbasis),
                        targetid=my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
   }
  sts = EFextract_par(BSTOLSQLENVEC,partolbasis->tol,&parsqtollen,&rc);


   sts = om$get_channel_count(object = me,p_chanselect = &to_edges,
                                 count = &count);
   if(!(1&sts))goto wrapup;

  if(make_dummy_edges)
   {
     GRobjid dummy_edge, real_edge;
     IGRboolean rev_edge = TRUE;

    sts = EMmake_chanselect (EMSedge_to_owner, &to_owner);
    EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_OMerror, wrapup);

    for(i = count-1; i >=0; i--)
     {
       sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &real_edge), 
                        p_chanselect = &to_edges, from = i, to = i);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);

       sts = om$get_classid(objid = real_edge, p_classid = &edge_class);
       EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

       if(edge_class == OPP_EMSptedge_class_id) continue;

       sts = om$construct(classid = OPP_EMSdumedge_class_id, 
                          p_objid = &dummy_edge, 
                          msg = message EMSdumedge.EMdumedgeinit
                          (EMmsg, real_edge, rev_edge));
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_OMerror, wrapup);

       sts = om$send(msg = message Root.connect(to_owner, MAXINT, my_id, 
                                OM_Gw_current_OS, to_edges, NULL), 
                                targetid = dummy_edge);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_OMerror, wrapup);

     }
   }

/* decide my min max values */

   ME.EMSloop->range[0] = MAXFLOAT;     /* Any big number */
   ME.EMSloop->range[1] = MAXFLOAT;
   ME.EMSloop->range[2] = MINFLOAT;    /* Any small number*/
   ME.EMSloop->range[3] = MINFLOAT;
   for(i=0;i<count;i++)
    {
      sts = om$send(msg = message EMSedge.EMgetrange(EMmsg,range,NULL),
                       p_chanselect = &to_edges,from = i,to = i);
      if( !(1 & *EMmsg & sts)) goto wrapup;
      if(range[0] < ME.EMSloop->range[0]) ME.EMSloop->range[0] = range[0];
      if(range[1] < ME.EMSloop->range[1]) ME.EMSloop->range[1] = range[1];
      if(range[2] > ME.EMSloop->range[2]) ME.EMSloop->range[2] = range[2];
      if(range[3] > ME.EMSloop->range[3]) ME.EMSloop->range[3] = range[3];
    }

/* Check whether I am open or closed
*/
  sts = om$send(msg=message EMSloop.EMendpts(EMmsg,begin_pt,end_pt,NULL,NULL),
                        targetid = my_id);
  if(!(1&*EMmsg&sts)) goto wrapup;
  if(EM2ddistptpts(begin_pt,end_pt)<parsqtollen) 
        ME.EMSloop->lp_props &= ~EMLP_OPEN;
  else  ME.EMSloop->lp_props |= EMLP_OPEN;


wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSopenloop.EMlpinit")
  return(sts);
}

end implementation EMSopenloop;


