class specification APnode(1:0) of APndel, GA3dpoint;

#include "igrtypedef.h"
#include "igr.h"
#include "APpardef.h"
#include "APlabel.h"

/****************************************************************************

   revision log:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      5/30/91	bwh	2.0.1	Changed class from FEmsnod to APnode
				for 2.0.1.  Also changed parent from
				GR3dxpoint to GR3dpoint.
      7/10/91	msl	2.0.1	Subclass from APndel
      9/05/91	bwh	2.0.0	moved intid instance data up to APndel
				changed parent from GR3dpoint to
				GA3dpoint to allow node to be assoc
				parent of map edges
      11/19/91	bwh	2.0.0	argument changes to init method
				and get_coord method
      12-03-91	kk	2.0.0	Added are_you_connected message
      12-12-91  smt	2.0.0	Added update_node_display message
      05-06-92	smt	2.0.1	Changed mask from short to long in
				update_node_display method.
      07-13-92	Manyam	2.0.0	Added cvrt_wakeup message
      10-13-92  qn,aa   2.2.0	Added label_node message
      12-09-93  ret     3       inherit GRcopy from GRgraphics to bypass
				GAcurve.GRcopy which causes problems 
 ****************************************************************************/

channel to_elem {(initial=4,increment=4) APelem.to_node;};
channel to_mesh {( many_to_one ) APmesh.to_node;};

instance APnode
    {
	IGRdouble	uv[2];
	channel to_elem	to_elem;	
	channel to_mesh	to_mesh;
    };

override debug, GRdelete, GRgetobjinfo, GRxform,
		/*, GRcopy,*/ GRcptform;
override NDupdate,/* ignore update */
	 NDget_objects, /* get elements as children */
	 NDcopy_graph, /* handle associative copy */
	 NDconnect_graph; /* ignore */

from GRgraphics inherit GRcopy;

message init
    (
	IGRlong		*msg;		/* o - Return status            */
	IGRlong		type;		/* i - Node type in APdef.h     */
	IGRdouble	uv[2];		/* i - uv coordinates           */
	IGRdouble	coord[3];	/* i - coordinates of node	*/
	IGRlong		uid;		/* i - uid of node
						NO_UID - do not assign uid
						DEFAULT_UID - get next uid
						>0 assign this uid 	*/
	OM_S_OBJID	mesh;		/* i - Mesh to connect to	*/
	long		options;	/* i - init options in APdef.h	*/
    );

/*
 ----------------------------- upd_mesh_if_orphan -------------------------
 *
 *  Abstract:
 *	This message is to be sent to the nodes by an element which is being
 *	created.  If the node's parent (mesh) is the orphnode, the node
 *	should connect to the element's mesh parent passed in.
 *	If the node's parent is another mesh, the parent is not changed.
 */

message upd_mesh_if_orphan
    (
	long			*msg;	/* i/o - return status		    */
	OM_S_OBJID		mesh;	/* i - parent mesh                  */
    );

/*
 ----------------------------- orphan_check ----------------------------------
 *
 *	If the node is connected to num_elem elements, the node will
 *	become an orphan (no elements), and is to be connected to the
 *	orphnode object.  Using this method will not force a node to be
 *	connected to the same mesh as elements to which the node is connected.
 */

message orphan_check
    (
	IGRlong			*msg;	/* i/o - return status		    */
	IGRlong			num_elem;/* i  - Move to orphnode if num_elem
						is >= num of connected elem */
    );

/* 
 * This message is sent to the node when the node's automesh parent
 * is being deleted.  This allows the node to move to the orphan mesh
 * or any mapped mesh before the node will be deleted in the case it is
 * connected to a singly placed or mapped mesh element.
*/
message leave_automesh_parent();

/*
 ---------------------------- quick_set_node_uv -----------------------
 *
 * This method sets the uv coordinates of the node by simply projecting
 * the node coordinates to the surface.  NOTE:  this will not give correct
 * uv values in the case of seam edges and their vertices.
*/

message quick_set_node_uv
    (
	struct IGRbsp_surface	*surfgeom;	/*  i - geom to eval on   */
    );

message get_coord
    (
	IGRlong      *msg;                   /* o - Return status            */
	IGRdouble    coord[3];               /* o - Coordinates              */
    );

