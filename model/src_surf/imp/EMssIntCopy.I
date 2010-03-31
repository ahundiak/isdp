/* ###################   APOGEE COMPILED   ################## */
/* -----

     CHANGE HISTORY:
        
                RC : 03/04/86   Creation date
                AIC: 15-Jul-87  Notify associations.
		RC : 10/29/87   Modified for version 1.1.0
		SS : 07/27/88   Passing in the - old multiplied by new -
				module-environment to EMintcopy method
				at EMSboundary.
		SM : 06-Jul-89	Added bdry_options and sf_options arguments
                pp : 05/05/91   Modified the code to support associative copy
              Jack : 08/30/92   Moved copy of helper objects further down in
                                the method, especially so it is done after the
                                loopset is copied over.
				
----*/

class implementation EMSsubbs;

# include "ma.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "gocmacros.h"
# include "emsdef.h"
# include "ndmacros.h" /* For nd$get_clone */

# define HSURF_BUNDLES 1

#if HSURF_BUNDLES
#include "hssymbmacros.h"
#include "hsurf.h"
#endif

from EMSboundary  import   EMintcopy;
from GRlistener   import   GRnotifylis;
from EMShelper    import   EMhelperCopy;
from EMSloopset   import   EMget_props;

/* 2.0.1 */
from EMAsurface   import   EMcopy_recomp_info;
from NDnode import         NDmove_to_root;

extern OMuword OPP_EMSassoc_class_id;

method EMintcopy(
        IGRlong         *EMmsg; 
        struct GRmd_env *obj_mdenv;
        struct GRmd_env *new_mdenv; 
        GRobjid         *newobjid;
        struct EMcp_info *copy_info;
	IGRushort       bdry_options,  sf_options)
{
    IGRboolean        is_associative_class;
    IGRlong           OM_stat, mthd_stat;
    IGRuint   count;
    GRobjid           loopset_id;
    IGRboolean        sf_copy_exists;
    OM_S_CHANSELECT   surface_chan, loopset_chan;
    extern IGRint EMmake_chanselect();
    extern void EMcpsearch ();

    *EMmsg = EMS_S_Success;
    OM_stat = OM_S_SUCCESS;

    /*
     * find out if I have been already copied or not.
     * If so, return my counter part's objid and I am all done
     */
        
    EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0, 
                &sf_copy_exists);
    EMerr_hndlr(EMis_error(mthd_stat), *EMmsg, mthd_stat, wrapup);
  

    if (sf_copy_exists) goto wrapup;

    /* copy  myself */

    if (EFisAncestryValid(&mthd_stat, my_id, OM_Gw_current_OS,
                        OPP_EMSassoc_class_id, FALSE))
    is_associative_class = TRUE;
    else
     is_associative_class = FALSE;
/*
 * If I am of associative class then check to see if I have a clone in
 * list maintained by the graph manager.
 */
    if (is_associative_class && (sf_options & EMS_COPY_ASSOCIATIVE))
    {
      struct GRid my_grid,my_clone;

      my_grid.objid = my_id;
      my_grid.osnum = OM_Gw_current_OS;
      my_clone.objid = NULL_OBJID;
/*
      nd$get_clone(nb_obj = 1, p_original = &my_grid, p_clone = &my_clone);
*/

      if(!(IF_NULL_OBJID(my_clone.objid)))
      {
       *newobjid = my_clone.objid;

       EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 3, 
                   &sf_copy_exists);
       EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);
       goto wrapup;
      }
    }
        
    OM_stat = om$send(mode = OM_e_wrt_message,
                      msg = message GRgraphics.GRcopy (&mthd_stat,
                           obj_mdenv, new_mdenv, newobjid),
                      senderid = my_id, targetid = my_id);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, mthd_stat, wrapup);

    /*
     * put my_id and my counter part's id in the copy_info
     */

    EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 3, 
	         &sf_copy_exists);
    EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);


    /*
     * this is where the copy of the graphics data objects used to take place
     */


     OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &surface_chan);
     EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

     OM_stat = om$get_channel_count(object = me,
                      p_chanselect = &surface_chan, count = &count);
     EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

     if (count )
     {
         IGRboolean copymcp;
         struct GRmd_env mdenvs[2];

         if (obj_mdenv->md_id.osnum == new_mdenv->md_id.osnum)
           {
           /*
            * The object space in which the copy is to be placed is the
            * same as this object's object-space. Therefore, it is possible
            * to copy any model-space geometry associated with the loopset.
            * (This is currently a restriction that must be satisfied).
            * The old and the new module environments are put into an
            * array as elements 0 and 1, respectively.
            */

           OM_BLOCK_MOVE (obj_mdenv, &mdenvs[0], sizeof (struct GRmd_env));
           OM_BLOCK_MOVE (new_mdenv, &mdenvs[1], sizeof (struct GRmd_env));
           copymcp = TRUE;
           }
         else
           copymcp = FALSE;

         OM_stat = om$send(msg = message EMSboundary.EMintcopy (
                           &mthd_stat, mdenvs,
                           obj_mdenv->md_id.osnum, new_mdenv->md_id.osnum,
                           copymcp ? bdry_options
				   : bdry_options | EMS_COPY_NOMSC, 
			   &loopset_id, copy_info), 
                           p_chanselect = &surface_chan);

         EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_LoopsetError, 
          wrapup);

         OM_stat = EMmake_chanselect (EMSloopset_to_surface, &loopset_chan);
         EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

         OM_stat = om$send(msg = message Root.connect (surface_chan, 0,
                           loopset_id, new_mdenv->md_id.osnum, 
                           loopset_chan, 0),
                 targetid = *newobjid, targetos = new_mdenv->md_id.osnum);

          EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

     } /* if (count ) */




