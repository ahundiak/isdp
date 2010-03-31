
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef ve_include
#define ve_include 1

/*
DESCRIPTION
	Structure definitions used by Vector Hidden Line

HISTORY
	S.P. Rogers    01/11/87  Creation Date
	S.P. Rogers    05/11/87  Changed prefixes to VE
	S.P. Rogers    08/17/87  Changed edge header, removed parm nodes and
		                 added visibility nodes and temp nodes.
	S.P. Rogers    11/28/88  Added global structure definitions.
*/

#include "igetypedef.h"
#include "bsgeom_cvsf.h"
#include "ex.h"
#include "igrdp.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpb.h"

/* plane structure */
struct VEplane
	{
	IGRdouble point[3];
	IGRdouble normal[3];
	};
   
/* linked list of environment matrices */
struct VEenv_info
	{
	IGRmatrix            matrix;            /* environment matrix                     */
	IGRdouble            to_world_scale;    /* scale factor from environment to world */
	struct VEenv_info    *next;             /* pointer to entry in list               */
	IGRint               osnum;             /* object space number of attachment      */
	IGRint               layers[32];        /* environment layer mask                 */
	IGRint               num_surfs;         /* number of surfaces in environment      */
	IGRint               num_curves;        /* number of curves in environment        */
	IGRshort             matrix_type;       /* environment matrix type                */
	IGRshort             attach_id;         /* unique id of attachement using matrix  */
	IGRshort             flags;             /* flags word                             */
	struct VEplane       clip_planes[6];    /* clipping planes for attachment         */
	struct GRhesym       ref_symb;          /* override symbology for reference file  */
	struct GRmd_env      md_env;            /* module environment                     */	
	struct GRid          ref_plane;         /* reference plane id for environment     */
	};
	
/* sorting structure */
struct VEsort_record
	{
	IGRdouble              range[6];        /* transformed range of element           */
	struct VEenv_info      *env;            /* pointer to environment information     */
 	struct VEsort_record   *left;           /* pointer to left descendant             */
	struct VEsort_record   *right;          /* pointer to right descendant            */
	IGRint                 objid;           /* object id                              */
	IGRint                 parent_id;       /* parent object id                       */
	IGRshort               type;            /* element type                           */
	IGRshort               flags;           /* flags word                             */
	};

/******************************************************************************************/

/* The linked-list structures that are managed in pools by Visible Edges must have their  */
/* "next" pointer as the first field in the structure.  This is done because one routine  */
/* manages the allocation/freeing of all of these structures and it must be able to link  */
/* the structures that are not being used into a free list.  See the documentation in the */
/* memory management routines for more details.                                           */

/* shared edge id list nodes */
struct VEid_list
	{
	struct VEid_list *next;                 /* pointer to next list element           */
	IGRlong          objid;                 /* object id of shared edge               */
	IGRshort         attach_id;             /* attachement id of shared edge          */
	};
	

/* visibility node structure */
struct VEvisib_node
	{
	struct VEvisib_node       *next;        /* pointer to next node                   */
	IGRshort                  visib;        /* visibility for span from this node     */
	                                        /* to the next one in the list            */
	IGRdouble                 u;            /* u value of visiblity change            */
	};

/* temporary node structure */
struct VEtemp_node
	{
	struct VEtemp_node        *next;        /* pointer to next node                   */
	IGRchar                   prev_visib;   /* visibility of previous span            */
	IGRchar                   next_visib;   /* visibility of next span                */
	IGRshort                  status;       /* status field                           */
	IGRdouble                 u;            /* u value of temporary node              */
	};
	

/* point projection node structure */
struct VEpt_proj_node
	{
	struct VEpt_proj_node     *next;        /* pointer to next node	                  */
	struct VEtemp_node        *temp_node;   /* point to temp-node that starts span    */
	union
	   {
	   IGRdouble              pt[3];        /* XYZ of projection point                */
	   struct
	      {
	      struct VEelement_header *elem;
	      struct VEedge_header    *edge;
	      } ptrs;                           /* new edge indicator                     */
	   } variants;
	};


