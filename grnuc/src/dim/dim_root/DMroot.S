/*
	Abstract Class. All dimensioning classes subclass from
	this class. Supports the basic messages used by all.
*/

class specification DMroot(2:0) of ASnode;

#include "OMmacros.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"

#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"

#include "dpmacros.h"

#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "gotextdef.h"
#include "gotext.h"

#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"

#include "ma.h"
#include "bserr.h"

#include "dimdef.h"
#include "dim.h"
#include "dimglobal.h"
#include "dimerror.h"
#include "dimplan.h"
#include "dimext.h"
#include "dimacc.h"
#include "dimmacros.h"
#include "diminfo.h"
#include "dimcomplex.h"
#include "dm_status.h"
#include "dimsrc.h"
#include "dimdload.h"

override GRvg;

instance DMroot
{
	IGRlong	 comp_mask;
	IGRuchar dim_type;
	IGRuchar geom_type;
	IGRuchar dim_state;
	IGRuchar display;
};


/**************************************************************************

			- DMplace -

	Description:

	The DMplace message is a simplified form of NDplace, to be
	used mainly by the placement command objects. It takes the
	list of roots in their final form (DMkeypt, DMkeyseg type
	source objects) while NDplace takes raw graphic objects and
	creates the source objects as required by DMplace.

	Arguments:

	IGRint *msg			(O)	DIM_S_SUCCESS - success
						failure otherwise

	IGRint count			(I)	Number of parents

	struct GRid list[]		(I)	List of parents in their
						final form, i.e., directly
						attachable to the dimension

	char *attr			(I)	Class specific attributes.

	struct GRmd_env *md_env		(I)	Module Environment.

**************************************************************************/

message DMplace(IGRint *msg;
		IGRint count;
		struct GRid list[];
		char *attr;
		struct GRmd_env *md_env);

/**************************************************************************

			- return_dim_go -

	Description

	This message returns the grid of a graphic component of
	the dimension identified by 'go_index'. The "comp_mask" in
	the object's instant data would immediately identify the
	presence or absence of this graphic object and if present
	would give the index on the "to_components" channel. If
	the object is not present and create_flag is set to TRUE
	a new object of type specified by 'obj_type' is constructed
	and connected to the "to_components" channel and the
	appropriate bit	in the "comp_mask" is turned ON.

	Arguments:

	IGRint	*msg		(I)	Error Information
					DIM_S_SUCCESS - success
					DIM_E_BAD_GO_INDEX - invalid index
					DIM_E_BAD_OBJTYPE  - invalide objec type
					DIM_I_OBJ_CREATED  - object is created
					DIM_E_NO_OBJECT    - object not present

	IGRint go_index		(I)	Graphic Object Index
					#defined in "dimdef.h"
					DIM_TEXT
					DIM_ORI_TERM etc.

	IGRint create_flag	(I)	Create the object if required?
					The this flag is TRUE an object
					of type "obj_type" is created
					and connected to proper index.
					"obj_type" must be properly
					specified if this flag is TRUE.

	IGRint obj_type		(I)	Object Type - must be specified
					properly if create_flag is TRUE.
					#defined in "dimdef.h"
					DIM_LINE
					DIM_TEXT
					DIM_ARC

	struct GRmd_env *md_env (I)	Module environment

	struct GRid *go_grid	(O)	GRID of graphic object - returned

**************************************************************************/

message return_dim_go(
	IGRint *msg;
	IGRint go_index;
	IGRint create_flag;
	IGRint obj_type;
	struct GRmd_env *md_env;
	struct GRid *go_grid);

/**************************************************************************

			- return_dim_go -

	Description

	This message returns the index of the given graphic component.
	Used primarily by "modify dimension geometry" command.

	Arguments:

	IGRint	*msg		(I)	Error Information
					DIM_S_SUCCESS - success
					DIM_E_NO_OBJECT - object not present

	struct GRid go_grid	(I)	GRID of graphic object

	IGRint go_index		(O)	Graphic Object Index - Returned
					#defined in "dimdef.h"
					DIM_TEXT
					DIM_ORI_TERM etc.

**************************************************************************/

message return_go_index(
	IGRint *msg;
	struct GRid go_grid;
	IGRint *go_index);

