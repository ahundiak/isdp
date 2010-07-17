/* $Id: VRGenRepCmd.sl,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrnetworkco / VRGenRepCmd.sl
 *
 * Description:
	"Generate From To Report" command.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRGenRepCmd.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.4  1997/07/02  13:53:30  pinnacle
# Replaced: vrnetworkco/VRGenRepCmd.sl for:  by lawaddel for route
#
# Revision 1.3  1997/03/20  20:06:06  pinnacle
# Replaced: vrnetworkco/VRGenRepCmd.sl for:  by lawaddel for route
#
# Revision 1.2  1996/08/27  18:49:12  pinnacle
# TR179602230 ah
#
# Revision 1.7  1996/05/13  21:26:50  pinnacle
# Replaced: vrnetworkco/VRGenRepCmd.sl for:  by hverstee for route240
#
# Revision 1.6  1996/04/04  21:21:50  pinnacle
# Replaced: vrnetworkco/VRGenRepCmd.sl for:  by hverstee for route240
#
# Revision 1.5  1996/03/04  20:46:50  pinnacle
# Replaced: vrnetworkco/VRGenRepCmd.sl for:  by hverstee for route240
#
# Revision 1.4  1996/02/04  07:29:18  pinnacle
# Replaced: vrnetworkco/VRGenRepCmd.sl for:  by ashankar for route240
#
# Revision 1.3  1996/01/17  00:09:48  pinnacle
# Replaced: vrnetworkco/VRGenRepCmd.sl for:  by r240_int for route240
#
 *
 * History:
 *      08/14/86        ah      TR179602230, Added UNITS to header
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      03/05/97        law     TR179603615, ref-file connectors crashing
 *                              and giving errors
 *      07/02/97        law     TR179603615, buffer size increased to 120.
 *************************************************************************/

options		"t"
product_name	"$ROUTE"
command_table	"route.cmd"
class		VRGenRepCmd
super_class	VDB_LOCATE
start_state	terminate

specification

#include <stdio.h>
#include "VRreports.h"
#include "growner.h"

instance {
	variable struct {
		unsigned int	item ;
		struct GRid	obj_id ;
	}			stackLoop[0] ;	   		/* Stack loop.			*/

	struct	GRobj_env	component ;	   		/* Component located.		*/
	char			file_name[80] ;    		/* Output file name.		*/
	FILE			*file_ptr ;	   		/* File pointer			*/
	unsigned int		component_number ; 		/* The component number		*/
						   		/* in the graph.		*/
	unsigned int		page_number ;	   		/* Page number			*/
	unsigned int		nb_of_rows ;	   		/* Number of rows in the	*/
						   		/* page writed.			*/
	unsigned int		TotalNbHangers;
	variable struct GRid	HangIds[20], ComponentId[20];
	variable struct GRid	IdLoop[0] ;	   		/* List of component where	*/
						   		/* a loop was detected.		*/
	IGRchar			RepMesName[NUMBER_OF_CHARS+1];	/* Variable message name	*/
	IGRchar			RepSysName[NUMBER_OF_CHARS+1];	/* header buffer: sysname	*/
	IGRchar			RepParName1[NUMBER_OF_CHARS+1];	/* first header line		*/
	IGRchar			RepParName2[NUMBER_OF_CHARS+1];	/* second header line		*/
	struct {
		int 	type;
		char	att_txt[80];
	} RepValue[VR_REPORT_LIST_MAX]; /* selected attribute type	*/

}

implementation

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "EMSmsgdef.h"
#include "EC_I.h"
#include "msmacros.h"
#include "VRparamdef.h"
#include "parametric.h"
#include "VRmsg.h"
#include "VDmem.h"
#include "VRreports.h"
#include "AS_status.h"

%safe
#include "VX_FIproto.h"
%endsafe

from ACncpx	import ACgive_structure ;
from VRGeneric	import VRGetNumberOfCpts,
		       VRGetTopo,
		       VRGetHangers,
		       VRGetCode;
from VRHanger	import VRGetAttributes;

extern	som_vla_set_dimension();
extern  GRunit_database_type();

