#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "wl.h"

#include "OMerrordef.h"
#include "OMtypes.h"
#include "OMindex.h"
#include "OMminimum.h"
#include "OMlimits.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "madef.h"

#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"

#include "gr.h"

#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "hsmacdef.h"
#include "HStl_window.h"
#include "HStl_global.h"

#include "DPdlist.h"
#include "HSdlist.h"
#include "HSdl_bbs.h"

/******************************************************************

	This file contains the implementation of 

	"Bucket Bactching Algorithm for Symbology"
	------------------------------------------

	The initial implementation is done only for XGL. If any body
	is interested in porting this effort on to make use of other
	libraries, he should port following two functions:

	extern void	HSdlist_bbs_xgl_set_surf_attributes();
	extern void  	HSdlist_bbs_xgl_flush_bucket();

	I have finished writing above said functions for EG and OpenGL

	If it is required to do "Geometry Batching" then one should
	implement some logic to do on the fly batching in
	HSdlist_bbs_xgl_flush_bucket() function. The effort was not
	worth while incase of XGL. So I took out the code from
	HSdlist_bbs_xgl_flush_bucket().

	No geometry batching should occur across two color lists. One
	should flush all geometry before switching to next color list.

******************************************************************/


	/*
	 *
	 *		Globals.
	 *
	 */

extern struct HS_window_parms *active_window;

unsigned long           HS_bbs_num_bytes_allocated = 0;

struct  HSdlist_bbs     *hsdlist_bbs               = NULL;

static struct  HSdlist_bbs_debug_info bbs_debug = { 0,0,NULL};

	/****	PROTOTYPES	*****/

PROTO_HSdlist_enter_bbs
PROTO_HSdlist_exit_bbs
PROTO_HSdlist_flush_bbs
PROTO_HSdlist_add_surface_to_bbs
PROTO_HSdlist_alloc_data_block
PROTO_HSdlist_free_data_blocks
PROTO_HSdlist_alloc_chunk 
PROTO_HSdlist_free_chunk 
PROTO_HSdlist_alloc_data_block_node 
PROTO_HSdlist_free_data_block_node 
PROTO_HSdlist_alloc_free_chunk_node
PROTO_HSdlist_free_free_chunk_node
PROTO_HSdlist_enter_bbs	
PROTO_HSdlist_exit_bbs
PROTO_HSdlist_flush_bbs
PROTO_HSdlist_add_surface_to_bbs


/*
	I donot expect others to use following functions.
	So I am not keeping these prototypes in HSdl_bbs.h file.
*/
extern struct HSdlist_bbs_color_list *HSdlist_bbs_find_color_list(
		struct HSdlist_bbs *hsdlist_bbs,		/* i */
		float  	rgb[3]					/* i */
	);

extern void 	HSdlist_flush_color_list(
	struct HSdlist_bbs_color_list 	*clist,			/* i */
	unsigned int			*p_force_setting	/* i */
	);

extern void	HSdlist_debug_print_bucket(
	struct	HSdlist_bbs_bucket 	*bucket,		/* i */
	unsigned	long		*p_num_verts,		/* i */
	FILE				*fp_bbs			/* i */
   );

extern void	HSdlist_debug_print_color_list(
	struct	HSdlist_bbs_color_list	*clist,			/* i */
	FILE				*fp_bbs			/* i */
	);
extern void	HSdlist_debug_print_bbs(
	int			write_to_file,			/* i */
	struct HSdlist_bbs	*bbs				/* i */
	);

extern	void	HSdlist_reset_bbs(void);


#if defined(XGL)
extern void  	HSdlist_bbs_xgl_flush_bucket(
	struct HSdlist_bbs_bucket	*bucket			/* i */
	);

extern void	HSdlist_bbs_xgl_set_surf_attributes(
	struct HSdlist_bbs_color_list	*clist,			/* i */
        struct HSdlist_bbs_bucket_attributes attributes,	/* i */
	unsigned	int		set_all_attributes,	/* i */
	unsigned	int		*p_force_setting	/* i */
	);
#endif


#if defined(ENV5)
#include <EG.h>

extern void  	HSdlist_bbs_env5_flush_bucket(
	struct HSdlist_bbs_bucket	*bucket			/* i */
	);

extern void	HSdlist_bbs_env5_set_surf_attributes(
	struct HSdlist_bbs_color_list	*clist,			/* i */
        struct HSdlist_bbs_bucket_attributes attributes,	/* i */
	unsigned	int		set_all_attributes,	/* i */
	unsigned	int		*p_force_setting	/* i */
	);
#endif


#if defined( OPENGL )

static float GLmaterial[4] = {1.0, 1.0, 1.0, 1.0};

static GLubyte gl_narrow_trans[] = {
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55,
   0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55 };

static GLubyte gl_wide_trans[] = {
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,
   0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F };

extern void  	HSdlist_bbs_sgi_flush_bucket(
	struct HSdlist_bbs_bucket	*start_bucket		/* i */
	);

extern void	HSdlist_bbs_sgi_set_surf_attributes(
	struct HSdlist_bbs_color_list	*clist,			/* i */
        struct HSdlist_bbs_bucket_attributes attributes,	/* i */
	unsigned	int		set_all_attributes,	/* i */
	unsigned	int		*p_force_setting	/* i */
	);
#endif









struct HSdlist_bbs_color_list *HSdlist_bbs_find_color_list(
		struct HSdlist_bbs *hsdlist_bbs,
		float  	rgb[3]
	)
