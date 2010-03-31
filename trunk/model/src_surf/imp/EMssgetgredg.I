/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include <alloca.h>
#include "emsmacros.h"
#include "EMSfrtdef.h"     /* EMGL_NO_DISPLAY              */
#include "msdef.h"
#include "gocmacros.h"
#include "emsedgedef.h"    /* EMlinestring                 */
#include "EMSprop.h"       /* EMLP_ACTIVE                  */
#include "EMSopt.h"        /* nesting and profile options  */
#include "EMSbnddef.h"     /* EMSbnd.h                     */
#include "EMSbnd.h"        /* EMSpartolbasis               */
#include "bstypes.h"
#include "emsdef.h"
#include "EMdtmacros.h"
#include "EMSasnuc.h"      /* struct EMSobject_info        */
#include "EMSasopts.h"     /* EMSassoc.EMinit_associative options */
#include "madef.h"
#include "exdef.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMShrzcvs.h"

extern OMuword  OPP_EMSlinedge_class_id;
extern OMuword  OPP_EMSgraloop_class_id;
extern OMuword  OPP_EMShorizon_class_id;
extern OMuword  OPP_EMScusp_class_id;
extern OMuword  OPP_EMShrzcvs_class_id;

from EMSgraloop     import  EMglpinit, 
                            EMupdate_feature;
from EMSlinedge     import  EMleinit;
from EMSboundary    import  EMget_objid;
from EMShorizon     import  EMset_orientation;
from EMScusp        import  EMinit_cusp;
from EMShelper      import  EMget_the_edges,
                            EMset_props,
                            EMcheck_orientation;
from EMSdatpln      import  EMget_pln_info;
from EMSassoc       import  EMinit_associative;
from EMShrzcvs      import  EMplanar_to_view;


extern void EFset_surface_display();

method EMget_graphics_edges(
                      IGRlong         *EMmsg;
                      IGRint          *num_parents;   /* new parm */ 
                      struct EMSobject_info *parents; /* new parm */
                      IGRshort         options;
                      IGRint          *num_gralp_edges;
                      IGRint          *num_horiz_edges;
                      IGRint          *num_cusp_edges;                
                      struct GRid     **gralp_edges;
                      struct GRid     **horiz_edges;
                      struct GRid     **cusp_edges)


