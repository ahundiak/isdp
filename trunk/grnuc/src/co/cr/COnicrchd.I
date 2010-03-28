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
#include "grerr.h"
#include "grmessage.h"
#include "codef.h"
#include "madef.h"
#include "msdef.h"
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
 * CO_ni_place_circle_tan_chord
 *
 *------------------------------------------
 */

IGRlong CO_ni_place_circle_tan_chord(
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
   This function was written for the Place Circle Tangent to Element
   by Chord Definition command.  The following event information is 
   passed in:      Events[0] -- chord length or chord endpoint
                   Events[1] -- tangent point on element
   A circle will be constructed tangent to a given element and will
   be defined by a chord that is a defined angle from the tangent in
   a counterclockwise direction.  The Active Angle is used.                     
                                                                            

History
    jjc 10/10/89 : created

*/



{


    IGRboolean            b_status;
    struct IGRbsp_curve  *bspline_ptr,
                         *tmpcurve,
                         *circle; 
    IGRlong               size;
    IGRdouble             distance,
                          tanpoint[3],
                          uparm,
                          endpoint[3];
    IGRdouble             lnpoint1[3];
    IGRdouble             lnpoint2[3];
    IGRpoint              eval[2];
    IGRlong               localsize;
    IGRdouble             active_angle;
    IGRdouble             basis_tol;
    IGRdouble             scale;
    IGRdouble             mypi;
    IGRdouble             mymod;
    IGRdouble             dist_tol;
    IGRlong               NumberToRotate;
    struct IGRline        chordline;
    IGRlong               mynret;
    IGRvector             tanvec;
    IGRvector             tvec;
    IGRdouble             Zvector[3];
    IGRmatrix             OutMatrix;
    IGRdouble             tparm;
    IGRdouble             proj_point[3];
    struct var_list       VariableList[2];
    struct GRid           WindowGrid;   
    IGRlong               WhichError; 
    IGRmatrix             RotationMatrix;
    IGRdouble             rmat[3][3];
    IGRlong               BytesReturned;
    IGRlong               status = 1;         /* return code    */
    BSrc                  rc;

    *msg = MSSUCC;
 


      /*  declare memory for the circle
       */
      BSalloccv(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX, 1, NULL,
	        &circle, &rc);
      if (BSERROR(rc))
	  goto quit;


   
    /*  get the element from which the circle will be tangent.  first
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
    _m_debug_str( "COnicrchd - calling inq_set." );
    status = dp$inq_set_gragad(
                            msg = msg,
                            gragad_objid = WindowGrid.objid,
                            which_error = &WhichError,
                            var_list = VariableList );
    _m_check2p( status, *msg, "COnicrchd - failed inq_set_gragad." );
    _m_check2q( status, *msg );


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
                     msg    =  msg,
                     sizbuf = &localsize,
                     buffer = &basis_tol,
                     nret   = &mynret );
       _m_checkq(*msg);   
          

       if (( active_angle == 0.0 ) || ( mymod <= basis_tol )) {
             *msg = MSINARG;
             goto quit;
         } 


   /* get length of chord
    */
   if(Events[0]->response == DATA) {
     /* if data point was entered for endpoint of chord */

     /*  get the z vector for the view
      */
     Zvector[0]=0;
     Zvector[1]=0;
     Zvector[2]=1;

   /*  allocate  memory for the bspline curve that will be transformed to
    *  view coordinates
    */
   BSalloccv(bspline_ptr->order, bspline_ptr->num_poles, bspline_ptr->rational,
             NULL,&tmpcurve, &rc);
   if (BSERROR(rc))
      goto quit;

   /*  set up the 3X3 version of the RotationMatrix for BScvoton
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

   /*  other parms for BScvoton
    */
   tvec[0] = 0.0;
   tvec[1] = 0.0;
   tvec[2] = 0.0;
   scale   = 1.0;

   /*  convert the bspline curve that the circle will be tangent from
    *  to view coordinates
    */
   (void) BScvoton(&rc, tvec, rmat, &scale, bspline_ptr, tmpcurve);
   if (BSERROR(rc))
      goto quit;

   /*  evaluate the u parm to get the tangent point and the tangent vector
    *  in the view
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

    /*  create a rotation matrix that will rotate the tangent vector about
     *  the tangent point by the active angle
     */
    b_status = MAgrotmx( 
                      msg,
                      Zvector,
                      lnpoint1,
                     &active_angle,
                      OutMatrix );
    _m_check_boolq(b_status);


    /*  transform the endpoint using the matrix
     */
    NumberToRotate = 1;
    b_status = MAptsxform(
                msg,
               &NumberToRotate,
                OutMatrix,
                lnpoint2,
                lnpoint2 );
    _m_check_boolq(b_status);

    /*  the two points now represent the chord for the circle
     */
    chordline.point1 = lnpoint1;
    chordline.point2 = lnpoint2;

    /*  get the user defined endpoint for the chord
     */    
    endpoint[0]=Events[0]->event.button.x;
    endpoint[1]=Events[0]->event.button.y;
    endpoint[2]=Events[0]->event.button.z;

    /*  transform the point to view coordinates
     */
    b_status = MAptsxform(
                msg,
               &NumberToRotate,
                RotationMatrix,
                endpoint,
                endpoint );
    _m_check_boolq(b_status);

    /*  project the point onto the chord line 
     */
    b_status = MAptlnproj(
                msg,
                endpoint,
               &chordline,
                proj_point,
               &tparm );  
    _m_check_boolq(b_status);

    /*  calculate the length of the chord
     */
    b_status = MA2ptdis(
                msg,
                chordline.point1,
                proj_point,
               &distance );
    _m_check_boolq(b_status);

    }



   if(Events[0]->response == VALUE) {
     /* if value was entered for length of chord */
    
      distance = Events[0]->event.value;             
      
    }


   /*  call the function that will create the circle 
    *  note: sending in a one for the ccw flag.  the flag is only
    *  used for arcs, not circles.
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
                          circle );
    _m_check_boolq(b_status);
    _m_checkq(*msg);

    /*
     *  set up the object space of the new object and construct the circle
     */
    _m_debug_str( "CO_ni_place_circle_tan_chord - calling construct." );
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
                        geometry = circle,
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
                        geometry = circle,
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
              "CO_construct_circle_tan_chord-failed in co$construct object." );


    om$dealloc( ptr = bspline_ptr );
    om$dealloc( ptr = circle );
    om$dealloc( ptr = tmpcurve );

quit:
    return ( status );
}

end implementation Root;
