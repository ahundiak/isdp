class implementation VLabstract;

/* ************************************************************************** */
/*	Strudel Context Mamagement for Loft command		 	      */
/*	Marc Fournier & Ludovic Le Corvec  (COC shipbuilding, Rungis)	      */
/*	12-JUN-1994	:	creation				      */
/* ************************************************************************** */

#include	<stdio.h>
#include	<string.h>
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"bsvalues.h"
#include 	"ACattrib.h"
#include 	"ACrg_collect.h"
#include 	"grmacros.h"
#include 	"grdpbmacros.h"

#include        "vscmd.h"
#include        "vsdrwdef.h"
#include        "vsdrw.h"
#include        "vsdrwmacros.h"
#include        "vsdrwapi.h"

#include	"vlsdldef.h"
#include	"vlsdl.h"
#include	"vlsdlmacros.h"
#include	"vlpcdef.h"
#include	"vlmsg.h"


from	ACrg_collect	import	ACmod_list_attribute;
from	ACrg_collect	import	ACadd_list_attribute;
from	ACrg_collect	import	ACget_named_attribute;

extern	GRclassid	OPP_ACdyn_col_class_id;

/* -------------------- FCT VLdrwISOFTYPEuserBlock() -----------	*/
/* -------------------- ALIAS userBlock IS OF TYPE  ---------------	*/
#argsused
IMPLEMENT_ISOFTYPE( VL, userBlock ) {

long			sts, msg;
struct	ACrg_coll	attr;

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "NOCLASS" );
	if( DRW_wantType ){

		DRW_elmType = 0;
		inp->constDefName[0] = '\0';
		strcpy( attr.name, VLSDL_STATE );
		sts = om$send(	msg = message ACrg_collect.ACget_named_attribute
					( &msg, &attr ),
				senderid = NULL_OBJID,
				targetid = DRW_elmId->objid,
				targetos = DRW_elmId->osnum );
		if( sts&msg&1 ){

			if( ! strcmp( attr.desc.value.att_txt, DRW_elmDesc )){
				DRW_elmType	= VL_M_PlcButt;
				inp->constDefName[0] = '\0';

				// clean state field
				attr.desc.value.att_txt[0] = '\0';
				sts = om$send(	msg = 
				      message ACrg_collect.ACmod_list_attribute
							( &msg, 1, &attr ),
						senderid = NULL_OBJID,
						targetid = DRW_elmId->objid,
						targetos = DRW_elmId->osnum );
			}
		}
	}
	if( DRW_wantView ){

		DRW_elmView = VSunknownViewType;

		strcpy( attr.name, VLSDL_VIEW );
		sts = vl$sdlGetAttr(	ctx	= (VLsdlContext *) inp->appData,
					attr	= &attr,
					colType	= VLSDL_SYST_COL );

		if( ! (sts&1))	return;

		if( ! strcmp( attr.desc.value.att_txt, VLPC_VIEW_SIDE ))
				DRW_elmView = VSfromSide;

		else if( ! strcmp( attr.desc.value.att_txt, VLPC_VIEW_BOTTOM ))
				DRW_elmView = VSfromBottom;

	} // end-want-view

}

/* -------------------- FCT VLdrwFUNCTIONopenFile () ----------	*/
/* -------------------- ALIAS openFile FUNCTION ---------------	*/
#argsused
IMPLEMENT_FUNCTION ( VL, openFile ) {

long			sts;
VSfileFormInfo		file;
struct	ACrg_coll	attr;

	STR_RES("");		// no output
	CHECK_ARGCOUNT( 1 );	// check arg number

	VSdrwStrVal( &arglist->arg, file.pathName );
	file.openMode[0] = 'w',
	file.openMode[1] = '\0';

	sts = vl$sdlOpenFile(	ctx	= (VLsdlContext *) inp->appData,
				file	= &file );

	if( ! (sts&1))	return xfFAILURE;

	// set pathName
	strcpy( attr.name, VLSDL_FILE_PATH );
	attr.desc.type	= AC_ATTRIB_TEXT;
	strcpy( attr.desc.value.att_txt, file.pathName );

	sts = vl$sdlSetAttr(	ctx	= (VLsdlContext *) inp->appData,
				attr	= &attr,
				colType	= VLSDL_SYST_COL );

return	xfSUCCESS;
}

