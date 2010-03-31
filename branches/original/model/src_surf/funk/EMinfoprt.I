class  implementation EMSsubbs;

#include "emsaddraft.h"
 

   EMinfo_print(EMmsg, info_list, len, fp)
   IGRlong *EMmsg;
    FILE  *fp;
   struct EMSadj_surf_info  **info_list;
   IGRint len;

   {
    IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    IGRint ZZZ, ii;
    struct EMSadj_surf_info  *info;
    if( fp == NULL )
      {
         printf("error opening file \n");
         return;
      }
    for(ZZZ=0; ZZZ<len; ZZZ++)
    {
  fprintf(fp,"********************************************* \n");
     info = info_list[ZZZ];
    if(info)
    {
  fprintf(fp,"The surf GRid %d  %d \n", info->myself.osnum, info->myself.objid);
    fprintf(fp, "The surfs copy %d\n", info->copy);
    fprintf(fp, "The operate %d\n", info->operate);
    fprintf(fp, "The surf copy extend flag %d\n", info->extend);
    fprintf(fp, "The surf copy affect %d\n", info->affect);
    fprintf(fp, "The loop  %d\n", info->the_loop);
    fprintf(fp, "The loop no %d\n", info->loop_no);
    fprintf(fp, "The parent lp no %d\n", info->par_loop_no);
    fprintf(fp, "num_adjacent  %d\n", info->num_adjacent);
    fprintf(fp, "next  %d\n", info->next);
    fprintf(fp, "pos orient  %d\n", info->pos_orient);
    fprintf(fp, "planarity  %d\n", info->planar);

        if(info->adj_loops)
          {
           fprintf(fp, "Adjacent loops :\n");
           for(ii=0; ii< info->num_adjacent; ii++)
             fprintf(fp,  " %d" , info->adj_loops[ii]);
           fprintf(fp, " \n");
           }
        if(info->adj_surfs)
          {
           fprintf(fp, "Adjacent surfs :\n");
           for(ii=0; ii< info->num_adjacent; ii++)
             fprintf(fp,  " %d" , info->adj_surfs[ii]);
           fprintf(fp, " \n");
          }
        if(info->commedges)
          {
           fprintf(fp, "Commedges: \n");
           for(ii=0; ii< info->num_adjacent; ii++)
             fprintf(fp, " %d" , info->commedges[ii]);
           fprintf(fp, " \n");
          }
        if(info->edges)
          {
           fprintf(fp, "Surf edges: \n");
           for(ii=0; ii< info->num_adjacent; ii++)
            fprintf(fp," %d" , info->edges[ii]);
           fprintf(fp," \n");
          }
        if(info->comedge_cncv)
          {
           fprintf(fp,"commedge edge type : \n");
           for(ii=0; ii< info->num_adjacent; ii++)
             fprintf(fp," %d" , info->comedge_cncv[ii]);
           fprintf(fp," \n");
          }
     }
    }
     return (stat_OM);
    }

end  implementation EMSsubbs;