#define F_NEWLINE	fprintf( me->file_ptr, "\n" ) ;\
			me->nb_of_rows++ ;\
			if( me->nb_of_rows > NUMBER_OF_ROWS ) {\
				me->page_number++ ;\
				me->nb_of_rows = 0 ;\
				F_STRING( me->file_ptr, "\n" ) ;\
				om$send( msg	  =\
					 message VRGenRepCmd.begin_page(\
						     me->page_number ),\
					 targetid = my_id ) ;\
			}

#define AS_DEBUG


/*----------------------------------------------------------------------------*/
action store_component
{

  me->component.obj_id  = me->event1.located_object[0].located_obj ;
  me->component.mod_env = me->event1.located_object[0].module_info ;

  /*"component located : [%d,%d]\n", me->component._osnum, me->component._objid */

  /* Store component located to stack loop. */
  status = om$vla_set_dimension(	varray	= me->stackLoop,
					size	= 1 ) ;

  as$status( action = RET_STATUS ) ;

  me->stackLoop[0].obj_id = me->component.obj_id ;
  me->stackLoop[0].item	= 1 ;

  goto quit;

} /* store_component */

/*----------------------------------------------------------------------------*/
action store_file_name( long *msg )
{

/*
   Before storing instance 'me->file_name', this method check if
   the given file name exists and isn't a directory. The value of
   msg are :
	- VR_K_FileIsDirectory	: The given file name is a directory
	- VR_K_FileExist	: The given file name exist.
	- MSSUCC		: The given file name doen't exist.
 */

struct stat	state_file ;

  strcpy( me->file_name, me->event1.event.keyin ) ;

  /*"file_name : %s\n", me->file_name */

  /* See if the file exists and isn't a directory. */
  status = stat( me->file_name, &state_file ) ;

  if( status == 0 ) {
	/*
	 * File exists. See if it's a directory.
	 */
	if( S_ISDIR( state_file.st_mode ) ) {
		/*|File is a directory */
		*msg = VR_K_FileIsDirectory ;
	} else {
		/*|File exists */
		*msg = VR_K_FileExist ;
	}
  }
  else {
	/*
	 * File doesn't exist.
	 */
	/*|File doesn't exist */
	*msg = MSSUCC ;
  }

  goto quit;

} /* store_file_name */

/*----------------------------------------------------------------------------*/
action check_response( long *overwrite )
{

 status = OM_S_SUCCESS;

/*
  This method check is user want to overwrite file or not.
 */

  if( !strcmp( "n", me->event1.event.keyin ) ||
      !strcmp( "N", me->event1.event.keyin ) ) {
	/*|Dont't overwrite file */
	*overwrite = FALSE ;
  }
  else{
	/*|Overwrite file */
	*overwrite = TRUE ;
  }

  goto quit;

} /* check_response */

/*----------------------------------------------------------------------------*/
action open_file( long *msg )
{
/*
   This method open file on write mode. The value of *msg are :
   - VR_K_CantCreateFile	: Cannot create file.
   - MSSUCC			: Sucessfull operation.
 */

 status = OM_S_SUCCESS;

  me->file_ptr = fopen( me->file_name, "w" ) ;

  if( !me->file_ptr ) {
	/*|Cannot create file */
	*msg = VR_K_CantCreateFile ;
  }
  else {
	/*|File create */
	*msg = MSSUCC ;
  }

  goto quit;

} /* open_file */

/*----------------------------------------------------------------------------*/
action fill_file
{
long		msg ;
struct GRid	PrevCompId ;

/*
   This method fill the file.
 */

  ex$message( msgnumb = EMS_I_Processing ) ;

  /*
   * Write the beginning of the report.
   */
  status =
  om$send( msg	  = message VRGenRepCmd.begin_page( me->page_number ),
	   targetid = my_id ) ;

  status =
  om$send( msg	  = message VRGenRepCmd.write_generic( BEGIN_TRACE,
						       NULL,
						       NULL,
						       NULL ),
	   targetid = my_id ) ;

  /*
   * Span the graph. The previous object of the component located
   * is considered to NULL_OBJID.
   */
  PrevCompId.objid	= NULL_OBJID ;
  PrevCompId.osnum	= me->component._osnum ;

  me->component_number	= 1 ;
	
  me->TotalNbHangers = 0;

  status =
  om$send( msg	  = message VRGenRepCmd.write_next_in_graph(
					   &msg,
					   me->component.obj_id,
					   PrevCompId ),
	 targetid = my_id ) ;

  /* End of the report. */
  status =
  om$send( msg	  = message VRGenRepCmd.write_generic( END_TRACE,
						       NULL,
						       NULL,
						       NULL ),
	 targetid = my_id ) ;

  if(me->TotalNbHangers) {
  status = om$send( msg 	  = message VRGenRepCmd.write_supports(),
	   	    targetid 	  = my_id	); 
  as$status();
	}
  /* Close the output file. */

  fclose( me->file_ptr ) ;

  ex$message( 	field   = ERROR_FIELD,
		in_buff = "" ) ;

  goto quit;

} /* fill_file */

