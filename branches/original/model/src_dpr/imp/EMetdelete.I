/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedittree;

#include "EMS.h"
#include "msdef.h" /* MS message codes */
#include "emsdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "dpmacros.h"
#include "EMSdpr.h"

extern OMuword OPP_EMScomposite_class_id;

from EMSsurface import EMreplace;

method GRdelete(IGRlong *EMmsg; struct GRmd_env *env)
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            display_count=0, sf_count, ii, jj;
  GRobjid           active_id;
  GRobjid           *display_ids=NULL;
  enum GRdpmode     display_mode;
  struct GRid       *sf_list=NULL;
  IGRushort options;

  *EMmsg = MSSUCC;

  options = EMreplace_DO_DISPLAY | EMreplace_DONT_REDRAW;
  OM_stat = om$send(msg = message EMSsurface.EMreplace(EMmsg, NULL_OBJID,
                          env, options, &display_ids, &display_count,
                          &active_id), 
                    targetid = ME.EMSedittree->node_id,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  if (*EMmsg == EMS_I_CantRecompute)
  {
    IGRlong locmsg;
    dp$erase_hilite(msg = &locmsg);
    goto wrapup;
  }

  /*Display any surfaces that weren't during the replace.*/
  if (EFisAncestryValid(EMmsg, 
                        ME.EMSedittree->node_id, 
                        ME.EMSedittree->node_os,
                        OPP_EMScomposite_class_id, FALSE))
  {
    EFgetcomponents(EMmsg, my_id, 
                    ME.EMSedittree->node_id, 
                    ME.EMSedittree->node_os,
                    &sf_count, &sf_list);
    if (!(1 & *EMmsg)) goto wrapup;

    display_mode = GRbe;
    for(ii=0; ii<sf_count; ii++)
    {
      for(jj=0; jj<display_count; jj++)
      {
        if (sf_list[ii].objid == display_ids[jj]) break;
      }
      if (jj == display_count)
      {
        /*This one hasn't been erased so do so now*/
        OM_stat = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                                &env->md_env.matrix_type,
                                env->md_env.matrix,
                                &display_mode, &env->md_id),
                          targetid = sf_list[ii].objid,
                          targetos = ME.EMSedittree->node_os);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }
    }                          
  }                        
  
  OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                    targetid = ME.EMSedittree->node_id,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    
  
  /*Redraw affected sfs*/
  display_mode = GRbd;
  for (ii=0; ii<display_count; ii++)
  {
    if (om$is_objid_valid(objid = display_ids[ii],
                          osnum = ME.EMSedittree->node_os) == OM_S_SUCCESS)
    {
      OM_stat = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
                              &env->md_env.matrix_type,
                              env->md_env.matrix, &display_mode,
                              &env->md_id),
                        targetid = display_ids[ii],
                        targetos = ME.EMSedittree->node_os);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

  wrapup:
    if (display_ids) om$dealloc(ptr = display_ids);
    if (sf_list) om$dealloc(ptr = sf_list);

    EMWRAPUP (*EMmsg, OM_stat, "EMSedittree.GRdelete");
    return(OM_stat);
}
end implementation EMSedittree;
