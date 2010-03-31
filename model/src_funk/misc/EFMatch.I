class implementation Root;
#include "EMS.h"
#include "msdef.h"
#include "OMmacros.h"
#include "bstypes.h"
#include "emsmacros.h"
#include "maerr.h"
#include "bs.h"
#include "bsparameters.h"
#include "bserr.h"
#include "emserr.h"
#include "OMerrordef.h"
#include "emsedgedef.h"
#include "GRtypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "igr.h"
#include "griodef.h"
#include "grio.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSerrordef.h"
#include "EMSsweep.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "emsdef.h"
#include "EMSasnuc.h"

/*
Name
 EFMatch

Abstract
 This function gets two sets of ids. For each set it checks whether
 all the objects within the set have the same number of components. It
 returns the number of components in numcomps. If they did not have the
 same number of elements, -1 is put in numcomps.

Synopsis
 OUT:	IGRlong *sts;
 IN:	int nset1;
 IN:	int nset2;
 IN:	struct GRid *set1;
 IN:	struct GRid *set2;
 OUT:	int numcomps[2];

Description

Return Value
 IGRlong, always 0

Notes

Index

Keywords
 components,number,composite,curve

History
 06/22/93 : Carlos M. Diaz : created
*/

IGRlong EFMatch (EMmsg, nset1, nset2, set1, set2, numcomps)
IGRlong *EMmsg;
int nset1;
int nset2;
struct GRid *set1;
struct GRid *set2;
int numcomps[2];
{
  IGRlong loc_msg;
  OM_S_CHANSELECT    to_compcrv_components;
  int set=0, comp_curve=0;
  struct GRid *sets[2];
  int nset[2];

  sets[0] = set1;
  sets[1] = set2;
  nset[0] = nset1;
  nset[1] = nset2;

  EMmake_chanselect ( GRcmpowner_to_components, &to_compcrv_components);
  for (set=0; set < 2; set++)
  {
    int hold_num_comps = 0;

    for (comp_curve = 0; comp_curve < nset[set]; comp_curve++)
    {
      OMuint loc_num_comps;
      loc_msg = om$get_channel_count ( p_chanselect = &to_compcrv_components,
          objid = sets[set][comp_curve].objid, 
          osnum = sets[set][comp_curve].osnum,
          count = &loc_num_comps);
      if (1 & loc_msg)
      {
        if (hold_num_comps == 0) /* this initializes the holder for no. curves */
          hold_num_comps = loc_num_comps;
        else
          if (hold_num_comps != loc_num_comps)
          {
             hold_num_comps =  -1;
          }
          else 
            hold_num_comps = loc_num_comps;
      }
      else 
      {
        *EMmsg = OM_S_SUCCESS;
        hold_num_comps = 1;
      }
    }
   numcomps[set] = hold_num_comps;
  }
  return 0;
}
end implementation Root;
