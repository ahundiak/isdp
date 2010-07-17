/*
	I/STRUCT
*/
#ifndef vsplatmacros_include
#	define vsplatmacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vsattr_include
#	include "vsattr.h"
#endif
#ifndef vsplate_include
#	include "vsplate.h"
#endif

/*+M
Macro vs$fillPlateAttr

Abstract
	Fill some or all of the fields of a plate attribute structure.
Arguments
	OUT	long	*msg		Completion code.
	IN	int	options		Mask flagging attributes to be filled
					in (ORing of masks in vsoptdef.h).
	IN	char	*partFam	PDM/PDU part family of plate.
	IN	char	*partNum	PDM/PDU part number of plate.
	IN	char	*matType	Material of plate.
	IN	char	*matGrade	Grade of material.
	IN	int	mbrClass	Member class.
	IN	int	mbrType		zMember type.
	IN	char	*usrNote	User notes about parts.
	IN	char	*mtoSrc		MTO source.
	IN	char	*mtoStk		MTO stock
	IN	int	mtoChgNo	MTO change request number.
	IN	double	FireProofing	Thickness of fireproofing material.
	IN	char	*apprvStat	Approval status.
	IN	char	*constStat	Construction status.
	IN	struct GRid
			*usrAttrId	Id of collection of user attributes.
	IN	double	thickness	Thickness of plate.
	IN	double	cutOff		Cut-off thickness.
	IN	double	offset		Offset from support surface.
	IN	int	orientation	Orientation wrt support surface.
	OUT	VSpartAttr
			*partAttr	Part attributes.
	OUT	VSplateAttr
			*plateAttr	Plate-specific attributes.
Notes
	If an attribute is specified in the options, the corresponding value
	must be input (the default values are meaningless and even dangerous).
	If an input character string attribute was too long, it is truncated and
	`*msg' is set to EMS_I_Fail.
-M*/
extern long
VSfillPlateAttr			__((	long		*msg,
					int		options,
					char		*partFam,
					char		*partNum,
					char		*matType,
					char		*matGrade,
					int		mbrClass,
					int		mbrType,
					char		*usrNote,
					char		*mtoSrc,
					char		*mtoStk,
					int		mtoChgNo,
					double		FireProofing,
					char		*apprvStat,
					char		*constStat,
					struct GRid	*usrAttrId,
					double		thickness,
					double		cutOff,
					double		offset,
					int		orientation,
					VSpartAttr	*partAttr,
					VSplateAttr	*plateAttr )) ;

#omdef vs$fillPlateAttr(msg,
			options,
			partFam		= NULL,
			partNum		= NULL,
			matType		= NULL,
			matGrade	= NULL,
			mbrClass	= 0,
			mbrType		= 0,
			usrNotes	= NULL,
			mtoSrc		= NULL,
			mtoStk		= NULL,
			mtoChgNo	= 0,
			FireProofing	= 0.,
			apprvStat	= NULL,
			constStat	= NULL,
			usrAttrId	= NULL,
			thickness	= 0.,
			cutOff		= 0.,
			offset		= 0.,
			orientation	= 0,
			partAttr,
			plateAttr )
	VSfillPlateAttr((msg),
			(options),
			(partFam),	/*  1 PDM/PDU family name	*/
			(partNum),	/*  2 PDM/PDU part number	*/
			(matType),	/*  3 Material			*/
			(matGrade),	/*  4 Grade of material		*/
			(mbrClass),	/*  5 Member class		*/
			(mbrType),	/*  6 Member type		*/
			(usrNotes),	/*  7 User comments		*/
			(mtoSrc),	/*  8 Source number		*/
			(mtoStk),	/*  9 Stock number		*/
			(mtoChgNo),	/* 10 Change-request number	*/
			(FireProofing),	/* 11 Fireproofing thickness	*/
			(apprvStat),	/* 12 Approval status		*/
			(constStat),	/* 13 Construction status	*/
			(usrAttrId),	/* 14 Collection of user attr.	*/
			(thickness),	/* 15 Plate thickness		*/
			(cutOff),	/* 16 Plate cut-off thickness	*/
			(offset),	/* 17 Offset from support	*/
			(orientation),	/* 18 Orietation (natural/rev.)	*/
			(partAttr),
			(plateAttr) )
#endomdef

/*+M
Macro vs$listPlateFaces

Abstract
	Returns the list of the faces of a plates : their internal foot names
	and message numbers of their decriptions.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*plate		Id of plate.
	OUT	int		*count		Count of faces.
	OUT	char		***names	Foot names of faces.
	OUT	long		**descrs	Descriptions of faces.
Note
	The memory allocated for `*names' names must be freed with
		VSfreeList( *names ) ;
	The memory allocated for `*descrs' must be freed with
		free( *descrs ) ;
-M*/
extern long
VSlistPlateFaces		__((	long		*msg,
					struct GRid	*plate,
					int		*count,
					char		***names,
					long		**descrs )) ;

#omdef vs$listPlateFaces( msg, plate, count, names, descrs )
	VSlistPlateFaces( (msg), (plate), (count), (names), (descrs) )
#endomdef

#endif
