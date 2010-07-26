class implementation COnpt;

#include "coimport.h"
#include "codebug.h"
#include "grerr.h"
#include "grmessage.h"
#include "codef.h"
#include "godef.h"
#include "msdef.h"
#include "madef.h"
#include "dpdef.h"
#include "griodef.h"
#include "grio.h"
#include "comisc.h"
#include "comiscmac.h"
#include "coniarray.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "msmacros.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "igrmacros.h"
#include "lcmacros.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"
#include "maerr.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include <stdio.h>

/* COnpt3.I - graphic object manipulation */
/*
 setup_dyn_info
 add_point 
 delete_point 
 ?????????  const_dynamics 
 construct_object 
 construct_polygon 
 close_ortho_polygon 
 delete_element 
 use_one_element 
 use_two_elements 
 set_up_n_elements 
 locate_two_and_construct 
 use_events 
 DYlinear 
 change_arc_to_circle 
 arc_to_comp_arc 
 extend_arc_by_angle 
 diameter_to_radius 
 convert_to_profile 
 ignore_skobj 
 isopen 
 is_physically_open 
*/

from GRvg       import  GRgeomprops, GRgetgeom, GRgetsize;
from GRgraphics import  GRdelete;
from GRlinear   import  GRremovepts;


method setup_dyn_info ( long * sts )
{
  extern IGRint LCdyn_rbextend();
  
  *sts = MSSUCC;

  me->dyn = &me->dyn_info;
  me->dyn_info.GRlc_dyn = (IGRint (*)()) LCdyn_rbextend;
  me->dyn_info.add_info = (IGRchar *) &me->locate_ModuleInfo;

  return OM_S_SUCCESS;
}

method add_point ( long * sts )
{

  /* works for linear, poly.uses pt1, pt2.sends add pt */

  int status = OM_S_SUCCESS;
  struct GRid          WindowGrid,ObjectsGrid,NewObjid;
  IGRmatrix            RotationMatrix;
  IGRlong              BytesReturned, WhichError; 
  struct var_list      VariableList[2];
  OM_S_OBJECT_LINKAGE  ChannelLinkage[1];
  IGRint               NumberObjectsFound;
  IGRshort             NumberOfPoints=1;
  IGRpoint             SecondPoint;
  struct GRevent      *Events[2];
  IGRshort              NumberOfEvents;
  IGRboolean           b_status;

    /*
     *  make the neccessary declarations for the bspline curve
     *  and the knots, weights, poles for a line 
     */
    GRls_declare( line, LinePolesetc );

/* EV - end of variable declarations */

    status = OM_S_SUCCESS;
    NumberOfEvents = 2;

    /*
     *  initialize the poles, weights, knots pointers in the line 
     */
    GRls_init( line, LinePolesetc );

    /*  load the events for the call to the router
     */
    Events[0] = &(me->first_event);
    Events[1] = &(me->second_event);    

    /*  
     *  ROUTER:
     *  Construct the nurb form of a line given
     *  the two data point events.  Special construction
     *  points are handled by this router.
     */
    b_status = GRls2pt( 
                    sts,
                    Events,
                    &NumberOfEvents,
                    &line );

    /*
     * verify a valid curve was generated
     */
    status = COcheck_curve(sts,&line);
    _m_checkq(status);


    /*  extract the second point from the line passed back by the router 
     */
    SecondPoint[0] = line.poles[3];
    SecondPoint[1] = line.poles[4];
    SecondPoint[2] = line.poles[5];


  WindowGrid.objid = me->second_event.event.button.objid;
  WindowGrid.osnum = me->second_event.event.button.osnum;

  /*
   *  set up the variable list
   */
  VariableList[0].var       = VIEW_ROTATION;
  VariableList[0].var_ptr   = (IGRchar *)RotationMatrix;
  VariableList[0].num_bytes = sizeof( IGRdouble ) * 16;
  VariableList[0].bytes_returned = &BytesReturned;
  VariableList[1].var = END_PARAM;
                                                                              
  /*
   *  get the view matrix for the display
   */
  status = dp$inq_set_gragad( msg = sts,
                             gragad_objid = WindowGrid.objid,
                             which_error = &WhichError,
                             var_list = VariableList );
  _m_check2q( status, *sts );


  /*
   *  find out who is the GO that I am connected to
   */
  status = lc$get_channel_objects(objid = my_id,
                                  p_chanselect = &me->const_chansel,
                                  list = ChannelLinkage,
                                  size = 1,
                                  count = &NumberObjectsFound );
  
  if ( status != OM_I_LISTOVFLOW )
    {
      *sts = MSSUCC;
      ObjectsGrid.objid = ChannelLinkage[0].S_objid;
      ObjectsGrid.osnum = ChannelLinkage[0].osnum;
    }
  _m_checkq( status );
  
  
  /*
   *  add the points
   */
  status = GRaddptsutil(sts,
                        &me->ConstructInfo,
                        &ObjectsGrid.osnum,
                        &ObjectsGrid.objid,
                        &NumberOfPoints,
                        SecondPoint,
                        &RotationMatrix[8],
                        &NewObjid.objid );

quit:
  return OM_S_SUCCESS;
}