/*----------------------------------------------------------------------------*/
action begin_page( unsigned int page_nb )
{

/*
   This method write the beggining of the page 'page_nb'.
 */
IGRint		msg,
		index = -1,
		lenght ;
IGRchar		*date, buffer[120];
time_t		dh ;
struct ret_struct attr ;

/* TR179602230 */
IGRint eng_met;

  /*| Retrieve the date. */
  time( &dh ) ;
  date = ctime( &dh ) ;
  *( date + 24 ) = '\0' ;        /* Reject character \n */
  /*"date : %s\n", date */

  /*| Write beginning of report. */
  
  F_REPEATCHAR( me->file_ptr, '=', NUMBER_OF_CHARS );
  F_NEWLINE ;
  F_NEWLINE ;

  F_SPACE( me->file_ptr, NUMBER_OF_CHARS /2 -strlen( me->RepMesName ) /2 ) ;

  F_STRING( me->file_ptr, me->RepMesName ) ;
  F_NEWLINE ;
  F_NEWLINE ;

  ex$message( msgnumb	= VR_I_Date,
		type	= "%s",
		var 	= `date`,
		buff	= buffer ) ;

  lenght = strlen( buffer ) ;

  F_STRING( me->file_ptr, buffer ) ;

  ex$message( msgnumb	= VR_I_Page,
		type	= "%-3d",
		var 	= `page_nb`,
		buff	= buffer ) ;

  F_SPACE( me->file_ptr, NUMBER_OF_CHARS -lenght -strlen( buffer ) ) ;

  F_STRING( me->file_ptr, buffer ) ; 
  F_NEWLINE ;
  F_NEWLINE ;

  ex$message( msgnumb	= VR_I_FromToReport,
	    buff	= buffer ) ;

  /* TR179602230, adjust header to reflect units */ 
  GRunit_database_type(me->component.mod_env.md_id.osnum, &eng_met);

  switch(eng_met)
  {
    case GRIO_UNITS_ARE_ENGLISH:
      strcat(buffer," (ENGLISH UNITS)");
    break;
    case GRIO_UNITS_ARE_METRIC:
      strcat(buffer," (METRIC UNITS)");
    break;
    default:
      strcat(buffer," (UNKNOWN UNITS)");
    break;
  }

  F_SPACE( me->file_ptr, NUMBER_OF_CHARS /2 - strlen( buffer ) /2 ) ;

  F_STRING( me->file_ptr, buffer ) ; 
  F_NEWLINE ;
 F_NEWLINE ;

  F_REPEATCHAR( me->file_ptr, '=', NUMBER_OF_CHARS ) ; 
  F_NEWLINE ;
  F_NEWLINE ;

  /*| Retrieve system name. */
  if( me->RepSysName[0] != '\0' ){
    status = om$send( msg	= message ACncpx.ACgive_structure(
					       &msg,
					       &index,
					       me->RepSysName,
					       &attr,
					       &me->component.mod_env ),
			targetid = me->component._objid,
			targetos = me->component._osnum ) ;

    as$status( action = RET_STATUS ) ;
    as$status( action = RET_STATUS, sts = msg ) ;

    /*"System Name : %s\n", attr.var.text_st.text_string */
    ex$message( msgnumb	= VR_I_System,
	    type	= "%s",
	    var 	= `attr.var.text_st.text_string`,
	    buff	= buffer ) ;
	
    F_STRING( me->file_ptr, buffer ) ;
  }
  F_NEWLINE ;
  F_NEWLINE ;

  F_STRING( me->file_ptr, me->RepParName1 ) ;
  F_NEWLINE ;

  F_STRING( me->file_ptr, me->RepParName2 ) ;
  F_NEWLINE ;

  F_REPEATCHAR( me->file_ptr, '-', NUMBER_OF_CHARS ) ;
  F_NEWLINE

  goto quit;

} /* begin_page */

