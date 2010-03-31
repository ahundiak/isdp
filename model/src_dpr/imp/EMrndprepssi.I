/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSbnd.h"
#include "EMSbnddef.h"

method  EMprepare_rnd_ssi(IGRlong *EMmsg;
                          struct EMround_save_state *svst_info)
{
 
 IGRlong                      stat_OM, msg;
 IGRint                       i, j, inx;
 union   EMSssiSizeData       ssi_size;
 union   EMSssi_table         *ssi_table;
 struct  EMSrndssi_table      *my_info;

/*-------------------------------------------------------------------*/

stat_OM = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

ssi_table = NULL;

ssi_size.rnd_info.num_surfaces = svst_info->num_surfaces;

ssi_size.rnd_info.num_regions_in = 0;

for (i=0; i<(svst_info->num_surfaces); i++)
    ssi_size.rnd_info.num_regions_in += svst_info->num_regions_in[i];

ssi_size.rnd_info.num_regions_out = 0;

for (i=0; i<(svst_info->num_surfaces); i++)
    ssi_size.rnd_info.num_regions_out += svst_info->num_regions_out[i];

ssi_size.rnd_info.num_edges_out = svst_info->num_edges_out;

ssi_size.rnd_info.num_edges_in = 0;

for (i=0; i<(svst_info->num_edges_out); i++)
    ssi_size.rnd_info.num_edges_in += svst_info->num_edges_in[i];

ssi_size.rnd_info.num_edges_rounded = svst_info->num_edges_rounded;

stat_OM = om$send (msg = message EMSdpr.EMgetSSIbuffer(&msg, &ssi_size,
                         &ssi_table),
                   targetid = my_id);
EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
  
/* fill the buffer */

my_info = &ssi_table->rnd_info;
my_info->num_surfaces = svst_info->num_surfaces;
for (i=0; i<svst_info->num_surfaces; i++)
 {
  my_info->surface_ids[i] = svst_info->surface_ids[i];
 }

for (i=0; i<svst_info->num_surfaces; i++)
 {
  my_info->num_regions_in[i] = svst_info->num_regions_in[i];
 }

inx = 0;
for (i=0; i<svst_info->num_surfaces; i++)
 {
  for (j=0; j<svst_info->num_regions_in[i]; j++, inx++)
   {
    my_info->region_in_ids[inx] = svst_info->region_in_ids[i][j];
   }
 }

for (i=0; i<svst_info->num_surfaces; i++)
 {
  my_info->num_regions_out[i] = svst_info->num_regions_out[i];
 }

inx = 0;
for (i=0; i<svst_info->num_surfaces; i++)
 {
  for (j=0; j<svst_info->num_regions_out[i]; j++, inx++)
   {
    my_info->region_out_ids[inx] = svst_info->region_out_ids[i][j];
   }
 }

my_info->num_edges_out = svst_info->num_edges_out;
for (i=0; i<svst_info->num_edges_out; i++)
 {
  my_info->edge_out_ids[i] = svst_info->edge_out_ids[i];
 }

for (i=0; i<svst_info->num_edges_out; i++)
 {
  my_info->num_edges_in[i] = svst_info->num_edges_in[i];
 }

inx = 0;
for (i=0; i<svst_info->num_edges_out; i++)
 {
  for (j=0; j<svst_info->num_edges_in[i]; j++, inx++)
   {
    my_info->edge_in_ids[inx] = svst_info->edge_in_ids[i][j];
   }
 }

my_info->num_edges_rounded = svst_info->num_edges_rounded;
for (i=0; i<svst_info->num_edges_rounded; i++)
 {
  my_info->rounded_edge_ids[i] = svst_info->rounded_edge_ids[i];
 }

stat_OM = om$send (msg = message EMSdpr.EMputSSI (&msg, ssi_table), 
                   targetid = my_id); 
EMerr_hndlr (!(1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:

  EMWRAPUP (*EMmsg, stat_OM, "In EMSsfround.EMprepare_ssi");
  if(ssi_table)
    {
    om$dealloc(ptr = ssi_table);
    ssi_table = NULL;
    }
  return (stat_OM);

}

end implementation  EMSsfround;
                                  