method delete_point ( long * sts )
{
  int status = OM_S_SUCCESS;

  IGRshort NumberOfPoints = 1;


  *sts = MSSUCC;

  /*
   *  delete a vertex from the object.
   */
  status = om$send( msg = message GRlinear.GRremovepts( 
                             (IGRlong *)sts,
                             &me->ConstructInfo,
                             &NumberOfPoints ),
                    p_chanselect = &me->const_chansel );

  _m_check2( status, *sts, *sts = MSFAIL );

  return OM_S_SUCCESS;
}

method construct_object ( long * sts )
{
  int             status;
  struct GRid     NewObjectsGrid; /* grid for line string             */
  struct GRevent *events[NUMBER_OF_EVENTS];

  *sts = MSSUCC;


  /*
   *  make sure that the function index is in the range allowable,
   *  make sure that there is that many functions, and that the
   *  index is greater than zero
   */
  if ( !CO_ni_index_in_range( me->mytype ) )
  {
    return( OM_S_SUCCESS );
  }


  /*
   *  set up the array of events so that the function that we
   *  called will know all the data points an values that the user
   *  has entered.
   */
  set_up_event_array;


  /*
   *  disconnect the previously created object from
   *  myself
   */
  status = lc$wild_disconnect( p_chanselect = &me->const_chansel );
  _m_checkq( status );


  /*
   *  construct the damn object
   */
  status = co$ni_place_func( func_index = me->mytype,
                             msg = sts,
                             events = events,
                             module = &me->ConstructInfo,
                             attr = me->AttributePointer,
                             grid = &NewObjectsGrid,
                             classname = me->const_class,
                             p_co_chansel = &me->const_chansel );
  if( (*sts == GRILLDEFINITION) || (*sts == MADGENRAT)|| 
      (*sts == MASDGENRAT) || (*sts == MAIDGENRAT)||
      (*sts == MANOSOLUTION))
  {
    ex$message( msgnumb = GR_E_IllDef,
                field   = ERROR_FIELD,
                justification = LEFT_JUS );
    *sts = MSSUCC;
    goto quit;
  }
  if ( *sts == GRNOTIMPLEMENTED )
  {
    ex$message( msgnumb = GR_E_ConstNotImp,
                field   = ERROR_FIELD,
                justification = LEFT_JUS );
       
    *sts = MSSUCC;
    goto quit;
  }
  _m_check2( status, 
             *sts, 
             ex$message( msgnumb = GR_E_ErrInConst,
                         field   = ERROR_FIELD,
                         justification = LEFT_JUS  ) );

quit:
  return OM_S_SUCCESS;
}


method construct_polygon ( long * sts )
{
  int status;

  status = om$send (mode = OM_e_wrt_message,
                    msg = message COnpt.construct_object(sts),
                    targetid = my_id);
           
  return OM_S_SUCCESS;
}


