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
#include "igr.h"
#include "igrdef.h"
#include "igrmacros.h"
#include "lcmacros.h"

#include "bsdefs.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsstackalloc.h"
#include "bsparameters.h"
#include "bsconic.h"
#include <stdio.h>
#include "bsdmod.h"

%safe
#include "math.h"
%endsafe

%safe
extern IGRlong    DYcirchd(); 
%endsafe

from GRvg    import       GRgetgeom,
                          GRgetsize;


struct DYcrtnchd_params {
        IGRlong               msg;  
        struct IGRbsp_curve  *bspline_ptr;
        IGRdouble             tanpoint[3],
                              uparm;
        IGRdouble            *RotationMatrix;
        struct DPele_header   ele_buf[2];
        struct IGRline       *chordline;
        IGRdouble             fixmatrix[16];
        IGRdouble            *active_angle;
        IGRvector             vnew; 
 };


/*------------------------------------------
 *  DYrbcirchd
 *  
 *  History: jjc 10/27/89 created
 *
 *  Abstract: These functions will do dynamics for displaying a circle
 *            tangent to an element where the circle is defined by a
 *            chord at a given angle from the tangent.
 *
 *
 *------------------------------------------
 */

IGRlong  DYrbcirchd( Events, Display1 ) 

    struct GRevent        *Events[];
    struct IGRdisplay     *Display1;     

{



    IGRlong                  msg;
    IGRboolean               b_status = 0;
    struct IGRbsp_curve     *bspline_ptr,
                            *tmpcurve,
                            *circle;
    struct IGRpolyline       line;
    struct IGRdisplay        Display2;
    IGRlong                  size;
    IGRdouble                scale;
    IGRvector                tvec;
    IGRdouble                mypi;
    IGRdouble                mymod;
    IGRdouble                lnpoint1[3];
    IGRdouble                lnpoint2[3];
    IGRdouble                lnpoints[6];
    IGRpoint                 eval[2];
    IGRlong                  localsize;
    IGRdouble                active_angle;
    IGRdouble                basis_tol;
    IGRlong                  NumberToRotate;
    struct IGRline           chordline;
    IGRlong                  mynret;
    IGRvector                tanvec;
    IGRdouble                Zvector[3];
    struct var_list          VariableList[2];
    struct GRid              WindowGrid;   
    IGRlong                  WhichError; 
    IGRmatrix                RotationMatrix;
    IGRmatrix                OutMatrix;
    IGRdouble                rmat[3][3];
    IGRdouble                dist_tol;
    IGRlong                  BytesReturned;
    IGRshort                 dim;
    IGRlong                  status = 1;         /* return code    */
    struct DYcrtnchd_params  DYinfo;
    struct IGResbc           CircleSpecific;    
    BSrc                     rc;    


 msg = MSSUCC;


    /*  declare memory for the circle
    */
    BSalloccv(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 1, NULL,&circle,&rc);
       if (BSERROR(rc))
           goto quit;


    /*  declare memory for the element from which the circle will be tangent
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
    _m_debug_str( "DYcrchd - calling inq_set." );
    status = dp$inq_set_gragad(
                            msg = &msg,
                            gragad_objid = WindowGrid.objid,
                            which_error = &WhichError,
                             var_list = VariableList );
    _m_check2p( status, msg, "DYcrchd - failed inq_set_gragad." );
    _m_check2q( status, msg );



    /*  invert the wld_to_view matrix to get view_to_wld
     */
    dim=4;
    b_status = MAinvmx(
                  &msg,
                  &dim,
                   RotationMatrix,
                   DYinfo.fixmatrix );          
    _m_check_boolq(b_status);


   /*  allocate memory for the bspline curve in the view
    */
   BSalloccv(bspline_ptr->order, bspline_ptr->num_poles, bspline_ptr->rational,
             NULL,&tmpcurve, &rc);
   if (BSERROR(rc))
      goto quit;

