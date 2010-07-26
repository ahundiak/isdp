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


from IGEgragad import DPinrot;

struct block_st
  { 
    struct DPele_header          elem;
    IGRdouble                    pts[3];
    IGRdouble                    dirv[3];
  };
/*-------------------------------------------------------------------
 *
 *    DYblock: This function will generate a bspline curve to be
 *               used by the rubber banding functions.
 *
 *-------------------------------------------------------------------
*/
IGRint DYblock(block_data,pnt2,mtx,objects,num_objects,buffers,num_buffers,
                       dummy1,dummy2,dummy3,dummy4,dummy5,dummy6)
  struct block_st     *block_data;
  struct EX_button    *pnt2;
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
     IGRlong status;                    /*  return status       */
     IGRlong msg;                       /*  return message      */
     IGRdouble diag2[3];                  /*  point from getevent */
extern    IGRboolean    MA2ptrcconstr();
     /*
      * load 2st point
      */
     diag2[0]=pnt2->x;
     diag2[1]=pnt2->y;
     diag2[2]=pnt2->z;

     /*
      * call math function to get bspline curve
      */
     b_status=MA2ptrcconstr(&msg,
                         &block_data->pts[0],
                          diag2,
                         &block_data->dirv[0],
                          block_data->elem.geometry.bspcurve);
     *num_buffers = (b_status & 1);
      status = (b_status & 1) ? MSSUCC:MSFAIL;
     *buffers = &block_data->elem;         /* add. of buffer             */
     return(status);
   }


/*-----------------------------------------------------------------------
 *
 *                Rubber Band Block 
 *
 *-----------------------------------------------------------------------
*/ 
IGRlong DYrbblock( Events, dis_attr )

 struct GRevent             *Events[];
 struct IGRdisplay *dis_attr;
 
 {
  struct block_st              block_data;
  struct IGRbsp_curve          bspline;
  IGRdouble                    pole_buff[15];  /* stub poles for bspline  */
  IGRdouble                    knot_buff[15];  /* stub knots for bspline  */
  struct IGResbc               bsp_ele_spec;
  IGRlong                      status;       /* return code                  */
  IGRmatrix                    rot_matrix;   /* rotation mtx from view  */
  IGRlong                      msg;                 /*  return message      */

  /*
   * load diag point 1
   */
  bsp_ele_spec.is_polydis = FALSE;
  bsp_ele_spec.is_curvedis = TRUE;
  bspline.poles = pole_buff;         
  bspline.knots = knot_buff;
  block_data.pts[0]=Events[0]->event.button.x;
  block_data.pts[1]=Events[0]->event.button.y;
  block_data.pts[2]=Events[0]->event.button.z;

  /*
   * load directional vector
   */
   status = om$send(msg = message IGEgragad.DPinrot(&msg,rot_matrix),
                      senderid = NULL_OBJID,
                      targetid = Events[0]->event.button.objid,
                      targetos = Events[0]->event.button.osnum );
   block_data.dirv[0] = rot_matrix[4];
   block_data.dirv[1] = rot_matrix[5];
   block_data.dirv[2] = rot_matrix[6];

   dp$build_dis_buffer( buffer = &block_data.elem,
                        type = IGRBC,
                        display_att = dis_attr,
                        ele_spec_att = (struct IGResbc *)&bsp_ele_spec,
                        geometry = (struct IGRbsp_curve *)&bspline);

  /*
   * call dynamics function
   */
  dp$dynamics(dyn_fun =  DYblock,
              information = &block_data);
  return(1);
 }
end implementation Root;