method close_ortho_polygon ( long * sts )
{
  int status = OM_S_SUCCESS;

  /*
   *  srh  05/23/89 : removed hard coded properties from construct list
   */
  IGRboolean            b_status;

  struct IGRbsp_curve  *bspline_ptr,   
                        orthopoly;   

  struct GRid           orthopoly_grid;

  struct IGRpolyline    polyline;

  IGRdouble            *poles,
                       *knots;

  IGRlong               index,
                        size;


  *sts = MSSUCC;

  status = om$send( msg = message GRvg.GRgetsize(
                             (IGRlong *)sts,
                            &me->ModuleInfo.md_env.matrix_type,
                             me->ModuleInfo.md_env.matrix,
                            &size ),
                    p_chanselect = &me->const_chansel );
 
  bspline_ptr = (struct IGRbsp_curve *)om$malloc( size = size );

  status = om$send( msg = message GRvg.GRgetgeom(
                        (IGRlong *)sts,
                        &me->ModuleInfo.md_env.matrix_type,
                        me->ModuleInfo.md_env.matrix,
                        (IGRchar *)bspline_ptr ),
                    p_chanselect = &me->const_chansel );
  _m_check2q( status, *sts );


  /*  Added this line of code to avoid closing ortho polygons that have
   *  fewer than 3 vertices.  At this time the graphic object would 
   *  allow itself to have fewer than 3 vertices so this code was needed.
   *  1/9/90,jjc.
   */
  if(bspline_ptr->num_poles < 3) 
  {
    *sts = MSFAIL;
    goto quit;
  }


  polyline.points = 
           (IGRdouble *)om$malloc(size = ( ((bspline_ptr->num_poles+5)*3) 
                                           * sizeof(IGRdouble)) );

  polyline.num_points = bspline_ptr->num_poles;

  poles = (IGRdouble *)om$malloc(size = ( ((bspline_ptr->num_poles+5)*3) 
                                          * sizeof(IGRdouble)) );   

  knots = (IGRdouble *)om$malloc(size = ( (bspline_ptr->num_poles+6) 
                                          * sizeof(IGRdouble) ) );   

  orthopoly.poles = poles;
  orthopoly.knots = knots;

  for( index=0; index < bspline_ptr->num_poles*3; index++ )
  {
    polyline.points[index] = bspline_ptr->poles[index];
  }

  b_status = GRclorthpg(sts, &polyline);

  status = MApytobc( sts, &polyline, &orthopoly ); 

  status = om$send( msg = message GRgraphics.GRdelete(
                            (IGRlong *)sts,
                            &me->ModuleInfo),
                    p_chanselect = &me->const_chansel );

  status = co$construct_object( msg = sts,
                                mode = GRbd,
                                module = &me->ConstructInfo,
                                properties = 0,
                                geometry = &orthopoly,
                                level = NULL,
                                symbology = NULL,
                                attr = me->AttributePointer,
                                grid = &orthopoly_grid,
                                p_co_chansel = &me->const_chansel,
                                classname = "GR3dorthpoly" );

  /* BE CAREFUL IF YOU BRANCH TO quit AFTER MALLOCING !!! */
  om$dealloc( ptr = polyline.points );
  om$dealloc( ptr = knots );
  om$dealloc( ptr = poles );
  om$dealloc( ptr = bspline_ptr );

quit:
  return OM_S_SUCCESS;
}

method delete_element ( long * sts )
{
  int status = OM_S_SUCCESS;

  /*  This action will delete an element that is on the construct
   *  channel. 1/9/90,jjc.
   */

  status = om$send( msg = message GRgraphics.GRdelete( (IGRlong *)sts,
                                                       &me->ModuleInfo),
                    p_chanselect = &me->const_chansel );

  return OM_S_SUCCESS;
}

method use_one_element ( long * sts )
{
  int status = OM_S_SUCCESS;
  struct GRid    ModuleGrid;
  struct GRevent *events[NUMBER_OF_EVENTS];

  *sts = MSSUCC;

  if ( !CO_ni_index_in_range( me->mytype ) )
  {
    return(OM_S_SUCCESS);
  }

  /*
   *  set up the array of events so that the function that we
   *  called will know all the data points an values that the user
   *  has entered.
   */
  set_up_event_array;

  /*
   *  get the active module
   */
  status = ex$get_cur_mod( id = &ModuleGrid.objid,
                           osnum = &ModuleGrid.osnum );


  status = co$ni_modify_func( func_index = me->mytype,
                              msg = sts,
                              events = events,
                              module = &me->ModuleInfo,
                              mode = GRbd,
                              display_obj = &ModuleGrid,
                              p_chanselect = &me->located_chansel );

  _m_check( status, *sts = MSFAIL; );

  return OM_S_SUCCESS;
}

