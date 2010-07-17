/*d-----------------------------------------------------------------------------


        Class Name:     VLcoToAlCmd

	Prefix:		This command (convert elements to Alma's
			interface format ) has evolved over a couple of
			years from a simple ppl command that had had at
			least 3 authors into a multi-file COB command
			with form and specialised locate.  There has
			NEVER been a clear SPECIFICATION of what it's
			supposed to convert and how, either from
			Intergraph Personnel or from customers.  Most of
			the feedback has command from benchmarks or beta
			tests, this has resulted in several rewrites
			of the basic structure of the command.  Due to
			this uncertainty a lot of code which is probably
			redundant, has been left in place until someone
			can once and for all decide what's going on.  So
			to anyone maintaining this code, GOOD LUCK!  
			PW '94

        Abstract:       Convert elements to Alma

                        Jan. '93 convert from JLL's PPL
			Feb. '93 change from command that looks for a
				graphic group to one that looks for the
				nci_macro srf_unwrap ie an flattened
				surface.
			May. '93 add logic to translate planar plates as
				these do not need to be unwrap and can
				thus be translated directly.  At the
				request of Regis + Jan Lunde add the
				ability to generate an *.ini file for
				each combination of material grade plus
				plate thickness eg generate files such
				as A42_10mm.ini = grade A42 of 10 mm.
				Having lots of open files could be a
				problem, so restrict to MAXOFILES for
				the time being.  As the person from Alma 
				couldn't say what the init_file is about
				this function has been disabled.  A master
				file is created the same way as the *.ini
				the output is usually generic apart from
				parameters linked to the thickness, so the
				user is expected to modify the master file
				data afterwards using the cpalma software.

			'94
				Request from customers for more control
				over what type of elements to locate and
				for log files etc, has led to the
				development of an internal locate filter.
				These changes, along with the amount of
				globals that this command appears to
				have acculmulated over the years, has
				forced me to change the interface from
				simple prompts to a form, where the user
				can specify various parameters.


				Below is the header taken from the
				original PPL command object.  Most
				functions were converted to messages and
				any necessary global data was put into
				instance.  Most methods for converting
				non-linear geometry are no longer needed
				for srf_unwrap, but have been left in
				the command object for compatibility and
				future use...

NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC

NAME
   alma.u

DESCRIPTION
  This command reads EMS geometry from a srf_unwrap ncimacro and produces 
  a file for input into the ALMA nesting package.

HISTORY

       Author     Date          Description
       ------     ----          -----------
       kpl       2/28/90        updated for ALMA use
       jll       2/4/91         rewritten, fix bugs, 
				 . convert bsplines in a series of bezier arcs
				 . add ellipse.
       PPCfp	 05/06/92	fix bugs, added :
				 . read develop results
				 . attributes management
				 . circle approximation option
				 . rimbaud file creation
       PPCfp	 25/06/92	modified user interface

	LLC	 06/07/92	for composite curve GetAttribOfObj is perform
				on each component.

	LLC 	 06/07/92	Impose filter on components of graphic group
				. take edge of marking line
				. take composite curve for external edge.
				 
ALGORITHM
  o The user is prompted for an input file name - this should be an ASCII file
   and srf_unwrap objects
  o The software scans a cell for elements belonging to the following classes:
      GRlinear
      GRcircle
      GRcirarc
      GRellipse
      GRellarc
      GRsubbc
      GRcomposite 

  o Each element is evaluated and different information is gathered for the
    various element classes:

      GRcircle  - center point, radius
      GRcirarc  - end points, radius,center point
      GRlinear  - end points
      GRsubbc   - stroked into line segments using chordal height tolerance
      GRcomposite   - broken up into its member elements

  o The information for each element is written to an ASCII file.  The format
    of this file is as follows:

    (see ALMA documentation for details)




   NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC 
------------------------------------------------------------------------------*/

command_string  VLC_M_CONVERT_TO_ALMA, 0, VLCoToAl
command_table   "vl.cmd"
class           VLcoToAlCmd
super_class     VLlocateCmd
product_name    "$LOFT"
status_display  "VLrimbaud", "-1", "-1"

start_state     FILLINFORM		/* was GETCIRCLESTATE	*/

specification		/* SPEC starts here *****************************/

#define	MATL_SIZE	20	/* no of characters as defined by Alma   */
#define	GRADE_SIZE	20	/* no of characters as defined by Alma   */
#define MAX_PREFIX      10		/*c keeps filename down to 14 chars  */
#define VL_FORM_MODIF	112

instance {

IGRboolean	autofile;	/* are filenames generated automatically */
IGRboolean	LogFile;	/* is a log file required ?		 */
char 		fileprefix[MAX_PREFIX]; /* current filename prefix	 */
char **		fileprefixes;		/* list of all files open	 */
char *    	master_fileid;  /*c FILE* for all Alma stuff		 */
char *    	init_fileid;	/*c FILE* for all Alma stuff		 */
char *    	ini_fileid;	/*c FILE* for all Alma stuff		 */
char *		LogFileId ;	/*  FILE* to log file for this session   */
char **    	ini_files;	/*c .ini FILEs for all Alma stuff	 */
char **    	master_files;	/*c .rin FILEs for all Alma stuff	 */
int		no_files;	/* no of files currently open		 */
int		curfile;	/* file currently in use		 */
char * 		SdlContexts;    /* VLsdlContextstrudel contexts for each file*/

IGRboolean	planar_plate; 	/* Is it flat(planar)or flattened(unwrap)*/
IGRboolean	circleapprox; 	/* circle approximation or not		 */
IGRboolean      tooling;        /* 0 cutting , 1 marquing		 */
int		TransTypes;	/* bitmap of types to locate for translation */
struct GRid	Coord;		/* Coord system for located object	 */
IGRdouble	epaisseur;	/* Thickness of plate			 */
IGRchar		material[MATL_SIZE];	/* Type of MATERIAL		 */
IGRchar		grade[GRADE_SIZE];	/* Material GRADE		 */
IGRint		aStatus;		/* Approval status		 */
IGRchar		name[DI_PATH_MAX];	/* name of current plate	 */
IGRdouble	tmat[9];		/* transformation matrix	 */
IGRdouble	scale ;			/* transformation scale		 */
IGRvector	transv;			/* transformation vector	 */
IGRmatrix	RefMatrix ;		/* matrix applied to ref. file	 */
IGRshort	RefMatType;		/*  this above matrix's type	 */
struct GRid *	topMarks;		/* list of marks on top of plate */
struct GRid *	botMarks;		/* list of marks on bottom of plate */
IGRint		numTopMarks;
IGRint		numBotMarks;
IGRboolean	whichSide;		/* side of plate to process, this
					   usually depends on the no. of marks*/
struct edgeAttrib       {
	struct GRid     macOcId;
	char            type[3];
	double          angle1,angle2;
				}edgeAt;	/* edge attributes */
}