/**************************************************************************

			- delete_dim_go -

	Description

	This message deletes the graphic component specified by
	'go_index' if it exits. No action is taken if the graphic
	component does not exist.

	Arguments:

	IGRint	*msg		(I)	Error Information
					DIM_S_SUCCESS - success
					DIM_E_BAD_GO_INDEX - invalid index

	IGRint go_index		(I)	Graphic Object Index
					#defined in "dimdef.h"
					DIM_TEXT
					DIM_ORI_TERM etc.

	struct GRmd_env *md_env (I)	Module environment

**************************************************************************/

message delete_dim_go(
	IGRint *msg;
	IGRint go_index;
	struct GRmd_env *md_env);


/**************************************************************************

			- position_line -

	Description:

	Given the end points and the module environment, this message
	would position the line identified by 'line_index' or 'line_grid'.
	If 'line_index' is set DIM_NO_INDEX then 'line_grid' is used else
	the grid is obtained using "return_dim_go" message and returned
	in 'line_grid' if it is not a NULL pointer.

	NOTE: The return_dim_go is invoked with
			create_flag = TRUE
	      and	obj_type    = DIM_LINE
	      So, the graphic object is created if it does not
	      exist.

	Arguments:

	IGRint	*msg		(I)	Error Information
					DIM_S_SUCCESS - success
					DIM_E_BAD_OBJSPEC - no index or grid
					and others from return_go_index

	IGRint	line_index	(I)	#defined in "dimdef.h"
					If set to DIM_NO_INDEX then
					line_grid must be specified

	struct GRid *line_grid	(I/O)	If this pointer is not NULL
					and line_index is specified
					then the grid of the line
					is obtained and returned in
					this. If line_index is set to
					DIM_NO_INDEX then this pointer
					must point to the grid of the
					line

	struct GRmd_env *md_env	(I)	Module Environment

	IGRdouble	line[6]	(I)	End points of line

**************************************************************************/

message position_line(
	IGRint *msg;
	IGRint line_index;
	struct GRid *line_grid;
	struct GRmd_env *md_env;
	IGRdouble line[6]);

message position_line_string(
	IGRint *msg;
	IGRint line_index;
	struct GRid *line_grid;
	struct GRmd_env *md_env;
	IGRint num_vertex;
	IGRdouble line[]);

message position_arc(
	IGRint *msg;
	IGRint arc_index;
	struct GRid *arc_grid;
	struct GRmd_env *md_env;
	IGRdouble *norm;
	struct DMdim_arc *arc_info);

/**************************************************************************

			- position_text -

	Description:

	Given a unit vector normal to plane of orientation (norm),
	placement point (origin), a vector to identify the text
	orientation in the given plane (orie_vec), text justification
	(justification)	and the module environment, this message would
	position the text identified by 'text_index' or 'text_grid'.
	If 'text_index' is set DIM_NO_INDEX then 'text_grid' is used else
	the grid is obtained using "return_dim_go" message and returned
	in 'text_grid' if it is not a NULL pointer.

	NOTE: The return_dim_go is invoked with
			create_flag = TRUE
	      and	obj_type    = DIM_TEXT
	      So, the graphic object is created if it does not
	      exist.

	Arguments:

	IGRint	*msg		(I)	Error Information
					DIM_S_SUCCESS - success
					DIM_E_BSCROSSP - BScrossp failed
					DIM_E_BAD_OBJSPEC - no index or grid
					and others from return_go_index

	IGRboolean txt_flag	(I)	Position Text(TRUE)
						 or
					Position Terminator(FALSE)
					This information is used
					to automatically update box
					and/or underline positions
					automatically.
					

	IGRint	text_index	(I)	#defined in "dimdef.h"
					If set to DIM_NO_INDEX then
					text_grid must be specified

	struct GRid *text_grid	(I/O)	If this pointer is not NULL
					and text_index is specified
					then the grid of the text
					is obtained and returned in
					this. If text_index is set to
					DIM_NO_INDEX then this pointer
					must point to the grid of the
					text

	struct GRmd_env *md_env	(I)	Module Environment

	IGRshort justification	(I)	Text Justification (gotextdef.h)

	IGRdouble origin[3]	(I)	Placement Point

	IGRdouble orie_vec[3]	(I)	Unit vector indicating the orientation
					of text

	IGRdouble norm[3]	(I)	Unit vector normal to the plane
					of orientation

**************************************************************************/

