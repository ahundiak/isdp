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


class implementation Root;

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "coimport.h"
#include "codebug.h"
#include "grerr.h"
#include "grmessage.h"
#include "codef.h"
#include "msdef.h"
#include "madef.h"
#include "go.h"
#include "dp.h"
#include "dpdef.h"
#include "griodef.h"
#include "comiscmac.h"
#include "coniarray.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "msmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "igrmacros.h"
#include "lcmacros.h"
#include "godef.h"
#include "dpstruct.h"
#include "igr.h"
#include "igrdef.h"
#include "lcmacros.h"

#include "bsdefs.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsstackalloc.h"
#include "bsparameters.h"
#include "bsconic.h"
#include "bsdmod.h"

#include <stdio.h>
%safe
#include "math.h"
%endsafe

/*----------------------------------------
 *    imports
 *----------------------------------------
 */
from GRvg       import    GRgetgeom;
from GRvg       import    GRgetsize;


/*------------------------------------------
 * CO_ni_place_arc_tan_chord
 *------------------------------------------
 */

IGRlong CO_ni_place_arc_tan_chord(
                    msg,
                    Events,
                    DisplayMode,
                    newflag,
                    ModuleInfo,
                    ActiveDisplay,
                    ActiveLevel,
                    attr,
                    name,
                    CircleGrid,
                    DisplayGrid,
                    classname,
                    classid,
                    neighbor,
                    cob_id,
                    cob_os,
                    p_co_chanselect,
                    co_index )



    IGRlong              *msg;
    struct GRevent       *Events[];
    enum GRdpmode        *DisplayMode;
    IGRboolean            newflag;
    struct GRmd_env      *ModuleInfo;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort             *ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *CircleGrid;
    struct GRid          *DisplayGrid;
    IGRchar              *classname;
    GRclassid             classid;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                co_index;

/*
Abstract
   This function was written for the Place Arc Tangent to Element
   by Chord Definition command.  The following event information is 
   passed in:      Events[0] -- chord length or chord endpoint
                   Events[1] -- tangent point on element
                   Events[2] -- arc endpoint
   An arc will be constructed tangent from a given element and will
   be defined by a chord that is a given angle from the tangent in
   a counterclockwise direction.  The Active Angle is used and the
   CW/CCW flag is active for placement of the arc.                    
  
History
    jjc 10/10/89 : created

*/



