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
#include "OMminimum.h"
#include "OMprimitives.h"
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
#include "dpstruct.h"
#include "igrdef.h"
#include "dpmacros.h"


struct quartell_st
  { 
    struct DPele_header          elem;
    IGRdouble                    pts[6];
  };

/*-------------------------------------------------------------------
 *
 *    DYquartell: This function will generate a bspline curve to be
 *               used by the rubber banding functions.
 *
 *-------------------------------------------------------------------
*/
IGRint DYquartell(quartell_data,pnt3,mtx,objects,num_objects,buffers,
                  num_buffers,dummy1,dummy2,dummy3,dummy4,dummy5,dummy6)
  struct quartell_st   *quartell_data;
  struct EX_button    *pnt3;
  IGRdouble           *mtx;
  struct GRid         **objects;
  IGRint              *num_objects;
  struct DPele_header **buffers;
  IGRint              *num_buffers;
  IGRchar             *dummy1;
  IGRchar             *dummy2;
  IGRchar             *dummy3;
  IGRchar             **dummy4;
  IGRchar             **dummy5;
  IGRchar             **dummy6;
   {
     IGRboolean b_status;
extern    IGRboolean    MAeasmpsmconstr();
     IGRlong status;                    /*  return status       */
     IGRlong msg;                       /*  return message      */
     IGRdouble pt3[3];                  /*  point from getevent */
     /*
      * load 3rd point
      */
     pt3[0]=pnt3->x;
     pt3[1]=pnt3->y;
     pt3[2]=pnt3->z;
     /*
      * call math function to get bspline curve
      */
     b_status=MAeasmpsmconstr(&msg,
                           &quartell_data->pts[0],
                           &quartell_data->pts[3],
                           pt3,
                           quartell_data->elem.geometry.bspcurve);
     *num_buffers = (b_status & 1);
      status = (b_status & 1) ? MSSUCC:MSFAIL;
     *buffers = &quartell_data->elem;         /* add. of buffer             */
     return(status);
   }

/*-----------------------------------------------------------------------
 *
 *    Rubber Band Ellipse by center, axis point, and point on ellipse
 *
 *-----------------------------------------------------------------------
*/ 
IGRlong DYrbquartell( Events, dis_attr )

 struct GRevent             *Events[];
 struct IGRdisplay *dis_attr;
 {


  struct quartell_st quartell_data;
  struct IGRbsp_curve bspline;
  IGRdouble                    pole_buff[21];  /* stub poles for bspline  */
  IGRdouble                    weight_buff[10];/* stub weights for bspline */
  IGRdouble                    knot_buff[21];  /* stub knots for bspline  */
  struct IGResbc               bsp_ele_spec;

  /*
   * load axis point 1
   */
  bsp_ele_spec.is_polydis = FALSE;
  bsp_ele_spec.is_curvedis = TRUE;
  bspline.poles = pole_buff;         
  bspline.knots = knot_buff;
  bspline.weights = weight_buff;
  quartell_data.pts[0]=Events[0]->event.button.x;
  quartell_data.pts[1]=Events[0]->event.button.y;
  quartell_data.pts[2]=Events[0]->event.button.z;

  /*
   * load axis 2
   */
  quartell_data.pts[3]=Events[1]->event.button.x;
  quartell_data.pts[4]=Events[1]->event.button.y;
  quartell_data.pts[5]=Events[1]->event.button.z;

  dp$build_dis_buffer( buffer = &quartell_data.elem,
                       type = IGRBC,
                       display_att = dis_attr,
                       ele_spec_att = (struct IGResbc *)&bsp_ele_spec,
                       geometry = (struct IGRbsp_curve *)&bspline);
  
  /*
   * call dynamics function
   */
  dp$dynamics(dyn_fun = DYquartell,
              information = &quartell_data);
  return(1);
 }
