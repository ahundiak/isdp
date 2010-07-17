/*
	I/STRUCT
*/
#ifndef	vsdef_include
#	define	vsdef_include

/*
 * Index of consumed parent on parents channel.
 */
#define VS_K_ConsumedIx	0

/*
 * Marker for generic names of components of graphic feet in associative
 * complexes. The genric names will be in the form "<marker><n>", where <n>
 * is the index of the component on its owner's channel.
 */
#define VS_K_GENERIC_CMP_MARKER '$'

/*
 * Maximum sizes of character string for attributes, including the terminating
 * null character.
 * ( MTO = Material Take-Off )
 */
#	define VS_K_MatTypLen	64	/* Material type		*/
#	define VS_K_MatGrdLen	64	/* Material grade		*/
#	define VS_K_FamilyLen	64	/* Part family			*/
#	define VS_K_PrtNumLen	64	/* Part type inside family	*/
#	define VS_K_UsrNotLen	256	/* User notes about part	*/
#	define VS_K_MTOSrcLen	64	/* Source identification	*/
#	define VS_K_MTOStkLen	64	/* Stock identification		*/
#	define VS_K_AppStsLen	32	/* Apprpval status		*/
#	define VS_K_CstStsLen	32	/* Construction status		*/

/*
 * Maximum number of supports (ie. parents, excluding private and user
 * attributes) which a source part can have.
 */
#	define VS_K_MAXSUPPORTS	10

/*
 * Operation types.
 */
#	define VS_m_SRC_generic	0x1
#	define VS_m_MOD_generic	0x2
#	define VS_m_FRZ_generic	0x10000
#	define VS_m_IMG_generic	0x20000
#	define VS_m_SUB_generic ( VS_m_SRC_generic | 0x4  )
#	define VS_m_DPR_generic ( VS_m_MOD_generic | 0x8  )
#	define VS_m_DIV_generic ( VS_m_MOD_generic | 0x10 )
/*
 * The following may be ORed with those above.
 */
#	define VS_m_IN_ASSEMBLY		0x20
#	define VS_m_IN_DEFINITION	0x40
#	define VS_m_IN_OCCURRENCE	0x80

#	define VS_m_PLATE		0x10000000
#	define VS_m_BEAM		0x20000000
#	define VS_m_COMPRESSABLE	0x40000000
#	define VS_m_JOINT		0x80000000

#	define VS_m_SRC_PLATE \
		( VS_m_SRC_generic | VS_m_PLATE | 0x100  )
#	define VS_m_VAR_PLATE \
		( VS_m_SRC_generic | VS_m_PLATE | 0x200  )
#	define VS_m_IMB_PLATE \
		( VS_m_MOD_generic | VS_m_PLATE | 0x400  | VS_m_COMPRESSABLE )
#	define VS_m_MRK_PLATE \
		( VS_m_MOD_generic | VS_m_PLATE | 0x800  | VS_m_COMPRESSABLE )
#	define VS_m_SPL_PLATE \
		( VS_m_DIV_generic | VS_m_PLATE | 0x1000 )
#	define VS_m_GAP_PLATE \
		( VS_m_DIV_generic | VS_m_PLATE | 0x2000 )
#	define VS_m_SUB_PLATE \
		( VS_m_SUB_generic | VS_m_PLATE | 0x4000 )
#	define VS_m_BOO_PLATE \
		( VS_m_DPR_generic | VS_m_PLATE | 0x8000 | VS_m_COMPRESSABLE )
#	define VS_m_FRZ_PLATE \
		( VS_m_FRZ_generic | VS_m_PLATE )
#	define VS_m_SRC_BEAM  \
		( VS_m_SRC_generic | VS_m_BEAM  | 0x100  )
#	define VS_m_STF_BEAM  \
		( VS_m_SRC_generic | VS_m_BEAM  | 0x200  )
#	define VS_m_ORN_BEAM  \
		( VS_m_MOD_generic | VS_m_BEAM  | 0x400  )
#	define VS_m_BOO_BEAM  \
		( VS_m_DPR_generic | VS_m_BEAM  | 0x800  | VS_m_COMPRESSABLE )
#	define VS_m_XTR_BEAM  \
		( VS_m_DPR_generic | VS_m_BEAM  | 0x1000 )
#	define VS_m_SPL_BEAM  \
		( VS_m_DIV_generic | VS_m_BEAM  | 0x2000 )
#	define VS_m_SUB_BEAM  \
		( VS_m_SUB_generic | VS_m_BEAM  | 0x4000 )
#	define VS_m_FRZ_BEAM \
		( VS_m_FRZ_generic | VS_m_BEAM )
