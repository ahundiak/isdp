/*
 * HSpr_pbust_f.h: The prototype file for the 
 * hsurf/src/pbust_func directory
 */
 

#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/*---HSe2_edges.c------------------------------------------*/

extern void HSfree_edges __(( 
   void ));

extern void HSaddEdge  __(( 
   struct HStri_vertex *,
   struct HStri_vertex *,
   unsigned short,
   int,
   int,
   struct Edge *,
   struct Edge *,
   double ));

extern void HScreateEdges  __((
   struct HSloop *,
   int,
   int,
   double )); 

extern int HShandleCrossingEdges __((
   struct Edge *,
   struct Edge *,
   short, 
   int,
   int ));

/*---HSe2_maketri.c---------------------------------------*/

extern int HSprocess_tri_facet __((
   struct HStri_loop *,
   int,
   int,
   int,
   int )); 

/*---HSe2_regular.c---------------------------------------*/

extern void HSdelSetFromAEL __((
   struct Edge **,
   int,
   int ));

extern int HSgetIntercepts  __((
   struct HStri_vertex *,
   double,
   IGRshort ));

/*---HSe2_sort.c------------------------------------------*/

extern struct HStri_vertex **HSsetupList __((
   struct HSloop *,
   int,
   int,
   int ));

extern void HSquickSort  __((
   int,
   int ));

/*---HSe2_triangl.c---------------------------------------*/

extern int HStriangulate __((
   int,
   struct PolygonVert *,
   int,
   int,
   int,
   double,
   int )); 

/*---HSe2_trimesh.c---------------------------------------*/

extern void HSdisplay_buffered_trimesh __((
   void ));

extern void HSadd_vertex_to_buffered_trimesh __((
   IGRpoint,
   IGRpoint,
   IGRpoint )); 

/*---HStl_maketrp.c---------------------------------------*/

extern int make_trapezoids __((
   double,
   double,
   double,
   double,
   double,
   double,
   double,
   double,
   double,
   IGRshort,
   IGRshort,
   int )); 

/*---HStl_pbust.c-----------------------------------------*/

extern void poly_bust __((
   int,
   struct HSpb_master *,
   struct HSpb_edge *,
   int *,
   int *,
   int,
   int ));

/*---HSts_mem_man.c------------------------------------------------*/

extern void HSinit_pool_memory_management __((
   int ));

extern void HSfree_pool_memory __((
   void ));

extern IGRchar *HSalloc_struct_from_pool  __((
   int  ));

/*---HSts_tri.c----------------------------------------------------*/

extern int make_triangles __((
   double,
   double,
   double,
   double,
   double,
   double,
   double,
   IGRshort,
   IGRshort,
   int,
   int,
   int )); 

extern int HStessel_facet __((
   void ));


#if defined(__cplusplus)
}
#endif


#undef __