/* ****************** FCT VLsdlInit () ********************************	*/

long VLsdlInit( VLsdlContext *sdlC )
{

	sdlC->systTxt.row[0]	= '\0';
	sdlC->systTxt.txt[0]	= '\0';
	sdlC->systTxt.col 	= 0;
	sdlC->systTxt.ini 	= 0;
	sdlC->systTxt.jst	= 1;
	sdlC->systTxt.out	= NULL;

	sdlC->systCol.objid	= NULL_OBJID;
	sdlC->userCol.objid	= NULL_OBJID;
	sdlC->stateArgs		= NULL;

return	MSSUCC;
}

/* ****************** FCT VLsdlOpenFile () ****************************	*/
long VLsdlOpenFile( VLsdlContext *sdlC, VSfileFormInfo *file )
{
long		sts;
char		*ptr;
char		cmd[DI_PATH_MAX * 2];

	if( sdlC->systTxt.out )	printf(" file already open \n");

	else {

		// create directory if need
		ptr = strrchr( file->pathName, '/' );
		if( ptr ){
			*ptr = '\0';
			sprintf( cmd, "mkdir -p %s", file->pathName );
			*ptr = '/';
			system(cmd);
		}

	        sdlC->systTxt.out = (FILE *) 
				fopen( file->pathName, file->openMode );
        	if( ! sdlC->systTxt.out ){
			printf( "Cannot open file <%s> with mode <%s>\n",
				file->pathName, file->openMode);
			sts = MSFAIL;
			goto	wrapup;
		}
	}

	sts = MSSUCC;

wrapup :

return	sts;
}

/* ****************** FCT VLsdlGetCol () ******************************	*/

long VLsdlGetCol( VLsdlContext *sdlC, int colType, 
					struct GRid *colId, short create )
{
long			sts, msg;
struct	GRid		col;
struct	GRmd_env	MOD_ENV;
long			NumberOfBytes,BytesReceived;


	if( VLSDL_SYST_COL == colType )		col	= sdlC->systCol;
	else if( VLSDL_USER_COL == colType )	col	= sdlC->userCol;
	else{ col.objid	= NULL_OBJID; sts = MSFAIL; goto wrapup; }

	if( NULL_OBJID != col.objid || ! create ){ sts = MSSUCC; goto wrapup; }

	// Create a collection 
        NumberOfBytes = sizeof( MOD_ENV );
        gr$get_module_env(      msg     = &msg,
                                sizbuf  = &NumberOfBytes,
                                buffer  = &MOD_ENV,
                                nret    = &BytesReceived);

	col.osnum	= MOD_ENV.md_id.osnum;
	col.objid	= NULL_OBJID;
	sts = om$construct(	classid	= OPP_ACdyn_col_class_id,
				osnum	= col.osnum,
				p_objid = &col.objid );

	if( VLSDL_SYST_COL == colType )		sdlC->systCol = col;
	else if( VLSDL_USER_COL == colType )	sdlC->userCol = col;

wrapup :

	if( colId )	*colId = col;

return	sts;
}

/* ****************** FCT VLsdlSetAttr () *****************************	*/

long VLsdlSetAttr( VLsdlContext *sdlC, struct ACrg_coll *attr, short colType )
{
long			sts, msg;
struct	GRid		col;
	
	sts = vl$sdlGetCol(	ctx	= sdlC,
				colType	= colType,
				colId	= &col,
				create	= TRUE );
	if( ! (sts&1))	goto	wrapup;

	sts = om$send(	msg	 = message 
				ACrg_collect.ACmod_list_attribute
					( &msg, 1, attr ),
			senderid = NULL_OBJID,
			targetid = col.objid,
			targetos = col.osnum );
	if( ! (msg&1))
		sts = om$send(	msg	 = 
				message ACrg_collect.ACadd_list_attribute
						( &msg, 1, attr ),
				senderid = NULL_OBJID,
				targetid = col.objid,
				targetos = col.osnum );

	if( ! (sts&msg&1))	sts = MSFAIL;
	else			sts = MSSUCC;

wrapup :

return	sts;
}