method use_two_elements ( long * sts )
{
  int status = OM_S_SUCCESS;

    struct GRevent    *events[NUMBER_OF_EVENTS];
    struct GRid        ModuleGrid;

    declare_multi;

    *sts = MSSUCC;

    /*
     *  get myself to set up some data structures
     */
    set_up_multi;
    status = om$send( msg = message COnpt.set_up_n_elements( grids ),
                     targetid = my_id );
    _m_checkq( status );


    /*
     *  get the active module
     */
    status = ex$get_cur_mod( id    = &ModuleGrid.objid,
                             osnum = &ModuleGrid.osnum );

    /*
     *  call the two locate modify function
     */
    status = co$ni_modify_two_elements_func(
                func_index = me->mytype,
                msg = sts,
                events = events,
                modules = modules,
                display_obj = &ModuleGrid,
                objects = grids );
quit:
  return OM_S_SUCCESS;
}

method set_up_n_elements ( struct GRid  *grids[] )
{
  int status = OM_S_SUCCESS;

    IGRlong              NumberObjectsFound;
    OM_S_OBJECT_LINKAGE  ChannelLinkage[1];/* linkage to objects on channel */
    OM_S_CHANSELECT      MyChannelStruct;

    /*
     *  set up the channel structure
     */
    status = om$make_chanselect( chanaddr     = &me->ToFirstLocated,
                                 p_chanselect = &MyChannelStruct );

    /*
     *  find out who is on my channel
     */
    status = lc$get_channel_objects(objid = my_id,
                                    p_chanselect = &MyChannelStruct,
                                    list = ChannelLinkage,
                                    size = 1,
                                    count = &NumberObjectsFound );
    _m_checkq( status );

    /*
     *  store the GRids for later use
     */
    grids[0]->objid = ChannelLinkage[0].S_objid;
    grids[0]->osnum = ChannelLinkage[0].osnum;


    /*
     *  find out who is on my channel
     */
    status = lc$get_channel_objects( objid = my_id,
                                     p_chanselect = &me->located_chansel,
                                     list = ChannelLinkage,
                                     size = 1,
                                     count = &NumberObjectsFound );
    _m_checkq( status );


    grids[1]->objid = ChannelLinkage[0].S_objid;
    grids[1]->osnum = ChannelLinkage[0].osnum;


    /*
     *  set up the channel structure
     */
    status = om$make_chanselect(chanaddr     = &me->ToSecondLocated,
                                p_chanselect = &MyChannelStruct );

    /*
     *  find out who is on my channel
     */
    status = lc$get_channel_objects(objid = my_id,
                                    p_chanselect = &MyChannelStruct,
                                    list = ChannelLinkage,
                                    size = 1,
                                    count = &NumberObjectsFound );
    _m_checkq( status );


    /*
     *  store the GRids for later use
     */
    grids[2]->objid = ChannelLinkage[0].S_objid;
    grids[2]->osnum = ChannelLinkage[0].osnum;

quit:
  return OM_S_SUCCESS;
}