implementation

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include <stdio.h>
#include <sys/stat.h>
#include "FI.h"
#include "madef.h"
#include "AS_status.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "exmacros.h"
#include "grmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "growner.h"
#include "nddef.h"
#include "vsplatedef.h"
#include "vsbmaxisdef.h"
#include "vsdrwapi.h"
#include "vsdrwmacros.h"
#include "vlstructure.h"
#include "vlsdldef.h"
#include "vlsdl.h"
#include "vlsdlmacros.h"
#include "vlmsg.h"

#include <time.h>		/* to get today's date		*/

/************************** internal definitions************************/

#include "vlalma.h"

/************************** internal definitions************************/

/********************** for DEBUGGING*********************************

#ifndef CONVTOALDEBUG

#define CONVTOALDEBUG 1

#define vsDEBUG         1
#define vserrDEBUG      1

#endif

********************** end DEBUGGING*********************************/

#include "vldbgmacros.h"

/*c     External Functions ****/
/*c defined in include files */

#include	"maidmx.h"

/*c *************** External Methods ***********************/


/*c     Extern variables ***/
  extern OMuword        OPP_VSimgFeature_class_id,
                        OPP_VSplate_class_id,
                        OPP_VSbeam_class_id,
                        OPP_VLunwrap_class_id,
                        OPP_VLjigObj_class_id ,
                        OPP_VLstfnrTpl_class_id ,
			OPP_VLtplMgr_class_id;

/*c  ***********   one global external func.. ***/

extern int VLrimbActHandler() ;

extern void GRstatus_display_button(int on) ;

/*c     Define the state transitions... *****/

state_table

/***************** definitions & includes for the state table     ******/

#include	"OMerrordef.h"
#include        "vlmsg.h"
#include        "vltemplate.h"
#define		FALSE	0


/*c***************************************************************
	1st state prompts user to see if circular approximation is to be used
	for elliptical elements.  The default should be yes.  This can be
	overriden using the form, but is still used as the initial interface
	to the command and as the link between the command's setup and locate
	states.
	**********************************************************/

state FILLINFORM		/*GETCIRCLESTATE*/
	message_key	VL_S_CONVERT_TO_ALMA

	prompt		"Fill-in form or reset to locate"
        status_key      VL_S_STATUS_FORM   
	filter		wfi


	on NULL_STRING	state .

	on STRING or EX_RJT_MOVEON

			state GETCOMPONENTS 

/*	on CLEAR_STACK
			state terminate
	on ELSE		state .  */

/*c****************************************************************
	2nd state prompts user to locate the objects  whose geometry will be 
	examined and written into the "toto".ini file (Rimbaud definition).
	default types to be located are defined here, these can be overriden
	using the list on the form VLrimbaud.  Normally these object are flat
	as Rimbaud only deals with 2D objects.
	******************************************/

state GETCOMPONENTS
	message_key	VL_S_CONVERT_TO_ALMA
        prompt_key	VL_P_ALMA_ELEMENT
        accept_key      VL_M_ELEMENT
        status_key      VL_S_CLOSE_FILES

        locate_eligible       "+VSplate,VSbeam,VSimgFeature,VLjigObj,VLstfnrTpl,VLtplMgr,VLunwrap"

        locate_properties     "LC_LC_ONLY | LC_DP_ONLY 	| LC_PLANAR_ONLY |LC_RW"


        locate_owner            "LC_RIGID_COMP |LC_RIGID_OWNER 
                                |LC_FLEX_OWNER   LC_FLEX_COMP |
                                 LC_REF_OBJECTS "
        filter                  locate

	on GR_UNKNOWN_TYPE.VL_FORM_MODIF	state .

        on EX_RJT_MOVEON        do CloseFiles()
				state previous_state

	on EX_BACK_UP		state previous_state

        on EX_OBJID or EX_DATA	do VLstoreLocate( &me->ret )
				do VLstoreResponse( &me->ret )
                                do VLstoreList( &me->ret, FALSE, 1)
                                do VLloadCst( &me->ret )
                                do VLcoToAlCmdma( &me->ret )

/** per TR request all messages processed inside command
                                on RETURN_CODE =  OM_S_SUCCESS
                                   do status_key  VL_S_CONVERTED
                                   	state .
****/
                                state .



at init do InitInstance()

at delete do CloseFiles()
	  do FreeSpace()

/*c***********  That's all of the state table folks 		****/

/***	the following methods, concerned with converting specific
	geometry into a form that Rimbaud understands, are in defined in
	VLConGeomi.I,VLConTempli.I,VLConPlatei.I,VLConMisci.I
****/
/******************************************************************************/
action sleep {

        // Remove keywords
  	VSdrwRmFunctions ();

	/* Execute method sleep of upper class */
	me->ret = om$send ( msg      = message VLlocateCmd.sleep (pos),
			    mode     = OM_e_wrt_message,
			    targetid = my_id );
	as$status(sts = me->ret);

	status = OM_S_SUCCESS;
	goto quit;
}