/* ****************** FCT VLsdlGetAttr () *****************************	*/

long VLsdlGetAttr( VLsdlContext *sdlC, struct ACrg_coll *attr, short colType )
{
long			sts, msg;
struct	GRid		col;
	
	sts = vl$sdlGetCol(	ctx	= sdlC,
				colType	= colType,
				colId	= &col,
				create	= TRUE );
	if( ! (sts&1))	goto	wrapup;

	sts = om$send(	msg	 = message 
				ACrg_collect.ACget_named_attribute
					( &msg, attr ),
			senderid = NULL_OBJID,
			targetid = col.objid,
			targetos = col.osnum );
	if( ! (sts&msg&1))	sts = MSFAIL;

wrapup :

return	sts;
}

/* ****************** FCT VLsdlSetState () ****************************	*/

long VLsdlSetState( VLsdlContext *sdlC, char *state )
{
long			sts;
struct	ACrg_coll	attr;

	strcpy( attr.name, VLSDL_STATE );
	attr.desc.type	= AC_ATTRIB_TEXT;
	strcpy( attr.desc.value.att_txt, state );

	sts = vl$sdlSetAttr(	ctx	= sdlC,
				attr	= &attr,
				colType	= VLSDL_SYST_COL );

return	sts;
}

/* ****************** FCT VLsdlGetState () ****************************	*/

long VLsdlGetState( VLsdlContext *sdlC, char *state )
{
long			sts;
struct	ACrg_coll	attr;

	state[0] = '\0';

	strcpy( attr.name, VLSDL_STATE );

	sts = vl$sdlGetAttr(	ctx	= sdlC,
				attr	= &attr,
				colType	= VLSDL_SYST_COL );
	if( sts ) strcpy( state, attr.desc.value.att_txt );

return	sts;
}

/* ****************** FCT VLsdlFree () ********************************	*/

long VLsdlFree( VLsdlContext *sdlC )
{
long	no_msg;

	if( NULL_OBJID != sdlC->systCol.objid )
		gr$delete_object(	msg	  = &no_msg,
					object_id = &sdlC->systCol );

	if( NULL_OBJID != sdlC->userCol.objid )
		gr$delete_object(	msg	  = &no_msg,
					object_id = &sdlC->userCol );

	// close file
        if( sdlC->systTxt.out ){
		vl$sdlSkip( ctx = sdlC );
		fflush( sdlC->systTxt.out );
		fclose( sdlC->systTxt.out );
		sdlC->systTxt.out = NULL;
	}

	sdlC->stateArgs	= NULL;

return	MSSUCC;
}

/* ************************************************************************** */
VSxfRC	VLsdlSkip (VLsdlContext    *sdlC)
{

	IGRint		Rlen=0, i;
	VSxfRC		sts=xfSUCCESS;
	VStktxt		blk;
	VLsdlText	*Txt;

	/* Initialize */
	blk[0] = '\0';

	/* Finish the row */
	Txt = &sdlC->systTxt;
	Rlen = strlen (Txt->row);
	for ( i=0; i<Txt->col-Rlen; i++)	blk[i] = ' ';
	blk[Txt->col-Rlen] = '\0';
	sprintf ( Txt->row, "%s%s%s", Txt->row, blk, Txt->txt );

	if (Txt->out) {
		/* Print result in ASCII file */
		if (Txt->row[0] != '\0')
			fprintf( Txt->out, "%s%c", Txt->row, '\n');
	}
	else {	/* Write an Apfel-Strudel error */
		VSdrwPrintf ( "!!! Output file not open");
		sts = xfFAILURE;
	}

	/* Reinitialize globals */
	Txt->row[0] = '\0';
	Txt->txt[0] = '\0';
	Txt->col = 0;
	Txt->jst = 1;
	Txt->ini = 0;

	return	(sts);
}
/* ************************************************************************** */

end implementation VLabstract;
