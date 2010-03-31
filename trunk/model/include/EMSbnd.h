/*
 * This file contains the structure definitions for EMS surface boundary
 * and topology messages and methods.
 */

#ifndef EMSbnd_h
#define EMSbnd_h    1

#ifndef emsdattyp_include
#include "emsdattyp.h"
#endif

#ifndef EMSssi_include
#include "EMSssi.h"
#endif

#ifndef emsinter_include
#include "emsinter.h"
#endif

/* The following structure represents the parameter on an edge
*/

struct EMSedgebound
{
  IGRdouble param;          /* parameter value on the span(each span
                                being parametrized from 0 to 1) */
  IGRshort span_inx;        /* span index of the span on which the
                                parameter lies.*/
};

/*
 * This structure is used by EMSpartedges to 
 * transmit information related to them, down
 * to the EMSlinedge for correct execution of
 * the method.
 */

struct EMSpartedinfo 
  {
  unsigned short edprops;               /* properties bits */
  unsigned char  edtype;                /* type of the edge */
  struct EMSedgebound edbdry[2];        /* bounds of the partedge*/
  GRobjid edid;                         /* objid of the partedge*/
  };

/* The following structure returns the information regarding projection
   of a point(2D) on a edge
*/
struct EMSproj_info
{
  IGRdouble             proj_pt[2];     /* point on the edge */
  IGRdouble             dist;           /* minimum dist. to the edge*/
  struct EMSedgebound   param;          /* param on the edge for the
                                           point on the edge */
  IGRdouble             tangent[2];     /* tangent value returned at param
                                           extremely useful for a bs
                                           edge */
  enum EMScvinttype     location;       /* location of projected point
                                           on element */
};


/*
 * The following structure is used to define the location
 * of a uv point with respect to a loop.
 */
struct EMSlocated_edge
{
  GRobjid               edge_id;        /* objid of the nearest edge*/
  struct EMSproj_info   nst_pt;         /* projection info wrt
                                          the edge */
};


struct EMSptloc_info
{
  IGRshort                      location;       	/* Location of
                                                 	 the point wrt the 
                                                  	 element(loop/loopset/
                                                  	 edge) */
  IGRshort                      options;   		/* options for the
                                              		   location test*/
  GRobjid                       loop_id;   		/* objid of the loop 
							   which did the 
							   location test*/
  IGRshort                      num_located_edges; 	/* num. of located
                                                      	   edges*/
  struct EMSlocated_edge        edge[MAX_LOCATED_EDGES];   /* info about
							   each  located 
							   edge */
};


/* following structure is used to get the nesting information of a loop
*/
struct EMSnest_info
  {
     GRobjid             loopid;   /* objid of the loop whose info
                                        this is.*/
     IGRshort            lp_props; /* properties of the loop */
     GRobjid             parent;   /* parent of the loop. If orphan this
                                        will be NULL_OBJID */
     IGRshort            parent_props; /* properties of the parent. Valid
                                          only if not orphan */
     IGRdouble           range[4]; /* range box of the loop */
  };


struct EMSpack_info
 {
        IGRlong                 option;
        IGRdouble               point[2];
        struct IGRbsp_bdry_pts  *bdrys;
        IGRshort                num_bdrys;
        IGRboolean              on_off;
 };

/*
 * This structure is used to pass as an argument,
 * the parametric basis tolerance, associated with
 * the boundary element.
 */

struct EMSpartolbasis
  {
  IGRdouble tol;          /* The basis tolerance. If this field is invalid
                             "is_valid" is set to FALSE */
  IGRboolean is_valid;    /* Iff TRUE then the "tol" field has the valid
                             tolerance */
  IGRboolean in_world;    /* The tolerance refers to the world space if
                             TRUE, else refers to the local space */
  IGRshort *mattyp;       /* Pointer to the matrix-type of the matrix
                             that takes local space to world space */
  IGRdouble *mat;         /* Pointer to the 4 X 4, matrix array that
                             takes local space to world space. */
  };

/*
 * The following linked-list structure is used for storing
 * information about a string of owner-objects and their components
 * in an ordered fashion.
 */

struct EMSownercomp
  {
  GRobjid owner;             /* Object-id of the owner */
  IGRint num_comps;          /* Number of owner's components stored */
  GRobjid *comps;            /* Array of component object-ids */
  IGRint *ownerindex;        /* Array of owners chan index to each comp.*/
  struct EMSownercomp *next; /* Pointer to next node in the linked-list */  
  };

/*
 * Enumerated type that denotes the kind of manipulation
 * operation that may be performed on some data.
 */