action AngleBet2Vecs (
        IGRdouble       *v1;
        IGRdouble       *v2;
        IGRdouble       *vz;
        IGRdouble       *angle ) extern


			/*++ next external action  ++*/

action TranslateLine (	struct GRid GRid_obj /* line to convert */ ) extern


			/*++ next external action  ++*/

action TranslateArc (	struct GRid     GRid_obj )	extern


			/*++ next external action  ++*/

action TranslateEllipse (	struct GRid     GRid_obj )	extern


			/*++ next external action  ++*/

action TranslateEllipArc (	struct GRid     GRid_obj )	extern


			/*++ next external action  ++*/

action TranslateCircle (	struct GRid     GRid_obj )	extern


			/*++ next external action  ++*/

action TranslateBSCurve (
struct GRid  	    *   GRid_obj;       /* the objid of the spline to convert*/
struct IGRbsp_curve * inspline          /* NULL or the geometry of the spline*/
			)	extern


			/*++ next external action  ++*/

action ConvertCompCurve (	struct GRid *	GRid_obj;   /*I:ptr to composite curve*/
			IGRint        fl_att /* I:flag on how to handle the curve */ )	extern


			/*++ next external action  ++*/

action FindTypeThenConvert(  struct GRid * GRid_obj;  /* I: object to convert*/
			     IGRint         fl_att  /* I: attributes */ ) extern


			/*++ next external action  ++*/

action ProducePascalForm (		IGRint          order;
			IGRdouble       *tpas )			extern


			/*++ next external action  ++*/

action pococv_pcr (	IGRint          idim;
			IGRdouble       *poles;
			IGRint          order;
			IGRdouble       *coefs )		extern


			/*++ next external action  ++*/

action GetAttribOfObj (	struct GRid ObjectId ;	    //I: object to check attribs
			int	*   NumEdgeAtts     //O: the num of edge atts 
			)			extern


			/*++ next external action  ++*/


action WriteAttrib (	struct GRid GRid_obj)			extern


			/*++ next external action  ++*/

action	LineStrToCurve (
struct GRid		* inLineString;	   /* IN:  lineString id or     */
struct IGRbsp_curve	*  inLSbyGeom      /* IN: lineString by geom    */
			)					extern


			/*++ next external action  ++*/

action  ApplyCirApprox (
	struct GRobj_env    *   TEMP;	      /* obj env of incoming curve or*/
	struct IGRbsp_curve * inspline        /* geom of incoming curve	*/
			    )		extern 


			/*++ next external action  ++*/

action GetEdges(
/******************************************************************************
*
* message GetEdges : recupere les composant d'un sucesseur de GRowner
*
*
*				pour EMS version 1.4.0
* Entrees :
*	- GRid du groupe 
*
* Sorties : 
*	- Tableau de GRid des elements du groupe
*	- nb d'element dans le groupe
*	- rend   OM_S_SUCCESS si ok , MSFAIL sinon
*
* Dependances : 
*	- mydef.h
*	- message GRowner.GRget_number_components
*	- message GRowner.GRget_components
*	- define :  CONVTOALDEBUG
*
* Algorithme : 
*	- met a jour  LEVEL_TO_OBJECT_INDEX  et OBJECT_NUMBER 
*	- verifie que OBJECT_NUMBER<400
*
*******************************************************************************/

struct	GRid	UnWrap_id;
struct	GRid	**edge_ids;
IGRint		*numObjects ) extern


			/*++ next external action  ++*/

action EcritDansFichierINI(
/******************** EcritDansFichierINI = write file INI :

	For each located object, write out the 
	header and data for each element found. 
*****************************************************************************/
	
IGRchar		*dpr_name;
struct GRid	UnWrap_id )	extern


			/*++ next external action  ++*/

action writeToMaster
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*

	Method to write out name and attributes to the alma master file 

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

( IGRchar * objectName /* I: name of object to convert */ ) extern


			/*++ next external action  ++*/

action VLcoToAlCmdma
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*

	Method to go through list of located elements to see if these can be
	converted, current support elements are only unwrap (unfolded) 
	objects, flat Struct plates and Man jigs.

******************************************************************************/
( IGRlong *l_ret )	extern


			/*++ next external action  ++*/


action ProcessPlate
/****+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*

	Get name and parameters of a plate, then translate its geometry
	by 1st using the range of the outer edge (1st in loopset) to
	define a plane, get the transformation information to go from
	this plane to the xy plane at 0,0 then map the geometry onto the
	xy plane.

****+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

(
	struct GRid *	plate;	/* incoming plate */
	IGRint 		index 	/* incoming index into list of located objs */
)  extern


			/*++ next external action  ++*/


action GetPlateAttribs
/**************** get plate attributes ***************************************

	Given a plate as a grid, find out its thickness, material etc

***************** get plate attributes ***************************************/

(
	struct GRid *	plate;	/* incoming plate */
	IGRint 		indx 	/* incoming index into list of located objs */
)	extern


			/*++ next external action  ++*/

action FindPlate
/**************** find plate ******************++++++++++++++++++++++++++++++++

	Given an object in a grid see whether its a pretend, if it is try and 
	find the real object, usually a plate, underneath.

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++**********/

( struct GRid * surf /* incoming object surf,plate... */ ) extern


			/*++ next external action  ++*/


action ProcessMarks (
/*============================================================================*/
/*		ProcessMarks:  go through the list of dependent elements
		for an object, usually the base of a planar plate, and see
		if these are linear elements, if so treat them as marking lines.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

  struct GRid * lmarks;		/* list of marks to find geometry */
	 int	number		/* number of marks in the list    */
	)	extern


			/*++ next external action  ++*/

action ProcessJig
/*============================ process a Man jig object   ====================*/

(
	struct GRid *	jig ;	/* incoming plate jig */
	IGRint 		index 	/* incoming index into list of located objs */
)	extern


			/*++ next external action  ++*/