/*----------------------------------------------------------------------------*/
action write_parameter( struct GRid	compId ;
			unsigned int	Item ; )
{
/*
   This method retrieves and write to output file all parameters
   for the report.
 */

IGRint	msg, i,
	index = -1 ;
IGRchar	string[NUMBER_OF_CHARS+1],
	buffer[120],
	float_to_ascii[15] ;

struct ret_struct	attr ;


  /*| Item. */
  sprintf( string, "%-*d", TAB, Item ) ;

  /* get all the information */
  for( i=0; i<VR_REPORT_LIST_MAX; i++ ){

    /* stop criteria */
    /*" index[%d]: %d\n", i, me->RepValue[i].type */
    if( me->RepValue[i].type == VR_REP_NOT_DEF ) break;

    if( me->RepValue[i].type != VR_REP_CONST_1 ){

      /* get structure information */
      status = om$send( msg = message ACncpx.ACgive_structure(
					&msg,
					&index,
					me->RepValue[i].att_txt,
					&attr,
					&me->component.mod_env ),
		    targetid = compId.objid,
		    targetos = compId.osnum ) ;
      as$status( action = RET_STATUS ) ;
      as$status( action = RET_STATUS, sts = msg ) ;
    }

    switch( me->RepValue[i].type ){
      case VR_REP_STR :
	/* "STR[%d]<%s>:<%s>\n", i, me->RepValue[i].att_txt, attr.var.text_st.text_string */

	sprintf( buffer, "%-*s", TAB, attr.var.text_st.text_string ) ;
	strcat( string, buffer ) ;
	break;

      case VR_REP_CONST_1 :
	/*"STR[%d]<%s>:<=CLASS=>\n", i, me->RepValue[i].att_txt */

	sprintf( buffer, "%-*s", TAB, "CLASS");
	strcat( string, buffer ) ;
	break;

      case VR_REP_FLO_4_1_INCH :
	/*"VAL[%d]<%s>:%f\n", i, me->RepValue[i].att_txt, attr.var.root_pm_st.value */

	sprintf( float_to_ascii, "%4.1f", attr.var.root_pm_st.value );
	sprintf( buffer, "%s%-*c", float_to_ascii, TAB-4, INCH_CHAR );
	sprintf( buffer, "%s%-*c", float_to_ascii, TAB-4, ' ' );
	strcat( string, buffer ) ;

	break;
      case VR_REP_FLO_3_0 :
	/*"VAL[%d]<%s>:%f\n", i, me->RepValue[i].att_txt, attr.var.root_pm_st.value */

	sprintf( float_to_ascii, "%3.0f", attr.var.root_pm_st.value ) ; 
	sprintf( buffer, "%-*s", TAB, float_to_ascii ) ;
	strcat( string, buffer ) ;

	break;
      case VR_REP_FLO_6_1 :
	/*"VAL[%d]<%s>: %f\n", i, me->RepValue[i].att_txt, attr.var.root_pm_st.value */

	sprintf( float_to_ascii, "%6.1f", attr.var.root_pm_st.value ) ;
	sprintf( buffer, "%-*s", TAB, float_to_ascii ) ;
	strcat( string, buffer ) ;

	break;
      case VR_REP_FLO_8_1 :
	/*"VAL[%d]<%s>: %f\n", i, me->RepValue[i].att_txt, attr.var.root_pm_st.value */

	sprintf( float_to_ascii, "%8.1f", attr.var.root_pm_st.value ) ;
	sprintf( buffer, "%-*s", TAB, float_to_ascii ) ;
	strcat( string, buffer ) ;

	break;
      default:
	printf(" Error:Type %d ->list[%d].att_txt:<%s>\n",  me->RepValue[i].type, i, me->RepValue[i].att_txt );
	break;
    } /* switch */
  } /* for */

  /*
   * Write string to output file.
   */
  F_STRING( me->file_ptr, string ) ; F_NEWLINE ;

  goto quit;

} /* write_parameter */

