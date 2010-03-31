/*
IGRlong SKcreate_polygon(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                LineGrid,
                DisplayGrid,
                classname,
                classid,
                neighbor,
                cob_id,
                cob_os)
                                                                            
    IGRlong              *msg;
    struct GRevent       *Events[];
    enum GRdpmode        *DisplayMode;
    IGRboolean            newflag;
    struct GRmd_env      *ModuleInfo;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort             *ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *LineGrid;
    struct GRid          *DisplayGrid;
    IGRchar              *classname;
    GRclassid             classid;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;

Abstract
    This function constructs a bspline representation of an n-sided
    polygon, then constructs and optionally displays a polygon object.
    If the display_obj is specified, then the object is displayed.
    Note: The function has been modified to be used for placing polygons
    by midpoint of side as well.
         
                                                                        
Arguments

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the number of sides
        event[1] is the center point of the polygon.
        event[2] is a vertex point of the polygon.

    The rest of the arguments are exactly as specified in co$construct_object.
    Except that object, objid, and geometry are not allowed.

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
Caveats
    May not specify an object space.  The object space will be the
    same object space as the module's object space.

History
    trc 06/15/87 : Created
    srh 05/23/89 : removed GRIS_ properties from construct list 
    jjc 10/25/89 : added funtionality for N-sided Polygon by Midpoint of Side
    jjc 01/24/90 : Conditionally compiled out the code for Polygon by
                   Midpoint of Side for IDRAW.
    ra  11/10/92 : Added code to create a profile or a composite curve.
 Sudha  07/02/93 : Modified for BSprototypes ansification
 09/01/93 : Rajiv Agrawal : Use the convert to profile technology.
 09/09/93 : Rajiv Agrawal : Place a multi-equality constraint rather than in pairs.
 04/18/94 : Sudha         : Purify fix 
 
*/

class implementation Root;

#include "coimport.h"
#include "codebug.h"

#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "griodef.h"
#include "madef.h"
#include "msdef.h"
#include "dpdef.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"
#include "comisc.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"
#include "EMdtmacros.h"
#include "EMSdatumdef.h"
#include "emserr.h"
#include "SKdef.h"
#include "SKinc.h"
#include "SKmacros.h"
#include "emsdef.h"
#include "alloca.h"
#include "dimplcmacros.h"
#include "dimdef.h"
#include "mapytobc.h"

from GRgraphics   import GRdisplay, GRdelete;
from GRconnector  import GRrigidconn;
from GRvg	  import GRpostabsg;
from EMSdatpln 	  import EMget_pln_info;
from SKconstraint import SKinit;
from SKvariable	  import SKgetvar;

extern GRclassid OPP_SKifequal_class_id, OPP_SKrelang_class_id, OPP_SKifptpt_class_id;
extern IGRlong COnpolygonConstruct();

#ifndef IDRAW
extern IGRlong COnmppolygonConstruct();
#endif /* IDRAW */

/*----------------------------------------
 *  SKcreate_polygon
 *----------------------------------------
 */
