/* #######################    APOGEE COMPILED   ######################## */
/*
   CO_ni_line_at_minimum_distance()

 Abstract
   This function constructs a GRlineseg object ( line segment ) which 
   is of minimum length between two specified objects.

 Arguments

    IGRlong           *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the from point
        event[1] is the to point

    struct GRmd_env   *module
        context of located object

    GRobjid           CobID
        object id of calling object, or at least some object

    GRspacenum        CobOS
        object space number of calling object, or at least some object

    struct GRid       *display_obj
        id of object to display located object

 Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

 History
    srh 06/22/87 :  created 
    srh 11/03/87 :  accomodated new arguments in GR2objminline to support 
		    TRUE/APPARENT flag and Local/Abs flag
    srh 05/23/89 : removed GRIS_ properties from construct list 

 */

/*  EH - end of header */


class implementation Root;


#include "coimport.h"
#include "codebug.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "comiscmac.h"
#include "msdef.h"
#include "dp.h"
#include "maerr.h"
#include "codef.h"
#include "igrmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"


from IGEgragad  import DPinrot;


IGRlong  CO_ni_line_at_minimum_distance( ReturnMsg,
                                         Events,
                                         ConstructInfo,
                                         NewFlag,
                                         ActiveDisplay,
                                         ActiveLevel,
                                         Attributes,
                                         Name,
                                         LineSegmentGrid,
                                         ClassName,
                                         ClassID,
                                         Neighbor,
                                         CobID,
                                         CobOS,
                                         p_co_chanselect,
                                         co_index,
                                         LocateDisplayMode,
                                         ConstructDisplayMode,
                                         DisplayGrid,
                                         ModuleInfo,
                                         ObjectsGrid )

    IGRlong              *ReturnMsg;
    struct GRevent       *Events[];
    struct GRmd_env      *ConstructInfo;
    IGRboolean            NewFlag;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort             *ActiveLevel;
    IGRchar              *Attributes;
    IGRchar              *Name;
    struct GRid          *LineSegmentGrid;
    IGRchar              *ClassName;
    GRclassid             ClassID;
    OM_S_NEIGHBOR         Neighbor;
    OM_S_OBJID            CobID;
    GRspacenum            CobOS;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                co_index;
    enum GRdpmode         LocateDisplayMode;
    enum GRdpmode         ConstructDisplayMode;
    struct GRid          *DisplayGrid;
    struct GRmd_env      *ModuleInfo[];
    struct GRid          *ObjectsGrid[];

{
    /*  BV  - beginning of local variables  */

    IGRboolean
                BooleanStatus,   /* boolean return code              */
                AbsoluteFlag,    /* local line flag for linear cases */ 
                ApparentFlag;    /* flag for apparent line           */

    IGRlong
                ReturnStatus = OM_S_SUCCESS,  /* status returned           */
		Size = sizeof( IGRboolean ),  /* for gr$get_apparent_flag  */
		ReturnSize;                   /* for gr$get_apparent_flag  */

    IGRpoint       
                Point1,       /* the 2 points determining the line */
                Point2,
                ProjectPoint, 
                PointOnPlane; /* origin of view */

    IGRvector
                ViewVector;         /* vector normal to plane of app line  */

    struct IGRline 
                MinDistLine;         /* minimum distance line endpoints   */

    struct GRparms 
                Parms1,
                Parms2;

    GRls_declare( LineSegment, PoleKnotBuffer );

    /*  EV - end of local variables  */

    _m_debug_str( "> CO_ni_line_at_minimum_distance" );
    /*
     *  -------------------------------------------------------------------
     *   Step 0:  Asign bspline and line buffers 
     *  -------------------------------------------------------------------
     */
    GRls_init( LineSegment, PoleKnotBuffer );

    MinDistLine.point1 = Point1;
    MinDistLine.point2 = Point2;

    *ReturnMsg = OM_S_SUCCESS;
    /*
     *  -------------------------------------------------------------------
     *   Step 1: Project the Locate event of first element onto the 
     *           first element;
     *  -------------------------------------------------------------------
     */

    _m_debug_str( 
       "CO_ni_line_at_minimum_distance: calling first co$project_event()" );
    ReturnStatus = co$project_event( msg    =  ReturnMsg,
                                     event  =  Events[0],
                                     module =  ModuleInfo[0],
                                     cob_id =  CobID,
                                     grid   =  ObjectsGrid[0],
                                     parms  = &Parms1 );
 
