/* ###################   APOGEE COMPILED   ################## */
class implementation GRvg;

/*
  HISTORY

    Sudha  07/09/93  :  Modified for BSprototypes anisfication
*/

#include "EMS.h"

%safe
#include "math.h"
%endsafe

#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlm.h"
#include "bsnorvec.h"
#include "bsdotp.h"

IGRboolean EMis_vertex_uniform (EMmsg,
                                my_info,
                                edge_index,
                                num_rnd_edges)

IGRlong 	             *EMmsg;
struct EMedge_round_info *my_info;
IGRint                   *edge_index;
IGRint                   *num_rnd_edges;

{
 
 IGRlong                 stat_OM, msg;
 IGRint                  i, j;
 IGRdouble               deciding_angle;
 IGRdouble               other_angle;
 IGRdouble               toler;
 IGRpoint                xyz_beg, xyz_end;
 IGRvector               *edge_vectors;
 IGRboolean              all_planar = TRUE;
 IGRboolean              status;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 edge_vectors = NULL;

 BSEXTRACTPAR(&msg, BSTOLLENVEC, toler);

 edge_vectors = (IGRvector *) om$malloc (size = (*num_rnd_edges) *
                                            sizeof (IGRvector));

 EMerr_hndlr(! edge_vectors, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 for (i=0; i<(*num_rnd_edges); i++)
  {
   if (my_info[edge_index[i]].curve->order != 2)
       all_planar = FALSE;   
  }

 if (! all_planar)
    return (FALSE);
 
 for (i=0; i<(*num_rnd_edges); i++)
  {
   if (my_info[edge_index[i]].curve->rational)
    {
     for (j=0; j<3; j++)
      {
       xyz_beg[j] = my_info[edge_index[i]].curve->poles[j] /
                    my_info[edge_index[i]].curve->weights[0];
       xyz_end[j] = (my_info[edge_index[i]].curve->poles[3 *
                    (my_info[edge_index[i]].curve->num_poles-1) + j]) /
                    (my_info[edge_index[i]].curve->weights[
                    my_info[edge_index[i]].curve->num_poles -1]);
      }
    }
   else
    {
     for (j=0; j<3; j++)
      {
       xyz_beg[j] = my_info[edge_index[i]].curve->poles[j];
       xyz_end[j] = my_info[edge_index[i]].curve->poles[3 *
                    (my_info[edge_index[i]].curve->num_poles-1) + j];
      }
    } 
   
   for(j=0; j<3; j++)
    {
     edge_vectors[i][j] = xyz_beg[j] - xyz_end[j];
    }   
   status = BSnorvec(&msg, edge_vectors[i]);
  }

 deciding_angle = BSdotp(&msg, edge_vectors[0], edge_vectors[1]);

 for (i=0; i<(*num_rnd_edges); i++)
  {
   for (j=i+1; j<(*num_rnd_edges); j++)
    {
     other_angle = BSdotp(&msg, edge_vectors[i], edge_vectors[j]);
     if ((fabs(other_angle)-fabs(deciding_angle)) > toler)
        return(FALSE);
    }
  }

 wrapup:
 	EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMis_vertex_uniform");
 	return(TRUE);
}

end implementation GRvg;

