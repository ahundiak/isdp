/*
Name
IGRlong COConstructObject( msg,
                display_mode,
                newflag,
                properties,
                geometry,
                module,
                symbology,
               *level,
                attr,
                name,
                new_objects_grid,
                display_grid,
                classname,
                classid,
                objid,
                object,
                neighbor,
                cob_id,
                cob_os,
                p_co_chanselect,
                from_index )

    IGRlong              *msg;
    enum GRdpmode        *display_mode;
    IGRboolean            newflag;
    short unsigned        properties;
    IGRchar              *geometry;
    struct GRmd_env      *module;
    struct IGRdisplay    *symbology;
    IGRshort             *level;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *new_objects_grid;
    struct GRid          *display_grid;
    IGRchar              *classname;
    GRclassid             classid;
    GRobjid               objid;
    GRobjecthdr          *object;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                from_index;


Abstract
        This function constructs and optionally displays an object.
        If the display_grid is specified, then the object is displayed.

Arguments
        msg
                return codes

        display_mode
                mode the object is displayed in ( if it is displayed ).
                defaults to GRbd

        newflag
                defaults to false.

        properties
                properties of the new graphics object

        geometry
                pointer to the geometry

        module
                module of the object space that the object in which the object
                is to be constructed

        symbology
                symbology of the new object
                if this pointer is NULL, then the symbology is gotten
                from the dpb.

        level
                level new object is to be placed on

        attr
                class attributes of the new object

        name
                name of the new object

        new_objects_grid
                GRid of the new object
                
        display_grid
                object that will display the new object

classname ^ classid ^ objid ^ object 

        classname
                class name of the new object

        classid
                class id of the new object

        objid
                object id of an old object

        object
                pointer to an object header

        neighbor
                a structure for neighbor near whom the object will be
                created

        cob_id   OM_S_OBJID
                command object's object id

        cob_os   GRspacenum
                command object's OS

        p_co_chanselect    *OM_S_CHANSELECT
                pointer to a channel structure in command object

Status returns

    om return codes dealing with constructs/connects
                                                                            
Caveats
    May not specify an object space.  The object space will be the
    same object space as the module's object space.
*/


class implementation Root;

#include "coimport.h"
#include "codebug.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "madef.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "ex.h"
#include "igrmacros.h"
#include "grdpbmacros.h"
#include "lcmacros.h"

/*----------------------------------------
 *  imports
 *----------------------------------------
 */

from GRgraphics import GRdisplay, GRconstruct;

#argsused
IGRlong COConstructObject(msg,
                          display_mode,
                          newflag,
                          properties,
                          geometry,
                          module,
                          symbology,
                          level,
                          attr,
                          name,
                          new_objects_grid,
                          display_grid,
                          classname,
                          classid,
                          objid,
                          object,
                          neighbor,
                          cob_id,
                          cob_os,
                          p_co_chanselect,
			  from_index )
     
     IGRlong              *msg;
     enum GRdpmode        *display_mode;
     IGRboolean            newflag;
     short unsigned        properties;
     IGRchar              *geometry;
     struct GRmd_env      *module;
     struct IGRdisplay    *symbology;
     IGRshort             *level;
     IGRchar              *attr;
     IGRchar              *name;
     struct GRid          *new_objects_grid;
     struct GRid          *display_grid;
     IGRchar              *classname;
     GRclassid             classid;
     GRobjid               objid;
     GRobjecthdr          *object;
     OM_S_NEIGHBOR         neighbor;
     OM_S_OBJID            cob_id;
     GRspacenum            cob_os;
     OM_S_CHANSELECT      *p_co_chanselect;
     IGRint                from_index;
     