method locate_two_and_construct ( long * sts )
{
  int status = OM_S_SUCCESS;
  struct GRevent  *events[NUMBER_OF_EVENTS];
  struct GRid      ModuleGrid,
                   NewObjectsGrid,
                   tmp_grid;
  declare_multi; /* a macro */

  *sts = MSSUCC;


    /*
     *  disconnect the previously created object from
     *  myself
     */
     status = lc$wild_disconnect(
                          p_chanselect = &me->const_chansel );
    _m_checkq( status );


    /*
     *  get myself to set up some data structures
     */
    set_up_multi2;
    status = om$send(mode = OM_e_wrt_message,
                    msg = message COnpt.set_up_n_elements(grids ),
                    targetid = my_id );
    _m_checkq( status );

    tmp_grid = SecondGrid;
    SecondGrid = ThirdGrid;
    ThirdGrid = tmp_grid;

    /*
     *  get the active module
     */
    status = ex$get_cur_mod( id    = &ModuleGrid.objid,
                             osnum = &ModuleGrid.osnum );

    /*
     *  call the two locate construct function
     */
    status = co$ni_locate_two_and_construct(
                func_index = me->mytype,
                msg = sts,
                events = events,
                modules = modules,
                construct_module = &me->ConstructInfo,
                attr = &me->AttributePointer,
                classname = me->const_class,
                grid = &NewObjectsGrid,
                display_obj = &ModuleGrid,
                objects = grids,
                p_co_chansel = &me->const_chansel );

    if( (*sts == GRILLDEFINITION) || (*sts == MADGENRAT)|| 
        (*sts == MASDGENRAT) || (*sts == MAIDGENRAT)||
        (*sts == MANOSOLUTION))
    {
       ex$message( msgnumb = GR_E_IllDef,
                   field   = ERROR_FIELD,
                   justification = LEFT_JUS );
       *sts = MSSUCC;
       goto quit;
    }
    if ( *sts == GRNOTIMPLEMENTED )
    {
       ex$message( msgnumb = GR_E_ConstNotImp,
                   field   = ERROR_FIELD,
                   justification = LEFT_JUS );
        *sts = MSSUCC;
        goto quit;
    }
    if ( *sts == MANONPLANAR )
    {
       ex$message( msgnumb = GR_E_NotCoplanar,
                   field   = ERROR_FIELD,
                   justification = LEFT_JUS );
        *sts = MSSUCC;
        goto quit;
    }
    _m_check2( status, *sts,  
               ex$message( msgnumb = GR_E_ErrInConst,
                           field   = ERROR_FIELD,
                           justification = LEFT_JUS ) );
quit:
  return OM_S_SUCCESS;
}

method use_events ( long * sts )
{
  int             status = OM_S_SUCCESS;
  struct GRevent *events[NUMBER_OF_EVENTS];

  *sts = MSSUCC;


  /*
   *  make sure that the function index is in the range allowable,
   *  make sure that there is that many functions, and that the
   *  index is greater than zero
   */
  if ( !CO_ni_index_in_range( me->mytype ) )
  {
    return( status );
  }


  /*
   *  set up the array of events so that the function that we
   *  called will know all the data points an values that the user
   *  has entered.
   */
  set_up_event_array;


  /*
   *  call the non-interactive function
   */
  status = CO_GA_ni_funcs[ me->mytype ]( sts, events );

  return OM_S_SUCCESS;
}

method DYlinear ( long *sts; int index )
{
  struct GRevent     *Events[1];
  struct IGRdisplay   ActiveDisplay;
  IGRlong             NumberOfBytes = sizeof( ActiveDisplay ),
                      BytesReceived;

  *sts = MSSUCC;

  switch( index )
  {
    case 0:   Events[0] = &me->first_event; break;
    case 1:   Events[0] = &me->second_event; break;
    case 2:   Events[0] = &me->third_event; break;
    case 3:   Events[0] = &me->fourth_event; break;
    case 4:   Events[0] = &me->fifth_event; break;
    case 5:   Events[0] = &me->sixth_event; break;
    case 6:   Events[0] = &me->seventh_event; break;
    default:  *sts = MSINARG; goto quit;
  }

  /*
   *  now, call the object dynamics routine.
   */

  gr$get_active_display( msg    =  sts,
                         sizbuf = &NumberOfBytes,
                         buffer = &ActiveDisplay,
                         nret   = &BytesReceived );

  if ( queue_empty && vsd_empty )
  {
    ex$message( in_buff       = me->prompt,
                field         = PROMPT_FIELD,
                justification = RIGHT_JUS );
  }

  DYrblinear( Events, &ActiveDisplay );

quit:
  return OM_S_SUCCESS;
}

method change_arc_to_circle ( long * sts )
{
  int status = OM_S_SUCCESS;

    struct GRid         ModuleGrid;

    status = ex$get_cur_mod(id    = &ModuleGrid.objid,
                            osnum = &ModuleGrid.osnum );

    status = COarc_to_circle( sts,
                             &me->first_event,
                             &me->ModuleInfo,
                             &ModuleGrid,
                              my_id,
                             &me->located_chansel );

  return OM_S_SUCCESS;
}

