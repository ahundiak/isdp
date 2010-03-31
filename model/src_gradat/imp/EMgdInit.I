/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

#include "EMS.h"
# ifndef EMSlogic_include
# include "EMSlogic.h"      /* IS, EMSmsgReport     */
# endif

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS message codes    */
# endif

# ifndef EMStypedef_include
# include "EMStypedef.h"    /* EMSmsgReport         */
# endif

# ifndef EMScmacros_include
# include "EMScmacros.h"    /* EMSmsgReport         */
# endif

# ifndef emserr_include
# include "emserr.h"        /* EMWRAPUP             */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMGD_NONNATURAL      */
# endif

# include "emsdef.h"

/*
HISTORY:

SAM   28/06/88   Modified such as to send EMnotify_surface_range_modify
                 message to my_id.
SCW   20-JUN-91  Added call to reset the graphic loop objects.
msm   03-OCT-92  ANSI-C conversion.

*/

method EMinit( IGRlong *EMmsg; 
               GRobjid  surf_id, 
                        loop_id )
{
  IGRlong  sts;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if( surf_id ISNT NULL_OBJID )
  {
    /*
     * Connect the surface
     */
    sts = om$send( msg = message EMShelper.EMhelperConnect( EMmsg, 
                                                            surf_id,
                                                            0 ),
                   targetid = my_id );
    if( !( 1 & *EMmsg & sts )) goto wrapup;

    /* Notify display list that a change has taken place - S. Subramanian 6/7/93 */
    DPdlist_loopset_notify( surf_id, OM_Gw_current_OS );

  }

  if( loop_id ISNT NULL_OBJID )
  {
    /*
     * Connect the loop
     */
    sts = om$send( msg = message EMShelper.EMhelperConnect( EMmsg, 
                                                            loop_id,
                                                            1 ), 
                   targetid = my_id );
    if( !( 1 & *EMmsg & sts )) goto wrapup;
    
    /*
     * Turn EMGD_NONNATURAL property bit on.
     */
    ME.EMShelper->props = 0;
    ME.EMShelper->props |= EMGD_NONNATURAL;
  }

  sts = om$send( msg = message EMSgradata.EMnotify_surface_range_modify(
                                                EMmsg ),
                 targetid = my_id );
  if( !( 1 & sts & *EMmsg )) goto wrapup;

  

  /* This next section of code will flag any graphic loop
   * objects as out of date.  This is so they will regenerate
   * on the next display.
   */
  { 
     unsigned int                count = 1;
     IGRushort     gl_options = EMS_GL_OUTOFDATE;
     OM_S_OBJECT_LINKAGE   surf_link[1];
     OM_S_CHANSELECT       to_data_loop,
                           to_request; 

     /* channel that connects the graphic data(me) to the surface */
     to_request.type = OM_e_addr;
     to_request.u_sel.addr = &ME.EMShelper->to_requesters;

     /* get the objid of the surface */
     sts = om$get_channel_objects( object       =  me,
                                   p_chanselect = &to_request,
                                   list         =  surf_link,
                                   size         =  count,
                                   count        = &count );
     EMerr_hndlr( !( 1 & sts ), sts, EMS_E_Fail, wrapup );

     /* channel connects the surface to graphic data & graphic loops */
     sts = EMmake_chanselect( EMSrequester_to_helpers, &to_data_loop );
     EMerr_hndlr( !( 1 & sts ), *EMmsg, EMS_E_OMerror, wrapup );

     sts = om$send( msg = message EMShelper.EMreset( EMmsg,
                                                     gl_options ),
                    senderid     = surf_link[0].S_objid,
                    p_chanselect = &to_data_loop );
     if( !( 1 & sts & *EMmsg )) goto wrapup;
  }
   
wrapup:
  EMWRAPUP( *EMmsg, sts, "EMSgradata.EMinit" )
  return( sts );
}

end implementation EMSgradata;
