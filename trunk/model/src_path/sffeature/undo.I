/*
 OVERVIEW

 APIs for undoing states in a feature tree.


 HISTORY

 Aditya  04/19/96   Creation
*/

class implementation Root;

#include <alloca.h>
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "EMSdef.h"

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWerror.h"
#include "PWapi/clsid.h"
#include "PWapi/undo.h"
#include "PWapi/featquery.h"

#define BUFFER_SIZE 10

from EMSdpr import EMundo, EMget_dpr_props;

extern OMuword OPP_EMSdpr_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMSsubbs_class_id;

extern IGRlong EMmake_chanselect(IGRint,OM_S_CHANSELECT *);

%safe
static PWboolean valid_feature_state
(
  PWobjid feature_id,
  PWosnum os
);

static PWboolean is_feature_state
(
  PWobjid feature_id,
  PWosnum os
);

static PWboolean is_feature_in_active_path
(
  PWobjid feature_id,
  PWosnum os
);

static PWboolean is_target_in_tree
(
  PWobjid feature_id,
  PWosnum os,
  PWobjid target_id
);
%endsafe

/*
  DESCRIPTION

  This API deletes feature states in a feature tree, given the id of the
  topmost (latest) feature state. Multiple states from the top of the
  tree can be undone by specifying 'levels_to_undo'. Undoing states in
  the tree might result in other free feature trees. The number of top 
  nodes of the resulting trees and their objids are returned in num_top_owners
  and the array top_owners respectively.

  This API is useful when the caller wants to undo a known finite number
  number of states, from the latest state. All the branches of the feature
  tree upto the level specified are affected. 

  If the caller wishes to undo the feature tree completely, to be left with
  just the primitives, the levels_to_undo can be specified as 'MAXINT'
  (defined in <values.h>), which will definitely be more than the total 
  depth of the tree.


  ARGUMENTS

  PWobjid feature_id           -I : Topmost state of the feature tree.
  PWosnum os                   -I : OS number of the feature tree.
  int levels_to_undo           -I : Number of states to be undone.
  int *num_top_owners          -O : Number of free feature trees after undo.
                                    NULL, if not interested.
  PWobjid **top_owners         -O : Objids of the top states of the free
                                    feature trees. NULL, if not interested.
                                    When this is non-NULL, so must 
                                    num_top_owners be.
                         

  RETURN VALUE

  PWresult
  PW_K_Success       - Operation completed successfully.
  PW_K_InvalidArg    - Invalid arguments passed to the function.
  PW_K_DynamicMemory - Function couldn't allocate sufficient memory.
  PW_K_Error         - An internal error occurred.


  NOTES

  Memory for the active trees objids (in top_owners) is allocated by the
  API. It is the responsibility of the caller to free the memory.
 

  HISTORY

  Aditya   04/23/1996   Creation.
*/

