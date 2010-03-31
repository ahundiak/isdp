/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

#include "EMS.h"
# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS message codes    */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMFRT_UPTODATE       */
# endif

#include "emsmacros.h"
#include "emserr.h"
#include "emsdef.h"

method EMreset( IGRlong           *EMmsg; 
                IGRushort  options )
/*
Abstract

    This method is used to reset the graphics data status.

Options

    EMS_O_OUTOFDATE : This option indicates that the graphics
                      data object is out of date with the current
                      boundaries. The graphics data must be
                      redisplayed before any other operation can
                      succeed.

    EMS_O_RETRIM    : This option indicates that the graphics
                      data object is out of date with the current
                      boundaries, but that the surface will not
                      be automatically redisplayed. Operations on
                      the graphics data (such as locate) will
                      work on the old data until a display is
                      performed.

History

    02-OCT-1992     msm     ANSI-C conversion.        
    24-APR-1991     SCW     Added graphic loop code
    28-Jun-1988     SAM     Added EMnotify_surface_range_modify message 
                                                         send to my_id.
    28-Apr-1988     AIC     Added reset option.
    ??-???-198?     AIC     Creation Date
*/
{
  IGRlong OM_stat;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if(options & EMS_O_OUTOFDATE) me^^EMShelper.props &= ~EMGD_UPTODATE;
  if(options & EMS_O_RETRIM) me^^EMShelper.props &= ~EMGD_TRIMMED;
  
  if(!(( options & EMS_GL_OUTOFDATE ) || ( options & EMS_GL_HOLD )))
  { 
     unsigned int                count = 1;
     IGRushort     gl_options = EMS_GL_OUTOFDATE;
     OM_S_OBJECT_LINKAGE   surf_link[1];
     OM_S_CHANSELECT       to_data_loop,
                           to_request; 


     OM_stat = om$send(msg = message EMSgradata.EMnotify_surface_range_modify
                                                        ( EMmsg ),
                       targetid = my_id);
     if( !( 1 & OM_stat & *EMmsg )) goto wrapup;

     /* channel that connects the graphic data(me) to the surface */
     to_request.type = OM_e_addr;
     to_request.u_sel.addr = &ME.EMShelper->to_requesters;

     /* get the objid of the surface */
     OM_stat = om$get_channel_objects( object       =  me,
                                       p_chanselect = &to_request,
                                       list         =  surf_link,
                                       size         =  count,
                                       count        = &count );
     EMerr_hndlr( !( 1 & OM_stat ), OM_stat, EMS_E_Fail, wrapup );

     /* channel connects the surface to graphic data & graphic loops */
     OM_stat = EMmake_chanselect( EMSrequester_to_helpers, &to_data_loop );
     EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, EMS_E_OMerror, wrapup );

     OM_stat = om$send( msg = message EMShelper.EMreset( EMmsg,
                                                         gl_options ),
                        senderid     = surf_link[0].S_objid,
                        p_chanselect = &to_data_loop );
     if( !( 1 & OM_stat & *EMmsg )) goto wrapup;
  }
  if ( options & EMS_O_OUTOFDATE)
  {
     unsigned int                count = 1;
     OM_S_OBJECT_LINKAGE   surf_link[1];
     OM_S_CHANSELECT       to_request;

     /* channel that connects the graphic data(me) to the surface */
     to_request.type = OM_e_addr;
     to_request.u_sel.addr = &ME.EMShelper->to_requesters;

     /* get the objid of the surface */
     OM_stat = om$get_channel_objects( object       =  me,
                                       p_chanselect = &to_request,
                                       list         =  surf_link,
                                       size         =  count,
                                       count        = &count );
     DPdlist_loopset_notify( surf_link[0].S_objid, surf_link[0].osnum );
   }
wrapup:

 EMWRAPUP(*EMmsg, OM_stat, "In EMSgradata.EMreset");
 return(OM_stat);
}

end implementation EMSgradata;
