class implementation Root;

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <alloca.h>

#include "wl.h"

#include "OMminimum.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "exdef.h"
#include "msdef.h"
#include "exmacros.h"

#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "godef.h"

#include "refdef.h"

#include "dl.h"

#include "DPdlist.h"

#include "gr.h"
#include "dpmacros.h"
#include "madef.h"


#define ONE_OVER_SQRT_THREE 0.5773502691896  /* 1.0 / sqrt( 3.0 ) */

#define DP_DLIST_MIN_TRANS_BUFFER_SIZE 1024
#define DP_DLIST_SET_ARRAY_INCREMENT 10

/* statics for transformation buffer */
%safe
static int DPdlist_trans_buffer_size = 0;
static void *DPdlist_trans_buffer = NULL;

/* statics for building up elements w/ sets of edges */
static int DPdlist_num_vi_ptrs = 0;
static int DPdlist_num_vd_ptrs = 0;
static int DPdlist_num_vi_ids = 0;
static int DPdlist_num_vd_ids = 0;
static int DPdlist_num_sub_ptrs = 0;
static int DPdlist_num_sub_msc_ids = 0;

static int DPdlist_size_vi_ptrs = 0;
static int DPdlist_size_vd_ptrs = 0;
static int DPdlist_size_vi_ids = 0;
static int DPdlist_size_vd_ids = 0;
static int DPdlist_size_sub_ptrs = 0;
static int DPdlist_size_sub_msc_ids = 0;

static void **DPdlist_vi_ptrs = NULL;
static void **DPdlist_vd_ptrs = NULL;
static OM_S_OBJID *DPdlist_vi_ids = NULL;
static OM_S_OBJID *DPdlist_vd_ids = NULL;
static void **DPdlist_sub_ptrs = NULL;
static OM_S_OBJID *DPdlist_sub_msc_ids = NULL;

extern IGRboolean DPdlist_use_display_list;
extern IGRdouble DPdlist_stroke_tolerance;
extern int DPdlist_wf_fb_pipe_id;
extern IGRboolean DPdlist_performance_boost;
extern struct DPdlist_hash_table *DPhash_tables;

/* statics for building up surface meshes */
static int DPdlist_num_mesh_ptrs = 0;
static int DPdlist_size_mesh_ptrs = 0;
static void **DPdlist_mesh_ptrs;

/* statics used when dropping a solid in EMS */
static IGRboolean DPdlist_partial_drop_mode = FALSE;

static int (*DPdlist_enter_reference_file_sh)(
   struct DP_information *dp_info,
   IGRshort matrix_type,
   IGRmatrix matrix ) = NULL;

static int (*DPdlist_exit_reference_file_sh)(
   struct DP_information *dp_info,
   IGRshort matrix_type,
   IGRmatrix matrix ) = NULL;
%endsafe

/* Old Prototypes */
#include "DPsetinq.h"  /* DPsetinqgragad */
#include "DPgetggid.h" /* DPgetggid */
#include "matrnmx.h"

/* New Prototypes */
PROTO_DPdlist_get_partial_drop_mode
PROTO_DPdlist_set_partial_drop_mode
PROTO_DPdlist_get_transform_buffer
PROTO_DPdlist_init_set_arrays
PROTO_DPdlist_add_pointer_to_set
PROTO_DPdlist_add_sub_pointer_to_set
PROTO_DPdlist_add_objid_to_set
PROTO_DPdlist_add_sub_objid_to_set
PROTO_DPdlist_get_pointer_sets
PROTO_DPdlist_get_sub_pointer_sets
PROTO_DPdlist_get_objid_sets
PROTO_DPdlist_get_sub_objid_sets
PROTO_DPdlist_init_mesh_array
PROTO_DPdlist_add_mesh_to_set
PROTO_DPdlist_get_mesh_set
PROTO_DPdlist_transform_points
PROTO_DPdlist_change_attr
PROTO_DPdlist_set_tolerance_gragad
PROTO_DPdlist_hash_delete_all
PROTO_DPdlist_set_shading_reference_file_functions
PROTO_DPdlist_enter_reference_file
PROTO_DPdlist_exit_reference_file
PROTO_DPdlist_set_element_flags
PROTO_DPdlist_get_performance_boost_status
PROTO_DPdlist_set_performance_boost_status
PROTO_DPdlist_set_object_space_scales
PROTO_DPdlist_get_object_space_scale
PROTO_DPdlist_hash_lookup

extern int	DPinq_display_tolerance( int * );

from GRgraphics import GRgetprops;
from GRcontext import GRgetinstance;

/*--- DPdlist_get_partial_drop_mode -----------------------------------*/

IGRboolean DPdlist_get_partial_drop_mode()
   
/*
NAME
   DPdlist_get_partial_drop_mode

DESCRIPTION
   This function returns the partial drop mode

SYNOPSIS
   IGRboolean DPdlist_get_partial_drop_mode()

PARAMETERS
   none
   
GLOBALS USED
   DPdlist_partial_drop_mode

RETURN VALUES
   TRUE
   FALSE

HISTORY
   10/05/93 Shridar Subramanian
      Initial specification and design
*/

{
   return( DPdlist_partial_drop_mode );
   
}  /* DPdlist_get_partial_drop_mode */

/*--- DPdlist_set_partial_drop_mode -----------------------------------*/

int DPdlist_set_partial_drop_mode(
   IGRboolean mode )
   
