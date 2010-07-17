#ifndef APndelmac_include
#define APndelmac_include
#include "APdef.h"
#include "APlabel.h"

/* extern all functions used in macro definitions below */

extern long APset_elem_checklim ();
extern long APget_elems_nodeids ();
extern long APget_node_coords ();
extern long APget_elem_centroid ();
extern long APlabel_ndel();
extern long APplace_node();
extern long APget_elem_list ();
extern long APlabel_ndel();
extern long APget_node_list ();
extern long FEplace_elem();
extern long FEreview_elem_stats();
extern long FEset_ndel_symbology();
extern long FE_merge_nodes();

/*----------------------------------------------------------------------------*/
/* Doc: fe$set_elem_check_limits

   Abstract:
	This macro will set the element warning and error check limits
	A global flag can also be set which enables/disables the element
	checks at element construct time.

   Arguments:
	double	*ar_warn	i - aspect ratio warning value

	double	*ar_err		i - aspect ratio error value

	double	*warp_warn	i - warpage warning value

	double	*warp_err	i - warpage error value

	double	*skew_warn	i - skewness warning value

	double	*skew_err	i - skewness error value

	long	*check_shape	i - global flag to enable(TRUE)
				    or disable(FALSE) shape checks
				    
   Notes:				   
	pass NULL for any argument which you do not desire to change

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

#omdef	fe$set_elem_check_limits( ar_warn = NULL, 
				  ar_err = NULL,
				  warp_warn = NULL, 
				  warp_err = NULL,
				  skew_warn = NULL, 
				  skew_err = NULL,
				  mid_warn = NULL, 
				  mid_err = NULL,
				  check_shape = NULL )

	APset_elem_checklim ( ar_warn, ar_err, warp_warn, warp_err,
			skew_warn, skew_err, mid_warn, mid_err, check_shape )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$get_elem_list

   Abstract:
	This macro will return the number of elements in the file and a
	the list of uids and/or GRids for the elements.

   Arguments:
	struct GRid	**elgrids	o - list of element objids and osnum

	long		**eluids	o - list of element user ids

	long		*elcount	o - number of elements in file
	
   Notes:
	pass NULL for either of the above lists if not needed.
	memory for these lists is allocated within the macro
	and should be freed by the calling routine

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

#omdef	fe$get_elem_list( elgrids = NULL, 
			  eluids = NULL, 
			  elcount )

	APget_elem_list ( elgrids, eluids, elcount )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$get_elem_nodeids

   Abstract:
	This macro will return the list of uids and/or GRids for all nodes
	defining an element.  Memory for the nodes should be allocated by
	the calling routine to allow for MAX_EL_PTS (APdef.h).

   Arguments:
	struct GRid	*elgrid		i - element for which node list is needed

	struct GRid	*ndgrids	o - list of node objids and osnum

	long		*nduids		o - list of node user ids

	long		*ndcount	o - number of nodes defining the element

   Notes:
	pass NULL for either of the above lists if not needed.

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
*/
/* *****************************H H H H H******************************* */

#omdef	fe$get_elem_nodeids( elgrid, 
			     ndgrids = NULL, 
			     nduids = NULL, 
			     ndcount )

	APget_elems_nodeids ( elgrid, ndgrids, nduids, ndcount )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$get_node_coords

   Abstract:
	This macro will return the xyz coordinates of a list of nodes.
	Memory for the coordinates should be allocated by the calling
	routine (3 doubles per node).

   Arguments:
	long		nnode		i - number of nodes 

	struct GRid	*ndgrids	i - array of nodes for which coords

	double		*coords		o - node coordinates

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

#omdef	fe$get_node_coords( nnode, 
			    ndgrids, 
			    coords )

	APget_node_coords ( nnode, ndgrids, coords )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$get_elem_centroid

   Abstract:
	This macro will return the xyz coordinates of the element centroid
	for a list of elements.  Memory for the centroid coordinates must
	be allocated by the calling routine to allow for 3 doubles per element.

   Arguments:
	long		numelem		i - number of elements

	struct GRid	*elgrids	i - elements for which centroid is needed

	double		*elcent		o - element centroids

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

#omdef	fe$get_elem_centroid( numelem, 
			      elgrids, 
			      elcent )

	APget_elem_centroid ( numelem, elgrids, elcent )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$label_ndel

   Abstract: 
	This macros places labels for nodes or elements.

   Arguments:
	IGRlong		type		i - NODE to Label Nodes
					    ELEM to Label  Elements
					    		
	IGRlong		data_id	 	i - DATA_UID, DATA_INTID,
					     DATA_VALUE or DATA_COORDS (see APlabel.h)
					     
	IGRlong		din		i - din to use, only used if
					     data_id is DATA_VALUE	
					     	
	IGRlong		def_shap	i - FALSE- draw on undeformed shape
					     TRUE - draw on deformed shape
					     
	AP_textparms	*text_params	i - text parameters (NULL for default)	
	
	struct GRsymbology	*sym	i - graphics symbology (NULL for active symb.)

	struct GRid	*gg_grid	o - graphics group created
	 
	struct GRid	*list_grids	i - list of grids  for group op.
	
	long		list_cnt	i - # of grids in the list	

   Return Status:
	1	-	SUCCESS

	else	-	failure
		  
   Examples:

	include "FEmacincl.h"

	main()
	{
		fe$label_ndel( );
	}	

   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	13 Oct 92	qxn,aea	creation 
*/
/*  ************************************************************************* */