IGRlong SKcreate_polygon(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                LineGrid,
                DisplayGrid,
                classname,
                classid,
                neighbor,
                cob_id,
                cob_os)
                                                                            
    IGRlong              *msg;
    struct GRevent       *Events[];
    enum GRdpmode        *DisplayMode;
    IGRboolean            newflag;
    struct GRmd_env      *ModuleInfo;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort             *ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *LineGrid;
    struct GRid          *DisplayGrid;
    IGRchar              *classname;
    GRclassid             classid;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;
{
/* BV - BEGINNING OF VARIABLE LIST */

    IGRlong             status;         /* return code                  */
    IGRboolean          b_status;       /* return status                */
    struct GRid         WindowGrid;   /* window object id */
    IGRlong             WhichError; 
    IGRmatrix           RotationMatrix;
    IGRlong             BytesReturned;
    struct var_list     VariableList[2];
    IGRlong             NumberOfSides;
    IGRdouble          *PointArray;
    IGRdouble          *Knots;
    struct IGRbsp_curve bspline;        /* used in the construct            */
    struct IGRpolyline  polyline;       /* polyline used to when making bsp */
    IGRpoint            CenterPoint;    /* point part of center event       */
    IGRpoint            EdgePoint;      /* point part of vertex event       */
    IGRshort		properties;
    struct IGRpolyline  oneline;
    double		line_points[6];
    long		i, msg_loc;
    struct GRid		comp_curve_grid;
    struct GRpost_info	post_info;
    IGRboolean		assoc_state;
    

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */


    _m_debug_str( "CO_ni_place_npoly_by_vertex." );


    /*
     *  set up msg and status so that a nil event will not end up with a
     *  bad status
     */
    *msg = MSSUCC;
    status = MSSUCC;
    b_status = TRUE;
    msg_loc = OM_S_SUCCESS;

    NumberOfSides = (IGRlong) Events[0]->event.value;
    PointArray = (IGRdouble *)om$malloc( 
                    size = ((NumberOfSides + 1) * 3) * sizeof( IGRdouble ) );
    Knots = (IGRdouble *)om$malloc(
                    size = (NumberOfSides + 1 + 2 ) * sizeof( IGRdouble ) );
    if ( PointArray == NULL || Knots == NULL )
    {
        *msg = MSFAIL;
        return( OM_E_ABORT );
    }

    WindowGrid.objid = Events[1]->event.button.objid;
    WindowGrid.osnum = Events[1]->event.button.osnum;
                                                                              

    /*
     *  set up the variable list
     */
    VariableList[0].var       = VIEW_ROTATION;
    VariableList[0].var_ptr   = (char *) RotationMatrix;
    VariableList[0].num_bytes = sizeof( IGRdouble ) * 16;
    VariableList[0].bytes_returned = &BytesReturned;
    VariableList[1].var = END_PARAM;
                                                                              

    /*
     *  get the view matrix for the display
     */
    _m_debug_str( "COnipoly - calling inq_set." );
    status = dp$inq_set_gragad(
                            msg = msg,
                            gragad_objid = WindowGrid.objid,
                            which_error = &WhichError,
                            var_list = VariableList );
    _m_check2p( status, *msg, "COnipoly - failed inq_set_gragad." );
    _m_check2q( status, *msg );
                                                                              
    /*
     *  init the polyline
     */
    polyline.num_points = NumberOfSides + 1;
    polyline.points     = PointArray;
                                                                              
    /*
     *  init the bspline's pointers
     */
    bspline.poles = PointArray;
    bspline.knots = Knots;
                                                                              

    /*
     *  construct the point array of the polygon
     */
    CenterPoint[0] = Events[1]->event.button.x;
    CenterPoint[1] = Events[1]->event.button.y;
    CenterPoint[2] = Events[1]->event.button.z;
    EdgePoint[0] = Events[2]->event.button.x;
    EdgePoint[1] = Events[2]->event.button.y;
    EdgePoint[2] = Events[2]->event.button.z;


/*  the following check is done to distinguish which command called this
 *  function.  Place N-sided Polygon by Vertex will have a subtype of
 *  GRst_REGULAR and Place N-sided Polygon by Midpoint of Side will 
 *  have a subtype of GRst_DEFAULT.  this was done since the two commands
 *  were so similar. 
 */

 if(Events[3]->subtype == GRst_REGULAR) {

    _m_debug_str( "COnipoly - calling COnpolygonConstruct." );
    status = COnpolygonConstruct( 
                                msg,
                                RotationMatrix,
                                CenterPoint,
                                EdgePoint,
                                &NumberOfSides,
                                PointArray );
    _m_check2p( status, *msg, "COninpoly - failed in COnpolyConstr." );
    _m_check2q( status, *msg );

  }
 else if(Events[3]->subtype == GRst_DEFAULT) {
#ifndef IDRAW
    _m_debug_str( "COnipoly - calling COnmppolygonConstruct." );
    status = COnmppolygonConstruct( 
                                msg,
                                RotationMatrix,
                                CenterPoint,
                                EdgePoint,
                                &NumberOfSides,
                                PointArray );
    _m_check2p( status, *msg, "COninpoly - failed in COnmppolyConstr." );
    _m_check2q( status, *msg );
#endif /* IDRAW */
  }

    /*
     *  classname is specified
     */
    _m_debug_str( "CO_ni_place_npoly - calling construct." );
    LineGrid->osnum = comp_curve_grid.osnum = ModuleInfo->md_id.osnum;
    properties = GRIS_NEW | GRIS_DISPLAYABLE | GRIS_LOCATABLE;
    if ( classname != NULL )
    {
        status = co$construct_object(
                        msg = msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = properties, 
                        geometry = &bspline,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = &comp_curve_grid,
                        display_obj = DisplayGrid,
                        neighbor = neighbor,
                        cob_id = cob_id,
                        cob_os = cob_os,
                        classname = classname );
    }
    else /* classid is specified */
    {
        status = co$construct_object(
                        msg = msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = properties,
                        geometry = &bspline,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = &comp_curve_grid,
                        display_obj = DisplayGrid,
                        neighbor = neighbor,
                        cob_id = cob_id,
                        cob_os = cob_os,
                        classid = classid );
    }

    _m_check2p( 
                status,
                *msg,
                "CO_ni_place_npoly - failed in co$construct object." );
        

    /*
     * construct all the component line segements and attach them to
     * the composite curve.
     */
        
    for (i=0; i<NumberOfSides; i++)
    {
      OM_BLOCK_MOVE( &PointArray[i*3], &line_points[0], 2*sizeof(IGRpoint));
      oneline.num_points = 2;
      oneline.points = line_points;
      b_status = MApytobc( msg, &oneline, &bspline );
      _m_check_boolp( b_status, "COninspoly - failed MApytobc." );
      _m_check_boolq( b_status );
      _m_checkp( *msg, "COninspoly - failed MApytobc." );
      _m_checkq( *msg );
      status = co$construct_object(
                  msg = msg,
                  mode = DisplayMode,
                  module = ModuleInfo,
                  newflag = newflag,
                  properties = properties, 
                  geometry = &bspline,
                  symbology = ActiveDisplay,
                  level = ActiveLevel,
                  attr = attr,
                  name = name,
                  grid = LineGrid,
                  display_obj = DisplayGrid,
                  neighbor = neighbor,
                  cob_id = cob_id,
                  cob_os = cob_os,
                  classname = "GR3dlineseg" );

      status = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
                              &comp_curve_grid, &i),
                        targetid = LineGrid->objid,
                        targetos = LineGrid->osnum,
                        senderid = NULL_OBJID );
      EMerr_hndlr (EMSerror (status & msg_loc), status, OM_E_ABORT, quit);
    }
    
    /*
     * post the abstract geometry of the comp curve .. basically set the
     * GRIS_PHY_CLOSED bit.
     */

    post_info.construct_flag = TRUE;
    status = om$send ( msg = message GRvg.GRpostabsg
                             (&msg_loc, ModuleInfo, &post_info, NULL, &comp_curve_grid.objid),
                       targetid = comp_curve_grid.objid,
                       targetos = comp_curve_grid.osnum,
                       senderid = NULL_OBJID );
    EMerr_hndlr (EMSerror (status & msg_loc), status, OM_E_ABORT, quit);

    /*
     * Depending on the Associativity lock, convert the composite curve 
     * into a profile and add the equality constraint.
     */
    gr$get_associative_flag(buffer = &assoc_state);
    if (assoc_state)
    {
      OM_S_OBJECT_LINKAGE 	*objlist;
      int			num_vgpts;
      OM_S_CHANSELECT   	chan_to_defpts;
      OMuint			count = 0;
      GRobjid			*vgpts, skmgr = NULL_OBJID;
      struct GRid		cnstr_grid;
      
      sk$convert_to_profile ( msg = &msg_loc,
                              options = SK_CONVERT_VERBOSE | SK_CONVERT_NO_AUTO_CONSTRAIN, 
                              module = ModuleInfo, 
                              geometry = comp_curve_grid,
                              profile = &skmgr);

      if ( msg_loc != SK_CONVERT_OK ) {
	status = OM_E_ABORT;
        goto quit;
      }

      EMmake_chanselect (SKmgr_to_vars, &chan_to_defpts);
      objlist = (OM_S_OBJECT_LINKAGE *) alloca (NumberOfSides * sizeof(OM_S_OBJECT_LINKAGE));
      vgpts = (GRobjid *) alloca (2*NumberOfSides * sizeof(GRobjid));
       
      status = om$get_channel_objects (objid = skmgr,
                                       osnum = comp_curve_grid.osnum, 
                                       p_chanselect = &chan_to_defpts,
                                       count = &count, size = NumberOfSides, 
                                       list = objlist);
      EMerr_hndlr (count != NumberOfSides, status, OM_E_ABORT, quit);
      num_vgpts = 0;
      for (i=0; i < NumberOfSides; i++)
      {
        vgpts[num_vgpts++] = objlist[i].S_objid;
        if (i < NumberOfSides - 1)
          vgpts[num_vgpts++] = objlist[i+1].S_objid;
        else
          vgpts[num_vgpts++] = objlist[0].S_objid;
      }

      status = om$construct (classid = OPP_SKifequal_class_id,
                             osnum = comp_curve_grid.osnum,
                             msg = message SKconstraint.SKinit (&msg_loc,
                                   SK_OPT_CREATE_GEOMETRY | SK_OPT_DISPLAY_GEOMETRY |
                                   SK_OPT_MARK_AS_NEWADD | SK_OPT_MARK_AS_USERADD,
                                   ModuleInfo, num_vgpts, vgpts, NULL, NULL, NULL),
                             p_objid = &cnstr_grid.objid);
      EMerr_hndlr (EMSerror (status & msg_loc), status, OM_E_ABORT, quit);
    }

    /*
     * time to display it ...
     */
    status = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                            &ModuleInfo->md_env.matrix_type, ModuleInfo->md_env.matrix, 
                            DisplayMode,
                            &ModuleInfo->md_id), 
                      targetid = comp_curve_grid.objid, 
                      targetos = comp_curve_grid.osnum,
                      senderid = NULL_OBJID);
    EMerr_hndlr (EMSerror (status & msg_loc), status, OM_E_ABORT, quit);