/*
NAME
   DPdlist_set_partial_drop_mode

DESCRIPTION
   This function sets the partial drop mode

SYNOPSIS
   int DPdlist_set_partial_drop_mode()

PARAMETERS
   mode (IN) - The mode
   
GLOBALS USED
   DPdlist_partial_drop_mode

RETURN VALUES
   DLIST_S_SUCCESS
   DLIST_E_ERROR
   
HISTORY
   10/05/93 Shridar Subramanian
      Initial specification and design
*/

{
   DPdlist_partial_drop_mode = mode;
   return( DLIST_S_SUCCESS );
}  /* DPdlist_set_partial_drop_mode */

/*--- DPdlist_get_transform_buffer -----------------------------------*/

int DPdlist_get_transform_buffer(
   unsigned int byte_size,
   void **buffer )

/*
NAME
   DPdlist_get_transform_buffer

DESCRIPTION
   This function gets a temporary buffer that is used as a temporary buffer
   for transforming element geometry.  Subsequent calls to this function will
   reuse the buffer.

SYNOPSIS
   int DPdlist_get_transform_buffer(
      unsigned int byte_size,
      void **buffer )

PARAMETERS
   byte_size (IN) - the size in bytes of the buffer
   buffer (OUT) - a pointer to the buffer

GLOBALS USED
   DPdlist_trans_buffer_size
   DPdlist_trans_buffer

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design
*/

{

   if ( byte_size < DP_DLIST_MIN_TRANS_BUFFER_SIZE )
   {
      byte_size = DP_DLIST_MIN_TRANS_BUFFER_SIZE;
   }

   if ( byte_size > DPdlist_trans_buffer_size )
   {
      if ( DPdlist_trans_buffer )
      {
         free( DPdlist_trans_buffer );
      }

      DPdlist_trans_buffer = malloc( byte_size );
      if ( ! DPdlist_trans_buffer )
      {
         DPdlist_trans_buffer_size = 0;
         return( DLIST_E_ERROR );
      }
   }

   *buffer = DPdlist_trans_buffer;
   return( DLIST_S_SUCCESS );

}  /* DPdlist_get_transform_buffer */


/*--- DPdlist_init_set_arrays -----------------------------------------*/

int DPdlist_init_set_arrays(
   void )

/*
NAME
   DPdlist_init_set_arrays

DESCRIPTION
   This functions initializes the arrays used to add elements that are sets
   of curves/polygons.

SYNOPSIS
   int DPdlist_init_set_arrays(
      void )

PARAMETERS
   none

GLOBALS USED
   DPdlist_num_vi_ptrs
   DPdlist_num_vd_ptrs
   DPdlist_num_vi_ids
   DPdlist_num_vi_ids

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/12/93 S.P. Rogers
      Initial implementation
*/

{

   DPdlist_num_vi_ptrs = DPdlist_num_vd_ptrs =
   DPdlist_num_vi_ids = DPdlist_num_vd_ids = 
   DPdlist_num_sub_ptrs = DPdlist_num_sub_msc_ids = 0;

   return( DLIST_S_SUCCESS );
} /* DPdlist_init_set_arrays */

/*--- DPdlist_add_pointer_to_set -----------------------------------*/

int DPdlist_add_pointer_to_set(
   int type,
   void *ptr )

/*
NAME
   DPdlist_add_pointer_to_set

DESCRIPTION
   This function adds a pointer to the set of edges that makes up an
   element.

SYNOPSIS
   int DPdlist_add_pointer_to_set(
      int type,
      void *ptr )

PARAMETERS
   type (IN) - the type of edge pointer that is being added
   ptr (IN) - the edge pointer to add

GLOBALS USED
   DPdlist_vi_ptrs
   DPdlist_vd_ptrs
   DPdlist_num_vi_ptrs
   DPdlist_num_vd_ptrs
   DPdlist_size_vi_ptrs
   DPdlist_size_vd_ptrs
   
RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design
*/

{
   void **old_ptr;

   if ( type == DP_DLIST_VIEW_DEP )
   {
      if ( DPdlist_num_vd_ptrs == DPdlist_size_vd_ptrs )
      {
         old_ptr = DPdlist_vd_ptrs;
         DPdlist_vd_ptrs = realloc( DPdlist_vd_ptrs, 
                                    (DPdlist_size_vd_ptrs + DP_DLIST_SET_ARRAY_INCREMENT) *
                                          sizeof( void * ) );
         if ( ! DPdlist_vd_ptrs )
         {
            DPdlist_vd_ptrs = old_ptr;
            return( DLIST_E_ERROR );
         }

         DPdlist_size_vd_ptrs += DP_DLIST_SET_ARRAY_INCREMENT;
      }

      DPdlist_vd_ptrs[DPdlist_num_vd_ptrs] = ptr;
      DPdlist_num_vd_ptrs++;
   }
   else if ( type == DP_DLIST_VIEW_IND )
   {
      if ( DPdlist_num_vi_ptrs == DPdlist_size_vi_ptrs )
      {
         old_ptr = DPdlist_vi_ptrs;
         DPdlist_vi_ptrs = realloc( DPdlist_vi_ptrs, 
                                    (DPdlist_size_vi_ptrs + DP_DLIST_SET_ARRAY_INCREMENT) *
                                          sizeof( void * ) );
         if ( ! DPdlist_vi_ptrs )
         {
            DPdlist_vi_ptrs = old_ptr;
            return( DLIST_E_ERROR );
         }

         DPdlist_size_vi_ptrs += DP_DLIST_SET_ARRAY_INCREMENT;
      }

      DPdlist_vi_ptrs[DPdlist_num_vi_ptrs] = ptr;
      DPdlist_num_vi_ptrs++;
   }
   else
   {
      return( DLIST_E_ERROR );
   }

   return( DLIST_S_SUCCESS );
}
/*--- DPdlist_add_sub_pointer_to_set -----------------------------------*/