PWresult pwUndoFeatureTree
(
  PWobjid feature_id,
  PWosnum os,
  int levels_to_undo,
  int *num_top_owners,
  PWobjid **top_owners
)
{
  PWboolean reset_os=FALSE;
  PWresult PWsts=PW_K_Success;
  PWobjid *free_nodes=NULL;
  PWosnum save_os;

  int sts=1, num_free=0, size=0;
  int cnt=0, buff_size=0, num_free_nodes=0;
  long msg=EMS_S_Success;
  unsigned short options=0;

  struct GRmd_env md_env;
  struct GRid *free_tree=NULL;

  /*
   * Switch OS.
   */
  if((save_os = pwGetActiveOs()) != os)
  {
    sts = pwActivateOS(os);
    OnErrorState ( !(1&sts), PWsts,
                   SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

    reset_os = TRUE;
  }

  sts = pwGetActiveModuleEnv( &md_env);
  OnErrorState( !(1&sts), PWsts,
                SetError( PW_K_Pathway, PW_K_Error), wrapup);

  sts = valid_feature_state(feature_id, os);
  OnErrorState( !(1&sts), PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), 
   wrapup);

  /*
   * Passing levels_to_undo as 0 is not a crime and not an invalid arg. Just
   * give back the caller the input feature id. But we stil have to allocate
   * space for 1 objid.
   */

  if(!levels_to_undo)
  {
    if (num_top_owners)
      *num_top_owners = 1;

    if (num_top_owners && top_owners)
    {
      *top_owners = (PWobjid *) malloc( sizeof(PWobjid));
      OnErrorState( !(*top_owners), PWsts, 
       SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);

      (*top_owners)[0] = feature_id;
    }
    goto wrapup;
  }

  if (num_top_owners && top_owners)
  {
    size = BUFFER_SIZE;
    *top_owners = (PWobjid *) malloc(size * sizeof(PWobjid));
    OnErrorState(!(*top_owners), PWsts, 
     SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);
  }

  if (num_top_owners)
    *num_top_owners = 0;

  options = EMS_GET_ACTIVE_STATES | EMS_UNDO_DELETE;

  /*
   * Call this function to undo one state.
   */
  sts = om$send (msg = message EMSdpr.EMundo( &msg, &options,
                                              &md_env, &free_tree,
                                              &num_free, &buff_size,
                                              NULL, NULL, NULL),
                 senderid = PW_K_NullObjid,
                 targetid = feature_id,
                 targetos = os);
  OnErrorState(!(1 & msg & sts), PWsts, SetError (PW_K_Pathway, PW_K_Error),
   wrapup);

  for(cnt=0; cnt<num_free; cnt++)
  {
    if(valid_feature_state(free_tree[cnt].objid, os))
    {
      /*
       * This is the top_owner of a feature branch. Send down the
       * message to undo 'levels_to_undo-1' levels of this branch.
       */
      PWsts = pwUndoFeatureTree( free_tree[cnt].objid, os, levels_to_undo-1,
                                  &num_free_nodes, &free_nodes);
      OnErrorCode(PWsts, wrapup);

      if (num_top_owners && top_owners)
      {
        if((*num_top_owners + num_free_nodes) > size)
        {
          /*
           * This magic because of the possibilty that num_free_nodes
           * might be greater than BUFFER_SIZE.
           */
          size = size + ((num_free_nodes/BUFFER_SIZE)+1) * BUFFER_SIZE;

          *top_owners = (PWobjid *) realloc(*top_owners, size);
          OnErrorState(!(*top_owners), PWsts, 
           SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);
        }
      }

      /*
       * Copy the free_nodes into the top_owners array. What we have at
       * this stage are the final nodes ready to be returned to the caller.
       */

      if (num_top_owners && top_owners)
        memcpy(((*top_owners)+(*num_top_owners)), free_nodes,
               num_free_nodes*sizeof(PWobjid));

      if (num_top_owners)
        *num_top_owners += num_free_nodes;

      if(free_nodes) free(free_nodes);
      free_nodes = NULL;
      num_free_nodes = 0;
    }
    else
    {
      if (num_top_owners && top_owners)
      {
        if((*num_top_owners) > size)
        {
          size += BUFFER_SIZE;

          *top_owners = (PWobjid *) realloc(*top_owners, size);
          OnErrorState(!(*top_owners), PWsts, 
           SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);
        }
  
        (*top_owners)[*num_top_owners] = free_tree[cnt].objid;
      }

      if (num_top_owners)
        (*num_top_owners)++;
    } /* if not feature state */
  }

wrapup:
  /*
   * Switch back to original OS.
   */
  if(reset_os)
  {
    sts = pwActivateOS(save_os);
    if(!(1&sts))
      PWsts = SetError( PW_K_Pathway, PW_K_Error);
  }

  if(free_tree) free(free_tree);
  if(free_nodes) free(free_nodes);

 return(PWsts);
}


