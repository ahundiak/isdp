/* ###################   APOGEE COMPILED   ################## */
class implementation EMSmassprop;

/*
  History

	Sudha	06/28/93	Modified for BSprototype ansification
*/

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include <stdio.h>
#include "OMmacros.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsmass.h"
#include "grdpbdef.h"
#include "gr.h"
#include "grdpbmacros.h"
#include "ma.h"
#include "madef.h"
#include "bserr.h"
#include "bsdistptpt.h"

#define DEBUG 0
#define AREA_PROPERTIES 0
#define MASS_PROPERTIES 1


from EMSsurface import EMmassprop ;
from EMSsurface import EMareaprop ;


method EMmprecalc(IGRlong *EMmsg)

{
         IGRlong *stat_OM, sts_OM;
         IGRdouble density, trans_vector[3] , scaling_factor = 1.,loc_mass[20];
         IGRdouble in_glo_loc[9], solid_range[9];
         IGRdouble  sld_range=0.0;
         IGRint number_of_surfs = 1;
	 OMuint chan_count = 0;
         IGRlong bsrc, msg;
         IGRboolean world = TRUE;
         struct GRmd_env mod_env;
         IGRlong size, nreturn;
         enum GRdpmode display_mode ;
         struct GRvg_construct construct_list;
         IGRint	bytes_in, bytes_out, ii;
         IGRlong option;
         struct IGRdisplay display;
         struct GRid my_GRid;

         OM_S_CHANSELECT        to_object, to_comps;
         OM_S_OBJECT_LINKAGE *chan_objects ; 

  stat_OM = &sts_OM;
  *stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

         my_GRid.objid = my_id;
         my_GRid.osnum = OM_Gw_current_OS;
         trans_vector[0] =  trans_vector[1] =  trans_vector[2] = 0.0;

             size = sizeof(struct GRmd_env);
             *stat_OM =  gr$get_module_env( msg = EMmsg,
                           sizbuf = &size,
                           buffer = &mod_env,
                           nret = &nreturn);

             *stat_OM = om$make_chanselect (channame = "EMSmassprop.to_object",
                              p_chanselect = &to_object);

             *stat_OM = om$get_channel_count (
                               objid = my_id,
                               p_chanselect = &to_object,
                               count = &chan_count);
             if (! (1 & *stat_OM)) goto wrapup;
 
              chan_objects = NULL;
  
             if (chan_count)
               {
                chan_objects = (OM_S_OBJECT_LINKAGE *) om$malloc(size = 
                             chan_count * (sizeof (OM_S_OBJECT_LINKAGE)));
                if (! chan_objects) goto wrapup;
               }

             *stat_OM = om$get_channel_objects (
                              objid = my_id,
                              p_chanselect = &to_object,
                              list = chan_objects,
                              size = chan_count,
                              count = &chan_count);
              if (! (1 & *stat_OM)) goto wrapup;

             *stat_OM = om$send(msg = message GRvg.GRgetrang(EMmsg, 
                         &mod_env.md_env.matrix_type,
                         mod_env.md_env.matrix,
		   	 &world, &solid_range[0]),
                    p_chanselect = &to_object);
	        if (EMSmsgReport (*stat_OM, "EMmpnotifylis: get range", FALSE))
                              goto wrapup;

              sld_range = BSdistptpt(&bsrc, &solid_range[0], &solid_range[3]);

              number_of_surfs = 0;
   	      *stat_OM = om$send(
                    msg = message GRowner.GRget_number_components(
                               EMmsg, &number_of_surfs),
                    p_chanselect = &to_object);


     /* initialize */
           for(ii=0;ii<20;ii++)
              loc_mass[ii] = 0.0;

  OM_BLOCK_MOVE(ME.EMSmassprop->glo_loc, in_glo_loc, 9* sizeof(IGRdouble));

     /*  re-calculate mass/ area properties */
           if(ME.EMSmassprop->operation_type == 1)
             {
             option = AREA_PROPERTIES;
             *stat_OM = om$send(msg = message EMSsurface.EMareaprop(EMmsg,
                          FALSE,
                          number_of_surfs,
                          &mod_env,
                          scaling_factor,
                          trans_vector,
                          loc_mass),
                    p_chanselect = &to_object);
              EMerr_hndlr(!(1 & *stat_OM  & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);
           }
           else
              {
              option = ME.EMSmassprop->axes_orient;
              option = MASS_PROPERTIES;

              density = ME.EMSmassprop->density;

              *stat_OM = om$send(msg = message EMSsurface.EMmassprop(EMmsg,
                          number_of_surfs,
                          sld_range,
                          &mod_env,
                          scaling_factor,
                          trans_vector,
                          &density,
                          loc_mass),
                    p_chanselect = &to_object);
              EMerr_hndlr(!(1 & *stat_OM  & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);
          }

 for(ii=0;ii<19;ii++) printf("loc mass %f\n", loc_mass[ii]);

     /* construct triad */
          construct_list.msg = &msg;
          construct_list.newflag = FALSE;
          construct_list.geometry = NULL;
          construct_list.class_attr = NULL;
          construct_list.name = NULL;

          bytes_in = sizeof (struct IGRdisplay);
          gr$get_active_display (msg = EMmsg, 
                         sizbuf = &bytes_in,
                         buffer = &display, 
                         nret = &bytes_out);
          if (!(1& *EMmsg)) goto wrapup;

          construct_list.display = &display;

          bytes_in = sizeof(construct_list.level);
          gr$get_active_level(
                 msg = EMmsg,
                 sizbuf = &bytes_in,
                 buffer = &construct_list.level,
                 nret = &bytes_out);
	  if (!(1& *EMmsg)) goto wrapup;


   /* Load the active properties.  We should load these
            * because someone may wish to drive command through the
            * CI and therefore may wish to place non-displayable
            * objects.  */
#if IGE_WORKS
            bytes_in = sizeof(construct_list.properties);
            gr$get_active_prop(
               msg = EMmsg,
               sizbuf = &bytes_in,
               buffer = &construct_list.properties,
               nret = &bytes_out);
            if (!(1& *EMmsg)) goto wrapup;
#else
            construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
#endif
            construct_list.env_info = &mod_env;

     /* erase old triad  */
          display_mode = GRbe;
          *stat_OM = om$send(msg = message EMSmassprop.EMmpdisplay(EMmsg,
                     &mod_env,
                     &display_mode),
                  targetid = my_id);
          EMerr_hndlr(!(1 & *stat_OM  & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);

      /*  old delete triad   */
          *stat_OM = om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_comps);
          EMerr_hndlr(!(1 & *stat_OM  & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);

          *stat_OM = om$send(msg = message GRgraphics.GRdelete(EMmsg,
                     &mod_env),
                    p_chanselect = &to_comps,
                    from = (option == AREA_PROPERTIES ? 4 : 7),
                    to = 0);
          EMerr_hndlr(!(1 & *stat_OM  & *EMmsg), *EMmsg, EMS_E_Fail,wrapup); 
          

       /* draw new triad */
          sld_range *= 0.2;
          MSdrawtriadn (EMmsg, option , in_glo_loc, sld_range, loc_mass,
                          &mod_env,&construct_list.display, my_GRid.objid,
                          TRUE, &construct_list,&my_GRid); 
     /* display  new triad*/
          display_mode = GRbd;
          *stat_OM = om$send(msg = message EMSmassprop.EMmpdisplay(EMmsg,
                     &mod_env,
                     &display_mode),
                  targetid = my_id);
          EMerr_hndlr(!(1 & *stat_OM  & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);


wrapup:
  EMWRAPUP (*stat_OM, *EMmsg, "In EMSmassprop.EMnotify");
  return(*stat_OM) ;
}
end implementation EMSmassprop;
