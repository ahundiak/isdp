/* Defines */

#ifndef DPDLIST_INCLUDE
#define DPDLIST_INCLUDE

/* Hashing function */
#define DLIST_HASH_FUNCTION( objid, size ) \
   ((objid) * (objid)) % (size)

/* feedback buffer size for stroking (64K doubles) */
#define DP_DLIST_FB_BUFFER_SIZE (64 * 8 * 1024)

/* minimum data block size */
#define DP_DLIST_MIN_BLOCK_SIZE (64 * 1024)

/* minimum hash table size */
#define DP_DLIST_MIN_HASH_SIZE 1000

/* Hash Table Flags */
#define DP_DLIST_HASH_EMPTY   0x0001
#define DP_DLIST_HASH_USED    0x0002
#define DP_DLIST_HASH_DELETED 0x0004

/* Element Flags */
#define DP_DLIST_ELE_DISPLAYABLE        0x0001
#define DP_DLIST_ELE_INACTIVE           0x0002
#define DP_DLIST_ELE_FILLED             0x0004
#define DP_DLIST_ELE_HAS_SOS            0x0008
#define DP_DLIST_ELE_IS_MSC             0x0010
#define DP_DLIST_ELE_VIEW_IND           0x0020
#define DP_DLIST_ELE_SCALE_IND          0x0040
#define DP_DLIST_ELE_HAS_GRALOOPS       0x0080
#define DP_DLIST_ELE_HAS_GRADATA        0x0100
#define DP_DLIST_ELE_HAS_HORIZON_CURVES 0x0200
#define DP_DLIST_ELE_DISPLAY_POLYGON    0x0400

/* Element Types */
#define DP_DLIST_POINT     0x0001
#define DP_DLIST_POLYGON   0x0002
#define DP_DLIST_CURVE     0x0003
#define DP_DLIST_TEXT      0x0004
#define DP_DLIST_SURFACE   0x0005
#define DP_DLIST_UNKNOWN   0x0006
#define DP_DLIST_DIMENSION 0x0007
#define DP_DLIST_SKPOINT   0x0008

/* Surface Edge Types */
#define DP_DLIST_VIEW_DEP 0x0001
#define DP_DLIST_VIEW_IND 0x0002


/* Flags for Curve Variable Data */
#define DP_DLIST_CRV_WIREFRAME   0x00000001
#define DP_DLIST_CRV_TEXT        0x00000002
#define DP_DLIST_CRV_SURFACE     0x00000004
#define DP_DLIST_CRV_RULE_LINE   0x00000008
#define DP_DLIST_CRV_TANGENT     0x00000010
#define DP_DLIST_CRV_SEAM        0x00000020
#define DP_DLIST_CRV_SUBORDINATE 0x00000040

/* Delete flags for variable data */
#define DP_DLIST_DELETE_WF_DATA  0x00000001
#define DP_DLIST_DELETE_SH_DATA  0x00000002

/* Element Display flags */
#define DP_DLIST_DISPLAY_SINGLE_ELEMENT  0x00000001
#define DP_DLIST_DISPLAY_ALL_EDGES       0x00000002
#define DP_DLIST_DISPLAY_FROM_RTREE      0x00000004

/* Return Codes For Display List Functions  */
/* Last three bits indicate severity of the */
/* error:                                   */
/*         0 - warning,                     */
/*         1 - success,                     */
/*         2 - error                        */
/*         3 - information                  */
/*         4 - fatal error                  */

/* success codes */
#define DLIST_S_SUCCESS ((1 << 3) + 0x1)

/* error codes */
#define DLIST_E_ERROR ((1 << 3) + 0x2)

/* information codes */
#define DLIST_I_NOTFOUND ((1 << 3) + 0x3)
#define DLIST_I_NOVARIABLEDATA ((2 << 3) + 0x3)

/* Structures */

#if defined(XGL)

struct DPdlist_xgl_data {
        int     shading_style;
        void    *vertex_data;
        void    *facet_data;
        unsigned long      vertex_data_size;
        unsigned long      facet_data_size;
        unsigned long      total_num_verts;
        unsigned long      total_num_facets;
};
 
#endif

/* Fixed hash table data for an element */
struct DPdlist_fixed_data
{
   OM_S_OBJID objid;
   void *wf_data;
   void *sh_data;

#if defined(XGL)
   struct DPdlist_xgl_data	*xgl_data;
   int	valid_xgl_data;
#endif

   unsigned short hash_flags;
   unsigned short ele_flags;
   unsigned short color;
   unsigned short layer;
   unsigned char style;
   unsigned char weight;
   unsigned char type;
};

/* hash table structure for each object space */
struct DPdlist_hash_table
{
   double max_to_world_scale;
   unsigned int size;
   unsigned int used;
   struct DPdlist_fixed_data *fixed_data;
};

/* Data block list node */
struct DPdlist_data_block_node
{
   unsigned int size;
   void *address;
   struct DPdlist_data_block_node *next;
};

/* Free chunk list node */
struct DPdlist_free_chunk_node
{
   unsigned int size;
   void *address;
   struct DPdlist_free_chunk_node *next;
};


/*
Variable length data format for a triangular mesh

   unsigned int byte_size;
   unsigned int num_verts;
   unsigned int flags;
   unsigned int num_facet_normals;
   float verts[num_verts*3];
   float vnorms[num_verts*3];
   float fnorms[num_facet_normals*3];
*/

struct DPdlist_tri_mesh
{
   unsigned int *byte_size;
   unsigned int *num_verts;
   unsigned int *flags;
   unsigned int *num_facet_normals;
   float *verts;
   float *vnorms;
   float *fnorms;
   /*** float *vcolors; ***/
};