/*
  DESCRIPTION

  This API deletes feature states in a feature tree, given the id of the
  topmost (latest) feature state and the target_feature upto which features
  are to be undone. All the states that lie in the path from the 
  'feature_id' to the target_id (including target_id) are undone.
  Undoing states in the tree might result in other free feature trees. 
  The number of top nodes of the resulting trees and their objids are
  returned in num_top_owners and the array top_owners respectively.

  This API is useful when the caller wants to undo a branch of the
  feature tree, undoing only those states that are dependent on 
  target_id.


  ARGUMENTS

  PWobjid feature_id           -I : Topmost state of the feature tree.
  PWosnum os                   -I : OS number of the feature tree.
  PWobjid target_id            -I : Feature state upto (and incl) which
                                    the feature tree is to be undone.
  int *num_top_owners          -O : Number of free feature trees after undo.
                                    NULL, if not interested.
  PWobjid **top_owners         -O : Objids of the top states of the free
                                    feature trees. NULL, if not interested.
                                    When this is non-NULL, so must 
                                    num_top_owners be.


  RETURN VALUE

  PWresult
  PW_K_Success       - Operation completed successfully.
  PW_K_InvalidArg    - Invalid arguments passed to the function.
  PW_K_DynamicMemory - Function couldn't allocate sufficient memory.
  PW_K_Error         - An internal error occurred.
 

  NOTES

  It is necessary that the feature_id is the latest feature state. An
  error condition occurs if target_id is not a state in the tree 
  represented by feature_id.

  Memory for the active trees objids (in top_owners) is allocated by the
  API. It is the responsibility of the caller to free the memory.
 

  HISTORY

  Aditya   04/23/1996   Creation.
*/

