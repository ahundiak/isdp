/* #######################    APOGEE COMPILED   ######################## */
/*

 COline_at_angle_in_view()

 Abstract:
        This function produces the abstract geometry of a Line Segment at 
        a specified angle with respect to view.

        The data point in Events[0] is one end point of the line segment.
        The data point in Events[1] is first projected onto the view plane 
        of the window defined in Events[0]; the result is then projected
        onto the vector defined by the first point, the view plane and the
        specified angle ( Angle ).  This projected point defines the second 
        end point of the line whose geometry is returned.

 Arguments:

        ReturnMsg          * IGRlong

             return code:  MSSUCC
                           MSFAIL

        Events[]           * struct GRevent       - 

             Event array of information needed to calculate abstract geometry
             of the line segment

               Events[0] - Type DATA; fixed endpoint of the line segment 
                           with view information used for determining the
                           direction of the line vector.

               Events[1] - Type DATA; point projected onto line vector to
                           produce second endpoint.


        Angle              * IGRdouble   

             Angle with respect to view in Events[0] used to calculate
	     the direction of the line segment.

        AbstractGeometry   * struct IGRbsp_curve

	     Abstract geometry of a line segment returned

 Caveates:

 History:
     
        srh  05/04/87  -  Created;
                         
 */

/*   EH -  End of Header  */

#include "coimport.h"
#include    "OMminimum.h"
#include    "igetypedef.h"
#include    "igrtypedef.h"
#include    "godef.h"
#include    "gr.h"
#include    "igr.h"
#include    "igrdp.h"
#include    "msdef.h"
#include    "go.h"
#include    "ex.h"
#include    "codef.h"
#include    "griodef.h"
#include    "grio.h"
#include    "dpdef.h"
#include    "dp.h"
#include    "grdpbdef.h"
#include    "grdpb.h"
#include    "griomacros.h"
#include    "grdpbmacros.h"
#include    "madef.h"
#include    "comiscmac.h"
#include    "exmacros.h"
#include    "dpmacros.h"
#include    "OMprimitives.h"
#include "codebug.h"
#include "igrmacros.h"

extern  IGRboolean   MAdegrad();
extern  IGRboolean   MAtrnmx();
extern  IGRboolean   MAlalnfpt();

/*
 *----------------------------------------
 *   CO_ni_place_horizontal_line
 *----------------------------------------
 */
IGRlong COline_at_angle_in_view( ReturnMsg,
                                 Events,
                                 Angle,
                                 AbstractGeometry )


    IGRlong              *ReturnMsg;
    struct GRevent       *Events[];
    IGRdouble            *Angle;
    struct IGRbsp_curve  *AbstractGeometry;

{

/* BV - BEGINNING OF VARIABLE LIST */

    IGRboolean         BooleanStatus;       /* return status         */
    IGRlong            LocalMsg;            /* return code           */
    IGRlong            ReturnStatus;        /* return code           */
    IGRlong            WhichError;
    IGRlong            ReturnSize;

    IGRshort           Dimension;

    IGRpoint           StartPoint;
    IGRpoint           ProjectPoint;
    IGRpoint           EndPoint;
    IGRpoint           Xaxis;               /* X axis vector from ViewToWorld */

    IGRmatrix          WorldToView;
    IGRmatrix          ViewToWorld;

    struct var_list    VariableList[2];
    struct IGRline     Line;


/* EV - END OF VARIABLE LIST */

    _m_debug_str( "COline_at_angle_in_view >" );

    /* 
     * ----------------------------------------------------------------------
     *  Step 0:  Initialize data 
     * ----------------------------------------------------------------------
     */

    StartPoint[0] = Events[0]->event.button.x;
    StartPoint[1] = Events[0]->event.button.y;
    StartPoint[2] = Events[0]->event.button.z;

    ProjectPoint[0] = Events[1]->event.button.x;
    ProjectPoint[1] = Events[1]->event.button.y;
    ProjectPoint[2] = Events[1]->event.button.z;