/*
NAME
	HSdlist_bbs_find_color_list

DESCRIPTION
	This function finds and returns a color list for 
	the given color (r,g,b). If it could not find any, 
	then it will return NULL.

SYNOPSIS
struct HSdlist_bbs_color_list 
  	*HSdlist_bbs_find_color_list(
		struct HSdlist_bbs *hsdlist_bbs,
		float  	rgb[3]
	)

PARAMETERS
	hsdlist_bbs (IN)	Global data structure.
	rgb[3]	    (IN)	red,green,blue.

GLOBALS USED
	None.

RETURN VALUES
	Pointer to HSdlist_bbs_color_list structure OR
	NULL

HISTORY
   	10-June-94	sash	Creation
*/

{
   int is_same_color = FALSE;

   struct HSdlist_bbs_color_header color_header;

   struct HSdlist_bbs_color_list   *color_list = hsdlist_bbs->color_list;

   /*-----------------------------------------------------------------*/

   while(color_list)
   {

      color_header = color_list->color_header;	

      HSDLIST_BBS_COMPARE_COLORS(is_same_color,color_header.rgb, rgb);
  
      if(is_same_color)/* Found a color header. */
	break;

      color_list = color_list->next_color_list;

   };

   if(is_same_color)
	return color_list;
   else
	return NULL;
} /* HSdlist_bbs_find_color_list */



void 	HSdlist_flush_color_list(
	struct HSdlist_bbs_color_list 	*clist,
	unsigned int			*p_force_setting
	)
/*
NAME
	HSdlist_flush_color_list

DESCRIPTION
	Flushes the given color list in bbs linked list.

SYNOPSIS
void 	HSdlist_flush_color_list(
	struct HSdlist_bbs_color_list 	*clist,
	unsigned int			*p_force_setting
	)

PARAMETERS
    *clist		(IN)	color list structure.
    *p_force_setting 	(IN)	flag bit.

GLOBALS USED
	old_attributes.

RETURN VALUES
	None.

HISTORY
   	10-June-94	sash	Creation
*/

{
  register	struct DPdlist_sh_surf *temp_ptr;    

  unsigned int	first_setting = TRUE, set_all_attributes = TRUE;

  struct HSdlist_bbs_bucket	*start_bucket = NULL;

  struct HSdlist_bbs_bucket_attributes old_attributes, new_attributes;

  /*----------------------------------------------------------------*/

  if(!clist) return;

  while(clist->color_header.bucket)
  {
  	start_bucket = clist->color_header.bucket;

/*
        HSDLIST_FETCH_BUCKET_ATTRIBUTES(start_bucket,new_attributes);
*/

       	temp_ptr = (struct DPdlist_sh_surf *)start_bucket->fixed->sh_data; 
   	new_attributes.diff_refl = &temp_ptr->diff_refl;
   	new_attributes.spec_refl = &temp_ptr->spec_refl;               
   	new_attributes.finish    = &temp_ptr->finish;                  
   	new_attributes.trans     = &temp_ptr->trans;

     	if(first_setting)
     	{
		/* Doing setting for the first bucket in clist. */
		set_all_attributes = TRUE;

#if defined(ENV5)
		HSdlist_bbs_env5_set_surf_attributes(clist,
					    	    new_attributes,	
					    	    set_all_attributes,
					    	    p_force_setting);
#endif

#if defined(OPENGL)
		HSdlist_bbs_sgi_set_surf_attributes(clist,
					    	    new_attributes,	
					    	    set_all_attributes,
					    	    p_force_setting);
#endif

#if defined(XGL)
		HSdlist_bbs_xgl_set_surf_attributes(clist,
					    	    new_attributes,	
					    	    set_all_attributes,
					    	    p_force_setting);
#endif
		first_setting = FALSE;

		/* Moved it up..... june 17th */
     		old_attributes = new_attributes;

     	}
     	else
     	{
		/* 
			Doing setting for n'th bucket in clist. 
			( where n is greater than 1 )
	         */

		unsigned int different = FALSE;

		/* 
	    	    If required set only spec,diff,trans and finish etc., 
		*/
		set_all_attributes = FALSE;

		/*
		   If this bucket has same lighting settings as 
		   previous  bucket, then skip attribute setting.
		*/

/*
		HSDLIST_BBS_COMPARE_ATTRIBUTES(different,
					       new_attributes,
					       old_attributes);
*/

		if(
		   (fabs(*old_attributes.diff_refl - *new_attributes.diff_refl)     > HSDLIST_FLOAT_TOL) ||
		   (fabs(*old_attributes.spec_refl - *new_attributes.spec_refl)     > HSDLIST_FLOAT_TOL) ||
		   (fabs(*old_attributes.finish    - *new_attributes.finish)        > HSDLIST_FLOAT_TOL) ||
		   (fabs(*old_attributes.trans     - *new_attributes.trans)         > HSDLIST_FLOAT_TOL)
		   )
		        different = TRUE;                                          
		 else                                                             
		        different = FALSE;


		if(different)
		{

#if defined(ENV5)
		HSdlist_bbs_env5_set_surf_attributes(clist,
					    	    new_attributes,	
					    	    set_all_attributes,
					    	    p_force_setting);
#endif

#if defined(OPENGL)
		HSdlist_bbs_sgi_set_surf_attributes(clist,
					    	    new_attributes,	
					    	    set_all_attributes,
					    	    p_force_setting);
#endif

#if defined(XGL)
		HSdlist_bbs_xgl_set_surf_attributes(clist,
					            new_attributes,	
					            set_all_attributes,
					    	    p_force_setting);
#endif
		/* Moved it up..... june 17th */
     		old_attributes = new_attributes;

		}

	}/*  if(first_setting) */

/*
 	Moved it up..... june 17th
     	old_attributes = new_attributes;
*/

#if defined(ENV5)
	HSdlist_bbs_env5_flush_bucket(start_bucket);
#endif

#if defined(OPENGL)
	HSdlist_bbs_sgi_flush_bucket(start_bucket);
#endif

#if defined(XGL)
	HSdlist_bbs_xgl_flush_bucket(start_bucket);
#endif

     	clist->color_header.bucket = start_bucket->next_bucket;

  }/* while(clist->color_header.bucket) */

  return;

}/* HSdlist_flush_color_list() */