/*
Notes
    Upon exit the return code may be
      - EMS_S_Success if success
      - EMS_I_Success if horizon edges were requested and horizon curves
        have been returned.
	
  The current options available for edge selection are

  EMS_OPT_GRALOOP:          return graphic loop edges.
  EMS_OPT_HORIZON:          return horizon loop edges or horizon curves if
                            they exist.
  EMS_OPT_ALL_HORIZON:      return all horizon loop edges, regardless of
                            of what the z-vector is.
  EMS_OPT_CUSP:             return cusp edges.
  EMS_OPT_CREATE:           create horizon edges/cusps for the surface if 
                            they don't already exist.
  EMS_OPT_NO_DIS:           display and locate turned off for the 
                            horizon/cusp/graphic loop.  To be specified
                            with the EMS_OPT_CREATE option.
  EMS_OPT_DELETE_HRZ:       delete the horizon edges for the specified
                            view.
  EMS_OPT_ONLY_CUSP       [ only create an EMScusp and no EMShorizon object.
                            parent[1] should be filled out with the surface.
                            parent[0] will not be used.]
  EMS_OPT_CREATE_HRZ_CVS    create horizon curves if the surface is in a
                            read-only object space


  These options are includes in EMSopt.h file.

  The z_vector from the passed in reference plane will
  be used for creating and/or returning horizon edges.
  The reference plane must be in parents[0].  The surface
  should be in parents[1].

  The space will be allocated to store edges. The caller
  has the responsibility of deallocating this space.

History
        Jack 12-June-91  Creation
        Jack 02-July-91  Modified to create horizon edges/cusps for the
                         surface if so specified and if they don't 
                         already exist.
        SCW  23-JUL-1991 Added option for loop to be created with 
                         display and locate properties turned off.
                         Replaced the EMprofile call for horizon loops
                         with the necessary code from EMprofile.  This
                         was done to retrieve the loop id along with
                         other assorted reasons.
        Jack 13-Aug-91   Added option for deleting the specified horizon
                         loop and its edges.
        Jack 21-Aug-91   Changed so that a horizon/cusp object is not 
                         created if there are no edges for it.  Also
                         put a check in to not create a cusp object if
                         one already exists for this surface.
        Jack 28-Aug-91   Added capability to let the caller pass in a 
                         NULL z_vector implying that he only wants to 
                         attempt cusp placement.(no horizon edges)
        Jack 14-Sep-91   Moved call to get partolbasis and also removed
                         the conditional on the call to get it.
        Jack 16-Sep-91   The z_vector will no longer be passed in.  A 
                         parameter was added for the GRid of a reference 
                         plane.  If this is NULL, the active reference 
                         plane will be used.  The z_vector will be returned
                         by the reference plane.
        Jack 27-Sep-91   Added two new parms, num_parents and parents.
                         Removed the reference plane parm since that will
                         be in the parents list. 
        Jack 08-Nov-91   Moved the call to EMset_props back to here from
                         EMconstruct_associative.  If the EMS_OPT_NO_DIS
                         is set, the no_display prop will get set.
        Jack 20-Nov-91   When the user wanted cusp edges returned for an
                         existing cusp, I was exiting before getting the
                         edges.  Fixed that.
        Jack 27-Nov-91   If the uv order of the surface is 2X2, then it
                         will not get any horizon edges.  I put in a check
                         to avoid the horizon code in this case and just
                         do the cusp code.
        Jack 05-Dec-91   Make sure that the env matrices for the parents are
                         identity.  Re: problem with drawing views.
        AIC  03-Feb-92   include alloca.h
        NP   26-Aug-92   Modified for ANSI compliance. Modified typecasts and
                         changed variable "obj_count" type to IGRuint.
        Jack 10-Oct-92   After creating the cusp, turn off its EMGL_UPTODATE
                         prop.  This will insure that the cusp gets clipped
                         against the surface at display when the surface is
                         up to date.
        WBC  17-Jun-93   Added the option EMS_OPT_ALL_HORIZON so that all
                         horizon edges can be returned instead of just those
                         for a paticular orientation.
        WBC  19-Jul-93   Now searching for and/or creating horizon curves
                         as well as horizon edges.
        WBC  22-Nov-93   Getting the list of objects on the notification
                         channel and sending each of them the
                         EMShrzcvs.EMplanar_to_view message until
                         OM_I_STOP_SENDING is returned instead of just sending
                         the message out the notification channel.
        WBC  20-Jun-94   (TR 119419563) Added code to handle the option
                         EMS_OPT_CREATE_HRZ_CVS which indicates that horizon
                         curves should be created if the specified surface is
                         in a read-only object space.
                         
*/

