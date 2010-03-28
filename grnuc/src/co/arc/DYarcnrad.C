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
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

struct dyn_arc 
{
  struct GRevent              ev[4]; 
  struct GRevent             *ev_ptr[4]; 
  IGRshort                    cntr_clk;
  struct DPele_header         ele_buf;
}; 

DYarccntrad(arc_info,pt,mtx,objects,num_objects,buffers,num_buffers)

  struct dyn_arc               *arc_info;
  struct EX_button             *pt;
  IGRdouble                    *mtx;
  struct GRid                  **objects;
  IGRint                       *num_objects;
  struct DPele_header          **buffers;
  IGRint                       *num_buffers;

{
  IGRboolean                    b_status;
  IGRlong                       status; 
  IGRlong                       msg;
  IGRshort                      num_ev;
extern    IGRboolean    GRarcnradpts();

  arc_info->ev[3].event.button = *pt;
  num_ev = 4;
  b_status = GRarcnradpts(&msg, 
                         arc_info->ev_ptr,
                        &num_ev,
                        &arc_info->cntr_clk, 
                         arc_info->ele_buf.geometry.bspcurve);

  *num_buffers = (b_status & 1) ;
  *buffers = &arc_info->ele_buf;
  status = (b_status & 1) ? MSSUCC:MSFAIL;
  return(status);
}

IGRint DYrbarccntrad(Events, dis_attr )

 struct GRevent               *Events[];
 struct IGRdisplay            *dis_attr;

{
  struct dyn_arc               arc_info;
  struct IGResbc               bsp_ele_spec;
  IGRlong                      status;       /* return code                  */
  IGRlong                      msg;          /*  return message      */
  IGRlong                      NumberOfBytes;
  IGRlong                      BytesReceived;

  GRconic_declare(bspline, circle_arc_poles );
  GRconic_init(bspline, circle_arc_poles);

  /* load pnt 1   */
  bsp_ele_spec.is_polydis = FALSE;
  bsp_ele_spec.is_curvedis = TRUE;

  NumberOfBytes = sizeof(arc_info.cntr_clk);
  status = gr$get_arc_direction(msg = &msg,
                                sizbuf = &NumberOfBytes,
                                buffer = &arc_info.cntr_clk,
                                nret = &BytesReceived );
  arc_info.ev[0]=*Events[1];
  arc_info.ev[1]=*Events[0];
  arc_info.ev[2]=*Events[2];
  arc_info.ev[3]=*Events[2];

  arc_info.ev_ptr[0] = &arc_info.ev[0];
  arc_info.ev_ptr[1] = &arc_info.ev[1];
  arc_info.ev_ptr[2] = &arc_info.ev[2];
  arc_info.ev_ptr[3] = &arc_info.ev[3];

  arc_info.ev[3].response = DATA;
  arc_info.ev[3].subtype = GRst_REGULAR;

   /*
    * build buffer for DYarccnt
    */
   dp$build_dis_buffer( buffer = &arc_info.ele_buf,
                        type = IGRBC,
                        display_att = dis_attr,
                        ele_spec_att = (struct IGResbc *)&bsp_ele_spec,
                        geometry = (struct IGRbsp_curve *)&bspline);

  dp$dynamics(dyn_fun =  DYarccntrad,
              information = &arc_info);
  return(1);
}
