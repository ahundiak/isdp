# ifndef omrtreeops_include
# define omrtreeops_include 1

#define OM_R_ADD 	(1)
#define OM_R_REPLACE	(2)
#define OM_R_REMOVE	(3)
#define OM_R_FREMOVE	(4)


struct OM_sd_rtree_op
       {
       OM_S_OBJID objid;
       unsigned char op_code;
       OMuword osnum;
       };

typedef struct OM_sd_rtree_op  OM_S_RTREE_OP;
typedef struct OM_sd_rtree_op  *OM_p_RTREE_OP;

OM_S_RTREE_OP  *OM_GA_rtree_ops;
int  OM_Gi_ops_head, OM_Gi_ops_tail, OM_Gi_ops_count, OM_Gi_record_ops;

#endif /* omrtreeops_include */