    _m_check2p( ReturnStatus,  *ReturnMsg,
       "CO_ni_line_at_minimum_distance: first co$project_event FAILED" );
    _m_check2q( ReturnStatus, *ReturnMsg );

    /*
     *  -------------------------------------------------------------------
     *   Step 2: Project the Accept event of second element onto the 
     *           second element;
     *  -------------------------------------------------------------------
     */

    _m_debug_str(
       "CO_ni_line_at_minimum_distance: calling second co$project_event()" );
    ReturnStatus = co$project_event( msg    =  ReturnMsg,
                                     event  =  Events[1],
                                     module =  ModuleInfo[1],
                                     cob_id =  CobID,
                                     grid   =  ObjectsGrid[1],
                                     parms  = &Parms2,
                                     point  =  ProjectPoint );
 
    _m_check2p( ReturnStatus,  *ReturnMsg,
       "CO_ni_line_at_minimum_distance: second co$project_event FAILED");
    _m_check2q( ReturnStatus, *ReturnMsg );

    /*
     *  -------------------------------------------------------------------
     *   Step 3:  Get endpoints of the line at minimum distance between the
     *            two elements
     *  -------------------------------------------------------------------
     */

#ifndef IDRAW

    gr$get_apparent_flag( msg    =  ReturnMsg,
                          sizbuf = &Size,
                          buffer = &ApparentFlag,
                          nret   = &ReturnSize );
    _m_checkp( *ReturnMsg, 
       "CO_ni_line_at_minimum_distance:  gr$get_apparent_flag() FAILED" );
    _m_checkq( *ReturnMsg );


    gr$get_local_abs_flag( msg    =  ReturnMsg,
                           sizbuf = &Size,
                           buffer = &AbsoluteFlag,
                           nret   = &ReturnSize );
    _m_checkp( *ReturnMsg, 
       "CO_ni_line_at_minimum_distance:  gr$get_local_abs_flag() FAILED" );
    _m_checkq( *ReturnMsg );

    if( ApparentFlag )
    {
	   
       /*
        *  If we are to construct the line apparent to the view ( as apposed to
        *  true ), then we need to assign pertanent values to PointOnPlane and 
        *  ViewVector; the view matrix from the ModuleInfo of the first object
        *  will be used; it has the following form:
        *
        *         X . . 0           ^  ^  ^
        *         Y . . 0     where X, Y, Z are the X, Y, and Z vectors
        *         Z . . 0     of the view.  
        *         0 0 0 0
        *
        *
        *  If we are to construct the line TRUE ( not apparent ), then the 
        *  values of PointOnPlane and ViewVector are no significant.
        */

       IGRmatrix 
		  RotationMatrix;   /* World to View matrix */

       BooleanStatus = COproj_pt_to_view_pl( ReturnMsg, 
					     Events[0], 
					     PointOnPlane );

       if ( ( ! BooleanStatus ) || (! (*ReturnMsg & 1) ) )
       {
          _m_debug_str( 
	     "CO_ni_line_at_minimum_distance: COproj_pt_to_view_pl FAILED" ); 
          _m_debug( 
	     printf( "    b_status = %s\n", BooleanStatus ? "TRUE" : "FALSE") );
          _m_debug( printf( "    msg = 0x%x\n", *ReturnMsg ) );
          _m_debug( om$report_error( sts = *ReturnMsg ) );
          goto quit;
       }
    
       ReturnStatus = om$send( senderid = NULL_OBJID,

		               msg      = message IGEgragad.DPinrot(
				             ReturnMsg,
				             RotationMatrix ),

                               targetid = Events[0]->event.button.objid,
                               targetos = Events[0]->event.button.osnum );

       _m_check2p( ReturnStatus, *ReturnMsg,
          "CO_ni_line_at_minimum_distance:  IGEgragad.DPinrot FAILED" );

       _m_check2q( ReturnStatus, *ReturnMsg );

       /*  world to view */
       ViewVector[0] =  RotationMatrix[8];
       ViewVector[1] =  RotationMatrix[9];
       ViewVector[2] =  RotationMatrix[10];
     }

     _m_debug( 
	printf( "CO_ni_line_at_minimum_distance: AbsoluteFlag is set to %s\n", 
                AbsoluteFlag ? "Absolute" : "Local" ) );
     _m_debug( 
	printf( "CO_ni_line_at_minimum_distance: apparent projection is %s\n", 
                ApparentFlag ? "ON" : "OFF" ) );

