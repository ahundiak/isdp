class specification VDCmdExDr (1:0) of VDS_LOCATE;

/* -----------------------------------------------
 * 04 Jan 2001 - ah
 * Originally included v_drw.h which the Forte compilier
 * could not handle, only needed the mac_info structre
 * so it was moved to it's own include file
 */
#include "v_drwcmd.h"

/*
 * state table resulting values.
 */
#define		VD_K_VIS_OKE		0
#define		VD_K_VIS_ERROR		1

#define		VD_K_LOC_SELECT		11

instance VDCmdExDr
{
	/*
	 * located buffer size.
	 */
	int			MaxObjList;

	/*
	 * list of located object. The list is used for the parent objects
	 * and for the resulting drawing objects.
	 */
	variable struct GRobj_env 	ObjList[0]; 

	/*
	 * display window for levels.
	 */
	struct GRid		dispWindow;

	/*
	 * list of locate criteria for locatable macro objects.
	 */
	variable IGRchar	locate_type[2];

	/*
	 * structure of macro definition with corresponding list
	 * of attributes to be add in the drawing object.
	 */
	VD_drwMacInfo		*drwMacInfo;

	/*
	 * name of the setup file for the located objects.
	 */
	IGRchar			setup_file[DI_PATH_MAX];

	/*
	 * name of the set for the visible/hidden objects.
	 */
	IGRchar			set_name[DI_PATH_MAX] ;

	/*
	 * locate Type	(select_list / transparent ).
	 */
	IGRshort		locGroup ;
};


message myinit ( long * sts );

message mywakeup ( long * sts );

message mysleep ( long * sts );

message mydelete ( long * sts );

message display_default( long * sts );

message display_setup( long * sts );

message set_locate_filter( long * sts );

message get_setup_file( long * sts );

message process_locate ( long * sts );

message extract_drw ( long * sts );

message extract ( long * sts );

message restart_cmd( long * sts );

message setup_act_handler ( long * sts );

message change_scale( long * sts );

message read_drawing_macro ( long * sts );

override	addLocatedObject,
		form_notification,
		status_disp,
		filter,
		dpLocObjs ;

end specification VDCmdExDr;