/* edge header structure */
struct VEedge_header 
	{
	struct VEedge_header      *next;            /* pointer to next edge                     */
	struct BSgeom_bsp_curve   *gm_curve3d;      /* pointer to 3D geometric curve definition */
	struct BSgeom_bsp_curve   *gm_curve2d;      /* pointer to 2D geometric curve definition */
	struct BSgeom_bsp_curve   *stroked_gmcurve; /* pointer to stroked curve definition      */
	IGRdouble                 range[6];         /* transformed range of edge                */
	IGRdouble                 iso_parm;         /* constant parameter if iso-curve          */
	IGRdouble                 *sh_spans;        /* array of self-hidden spans               */
	struct VEvisib_node       *visib_list;      /* list of visibility changes               */
	struct VEtemp_node        *temp_list;       /* list of possible visibility changes      */
	struct VEedge_header      *shared_edge;     /* pointer to corresponding shared edge     */
	struct VEelement_header   *shared_elem;     /* pointer to shared edge's element         */
	IGRint                    num_sh_spans;     /* number of self-hidden spans              */
	IGRint                    edge_id;          /* object id of edge                        */
	IGRint                    saved_cvcv_id;    /* id used for saving cv/cv intersections   */
	IGRint                    status;           /* edge's overlap/self-hidden status        */
 	IGRshort                  type;             /* type of the edge                         */
	};

/* header record for an element */
struct VEelement_header
	{
	struct VEelement_header   *next;          /* pointer to next element in active list */
	struct VEelement_header   *next_in_solid; /* pointer to next surface in solid       */
	struct VEedge_header      *edges;         /* pointer to edge list                   */
	struct VEenv_info         *env;           /* pointer to environment information     */

	union
	   {
	   struct IGRbsp_curve    *curve;         /* pointer to element geometry            */
	   struct BSgeom_bsp_surf *gmsurf;
	   } geom;

	IGRdouble                 range[6];       /* transformed range                      */
	IGRdouble                 u_range[2];     /* u range of active surface              */
	IGRdouble                 v_range[2];     /* v range of active surface              */
	IGRint                    objid;          /* object id                              */
	IGRint                    parent_id;      /* object id of parent                    */
	IGRint                    loopset_id;     /* object id of the element's loopset     */
	IGRshort                  type;           /* element type                           */
	IGRshort                  flags;          /* flags word for element                 */
	};

/******************************************************************************************/

/* saved intersection data structure */
struct VEsaved_int_node
	{
	struct VEsaved_int_node *next;         /* pointer to next saved int node          */
	IGRdouble               *buffer;       /* pointer to buffer containing int. data  */
	IGRint                  id0;           /* id of the first edge                    */
	IGRint                  id1;           /* id of the second edge                   */
	IGRshort                num_int;       /* number of ints. between the edges       */
	IGRshort                num_over;      /* number of overlaps between the edges    */
	IGRshort                buffer_size;   /* size of the buffer in doubles           */
	IGRshort                ints_left;     /* number of ints. left to be re-used      */
	};

/* global data for VE results */
struct VEresults_info
	{
	struct GRhesym    visible_symb;                     /* symbology for visible edges               */
	struct GRhesym    hidden_symb;                      /* symbology for hidden edges                */
	unsigned short    visible_level;                    /* visible results level                     */
	unsigned short    hidden_level;                     /* hidden results level                      */
	unsigned short    text_level;                       /* text results level                        */
	IGRboolean        output_hidden;                    /* TRUE, if outputting hidden edges          */
	IGRboolean        output_2d;                        /* TRUE, if 2d output                        */
	IGRboolean        output_curves;                    /* TRUE, if outputting curves                */
	IGRboolean        copy_text;                        /* TRUE, if copying text                     */
	IGRboolean        output_solid_self_hidden_edges;   /* TRUE, output self hidden curves of solids */
	IGRboolean        delete_overrides;                 /* TRUE, delete overrides if running CHS     */
	};