#define DLIST_SIZEOF_MSH( numverts, numfacetnormals ) \
   ( (4 * sizeof( unsigned int)) + \
     (2 * (3 * (numverts) * sizeof( float ) ) ) + \
     (3 * (numfacetnormals) * sizeof( float ) ) )

#define DLIST_MSH_BYTE_SIZE_PTR( ptr, byte_size ) \
  (byte_size) = (unsigned int *) (ptr);

#define DLIST_MSH_NUM_VERTS_PTR( ptr, num_verts ) \
  (num_verts) = (unsigned int *) ((char *)ptr + sizeof( unsigned int ) );

#define DLIST_MSH_FLAGS_PTR( ptr, flags ) \
  (flags) = (unsigned int *) ((char *)ptr + (2 * sizeof( unsigned int )) );

#define DLIST_MSH_NUM_FACET_NORMALS_PTR( ptr, num_facet_normals ) \
  (num_facet_normals) = (unsigned int *) ((char *)ptr + (3 * sizeof( unsigned int )) );

#define DLIST_MSH_VERTS_PTR( ptr, verts ) \
  (verts) = (float *) ((char *)ptr + (4 * sizeof( unsigned int )) );

#define DLIST_MSH_VNORMS_PTR( ptr, vnorms, numverts ) \
  (vnorms) = (float *) ((char *)ptr + (4 * sizeof( unsigned int )) + \
                       ((numverts) * 3 * sizeof( float )) );

#define DLIST_MSH_FNORMS_PTR( ptr, fnorms, numverts ) \
  (fnorms) = (float *) ((char *)ptr + (4 * sizeof( unsigned int )) + \
                       ((2 * (numverts) * 3 * sizeof( float ))) );


#define DLIST_MSH_ALL_PTRS( ptr, msh, numverts ) \
   DLIST_MSH_BYTE_SIZE_PTR( (ptr), (msh).byte_size ) \
   DLIST_MSH_NUM_VERTS_PTR( (ptr), (msh).num_verts ) \
   DLIST_MSH_FLAGS_PTR( (ptr), (msh).flags ) \
   DLIST_MSH_NUM_FACET_NORMALS_PTR( ptr, (msh).num_facet_normals ) \
   DLIST_MSH_VERTS_PTR( (ptr), (msh).verts ) \
   DLIST_MSH_VNORMS_PTR( (ptr), (msh).vnorms, (numverts) ) \
   DLIST_MSH_FNORMS_PTR( (ptr), (msh).fnorms, (numverts) )

/*
Varaible length data format for : DP_DLIST_POINT

   unsigned int byte_size
   float point[3]
*/

struct DPdlist_point_variable
{
   unsigned int *byte_size;
   float *point;
};

#define DLIST_SIZEOF_PNT( ele_flags )    \
   ( sizeof( unsigned int ) + \
     (3 * sizeof( float )) + \
     ( ((ele_flags) & DP_DLIST_ELE_HAS_SOS) ? sizeof( void * ) : 0 ) )

#define DLIST_PNT_BYTE_SIZE_PTR( ptr, byte_size ) \
  (byte_size) = (unsigned int *) (ptr);

#define DLIST_PNT_POINT_PTR( ptr, point ) \
   (point) = (float *) ((char *)(ptr) + sizeof( unsigned int ) );

#define DLIST_PNT_ALL_PTRS( ptr, pnt ) \
   DLIST_PNT_BYTE_SIZE_PTR( (ptr), (pnt).byte_size ) \
   DLIST_PNT_POINT_PTR( (ptr), (pnt).point )


/*
Varaible length data format for : DP_DLIST_POLYGON

   unsigned int byte_size
   unsigned int num_points
   float points[3*num_points]
*/

struct DPdlist_polygon_variable
{
   unsigned int *byte_size;
   unsigned int *num_points;
   float *points;
};

#define DLIST_SIZEOF_PLY( numpts, ele_flags ) \
   ( (2 * sizeof( unsigned int )) + \
     (3 * (numpts) * sizeof( float )) + \
     ( ((ele_flags) & DP_DLIST_ELE_HAS_SOS) ? sizeof( void * ) : 0 ) )

#define DLIST_PLY_BYTE_SIZE_PTR( ptr, byte_size ) \
   (byte_size) = (unsigned int *) (ptr);

#define DLIST_PLY_NUM_POINTS_PTR( ptr, num_points ) \
   (num_points) = (unsigned int *) ((char *)(ptr) + sizeof( unsigned int ) );
 
#define DLIST_PLY_POINTS_PTR( ptr, points ) \
   (points) = (float *) ((char *)(ptr) + 2 * sizeof( unsigned int ) );

#define DLIST_PLY_ALL_PTRS( ptr, poly ) \
   DLIST_PLY_BYTE_SIZE_PTR( (ptr), (poly).byte_size ) \
   DLIST_PLY_NUM_POINTS_PTR( (ptr), (poly).num_points ) \
   DLIST_PLY_POINTS_PTR( (ptr), (poly).points )

/*
Variable length data format for: DP_DLIST_CURVE

   unsigned int byte_size
   unsigned int num_points
   unsigned int flags;
   float points[3*num_points] 
*/

struct DPdlist_curve_variable
{
   unsigned int *byte_size;
   unsigned int *num_points;
   unsigned int *flags;
   float *points;
};

#define DLIST_SIZEOF_CRV( numpts, ele_flags ) \
   ( (2 * sizeof( unsigned int )) + \
     sizeof( OM_S_OBJID ) + \
     (3 * (numpts) * sizeof( float )) + \
     ( ((ele_flags) & DP_DLIST_ELE_HAS_SOS) ? sizeof( void * ) : 0 ) )

#define DLIST_CRV_BYTE_SIZE_PTR( ptr, byte_size ) \
   (byte_size) = (unsigned int *) (ptr);

#define DLIST_CRV_NUM_POINTS_PTR( ptr, num_points ) \
   (num_points) = (unsigned int *) ((char *)(ptr) + sizeof( unsigned int ) );

