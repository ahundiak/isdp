/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdlift;

#include "EMSasdef.h"
#include "EMSas.h"
#include "OMmacros.h"
#include "emserr.h"

/* align a value 'x' up to the next 'a'-sized boundary */
#define ALIGN(x,a) ((char *) (((unsigned int)(x) + (a) - 1) / (a) * (a)))

struct EMSint_info
{
   struct GRid               sf_GRid;
   IGRuchar          lift_operation;
   IGRvector                 draft_vec;
   IGRdouble                 mx_exlp_dangle;
   IGRboolean                uniform_surface;
   IGRboolean                no_fillets;
   IGRint                    num_ed_infos;
   IGRint                    num_lps;
   struct   EMSint_lp_info  *lps_info;
};

struct EMSint_lp_info
{
  struct GRid               lp_GRid;
  IGRboolean                is_uniform;
  IGRdouble                 draft_angle;
  IGRboolean                fillet;
  IGRint                    num_eds;
  struct EMSint_ed_info    *eds_info;
};

struct EMSint_ed_info
{
   struct   GRid              ed_GRid;
   IGRushort          ed_sf_type;
   IGRuchar           ed_cv_type;
   IGRushort          ed_constraint_type;
   IGRdouble                  draft_angle;
   IGRint                     offset_code;
};

method EMget_info(IGRlong *EMmsg;
                   IGRushort options;
                   IGRuint *type;
                   IGRuint *info_size;
                   IGRchar **info)
