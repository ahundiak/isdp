class  implementation EMSsubbs;

#include "emsaddraft.h"
 

   EMinfo_free_both(EMmsg, info_list1, info_list2, len)
   IGRlong *EMmsg;
   struct EMSadj_surf_info  **info_list1;
   struct EMSadj_surf_info  **info_list2;
   IGRint len;

   {
    IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    struct EMSadj_surf_info  *info1;
    struct EMSadj_surf_info  *info2;
    IGRint ZZZ;
   
    if( !info_list1 || !info_list2  )
       return(stat_OM);

   for(ZZZ=0; ZZZ<len; ZZZ++)
   {
    info1 = info_list1[ZZZ];
    info2 = info_list2[ZZZ];
    if(info1)
    {
        if(info1->adj_loops)
         {om$dealloc (ptr = info1->adj_loops); info1->adj_loops=NULL;}
        if(info1->adj_surfs)
         {om$dealloc (ptr = info1->adj_surfs); info1->adj_surfs=NULL;}
        if(info1->commedges)
         {om$dealloc (ptr = info1->commedges); info1->commedges=NULL;}
        if(info1->edges)
         {om$dealloc (ptr = info1->edges); info1->edges=NULL;}
        if(info1->comedge_cncv)
         {om$dealloc (ptr = info1->comedge_cncv); info1->comedge_cncv=NULL;}
     }

    if(info2)
    {
        if(info2->adj_surfs)
         {om$dealloc (ptr = info2->adj_surfs); info2->adj_surfs=NULL;}
        if(info2->commedges)
         {om$dealloc (ptr = info2->commedges); info2->commedges=NULL;}
        if(info2->edges)
         {om$dealloc (ptr = info2->edges); info2->edges=NULL;}

        EMinters_data_free( &msg_loc,info2->my_inters, NULL, NULL, NULL);
        EMinters_data_free( &msg_loc,info2->adj_inters, NULL, NULL, NULL);
        EMinters_free(info2->my_inters, NULL);
        EMinters_free(info2->adj_inters, NULL);
     }
    }
    return (stat_OM);
   }

end  implementation EMSsubbs;



