class implementation Root;

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "refdef.h"

#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "ACrg_collect.h"

#include "vderrmacros.h"

#include "SFmsg.h"
#include "SFconvDef.h"
#include "SFconvStruct.h"

extern IGRlong  SFConvertPlateAndStfnrs();
extern IGRlong  SFConvertBeam();

extern OMuword  OPP_VSplate_class_id;
extern OMuword  OPP_VSbeam_class_id;
extern OMuword  OPP_VSstfBeam_class_id;

from  GRcontext  import  GRgetinstance;
from  GRreffile  import  GRgetosnum;
from  GRreffile  import  GRgetenvironment;
from  OMObjSpace import  pass;
from  GRgraphics import  GRfunction;

/**************************************************************************
 Doc : SFConvertElement

 Desrciption :  This function is called for each plate and beam in a
		refence OS. This function calls appropriate routines
		for plate and beam.

 History :

 Date	   Who       Revision	Why
 -----     ---       --------   ---
 08-30-94  raju	     2.3.1	Creation

************************************************************************/
IGRint   SFConvertElement( 
 long *msg,			/* O - return status	*/
 struct GRid *ElemId,		/* I - objid of the struct element */
 struct SFConvOpt *ConvOpt	/* I - mod env of the reference file */
)
{

long			sts;
OMuword			ElemClassid;

   sts = OM_S_SUCCESS;
   *msg = MSSUCC;


   /*
    *  see if user wants to stop the process
    */

   if ( IGEstop() )
   {
	return OM_I_STOP_SENDING;
   }

   sts = om$get_classid ( osnum     = ElemId->osnum,
			  objid     = ElemId->objid,
			  p_classid = &ElemClassid  );

   if ( om$is_ancestry_valid (  subclassid   = ElemClassid,
				superclassid = OPP_VSstfBeam_class_id ) ==
								OM_S_SUCCESS )
   {
	/* 
	 * stiffeners are converted along with plates.
	 */
	goto wrapup;
   }

   if ( om$is_ancestry_valid (  subclassid   = ElemClassid,
				superclassid = OPP_VSplate_class_id ) ==
								OM_S_SUCCESS )
   {
	/*
	 * It's a plate.
	 */

	__DBGpr_obj("Processing plate", *ElemId);
	sts = SFConvertPlateAndStfnrs ( msg, ElemId, ConvOpt );
	VDS_ERR_HNDLR ( "SFConvertPlateAndStfnrs", sts, *msg,
			VD_VERBOSE, wrapup );
   }
   else if ( om$is_ancestry_valid (  subclassid   = ElemClassid,
				     superclassid = OPP_VSbeam_class_id ) ==
								OM_S_SUCCESS )
   {
	/*
	 * It's a beam.
	 */

	__DBGpr_obj("Processing beam", *ElemId);
	sts = SFConvertBeam ( msg, ElemId, ConvOpt );
	VDS_ERR_HNDLR ( "SFConvertBeam", sts, *msg, VD_VERBOSE, wrapup );
   }
   else
   {
	printf("Invalid object[%d,%d] in SFConvertElement\n",
					ElemId->objid, ElemId->osnum);
   }

wrapup:
   return sts;

}