/*
History
    DLB     02/25/92    Dont do anything if not associative.
    DLB     11/03/91    Fix incorrect casting of ptr - SUN PORT.
    DLB     08/29/91    Support view_index storage.
    DLB     06/08/91    Creation.
*/
{
 IGRint                 new_size;
 struct EMSint_info     *int_info;
 struct EMSdrafted_lift tmp_recomp_info;
 IGRchar                *inst_ptr;

 *EMmsg = EMS_S_Success;
 
 if (!(ME.GRgraphics->properties & GRIS_ASSOCIATIVE))
 {
   if (type) *type = 0;
   if (info_size) *info_size = 0;
   if (info) *info = NULL;
   goto wrapup;
 }

 inst_ptr = ME.EMSassoc->info + sizeof(IGRdouble);
 tmp_recomp_info.num_views = *((OMuword *) inst_ptr);
 inst_ptr += sizeof(IGRdouble);

 if (tmp_recomp_info.num_views)
 {
   inst_ptr += tmp_recomp_info.num_views * sizeof(struct EMSview_info);
   inst_ptr = ALIGN(inst_ptr, sizeof(IGRdouble));
 }
 int_info = (struct EMSint_info *) inst_ptr;

 new_size = sizeof(struct EMSdrafted_lift) + sizeof(IGRdouble);
 new_size += tmp_recomp_info.num_views * sizeof(struct EMSview_info) + 
             sizeof(IGRdouble);
 new_size += sizeof(struct EMSdlft_info) + sizeof(IGRdouble);
 new_size += int_info->num_lps * sizeof(struct EMSdlft_lp_info) +
             sizeof(IGRdouble);
 new_size += int_info->num_ed_infos * sizeof(struct EMSdlft_ed_info) +
             sizeof(IGRdouble);

 if (type) *type = me->type;
 if (new_size)
 {
   if (info_size) *info_size = new_size + sizeof(struct EMSdlft_info *);
 }
 else
 {
   if (info_size) *info_size = 0;
   if (info) *info = NULL;
 }

 if (info && new_size)
 {
   OMuint                 ii, jj;
   struct EMSdrafted_lift *recomp_info;
   struct EMSdlft_info    *dlift_info;
   struct EMSint_lp_info  *int_lp_info;
   struct EMSint_ed_info  *int_ed_info;
   struct EMSdlft_ed_info *ed_info;
   IGRchar                *cur_loc; 

   if (!*info)
   {
     *info = (IGRchar *) om$malloc(size = new_size);
     if (! *info) {*EMmsg=EMS_E_NoDynamicMemory; goto wrapup;}
   }

   cur_loc = *info;
   recomp_info = (struct EMSdrafted_lift *) *info;
   OM_BLOCK_MOVE(ME.EMSassoc->info,
                 &recomp_info->cht,
                 sizeof(IGRdouble));
   inst_ptr = ME.EMSassoc->info + sizeof(IGRdouble);

   OM_BLOCK_MOVE(inst_ptr,
                 &recomp_info->num_views,
                 sizeof(OMuword));
   inst_ptr += sizeof(IGRdouble);

   if (recomp_info->num_views)
   {
     OMuint v_size;

     v_size = recomp_info->num_views * sizeof(struct EMSview_info);
     recomp_info->view_info = (struct EMSview_info *) om$malloc(size = v_size);
     if (!recomp_info->view_info){*EMmsg=EMS_E_NoDynamicMemory;goto wrapup;}
       
     OM_BLOCK_MOVE(inst_ptr,
                   recomp_info->view_info,
                   v_size);
     inst_ptr += v_size;
     inst_ptr = ALIGN(inst_ptr, sizeof(IGRdouble));
   }
   else recomp_info->view_info = NULL;

   cur_loc += sizeof(struct EMSdrafted_lift);
   recomp_info->dlift_info = (struct EMSdlft_info *) cur_loc;
   dlift_info = recomp_info->dlift_info;

   int_info = (struct EMSint_info *) inst_ptr;

   dlift_info->sf_GRid = int_info->sf_GRid;
   dlift_info->lift_operation= int_info->lift_operation;
   OM_BLOCK_MOVE(int_info->draft_vec, dlift_info->draft_vec,
                 sizeof(IGRvector));
   dlift_info->mx_exlp_dangle = int_info->mx_exlp_dangle;
   dlift_info->uniform_surface = int_info->uniform_surface;
   dlift_info->no_fillets = int_info->no_fillets;
   dlift_info->num_ed_infos = int_info->num_ed_infos;
   dlift_info->num_lps = int_info->num_lps;
   dlift_info->lps_info = NULL;

   if (dlift_info->num_lps)
   {
     inst_ptr += sizeof(struct EMSint_info);
     inst_ptr = ALIGN(inst_ptr, sizeof(IGRdouble));
     int_lp_info = (struct EMSint_lp_info *) inst_ptr;

     cur_loc += sizeof(struct EMSdlft_info);
     cur_loc = ALIGN(cur_loc, sizeof(IGRdouble));
     dlift_info->lps_info = (struct EMSdlft_lp_info *) cur_loc;
  
     for(ii=0; ii<dlift_info->num_lps; ii++)
     {
       dlift_info->lps_info[ii].lp_GRid = int_lp_info->lp_GRid;
       dlift_info->lps_info[ii].is_uniform = int_lp_info->is_uniform;
       dlift_info->lps_info[ii].draft_angle = int_lp_info->draft_angle;
       dlift_info->lps_info[ii].fillet = int_lp_info->fillet;
       dlift_info->lps_info[ii].num_eds = int_lp_info->num_eds;
       dlift_info->lps_info[ii].eds_info = NULL;
       int_lp_info++;
     }

     inst_ptr += dlift_info->num_lps * sizeof(struct EMSint_lp_info);
     inst_ptr = ALIGN(inst_ptr, sizeof(IGRdouble));
     int_ed_info = (struct EMSint_ed_info *) inst_ptr;

     cur_loc += dlift_info->num_lps * sizeof(struct EMSdlft_lp_info);
     cur_loc = ALIGN(cur_loc, sizeof(IGRdouble));
     ed_info = (struct EMSdlft_ed_info *) cur_loc;  

     for(ii=0; ii<dlift_info->num_lps; ii++)
     {
       if (!dlift_info->lps_info[ii].is_uniform)
       {
         for(jj=0; jj<dlift_info->lps_info[ii].num_eds; jj++)
         {
           dlift_info->lps_info[ii].eds_info = ed_info;
           dlift_info->lps_info[ii].eds_info[jj].ed_GRid = 
                                                          int_ed_info->ed_GRid;
           dlift_info->lps_info[ii].eds_info[jj].ed_sf_type = 
                                                       int_ed_info->ed_sf_type;
           dlift_info->lps_info[ii].eds_info[jj].ed_cv_type = 
                                                       int_ed_info->ed_cv_type;
           dlift_info->lps_info[ii].eds_info[jj].ed_constraint_type = 
                                               int_ed_info->ed_constraint_type;
           dlift_info->lps_info[ii].eds_info[jj].draft_angle = 
                                                      int_ed_info->draft_angle;
           dlift_info->lps_info[ii].eds_info[jj].offset_code = 
                                                      int_ed_info->offset_code;
           int_ed_info++;
         }
         ed_info += dlift_info->lps_info[ii].num_eds;
       }
       else dlift_info->lps_info[ii].eds_info = NULL;
     }
   }
   else dlift_info->lps_info = NULL;
 }

wrapup:
 return (OM_S_SUCCESS);
}

method EMput_info(IGRlong *EMmsg; 
                  IGRushort options;
                  IGRuint type;
                  IGRuint size;
                  IGRchar *info)

