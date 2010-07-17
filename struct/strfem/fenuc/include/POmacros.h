#ifndef POmacros_included
#define POmacros_included

#include "APdef.h"
#include "POdef.h"
#include "POstruct.h"
#include "POextgrid.h"

/*************************************************************************

   Doc: POmacros.h

   Abstract: This file contains definitions of all post-processing macros.
      The macro name convention is: 'fe$' plus the command string with
      under-bar '_' between words. The macro name uses all lower cases. 

      Example, the macro corresponding to the command "Place Line Contours" is 
      			fe$place_line_contours.


   History:

	Date		Who	Why
	---------	---	--------------------------------------------
	???		???	pre-history creation
	1992		qxn	addition, activation, and test of all macros
	Dec 15 92	qxn	straighten up macro name convention
	
******************************H H H H H******************************* */
/* Doc: fe$place_line_contours

   Abstract: 
	This macro places a line contour plot of the model.
	
   Arguments:
	long		id 		i - Node data id number	OR

	char		*data_name	i - Name of this din

	int		num__cont_lines i - the number of contour lines requested

	IGRboolean	deformed_shape  i - TRUE - place contour on deforemd shape
					    FALSE- place contour on original shape
					    
	double		*max		i - max. value of contour data

	double		*min		i - min. value of contour data
			    
	POplgr_data	*pg		i - Place Graphics parameters  
					    = NULL for default parameters.    

	POsec_info	*section_info	i - cutting surface. default NULL	

	struct GRid	*gg_grid	o - grid of graphic group created  

	struct GRid	*list_grids	i - list of element grids to contour with 	

	long		list_cnt	i - # of grids in the list ( -1: process all ) 	

   Return Status: 
	1	-	SUCCESS

	else	-	failure

   Notes: 
	1. When pg is not specified (pg is set to NULL as default), The
	parameters ( layer, legend on/off, exposed face/all face ... ) for contour 
	graphics are set to those that were defined when the interactive command
	was last executed. If there is no interactive execution of the command before
	this macro, a full set of defaults is assumed (as shown in the Postprocessing
	setup form when the command is first executed).
	
	2. Any arguments specified in this macro will override the default setting. But
	will not be saved as default for the next call.
	
   Examples:

#include "FEmacincl.h"

main()
{	fe$place_line_contours(  data_name = "LC1:SXXTOP",
				 num_cont_lines = 48 );

	fe$place_line_contours(  id = 1, deformed_shape = TRUE );
}	

   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	23 Aug 92	qxn	creation 
*/
/*  ************************************************************************* */
extern POmacro_contours();
#omdef fe$place_line_contours(
			  data_name^
			  id,
			  num_cont_lines = 24,
			  deformed_shape = FALSE,
			  max = NULL,
			  min = NULL,
			  pg = NULL,
			  section_info = NULL,
			  gg_grid = NULL,
			  list_grids = NULL,
			  list_cnt = -1)

#if om$specified( data_name )
	POmacro_contours( -1, data_name, num_cont_lines, deformed_shape, FALSE, max, min,
	pg, section_info, gg_grid, list_grids, list_cnt)
#elif om$specified( id )  
	POmacro_contours(id, NULL, num_cont_lines, deformed_shape, FALSE, max, min,
	pg, section_info, gg_grid, list_grids, list_cnt)
#endif

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_filled_contours

   Abstract: 
	This macros places a filled contour plot of the model.

   Arguments:
	long		id 		i - Node data id number	OR

	char		*data_name	i - Name of this din

	IGRboolean	deformed_shape  i - TRUE - place contour on deforemd shape
					    FALSE- place contour on original shape
					    
	double		*max		i - max. value of contour data

	double		*min		i - min. value of contour data
			    
	POplgr_data	*pg		i - Place Graphics parameters  
					    = NULL for default parameters.    

	POsec_info	*section_info	i - cutting surface. default NULL	

	struct GRid	*gg_grid	o - grid of graphic group created
	  
	struct GRid	*list_grids	i - list of element grids to contour with 	

	long		list_cnt	i - # of grids in the list ( -1: process all ) 	

   Return Status:
	1	-	SUCCESS

	else	-	failure

   Notes: 
	1. When pg is not specified (pg is set to NULL as default), The
	parameters ( layer, legend on/off, exposed face/all face ... ) for contour 
	graphics are set to those that were defined when the interactive command
	was last executed. If there is no interactive execution of the command before
	this macro, a full set of defaults is assumed (as shown in the Postprocessing
	setup form when the command is first executed).
	
	2. Any arguments specified in this macro will override the default setting. But
	will not be saved as default for the next call.

   Examples:

#include "FEmacincl.h"

main()
{
	fe$place_filled_contours(  data_name = "LC1:SXXTOP" );
}	

   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	23 Aug 92	qxn	creation 
*/
/*  ************************************************************************* */
extern POmacro_contours();
#omdef fe$place_filled_contours(
			  data_name^
			  id,
			  deformed_shape = FALSE,
			  max = NULL,
			  min = NULL,
			  pg = NULL,
			  section_info = NULL,
			  gg_grid = NULL,
			  list_grids = NULL,
			  list_cnt = -1)

#if om$specified( data_name )
	POmacro_contours( -1, data_name, 0, deformed_shape, TRUE, max, min, pg,
	section_info, gg_grid, list_grids, list_cnt)
#elif om$specified( id )  
	POmacro_contours(id, NULL, 0, deformed_shape, TRUE, max, min, pg,
	section_info, gg_grid, list_grids, list_cnt)
#endif

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_deformed_shape

   Abstract:
	This macro places a deformed shape of the model.

   Arguments:
	long		*ids 		i - list of 3 Node data id numbers (x,y,z) OR

	char		*data_names[3]	i - data Names for (x,y,z)

	double		exagg_factor	i - exaggeration factor

	IGRboolean	shaded  	i - TRUE - place shadeable deforemd shape
					    FALSE- place non-shadeable deformed shape

	POplgr_data	*pg		i - Place Graphics parameters  
					    = NULL for default parameters.    

	struct GRid	*list_grids	i - list of element grids to process	

	long		list_cnt	i - # of grids in the list ( -1: process all ) 	

	struct GRid	*gg_grid	o - grid of graphic group created  

   Return Status:
	1	-	SUCCESS

   Notes: 
	1. When pg is not specified (pg is set to NULL as default), The
	parameters ( layer, exposed face/all face ... ) for deformed shape 
	graphics are set to those that were defined when the interactive command
	was last executed. If there is no interactive execution of the command before
	this macro, a full set of defaults is assumed (as shown in the Postprocessing
	setup form when the command is first executed).
	
	2. Any arguments specified in this macro will override the default setting. But
	will not be saved as default for the next call.

   Examples:

#include "FEmacincl.h"

main()
{
int	msg;
char	dx[80], dy[80], dz[80], *ptr[3];

	strcpy(dx, "LC1:DX");
	strcpy(dy, "LC1:DY");
	strcpy(dz, "LC1:DZ");
	ptr[0] = dx;
	ptr[1] = dy;
	ptr[2] = dz;
  	fe$place_deformed_shape ( data_names = ptr,
   				  exagg_factor = 0.1 );
}

   History:

     	Date		Who	Why
      	---------	------	---------------------------
	02 OCT 92	qxn	2.1 creation 

*/
/* *****************************H H H H H******************************* */

extern int POdeform();

#omdef fe$place_deformed_shape( data_names^
				ids,
				exagg_factor = 1.0,
				shaded = FALSE,
				list_grids = NULL,
				list_cnt = -1,
				pg = NULL,
				gg_grid = NULL)

#if om$specified( ids )
	POdeform( ids, NULL, exagg_factor, shaded, pg, gg_grid, list_grids, list_cnt)
#elif om$specified( data_names )  
	POdeform(NULL, data_names, exagg_factor, shaded, pg, gg_grid, list_grids, list_cnt)
#endif

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_node_vectors

   Abstract: 
	This macros places a vector plot of the model at nodes.

   Arguments:

	long		*ids 		i - list of 3 data id numbers (x,y,z) OR

	char		*data_names[3]	i - data Names for (x,y,z)

	double		*max		i - max. value of data

	double		*min		i - min. value of data

	double		exagg_factor	i - exaggeration factor

	POplgr_data	*pg		i - Place Graphics parameters

	struct GRid	*gg_grid	o - grid of graphic group created

	struct GRid	*list_grids	i - list of element grids to process 	

	long		list_cnt	i - # of grids in the list ( -1: process all ) 	


   Return Status:
	1	-	SUCCESS

	else	-	failure

   Notes: 
	1. When pg is not specified (pg is set to NULL as default), The
	parameters ( layer, exposed face/all face ... ) for vector 
	graphics are set to those that were defined when the interactive command
	was last executed. If there is no interactive execution of the command before
	this macro, a full set of defaults is assumed (as shown in the Postprocessing
	setup form when the command is first executed).
	
	2. Any arguments specified in this macro will override the default setting. But
	will not be saved as default for the next call.

   Examples:

