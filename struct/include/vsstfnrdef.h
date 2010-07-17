/*
	I/STRUCT
	Definition file for stiffener beam.
*/
#ifndef vsstfnrdef_include
#	define vsstfnrdef_include

/*
 * Constants defining on which side of plate stiffener was build originally and
 * to which it must stick, even if orintation of plate is reversed.
 */
#	define VS_K_stOnBotOfPlate	0
#	define VS_K_stOnTopOfPlate	1

/*
 * Constant defining how stiffener generates itself:
 * - normal to the side of the plate
 * - normal to a surface of projection built on its axis here supposed planar
 * but not linear (otherwise same as above).
 */
#	define VS_K_stNormalToSide	0
#	define VS_K_stUseSurfOfPrj	1

/*
 * Name of parent support plate
 */
#	define VS_K_stSuppPlate	"plate"

#endif