PWresult pwUndoFeatTreeUntilObjid
(
  PWobjid feature_id,
  PWosnum os,
  PWobjid target_id,
  int *num_top_owners,
  PWobjid **top_owners
)
{
  IGRint sts=1, inx=0, num_free=0, buff_size=0;
  IGRlong msg=EMS_S_Success;
  unsigned short options=0;

  PWresult  PWsts=PW_K_Success;
  PWboolean reset_os=FALSE;
  PWosnum   save_os;


  struct GRmd_env md_env;
  struct GRid *free_tree=NULL;

  /*
   * Switch OS.
   */
  if((save_os = pwGetActiveOs()) != os)
  {
    PWsts = pwActivateOS(os);
    OnErrorState ( !(1&PWsts), PWsts,
                   SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

    reset_os = TRUE;
  }

  sts = pwGetActiveModuleEnv( &md_env);
  OnErrorState( !(1&sts), PWsts,
                SetError( PW_K_Pathway, PW_K_Error), wrapup);

  OnErrorState(!(valid_feature_state(feature_id, os)),
               PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  /*
   * Check if the target is a feature in the active path of a
   * feature tree. But we still have to verify that it is a feature
   * in the tree topped with feature_id.
   */
  OnErrorState( !(is_feature_state(target_id, os) &&
                 is_feature_in_active_path(target_id, os)),
                 PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  OnErrorState(!is_target_in_tree(feature_id, os, target_id),
               PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

  options = EMS_GET_ACTIVE_STATES | EMS_UNDO_DELETE;

  /*
   * Call this function on the target state.
   */
  sts = om$send (msg = message EMSdpr.EMundo( &msg, &options,
                                              &md_env, &free_tree,
                                              &num_free, &buff_size,
                                              NULL, NULL, NULL),
                 senderid = PW_K_NullObjid,
                 targetid = target_id,
                 targetos = os);
  OnErrorState(!(1 & msg & sts), PWsts, 
   SetError (PW_K_Pathway, PW_K_Error), wrapup);

  if (num_top_owners && top_owners)
  {
    *top_owners = (PWobjid *) malloc(num_free * sizeof(PWobjid));
    OnErrorState(!(*top_owners), PWsts, 
     SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);

    for(inx=0; inx<num_free; inx++)
      (*top_owners)[inx] = (free_tree+inx)->objid;
  }

  if (num_top_owners)
    *num_top_owners = num_free;

wrapup:
  /*
   * Switch back to original OS.
   */
  if(reset_os)
  {
    sts = pwActivateOS(save_os);
    if(!(1&sts))
      PWsts = SetError( PW_K_Pathway, PW_K_Error);
  }

  return(PWsts);
}



/*---------------------- STATIC FUNCTIONS ---------------------------------*/

static PWboolean is_feature_state
(
  PWobjid feature_id,
  PWosnum os
)
{
  return(pwIsFeatureState( feature_id, os, NULL));
}

static PWboolean is_feature_in_active_path
(
  PWobjid feature_id,
  PWosnum os
)
{
  unsigned short props=0;
  long msg=EMS_S_Success;
  int sts=1;

  PWresult PWsts=PW_K_Success;

  /*
   * Check if the feature is in the active path of the dpr tree.
   */
  sts = om$send(msg = message EMSdpr.EMget_dpr_props( &msg, &props),
                senderid = PW_K_NullObjid,
                targetid = feature_id,
                targetos = os);
  OnErrorState(!(1 & msg & sts), PWsts, 
   SetError (PW_K_Pathway, PW_K_Error), wrapup);

  OnErrorState(!(props & EMSIS_ACTIVE_PATH), PWsts, 
   SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

wrapup:

 if(IsError(PWsts)) return(FALSE);

 return(TRUE);

}

static PWboolean valid_feature_state
(
  PWobjid feature_id,
  PWosnum os
)
{
   return( is_feature_state(feature_id, os)  &&
           pwIsFeatureActive(feature_id, os) &&
           is_feature_in_active_path(feature_id, os));
}

static PWboolean is_target_in_tree
(
  PWobjid feature_id,
  PWosnum os,
  PWobjid target_id
)
{
  PWresult PWsts=PW_K_Success;
  OM_S_OBJECT_LINKAGE *p_comps=NULL;

  OM_S_CHANSELECT to_comps;
  int num_comps=0, sts=1, inx=0;

  sts = EMmake_chanselect( GRcmpowner_to_components, &to_comps);
  OnErrorState(!(1&sts), PWsts, SetError (PW_K_Pathway, PW_K_Error), wrapup);
  
  /*
   * Look no further if the target_id is on the components channel.
   * Else go ahead, get the objects on the channel and search down
   * every branch.
   */
  sts = om$is_objid_on_channel( osnum_c = os,
                                objid_c = feature_id,
                                p_chanselect = &to_comps,
                                objid = target_id,
                                osnum2 = os );
  if(1&sts) return(TRUE);

  sts = om$get_channel_count( osnum = os,
                              objid = feature_id,
                              p_chanselect = &to_comps,
                              count = (unsigned int *)&num_comps );
  OnErrorState(!(1&sts) || !num_comps, PWsts, 
   SetError (PW_K_Pathway, PW_K_Error), wrapup);

  p_comps = (OM_S_OBJECT_LINKAGE *)
            alloca(num_comps * sizeof(OM_S_OBJECT_LINKAGE));
  OnErrorState(!p_comps, PWsts, SetError (PW_K_Pathway, PW_K_Error), wrapup);

  sts = om$get_channel_objects( objid = feature_id,
                                osnum =  os,
                                p_chanselect =  &to_comps,
                                list = p_comps,
                                size = num_comps,
                                count = (unsigned int *)&num_comps);
  OnErrorState(!(1&sts), PWsts, SetError (PW_K_Pathway, PW_K_Error), wrapup);

  for(inx=0; inx<num_comps; inx++)
    if(is_target_in_tree(p_comps[inx].S_objid, os, target_id)) 
       return(TRUE);

wrapup:
  if(IsError(PWsts)) return(FALSE);

  return(TRUE);
}

end implementation Root;
