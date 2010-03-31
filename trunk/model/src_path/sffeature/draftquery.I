class implementation Root;

#include <math.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "bsvalues.h"
#include "values.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
#include "dp.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSascmacros.h"
#include "EMSasopts.h"
#include "nddef.h"


#include "PWminimum.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/mx.h"


#include "EMSmsgdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSas.h"
#include "REaddrmfea.h"
#include "EMSfeadef.h"
#include "EMSasfeatdef.h"
#include "PWapi/msgsend.h"

#include "bsparameters.h"
#include "bserr.h"
#include "bsdotp.h"
#include "bscvtstclsd.h"
#include "bsnorvec.h"
static void get_parent_types();

from NDnode import NDget_objects;
from EMSassoc import EMget_parent_info,EMget_info;

void pwQueryAddDraft
(
  PWobjid feature_id,
  PWosnum os,
  PWobjid *datum_plane, 
  int *num_draft_sfs,
  PWobjid **draft_sfs, 
  double *draft_angle,
  PWboolean *draft_into_volume,
  PWobjid *base_solid
)
{
  struct GRid *p_parentobjs=NULL;
  int num_parents = 0,i,num_drafts;
  IGRlong stat,msg_loc;
  unsigned int p_parenttypes[10],info_size=0,type=0;
  struct EMSadd_draft recomp_info,*p_recompinfo=NULL;
  union EMSparent_info p_parents[10];
  PWobjid *draft_sfs_ids=NULL,datum_plane_id;

  /*
   * Get the recompute info for the feature.
   */
  p_recompinfo = &recomp_info;
  stat = om$send (msg = message EMSassoc.EMget_info(&msg_loc,
                                                    NULL,
                                                    &type,
                                                    &info_size,
                                                    (char **)&p_recompinfo),
                  senderid = NULL_OBJID,
                  targetid = feature_id,
                  targetos = os );
 /*  OnErrorState( !(1 & stat & msg_loc), result, PW_K_Error, wrapup); */
  stat = om$send (msg = message NDnode.NDget_objects(ND_IN_BUF | ND_ROOT,
                                                       NULL, 0,
                                                       &p_parentobjs, 0,
                                                       MAXINT, &num_parents),
                    senderid = NULL_OBJID,
                    targetid = feature_id,
                    targetos = os );
  for(i = 0 ; i< num_parents ; i++)
     p_parenttypes[i] = EMSgrid;
  p_parenttypes[num_parents - 2] = EMSangle;
  p_parenttypes[num_parents - 3] = EMSangle;

  if(type == SURFACES_AND_EDGES_OR_CRVS_OR_SURFS)
     num_drafts = (num_parents-3+1)/2;
  else if(type == SURFACE_AND_SURFACES)
          num_drafts = (num_parents-4);

  // get_parent_types(type,num_parents,&num_drafts,p_parenttypes);    
  *num_draft_sfs = num_drafts;

    stat = om$send (msg = message EMSassoc.EMget_parent_info(&msg_loc,
                                                           NULL,
                                                           num_parents,
                                                           NULL,
                                                           p_parenttypes,
                                                           p_parents ),
                  senderid = NULL_OBJID,
                  targetid = feature_id,
                  targetos = os );
  /* Fill the required info from parents info  */
  
  *draft_angle = p_parents[num_parents -3].value;
  *draft_into_volume = p_parents[num_parents - 2].value;
  *base_solid = p_parents[num_parents - 1].grobj.grid.objid;
   if(draft_sfs != NULL)
   {
     draft_sfs[0] = (PWobjid *)malloc(*num_draft_sfs * sizeof(PWobjid));
     for(i=0; i < *num_draft_sfs ; i++)
      draft_sfs[0][i] = p_parents[i].grobj.grid.objid;
     datum_plane_id = p_parents[*num_draft_sfs].grobj.grid.objid; 
    }
     *datum_plane = datum_plane_id; 
  return;
}

static void get_parent_types(
IGRuint add_draft_type,
int num_parents,
int *num_drafts, 
IGRuint *p_parenttypes
)
{
  int index,i;

  /* Find out the no of drafted surfaces */
 
  if(add_draft_type == SURFACES_AND_EDGES_OR_CRVS_OR_SURFS)
     *num_drafts = (num_parents-3)/2;
  else if(add_draft_type == SURFACE_AND_SURFACES)
          *num_drafts = (num_parents-4);
       else if(add_draft_type == REPLACE_SURFACE)
              *num_drafts = (num_parents-1)/2;

/*    printf("\n ------NO Drafts = %d-------- ",*num_drafts); */
   /* Fill up the parent_types array     */

  index=0;
  for(i=0;i< *num_drafts; i++)
  {
   p_parenttypes[index] = EMSgrid;
   index++;
  }

   /* For ref edged or surfaces          */

  if((add_draft_type == SURFACES_AND_EDGES_OR_CRVS_OR_SURFS)
      || (add_draft_type == REPLACE_SURFACE))
    {
      for(i=0; i< *num_drafts; i++)
      {
       p_parenttypes[index] = EMSgrid;
       index++;
      }
     }
  else
     {
       p_parenttypes[index] = EMSgrid;
       index++;
      }

  if(!(add_draft_type == REPLACE_SURFACE))
    {
     /* draft angle                                       */
     p_parenttypes[index] = EMSangle;
     index++;

      /* draft angle rev i.e, In to volume or out of volume */
      p_parenttypes[index] = EMSangle;
      index++;
     }
     /* The Solid that is has got drafted                   */
      p_parenttypes[index] = EMSgrid;
      index++;
  
   return;
}

end implementation Root;