#include "FEmacincl.h"

main()
{

int	msg;
char	dx[80], dy[80], dz[80], *ptr[3];

	strcpy(dx, "LC1:DX");
	strcpy(dy, "LC1:DY");
	strcpy(dz, "LC1:DZ");
	ptr[0] = dx;
	ptr[1] = dy;
	ptr[2] = dz;
  	fe$place_node_vectors ( data_names = ptr,
   				  exagg_factor = 0.1 );
}

   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	10 Apr 91	msl	Creation
	06 Oct 92	qxn	rewrite and test

*/
/*  ************************************************************************* */

extern int POdisplay_vectors();

#omdef fe$place_node_vectors( data_names^
			 ids,
			 exagg_factor = 1.0,
			 max = NULL,
			 min = NULL,
			 pg = NULL,
			 gg_grid = NULL,
			 list_grids = NULL,
			 list_cnt = -1
			  )

#if om$specified( ids )
	POdisplay_vectors( ids, NULL, exagg_factor, 1, max, min, pg, gg_grid, list_grids, list_cnt)
#elif om$specified( data_names )  
	POdisplay_vectors( NULL, data_names, exagg_factor, 1, max, min, pg, gg_grid, list_grids, list_cnt)
#endif

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_element_vectors

   Abstract: 
	This macros places a vector plot of the model at element centroids.

   Arguments:

	long		*ids 		i - list of 3 data id numbers (x,y,z) OR

	char		*data_names[3]	i - data Names for (x,y,z)

	double		*max		i - max. value of data

	double		*min		i - min. value of data

	double		exagg_factor	i - exaggeration factor

	POplgr_data	*pg		i - Place Graphics parameters

	struct GRid	*gg_grid	o - grid of graphic group created

	struct GRid	*list_grids	i - list of element grids to process 	

	long		list_cnt	i - # of grids in the list ( -1: process all ) 	


   Return Status:
	1	-	SUCCESS

	else	-	failure

   Notes: 
	1. When pg is not specified (pg is set to NULL as default), The
	parameters ( layer, exposed face/all face ... ) for vector 
	graphics are set to those that were defined when the interactive command
	was last executed. If there is no interactive execution of the command before
	this macro, a full set of defaults is assumed (as shown in the Postprocessing
	setup form when the command is first executed).
	
	2. Any arguments specified in this macro will override the default setting. But
	will not be saved as default for the next call.

   Examples:

#include "FEmacincl.h"

main()
{
int	msg;
char	dx[80], dy[80], dz[80], *ptr[3];

	strcpy(dx, "LC1:SXXTOP");
	strcpy(dy, "LC1:SYYTOP");
	strcpy(dz, "LC1:SXYTOP");
	ptr[0] = dx;
	ptr[1] = dy;
	ptr[2] = dz;
  	fe$place_element_vectors ( data_names = ptr,
   				  exagg_factor = 0.1 );
}

   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	10 Apr 91	msl	Creation
	06 Oct 92	qxn	rewrite and test

*/
/*  ************************************************************************* */

extern int POdisplay_vectors();

#omdef fe$place_element_vectors( data_names^
			 ids,
			 exagg_factor = 1.0,
			 max = NULL,
			 min = NULL,
			 pg = NULL,
			 gg_grid = NULL,
			 list_grids = NULL,
			 list_cnt = -1
			  )

#if om$specified( ids )
	POdisplay_vectors( ids, NULL, exagg_factor, 0, max, min, pg, gg_grid, list_grids, list_cnt)
#elif om$specified( data_names )  
	POdisplay_vectors( NULL, data_names, exagg_factor, 0, max, min, pg, gg_grid, list_grids, list_cnt)