message position_text(
	IGRint *msg;
	IGRboolean txt_flag;
	IGRint text_index;
	struct GRid *text_grid;
	struct GRmd_env *md_env;
	IGRshort justification;
	IGRdouble origin[3];
	IGRdouble orie_vec[3];
	IGRdouble norm[3];
	struct DMloc_param *par_loc;
	struct DMenv_param *par_env);

/**************************************************************************

			- replace_text -

	Description:

	Sends a GRreplace_text message to the graphic object identified
	by the 'text_index' or 'text_grid'.
	If 'text_index' is set DIM_NO_INDEX then 'text_grid' is used else
	the grid is obtained using "return_dim_go" message and returned
	in 'text_grid' if it is not a NULL pointer.

	NOTE: The return_dim_go is invoked with
			create_flag = TRUE
	      and	obj_type    = DIM_TEXT
	      So, the graphic object is created if it does not
	      exist.

	Arguments:

	IGRint	*msg		(I)	Error Information
					DIM_S_SUCCESS - success
					DIM_E_BAD_OBJSPEC - no index or grid
					and others from return_go_index

	IGRint	text_index	(I)	#defined in "dimdef.h"
					If set to DIM_NO_INDEX then
					text_grid must be specified

	struct GRid *text_grid	(I/O)	If this pointer is not NULL
					and text_index is specified
					then the grid of the text
					is obtained and returned in
					this. If text_index is set to
					DIM_NO_INDEX then this pointer
					must point to the grid of the
					text

	struct GRmd_env *md_env	(I)	Module Environment

	IGRint text_len		(I)	Length of text_string in bytes

	IGRuchar *text_str 	(I)	Pointer to text string

***************************************************************************/

message replace_text(
	IGRint *msg;
	IGRint text_index;
	struct GRid *text_grid;
	struct GRmd_env *md_env;
	IGRint text_len;
	IGRuchar *text_str);



/**************************************************************************

			- chgtextattr -

	Description:

	Sends a GRchgtextattr message to the graphic object identified
	by the 'text_index' or 'text_grid'.
	If 'text_index' is set DIM_NO_INDEX then 'text_grid' is used else
	the grid is obtained using "return_dim_go" message and returned
	in 'text_grid' if it is not a NULL pointer.

	NOTE: The return_dim_go is invoked with
			create_flag = TRUE
	      and	obj_type    = DIM_TEXT
	      So, the graphic object is created if it does not
	      exist.

	The attributes changed are:
			font,
			line spacing,
			character spacing,
			text height and
			text width.

	text justification is NOT changed by this message.

	Arguments:

	IGRint	*msg		(I)	Error Information
					DIM_S_SUCCESS - success
					DIM_E_BAD_OBJSPEC - no index or grid
					and others from return_go_index

	IGRint	text_index	(I)	#defined in "dimdef.h"
					If set to DIM_NO_INDEX then
					text_grid must be specified

	struct GRid *text_grid	(I/O)	If this pointer is not NULL
					and text_index is specified
					then the grid of the text
					is obtained and returned in
					this. If text_index is set to
					DIM_NO_INDEX then this pointer
					must point to the grid of the
					text

	struct GRmd_env *md_env	(I)	Module Environment

	struct GRdpb_text_symb
		*text_symb	(I)	Text Symbology

***************************************************************************/

message chgtextattr(
	IGRint *msg;
	IGRint text_index;
	struct GRid *text_grid;
	struct GRmd_env *md_env;
	struct GRdpb_text_symb *text_symb);

/**************************************************************************

			- chgdp -

	Description:

	This message changes the display attributes of all the
	components currently present. The display attributes
	are obtained from the environment parameters.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	struct DMenv_param *par_env	(I)	environment parameters

**************************************************************************/

message chgdp(
	IGRint *msg;
	struct DMenv_param *par_env);



