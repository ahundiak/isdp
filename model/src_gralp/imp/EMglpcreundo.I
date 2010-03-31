/* ###################   APOGEE COMPILED   ################## */
/*                                                            */

/* history
   10-JUN-91  SCW  Genesis
   03-OCT-92  msm  ANSI-C conversion
   
*/   
class implementation EMSgraloop;


method EMcreator_undoing( IGRlong  *EMmsg; 
                          GRobjid  *creator_id )
{
  IGRlong               i,
                        status;
  OMuint                edge_cnt;
  unsigned short        options=NULL;
  GRobjid               creator_objid;
  OM_S_OBJECT_LINKAGE  *pt_edge=0;
  OM_S_CHANSELECT       to_ptedge;

  extern OMuword        OPP_EMSpartedge_class_id;
  extern IGRlong        EFget_creator_id();
  extern IGRboolean     EFisAncestryValid();

  /*
   * Initialize
   */
  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;


  status = EMmake_chanselect( EMSbd_owner_to_comps, &to_ptedge );
  EMerr_hndlr( !( 1 & status ), *EMmsg, EMS_E_OMerror, wrapup );

  /* find out how many [part]edges are out there */
  status = om$get_channel_count( object       =  me,
                                 p_chanselect = &to_ptedge,
                                 count        = &edge_cnt );

  pt_edge = (OM_S_OBJECT_LINKAGE *)om$malloc(
                       size = edge_cnt * sizeof(OM_S_OBJECT_LINKAGE ));
  if( !( pt_edge ))
  {
     *EMmsg = EMS_E_NoDynamicMemory; 
     goto wrapup;
  }

  /* retrieve all the [part]edges out there */
  status = om$get_channel_objects( object       =  me,
                                   p_chanselect = &to_ptedge,
                                   list         = pt_edge,
                                   size         =  edge_cnt,
                                   count        = &edge_cnt );
  EMerr_hndlr( !( 1 & *EMmsg & status ), *EMmsg, EMS_E_Fail, wrapup );

  for( i = 0; i < edge_cnt; i++ )
  {
     /* check to make sure we have a part edge rather than an edge */
     if( EFisAncestryValid( EMmsg,
                            pt_edge[i].S_objid,
                            pt_edge[i].osnum,
                            OPP_EMSpartedge_class_id,
                            FALSE ))
     {
        /* get the creator of the part edge */
        status = EFget_creator_id( EMmsg,
                                   pt_edge[i].S_objid,
                                   pt_edge[i].osnum,
                                  &creator_objid,
                                   options );
        EMerr_hndlr( !( 1 & *EMmsg & status ), *EMmsg, EMS_E_Fail, wrapup );

        /* if we have the right class and matching creator ids
         * rearrange the channels and delete the offending part edge
         */
        if( creator_objid == *creator_id )
        {
           /* move connections from part edge to myself */
           status = om$send( msg = message Root.move_chan( to_ptedge,
                                                           pt_edge[i].S_objid,
                                                           pt_edge[i].osnum,
                                                           to_ptedge ),
                             targetid = my_id );
           EMerr_hndlr( !( 1 & status ), *EMmsg, EMS_E_OMerror, wrapup );

           status = om$send( msg = message Root.delete( NULL ),
                             targetid = pt_edge[i].S_objid, 
                             targetos = pt_edge[i].osnum );
           EMerr_hndlr( !( 1 & status ), *EMmsg, EMS_E_EdgeError, wrapup );
        }
     }
  }

wrapup:
  if( pt_edge ) om$dealloc( ptr = pt_edge );

  EMSmsgReport( status, "EMSgraloop.EMcreator_undoing", FALSE );
  if EMSmsgReport( *EMmsg, "EMSgraloop.EMcreator_undoing", FALSE )
    status = OM_E_ABORT;
  return( status );                              
}

end implementation EMSgraloop;
