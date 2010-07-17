/*
	vlsdlmacros.h : definition of macro to manipulate Strudel Context
			in LOFT environment.
*/

#ifndef	vlsdlmacros_include
#define	vlsdlmacros_include

#include "vscmd.h"
#include "ACrg_collect.h"

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VLsdlContext.I */
int IMPLEMENT_ISOFTYPE __((int VL, int userBlock));
long VLsdlInit __((VLsdlContext *sdlC));
long VLsdlOpenFile __((VLsdlContext *sdlC, VSfileFormInfo *file));
long VLsdlGetCol __((VLsdlContext *sdlC, int colType, struct GRid *colId, short create));
long VLsdlSetAttr __((VLsdlContext *sdlC, struct ACrg_coll *attr, short colType));
long VLsdlGetAttr __((VLsdlContext *sdlC, struct ACrg_coll *attr, short colType));
long VLsdlSetState __((VLsdlContext *sdlC, char *state));
long VLsdlGetState __((VLsdlContext *sdlC, char *state));
long VLsdlFree __((VLsdlContext *sdlC));
VSxfRC VLsdlSkip __((VLsdlContext *sdlC));

#if defined(__cplusplus)
}
#endif

/* -------------------------------------------------------------------------- */
/*
Macro vl$sdlInit()

Abstract 
	Initialize the strudel contex

Arguments 
	VLsdlContext *sdlC 
*/

#omdef vl$sdlInit( ctx )
	
	VLsdlInit( ctx )

#endomdef
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*
Macro vl$sdlOpenFile()

Abstract 
	Open the outPut file

Arguments 
	VLsdlContext	*sdlC 
	VSfileFormInfo	*file;
*/

#omdef vl$sdlOpenFile( ctx, file )
	
	VLsdlOpenFile( ctx, file )

#endomdef
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*
Macro vl$sdlSetAttr()

Abstract 
	Set attribute in collection

Arguments 
	VLsdlContext 		*sdlC
	struct	ACrg_coll	*attr
	short			colType		I  : User or System
*/

#omdef vl$sdlSetAttr(	ctx,
			attr,
			colType	= VLSDL_USER_COL )
	
	VLsdlSetAttr(	ctx,
			attr,
			colType )
#endomdef
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*
Macro vl$sdlGetAttr()

Abstract 
	Get attribute in collection

Arguments 
	VLsdlContext 		*sdlC
	struct	ACrg_coll	*attr		IO : Set name Get Value
	short			colType		I  : User or System
*/

#omdef vl$sdlGetAttr(	ctx,
			attr,
			colType	= VLSDL_USER_COL )
	
	VLsdlGetAttr(	ctx,
			attr,
			colType )
#endomdef
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*
Macro vl$sdlSetState()

Abstract 
	Set the current State

Arguments 
	VLsdlContext 	*sdlC
	char		*state
*/

#omdef vl$sdlSetState(	ctx,
			state )
	
	VLsdlSetState(	ctx,
			state )
#endomdef
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*
Macro vl$sdlGetState()

Abstract 
	Get the current State

Arguments 
	VLsdlContext 	*sdlC
	char		*state
*/

#omdef vl$sdlGetState(	ctx,
			state )
	
	VLsdlGetState(	ctx,
			state )
#endomdef
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*
Macro vl$sdlGetCol()

Abstract 
	Retrieve in context the collection

Arguments 
	VLsdlContext 	*sdlC
	short		colType
	struct GRid	*colId
	short		create
*/

#omdef vl$sdlGetCol(	ctx,
			colType	= VLSDL_USER_COL,
			colId,
			create	= TRUE )
	
	VLsdlGetCol(	ctx,
			colType,
			colId,
			create )
#endomdef
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*
Macro vl$sdlSkip()

Abstract 
	Flush the Strudel buffer into the output ASCII file.

Arguments 
	VLsdlContext 	*sdlC
*/

#omdef vl$sdlSkip( ctx )
	
	VLsdlSkip( ctx )

#endomdef
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*
Macro vl$sdlFree()

Abstract 
	Close file and delete context collection

Arguments 
	VLsdlContext 	*sdlC
*/

#omdef vl$sdlFree( ctx )
	
	VLsdlFree( ctx )

#endomdef
/* -------------------------------------------------------------------------- */

#endif