    /*
     * ------------------------------------------------------------------------
     * Step 1:  Get world to view matrix from view of first point ( Events[0] )
     * ------------------------------------------------------------------------
     */
    VariableList[0].var            = VIEW_ROTATION;
    VariableList[0].var_ptr        = (char *) WorldToView;
    VariableList[0].num_bytes      = sizeof( WorldToView );
    VariableList[0].bytes_returned = &ReturnSize;
    
    VariableList[1].var            = END_PARAM;

    ReturnStatus = dp$inq_set_gragad(
                 msg          = &LocalMsg,
                 osnum        = Events[0]->event.button.osnum,
                 gragad_objid = Events[0]->event.button.objid,
                 which_error  = &WhichError,
                 var_list     = VariableList );

    _m_check2( ReturnStatus, LocalMsg,
    {
        printf( "CO_ni_place_horizontal_line:  dp$inq_set_gragad\n");
        printf( "   status = %d\n", ReturnStatus );
        printf( "   msg = %x\n", LocalMsg );
        goto quit;
    } );
     
    /*
     * -----------------------------------------------------------------------
     *   Step 2:  Get view-to-world matrix 
     * -----------------------------------------------------------------------
     */
     
    Dimension = 4;
    BooleanStatus = MAtrnmx( &LocalMsg,
                             &Dimension,
                              WorldToView,
                              ViewToWorld );
  
    if( ( !BooleanStatus ) || ( COERROR( LocalMsg ) ) ) 
    {
        printf( "CO_ni_place_horizontal_line:  MAtrnmx failed\n" );
        printf( "   b_status = 0x%x\n", BooleanStatus );
        printf( "   msg      = 0x%x\n", LocalMsg );
	ReturnStatus = MSFAIL;
        goto quit;
    }

    /*
     * -----------------------------------------------------------------------
     *   Step 3:  Calculate endpoint of the Horizontal Line needed for 
     *            refernece in MAlalnfpt.  This is done by adding the 
     *            X axis vector from the View to the start point
     * -----------------------------------------------------------------------
     */
    Line.point1 = StartPoint;
    Line.point2 = EndPoint;

    Xaxis[0] = ViewToWorld[0];
    Xaxis[1] = ViewToWorld[4];
    Xaxis[2] = ViewToWorld[8];

    BooleanStatus = MAaddvc( &LocalMsg, 
                              StartPoint, 
                              Xaxis, 
                              EndPoint );  /* end_point for Line */

    if( ( !BooleanStatus ) || ( COERROR( LocalMsg ) ) )
    {
       printf( "CO_ni_place_horizontal_line: MAaddvc failed\n" );
       printf( "   b_status = 0x%x\n", BooleanStatus );
       printf( "   msg      = 0x%x\n", LocalMsg );
       ReturnStatus = MSFAIL;
       goto quit;
    }

    /*
     * -----------------------------------------------------------------------
     *   Step 4:  get the B-spline geometry of the horizontal line 
     * -----------------------------------------------------------------------
     */
    _m_debug_str( "CO_ni_place_horizontal_line:  calling MAlalnfpt" );
    BooleanStatus = MAlalnfpt( &LocalMsg,
                               &Line,
                                StartPoint,
                                ProjectPoint,
                                Angle, 
                                ViewToWorld,
                                AbstractGeometry );

    /*
     * verify a valid curve was generated
     */
    ReturnStatus = COcheck_curve(&LocalMsg,AbstractGeometry);
    _m_checkq(ReturnStatus);
    
    if( ( !BooleanStatus ) || ( COERROR( LocalMsg ) ) )
    {
       printf( "CO_ni_place_horizontal_line: MAlalnfpt failed\n" );
       printf( "   b_status = 0x%x\n", BooleanStatus );
       printf( "   msg      = 0x%x\n", LocalMsg );
       ReturnStatus = MSFAIL;
       goto quit;
    }

quit:
    *ReturnMsg = LocalMsg;
    _m_debug_str( "< CO_ni_place_horizontal_line" );

    return ( ReturnStatus );

} /* end CO_ni_place_horizontal_line() */

