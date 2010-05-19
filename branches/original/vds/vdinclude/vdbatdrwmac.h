/* $Id: vdbatdrwmac.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdinclude/vdbatdrwmac.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdbatdrwmac.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1995/07/25  21:04:52  pinnacle
 * Created: vdinclude/vdbatdrwmac.h by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/25/95	raju		creation date
 *
 ***************************************************************************/

#ifndef  vdbatdrw_macros_define
#define  vdbatdrw_macros_define

/*
 *  depends on :
 *	vdbatdrw.h
 *
 *  Macros to interact with control data of batch extraction of drawings.
 */


extern  long  VDdrw_batch_process __((	long		 *msg,
					VD_drwViewStatus procSts,
					int		 *nbDwgViews,
					int		 **list ));

extern  long  VDdrw_list_extract __((	long		 *msg,
					int		 *nbDwgViews,
					int		 **list ));

extern  long VDdrw_batch_info	  __((	long		*msg,
					int		set_inq,
					int		index,
					long		type,
					VDdrwBatchInfo  *info  ));

extern  long VDdrwBatSolidsFromIndex __((  long		 *msg,
					int		 index,
					struct GRobj_env *solid,
					struct GRobj_env *offsetSol ));

extern  long VDdrwBatSolidsFromData __((  long		 *msg,
					struct GRobj_env *dvSol,
					long		 props,
					double		 offset,
					struct GRobj_env *solid,
					struct GRobj_env *offsetSol ));

extern  long VDdrw_get_globInfo   __((  long		 *msg,
					char		 *queue,
					char		 *login,
					char		 *passwd,
					IGRboolean	 *procType,
					struct GRid	 *locateWin ));

/*
 ***************************************************************************
 * Macros used to interact with control data for batch processing of drawing
 * views.
 */

/*+Me
  External Macro vd$drw_batch_process

  Abstract
	This macro is used to get the number and indices of drawing views
	which have the given status.


  Arguments
	long		*msg		(O)	return code
	VD_drwViewStatus procSts	(I)	drawing views having
						this process status are needed.
	int		*nbDwgViews	(O)	no. of dwgviews of the given status
	int		**list		(O)	Valid indexes.

	
  Examples

	VD_drwViewStatus	procSts	= VD_B_drwCopyFinished ;
	int			nbDwgViews;
	IGRint			*list = NULL;

	sts = vd$drw_batch_process(	msg		= &msg,
					procSts		= procSts,
					num_dwg_views	= &nbDwgViews,
					list		= &list );

	The 'list' contains the occurrence of drawing view with needs to
	start from preprocessing.

	.
	.
	.
	if ( list ) free ( list );

  Status/Return Code
	OM_S_SUCCESS    : if everything goes well
	OM_W_ABORT      : otherwise
-Me*/

#omdef vd$drw_batch_process(	msg,
				procSts,
				num_dwg_views,
				list )
       VDdrw_batch_process( (msg), (procSts), (num_dwg_views), (list) );

#endomdef

/*+Me
  External Macro vd$drw_list_extract

  Abstract
	This macro is used to get the number and indices of drawing views
	which need to be extracted.


  Arguments
	long		*msg		(O)	return code
	int		*nbDwgViews	(O)	no. of dwgviews to be extracted
	int		**list		(O)	Valid indexes.

	
  Examples

	int			nbDwgViews;
	IGRint			*list = NULL;

	sts = vd$drw_list_extract(	msg		= &msg,
					num_dwg_views	= &nbDwgViews,
					list		= &list );
	.
	.
	.

	if ( list ) free ( list );


	The 'list' contains indices of drawing view which needs to
	be extracted.

  Status/Return Code
	OM_S_SUCCESS    : if everything goes well
	OM_W_ABORT      : otherwise
-Me*/

#omdef vd$drw_list_extarct(	msg,
				num_dwg_views,
				list )
       VDdrw_list_extract( (msg), (num_dwg_views), (list) );

#endomdef