    _m_debug_str( "CO_ni_line_at_minimum_distance: calling GR2objminline()" );

#else  /* if IDRAW set flags to indicate not apparent and local */

    AbsoluteFlag = 0;
    ApparentFlag = 0;

#endif /* IDRAW */

    /* GR2objminline expects Absolute=FALSE and Local=TRUE */
    /* This is opposite to the dpb */
    AbsoluteFlag = ! AbsoluteFlag;

    BooleanStatus = GR2objminline(  ReturnMsg, 
                                    ObjectsGrid[0],
                                   &ModuleInfo[0]->md_env, 
                                   &Parms1,
                                    ObjectsGrid[1],
                                   &ModuleInfo[1]->md_env,
                                   &Parms2,
                                   &AbsoluteFlag,
                                   &ApparentFlag,
                                    PointOnPlane,
                                    ViewVector,
                                    ProjectPoint,
                                   &MinDistLine );

    if ( ( ! BooleanStatus ) || (! (*ReturnMsg & 1) ) )
    {
       _m_debug_str( "CO_ni_line_at_minimum_distance: GR2objminline FAILED" ); 
       _m_debug( printf( "    b_status = %d\n", BooleanStatus ) );
       _m_debug( printf( "    msg = 0x%x\n", *ReturnMsg ) );
       _m_debug( om$report_error( sts = *ReturnMsg ) );
       goto quit;
    }
    else
    {
       /*
        *  -------------------------------------------------------------------
        *   Step  : Get bspline geometry of line to be constructed given its
        *           two endpoints
        *  -------------------------------------------------------------------
        */

       _m_debug_str( "CO_ni_line_at_minimum_distance: calling MA2pttobc()" );
       BooleanStatus = MA2pttobc(  ReturnMsg,
                                   MinDistLine.point1,
                                   MinDistLine.point2,
                                  &LineSegment );

       if ( ( ! BooleanStatus ) || (! (*ReturnMsg & 1) ) )
       {
          _m_debug_str( "CO_ni_line_at_minimum_distance: MA2pttobc FAILED" ); 
          _m_debug( printf( "      b_status = %d\n", BooleanStatus ) );
          _m_debug( printf( "      msg      = 0x%x\n", *ReturnMsg ) );
          goto quit;
       }

      /*
       * verify a valid curve was generated
       */
      ReturnStatus = COcheck_curve( ReturnMsg, &LineSegment );
      _m_checkq(ReturnStatus);
      
       /*
        *  -------------------------------------------------------------------
        *   Step  :  construct the line at minimum distance
        *  -------------------------------------------------------------------
        */
       _m_debug_str( "CO_ni_line_at_minimum_distance: calling co$construct" );
       if ( ClassName != NULL )
       {
           /* classname is specified */
           ReturnStatus = co$construct_object(
                           msg          =  ReturnMsg,
                           mode         = &ConstructDisplayMode,
                           module       =  ConstructInfo,
                           newflag      =  NewFlag,
                           properties   =  0,
                           geometry     = &LineSegment,
                           symbology    =  ActiveDisplay,
                           level        =  ActiveLevel,
                           attr         =  Attributes,
                           name         =  Name,
                           grid         =  LineSegmentGrid,
                           display_obj  =  DisplayGrid,
                           neighbor     =  Neighbor,
                           cob_id       =  CobID,
                           cob_os       =  CobOS,
                           p_co_chansel =  p_co_chanselect,
                           co_index     =  co_index,
                           classname    =  ClassName );
                                                                               
       }
       else /* classid is specified */
       {
           ReturnStatus = co$construct_object(
                           msg          =  ReturnMsg,
                           mode         = &ConstructDisplayMode,
                           module       =  ConstructInfo,
                           newflag      =  NewFlag,
                           properties   =  0,
                           geometry     = &LineSegment,
                           symbology    =  ActiveDisplay,
                           level        =  ActiveLevel,
                           attr         =  Attributes,
                           name         =  Name,
                           grid         =  LineSegmentGrid,
                           display_obj  =  DisplayGrid,
                           neighbor     =  Neighbor,
                           cob_id       =  CobID,
                           cob_os       =  CobOS,
                           p_co_chansel =  p_co_chanselect,
                           co_index     =  co_index,
                           classid      =  ClassID );
       }

       _m_check2p( 
	  ReturnStatus,
	  *ReturnMsg,
          "CO_ni_line_at_minimum_distance: co$construct FAILED" );
    }

quit:

   return( ReturnStatus );

} /*  end  of CO_ni_line_at_minimum_distance  */

end implementation Root;