action RangeToxyPlane( 
/************++++++++++++++++++++++++ RangeToxyPlane	***********************

	Give a (planar) graphic object, use its range to define the plane of its
	geometry, then calculate the matrix to map the geometry onto the 
	xy plane with origin at 0,0.
----------------------------------------------------------*********************/


	struct GRid * graphic		/* planar graphic object to convert */
		)	extern


			/*++ next external action  ++*/

action FindSuccessors(
/************************

	FindSuccessors:  given a plate, find the number of marks, control and
			  roll lines that are attached.
*******+++++++++++++++++++++++++++++++++++++++++++++++++**********************/


struct GRid *	plate;		/*I:	id of plate/surface to interrogate */
int	    	whichType;	/*I:	looking for marks=0 otherwise plates */
int	    *	topmarks;	/*0:	no of marks on top surface	*/
int	    *   botmarks	/*0:	no of marks on bottom surface	*/ ) extern

/*******+++++++++++++++++next external action +++++++++++**********************/

action ProcessName( IGRchar * typeName;	      /* I: TypeName for formatting */
		    struct GRid * plate	      /* I: plate/object with name */
						/* given a plate or similar,
						find its name or build one from
						the object id */ ) 	extern

			/*++ next external action  ++*/

action ProcessTemplMgr 
/****************************************************************************
        Given a template manager, find and translate all the templates that
        it manages..
******************************************************************************/
( struct GRid * templateMgr ) extern

			/*++ next external action  ++*/

action ProcessTemplate
/****************************************************************************
	Given a template convert its graphic feet to neutral file format
*****************************************************************************/
 ( struct GRobj_env * template ) extern


			/*++ next external action  ++*/

action ProcessStiffTemplate
/****************************************************************************
	Given a stiffener template convert its graphic feet to neutral ini file 
*****************************************************************************/
 ( struct GRobj_env * template ) extern


			/*++ next external action  ++*/


action ProcessFlatBar
/*============================ process a flat bar object  ====================*/

(
	struct GRid *	bar ;	/* incoming flat bar */
)	extern

			/*++ next external action  ++*/

action ProcessSurf
/*============================ translate a surf object  ====================*/

(
	struct GRid *	surf;		/* incoming surf bar */
	GRobjid *	LoopIds;	/* incoming loops of surf */
	int		NumLoops	/* number of loops for surf */
)	extern

/*=====		find orientation and scale of flat plate ====================*/

action VLOrientScaleFlatPlate(
        struct GRobj_env        *FlatPlate;
	struct mise_a_plat 	*FlatSurf;
        double                  *ScaleMatrix ;
        int                     TypeOfExpansion;
        double                  ExpansionInX,
                                ExpansionInY;
        struct GRmd_env         *CurEnv;
        struct GRvg_construct   *VgCst )	extern

/*=====		get list of loops for a surface ====================*/

action GetSurfLoops( struct GRid * surfGrid     /*I: the surface to convert*/ ;
                        GRobjid **  LoopIds     /* ptr to list of loop ids */ ;
                     int        *   NumLoops    /* no of loops returned    */
		)  extern 

/*=====		form interface method	====================*/

action form_notification extern

/**++++++	actions concerned with flow of the command are below +++++*****/

action InitInstance ( )		/* init instance data ********/
{

 int i;
 IGRlong	RetMes	= OM_E_INVARG  ;

 me->StatusDisplay = TRUE ;

		// if in debug mode save/restore will stop any output 

 #ifdef vsDEBUG

  if ( me->status_display_form_ptr )
 			 FIf_cvrt_to_perm_win ( me->status_display_form_ptr );
	
 #endif
		// set the default types to be located, only flat objects 

 me->TransTypes =	FlatPlates | Flattened | PlateTempls | 
			StiffTempls | FlatBars | PinJigs ;

 __DBGpr_int( "TransTypes", me->TransTypes ) ;

			// set up the action handler

 me->action_handler = (char (*)())VLrimbActHandler ;
 me->action_args    = (char*)&me->TransTypes;

 me->circleapprox  = TRUE ;
 me->LogFile	   = FALSE;
 me->LogFileId	   = NULL ;

 me->master_fileid = NULL;
 me->init_fileid   = NULL;
 me->ini_fileid    = NULL;
 me->Coord.objid   = NULL_OBJID;
 me->tooling	   = 0; 		// cutting
 me->autofile	   = TRUE ;		// don't expect user to type in name
 me->curfile	   = FALSE;		// haven't opened a file yet
 me->no_files	   = 0;

			// stay at one until multi files is resolve in Strudel
 me->SdlContexts  = om$malloc( size = sizeof(VLsdlContext));
 if ( !me->SdlContexts ){status = OM_E_NODYNMEM ; goto wrapup ; } 
 else {
	VLsdlContext * CtxCast = &(((VLsdlContext*)(me->SdlContexts))[0]) ;
	CtxCast->systTxt.out = NULL ;
	CtxCast->stateArgs   = NULL ;
 }
					// used ini file pointers
 me->ini_files	   = (char**)om$malloc( size = (MAXOFILES)*sizeof(char *));
 if ( !me->ini_files )	{ status = OM_E_NODYNMEM ; goto wrapup ; } 

					// used master file pointers
 me->master_files  = (char**)om$malloc( size = (MAXOFILES)*sizeof(char *));
 if ( !me->master_files ) { status =  OM_E_NODYNMEM ; goto wrapup ; }

					// pters to prefixes
 me->fileprefixes  = (char**)om$malloc( size = (MAXOFILES)*sizeof(char *));
 if ( !me->fileprefixes ) { status =  OM_E_NODYNMEM ; goto wrapup ; }

 for ( i=0; i<MAXOFILES; ++i) {
	me->ini_files[i] = me->master_files[i] = me->fileprefixes[i] = NULL;
 }

 me->fileprefix[0]    = '\0';

		// alloc space for floating list of welding lines
 me->topMarks = (struct GRid *)om$malloc( size = NUMMARKS*sizeof(struct GRid));
 me->botMarks = (struct GRid *)om$malloc( size = NUMMARKS*sizeof(struct GRid));

 if ( me->topMarks ) me->topMarks[0].objid = NULL_OBJID;
 else		   { status =  OM_E_NODYNMEM ;  goto wrapup ; } 

 if ( me->botMarks ) me->botMarks[0].objid = NULL_OBJID;
 else		   { status =  OM_E_NODYNMEM ;  goto wrapup ; } 

 me->numTopMarks =  NUMMARKS;
 me->numBotMarks =  NUMMARKS;
 me->whichSide = VS_K_baOnBotOfPlate ;

 me->RefMatType	= MAIDMX ;

 __DBGpr_int( "action handler addr", me->action_handler ) ;

 status = MAidmx( &RetMes, me->RefMatrix ) ;
 __CheckRC( status, 1, "MAidmx", quit ) ;

wrapup :
	return status ;

}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
	Message CloseFiles:
	If the file has been opened, write the end section (/END) when
	all the models and all the parts have been described.  Very
	important for the neutral file (Rimbaud: *.ini).
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