void	HSdlist_flush_bbs(void)
/*
NAME
	HSdlist_flush_bbs

DESCRIPTION
	This function flushes the entire bucket lists stored in
	diferent color lists.

SYNOPSIS
	void	HSdlist_flush_bbs(void);

PARAMETERS
	None.

GLOBALS USED
	hsdlist_bbs.

RETURN VALUES
	None.

HISTORY
   	10-June-94	sash	Creation
*/

{

/*
 *   force_setting bit is used to set few things only once.
 */
  unsigned int	force_setting=TRUE;

  struct HSdlist_bbs_color_list	*clist = NULL;

  if(!hsdlist_bbs)  
	return;

  if(!hsdlist_bbs->color_list)
	return;

  clist = hsdlist_bbs->color_list;

  while(clist)
  {
     HSdlist_flush_color_list(clist,&force_setting);
     clist = clist->next_color_list;
  }

  hsdlist_bbs = NULL;

  return;

} /* HSdlist_flush_bbs() */


void  HSdlist_enter_bbs(void)

/*
NAME
	HSdlist_enter_bbs

DESCRIPTION
	This is a wrapup function for "Bucket Batching for Symbology"
	implementation.

SYNOPSIS
	void  HSdlist_enter_bbs(void)

PARAMETERS
	None.

GLOBALS USED
	hsdlist_bbs.

RETURN VALUES
	None.

HISTORY
   	10-June-94	sash	Creation
*/

{
   HS_bbs_num_bytes_allocated = 0;

   hsdlist_bbs = NULL;

}/* HSdlist_enter_bbs() */


int HSdlist_add_surface_to_bbs (
   struct DPdlist_fixed_data 	*fixed,
   OMuword 			osnum,
   struct DP_information 	*dp_info,
   enum GRdpmode 		dp_mode,
   struct IGRaltdisplay 	*alt_symb,
   IGRmatrix 			matrix,
   IGRshort 			matrix_type,
   WLuint32 			context_no,
   int (*color_to_rgb)(
   WLuint32 context_no,
   WLuint32 index,
   WLuint32 red,
   WLuint32 green,
   WLuint32 blue,
   WLuint32 flag,
   WLuint32 *out_red,
   WLuint32 *out_green,
   WLuint32 *out_blue )
   )

/*
NAME
	HSdlist_add_surface_to_bbs

DESCRIPTION
	Creates a new bucket (and a new color list if necessary) for
	given surface. Does pushing old color list down and old bucket
	down if required.

	If required flushes old buckets and color lists.

SYNOPSIS

int HSdlist_add_surface_to_bbs (
   struct DPdlist_fixed_data 	*fixed,
   OMuword 			osnum,
   struct DP_information 	*dp_info,
   enum GRdpmode 		dp_mode,
   struct IGRaltdisplay 	*alt_symb,
   IGRmatrix 			matrix,
   IGRshort 			matrix_type,
   WLuint32 			context_no,
   int 				(*color_to_rgb)()
   )

PARAMETERS
   *fixed	(IN)	the fixed data for the surface.
   osnum	(IN)	the object space number of the surface.
   *dp_info	(IN)	the display information.
   dp_mode	(IN)	the display mode.
   *alt_symb	(IN)	the alternate symbology for the surface.
   matrix	(IN)	the environment matrix for the display.
   matrix_type	(IN)	the type of matrix.
   context_no	(IN)	the display context number
(*color_to_rgb)	(IN) 	the function pointer.
	
GLOBALS USED
	hsdlist_bbs
	HSdlist_bbs_num_bytes_allocated

RETURN VALUES
	DLIST_S_SUCCESS	for success.
	DLIST_E_ERROR	for error.

HISTORY
	10-June-94	sash	Creation
*/