/* structure that contains the global tolerance information */
struct VEtolerance_info
	{
	IGRdouble VEsystem_base_tol;           /* system basis tol when VE was started    */
	IGRdouble VEscaled_base_tol;           /* scaled basis tol used by VE             */
	IGRdouble VEsystem_cht;                /* system CHT when VE was started          */
	IGRdouble VEscaled_cht;                /* scaled CHT used by VE                   */
	IGRdouble VEscaled_trace_tol;          /* scaled tracing tolerance used by VE     */
	};
	

/* structure containing the global execution parameters */
struct VEexecution_parms
	{
	IGRdouble  VEgapping_distance;         /* model space gaping distance             */
	IGRint     VEsurf_threshold;           /* min. num of poles to start reducing     */
	IGRint     VEcurve_threshold;          /* min. numboer of poles to start reducing */
	IGRboolean VEprocessing_wireframe;     /* TRUE, if processing wireframe elements  */
	IGRboolean VEhiding;                   /* TRUE, if running GVE                    */
	IGRboolean VEtracing;                  /* TRUE, if tracing                        */
	IGRboolean VEcopying;                  /* TRUE, if running GPE without trace      */
	IGRboolean VEbatch;                    /* TRUE, if running in batch mode          */
	IGRboolean VEdata_reduction;           /* TRUE, if reduction is activated         */
	IGRboolean VEgapping;                  /* TRUE, if gapping hidden lines           */
	IGRboolean VEturn_ref_files_off;       /* TRUE, if turning reference files off    */
	IGRboolean VEprocess_tangent_edges;    /* TRUE, if processing tangent edges       */
	IGRshort   displayed_layer;            /* layer for displayed elems in batch      */
	IGRshort   non_displayed_layer;        /* layer for non-displayed elems in batch  */
	};
	

/* structure containing the global execution status */
struct VEexecution_status
	{
	IGRdouble       VEabort_xmin;          /* XMIN of last element before abort                 */
	IGRint          VEtotal_elems;         /* total number of processable elements              */
	IGRint          VEfinished_elems;      /* total number of finished elements                 */
	IGRint          VEactivated_elems;     /* total number of activated elements                */
	IGRint          VEunique_edge_id;      /* counter used to generate unique ids               */
	unsigned int    VEnext_saved_cvcv_id;  /* counter for assigning ids for saved ints          */
	IGRshort        VEattach_count;        /* number of different attachment envs.              */ 
	IGRboolean      VEprev_output_found;   /* TRUE, if previous VE output was located           */
	IGRboolean      VEupdate_window;       /* TRUE, if window should be updated                 */
	IGRboolean      VEabort;               /* TRUE, if VE should abort processing               */
	IGRboolean      VEint_save_denied;     /* TRUE, if an intersection wasn't saved             */
	IGRboolean      VEtouched_center_line; /* TRUE, if element crossed window center            */
	IGRboolean      VEread_only_found;     /* TRUE, if objects from a read-only file were found */
	IGRboolean      VEsymbol_found;        /* TRUE, if a symbol object was found                */
	};


/* structure containing the global window data */
struct VEwindow_info
	{
	struct GRid	VEwin_grid;            /* window id                               */
	IGRdouble       clip_range[6];         /* clipping range for window               */
	IGRdouble       VEy_middle;            /* Middle Y of window in viewing coords    */
	IGRdouble       VEt_matrix[4][4];      /* transformation matrix                   */
	IGRdouble       VEview_vector[3];      /* view vector in world coordinates        */
	IGRint          VEmaster_layers[32];   /* layer mask for the window               */
	IGRdouble	VErot_matrix[4][4];    /* rotation matrix                         */
	};

#endif