action CloseFiles( )
{
	int i;

	long ret = OM_E_INVARG ;

VLsdlContext * CtxCast = &(((VLsdlContext*)(me->SdlContexts))[0]) ;

  SetProc( CloseFiles ) ;  Begin 

  if (me->master_fileid != NULL)  {

      if ( me->autofile ) {
	for ( i=0; i< me->no_files; ++i ) {
	      if ( me->master_files[i] ) {
 		fprintf((FILE*)me->master_files[i],"/PLACEMENT\nnest/ \n");
 		fprintf((FILE*)me->master_files[i],"/END\n" );
		fclose( (FILE*)me->master_files[i]);
		me->master_files[i] = NULL ;
	      }
	      else { __DBGpr_int( "bad master file at", i ) ; }
	  }
      }
      else {
	fprintf((FILE*)me->master_fileid,"/PLACEMENT\nnest/ \n");
	fprintf((FILE*)me->master_fileid,"/END\n");
	fclose( (FILE*)me->master_fileid);
	me->master_fileid   = NULL ;
      }


  }	// if file.rin

  if (me->init_fileid  != NULL) {
	fprintf((FILE*)me->init_fileid,"end\n");
	fclose( (FILE*)me->init_fileid);
  	me->init_fileid  = NULL ;
  }

  if ( CtxCast->systTxt.out ) { 

	VLpinCorn       PinCorn ;
	VSdrwOutputData *outPutInit = NULL ;
	struct GRid Element ;

        ret = vl$sdlGetCol(   ctx     = CtxCast ,
                        colType = VLSDL_SYST_COL,
                        colId   = &Element );
	CheckRC( ret , 1 ) ;
	__DBGpr_obj( "syst col", Element ) ;


	for ( i=0; i< me->no_files; ++i ) {

        	// End of report (tail)
		vl$sdlSetState( ctx     = CtxCast ,
				state   = "vl-alma-tail" );

		CtxCast->systTxt.out = (FILE*)me->ini_files[i] ;
		__DBGpr_str( "fileprefix" , me->fileprefixes[i] ) ;
		strcpy( PinCorn.cp , strcat( me->fileprefixes[i], ".ini" ) ) ;
	        CtxCast->stateArgs  = &PinCorn ;

		status =  vs$drwExecConfig (      msg             = &ret ,
                                elmId           = &Element , 
                                elmEnv          = &me->Current ,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = "AlmaIni" ,
                                appData         = CtxCast ,
                                output          =  &outPutInit );
		CheckRC( status , ret ) ;

		fclose( (FILE*)me->ini_files[i]);
		__DBGpr_int( "closed", me->ini_files[i] ) ;
		me->ini_files[i] = NULL ;

		if(me->fileprefixes[i]) {
			__DBGpr_str( "closed", me->fileprefixes[i] ) ;
			om$dealloc(ptr = me->fileprefixes[i]);
			me->fileprefixes[i] = NULL;
		}

	}	// for all files in the list


  }		// if strudel active
  else 
	__DBGpr_com( "STRUDEL OUTPUT FILE NOT OPEN?" );


  me->no_files		= 0 ;			// clear globals
  me->ini_fileid	= NULL ;
  CtxCast->systTxt.out	= NULL ;
  CtxCast->stateArgs   = NULL ;

  if ( me->LogFileId ){
	fprintf( (FILE*)me->LogFileId , "conversion completed\n\n" );
	fclose( (FILE*)me->LogFileId );
	me->LogFileId = NULL ;
  }
  status = om$send( msg = message VLcoToAlCmd.status( "" ),
                        targetid   = my_id);
  __CheckRC( status, 1, "blank status", quit ) ;

  status = OM_S_SUCCESS;

  End

} /*c end close files */

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

action FreeSpace( )
{
        // Free memory
	// Close the ASCII file

  SetProc( FreeSpace ) ;   Begin

  if ( me->SdlContexts ) 
	om$dealloc( ptr = me->SdlContexts );

  if ( me->ini_files ) 
	om$dealloc( ptr = me->ini_files );
  
  if ( me->master_files ) 
	om$dealloc( ptr = me->master_files );

  if (me->fileprefixes)
	om$dealloc( ptr = me->fileprefixes );

  if ( me->topMarks )
	om$dealloc( ptr = me->topMarks );

  if ( me->botMarks )
	om$dealloc( ptr = me->botMarks );

  me->numTopMarks = me->numBotMarks = 0;

  status = OM_S_SUCCESS;

  End 
  goto quit ;

}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

