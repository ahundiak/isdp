class implementation NMassoctrans;

#include "emsmacros.h"
#include "EMSopt.h"
#include "OMmacros.h"

from EMSsurface import EMgetactiveid, EMtransform_to_associative;
from EMSdpr import EMundo, EMredo;

#define StaticBuf	10

extern OMuword OPP_EMSsurface_class_id;

method NMinit_associative (IGRlong *EMmsg;
                            IGRushort options, nm_options;
                            IGRint num_parents;
                            struct EMSobject_info *list;
			    IGRint num_base_state;
			    IGRboolean *transmigrate;
			    struct GRid *base_state;
                            IGRint type;
                            unsigned int size;
                            IGRchar *recomp_data;
                            struct GRvg_construct *construct_list)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			i, j;
 IGRboolean		*undone = NULL, undonebuf[StaticBuf], *trptr = NULL;
 struct GRid		*op, *actid = NULL, actidbuf[StaticBuf],
			*baseptr = NULL, basebuf[StaticBuf];
 struct GRmd_env 	*openv;
 OM_S_CHANSELECT	to_owners;
 struct EMSobject_info	*loclistptr = NULL, loclistbuf[StaticBuf];
 IGRboolean		*loctransptr = NULL, loctransbuf[StaticBuf], duplicate,
			atleastonedup = FALSE;
 struct GRid		*locbasestptr = NULL, locbasestbuf[StaticBuf];
 IGRint			locnumparents = 0, locnumbase = 0;

 *EMmsg = EMS_S_Success;
 openv = &list[0].env;

 if(nm_options & NMinitas_NoDuplicateParents)
  {
   if(num_parents > StaticBuf)
    {
     loclistptr = (struct EMSobject_info *) om$malloc(size = num_parents
                  * sizeof(struct EMSobject_info));
     if(transmigrate)
       loctransptr = (IGRboolean *) om$malloc(size = num_parents
		     * sizeof(IGRboolean));
     if(base_state)
       locbasestptr = (struct GRid *) om$malloc(size = num_parents
		      * sizeof(struct GRid));
    }
   else
    {
     loclistptr = loclistbuf;
     if(transmigrate) loctransptr = loctransbuf;
     if(base_state) locbasestptr = locbasestbuf;
    }
   EMerr_hndlr(!loclistptr || (transmigrate && !loctransptr) || 
               (base_state && !locbasestptr), *EMmsg, 
	       EMS_E_NoDynamicMemory, wrapup);
   locnumparents = 0;
   for(i=0; i<num_parents; i++)
    {
     duplicate = FALSE;
     for(j=0; j<locnumparents; j++)
      {
       if(IF_EQ_GRID(list[i].grid, loclistptr[j].grid))
        {
	 duplicate = TRUE;
	 atleastonedup = TRUE;
	 break;
        }
      }
     if(!duplicate)
       loclistptr[locnumparents++] = list[i];
    }

   if(base_state)
    {
     locnumbase = 0;
     for(i=0; i<num_parents; i++)
      {
       duplicate = FALSE;
       for(j=0; j<locnumbase; j++)
        {
         if(IF_EQ_GRID(base_state[i], locbasestptr[j]))
          {
	   duplicate = TRUE;
	   atleastonedup = TRUE;
	   break;
          }
        }
       if(!duplicate)
        {
         if(transmigrate) loctransptr[locnumbase] = transmigrate[i];
         if(base_state) locbasestptr[locnumbase] = base_state[i];
         locnumbase++;
        }
      }
    }

   if(atleastonedup)
    {
     sts = om$send(msg = message NMassoctrans.NMinit_associative(EMmsg, 
	   options, (nm_options & ~NMinitas_NoDuplicateParents), 
	   locnumparents, loclistptr, locnumbase, loctransptr, locbasestptr, 
	   type, size, recomp_data, construct_list), targetid = my_id);
     goto wrapup;      
    }
  }


 /* If this node does not transmigrate on a parent, and that parent is not
    active, it needs to be temporarily activated.
 */
 if(transmigrate)
  {
   trptr = transmigrate;
   baseptr = base_state;
  }
 else if( (num_base_state = om$dimension_of(varray = 
           ME.NMassoctrans->transmigrate)))
  {
   trptr = ME.NMassoctrans->transmigrate;
   if(num_base_state > StaticBuf)
    baseptr = NULL;
   else baseptr = basebuf;
   sts = om$send(msg = message NMassoctrans.NMget_trans_info(EMmsg, NULL, 
	 &baseptr, NULL), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else
  {
   trptr = NULL;
   baseptr = NULL;
  }

 if(trptr && baseptr)
  {
   IGRushort undo_opt = EMS_UNDO_SAVE;

   if(num_base_state > StaticBuf)
    {
     undone =(IGRboolean *) om$malloc(size = num_base_state * sizeof(IGRboolean));
     actid = (struct GRid *) om$malloc(size = num_base_state * 
              sizeof(struct GRid));
    }
   else
    {
     undone = undonebuf;
     actid = actidbuf;
    }
   EMerr_hndlr(!undone || !actid, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   for(i=0; i<num_base_state; i++)
    {
     undone[i] = FALSE;
     actid[i].objid = NULL_OBJID;
    }

   EMmake_chanselect(GRconnector_to_owners, &to_owners);

   for(i=0; i<num_base_state; i++)
    {
     if(trptr[i]) continue;

     op = &baseptr[i];

     if(!EFisAncestryValid(EMmsg, op->objid, op->osnum, 
        OPP_EMSsurface_class_id, FALSE)) continue;

     sts = om$send(msg = message EMSsurface.EMgetactiveid
           (EMmsg, &actid[i], NULL),
           targetid = op->objid, targetos = op->osnum);
     if(!(1&*EMmsg&sts)) goto wrapup;
     if((!IF_NULL_OBJID(actid[i].objid)) && (!IF_EQ_GRID(*op, actid[i])))
      {
       sts = om$send(msg = message EMSdpr.EMundo(EMmsg, &undo_opt, 
             openv, NULL, NULL, NULL, NULL, NULL, NULL), 
             senderid = op->objid, 
             p_chanselect = &to_owners, from = 0, to = 0);
       if(!(1&*EMmsg&sts)) goto wrapup;
       undone[i] = TRUE;
      }
    }
  }

 sts = om$send(msg = message EMSassoc.EMinit_associative(EMmsg, options, 
       num_parents, list, type, size, recomp_data, construct_list), 
       targetid = my_id);
 if(!(1&*EMmsg&sts))  goto wrapup;

 if(transmigrate)
  {
   sts = om$vla_set_dimension(varray = ME.NMassoctrans->transmigrate, 
	 size = num_base_state);
   OM_BLOCK_MOVE(transmigrate, ME.NMassoctrans->transmigrate, num_base_state * 
               sizeof(IGRboolean));
  }

 if(base_state)
  {
   sts = om$vla_set_dimension(varray = ME.NMassoctrans->base_state, 
	 size = num_base_state);
   for(i=0; i<num_base_state; i++)
    {
     struct GRid junk;

     if(!IF_NULL_OBJID(base_state[i].objid)) junk = base_state[i];
     else junk = list[i].grid;

     sts = NMtag(EMmsg, &junk, &ME.NMassoctrans->base_state[i], TRUE);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
  }


 if(trptr)
  {
   IGRushort redo_opt = NULL;
   for(i=0; i<num_base_state; i++)
    {
     if(!undone[i]) continue;
     if(IF_NULL_OBJID(actid[i].objid)) continue;
     sts = om$send(msg = message EMSdpr.EMredo(EMmsg, &redo_opt, 
           openv, NULL, NULL, NULL), 
           targetid = actid[i].objid, targetos = actid[i].osnum);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
  }

 wrapup:
 if(undone && (undone != undonebuf)) om$dealloc(ptr = undone);
 if(actid && (actid != actidbuf)) om$dealloc(ptr = actid);
 if(loclistptr && (loclistptr != loclistbuf))
   om$dealloc(ptr = loclistptr);
 if(loctransptr && (loctransptr != loctransbuf))
   om$dealloc(ptr = loctransptr);
 if(locbasestptr && (locbasestptr != locbasestbuf))
   om$dealloc(ptr = locbasestptr);
 if(baseptr && (baseptr != basebuf) && (baseptr != base_state))
   om$dealloc(ptr = baseptr);

 EMWRAPUP(*EMmsg, sts, "NMassoctrans.NMinit_associative");
 return(sts);
}


end implementation NMassoctrans;