quit:
    om$dealloc( ptr = PointArray );
    om$dealloc( ptr = Knots );
    return ( status );
}

end implementation Root;

#if WE_NEED_TO_LOOK_AT_THE_OLD_CONSTRAINING_SCHEME
    int			ref_lock_state;
    OM_S_OBJECT_LINKAGE *objlist;
    int			num_vgpts;
    OM_S_CHANSELECT     chan_to_defpts, to_geom;
    OMuint		count;
    GRobjid		*vgpts;
    struct GRid		cnstr_grid, line_id, line2_id, dim_grid;
    int 		trak_dir, sector;
    IGRpoint      	dumpt;
    struct SKcnstr_ptinfo *cnstr_ptinfo;
      GRobjid   skmgr;
      struct GRid planid;
      IGRvector x_axis, z_axis;
      IGRpoint  origpt;
      
      ems$ref_plane_lock(msg = &msg_loc,
                         options = EMS_REF_PLANE_LOCK_INQ,
                         mode = &ref_lock_state);
      if (ref_lock_state & EMS_REF_PLANE_LOCK_OFF)
      {
        ems$ref_plane_lock(msg = &msg_loc, 
                           options = EMS_REF_PLANE_LOCK_ON | EMS_REF_PLANE_LOCK_SET );
      }

      planid.objid = NULL_OBJID;
      ems$get_active_datum_plane (msg = &msg_loc, datpln = &planid);
      EMerr_hndlr (EMSerror (msg_loc) || IF_NULL_OBJID (planid.objid),
                   status, OM_E_ABORT, quit);
      status = om$send (msg = message EMSdatpln.EMget_pln_info (&msg_loc,
                              NULL, ModuleInfo, x_axis, NULL, z_axis, origpt, NULL),
                        targetid = planid.objid, targetos = planid.osnum,
                        senderid = NULL_OBJID);
      EMerr_hndlr (EMSerror (status & msg_loc), status, OM_E_ABORT, quit);

      /*
       * Setup the constraints information for creating a profile.
       */
      cnstr_ptinfo = (struct SKcnstr_ptinfo *) alloca(NumberOfSides * sizeof(struct SKcnstr_ptinfo));
      for (i=0; i<NumberOfSides; i++)
      {
        cnstr_ptinfo[i].pttype[0] = PT_NULL;
        cnstr_ptinfo[i].pttype[1] = PT_NULL;
      }