int DPdlist_add_sub_pointer_to_set(
   int type,
   void *ptr )

/*
NAME
   DPdlist_add_sub_pointer_to_set

DESCRIPTION
   This function adds a subordiante pointer to the set of edges that makes up an
   element.

SYNOPSIS
   int DPdlist_add_sub_pointer_to_set(
      int type,
      void *ptr )

PARAMETERS
   type (IN) - the type of edge pointer that is being added
   ptr (IN) - the edge pointer to add

GLOBALS USED
   DPdlist_sub_ptrs
   DPdlist_num_sub_ptrs
   DPdlist_size_sub_ptrs
   
RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   09/01/93 Shridar Subramanian
      Initial specification and design
*/

{
   void **old_ptr;

   if ( type == DP_DLIST_VIEW_IND )
   {
      if ( DPdlist_num_sub_ptrs == DPdlist_size_sub_ptrs )
      {
         old_ptr = DPdlist_sub_ptrs;
         DPdlist_sub_ptrs = realloc( DPdlist_sub_ptrs, 
                                    (DPdlist_size_sub_ptrs + DP_DLIST_SET_ARRAY_INCREMENT) *
                                          sizeof( void * ) );
         if ( ! DPdlist_sub_ptrs )
         {
            DPdlist_sub_ptrs = old_ptr;
            return( DLIST_E_ERROR );
         }

         DPdlist_size_sub_ptrs += DP_DLIST_SET_ARRAY_INCREMENT;
      }

      DPdlist_sub_ptrs[DPdlist_num_sub_ptrs] = ptr;
      DPdlist_num_sub_ptrs++;
   }
   else
   {
      return( DLIST_E_ERROR );
   }

   return( DLIST_S_SUCCESS );
}

/*--- DPdlist_add_objid_to_set ------------------------------------*/

int DPdlist_add_objid_to_set(
   int type,
   OM_S_OBJID objid )

/*
NAME
   DPdlist_add_objid_to_set

DESCRIPTION
   This function adds an objid to the set of edges that makes up an
   element.

SYNOPSIS
   int DPdlist_add_objid_to_set(
      int type,
      OM_S_OBJID objid )

PARAMETERS
   type (IN) - the type of edge id that is being added
   objid (IN) - the edge id to add

GLOBALS USED
   DPdlist_vi_ids
   DPdlist_vd_ids
   DPdlist_num_vi_ids
   DPdlist_num_vd_ids
   DPdlist_size_vi_ids
   DPdlist_size_vd_ids

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/12/93 S.P. Rogers
      Initial implementation
*/

