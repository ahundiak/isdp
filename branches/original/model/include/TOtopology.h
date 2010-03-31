#ifndef TOtopology
#define TOtopology

#include "TOstruct1.h"

/*
Definition of linked lists for the basic topology
list->header.next = list->tail -->  list is empty;
list->tail.next --> pointer to the last list element;
*/
struct TOPO_surface{				/* surface list	*/
		struct surface  *sfhead;	/* list header	*/
		struct surface  *sftail;	/* list tail	*/
		int		num_sf;		/* number of surfaces */
};		

struct TOPO_edge{			/* edge list */
		struct edge  *ehead;	/* list header */
		struct edge  *etail;	/* list tail */
		int	     num_ed;	/* number of edges */
};		

struct TOPO_point{			/* point list */
		struct point *phead;	/* list header */	
		struct point *ptail;	/* list tail */
		int	     num_pt;	/* number of points */
};		

struct TOPO_top_point{ 				/* list of topological points */
		struct top_point *tphead;	/* list header */
		struct top_point *tptail;	/* list tail */
		int	    	 num_tp;	/* number of topological 
						   points */
};		

struct TOPO_top_edge{				/* list of topological edges */
		struct top_edge *tehead;	/* list header */
		struct top_edge *tetail;	/* list tail */
		int	    	num_te;		/* number of topological
						   edges */
};			

struct memory	{				/* member of the list for
						   allcoted memory */
		struct memory *next;		/* next list element        */
		char          *p;		/* address pointer to the 
						   allocated memory part    */
		char	      *current;		/* pointer to the first free
						   element */
};
struct TOPO_memory{				/* list for memory alocation
						   control */
		struct memory *mohead;		/* list header */
		struct memory *motail;		/* list tail   */
};


/* parameter for analyze topology */

struct TOPO_param {

/* indizes for the layer,color,weight and style arrays
	outer boundary,
	violated cont,
	violated normal,
	violated rad,
	ramific
 */
#define TOPO_DO_I_OUTER	0
#define TOPO_DO_I_VCONT	1
#define TOPO_DO_I_VNORM	2
#define TOPO_DO_I_RADIU	3
#define TOPO_DO_I_RAMIF	4
/* maximum number of elements:  */
#define TOPO_DO_MAX	5
#define TOPO_MO_MAX	3

   int option;
/* analyze_topology */
#define TOPO_DO_DISPLAY_OPTION  0x001
#define TOPO_DO_GRAPHIC_PERMAN  0x001
#define TOPO_DO_POINTS  0x1000
     /* if set graphic is permanent, else it will be droped 
        when the command is deleted
     */

#define TOPO_DO_OUTER_BOUNDARY	0x002
#define TOPO_DO_VIOLATED_CONTI	0x004
#define TOPO_DO_VIOLATED_RADIU	0x008
#define TOPO_DO_VIOLATED_NORMA	0x010
#define TOPO_DO_RAMIFICATION_C	0x020

#define TOPO_DO_INTERIOR_OF_CO	0x040
/* if set interior of composite surfaces used, else not used for analyzing
*/

#define TOPO_DO_CURVATURE_DIAG  0x080

/* investigate edge match */
#define TOPO_MO_DISTANCE        0x100
#define TOPO_MO_NORMAL          0x200
#define TOPO_MO_RADIUS          0x400

#define TOPO_MO_UV              0x800


   /* analyze topology */

   /* display options */
   int layer[ TOPO_DO_MAX ];
   int color[ TOPO_DO_MAX ];
   int weight[ TOPO_DO_MAX ];
   int style[ TOPO_DO_MAX ];

   /* diagnosis parameters */
   double topology_tolerance;
   double diagnosis_distance_tolerance;
   double diagnosis_angle_tolerance;
   double diagnosis_radius_tolerance;
   int    number_of_diagnosis_points;
       
   /* investigate edge match, measure option */
   double distance;
   double normal;
   double radius;

   int    number_of_edge_match_points;
   int edge_layer[TOPO_MO_MAX];
   int edge_color[TOPO_MO_MAX];
   int edge_weight[TOPO_MO_MAX];

   char   *file_name;
   char   *header_line;
 
   /* location and value of the maximum violation for the last analysis
   */
   double max_dist_viol;
   double loc_dist_viol[3];
   double max_norm_viol;
   double loc_norm_viol[3];
   double max_radi_viol;
   double loc_radi_viol[3];


   /* action state */
   int  form_state;   /* indicates, action to do, when execute pressed */
#define FORM_STATE_NO	0	/* nothing to do(no surface selected) */
#define FORM_STATE_AA	'A'	/* Analyze adjacency */
#define FORM_STATE_IE	'I'	/* Investigate edge match */
#define FORM_STATE_DT	'D'	/* Delete basic topology  */
#define FORM_STATE_MM	'M'	/* M for extension        */

   /* storage for:
   ** referenced_object: objid of the command object
   ** displayed_objec:   objid of the group object, which contains
   **                    all temporary objects
   */
   struct Ext_data_tmp *temporary_objects;
   struct Ext_data_tmp *temporary_points;
};

struct TOPO_free_list {
       struct surface   *free_surface   ;
       struct edge      *free_edge      ;
       struct point     *free_point     ;
       struct top_point *free_top_point ;
       struct top_edge  *free_top_edge  ;

       struct elist   *free_elist   ;
       struct plist   *free_plist   ;
       struct telist  *free_telist  ;
};

struct topology {
		struct TOPO_surface	sf;
		struct TOPO_edge 	ed;
		struct TOPO_point	pt;
		struct TOPO_top_point	tp;
		struct TOPO_top_edge	te;
		struct TOPO_memory	mo;
                struct TOPO_param       pa;
                struct TOPO_free_list   fl;
};

#endif