{
   short 		log_color;
   float		red, green,blue, rgb[3];
   unsigned int		is_new_bbs = FALSE, is_new_color = FALSE;
   struct HSdlist_bbs_color_list	*color_list=NULL;
   struct HSdlist_bbs_bucket 		*bucket=NULL;

   /*------------------------------------------------------------*/

   /* 
	If the total mem use exceeds or close to maximum limit
	then flush every thing in hand.
   */
   if(HS_bbs_num_bytes_allocated > HS_DLIST_FB_BUFFER_SIZE)
   {
	HSdlist_reset_bbs();
   }

   if(hsdlist_bbs)
   if(hsdlist_bbs->osnum != osnum)
   {
         /* osnum has changed so flush old buffer immdtly. */
         HSdlist_reset_bbs();
   }

   if(!fixed)
   {
       return( DLIST_E_ERROR );
   }

#if defined(XGL)
   if(!fixed->xgl_data || !fixed->valid_xgl_data)
   {
	return( DLIST_E_ERROR );
   }
#endif

    /* Create a new bucket and fill it. */
    HSDLIST_FETCH_MEMORY(bucket, HSDLIST_SIZEOF_BUCKET);

#if defined(XGL)
    HSDLIST_FILL_BUCKET(bucket,
                        fixed->xgl_data->total_num_verts,
                        fixed);
#else
  HSDLIST_FILL_BUCKET(bucket,
                      0, 		/* no verts */
                      fixed);
#endif

    /* Find the color of this surface. */
    GET_LOG_COLOR( alt_symb, fixed->color, log_color );
    GET_COLOR_UPDATE( log_color );

    rgb[0] = red; rgb[1] = green; rgb[2] = blue;

    /* If there is no bbs available then create afresh. */
    if(!hsdlist_bbs)
    {
	HSDLIST_FETCH_MEMORY(hsdlist_bbs,HSDLIST_SIZEOF_BBS);

	/* Fill bbs structure. */
	HSDLIST_SET_BBS_PTR(hsdlist_bbs,
				osnum,
				dp_mode,
				matrix,
				matrix_type,
				alt_symb,
				dp_info);
	is_new_bbs = TRUE;
    }

    if(!is_new_bbs)
    {
	/* 
	   Serach for a color list which has same color as this 
	   surface in it's color header.
        */
        color_list = HSdlist_bbs_find_color_list(hsdlist_bbs,rgb);
						     
	if(!color_list)
	{
	   /* No such color encountered so far..... */
	   is_new_color = TRUE;
	}

    }/* if(!hsdlist_bbs) */

    if(!color_list)
    {
	/*
		That means there is no color header with this
		surface color. So create a new one. And add
		this surface (bucket) to color_list.
	*/
	HSDLIST_FETCH_MEMORY(color_list,HSDLIST_SIZEOF_COLOR_LIST);
	color_list->color_header.bucket = bucket;
	color_list->color_header.rgb[0] = red;
	color_list->color_header.rgb[1] = green;
	color_list->color_header.rgb[2] = blue;
	color_list->next_color_list     = NULL;
    }
    else
    {
	/* Push old bucket down and insert new bucket. */
	struct HSdlist_bbs_bucket 	*old_bucket, *new_bucket;
 
	old_bucket = color_list->color_header.bucket;
	new_bucket = bucket;

	new_bucket->next_bucket = old_bucket;
	color_list->color_header.bucket = new_bucket;
    }

    if(is_new_bbs)
    {
	hsdlist_bbs->color_list = color_list;
    }
    else if(is_new_color)
    {
	/* 
	   Push old color list down and insert this color list
	   into hsdlist_bbs structre. 
	*/
  	color_list->next_color_list = hsdlist_bbs->color_list;	
	hsdlist_bbs->color_list     = color_list;
    }

    return DLIST_S_SUCCESS;

} /* HSdlist_add_surface_to_bbs() */

void	HSdlist_debug_print_bucket(
	struct	HSdlist_bbs_bucket 	*bucket,
	unsigned	long		*p_num_verts,
	FILE				*fp_bbs
	)
/*
NAME
	HSdlist_debug_print_bucket

DESCRIPTION
	Prints the contents of given bucket.

SYNOPSIS
void	HSdlist_debug_print_bucket(
	struct	HSdlist_bbs_bucket 	*bucket,
	unsigned	long		*p_num_verts,
	FILE				*fp_bbs
	)
	
PARAMETERS
  	*bucket,	(IN)	pointer to bucket.
	*p_num_verts,	(IN)	pointer to number of verts.
	*fp_bbs		(IN)	the file pointer.

GLOBALS USED
	None.

RETURN VALUES
	None.

HISTORY
   	10-June-94	sash	Creation
*/

{
	*p_num_verts  += bucket->total_num_verts;

	if(fp_bbs)
	{
		fprintf(fp_bbs,
		"\t\tbucket:num_verts = %d", bucket->total_num_verts);
	}
	else
	{
	printf("\t\tbucket:num_verts = %d", bucket->total_num_verts);
	}
}

void	HSdlist_debug_print_color_list(
	struct	HSdlist_bbs_color_list	*clist,
	FILE				*fp_bbs
	)
/*
NAME
	HSdlist_debug_print_color_list

DESCRIPTION
	Print contents of the given color list.

SYNOPSIS
void	HSdlist_debug_print_color_list(
	struct	HSdlist_bbs_color_list	*clist,
	FILE				*fp_bbs
	)

PARAMETERS
	*clist,	(IN)	pointer to color list.
	*fp_bbs	(IN)	the file pointer

GLOBALS USED
	bbs_debug.

RETURN VALUES
	None.

HISTORY
   10-June-94	sash	Creation
*/
{
	unsigned long	num_buckets=0,num_verts=0;
	struct	HSdlist_bbs_bucket		*bucket=NULL;
	struct	HSdlist_bbs_color_header	header;
	
	bbs_debug.num_clists++;
   	if(bbs_debug.num_clists == 1)
	{
		bbs_debug.verts_per_clist = (unsigned long *)malloc(sizeof(unsigned long));
	}
	else
	{
		bbs_debug.verts_per_clist = (unsigned long *)realloc(
						bbs_debug.verts_per_clist,
						bbs_debug.num_clists*sizeof(unsigned long));

	}
	if(!bbs_debug.verts_per_clist)
	{
		fprintf(stderr,"Malloc or Realloc failed.\n");
		return;
	}

	header = clist->color_header;

	if(fp_bbs)
	{
		fprintf(fp_bbs,"********* R G B ********** = %lf, %lf, %lf\n", header.rgb[0], 
						header.rgb[1], header.rgb[2]);
	}
	else
	{
		printf("********* R G B ********** = %lf, %lf, %lf\n", header.rgb[0], 
						header.rgb[1], header.rgb[2]);
	}
	
	bucket = clist->color_header.bucket;
	while(bucket)
	{
		num_buckets++;
		HSdlist_debug_print_bucket(bucket, &num_verts,fp_bbs);
		bucket = bucket->next_bucket;
	}

	bbs_debug.num_buckets += num_buckets;
	bbs_debug.verts_per_clist[bbs_debug.num_clists-1]  = num_verts;
}

