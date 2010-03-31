/*
        DLB     years ago       Creation.
        SM      29-Aug-89       print out cht for booleans.
        DLB     07-feb-91       print tags and objids.
        DLB     07/10/91        remove tag printing.
Carlos M. Diaz  01/11/94	Moved EFprint_assoc_info and
				EFprint_comps to file EFprtassoc.I for MDS. 
*/
class implementation EMSdpr;

#include <stdio.h>
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "EMSbnddef.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsdef.h"

from EMSsfboolean import EMget_operation_type, EMget_put_cht;
from EMSassoc import EMget_info;

method debug()
{
 IGRlong          OM_stat, EMmsg;
 IGRint           num_ids, ii;
 IGRchar          name[OM_K_MAXCLASS_LEN];
 extern IGRlong   EFprint_assoc_info();
 extern IGRlong   EFprint_comps();

 fprintf(stderr,
   "\n***************************DPR DEBUG*******************************");

 OM_stat = om$get_classname(object = me,
                            classname = name);
 if (! (1 & OM_stat)) goto wrapup;

 fprintf (stderr, "\n My class name = %s", name);
 fprintf (stderr, "\n My id = %d ",my_id);

 fprintf(stderr,"\n Dpr properties = 0x%x", ME.EMSdpr->dpr_props);
 fprintf(stderr,
       "\n Graphics properties = 0x%x\n",(IGRushort)ME.GRgraphics->properties);
 {
   enum EMSbooltype      exact_type; 
   IGRdouble             cht;

   OM_stat = om$send(msg = message EMSsfboolean.EMget_operation_type(
                           &EMmsg, NULL, &exact_type, NULL, NULL, NULL,
                           NULL, NULL, NULL, NULL, NULL, NULL),
                     targetid = my_id);
   if (1 & OM_stat & EMmsg) 
   {
     fprintf(stderr,"\n operation type = %d", exact_type);
     OM_stat = om$send(msg = message EMSsfboolean.EMget_put_cht(
                           &EMmsg, FALSE, &cht), targetid = my_id);
     if (1 & OM_stat & EMmsg) fprintf(stderr, "\n cht = %2.12lf\n", cht);
   }
 }

 if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
   EFprint_assoc_info(my_id, OM_Gw_current_OS);

 num_ids = om$dimension_of(varray = ME.EMSdpr->ids);

 fprintf(stderr,"\n Ids vla:");

 for(ii=0;ii<num_ids;ii++)
 {
   fprintf(stderr,"\n Index: %d, Objid: %d", ii, ME.EMSdpr->ids[ii]); 
   if (om$is_objid_valid(objid = ME.EMSdpr->ids[ii]) != OM_S_SUCCESS)
     fprintf(stderr,"   INVALID OID");
 }

 { /*ON PURPOSE!*/
   IGRint findex=0, tindex = OM_K_MAXINT;

   EFprint_comps(my_id, OM_Gw_current_OS, &findex, &tindex);

   fprintf(stderr,
   "\n*************************END DPR DEBUG***************************\n");

   if (findex != OM_K_MAXINT || tindex != OM_K_MAXINT)
   {
     OM_S_CHANSELECT to_comps;

     EMmake_chanselect(GRcmpowner_to_components, &to_comps);
     OM_stat = om$send(msg = message Root.debug(),
                       p_chanselect = &to_comps,
                       from = findex, to = tindex);
     if (! (1 & OM_stat)) goto wrapup;
   }
 }

wrapup:
 return (OM_stat);
}
 
end implementation EMSdpr;