/*----------------------------------------------------------------------------*/
action write_generic( unsigned short	typeGeneric ;
		      unsigned int	Item ;
		      unsigned int	NbOfBranch ;
		      unsigned int	BranchNb ;	) {

/*
  This method write to the report :
	- BEGIN TRACE or
	- START BRANCH (BranchNb) of (NbOfBranch) ITEM (Item) or
	- BEGIN BRANCH (BranchNb) of (NbOfBranch) ITEM (Item) or
	- END BRANCH (BranchNb) ITEM (Item) or
	- END TRACE or
	- LOOP DETECTED ON (Item)
*/

char	buffer[120] ;

status = OM_S_SUCCESS;

  switch( typeGeneric ) {

  case BEGIN_TRACE :
	ex$message( msgnumb = VR_I_BeginTrace,
		    buff    = buffer ) ;
	break ;
  case START_BRANCH :
	F_NEWLINE ;

	ex$message( msgnumb = VR_I_StartBranch,
		    type    = "%d%d%d",
		    var     = `BranchNb, NbOfBranch, Item`,
		    buff    = buffer ) ;
	break ;
  case BEGIN_BRANCH :
	F_NEWLINE ;

	ex$message( msgnumb = VR_I_BeginBranch,
		    type    = "%d%d%d",
		    var     = `BranchNb, NbOfBranch, Item`,
		    buff    = buffer ) ;
	break ;
  case END_BRANCH :
	ex$message( msgnumb = VR_I_EndBranch,
		    type    = "%d%d",
		    var     = `BranchNb, Item`,
		    buff    = buffer ) ;
	break ;
  case END_TRACE :
	ex$message( msgnumb = VR_I_EndTrace,
		    buff    = buffer ) ;
	break ;
  case LOOP_DETECTED :
	ex$message( msgnumb = VR_I_LoopDetected,
		    type    = "%d",
		    var     = `Item`,
		    buff    = buffer ) ;
	break ;
  /* TR#179603615- VrCptIn objects are generating errors */
  case CONNECT_DETECTED :
	strcpy (buffer, " PREVIOUS COMPONENT CONNECTS TO REFERENCE FILE ");
	break ;
  }

  F_STRING( me->file_ptr, buffer ) ; F_NEWLINE ;

  goto quit;

} /* write_generic */

