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

 IGRboolean COproj_pt_to_view_pl(msg,
                                 event,
                                 projected_point)

    IGRlong              *msg;
    struct GRevent       *event;
    IGRdouble            *projected_point;

 Abstract
    This function constructs a bspline representation of a line, then
     constructs and optionally displays a line object.
    If the display_obj is specified, then the object is displayed.
                                                                            
 Arguments

    IGRlong          *msg
       Return msg code
          has value return from the last routine it called; if msg contains
	  an error it is from the first routine that failed


    struct GRevent   *event
        event containing the data point to be projected onto the plane 
	which is specified in its event->event.button structure
        

    IGRdouble            *projected_point
	points to an array of 3 doubles and on return it contains the
	result of the event's point projected onto the events view.


 Status returns
    IGRboolean   
       TRUE 
       FALSE
                                                                            
 Caveats
    May not specify an object space.  The object space will be the
    same object space as the module's object space.

 History
    ??/??/??   ???  - created  ( Tom Corbin I think )
    01/07/87   srh  - fixed bug where the wrong point on plane was being
		      used.


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
#include "madef.h"
#include "msdef.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "OMprimitives.h"


from IGEgragad  import DPinrot;

IGRboolean COproj_pt_to_view_pl(msg,
                                event,
                                projected_point)

    IGRlong              *msg;
    struct GRevent       *event;
    IGRdouble            *projected_point;
{
    IGRlong                      status;         
    IGRmatrix                    rot_matrix;     
    struct IGRplane              view_plane;
    IGRpoint                     point_on_plane;
    IGRpoint                     point_from_event;
    IGRlong                      which_err;
    IGRlong                       return_size;
    IGRboolean                   b_status;
    IGRvector                    normal_vector;
    struct var_list              var_list[2];
    extern    IGRboolean    MAptplproj();

    /* EV */



    b_status = TRUE;

    /* 
     *  set up buffers for view_plane struct
     */
    view_plane.point  = &point_on_plane[0];
    view_plane.normal = &normal_vector[0];

    point_from_event[0] = event->event.button.x;
    point_from_event[1] = event->event.button.y;
    point_from_event[2] = event->event.button.z;

    /* 
     *  load normal vector from the rotation matrix Z vector
     */
    status = om$send(msg = message IGEgragad.DPinrot(msg,
                                                     rot_matrix ),
                     senderid = NULL_OBJID,
                     targetid = event->event.button.objid,
                     targetos = event->event.button.osnum );
    _m_check( *msg, b_status = FALSE );
    _m_checkq(*msg);

    /* Z vector is in 3rd row of rotation matrix */
    normal_vector[0] = rot_matrix[8];
    normal_vector[1] = rot_matrix[9];
    normal_vector[2] = rot_matrix[10];

    /*
     *  load the view origin as the point on the view plane 
     */
    var_list[0].var = VIEW_ORIGIN;
    var_list[0].var_ptr = (IGRchar *)point_on_plane;
    var_list[0].num_bytes = 3 * sizeof( IGRdouble );
    var_list[0].bytes_returned = &return_size;
    var_list[1].var = END_PARAM;
    
    dp$inq_set_gragad(msg          = msg,
                      osnum        = event->event.button.osnum,
                      gragad_objid = event->event.button.objid,
                      which_error  = &which_err,
                      var_list     = var_list );
    _m_checkq(*msg);

    /* project point onto view plane */
    b_status = MAptplproj( msg,
                           point_from_event,
                          &view_plane,           
                           projected_point);

quit:
    return( b_status );
}



