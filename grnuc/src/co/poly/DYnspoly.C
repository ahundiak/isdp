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
 * history : jjc 10/25/89  added funtionality for Place N-sided Polygon by
 *                         midpoint of side.
 */

#include "coimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "griodef.h"
#include "msdef.h"
#include "igrdef.h"
#include "dpdef.h"
#include "madef.h"
#include "codef.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"
#include "dpstruct.h"

#include "igrmacros.h"
#include "dpmacros.h"

#include "codebug.h"



extern    IGRint    DYnpolygon();
extern    IGRlong   COnpolygonConstruct();

#ifndef IDRAW
extern    IGRlong   COnmppolygonConstruct();
#endif /* IDRAW */


struct DYnpolygon_params {
    IGRlong                 msg;
    IGRpoint                CenterPoint;
    IGRlong                 NumberOfSides;
    struct DPele_header    *Element;
    IGRdouble              *RotationMatrix;
    IGRdouble              *PointArray;
    struct IGRbsp_curve    *bspline;
    struct IGRpolyline     *polyline;
    IGRlong                 mpside;
};






IGRint DYrbnpolygon( Events, Display )

    struct GRevent             *Events[];
    struct IGRdisplay          *Display;

{
/* BV - BEGINNING OF VARIABLE LIST */

    IGRlong                   msg;
    IGRlong                   status;
    struct DPele_header       Element;
    struct DYnpolygon_params  DYinfo;
    struct IGRbsp_curve       bspline;
    struct IGResbc            BsplineSpecific;
    struct IGRpolyline        polyline;
    struct GRid               WindowGrid;
    IGRlong                   WhichError; 
    IGRmatrix                 RotationMatrix;
    IGRlong                   BytesReturned;
    struct var_list           VariableList[2];
    IGRlong                   NumberOfSides;
    IGRdouble                *PointArray;
    IGRdouble                *Knots;

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */


    _m_debug_str( "DYrbnpolygon." );




/*  the following check is done to distinguish which command called this
 *  function.  Place N-sided Polygon by Vertex will have a subtype of
 *  GRst_REGULAR and Place N-sided Polygon by Midpoint of Side will 
 *  have a subtype of GRst_DEFAULT.  this was done since the two commands
 *  were so similar. 
 */
 if(Events[3]->subtype == GRst_REGULAR) 
   DYinfo.mpside = 0;
 else DYinfo.mpside = 1;


    NumberOfSides = (IGRlong) Events[0]->event.value;
    PointArray = (IGRdouble *)om$malloc( 
                    size = ((NumberOfSides + 1) * 3) * sizeof( IGRdouble ) );
    Knots = (IGRdouble *)om$malloc(
                    size = (NumberOfSides + 1 + 2 ) * sizeof( IGRdouble ) );
    if ( PointArray == NULL || Knots == NULL )
    {
        return( OM_E_ABORT );
    }


    WindowGrid.objid = Events[1]->event.button.objid;
    WindowGrid.osnum = Events[1]->event.button.osnum;


    /*
     *  set up the variable list
     */
    VariableList[0].var            = VIEW_ROTATION;
    VariableList[0].var_ptr        = (char *) RotationMatrix;
    VariableList[0].num_bytes      = sizeof( IGRdouble ) * 16;
    VariableList[0].bytes_returned = &BytesReturned;
    VariableList[1].var            = END_PARAM;


                                                                            
    /*
     *  get the view matrix for the display
     */
    status = dp$inq_set_gragad(
                    msg = &msg,
                    gragad_objid = WindowGrid.objid,
                    which_error = &WhichError,
                    var_list = VariableList );
    _m_check2p( status, msg, "DYrbnpolygon - failed inq_set." );
    _m_check2q( status, msg );