enum EMSmaniptype
  {
  EMSmanip_delete,   /* A deletion of a part or the entire data */
  EMSmanip_extract,  /* Some portion or the entire data is to be extracted */
  EMSmanip_modify,   /* Some portion or the entire data is to be modified */
  EMSmanip_insert,   /* Some new piece of data is to be inserted */
  EMSmanip_null      /* When a null operation is specified */
  };

/*
 * The following structure is used by stitching methods at EMSedge and
 * EMSgencompsf, to communicate stitching information of an edge-pair.
 */

struct EMSstitch_info
{
   GRobjid edge0, edge1;
   GRobjid surf0, surf1;
   struct IGRbsp_curve *edge_geom0, *edge_geom1;
   struct IGRbsp_surface *surf_geom0, *surf_geom1;
   unsigned short option;
};


/* Following structure is used to communicate memory allocation for save state
   information during  stitching operation.
*/

struct EMSstitch_saveinfo
{
 struct EMSstchssi_table	my_info;		/* Save state info*/
 IGRint				edges_out_buf_size,     /* Free space
							   for edges out
							ids*/
							
				edges_in_buf_size, 	/* Free space
							   for edge in
							ids */
							
				num_edges_in_buf_size,   /* Free space for
							   number of edges
							   in */
				num_edges_connected_buf_size; /* Free space
							 for edges connected
							  */
};

struct EMSstitch_geominfo
{
 struct IGRbsp_surface **surf_geom;
 struct IGRbsp_curve **edge_geom;
 GRrange **edgerange, **surfrange;
 GRobjid *surf_list, *edge_list;
 IGRint numsf, numed, surf_buf_size, edge_buf_size;
};

/*
 * Structure that contains information about a surface
 * that might be generally useful. The first usage of this
 * structure is in the message EMSboundary.EMbdrylocate
 */

struct EMSsfinfo
  {
  struct GRid id;
  struct IGRbsp_surface *geom;
  struct GRsymbology symb;
  IGRshort props;
  };

/* Structure that contains topology information for an edge	*/

struct EMStopinfo
  {
  GRobjid edge_id;
  OMuword class_id;
  GRobjid surf_id;
  unsigned short props;
  unsigned char curve_type;
  struct EMSdataselect edge_geom;
  GRobjid partner_edge_id;
  GRobjid partner_surf_id;
  };

/*
 * Structure that contains the edge and its replacement id
 * while transforming the topology of a given surface.
 */

struct EMSuvtrans_info
{
  GRobjid   *ed_ids, *rpl_ed_ids;
  IGRint    num_eds, eds_arrsz;

};


/* Structures with just one field defined for future growth.
*/
struct EMSlinedgedef
{
 unsigned short num_points;			/* Num pts in linedge*/
};

struct EMSnatedgedef
{
 unsigned char location;			/* location of natedge*/
};

struct EMSbsedgedef				/* bsedge info */
{
 unsigned char order;
 unsigned short num_poles;
 unsigned char bs_props;
};

union EMSfulledgedef			/* These are the kinds of edges the
					   partedge can be owning.
					*/
{
 struct EMSlinedgedef linedge;
 struct EMSnatedgedef natedge;
 struct EMSbsedgedef  bsedge;
};

enum EMSedgetype				/* Types of edges */
{
 EMSlinear, 
 EMSnatural, 
 EMSbs, 
 EMSpt, 
 EMSpart, 
 EMSdummy, 
 EMSunknown
};


struct EMSpartedgedef				/* partedge/dummy edge specific
						   info*/
{
 struct EMSedgebound edbdry[2];
 enum EMSedgetype fulled_type;
 struct GRid	  fulled_id;
 unsigned short fulled_props;
 unsigned char  fulled_curve_type;
 union EMSfulledgedef fulled; 		/* info for the specific
						   kind of full edge
						  (linear/nat/bs) */
};


union EMSedgedef			
{
 struct EMSlinedgedef 	linedge;
 struct EMSnatedgedef	natedge;
 struct EMSbsedgedef	bsedge;
 struct EMSpartedgedef	partedge;
};



struct EMSedgeinfo				/* Edge information */
{
 enum	EMSedgetype	edgetype;
 struct GRid		edgeid;
 unsigned short 	edprops;
 unsigned char 	curve_type;
 union  EMSedgedef	specinfo; 	/* Information for a specific kind
					   of edge(linear/nat/bs/pt/part/dummy)
					*/
};

struct EMmerge_info
 {
  GRobjid edge0, edge1;
  GRobjid surf0, surf1;
  GRobjid new_edge;
 };


struct EMtopology_info
{
 GRobjid edge_id;
 struct IGRpolyline *poly;
 IGRboolean boundary_poly;
 IGRboolean pygeom_sacked;
 IGRboolean u_dir;
 IGRdouble  param;
};

#endif