/**************************************************************************

			- set_ter_type -

	Description:

	Sets the terminator type of the terminator identified
	by the 'term_index' or 'term_grid'. The symbology and
	the instance are intialised properly.

	If 'term_index' is set DIM_NO_INDEX then 'term_grid' is used else
	the grid is obtained using "return_dim_go" message and returned
	in 'term_grid' if it is not a NULL pointer.

	NOTE: The return_dim_go is invoked with
			create_flag = TRUE
	      and	obj_type    = DIM_TEXT
	      So, the graphic object is created if it does not
	      exist.

	Arguments:

	IGRint	*msg		(I)	Error Information
					DIM_S_SUCCESS - success
					DIM_E_BAD_OBJSPEC - no index or grid
					and others from return_go_index

	IGRint	term_index	(I)	#defined in "dimdef.h"
					DIM_ORI_TERM
					DIM_MEA_TERM
					DIM_NO_INDEX

					If set to DIM_NO_INDEX then
					term_grid must be specified

	struct GRid *term_grid	(I/O)	If this pointer is not NULL
					and term_index is specified
					then the grid of the terminator
					is obtained and returned in
					this. If term_index is set to
					DIM_NO_INDEX then this pointer
					must point to the grid of the
					term

	struct GRmd_env *md_env	(I)	Module Environment

	struct DMenv_param
		*par_env	(I)	Dimensioning environment params

***************************************************************************/

message set_ter_type(
	IGRint *msg;
	IGRint term_index;
	struct GRid *term_grid;
	struct GRmd_env *md_env;
	struct DMenv_param *par_env;
	struct DMloc_param *par_loc);


/***************************************************************************

			- dynamics -

	Description:

	This is the message to support the "placement" and the
	"modify dimension geometry" command objects.
	The current cursor position is passed as input to this message.
	Also, depending on the type of dimension, address of a specific
	structure type-cast to a character pointer ("info") should be passed.

	At this level, the message is dummy. It must be overridden by
	the subclass to be implemented in the required manner.

	Arguments:

	IGRint *msg		(O)		DIM_S_SUCCESS - success
						anything else - failure

	IGRint *level		(I/O)		For use in complex dimensions

	IGRint control		(I)		Control Points to modify
						MOVE_TRAK_PT
						MOVE_BREAK_PT
						MOVE_LEADER_PT
						MOVE_TEXT 
						#defined in "dimmod.h"

	char info[]		(I/O)		Internal Information
						type cast to a character
						pointer.

	IGRdouble *matrix	(I)		Window orientation

	struct GRmd_env *md_env	(I)		Module Environment

	IGRdouble cursor[3]	(I)		Cursor Position in
						world coordinates

***************************************************************************/

message dynamics(
	IGRint  *msg;
	IGRint  control;
	IGRint  *level;
	IGRchar info[];
	IGRdouble *matrix;
	struct GRmd_env *md_env;
	IGRdouble cursor[3]);

/***************************************************************************

			- leader_needed -

	Description:

	This message tells whether a leader line is required for the
	dimension based on the current settings.

	Arguments:

	IGRint *msg			(O)	DIM_S_SUCCESS - success
						anything else - failure

	IGRboolean *leader		(O)	TRUE if needed
						FALSE if not needed

***************************************************************************/

message leader_needed(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRboolean *leader);

/***************************************************************************

			- get_dim_params -

	Description:

	This is THE message to obtain the dimension parameters of any type.
	This message takes as input the type of parameters to be obtained,
	the grid of the parameter object (can be NUL, in which case it
	is obtained from the parents channel), and a pointer to the proper
	structure.

	Philosophy:

	In the current design, the parameter objects are shared between
	different dimensions. This calls for some overriding based on
	the requirements of a specific type of dimension. For example,
	the project line display is based on a parameter "proj_disp"
	stored in the local parameters. But, for a symmetric diameter
	dimension - it is always off. So, it must be overridden by
	this dimension before they can be used. There are more such
	examples and must be handled carefully.

	Every type of dimension will have its own override values for
	the parameters, thus making it transparent to other methods
	in the system.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRint type			(I)	Parameter Type
						DM_ENV_PARAM
						DM_LOC_PARAM
						DM_MISC_PARAM
						#defined in "dimdef.h"

	IGRint size			(I)	size of the structure
						pointed at by param.

	char *param			(O)	Pointer to the proper
						structure typecast to
						a character pointer. The
						parameter values are
						returned in this structure

***************************************************************************/

message get_dim_params(
	IGRint *msg;
	IGRint type;
	IGRint size;
	char *param);

message set_dim_params(
	IGRint *msg;
	IGRint type;
	IGRint size;
	struct GRmd_env *md_env;
	char *param);

/***************************************************************************

			- validate_roots -

	Description:

	This message is called from inside DMplace. It checks the validity
	of the roots (or templates) specified in the "asocc_lis". Should
	be implemented by each type of dimension.

	Arguments:

	IGRint *msg			(O)	DIM_S_SUCCESS - success
						failure otherwise

	IGRint count			(I)	Number of parents

	struct GRid list[]		(I)	List of parents grids

***************************************************************************/

