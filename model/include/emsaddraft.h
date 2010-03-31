# ifndef emsaddraft_include
# define emsaddraft_include



  struct EMSadj_surf_info 
  {
  struct GRid myself;
  GRobjid copy;
  IGRboolean operate;
  GRobjid the_loop;
  IGRint loop_no;
  IGRint par_loop_no;
  IGRushort loop_props;
  IGRushort affect;
  IGRint extend;
  IGRint num_adjacent;
  GRobjid *edges;
  GRobjid *commedges;
  GRobjid *adj_surfs;
  GRobjid *adj_loops;
  IGRint *comedge_cncv;
  struct EMSinters *my_inters;
  struct EMSinters *adj_inters;
  struct EMSadj_surf_info *next;
  IGRboolean pos_orient;
  IGRboolean planar;
  };

#define EM_ADDRFT_TRIM        0x01
#define EM_ADDRFT_EXTND       0x02
#define EM_ADDRFT_PIVOT       0x04
#define EM_ADDRFT_DRAFT_SRF   0x08
#define EM_ADDRFT_INTRNL_LP   0x10
#define EM_ADDRFT_P_LOOP      0x20
#define EM_ADDRFT_C_LOOP      0x40
      
#endif
