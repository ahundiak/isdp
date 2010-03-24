#ifndef OMINDEX							/*+public*/
#define OMINDEX 1
#include "OMlimits.h"

/* define tree types */

#define RTREE_3D_DBL   ( 3 )
#define BTREE_STRING   ( 1 )
#define BTREE_INTEGER  ( 2 )
#define BTREE_FLOAT    ( 3 )
#define BTREE_DOUBLE   ( 4 )

#define BTREE_NODUP    (char)(128)

typedef struct
	{
	double xmin, ymin, zmin, xmax, ymax, zmax;
	} DB_3D_DBL_BOX;

typedef struct
	{
	float xmin, ymin, zmin, xmax, ymax, zmax;
	} DB_3D_FLT_BOX;

/*
OM_sd_key_desc

Description:
	    This data structure is used to define variant keys in both
  	    rtree and btree. To use it, set the type field to indicate
	    the key type and use the corresponding pointer to store
	    the address of the key

*/	

struct OM_sd_key_desc						
	{
         int type;		/* Identifies the type of key */
#define  KEY_STRING (1)         /* Btree only */
#define  KEY_INTEGER (2)	/*   "    "   */
#define  KEY_FLOAT   (3)	/*   "    "   */
#define  KEY_DOUBLE  (4)	/*   "    "   */
#define  KEY_3D_DBL  (8) 	/*   Rtree only   */
		union 
		{
		char   *p_string;
		int    *p_integer;
		float  *p_float;
		double *p_double;
		DB_3D_DBL_BOX *p_3ddbl;
		} key;
	};		

typedef struct OM_sd_key_desc OM_S_KEY_DESC;
typedef struct OM_sd_key_desc *OM_p_KEY_DESC;


/*

OM_sd_objarray

Description:
	    This structure is defined for translate message, if the
	    message is successful, the count field will be updated to
	    indicate the number of entries in the tree that exactly
	    matched the key, and the array will contain a list of objids
	    up to the number of count.

*/	

struct OM_sd_objarray
	{
	 int size;		/* Total size of this structure in bytes */
	 int count;		/* Number of entries in the array */
         int tree_type;		/* The type of tree */
    	 OM_S_OBJID array[1];   /* Array to hold objids */
	 };					

typedef struct OM_sd_objarray OM_S_OBJARRAY;
typedef struct OM_sd_objarray *OM_p_OBJARRAY;


/*
OM_sd_keyname

Description:
	    This structure will be filled with btree key including its
	    length and key string.
	
*/

struct OM_sd_keyname
	{
	double key_len;
	char  key_name[MAXNAMSIZE];
	};							/*-dsdesc*/
	
typedef struct OM_sd_keyname OM_S_KEYNAME;
typedef struct OM_sd_keyname *OM_p_KEYNAME;

struct OM_sd_btree_contents
	{
	OM_S_OBJID	objid;
	OM_S_KEYNAME	name;
	};							/*-dsdesc*/
	
typedef struct OM_sd_btree_contents OM_S_BTREE_CONTENTS;
typedef struct OM_sd_btree_contents *OM_p_BTREE_CONTENTS;


/* The following definitions are used in skew searches */

typedef
  struct
    {
    DB_3D_DBL_BOX range1;
    DB_3D_DBL_BOX range2;
    double sx, sy, sz;
    } SKEW_KEY_3D_DBL;


								/*+dsdesc*/
struct OM_sd_skew_desc						
	{
    int type;		/* Identifies the type of key */
    union 
 	   {
	   SKEW_KEY_3D_DBL *p_skew_3ddbl;
	   } key;
	};							/*-dsdesc*/

typedef struct OM_sd_skew_desc OM_S_SKEW_DESC;
typedef struct OM_sd_skew_desc *OM_p_SKEW_DESC;


/* user compare macro */

#define USER_COMPARE( user_compare_p, key1_ptr, key2_ptr, length1, length2, value ) \
{									\
int result;								\
									\
if (user_compare_p != 0)						\
   value = (*user_compare_p)( key1_ptr, key2_ptr, length1, length2 );	\
else \
  { \
  if (length1 < length2)			\
    if ((result = strncmp(key1_ptr, key2_ptr, length1)) == 0)	\
      value = -1;						\
    else			\
      value = result;				\
  else if (length2 < length1)			\
    if ((result = strncmp(key1_ptr, key2_ptr, length2)) == 0)	\
      value = 1;				\
    else			\
      value = result;			\
  else				\
     value = strncmp(key1_ptr, key2_ptr, length1); \
  }		\
}		

								/*+dsdesc*/
/*
OM_sd_rtree_status

Description:
	    This data structure is defined for get_stat message.
	    To use it, the user has to set the type of information
	    he wants in the flag field, i.e. request_type.
*/	

struct OM_sd_rtree_status
 	{
	OMbyte	request_type;   /* What type of status do you want */

#define RTREE_MISC_STATUS    0
#define RTREE_LEVEL_STATUS   1
#define RTREE_PAGE_STATUS    2
        union
 	     {
	     struct
	           {
                   int tree_type;
		   int tree_height;
		   int page_count;
		   int key_count;
		   int nl_maxkeys;
		   int lf_maxkeys;
		   } misc;

	     struct
		   {
                   int level_no;
		   int level_type;

#define RTREE_NL_LEVEL   0
#define RTREE_LF_LEVEL   1

		   int num_pages;
	           } level;

	     struct
		   {
		   int level_no;
		   int page_no;
		   union
			{
            int dummy;
			DB_3D_DBL_BOX r3ddkey;
			} page_range;
                   int num_keys;
		   } page;
	     } rtree_status;  
	};

typedef struct OM_sd_rtree_status OM_S_RTREESTAT;	
typedef struct OM_sd_rtree_status *OM_p_RTREESTAT;

/* key entry format */


typedef
  struct
    {
    DB_3D_DBL_BOX Coordinates;
    OM_S_OBJID    Objid;
    } R_PACKED_KEYENTRY_3D_DBL;

typedef
  struct
    {
    DB_3D_FLT_BOX Coordinates;
    OM_S_OBJID    Objid;
    } R_PACKED_KEYENTRY_3D_FLT;
	
								/*+dsdesc*/
/* The following definition is used for the record keeping of R-tree
   operation */
struct OM_sd_rtree_op
       {
       OM_S_OBJID objid;
       unsigned char op_code; /* Identifies the type of R-tree operation */
#define OM_R_ADD 	(1)   /* R-tree add */
#define OM_R_REPLACE	(2)   /* R-tree replace */
#define OM_R_REMOVE	(3)   /* R-tree remove */
#define OM_R_FREMOVE	(4)   /* R-tree find_and_remove */

       OMuword osnum;
       };
								/*-dsdesc*/

typedef struct OM_sd_rtree_op  OM_S_RTREE_OP;
typedef struct OM_sd_rtree_op  *OM_p_RTREE_OP;

/* Bit masks for Rtree control message */
#define RTREE_M_NOMERGE (char)(1)  /* Inhibit merging of pages when a leaf
                                      node underflow */
#define RTREE_M_ORDER   (char)(2)  /* Keep leaf node entries in sequence by
                                      cluster number */
#define RTREE_M_DYNAMIC (char)(4)  /* If an Rtree leaf node splits, move
				      objects among clusters so that the two
				      resulting leaf nodes do not share a
				      cluster in common */

/* The maximum number of clusters associated with all of the keys on one 
   R-tree leaf page.  This constant has to be updated whenever the definition
   of R_MAX_KEYS_2D_INT is changed */
#define R_MAX_CLUSTERS  203

#endif								/*-public*/
