class implementation ASnode;
/*
   Ch    dec 87 :  update for the 1.1 release

   This is the implementation file for all the messages declared in
   ASnode.S dealing with macro.

*/


#include "AS_status.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "grerr.h"
#include "nddef.h"
#include "asbox.h"
#include "asmacros.h"
#include "ndmacros.h"

#define AS_DEBUG 1


method ACcompute_node( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *prop,*size_inst,*no_go;
			   char *inst_save)
{
int status,csize;

     status = om$send(msg =  message NDnode.NDcompute_node (msg,cn_type ,
					count,list, 
					md_env),
  		   targetid =my_id ); 
     as$status( );

/* note no_go is used only if defn contains object that change 
	number of graphic entities */

     if (!( (me->state) & ND_OUT_OF_RT)&& *no_go != -1 )
      {
      status = om$get_channel_count(object = me,
			       p_chanselect = &AS_to_comp,
			       count = (OMuint *)&csize);
      as$status();
      *no_go += csize;
      }

  return (  OM_S_SUCCESS );
}

end implementation ASnode;
	 