#	define VS_m_SRC_JOINT \
		( VS_m_SRC_generic | VS_m_JOINT  | 0x100  )
#	define VS_m_MOD_JOINT \
		( VS_m_MOD_generic | VS_m_JOINT )
#	define VS_m_DIV_JOINT \
		( VS_m_DIV_generic | VS_m_JOINT )
#	define VS_m_SUB_JOINT \
		( VS_m_SUB_generic | VS_m_JOINT )
#	define VS_m_FRZ_JOINT \
		( VS_m_FRZ_generic | VS_m_JOINT )

#	define VS_OP_TYPE( mask ) ( (mask) & ~(   VS_m_IN_ASSEMBLY   \
						| VS_m_IN_OCCURRENCE  \
						| VS_m_IN_DEFINITION ) )

/*
 * Operator types.
 */
#	define	VS_K_UNKNOWNtype	0
#	define	VS_K_PLATEtype		0x1
#	define	VS_K_BEAMtype		0x2
#	define	VS_K_JOINTtype		0x4
#	define	VS_K_POINTtype		0x8
#	define	VS_K_LINEtype		0x10
#	define	VS_K_CURVEtype		0x20
#	define	VS_K_PLANEtype		0x40
#	define	VS_K_SURFACEtype	0x80
#	define	VS_K_SOLIDtype		0x100
#	define	VS_K_EXPRtype		0x200
#	define	VS_K_COLLECTIONtype	0x400

/*
 * Maximum number of sub-features for a divided feature.
 */
#define VS_K_MAX_SUBS	CHAR_BIT

/*
 * Type of message sent.
 */
#	define	VS_K_WRITE_OMmsg	0
#	define	VS_K_READ_OMmsg		1

/*
 * Name of parent collections of private and user-attributes for a structural
 * part.
 */
#	define VS_K_prPrvAttr		"prvAttr"
#	define VS_K_prUsrAttr		"usrAttr"

/*
 * Part attributes accessible to the user.
 */
#	define VS_K_prPrtFamAttr "family_name"	/* PDM/PDU family name	*/
#	define VS_K_prPrtNumAttr "part_num"	/* PDM/PDU part number	*/
#	define VS_K_prMbrNamAttr "memb_name"	/* Object's name	*/
#	define VS_K_prMbrClsAttr "memb_class"	/* Class of object	*/
#	define VS_K_prMbrTypAttr "memb_type"	/* Type of object	*/
#	define VS_K_prMbrGeoAttr "memb_geom"	/* Geometry		*/
#	define VS_K_prMatTypAttr "material"	/* Steel, aluminium, etc*/
#	define VS_K_prMatGrdAttr "grade"	/* Grade of material	*/
#	define VS_K_prUsrNotAttr "notes"	/* User comments	*/
#	define VS_K_prMTOSrcAttr "source_no"	/* Source number	*/
#	define VS_K_prMTOStkAttr "stock_no"	/* Stock number		*/
#	define VS_K_prVolumeAttr "volume"	/* Of member		*/
#	define VS_K_prSfAreaAttr "surface_area"	/* Of member		*/
#	define VS_K_prXGvCtrAttr "cog_x"	/* X of center of grav.	*/
#	define VS_K_prYGvCtrAttr "cog_y"	/* Y of center of grav.	*/
#	define VS_K_prZGvCtrAttr "cog_z"	/* Z of center of grav.	*/
#	define VS_K_prFpThckAttr "fp_thick"	/* Fireproof'g thickness*/
#	define VS_K_prApprvlAttr "apprv_stat"	/* Approval status	*/
#	define VS_K_prConstrAttr "constr_stat"	/* Construction status	*/
#	define VS_K_prChgNumAttr "chg_no"	/* Change-request number*/
#	define VS_K_prFPtNumAttr "f_part_num"	/* Same as "part_num"	*/
#	define VS_K_prPrtRevAttr "f_part_rev"	/* Same as "material"	*/
#	define VS_K_prPnlNamAttr "panel_name"	/* ..:..:<dir>		*/
#	define VS_K_prMassAttr	 "mass"		/* Object's mass	*/

/*
 * Name of root complex representing the principal axes of the moment of
 * inertia.
 */
#	define VS_K_prMomOfInertiaCPX	"Mnt Of Inertia"

/*
 * Geometrical qualifiers for parts.
 */
#	define VS_K_flat	"flat"
#	define VS_K_curved	"curved"
#	define VS_K_linear	"linear"
#	define VS_K_twisted	"twisted"

#endif	/* vsdef_include */