#endif

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$place_color_coded_elements

   Abstract: 
	This macros places a color coded element plot of the model.

   Arguments:
	long		id 		i - Node data id number	OR

	char		*data_name	i - Name of this din

	IGRboolean	shaded  	i - TRUE - place shadeable color coded elements
					    FALSE- place non-shadeable color coded elements

	double		shrink_factor	i - element shrink factor
	
	IGRboolean	deformed_shape  i - TRUE - place contour on deforemd shape
					    FALSE- place contour on original shape
					    
	double		*max		i - max. value of color code data

	double		*min		i - min. value of color code  data
			    
	POplgr_data	*pg		i - Place Graphics parameters  
					    = NULL for default parameters.    

	struct GRid	*gg_grid	o - grid of graphic group created  

	struct GRid	*list_grids	i - list of element grids to contour with 	

	long		list_cnt	i - # of grids in the list ( -1: process all ) 	

   Return Status:
	1	-	SUCCESS
   
	else	-	failure

   Notes: 
   
	1. When pg is not specified (pg is set to NULL as default), The
	parameters ( layer, legend on/off, exposed face/all face ... ) for color coded 
	graphics are set to those that were defined when the interactive command
	was last executed. If there is no interactive execution of the command before
	this macro, a full set of defaults is assumed (as shown in the Postprocessing
	setup form when the command is first executed).
	
	2. Any arguments specified in this macro will override the default setting. But
	will not be saved as default for the next call.
	
   Examples:

#include "FEmacincl.h"

main()
{
	fe$place_color_coded_elements(data_name = "LC1:SXXTOP", 
			shrink_factor = 1.0, deformed_shape = TRUE);
}	

   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	23 Aug 92	qxn	creation 
*/
/*  ************************************************************************* */
extern POcolor_mesh();
#omdef fe$place_color_coded_elements(
			  data_name^
			  id,
			  shaded = TRUE,
			  shrink_factor = 0.75,
			  deformed_shape = FALSE,
			  max = NULL,
			  min = NULL,
			  pg = NULL,
			  gg_grid = NULL,
			  list_grids = NULL,
			  list_cnt = -1)

#if om$specified( data_name )
	POcolor_mesh( -1, data_name, shaded, shrink_factor, deformed_shape, max, min, pg,
	gg_grid, list_grids, list_cnt)
#elif om$specified( id )  
	POcolor_mesh(id, NULL,shaded, shrink_factor, deformed_shape, max, min, pg,
	gg_grid, list_grids, list_cnt)
#endif

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$retrieve_results

   Abstract: 
	This macro loads a Generic Results file onto the current FEM model.

   Arguments:
	long		*msg		o - return message 
					( 1: success, 0: error encountered during loading)

	char		*result_name	i - name of the result set to be loaded
					    if not specified, the default name will
					    be "RS_k" where k is a sequential number
					    that distinguishes this result set from
					    others.

	char		*result_desc	i - result descriptor (default to NULL)

	char		*file_name	i - result file name
	
	char		*neu_file	i - neutral file name. Default is NULL.
					    If specified, it is loaded as archive.

   Return Status:
	1	-	SUCCESS

   Examples:
   
#include "FEmacincl.h"

main()
{
	fe$retrieve_results( msg= &msg,
			     file_name = "rs1.g" )
}
			     
   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	18 Aug 92	qxn	Creation
	23 Jan 93	raju	Added neu_file option

*/
/*  ************************************************************************* */

extern int POret_results();

#omdef fe$retrieve_results(  msg,
			     result_name = NULL,
			     result_desc = NULL,
			     file_name,
			     neu_file	 = NULL )

	POret_results(msg, result_name, result_desc, file_name, neu_file)

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$create_generic_results

   Abstract: 
	This macro creates a Generic Results file from the current FEM model.

   Arguments:

	char		*file_name	i - result file name

	struct GRid	*list_grids	i - list of element grids to process 	

	long		list_cnt	i - # of grids in the list ( -1: process all ) 	

   Return Status:
	1	-	SUCCESS

	0	-	failure
	
   Examples:
   
#include "FEmacincl.h"

main()
{
	fe$create_generic_results(file_name = "rs1.g" )
}
			     
   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	18 Aug 92	qxn	Creation

*/
/*  ************************************************************************* */

extern int POwrite_genres();

