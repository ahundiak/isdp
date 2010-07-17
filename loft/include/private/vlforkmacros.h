/* ************************************************************************** *//*			I/LOFT fork macros.				      */
/*									      */
/*	Marc FOURNIER : COC shipbuilding (Rungis, France)		      */
/*			created		23-Mar-1995	MF
/* ************************************************************************** */
/*			I/LOFT fork macros.				      */
/*									      */
/*	Marc FOURNIER : COC shipbuilding (Rungis, France)		      */
/*			created		23-Mar-1995	MF		      */
/* ************************************************************************** */

#ifndef	vlforkmacros_include
#define	vlforkmacros_include

/* ************************************************************************** */
/*                              Functions prototypes                          */
/* ************************************************************************** */

#include        "gr.h"
#include        "igrdp.h"
#include        "go.h"
#include        "macro.h"
#include        "dp.h"
#include        "nddef.h"
#include        "OMminimum.h"

#include	"vlPjunction.h"

/* ************************************************************************** */
/*                              Macro : vl$createLoftFork ()		      */
/* ************************************************************************** */
/*
Abstract :
        Create a root macro that holds a graphic (curve or surface) and
	a collection of attributes (numeric and alphanumeric).
	A "measure" foot is added for pinjigs height display.

Arguments :
OUT             IGRlong         *msg            Completion code.
IN	struct	GRobj_env	*graphic	Graphic object.
IN/OUT	struct	GRobj_env	*collect	Collection object.
IN	struct	ACrg_coll	*attr		Attributes array.
IN		IGRint		number		Attributes number.
IN	struct	GRobj_env	*measure	Measure object.
IN      struct  GRmd_env        *Env            Enviroment for ACmplace.
OUT     struct  GRid            *forkId         Resulting occurence ID.

Note :  If (collect == NULL)    collection is built from (attr) and (number).
	If (collect->obj_id.objid == NULL_OBJID)
				An ACrg_collect object is built from (attr) and
				(number) and it's returned in (collect).
        If (Env  == NULL)      	active environment is taken.
        If (forkId  == NULL)   	no ID is returned.
*/

#omdef	vl$createLoftFork (	msg,
				graphic,
				collect	= NULL,
				attr	= NULL,
				number	= 0,
				measure = NULL,
				Env	= NULL,
				forkId	= NULL	)

	VLcreateLoftJunction (	(msg),
				(graphic),
				(collect),
				(attr),
				(number),
				(measure),
				(Env),
				(forkId)	)
#endomdef

/* ************************************************************************** */
/*                              Macro : vl$getForkGeom ()		      */
/* ************************************************************************** */
/*
Abstract :
	Get the curve/surface geometry from the <graphic> foot of the
	<VLjunction> object.
	
Arguments :
OUT             IGRlong         *msg            Completion code.
IN	struct	GRid		*forkId		<VLjunction> object ID.
IN	struct	GRobj_env	*forkEnv	<VLjunction> environment.
OUT	struct	GRid		*footId		Graphic foot ID.
OUT	struct	GRobj_env	*footEnv	Graphic foot environment.
IN		IGRint		option 		0 : regular geometry.
						1 : geometry with boundaries.
						2 : extended geometry.
IN		OM_S_OBJID	CobMyId		ID of the calling process.	
OUT		IGRchar**	geometry	Geometry structure.

Notes :
        If (forkEnv == NULL) 	active environment is taken.
        If (footId == NULL   	no ID is returned.
        If (footEnv == NULL) 	no environment is returned.
        If (geometry == NULL)	no geometry allocated/returned.
        If (geometry != NULL)	returned structure must be deallocated by caller
				using an om$dealloc() for example.
*/

#omdef	vl$getForkGeom (	msg,
				forkId,
				forkEnv = NULL,
				footId = NULL,
				footEnv = NULL,
				option = 0,
				CobMyId = NULL_OBJID,
				geometry = NULL	)

	VLgetLoftJunctionGeom (	(msg),
				(forkId),
				(forkEnv),
				(footId),
				(footEnv),
				(option),
				(CobMyId),
				(geometry)	)
#endomdef

/* ************************************************************************** */
/*                              Macro : vl$getForkAttr ()		      */
/* ************************************************************************** */
/*
Abstract :
	Retrieve an attribute value by name from the <collect> foot of the
	<VLjunction> object.
	
Arguments :
OUT             IGRlong         *msg            Completion code.
IN	struct	GRid		*forkId		<VLjunction> object ID.
IN		IGRname		*name		Attribute name.
OUT		IGRdouble	*value		Attribute value if double.
OUT		IGRchar		*text		Attribute value if string.

Notes :
	If (name == NULL)	no attribute is search/returned.
	If (value == NULL)	no double attribute value is returned.
	If (value != NULL)	initialize to *value=0.0.
	If (text == NULL)	no string attribute value is returned.
	If (text != NULL)	initialize to text[0]='\0'.
		--> text must be allocated by user to ATTR_TXT (ACrg_collect.h)

	Using this vl$macro(), you must no the type of the attribute you want.
*/

#omdef	vl$getForkAttr (	msg,
				forkId,
				name = NULL,
				value = NULL,
				text = NULL	)

	VLgetLoftJunctionAttr (	(msg),
				(forkId),
				(name),
				(value),
				(text)	)
#endomdef


/* ************************************************************************** */
#endif
