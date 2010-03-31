/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;

#include "asbox.h"    /* For NULL_GRID */
#include "nddef.h"    /* For ND_NC_NEW */
#include "asmacros.h" /* For as$make_source */
#include "emserr.h"
#include "EMSasdef.h" /* For EMS_no_const_assoc */

#include "actparam.h"


from EMSidentity import EMinit;
extern OMuword OPP_EMSidentity_class_id;

static IGRboolean aflag;
static GRspacenum osn;

method EMmake_source(IGRlong               *EMmsg;
                     IGRushort     options;
                     IGRint                num_parents;
                     struct EMSobject_info *parents;
                     struct GRid           *src_parents)
/*
Description
  This method constructs the source objects for each parent and returns the 
  list via src_parents.

Notes
  It is assumed that src_parents is already allocated since its size is
  num_parents which is known at send time.

  Some parents do not need source object and therefore appear in the
  src_parents array 'as is'.  

  The src_parents array is allocated via 

History
    WBC     12/27/93    Check to see if the module environment, as well as the
                        object id and object space number, are the same before
                        creating an EMSidentity object. (TR#119307149)
    PP      07/17/91    Modified to use GRmksource message.
    PP      06/08/91    Modified to support the same object being connected
                        multiple times on the father channel.
    PP      05/15/91    Modified to allow construction of indirection objects
                        when connecting to components of solid.
    DLB     05/13/91    If parent.objid is NULL_OBJID just move it over to
                        src_parents.  This is to fix problems caused by 
                        state parents during recompute.
    DLB     05/09/91    Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  IGRint          ii,j;
  OMuword         spacenum;
  struct GRid     context_GRid, *current_parent;
  struct GRmd_env *env_ptr, *current_parent_env;
  extern OMuword  OPP_EMSpointer_class_id;
 
 
  *EMmsg = EMS_S_Success;

  context_GRid.objid = NULL_OBJID;
 
  for(ii=0; ii<num_parents; ii++)
  {
    current_parent = &parents[ii].grid;
    current_parent_env = &parents[ii].env;
    src_parents[ii].objid = NULL_OBJID;
 

    if (current_parent->objid == NULL_OBJID) /*DLB 5/13/91*/
    {
      src_parents[ii] = *current_parent;
      continue;
    }

/*
 * See if the parent is occuring multiple times. Since OM does not
 * allow us to connect the same object multiple times on a channel.
 * We have to resort to this.
 * pp 06/08/91 
 * 
 * Checking to see if the module environments are the same; if not, a different
 * source object should be created for this object even though its object id
 * and osnum are the same as another parent object.
 * WBC 12/27/93
 */
    for (j=0;j<ii;j++)
    {
     if ((parents[j].grid.objid == current_parent->objid) &&
         (parents[j].grid.osnum == current_parent->osnum) &&
         (parents[j].env.md_id.osnum == current_parent_env->md_id.osnum) &&
         (parents[j].env.md_id.objid == current_parent_env->md_id.objid) &&
         (parents[j].env.md_env.matrix_type ==
                                  current_parent_env->md_env.matrix_type))
     {
      IGRint     tmp_index;
      IGRboolean identical_objects = TRUE;

      if (current_parent_env->md_env.matrix_type != MAIDMX)
      {
       for (tmp_index = 0; tmp_index < 16; tmp_index++)
       {
        if (parents[j].env.md_env.matrix[tmp_index] !=
                                 current_parent_env->md_env.matrix[tmp_index])
        {
         identical_objects = FALSE;
         break;
        }
       }
      }

      if (identical_objects)
      {
       src_parents[ii].osnum = src_parents[j].osnum;
       OM_stat = om$construct(classid = OPP_EMSidentity_class_id,
                             p_objid = &src_parents[ii].objid,
                             osnum = src_parents[ii].osnum);
       EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);

       OM_stat = om$send (msg = message EMSidentity.EMinit(EMmsg,
                                   NULL, &src_parents[j]),
                          targetid = src_parents[ii].objid,
                          targetos = src_parents[ii].osnum);
       EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
       break;
      }
     }
    }
    if (src_parents[ii].objid != NULL_OBJID) continue;

 
    /*Compiler optimization*/
    env_ptr = &parents[ii].env;