/*----------------------------------------------------------------------------*/
action write_next_in_graph( long		*msg ;
			    struct GRid 	CompId ;
			    struct GRid 	PrevCompId ; )
{

/*
  This method spans the graph. For each component, the method takes
  the topo and write the report.

  CompId	: The next component in the graph to process.
  PrevCompId	: The previous component.

*/

int		NbOfNeighbours ;       /* Number of neighbours.       */
struct	 GRid	*NeidIds = NULL;       /* List of neighbours.	      */
int		BuffSize ;	       /* Size of List NeidIds.       */
int		TotalCps ;	       /* Total number of connect pts.*/
unsigned int	Item ;		       /* The component number	      */
				       /* associated to CompId.       */
unsigned int	BranchNb ;	       /* Branch number in process.   */
int		i ;		       /* Loop index.		      */
int		j ;		       /* Loop index.		      */
int		size ;		       /* Size of stack loop	      */
int		next = FALSE ;	       /* Take next component of a    */
				       /* branch ?.		      */
/* TR#179603615- VrCptIn objects are generating errors */
extern GRclassid OPP_VRCptIn_class_id;
GRclassid ClassId;

Item = me->component_number ;

/*"->Process component : [%d,%d]\n", CompId.osnum, CompId.objid */
/*"Previous component : [%d,%d]\n", PrevCompId.osnum,PrevCompId.objid */
/*"Item : %d\n", Item */

/* TR#179603615- VrCptIn objects are generating errors */
/* Report the existence of the pseudo-object and skip the component. */
   status = om$get_classid ( objid = CompId.objid,
                             osnum = CompId.osnum,
                             p_classid = &ClassId);
   as$status();
   if ( ClassId == OPP_VRCptIn_class_id )
   {
      om$send( msg = message VRGenRepCmd.write_generic(
                     CONNECT_DETECTED,
                     NULL,   /* Guessing Here,was me->stackLoop[i].item */
                     NULL,
                     NULL ),
                     targetid = my_id ) ;
      size = om$dimension_of( varray = me->IdLoop ) ;

      status = om$vla_set_dimension(  varray  = me->IdLoop,
                                      size    = size + 1 ) ;

      as$status( action = RET_STATUS ) ;

      me->IdLoop[size] = PrevCompId ;
      *msg             = MSSUCC ;

      me->component_number-- ;

      goto quit;
   }
/*
 * See if the component is on the stack loop. If the component is
 * inside the stack loop, that minds there is a loop.
 * Note :
 * ------
 *	Before starting this method, the component located ( which is
 *	the first of the graph ) is stored on the stack loop.
 *	This test should not be done for the first component.
 */
  if( !IF_NULL_OBJID( PrevCompId.objid ) ) {

	size = om$dimension_of( varray = me->stackLoop ) ;

	for( i=0; i<size; i++ )
	  if( me->stackLoop[i]._objid == CompId.objid ) {
		/*|Loop detected*/

		om$send( msg	  =
			 message VRGenRepCmd.write_generic(
					  LOOP_DETECTED,
					  me->stackLoop[i].item,
					  NULL,
					  NULL ),
			 targetid = my_id ) ;
		size = om$dimension_of( varray = me->IdLoop ) ;

		status = om$vla_set_dimension(	varray	= me->IdLoop,
						size	= size + 1 ) ;

		as$status( action = RET_STATUS ) ;

		me->IdLoop[size] = PrevCompId ;
		*msg		 = MSSUCC ;

		me->component_number-- ;

		goto quit;
	  }
  }

  /*
   * Write the parameter.
   */
  om$send( msg = message VRGenRepCmd.write_parameter( CompId, Item ),
	 targetid = my_id ) ;

/*
 * Get the number of connect points.
 */
  status = om$send( msg	   = message VRGeneric.VRGetNumberOfCpts(
						       msg,
						       &NbOfNeighbours,
						       &me->component.mod_env ),
		  targetid = CompId.objid,
		  targetos = CompId.osnum ) ;

  as$status( action = RET_STATUS ) ;
  as$status( action = RET_STATUS, sts = *msg ) ;

  /*"Number of connect points : %d\n", NbOfNeighbours */

/*
 * Retrieve the neighbours.
 */
  NeidIds = _MALLOC (NbOfNeighbours, struct GRid);
  if( !NeidIds ) {
	*msg = EMS_E_NoDynamicMemory ;
	as$status( action = RET_STATUS, sts = *msg ) ;
  }
  /*|MALLOC done */

  BuffSize = sizeof( struct GRid ) * NbOfNeighbours ;

  status = om$send( msg	   = message VRGeneric.VRGetTopo(
					       msg,
					       BuffSize,
					       &TotalCps,
					       NULL,
					       NULL,
					       NeidIds,
					       NULL,
					       &me->component.mod_env ),
		  targetid = CompId.objid,
		  targetos = CompId.osnum ) ;

  om$send( msg    = message VRGenRepCmd.get_supports( CompId ),

	 targetid = my_id ); 

  if( !( status & *msg & 1 ) ) {
	_FREE( NeidIds ) ;
	/*|FREE done */
  }

  as$status( action = RET_STATUS ) ;
  as$status( action = RET_STATUS, sts = *msg ) ;

/*
 * See if in the list of neighbours there is the previous
 * component.
 */
  for( i=0; i<TotalCps; i++ ) {
	/*"Neighbour[ %d ] : [%d,%d]\n",i, NeidIds[i].osnum, NeidIds[i].objid */
	
	if( NeidIds[i].objid == PrevCompId.objid )
		NbOfNeighbours-- ;
  }