{
  IGRlong                 status;
  IGRshort                local_level;
  struct IGRdisplay       local_symbology;
  struct GRvg_construct   construct_list;
  IGRlong                 num_bytes;
  IGRlong                 num_bytes_ret;
  IGRshort                dpb_properties;
  
  status = OM_S_SUCCESS;
  *msg = MSSUCC;
  
  if ( symbology == NULL )
    {
      /*
       *  get the default display symbology data from the DPB
       */
      _m_debug_str( "COConstructObject - getting active symbology." );
      num_bytes = sizeof( local_symbology );
      gr$get_active_display(msg = msg,
			    sizbuf = &num_bytes,
			    buffer = &local_symbology,
			    nret = &num_bytes_ret );
      _m_checkp( *msg, "COconstruct - failed get_active_display." );
      _m_checkq( *msg );
      
      symbology = &local_symbology;
    }
  
  
  if ( level == NULL )
    {
      /*
       *  get the default display symbology data from the DPB
       */
      _m_debug_str( "COConstructObject - getting active level." );
      num_bytes = sizeof( local_level );
      gr$get_active_level(msg = msg,
			  sizbuf = &num_bytes,
			  buffer = &local_level,
			  nret = &num_bytes_ret );
      _m_checkp( *msg, "COconstruct - failed get_active_level." );
      _m_checkq( *msg );

      level = &local_level;
    }
  
   num_bytes = sizeof(IGRshort);
   gr$get_active_prop(msg = msg,
                      sizbuf = &num_bytes,
                      buffer = &dpb_properties,
                      nret = &num_bytes_ret );

  /*  set up the vg_construct structure  */
  construct_list.msg         = msg;      /* msg returned from construct  */
  construct_list.env_info    = module;   /* context returned from ???    */
  construct_list.display     = symbology;/* contruction display parameter*/
  construct_list.geometry    = geometry; /* bspline geometry             */
  construct_list.newflag     = newflag;  /* normally false               */
  construct_list.level       = *level;   /* level object placed on       */
  construct_list.properties  = properties | dpb_properties;
  construct_list.class_attr  = attr;     /* special attr of a class      */
  construct_list.name        = name;     /* name of an object            */
  
  
  /*
   *  construct the object
   */
  new_objects_grid->osnum = module->md_id.osnum;
  if ( classname != NULL )
    {
      _m_debug_str( "COConstructObject - constructing obj by classname." );
      status = om$construct( msg = message GRgraphics.GRconstruct(
							  &construct_list ),
			    classname = classname,
			    obj_osnum = new_objects_grid->osnum,
			    osnum     = new_objects_grid->osnum,
			    p_objid   = &new_objects_grid->objid,
			    neighbor  = neighbor );
    }
  else if ( classid != OM_K_NOTUSING_CLASSID )
    {
      _m_debug_str( "COConstructObject - constructing obj by classid." );
      status = om$construct(msg = message GRgraphics.GRconstruct(
							     &construct_list ),
			    classid   = classid,
			    obj_osnum = new_objects_grid->osnum,
			    osnum     = new_objects_grid->osnum,
			    p_objid   = &new_objects_grid->objid,
			    neighbor  = neighbor );
    }
  else if ( objid != NULL_OBJID )
    {
      _m_debug_str( "COConstructObject - constructing obj by objid." );
      status = om$construct(msg = message GRgraphics.GRconstruct(
							     &construct_list ),
			    objid     = objid,
			    obj_osnum = new_objects_grid->osnum,
			    osnum     = new_objects_grid->osnum,
			    p_objid   = &new_objects_grid->objid,
			    neighbor  = neighbor );
    }
  else if ( object != NULL )
    {
      _m_debug_str( "COConstructObject - constructing obj by object." );
      status = om$construct(msg = message GRgraphics.GRconstruct(
							    &construct_list ),
			    object    = object,
			    obj_osnum = new_objects_grid->osnum,
			    osnum     = new_objects_grid->osnum,
			    p_objid   = &new_objects_grid->objid,
			    neighbor  = neighbor );
    }
  _m_check2p(status, *construct_list.msg,
	     "COConstructObject - failed construct" );
  _m_check2q( status, *construct_list.msg );

  /*
   *  Display object 
   */
  if ( display_grid != NULL )
    {
      enum GRdpmode  local_display_mode = GRbd;
      
      if ( display_mode == NULL )
        {
	  display_mode = &local_display_mode;
        }
      
      _m_debug_str( "COConstructObject - displaying object." );
      _m_debug(printf( "COConstructObject - display_mode is %d.\n",
                       *display_mode ); );

      status = om$send(msg = message GRgraphics.GRdisplay(msg,
					          &module->md_env.matrix_type,
                                                   module->md_env.matrix,
                                                   display_mode,
                                                   display_grid ),
		       senderid = NULL_OBJID,
		       targetid = new_objects_grid->objid,
		       targetos = new_objects_grid->osnum );
      
      _m_check2p( status, *msg, "COConstructObject - failed display" );
      _m_check2q( status, *msg );
    }
    
    /*
     *  if both channel selectors are not null, ( checked in the
     *  om macro ), then connect the two objects.
     */
  if ( p_co_chanselect != NULL )
    {
      _m_debug_str( "COConstructObject - calling lc$connect." );
      status = lc$connect(osnum = cob_os,
			  objid = cob_id,
			  p_chanselect = p_co_chanselect,
			  go_objid = new_objects_grid->objid,
			  go_osnum = new_objects_grid->osnum );
      _m_checkp( status, "COConstructObject - failed lc$connect." );
    }
  
  
 quit:
  return( status );
}

end implementation Root;
