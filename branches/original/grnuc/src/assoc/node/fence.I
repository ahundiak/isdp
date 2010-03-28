class implementation NDnode;
/*  
  Implementation of the  batch mode of the graph manager 
*/

#include "OMminimum.h"
#include "OMmacros.h"
#include "GMerrordef.h" 
#include "GMdef.h"
#include "GMhcode.h"
#include "nddef.h"
#include "GMmacros.h" 
#include "ndmacros.h" 
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
/*#include "batch.h"*/
#include "AS_status.h"
#include "madef.h"
#include "exdef.h"
#include "exmacros.h"
#include "ASmessages.h"
#include "msmacros.h"

from GRgraphics
  import
  GRcopy;

extern GRclassid OPP_ASnode_class_id,
		 OPP_ASsource_class_id;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function NDcopy_fence                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDcopy_fence(l_object, nb_object, p_nbcop, p_fr_env, p_to_env, dynamics, xform)

  struct GRid  *l_object;     /* IN/OUT List of objects to copy/copied objects*/
  int          nb_object;     /* IN     Number of objects to copy             */
  struct GRmd_env *p_fr_env;  /* IN     Environment of the initial objects    */
  struct GRmd_env *p_to_env;  /* IN     Environment used to copy              */
  int          xform;         /* IN     Flag = TRUE if used for xform dynamic */
  int          dynamics;      /* IN     Flag = TRUE if copy for dynamcis      */
  int          *p_nbcop;      /* OUT    Number of objects copied              */
  /*.NDcopy_fence*/
  {
  struct GRid  *l_assoc=NULL; /* List of associative objects to copy          */
  int          nb_assoc=0;    /* Number of associative objects to copy        */
  int          s_lassoc=0;    /* Size of this list                            */
  long         status;        /* Status returned by the function              */
  int          ind;           /* Index for a loop                             */
  long         msg;           /* Return code of messages                      */
  struct GRid  null_grid;     /* Null grid                                    */
  struct GRid  as_obj;        /* Associative object to copy                   */
  struct GRid  copy;          /* Resultant copy of an object                  */
  OMuword      class_id;      /* Class identifier of an object                */
  struct NDcp_struct clone;   /* List of copied arguments	              */
 
  null_grid.objid = NULL_OBJID;
  null_grid.osnum = 0;
  *p_nbcop = 0;
  clone.list = NULL;

  for(ind=0; ind< nb_object; ind++)
    {
    /*| Test source objects */

    status= ASget_source(&l_object[ind],&null_grid,&as_obj,l_object[ind].osnum);

    if(IF_NULL_OBJID(as_obj.objid))
      {
      /*| Test assoc objects */

      status = om$get_classid
                 (objid = l_object[ind].objid,
                  osnum = l_object[ind].osnum,
                  p_classid = &class_id);

      if(om$is_ancestry_valid(subclassid = class_id,
        superclassid = OPP_ASnode_class_id) == OM_S_SUCCESS)
        as_obj = l_object[ind];
    }/* if(IF_NULL_OBJID)*/

    if(!IF_NULL_OBJID(as_obj.objid))
      {
      /*" %d.%d is an associative object",l_object[ind].objid,l_object[ind].osnum*/

      if(!l_assoc)
        {
        /*| Allocate the temporary list */

        s_lassoc = nb_object-ind;
        if(s_lassoc > GMH_DEF_SIZE) s_lassoc = GMH_DEF_SIZE;
        l_assoc  = (struct GRid *)malloc(s_lassoc*sizeof(struct GRid));
        if(!l_assoc) return OM_W_ABORT;
      }/* if(!l_assoc)*/

      if(nb_assoc >= s_lassoc)
        {
        /*| Reallocate the temporary list */

        s_lassoc *= 2;
        l_assoc  = (struct GRid *)realloc(l_assoc,s_lassoc*sizeof(struct GRid));
        if(!l_assoc) return OM_W_ABORT;
      }/* if(!l_assoc)*/

      /*" Put this object in the assoc list\n",l_object[ind].objid,l_object[ind].osnum*/

      l_assoc[nb_assoc++] = as_obj;
      }
    else
      {
      /*| Copy the graphic object */

      status = om$send
                (msg      = message GRgraphics.GRcopy
                            (&msg, p_fr_env, p_to_env, &copy.objid),
		 senderid = NULL_OBJID,
		 targetid = l_object[ind].objid,
		 targetos = l_object[ind].osnum);
      as$status(action = GOTO_VALUE, value = exception);

      /*| Update the copy list */

      l_object[*p_nbcop].objid = copy.objid;
      l_object[*p_nbcop].osnum = p_to_env->md_id.osnum;
      (*p_nbcop)++;
    }/* if */
  }/* end for */

  if(l_assoc)
    {
    if(xform)
      {
      /*| Get the complete graph */

      status = nd$get_graph
                 (p_initial = l_assoc,
                  nb_initial = nb_assoc);
      as$status(action = GOTO_VALUE, value = exception);
      }
    else
      {
      /*| Get the internal graph */

      status = nd$get_internal_graph
                 (p_initial  = l_assoc,
		  nb_initial = nb_assoc);
      as$status(action = GOTO_VALUE, value = exception);
    }/* end if(l_assoc)*/

    /*| Copy the graph moving the graph's roots to roots */

    status = nd$copy_graph
               (from_info  = p_fr_env,
	        to_info    = p_to_env,
	        p_clone	   = &clone);
    as$status(action = GOTO_VALUE, value = exception);

    /*| Get the associative clones (for root only) */

    for(ind=0; ind < clone.nb_obj; ind++)
      {
      if(clone.list[ind].position & ND_ROOT)
        {
        /*| Add the graphic object in the list */
	status = om$get_classid(objid = clone.list[ind].clone,
				osnum = p_to_env->md_id.osnum,
				p_classid = &class_id);
	if(om$is_ancestry_valid(superclassid = OPP_ASsource_class_id,
				subclassid = class_id) == OM_S_SUCCESS)
	 {
          status = om$send
                   (msg = message NDnode.ASreturn_go(&(l_object[*p_nbcop]),0,0),
                    senderid = NULL_OBJID,
                    targetid = clone.list[ind].clone,
                    targetos = p_to_env->md_id.osnum);
	 }
	else 
         {
	  l_object[*p_nbcop].objid = clone.list[ind].clone;
	  l_object[*p_nbcop].osnum = p_to_env->md_id.osnum; 
	 }
        (*p_nbcop)++;
        }
      else if(dynamics)
        {
        /*| Change the properties of this element */

        status = om$send
                  (msg = message NDnode.NDchg_state(ND_SUP_ONLY,ND_SUP_ONLY),
                   senderid = NULL_OBJID,
                   targetid = clone.list[ind].clone,
                   targetos = p_to_env->md_id.osnum);
      }/* end if */
      as$status(action = GOTO_VALUE, value = exception);
    }/* while */  

exception:
    if(clone.list) om$dealloc(ptr = clone.list);  
    if(l_assoc) free(l_assoc);
  }/* if(l_assoc)*/
  
  return status;
}/* end NDcopy_fence */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation NDnode;