#define DLIST_CRV_FLAGS_PTR( ptr, flags ) \
   (flags) = (unsigned int *) ((char *)(ptr) + 2 * sizeof( unsigned int ) );

#define DLIST_CRV_POINTS_PTR( ptr, points ) \
   (points) = (float *) ((char *)(ptr) + 3 * sizeof( unsigned int ) );

#define DLIST_CRV_ALL_PTRS( ptr, curve ) \
   DLIST_CRV_BYTE_SIZE_PTR( (ptr), (curve).byte_size ) \
   DLIST_CRV_NUM_POINTS_PTR( (ptr), (curve).num_points ) \
   DLIST_CRV_FLAGS_PTR( (ptr), (curve).flags ) \
   DLIST_CRV_POINTS_PTR( (ptr), (curve).points )

/*
Variable length data format for: DP_DLIST_TEXT

   Filled:
      unsigned int byte_size
      unsigned int num_polys
      void *polys[num_polys]

   Not Filled:
      unsigned int byte_size
      unsigned int num_lines
      void *lines[num_lines]
*/

struct DPdlist_filled_text_variable
{
   unsigned int *byte_size;
   unsigned int *num_polys;
   void **polys;
};

struct DPdlist_text_variable
{
   unsigned int *byte_size;
   unsigned int *num_lines;
   void **lines;
};

#define DLIST_SIZEOF_TXT( numlines, ele_flags ) \
   ( (2 * sizeof( unsigned int )) + \
     ((numlines) * sizeof( void * )) + \
     ( ((ele_flags) & DP_DLIST_ELE_HAS_SOS) ? sizeof( void * ) : 0 ) )

#define DLIST_SIZEOF_FTXT( numpolys, ele_flags ) \
   ( (2 * sizeof( unsigned int )) + \
     ((numpolys) * sizeof( void * )) + \
     ( ((ele_flags) & DP_DLIST_ELE_HAS_SOS) ? sizeof( void * ) : 0 ) )

#define DLIST_TXT_BYTE_SIZE_PTR( ptr, byte_size ) \
   (byte_size) = (unsigned int *) (ptr);

#define DLIST_FTXT_BYTE_SIZE_PTR( ptr, byte_size ) \
   (byte_size) = (unsigned int *) (ptr);

#define DLIST_TXT_NUM_LINES_PTR( ptr, num_lines ) \
   (num_lines) = (unsigned int *) ((char *)(ptr) + sizeof( unsigned int ) );

#define DLIST_FTXT_NUM_POLYS_PTR( ptr, num_polys ) \
   (num_polys) = (unsigned int *) ((char *)(ptr) + sizeof( unsigned int ) );

#define DLIST_TXT_LINES_PTR( ptr, lines ) \
   (lines) = (void *) ((char *)(ptr) + 2 * sizeof( unsigned int ) );

#define DLIST_FTXT_POLYS_PTR( ptr, polys ) \
   (polys) = (void *) ((char *)(ptr) + 2 * sizeof( unsigned int ) );

#define DLIST_TXT_ALL_PTRS( ptr, text ) \
   DLIST_TXT_BYTE_SIZE_PTR( (ptr), (text).byte_size ) \
   DLIST_TXT_NUM_LINES_PTR( (ptr), (text).num_lines ) \
   DLIST_TXT_LINES_PTR( (ptr), (text).lines )

#define DLIST_FTXT_ALL_PTRS( ptr, filled_text ) \
   DLIST_FTXT_BYTE_SIZE_PTR( (ptr), (filled_text).byte_size ) \
   DLIST_FTXT_NUM_POLYS_PTR( (ptr), (filled_text).num_polys ) \
   DLIST_FTXT_POLYS_PTR( (ptr), (filled_text).polys )

/*
Variable length wireframe data format for: DP_DLIST_SURFACE

   unsigned int byte_size
   unsigned int num_vi_edges
   unsigned int num_vi_msc_edges
   unsigned int num_sub_edges;
   unsigned int num_sub_msc_ids;
   void *vi_edges[num_vi_edges]
   OM_S_OBJID vi_msc_edges[num_vi_msc_edges]
   void *sub_edges[num_sub_edges];
   OM_S_OBJID sub_msc_ids[num_sub_msc_ids];

*/

struct DPdlist_surface_variable
{
   unsigned int *byte_size;
   unsigned int *num_vi_edges;
   unsigned int *num_vi_msc_edges;
   unsigned short *num_u_rules;
   unsigned short *num_v_rules;
   unsigned int *num_sub_edges;
   unsigned int *num_sub_msc_ids;
   void **vi_edges;
   OM_S_OBJID *vi_msc_edges;
   void **sub_edges;
   OM_S_OBJID *sub_msc_ids;
};

#define DLIST_SIZEOF_SRF( numvi, nummscvi, numsubedges, numsubmsc ) \
   ( (3 * sizeof( unsigned int )) + \
     (2 * sizeof( unsigned short)) + \
     (2 * sizeof ( unsigned int)) + \
     ((numvi) * sizeof( void * )) + \
     ((nummscvi) * sizeof( OM_S_OBJID )) + \
     ((numsubedges * sizeof( void *)) ) + \
     ((numsubmsc * sizeof( void *)) ))

#define DLIST_SRF_BYTE_SIZE_PTR( ptr, byte_size ) \
   (byte_size) = (unsigned int *) (ptr);

#define DLIST_SRF_NUM_VI_EDGES_PTR( ptr, num_vi_edges ) \
   (num_vi_edges) = (unsigned int *) ((char *)(ptr) + sizeof( unsigned int ) );

#define DLIST_SRF_NUM_VI_MSC_EDGES_PTR( ptr, num_vi_msc_edges ) \
   (num_vi_msc_edges) = (unsigned int *) ((char *)(ptr) + 2 * sizeof( unsigned int ) );