{
   OM_S_OBJID *old_ptr;

   if ( type == DP_DLIST_VIEW_DEP )
   {
      if ( DPdlist_num_vd_ids == DPdlist_size_vd_ids )
      {
         old_ptr = DPdlist_vd_ids;
         DPdlist_vd_ids = (OM_S_OBJID *) realloc( DPdlist_vd_ids, 
                                                 (DPdlist_size_vd_ids + DP_DLIST_SET_ARRAY_INCREMENT) *
                                                        sizeof( OM_S_OBJID ) );
         if ( ! DPdlist_vd_ids )
         {
            DPdlist_vd_ids = old_ptr;
            return( DLIST_E_ERROR );
         }

         DPdlist_size_vd_ids += DP_DLIST_SET_ARRAY_INCREMENT;
      }

      DPdlist_vd_ids[DPdlist_num_vd_ids] = objid;
      DPdlist_num_vd_ids++;
   }
   else if ( type == DP_DLIST_VIEW_IND )
   {
      if ( DPdlist_num_vi_ids == DPdlist_size_vi_ids )
      {
         old_ptr = DPdlist_vi_ids;
         DPdlist_vi_ids = (OM_S_OBJID *) realloc( DPdlist_vi_ids, 
                                                  (DPdlist_size_vi_ids + DP_DLIST_SET_ARRAY_INCREMENT) *
                                                  sizeof( OM_S_OBJID ) );
         if ( ! DPdlist_vi_ids )
         {
            DPdlist_vi_ids = old_ptr;
            return( DLIST_E_ERROR );
         }

         DPdlist_size_vi_ids += DP_DLIST_SET_ARRAY_INCREMENT;
      }

      DPdlist_vi_ids[DPdlist_num_vi_ids] = objid;
      DPdlist_num_vi_ids++;
   }
   else
   {
      return( DLIST_E_ERROR );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_add_objid_id_to_set */

/*--- DPdlist_add_sub_objid_to_set ------------------------------------*/

int DPdlist_add_sub_objid_to_set(
   int type,
   OM_S_OBJID objid )

/*
NAME
   DPdlist_add_sub_objid_to_set

DESCRIPTION
   This function adds objid of subordinate edge  to the set of edges that makes up an
   element.

SYNOPSIS
   int DPdlist_add_sub_objid_to_set(
      int type,
      OM_S_OBJID objid )

PARAMETERS
   type (IN) - the type of edge id that is being added
   objid (IN) - the edge id to add

GLOBALS USED
   DPdlist_sub_msc_ids
   DPdlist_num_sub_msc_ids
   DPdlist_size_sub_msc_ids

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   09/06/93 Shridar Subramanian
      Initial specification,design and implementation

*/

{
   OM_S_OBJID *old_ptr;

   if ( type == DP_DLIST_VIEW_IND )
   {
      if ( DPdlist_num_sub_msc_ids == DPdlist_size_sub_msc_ids )
      {
         old_ptr = DPdlist_sub_msc_ids;
         DPdlist_sub_msc_ids = (OM_S_OBJID *) realloc( DPdlist_sub_msc_ids, 
                                                  (DPdlist_size_sub_msc_ids + DP_DLIST_SET_ARRAY_INCREMENT) *
                                                  sizeof( OM_S_OBJID ) );
         if ( ! DPdlist_sub_msc_ids )
         {
            DPdlist_sub_msc_ids = old_ptr;
            return( DLIST_E_ERROR );
         }

         DPdlist_size_sub_msc_ids += DP_DLIST_SET_ARRAY_INCREMENT;
      }

      DPdlist_sub_msc_ids[DPdlist_num_sub_msc_ids] = objid;
      DPdlist_num_sub_msc_ids++;
   }
   else
   {
      return( DLIST_E_ERROR );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_add_sub_objid_to_set */

/*--- DPdlist_get_pointer_sets -----------------------------------*/

int DPdlist_get_pointer_sets(
   unsigned int *num_vi,
   void ***vi_ptrs,
   unsigned int *num_vd,
   void ***vd_ptrs )
/*
NAME
   DPdlist_get_pointer_sets

DESCRIPTION
   This function gets the set of edge pointers that make up an element

SYNOPSIS
   int DPdlist_get_pointer_sets(
      unsigned int *num_vi,
      void ***vi_ptrs,
      unsigned int *num_vd,
      void ***vd_ptrs )

PARAMETERS
   num_vi (OUT) - the number of view independent edge pointers
   vi_ptrs (OUT) - the array of view independent edge pointers
   num_vd (OUT) - the number of view dependent edge pointers
   vd_ptrs (OUT) - the array of view dependent edge pointers

GLOBALS USED
   DPdlist_num_vd_ptrs
   DPdlist_num_vi_ptrs
   DPdlist_vd_ptrs
   DPdlist_vi_ptrs

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design

   05/12/93 S.P. Rogers
      Initial implementation
*/

{
   *num_vd = DPdlist_num_vd_ptrs;
   *num_vi = DPdlist_num_vi_ptrs;
   (*vd_ptrs) = DPdlist_vd_ptrs;
   (*vi_ptrs) = DPdlist_vi_ptrs;

   return( DLIST_S_SUCCESS );
} /* DPdlist_get_pointer_sets */

/*--- DPdlist_get_sub_pointer_sets -----------------------------------*/

int DPdlist_get_sub_pointer_sets(
   unsigned int *num_sub_ptrs,
   void ***sub_ptrs )
  
  /*
NAME
   DPdlist_get_pointer_sets

DESCRIPTION
   This function gets the set of subordinate edge pointers that make up an element

SYNOPSIS
   int DPdlist_get_pointer_sets(
      unsigned int *num_sub_ptrs,
      void ***sub_ptrs )

PARAMETERS
   num_sub_ptrs (OUT) - the number of subordinate edge pointers
   sub_ptrs (OUT) - the array of subordinate edge pointers

GLOBALS USED
   DPdlist_num_sub_ptrs
   DPdlist_sub_ptrs

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   08/01/93 Shridar Subramanian
      Initial specification, design and implementation

*/

{
   *num_sub_ptrs = DPdlist_num_sub_ptrs;
   (*sub_ptrs) = DPdlist_sub_ptrs;

   return( DLIST_S_SUCCESS );
} /* DPdlist_get_sub_pointer_sets */

/*--- DPdlist_get_objid_sets --------------------------------------*/

int DPdlist_get_objid_sets(
   unsigned int *num_vi,
   OM_S_OBJID **vi_ids,
   unsigned int *num_vd,
   OM_S_OBJID **vd_ids )

/*
NAME
   DPdlist_get_objid_sets

DESCRIPTION
   This function gets the sets of objids that make up an element

SYNOPSIS
   int DPdlist_get_objid_sets(
      unsigned int *num_vi,
      OM_S_OBJID **vi_ids,
      unsigned int *num_vd,
      OM_S_OBJID **vd_ids )

PARAMETERS
   num_vi (OUT) - the number of view independent edge ids
   vi_ids (OUT) - the array of view indepdendent edge ids
   num_vd (OUT) - the number of view dependent edge ids
   vd_ids (OUT) - the array of view depdendent edge ids

GLOBALS USED
   DPdlist_num_vd_ids
   DPdlist_num_vi_ids
   DPdlist_vd_ids
   DPdlist_vi_ids

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design
*/

{
   *num_vd = DPdlist_num_vd_ids;
   *num_vi = DPdlist_num_vi_ids;
   *vd_ids = DPdlist_vd_ids;
   *vi_ids = DPdlist_vi_ids;

   return( DLIST_S_SUCCESS );

} /* DPdlist_get_objid_sets */

/*--- DPdlist_get_sub_objid_sets --------------------------------------*/

int DPdlist_get_sub_objid_sets(
   unsigned int *num_sub_msc_ids,
   OM_S_OBJID **sub_msc_ids )

/*
NAME
   DPdlist_get_sub_objid_sets

DESCRIPTION
   This function gets the sets of subordinate objids that make up an element

SYNOPSIS
   int DPdlist_get_sub_objid_sets(
      unsigned int *num_sub_msc_ids,
      OM_S_OBJID **sub_msc_ids )

PARAMETERS
   num_sub_msc_ids (OUT) - the number of subordinate edge ids
   sub_msc_ids (OUT) - the array of subordinate edge ids

GLOBALS USED
   DPdlist_num_sub_msc_ids
   DPdlist_sub_msc_ids

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   09/06/93 Shridar Subramanian
      Initial specification, design and implementation
*/

{
   *num_sub_msc_ids = DPdlist_num_sub_msc_ids;
   *sub_msc_ids = DPdlist_sub_msc_ids;

   return( DLIST_S_SUCCESS );

} /* DPdlist_get_objid_sets */

/*--- DPdlist_init_mesh_array -----------------------------------------*/

int DPdlist_init_mesh_array(
   void )

/*
NAME
   DPdlist_init_mesh_array

DESCRIPTION
   This functions initializes the array used to add triangular meshes
   to a surface

SYNOPSIS
   int DPdlist_init_mesh_array(
      void )

PARAMETERS
   none

GLOBALS USED
   DPdlist_num_mesh_ptrs

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   07/09/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{

   DPdlist_num_mesh_ptrs = 0;
   return( DLIST_S_SUCCESS );
} /* DPdlist_init_mesh_array */

/*--- DPdlist_add_mesh_to_set -----------------------------------*/

int DPdlist_add_mesh_to_set(
   void *mesh_ptr )

/*
NAME
   DPdlist_add_mesh_to_set

DESCRIPTION
   This function adds a triangular mesh to the set that
   makes up a surface

SYNOPSIS
   int DPdlist_add_mesh_to_set(
      void *mesh_ptr )

PARAMETERS
   mesh_ptr (IN) - the mesh to add

GLOBALS USED
   DPdlist_num_mesh_ptrs
   DPdlist_size_mesh_ptrs
   DPdlist_mesh_ptrs

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   07/09/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   void **old_ptr;

   if ( DPdlist_num_mesh_ptrs == DPdlist_size_mesh_ptrs )
   {
      old_ptr = DPdlist_mesh_ptrs;
      DPdlist_mesh_ptrs = realloc( DPdlist_mesh_ptrs, 
                               (DPdlist_size_mesh_ptrs + DP_DLIST_SET_ARRAY_INCREMENT) *
                                       sizeof( struct DPdlist_tri_mesh * ) );
      if ( ! DPdlist_mesh_ptrs )
      {
         DPdlist_mesh_ptrs = old_ptr;
         return( DLIST_E_ERROR );
      }

      DPdlist_size_mesh_ptrs += DP_DLIST_SET_ARRAY_INCREMENT;
   }

   DPdlist_mesh_ptrs[DPdlist_num_mesh_ptrs] = mesh_ptr;
   DPdlist_num_mesh_ptrs++;

   return( DLIST_S_SUCCESS );
} /* DPdlist_add_mesh_to_set */

/*--- DPdlist_get_mesh_set -----------------------------------*/

int DPdlist_get_mesh_set(
   unsigned int *num_mesh_ptrs,
   void ***mesh_ptrs )

/*
NAME
   DPdlist_get_mesh_set

DESCRIPTION
   This function gets the set of edge pointers that make up an element

SYNOPSIS
   int DPdlist_get_mesh_set(
      unsigned int *num_mesh_ptrs,
      void ***mesh_ptrs )

PARAMETERS
   num_mesh_ptrs (OUT) - the number of meshes
   mesh_ptrs (OUT) - the array of meshes

GLOBALS USED
   DPdlist_num_mesh_ptrs
   DPdlist_mesh_ptrs

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   07/09/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   *num_mesh_ptrs = DPdlist_num_mesh_ptrs;
   *mesh_ptrs = DPdlist_mesh_ptrs;

   return( DLIST_S_SUCCESS );
} /* DPdlist_get_mesh_set */

/*--- DPdlist_transform_points ---------------------------------------------*/

int DPdlist_transform_points(
   int num_points,
   IGRmatrix matrix,
   short matrix_type,
   float *src_pts,
   float *dest_pts )

/*
NAME
   DPdlist_transform_points

DESCRIPTION
   This function transforms an array of points using the given matrix.  The
   source and destination arrays can overlap.

SYNOPSIS
   int DPdlist_transform_points(
      int num_points,
      IGRmatrix matrix,
      short matrix_type,
      float *src_pts,
      float *dest_pts )

PARAMETERS
   num_points (IN) - the number of points to transform
   matrix (IN) - the transformation matrix
   matrix_type (IN) - the type of the transformation matrix
   src_pts (IN) - the array of original points
   dest_pts (OUT) - the array of the transformed points

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/14/93 S.P. Rogers
      Initial design, specification, and implementation
*/

{
   int ii;
   float x, y, z;

   if ( matrix_type == MAIDMX )
   {
      if ( dest_pts != src_pts )
      {
         /* use memmove in case of overlap */
         memmove( dest_pts, src_pts, num_points * 3 * sizeof( float ) );
      }
      return( DLIST_S_SUCCESS );
   }

   for ( ii = 0; ii < num_points; ii++, src_pts +=3, dest_pts +=3 )
   {
      /* use x,y,z temporaries so src and dest can be the same */
      x = (matrix[0] * src_pts[0]) +
          (matrix[1] * src_pts[1]) +
          (matrix[2] * src_pts[2]) +
          matrix[3];

      y = (matrix[4] * src_pts[0]) +
          (matrix[5] * src_pts[1]) +
          (matrix[6] * src_pts[2]) +
          matrix[7];

      z = (matrix[8] * src_pts[0]) +
          (matrix[9] * src_pts[1]) +
          (matrix[10] * src_pts[2]) +
          matrix[11];

      dest_pts[0] = x;
      dest_pts[1] = y;
      dest_pts[2] = z;

   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_transform_points */

/*--- DPdlist_change_attr ---------------------------------------------------*/

int DPdlist_change_attr(
   OM_S_OBJID objid,
   OMuword osnum,
   IGRshort color,
   IGRchar style,
   IGRchar weight,
   IGRshort layer )

/*
NAME
   DPdlist_change_attr

DESCRIPTION
   This function will change the attributes of an element in
   the display list.

SYNOPSIS
   int DPdlist_change_attr(
      OM_S_OBJID objid,
      OMuword osnum,
      IGRshort color,
      IGRchar style,
      IGRchar weight,
      IGRshort layer )

PARAMETERS
   objid (IN) - the object id of the element whose attributes are to be
                changed
   osnum (IN) - the object space number of the element
   color (IN) - the new logical color of the element
   style (IN) - the new logical style of the element
   weight (IN) - the new weight of the element
   layer (IN) - the new layer of the element

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;
   struct DPdlist_fixed_data *fixed;

   sts = DPdlist_hash_lookup( objid, osnum, &fixed );
   if ( ! fixed )
   {
      return( DLIST_E_ERROR );
   }

   fixed->color = color;
   fixed->style = style;
   fixed->weight = weight;
   fixed->layer = layer;

   return( DLIST_S_SUCCESS );

} /* DPdlist_change_attr */

/*--- DPdlist_set_tolerance_gragad -------------------------------------*/

int DPdlist_set_tolerance_gragad(
   struct GRid *gragad )

/*
NAME
   DPdlist_set_tolerance_gragad

DESCRIPTION
   This function sets the tolerance used by the display list
   to stroke/tile elements.

SYNOPSIS
   int DPdlist_set_tolerance_gragad(
      struct GRid *gragad )

PARAMETERS
   gragad (IN) - the GRid of the gragad whose scale is to
                 be used

GLOBALS USED
   DPdlist_stroke_tolerance

RETURN VALUES
   DLIST_S_SUCCESS
      Success

   DLIST_E_ERROR
      Failure

HISTORY
   07/14/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   int ii;
   IGRint pixel_tolerance;
   IGRlong msg, bytes_ret, which_error;
   IGRdouble vvol_scale;
   struct var_list var_list[2];

   var_list[0].var = VVOL_VIEWPORT_SCALE;
   var_list[0].var_ptr = (char *) &vvol_scale;
   var_list[0].num_bytes = sizeof( IGRdouble );
   var_list[0].bytes_returned = &bytes_ret;
   var_list[1].var = END_PARAM;

   sts = dp$inq_set_gragad( msg = &msg,
                            osnum = gragad->osnum,
                            gragad_objid = gragad->objid,
                            which_error = &which_error,
                            var_list = var_list );

   if ( !(1 & sts & msg) )
   {
      return( DLIST_E_ERROR );
   }

   dp$inq_display_tolerance( pixel_toler = &pixel_tolerance );
   DPdlist_stroke_tolerance = (IGRdouble )pixel_tolerance / vvol_scale;

   /* set new tolerance in wireframe feedback pipeline */
   /* world and device tolerances should be the same   */
   /* because the pipe has an identity transformation  */
   sts = DLset_curve_tolerance( DPdlist_wf_fb_pipe_id,
                                DPdlist_stroke_tolerance,
                                DPdlist_stroke_tolerance );
   if ( sts != DL_SUCCESS )
   {
      return( DLIST_E_ERROR );
   }

   /* we want to delete the current display list and create a new one */
   /* call this function to properly delete the old display list */
   /* mike lanier 1/7/97: for TR 119702600 */

   DPdlist_exit();

   /* delete the variable data for all elements */
   for ( ii = 0; ii < OM_Gw_maxOS; ii++ )
   {
      sts = DPdlist_hash_delete_all( ii, FALSE );
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }
   }
      
   return( DLIST_S_SUCCESS );

} /* DPdlist_set_tolerance_gragad */

/*--- DPdlist_set_shading_reference_file_functions ------------------*/

int DPdlist_set_shading_reference_file_functions(
   int (*enter_reference_file)(
      struct DP_information *dp_info,
      IGRshort matrix_type,
      IGRmatrix matrix ),
   int (*exit_reference_file)(
      struct DP_information *dp_info,
      IGRshort matrix_type,
      IGRmatrix matrix ) )

/*
NAME
   DPdlist_seet_shading_reference_file_functions

DESCRIPTION
   This function sets the function pointers for the shading
   implementation of the reference file enter/exit routines.

SYNOPSIS
   int DPdlist_set_shading_reference_file_functions(
      int (*enter_reference_file)(
         struct DP_information *dp_info,
         IGRshort matrix_type,
         IGRmatrix matrix ),
      int (*exit_reference_file)(
         struct DP_information *dp_info ) )

PARAMETERS
   enter_reference_file (IN) - the enter reference file function
   exit_reference_file (IN) - the exit reference file function

GLOBALS USED
   DPdlist_enter_reference_file_sh (static)
   DPdlist_exit_reference_file_sh (static)

RETURN VALUES
   DLIST_S_SUCCESS
      Success

HISTORY
   07/19/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{

   DPdlist_enter_reference_file_sh = enter_reference_file;
   DPdlist_exit_reference_file_sh = exit_reference_file;

   return( DLIST_S_SUCCESS );
}  /* DPdlist_set_shading_reference_file_functions */

/*--- DPdlist_enter_reference_file ----------------------------------*/

int DPdlist_enter_reference_file(
   struct DP_information *dp_info,
   IGRshort matrix_type,
   IGRmatrix matrix )

/*
NAME
   DPdlist_enter_reference_file

DESCRIPTION
   This function is used to tell the display list that a refernce
   file has been entered.  It is used to speed up the display
   by concatenating the ref-file-to-world matrix with the
   viewing matrix

SYNOPSIS
   int DPdlist_enter_reference_file(
      struct DP_information *dp_info,
      IGRshort matrix_type,
      IGRmatrix matrix )

PARAMETERS
   dp_info (IN) - display information for window
   matrix_type (IN) - the type of the ref. file matrix
   matrix (IN) - the reference file matrix

GLOBALS USED
   DPdlist_enter_reference_file_sh (static)

RETURN VALUES
   DLIST_S_SUCCESS
      Success

HISTORY
   07/19/93 S.P. Rogers
      Initial spefication, design, and implementation
*/

{
   IGRlong msg;
   IGRshort four = 4;
   IGRdouble trans_matrix[16];

   if ( (DPdlist_use_display_list) && (dp_info->is_update) )
   {
      MAtrnmx( &msg, &four, matrix, trans_matrix );
      DLset_modelling_matrix( dp_info->gragad->gpipe_id, trans_matrix );

      if ( dp_info->is_hidden_line )
      {
         if ( DPdlist_enter_reference_file_sh )
         {
            (*DPdlist_enter_reference_file_sh)( dp_info,
                                                matrix_type,
                                                matrix );
         }
      }
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_enter_reference_file */

/*--- DPdlist_exit_reference_file ----------------------------------*/

int DPdlist_exit_reference_file(
   struct DP_information *dp_info,
   IGRshort matrix_type,
   IGRmatrix matrix )

/*
NAME
   DPdlist_exit_reference_file

DESCRIPTION
   This function is used to tell the display list that a refernce
   file has been exited.  It is used to speed up the display
   by concatenating the ref-file-to-world matrix with the
   viewing matrix

SYNOPSIS
   int DPdlist_exit_reference_file(
      struct DP_information *dp_info,
      IGRshort matrix_type,
      IGRmatrix matrix )

PARAMETERS
   dp_info (IN) - display information for window
   matrix_type (IN) - the type of the ref. file matrix
   matrix (IN) - the reference file matrix

GLOBALS USED
   DPdlist_exit_reference_file_sh (static)

RETURN VALUES
   DLIST_S_SUCCESS
      Success

HISTORY
   07/19/93 S.P. Rogers
      Initial spefication, design, and implementation
*/

{
   IGRlong msg;
   IGRshort four = 4;
   IGRdouble trans_matrix[16];

   if ( (DPdlist_use_display_list) && (dp_info->is_update) )
   {
      MAtrnmx( &msg, &four, matrix, trans_matrix );
      DLset_modelling_matrix( dp_info->gragad->gpipe_id, trans_matrix );

      if ( dp_info->is_hidden_line )
      {
         if ( DPdlist_exit_reference_file_sh )
         {
            (*DPdlist_exit_reference_file_sh)( dp_info,
                                               matrix_type,
                                               matrix );
         }
      }
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_exit_reference_file */


/*--- DPdlist_set_element_flags -----------------------------------------_*/

int DPdlist_set_element_flags(
   OM_S_OBJID objid,
   OMuword osnum,
   unsigned short *ele_flags )

/*
NAME
   DPdlist_set_element_flags 

DESCRIPTION
   This function sets the basic display list flags for an element.

SYNOPSIS
   int DPdlist_set_element_flags(
      OM_S_OBJID objid,
      OMuword osnum,
      unsigned short *ele_flags )

PARAMETERS
   objid (IN) - the object id of the element whose flags are to be set
   osnum (IN) - the object space number of the element
   ele_flags (OUT) - the element's display list flags

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/03/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   IGRlong msg;
   IGRshort props;

   *ele_flags = 0;

   sts = om$send( msg = message GRgraphics.GRgetprops( &msg, &props ),
                  targetid = objid,
                  targetos = osnum,
                  senderid = NULL_OBJID );

   if ( !(1 & sts & msg) )
   {
      return( DLIST_E_ERROR );
   }

   if ( props & GRIS_DISPLAYABLE )
   {
      (*ele_flags) |= DP_DLIST_ELE_DISPLAYABLE;
   }

   if ( props & DEHAS_OVERRIDE )
   {
      (*ele_flags) |= DP_DLIST_ELE_HAS_SOS;
   }

   if ( props & GRIS_VIEW_INDEP )
   {
      (*ele_flags) |= DP_DLIST_ELE_VIEW_IND;
   }

   if ( props & GRIS_SCALE_INDEP )
   {
      (*ele_flags) |= DP_DLIST_ELE_SCALE_IND;
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_set_element_flags */

/*--- DPdlist_get_performance_boost_status -----------------------*/

int DPdlist_get_performance_boost_status(
   IGRboolean *on_off )

/*
NAME
   DPdlist_get_performance_boost_status

DESCRIPTION
   This function gets the status of the display list
   performance boost flag.  If the flag is TRUE, then
   'dynamic display' from the display list will be
   in performance boost mode and elements with symbology
   overrides and surfaces with horizon edges/curves,
   will be displayed without these entities.

SYNOPSIS
   int DPdlist_get_performance_boost_status(
      IGRboolean *on_off )

PARAMETERS
   on_off (OUT) - the performance boost status

GLOBALS USED
   DPdlist_performance_boost

RETURN VALUES
   DLIST_S_SUCCESS
      Success

HISTORY
   08/05/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   *on_off = DPdlist_performance_boost;
   return( DLIST_S_SUCCESS );
} /* DPdlist_get_performance_boost_status */

/*--- DPdlist_set_performance_boost_status -----------------------*/

int DPdlist_set_performance_boost_status(
   IGRboolean on_off )

/*
NAME
   DPdlist_set_performance_boost_status

DESCRIPTION
   This function sets the status of the display list
   performance boost flag.  If the flag is TRUE, then
   'dynamic display' from the display list will be
   in performance boost mode and elements with symbology
   overrides and surfaces with horizon edges/curves,
   will be displayed without these entities.

SYNOPSIS
   int DPdlist_set_performance_boost_status(
      IGRboolean on_off )

PARAMETERS
   on_off (IN) - the new performance boost status

GLOBALS USED
   DPdlist_performance_boost

RETURN VALUES
   DLIST_S_SUCCESS
      Success

HISTORY
   08/05/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   DPdlist_performance_boost = on_off;
   return( DLIST_S_SUCCESS );
} /* DPdlist_set_performance_boost_status */


/*--- DPdlist_set_object_space_scales --------------------------------*/

int DPdlist_set_object_space_scales(
   void )

/*
NAME
   DPdlist_set_object_space_scales

DESCRIPTION
   This function calculates the maximum "to_world" scale that is
   used for all attachments of a given object space.

SYNOPSIS
   int DPdlist_set_object_space_scales(
      void )
   
PARAMETERS
   none

GLOBALS USED
   DPhash_tables

RETURN VALUES
   DLIST_S_SUCCESS
      Success
   DLIST_E_ERROR
      An error occured during the calculation

HISTORY
   09/21/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   IGRlong sts, msg;
   IGRint ii;
   OM_S_OBJID mod_id, super_id;
   OMuword mod_os, super_os;
   OMuint count;
   OM_S_OBJECT_LINKAGE *objects;
   OM_S_CHANSELECT to_contexts;
   IGRdouble x, y, z, scale;
   IGRmatrix mat;
   GRspacenum ctx_os;
   IGRshort mat_type, ctx_flag;
   struct GRid ctx_grid;

   /* set all scales back to 1.0 */
   for ( ii = 0; ii < OM_Gw_maxOS; ii++ )
   {
      DPhash_tables[ii].max_to_world_scale = 1.0;
   }

   ex$get_cur_mod( id = &mod_id, osnum = &mod_os );

   sts = ex$get_super( mod_id = mod_id, mod_osnum = mod_os,
                       super_name = "Ref Mgr", super_class = "Super_rfmgr",
                       create = FALSE, super_id = &super_id, super_osnum = &super_os );

   if ( (!(1 & sts)) || (super_id == NULL_OBJID) )
   {
      return( DLIST_S_SUCCESS );
   }
                
   om$make_chanselect( channame = "Super_rfmgr.to_context", p_chanselect = &to_contexts );

   om$get_channel_count( osnum = super_os, objid = super_id,
                         p_chanselect = &to_contexts, count = &count );

   objects = (OM_S_OBJECT_LINKAGE *) alloca( count * sizeof( OM_S_OBJECT_LINKAGE ) );

   om$get_channel_objects( osnum = super_os, objid = super_id,
                         p_chanselect = &to_contexts, 
                         list = objects, size = count, count = &count );
   
   for ( ii = 0; ii < count; ii++ )
   {
      sts = om$send( msg = message GRcontext.GRgetinstance( &msg, &mat_type, mat,
                                                            &ctx_os, &ctx_flag, &ctx_grid ),
                     targetid = objects[ii].S_objid, targetos = objects[ii].osnum,
                     senderid = NULL_OBJID );

      if ( !(1 & sts & msg) )
      {
         return( DLIST_E_ERROR );
      }

      if ( ctx_flag & GRACTIVATED_CONTEXT )
      {
         /* determine the uniform scale contained in the matrix by applying the */
         /* matrix to a vector of unit length and then calculating the length   */
         /* of the transformed vector                                           */
         x = (mat[0] + mat[1] + mat[2]) * ONE_OVER_SQRT_THREE;
         y = (mat[4] + mat[5] + mat[6]) * ONE_OVER_SQRT_THREE;
         z = (mat[8] + mat[9] + mat[10]) * ONE_OVER_SQRT_THREE;
         scale = sqrt( x*x + y*y + z*z );

         if ( scale > DPhash_tables[ctx_os].max_to_world_scale )
         {
            DPhash_tables[ctx_os].max_to_world_scale = scale;
         }
      }
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_set_object_space_scales */

/*--- DPdlist_get_object_space_scale -------------------------------------------------*/

int DPdlist_get_object_space_scale(
   OMuword osnum,
   IGRdouble *scale )

/*
NAME
   DPdlist_get_object_space_scale

DESCRIPTION
   This function gets the maximum "to_world" scale that is
   used for all attachments of the given object space.

SYNOPSIS
   int DPdlist_get_object_space_scale(
      OMuword osnum,
      IGRdouble *scale )
   
PARAMETERS
   osnum (IN) - the object number whose scale is desired
   scale (OUT) - the scale of the object space

GLOBALS USED
   DPhash_tables

RETURN VALUES
   DLIST_S_SUCCESS
      Success
   DLIST_E_ERROR
      osnum is greater than OM_Gw_maxOS or scale is NULL

HISTORY
   09/22/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{

   if ( (osnum > OM_Gw_maxOS) || (!scale) )
   {
      return( DLIST_E_ERROR );
   }

   *scale = DPhash_tables[osnum].max_to_world_scale;

   return( DLIST_S_SUCCESS );

} /* DPdlist_get_object_space_scale */

end implementation Root;
