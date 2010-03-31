/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

/*
  history : gupta - creation November 06, 1989
                    being used for mass properties
                    computes the density of the solid based on density
                    assignments made to the previous solids
*/

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSssprops.h"

#define SURF_BUF	20

from EMSmassprop import EMget_density,
                        EMget_objectid;
from GRowner import GRget_number_components,
                    GRget_components;
from EMSsubbs import EMset_inactive;

method EMcompute_density (IGRlong         *EMmsg;
                          struct GRmd_env *my_env;
                          IGRdouble       *density)
{
 IGRlong            stat_OM, msg;
 IGRboolean         comp_activated, set_inactive;
 IGRshort           surf_props;
 IGRint	            num_surfs, surfs_returned, i;
 IGRdouble          last_density, current_density;
 struct GRid        *surfs, static_buf[SURF_BUF], owner_GRid;
 struct GRid        mass_prop_obj;
 OM_S_CHANSELECT    to_owners, notify_chan;

 /*--------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 surfs = NULL;
 num_surfs = 0;
 last_density = 1.0;
 *density = 1.0;
 comp_activated = FALSE;

 stat_OM = om$send(msg = message GRowner.GRget_number_components (&msg,
                         &num_surfs), 
                   targetid = my_id);
 if (! num_surfs) return (OM_S_SUCCESS); /* single surface */
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 if(num_surfs > SURF_BUF)
  surfs = (struct GRid *) om$malloc(size = num_surfs*sizeof(struct GRid));
 else 
  surfs = static_buf;
 EMerr_hndlr(! surfs, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 stat_OM = om$send(msg = message GRowner.GRget_components (&msg, my_env,
                         surfs, num_surfs, &surfs_returned, 0, MAXINT),
                   targetid = my_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
 EMerr_hndlr(surfs_returned != num_surfs, *EMmsg, EMS_E_Fail, wrapup);
 
 stat_OM = EMmake_chanselect (GRconnector_to_owners, &to_owners);
 stat_OM = EMmake_chanselect (GRnotify_notification, &notify_chan);
 EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 for(i=0; i<num_surfs; i++)
  {
   surf_props = NULL;
   stat_OM = om$send(msg = message GRgraphics.GRgetprops(&msg,
                           &surf_props), 
                     targetid = surfs[i].objid,
                     targetos = surfs[i].osnum);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

   if ( !(surf_props & GRIS_LOCATABLE) &&
        !(surf_props & GRIS_DISPLAYABLE) &&
        !(surf_props & EMSIS_INACTIVE))
   {
    om$send(msg = message EMSsubbs.EMset_inactive(&msg, &set_inactive),
            targetid = surfs[i].objid,
            targetos = surfs[i].osnum);
   }

   if (! (surf_props & EMSIS_INACTIVE))
    {
     owner_GRid.objid = NULL_OBJID;
     stat_OM = om$get_objid_at_index (objid = surfs[i].objid, 
                                      osnum = surfs[i].osnum, 
                                      index = 0, 
                                      objidaddr = &owner_GRid.objid, 
                                      osnumaddr = &owner_GRid.osnum, 
                                      p_chanselect = &to_owners);

     if ((1 & stat_OM) && (owner_GRid.objid != NULL_OBJID))
      {
/* fix for not able to assign density to a solid of revolution  */
       mass_prop_obj.objid = NULL_OBJID;
       stat_OM = om$send (msg = message EMSmassprop.EMget_objectid (&msg,
                                &mass_prop_obj),
                          p_chanselect = &notify_chan,
                          from = 0,
                          to = 100000);

 /* the following  check is for the 
     fix for not able to assign density to a solid of revolution */

 if (! (1 & stat_OM & msg) || (mass_prop_obj.objid == NULL_OBJID ))
  {
       stat_OM = om$send (msg = message EMSmassprop.EMget_objectid (&msg,
                                &mass_prop_obj),
                          senderid = owner_GRid.objid,
                          p_chanselect = &notify_chan,
                          from = 0,
                          to =  100000);
       if (! (1 & stat_OM & msg))
        {
         stat_OM = OM_S_SUCCESS;
         msg = EMS_S_Success;
        }
  }

       if (mass_prop_obj.objid != NULL_OBJID)
        {
         stat_OM = om$send (msg = message EMSmassprop.EMget_density (&msg,
                                  &current_density),
                            targetid = mass_prop_obj.objid);
         if (! (1 & stat_OM & msg)) goto wrapup;

         if ((current_density != last_density) && (comp_activated))
          {
           *density = 1.0;
           goto wrapup;
          }
         else
          {
           *density = current_density;
           last_density = current_density;
           comp_activated = TRUE;
          }
        }
      }
    }
  }

 wrapup:
 if (surfs && (surfs != static_buf)) om$dealloc(ptr = surfs);

 EMWRAPUP(*EMmsg, stat_OM, "In EMSsurface.EMcompute_density");
 return (stat_OM);
}

end implementation EMSsurface;
