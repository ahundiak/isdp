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


#include "coimport.h"
#include "codebug.h"
#include "grerr.h"
#include "grmessage.h"
#include "codef.h"
#include "msdef.h"
#include "madef.h"
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
#include <stdio.h>


extern IGRdouble MAsin();
extern void      BSarctnfrcv();

/*------------------------------------------
 *  CO_create_circle_tan_chord
 *
 *  History:  jjc 10/27/89  created
 *
 *  Notes:  This routine is mainly a calling routine to BSarctnfrcv.
 *          If the arcept is NULL, a circle will be returned, else
 *          an arc.  
 *------------------------------------------
 */

IGRlong CO_create_circle_tan_chord(
                     msg,
                     bspline_ptr,
                     active_angle,
                     distance,                    
                     tanpoint,
                     uparm,
                     RotationMatrix,
                     arcept,
                     ccw,
                     circle )

    IGRlong              *msg;
    struct IGRbsp_curve  *bspline_ptr;
    IGRdouble            *active_angle,
                         *distance,
                         *tanpoint,
                         *uparm; 
    IGRdouble            *RotationMatrix;
    IGRpoint              arcept;
    IGRboolean            ccw;
    struct IGRbsp_curve  *circle;

{
IGRdouble  radius;
IGRdouble  mysine;
IGRlong    rc;

      /*  first calculate the radius of the circle.
       */
      mysine = MAsin(
               msg,
               active_angle);
      _m_checkq(*msg);   

      if (mysine == 0) {
         *msg = MSFAIL;
          goto quit;
        }

      radius = (*distance)/(2 * mysine);    


      /*  call Dieter's BS routine to give me the circle(or arc) 
       */ 
      BSarctnfrcv(
                  bspline_ptr,
                (*uparm),
                  radius,
                  RotationMatrix,
                  arcept,
                  ccw,
                  circle,
                 &rc );                   
      if(rc != 0) {
        *msg = MSFAIL;
         goto quit;
        }

quit:                    
   return(*msg);
}