void	HSdlist_debug_print_bbs(
	int			write_to_file,
	struct HSdlist_bbs	*bbs
	)
/*
NAME
	HSdlist_debug_print_bbs

DESCRIPTION
	Prints the contents of linked lists in hsdlist_bbs.

SYNOPSIS
void	HSdlist_debug_print_bbs(
	int			write_to_file,
	struct HSdlist_bbs	*bbs
	)

PARAMETERS
	write_to_file,	(IN)	true/false bit.
	*bbs	        (IN) 	pointer to global data structure.

GLOBALS USED
	bbs_debug.

RETURN VALUES
	None.

HISTORY
   10-June-94	sash	Creation
*/
{
	FILE		*fp_bbs=NULL;
	unsigned long	total_verts=0, ii;
	struct	HSdlist_bbs_color_list	*clist=NULL;

	if(!bbs)
	{
		return;
	}

	if(write_to_file)
	{
		fp_bbs = fopen("bbs_debug.txt","w");
		if(!fp_bbs)
		{
			fprintf(stderr,"\tCould not open bbs_debug.txt file for writing.\n");
			fp_bbs = NULL;
			write_to_file = 0;	
		}
	}

	bbs_debug.num_buckets 	  = bbs_debug.num_clists	= 0;
	bbs_debug.verts_per_clist = NULL;

	clist = bbs->color_list;

	if(fp_bbs)
	{
		fprintf(fp_bbs,"bbs: osnum = %d, dp_mode = %d, matrix_type = %d\n",
				bbs->osnum, bbs->dp_mode, bbs->matrix_type);
	}
	else
	{
		printf("bbs: osnum = %d, dp_mode = %d, matrix_type = %d\n",
			bbs->osnum, bbs->dp_mode, bbs->matrix_type);
	}

	while(clist)
	{
		if(fp_bbs)
			fprintf(fp_bbs,"----------------------------------------\n");
		else	
			printf("----------------------------------------\n");

		HSdlist_debug_print_color_list(clist, fp_bbs);

		if(fp_bbs)
			fprintf(fp_bbs,"----------------------------------------\n");
		else	
			printf("----------------------------------------\n");

		clist = clist->next_color_list;
	}

	if(fp_bbs)
	{
		fprintf(fp_bbs,"---------------------------------------------------\n");
		fprintf(fp_bbs,"Final statistics:\n");
		fprintf(fp_bbs,"---------------------------------------------------\n");
		fprintf(fp_bbs,"Total number of color lists = %d\n",bbs_debug.num_clists);
		fprintf(fp_bbs,"Total number of buckets	    = %ld\n",bbs_debug.num_buckets);
	}
	else
	{
		printf("---------------------------------------------------\n");
		printf("Final statistics:\n");
		printf("---------------------------------------------------\n");
		printf("Total number of color lists = %d\n",bbs_debug.num_clists);
		printf("Total number of buckets	    = %ld\n",bbs_debug.num_buckets);
	}

	for(ii=0;ii<bbs_debug.num_clists;ii++)
	{
		if(fp_bbs)
		{
			fprintf(fp_bbs,"clist[%d]: verts = %ld\n",
			ii,bbs_debug.verts_per_clist[ii]);
		}
		else
		{
			printf("clist[%d]: verts = %ld\n",
			ii,bbs_debug.verts_per_clist[ii]);
		}
		total_verts += bbs_debug.verts_per_clist[ii];
	}
	
	if(fp_bbs)
	{
		fprintf(fp_bbs,"Total no. of verts sent to display = %ld\n",total_verts);
		fprintf(fp_bbs,"---------------------------------------------------\n");
	}
	else
	{
		printf("Total no. of verts sent to display = %ld\n",total_verts);
		printf("---------------------------------------------------\n");
	}

	free(bbs_debug.verts_per_clist);
	if(fp_bbs) fclose(fp_bbs);	
	
	/* Reset global structure. */
	bbs_debug.num_buckets 	  = bbs_debug.num_clists	= 0;
	bbs_debug.verts_per_clist = NULL;
}

void  HSdlist_exit_bbs(void)

/*
NAME
	HSdlist_exit_bbs(void)

DESCRIPTION
	This is a wrapup function for "Bucket Batching for Symbology"
	implementation. All memory requested for builiding linked
	lists will be freed here.

SYNOPSIS
	HSdlist_exit_bbs(void)

PARAMETERS
	void.

GLOBALS USED
	hsdlist_bbs.

RETURN VALUES
	None

HISTORY
  	10-June-94	sash	Creation
*/
{
   int	bbs_bool=0, write_to_file = 1;

   if(bbs_bool)
   {
      HSdlist_debug_print_bbs(write_to_file,hsdlist_bbs);
   }

   HSdlist_flush_bbs();
   HSdlist_free_data_blocks();
   HS_bbs_num_bytes_allocated = 0;

}/* HSdlist_exit_bbs */


void	HSdlist_reset_bbs(void)

/*
NAME
	HSdlist_reset_bbs

DESCRIPTION
	Exits and enters again into BBS.

SYNOPSIS
	HSdlist_reset_bbs(void)

PARAMETERS
	None.

GLOBALS USED
	None.

RETURN VALUES
	None.

HISTORY
   	10-June-94	sash	Creation
*/
{
	HSdlist_exit_bbs();
	HSdlist_enter_bbs();
}

#if defined(XGL)

void	HSdlist_bbs_xgl_set_surf_attributes(
	struct HSdlist_bbs_color_list	*clist,			/* i */
        struct HSdlist_bbs_bucket_attributes attributes,	/* i */
	unsigned	int		set_all_attributes,	/* i */
	unsigned	int		*p_force_setting	/* i */
	)
