/* ###################   APOGEE COMPILED   ################## */
class implementation EMSptedge;

method EMsfintdata (IGRlong *msg; 
                    struct GRid *sf1; IGRboolean sf1_rev;
                    struct GRmdenv_info *toxypln1, *towspace1;
                    struct GRid *sf2; IGRboolean sf2_rev;
                    struct GRmdenv_info *toxypln2, *towspace2;
                    IGRushort proc_info;
                    struct GRvg_construct *const_args;
                    IGRushort outworld_options;
                    IGRushort outparam_options;
                    IGRushort trim_options;
                    IGRlong *num_inters;
                    struct EMSinters **sf1_inters; 
                    struct EMSinters **sf2_inters)
{
  *msg = EMS_S_Success;
  return (OM_S_SUCCESS);
}

end implementation EMSptedge;
