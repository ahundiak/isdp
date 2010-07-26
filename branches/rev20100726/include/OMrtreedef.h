#ifndef OMrtreedef
#define OMrtreedef

#include "OMobjectcomm.h"
#include "OMminimum.h"


#define   NONLEAF       (0)
#define   LEAF          (1)

#define NORM(a, b, c, d) ((c - d) == 0 ? (0) : ( (a - b) / (c - d)) )

#define   NORMALIZE(a)                     ( (a) < 0 ? (-(a)) : (a) )

#define SIGN(s)		((s<0)?-1:1)	/* Used in 3d skew search */

/* maximum keys in R_LF_PAGE_2D_INT node. */

#define   R_MAX_KEYS_2D_INT ((DB_BYTES_RPAGE-sizeof(R_PAGE_HDR)) / (sizeof(DB_2D_INT_BOX) + sizeof(OM_S_OBJID)) )

/* maximum keys in R_LF_PAGE_2D_DBL node. */
#define   R_MAX_KEYS_2D_DBL ((DB_BYTES_RPAGE-sizeof(R_PAGE_HDR)) / (sizeof(DB_2D_DBL_BOX) + sizeof(OM_S_OBJID)) )

/* maximum keys in R_LF_PAGE_3D_INT node. */
#define   R_MAX_KEYS_3D_INT ((DB_BYTES_RPAGE-sizeof(R_PAGE_HDR)) / (sizeof(DB_3D_INT_BOX) + sizeof(OM_S_OBJID)) )

/* maximum keys in R_LF_PAGE_3D_DBL node. */
#define   R_MAX_KEYS_3D_DBL ((DB_BYTES_RPAGE-sizeof(R_PAGE_HDR)) / (sizeof(DB_3D_DBL_BOX) + sizeof(OM_S_OBJID)) )

#define R_MAX_KEYS_2D_INT_PLUS_ONE (R_MAX_KEYS_2D_INT + 1)
#define R_MAX_KEYS_2D_DBL_PLUS_ONE (R_MAX_KEYS_2D_DBL + 1)
#define R_MAX_KEYS_3D_INT_PLUS_ONE (R_MAX_KEYS_3D_INT + 1)
#define R_MAX_KEYS_3D_DBL_PLUS_ONE (R_MAX_KEYS_3D_DBL + 1)

#define   IS_R_LEAF(t)   ( ((t) == R_LF_RT_PAGE) || ((t) == R_LF_NR_PAGE) )
#define   IS_R_ROOT(t)   ( ((t) == R_LF_RT_PAGE) || ((t) == R_NL_RT_PAGE) )
#define   NOT_R_LEAF(t)  ( ((t) == R_NL_RT_PAGE) || ((t) == R_NL_NR_PAGE) )
#define   NOT_R_ROOT(t)  ( ((t) == R_LF_NR_PAGE) || ((t) == R_NL_NR_PAGE) )


/* element of path array used to track from root to leaf node. */

typedef
  struct
    {
    OM_S_OBJID Child_page_objid;
    unsigned char Entry_number;
    } R_PATH_ENTRY;

/* structure for remembering path from root to leaf node. */

typedef
  struct
    {
    unsigned char Path_count;
    R_PATH_ENTRY Path_array[10];
    } R_PATH_HISTORY;


/* Following is the RTREE header definition for both LF & NL */
typedef
  struct
    {
    unsigned char Page_type;
    unsigned char Rtree_type;
    unsigned char Key_count;
    unsigned char Filler_1;         /* this is just a dummy byte */
    int Page_count;		    /* This field in root page indicates
				       the number of pages in the tree */
    } R_PAGE_HDR;

/* Following are the RTREE non-leaf page definitions. */




/* elements of re-insert array used to store information of re-insert entry */


    
/* structures for collecting all the entries needed to reinsert */
#define RTREE_3D_FLT   ( 4 )

typedef struct 
{
double sx,sy,sz;
} DB_vector;



struct rtree_3d_dbl
{
	double xmin, ymin, zmin, xmax, ymax, zmax;
};

typedef
  struct
    {
    int (*user_action_routine_p)();
    char *user_context_p;
    } RTREE_LOCAL_CONTEXT_3D_FLT;


/* maximum keys in R_LF_PAGE_3D_FLT node. */
#define   R_MAX_KEYS_3D_FLT ((DB_BYTES_RPAGE-sizeof(R_PAGE_HDR)) / (sizeof(DB_3D_FLT_BOX) + sizeof(OM_S_OBJID)) )

#define R_MAX_KEYS_3D_FLT_PLUS_ONE (R_MAX_KEYS_3D_FLT + 1)


typedef
  struct
    {
    R_PAGE_HDR  Header;
    DB_3D_FLT_BOX Key[R_MAX_KEYS_3D_FLT];
    OM_S_OBJID    Objid[R_MAX_KEYS_3D_FLT];
    } R_PAGE_3D_FLT;

/* elements of re-insert array used to store information of re-insert entry */

typedef
  struct
    {
    int Level;
    unsigned char    Entry_type;
    R_PACKED_KEYENTRY_3D_FLT Reinsert_entry;
    } R_REINSERT_ENTRY_3D_FLT;

/* structures for collecting all the entries needed to reinsert */
typedef
  struct
    {
    unsigned char Entry_count;
    R_REINSERT_ENTRY_3D_FLT Reinsert_array[500];
    } R_REINSERT_SET_3D_FLT;

extern int DB_rtree_convert_key __((unsigned char tree_type,
	DB_3D_DBL_BOX *p_key, OM_p_OBJID p_objid,
	R_PACKED_KEYENTRY_3D_FLT *p_converted_key));

#endif  /* OMrtreedef */