/*

 CO_ni_world_to_view()

 Abstract:
    This routine takes an data point event and a view GRid and returns a 
    View coordinate projected onto that view's X/Y plane.

 Arguments:

    IGRlong          *ReturnMsg;
        return code
	   MSSUCC - always succeeds

    struct GRevent   * Event
          Events[0] -  data point event containing world coordinates
    
    struct GRid      * ViewGrid
	Grid of gragad to which the world coordinate is translated

    IGRpoint           ViewPoint
	  View coordinate returned.



 Example call

    CO_ni_world_to_view(&msg,
		        &Event,
		        &ViewGrid,
			 ViewPt);

 Returns:  
    IGRboolean
       TRUE
       FALSE

 Caveats:

 History:
     
    srh  02/02/89  -  Created;
                         
 */

/*   EH -  End of Header  */
/*
 *----------------------------------------
 *  CO_ni_world_to_view()
 *----------------------------------------
 */
IGRboolean CO_ni_world_to_view( ReturnMsg,
                                Event,
                                ViewGrid,
			        ViewPoint )

    IGRlong              *ReturnMsg;
    struct GRevent       *Event;
    struct GRid          *ViewGrid;
    IGRpoint              ViewPoint;
{

/* BV - BEGINNING OF VARIABLE LIST */

    IGRboolean 
               BooleanStatus = TRUE;

    IGRlong  
               ReturnSize;

    IGRlong
               ReturnStatus = MSSUCC,
               WhichError,
               NumberOfPoints = 1;

    IGRmatrix
               WorldToView;

    IGRpoint 
	       WorldPoint;

    struct var_list 
               VariableList[4];

    extern IGRboolean MAptsxform();

/* EV - END OF VARIABLE LIST */



    _m_debug_str( "CO_ni_world_to_view>" );

    *ReturnMsg = MSSUCC;

    /* 
     * ----------------------------------------------------------------------
     *  Step 1:  Get view rotation matrix WorldToView 
     * -----------------------------------------------------------------------
     */
    VariableList[0].var            =  WLD_TO_VIEW;
    VariableList[0].var_ptr        =  (IGRchar *)WorldToView;
    VariableList[0].num_bytes      =  sizeof( WorldToView );
    VariableList[0].bytes_returned = &ReturnSize;
    VariableList[1].var            =  END_PARAM;

    _m_debug_str( "CO_ni_world_to_view: calling dp$inq_set_gragad()" );
    ReturnStatus = dp$inq_set_gragad( msg          =  ReturnMsg,
                                      osnum        =  ViewGrid->osnum,
                                      gragad_objid =  ViewGrid->objid,
                                      which_error  = &WhichError,
                                      var_list     =  VariableList );
            
    _m_check2p ( ReturnStatus, *ReturnMsg,
       " CO_ni_world_to_view:  dp$inq_set_gragad failed");
    _m_check2q ( ReturnStatus, *ReturnMsg );
     
    /* 
     * ----------------------------------------------------------------------
     *  Step 2:  transform world point into the view's  coord sys
     * ----------------------------------------------------------------------
     */
     WorldPoint[0] = Event->event.button.x;
     WorldPoint[1] = Event->event.button.y;
     WorldPoint[2] = Event->event.button.z;

     BooleanStatus = MAptsxform(  ReturnMsg,
                                 &NumberOfPoints,
                                  WorldToView,
                                  WorldPoint,
                                  ViewPoint );
           
     if( ( ! BooleanStatus ) || ( ! ( *ReturnMsg & 1 ) ) )
     {
        printf( "CO_ni_world_to_view: MAptsxform FAILED!\n" );
        printf( "     status = 0x%x\n", BooleanStatus );
        printf( "     msg    = 0x%x\n", *ReturnMsg );
     }

     /*
      *   Project ViewPoint onto the vieiw's X/Y Plane;  NOTE!  the
      *   ViewPoint's X and Y coordinates are already correct due to
      *   the above Xformation.  All we have to do to project it onto
      *   the view plane is zero out the Z coordinates (thanks, RD! ).
      */

     ViewPoint[2] = 0.0;

quit:

    _m_debug_str( "< CO_ni_world_to_view" );
    return( BooleanStatus );
}










end implementation Root;