/*
 * If the copy has been initiated by my roots then I need to inform the
 * associative graph manager about my clone object so that connections
 * can take place across my father child channel.
 * pp 05/05/91
 */
     if ((sf_options & EMS_COPY_ASSOCIATIVE) && is_associative_class)
     {
       struct GRid original,clone;
       IGRushort nb_object;

       nb_object = 1;
       original.objid = my_id;
       original.osnum = OM_Gw_current_OS;
       clone.objid = *newobjid;
       clone.osnum = new_mdenv->md_id.osnum;
     
       OM_stat = om$send (msg = message EMAsurface.EMcopy_recomp_info (
                               &mthd_stat, obj_mdenv, new_mdenv, *newobjid,
                               copy_info, bdry_options, sf_options),
                         targetid = my_id);
       EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);
     }

     if (is_associative_class && !(sf_options & EMS_COPY_ASSOCIATIVE))
     {
       struct GRid ret_GRid;
       ret_GRid.objid = NULL_OBJID;
       OM_stat = om$send (msg = message NDnode.NDmove_to_root(&mthd_stat,
                                &ret_GRid, new_mdenv),
                          targetid = *newobjid,
                          targetos = new_mdenv->md_id.osnum);
       EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

       if (ret_GRid.objid != (*newobjid))
       {
        *newobjid = ret_GRid.objid;
        EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 3, 
    	            &sf_copy_exists);
        EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);
       }
     } 

     /* Copy the graphics data objects */
    {
      struct GRid       copy_surf_GRid;
      OM_S_CHANSELECT   chan;

      copy_surf_GRid.objid = *newobjid;
      copy_surf_GRid.osnum = new_mdenv->md_id.osnum;
      
      OM_stat = EMmake_chanselect (EMSrequester_to_helpers, &chan);
      EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

      OM_stat = om$send(msg = message EMShelper.EMhelperCopy(EMmsg,
                        &copy_surf_GRid, copy_info),p_chanselect = &chan);
      if(! (1 & OM_stat & *EMmsg)) goto wrapup;
     }



#if HSURF_BUNDLES
  {
    struct  HSrender_bundle         rend;
    char 		            *app;
    IGRlong                         loc_msg;
    IGRint                          index;
    IGRint                          size1,size2;
    

    app = NULL;
    hs$get_app_entry_size (msg = &loc_msg, size = &size1,active=0,
                           mod_id = obj_mdenv->md_id.objid, 
                           mod_osnum = obj_mdenv->md_id.osnum);

    if (size1)
    {
        app = (char *) malloc(size1 +8);
        if ( app )
        {
           ((int *)app)[0] = 0;
           ((int *)app)[1] = 0;
        }
    }
    else
        app = NULL;
                           
 
    hs$retrieve_symb_entry(msg = &loc_msg, index = me->hidden_line,
                           entry = &rend, app_entry = app,
                           mod_id = obj_mdenv->md_id.objid, 
                           mod_osnum = obj_mdenv->md_id.osnum);

    if (size1 && app)
    {
        size2 = ((int *)app)[0];
        if (size1 != size2)
        {
            free(app);
            app = NULL;
        }
    }

    if (!(loc_msg&1))
    {
      hs$get_rendering_bundles(rend_bundle = &rend,
                               extra_rend_bundle = app);
    }

    hs$add_symb_entry(msg = &loc_msg, entry = &rend, app_entry = app,
                      index = &index, mod_id = new_mdenv->md_id.objid,
                      mod_osnum = new_mdenv->md_id.osnum);

    om$send(msg = message EMSsubbs.GRchghprops(&loc_msg, NULL, &index),
                        targetid = *newobjid,
                        targetos = new_mdenv->md_id.osnum);
    if (app)
        free(app);
  }
#endif

wrapup:
    GR_NOTIFY_LISTENERS(EMmsg, &OM_stat, GR_COPIED);

    EMWRAPUP (*EMmsg, OM_stat, "EMSsubbs.EMintcopy");

    return(OM_stat);
}

method GRchghprops(IGRlong *EMmsg; IGRshort *action; IGRint *index)
{
    *EMmsg = EMS_S_Success;
    me->hidden_line = *index;
    return OM_S_SUCCESS;
}


end implementation EMSsubbs;