/*
 * If I am in the same object space as the parent and the matrix
 * is identity, then there is no need for checking for the context.
 * pp 06/22/91
 */

    aflag = pwIsActivationOn();
    osn = pwGetActiveOs();

    /*
     * Try finding a context only in the following cases:
     * 1. Activation is on AND the current_parent is not in the activated os.
     * 2. Activation is off (normal/ run of the mill case) AND
     *    current_parent is not in the same os AND matrix is not identity.
     */

    if ( (aflag && current_parent->osnum != osn ) ||
       (!aflag && !((current_parent->osnum == OM_Gw_current_OS) &&
       (env_ptr->md_env.matrix_type == MAIDMX))) )

    {
    OM_stat = GRfindcontext(EMmsg,
                            &env_ptr->md_env.matrix_type,
                            env_ptr->md_env.matrix, 
                            &current_parent->osnum, 
                            &context_GRid);
    if (OM_stat == OM_S_SUCCESS && *EMmsg == MSSUCC )
    {
      spacenum = context_GRid.osnum; /* Where the source gets constructed */
    }
    else
    {
      if (aflag)
         spacenum = OM_Gw_current_OS;
      else
         spacenum = osn;

      context_GRid.objid = NULL_OBJID;
      *EMmsg = EMS_S_Success;
      OM_stat = OM_S_SUCCESS;
    }
   }
   else
    context_GRid.objid = NULL_OBJID;
 
      if (context_GRid.objid == NULL_OBJID)
      {
        OM_stat = as$make_source(go_grid = *current_parent,
                                 as_grid = &src_parents[ii]);
        if (!(1&OM_stat)) goto wrapup;
      }
      else
      {
        OM_stat = as$make_source(go_grid = *current_parent,
                                 context_grid = context_GRid,
                                 as_grid = &src_parents[ii]);
        if (!(1 & OM_stat)) goto wrapup;
      }
  }
 
wrapup:
 EMWRAPUP(*EMmsg, OM_stat, "assoc.mk_src")
 return (OM_stat);
}

IGRlong EFdelete_source_or_pointers(EMmsg, parent_id, parent_os, env, options)
IGRlong     *EMmsg;
GRobjid     parent_id;
OMuword     parent_os;
struct GRmd_env   *env;
IGRushort options;
{
  IGRint loc_msg;
  OM_S_CHANSELECT notify, to_children;
  extern OMuword OPP_EMSsurface_class_id, OPP_EMSboundary_class_id;

  *EMmsg = EMS_S_Success;

  EMmake_chanselect(GRnotify_notification, &notify);
  EMmake_chanselect(NDchildren_children, &to_children);

  if ((EFisAncestryValid(EMmsg, parent_id, parent_os, 
                          OPP_EMSsurface_class_id, FALSE)) ||
        (EFisAncestryValid(EMmsg,parent_id,
             parent_os,
             OPP_EMSboundary_class_id, FALSE)))
       
  {
   struct GRid context_GRid;
   struct GRid src_GRid;
   struct GRid parent_GRid;
   IGRint child_count = 0;

   context_GRid.objid = NULL_OBJID;
   src_GRid.objid = NULL_OBJID;
   parent_GRid.objid = parent_id;
   parent_GRid.osnum = parent_os;

   EFcreate_pointer(&loc_msg, NULL, &context_GRid, parent_os,
                      &parent_GRid, &src_GRid);
   if (src_GRid.objid != NULL_OBJID)
   {
    om$get_channel_count(osnum = src_GRid.osnum,
                         objid = src_GRid.objid,
                         p_chanselect = &to_children,
                         count = (OMuint *)&child_count);
    if (!child_count)
    {
      om$send (msg = message Root.delete(1),
               senderid = NULL_OBJID,
               targetid = src_GRid.objid,
               targetos = src_GRid.osnum);
    }
   }
  }

    /*tough luck if it fails!*/
    om$send(msg = message NDnode.NDdelete(env),
            senderid = parent_id,
            targetos = parent_os,
            p_chanselect = &notify);


  return(OM_S_SUCCESS);
}
end implementation EMSassoc;