action AutoFileName( )		/* set global flag to automatic filenames*/
{
    char * fp = me->status_display_form_ptr ;

	me->autofile = TRUE;	// generate filename from grade & thickness


	if ( fp ) {
	    status = FIfld_set_text( fp, FILEPREFIX, 0 , 0 , "", FALSE ) ;
	    __CheckRC( 1, !status, "FIfld_set_text", quit ) ;
	    status = FIg_disable( fp, FILEPREFIX ) ;
	    __CheckRC( 1, !status, "FIg_disable", quit ) ;
	}

  status = OM_S_SUCCESS;

}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
	Message savefilename:
	If given a valid file prefix, open each file and write the
	appropriate header data.
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

action SaveFilename( IGRlong * ret )
{
IGRchar		IniFileName[50],		//c name of *.ini Rimbaud file
		IniFileNamet[50],		//c name of *.int log file
		MasterFileName[50],		//c name of *.rin master file
		LogFileName[50];		//c name of *.rin master file
time_t          current_time;		    //c today's date in time format
char            time_string[30],	    //c date in character format
		*format_string;		    // date format, usually American
#define MAX_PREFIX (size_t)10		    //c keeps filename down to 14 chars
					/* if this is changed don't forget the
					   message file  ********/

		// cast from instance char * to sdlContext due to COB FILE probl
VLsdlContext * CtxCast = &(((VLsdlContext*)(me->SdlContexts))[0]) ;

  SetProc( SaveFileName ) ; Begin

  *ret =  OM_S_SUCCESS;

  time_string[29] = 0 ;

	/* check if the file name is shell compatible ie the prefix has up to
	   10 characters, so as to leave space at end for the 4 char suffixes
	***/

 if ( me->autofile ) {
	int i;

	strcpy( MasterFileName, me->fileprefix );
	__DBGpr_int( "numb of open files ", me->no_files ) ;

        for ( i=0; i< me->no_files; ++i ) 
	   if ( !strcmp( me->fileprefixes[i], me->fileprefix ) )break;

	if ( i >= me->no_files ) {	// file not in list 
		me->ini_fileid = NULL;
 		me->fileprefixes[i]  = om$malloc( size = 
						  (MAX_PREFIX+1)*sizeof(char ));
		if ( ! me->fileprefixes[i] )
					{status = OM_E_NODYNMEM ; goto wrapup ;}

		strcpy( me->fileprefixes[i], me->fileprefix );
		__DBGpr_str( "didn't find in list ",me->fileprefix );
	}
	else {
	   __DBGpr_str( "Found file ", me->fileprefix );
	   __DBGpr_str( "file should be", me->fileprefixes[i] );
	   me->ini_fileid = me->ini_files[i];
	   me->master_fileid = me->master_files[i];
	   if (me->LogFileId)
	 	fprintf( (FILE*)me->LogFileId,"ini file already open:%s\n",
								me->fileprefix);
	}	

 }
 else if ( strlen( me->fileprefix ) > MAX_PREFIX ) {
	/* too many characters so truncate to MAX_PREFIX then add null char
	   as strncpy doesn't add the end of string char *****/
 	strncpy(MasterFileName,me->event1.event.keyin, MAX_PREFIX );
	MasterFileName[MAX_PREFIX] = '\0';
        ex$message(  msgnumb = VL_E_MAX_PREFIX,
                        type = "%s%s",
                        var  = `me->event1.event.keyin,MasterFileName`,
                        buff = me->status );

        status = om$send( msg = message VLcoToAlCmd.status( me->status ),
                        targetid   = my_id);
 }
 else if ( ! strlen( me->fileprefix ) ) {
    status = om$send( msg = message VLcoToAlCmd.status( "No filename entered" ),
                        targetid   = my_id);

    strcpy( me->fileprefix, "noname" );
 }
 else
	__DBGpr_str( "file prefix", me->fileprefix ) ;

 if ( !me->fileprefixes[0] ) {
	// there will always be at least one file
	me->fileprefixes[0]  = om$malloc( size = (MAX_PREFIX+1)*sizeof(char ) );
	if ( !me->fileprefixes[0] ) { status =  OM_E_NODYNMEM ; goto wrapup ; }
 	strcpy( me->fileprefixes[0],  me->fileprefix ) ;

 }
		// global to local for manipulation 
 strcpy(MasterFileName, me->fileprefix );

 strcpy(IniFileNamet,MasterFileName );
 strcat(IniFileNamet,".int");
 strcpy(IniFileName,MasterFileName );
 strcat(IniFileName,".ini");
 strcpy( LogFileName,	MasterFileName );
 strcat( LogFileName,	".log");
 strcat(MasterFileName,".rin");

 if ( me->status_display_form_ptr ) {

	if ( ! me->autofile ) 	// if manual file names
 		FIg_enable( me->status_display_form_ptr, FILEPREFIX ) ;

	if ( me->fileprefix[0] ) {

	    FIfld_set_text( me->status_display_form_ptr, FILEPREFIX, 0 , 0 ,
							me->fileprefix, FALSE );
	    if ( me->LogFile )
		FIfld_set_text( me->status_display_form_ptr, LOGFILENAME, 0 , 0,
							  LogFileName, FALSE );
 	} // if have a file prefix
 }		// if have a form
 else
	__DBGpr_com( "NO STATUS FORM!!" ) ;

		// do check to see if file is creatable + writable

 if ( me->ini_fileid != NULL ) {

	__DBGpr_str( "File already in USE",me->fileprefix );
	goto quit ;
 }

#ifdef INITFILEUSED
	 else if((me->init_fileid=(char*)fopen(IniFileNamet,"a"))==NULL) {

		ex$message(  msgnumb = VL_E_FILEWRITE,
				type = "%s",
				var  = `IniFileNamet`,
				buff = me->status );

		status = om$send( msg = message VLcoToAlCmd.status(me->status ),
				targetid   = my_id);
		*ret = MSFAIL; 
		return OM_S_SUCCESS;
 }
#endif

// open fichier log   

   if ( me->LogFile && !me->LogFileId )  {
   
	__DBGpr_int( "log id", me->LogFileId ) ;
	__DBGpr_str( "opening log ", LogFileName ) ;


	if(( me->LogFileId=(char*)fopen( LogFileName, "a" ))==NULL ){

		ex$message(  msgnumb = VL_E_FILEWRITE,
				type = "%s",
				var  = `LogFileName`,
				buff = me->status);
		status = om$send( msg = message VLcoToAlCmd.status(me->status ),
					targetid   = my_id);
 		if (me->init_fileid) {
			fclose((FILE*)me->init_fileid);
			me->init_fileid = NULL ;
		}
		*ret = MSFAIL; 
		goto quit;
	}  // if opened log file

   } // if allowed to open a log file
     // else set to closed

   else	if ( !me->LogFile ) {
		me->LogFileId = NULL ;
		__DBGpr_int( "no log file required", me->LogFile ) ;
		__DBGpr_int( "log file id", me->LogFileId ) ;
   }	
//	STRUDEL initialisation stuff for this file
//
{
  VLpinCorn       PinCorn ;
  VSdrwOutputData *outPutInit = NULL ;
  struct GRid Element ;
  struct stat StatBuffer ;		// check size of ini file

    *ret = vl$sdlInit( ctx = CtxCast );
    __CheckRC( *ret, 1, "sdlInit", wrapup ) ;

        // Begin report
	//
    (*ret) = vl$sdlGetCol(   ctx     = CtxCast ,
                        colType = VLSDL_SYST_COL,
                        colId   = &Element );
    CheckRC( (*ret) , 1 ) ;
    __DBGpr_obj( "syst col", Element ) ;

    strcpy( me->Afile.pathName, IniFileName ) ;

    __DBGpr_str( "Afile.pathname", me->Afile.pathName) ;

    if ( ! me->ini_fileid ) {	// if don't already have a file

        	// Open output ASCII file
	*ret = vl$sdlOpenFile(	ctx     = CtxCast  ,
				file    = &( me->Afile ) );
	CheckRC( *ret, 1 ) ;

//	Each model is identified by a general header (/MO) with different
//	records which are written only one time for all the parts of this model
//	to be transfered.  Each record of the model contains an identificator
//	on the 1st line and one or several variables on the following lines.
//	First thing to do is to see if file already has a / at the start.



		// check opened ini file

      if (	NULL == CtxCast->systTxt.out ) {

		ex$message(  msgnumb = VL_E_FILEWRITE,
				type = "%s",
				var  = `IniFileName`,
				buff = me->status );
		status = om$send( msg = message VLcoToAlCmd.status(me->status),
					targetid   = my_id);
	
 		if (me->init_fileid) {
			fclose((FILE*)me->init_fileid);
			me->init_fileid = NULL ;
		}
 		if (me->LogFileId    ) {
			fprintf( (FILE*)me->LogFileId, "%s\n\n", me->status ) ;
			fclose((FILE*)me->LogFileId    );
			me->LogFileId = NULL ;
		}

 		if (me->master_fileid) {
			fclose((FILE*)me->master_fileid);
			me->master_fileid = NULL ;
		}

		*ret = MSFAIL;

		goto quit ;		// COB EXIT VIA QUIT 

    }  			// if unable to open file

    else		// ini_fileid and systTxt.out are one and the same
	me->ini_fileid  =  (char*)CtxCast->systTxt.out ; 

    stat(  me->Afile.pathName, &StatBuffer ) ;		// get file info 
    __DBGpr_int( "stat size ", StatBuffer.st_size ) ;

    if ( ! StatBuffer.st_size ) {	// if ini file empty need file header


	if (me->LogFileId)
	    fprintf( (FILE*)me->LogFileId, "New ini file:%s\n\n", IniFileName );

        // Title report
        vl$sdlSetState( ctx     = CtxCast ,
                        state   = "vl-alma-head" );

	strcpy( PinCorn.cp , IniFileName ) ;
        CtxCast->stateArgs  = &PinCorn ;


       status =  vs$drwExecConfig (      msg             = ret ,
                                elmId           = &Element , 
                                elmEnv          = &me->Current ,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = "AlmaIni" ,
                                appData         = CtxCast ,
                                output          =  &outPutInit );
	CheckRC( status , *ret ) ;
                                                        
     }	// if first time file opened 
     else
	__DBGpr_int( "file size ", StatBuffer.st_size ) ;

   }	// if need to open the ini file

   else {		// log the opening 
	
   	CtxCast->systTxt.out = (FILE*)me->ini_fileid ;
	me->curfile = TRUE;
	__DBGpr_int( "current file flag", me->curfile ) ;
   }



}	// strudel specific stuff




// open fichier maitre

    if((me->master_fileid=(char*)fopen( MasterFileName, "a"))== NULL ){

		ex$message(  msgnumb = VL_E_FILEWRITE,
				type = "%s",
				var  = `MasterFileName`,
				buff = me->status);
		status = om$send( msg = message VLcoToAlCmd.status(me->status ),
					targetid   = my_id);
 		if (me->init_fileid) {
			fclose((FILE*)me->init_fileid);
			me->init_fileid = NULL ;
		}
		if (me->LogFileId){
			fprintf( (FILE*)me->LogFileId, 	"%s\n\n", me->status );
 			fclose( (FILE*)me->LogFileId );
			me->LogFileId = NULL ;
		}
		*ret = MSFAIL; 
		goto quit ;
	}

 if ( me->autofile ) {
	me->ini_files[me->no_files] = me->ini_fileid;
	me->master_files[me->no_files] = me->master_fileid;
	me->no_files++;
 }
 else {
	me->ini_files[0] = me->ini_fileid;
	me->no_files	= 1 ;
 }

 __DBGpr_int( "\nOpened ini file idd", me->ini_fileid );

 if ( me->master_fileid ) {
 	if ( fgetc((FILE*)me->master_fileid) != '/' ) {
 		//c assume if file is open we can write without a problem

		fprintf((FILE*)me->master_fileid,"/REPERE\n\n");
		fprintf((FILE*)me->master_fileid,"/FICHIERS\n\n");
		fprintf((FILE*)me->master_fileid,"ppla.fic\n\n");
		fprintf((FILE*)me->master_fileid,"maint.fic\n");
		fprintf((FILE*)me->master_fileid,"sauve.fic\n\n");

		fprintf((FILE*)me->master_fileid,"/SCALE\n   1\n");

		fprintf((FILE*)me->master_fileid,"/TOLES\noffcuts/ \n");

		fprintf((FILE*)me->master_fileid,"%-32s %-32s\n",
						 "offcut",me->grade);
		fprintf((FILE*)me->master_fileid,
    "%4d%4d%4d %9d%9d %9d%9d%9d%9d %2.1f%4d\n %4d%4d%4d   \n",

    1,1,1, 10000,5000, 1,1,1,1, me->epaisseur, 0, 0,0,0 );
		 	
		
		fprintf((FILE*)me->master_fileid,
			"/ECA\n%7d%7d%7d%7d%7d%7d%7d%7d\n",
			20,20,  0, 0, 0, 0, 0, 0 );

		fprintf((FILE*)me->master_fileid,"/PIECES\nparts/ \n");

	} // if new or corrupted file

 } // if master file enabled


 if ( me->LogFileId ) {
	time( &current_time );
	format_string = "%D:%H:%M";			// unix U.S. date format
	cftime( time_string, format_string, &current_time );
	fprintf((FILE*)me->LogFileId, "%s\n",	time_string );
	__DBGpr_str( "date/time", time_string ) ;
 }

wrapup:

	End
	return status ;

} 	/* savefilename	*/