  /*"Number of neighbours : %d\n", NbOfNeighbours */

/*
 * If number of neighbours > 1, add component to stack loop.
 */
  if( NbOfNeighbours > 1 ) {
	/*|Add component to Stack Loop*/
	size = om$dimension_of( varray = me->stackLoop ) ;

	status = om$vla_set_dimension(	varray	= me->stackLoop,
					size	= size + 1 ) ;

	as$status( action = RET_STATUS ) ;

	me->stackLoop[size].obj_id = CompId ;
	me->stackLoop[size].item   = Item ;
  }

  if( NbOfNeighbours > 1 ) {

	/*|There is a branch*/

	BranchNb = 0 ;

	/*
	 * For each neighbour (no previous component and no neighbour
	 * already processing) redo the same operation.
	 */
	for( i=0; i<TotalCps; i++ ) {

		next = FALSE ;

		/*"Neighbour : [%d,%d]\n", NeidIds[i].osnum, NeidIds[i].objid */

		if( NeidIds[i].objid == PrevCompId.objid ) next = TRUE ;

		size = om$dimension_of( varray = me->IdLoop ) ;

		for( j=0; j<size; j++ )
			if( NeidIds[i].objid == me->IdLoop[j].objid ) {
					next = TRUE ;
					break ;
			}

		if( next ) continue ;

		BranchNb++ ;

		/*"Branch number : %d\n", BranchNb */

		/*
		 * write 'START BRANCH ...' or 'BEGIN BRANCH...'.
		 */
		if( BranchNb == 1 ) {
			/*|Start branch */

			om$send( msg	  =
				 message VRGenRepCmd.write_generic(
							 START_BRANCH,
							 Item,
							 NbOfNeighbours,
							 BranchNb ),
				 targetid = my_id ) ;
		} else {
			/*|Other branch */
			om$send( msg	  =
				 message VRGenRepCmd.write_generic(
							 BEGIN_BRANCH,
							 Item,
							 NbOfNeighbours,
							 BranchNb ),
				 targetid = my_id ) ;
		}

		/* Write the parameter. */
		om$send( msg	  = message VRGenRepCmd.write_parameter(
								 CompId,
								 Item ),
			 targetid = my_id ) ;

		/*  Redo operation. */
		me->component_number++ ;

		om$send( msg	  =
			 message VRGenRepCmd.write_next_in_graph(
							     msg,
							     NeidIds[i],
							     CompId ),
			 targetid = my_id ) ;

		if( !( *msg & 1 ) ) {
			_FREE( NeidIds ) ;
			/*|FREE done */
		}

		as$status( action = RET_STATUS, sts = *msg ) ;

		/*  write 'END BRANCH...'. */
		om$send( msg	  = message VRGenRepCmd.write_generic(
							    END_BRANCH,
							    Item,
							    NULL,
							    BranchNb ),
			 targetid = my_id ) ;
	}

  } else {

	/*
	 * No branch.
	 */
	if( NbOfNeighbours == 1 ) {

		/*|Just one neighbour */

		/*
		 * Redo operation to the neighbour.
		 */
		me->component_number++ ;

		for( i=0; i<TotalCps; i++ ) {
			if( NeidIds[i].objid == PrevCompId.objid )
				continue ;

                        /*   if I also find a NULL neighbor it means this
                             component with two connectpoints is at the
                             end of the line, decrease compnumber again   */

                        if( NeidIds[i].objid == NULL_OBJID)
                        {
                          me->component_number--;
                          continue;
                        }

			/*"Neighbour : [%d,%d]\n", NeidIds[i].osnum, NeidIds[i].objid */
			/*"Branch number : %d\n", BranchNb */

			om$send( msg	  =
				message VRGenRepCmd.write_next_in_graph(
							     msg,
							     NeidIds[i],
							     CompId ),
				targetid = my_id ) ;
			as$status( action = RET_STATUS, sts = *msg ) ;
		}

	}
	else {
		/*|Last component */
	}
  }

  /*"->End process component : [%d,%d]\n", CompId.osnum, CompId.objid */

  _FREE( NeidIds ) ;

  goto quit;

} /* write_next_in_graph */

/*----------------------------------------------------------------------------v*/

