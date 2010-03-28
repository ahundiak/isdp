/* #######################    APOGEE COMPILED   ######################## */
/* 
    Name

    IGRlong CO_ni_measure_angle_of_line_and_axis(
                ReturnMsg,
                Events,
                ModuleInfo,
                Angle,
                Units,
                my_id,
                MyChannelStruct,
                ObjectsGrid )

    IGRlong              *ReturnMsg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo[];
    IGRdouble            *Angle;
    IGRchar              *Units;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;
    struct GRid          *ObjectsGrid[];
                                                                               

Abstract
    This function measures the angle between a line and an arbitrary axis
                                                                            
Arguments

    ReturnMsg
        return codes

    Events
        array of pointers to events retrieved by the calling command
        Events[0] - first point defining axis
        Events[1] - second point defining axis
        Events[2] - locate point on line

    ModuleInfo
        context of located object

    Angle
        value of everything that we measure

    Units
        returned by the function, units specify whether distance/angle
        is to be used
    my_id
        object id of calling object, or at least some object

    MyChannelStruct
        pointer to a chanselect structure for located object on channel

    ObjectsGrid
        object to measure

Status returns

    om error codes

History

    dlw 08/19/88 : created from measure angle between two lines

*/




class implementation Root;

#include "coimport.h"
#include "codebug.h"

#include "OMminimum.h"
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
#include "igrmacros.h"
#include "comiscmac.h"
#include "madef.h"
#include "msdef.h"
#include "dp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"


extern IGRboolean MAutoparms();
extern IGRboolean MA2lnisect();
extern IGRboolean MAang3pt();
extern IGRboolean CO_ni_world_to_view();
extern IGRboolean BSdistnct2();

from GRvg      import
		       GRgenabsg;

/*----------------------------------------
 *  CO_ni_measure_angle_of_line_and_axis
 *----------------------------------------
 */
IGRlong CO_ni_measure_angle_of_line_and_axis(
                ReturnMsg,
                Events,
                ModuleInfo,
                Angle,
                Units,
                my_id,
                MyChannelStruct,
                ObjectsGrid )
                                                                               
    IGRlong              *ReturnMsg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo[];
    IGRdouble            *Angle;
    IGRchar              *Units;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;
    struct GRid          *ObjectsGrid[];
                                                                               
{
    IGRlong 
        ReturnStatus,         /* return code */
        BufferSize,
        ReturnSize,
	segnum,
        rc;
    IGRuint NumberObjectsFound; 

    IGRboolean
        BooleanStatus,
        ApparentFlag;

    OM_S_OBJECT_LINKAGE    
        ChannelLinkage[1];

    struct GRid  
	ViewGrid,
        Line;

    IGRdouble
	DummyTparm1,
	DummyTparm2,
	Mangle[3],
	Tolerance = 0.1,
       *p_axis_pt,
       *p_sweep_pt,
	t;

    struct IGRbsp_curve         *bspline_ptr;      

    IGRchar                     *ptr;

    IGRpoint
	SweepPoint1,
	SweepPoint2,
	IsectPoint,
	AxisPoint1,
	AxisPoint2;

    struct IGRline
       SweepLine,
       AxisLine;

   /* ----------------  EV - end of variable declarations  ----------------  */



   _m_debug_str( "> CO_ni_measure_angle_of_line_and_axis" );

   /*
    * ------------------------------------------------------------------------
    *  Step 0: Initiliaze values
    * ------------------------------------------------------------------------
    */

   *ReturnMsg = MSSUCC;

   SweepLine.point1 = SweepPoint1;
   SweepLine.point2 = SweepPoint2;
   AxisLine.point1  = AxisPoint1;
   AxisLine.point2  = AxisPoint2;

   /*
    * ------------------------------------------------------------------------
    *  Step 1: Get the GRid of the line from either the channel or
    *          as passed in the arglist.
    * ------------------------------------------------------------------------
    */

