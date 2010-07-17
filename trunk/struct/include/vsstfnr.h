/*
	I/STRUCT
	Types file for stiffener beam.
	File dependency:	vspart.h
*/

#ifndef vsstfnr_include
#	define vsstfnr_include

/*
 * Object attributes needed for construction of stiffener.
 * NOTE :
 * `attr.specific' must point to a variable `beamAttr' of type `VSbeamAttr'.
 */
struct VS_s_StfnrAttr {
	/*
	 * Attributes as those used to build a source beam (VSsrcBeam).
	 */
	VSpartAttr	attr ;
	/*
	 * Flag indicating on which side of plate stiffener is to be built.
	 * - VS_K_stOnBotOfPlate
	 * - VS_K_stOnTopOfPlate
	 */
	int		onWhichSideOfPlate,
	/*
	 * How stiffener generates itself:
	 * - normal to the side of the plate
	 * - normal to a surface of projection built on its axis here supposed
	 *   planar but not linear (otherwise same as above).
	 */
			constructType ;
} ;
typedef struct VS_s_StfnrAttr VSstfnrAttr ;

struct VS_s_stfnrFlags	{
	unsigned char	onWhichSideOfPlate	:1,
			constructType		:1 ;
} ;

typedef struct VS_s_stfnrFlags VSstfnrFlags ;

#endif