action write_supports()
{
  IGRint	    i,mssg,index=-1;
  IGRlong 	    msg;
  IGRchar	    *pCompNumber, *pCompCode;
  struct tagVRSupAttr sSupAttr;
  struct ret_struct   sAttr1,sAttr2;

  F_REPEATCHAR( me->file_ptr, '=', NUMBER_OF_CHARS );
  F_NEWLINE ;
  fprintf(me->file_ptr, "\n\t\t\t\t\t\tSUPPORT INFORMATION\n");
  F_NEWLINE;
  F_REPEATCHAR( me->file_ptr, '-', NUMBER_OF_CHARS );

  fprintf(me->file_ptr,"\n\t\t\tSUPPORTED\tSUPPORTED"); 
  fprintf(me->file_ptr, "\nSUPPORT\tTAG NUMBER\tCOMP. CODE\tCOMP. NUMBER\tSIZE\t\tTYPE\tDETAIL NUMBER\tWEIGHT\n");
  F_REPEATCHAR( me->file_ptr, '-', NUMBER_OF_CHARS );
  F_NEWLINE;

  for(i=0; i<me->TotalNbHangers; ++i) {
	status = om$send( msg = message VRHanger.VRGetAttributes(&msg, &sSupAttr),
			  targetid = me->HangIds[i].objid,
			  targetos = me->HangIds[i].osnum	);
	as$status();
    status = om$send( msg	= message ACncpx.ACgive_structure(
					       &mssg,
					       &index,
					       VR_N_TAG_NUMBER_AN,
					       &sAttr1,
					       &me->component.mod_env ),
			targetid = me->ComponentId[i].objid,
			targetos = me->ComponentId[i].osnum ) ;

    as$status( action = RET_STATUS ) ;
    as$status( action = RET_STATUS, sts = mssg );

    pCompNumber = sAttr1.var.text_st.text_string;

    status = om$send( msg	= message ACncpx.ACgive_structure(
					       &mssg,
					       &index,
					       VR_N_COMP_CODE_AN,
					       &sAttr2,
					       &me->component.mod_env ),
			targetid = me->ComponentId[i].objid,
			targetos = me->ComponentId[i].osnum ) ;

    as$status( action = RET_STATUS ) ;
    as$status( action = RET_STATUS, sts = mssg );

    pCompCode = sAttr2.var.text_st.text_string;

  fprintf(me->file_ptr, "\n%i\t%s\t\t%s\t\t%s\t\t%lf\t%i\t%s\t\t%lf", i+1,
			 sSupAttr.szTagNumber, pCompCode, pCompNumber, sSupAttr.dSize,  
			 sSupAttr.Type, sSupAttr.szDetailNumber,  sSupAttr.dWeight);
	}
  F_NEWLINE;
  F_REPEATCHAR( me->file_ptr, '=', NUMBER_OF_CHARS );

  goto quit;
}


action  get_supports ( struct GRid CompId)
{
IGRlong 	msg;
/* TR#179603615- Failure to initialize causing crashes. */
IGRint 		NbHangers = 0, i;
IGRint		size;
IGRdouble	d30CpCoors[30];
struct GRid	s10HangerIds[10];

	status = om$send( msg=message VRGeneric.VRGetHangers(&msg,10, s10HangerIds,
			 &NbHangers, d30CpCoors, &me->component.mod_env),
		  targetid = CompId.objid,
		  targetos = CompId.osnum ) ;
	as$status();

	if(NbHangers!=0)
	{
	  size = om$dimension_of( varray = me->HangIds );

	  /* allocate more memory */
	  if( me->TotalNbHangers + NbHangers > size )
	  {
	    status = om$vla_set_dimension(
			 varray = me->HangIds,
			 size	= me->TotalNbHangers+NbHangers );

	    status = om$vla_set_dimension(
			 varray = me->ComponentId,
			 size	= me->TotalNbHangers+NbHangers );
	  }

	  for(i=0; i<NbHangers; i=i+1)
	  {
	    me->ComponentId[me->TotalNbHangers+i].objid = CompId.objid;
	    me->ComponentId[me->TotalNbHangers+i].osnum = CompId.osnum;
	    me->HangIds[me->TotalNbHangers+i].objid = s10HangerIds[i].objid;
	    me->HangIds[me->TotalNbHangers+i].osnum = s10HangerIds[i].osnum;
 	  }
	}
	
	me->TotalNbHangers += NbHangers;

  goto quit;
}
