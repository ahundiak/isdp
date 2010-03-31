#ifndef hsdlist_bbs_include
#define hsdlist_bbs_include

#include "math.h"


struct HSdlist_bbs_bucket_attributes {
  	float	*diff_refl;
	float	*spec_refl;
	float	*trans;
	float	*finish;
};

struct	HSdlist_bbs_debug_info {
	unsigned long	num_buckets;
	unsigned long	num_clists;
	unsigned long	*verts_per_clist;
};

struct HSdlist_bbs_bucket {
	unsigned long			total_num_verts;
	struct DPdlist_fixed_data 	*fixed;
	struct HSdlist_bbs_bucket	*next_bucket;
};

struct HSdlist_bbs_color_header {
	float	rgb[3];
	struct	HSdlist_bbs_bucket	*bucket;
};
 

struct HSdlist_bbs_color_list {
	struct HSdlist_bbs_color_header	color_header;
	struct HSdlist_bbs_color_list	*next_color_list;
};

struct HSdlist_bbs {
	OMuword 			osnum;
	enum	GRdpmode		dp_mode;
	float				matrix[16];
	short				matrix_type;
	struct	IGRaltdisplay		*alt_symb; 
	struct 	DP_information		*dp_info; 
	struct HSdlist_bbs_color_list  	*color_list;
};

/* Data block list node */
struct HSdlist_data_block_node
{
   unsigned int size;
   void *address;
   struct HSdlist_data_block_node *next;
};

/* Free chunk list node */
struct HSdlist_free_chunk_node
{
   unsigned int size;
   void *address;
   struct HSdlist_free_chunk_node *next;
};

/* feedback buffer size for stroking (64K doubles) */
#define HS_DLIST_FB_BUFFER_SIZE (64 * 8 * 1024)

/* minimum data block size */
#define HS_DLIST_MIN_BLOCK_SIZE (64 * 1024)

#define PROTO_HSdlist_alloc_data_block \
   extern int HSdlist_alloc_data_block( \
      int size, \
      void **ptr );

#define PROTO_HSdlist_free_data_blocks \
   extern int HSdlist_free_data_blocks( \
      void );

#define PROTO_HSdlist_alloc_chunk \
   extern int HSdlist_alloc_chunk( \
      int size, \
      void **ptr );

#define PROTO_HSdlist_free_chunk \
   extern int HSdlist_free_chunk( \
      int size, \
      void *ptr );

#define PROTO_HSdlist_alloc_data_block_node \
   extern int HSdlist_alloc_data_block_node( \
      struct HSdlist_data_block_node **node_ptr ) ;

#define PROTO_HSdlist_free_data_block_node \
   extern int HSdlist_free_data_block_node( \
      struct HSdlist_data_block_node **node_ptr );

#define PROTO_HSdlist_alloc_free_chunk_node \
   extern int HSdlist_alloc_free_chunk_node( \
      struct HSdlist_free_chunk_node **node_ptr );

#define PROTO_HSdlist_free_free_chunk_node \
   extern int HSdlist_free_free_chunk_node( \
      struct HSdlist_free_chunk_node **node_ptr );

#define PROTO_HSdlist_enter_bbs	\
extern void  	HSdlist_enter_bbs(void);

#define PROTO_HSdlist_exit_bbs	\
extern void     HSdlist_exit_bbs(void);

#define PROTO_HSdlist_flush_bbs	\
extern void	HSdlist_flush_bbs(void);

#define	PROTO_HSdlist_add_surface_to_bbs	\
extern int 	HSdlist_add_surface_to_bbs (	\
   struct DPdlist_fixed_data 	*fixed,		\
   OMuword 			osnum,		\
   struct DP_information 	*dp_info,	\
   enum GRdpmode 		dp_mode,	\
   struct IGRaltdisplay 	*alt_symb,	\
   IGRmatrix 			matrix,		\
   IGRshort 			matrix_type,	\
   WLuint32 			context_no,	\
   int 				(*color_to_rgb)(			\
					   WLuint32 context_no,		\
					   WLuint32 index,		\
					   WLuint32 red,		\
					   WLuint32 green,		\
					   WLuint32 blue,		\
					   WLuint32 flag,		\
					   WLuint32 *out_red,		\
					   WLuint32 *out_green,		\
					   WLuint32 *out_blue )		\
   );

