/*
**  TOproto_ds.h - prototypes for dsl layer
*/

#include "TOtopology.h"
#include "TOstruct1.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "igrtypedef.h"
#include "igr.h"


/* file TOanaly_ds.I */

extern int TOinitialize_top( struct topology *topo);
extern int TOadd_surfaces( struct topology *topo, int num_sf, 
                       	   struct GRid *sfids);
extern int TOgen_input( struct topology *topo, int num_sf, 
                       	struct GRid *sfids);
extern int TOadd_engine( struct topology *topo, struct topology *topo1);
extern int TOdelete_surfaces(struct topology *topo, int num_sf, 
                             struct GRid *objid);
extern int TOdelete_topology(struct topology *topo);

extern int TOana_out_bdr(struct topology *topo,
                         int *n_out_bdr,
                         struct elist **out_bdr_head,
                         struct elist **out_bdr_tail);

extern int TOana_dist(struct topology *topo,
                      int *n_poi_con,
                      struct telist **poi_con_head,
                      struct telist **poi_con_tail,
                      int *n_poi_p_con,
                      struct point    **p_con_head,
                      struct point    **p_con_tail);

extern int TOana_nor(struct topology *topo,
                     int *n_poi_con,
                     struct telist **poi_con_head,
                     struct telist **poi_con_tail,
                     int *n_nor_con,
                     struct telist **nor_con_head,
                     struct telist **nor_con_tail,
                     int *n_rad_con,
                     struct telist **rad_con_head,
                     struct telist **rad_con_tail,
                     int *n_poi_p_con,
                     struct point    **p_con_head,
                     struct point    **p_con_tail,
                     int *n_poi_n_con,
                     struct point    **n_con_head,
                     struct point    **n_con_tail,
                     int *n_poi_r_con,
                     struct point    **r_con_head,
                     struct point    **r_con_tail);

extern int TOanalyze_top(struct topology *topo,
                 int *n_out_bdr, struct elist **out_bdr_head,
                                 struct elist **out_bdr_tail,
                 int *n_poi_con, struct telist **poi_con_head,
                                 struct telist **poi_con_tail,
                 int *n_nor_con, struct telist **nor_con_head,
                                 struct telist **nor_con_tail,
                 int *n_rad_con, struct telist **rad_con_head,
                                 struct telist **rad_con_tail,
                 int *n_ramific, struct telist **ramific_head,
                                 struct telist **ramific_tail,
                 int *n_poi_p_con, struct point **p_con_head,
                                   struct point **p_con_tail,
                 int *n_poi_n_con, struct point **n_con_head,
                                   struct point **n_con_tail,
                 int *n_poi_r_con, struct point **r_con_head,
                                   struct point **r_con_tail);

extern int TOdelete_top(struct topology *topo);
extern int TOinvest_edge_match(struct topology *topo,
                               struct edge     *edge1,
                               struct edge     *edge2,
                               int             *n_poi_p_con,
                               struct point    **p_con_head,
                               struct point    **p_con_tail,
                               int             *n_poi_n_con,
                               struct point    **n_con_head,
                               struct point    **n_con_tail,
                               int             *n_poi_r_con,
                               struct point    **r_con_head,
                               struct point    **r_con_tail);

extern int TOdelete_ext_surf(struct Ext_data_surface *surface);

extern int TOdelete_ext_edge(struct Ext_data_edge *edge);

/* file TOdisplay.I */
extern int TOdisplay(struct topology *topo,
                     int n_out_bdr, struct elist *out_bdr_head,
                                    struct elist *out_bdr_tail,
                     int n_poi_con, struct telist *poi_con_head,
                                    struct telist *poi_con_tail,
                     int n_nor_con, struct telist *nor_con_head,
                                    struct telist *nor_con_tail,
                     int n_rad_con, struct telist *rad_con_head,
                                    struct telist *rad_con_tail,
                     int n_ramific, struct telist *ramific_head,
                                    struct telist *ramific_tail,
                     int n_poi_p_con, struct point *p_con_head,
                                      struct point *p_con_tail,
                     int n_poi_n_con, struct point *n_con_head,
                                      struct point *n_con_tail,
                     int n_poi_r_con, struct point *r_con_head,
                                      struct point *r_con_tail);

extern int TOdisplay_points(struct topology *topo,
                            int n_poi_con, struct point *p_con_head,
                                           struct point *p_con_tail,
                            int n_nor_con, struct point *n_con_head,
                                           struct point *n_con_tail,
                            int n_rad_con, struct point *r_con_head,
                                           struct point *r_con_tail);

extern int TOdelete_temp(struct topology *topo,int and_redraw);
extern int TOdelete_points(struct topology *topo,int and_redraw);

extern int TOadd_pe(struct topology *topo,
                    struct edge     *ed0,
                    double          para[2][2],
                    struct point    *end_pts[2][2],
                    struct edge     **new_ed);

extern int TOpartedge(struct topology *topo,
                      struct edge **ed,
                      IGRint ovlap_type[2][4],
                      IGRdouble bsovlap[2][4]);