{
    IGRboolean            b_status;
    struct IGRbsp_curve  *bspline_ptr,
                         *tmpcurve, 
                         *arc; 
    IGRlong               size;
    IGRdouble             distance,
                          tanpoint[3],
                          uparm,
                          endpoint[3],
                          fixed_point[3],
                          u_parameter,
                          tolr,
                          arcept[3];
    struct var_list       VariableList[2];
    struct GRid           WindowGrid;   
    IGRlong               WhichError; 
    IGRshort              dim;
    IGRmatrix             RotationMatrix;
    IGRmatrix             fixmatrix;
    IGRdouble             lnpoint1[3];
    IGRdouble             lnpoint2[3];
    IGRdouble             mypi;
    IGRdouble             mymod;
    IGRdouble             dist_tol;
    IGRpoint              eval[2];
    IGRlong               localsize;
    IGRdouble             active_angle;
    IGRdouble             basis_tol;
    IGRboolean            ccw;
    IGRdouble             scale;
    IGRlong               NumberToRotate;
    struct IGRline        chordline;
    IGRlong               mynret;
    IGRvector             tanvec;
    IGRvector             tvec;
    IGRvector             vnew;
    IGRdouble             Zvector[3];
    IGRmatrix             OutMatrix;
    IGRdouble             tparm;
    IGRdouble             proj_point[3];
    IGRdouble             rmat[3][3];
    IGRlong               BytesReturned;
    IGRlong               status=0;         /* return code    */
    BSrc                  rc;




    *msg  = MSSUCC;

      /*  declare memory for the arc
       */
      BSalloccv(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 1, NULL,
	        &arc, &rc);
      if (BSERROR(rc))
	  goto quit;


    /*  get the element from which the arc will be tangent.  first
     *  get the size, then declare the memory, then get the geometry.
     */
    status = om$send(
            msg = message GRvg.GRgetsize(
                   msg,
                  &Events[1]->located_object[0].module_info.md_env.matrix_type,
                   Events[1]->located_object[0].module_info.md_env.matrix,
                  &size ),
                   senderid = NULL_OBJID, 
                   targetid = Events[1]->located_object[0].located_obj.objid,
                   targetos = Events[1]->located_object[0].located_obj.osnum
                    );
    _m_check2q(status,*msg);

    bspline_ptr = (struct IGRbsp_curve *)om$malloc( size = size );

    status = om$send(
                  msg = message GRvg.GRgetgeom(
                   msg,
                  &Events[1]->located_object[0].module_info.md_env.matrix_type,
                   Events[1]->located_object[0].module_info.md_env.matrix,
                   (IGRchar *)bspline_ptr ),
                   senderid = NULL_OBJID, 
                   targetid = Events[1]->located_object[0].located_obj.objid,
                   targetos = Events[1]->located_object[0].located_obj.osnum
                    );
    _m_check2q(status,*msg);


       /*  get u-parameter for point of tangency 
        */
       uparm = Events[1]->located_object[0].geom_parms.u;


       /*  get point of tangency 
        */
       tanpoint[0]=Events[1]->located_object[0].proj_pnt[0];
       tanpoint[1]=Events[1]->located_object[0].proj_pnt[1];
       tanpoint[2]=Events[1]->located_object[0].proj_pnt[2];

   
       /*
        *  set up the variable list
        */
       WindowGrid.objid = Events[1]->event.button.objid; 
       VariableList[0].var       = VIEW_ROTATION;
       VariableList[0].var_ptr   = (IGRchar *)RotationMatrix;
       VariableList[0].num_bytes = sizeof( IGRdouble ) * 16;
       VariableList[0].bytes_returned = &BytesReturned;
       VariableList[1].var = END_PARAM;
                                                                              
       /*
        *  get the view matrix for the display
        */
       _m_debug_str( "COniarctnchd - calling inq_set." );
       status = dp$inq_set_gragad(
                            msg = msg,
                            gragad_objid = WindowGrid.objid,
                            which_error = &WhichError,
                            var_list = VariableList );
       _m_check2p( status, *msg, "COniarctnchd - failed inq_set_gragad." );
       _m_check2q( status, *msg );



       /*  get arc direction from dpb
        */
       localsize = sizeof( ccw );

       gr$get_arc_direction(
                     msg    = msg,
                     sizbuf = &localsize,
                     buffer = &ccw,
                     nret   = &mynret );
       _m_checkq(*msg);                           


       /*  get active angle from dpb
        */
       localsize = sizeof( active_angle );

       gr$get_active_angle (
                     msg    =  msg,
                     sizbuf = &localsize,
                     buffer = &active_angle,
                     nret   = &mynret );
       _m_checkq(*msg);   


          if( active_angle < 0.0 ) 
              active_angle = -active_angle;

          /*  test if active angle is valid
           */
          mypi  = PI;
          mymod = BSdmod(
                      active_angle,
                      mypi, 
                     &rc );
          if (BSERROR(rc))
	      goto quit;


       gr$get_basis_tolerance (
                     msg    =  msg,
                     sizbuf = &localsize,
                     buffer = &basis_tol,
                     nret   = &mynret );
       _m_checkq(*msg);   
          

       if (( active_angle == 0.0 ) || ( mymod <= basis_tol )) {
            *msg = MSINARG;
             goto quit;
         } 



     /*  get the z vector for the view
      */
     Zvector[0]=0;
     Zvector[1]=0;
     Zvector[2]=1;

   /*  allocate memory for the bspline curve that will be transformed into
    *  view coordinates
    */
   BSalloccv(bspline_ptr->order, bspline_ptr->num_poles, bspline_ptr->rational,
             NULL,&tmpcurve, &rc);
   if (BSERROR(rc))
      goto quit;

   /*  set up the 3X3 version of the RotationMatrix
    */
   rmat[0][0] = RotationMatrix[0];
   rmat[0][1] = RotationMatrix[1];
   rmat[0][2] = RotationMatrix[2];
   rmat[1][0] = RotationMatrix[4];
   rmat[1][1] = RotationMatrix[5];
   rmat[1][2] = RotationMatrix[6];
   rmat[2][0] = RotationMatrix[8];
   rmat[2][1] = RotationMatrix[9];
   rmat[2][2] = RotationMatrix[10];

   /*  other variables for BScvoton
    */
   tvec[0] = 0.0;
   tvec[1] = 0.0;
   tvec[2] = 0.0;
   scale   = 1.0;

   /*  transform the bspline curve that the arc will be tangent from
    *  into view coordinates for calculations
    */
   (void) BScvoton(&rc, tvec, rmat, &scale, bspline_ptr, tmpcurve);
   if (BSERROR(rc))
      goto quit;

   /*  evaluate the u parameter on the transformed bspline to get the 
    *  tangent point and the first derivitive which is the tangent vector
    */
   BScveval(tmpcurve, uparm, 1, eval,&rc);
   if (BSERROR(rc))
      goto quit;

   /*  get the tangent point
    */
   lnpoint1[0]=eval[0][0];
   lnpoint1[1]=eval[0][1];
   lnpoint1[2]=eval[0][2];

   /*  set the direction for the tangent vector
    */
   BSEXTRACTPAR(&rc, BSTOLLENVEC, dist_tol);
   if (BSERROR(rc))
      goto quit;
   
   if ( (fabs(eval[1][1]) < dist_tol && eval[1][0] < 0.0 ) || 
        (eval[1][1] >= dist_tol))
   {
      eval[1][0] = -eval[1][0];
      eval[1][1] = -eval[1][1];

   }

   /*  get the tangent vector
    */
   tanvec[0]=eval[1][0];
   tanvec[1]=eval[1][1];
   tanvec[2]=0.0;

   /*  get a point along the tangent vector
    */
   b_status = MAaddvc(
                      msg,
                      lnpoint1,
                      tanvec,
                      lnpoint2 );        
   _m_check_boolq(b_status);     

    /*  set up a rotation matrix to rotate the tangent line about the tangent
     *  point by the active angle
     */
    b_status = MAgrotmx( 
                      msg,
                      Zvector,
                      lnpoint1,
                     &active_angle,
                      OutMatrix );
    _m_check_boolq(b_status);



    /*  transform the endpoint of the tangent line using the matrix
     */
    NumberToRotate = 1;
    b_status = MAptsxform(
                msg,
               &NumberToRotate,
                OutMatrix,
                lnpoint2,
                lnpoint2 );
    _m_check_boolq(b_status);

    /*  the tangent line is now positioned to be the chord for the arc
     */
    chordline.point1 = lnpoint1;
    chordline.point2 = lnpoint2;



   /*  get length of chord
    */

   if(Events[0]->response == DATA) {
     /* if data point was entered for endpoint of chord 
      */

     /*  get the endpoint from the event
      */
     endpoint[0]=Events[0]->event.button.x;
     endpoint[1]=Events[0]->event.button.y;
     endpoint[2]=Events[0]->event.button.z;

     /*  transform the point to view coordinates
      */
     NumberToRotate = 1;
     b_status = MAptsxform(
                 msg,
                &NumberToRotate,
                 RotationMatrix,
                 endpoint,
                 endpoint );
     _m_check_boolq(b_status);

     /*  project the chord endpoint onto the chord
      */
     b_status = MAptlnproj(
                   msg,
                   endpoint,
                  &chordline,
                   proj_point,
                  &tparm );  
     _m_check_boolq(b_status);


     /*  find the length of the chord
      */    
     b_status = MA2ptdis(
                   msg,
                   chordline.point1,
                   proj_point,
                   &distance );
     _m_check_boolq(b_status);

    }
   else if(Events[0]->response == VALUE) { 
          /*  if value was entered for length of chord
           */
          distance = Events[0]->event.value;             
      }



    /*  create a vector for the chordline
     */
    vnew[0] = lnpoint2[0] - lnpoint1[0];
    vnew[1] = lnpoint2[1] - lnpoint1[1];    
    vnew[2] = lnpoint2[2] - lnpoint1[2];        

   /*  normalize the chord vector
    */
   (void)BSnorvec(&rc, vnew);
   if (BSERROR(rc))
      goto quit;


    /*  get arc endpoint
     */

    if(Events[2]->subtype == GRst_DEFAULT) {
       /*  user entered moveon to use chord endpoint for arc endpoint
        */

      /*  using the chordline vector and the distance, calculate the
       *  other endpoint of the chord
       */
      fixed_point[0] = chordline.point1[0] + distance * vnew[0];
      fixed_point[1] = chordline.point1[1] + distance * vnew[1];
      fixed_point[2] = chordline.point1[2] + distance * vnew[2];


      /*  invert the RotationMatrix to get view_to_wld
       */
      dim=4;
      b_status = MAinvmx(
                     msg,
                    &dim,
                     RotationMatrix,
                     fixmatrix );          
      _m_check_boolq(b_status);

       /*  transform the chord endpoint to world coordinates
        */
       NumberToRotate = 1;
       b_status = MAptsxform(
                   msg,
                  &NumberToRotate,
                   fixmatrix,
                   fixed_point,
                   fixed_point);
       _m_check_boolq(b_status); 

       }

    else {
     /*  user entered data point for arc endpoint. 
      *  call the function that will create a circle.
      *  send in 1 for ccw flag, only used for arcs, not circles.
      */
     b_status = CO_create_circle_tan_chord( 
                          msg,
                          bspline_ptr,
                         &active_angle, 
                         &distance,                    
                          tanpoint,
                         &uparm,
                          RotationMatrix,
                          NULL,
                          1,
                          arc );
     _m_check_boolq(b_status);

     /*  now get the user defined endpoint for the arc(we already have the
      *  first endpoint which is the point tangent from the bspline curve.
      *  then project the input point onto the circle we just created.
      */

     arcept[0]=Events[2]->event.button.x;
     arcept[1]=Events[2]->event.button.y;
     arcept[2]=Events[2]->event.button.z;


     /*  project the arc endpoint onto the circle
      */
     tolr = .000001; 
     b_status = MAptbcproj(
                      msg,
                      arcept,
                      arc,
                     &tolr,                         
                      fixed_point,
                     &u_parameter );
     _m_check_boolq(b_status);

    }


    /*  call the function that will create the arc 
     */
     b_status = CO_create_circle_tan_chord( 
                          msg,
                          bspline_ptr,
                         &active_angle,
                         &distance,                    
                          tanpoint,
                         &uparm,
                          RotationMatrix,
                          fixed_point,
                          ccw,
                          arc );
      _m_check_boolq(b_status);

    /*
     *  set up the object space of the new object then construct the arc
     */
    _m_debug_str( "CO_ni_place_arc - calling construct." );
    CircleGrid->osnum = ModuleInfo->md_id.osnum;


    /*
     *  classname is specified
     */
    if ( classname != NULL )
    {
        status = co$construct_object(
                        msg = msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
			properties = 0,
                        geometry = arc,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = CircleGrid,
                        display_obj = DisplayGrid,
                        neighbor = neighbor,
                        cob_id = cob_id,
                        cob_os = cob_os,
                        p_co_chansel = p_co_chanselect,
                        co_index = co_index,
                        classname = classname );
                                                                            
    }
    else /* classid is specified */
    {
        status = co$construct_object(
                        msg = msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
			properties = 0,
                        geometry = arc,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = CircleGrid,
                        display_obj = DisplayGrid,
                        neighbor = neighbor,
                        cob_id = cob_id,
                        cob_os = cob_os,
                        p_co_chansel = p_co_chanselect,
                        co_index = co_index,
                        classid = classid );
    }

   _m_check2p( 
              status,
              *msg,
              "CO_construct_arc_tan_chord-failed in co$construct object." );


    om$dealloc( ptr = bspline_ptr );
    om$dealloc( ptr = arc );
    om$dealloc( ptr = tmpcurve );

quit:
    return ( status );
}

end implementation Root;
