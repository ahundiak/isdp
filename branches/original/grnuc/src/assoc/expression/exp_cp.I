/*###########################################################################
/*
/* The methods in the file are overides in support of equational constraints.
/* 
/*
/*  Initial revision: Kapil Singh
/*
/*
/*--------------------------------------------------------------------------*/
class implementation expression;

/*  */

#include <tools.h>
#include <stdio.h> 
#include <string.h> 
#include <OMminimum.h>
#include <OMmacros.h>
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "expression.h"
#include "expmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMindex.h"
#include "nddef.h"
#include "asbox.h"
#include "AS_status.h"
#include "gocmacros.h"
#include "exmacros.h"
%safe
#include "math.h"
%endsafe
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "referr.h"
#include "ASmessages.h"
#include "msmacros.h"

method NDcopy(IGRlong *msg; IGRint cp_type;
	      struct GRmd_env *obj_env,*new_env;
	      struct GRid *newobjid)
{
  int   status;
  char	exp_syntax[EXP_MAX_LEN];
  char  original_index[20], new_index[20];
  
  *msg = MSFAIL;
  newobjid->osnum = new_env->md_id.osnum;
  status = om$construct_and_copy(object  = me,
				 osnum   = new_env->md_id.osnum,
				 p_objid = &newobjid->objid);
  as$status(action = RET_STATUS);
 
  status = om$send(msg = message expression.give_syntax (exp_syntax),
          	   targetid = newobjid->objid);
  as$status(action = RET_STATUS);

  sprintf(original_index, "\\%lu", my_id);
  sprintf(new_index, "\\%lu", newobjid->objid);

  status = EXPsubstitute( original_index, new_index, exp_syntax);
  as$status(action = RET_STATUS);

  status = EXPsubstitute("\\", "\\\\", exp_syntax);
  as$status(action = RET_STATUS);

  sprintf(original_index, "\\\\%lu", newobjid->objid);

  status = EXPsubstitute(original_index, new_index, exp_syntax);
  as$status(action = RET_STATUS);

  *msg = MSSUCC;
  return(status);
}


method NDnotify_connect(struct GRid new_connected)
{
  long status;
  struct GRid my_grid;
    
  status = om$send ( msg = message NDnode.NDnotify_connect (new_connected),
           mode = OM_e_wrt_message, targetid = my_id );
  as$status(action = RET_STATUS);


 
  return(OM_S_SUCCESS);
}

end implementation expression ;