message validate_roots(
	IGRint *msg;
	IGRint count;
	struct GRid list[]);

/***************************************************************************

			- toggle_ter_loca -

	Description:

	Toggles the terminator location by setting the instance data
	properly. If the module environment is sent, the object is put
	in the batch for a recompute.

	Arguments:

	IGRint *msg			(O)	DIM_S_SUCCESS

	struct GRmd_env *md_env		(I)	Module Environment -
						If not NULL object
						is put in batch for
						recompute.

***************************************************************************/

message toggle_ter_loca(IGRint *msg; struct GRmd_env *md_env);

message get_dim_type(IGRshort *type);
message inq_dim_state(IGRchar *state);


/**************************************************************************

			- set_dim_state -

	Operations:

	flag =	BIT_AND
		BIT_OR
		BIT_XOR
		BIT_SET

***************************************************************************/

message set_dim_state(int flag; IGRchar state);


/***************************************************************************

			- clear_offset -

	Description:

	Clear the text offset by clearing me->offs_pt instance data.
	Implemented at this level.

***************************************************************************/

message clear_offset();

/***************************************************************************

			- leader_off -

	Description:

	Turns off the leader line, by setting me->leader = FALSE;

	Arguments: NONE

***************************************************************************/

message leader_off();

/*****************************************************************************

			- fill_info -

	Description:

	Returns the dimension information for the all the dimensions
	starting from (and including) this dimension. The buffer must
	be allocated for by the caller. The buffer is an array of pointers
	each pointing to a structure (allocated by the caller) as defined
	by the dimension type.
	MUST BE IMPLEMENTED BY THE SUB CLASSES.

	Arguments:

	IGRint *msg			(O)	DIM_S_SUCCESS - success
						failure otherwise

	struct GRmd_env *md_env		(I)	Module info

	IGRint  *level			(I/O)	For use of complex dimensions

	IGRchar info[]			(O)	Information Buffer.

*****************************************************************************/

message fill_info(
		IGRint  *msg;
		IGRint  control;
		IGRint  *level;
		IGRchar info[];
		struct GRmd_env *md_env);

/*****************************************************************************

			- get_first_in_cpx -

	Description:

	This message sent to any dimension in a complex would return the
	first dimension in that complex

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	struct GRid *first		(O)	Grid of the first dimension
						in the complex

*****************************************************************************/

message get_first_in_cpx(
	IGRint *msg;
	struct GRid *first);

/*****************************************************************************

			- find_postion_in_cpx -

	Description:

	Given the measure point, this message would find the postion
	of the new dimension in a complex and returns the dimensions
	before and after the new dimension. An outsider (like a command
	object) should always send this message to the first dimension
	in the complex. The sender must initialise both "dim_before"
	and "dim_after" to NULL_GRID before sending this message.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRint cpx_type			(I)	complex type
						STACKED_CPX
						STRINGED_CPX
						#defined in "dimcomplex.h"

	struct GRid new_dim		(I)	grid of the dimension
						new_meas belongs to.

	struct GRid new_meas		(I)	grid of the new element
						to dimension to.

	struct GRmd_env *md_env		(I)	module environment

	struct GRid *rel_pos		(O)	Relative position in
						the complex

	struct GRid *dim_before		(O)	dimension before the new
						dimension - NULL_GRID if
						none exists

	struct GRid *dim_after		(O)	dimension after the new
						dimension - NULL_GRID if
						none exists

*****************************************************************************/

message find_position_in_cpx(
	IGRint *msg;
	IGRint cpx_type;
	struct GRid new_dim;
	struct GRid new_meas;
	struct GRmd_env *md_env;
	IGRint *rel_pos;
	struct GRid *dim_before;
	struct GRid *dim_after);

/* - SECOND SET - PUBLIC MESSAGES - */

/*****************************************************************************

			- insert_into_cpx -

	Description:

	This message inserts a new dimension into a complex. The insert
	position is defined by the dimension before and the dimension
	after the new dimension.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRint action			(I)	NO_ACTION
						ADJUST_TRAK_DIST

	struct GRmd_env *md_env		(I)	Module Environment

	IGRint rel_pos			(I)	Relative Position in
						the complex

	struct GRid *dim_before		(I)	dimension before the new
						dimension - NULL_GRID if
						none exists

	struct GRid *dim_after		(I)	dimension after the new
						dimension - NULL_GRID if
						none exists

*****************************************************************************/

