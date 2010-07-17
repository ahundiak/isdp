#ifndef MHmsdef_include

#define MHmsdef_include

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

/* define indices for connecting vertex meshes to edge meshes */

#define MHED_LEFT_VTX_IDX 0
#define MHED_RIGHT_VTX_IDX 1

/* define values to indicate left and right end of edge */
#define MHedge_left_end 0
#define MHedge_right_end 1


/* define types for loops */
#define P_LOOP 		1
#define C_LOOP 		-1
#define FEATURE_LOOP	2

/* define a structure with the information used in meshing */
struct MHmeshing_info
	{
		int	sf_eltype;	/* surface element type */
		int	sl_eltype;	/* solid element type */
		double	elem_size;	/* nominal element size (mesh density) */
		double	gamma;		/* quad conversion shape factor */
	};

/* define a structure with the information used in meshing */
struct MHsfmesh_info
	{
		int	sf_eltype;	/* surface element type */
		double	elem_size;	/* nominal element size (mesh density) */
		double	gamma;		/* quad conversion shape factor */
	};

/* define a structure with the information used in meshing */
struct MHsolmesh_info
	{
		int	sl_eltype;	/* solid element type */
		double	elem_size;	/* nominal element size (mesh density) */
	};

/* define a structure which contains a list of meshes */
struct MHmesh_list
	{
		int		num_mspart;
		struct GRid	*mspart;	/* part objects */
		int		num_mssolid;
		struct GRid	*mssolid;	/* volume meshes */
		int		num_msface;
		struct GRid	*msface;	/* surface meshes */
		int		num_msedge;
		struct GRid	*msedge;	/* edge meshes */
		int		num_msvtx;
		struct GRid	*msvtx;		/* vertex meshes */
	};

struct quad
	{
		OM_S_OBJID	nodes[4];
	};

struct MHelem_list
	{
		int		el_dimension;
		int		*eltypes;
		int		num_elems;
		OM_S_OBJID	*node_list;
	};

/*
 * this structure stores info for a group of 2d elements or solid element
 * faces which map to a face (2d region).  the elements may be pseudo
 * elements (only node objids and a connectivity map) rather than actual
 * elements or solid faces
*/
struct MHface_elmap
	{
/* the following fields are used for bilinear and trilinear face maps */
		long		type;		/* face map type (below) */
		long		ncol;		/* number of columns of nodes */
		long		nrow;		/* number of rows per column */
		OM_S_OBJID	*node_list;	/* list of nodes on a face */
		double		*ndcoords;	/* node coordinates */

/* the following fields are added/used for general 2d element maps */
		char		*mid_layer;	/* TRUE if node projects to
						   mid layer for high order
						   mid_layer can be NULL for
						   low order */
		long		num_elems;	/* number of elements */
		long		*eltypes;	/* elem_type for each elem */
		long		*conn_map;	/* connectivity map - allocate
						   8 nodes per element to allow
						   for quad8, conn_map contains
						   the index in the node_list
						   for the nodes of an elem */
	};

/* face map types */
#define BILIN_MAP	0
#define TRILIN_MAP	1

#define FACE_ELEM_MAP	2	/* general map of panel elements (mixed types)*/

/* Smoothing iterations (see MHCmsauto.sl) */
#define MH_FACE_ITER	3
#define MH_SOLID_ITER	20

/* Flags for smoothing (used in "fixed" node-flag array) */
#define MH_SM_INTERIOR	0	/* coordinate modified every pass */
#define MH_SM_FIXED	1	/* coordinate not modified */
#define MH_SM_MIDSIDE	2	/* coordinate modified on last pass only */
#endif
