#ifndef SKgraph_include
#define SKgraph_include

/*
 * Structures used in Bipartite Matching
 */

struct SKadj_node
 {
  struct GRid       nd_GRid;
  struct SKadj_node *next;
 };

struct SKhd_node
 {
  struct GRid         nd_GRid;
  IGRshort            props;
  IGRshort            level;
  IGRshort            dfn;
  struct SKadj_node   *adj_node;
 };

struct SKadj_list
 {
  IGRint               num_hd_nodes;
  IGRint               hd_nodes_arrsz;
  struct  SKhd_node    *hd_nodes;
 };
 
struct SKed_info
 {
  struct SKhd_node   *hd_node;
  struct SKadj_node  *adj_node;
  struct SKed_info   *next;
 };

struct SKaux_graph
 {
  struct SKed_info  *eds_info;
  struct SKed_info  *trash_eds;
 };

struct SKsc_node
 {
  struct GRid        nd_GRid;
  IGRint             num_hd_nodes;
  IGRint             hd_nodes_arrsz;
  struct SKhd_node   *hd_nodes;
  IGRshort           props;
  IGRshort           level;
  struct SKadj_node  *adj_node;
 };

struct SKsc_list
 {
  IGRint           num_sc_nodes;
  IGRint           sc_nodes_arrsz;
  struct SKsc_node *sc_nodes;
 };

enum SKnode_type
 {
  SK_VAR_DATA,
  SK_FUNC_DATA,
  SK_SCOMP_DATA
 };

 union SKnode
  {
    struct SKhd_node  *hd_node;
    struct SKsc_node  *sc_node;
  };


struct SKqu_node
 {
  enum SKnode_type  node_type;
  union SKnode      node;
  struct SKqu_node  *next;
 };

struct SKqueue
 {
  struct SKqu_node       *start_queue;
  struct SKqu_node       *end_queue;
  struct SKqu_node       *trash_node;
 };

struct SKgraph
 {
  struct SKadj_list  fns_list;
  struct SKadj_list  vars_list;
  struct SKsc_list   sc_list;
  struct SKqueue     sol_path;
 };

struct SKgr_info
 {
  IGRint       num_uncnstr_vars;
  IGRint       uncnstr_vars_arrsz;
  struct GRid  *uncnstr_vars;
  IGRint       num_red_cnstrs;
  IGRint       red_cnstrs_arrsz;
  struct GRid  *red_cnstrs;
 };

#endif
