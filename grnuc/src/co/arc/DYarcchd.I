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

#include "coimport.h"
#include "codebug.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "grerr.h"
#include "grmessage.h"
#include "godef.h"
#include "madef.h"
#include "codef.h"
#include "msdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "griodef.h"
#include "comiscmac.h"
#include "coniarray.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "msmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "igrdef.h"
#include "igrmacros.h"
#include "lcmacros.h"
#include "comiscmac.h"
#include "bsdefs.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsstackalloc.h"
#include "bsparameters.h"
#include "bsconic.h"
#include <stdio.h>
#include "go.h"
#include "igr.h"
#include "bsdmod.h"

%safe
extern IGRlong    DYarcchd(); 
#include "math.h"
%endsafe

from GRvg    import       GRgetgeom,
                          GRgetsize;

struct DYarctnchd_params {
        IGRlong               msg;  
        struct IGRbsp_curve  *bspline_ptr;
        IGRdouble             tanpoint[3],
                              distance,
                              active_angle,
                              uparm;
        IGRdouble            *RotationMatrix;
        IGRboolean            ccw;
        struct IGRbsp_curve  *circle;
        struct DPele_header   ele_buf[2]; /* [0]-arc [1]-chord */
 };


/*------------------------------------------
 *  DYrbarcchd
 *  
 *  History: jjc 10/27/89 created
 *
 *  Abstract: These functions will do dynamics for displaying an arc
 *            tangent to an element where the arc is defined by a
 *            chord at a given angle from the tangent.  The chord is 
 *            also shown in dynamics.
 *
 *------------------------------------------
 */


IGRlong  DYrbarcchd( Events, Display1 ) 

    struct GRevent        *Events[];
    struct IGRdisplay     *Display1;     

{



    IGRlong                  msg;
    IGRboolean               b_status;
    struct IGRdisplay        Display2;
    struct IGRbsp_curve     *bspline_ptr;
    struct IGRbsp_curve     *circle;
    struct IGRbsp_curve     *arc;
    struct IGRbsp_curve     *tmpcurve;
    struct IGRpolyline       line;
    IGRlong                  size;
    IGRdouble                mypi;
    IGRdouble                mymod;
    IGRdouble                basis_tol;
    IGRdouble                endpoint[3];
    IGRvector                vnew;
    struct var_list          VariableList[2];
    struct GRid              WindowGrid;   
    IGRlong                  WhichError; 
    IGRmatrix                RotationMatrix;
    IGRlong                  BytesReturned;
    IGRlong                  status=0;         /* return code    */
    struct DYarctnchd_params DYinfo;
    struct IGResbc           CircleSpecific;    
    BSrc                     rc;    
    IGRdouble                lnpoint1[3];
    IGRdouble                lnpoint2[3];
    IGRdouble                lnpoints[6];
    IGRdouble                dist_tol;
    IGRpoint                 eval[2];
    IGRlong                  localsize;
    IGRdouble                scale;
    IGRlong                  NumberToRotate;
    struct IGRline           chordline;
    IGRlong                  mynret;
    IGRvector                tanvec;
    IGRvector                tvec;
    IGRdouble                Zvector[3];
    IGRmatrix                OutMatrix;
    IGRdouble                tparm;
    IGRshort                 dim;
    IGRdouble                proj_point[3];
    IGRmatrix                fixmatrix;
    IGRdouble                rmat[3][3];

 /*  declare memory for the circle that the arc endpoint will be projected
  *  onto.
  */
BSalloccv(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 1, NULL,&circle,&rc);
      if (BSERROR(rc))
	  goto quit;


 /*  declare memory for the arc
  */
BSalloccv(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 1, NULL,&arc,&rc);
      if (BSERROR(rc))
	  goto quit;


 /*  declare memory for the element from which the arc will be tangent
  *  and get the element from the event.
  */
    status = om$send(
            msg = message GRvg.GRgetsize(
                  &msg,
                  &Events[1]->located_object[0].module_info.md_env.matrix_type,
                   Events[1]->located_object[0].module_info.md_env.matrix,
                  &size ),
                   senderid = NULL_OBJID, 
                   targetid = Events[1]->located_object[0].located_obj.objid,
                   targetos = Events[1]->located_object[0].located_obj.osnum
                    );
    _m_check2q(status,msg); 
    
