#ifndef SKgraphdef_include
#define SKgraphdef_include

/*
 * The following options are used in graph creation
 */

#define SK_CREATE_GRAPH       0x1
#define SK_CREATE_SOL_PATH    0x2

/*
 * The following defintions are used in Bipartite Matching
 */

#define SK_NODE_UNUSED         0x1
#define SK_NODE_VAR            0x2
#define SK_NODE_DELETED        0x4
#define SK_NODE_SCOMP          0x8
#define SK_NODE_ZERO_LEVEL     0x10
#define SK_NODE_DUMMY_FUNC     0x20

/*
 * The following options are used in analyzing a graph
 */

#define SK_OPT_RED_CONSTRAINTS       0x1
#define SK_OPT_UNCONSTRAINED_VARS    0x2

/*
 * The options used in build a graph
 */

#define SK_OPT_ALL               0x01
#define SK_OPT_INIT_GRAPH        0x02
#define SK_OPT_BUILD_ADJ_LIST    0x04
#define SK_OPT_INIT_BIPART_MATCH 0x08
#define SK_OPT_BIPART_MATCH      0x10
#define SK_OPT_ASSIGN_SCOMP      0x20
#define SK_OPT_CREATE_SOL_PATH   0x40

#define SK_NEW_CNSTR_ID    -911
#define SK_NEW_CNSTR_OS    -911

#endif