    /*
     *  init the data structures
     */
    polyline.num_points         = NumberOfSides + 1;
    polyline.points             = PointArray;
    bspline.poles               = PointArray;
	/******* FIX 90N1353 ********/
    bspline.weights             = NULL;
		/*******/
    bspline.knots               = Knots;
    BsplineSpecific.is_polydis  = FALSE;
    BsplineSpecific.is_curvedis = TRUE;
    DYinfo.bspline              = &bspline;
    DYinfo.polyline             = &polyline;
    DYinfo.CenterPoint[0]       = Events[1]->event.button.x;
    DYinfo.CenterPoint[1]       = Events[1]->event.button.y;
    DYinfo.CenterPoint[2]       = Events[1]->event.button.z;
    DYinfo.Element              = &Element;
    DYinfo.RotationMatrix       = RotationMatrix;
    DYinfo.NumberOfSides        = NumberOfSides;
    DYinfo.PointArray           = PointArray;


    /*
     *  build the display buffer
     */
    dp$build_dis_buffer(
                    buffer = &Element,
                    display_att = Display,
                    geometry = &bspline,
                    ele_spec_att = &BsplineSpecific );

    dp$dynamics( 
                dyn_fun = DYnpolygon,
                information = &DYinfo );
quit:
    om$dealloc( ptr = PointArray );
    om$dealloc( ptr = Knots );
    return( status );
}


IGRint DYnpolygon( 
                DYinfo,
                point,
                matrix,
                objects,
                num_objects,
                buffers,
                 num_buffers,
                dummy_in1,
                dummy_in2,
                dummy_in3,
                dummy_out1,
                dummy_out2,
                dummy_out3 )

        struct DYnpolygon_params  *DYinfo;
        struct EX_button        *point;
        IGRdouble               *matrix;
        struct GRid             **objects;
        IGRint                  *num_objects;
        struct DPele_header     **buffers;
        IGRint                  *num_buffers;

        IGRchar                 *dummy_in1;
        IGRchar                 *dummy_in2;
        IGRchar                 *dummy_in3;

        IGRchar                 **dummy_out1;
        IGRchar                 **dummy_out2;
        IGRchar                 **dummy_out3;

{
    IGRlong       status;
    IGRboolean    b_status;
    IGRpoint      EdgePoint;

    EdgePoint[0] = point->x;
    EdgePoint[1] = point->y;
    EdgePoint[2] = point->z;


    /*
     *  construct the polyline
     *  Note: if mpside == 0 then this function was called from Place N-sided
     *  Polygon by Vertex.  if mpside == 1 then it was called by Place N-sided
     *  Polygon by Midpoint of Side.  mpside will tell which construction
     *  routine to call.
     */    

 if(DYinfo->mpside == 0) {
    status = COnpolygonConstruct( 
                            &DYinfo->msg,
                            DYinfo->RotationMatrix,
                            DYinfo->CenterPoint,
                            EdgePoint,
                            &DYinfo->NumberOfSides,
                            DYinfo->PointArray );
  }
 else  {
#ifndef IDRAW
    status = COnmppolygonConstruct( 
                            &DYinfo->msg,
                            DYinfo->RotationMatrix,
                            DYinfo->CenterPoint,
                            EdgePoint,
                            &DYinfo->NumberOfSides,
                            DYinfo->PointArray );
#endif /* IDRAW */
  }

    /*
     *  turn the polyline into a bspline
     */
    b_status = MApytobc( 
                    &DYinfo->msg,
                    DYinfo->polyline,
                    DYinfo->bspline );
    _m_check_boolp( b_status, "DYnpolygon - failed MApytobc." );
    _m_check_boolq( b_status );
    _m_checkp( DYinfo->msg, "DYnpolygon - failed MApytobc." );
    _m_checkq( DYinfo->msg );

    *buffers = DYinfo->Element;
    *num_buffers = 1;

quit:
  return((b_status&& !COERROR(DYinfo->msg)&& !COERROR(status))?MSSUCC:MSFAIL);
}