method arc_to_comp_arc ( long * sts )
{
  int status = OM_S_SUCCESS;

    struct GRid         ModuleGrid;

    status = ex$get_cur_mod(id    = &ModuleGrid.objid,
                            osnum = &ModuleGrid.osnum );

    status = COcomp_arc( sts,
                        &me->first_event,
                        &me->ModuleInfo,
                        &ModuleGrid,
                         my_id,
                        &me->located_chansel );

  return OM_S_SUCCESS;
}

method extend_arc_by_angle ( long * sts )
{
  int status = OM_S_SUCCESS;

    struct GRid         ModuleGrid;

    status = ex$get_cur_mod(id    = &ModuleGrid.objid,
                            osnum = &ModuleGrid.osnum );

    me->second_event.event.value = me->first_event.event.value;

    status = COx_arc_angle( sts,
                           &me->second_event,
                           &me->ModuleInfo,
                           &ModuleGrid,
                            my_id,
                           &me->located_chansel );

  return OM_S_SUCCESS;
}


method diameter_to_radius ( long *sts; int index )
{
  switch( index )
  {
    case 0:   me->first_event.event.value   /= 2.0; break;
    case 1:   me->second_event.event.value  /= 2.0; break;
    case 2:   me->third_event.event.value   /= 2.0; break;
    case 3:   me->fourth_event.event.value  /= 2.0; break;
    case 4:   me->fifth_event.event.value   /= 2.0; break;
    case 5:   me->sixth_event.event.value   /= 2.0; break;
    case 6:   me->seventh_event.event.value /= 2.0; break;
    default:  *sts = MSINARG;
  }
  return OM_S_SUCCESS;
}

/* 
 * the three actions below are not used in GRNUC - they are overriden in 
 * EMS but calls as a stub by GRNUC wireframe commands  (Shelley Heard 1/6/93)
 */
method convert_to_profile ( long * sts )
{
  return OM_S_SUCCESS;
}

method ignore_skobj ( long * sts )
{
  IGRboolean flag;   
  extern IGRint extlocact();
  
  /* 
   * We should not extend SK objects such as SKline, SKcompcurve etc.
   * This action handler will ignore those objects in extlocact function.
   */

  me ->action_handler = (char (*)()) extlocact;
  flag = TRUE;
  me->action_args = (char *)&flag;

  return OM_S_SUCCESS;
}


method isopen ( long * sts )
{
  int status = OM_S_SUCCESS;

    struct GRprops  
                 Properties;


    /*
     *  send by channel
     */
    status = om$send(
                    msg = message GRvg.GRgeomprops(
                        (IGRlong *)sts,
                        &me->ModuleInfo.md_env.matrix_type,
                        me->ModuleInfo.md_env.matrix,
                        &Properties ),
                     p_chanselect = &me->located_chansel );

    if ( !(status & *sts & 1) )
    {
        *sts = MSFAIL;
	goto wrapup;
    }

/*
 *  trc - this was checking phy_closed.  I changed it to 
 *        "closed by definition (class)". why ????????????
 *         changed back to phy_closed.
 */

    if ( Properties.phy_closed )
    {
        *sts = MSFAIL;
    }
    else
    {
        *sts = MSSUCC;
    }
wrapup:
  return OM_S_SUCCESS;
}

method is_physically_open ( long * sts )
{
  int status = OM_S_SUCCESS;

    struct GRprops  
                 Properties;


    /*
     *  send by channel
     */
    status = om$send(
                    msg = message GRvg.GRgeomprops(
                        (IGRlong *)sts,
                        &me->ModuleInfo.md_env.matrix_type,
                        me->ModuleInfo.md_env.matrix,
                        &Properties ),
                     p_chanselect = &me->located_chansel );

    if ( !(status & *sts & 1) )
    {
        *sts = MSFAIL;
	goto wrapup;
    }

    if ( Properties.phy_closed )
    {
        *sts = MSFAIL;
    }
    else
    {
        *sts = MSSUCC;
    }
wrapup:
  return OM_S_SUCCESS;
}


end implementation COnpt;