    bspline_ptr = (struct IGRbsp_curve *)om$malloc( size = size );

    status = om$send(
                  msg = message GRvg.GRgetgeom(
                  &msg,
                  &Events[1]->located_object[0].module_info.md_env.matrix_type,
                   Events[1]->located_object[0].module_info.md_env.matrix,
                   (IGRchar *)bspline_ptr ),
                   senderid = NULL_OBJID, 
                   targetid = Events[1]->located_object[0].located_obj.objid,
                   targetos = Events[1]->located_object[0].located_obj.osnum
                    );
    _m_check2q(status,msg); 



     /*  get u-parameter for point of tangency
      */
       DYinfo.uparm = Events[1]->located_object[0].geom_parms.u;
      

     /*  get the point of tangency 
      */
       DYinfo.tanpoint[0]=Events[1]->located_object[0].proj_pnt[0];
       DYinfo.tanpoint[1]=Events[1]->located_object[0].proj_pnt[1];
       DYinfo.tanpoint[2]=Events[1]->located_object[0].proj_pnt[2];



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
    _m_debug_str( "DYarcchd - calling inq_set." );
    status = dp$inq_set_gragad(
                            msg = &msg,
                            gragad_objid = WindowGrid.objid,
                            which_error = &WhichError,
                            var_list = VariableList );
    _m_check2p( status, msg, "DYarcchd - failed inq_set_gragad." );
    _m_check2q( status, msg );



    /*  invert the wld_to_view matrix to get view_to_wld
     */
    dim=4;
    b_status = MAinvmx(
                  &msg,
                  &dim,
                   RotationMatrix,
                   fixmatrix );          
    _m_check_boolq(b_status);



    /*  get arc direction from dpb
     */
    localsize = sizeof( DYinfo.ccw );

    gr$get_arc_direction(
                  msg    = &msg,
                  sizbuf = &localsize,
                  buffer = &DYinfo.ccw,
                  nret   = &mynret );
    _m_checkq(msg);                           



   /*  get active angle from dpb
    */
   localsize = sizeof( DYinfo.active_angle );

   gr$get_active_angle (
                 msg    = &msg,
                 sizbuf = &localsize,
                 buffer = &DYinfo.active_angle,
                 nret   = &mynret );
   _m_checkq(msg);   


        if( DYinfo.active_angle < 0.0 ) 
            DYinfo.active_angle = -(DYinfo.active_angle);

        /*  test if active angle is valid
         */
        mypi  = PI;
        mymod = BSdmod(
                    DYinfo.active_angle,
                    mypi,
                    &rc );
           if (BSERROR(rc))
	       goto quit;



       gr$get_basis_tolerance (
                     msg    = &msg,
                     sizbuf = &localsize,
                     buffer = &basis_tol,
                     nret   = &mynret );
       _m_checkq(msg);   
          

       if (( DYinfo.active_angle == 0.0 ) || ( mymod <= basis_tol )) {
             msg = MSINARG;
             goto quit;
         } 



   /*  set the zvector for the view
    */
   Zvector[0]=0;
   Zvector[1]=0;
   Zvector[2]=1;

   /*  allocate memory for the bspline curve that the arc will be tangent
    *  from.  this curve will be transformed onto the view plane for 
    *  calculations.  
    */  
   BSalloccv(bspline_ptr->order, bspline_ptr->num_poles, bspline_ptr->rational,
             NULL,&tmpcurve, &rc);
   if (BSERROR(rc))
      goto quit;

   /*  set up the 3X3 version of the RotationMatrix for use by BScvoton
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

   /*  convert the bspline curve from world to view coordinates
    */
   (void) BScvoton(&rc, tvec, rmat, &scale, bspline_ptr, tmpcurve);
   if (BSERROR(rc))
      goto quit;

   /*  evaluate the u parameter for the point of tangency along the 
    *  bspline curve to get the point and the first derivitive which
    *  will be the tangent.
    */
   BScveval(tmpcurve, DYinfo.uparm, 1, eval,&rc);
   if (BSERROR(rc))
      goto quit;
   
