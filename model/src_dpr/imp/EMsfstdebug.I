/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfstitch;

#include "EMS.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "OMmacros.h"

extern OMuword OPP_EMSedge_class_id;

method debug()
{
 IGRlong			sts, EMmsg;
 struct EMSstchssi_table	*my_info = NULL;
 IGRint				i, j, total_edgesin = 0;
 OMuint				count;
 union EMSssi_table		*mod_table = NULL;
 OM_S_CHANSELECT		to_comm;
 OM_S_OBJECT_LINKAGE		comm;
 GRobjid			*in;
 IGRchar 			keyin='n';
 extern IGRint			EMmake_chanselect();
 extern IGRboolean		EFisAncestryValid();

 EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 sts = EMmake_chanselect(EMSedge_to_common_edge, &to_comm);

 sts = om$send(msg = message EMSdpr.EMgetSSI(&EMmsg, &mod_table),
                targetid = my_id);
 EMerr_hndlr(!(1&EMmsg&sts),EMmsg,EMS_E_Fail,wrapup);  

 my_info = &mod_table->stch_info;

 total_edgesin = 0;
 for(i=0; i<my_info->num_edges_out; i++)
  total_edgesin += my_info->num_edges_in[i];
 
 if(my_info->num_edges_out)
  {
   fprintf(stderr, "\n %d Edges Created ---\n", total_edgesin);
   in = (GRobjid *) my_info->edges_in;

   EFgetchar (stderr, "\n Print created edge ids? y/n [n] ", &keyin);
   if (toupper (keyin) == 'Y')
    {
     for(i=0; i<my_info->num_edges_out; i++)
      {
       fprintf(stderr, "%d -->", my_info->edges_out[i]);
       for(j=0;j<my_info->num_edges_in[i]; j++, in++)
         fprintf(stderr, "%d ", *in);
       fprintf(stderr, "\n");
      }
    }
  }
 else fprintf(stderr, "\nNo Edges created\n");

 keyin = 'n';
 if(my_info->num_edges_connected)
  {
   fprintf(stderr, "\n%d Old Edges Connected ---\n",
					my_info->num_edges_connected );
   in = (GRobjid *) my_info->edges_connected;

   EFgetchar (stderr, "\n Print connected edge ids? y/n [n] ", &keyin);
   if (toupper (keyin) == 'Y')
    {
     for(i=0; i<my_info->num_edges_connected; i+=2)
      {
       count = 0;
       if(EFisAncestryValid(&EMmsg, in[i], OM_Gw_current_OS, 
			    OPP_EMSedge_class_id, TRUE))
	{
         sts = om$get_channel_objects(objid = in[i], p_chanselect = &to_comm, 
				list = &comm, size = 1, count = &count);
         if(!(1&sts)) goto wrapup;
        }

       if(!count) continue;
       fprintf(stderr, "%d <----> %d\n", in[i], comm.S_objid);
      }
    }
  }
 else fprintf(stderr, "\nNo old edges connected\n");


 sts =om$send(mode = OM_e_wrt_message, msg = message EMSdpr.debug(), 
		targetid = my_id);
		
wrapup:
if(mod_table) om$dealloc(ptr = mod_table);

EMWRAPUP(EMmsg, sts, "In EMSsfstitch.debug");
return(sts);
}

end implementation EMSsfstitch;