   /*  initialize the 3X3 matrix for the view
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

   /*  transform the tangent bspline to view coordinates
    */ 
   (void) BScvoton(&rc, tvec, rmat, &scale, bspline_ptr, tmpcurve);
   if (BSERROR(rc))
      goto quit;

   /*  evaluate the uparm to get the tangency point and the first
    *  derivitive which will be the tangent vector
    */
   BScveval(tmpcurve, DYinfo.uparm, 1, eval,&rc);
   if (BSERROR(rc))
      goto quit;

   /*  get the point of tangency
    */
   lnpoint1[0]=eval[0][0];
   lnpoint1[1]=eval[0][1];
   lnpoint1[2]=eval[0][2];

   /*  set the direction of the tangency vector
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

   /*  get a second point along the vector
    */
   b_status = MAaddvc(
                   &msg,
                    lnpoint1,
                    tanvec,
                    lnpoint2 );        
   _m_check_boolq(b_status);     


   /*  get the active angle
    */
   localsize = sizeof( active_angle );

   gr$get_active_angle (
                 msg    = &msg,
                 sizbuf = &localsize,
                 buffer = &active_angle,
                 nret   = &mynret );
   _m_checkq(msg);   


         if( active_angle < 0.0 ) 
             active_angle = -(active_angle);


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
                     msg    = &msg,
                     sizbuf = &localsize,
                     buffer = &basis_tol,
                     nret   = &mynret );
       _m_checkq(msg);   
          

       if (( active_angle == 0.0 ) || ( mymod <= basis_tol )) {
             msg = MSINARG;
             goto quit;
         } 


     /*  set the z vector for the view
      */
     Zvector[0]=0;
     Zvector[1]=0;
     Zvector[2]=1;


    /*  create rotation matrix to rotate the tangent vector to where the
     *  circle's chord should be. rotating about the tangency point.
     */
    b_status = MAgrotmx( 
                     &msg,
                      Zvector,
                      lnpoint1,
                     &active_angle,
                      OutMatrix );
    _m_check_boolq(b_status);


    /*  transform the second endpoint using the matrix
     */
    NumberToRotate = 1;
    b_status = MAptsxform(
               &msg,
               &NumberToRotate,
                OutMatrix,
                lnpoint2,
                lnpoint2 );
    _m_check_boolq(b_status);

    /*  establish the line for the circle's chord
     */
    chordline.point1 = lnpoint1;
    chordline.point2 = lnpoint2;

    /*  set up a vector for the chordline
     */
    DYinfo.vnew[0] = lnpoint2[0] - lnpoint1[0];
    DYinfo.vnew[1] = lnpoint2[1] - lnpoint1[1];    
    DYinfo.vnew[2] = lnpoint2[2] - lnpoint1[2];        

   /*  normalize the vector
    */
   (void)BSnorvec(&rc, DYinfo.vnew);
   if (BSERROR(rc))
      goto quit;



    CircleSpecific.is_polydis = FALSE;
    CircleSpecific.is_curvedis = TRUE;


    /*  establish a polyline form of chord line for dynamics
     */
    line.num_points = 2;
    line.points     = lnpoints;
 
    /* set display parms for the chord line 
     */
    Display2 = *Display1;
    Display2.style = 3;
    Display2.weight = 1;

    /*  build display buffer for the new circle
     */
     dp$build_dis_buffer(
                    buffer       = &DYinfo.ele_buf[0],
                    display_att  =  Display1,
                    geometry     =  circle,
                    ele_spec_att = &CircleSpecific );

    /*  build display buffer for the chord line
     */
    dp$build_dis_buffer(
                    buffer       = &DYinfo.ele_buf[1],
                    type         = IGRPY,  /* type is polyline */
                    display_att  = &Display2,
                    geometry     = &line ); 
                    

   /*  load the remaining parameters to be sent to the routine called by
    *   DPdynamics
    */
    DYinfo.msg            = MSSUCC ;
    DYinfo.bspline_ptr    = bspline_ptr;
    DYinfo.RotationMatrix = RotationMatrix;
    DYinfo.chordline      = &chordline;
    DYinfo.active_angle   = &active_angle;

   /*  call the dynamics routine
    */
   dp$dynamics( dyn_fun = DYcirchd,
            information = &DYinfo );


    om$dealloc( ptr = bspline_ptr );
    om$dealloc( ptr = tmpcurve );
    om$dealloc( ptr = circle );