#define DLIST_SRF_NUM_U_RULES_PTR( ptr, num_u_rules ) \
   (num_u_rules) = (unsigned short *) ((char *)(ptr) + 3 * sizeof( unsigned int ) );

#define DLIST_SRF_NUM_V_RULES_PTR( ptr, num_u_rules ) \
   (num_u_rules) = (unsigned short *) ((char *)(ptr) + (3 * sizeof( unsigned int ) + \
                                       sizeof( unsigned short )) );

#define DLIST_SRF_NUM_SUB_EDGES_PTR( ptr, num_sub_edges ) \
   (num_sub_edges) = (unsigned int *) ((char *)(ptr) + (3 * sizeof( unsigned int ) + \
                                       2 * sizeof( unsigned short )) );

#define DLIST_SRF_NUM_SUB_MSC_PTR( ptr, num_msc_edges ) \
   (num_msc_edges) = (unsigned int *) ((char *)(ptr) + (3 * sizeof( unsigned int ) + \
                                       2 * sizeof( unsigned short )) + \
                                       sizeof( unsigned int ) );

#define DLIST_SRF_VI_EDGES_PTR( ptr, vi_edges ) \
   (vi_edges) = (void **) ((char *)(ptr) + \
                           (3 * sizeof( unsigned int ) + \
                           2 * sizeof( unsigned short ) + \
                           2 *  sizeof( unsigned int ) ));

#define DLIST_SRF_VI_MSC_EDGES_PTR( ptr, vi_msc_edges, num_vi_edges ) \
   (vi_msc_edges) = (OM_S_OBJID *) ((char *)(ptr) + \
                                    (3 * sizeof( unsigned int ) + \
                                    2 * sizeof( unsigned short ) + \
                                    2 * sizeof( unsigned int ) + \
                                    ( (num_vi_edges) * sizeof( void * ))) );

#define DLIST_SRF_SUB_EDGES_PTR( ptr, sub_edges, num_vi_edges, num_vi_msc_edges ) \
   (sub_edges) = (void **) ((char *)(ptr) + \
                                    (3 * sizeof( unsigned int ) + \
                                    2 * sizeof( unsigned short ) + \
                                    2 * sizeof( unsigned int ) + \
                                    ( (num_vi_edges) * sizeof( void * )) + \
                                    ( (num_vi_msc_edges) * sizeof(OM_S_OBJID *))));

#define DLIST_SRF_SUB_MSC_PTR( ptr, sub_edges, num_vi_edges, num_vi_msc_edges, num_sub_edges ) \
   (sub_edges) = (OM_S_OBJID *) ((char *)(ptr) + \
                                    (3 * sizeof( unsigned int ) + \
                                    2 * sizeof( unsigned short ) + \
                                    2 * sizeof( unsigned int ) + \
                                    ( (num_vi_edges) * sizeof( void * )) + \
                                    ( (num_vi_msc_edges) * sizeof(OM_S_OBJID *))) + \
                                    ( (num_sub_edges) * sizeof( void *)) );

#define DLIST_SRF_ALL_PTRS( ptr, surface, numviedges, nummscedges, numsubedges ) \
   DLIST_SRF_BYTE_SIZE_PTR( (ptr), (surface).byte_size ) \
   DLIST_SRF_NUM_VI_EDGES_PTR( (ptr), (surface).num_vi_edges ) \
   DLIST_SRF_NUM_VI_MSC_EDGES_PTR( (ptr), (surface).num_vi_msc_edges ) \
   DLIST_SRF_NUM_U_RULES_PTR( (ptr), (surface).num_u_rules ) \
   DLIST_SRF_NUM_V_RULES_PTR( (ptr), (surface).num_v_rules ) \
   DLIST_SRF_NUM_SUB_EDGES_PTR( (ptr), (surface).num_sub_edges ) \
   DLIST_SRF_NUM_SUB_MSC_PTR( (ptr), (surface).num_sub_msc_ids ) \
   DLIST_SRF_VI_EDGES_PTR( (ptr), (surface).vi_edges ) \
   DLIST_SRF_VI_MSC_EDGES_PTR( (ptr), (surface).vi_msc_edges, (numviedges) ) \
   DLIST_SRF_SUB_EDGES_PTR( (ptr), (surface).sub_edges, (numviedges), (nummscedges)) \
   DLIST_SRF_SUB_MSC_PTR( (ptr), surface.sub_msc_ids,(numviedges), (nummscedges), (numsubedges));


/*
Variable length shading data format for: DP_DLIST_SURFACE

   unsigned int byte_size
   unsigned int num_meshes
   float diff_refl
   float spec_refl
   float finish
   float trans
   void *meshes[num_meshes]
*/

struct DPdlist_sh_surface_variable
{
   unsigned int *byte_size;
   unsigned int *num_meshes;
   float *diff_refl;
   float *spec_refl;
   float *finish;
   float *trans;
   void **meshes;
};

/* this structure is used by HSURF to quickly access the variable */
/* surface data; if the DPdlist_sh_surface_variable is changed,   */
/* this structutre will have to be changed too.                   */
struct DPdlist_sh_surf
{
   unsigned int byte_size;
   unsigned int num_meshes;
   float diff_refl;
   float spec_refl;
   float finish;
   float trans;
};

#define DLIST_SIZEOF_SH_SRF( nummeshes ) \
   ( (2 * sizeof( unsigned int )) + \
     (4 * sizeof( float )) + \
     ((nummeshes) * sizeof( struct DPdlist_tri_mesh * )) );

#define DLIST_SH_SRF_BYTE_SIZE_PTR( ptr, byte_size ) \
   (byte_size) = (unsigned int *) (ptr);