/*
NAME
	HSdlist_bbs_xgl_set_surf_attributes
	
DESCRIPTION
	Sets the required attributes for surface display
	using XGL library.

SYNOPSIS
void	HSdlist_bbs_xgl_set_surf_attributes(
	struct HSdlist_bbs_color_list	*clist	
        struct HSdlist_bbs_bucket_attributes attributes
	unsigned	int		set_all_attributes
	unsigned	int		*p_force_setting
	)

PARAMETERS
	*clist			(IN)	pointer to color list.
        attributes 		(IN)	attribute structure.
	set_all_attributes	(IN)	true/false bit.
	*p_force_setting	(IN)	true/flase bit.

GLOBALS USED
	None.

RETURN VALUES
	None.

HISTORY
 	10-June-94	sash	Creation
*/
{
   float
	   diff_refl = *attributes.diff_refl,
	   spec_refl = *attributes.spec_refl,
	/* trans     = *attributes.trans, */
	   finish    = *attributes.finish;

   if (set_all_attributes)
   {

   	Xgl_color	 	xgl_color;	
   	Xgl_surf_illumination   xgl_surf_illumination;

   	if ( active_window->shading_style == HS_STYLE_SMOOTH )
   	{
		xgl_surf_illumination = XGL_ILLUM_PER_VERTEX;
   	}
   	else 
   	{
		xgl_surf_illumination = XGL_ILLUM_PER_FACET;
   	}

      	HS_XGL_SET_RGB_COLOR(xgl_color, 
			     clist->color_header.rgb[0],
			     clist->color_header.rgb[1],
			     clist->color_header.rgb[2]);

	if(*p_force_setting)
	{			       
		/* 
		   Set all attrubutes including color.
		   this is equal to HS_XGL_SURFACE_ATTRIBUTES.
		   Basically HS_XGL_SURFACE_ATTRIBUTES is divided
		   into three separate symbolic constancts.
		*/
        	xgl_object_set(active_window->xgl_context_3D,
			       HS_XGL_COLOR_ATTRIBUTES,
			       HS_XGL_ATTRIBUTES_BY_STYLE,
			       HS_XGL_ATTRIBUTES_BY_VALUE,
		               NULL);
		/* 
		   This kind of setting should be done only once per one
		   window update.
		*/
		*p_force_setting = FALSE;
	}
	else
	{
		/* 
	         *   Set all attrubutes excluding shading style, 
		 *   light mode etc.,. This block will be active 
 		 *   when we just entered a new color list.
		 */
        	xgl_object_set(active_window->xgl_context_3D,
			       HS_XGL_COLOR_ATTRIBUTES,
			       HS_XGL_ATTRIBUTES_BY_VALUE,
		               NULL);
	}
   }
   else
   {
     /* 
      *	   Set only diff_refl, spec_refl, trans, finish etc., 
      *	   This block will be active only if the current bucket
      *    has different lighting attributes compared to previous
      *	   bucket.
      */
     xgl_object_set(active_window->xgl_context_3D,
		    HS_XGL_ATTRIBUTES_BY_VALUE,
		    NULL);
   }

  return;

}/* HSdlist_bbs_xgl_set_surf_attributes() */ 

void  	HSdlist_bbs_xgl_flush_bucket(
	struct HSdlist_bbs_bucket	*bucket
	)
/*
NAME
	HSdlist_bbs_xgl_flush_bucket

DESCRIPTION
	Flushes the given bucket using XGL.

SYNOPSIS
void  	HSdlist_bbs_xgl_flush_bucket(
	struct HSdlist_bbs_bucket	*bucket
	)

PARAMETERS
	bucket	(IN)	pointer to bucket.

GLOBALS USED
	None.

RETURN VALUES
	None.

HISTORY
  	10-June-94	sash	Creation
*/
{
  Xgl_pt_list			pt_list[1];

  if(!bucket || !bucket->total_num_verts || !bucket->fixed->xgl_data || 
	!bucket->fixed->xgl_data->vertex_data)
  {
	return;
  }

   HS_XGL_SET_PT_LIST_NORMAL_FLAG_F3D(pt_list[0], 
			              bucket->total_num_verts, 
				      bucket->fixed->xgl_data->vertex_data);

   xgl_triangle_list(active_window->xgl_context_3D, 
		     NULL,
		     pt_list,
		     XGL_TLIST_FLAG_USE_VTX_FLAGS);

  return;

}/* HSdlist_bbs_xgl_flush_bucket() */

#endif

#if defined(ENV5)

void	HSdlist_bbs_env5_set_surf_attributes(
	struct HSdlist_bbs_color_list	*clist,			/* i */
        struct HSdlist_bbs_bucket_attributes attributes,	/* i */
	unsigned	int		set_all_attributes,	/* i */
	unsigned	int		*p_force_setting	/* i */
	)
/*
NAME
	HSdlist_bbs_env5_set_surf_attributes

DESCRIPTION
	Sets the display attributes on clipper.

SYNOPSIS
	void	HSdlist_bbs_env5_set_surf_attributes(
	struct HSdlist_bbs_color_list	*clist
        struct HSdlist_bbs_bucket_attributes attributes
	unsigned	int		set_all_attributes
	unsigned	int		*p_force_setting
	)

PARAMETERS
	*clist			(IN)	pointer to color list.
        attributes 		(IN)	attribute structure.
	set_all_attributes	(IN)	true/false bit.
	*p_force_setting	(IN)	true/flase bit.


GLOBALS USED
	None.

RETURN VALUES
	None.

HISTORY
   	10-June-94	sash	Creation
*/

