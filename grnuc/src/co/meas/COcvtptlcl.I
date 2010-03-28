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
#include "csdef.h"
#include "csmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

from GRcoords import GRcvt_to_lcl_coords;

IGRint   COcvt_pts_to_lcl_coord(msg,
                                num_pts,
                                in_points,
                                out_points)
     IGRlong              *msg;
     IGRint                num_pts;
     IGRdouble            *in_points;
     IGRdouble            *out_points;
{
  struct GRid           active_cs;
  IGRlong               num_bytes;
  IGRlong               bytes_rec;
  IGRchar               cs_type[MAX_CS_TYPE];
  IGRlong               status;

  status = ex$get_cur_mod(id = &active_cs.objid,
			  osnum = &active_cs.osnum );
  
  status = cs$get_active_info(msg = msg,
			      osnum = active_cs.osnum,
			      objid = &active_cs.objid);
  
  num_bytes = MAX_CS_TYPE;
  gr$get_cs_type(msg = msg,
		 sizbuf = &num_bytes,
		 buffer = cs_type,
		 nret = &bytes_rec );
    
  status = om$send(msg = message GRcoords.GRcvt_to_lcl_coords(msg,
							      cs_type,
							      num_pts,
							      in_points,
							      out_points),
                   senderid = NULL_OBJID,
		   targetid = active_cs.objid,
		   targetos = active_cs.osnum);
  return(status);
}
end implementation Root;