#define DLIST_SH_SRF_NUM_MESHES_PTR( ptr, num_meshes ) \
   (num_meshes) = (unsigned int *) ( (char *) (ptr) + sizeof( unsigned int ) );

#define DLIST_SH_SRF_DIFF_REFL_PTR( ptr, diff_refl ) \
   (diff_refl) = (float *) ( (char *) (ptr) + (2 * sizeof( unsigned int )) );

#define DLIST_SH_SRF_SPEC_REFL_PTR( ptr, spec_refl ) \
   (spec_refl) = (float *) ( (char *) (ptr) + (2 * sizeof( unsigned int )) + \
                             sizeof( float) );

#define DLIST_SH_SRF_FINISH_PTR( ptr, finish ) \
   (finish) = (float *) ( (char *) (ptr) + (2 * sizeof( unsigned int )) + \
                          (2 * sizeof( float) ) );

#define DLIST_SH_SRF_TRANS_PTR( ptr, trans ) \
   (trans) = (float *) ( (char *) (ptr) + (2 * sizeof( unsigned int )) + \
                         (3 * sizeof( float) ) );

#define DLIST_SH_SRF_MESHES_PTR( ptr, meshes ) \
   (meshes) = (void **) ( (char *) (ptr) + (2 * sizeof( unsigned int )) + \
                          (4 * sizeof( float) ) );

#define DLIST_SH_SRF_ALL_PTRS( ptr, sh_surface ) \
   DLIST_SH_SRF_BYTE_SIZE_PTR( (ptr), (sh_surface).byte_size ) \
   DLIST_SH_SRF_NUM_MESHES_PTR( (ptr), (sh_surface).num_meshes ) \
   DLIST_SH_SRF_DIFF_REFL_PTR( (ptr), (sh_surface).diff_refl ) \
   DLIST_SH_SRF_SPEC_REFL_PTR( (ptr), (sh_surface).spec_refl ) \
   DLIST_SH_SRF_FINISH_PTR( (ptr), (sh_surface).finish ) \
   DLIST_SH_SRF_TRANS_PTR( (ptr), (sh_surface).trans ) \
   DLIST_SH_SRF_MESHES_PTR( (ptr), (sh_surface).meshes )


/*
Variable length data format for: DP_DLIST_UNKNOWN

   unsigned int byte_size
   int (*disp_func)(
      OM_S_OBJID objid,
      OMuword osnum,
      void *data,
      struct DP_information *dp_info,
      IGRmatrix matrix,
      IGRshort matrix_type,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb )
   unsigned int data_size
   char data[data_size]
*/

struct DPdlist_unknown_variable
{
   unsigned int *byte_size;
   int (**disp_func)(
      OM_S_OBJID objid,
      OMuword osnum,
      void *data,
      struct DP_information *dp_info,
      IGRmatrix matrix,
      IGRshort matrix_type,
      enum GRdpmode dp_mode,
      struct IGRaltdisplay *alt_symb );
   unsigned int *data_size;
   char **data;
};

#define DLIST_SIZEOF_UNK( datasize ) \
   ( (2 * sizeof( unsigned int )) + \
     sizeof( int (*)() ) + \
     ((datasize) * sizeof( char )) )

#define DLIST_UNK_BYTE_SIZE_PTR( ptr, byte_size ) \
   (byte_size) = (unsigned int *) (ptr);

#define DLIST_UNK_DISP_FUNC_PTR( ptr, disp_func ) \
   (disp_func) = (int (**)( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      void *data, \
      struct DP_information *dp_info, \
      IGRmatrix matrix, \
      IGRshort matrix_type, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb)) ((char *)(ptr) + sizeof( unsigned int ) );

#define DLIST_UNK_DATA_SIZE_PTR( ptr, data_size ) \
   (data_size) = (unsigned int *) ((char *)(ptr) + sizeof( unsigned int ) + \
                                   sizeof( int (*)() ) );

#define DLIST_UNK_DATA_PTR( ptr, data ) \
   (data) = (char **) ((char *)(ptr) + 2 * sizeof( unsigned int ) + \
                              sizeof( int (*)() ) );

#define DLIST_UNK_ALL_PTRS( ptr, unknown ) \
   DLIST_UNK_BYTE_SIZE_PTR( (ptr), (unknown).byte_size ) \
   DLIST_UNK_DISP_FUNC_PTR( (ptr), (unknown).disp_func ) \
   DLIST_UNK_DATA_SIZE_PTR( (ptr), (unknown).data_size ) \
   DLIST_UNK_DATA_PTR( (ptr), (unknown).data )


/* Internal Function Prototypes */

#define PROTO_DPdlist_initialize \
   extern int DPdlist_initialize( \
      void );

#define PROTO_DPdlist_exit \
   extern int DPdlist_exit( \
      void );

#define PROTO_DPdlist_get_status \
   extern int DPdlist_get_status( \
      IGRboolean *on_off );

#define PROTO_DPdlist_set_status \
   extern int DPdlist_set_status( \
      IGRboolean on_off );

#define PROTO_DPdlist_set_partial_drop_mode \
   extern int DPdlist_set_partial_drop_mode ( \
      IGRboolean mode );

#define PROTO_DPdlist_get_partial_drop_mode \
   extern IGRboolean DPdlist_get_partial_drop_mode ( );

#define PROTO_DPdlist_setup_feedback_gragad \
   extern int DPdlist_setup_feedback_gragad( \
      void );

#define PROTO_DPdlist_set_tolerance_gragad \
   extern int DPdlist_set_tolerance_gragad( \
      struct GRid *gragad );

#define PROTO_DPdlist_set_shading_display_function \
   extern int DPdlist_set_shading_display_function( \
      int (*shading_display_function)( \
         OM_S_OBJID objid, \
         OMuword osnum, \
         struct DP_information *dp_info, \
         IGRmatrix matrix, \
         IGRshort matrix_type, \
         enum GRdpmode dp_mode, \
         struct IGRaltdisplay *alt_symb, \
         OM_p_KEY_DESC key, \
         IGRint single_display ) );