{
     
   EGObjectProp EGprop = { 1.0,   /* ambRefl */
                               1.0,   /* diffRefl */
                               0.0,   /* specRefl */
                               { 1.0, /* specColor.red */
                                 1.0, /* specColor.green */
                                 1.0, /* specColor.blue */
                               },
                               0.0,   /* specExp */
                               0.0,   /* transCoeff */
                             };

   /*------------------------------------------------------------*/

   /* 
    *	Set these things for each bucket. 
    */

   EGprop.diffRefl   = *attributes.diff_refl;
   EGprop.specRefl   = *attributes.spec_refl;
   EGprop.specExp    = (*attributes.finish > 32.0) ? 32.0 : *attributes.finish;
   EGprop.transCoeff = (*attributes.trans >= 0.5) ? 0.5 : 0.0;
   EGSetObjectProp( active_window->EG_vc_no, &EGprop );

   if(set_all_attributes)
   {
        EGRGBColor EGcolor;

	/* Set color for each color list. */
     	EGcolor.red   = clist->color_header.rgb[0];
   	EGcolor.green = clist->color_header.rgb[1];
   	EGcolor.blue  = clist->color_header.rgb[2];
        EGSetBaseColor( active_window->EG_vc_no, &EGcolor );

	/* Do this only once per one window update. */
	if(*p_force_setting)
	{			       
	   /* 
		Surprisingly shading style is not set for EG in
		HSdlist_display_surface_update()
	   */
	   EGSetNormReorientMode( active_window->EG_vc_no, EG_ON );
	   EGSetFaceCullingMode( active_window->EG_vc_no, EG_NO_CULL );
   	   *p_force_setting = FALSE;
	}
    }
    
    return;

} /* HSdlist_bbs_env5_set_surf_attributes() */

void  	HSdlist_bbs_env5_flush_bucket(
	struct HSdlist_bbs_bucket	*bucket	/* i */
	)
/*
NAME
	HSdlist_bbs_env5_flush_bucket

DESCRIPTION
	Flushes a given surface (bucket) using EG library.

SYNOPSIS
void  	HSdlist_bbs_env5_flush_bucket(
	struct HSdlist_bbs_bucket	*bucket
	)

PARAMETERS
	bucket	(IN)	surface.
GLOBALS USED
	None.

RETURN VALUES
	None.

HISTORY
   	10-June-94	sash	Creation
*/
{
   register int 	 ii;
   register char 	 **mesh_ptr;
   register float 	 *verts, *fnorms, *vnorms;
   register unsigned int *num_verts_ptr, num_verts, num_meshes;
   register unsigned int *num_facet_normals;
   register struct DPdlist_sh_surf *temp_ptr;

   EGTriMeshData3Info EGmesh = { 0,                  /* numVerts */
                                     NULL,               /* verts */
                                     sizeof( EGPoint3 ), /* vertOffset */
                                     NULL,               /* vColors */
                                     0,                  /* vColorOffset */
                                     NULL,               /* vNorms */
                                     sizeof( EGPoint3 ), /* VNormOffset */
                                     NULL,               /* fColors */
                                     0,                  /* fColorOffset */
                                     NULL,               /* fNorms */
                                     sizeof( EGPoint3 )  /* fNormOffset */
                                   };


   /*----------------------------------------------------------*/

   if ( !bucket->fixed->sh_data )
      return;

   temp_ptr = (struct DPdlist_sh_surf *) bucket->fixed->sh_data;
   num_meshes = temp_ptr->num_meshes;
   mesh_ptr = (char **) (temp_ptr + 1);

   /* display each mesh */
   switch ( HS_STYLE_SMOOTH )
   {
      case HS_STYLE_SMOOTH :

         for ( ii = 0; ii < num_meshes; ii++, mesh_ptr++ )
         {
            DLIST_MSH_NUM_VERTS_PTR( *mesh_ptr, num_verts_ptr );
            num_verts = *num_verts_ptr;

            DLIST_MSH_VERTS_PTR( *mesh_ptr, verts );
            DLIST_MSH_VNORMS_PTR( *mesh_ptr, vnorms, num_verts );
 
            DLIST_MSH_FNORMS_PTR( *mesh_ptr, fnorms, num_verts );
            DLIST_MSH_NUM_FACET_NORMALS_PTR( *mesh_ptr, num_facet_normals );

            EGmesh.numVerts = num_verts;
            EGmesh.verts = (EGPoint3 *) verts;
            EGmesh.vNorms = (EGVect3 *) vnorms;
            EGmesh.fNorms = (EGVect3 *) fnorms;
            EGmesh.fNormOffset = (*num_facet_normals > 1) ? sizeof( EGPoint3 ) : 0;
            EGTriMeshData3( active_window->EG_vc_no, &EGmesh );

         }
         break;

      default:	/* No other shading style is supported. */
         break;
 
   }/* end of switch */

   return;

} /* HSdlist_bbs_env5_flush_bucket */

#endif


#if defined(OPENGL)

void	HSdlist_bbs_sgi_set_surf_attributes(
	struct HSdlist_bbs_color_list	*clist,			/* i */
        struct HSdlist_bbs_bucket_attributes attributes,	/* i */
	unsigned	int		set_all_attributes,	/* i */
	unsigned	int		*p_force_setting	/* i */
	)
/*
NAME
	HSdlist_bbs_sgi_set_surf_attributes

DESCRIPTION
	Sets the display attributes on clipper.

SYNOPSIS
	void	HSdlist_bbs_sgi_set_surf_attributes(
	struct HSdlist_bbs_color_list	*clist
        struct HSdlist_bbs_bucket_attributes attributes
	unsigned	int		set_all_attributes
	unsigned	int		*p_force_setting
	)

PARAMETERS
	*clist			(IN)	pointer to color list.
        attributes 		(IN)	attribute structure.
	set_all_attributes	(IN)	true/false bit.
	*p_force_setting	(IN)	true/flase bit.


GLOBALS USED
	None.

RETURN VALUES
	None.

HISTORY
   	10-June-94	sash	Creation
*/

