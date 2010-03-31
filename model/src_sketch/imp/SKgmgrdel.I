/*

Name
  SKgeometry.GRdelete

Abstract
  Delete a profile segment.
  
Synopsis

Description

Return Value

Notes

Index

Keywords
  profile

History
  02/25/93 : Mike Mathis   : Fixed to check return code from calls to
                             om$get_channel_count; in some cases the object may
                             not have the specified channel.  See TR#119301889.
  06/02/93 : Rajiv Agrawal : Converted the deletion of constraints to a function.
  06/20/93 : Rajiv Agrawal : Added a call to delete geometric constraints and
  			     moved all the functions to /funk/SKgmdelproc.I.

 */

class implementation SKgeometry;

#include <alloca.h>

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from SKvariable import SKintdelete;

extern GRclassid OPP_SKcompcurve_class_id;

method GRdelete ( long *msg; struct GRmd_env *md_env )
{
  OMuint              count1;
  int                 i, stat_OM;
  long                msg_loc;
  OM_S_OBJECT_LINKAGE *objlist;
  OM_S_CHANSELECT     chan_to_defpts, to_owners;
  OM_S_OBJECT_LINKAGE list [1];
  struct GRid         composite, geomid;
  GRclassid           class_id;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  msg_loc = OM_S_SUCCESS;

  count1=0;

  EMmake_chanselect ( GRconnector_to_owners, &to_owners );

  stat_OM = om$get_channel_objects ( objid = my_id, 
				     p_chanselect = &to_owners, 
                                     count = &count1, 
				     size = 1, 
				     list = list );
  EMomerr_exit ( stat_OM, ret_end );

  composite.objid = NULL_OBJID;

  if (count1)
  {
     om$get_classid ( osnum = list [0].osnum, 
		      objid = list [0].S_objid, 
		      p_classid = &class_id );

     composite.osnum = list [0].osnum;

     if (om$is_ancestry_valid ( subclassid = class_id, 
                                superclassid = OPP_SKcompcurve_class_id ) == OM_S_SUCCESS)
        composite.objid = list [0].S_objid;
  };

  /*
   * Delete any dimensions and implicit constraints that are directly connected to me.
   */
  geomid.objid = my_id;
  geomid.osnum = OM_Gw_current_OS;

  stat_OM = SKdelete_dimensions (&msg_loc, md_env, geomid);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

  stat_OM = SKdelete_geom_constrs (&msg_loc, md_env, geomid);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

  /*
   * Disconnect me from my defining SKptvars and send them an internal delete.
   */

  EMmake_chanselect ( SKgeometry_to_defpts, &chan_to_defpts );
  om$get_channel_count ( object = me, 
			 p_chanselect = &chan_to_defpts, 
		         count = &count1 );

  if (count1)
  {
    objlist = (OM_p_OBJECT_LINKAGE) alloca ( count1 * sizeof (OM_S_OBJECT_LINKAGE) );
    EMerr_hndlr ( !objlist, *msg, EMS_E_NoStackMemory, ret_end );

    stat_OM = om$get_channel_objects ( object = me,
                                       p_chanselect = &chan_to_defpts, 
				       count = &count1,
                                       size = count1, 
				       list = objlist );
    EMomerr_exit ( stat_OM, ret_end );

    stat_OM = om$send (msg = message Root.wild_disconnect ( chan_to_defpts ),
                       targetid = my_id );
    EMomerr_exit ( stat_OM, ret_end );

    for (i = 0; i < count1; i++)
      if (om$is_objid_valid ( osnum = objlist [i].osnum, 
                              objid = objlist [i].S_objid ) == OM_S_SUCCESS)
      {
        stat_OM = om$send (msg = message SKvariable.SKintdelete ( &msg_loc,
                         				          NULL, 
								  md_env ), 
                           targetid = objlist[i].S_objid);
        EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );
      }
  }

  /*
   * Finally delete me....
   */
  stat_OM = om$send ( mode = OM_e_wrt_message, 
                      msg = message GRgraphics.GRdelete ( &msg_loc, md_env ), 
                      targetid = my_id );
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
  

  if (composite.objid != NULL_OBJID)
  {
    /*
     * Make sure we haven't altered an open composite curve. If it is the case
     * the we create two composite curves because surfaces/solids don't like
     * composites with holes.
     */

    SKcheck_composite ( &msg_loc, &composite, md_env );
    EMerr_hndlr ( EMSerror ( msg_loc ), *msg, EMS_E_Fail, ret_end );

  }
  
ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKgeometry.GRdelete" );
  return stat_OM;
}

end implementation SKgeometry;