/*+Me
  External Macro vd$drw_batch_info

  Abstract
	This macro is used to set/get information from the total batch
	process or from a specific drawing view.

  Arguments
	long		*msg		(O)	return code
	int		set_inq		(I)	process mode.
	int		index		(I)	drawing view index.
	long		type		(I)	process-type.
	VDdrwBatchInfo	*info		(I/O)	Information to handle.

  Examples

	long		type =	VD_B_drw_Solid | VD_B_drw_SetupFile |
				VD_B_drw_SolOffset ;
	VDdrwBatchInfo	info;

	sts = vd$drw_batch_info(	msg	= &msg,
					set_inq	= VD_B_drw_INQUIRE,
					index	= list[i],
					type	= type,
					info	= &info );

  Status/Return Code
	OM_S_SUCCESS    : if query is TRUE.
	OM_W_ABORT      : otherwise
-Me*/

#omdef vd$drw_batch_info(	msg,
				set_inq = VD_B_drw_INQUIRE,
				index,
				type,
				info )
       VDdrw_batch_info(  (msg), (set_inq), (index), (type), (info) );

#endomdef

/*+Me
  External Macro vd$drw_solids_from_index

  Abstract
	Given an index this macro gets solid and offset solid 
	( solid after offsetting ) of the dwg view which need to 
	be used for locate and section cuts.


  Arguments
	long		  *msg		(O)	return code.
	int		  index		(I)	drawing view index.
	struct GRobj_env  *solid	(O)	solid before offsetting.
						= NULL, if not needed.
	struct GRobj_env  *offsetSol	(O)	offset solid for the drawing
						view.
						= NULL, if not needed.

  Examples

  Status/Return Code
	OM_S_SUCCESS    : if all goes well.
	OM_W_ABORT      : otherwise
-Me*/

#omdef vd$drw_solids_from_index(  msg,
				  index,
				  solid = NULL,
				  offsetSol = NULL )
       VDdrwBatSolidsFromIndex(  (msg), (index), (solid), (offsetSol) );

#endomdef


/*+Me
  External Macro vd$drw_solids_from_data

  Abstract
	Given the data of dwg view such as solid, props, offset
	this macro gets solid and offset solid ( solid after offsetting )
	of the dwg view which need to be used for locate and section cuts.

  Arguments
	long		  *msg		(O)	return code.
	struct GRobj_env  *dvSol	(I)	id of the solid which
						need to used for getting solid.
						This is solid field in
						VDdrwBatchInfo(see vdbatdrw.h).
						It is either dwg view, solid,
						vvol. mdlView.
	long		  props		(I)	props of dwg view.
						This is props field in
						VDdrwBatchInfo(see vdbatdrw.h).
	long		  offset	(I)	offset for the dwg view solid.
						This is offset field in
						VDdrwBatchInfo(see vdbatdrw.h).
	struct GRobj_env  *solid	(O)	solid before offsetting.
						= NULL, if not needed.
	struct GRobj_env  *offset_sol	(O)	offset solid for the drawing
						view.
						= NULL, if not needed.

  Examples

  Status/Return Code
	OM_S_SUCCESS    : if all goes well.
	OM_W_ABORT      : otherwise
-Me*/

#omdef vd$drw_solids_from_data(  msg,
				 dv_sol,
				 props,
				 offset,
				 solid = NULL,
				 offset_sol = NULL )
       VDdrwBatSolidsFromData(  (msg), (dv_sol), (props),
				(offset), (solid), (offset_sol) );
#endomdef


/*+Me
  External Macro vd$drw_get_globInfo

  Abstract
	Gets the global information of batch extraction such as
	queue name, login, passwd, process status and locate window.

  Arguments
	long		  *msg		(O)	return code.
	char		  *queue	(O)	queue name
						= NULL, if not required
	char		  *login	(O)	local login
						= NULL, if not required
	char		  *passwd	(O)	passwd for login
						= NULL, if not required
	IGRboolean	  *procType	(O)	process Type
						= NULL, if not required
	struct GRid	  *locateWin	(O)	locate window
						= NULL, if not required

  Examples


  Status/Return Code
	OM_S_SUCCESS    : if all goes well.
	OM_W_ABORT      : otherwise
-Me*/

#omdef vd$drw_get_globInfo(	msg,
				queue = NULL,
				login = NULL,
				passwd = NULL,
				process_type = NULL,
				locate_win = NULL )
	VDdrw_get_globInfo(	(msg), (queue), (login), (passwd),
				(process_type), (locate_win) );
#endomdef

#endif