   /*  get the tangent point from the bspline curve in the view
    */
   lnpoint1[0]=eval[0][0];
   lnpoint1[1]=eval[0][1];
   lnpoint1[2]=eval[0][2];

   /*  set the direction of the tangent
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

   /*  set up the tangent vector
    */
   tanvec[0]=eval[1][0];
   tanvec[1]=eval[1][1];
   tanvec[2]=0.0;


   /*  set up the endpoint of the tangent vector
    */
   b_status = MAaddvc(
                   &msg,
                    lnpoint1,
                    tanvec,
                    lnpoint2 );        
   _m_check_boolq(b_status);     



    /*  create a rotation matrix that will rotate the endpoint of the 
     *  tangent vector by the active angle
     */
    b_status = MAgrotmx( 
                     &msg,
                      Zvector,
                      lnpoint1,
                     &DYinfo.active_angle,
                      OutMatrix );
    _m_check_boolq(b_status);

    NumberToRotate = 1;

    /*  transform the point using the matrix just created
     */
    b_status = MAptsxform(
               &msg,
               &NumberToRotate,
                OutMatrix,
                lnpoint2,
                lnpoint2 );
    _m_check_boolq(b_status);

    /*  establish the chordline
     */
    chordline.point1 = lnpoint1;
    chordline.point2 = lnpoint2;


   /* get the desired length of chord */
   if(Events[0]->response == DATA) {
     /* if data point was entered for endpoint of chord */

     /*  get the chord endpoint from the event
      */
     endpoint[0]=Events[0]->event.button.x;
     endpoint[1]=Events[0]->event.button.y;
     endpoint[2]=Events[0]->event.button.z;


     /*  transform the point to view coordinates
      */
     b_status = MAptsxform(
                &msg,
                &NumberToRotate,
                 RotationMatrix,
                 endpoint,
                 endpoint );
     _m_check_boolq(b_status);

     /*  project the point onto the chord
      */
     b_status = MAptlnproj(
                  &msg,
                   endpoint,
                  &chordline,
                   proj_point,
                  &tparm );  
     _m_check_boolq(b_status);


     /*  find the length of the chord
      */    
     b_status = MA2ptdis(
                  &msg,
                   chordline.point1,
                   proj_point,
                  &DYinfo.distance );
     _m_check_boolq(b_status);


    
    }

   if(Events[0]->response == VALUE) {
       /*  if value was entered for length of chord
        */
      DYinfo.distance = Events[0]->event.value;             
    }



    /*  establish polyline form of chord line for dynamics
     */
    line.num_points = 2;
    line.points     = lnpoints;

    /*  initialize display variables for the chordline
     */
    Display2 = *Display1;
    Display2.style = 3;
    Display2.weight = 1;

    /*  build display buffer for the arc
     */
    CircleSpecific.is_polydis = FALSE;
    CircleSpecific.is_curvedis = TRUE;

    dp$build_dis_buffer(
                    buffer       = &DYinfo.ele_buf[0],
                    display_att  =  Display1,
                    geometry     =  arc,
                    ele_spec_att = &CircleSpecific );

    /*  build display buffer for the chordline
     */
    dp$build_dis_buffer(
                    buffer       = &DYinfo.ele_buf[1],
                    type         = IGRPY,  /* type is polyline */
                    display_att  = &Display2,
                    geometry     = &line ); 
                    

    /*  create a vector for calculating the chord endpoint
     */
    vnew[0] = lnpoint2[0] - lnpoint1[0];
    vnew[1] = lnpoint2[1] - lnpoint1[1];    
    vnew[2] = lnpoint2[2] - lnpoint1[2];        