message insert_into_cpx(
	IGRint *msg;
	IGRint action;
	struct GRmd_env *md_env;
	IGRint rel_pos;
	struct GRid *dim_before;
	struct GRid *dim_after);
	
/*****************************************************************************

			- remove_from_cpx -

	Description:

	This messages removes the dimension from the complex. The
	broken links are sewed up properly by linking the dimension
	before and after this dimension.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRint action			(I)	NO_ACTION
						DELETE_ACTION
						DROP_ACTION

	struct GRmd_env *md_env		(I)	module environment

*****************************************************************************/

message remove_from_cpx(
	IGRint *msg;
	IGRint action;
	struct GRmd_env *md_env);

message get_trak_info(struct DMtrak_info *trak_info);
message set_trak_info(IGRint action; struct DMtrak_info *trak_info);

/* - SECOND SET - PRIVATE MESSAGES - */

/*****************************************************************************

			- give_previous -

	Description:

	This message returns the previous dimension in the complex.
	MUST BE IMPLEMENTED BY A SUBCLASS.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRboolean *first_in_cpx	(O)	TRUE or FALSE

	struct GRid *prev		(O)	Grid of the previous
						dimension in the complex
						Returns NULL_GRID if none
						exists

*****************************************************************************/

message give_previous(
	IGRint *msg;
	IGRboolean *first_in_cpx;
	struct GRid *prev);

/*****************************************************************************

			- give_next -

	Description:

	This message returns the next dimension in the complex.
	MUST BE IMPLEMENTED BY A SUBCLASS.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	IGRboolean *last_in_cpx		(O)	TRUE or FALSE

	struct GRid next[2]		(O)	Grid(s) of the next
						dimension(s) in the complex
						NULL_GRID if none exists

*****************************************************************************/

message give_next(
	IGRint *msg;
	IGRboolean *last_in_cpx;
	struct GRid *next);

/*****************************************************************************

			- give_rel_pos -

	Description:

	Given the grid of the new element to dimension to, this
	message returns its relative position with respect to
	itself.	MUST BE IMPLEMENTED BY A SUBCLASS.

	Arguments:

	IGRint *msg			(O)	return value
						DIM_S_SUCCESS - success
						failure otherwise

	struct GRid new_meas		(I)	Grid of the dimension the
						new element belongs to

	struct GRid new_meas		(I)	Grid of the new element
						to dimension.

	struct GRmd_env *md_env		(I)	module environment

	IGRint *rel_pos			(O)	Relative postion

						CPX_OPPOSITE_FAR
						CPX_OPPOSITE_NEAR
						CPX_BEFORE
						CPX_AFTER

						#defined in "dimcpx.h"

*****************************************************************************/

message give_rel_pos(
	IGRint *msg;
	struct GRid new_dim;
	struct GRid new_meas;
	struct GRmd_env *md_env;
	IGRint *rel_pos);

/*****************************************************************************

			- get_complex_type -

	Description:

	Returns the type of the complex - STACKED or STRINGED.
	NOT IMPLEMENTED AT THIS LEVEL - MUST BE IMPLEMENTED BY THE
	SUBCLASSES.

	Arguments:

	IGRint *type			(O)	Complex Type
						STRINGED_CPX
						STACKED_CPX
						#defined in "dimcomplex.h"

*****************************************************************************/

message get_complex_type(IGRint *type);

message is_complex(IGRint *msg);

message get_dimension_plane(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct DMplan_info *plan_info);

message get_window_plane(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRmatrix matrix);

message get_parent_info(
		IGRboolean   *orig_needed;
		IGRboolean   *meas_needed);

message change_dimension_origin(
		IGRint *msg;
		struct GRid new_orig;
		struct GRmd_env *md_env);

message change_dimension_measurement(
		IGRint *msg;
		struct GRid new_meas;
		struct GRmd_env *md_env);

message change_parent(
		IGRint *msg;
		IGRint parent_index;
		struct GRid new;
		struct GRmd_env *md_env);

message get_dim_attr(char *attr);
message set_dim_attr(char *attr);
message copy_dim_attr(
	IGRint *msg;
	IGRint control;
	struct GRid *dim_grid;
	struct GRmd_env *md_env);

message get_info(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct diminfo *info);

