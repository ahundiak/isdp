/* ###################   APOGEE COMPILED   ################## */
class implementation ECdbgsal;

/*
Description
    This is a klugamatic command for the testing of method written for
    Salvagnini Transferica.

History

06/01/92 Rustagi Modified for Message sub-system Compliance

12 May 1989 jBk Moved command name presentation from method
                wakeup to method execute;

                abolished wakeup method.

    DLB 10/14/88    Creation by canabalization of Siki's ECdbgsend CO.
*/    

#include "EMS.h"
#include <stdio.h>
#include "EMSdprquery.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "msdef.h" /* MS message codes */
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "OMerrordef.h" /* OM message codes */
#include "exdef.h"      /* RESET        */
#include "OMlimits.h"   /* for ex.h     */
#include "ex.h"         /* for grio.h   */
#include "griodef.h"    /* for grio.h   */
#include "grio.h"       /* for lc.h     */
#include "lcdef.h"      /* for lc.h     */
#include "lc.h"         /* GRlc_stack   */
#include "msmacros.h"
#include "madef.h"
#include "emsmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "EMSerrnumdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "EMSkey.h"
#include "EC_M.h"

from EMSsurface import EMgetprimsfromtree;
from EMSsurface import EMgetInfoAboutComponents;
from EMSsurface import EMgetattributeid;
from EMSsubbs   import EMgetowner;
from GRnotify   import GRntfyconn;
from EMSsurface import EMreplacePrimitive;
from EMSsurface import EMswapPrimitive;
from EMSsurface import EMgetSurfsOfPrim;
from EMSsurface import EMgetCuttingPrims;

extern OMuword OPP_ci_executor_class_id;

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRlong OM_stat=OM_S_SUCCESS, EMmsg=EMS_S_Success;
  IGRint  numret, sizebuff=sizeof(struct GRmd_env);
  IGRint  objid=0, case_number=0;
  struct GRmd_env display_env;
  OMuword osnum;

  ex$message(msgnumb = EM_M_DbSnSavTrans);

  OM_stat = gr$get_display_env(msg = &EMmsg,
                               sizbuf = &sizebuff,
                               buffer = &display_env,
                               nret = &numret);
  if (!(1 & OM_stat & EMmsg))
  {
    *response = TERMINATE;
    return (OM_S_SUCCESS);
  }

