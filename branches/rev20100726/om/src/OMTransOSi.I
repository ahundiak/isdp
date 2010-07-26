class	implementation	OMTransOS;

#include "OMerrordef.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMmacros.h"
#include "OMtags.h"

from OMMOSD import delete_entry;


method	delete	(int flag)
{
int               i, j, sts, size;
OM_p_TAGCON_LINK  p_link1, p_link2;

  /* if writing, try to open the file. if we fail, return */

  /* if there any ISO connections active, 'dissolve' them (i.e., look at
  /* all the other OS's and MARK their iso connections as hanging. Mark
  /* ours as well..
  */

  size = om$dimension_of(varray=ME.OMObjSpace->iso_d);

  if (size)
  {
    if (!(1&(sts = om$send ( msg = message OMObjSpace.dissolve_ISOs(), 
			     targetid = my_id ))))
      return (sts);
  }
  
 /* delete this from the entries in the MOSD */
  sts = om$send (msg = 	message OMMOSD.delete_entry (ME.OMObjSpace->OSD.OSnum),
		 targetid = OM_GO_current_MOSD,
		 targetos = 0);
  if (!(1&sts))
    return (sts);

 /*====================================================*/
 /*  check if there are any TagCon objects in this OS  */
 /*  and clean up any global TagCon data structures    */
 /*====================================================*/

 if ( OM_GA_p_tagcon )
 {
   if ( p_link1 = OM_GA_p_tagcon[OM_Gw_current_OS] )
   {
     while ( p_link1 )
     {
       p_link2 = p_link1->next;
       om$dealloc ( ptr = (char *) p_link1 );
       p_link1 = p_link2;
     }
     OM_GA_p_tagcon[OM_Gw_current_OS] = 0;
   }
 }

 /* set the flag in our OSD which indicates that we are being deleted..*/
  ME.OMObjSpace->OSD.flags |= OM_OSD_Rootdel_pending;

 /* set our spacemap flag to pending so send will call root.delete to 
 /* delete us .. 
 */

  j = ME.OMObjSpace->OSD.OSO_Oid;
  ME.OMObjSpace->OSD.Spacemap[j].flags |= OM_SM_Rootdel_pending;

 /* call the cluster trash routine for all but cluster 0 */

 for(i=ME.OMObjSpace->OSD.ClustersSize-1; i>0; i--)
	om$cleanup_cluster (p_clustcmp=ME.OMObjSpace->OSD.Clusters[i]);

  return(OM_S_SUCCESS);

}

end	implementation	OMTransOS;