message get_complex_size(IGRint *size);

message init_ter_loca(IGRdouble ter_limit);
message test_state(IGRshort mask; int *on, *off);
message connect_state(IGRshort mask; struct GRid *old, *new);
	
/***************** DMcompute_node *************************

	Description:
	-----------

	PRIVATE MESSAGE.

	Special compute node message to support
	imported dimensions.

	Called internally by NDcompute_node.
	Never to be called from outside.
	Results could be very damaging.

***********************************************************/

message DMcompute_node(
		IGRlong *msg;
		IGRint cn_type;
		IGRint count;
		struct GRid list[];
		struct GRmd_env *md_env);

/******************** DMreturn_roots **********************

	Description:
	-----------

	This message returns the list of parents of
	a dimension. The message is specially supported
	to take care of "imported" dimensions.

	The size of the array "struct GRid list[]" must
	be MAX_DIM_ROOTS (defined in dimdef.h).

***************************************************************/

message DMreturn_roots(
	IGRint *count;
	struct GRid list[]);

message get_absolute_roots(
	IGRint *count;
	struct GRid list[];
	struct GRid *prev);

/******************* send_to_root *************************

	Description:
	------------

	PRIVATE MESSAGE

	This message directs the p_msg (message to be sent
	to root) to the direct parent (in case of normal
	dimensions) or to the parents of the imported
	dimension (in case of imported dimensions).

	The "md_env" specified in this message must be
	the same as the one specified in "p_msg" so
	that the update on "md_env" is reflected in the
	message arguments.

	ALL INTERNAL ACCESS TO PARENTS MUST GO THROUGH
	THIS MECHANISM

**********************************************************/

message send_to_root(
	IGRint root_index;
	struct GRmd_env *md_env;
	OM_p_MESSAGE p_msg);

message compute_attr(
		IGRint *msg;
		IGRdouble axis_vec[3];
		IGRdouble trk_pt[3];
		IGRdouble brk_pt[3];
		IGRdouble lea_pt[3];
		IGRshort  txt_just;
		struct IGRlbsys *txt_geom;
		struct GRmd_env *md_env);

message convert_feet(struct GRid dim_13);

message update_parents();

message set_degrade(struct GRmd_env *md_env);

message set_geom_type(int flag; IGRchar type; struct GRmd_env *md_env);

message set_display_type(int flag; IGRchar display; struct GRmd_env *md_env);

message inq_display_type(IGRchar *display);

message inq_geom_type(IGRchar *type);

message GLupdate(
	IGRchar g_type, g_mask;
	IGRchar d_type, d_mask;
	IGRboolean compute;
	struct GRmd_env *md_env);

/****************** import_dimension ***********************

	Description:

	This message is used to import (semi associative copy)
	a dimension from a reference file to the master file.

	Arguments:
	---------

	IGRint *msg		  (O)	success (DIM_S_SUCCESS) /
					failure (DIM_E_IMPORTED etc.)

	IGRboolean parallel_only  (I)	Import dimensions parallel
					to view port only (if TRUE).

	struct GRmd_env *fr_env	  (I)	Environment to copy from 

	struct GRmd_env *to_env	  (I)	Environment to copy to

	struct GRid *copy	  (O)	GRid of the imported dim

************************************************************/

message import_dimension(
	IGRint *msg;
	IGRboolean parallel_only;
	IGRmatrix vw_orientation;
	struct GRmd_env *fr_env;
	struct GRmd_env *to_env;
	struct GRid *copy);

/******************** get_import_info ***********************

	Description:

	This message is used to get information about the
	dimension which is imported into another object space
	and the context of such an import.

	Return Values:

	DIM_S_SUCCESS		success
	DIM_I_NOT_IMPORTED	this dimension or any one down
				the group is not imported

**************************************************************/

message get_import_info(
	IGRint *msg;
	struct GRid *original;
	struct GRid *impdim;
	struct GRid *context);

/***************************************************************************

			- compare_dimension-

	Description:

	Compares the imported dimension and its parent(reference)
	dimension for a set of parameters, and if different set the
	bit DIM_IS_DIFFERENT in me->display.

	if set0clear1 is FALSE, the bit is set, and if TRUE the
	bit is cleared.

	Arguments:

	IGRboolean set0_clear1		(I) flag determines whether to
					    set or clear DIM_IS_DIFFERENT BIT.
	struct GRmd_env *md_env		(I) module info;

***************************************************************************/