start:
  EMWRAPUP(EMmsg, OM_stat, 
  "*******************************restarting*********************************")
  
  fprintf(stderr,"\nCase 0: exit");
  fprintf(stderr,"\nCase 1: Get primitives from tree");
  fprintf(stderr,"\nCase 2: Get component ids and connections");
  fprintf(stderr,"\nCase 3: Get owner id");
  fprintf(stderr,"\nCase 4: Get attribute id");
  fprintf(stderr,"\nCase 5: Replace primitive");
  fprintf(stderr,"\nCase 6: Swap primitive");
  fprintf(stderr,"\nCase 7: Get surfaces of a primitive");
  fprintf(stderr,"\nCase 8: Get primitives that cut a primitive");
  fprintf(stderr,"\nCase 9: Get objid from tag");
  fprintf(stderr,"\nCase 10: Get creator id from created id");
  fprintf(stderr,"\nCase 11: Generate key given created id and inverse");
  fprintf(stderr,"\n Enter case number : ");
  fflush(stdin);
  scanf("%d", &case_number);
  fprintf(stderr,"\n");

  if (case_number == 0)
  {
    *response = TERMINATE;
    return (OM_S_SUCCESS);
  }

  fflush(stdin);
  switch(case_number)
  {
    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    {
      fprintf(stderr,"\nEnter target object id: ");
      scanf("%d", &objid);
      fprintf(stderr,"\n");
      break;
    }

    case 10:
    case 11:
    {
      fprintf(stderr,"\nEnter created id: ");
      scanf("%d", &objid);
      fprintf(stderr,"\n");
      break;
    }

    default:
    {
      break;
    }
  }

  fflush(stdin);
  fprintf(stderr,"\nEnter osnum: ");
  scanf("%hu", &osnum);
  fprintf(stderr,"\n");

  switch(case_number)
  {
    case 1:
    {
      IGRint count=0, i;
      GRobjid *prims=NULL;
      
      OM_stat = om$send(msg = message EMSsurface.EMgetprimsfromtree(&EMmsg,
                              &count, &prims),
                        targetid = objid,
                        targetos = 2);
      if (!(1 & OM_stat & EMmsg)) goto start;

      fprintf(stderr, "\nPrim ids count = %d", count);
      fprintf(stderr, "\nPrim ids list");
      for (i=0; i<count; i++)
        fprintf(stderr,"\nid = %d", prims[i]);
      om$dealloc(ptr = prims);
      break;
    } 

    case 2:
    {
      IGRint tot_adjoin_info=0, tot_num_pairs=0;
      IGRint count=0, i, j ,k;
      struct EMScomponent_info *comp_info=NULL;

      OM_stat = om$send(msg = message EMSsurface.EMgetInfoAboutComponents(
                              &EMmsg, &count, &comp_info),
                        targetid = objid,
                        targetos = 2);
      if (!(1 & OM_stat & EMmsg)) goto start;

      fprintf(stderr, "\nComponent count = %d", count);
      fprintf(stderr, "\nComponent info list:");

      for (i=0; i<count; i++)
      {
        fprintf(stderr,"\n************** Component number %d ********",i+1);
        fprintf(stderr,"\n  Surf id = %d", comp_info[i].surf_id);
        fprintf(stderr,"\n  Adjoin info count = %d",
                            comp_info[i].num_adjoin_info);
        fprintf(stderr,"\n  Adjoin info list:");
                                            
        for(j=0; j<comp_info[i].num_adjoin_info; j++, tot_adjoin_info++)
        {                         
          fprintf(stderr,"\n  ########## Adjoin info number %d ######",j+1);
          fprintf(stderr,"\n    Ajoining surf id = %d", 
                                comp_info[i].adjoin_info[j].
                                adjoining_surf_id);
          fprintf(stderr,"\n    Edge pair count = %d", 
                                comp_info[i].adjoin_info[j].num_edge_pairs);
          fprintf(stderr,"\n    Edge pair list:");
          for(k=0; k<comp_info[i].adjoin_info[j].num_edge_pairs; k++, 
              tot_num_pairs++)
          {
            fprintf(stderr,"\n    $$$$$$$$$$ Edge pair number %d $$$$",k+1);
            fprintf(stderr,"\n       1st edge id = %d     2nd edge id = %d",
                                     (k == 0 ? 
                                      comp_info[i].adjoin_info[j].
                                      first_edge_pair[0] :
                                      comp_info[i].adjoin_info[j].
                                      other_edge_pairs[k-1][0]),
                                     (k == 0 ?
                                      comp_info[i].adjoin_info[j].
                                      first_edge_pair[1] : 
                                      comp_info[i].adjoin_info[j].
                                      other_edge_pairs[k-1][1]));
          }
        }
      }
      
      EFfreeComponentInfoMem(count, comp_info);
      fprintf(stderr,"\nComponent info struct has been freed.");
      if (tot_adjoin_info)
        fprintf(stderr,"\nAverage pairs per joint = %f", 
                (float) tot_num_pairs/tot_adjoin_info);
      break;
    }

    case 3:
    {
      GRobjid owner_id;

      
      OM_stat = om$send(msg = message EMSsubbs.EMgetowner(&EMmsg, &owner_id,
                              TRUE),
                        targetid = objid,
                        targetos = 2);
      if (!(1 & OM_stat & EMmsg)) goto start;
      fprintf(stderr, "\nImmediate owner = %d", owner_id);

      OM_stat = om$send(msg = message EMSsubbs.EMgetowner(&EMmsg, &owner_id,
                              FALSE),
                        targetid = objid,
                        targetos = 2);
      if (!(1 & OM_stat & EMmsg)) goto start;
      fprintf(stderr, "\nTop owner = %d", owner_id);
      break;
    }
    
    case 4:
    {
      IGRint          stupid_index=0;
      struct GRid     attribute_GRid, ciex_GRid;
      OM_S_CHANSELECT to_graphic;
      OMuword         stupid_os=2;
      IGRboolean      stupid_false=FALSE;

      OM_stat = om$construct(classid = OPP_ci_executor_class_id,
                             osnum = osnum,
                             p_objid = &ciex_GRid.objid);
      if (! (1 & OM_stat)) goto start;

      ciex_GRid.osnum = osnum;

      fprintf(stderr, "\nci_executor id = %d", ciex_GRid.objid);

      OM_stat = EMmake_chanselect (ci_executor_to_graphic, &to_graphic);
      
      OM_stat = om$send(msg = message GRnotify.GRntfyconn(&EMmsg,
                              &ciex_GRid, &to_graphic, &stupid_index,
                              &stupid_false, &stupid_os),
                        targetid = objid,
                        targetos = osnum);                              
      if (!(1 & OM_stat & EMmsg)) goto start;
                                   
      OM_stat = om$send(msg = message EMSsurface.EMgetattributeid(&EMmsg, 
                              &attribute_GRid),
                        targetid = objid,
                        targetos = osnum);
      if (!(1 & OM_stat & EMmsg)) goto start;

      fprintf(stderr, "\nAttribute id = %d", attribute_GRid.objid);
      break;
    }
    
    case 5:
    {
      GRobjid repl_objid;


      fflush(stdin);
      fprintf(stderr,"\nEnter object id to replace with: ");
      scanf("%d", &repl_objid);
      fprintf(stderr,"\n");
 
      OM_stat = om$send(msg = message EMSsurface.EMreplacePrimitive(&EMmsg,
                              &display_env, repl_objid, 
                              EMS_DO_DISPLAY),
                        targetid = objid,
                        targetos = osnum);
      if (!(1 & OM_stat & EMmsg)) goto start;                        
      break;
    }

    case 6:
    {
      GRobjid swap_objid;


      fflush(stdin);
      fprintf(stderr,"\nEnter object id to swap with: ");
      scanf("%d", &swap_objid);
      fprintf(stderr,"\n");
 
      OM_stat = om$send(msg = message EMSsurface.EMswapPrimitive(&EMmsg,
                              &display_env, swap_objid, 
                              EMS_DO_DISPLAY | EMS_DONT_REEX),
                        targetid = objid,
                        targetos = osnum);
      if (!(1 & OM_stat & EMmsg)) goto start;                        
      break;
    }

    case 7:
    {
      IGRint  num_surf=0, i, num_active;
      GRobjid *surf_ids=NULL;

      OM_stat = om$send(msg = message EMSsurface.EMgetSurfsOfPrim(&EMmsg,
                              NULL, &surf_ids, &num_surf, &num_active),
                        targetid = objid,
                        targetos = osnum);
      if (!(1 & OM_stat & EMmsg)) goto start;                        

      fprintf(stderr, "\nnum_surf = %d", num_surf);
      fprintf(stderr, "\nsurf_ids:");
      for(i=0; i< num_surf; i++)
      {
        fprintf(stderr, "\n%d", surf_ids[i]);
      }      
      om$dealloc(ptr = surf_ids);
      fprintf(stderr, "\nnum_active = %d", num_active);        
      break;
    }
    

    case 8:
    {
      IGRint  num_cutting_prim=0, i;
      GRobjid *cutting_prim_ids=NULL;

      OM_stat = om$send(msg = message EMSsurface.EMgetCuttingPrims(&EMmsg,
                              &cutting_prim_ids, &num_cutting_prim, NULL),
                        targetid = objid,
                        targetos = osnum);
      if (!(1 & OM_stat & EMmsg)) goto start;

      fprintf(stderr, "\nnum_cutting_prim = %d", num_cutting_prim);
      fprintf(stderr, "\ncutting_prim_ids:");
      for(i=0; i< num_cutting_prim; i++)
      {
        fprintf(stderr, "\n%d", cutting_prim_ids[i]);
      }      
      om$dealloc(ptr = cutting_prim_ids);
      break;
    }


    case 9:
    {
      OMuint tag;
      void EFcvrt_to_from_tag();

      fflush(stdin);
      fprintf(stderr,"\nEnter tag id: ");
      scanf("%u", &tag);
      fprintf(stderr,"\n");
 
      EFcvrt_to_from_tag(&EMmsg, 1, &objid, &tag, FALSE, osnum);
      if (!(1 & EMmsg)) goto start;                        

      fprintf(stderr, "\nobjid = %u", objid);
      break;
    }


    case 10:
    case 11:
    {
      GRobjid        creator_id;      
      extern IGRlong EFget_creator_id();

      OM_stat = EFget_creator_id(&EMmsg, objid, osnum, &creator_id, NULL);
      if (!(1 & OM_stat & EMmsg)) goto start;

      fprintf(stderr, "\ncreator = %u", creator_id);

      if (case_number == 11)
      {
        IGRint key_count=0, ii;
        struct EMSkey *key=NULL;
        extern IGRlong EFgenerate_key_from_id();

        OM_stat = EFgenerate_key_from_id(&EMmsg, objid, osnum, creator_id,
                                         &key_count, &key, 0, NULL);

        if (!(1 & OM_stat & EMmsg)) goto start;

        fprintf(stderr, "\nkey_count = %u", key_count);
        for(ii=0; ii<key_count; ii++)
        {
          fprintf(stderr, "\nkey[%d].chan_count = %u", ii, key[ii].chan_count);
          fprintf(stderr, "\nkey[%d].chan_index = %u", ii, key[ii].chan_index);
          fprintf(stderr, "\nkey[%d].sub_item_type = %u", ii,
                  key[ii].sub_item_type);
        }

        OM_stat = EFgenerate_id_from_key(&EMmsg, creator_id, osnum, key_count,
                                         key, &objid, NULL);
        if (!(1 & OM_stat & EMmsg)) goto start;

        fprintf(stderr,"\ngenerated id = %u", objid);

        if (key) om$dealloc(ptr = key);
      }
      break;
    }


    default:
    {
      fprintf(stderr, "\n Unknown option.");
      break;
    }
  } /*end switch*/

  goto start;
}
end implementation ECdbgsal;