#omdef fe$create_generic_results( file_name,
			     list_grids = NULL,
			     list_cnt = -1 )

	POwrite_genres(file_name, list_grids, list_cnt)

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$create_loadcase_combinations

   Abstract: 
	This macro creates a new data by combining different load case data according
	to the load case combination expression given.
	An example of the load case combination experssion is:
	LC1:DX+LC2:DX

   Arguments:

	char 		new_name[]	i - new data name to be generated
	
	char		expression[]	i - load case combination expression

	int		category        i - node/element category ( = NODE_CATEGORY
					    for node, ALL_ELEM_CATEGORY for elem. 
					    default to NODE_CATEGORY )
					    
	struct GRid	list_grids[]	i - list of grids for group operations

	int		list_cnt	i - number of grids in the list
	
   Return Status: 
	OM_S_SUCCESS	-	Success
	
	OM_E_ABORT	- 	Error

   Examples:
   
#include "FEmacincl.h"

main()
{
	fe$create_loadcase_combinations( new_name = "LC1:DEF",
			  expression = "X_COORD+LC1:DX" );

 	this example creates a new node data LC1:DEF by summing up the nodal
   	x-coordinate and displacement  for all nodes. To do this for all 
	elements, use the following

	fe$create_loadcase_combinations( new_name = "LC1:DEF",
			  expression = "X_COORD+LC1:DX",
			  cat = ALL_ELEM_CATEGORY );
}			     
   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	18 Aug 92	qxn	Creation

*/
/*  ************************************************************************* */

extern int POlccmbn();

#omdef fe$create_loadcase_combinations(  expression,
			  new_name,
			  cat = NODE_CATEGORY,
			  list_grids = NULL,
			  list_cnt = -1 )

	POlccmbn(expression, new_name, cat, list_grids, list_cnt)

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$compare_results_sets

   Abstract: 
	This macro compares two given results sets by looking at the difference
	between the two sets for all data names of a given category (node or element).
	If the max. relative percentage difference for any data name is less than 
	the tolerence percentage given, the second set is considered "the same" as
	the first set. Otherwise, a difference report file will be created that 
	lists all data names for which the difference is above the tolerence. 
	
   Notes:

   	In evaluating the difference, the data in the first results set is
	used as reference. That is, set2 is compared against set1.

	It is assumed that the two results sets are all associated with the
	same model. This macro does not support comparison of an archived
	results set against a results set that is connected to the FE model.
	      	      
	Example of the definition of max. relative percentage difference:
	
	Let's say there is a data name called LC1:DX in set 1 and in set 2. Let the 
	min. and max. values for set 1 across all nodes (for example) be -5.00 and
	200.00 respectively. For a particular node, a value difference of LC1:DX
	from the two sets is found. Let's assume that the maximum value difference
	across all nodes be 10.00, then, the max. relative percentage difference is:
	      
	               10.00/(200.00- (-5.00)) *100% = 4.878%
                 
   Arguments:

	char		set1_name[]	 i - Name of first result set		
					     NULL : use default first set	
					     
	char		set2_name[]	 i - Name of second result set	
					     NULL : use default second set	
					     
	int		category	 i - data category  			
					     =0 Node, =1 Element		
					     
	double		tolerence	 i - tolerence percentage allowable	
		
   Return Status: 
	1	-	Set 2 is  "the same" as Set 1

	0	- 	Set 2 is different from Set 1, a difference report file
			(filename is 'model_name'.diff) is generated.

   Examples:
   
#include "FEmacincl.h"

main()
{
	fe$compare_results_sets(tolerence = 2.0 );   
	
	This call compares the node data from second results set against the first 
	results set with a prescribed acceptance tolerence of 2 percent (2%)

	sts = fe$compare_results_sets(
		category = 1,
		set1_name = "RS2",
		set2_name = "RS3",
		tolerence = 0.5 );
}			     
   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	15 Dec 92	qxn	Creation

*/
/*  ************************************************************************* */

extern int POcompare_sets();

#omdef fe$compare_results_sets( set1_name = NULL,
			  set2_name = NULL,
			  category = 0,
			  tolerence = 1 )

	POcompare_sets(set1_name, set2_name, category, tolerence)

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$get_data

   Abstract: 
	This macro gets the data value for a node or element given the data name
	and node/element grid.

   Arguments:

	char 		data_name[]	i - data name
	
	int		category	i - data category  			
					     =NODE for Node, ELEM Element (APdef.h)
					     		
	int		ndel_uid	i - node or element uid
	
	struct GRid	ndel_grid	i - node or element grid
	
	double		*data_value	o - data value returned	

   Return Status: 
	1	-	Success

	0	- 	data not found for this grid

   Examples:
   
