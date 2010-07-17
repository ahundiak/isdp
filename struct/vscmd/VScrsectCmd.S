/*
	I/STRUCT
*/
class specification VScrsectCmd(1:0) of VSlocateCmd ;

#define NB_SECTIONS	 4 /* # of sections names defined in vssectiondef.h */
#define NB_PARMS	 5 /* # of exp. names defined in vssectiondef.h     */
#define NB_TEMPS	20 /* # of templates for the macro		    */
#define STR_SIZE	80 /* # of characters for strings		    */


instance VScrsectCmd {

	/*
	 * Number of cross-sections located.
	 */
	int		nbLcXs,

	/*
	 * Number of cross-sections displayed.
	 */
			nbDspXs,
	/*
	 * Number of expressions in the graph.
	 */
			expCount,
	/*
	 * Number of named expressions.
	 */
			nbNmExp ;

	/*
	 * Value of the expressions in graph.
	 */
	double		expVal[NB_TEMPS],

	/*
	 * Position of the last-selected field.
	 */
			last_value ;

	/*
	 * Cross-sections already displayed.
	 */
	IGRboolean	isXsDsp[NB_SECTIONS],

	/*
	 * Expressions already selected.
	 */
			isPmDsp[NB_PARMS] ;

	GRobjid		feet[NB_SECTIONS],
			tmps[NB_TEMPS] ;

	/*
	 * Name to give to cross-section.
	 */
	char		*curve_type[NB_SECTIONS],
	/*
	 * Name to give to expressions
	 */
			*pmName[NB_PARMS],
	/*
	 * Names of feet (compcurves).
	 */
			*feetNm[NB_SECTIONS],
	/*
	 * Names of templates (CS and expressions).
	 */
			*tempNm[NB_TEMPS],
	/*
	 * Space to store templates names.
	 */
			tempBuf[NB_TEMPS*STR_SIZE],
	/*
	 * Name of the created macro definition.
	 */
			macro_name[STR_SIZE] ;
} ;


override window_notification ;

message initCmd() ;

message chain_locate( int *sts ) ;

message resetCmd( int *sts ) ;

message refresh_form( int *sts ) ;

message dspPmGadgets( int *sts ) ;

message dspProfile( int xsNo ) ;

message process_fence( int *sts ) ;

message storeProfiles( int *sts ) ;

message getCsAndExps( int *sts ) ;

message chkNumCmps( int nb_cs ) ;

message areCrvsAttchdToCs( struct GRid  cs_id ) ;

message isCsAtOriOfXYplane( IGRdouble *cs_matrix ) ;

message areCrvsClosedInXYplane( int *sts ) ;

message unhiliteCrvs( int *sts ) ;

message dspNextPmName( int *sts ) ;

message createMacDef( int response ) ;

override form_notification ;

end specification VScrsectCmd ;
