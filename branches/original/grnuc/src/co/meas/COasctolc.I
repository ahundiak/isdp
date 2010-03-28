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

from GRconic import GRgetarc;
from GRgencs import GRcsgetscale;
from GRgencs import GRgetmatrix;

IGRint  COcompute_acs_lcl_matrix(msg,
			         module_env_matrix_type,
				 module_env_matrix,
				 local_matrix_type,
				 local_matrix)
     IGRlong              *msg;
     IGRshort              module_env_matrix_type;
     IGRdouble            *module_env_matrix;
     IGRshort             *local_matrix_type;
     IGRdouble            *local_matrix;
{
  struct  GRid          active_cs;
  IGRmatrix             cs_matrix;
  IGRmatrix             tmp_matrix;
  IGRdouble             cs_scale[3];
  IGRshort              dim = 4;
  IGRint                CODrawviewActive = 0;
  IGRlong               status;

  status = ex$get_cur_mod(id = &active_cs.objid,
			  osnum = &active_cs.osnum );

  status = cs$get_active_info(msg = msg,
			      osnum = active_cs.osnum,
			      objid = &active_cs.objid);
  _m_check2q(status,*msg);

  /* extract matrix from active cs object */
  status = om$send(msg = message GRgencs.GRgetmatrix(msg,
						     cs_matrix),
                   senderid = NULL_OBJID,
		   targetid = active_cs.objid,
		   targetos = active_cs.osnum );
  _m_check2q(status,*msg);

  if(!CODrawviewActive)
    {
      /* extract scale factors from active cs object */
      status = om$send(msg = message GRgencs.GRcsgetscale(msg,
							  cs_scale),
		       senderid = NULL_OBJID,
		       targetid = active_cs.objid,
		       targetos = active_cs.osnum );
      _m_check2q(status,*msg);
      
      /* compute local matrix */
      cs_matrix[0] = cs_matrix[0] * cs_scale[0];
      cs_matrix[1] = cs_matrix[1] * cs_scale[1];
      cs_matrix[2] = cs_matrix[2] * cs_scale[2];
      
      cs_matrix[4] = cs_matrix[4] * cs_scale[0];
      cs_matrix[5] = cs_matrix[5] * cs_scale[1];
      cs_matrix[6] = cs_matrix[6] * cs_scale[2];
      
      cs_matrix[8] = cs_matrix[8] * cs_scale[0];
      cs_matrix[9] = cs_matrix[9] * cs_scale[1];
      cs_matrix[10] = cs_matrix[10] * cs_scale[2];
    }

  MAinvmx( msg, &dim, cs_matrix, tmp_matrix);
  MAmulmx(msg, &dim, &dim, &dim, tmp_matrix, module_env_matrix, local_matrix);
  MAtypemx(msg, local_matrix, local_matrix_type);

 quit:
  return(status);
}
end implementation Root;