quit:
    return ( status );
}




/* This is the routine called by DPdynamics */


IGRlong DYcirchd(
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

       struct DYcrtnchd_params  *DYinfo;
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
IGRdouble  endpoint[3];
IGRdouble  distance;
IGRdouble  tparm;
IGRdouble  proj_point[3];
IGRlong    numpoints;


       /*  get cursor position for the chord endpoint
        */
       endpoint[0]=cursor->x;
       endpoint[1]=cursor->y;
       endpoint[2]=cursor->z;

       /*  transform the cursor position to view coordinates
        */
       numpoints = 1;
       b_status = MAptsxform(
                  &DYinfo->msg,
                  &numpoints,
                   DYinfo->RotationMatrix,
                   endpoint,
                   endpoint);
       _m_check_boolq(b_status); 

       /*  project the cursor onto the chord line to get the chord endpoint
        */
       b_status = MAptlnproj(
                  &DYinfo->msg,
                   endpoint,
                   DYinfo->chordline,
                   proj_point,
                  &tparm );  
       _m_check_boolq(b_status); 

       /*  get length of the chord line 
        */
       b_status = MA2ptdis(
                  &DYinfo->msg,
                   DYinfo->chordline->point1,
                   proj_point,
                   &distance );
       _m_check_boolq(b_status); 


/*  calculate the corrected chord endpoint using the tangent vector
 */
DYinfo->ele_buf[1].geometry.polyline->points[3] = DYinfo->chordline->point1[0] + distance * DYinfo->vnew[0];
DYinfo->ele_buf[1].geometry.polyline->points[4] = DYinfo->chordline->point1[1] + distance * DYinfo->vnew[1];
DYinfo->ele_buf[1].geometry.polyline->points[5] = DYinfo->chordline->point1[2] + distance * DYinfo->vnew[2];


/*  set up the points for the polyline to be displayed in dynamics
 */
DYinfo->ele_buf[1].geometry.polyline->points[0] = DYinfo->chordline->point1[0];
DYinfo->ele_buf[1].geometry.polyline->points[1] = DYinfo->chordline->point1[1];
DYinfo->ele_buf[1].geometry.polyline->points[2] = DYinfo->chordline->point1[2];


       /*  transform the chord line back to world coordinates
        */
       numpoints = 2;
       b_status = MAptsxform(
                  &DYinfo->msg,
                  &numpoints,
                   DYinfo->fixmatrix,  /* view_to_world */
                   DYinfo->ele_buf[1].geometry.polyline->points,
                   DYinfo->ele_buf[1].geometry.polyline->points );
       _m_check_boolq(b_status); 


     /*  call the function that will create the circle
      *  note: sending in a 1 for the ccw flag.  the flag is not
      *  used for circles, only for arcs.
      */
     b_status = CO_create_circle_tan_chord( 
                                &DYinfo->msg,
                                 DYinfo->bspline_ptr,
                                 DYinfo->active_angle,
                                &distance,                    
                                 DYinfo->tanpoint,
                                &DYinfo->uparm,
                                 DYinfo->RotationMatrix,
                                 NULL,
                                 1,
                                 DYinfo->ele_buf[0].geometry.bspcurve );
     _m_check_boolq(b_status);

     *buffers     = DYinfo->ele_buf;
     *num_buffers = 2;

quit:
    return((b_status) ? MSSUCC : MSFAIL);

}


end implementation Root;
