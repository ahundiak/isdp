/* #######################    APOGEE COMPILED   ######################## */
/* 
    Name

    IGRlong CO_ni_measure_angle_of_2_pts_and_axis(
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
    This function measures the angle between 2 points and an arbitrary axis
                                                                            
Arguments

    ReturnMsg
        return codes

    Events
        array of pointers to events retrieved by the calling command
        Events[0] - first point
        Events[1] - second point
        Events[2] - first point defining axis
        Events[3] - second point defining axis

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

    dlw 08/20/88 : created from measure angle between two lines

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


extern IGRboolean MAang3pt();
extern IGRboolean MA2lnisect();
extern IGRboolean BSdistnct2();

/*
 * ----------------------------------------
 *  CO_ni_measure_angle_of_2_pts_and_axis
 * ----------------------------------------
 */
IGRlong CO_ni_measure_angle_of_2_pts_and_axis(
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
        ReturnStatus = MSSUCC,                      /* return code  */
        BufferSize = sizeof( IGRboolean ),
        ReturnSize,
        rc;

    IGRboolean
        BooleanStatus,
        ApparentFlag;

    IGRdouble  
	DummyTparm1,
	DummyTparm2,
	Tolerance = 0.1,
        Mangle[3],
       *p_axis_pt,
       *p_sweep_pt;

    struct IGRline
       SweepLine,
       AxisLine;

    IGRpoint
       SweepPoint1,
       SweepPoint2,
       AxisPoint1,
       AxisPoint2,
       IsectPoint;

   /* ----------------  EV - end of variable declarations  ----------------  */



   _m_debug_str( "> CO_ni_measure_angle_of_2_pts_and_axis" );

   /*
    * ------------------------------------------------------------------------
    *  Step 0: Initilize values
    * ------------------------------------------------------------------------
    */
   *ReturnMsg = MSSUCC;

   SweepLine.point1 = SweepPoint1;
   SweepLine.point2 = SweepPoint2;
   AxisLine.point1  = AxisPoint1;
   AxisLine.point2  = AxisPoint2;

   /*
    * ------------------------------------------------------------------------
    *  Step 1:  Get value of the DPB's apparent flag 
    * ------------------------------------------------------------------------
    */
   gr$get_apparent_flag( msg    =  ReturnMsg,
                         sizbuf = &BufferSize,
                         buffer = &ApparentFlag,
                         nret   = &ReturnSize );
   _m_debug( printf( "ApparentFlag = %s\n", ApparentFlag ? "TRUE" : "FALSE" ) );

   /*
    * ------------------------------------------------------------------------
    *  Step 1: unpack points from events into sweep and axis line buffers
    *          the way we set up these two lines is dependent upon the 
    *          value of the apparent flag.
    * ------------------------------------------------------------------------
    */

   if ( ApparentFlag )
   {
      struct GRid ViewGrid;
      
      ViewGrid.objid = Events[3]->event.button.objid;
      ViewGrid.osnum = Events[3]->event.button.osnum;

      BooleanStatus = CO_ni_world_to_view(  ReturnMsg,
                                            Events[2],
                                           &ViewGrid,
                                            SweepPoint1 );

      ReturnStatus = ( BooleanStatus ) ? MSSUCC : MSFAIL ;
      _m_checkq( ReturnStatus );


      BooleanStatus = CO_ni_world_to_view(  ReturnMsg,
                                            Events[3],
                                           &ViewGrid,
                                            SweepPoint2 );

      ReturnStatus = ( BooleanStatus ) ? MSSUCC : MSFAIL ;
      _m_checkq( ReturnStatus );


      BooleanStatus = CO_ni_world_to_view(  ReturnMsg,
                                            Events[0],
                                           &ViewGrid,
                                            AxisPoint1 );

      ReturnStatus = ( BooleanStatus ) ? MSSUCC : MSFAIL ;
      _m_checkq( ReturnStatus );


      BooleanStatus = CO_ni_world_to_view(  ReturnMsg,
                                            Events[1],
                                           &ViewGrid,
                                            AxisPoint2 );

      ReturnStatus = ( BooleanStatus ) ? MSSUCC : MSFAIL ;
      _m_checkq( ReturnStatus );

   }
   else
   {
      /* true points */

      SweepPoint1[0] = Events[2]->event.button.x;
      SweepPoint1[1] = Events[2]->event.button.y;
      SweepPoint1[2] = Events[2]->event.button.z;

      SweepPoint2[0] = Events[3]->event.button.x;
      SweepPoint2[1] = Events[3]->event.button.y;
      SweepPoint2[2] = Events[3]->event.button.z;

      AxisPoint1[0] = Events[0]->event.button.x;
      AxisPoint1[1] = Events[0]->event.button.y;
      AxisPoint1[2] = Events[0]->event.button.z;

      AxisPoint2[0] = Events[1]->event.button.x;
      AxisPoint2[1] = Events[1]->event.button.y;
      AxisPoint2[2] = Events[1]->event.button.z;
   }

   /*
    * ------------------------------------------------------------------------
    *  Step 2:  find intersection point of two lines
    * ------------------------------------------------------------------------
    */
   Tolerance = 0.1; /* arbitrary */
   BooleanStatus = MA2lnisect( ReturnMsg, 
			      &SweepLine,
			      &AxisLine,
                              &Tolerance,
			       IsectPoint,
			      &DummyTparm1,
			      &DummyTparm2 );
   if ( *ReturnMsg == MSFAIL || *ReturnMsg == MAIDGENRAT )
   {
      /* no isect point found  or one line is a point */
      *ReturnMsg = MSFAIL;
      goto quit;
   }
   else if ( *ReturnMsg == MAINFSOLUTION )    /* lines parallel */
   {
     *ReturnMsg = MSSUCC;
     *Angle = 0.0;
     goto quit;
   }

   /*
    * ------------------------------------------------------------------------
    *  Step 3:  Get angle between the axis and sweep lines
    * ------------------------------------------------------------------------
    */
   _m_debug_str(
 "  CO_ni_measure_angle_of_2_pts_and_axis: calling MAang2ln to get angle");


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
   ReturnStatus = ( BooleanStatus ) ? MSSUCC : MSFAIL ;
   _m_check2q( ReturnStatus, *ReturnMsg );

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