/*=========================================================================*/

action SeeIfApproxCircs( )
{

 if ( me->event1.event.keyin[0] == 'N' || me->event1.event.keyin[0] == 'n')
 {
   me->circleapprox = FALSE;
   if ( me->status_display_form_ptr ) {
	status = FIg_set_state_off( me->status_display_form_ptr , CIRCAPPROX  );
	__CheckRC( 1, !status, "FIg_set_state_off", quit  ) ;
   }
 }
 else {
   me->circleapprox = TRUE;
   if ( me->status_display_form_ptr ) {
        status = FIg_set_state_on( me->status_display_form_ptr , CIRCAPPROX  ) ;
        CheckRC( 1, !status ) ;
   }

 }

 status = OM_S_SUCCESS;

}	/* end check for circular approximation of curves */

action filter
{

  SetProc( myFilter ) ; Begin

	__DBGpr_int( "into local filter",filter );

  if ( filter == 3 ) { 	// it's a locate


     if ( me->locate_eligible_thing.w_count ) {  // classids have been defined

	char	ClassName[30] ;
	int	i = 0,
		sts = 0 ;

				// number of classids in the classlist
	OMuword * pcount = &me->locate_eligible_thing.w_count ;

	__DBGpr_int( "num classids", me->locate_eligible_thing.w_count ) ;

		// override the predefined values !!

	me->locate_eligible_thing.w_count = 0 ;

	if (  me->TransTypes & PlateTempls)  {
	     me->locate_eligible_thing.p_classes[*pcount] =
							OPP_VLtplMgr_class_id;
	     ++ me->locate_eligible_thing.w_count ;
	}

	if ( (me->TransTypes & FlatPlates)  ) {
	     me->locate_eligible_thing.p_classes[*pcount] =
							OPP_VSplate_class_id;
	     ++ me->locate_eligible_thing.w_count ;
	}

	if ( me->TransTypes & Flattened ) {
		me->locate_eligible_thing.p_classes[*pcount] =
							OPP_VLunwrap_class_id;
		++ me->locate_eligible_thing.w_count ;
	}

	if ( me->TransTypes & StiffTempls ) {
	       me->locate_eligible_thing.p_classes[*pcount]
						= OPP_VLstfnrTpl_class_id;
		++ me->locate_eligible_thing.w_count ;
	}

	if ( me->TransTypes & FlatBars ) {
	       me->locate_eligible_thing.p_classes[*pcount] = 
							OPP_VSbeam_class_id;
		++ me->locate_eligible_thing.w_count ;
	}

	if ( me->TransTypes & PinJigs ) {
	       me->locate_eligible_thing.p_classes[*pcount] 
						= OPP_VLjigObj_class_id;
		++ me->locate_eligible_thing.w_count ;
	}

	if ( (me->TransTypes & FlatBars) || (me->TransTypes & FlatPlates)  ) {
	    me->locate_eligible_thing.p_classes[*pcount]
						= OPP_VSimgFeature_class_id;
	    ++ me->locate_eligible_thing.w_count ;
	}


	for ( i=0; i< me->locate_eligible_thing.w_count ; ++i ) {

		sts = om$get_classname( classid = 
					me->locate_eligible_thing.p_classes[i],
				  classname = ClassName );
		CheckRC( sts, 1 ) ;
		__DBGpr_str( "classname to locate", ClassName ) ;
		__DBGpr_int( "class", me->locate_eligible_thing.p_classes[i]) ;
	}

     }  // if list of classes

   } // if locate

   __DBGpr_com( "out of local filter" );

   status = om$send( msg = message CEO_LOCATE.filter( filter, 
						response, response_data),
		    mode = OM_e_wrt_message,
		    targetid = my_id );
   __CheckRC( status, 1, "CEO filter failed", quit ) ;

   End
   return status ;

}

action wakeup {

        // Execute method wakeup of precursor (parent) class

        me->StatusDisplay = TRUE;
        status  = om$send ( msg      = message VLcoToAlCmd.wakeup (pos),
                            mode     = OM_e_wrt_parent,
                            targetid = my_id );
        __CheckRC( status , 1, "wakeup to parent", quit ) ;

 	VLvl_report_LoadKeyWords();

        status = OM_S_SUCCESS;
}

/*+++++++++++++++++++++++++++ End of Command Object ++++++++++++++++++++++++*/
