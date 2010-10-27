/* $Id: vdbatdrw.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdinclude/vdbatdrw.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdbatdrw.h,v $
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
 * Revision 1.2  1996/06/07  05:53:30  pinnacle
 * Replaced: vdinclude/vdbatdrw.h for:  by rgade for vds.240
 *
 * Revision 1.1  1995/07/25  21:04:38  pinnacle
 * Created: vdinclude/vdbatdrw.h by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/25/95	adz		creation date
 *
 ***************************************************************************/

#ifndef   vdbatch_drawing_include
#define   vdbatch_drawing_include

/*
 * include file for batch extraction of drawings
 */

/*
 ***************************************************************************
 * The interaction types with the control object.
 */
#define	VD_B_drw_INQUIRE	1	/* Get information */
#define	VD_B_drw_SET		2	/* Set information */

/*
 ***************************************************************************
 * The interaction attributes with the control object.
 */
#define	VD_B_drw_DrwView		0x0001
#define	VD_B_drw_SolProp		0x0002
#define	VD_B_drw_Solid			0x0004
#define	VD_B_drw_SetupFile		0x0008
#define	VD_B_drw_Layer			0x0010
#define	VD_B_drw_SolOffset		0x0020
#define	VD_B_drw_3dVw			0x0040
#define	VD_B_drw_2dVw			0x0080

#define	VD_B_drw_ProcSts		0x0100

#define	VD_B_drw_NbDrwView		0x1000
#define	VD_B_drw_Queue			0x2000
#define	VD_B_drw_Login			0x4000
#define	VD_B_drw_Passwd			0x8000

/*
 ***************************************************************************
 * List of existing process stages to walk though to process 
 * interactively and in batch.
 * When new processes are added in the structure, it needs to be added 
 * in sequential order.
 */
enum	VD_e_drwViewStatus {

	VD_B_drwInitialSts	, /* initial status of drawing view	*/ 
	VD_B_drwLocObjects	, /* Location process of objects.	*/
	VD_B_drwLocFinished	, /* Locate of objects is finished	*/
	VD_B_drwCopyObjects	, /* Copy the object to local file.	*/
	VD_B_drwCopyFinished	, /* Copy process finished		*/
	VD_B_drwConnectToSet	, /* Connect the object to control	*/
	VD_B_drwCopySolid	, /* Copy volume to control object	*/
	VD_B_drwSetVisualInfo	, /* Store the visualization info	*/
	VD_B_drwPreFinished	, /* Preprocessing is finished		*/
	VD_B_drwSectProcess	, /* Apply the intersection process	*/
	VD_B_drwSectFinished	, /* Intersected process finished	*/
	VD_B_drwVisCreate	, /* Construct drawing data structure	*/ 
	VD_B_drwVisexecute	, /* Apply the visualization process	*/ 
	VD_B_drwVisFinished	  /* Visualization process finished	*/

};

typedef	enum	VD_e_drwViewStatus	VD_drwViewStatus;

/*
 ****************************************************************************
 * structure which holds all the information of dwg view for batch extraction.
 */
struct  VD_s_drwBatchInfo {
	struct	GRid	  dv;		/* object id of drawing view */
	IGRlong		  props;	/* flag which indicates the volume to
					 * be used for copying objects from
					 * reference files to active file.
					 * i.e., dwgView or solid or view volume
					 * or model view.
					 * Also contains status of the drawing
					 * view ( VD_EXTR_NEW, OK, ERR ).
					 * Also contains VD_EXTR_EXTR when
					 * user selects dwgView to be selected.
					 */
	struct  GRobj_env solid;	/* object id of dwgView/solid/ViewVol
					 * /ModelView for copying objects
					 */
	IGRchar		  setupFile[15]; /* setup file for extraction */
	IGRshort	  layer;	/* layer where objects are copied to */
	IGRdouble	  offset;	/* offset while copying objects */
	IGRlong		  error;	/* error no. in case there is an error
					 * durng extraction
					 */
	VD_drwViewStatus  procSts;	/* Process status of the drawing view.
					 * ( VD_B_drwLocObjects etc. )
					 */

	IGRchar		  drw3dVw[20];	/* The 3d visualization object */
	IGRchar		  drw2dVw[20];	/* The 2d visualization object */

};

typedef	struct	VD_s_drwBatchInfo	VDdrwBatchInfo;

/*
 ***************************************************************************
 * The following solid type, status of drawong view, extract bit
 * are properties of a dwg view. They are stored in 'props' of
 * instance data for each drawing view
 */

/*
 * Type solid used for copying objects from ref file to active file
 */
#define  VD_DV		0x1
#define  VD_SOLID	0x2
#define  VD_VV		0x4
#define  VD_MDLV	0x8

/*
 * status of drawing view
 */
#define  VD_EXTR_NEW	0x10
#define  VD_EXTR_OK	0x20
#define  VD_EXTR_ERR	0x40

/*
 * extract the drawing view
 */
#define  VD_EXTR_EXTR	0x100

/*
 * process types
 */
#define  VD_BATCH_PROC  1
#define  VD_INTER_PROC  0


#endif
