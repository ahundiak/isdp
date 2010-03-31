#ifndef TOproto_ta
#define TOproto_ta
#include "TOtopology.h"
#include "TOstruct1.h"

extern int TOgen_engine( struct topology *topo);

extern int TOconnect( struct topology *topo,
                      short           *status,
                      short           *num_se,
                      struct surface  *sf1);

extern int TOinit_mo( struct topology *topo);
extern int TOinit_input( struct topology *topo);
extern int TOinit_topo( struct topology *topo);

extern int TOinit_el( struct topology *topo,
                      struct elist    **elehead,
                      struct elist    **eletail);
extern int TOinit_pl( struct topology *topo,
                      struct plist    **elehead,
                      struct plist    **eletail);
extern int TOinit_pt( struct topology *topo,
                      struct point    **elehead,
                      struct point    **eletail);
extern int TOinit_tl( struct topology *topo,
                      struct telist   **elehead,
                      struct telist   **eletail);

extern int TOadd_mo( struct topology *topo);

extern int TOadd_sf( struct topology *topo,
                     struct Ext_data_surface  *sfid,
                     short           num_ed,
                     struct elist    **elehead,
                     struct elist    **eletail);
  
extern int TOadd_ed(struct topology *topo,
                  struct Ext_data_edge    *edid,
                  short             status,
                  struct edge       *edid0,
                  struct edge       *edid1,
                  struct edge       *edid2,
                  struct surface    *sf,
                  struct point      *p1,
                  struct point      *p2,
                  short             num_te,
                  struct telist     **elehead,
                  struct telist     **eletail);

extern int TOadd_pt(struct topology *topo,
                  short             status,
                  double            pt[3],
                  struct edge       *ed,
                  struct top_point  *tp);

extern int TOadd_pt1(struct topology  *topo,
                     short            status,
                     double           pt[3],
                     struct edge      *ed,
                     struct top_point *tp,
                     struct point     **ptail);

extern int TOadd_tp(struct topology  *topo,
                    short            status,
                    short           num_ele,
                    struct plist     **elehead,
                    struct plist     **eletail);

extern int TOadd_te( struct topology *topo,
                     short           status,
                     short           num_ele,
                     struct elist    **elehead,
                     struct elist    **eletail);


extern int TOadd_el(struct topology  *topo,
                    struct elist     *eltail,
                    struct edge      *ied);

extern int TOadd_pl(struct topology  *topo,
                    struct plist     *eltail,
                    struct point     *ied);

extern int TOadd_tl(struct topology  *topo,
                    struct telist    *eltail,
                    struct top_edge  *ied);

extern int TObasic_log(struct topology *topo);

extern int TOpt_vector(struct topology *topo,
                       struct point    **ipt);

extern int TOsort_pt(struct topology *topo,
                     struct point    **ipt);

extern int TOsort_ed(struct topology *topo);

extern int TOsort_sf(struct topology *topo,
                         short           *num_se);

extern int TOsuper_ed(struct topology *topo,
                      struct point    **p,
                      short           *num_se);

extern int TOlist_se( struct topology *topo,
                      struct elist    *eltail,
                      short           *num_se,
                      struct edge     *seid,
                      struct edge     *edid);

extern int TOlist_pe( struct topology *topo,
                      struct elist    *eltail,
                      short           *num_pe,
                      struct edge     *edid);

extern int TOfind_ed(struct topology *topo,
                     short           *num_se,
                     struct edge     *ed);

extern int TOfind_rest(struct topology *topo);
extern int TOfree_edges(struct topology *topo);

extern int TOstitch_ed(struct topology *topo,
                       short           sti_option,
                       struct edge     *ed1,
                       struct edge     *ed2,
                       int             *n_poi_p_con,
                       struct point    **p_con_head,
                       struct point    **p_con_tail,
                       int             *n_poi_n_con,
                       struct point    **n_con_head,
                       struct point    **n_con_tail,
                       int             *n_poi_r_con,
                       struct point    **r_con_head,
                       struct point    **r_con_tail);

extern int TOsplit_ed(struct topology *topo);

extern int TOsplit_se(struct topology *topo,
                      struct edge *ed1,
                      struct edge *ed2);

extern int TOprint_sf(struct topology *topo);
extern int TOprint_ed(struct topology *topo);
extern int TOprint_pt(struct topology *topo);
extern int TOprint_tp(struct topology *topo);
extern int TOprint_te(struct topology *topo);

#define TOnew(name) extern struct name *TOnew_##name(struct topology *) ;

#define TOfree(name) \
	extern void TOfree_##name(struct topology *topo, struct name *p) ;

#define TOall_proc(name) TOnew(name) TOfree(name)

TOall_proc(surface)
TOall_proc(edge)
TOall_proc(point)
TOall_proc(top_point)
TOall_proc(top_edge)

TOall_proc(elist)
TOall_proc(plist)
TOall_proc(telist)

#undef TOnew
#undef TOfree

#define TOfree_list(name)  extern void TOfree_list_##name( \
	struct topology *topo,  struct name *head, struct name *tail) ;

TOfree_list(elist)
TOfree_list(plist)
TOfree_list(telist)

#undef TOfree_list

extern char *TOnew_memory(struct topology *topo,int size);

#endif
