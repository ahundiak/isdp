/*
Name
        listref.h

Description
        This file is used in the utility function GRlist_ref_files, which
        reads a design file and returns a list of attached reference files.
        This file was extracted from the .c file produced by opping
        GRreffile.S.  It is therefore sensitive to any changes in either
        GRreffile or any of its ancestors.

History
        mrm     07/07/02    creation

*/

#ifndef listref_include
#define listref_include

#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"

 struct Root_instance 
  {
   struct OM_sd_objecthdr OPPobjecthdr;
  };
 struct GRgraphics_instance 
  {
   short properties;
   short level;
  };
 struct GRconnector_instance 
  {
   OM_p_CHANNEL_HDR    to_owners;
  };
 struct GRnotify_instance 
  {
   OM_p_CHANNEL_HDR    notification;
  };
 struct GRvg_instance 
  {
   struct IGRdisplay display_attr;
  };
 struct GRreffile_instance 
  {
   OM_p_CHANNEL_HDR    to_mgr;
   OM_p_CHANNEL_HDR    to_clone;
   OM_p_CHANNEL_HDR    to_clip;
   OM_p_CHANNEL_HDR    to_context;
   struct OM_sd_varlenarr_descr filename_descr;
   struct OM_sd_varlenarr_descr osname_descr;
   struct OM_sd_varlenarr_descr saved_view_descr;
   unsigned long ref_properties;
   struct OM_sd_varlenarr_descr description_descr;
   struct OM_sd_varlenarr_descr scale_factor_descr;
   double range[6];
   double vw_volume[6];
   double vw_rotation[16];
   double vw_origin[3];
   int dp_levels[32];
   double master_to_ref_matrix[16];
   double ref_to_master_matrix[16];
  };
struct GRreffile_total_instance
 {
  struct Root_instance Root;
  struct GRgraphics_instance GRgraphics;
  struct GRconnector_instance GRconnector;
  struct GRnotify_instance GRnotify;
  struct GRvg_instance GRvg;
  struct GRreffile_instance GRreffile;
 };

#endif