#define PROTO_DPdlist_alloc_hash_table \
   extern int DPdlist_alloc_hash_table( \
      OMuword osnum, \
      int size );

#define PROTO_DPdlist_free_hash_table \
   extern int DPdlist_free_hash_table( \
      OMuword osnum );

#define PROTO_DPdlist_resize_hash_table \
   extern int DPdlist_resize_hash_table( \
      OMuword osnum );

#define PROTO_DPdlist_hash_add \
   extern int DPdlist_hash_add( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      struct DPdlist_fixed_data **fixed_data );

#define PROTO_DPdlist_hash_lookup \
   extern int DPdlist_hash_lookup( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      struct DPdlist_fixed_data **fixed_data );

#define PROTO_DPdlist_hash_delete \
   extern int DPdlist_hash_delete( \
      OM_S_OBJID objid, \
      OMuword osnum );

#define PROTO_DPdlist_hash_delete_all \
   extern int DPdlist_hash_delete_all( \
      OMuword osnum, \
      IGRboolean set_to_empty );

#define PROTO_DPdlist_alloc_data_block \
   extern int DPdlist_alloc_data_block( \
      int size, \
      void **ptr );

#define PROTO_DPdlist_free_data_blocks \
   extern int DPdlist_free_data_blocks( \
      void );

#define PROTO_DPdlist_alloc_chunk \
   extern int DPdlist_alloc_chunk( \
      int size, \
      void **ptr );

#define PROTO_DPdlist_free_chunk \
   extern int DPdlist_free_chunk( \
      int size, \
      void *ptr );