#omdef fe$label_ndel(
			  type = NODE,
			  data_id = DATA_UID,
			  din = -1,
			  def_shap = FALSE,
			  text_params = NULL,
			  sym = NULL,
			  gg_grid = NULL,
			  list_grids = NULL,
			  list_cnt = -1)

	APlabel_ndel (type, data_id, din, def_shap, text_params, sym, gg_grid, list_grids, list_cnt)

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_node

   Abstract: 
   	This macro places a node with the specified or next avail (default) uid.

   Arguments:
	long	uid		i - uid to be saved in tree (in use)

	double	x,y,z		i - location

   Return Status:
	1	-	SUCCESS

	0	-	ERROR

   Examples:

   History:

        Date		Who 	Version	Why
        ---------	------	-------	---------------------------
	11/17/92	aa,ak	2.2	Creation

*/
/* *****************************H H H H H******************************* */

#omdef	fe$place_node( uid=NULL, coord )

	APplace_node( uid, coord );

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$get_node_list

   Abstract:
	This macro will return the number of nodes in the file and a
	the list of uids and/or GRids for the nodes.

   Arguments:
	struct GRid	**ndgrids	o - list of node objids and osnum

	long		**nduids	o - list of node user ids

	long		*ndcount	o - number of nodes in file
	
   Notes:
	pass NULL for either of the above lists if not needed.
	memory for these lists is allocated within the macro
	and should be freed by the calling routine

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
	1-21-93	jc	2.2	Creation

*/
/* *****************************H H H H H******************************* */

#omdef	fe$get_node_list( ndgrids = NULL, 
			  nduids = NULL, 
			  ndcount )

	APget_node_list ( ndgrids, nduids, ndcount )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_elem

   Abstract:
	This macro will create an element given the uid and uid_list of nodes.

   Arguments:
	long	uid		i - uid of the element to be created

	char	type		i - type of the element to be created
				    as defined in APdef.h

	long	*node_uids	i - list of node uids in the proper order

   Notes:

	Uid list of nodes should match with the I/FEM nodal order for the 
	respective elements.

   Return Status:
	1	-	SUCCESS

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      12/11/92  Manyam   2.2.0	Creation
      09/14/93	jc	3.0	moved from FEqkmacros.h to here

*/
/* *****************************H H H H H******************************* */

#omdef	fe$place_elem( 	uid, 
			type,
			node_uids =NULL )

	FEplace_elem( uid, type, node_uids )
#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$review_element_stats

   Abstract:
	checks the elements against aspect-ratio, warping factor, skewing 
	factor. if the uid-list is given, checking will be done for those
	elements otherwise will be done for all the elements in the model.

   Arguments:
	int	num_uids	i - num of uids ( num of elems ) in the list

	long	*uid_list	i - list of uids of elements to be checked 
				    against

   Return Status:
	1	-	SUCCESS

   Examples:

	include "FEmacincl.h"

	main()
	{	
	int sts;

	    sts = fe$review_element_stats();
	}

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      12/15/92  Manyam   2.2.0	Creation
      09/14/93	jc	3.0	moved from FEqkmacros.h to here

*/
/* *****************************H H H H H******************************* */

#omdef	fe$review_element_stats( num_uids = 0,
				   uid_list = NULL )

	FEreview_elem_stats(num_uids, uid_list );

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$set_element_symbology

   Abstract:
   	This macro sets default element symbology and active element 
	symbology global variable.

   Arguments:
	unsigned short  *color		i - new color
	
	unsigned char	*weight		i - new weight

	unsigned char	*style		i - new style

        short		*layer		i - new layer

   Return Status:
	1	-	SUCCESS

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      9 Jan 93  Manyam	2.2.0	Creation
      09/14/93	jc	3.0	moved from FEqkmacros.h to here

*/
/* *****************************H H H H H******************************* */

#omdef 	fe$set_element_symbology( color = NULL,
			      weight = NULL,
			      style = NULL,
			      layer = NULL )

	FEset_ndel_symbology( color, weight, style, layer, ELEM )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$set_node_symbology

   Abstract:
   	This macro sets default node symbology and active node 
	symbology global variable.

   Arguments:
	unsigned short  *color		i - new color
	
	unsigned char	*weight		i - new weight

	unsigned char	*style		i - new style

        short		*layer		i - new layer

   Return Status:
	1	-	SUCCESS

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      9 Jan 93  Manyam	2.2.0	Creation
      09/14/93	jc	3.0	moved from FEqkmacros.h to here

*/
/* *****************************H H H H H******************************* */

#omdef 	fe$set_node_symbology( color = NULL,
			      weight = NULL,
			      style = NULL,
			      layer = NULL )

	FEset_ndel_symbology( color, weight, style, layer, NODE )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$merge_nodes

   Abstract:
	Given a list of uids or grids of nodes, this function performs 
	merging of the nodes in the list within the specified tolerence. 
	Default node tolerence is considered if the (*nod_tol ) argument
	is NULL.

   Arguments:
	long		*uid_list	i - list of uids of nodes or NULL

	struct	GRid	*grid_list	i - list of GRids of nodesor NULL

	double		*nod_tol	i - node tolerence, pass NULL 
					   if default tol has to be considered

	int		num_nodes	i - number of nodes in the list

   Return Status:
	1	-	SUCCESS

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      12 Jan 93  Manyam	2.2.0	Creation
      09/14/93	jc	3.0	moved from FEqkmacros.h to here

*/
/* *****************************H H H H H******************************* */

#omdef 	fe$merge_nodes( uid_list=NULL ^
			grid_list = NULL,
			nod_tol = NULL,
			num_nodes = 0 )
	FE_merge_nodes( uid_list, grid_list, nod_tol, num_nodes)

#endomdef

#endif