message compare_dimension(
	IGRint set0_clear1;
	struct GRmd_env *md_env);

/***************************************************************************

			- get_compare_info -

	Description:

	Get all the needed parameters for compare dimension method
	to compare parameters.

	Arguments:

	IGRint *msg			(O) return code
					    OM_S_SUCCESS if succesful.
					    DIM_I_NOT_ELIGIBLE if not eligible.
					    DIM_I_NOT_IMPORTED if not imported.

	IGRboolean compare		(O) flag TRUE if dimension are
					    eligible to compare.

	struct GRid *parent_dim		(O) GRid of the parent dim.

	struct GRmd_env *md_env		(O) module info of parent dim

	struct DMenv_param *my_env,
			*parent_env     (O) enivornment info of both dim.

	struct DMloc_param *my_loc,
			*parent_loc	(O) local param info of both dim.

	struct DMmisc_param *my_misc,
			*parent_misc	(O) misc param info of both dim.

***************************************************************************/

message get_compare_info(
	IGRint *msg;
	IGRboolean *compare;
	struct GRid *parent_dim;
	struct GRmd_env *md_env;
	struct DMenv_param *my_env, *parent_env;
	struct DMloc_param *my_loc, *parent_loc;
	struct DMmisc_param *my_misc, *parent_misc);

message display_update(
	IGRchar g_type, g_mask;	
	IGRchar d_type, d_mask;
	IGRboolean erase;
	IGRboolean display;
	IGRboolean parallel_only;
	enum GRdpmode mode;
	IGRmatrix vw_orientation;
	struct GRmd_env *md_env);

/***************************************************************************

			- jogged_off -

	Description:

	Turns off the Jogged line, by setting me->jogged = FALSE;
	Applicable for Radial and Coordinate Dimnesions only.

	Arguments: NONE

***************************************************************************/

message jogged_off();

/***************************************************************************

			- jog_needed -

	Description:

	This message tells whether a jogged line is required for the
	dimension based on the current settings.

	Arguments:

	IGRint *msg			(O)	DIM_S_SUCCESS - success
						anything else - failure

	IGRboolean *jogged		(O)	TRUE if needed
						FALSE if not needed

***************************************************************************/

message jog_needed(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRboolean *jogged);

/***************************************************************************

			- clear_jog_pts -

	Description:

	Clear the jog pts by clearing me->jog_pt1 & me->jog_pt2 instance data.
	Applicable only for radial & coordinate dimensions.

	Arguments:

	IGRint flag			(I)   CLEAR_JOG_PTS - clears both points. 	
					      CLEAR_JOG_PT1 - clears jog_pt1
					      CLEAR_JOG_PT2 - clears jog_pt2

***************************************************************************/

message clear_jog_pts(int flag);

message return_vertex(
	IGRint *msg, *dim_type;
	IGRboolean *first_in_cpx, *jogged;
	IGRpoint point;
	IGRint *vertex_no;
	struct GRmd_env *md_env);

message get_jog_info(
	IGRint *msg;
	IGRboolean *jogged;
	IGRint *num_jog_pts;
	IGRdouble jog_line[12];
	struct GRmd_env *md_env);

override NDcompute_node;
override NDgive_structure;
override NDmake_source;
override NDcopy;
override NDcopy_to_root;
override NDdisplay;
override NDupdate;
override NDdelete;
override ASreturn_go;
override ACgive_structure;
override ACgive_foot;
override ACreturn_foot;
override ACcopy_to_Groot;
override ACbecome_foot;

override GRget_locate_properties;
override GRdrop;
override GRdelete;
override GRcopy;
override GRgetobjinfo;
override GRdisyourself;
override GRlocate;
override GRgetrang;
override GRaddwrng;
override GRremwrng;
override GRchgcolor;
override GRchglevel;
override GRchgweight;
override GRmksource;
override GRgetsymb;
override GRxform;
override GRplotyourself;
override GRadd_to_display_list;
override debug;
override GRanalyze_element;

reject DMcompute_node;
reject compute_attr;
reject dynamics;
reject fill_info;
reject get_parent_info;
reject change_dimension_origin;
reject change_dimension_measurement;
reject get_dim_attr;
reject set_dim_attr;
reject copy_dim_attr;
reject get_info;
reject update_parents;
reject DMcompute_node;

end specification DMroot;