#include "FEmacincl.h"

main()
{
struct GRid *node_grid;
long	uid;
double  value;

	uid = 152;
	fe$uids_to_grids( ndel = NODE,  
			  ndel_uids = &uid,
			  ndel_grids = &node_grid,
			  num_ndel = 1 );
			  	  
	fe$get_data( data_name = "LC1:DX",
		     ndel_grid = *node_grid,
		     data_value = &value );
	fprintf(stderr,"LC1:DX for uid = %d is %g\n", uid, value);

	fe$get_data( data_name = "LC1:SXXTOP",
		     category = NODE,
		     ndel_uid = 162,
		     data_value = &value );
}			     
   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	Dec 24 92	qxn	Creation

*/
/*  ************************************************************************* */

extern int POget_data();

#omdef fe$get_data(  data_name,
		     category = NODE,
		     ndel_uid^
		     ndel_grid,
		     data_value )

#if om$specified( ndel_uid )
	POget_data(data_name, category, ndel_uid, POman_grid, data_value )
#elif om$specified( ndel_grid )  
	POget_data(data_name, category, -1, ndel_grid, data_value )
#endif

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$report_results_statistics

   Abstract: 
	This macro writes the results statistics into a specified file. If
	the file exists before, the results statistics is appended at the 
	end.

   Arguments:

	int 		*msg		i - return message: 1 = success
							    0 = failure
	
	char		*file_name	i - file name to write to
					    = NULL to take the default (.sts)

   Return Status: 
	1	-	Success

   Examples:
   
#include "FEmacincl.h"

main()
{
int	msg, sts;

	sts = fe$report_results_statistics( msg = &msg,  
		file_name = "test.sts" );
}			     
   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	Feb 01 93	qxn	Creation

*/
/*  ************************************************************************* */

extern int POpost_stats();

#omdef fe$report_results_statistics(  msg,
		     file_name = NULL )

	POpost_stats(msg, file_name)

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$delete_results_set

   Abstract: 
	This macro deletes given results sets.


   Arguments:

	char 		**res_list	i - list of results sets to be deleted
	
	int		list_cnt	i - number of grids in the list.
					    Default is 1.	
   Return Status: 
	OM_S_SUCCESS	-	Success

	OM_E_ABORT	- 	Error

   Examples:
   
#include "FEmacincl.h"

main()
{
	char rs1[20], rs2[20], *ptr[2];
	int  list_cnt;
	
	list_cnt = 2;
	strcpy( rs1, "RS1" );
	strcpy( rs2, "RS2" );
	ptr[0] = rs1;
	ptr[1] = rs2;
	fe$delete_results_set( res_set = ptr,
			       list_cnt = list_cnt );
}			     


   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	20 Jan 93	raju	Creation

*/
/*  ************************************************************************* */

extern int POdel_results_set();

#omdef fe$delete_results_set(	res_list,
				list_cnt = 1 )

	POdel_results_set( res_list, list_cnt)

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$animate_deformed_shape

   Abstract:
	This macro animates a deformed shape of the model.

   Arguments:
	long		*ids 		i - list of 3 Node data id numbers (x,y,z) OR

	char		*data_names[3]	i - data Names for (x,y,z)

	double		exagg_factor	i - exaggeration factor

	POplgr_data	*pg		i - Place Graphics parameters  
					    = NULL for default parameters.    

	char		*win_name	i - Window name where animation takes place
					    = NULL( default ) for iso window
					    
	char		*file_name	i - File to store frames
					    = NULL ( default ) for not storing frames

	IGRboolean	po_modal  	i - TRUE - modal analysis
					    FALSE- static analysis ( default )

	IGRboolean	static_frm  	i - TRUE - display static frame
					    FALSE- no display ( default )

	struct GRid	*list_grids	i - list of element grids to process	

	long		list_cnt	i - # of grids in the list (-1: process all) 	

   Return Status:
	1	-	SUCCESS
   
   Notes:
   
	1. When pg is not specified (pg is set to NULL as default), The
	parameters ( layer, exposed face/all face ... ) for deformed shape 
	graphics are set to those that were defined when the interactive command
	was last executed. If there is no interactive execution of the command before
	this macro, a full set of defaults is assumed (as shown in the Postprocessing
	setup form when the command is first executed).

	2. Any arguments specified in this macro will override the default setting. But
	will not be saved as default for the next call.

   Examples:

#include "FEmacincl.h"

main()
{
int	msg;
char	dx[80], dy[80], dz[80], *ptr[3];

	strcpy(dx, "LC1:DX");
	strcpy(dy, "LC1:DY");
	strcpy(dz, "LC1:DZ");
	ptr[0] = dx;
	ptr[1] = dy;
	ptr[2] = dz;
  	fe$animate_deformed_shape ( data_names = ptr,
   				  static_frm = TRUE );
}

   History:

     	Date		Who	Why
      	---------	------	---------------------------
	23 Jan 93	raju	2.1 creation 

*/
/* *****************************H H H H H******************************* */

extern int POanim_def_sh();

#omdef fe$animate_deformed_shape( data_names^
				ids,
				exagg_factor = 1.0,
				pg = NULL,
				win_name = NULL,
				file_name = NULL,
				po_modal = FALSE,
				static_frm = FALSE,
				list_grids = NULL,
				list_cnt = -1)

#if om$specified( ids )
	POanim_def_sh( ids, NULL, exagg_factor, pg, win_name, file_name, po_modal,
		  static_frm, list_grids, list_cnt)
#elif om$specified( data_names )  
	POanim_def_sh( NULL, data_names, exagg_factor, pg, win_name, file_name,
		  po_modal,  static_frm, list_grids, list_cnt)
#endif

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$display_principal_stresses

   Abstract: 
	This macros creates wireframe graphics showing the magnitude and direction
	of principal stresses.

   Arguments:

	int		num_ids		i - number of data ids, must be either 3
					    or 6 (for 2-D or 3-D stress tensor data
					    
	int		*ids 		i - list of data id numbers  OR

	char		*data_names[]	i - data Names for the stress tensor in (x,y,z)
					    frame

	double		*max		i - max. value of principal stress

	double		*min		i - min. value of principal stress

	double		exagg_factor	i - exaggeration factor

	POplgr_data	*pg		i - Place Graphics parameters

	struct GRid	*gg_grid	o - grid of graphic group created

	struct GRid	*list_grids	i - list of element grids to process 	

	long		list_cnt	i - # of grids in the list ( -1: process all ) 	

	int		option          i - options: 
					= 0 display ALL principal stresses
					= 1 display 1st principal stress only
					= 2 display 2nd principal stress only
					= 3 display 3rd principal stress only

   Return Status:
	1	-	SUCCESS

	else	-	failure

   Notes: 

	1. When pg is not specified (pg is set to NULL as default), The
	parameters ( layer, line width... ) for vector 
	graphics are set to the active parameters.
	
	2. Any arguments specified in this macro will override the default setting.

   Examples:

#include "FEmacincl.h"

main()
{

int	msg;
char	sxx[80], syy[80], sxy[80], *ptr[3];

	strcpy(sxx, "LC1:SXXTOP");
	strcpy(syy, "LC1:SYYTOP");
	strcpy(sxy, "LC1:SXYTOP");
	ptr[0] = sxx;
	ptr[1] = syy;
	ptr[2] = sxy;
  	fe$display_principal_stresses ( 
  				num_ids = 3,
  				data_names = ptr,
   				exagg_factor = 0.1 );
}

   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	23 Sep 93	qxn	3.0 creation

*/
/*  ************************************************************************* */

extern int POprin_stress();

#omdef fe$display_principal_stresses( num_ids,
			 data_names^
			 ids,
			 exagg_factor = 1.0,
			 max = NULL,
			 min = NULL,
			 pg = NULL,
			 gg_grid = NULL,
			 list_grids = NULL,
			 list_cnt = -1,
			 option = 0
			  )

#if om$specified( ids )
	POprin_stress( num_ids, ids, NULL, max, min, exagg_factor, pg, gg_grid, list_grids, list_cnt, option)
#elif om$specified( data_names )  
	POdisplay_vectors(num_ids, NULL, data_names, max, min, exagg_factor, pg, gg_grid, list_grids, list_cnt, option)
#endif

#endomdef

#endif