/*
 ----------------------------- coord_bus -----------------------------------
 *
 *  This method gets the xyz coordinates of nodes from instance data.
 */

message coord_bus
    (
	IGRlong		*msg;       /*  o - Return status             */
	IGRint		max;        /*  i - Max number of points      */
	IGRint		*num;       /*  i/o- Points in coord array    */
	IGRdouble	coord[][3]; /*  o - Node coordinates          */
    );

/*
 This method loads the x,y,z and uv coordinates of the node which have
 been prestored in the node instance data.  It is used
 for quick coordinate access by the mesher.
*/
message get_uvxyz
    (
      double                    pos[5];	/* u,v,x,y,z for node */
    );

/*
 *----------------------------- update_node_pos ---------------------------
 *
 * This method updates the uv instance data and the point instance data.
 * The node will be re-displayed at the new location, but should be
 * erased before sending this message.
*/

message update_node_pos
    (
      long              *msg;           /* o - Return status            */
      double            uv[2];          /* i - new uv position          */
      double            pnt[3];         /* i - new pnt coord            */
      IGRboolean	*display;	/* i - 0 if no display		*/
    );

message	is_orphan (
	char		*any_orphan;	/* o - If any node is orphan
						initialize to FALSE	*/
	char		*all_orphan;	/* o - If all nodes are orphan
						initialize to TRUE	*/
	) ;

message	on_off (
	IGRshort		action;	/* i - 1: ON,  0: OFF		*/
	);

message	are_you_connected (
	long		*msg;		/* o - return status		*/
	long		*connected;	/* o - TRUE/FALSE		*/
	struct GRid	el_grids[];	/* i - if NULL : *connected = TRUE */
	long		num_els;	/* i - Number of elem in el_grids*/
	);

/*
   This method updates the display attributes for a node
*/
message update_node_display
    (
        IGRlong		*msg;		/*i/o- return status		*/
      	struct APnd_par	*nd_par;    	/* i - node parameter structure	*/ 
      	long		mask;		/* i - bit mask for display attributes */
     );

/*
 * This message checks if the node is within a given tolerance of a point
*/
message node_tol_search (
	long		*msg;		/* o - return status		*/
	double		pnt[3];		/* i - coord of node to be placed */
	double		tol;		/* i - distance from pnt (tolerance) */
	double		*mindist;	/* io- smallest dist so far */
	OM_S_OBJID	merge_node;     /* i - merge node if any - typically
					       a node at coords passed in (pnt) */
	OM_S_OBJID	*node_found;	/* o - node within tolerance	*/
	);

/*
 * delete a node which is not connected to any elements
*/
message delete_if_orphan( );

/*
 * connect the node to a set if it is within tolerance of a located object
*/
message tol_group_connect(
	long		*msg;		/* o - return status		*/
	double		tolerance;	/* i - tolerance for checking	*/
	struct GRid	located_id;	/* i - object to check for tolerance */
	struct GRid	sv_id;		/* i - the group/set to connect to */
	);

message APcptform
      (
     IGRlong		*msg;      /* o- completion code			*/
     struct GRmd_env	*md_env;   /* i - original object's context info	*/
     IGRmatrix		matrix;    /* i - transform. matrix to be applied to copy*/
     struct GRmd_env	*new_env;  /* i - copied object's context info		*/
     struct GRid 	mesh;	   /* i - the mesh the node connects to 	*/
     OM_S_OBJID		*newobjid; /* o - object id of copy			*/
      );

/*
 * This message is used to convert 1.4 file to 2.0.
*/

message cvrt_wakeup();

message label_node (
	IGRlong		*msg;		/* o - return message		*/
	IGRlong		data_id;	/* i - UID, COORDS, VALUE etc	*/
	IGRlong		din;		/* i - din (if label by VALUE)	*/
	IGRlong		shap;		/* i - 0 - draw on undeformed shape
					       1 - draw on deformed shape*/
	AP_textparms	*text_params;	/* i - text parameters		*/
	struct GRsymbology *sym;	/* i - symbology parameters	*/
	IGRmatrix	rot_matrix;	/* i - rotation matrix		*/
	struct GRid	*gg_grid;	/* i - graphic group grid	*/
	);

end specification APnode;