/*
History
    DLB     07/08/91    Check for NULL info (meaning reset vla).
    DLB     06/08/91    Creation.
*/
{
 IGRlong                OM_stat=OM_S_SUCCESS;
 OMuint                 new_size, cur_ed=0, ii, jj;
 struct EMSdrafted_lift *recomp_info;
 struct EMSdlft_info    *extern_dlift_info;
 struct EMSint_info     *dlift_info;
 struct EMSint_lp_info  *lp_info;
 struct EMSint_ed_info  *ed_info;
 IGRchar                *cur_loc; 


 *EMmsg = EMS_S_Success;
 me->type = type;

 if (!info)
 {
   OM_stat = om$vla_set_dimension(varray = ME.EMSassoc->info,
                                  size = 0);
   goto wrapup;
 }

 recomp_info = (struct EMSdrafted_lift *) info;

 extern_dlift_info = recomp_info->dlift_info;

 new_size = sizeof(IGRdouble) + sizeof(IGRdouble);
 new_size += recomp_info->num_views * sizeof(struct EMSview_info) + 
             sizeof(IGRdouble);
 new_size += sizeof(struct EMSint_info) + sizeof(IGRdouble);
 new_size += (extern_dlift_info->num_lps * sizeof(struct EMSint_lp_info)) +
             sizeof(IGRdouble);

 for(ii=0; ii<extern_dlift_info->num_lps; ii++)
 {
   if (!extern_dlift_info->lps_info[ii].is_uniform) 
      new_size += extern_dlift_info->lps_info[ii].num_eds * 
                  sizeof(struct EMSint_ed_info);
 }
 new_size += sizeof(IGRdouble);
 
 OM_stat = om$vla_set_dimension(varray = ME.EMSassoc->info,
                                size = new_size);
 if (!(1 & OM_stat & *EMmsg)) goto wrapup; 

 cur_loc = ME.EMSassoc->info;
 OM_BLOCK_MOVE(&recomp_info->cht,
               cur_loc,
               sizeof(IGRdouble));
 cur_loc += sizeof(IGRdouble);

 OM_BLOCK_MOVE(&recomp_info->num_views,
               cur_loc,
               sizeof(OMuword));
 cur_loc += sizeof(IGRdouble); /*ALIGNMENT on next 8 byte bndry*/

 OM_BLOCK_MOVE(recomp_info->view_info,
               cur_loc,
               recomp_info->num_views * sizeof(struct EMSview_info));
 cur_loc += recomp_info->num_views * sizeof(struct EMSview_info);

 cur_loc = ALIGN(cur_loc, sizeof(IGRdouble));

 dlift_info = (struct EMSint_info *) cur_loc; 

 dlift_info->sf_GRid.objid = NULL_OBJID;
 dlift_info->sf_GRid.osnum = OM_Gw_current_OS;
 dlift_info->lift_operation = extern_dlift_info->lift_operation;
 OM_BLOCK_MOVE(extern_dlift_info->draft_vec, dlift_info->draft_vec,
               sizeof(IGRvector)); 
 dlift_info->mx_exlp_dangle = extern_dlift_info->mx_exlp_dangle;
 dlift_info->uniform_surface = extern_dlift_info->uniform_surface;
 dlift_info->no_fillets = extern_dlift_info->no_fillets;
 dlift_info->num_ed_infos = extern_dlift_info->num_ed_infos;
 dlift_info->num_lps = extern_dlift_info->num_lps;
 dlift_info->lps_info = NULL;
 
 cur_loc += sizeof(struct EMSint_info);

 /*put it on an 8 byte bdry*/
 cur_loc = ALIGN(cur_loc, sizeof(IGRdouble));

 if (extern_dlift_info->num_lps)
 {
   lp_info = (struct EMSint_lp_info *) cur_loc;
   for(ii=0; ii<extern_dlift_info->num_lps; ii++)
   {
     lp_info[ii].lp_GRid.objid = NULL_OBJID;
     lp_info[ii].lp_GRid.osnum = OM_Gw_current_OS;
     lp_info[ii].is_uniform = extern_dlift_info->lps_info[ii].is_uniform;
     lp_info[ii].draft_angle = extern_dlift_info->lps_info[ii].draft_angle;
     lp_info[ii].fillet = extern_dlift_info->lps_info[ii].fillet;
     lp_info[ii].num_eds = extern_dlift_info->lps_info[ii].num_eds;
     lp_info[ii].eds_info = NULL;
   }

   cur_loc += extern_dlift_info->num_lps * sizeof(struct EMSint_lp_info);

   /*put it on an 8 byte bdry*/
   cur_loc = ALIGN(cur_loc, sizeof(IGRdouble));
   ed_info = (struct EMSint_ed_info *) cur_loc;
   cur_ed = 0;

   for(ii=0; ii<extern_dlift_info->num_lps; ii++)
   {
     if (!lp_info[ii].is_uniform)
     {
       for(jj=0; jj<lp_info[ii].num_eds; jj++)
       {
         ed_info[cur_ed].ed_GRid.objid = NULL_OBJID;
         ed_info[cur_ed].ed_GRid.osnum = OM_Gw_current_OS;
         ed_info[cur_ed].ed_sf_type = 
                       extern_dlift_info->lps_info[ii].eds_info[jj].ed_sf_type;
         ed_info[cur_ed].ed_cv_type = 
                       extern_dlift_info->lps_info[ii].eds_info[jj].ed_cv_type;
         ed_info[cur_ed].ed_constraint_type = 
               extern_dlift_info->lps_info[ii].eds_info[jj].ed_constraint_type;
         ed_info[cur_ed].draft_angle = 
                      extern_dlift_info->lps_info[ii].eds_info[jj].draft_angle;
         ed_info[cur_ed].offset_code = 
                      extern_dlift_info->lps_info[ii].eds_info[jj].offset_code;
         cur_ed++;                     
       }
     }
   }
 }

wrapup:
 EMWRAPUP(*EMmsg, OM_stat, "dlft.put_info")
 return(OM_stat);
}
end implementation EMSsfdlift;