    /*  normalize the vector
     */
    (void)BSnorvec(&rc, vnew);
    if (BSERROR(rc))
       goto quit;


/*  set up the points for the polyline to be displayed in dynamics
 */
DYinfo.ele_buf[1].geometry.polyline->points[0] = chordline.point1[0];
DYinfo.ele_buf[1].geometry.polyline->points[1] = chordline.point1[1];
DYinfo.ele_buf[1].geometry.polyline->points[2] = chordline.point1[2];

DYinfo.ele_buf[1].geometry.polyline->points[3] = chordline.point1[0] + DYinfo.distance * vnew[0];
DYinfo.ele_buf[1].geometry.polyline->points[4] = chordline.point1[1] + DYinfo.distance * vnew[1];
DYinfo.ele_buf[1].geometry.polyline->points[5] = chordline.point1[2] + DYinfo.distance * vnew[2];



       /*  transform the chord line back to world coordinates
        */
       NumberToRotate = 2;
       b_status = MAptsxform(
                  &msg,
                  &NumberToRotate,
                   fixmatrix,  /* view_to_world */
                   DYinfo.ele_buf[1].geometry.polyline->points,
                   DYinfo.ele_buf[1].geometry.polyline->points );
       _m_check_boolq(b_status); 


       /*  call the function that will create the circle.  we create a circle
        *  here to fix the radius of the arc and to have an object to project
        *  the arc endpoint onto. 
        */
        b_status = CO_create_circle_tan_chord( 
                         &msg,
                          bspline_ptr,
                         &DYinfo.active_angle,
                         &DYinfo.distance,                    
                          DYinfo.tanpoint,
                         &DYinfo.uparm,
                          RotationMatrix,
                          NULL,
                          1,
                          circle );
        _m_check_boolq(b_status);


   /*  load the remaining parameters to be sent to the routine called by
    *  DPdynamics
    */
    DYinfo.msg            = MSSUCC ;
    DYinfo.bspline_ptr    = bspline_ptr;
    DYinfo.RotationMatrix = RotationMatrix;
    DYinfo.circle         = circle;

   
   dp$dynamics( dyn_fun = DYarcchd,
            information = &DYinfo );


    om$dealloc( ptr = bspline_ptr );
    om$dealloc( ptr = circle );
    om$dealloc( ptr = arc );
    om$dealloc( ptr = tmpcurve );

quit:
    return ( status );
}




/* This is the routine called by DPdynamics */


IGRlong DYarcchd(
             DYinfo,
             cursor,
             ViewMatrix,
             objects,
             num_objects,
             buffers, 
             num_buffers,
             in_dum1,
             in_dum2,
             in_dum3,
             out_dum1,
             out_dum2,
             out_dum3 )

       struct DYarctnchd_params  *DYinfo;
       struct EX_button         *cursor;
       IGRdouble                *ViewMatrix;
       struct GRid             **objects;
       IGRint                   *num_objects;
       struct DPele_header     **buffers;
       IGRint                   *num_buffers;
       IGRchar                  *in_dum1,   *in_dum2,   *in_dum3;
       IGRchar                 **out_dum1, **out_dum2, **out_dum3;




{

IGRboolean b_status;
IGRdouble  arcept[3],
           projpoint[3];
IGRdouble  tolr,
           u_parameter;




     /*  now get the user defined endpoint for the arc. we already have the
      *  first endpoint which is the point tangent from the bspline curve.
      *  then project the input point onto the circle we just created.
      */
     arcept[0]=cursor->x;
     arcept[1]=cursor->y;
     arcept[2]=cursor->z;

     tolr = .000001;
     b_status = MAptbcproj(
                     &DYinfo->msg,
                      arcept,
                      DYinfo->circle, 
                     &tolr,                         
                      projpoint,
                     &u_parameter );
     _m_check_boolq(b_status);



     /*  call the function that will create the arc
      */
     b_status = CO_create_circle_tan_chord( 
                                &DYinfo->msg,
                                 DYinfo->bspline_ptr,
                                &DYinfo->active_angle, 
                                &DYinfo->distance,                    
                                 DYinfo->tanpoint,
                                &DYinfo->uparm,
                                 DYinfo->RotationMatrix,
                                 projpoint,
                                 DYinfo->ccw,
                                 DYinfo->ele_buf[0].geometry.bspcurve );
     _m_check_boolq(b_status);

     *buffers     = DYinfo->ele_buf;
     *num_buffers = 2;

quit:
    return((b_status) ? MSSUCC : MSFAIL);

}


end implementation Root;
