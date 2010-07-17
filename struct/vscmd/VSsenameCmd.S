/*
	I/STRUCT
*/
class specification VSsenameCmd (1:0) of VSlocateCmd ;

#include "vssectiondef.h"
#include <FIdyn.h>

instance VSsenameCmd {

	/*
	 * Conversion list to obtain the face number from the form field's
	 * row number.
	 */
	int		rowToFcIndex[VS_K_sc_MAXFACES] ;

	/*
	 * Number of elements in the list.
	 */
	int		nbNames ;

	/*
	 * List of components of composite curve representing cross-section.
	 */
	struct 		GRid component_grid[VS_K_sc_MAXFACES] ;

	/*
	 * Center of the cross-section.
	 */
	IGRpoint	center ;

	/*
	 * Number of components of the composite curve.
	 */
	int		count,

	/*
	 * Array of user indices.
	 */
			usrIndex[VS_K_sc_MAXFACES] ;

	/*
	 * Position of last-selected row in list.
	 */
	int		lastSelectedRow ;

	long		ldescrKeys[VS_K_sc_MAXFACES] ;

	/*
	 * Position of the last highlighted row.
	 */
	int		lastHilitedRow ;
} ;


override form_notification,
	 mouse,
	 window_notification,
	 button_notification ;

message initCmd( int *sts ) ;

message repaint_form( int *sts ) ;

message disable_gadgets( int *sts ) ;

message resetCmd() ;

message unhiliteProfile( int *sts ) ;

message getCtrAndCmpsOfPrfl( int *sts ) ;

message drwPrflOnForm( int faceNo ) ;

message display_list( int value ) ;

end specification VSsenameCmd ;
