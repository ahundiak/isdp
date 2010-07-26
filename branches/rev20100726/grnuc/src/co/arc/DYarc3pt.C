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


/*----
%GR%
---- */
/*EH*/


#include "coimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "igrdef.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "madef.h"
#include "msdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "exdef.h"

struct dyn_arc 
{
  struct GRevent              ev; 
  struct GRevent             *ev_ptr[3]; 
  IGRshort                    cntr_clk;
  struct DPele_header         ele_buf;
}; 

DYarc3pt(arc_info,pt,mtx,objects,num_objects,buffers,num_buffers)

  struct dyn_arc             *arc_info;
  struct EX_button           *pt;
  IGRdouble                  *mtx;
  struct GRid                **objects;
  IGRint                     *num_objects;
  struct DPele_header        **buffers;
  IGRint                     *num_buffers;

{
  IGRboolean                  b_status;
  IGRlong                     status;
  IGRlong                     msg;
  IGRshort                    num_ev;
extern    IGRboolean    GRar3pt();

  arc_info->ev.event.button.x = pt->x;
  arc_info->ev.event.button.y = pt->y;
  arc_info->ev.event.button.z = pt->z;
  num_ev = 3;
  b_status = GRar3pt(&msg, 
                     arc_info->ev_ptr,
                    &num_ev,
                     arc_info->ele_buf.geometry.bspcurve);
  *num_buffers = (b_status & 1);
   status = (b_status & 1) ? MSSUCC:MSFAIL;
  *buffers = &arc_info->ele_buf;
   return(status);
}

IGRlong DYrbarc3pt( Events, dis_attr )
 struct GRevent               *Events[];
 struct IGRdisplay            *dis_attr;
{
   struct dyn_arc               arc_info;
   struct IGResbc               bsp_ele_spec;

   GRconic_declare(bspline, circle_arc_poles );
   GRconic_init(bspline, circle_arc_poles);


  bsp_ele_spec.is_polydis = FALSE;
  bsp_ele_spec.is_curvedis = TRUE;

  arc_info.ev=*Events[1];

  arc_info.ev_ptr[0] =  Events[0];
  arc_info.ev_ptr[1] =  Events[1];
  arc_info.ev_ptr[2] = &arc_info.ev;

  arc_info.ev.response = DATA;
  arc_info.ev.subtype = GRst_REGULAR;

  /*
   * build buffer for DYarccnt
   */

   dp$build_dis_buffer( buffer = &arc_info.ele_buf,
                        type = IGRBC,
                        display_att = dis_attr,
                        ele_spec_att = (struct IGResbc *)&bsp_ele_spec,
                        geometry = (struct IGRbsp_curve *)&bspline);

  dp$dynamics(dyn_fun = DYarc3pt,
              information = &arc_info);
  return(1);
}