   if ( MyChannelStruct != NULL )  /* extract object from channel */
   {
      _m_debug_str( 
   "  CO_ni_measure_angle_of_line_and_axis: getting line from channel");
      /*
       *  find out who is on my channel
       */
      ReturnStatus = om$get_channel_objects(
                     objid        = my_id,
                     p_chanselect = MyChannelStruct,
                     list         = ChannelLinkage,
                     size         = 1,
                     count        = &NumberObjectsFound );
      _m_check2p( ReturnStatus, *ReturnMsg,
        "  CO_ni_measure_angle_of_line_and_axis: om$get_channel_objects FAILED");
      _m_check2q( ReturnStatus, *ReturnMsg );

      Line.objid = ChannelLinkage[0].S_objid;
      Line.osnum = ChannelLinkage[0].osnum;

   }
   else                            /* grid passed */
   {
      _m_debug_str( 
    "  CO_ni_measure_angle_of_line_and_axis: getting line from objids");
      Line = *ObjectsGrid[0];
   }

   /*
    * -----------------------------------------------------------------
    *  Step 2: Generate the abstract geometry of element 
    * -----------------------------------------------------------------
    */

   ReturnStatus = om$send(msg = message GRvg.GRgenabsg(ReturnMsg,         
                               &ModuleInfo[0]->md_env.matrix_type,
                                ModuleInfo[0]->md_env.matrix,
                               &ptr),
                          targetid = Line.objid,
                          targetos = Line.osnum);

    _m_check2q(ReturnStatus,*ReturnMsg);

    bspline_ptr = (struct IGRbsp_curve *) ptr;
    BooleanStatus = MAutoparms ( ReturnMsg,
			         bspline_ptr,
			        &Events[2]->located_object[0].geom_parms.u,
			        &segnum,
			        &t );

    *Events[3] = *Events[0];
    Events[3]->event.button.x = SweepPoint1[0] = bspline_ptr->poles[segnum*3+0];
    Events[3]->event.button.y = SweepPoint1[1] = bspline_ptr->poles[segnum*3+1];
    Events[3]->event.button.z = SweepPoint1[2] = bspline_ptr->poles[segnum*3+2];

    *Events[4] = *Events[0];
    Events[4]->event.button.x=SweepPoint2[0]=bspline_ptr->poles[(segnum-1)*3+0];
    Events[4]->event.button.y=SweepPoint2[1]=bspline_ptr->poles[(segnum-1)*3+1];
    Events[4]->event.button.z=SweepPoint2[2]=bspline_ptr->poles[(segnum-1)*3+2];

   /*
    * ------------------------------------------------------------------------
    *  Step 3:  Get value of the DPB's apparent flag 
    * ------------------------------------------------------------------------
    */

   gr$get_apparent_flag( msg    =  ReturnMsg,
                         sizbuf = &BufferSize,
                         buffer = &ApparentFlag,
                         nret   = &ReturnSize );
   _m_debug( printf( "ApparentFlag = %s\n", ApparentFlag ? "TRUE" : "FALSE" ) );

   /*
    * ------------------------------------------------------------------------
    *  Step 4: Unpack points from events into sweep and axis line buffers
    *          the way we set up these two lines is dependent upon the 
    *          value of the apparent flag.
    * ------------------------------------------------------------------------
    */

