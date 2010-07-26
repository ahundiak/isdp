/* #######################    APOGEE COMPILED   ######################## */
/*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/* 
    Name

    IGRlong CO_ni_measure_angle_between_2_lines(
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
    This function measures the angle_between_2_lines of an element
                                                                            
Arguments

    ReturnMsg
        return codes

    Events
        array of pointers to events retrieved by the calling command
        Events[0] - locate point or second element
        Events[1] - 
        Events[2] - 
        Events[3] - 

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
        pointer to a chaselect structure for located object on channel

    ObjectsGrid
        object to measure

Status returns

    om error codes

History

    bmr 05/13/87 : created
    srh 11/18/87 : added apparent measurement capabilities

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
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"


extern IGRboolean MAutoparms();
extern IGRboolean MA2lnisect();
extern IGRboolean MAang3pt();
extern IGRboolean BSdistnct2();
extern IGRboolean CO_ni_world_to_view();

from GRvg      import
		       GRgenabsg;

/*----------------------------------------
 *  CO_ni_measure_angle_between_2_lines
 *----------------------------------------
 */
IGRlong CO_ni_measure_angle_between_2_lines(
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
        ReturnStatus = MSSUCC,         /* return code              */
        BufferSize,
        ReturnSize,
	segnum,
        rc;

        IGRuint NumberObjectsFound;
    IGRboolean
        BooleanStatus,
        ApparentFlag;

    OM_S_OBJECT_LINKAGE    
        ChannelLinkage[2];

    struct GRid  
        Line1,
        Line2;

    IGRdouble
	DummyTparm1,
	DummyTparm2,
	Mangle[3],
	Tolerance = 0.00001,    /* 06/26/89 - from 0.1 */
       *p_axis_pt,
       *p_sweep_pt,
        t;

    IGRpoint 
        SweepPoint1,    /*  start point on the curve          */
        SweepPoint2,    /*  start point on the curve          */
        AxisPoint1,     /*  vertex point of the curve         */
        AxisPoint2,     /*  end point on the curve            */
        IsectPoint;     /*  intersect point                   */
       

    struct IGRbsp_curve         *bspline_ptr;      

    IGRchar                     *ptr;
                                

    struct IGRline
       SweepLine,
       AxisLine;

   /* ----------------  EV - end of variable declarations  ----------------  */



   _m_debug_str( "> CO_ni_measure_angle_between_2_lines" );

   /*
    * ------------------------------------------------------------------------
    *  Step 0: Initilaize values
    * ------------------------------------------------------------------------
    */
   *ReturnMsg = MSSUCC;

   SweepLine.point1 = SweepPoint1;
   SweepLine.point2 = SweepPoint2;
   AxisLine.point1  = AxisPoint1;
   AxisLine.point2  = AxisPoint2;

   /*
    * ------------------------------------------------------------------------
    *  Step 1: Get the GRids of the objects to be measured either from the 
    *          channel or as passed in the arglist.
    * ------------------------------------------------------------------------
    */
   if ( MyChannelStruct != NULL )  /* extract object from channel */
   {
      _m_debug_str( 
         "  CO_ni_measure_angle_between_2_lines: getting objects from channel");

      /*
       *  find out who is on my channel
       */
      ReturnStatus = om$get_channel_objects(
                       objid        = my_id,
                       p_chanselect = MyChannelStruct,
                       list         = ChannelLinkage,
                       size         = 2,
                       count        = &NumberObjectsFound );
      _m_check2p( ReturnStatus, *ReturnMsg,
        "  CO_ni_measure_angle_between_2_lines: om$get_channel_objects FAILED");
      _m_check2q( ReturnStatus, *ReturnMsg );

      Line1.objid = ChannelLinkage[0].S_objid;
      Line1.osnum = ChannelLinkage[0].osnum;

      Line2.objid = ChannelLinkage[1].S_objid;
      Line2.osnum = ChannelLinkage[1].osnum;

   }
   else                            /* gridassed */
   {
      _m_debug_str( 
         "  CO_ni_measure_angle_between_2_lines: getting objects from objids");
      Line1 = *ObjectsGrid[0];
      Line2 = *ObjectsGrid[1];
   }

   /*
    * -----------------------------------------------------------------
    *  Step 2: Generate the abstract geometry of elements so that the
    *          end points of the lines can be used to generate vectors
    * -----------------------------------------------------------------
    */

   ReturnStatus = om$send( msg = message GRvg.GRgenabsg(
                                            ReturnMsg,         
                                           &ModuleInfo[0]->md_env.matrix_type,
                                            ModuleInfo[0]->md_env.matrix,
                                           &ptr),
                          targetid = Line1.objid,
                          targetos = Line1.osnum );

   _m_check2q(ReturnStatus,*ReturnMsg);

   bspline_ptr = (struct IGRbsp_curve *) ptr;
   BooleanStatus = MAutoparms ( ReturnMsg,
			        bspline_ptr,
			       &Events[0]->located_object[0].geom_parms.u,
			       &segnum,
			       &t );

    
   *Events[2] = *Events[0];
   Events[2]->event.button.x = SweepPoint1[0] = bspline_ptr->poles[segnum*3+0];
   Events[2]->event.button.y = SweepPoint1[1] = bspline_ptr->poles[segnum*3+1];
   Events[2]->event.button.z = SweepPoint1[2] = bspline_ptr->poles[segnum*3+2];

   *Events[3] = *Events[0];
   Events[3]->event.button.x=SweepPoint2[0]=bspline_ptr->poles[(segnum-1)*3+0];
   Events[3]->event.button.y=SweepPoint2[1]=bspline_ptr->poles[(segnum-1)*3+1];
   Events[3]->event.button.z=SweepPoint2[2]=bspline_ptr->poles[(segnum-1)*3+2];

   ReturnStatus = om$send( msg = message GRvg.GRgenabsg(
                                            ReturnMsg,         
                                           &ModuleInfo[2]->md_env.matrix_type,
                                            ModuleInfo[2]->md_env.matrix,
                                           &ptr),
                          targetid = Line2.objid,
                          targetos = Line2.osnum );

   _m_check2q(ReturnStatus,*ReturnMsg);

    bspline_ptr = (struct IGRbsp_curve *) ptr;
    BooleanStatus = MAutoparms ( ReturnMsg,
			         bspline_ptr,
			        &Events[1]->located_object[0].geom_parms.u,
			        &segnum,
			        &t );

   *Events[4] = *Events[0];
   Events[4]->event.button.x = AxisPoint1[0] = bspline_ptr->poles[segnum*3+0];
   Events[4]->event.button.y = AxisPoint1[1] = bspline_ptr->poles[segnum*3+1];
   Events[4]->event.button.z = AxisPoint1[2] = bspline_ptr->poles[segnum*3+2];

   *Events[5] = *Events[0];
   Events[5]->event.button.x=AxisPoint2[0]=bspline_ptr->poles[(segnum-1)*3+0];
   Events[5]->event.button.y=AxisPoint2[1]=bspline_ptr->poles[(segnum-1)*3+1];
   Events[5]->event.button.z=AxisPoint2[2]=bspline_ptr->poles[(segnum-1)*3+2];


   _m_check2p( ReturnStatus, *ReturnMsg,
      "  CO_ni_measure_angle_between_2_lines: om$get_channel_objects FAILED");
   _m_check2q( ReturnStatus, *ReturnMsg );

   /*
    * ------------------------------------------------------------------------
    *  Step 3:  Get value of the DPB's apparent flag 
    * ------------------------------------------------------------------------
    */
   BufferSize = sizeof(ApparentFlag);
   gr$get_apparent_flag( msg    =  ReturnMsg,
                         sizbuf = &BufferSize,
                         buffer = &ApparentFlag,
                         nret   = &ReturnSize );  
   _m_debug( printf( "ApparentFlag = %s\n", ApparentFlag ? "TRUE" : "FALSE" ) );


   /*
    * ------------------------------------------------------------------------
    *  Step 4:  If the apparent flag is set, then project the three points 
    *           onto the view plane where the first line was located
    * ------------------------------------------------------------------------
    */

   if( ApparentFlag )
   {
      struct GRid   ViewGrid;
      
      ViewGrid.objid =  Events[0]->event.button.objid;
      ViewGrid.osnum =  Events[0]->event.button.osnum;

      BooleanStatus = CO_ni_world_to_view(  ReturnMsg,
                                            Events[2],
                                           &ViewGrid,
                                            SweepPoint1 );

      ReturnStatus = ( BooleanStatus && ( *ReturnMsg & 1 ) ) ? MSSUCC : MSFAIL;
      _m_checkq( ReturnStatus );


      BooleanStatus = CO_ni_world_to_view(  ReturnMsg,
                                            Events[3],
                                           &ViewGrid,
                                            SweepPoint2 );

      ReturnStatus = ( BooleanStatus && ( *ReturnMsg & 1 ) ) ? MSSUCC : MSFAIL;
      _m_checkq( ReturnStatus );


      BooleanStatus = CO_ni_world_to_view(  ReturnMsg,
                                            Events[4],
                                           &ViewGrid,
                                            AxisPoint1 );

      ReturnStatus = ( BooleanStatus && ( *ReturnMsg & 1 ) ) ? MSSUCC : MSFAIL;
      _m_checkq( ReturnStatus );


      BooleanStatus = CO_ni_world_to_view(  ReturnMsg,
                                            Events[5],
                                           &ViewGrid,
                                            AxisPoint2 );

      ReturnStatus = ( BooleanStatus && ( *ReturnMsg & 1 ) ) ? MSSUCC : MSFAIL;
      _m_checkq( ReturnStatus );

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

   /* 
    *  06/26/89 - srh
    *    For some reason unknown to me, MAINFSOLUTIONS is 'information'
    *    and not a warning or error.  In this case, it means that the
    *    two lines are coincident within tollerance.  We thus interpret
    *    this to means that the angle measured is ZERO radians.
    */
   if ( BooleanStatus && ( *ReturnMsg != MAINFSOLUTION ) )
   {
      if ( *ReturnMsg == MAIDGENRAT )
      {
         /* one line is a point */
         *ReturnMsg = MSFAIL;
         goto quit;
      }
   }
   else if ( *ReturnMsg == MSFAIL || *ReturnMsg == MAINFSOLUTION ) 
   {
      /*   
       *  lines parallel or coincident within tollerance 
       */
      *ReturnMsg = MSSUCC;
      *Angle = 0.0;
      goto quit;
   }

   /*
    * ------------------------------------------------------------------------
    *  Step 6:  Calculate the angle between the three points
    * ------------------------------------------------------------------------
    */


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

   *Angle = ( Mangle[0] >= PI ) ? ( Mangle[0] - PI ) : Mangle[0];

quit:

   return( ReturnStatus );

}

end implementation Root;