#define PROTO_DPdlist_display_point \
   extern int DPdlist_display_point( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_DPdlist_display_polygon \
   extern int DPdlist_display_polygon( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_DPdlist_display_curve \
   extern int DPdlist_display_curve( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_DPdlist_display_text \
   extern int DPdlist_display_text( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_DPdlist_display_surface \
   extern int DPdlist_display_surface( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type, \
      IGRint single_display );

#define PROTO_DPdlist_display_unknown \
   extern int DPdlist_display_unknown( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_DPdlist_display_unknown \
   extern int DPdlist_display_unknown( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      IGRmatrix matrix, \
      IGRshort matrix_type );

#define PROTO_DPdlist_delete_point_variable \
   extern int DPdlist_delete_point_variable( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum );
 
#define PROTO_DPdlist_delete_polygon_variable \
   extern int DPdlist_delete_polygon_variable( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum );
 
#define PROTO_DPdlist_delete_curve_variable \
   extern int DPdlist_delete_curve_variable( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum );
 
#define PROTO_DPdlist_delete_text_variable \
   extern int DPdlist_delete_text_variable( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum );
 
#define PROTO_DPdlist_delete_surface_variable \
   extern int DPdlist_delete_surface_variable( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum, \
      int delete_flag );
 
#define PROTO_DPdlist_delete_unknown_variable \
   extern int DPdlist_delete_unknown_variable( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum );

#define PROTO_DPdlist_delete_dimension_variable \
   extern int DPdlist_delete_dimension_variable( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum );

#define PROTO_DPdlist_delete_skpoint_variable \
   extern int DPdlist_delete_skpoint_variable( \
      struct DPdlist_fixed_data *fixed_data, \
      OMuword osnum );

#define PROTO_DPdlist_get_transform_buffer \
   extern int DPdlist_get_transform_buffer( \
      unsigned int byte_size, \
      void **buffer );

#define PROTO_DPdlist_init_set_arrays \
   extern int DPdlist_init_set_arrays( \
      void );

#define PROTO_DPdlist_add_pointer_to_set \
   extern int DPdlist_add_pointer_to_set( \
      int type, \
      void *ptr );

#define PROTO_DPdlist_add_sub_pointer_to_set \
   extern int DPdlist_add_sub_pointer_to_set( \
      int type, \
      void *ptr );

#define PROTO_DPdlist_add_objid_to_set \
   extern int DPdlist_add_objid_to_set( \
      int type, \
      OM_S_OBJID objid );

#define PROTO_DPdlist_add_sub_objid_to_set \
   extern int DPdlist_add_sub_objid_to_set( \
      int type, \
      OM_S_OBJID objid );

#define PROTO_DPdlist_get_pointer_sets \
   extern int DPdlist_get_pointer_sets( \
      unsigned int *num_vi, \
      void ***vi_ptrs, \
      unsigned int *num_vd, \
      void ***vd_ptrs );

#define PROTO_DPdlist_get_sub_pointer_sets \
   extern int DPdlist_get_sub_pointer_sets( \
      unsigned int *num_sub_vi, \
      void ***sub_vi_ptrs );

#define PROTO_DPdlist_get_objid_sets \
   extern int DPdlist_get_objid_sets( \
      unsigned int *num_vi, \
      OM_S_OBJID **vi_ids, \
      unsigned int *num_vd, \
      OM_S_OBJID **vd_ids );

#define PROTO_DPdlist_get_sub_objid_sets \
   extern int DPdlist_get_sub_objid_sets( \
      unsigned int *num_sub_msc_ids, \
      OM_S_OBJID **sub_msc_ids );

#define PROTO_DPdlist_init_mesh_array \
   extern int DPdlist_init_mesh_array( \
      void );

#define PROTO_DPdlist_add_mesh_to_set \
   extern int DPdlist_add_mesh_to_set( \
      void *mesh_ptr );

#define PROTO_DPdlist_get_mesh_set \
   extern int DPdlist_get_mesh_set( \
      unsigned int *num_mesh_ptrs, \
      void ***mesh_ptrs );

#define PROTO_DPdlist_transform_points \
   extern int DPdlist_transform_points( \
      int num_points, \
      IGRmatrix matrix, \
      short matrix_type, \
      float *src_pts, \
      float *dest_pts );

#define PROTO_DPdlist_alloc_data_block_node \
   extern int DPdlist_alloc_data_block_node( \
      struct DPdlist_data_block_node **node_ptr ) ;

#define PROTO_DPdlist_free_data_block_node \
   extern int DPdlist_free_data_block_node( \
      struct DPdlist_data_block_node **node_ptr );

#define PROTO_DPdlist_alloc_free_chunk_node \
   extern int DPdlist_alloc_free_chunk_node( \
      struct DPdlist_free_chunk_node **node_ptr );

#define PROTO_DPdlist_free_free_chunk_node \
   extern int DPdlist_free_free_chunk_node( \
      struct DPdlist_free_chunk_node **node_ptr );

#define PROTO_DPdlist_display_element \
   extern int DPdlist_display_element( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      IGRmatrix matrix, \
      IGRshort matrix_type, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      OM_p_KEY_DESC key, \
      IGRint single_display );

#define PROTO_DPdlist_display_element_update \
   extern int DPdlist_display_element_update( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      struct DP_information *dp_info, \
      IGRmatrix matrix, \
      IGRshort matrix_type, \
      enum GRdpmode dp_mode, \
      struct IGRaltdisplay *alt_symb, \
      OM_p_KEY_DESC key, \
      IGRint single_display );

#define PROTO_DPdlist_change_attr \
   extern int DPdlist_change_attr( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      IGRshort color, \
      IGRchar style, \
      IGRchar weight, \
      IGRshort layer );

#define PROTO_DPdlist_delete_element \
   extern int DPdlist_delete_element( \
      OM_S_OBJID objid, \
      OMuword osnum );

#define PROTO_DPdlist_delete_variable_data \
   extern int DPdlist_delete_variable_data( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      int delete_flag );

#define PROTO_DPdlist_add_point \
   extern int DPdlist_add_point( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      unsigned short ele_flags, \
      IGRshort color, \
      IGRchar style, \
      IGRchar weight, \
      IGRshort layer, \
      IGRdouble point[3] );

#define PROTO_DPdlist_add_polygon \
   extern int DPdlist_add_polygon( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      unsigned short ele_flags, \
      IGRshort color, \
      IGRchar style, \
      IGRchar weight, \
      IGRshort layer, \
      IGRuint num_points, \
      IGRdouble *points );

#define PROTO_DPdlist_add_curve \
   extern int DPdlist_add_curve( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      unsigned short ele_flags, \
      IGRshort color, \
      IGRchar style, \
      IGRchar weight, \
      IGRshort layer, \
      IGRuint num_points, \
      IGRdouble *points );

#define PROTO_DPdlist_add_dimension \
   extern int DPdlist_add_dimension( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      unsigned short ele_flags, \
      IGRshort color, \
      IGRchar style, \
      IGRchar weight, \
      IGRshort layer );

#define PROTO_DPdlist_add_skpoint \
   extern int DPdlist_add_skpoint( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      unsigned short ele_flags, \
      IGRshort color, \
      IGRchar style, \
      IGRchar weight, \
      IGRshort layer );

#define PROTO_DPdlist_add_SO_data \
   extern int DPdlist_add_SO_data( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      int num_SOs, \
      DEsoe *SOs );

#define PROTO_DPdlist_add_text \
   extern int DPdlist_add_text( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      unsigned short ele_flags, \
      IGRshort color, \
      IGRchar style, \
      IGRchar weight, \
      IGRshort layer, \
      struct DPdlist_fixed_data **fixed_data );

#define PROTO_DPdlist_finish_text \
   extern int DPdlist_finish_text( \
      struct DPdlist_fixed_data *fixed_data );

#define PROTO_DPdlist_add_curve_to_text \
   extern int DPdlist_add_curve_to_text( \
      struct DPdlist_fixed_data *fixed_data, \
      IGRuint num_points, \
      IGRdouble *points );

#define PROTO_DPdlist_add_polygon_to_text \
   extern int DPdlist_add_polygon_to_text( \
      struct DPdlist_fixed_data *fixed_data, \
      IGRuint num_points, \
      IGRdouble *points );

#define PROTO_DPdlist_add_surface \
   extern int DPdlist_add_surface( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      unsigned short ele_flags, \
      IGRshort is_hidden_line, \
      IGRshort color, \
      IGRchar style, \
      IGRchar weight, \
      IGRshort layer, \
      struct DPdlist_fixed_data **fixed_data );

#define PROTO_DPdlist_finish_surface \
   extern int DPdlist_finish_surface( \
      struct DPdlist_fixed_data *fixed_data, \
      IGRshort is_hidden_line, \
      unsigned short num_u_rules, \
      unsigned short num_v_rules );

#define PROTO_DPdlist_add_edge_to_surface \
   extern int DPdlist_add_edge_to_surface( \
      struct DPdlist_fixed_data *fixed_data, \
      IGRuchar edge_type, \
      IGRuint flags, \
      IGRuint num_points, \
      IGRdouble *points );

#define PROTO_DPdlist_add_msc_edge_to_surface \
   extern int DPdlist_add_msc_edge_to_surface( \
      struct DPdlist_fixed_data *fixed_data, \
      IGRuchar edge_type, \
      IGRuint flags, \
      OM_S_OBJID msc_id );
   
#define PROTO_DPdlist_add_unknown \
   extern int DPdlist_add_unknown( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      unsigned short ele_flags, \
      IGRshort color, \
      IGRchar style, \
      IGRchar weight, \
      IGRshort layer, \
      IGRint (*disp_func)( \
         OM_S_OBJID objid, \
         OMuword osnum, \
         void *data, \
         struct DP_information *dp_info, \
         IGRmatrix matrix, \
         IGRshort mat_type, \
         enum GRdpmode dp_mode, \
         struct IGRaltdisplay *alt_symb ), \
      IGRuint byte_size, \
      void *data );

#define PROTO_DPdlist_wireframe_notify \
   extern int DPdlist_wireframe_notify( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      IGRint notify_mask );

#define PROTO_DPdlist_loopset_notify \
   extern int DPdlist_loopset_notify( \
      OM_S_OBJID objid, \
      OMuword osnum );

#define PROTO_DPdlist_msc_created \
   extern int DPdlist_msc_created( \
      OM_S_OBJID msc_objid, \
      OMuword osnum );

#define PROTO_DPdlist_SO_notify \
   extern int DPdlist_SO_notify( \
      OM_S_OBJID objid, \
      OMuword osnum );

#define PROTO_DPdlist_add_curve_to_display_list \
   extern int DPdlist_add_curve_to_display_list( \
      OM_S_OBJID objid, \
      OMuword osnum );
 
#define PROTO_DPdlist_add_point_to_display_list \
   extern int DPdlist_add_point_to_display_list( \
      OM_S_OBJID objid, \
      OMuword osnum );

#define PROTO_DPdlist_add_polygon_to_display_list \
   extern int DPdlist_add_polygon_to_display_list( \
      OM_S_OBJID objid, \
      OMuword osnum );

#define PROTO_DPdlist_add_text_to_display_list \
   extern int DPdlist_add_text_to_display_list( \
      OM_S_OBJID objid, \
      OMuword osnum );

#define PROTO_DPdlist_add_surface_to_display_list \
   extern int DPdlist_add_surface_to_display_list( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      IGRboolean is_hidden_line );

#define PROTO_DPdlist_surface_active_notify \
   extern int DPdlist_surface_active_notify( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      IGRboolean active );

#define PROTO_DPdlist_surface_drop_notify \
   extern int DPdlist_surface_drop_notify( \
      OM_S_OBJID objid, \
      OMuword osnum );

#define PROTO_DPdlist_graloop_notify \
   extern int DPdlist_graloop_notify( \
      OM_S_OBJID objid, \
      OMuword osnum );

#define PROTO_DPdlist_horizon_curve_notify \
   extern int DPdlist_horizon_curve_notify( \
      OM_S_OBJID objid, \
      OMuword osnum );

#define PROTO_DPdlist_tangent_edge_display_notify \
   extern int DPdlist_tangent_edge_display_notify( \
      int display_flag );

#define PROTO_DPdlist_deactivate_object_space \
   extern int DPdlist_deactivate_object_space( \
      OMuword osnum );

#define PROTO_DPdlist_print_fixed_data \
   extern int DPdlist_print_fixed_data( \
      struct DPdlist_fixed_data *fixed_data );

#define PROTO_DPdlist_print_hash_table \
   extern int DPdlist_print_hash_table( \
      OMuword osnum, \
      short print_entries );

#define PROTO_DPdlist_print_point_variable \
   extern int DPdlist_print_point_variable( \
      void *variable );

#define PROTO_DPdlist_print_polygon_variable \
   extern int DPdlist_print_polygon_variable( \
      void *variable );

#define PROTO_DPdlist_print_curve_variable \
   extern int DPdlist_print_curve_variable( \
      void *variable );

#define PROTO_DPdlist_print_text_variable \
   extern int DPdlist_print_text_variable( \
      void *variable );

#define PROTO_DPdlist_print_filled_text_variable \
   extern int DPdlist_print_filled_text_variable( \
      void *variable );

#define PROTO_DPdlist_print_surface_variable \
   extern int DPdlist_print_surface_variable( \
      void *wf_variable, \
      void *sh_variable );

#define PROTO_DPdlist_print_unknown_variable \
   extern int DPdlist_print_unknown_variable( \
      void *variable );

#define PROTO_DPdlist_print_variable \
   extern int DPdlist_print_variable( \
      struct DPdlist_fixed_data *fixed_data );

#define PROTO_DPdlist_print_element \
   extern int DPdlist_print_element( \
      OM_S_OBJID objid, \
      OMuword osnum );

#define PROTO_DPdlist_set_shading_reference_file_functions \
   extern int DPdlist_set_shading_reference_file_functions( \
      int (*enter_ref_file)( \
         struct DP_information *dp_info, \
         IGRshort matrix_type, \
         IGRmatrix matrix ), \
      int (*exit_ref_file)( \
         struct DP_information *dp_info, \
         IGRshort matrix_type, \
         IGRmatrix matrix ) );

#define PROTO_DPdlist_enter_reference_file \
   extern int DPdlist_enter_reference_file( \
      struct DP_information *dp_info, \
      IGRshort matrix_type, \
      IGRmatrix matrix );

#define PROTO_DPdlist_exit_reference_file \
   extern int DPdlist_exit_reference_file( \
      struct DP_information *dp_info, \
      IGRshort matrix_type, \
      IGRmatrix matrix );

#define PROTO_DPdlist_set_element_flags \
   extern int DPdlist_set_element_flags( \
      OM_S_OBJID objid, \
      OMuword osnum, \
      unsigned short *ele_flags );

#define PROTO_DPdlist_get_performance_boost_status \
   extern int DPdlist_get_performance_boost_status( \
      IGRboolean *on_off );

#define PROTO_DPdlist_set_performance_boost_status \
   extern int DPdlist_set_performance_boost_status( \
      IGRboolean on_off );

#define PROTO_DPdlist_set_object_space_scales \
   extern int DPdlist_set_object_space_scales( \
      void );

#define PROTO_DPdlist_get_object_space_scale
   extern int DPdlist_get_object_space_scale( \
      OMuword osnum, \
      IGRdouble *scale );

#endif
