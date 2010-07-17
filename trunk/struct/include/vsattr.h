/*
	I/STRUCT
	Part attributes.
	File dependency : vs.h
*/
#ifndef vsattr_include
#	define vsattr_include

#ifndef vs_include
#	include "vs.h"
#endif

/*
	Material Take-Off
*/
struct VS_s_Mto {
	VSmtoStk	stock ;
	VSmtoSrc	source ;
	int		chgnum ;
} ;
typedef struct VS_s_Mto VS_Mto ;

struct VS_s_partInfo {
	VSfamily	family ;	/* PDM/PDU family name		*/
	VSprtNum	partNum ;	/* PDM/PDU part number		*/
	VSmatTyp	material ;	/* Material type		*/
	VSmatGrd	grade ;		/* Material grade		*/
	VSusrNot	notes ;		/* User comments		*/
	VSappSts	apprvstat ;	/* Approval status		*/
	VScstSts	conststat ;	/* Construction status		*/
	double		fpthickness ;	/* Fireproofing thickness	*/
	int		memberClass,	/* Member class			*/
			memberType ;	/* Member type			*/
} ;
typedef struct VS_s_partInfo VSpartInfo ;

/*
	Attributes of a part as they may be obtaine with GRgetattr or
	set with GRputattr.

	If the attributes are obtained with GRgetattr, the needed memory for
	some of them may have been allocated in a cache buffer and must be
	returned to the system when no longer needed :

		VSpartAttr attr ;

		om$send( ... GRvg.GRgetattr( &msg, (char *) &attr ) ... ) ;

		...

	When this structure is filled to be input to GRputattr, this
	field is to be ignored.

	Not all attributes are wanted all the time, to avoid useless filling
	of the unwanted attributes which may be costly, the attributes wanted
	must be specified in the "Iwant" field. This being for GRgetattr or
	GRputattr.

	If one want to set or get all attributes, "attr.Iwant" may be set
	to "VS_m_All".
*/
struct VS_s_partAttr {
	/*
	 * Attributes to be set or obtained (mask).
	 */
	unsigned long	Iwant ;
	/*
	 * Part information.
	 */
	VSpartInfo	info ;
	/*
	 * Material trade-off.
	 */
	VS_Mto		mto ;
	/*
	 * Id of collection of user attributes (NULL_OBJID if none).
	 */
	struct GRid	usrAttr ;
	/*
	 * Pointer to part-specific attributes.
	 */
	void		*specific ;
} ;
typedef struct VS_s_partAttr VSpartAttr ;

#endif /* vsattr_include */