/**************************************************************************
 Doc : SFConvert

 Desrciption :  This is the main function that is called for converting
		all elements in model. This calls convertion function
		for all the plates and beams in all the active reference OSs.

 History :

 Date	   Who       Revision	Why
 -----     ---       --------   ---
 08-30-94  raju	     2.3.1	Creation

************************************************************************/
IGRlong  SFConvert()
{


long			sts, msg;
struct SFConvOpt	ConvOpt;
struct GRsymbology	ActSymb;
OM_S_CLASSLIST		clist;
OMuword			classes[2];
int			*ProcessedOS = NULL,
			ii, jj,
			count;
char			Processed;
struct GRid		rfmgr;
OM_S_CHANSELECT		refmgrTOreffile;
OMuword			RefOsnum;
char			osname[OM_K_MAXOSNAME_LEN];
int			numberOfBytes,
			BytesReceived;
char			RefFileName[15],
			reffile_writable;
struct	GRevent		event;
int			response;
char			response_data[EX_RESPONSE_DATA_SIZE];

  sts = OM_S_SUCCESS;


  ex$message (	in_buff		= "Convert All Elements",
		field		= MESSAGE_FIELD,
		justification	= CENTER_JUS );
  /*
   * See if the user logged into database
   */ 

   if ( !VSisLoggedIntoRDB() )
   {
     ex$message ( msgnumb	= SF_E_NoDbLogin,
		  field		= ERROR_FIELD,
		  justification = CENTER_JUS );
     goto wrapup;
   }

  /*
   *  make sure user wants to convert all the elements
   */

get_event:
   co$getevent (  msg		= &msg,
		  event_mask	= ( GRm_STRING ),
		  prompt	= "Do you wish convert all elements <y/n> [y]?",
		  response	= &response,
		  response_data = &response_data,
		  event		= &event );

   if ( response == CLEAR_STACK )
   {
	sts = ex$putque( msg         = &msg,
			 pos         = FRONT,
			 response    = &response );
	goto wrapup;
   }

   if ( response == TERMINATE || response == EX_BACK_UP )  goto wrapup;

   if ( response != EX_STRING )
		goto get_event;

   if ( event.event.keyin[0] == 'n' || event.event.keyin[0] == 'N' )
	goto wrapup;

   numberOfBytes = sizeof ( struct GRmd_env );
   gr$get_module_env(	msg     = &msg,
			sizbuf  = &numberOfBytes,
			buffer  = &ConvOpt.MasterEnv,
			nret    = &BytesReceived );

   clist.w_count   = 2;
   clist.w_flags   = OM_CLST_subclass;
   clist.p_classes = classes;

   classes[0] = OPP_VSplate_class_id;
   classes[1] = OPP_VSbeam_class_id;


   om$make_chanselect ( channame      = "Super_rfmgr.mgr",
			p_chanselect  = &refmgrTOreffile  );

   /*
    *  get the context Super
    */
   sts = GRgetctxsuper( &msg, &rfmgr ) ;
   VDS_ERR_HNDLR ( "Getting context super", sts, msg, VD_VERBOSE, wrapup );

   sts = om$get_channel_count(     osnum           = rfmgr.osnum,
				   objid           = rfmgr.objid,
				   p_chanselect    = &refmgrTOreffile,
				   count           = (OMuint *) &count ) ;

   VDS_ERR_HNDLR ( "Getting refmgrTOreffile count", sts, 1, VD_VERBOSE,
			wrapup );

   __DBGpr_int("No. of ref. files attached", count );

   if ( count == 0 )
   {
	ex$message (  in_buff	= "No Reference Files Attached",
		      field	= ERROR_FIELD,
		      justification = CENTER_JUS );
	goto wrapup;
   }


   /*
    *  get the convertion options
    */
   sts = SFgetConvOpt ( &msg,
			ConvOpt.PlateSurfOpt,
			&ConvOpt.offset,
			ConvOpt.BmExtractOpt,
			&ConvOpt.ElemType,
			&ConvOpt.NbFemElem,
			&ConvOpt.ConvAllEl );
   VDS_ERR_HNDLR("Getting conversion options",sts,msg,VD_VERBOSE,wrapup);

   ConvOpt.ExtractStiffs = TRUE;

   /*
    * fill construction list
    */
   numberOfBytes = sizeof ( IGRshort );
   gr$get_active_layer(	msg     = &msg,
			sizbuf  = &numberOfBytes,
			buffer  = &ActSymb.level,
			nret    = &BytesReceived );

   numberOfBytes = sizeof ( struct IGRdisplay );
   gr$get_active_display(msg     = &msg,
			sizbuf  = &numberOfBytes,
			buffer  = &ActSymb.display_attr,
			nret    = &BytesReceived );

   ConvOpt.cst.msg	  = &msg;
   ConvOpt.cst.env_info	  = &ConvOpt.MasterEnv;
   ConvOpt.cst.level	  = ActSymb.level;
   ConvOpt.cst.display	  = &ActSymb.display_attr;
   ConvOpt.cst.newflag    = FALSE;
   ConvOpt.cst.geometry   = NULL;
   ConvOpt.cst.class_attr = NULL;
   ConvOpt.cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
   ConvOpt.cst.name       = NULL;

   /*
    * allocate memory for ProcessedOs
    */
   ProcessedOS = (int *) malloc ( sizeof(int) * count );
   for ( ii=0; ii<count; ii++ )
	ProcessedOS[ii] = 0;

   /*
    * Loop on contexts.
    */
   for( ii = 0 ; ii < count ; ii = ii+1 ) {
        sts = om$send(          msg     = message GRreffile.GRgetosnum(
							&msg,
                                                        &RefOsnum ),
			senderid        = rfmgr.objid,
			targetos        = rfmgr.osnum,
			p_chanselect    = &refmgrTOreffile,
			to              = ii,
			from            = ii ) ;
	/* It has been found that if a file has been attached and
	 * the file does not exist in the current directory,
	 * the above message fails */
	if ( !(sts&msg&1) ) continue;
	VDS_ERR_CONTINUE ("GRreffile.GRgetosnum", sts, msg, VD_VERBOSE);

	/*
	 * See if this object space is active before
	 * trying to use this context object.
	 */
	sts = om$os_number_to_name(	osnum   = RefOsnum,
					osname  = osname );
	if( !( 1 & sts ) )
	{
	  /* Skip this osnum. */
	  __DBGpr_int( "No OS name for OS num", RefOsnum );
	  continue;
	}

	__DBGpr_int ( "Osnum", RefOsnum );
	__DBGpr_str ( "Osname", osname );

	/*
	 * see if this OS has already been processed
	 */
	Processed = FALSE;
	jj = 0;
	while ( ProcessedOS[jj] && !Processed )
	{
	  if ( ProcessedOS[jj] == RefOsnum )
		Processed = TRUE;
	  jj++;
	}

	if ( Processed ) continue;

	/*
	 * see if the reference file is attached updatable
	 */
	sts = SFis_reffile_writable( 	&msg,
					RefOsnum,
					RefFileName,
					&reffile_writable );

	VDS_ERR_CONTINUE("SFis_reffile_writable", sts, msg, VD_VERBOSE);

	if ( !reffile_writable )
	{
	   ex$message(	field		= ERROR_FIELD,
			msgnumb		= SF_E_RefFileNtUpd,
			justification	= CENTER_JUS,
			type		= "%s",
			var		= `RefFileName` );

get_event1:
	   co$getevent (  msg		= &msg,
			  event_mask	= ( GRm_STRING ),
			  prompt	= "Continue <y/n> [y]?",
			  response	= &response,
			  response_data = &response_data,
			  event		= &event );

	   if ( response == CLEAR_STACK )
	   {
		sts = ex$putque( msg         = &msg,
				 pos         = FRONT,
				 response    = &response );
		goto wrapup;
   	   }

	   if ( response == TERMINATE || response == EX_BACK_UP )  goto wrapup;

	   if ( response != EX_STRING )
		goto get_event1;

	   if ( event.event.keyin[0] == 'n' || event.event.keyin[0] == 'N' )
		continue;
	}
        ConvOpt.reffile_writable = reffile_writable;

	sts = om$send( msg = message GRreffile.GRgetenvironment(
						&msg,
						&ConvOpt.MasterEnv,
						&ConvOpt.RefEnv ),
				senderid = rfmgr.objid,
				targetos = rfmgr.osnum,
				p_chanselect = &refmgrTOreffile,
				to = ii,
				from = ii);
	VDS_ERR_CONTINUE ( "GRreffile.GRgetenvironment", sts, msg, VD_VERBOSE);

	sts = om$send( msg = message OMObjSpace.pass( &clist, OM_e_wrt_object,
			message GRgraphics.GRfunction(&msg, SFConvertElement,
						(char *) &ConvOpt) ),
			senderid = NULL_OBJID,
			targetid = 0,
			targetos = RefOsnum );
	/*
	 * Check if user wishes to stop the process
	 */
	if ( sts == OM_I_STOP_SENDING )  goto wrapup;

	/* 
	 * check after adding the OS to processed list
	 */
	ProcessedOS[jj] = RefOsnum;
	VDS_ERR_CONTINUE ( "OMObjSpace.pass", sts, msg, VD_VERBOSE );
   }

wrapup:
   ex$message ( in_buff	= "",
		field	= ERROR_FIELD,
		justification = CENTER_JUS );
   if ( ProcessedOS ) free ( ProcessedOS );
   return sts;

}

end implementation Root;
