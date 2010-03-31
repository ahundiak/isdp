/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;

#include "emsdef.h"
#include "EMSasdef.h"

extern OMuword OPP_GRowner_class_id;

from EMSparameter import EMis_externally_constrained;

method EMexternal_constraint_changed(IGRlong *EMmsg; 
                                     IGRushort options)
/*
Description
    Modify GRHAS_EXTERNAL_CONSTRAINT bit setting of graphic object when an
    external constraint is added or removed.

Notes
    About arguments:
        options - EMext_const_chg_CONSTRAINT_ADDED - external constraint has
                    been added so set this object and all owners
                    GRHAS_EXTERNAL_CONSTRAINT bits to TRUE.             

                  EMext_const_chg_CHECK - Parents or components have been added
                    which may be externally constrained so see if my
                    EXTERNAL_CONSTRAINT bit should be set.   Use this option 
                    when an associative object is placed for the first time
                    or a change has occurred (removal or addition of a 
                    parent/component).


History
    DLB 12/03/92    Also check for REJECTED_METHOD returned from sending to
                    parent.
    DLB 04/18/91    Don't check for components that are parents if not an
                    owner.
    DLB 04/09/91    Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  OM_S_CHANSELECT to_owners, to_comps;

 
  *EMmsg = EMS_S_Success;
 
  EMmake_chanselect(GRconnector_to_owners, &to_owners);
  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  if (options & EMext_const_chg_CONSTRAINT_ADDED)
  {
    if (ME.GRgraphics->properties & GRHAS_EXTERNAL_CONSTRAINT) goto wrapup;
    else
    {
      ME.GRgraphics->properties |= GRHAS_EXTERNAL_CONSTRAINT;
      om$send(msg = message EMSassoc.EMexternal_constraint_changed(EMmsg, 
                    options),
              p_chanselect = &to_owners);
    }
  }    
  else if (options & EMext_const_chg_CHECK)
  {
    /*parent or component change...check'em out for constraintness*/

    IGRint          count, ii;
    OM_S_CHANSELECT to_father;
    IGRboolean      externally_constrained=FALSE, ima_owner=FALSE;

    if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                          OPP_GRowner_class_id, FALSE))
    {
      /*If I have components, see if they are externally constrained.*/
      IGRshort        props;

      ima_owner = TRUE;
      OM_stat = om$get_channel_count(object = me,
                                     p_chanselect = &to_comps,
                                     count = (OMuint *)&count);
      if (!(1 & OM_stat)) goto wrapup;

      for(ii=0; ii<count; ii++)
      {
        OM_stat = om$send(msg = message GRgraphics.GRgetprops(EMmsg, &props),
                          p_chanselect = &to_comps,
                          from = ii,
                          to = ii);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;                          

        if (props & GRHAS_EXTERNAL_CONSTRAINT)
        {
            externally_constrained = GRHAS_EXTERNAL_CONSTRAINT;
            break;
        }
      }
    }  

    if (!externally_constrained)
    {
      /*See if any of my parents are externally constrained*/
      GRobjid father_id;
      OMuword dumosnum;

      EMmake_chanselect(NDfather_father, &to_father);
      OM_stat = om$get_channel_count(object = me,
                                     p_chanselect = &to_father,
                                     count = (OMuint *)&count);
      if (!(1 & OM_stat)) goto wrapup;
  
      for(ii=0; ii<count; ii++)
      {
        OM_stat = om$get_objid_at_index(object = me,
                                        p_chanselect = &to_father,
                                        index = ii,
                                        objidaddr = &father_id,
                                        osnumaddr = &dumosnum);
        if (!(1 & OM_stat)) goto wrapup;
                                                
        OM_stat = om$send(msg = message
                             EMSparameter.EMis_externally_constrained 
                             (EMmsg, &externally_constrained),
                          targetid = father_id);
        if (OM_stat == OM_W_UNKNOWN_MSG || 
            OM_stat == OM_W_REJECTED_METHOD ||
            externally_constrained)
        {
          OM_stat = OM_S_SUCCESS;

          /*constr'd if not an owner OR don't own the parent.*/
          if (!ima_owner || (OM_W_NOTONCHAN == om$is_objid_on_channel
                                              (object_c = me,
                                               p_chanselect = &to_comps,
                                               objid = father_id)))
          {
            externally_constrained = GRHAS_EXTERNAL_CONSTRAINT;
            break;
          }
        }
      }                                          
    }

    if ((ME.GRgraphics->properties & GRHAS_EXTERNAL_CONSTRAINT) != 
        externally_constrained)
    {
      /*Toggle (xor magic) the constraint bit and tell the owners to check
       * theirs
       */
      ME.GRgraphics->properties ^= GRHAS_EXTERNAL_CONSTRAINT;

      OM_stat = om$send(msg = message EMSassoc.EMexternal_constraint_changed(
                              EMmsg, options),
                        p_chanselect = &to_owners);
      if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "assoc.EMext_constraint_chg")
  return(OM_stat);
}
end implementation EMSassoc;
