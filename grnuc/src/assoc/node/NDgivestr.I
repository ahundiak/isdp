/*

Name
  NDgivestr.I

Description
  function interfaces for ND methods.
Notes


 */

/*

Name
  NDgive_struct

Abstract
  This is a function wrapper for the NDgive_struct method.

Synopsis
  NDgive_struct( &msg, p_expr_id, &rst, &md_env );
  See NDnode.S for details about the NDgive_struct message.

Description
   long              *msg         (OUT)
   struct GRid       *p_expr_id   (IN )
   struct ret_struct *rst         (OUT)
   struct GRmd_env   *md_env      (OUT)

Return Value
  The return code is the one returned by the om$send of the NDgive_struct
  to the *p_expr_id object.
  
Notes

Index

Keywords

History
  07/01/93 : Shelley R. Heard : created

 */
class implementation NDnode;

#include "OMmacros.h"
#include "godef.h"
#include "grerr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "madef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "batch.h"
#include "csdef.h"
#include "griodef.h"
#include "grcoordsys.h"


long NDgive_struct( msg, p_expr_id, rst, md_env )
  long              *msg;
  struct GRid       *p_expr_id;
  struct ret_struct *rst;
  struct GRmd_env   *md_env;
{
  long status = OM_S_SUCCESS;

  status=om$send( msg = message NDnode.NDgive_structure( msg, rst, md_env),
                  senderid = NULL_OBJID,
                  targetid = p_expr_id->objid,
                  targetos = p_expr_id->osnum );

  return (status);
}

end implementation NDnode;