{
  IGRlong             OM_stat;
  IGRint              only_create_cusp=0,
                      match=0,
                      tmp_opt=0;
  IGRuint             index1,
                      obj_count;
  IGRdouble           result= MAXFLOAT;
  IGRint              no_display;
  OM_S_CHANSELECT     to_helpers,
                      notification_chan,
                      to_components;
  extern IGRlong      GRcheckref();
  struct GRid         obj,
                      hrzcvs_grid;
  IGRdouble           z_vector[3]; 
  struct GRid         ref_plane_id;
  GRobjid             hlp_id = NULL_OBJID;
  GRspacenum          hlp_os,
                      mod_osnum;
  IGRshort            tmp_options;
  IGRboolean          read_only_ref;
  extern OM_S_OBJID   current_creator;
  OM_S_OBJID          local_creator;
  struct IGRbsp_surface *surface;
  IGRint              b_status;
  IGRlong             rc;
  struct GRmd_env     ident_env,
                      save_first,
                      save_second;
  struct GRvg_construct construct_list;
  struct GRsymbology    symbology;

  local_creator = current_creator;  

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  tmp_options = options;
  hrzcvs_grid.objid = NULL_OBJID;
  no_display = FALSE;
  read_only_ref = FALSE;

  to_helpers.type = OM_e_addr;
  to_helpers.u_sel.addr = &ME.EMSrequester->to_helpers;

  if(options & EMS_OPT_ONLY_CUSP)
    only_create_cusp = 1;   


   GRgetabsg( EMmsg, 
             &parents[1].env.md_env.matrix_type, 
              parents[1].env.md_env.matrix,
             (IGRchar **) &surface, 
              0 );
   if(! (1 & *EMmsg)) goto wrapup;

  /* if the surface we are dealing with has a uv order of 2X2 then
     it will have no horizon edges.
   */
  if((surface->u_order == 2) && (surface->v_order == 2))    
    {
     /* turn off the create option to avoid horizon loop stuff */ 
     tmp_opt = EMS_OPT_CREATE;
     options &= ~tmp_opt; 
     /* then only do cusp stuff */
     only_create_cusp = 1;
    }


  if(!only_create_cusp)
   {
     z_vector[0] = 0;
     z_vector[1] = 0;
     z_vector[2] = 0;    

     ref_plane_id.objid = parents[0].grid.objid;
     ref_plane_id.osnum = parents[0].grid.osnum;


     /* get the z_vector from the reference plane */                                       
     OM_stat = om$send(msg = message EMSdatpln.EMget_pln_info
                           ( EMmsg,
                             NULL,
                            &parents[1].env, 
                             NULL,
                             NULL,
                             z_vector,
                             NULL,
                             NULL), 
                   senderid = my_id,
                   targetos = ref_plane_id.osnum,
                   targetid = ref_plane_id.objid );
     if(! (1 & OM_stat & *EMmsg)) goto wrapup;

   }

   
  if(options & EMS_OPT_DELETE_HRZ)
   {
     /* 
      * Check to see if there already exists a horizon loop at this 
      * orientation.
      */
     OM_stat = om$send(msg = message EMShelper.EMcheck_orientation( 
                                                      z_vector,
                                                     &parents[1].env.md_env, 
                                                     &match,
                                                     &result,
                                                     &obj ),
                       p_chanselect = &to_helpers);
     if(! (1 & OM_stat)) goto wrapup;
 
     if(match)
     {
       /* delete the horizon object and its edges */  
      OM_stat =  om$send(msg      = message Root.delete(1),
               targetid = obj.objid,
               targetos = obj.osnum);

       if(! (1 & OM_stat)) goto wrapup;
     }
   }

  match = 0;

  if( options & (EMS_OPT_NO_DIS | EMS_OPT_CREATE) )
  {
     /* check to see if we are in a reference file attachment */
     OM_stat = GRcheckref( EMmsg,
                          &parents[1].env.md_env.matrix_type,
                           parents[1].env.md_env.matrix,
                           NULL,
                          &OM_Gw_current_OS );

     if( *EMmsg == MSSUCC )
     {
        /* Check to see if the object space is read only
         * if it is set the loop objects to no display,
         * no locate
         */
        if( OM_GA_OSDs [OM_Gw_current_OS]->flags & OM_e_loados_ro )
          if (options & EMS_OPT_NO_DIS)
            no_display = TRUE;
          else
            read_only_ref = TRUE;
     }
  }

  match = 0;

  if(options & (EMS_OPT_CREATE | EMS_OPT_HORIZON))
   {
   OM_S_MESSAGE                           planar_to_view_msg;
   OM_S_OBJECT_LINKAGE                   *channel_objects;
   OMuint                                 index;
   struct EMShrzcvs_EMplanar_to_view_Msg  EMplanar_to_view_args;

   /* Check for existing horizon curves corresponding to the requested
    * orientation;
    * Send to horizon curves; getting the list of objects on the
    * notification channel and sending each of them the
    * EMShrzcvs.EMplanar_to_view message until OM_I_STOP_SENDING is returned.
    * This is being done instead of just sending the message out the
    * notification channel since a non-horizon curve object on the
    * channel could return an error status and cause the send to
    * terminate before the appropriate horizon curve was displayed.
    */

   OM_stat = EMmake_chanselect(GRnotify_notification, &notification_chan);
   if(! (1 & OM_stat)) goto wrapup;

   OM_stat = om$get_channel_count(object = me,
                                  p_chanselect = &notification_chan,
                                  count = &obj_count ); 
   if(! (1 & OM_stat)) goto wrapup;
       
   if(obj_count)
   {
     /* only want to get horizon curves in the active (master) object space */

     OM_stat = ex$get_cur_mod(osnum = &mod_osnum);
     if(! (1 & OM_stat))
       goto wrapup;

     channel_objects = (OM_S_OBJECT_LINKAGE *) alloca(obj_count *
                                               sizeof( OM_S_OBJECT_LINKAGE ));

     if (! channel_objects)
     {
       OM_stat = OM_E_ERROR;
       *EMmsg = EMS_E_NoStackMemory;
       goto wrapup;
     }

     OM_stat = om$get_channel_objects(osnum = OM_Gw_current_OS,
                                      objid = my_id,
                                      p_chanselect = &notification_chan,
                                      list = channel_objects,
                                      size = obj_count,
                                      count = &obj_count);
     if(! (1 & OM_stat)) goto wrapup;

     OM_stat = OM_S_SUCCESS;

     /* using make message for efficiency purposes */

     EMplanar_to_view_args.EMmsg = EMmsg;
     EMplanar_to_view_args.options = EMS_HRZCVS_STOP_SEND;
     EMplanar_to_view_args.mdenv_info = &parents[0].env.md_env;
     EMplanar_to_view_args.z_vector = z_vector;
     EMplanar_to_view_args.window_grid = NULL;
     EMplanar_to_view_args.osnum = &mod_osnum;
     EMplanar_to_view_args.curve_id = &hrzcvs_grid;

     OM_stat = om$make_message(classname = "EMShrzcvs",
                               methodname = "EMplanar_to_view",
                               size = sizeof(EMplanar_to_view_args),
                               p_arglist = &EMplanar_to_view_args,
                               p_msg = &planar_to_view_msg);
     if(! (1 & OM_stat)) goto wrapup;

     for (index = 0; (index < obj_count) &&
                     (OM_stat != OM_I_STOP_SENDING); index++)
     {
       OM_stat = om$send(msg = &planar_to_view_msg,
                         targetid = channel_objects[index].S_objid,
                         targetos = channel_objects[index].osnum);
     }

     if ((OM_stat == OM_I_STOP_SENDING) &&
         (*EMmsg == EMS_S_Success))
       match = 1;
    }
   }

  if(options & EMS_OPT_CREATE)
   {

   if(!match)
    {
    /* 
     * Check to see if there already exists a horizon loop at this 
     * orientation.
     */
     OM_stat = om$send(msg = message EMShelper.EMcheck_orientation( 
                                                      z_vector,
                                                     &parents[1].env.md_env, 
                                                     &match,
                                                     &result,
                                                     &obj ),
                       p_chanselect = &to_helpers);
     if(! (1 & OM_stat)) goto wrapup;
    }

   if(!match)
    {
     /* Construct horizon curves if in a read-only reference file and horizon
      * curves have been requested, else create a horizon loop
      */

     if ((read_only_ref) &&
         (options & EMS_OPT_CREATE_HRZ_CVS))
     {
       /* construct the horizon curves in the active (master) object space */

       gr$get_module_env(buffer = &ident_env);

       OM_stat = om$construct(classid = OPP_EMShrzcvs_class_id,
                              osnum = ident_env.md_id.osnum,
                              p_objid = &hlp_id);
       if(! (1 & OM_stat)) goto wrapup;

       hlp_os = ident_env.md_id.osnum;

       OM_stat = om$send(msg = message GRvg.GRgetsymb(&rc, &symbology),
                         senderid = my_id,
                         targetid = parents[1].grid.objid,
                         targetos = parents[1].grid.osnum);
       if(! (1 & OM_stat)) goto wrapup;

       /* set up the construct information */

       construct_list.msg = &rc;
       construct_list.env_info = &ident_env;
       construct_list.newflag = FALSE;
       construct_list.level = symbology.level;
       construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
       construct_list.geometry = NULL;
       construct_list.display = &symbology.display_attr;
       construct_list.class_attr = NULL;
       construct_list.name = NULL;
    
       /* send EMinit_associative to the horizon loop.  This method
          will send EMconstruct_associative to the horizon loop.
        */  
       OM_stat = om$send(msg = message EMSassoc.EMinit_associative(
                         EMmsg,             /* return code */
                       /*  init_assoc_options,  options */
                         NULL,              /* options */
                        *num_parents,       /* number of parents */
                         parents,           /* parent information */
                         EMS_AShorizon_curves, /* type defining assoc info */
                         NULL,              /* size of info to store */
                         NULL,              /* recomp_info */              
                         &construct_list),   /* construction parameters */
                     senderid = my_id,
                     targetid = hlp_id,
                     targetos = hlp_os);

       EMerr_hndlr (!(1&OM_stat & *EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);

       /* if EMS_I_NoSolution is returned, no parting lines were created for
        * this surface, so the horizon curves object was deleted within
        * EMShrzcvs' EMconstruct_associative method
        */

       if (*EMmsg != EMS_I_NoSolution)
       {
         hrzcvs_grid.objid = hlp_id;
         hrzcvs_grid.osnum = hlp_os;
       }
     }
     else  /* create horizon edges instead of curves */
     {
       OM_stat = om$construct(classid = OPP_EMShorizon_class_id,
                              p_objid = &hlp_id);
       if(! (1 & OM_stat)) goto wrapup;

       if( no_display )
        {
         OM_stat = om$send( msg = message EMShelper.EMset_props( 
                                                  EMmsg,
                                                  EMGL_NO_DISPLAY,
                                                  EMS_O_ON ),
                            mode = OM_e_wrt_message,
                            targetid = hlp_id );
        }

       /* sort of a KLUDGE */
       ident_env.md_id.objid = 0;
       ident_env.md_id.osnum = 0;   

       ident_env.md_env.matrix_type = MAIDMX;
       b_status = MAidmx( &rc,
                           ident_env.md_env.matrix);

       /* save the parent md_envs */
       save_first = parents[0].env;
       save_second = parents[1].env;

       /* set the parent md_envs to identity matrices just for the call to init_assoc */
       parents[0].env = ident_env;
       parents[1].env = ident_env;

       current_creator = hlp_id;
       /*     init_assoc_options |= EMSasconst_noautodimension; */

       /* send EMinit_associative to the horizon loop.  This method
          will send EMconstruct_associative to the horizon loop.
        */  
       OM_stat = om$send(msg = message EMSassoc.EMinit_associative(
                         EMmsg,             /* return code */
                       /*  init_assoc_options,  options */
                         NULL,              /* options */
                        *num_parents,       /* number of parents */
                         parents,           /* parent information */
                         NULL,              /* type not needed at this class */
                         NULL,              /* size of info to store */
                         NULL,              /* recomp_info */              
                         NULL),   /* construction parameters */
                     senderid = my_id,
                     targetid = hlp_id,
                     targetos = OM_Gw_current_OS);
       current_creator = local_creator;

       /* restore the parent md_envs */
       parents[0].env = save_first;
       parents[1].env = save_second;

       EMerr_hndlr (!(1&OM_stat & *EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
     }
    } /* end if !match */ 

  /*** BEGIN KLUDGE block *************
    This is a kludge to get around the problem of an ASsourcein object and an
    ACpretendin object getting put on my NDfather channel in front of my reference
    plane and EMSpointer objects respectively.  For now, I will just disconnect these
    objects and connect my objects as they should be.

    if (*EMmsg != EMS_I_NoSolution)
    {
    OM_S_CHANSELECT     father,
                        listeners;
    struct GRid         source_GRid,
                        pretend_GRid;
    OMuword             source_classid;
     
   OM_stat = EMmake_chanselect( NDfather_father, &father );
   if(! (1 & OM_stat)) goto wrapup;

   om$get_objid_at_index( osnum = OM_Gw_current_OS,
                          objid = hlp_id
                          p_chanselect = &father,
                          index = 0,
                          objidaddr = &source_GRid.objid,
                          osnumaddr = &source_GRid.osnum );

    OM_stat = om$get_classid( objid = source_GRid.objid,
                              osnum = source_GRid.osnum,
                              p_classid = &source_classid );
    if(! (1 & OM_stat)) goto wrapup;             
 

    if( temp_classid == OPP_ASsourcein_class_id )
     {

     om$get_objid_at_index( osnum = OM_Gw_current_OS,
                            objid = hlp_id,
                            p_chanselect = &father,
                            index = 1,
                            objidaddr = &pretend_GRid.objid,
                            osnumaddr = &pretend_GRid.osnum );
    
     OM_stat = EMmake_chanselect( ASsource_listeners, &listeners );
     if(! (1 & OM_stat)) goto wrapup;

     om$get_objid_at_index( osnum = pretend_GRid.osnum,
                            objid = pretend_GRid.objid,
                            p_chanselect = &father,
                            index = 1,
                            objidaddr = &pretend_GRid.objid,
                            osnumaddr = &pretend_GRid.osnum );


     OM_stat = om$send(msg = message Root.wild_disconnect(father), 
                       targetid = hlp.objid, 
                       targetos = hlp.osnum);
      
      
     }
     
  
    } *** END KLUDGE block  **************/

    /* setting this flag will allow access to the display, locate, etc... 
     * methods for horizon edges since the system wide horizon flag won't 
     * be on.  GET_GRA_EDGES is defined in EMSopt.h.
     */  
    EFset_surface_display(GET_GRA_EDGES,1);
   }

  if((options & EMS_OPT_CREATE) || only_create_cusp)
     /*
      * Place cusps
      */
     {
       OM_S_OBJID              cuspid;
       IGRuint obj_count = 0;
       IGRint  cnt,
               found = 0;
       OM_S_OBJECT_LINKAGE *channel_objects = NULL;
       OMuword obj_classid;

       /* before creating the cusp, we first need to make sure
          we don't already have a cusp object for this surface.
          Only one to a customer.8^)
        */  
       OM_stat = om$get_channel_count( object = me,
                                       p_chanselect = &to_helpers,
                                       count = &obj_count ); 
       if(! (1 & OM_stat)) goto wrapup;
       
       if(obj_count)
        {
         channel_objects = (OM_S_OBJECT_LINKAGE *) alloca(sizeof(
                                    OM_S_OBJECT_LINKAGE)*obj_count);
          
         OM_stat = om$get_channel_objects(object = me,
                                          p_chanselect = &to_helpers,
                                          list = channel_objects,
                                          size = obj_count,
                                          count = &obj_count);
         if(! (1 & OM_stat)) goto wrapup;
 
         for(cnt = 0; cnt < obj_count; cnt++)
           {
             OM_stat = om$get_classid( objid = channel_objects[cnt].S_objid,
                                       osnum = channel_objects[cnt].osnum,
                                       p_classid = &obj_classid );
             if(! (1 & OM_stat)) goto wrapup;             
 
             if( obj_classid == OPP_EMScusp_class_id )
               found = 1;

           }
         if(found) /* don't want to create another cusp, but I do want
                      to go to the code that returns edges if desired.
                      I know I shouldn't use a goto here, but I'm in a
                      hurry.
                    */  
           goto prewrapup;
          
        }

       OM_stat = om$construct(classid = OPP_EMScusp_class_id,
                              p_objid = &cuspid);
       if(! (1 & OM_stat)) goto wrapup;

       /* must get the abstract geometry again since the call to
        * EMinit_associative may have called GRgetabsg for another object
        * which would overwrite the abstract geometry cache
        */

       GRgetabsg( EMmsg, 
                 &parents[1].env.md_env.matrix_type, 
                  parents[1].env.md_env.matrix,
                 (IGRchar **) &surface, 
                  0 );
       if(! (1 & *EMmsg)) goto wrapup;

       OM_stat = om$send(msg = message EMScusp.EMinit_cusp(
                                               surface, 
                                               my_id,
                                              &parents[1].env.md_env.matrix_type, 
                                               parents[1].env.md_env.matrix),
                         targetid = cuspid);

       /* if there were no cusp edges, then EMinit_cusp will have deleted
          the cusp object and set OM_stat to 0, just exit.
        */  
      if(OM_stat != 0)
       {
        if( no_display )
        {
           OM_stat = om$send( msg = message EMShelper.EMset_props( 
                                                      EMmsg,
                                                      EMGL_NO_DISPLAY,
                                                      EMS_O_ON ),
                              mode = OM_e_wrt_message,
                              targetid = cuspid );
        }

        /*
         * the graphic loop display will update the cusp against the surface
         */
        OM_stat = om$send( msg = message EMShelper.EMset_props( 
                                                    EMmsg,
                                                    EMGL_UPTODATE,
                                                    EMS_O_OFF ),
                           mode = OM_e_wrt_message,
                           targetid = cuspid );
        if(! (1 & OM_stat & *EMmsg)) goto wrapup;
       }
      else
        OM_stat = EMS_S_Success;




     } /* place cusps */



prewrapup:
  /* start with room for 32 edges of each kind. can realloc later if needed */
  if(options & EMS_OPT_GRALOOP)
  {
    *gralp_edges = (struct GRid *) om$malloc(size = (unsigned)
                                       (32 * sizeof(struct GRid )));
  }

  if((options & EMS_OPT_HORIZON) ||
     (options & EMS_OPT_ALL_HORIZON))
  {
    /* if horizon curves are being returned, already have their owner's object
     * id; we just need to get its components
     */

    if (hrzcvs_grid.objid != NULL_OBJID)
    {
      OM_S_OBJECT_LINKAGE *channel_objects;

      OM_stat = EMmake_chanselect( GRcmpowner_to_components, &to_components );
      if(! (1 & OM_stat)) goto wrapup;

      OM_stat = om$get_channel_count(osnum = hrzcvs_grid.osnum,
                                     objid = hrzcvs_grid.objid,
                                     p_chanselect = &to_components,
                                     count = &obj_count ); 
      if(! (1 & OM_stat)) goto wrapup;
       
      if(obj_count)
       {
        channel_objects = (OM_S_OBJECT_LINKAGE *) alloca(sizeof(
                                   OM_S_OBJECT_LINKAGE)*obj_count);

        OM_stat = om$get_channel_objects(osnum = hrzcvs_grid.osnum,
                                         objid = hrzcvs_grid.objid,
                                         p_chanselect = &to_components,
                                         list = channel_objects,
                                         size = obj_count,
                                         count = (IGRuint *) num_horiz_edges);
        if(! (1 & OM_stat)) goto wrapup;

        *horiz_edges = NULL;
        *horiz_edges = (struct GRid *) om$malloc(size = (unsigned)
                                           (*num_horiz_edges *
                                            sizeof(struct GRid )));
        if (! *horiz_edges)
         {
          *EMmsg = EMS_E_DynamicMemoryAllocated;
          goto wrapup;
         }

        for (index1 = 0; index1 < *num_horiz_edges; index1++)
         {
          (*horiz_edges)[index1].objid = channel_objects[index1].S_objid;
          (*horiz_edges)[index1].osnum = channel_objects[index1].osnum;
         }
      }

      /* create an options bitmask that does not request horizon edges */

      tmp_options = options & ~(EMS_OPT_HORIZON | EMS_OPT_ALL_HORIZON);
    }
    else
    {
        *horiz_edges = (struct GRid *) om$malloc(size = (unsigned)
                                           (32 * sizeof(struct GRid )));
    }
  }

  if(options & EMS_OPT_CUSP)
  {
    *cusp_edges  = (struct GRid *) om$malloc(size = (unsigned)
                                       (32 * sizeof(struct GRid )));  
  }
     
  /* only call EMget_the_edges if we want some edges */
  if((tmp_options & EMS_OPT_GRALOOP) ||
     (tmp_options & EMS_OPT_HORIZON) ||
     (tmp_options & EMS_OPT_CUSP)    ||
     (tmp_options & EMS_OPT_ALL_HORIZON))
   {
     OM_stat = om$send(msg = message EMShelper.EMget_the_edges( 
                                               EMmsg,
                                               tmp_options,
                                               z_vector,
                                              &parents[1].env.md_env,
                                               num_gralp_edges,
                                               num_horiz_edges,
                                               num_cusp_edges,                
                                               gralp_edges,
                                               horiz_edges,
                                               cusp_edges),
                       p_chanselect = &to_helpers);
     EMerr_hndlr (!(1&OM_stat & *EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
   }

wrapup:

  if ((1 & OM_stat & *EMmsg) &&
      (hrzcvs_grid.objid != NULL_OBJID))
    *EMmsg = EMS_I_Success;

  EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMget_graphics_edges")
  return( OM_stat );
}

end implementation EMSsubbs;

