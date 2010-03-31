/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

# include "EMS.h"

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS error codes  */
# endif

# ifndef emserr_include
# include "emserr.h" 
# endif

# ifndef EMStypedef_include
# include "EMStypedef.h"    /* EMSmsgReport     */
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"      /* EMSmsgReport     */
# endif

# ifndef EMScmacros_include
# include "EMScmacros.h"    /* EMSmsgReport     */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMFRT_UPTODATE   */
# endif

# include "emsdef.h"

/*
HISTORY:
    
    02 Jan 1989 AIC Rewrite to prevent deletion of objects needed
                    to preserve the class.
    20-JUN-91   SCW Added call to reset graphic loop objects.
    03-MAR-92   WBC Checking to see if there are any graphic loop objects
                    before reseting them and deleting myself after the reset
                    instead of before it.
    03-OCT-92   msm ANSI-C conversion.
*/

extern OMuword OPP_EMSgraloop_class_id;

method delete( int f_defer_flag )
{
  IGRlong               sts, 
                        EMmsg;
  OM_S_CHANSELECT       to_requesters, 
                        to_helpers;
  OM_S_OBJECT_LINKAGE   obj_list[2];
  OMuint                count;
  OMuword               my_classid;
  IGRboolean            delete_gradata = FALSE;

  sts = OM_S_SUCCESS;
  EMmsg = EMS_S_Success;

  sts = om$get_classid( object    =  me,
                        p_classid = &my_classid );
  if( !( 1 & sts )) goto wrapup;

  if(( my_classid IS OPP_EMSgradata_class_id ) ||
     ( my_classid IS OPP_EMSgraloop_class_id ))
  {
    delete_gradata = TRUE;
  }
  else
  {
    sts = om$is_ancestry_valid( subclassid   = my_classid,
                                superclassid = OPP_EMSgraloop_class_id );
    if( sts IS OM_S_SUCCESS )
    {
      delete_gradata = TRUE;
    }
    else
    {
      sts = EMmake_chanselect( EMShelper_to_requesters, &to_requesters );
      if( !( 1 & sts )) goto wrapup;

      sts = om$get_channel_objects( object       =  me,
                                    p_chanselect = &to_requesters,
                                    list         =  obj_list,
                                    size         =  2,
                                    count        = &count );
      if( !( 1 & sts )) goto wrapup;

      if( obj_list[0].S_objid == sender_id )  delete_gradata = TRUE;
      else
      {
        sts = om$send( msg = message Root.wild_disconnect( to_requesters ),
                       targetid = my_id );
        if( !( 1 & sts )) goto wrapup;

        sts = EMmake_chanselect( EMSrequester_to_helpers, &to_helpers );
        if( !( 1 & sts )) goto wrapup;

        EMmsg = EMS_I_NoResponse;
        sts = om$send( msg = message EMSgradata.EMget_class_info(
                                                         &EMmsg,
                                                         &my_classid,
                                                          NULL ),
                       senderid = obj_list[0].S_objid,
                       p_chanselect = &to_helpers );

        if( sts == OM_W_UNKNOWN_MSG )  sts = OM_S_SUCCESS;
        if( !( 1 & sts )) goto wrapup;

        if( EMmsg IS EMS_I_NoResponse )
        {
          ME.EMShelper->props &= ~( EMGD_NONNATURAL | EMGD_UPTODATE );

          sts = om$send( msg = message EMSgradata.EMinit(
                                               &EMmsg,
                                                obj_list[0].S_objid,
                                                NULL_OBJID ),
                         targetid = my_id );
          if( !( 1 & EMmsg & sts )) goto wrapup;

        }
        else delete_gradata = TRUE;

      } /* else NOT ( obj_list[0].S_objid == sender_id ) */

    } /* else NOT is_ancestry_valid */

  } /* else my class ISNT EMSgradata or EMSgraloop */
 
  if( delete_gradata )
  {
    sts = om$send( msg = message EMSgradata.EMnotify_surface_range_modify(
                                                             &EMmsg ),
                   targetid = my_id );

    /* This next section of code will flag any graphic loop
     * objects as out of date.  This is so they will regenerate
     * on the next display.
     */
    { 
       OMuint                count = 1;
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

       if (count > 0)
       {
          sts = EMmake_chanselect( EMSrequester_to_helpers, &to_data_loop );
          EMerr_hndlr( !( 1 & sts ), EMmsg, EMS_E_OMerror, wrapup );

          sts = om$send( msg = message EMShelper.EMreset(&EMmsg,
                                                          gl_options ),
                         senderid     = surf_link[0].S_objid,
                         p_chanselect = &to_data_loop );
          if( !( 1 & sts & EMmsg )) goto wrapup;
       }
    }

    sts = om$send( mode = OM_e_wrt_message,
                   msg = message Root.delete( 1 ),
                   targetid = my_id );
  }

wrapup:
  EMWRAPUP( EMmsg, sts, "In EMSgradata.delete" )
  return( sts );
}

end implementation EMSgradata;