   if ( ApparentFlag )
   {
      ViewGrid.objid = Events[2]->event.button.objid;
      ViewGrid.osnum = Events[2]->event.button.osnum;

      BooleanStatus = CO_ni_world_to_view(  ReturnMsg,
                                            Events[0],
                                           &ViewGrid,
                                            AxisPoint1 );

      ReturnStatus = ( BooleanStatus && ( *ReturnMsg & 1 ) ) ? MSSUCC : MSFAIL;
      _m_checkq( ReturnStatus );

      BooleanStatus = CO_ni_world_to_view(  ReturnMsg,
                                            Events[1],
                                           &ViewGrid,
                                            AxisPoint2 );

      ReturnStatus = ( BooleanStatus && ( *ReturnMsg & 1 ) ) ? MSSUCC : MSFAIL;
      _m_checkq( ReturnStatus );

      BooleanStatus = CO_ni_world_to_view(  ReturnMsg,
                                            Events[3],
                                           &ViewGrid,
                                            SweepPoint1 );

      ReturnStatus = ( BooleanStatus && ( *ReturnMsg & 1 ) ) ? MSSUCC : MSFAIL;
      _m_checkq( ReturnStatus );

      BooleanStatus = CO_ni_world_to_view(  ReturnMsg,
                                            Events[4],
                                           &ViewGrid,
                                            SweepPoint2 );

      ReturnStatus = ( BooleanStatus && ( *ReturnMsg & 1 ) ) ? MSSUCC : MSFAIL;
      _m_checkq( ReturnStatus );

   }
   else
   {
      AxisPoint1[0] = Events[0]->event.button.x;
      AxisPoint1[1] = Events[0]->event.button.y;
      AxisPoint1[2] = Events[0]->event.button.z;

      AxisPoint2[0] = Events[1]->event.button.x;
      AxisPoint2[1] = Events[1]->event.button.y;
      AxisPoint2[2] = Events[1]->event.button.z;
   }

   /*
    * ------------------------------------------------------------------------
    *  Step 5:  find intersection point of two lines
    * ------------------------------------------------------------------------
    */

   BooleanStatus = MA2lnisect( ReturnMsg, 
			      &SweepLine,
			      &AxisLine,
                              &Tolerance,
			       IsectPoint,
			      &DummyTparm1,
			      &DummyTparm2 );
   if ( BooleanStatus )
   {
       if ( *ReturnMsg == MAIDGENRAT )
       {
          /* one line is a point */
          *ReturnMsg = MSFAIL;
          goto quit;
       }
   }
   else if ( *ReturnMsg == MSFAIL )    /* lines parallel */
   {
     *ReturnMsg = MSSUCC;
     *Angle = 0.0;
     goto quit;
   }

   /*
    * ------------------------------------------------------------------------
    *  Step 6:  Get angle between the axis and sweep lines
    * ------------------------------------------------------------------------
    */
   _m_debug_str(
 "  CO_ni_measure_angle_of_2_pts_and_axis: calling MAang3pt to get angle");

   /*  determine if the two points are different based on the base tolerance
    */
   BooleanStatus = BSdistnct2(
                  &rc, 
                   AxisPoint1,
                   IsectPoint );
   if ( rc != 0 )
        goto quit;

   /*  if the points are distinct, use point1 else use point2
    */
   p_axis_pt = ( BooleanStatus ) ? AxisPoint1 : AxisPoint2;


   /*  determine if the two points are different based on the base tolerance
    */
   BooleanStatus = BSdistnct2(
                  &rc, 
                   SweepPoint1,
                   IsectPoint );
   if ( rc != 0 )
        goto quit;


   /*  if the points are distinct, use point1 else use point2
    */
   p_sweep_pt = ( BooleanStatus ) ? SweepPoint1 : SweepPoint2;



   BooleanStatus = MAang3pt( ReturnMsg, 
			     p_axis_pt,
			     IsectPoint,
			     p_sweep_pt,
                             Mangle );
   _m_checkq( *ReturnMsg );
   _m_check_boolq( BooleanStatus ); 

   /* angle is first item in the Mangle array; get 180 compliment */
   *Angle = ( Mangle[0] >= PI ) ? ( Mangle[0] - PI ) : Mangle[0];

   /*
    *  we are measuring angle
    */
   strncpy( Units, GRIO_ANGLE, GRIO_MAX_ALIAS_SIZE );

quit:

   return( ReturnStatus );

}

end implementation Root;
