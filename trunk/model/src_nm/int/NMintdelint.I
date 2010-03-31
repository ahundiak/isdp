class implementation NMinters;

#include "OMmacros.h"
#include "EMSlmdef.h"

from EMSsubbs import EMget_ele_header;
from EMSedge import EMdisplay;

method NMdelete_inters (IGRlong *EMmsg; IGRboolean delete_other, do_display)
{
 IGRlong		sts, i;
 struct EMSinters	*inters[2], *this_inters = NULL;
 struct EMSintobj	*this_intobj = NULL;
 struct EMSdataselect	*this_data = NULL;
 OM_S_CHANSELECT	to_lp;
 struct DPele_header    local_sf_ele_header, *ele_header = NULL;
 struct IGResqbs        bsqsurf;
 GRrange                range;
 struct GRsymbology     symb;
 union IGRele_attr      ele_spec_att;
 enum GRdpmode		erase = GRbe;
 struct GRmdenv_info	env;

 *EMmsg = EMS_S_Success;
 EMidmatrix(EMmsg, &env.matrix_type, env.matrix);

 inters[0] = inters[1] = NULL;
 ele_header = &local_sf_ele_header;
 ele_spec_att.bsqsurf = &bsqsurf;

 sts = om$send(msg = message NMinters.NMget_inters(EMmsg, &inters[0], 
       delete_other ? &inters[1] : NULL, NULL, NULL, NULL, NULL, 
       NMgetint_NoStorageObjs), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(do_display)
  {
   /* Erase all the edges which are going to be deleted.
   */
   for(i=0; i<2; i++)
    {
     this_inters = inters[i];
     while(this_inters)
      {
       if(IF_NULL_OBJID(this_inters->this_obj.objid)) goto next_inters;

       /*
        * Get the element header
        */
       sts = om$send(msg = message EMSsubbs.EMget_ele_header(EMmsg, NULL,
             &env, NULL, ele_header, range, &symb.display_attr,
  	     ele_spec_att, NULL), targetid = this_inters->this_obj.objid, 
	     targetos = this_inters->this_obj.osnum);
       if(! (1 & *EMmsg & sts)) goto next_inters;

       ele_header->dis_att->weight += FlpDispWeightInc;

       this_intobj = this_inters->cvs;
       while(this_intobj)
        {
         this_data = &this_intobj->this_uvintobj;
         if( (this_data->datatype != EMSdata_object) ||
	     (IF_NULL_OBJID(this_data->data.object->objid)))
	   goto next_intobj;

         sts = om$send(msg = message EMSedge.EMdisplay(EMmsg, 
	       ele_header, &env.matrix_type, env.matrix, &erase, NULL, 
	       EMS_NONNATURAL_EDGE, NULL), 
               targetid = this_data->data.object->objid, 
	       targetos = this_data->data.object->osnum);

next_intobj:
         sts = OM_S_SUCCESS;
         *EMmsg = EMS_S_Success;
         this_intobj = this_intobj->next;
        }

next_inters:
       sts = OM_S_SUCCESS;
       *EMmsg = EMS_S_Success;
       this_inters = this_inters->next;

      } /* while(this_inters) */

    } /* for(i=0; i<2; i++) */

  }/* if(do_display) */

 /* Disconnect all the edges created by me, from their respective loops
    so as to ensure their deletion.
 */
 sts = EMmake_chanselect(EMSedge_to_owner, &to_lp);
 sts = NMdisconnect_edges(EMmsg, inters, NULL, NULL, &to_lp);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* EMinters_data free would automatically delete all the edges created
    by me.
 */
 for(i=0; i<2; i++)
  {
   if(!inters[i]) continue;
   EMinters_data_free(EMmsg, inters[i], MAXINT, NULL, NULL);
   EMinters_free(inters[i], MAXINT);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 ME.NMinters->num_inters = 0;

 /* Delete the storage objects.
 */
 sts = om$send(msg = message NMinters.NMdelete_storage_objs(EMmsg, 
	delete_other), targetid = my_id);

wrapup:
/*********
if(1&*EMmsg&sts) ME.NMinters->num_inters = 0;
EMWRAPUP(*EMmsg, sts, "NMinters.NMdelete_inters");
return(sts);
***********/
ME.NMinters->num_inters = 0;
*EMmsg = EMS_S_Success;
return(OM_S_SUCCESS);
}

end implementation NMinters;