#define	HSDLIST_BBS_COLOR_TOL		1e-06
#define HSDLIST_SIZEOF_BBS		sizeof(struct HSdlist_bbs)
#define HSDLIST_SIZEOF_BUCKET		sizeof(struct HSdlist_bbs_bucket)
#define HSDLIST_SIZEOF_COLOR_LIST	sizeof(struct HSdlist_bbs_color_list)
#define HSDLIST_SIZEOF_COLOR_HEADER	sizeof(struct HSdlist_bbs_color_header)

#define HS_BBS_MIN_BYTE_REQD		(HSDLIST_SIZEOF_BBS+		\
				         HSDLIST_SIZEOF_COLOR_LIST+	\
				         HSDLIST_SIZEOF_COLOR_HEADER+	\
				 	 HSDLIST_SIZEOF_BUCKET)


#define HSDLIST_BBS_COPY_MATRIX(source,target)	\
{						\
	int	jj;				\
	for(jj=0;jj<16;jj++)			\
		target[jj] = source[jj];	\
}


#define	HSDLIST_SET_BBS_PTR(p_bbs, osnum, dp_mode,matrix,matrix_type,alt_symb,dp_info)	\
		p_bbs->osnum   = osnum;				\
		p_bbs->dp_mode = dp_mode;			\
		p_bbs->matrix_type = matrix_type;		\
		HSDLIST_BBS_COPY_MATRIX(matrix,p_bbs->matrix)   \
		p_bbs->alt_symb = alt_symb;			\
		p_bbs->dp_info  = dp_info;			\

#define  HSDLIST_FILL_BUCKET(bucket,num_verts,fixed)	\
    bucket->total_num_verts  = num_verts;			\
    bucket->fixed	     = fixed;				\
    bucket->next_bucket	     = NULL;


#define HSDLIST_FETCH_MEMORY(ptr, size)				\
{								\
   int	sts;							\
   sts = HSdlist_alloc_chunk( size, (void **)&ptr );		\
   if ( !(1 & sts) )						\
   {								\
      return( sts );						\
   }								\
}

#define	HSDLIST_FREE_MEMORY(ptr, size)				\
{								\
   int sts;							\
   sts = HSdlist_free_chunk( size, (void *)ptr ); 		\
   if ( !(1 & sts) )						\
   {								\
      return( sts );						\
   }								\
   ptr = NULL;							\
}

#define HSDLIST_BBS_COMPARE_COLORS(is_color,rgb_1, rgb_2)	\
{								\
  if( 	(fabs(rgb_1[0] - rgb_2[0]) > HSDLIST_BBS_COLOR_TOL) ||	\
	(fabs(rgb_1[1] - rgb_2[1]) > HSDLIST_BBS_COLOR_TOL) ||	\
	(fabs(rgb_1[2] - rgb_2[2]) > HSDLIST_BBS_COLOR_TOL))	\
  {								\
  	is_color = FALSE;					\
  }								\
  else								\
  {								\
	is_color = TRUE;					\
  }								\
}

#define	HSDLIST_BBS_COMPARE_ATTRIBUTES(different,old,new)			\
{                                                                       \
 if(                                                                    \
   (fabs(old.diff_refl - new.diff_refl)     > HSDLIST_FLOAT_TOL) ||     \
   (fabs(old.spec_refl - new.spec_refl)     > HSDLIST_FLOAT_TOL) ||     \
   (fabs(old.finish    - new.finish)        > HSDLIST_FLOAT_TOL) ||     \
   (fabs(old.trans     - new.trans)         > HSDLIST_FLOAT_TOL)        \
   )									\
        different = TRUE;                                        	\
 else                                                                   \
        different = FALSE;                                       	\
}


#define	HSDLIST_FETCH_BUCKET_ATTRIBUTES(bucket,attributes)	\
{								\
   struct DPdlist_sh_surf *temp_ptr;				\
   temp_ptr = (struct DPdlist_sh_surf *)bucket->fixed->sh_data;	\
   attributes.diff_refl = temp_ptr->diff_refl;			\
   attributes.spec_refl = temp_ptr->spec_refl;			\
   attributes.finish    = temp_ptr->finish;			\
   attributes.trans     = temp_ptr->trans;			\
}

extern unsigned long	HS_bbs_num_bytes_allocated;
extern unsigned long	HS_bbs_max_verts;
extern struct	HSdlist_bbs	*hsdlist_bbs;

/*************************************************************************/

#endif
		/* End of file */


