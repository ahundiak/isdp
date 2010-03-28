#ifndef codynmeas_include
#define  codynmeas_include

struct disp_val_info {
      
     IGRboolean              supr_act_flag;
     IGRboolean              change_flag;
     IGRboolean              disp_fld_flag;
     IGRboolean              supr_dz_flag;
     IGRboolean              disp_dist_flag;
     IGRshort                mode_flag;
     struct  IGRdisplay      active_display;
     struct  GRid            ModuleGrid;
     struct GRevent          events[2];
     IGRchar                 units[24];
};
#endif