extern int TOpartedge1(struct topology *topo,
                       struct edge **ed,
                       IGRint ovlap_type[2][4],
                       IGRdouble bsovlap[2][4]);

extern int TOedstitch(struct topology *topo,
                      struct EMSstitch_info *pair,
                      struct          edge **ed,
                      IGRint          sample_size,
                      IGRdouble       match_tol,
                      IGRdouble       same_no_tol,
                      IGRdouble       same_rd_tol,
                      int             *n_poi_p_con,
                      struct point    **p_con_head,
                      struct point    **p_con_tail,
                      int             *n_poi_n_con,
                      struct point    **n_con_head,
                      struct point    **n_con_tail,
                      int             *n_poi_r_con,
                      struct point    **r_con_head,
                      struct point    **r_con_tail);


extern IGRint TOgetcv_ovlap(IGRlong             *EMmsg,
                            struct edge         **ed,
                            IGRint              *num_ovlap,
                            IGRdouble           *ovlap0,
                            IGRdouble           *ovlap1,
                            IGRdouble           tolerance,
                            IGRint              *hitinfo0,
                            IGRint              *hitinfo1,
                            IGRushort           options);

extern IGRint TOvalcv_ovlap( IGRlong              *EMmsg,
                            struct IGRbsp_curve   *crv0,
                            struct IGRbsp_curve   *crv1,
                            IGRdouble             *ovlap0,
                            IGRdouble             *ovlap1,
                            IGRint                sample_size,
                            IGRint                *num_hits,
                            IGRint                *num_misses,
                            IGRdouble             tolerance,
                            IGRushort             option,
                            struct topology       *topo,
                            int                   *n_poi_p_con,
                            struct point          **p_con_head,
                            struct point          **p_con_tail);

extern IGRint TOvalsf_ovlap(IGRlong              *EMmsg,
                            GRobjid               surf[2],
                            GRobjid               edge[2],
                            GRspacenum            pair_space[2],
                            struct IGRbsp_surface *surf_geom[2],
                            struct IGRbsp_curve   *edge_geom[2],
                            IGRdouble             *ovlap0,
                            IGRdouble             *ovlap1,
                            IGRint                sample_size,
                            IGRint                *num_hits,
                            IGRint                *num_misses,
                            IGRdouble             tolerance,
                            IGRdouble             same_an_tol,
                            IGRdouble             same_rd_tol,
                            IGRushort             option,
                            struct topology       *topo,
                            int                   *n_poi_p_con,
                            struct point          **p_con_head,
                            struct point          **p_con_tail,
                            int                   *n_poi_n_con,
                            struct point          **n_con_head,
                            struct point          **n_con_tail,
                            int                   *n_poi_r_con,
                            struct point          **r_con_head,
                            struct point          **r_con_tail);

extern IGRint TOinv_nor_cont(GRobjid        surf[2],
                             GRobjid        edge[2],
                             GRspacenum     pair_space[2],
                             struct IGRbsp_surface *surf_geom[2],
                             struct IGRbsp_curve   *edge_geom[2],
                             IGRdouble      cvpar[2],
                             IGRpoint       point_tmp,
                             IGRpoint       base_point,
                             IGRdouble      sti_tol,
                             IGRdouble      same_an_tol,
                             IGRdouble      same_rd_tol,
                             IGRdouble      *nor,
                             IGRdouble      *rad,
                             IGRushort      option,
                             struct topology       *topo);

extern void TOquick_pr_pt_cv (struct IGRbsp_curve *crv,
                              IGRdouble          start,
                              IGRdouble           ende,
                              IGRint           num_pts,
                              IGRdouble     *input_pts,
                              IGRdouble    *output_pts,
                              IGRdouble    *output_par,
                              IGRdouble     *distances,
                              IGRint            *max_i,
                              IGRdouble      *max_dist,
                              IGRint            *err_i,
                              IGRlong             *ret);
extern int TOprint_all_viol(struct topology *topo,
                             IGRint          size_flag,
                             IGRdouble       *ovlap0,
                             IGRdouble       *ovlap1,
                             IGRdouble       *in_pts,
                             IGRdouble       *in_par,
                             IGRdouble       *out_pts,
                             IGRdouble       *out_par,
                             IGRdouble       *dist,
                             IGRint          max_i,
                             IGRdouble       max_dist,
                             IGRdouble       *nor,
                             IGRint          max_n,
                             IGRdouble       max_nor,
                             IGRdouble       *rad,
                             IGRint          max_r,
                             IGRdouble       max_rad,
                             IGRlong         *ret);

extern int TOprint_dist_viol(struct topology *topo,
                             IGRint          size_flag,
                             IGRdouble       *ovlap0,
                             IGRdouble       *ovlap1,
                             IGRdouble       *in_pts,
                             IGRdouble       *in_par,
                             IGRdouble       *out_pts,
                             IGRdouble       *out_par,
                             IGRdouble       *dist,
                             IGRint          max_i,
                             IGRdouble       max_dist,
                             IGRlong         *ret);

extern int TOprint_hd(struct topology *topo);
 