{

   register float	finish;

   GLmaterial[0] = clist->color_header.rgb[0] * (*attributes.diff_refl);
   GLmaterial[1] = clist->color_header.rgb[1] * (*attributes.diff_refl);
   GLmaterial[2] = clist->color_header.rgb[2] * (*attributes.diff_refl);

   glMaterialfv( GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, GLmaterial );
   GLmaterial[0] = GLmaterial[1] = GLmaterial[2] = *attributes.spec_refl;
   glMaterialfv( GL_FRONT_AND_BACK, GL_SPECULAR, GLmaterial );

   finish = *attributes.finish;

   if ( finish > 128.0 )
   {
      finish = 128.0;
   }

   glMaterialf( GL_FRONT_AND_BACK, GL_SHININESS, finish );

   if ( *attributes.trans >= 0.5 )
   {
      glEnable( GL_POLYGON_STIPPLE );
      if ( tiling_parms.processing_mode & HS_PMODE_TRANS_1x1 )
      {
         glPolygonStipple( gl_narrow_trans );
      }
      else
      {
         glPolygonStipple( gl_wide_trans );
      }
   }

   if(set_all_attributes)
   {
  	glColor3f(clist->color_header.rgb[0], 
                  clist->color_header.rgb[1],      
                  clist->color_header.rgb[2]);
	
	if(*p_force_setting)
	{
	   /* 
		Surprisingly shading style is not set for OPENGL in
		HSdlist_display_surface_update()
	   */
		*p_force_setting = FALSE;
	}
   }

}/* HSdlist_bbs_sgi_set_surf_attributes() */

void  	HSdlist_bbs_sgi_flush_bucket(
	struct HSdlist_bbs_bucket	*bucket		/* i */
	)
/*
NAME
	HSdlist_bbs_sgi_flush_bucket

DESCRIPTION
	Flushes a given surface (bucket) using EG library.

SYNOPSIS
void  	HSdlist_bbs_sgi_flush_bucket(
	struct HSdlist_bbs_bucket	*bucket
	)

PARAMETERS
	bucket	(IN)	surface.
GLOBALS USED
	None.

RETURN VALUES
	None.

HISTORY
   	10-June-94	sash	Creation
*/

{
   register int ii;
   register struct DPdlist_sh_surf *temp_ptr;
   register unsigned int *num_verts_ptr, num_verts, num_meshes;
   register float *verts, *fnorms, *vnorms;
   register char **mesh_ptr;
   unsigned int *num_facet_normals;

   if (!bucket->fixed->sh_data)
      return;

   temp_ptr   = (struct DPdlist_sh_surf *) bucket->fixed->sh_data;
   num_meshes = temp_ptr->num_meshes;
   mesh_ptr   = (char **) (temp_ptr + 1);

   /* display each mesh */
   switch ( active_window->shading_style )
   {
      case HS_STYLE_SMOOTH :

         for ( ii = 0; ii < num_meshes; ii++, mesh_ptr++ )
         {
            DLIST_MSH_NUM_VERTS_PTR( *mesh_ptr, num_verts_ptr );
            num_verts = *num_verts_ptr;
            DLIST_MSH_VERTS_PTR( *mesh_ptr, verts );
            DLIST_MSH_VNORMS_PTR( *mesh_ptr, vnorms, num_verts );
 
            glBegin( GL_TRIANGLE_STRIP );
            SEND_VERTS_AND_NORMALS_TO_OPENGL( num_verts, verts, vnorms );
            glEnd();

         }/* end of for loop */
         break;

      default:

         for ( ii = 0; ii < num_meshes; ii++, mesh_ptr++ )
         {
            DLIST_MSH_NUM_FACET_NORMALS_PTR( *mesh_ptr, num_facet_normals );
            if ( *num_facet_normals > 1 )
            {
               DLIST_MSH_NUM_VERTS_PTR( *mesh_ptr, num_verts_ptr );
               num_verts = *num_verts_ptr;
 
               DLIST_MSH_VERTS_PTR( *mesh_ptr, verts );
               DLIST_MSH_FNORMS_PTR( *mesh_ptr, fnorms, num_verts );

               /* facet normal per triangle */
               glBegin( GL_TRIANGLE_STRIP );
               glNormal3fv( fnorms );
               glVertex3fv( verts );
               glVertex3fv( verts + 3 );
               glVertex3fv( verts + 6 );
               verts += 9;
               fnorms += 3;
               num_verts -= 3;

               SEND_VERTS_AND_NORMALS_TO_OPENGL( num_verts, verts, fnorms );
               glEnd();
            }
            else
            {
               DLIST_MSH_NUM_VERTS_PTR( *mesh_ptr, num_verts_ptr );
               num_verts = *num_verts_ptr;
               DLIST_MSH_VERTS_PTR( *mesh_ptr, verts );
               DLIST_MSH_FNORMS_PTR( *mesh_ptr, fnorms, num_verts );

               /* only one facet normal */
               glBegin( GL_TRIANGLE_STRIP );
               glNormal3fv( fnorms );
               SEND_VERTS_TO_OPENGL( num_verts, verts );
               glEnd();

            }/*  if ( *num_facet_normals > 1 ) */

         }/* end of for loop */
         break;
 
   }/* end of switch */


   if ( temp_ptr->trans >= 0.5 )
   {
      glDisable( GL_POLYGON_STIPPLE );
   }

wrapup:
   return;

} /* HSdlist_bbs_sgi_flush_bucket() */

#endif