/*
      cnstr_ptinfo[1].pttype[0] = PT_DIST;
      for (i=2; i<NumberOfSides-1; i++)
        cnstr_ptinfo[i].pttype[0] = PT_SWEEP;
*/
      status  = SKcreate_profile (&msg_loc, SK_OPT_CREATE_GEOMETRY,
                                  comp_curve_grid.objid, ModuleInfo, &planid, NULL,
                                  origpt, x_axis, z_axis, 
                                  NumberOfSides, cnstr_ptinfo, TRUE, &skmgr);
      EMerr_hndlr (EMSerror (status & msg_loc), status, OM_E_ABORT, quit);
      
      
      /*
       * construct one point-to-point constraint.
       */
      vgpts[0] = objlist[0].S_objid;
      vgpts[1] = objlist[1].S_objid;
      status = om$construct (classid = OPP_SKifptpt_class_id, 
                             osnum = comp_curve_grid.osnum,
                             msg = message SKconstraint.SKinit (&msg_loc,
                                   SK_OPT_MARK_AS_NEWADD | SK_OPT_MARK_AS_USERADD |
                                   SK_OPT_CONNECT_GEOMETRY, ModuleInfo,
                                   2, vgpts, NULL, NULL, NULL),
                             p_objid = &cnstr_grid.objid);
      EMerr_hndlr (EMSerror (status & msg_loc), *msg, OM_E_ABORT, quit);

      EMmake_chanselect ( SKvariable_to_geometries, &to_geom);
      om$get_objid_at_index ( objid = vgpts[1], 
                              osnum = comp_curve_grid.osnum,
                              p_chanselect = &to_geom,
                              index = 0,
                              objidaddr = &line_id.objid, osnumaddr = &line_id.osnum );
      
      dim_grid.objid = NULL_OBJID;
      trak_dir = 1;
      /* dumpt[0] = dumpt[1] = dumpt[2] = 0.0; */
      status = om$send ( msg = message SKvariable.SKgetvar(&msg_loc, NULL, 
                               &ModuleInfo->md_env.matrix_type, ModuleInfo->md_env.matrix,
                               (double *) dumpt),
                         targetid = vgpts[1],
                         targetos = comp_curve_grid.osnum,
                         senderid = NULL_OBJID);
      dm$place_sglpara (orig_grid = &line_id,
                        orig_pt = dumpt,
                        plane_grid = &planid,
                        trak_dir = trak_dir, 
                        owner = &cnstr_grid, 
                        dim_grid = &dim_grid); 
      EMerr_hndlr (dim_grid.objid == NULL_OBJID, *msg, OM_E_ABORT, quit);

      /*
       * construct the angle constraints.
       */
      for (i=0; i < NumberOfSides - 3; i++)
      {
        vgpts[0] = objlist[i].S_objid;
        vgpts[1] = objlist[i+1].S_objid;
        vgpts[2] = objlist[i+1].S_objid;
        vgpts[3] = objlist[i+2].S_objid;
        status = om$construct (classid = OPP_SKrelang_class_id,
                               osnum = comp_curve_grid.osnum,
                               msg = message SKconstraint.SKinit (&msg_loc,
                                     SK_OPT_CONNECT_GEOMETRY | 
                                     SK_OPT_MARK_AS_NEWADD | SK_OPT_MARK_AS_USERADD,
                                     ModuleInfo, 4, vgpts, NULL, NULL, NULL),
                               p_objid = &cnstr_grid.objid);
        EMerr_hndlr (EMSerror (status & msg_loc), status, OM_E_ABORT, quit);
        
        om$get_objid_at_index ( objid = vgpts[1], 
                                osnum = comp_curve_grid.osnum,
                                p_chanselect = &to_geom,
                                index = 0,
                                objidaddr = &line_id.objid, osnumaddr = &line_id.osnum );
        om$get_objid_at_index ( objid = vgpts[3], 
                                osnum = comp_curve_grid.osnum,
                                p_chanselect = &to_geom,
                                index = 0,
                                objidaddr = &line2_id.objid, osnumaddr = &line2_id.osnum );
       
        dim_grid.objid = NULL_OBJID;
        sector = 1;
        status = om$send ( msg = message SKvariable.SKgetvar(&msg_loc, NULL, 
                                 &ModuleInfo->md_env.matrix_type, ModuleInfo->md_env.matrix,
                                 (double *) dumpt),
                           targetid = vgpts[1],
                           targetos = comp_curve_grid.osnum,
                           senderid = NULL_OBJID);
            
        dm$place_angular (orig_grid = &line_id,
                          orig_pt = dumpt,
                          meas_grid = &line2_id,
                          meas_pt = dumpt,
                          plane_grid = &planid,
                          sector = sector, 
                          owner = &cnstr_grid,
                          dim_grid = &dim_grid);
        EMerr_hndlr (dim_grid.objid == NULL_OBJID, *msg, OM_E_ABORT, quit);
         
      }

      comp_curve_grid.objid = skmgr;  	/* just for display purposes */      

      /*
       * put the ref-plane lock OFF, if it was off.
       */
      if (ref_lock_state & EMS_REF_PLANE_LOCK_OFF)
      {
        ems$ref_plane_lock(msg = &msg_loc, 
                           options = EMS_REF_PLANE_LOCK_OFF | EMS_REF_PLANE_LOCK_SET );
      }
#endif

