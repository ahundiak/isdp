/*
	I/STRUCT
*/
#ifndef vsmacintdef_include
#define vsmacintdef_include

/*
 * Standard prefixes.
 */
 	/*
 	 * General constructions.
 	 */
#define VS_K_pfxGenCons		"GC"
#define VS_K_pfxGenHull		"GH"
#define VS_K_pfxGenPlate	"GP"
#define VS_K_pfxGenShape	"GS"

	/*
	 * Brackets.
	 */
#define VS_K_pfxPlanarBracket	"BR"
#define VS_K_pfxFlangeBracket	"BF"
#define VS_K_pfxCompBracket	"BC"
#define VS_K_pfxChockBracket	"BH"	/* added for 2.5 */

	/*
	 * Openings.
	 */
#define VS_K_pfxOpenCutout	"OP"
#define VS_K_pfxOpenHole	"OH"
#define VS_K_pfxOpenScallops	"OS"
#define VS_K_pfxHolesOnShapes	"OB"	/* 'B' for beams = shapes	*/
#define VS_K_pfxCutoutsOnShapes	"OC"

	/*
	 * End cuts (treatments).
	 */
#define VS_K_pfxEndTreatment	"ET"
#define VS_K_pfxEndSniped 	"ES"
#define VS_K_pfxEndComposite	"EC"	/* added for 2.5 */
#define VS_K_pfxEndBeamJoint	"EJ"	/* added for 2.5 */
#define VS_K_pfxEndLapJoint	"EL"	/* added for 2.5 */
#define VS_K_pfxEndMisc 	"EM"	/* added for 2.5 */

	/*
	 * Cut Throughs.
	 */
#define VS_K_pfxPlainCut	"CT"
#define VS_K_pfxReinfCut	"CR"
#define VS_K_pfxWaterCut	"CW"
#define VS_K_pfxCompCut		"CC"	/* Removed for 2.5 */

	/*
	 * Transitions.
	 */
#define VS_K_pfxLinearTran	"TR"
#define VS_K_pfxBendTran	"TB"
#define VS_K_pfxDiamondTran	"TD"
#define VS_K_pfxFlangeTran	"TF"

/*
 * And their corresponding indices.
 */
#define VS_K_pfxGC	0
#define VS_K_pfxGH	1
#define VS_K_pfxGP	2
#define VS_K_pfxGS	3

#define VS_K_pfxBR	4
#define VS_K_pfxBF	5
#define VS_K_pfxBC	6
#define	VS_K_pfxBH	22

#define VS_K_pfxOP	7
#define VS_K_pfxOH	8
#define VS_K_pfxOS	9
#define VS_K_pfxOC	20	/* No more used .. */
#define VS_K_pfxOB	21

#define VS_K_pfxET	10
#define VS_K_pfxEC	11
#define VS_K_pfxES	23	/* Added for 2.5 */
#define VS_K_pfxEJ	24
#define VS_K_pfxEL	25
#define VS_K_pfxEM	26

#define VS_K_pfxCT	12
#define VS_K_pfxCR	13
#define VS_K_pfxCW	14
#define VS_K_pfxCC	15	/* No more used .. */

#define VS_K_pfxTR	16
#define VS_K_pfxTB	17
#define VS_K_pfxTD	18
#define VS_K_pfxTF	19

/*
 * Types of "Load <type> Library" commands.
 */
#define VS_K_VSLdGCLb	100
#define VS_K_VSLdOPLb	200
#define VS_K_VSLdETLb	300
#define VS_K_VSLdBRLb	400
#define VS_K_VSLdCTLb	500
#define VS_K_VSLdTRLb	600

/*
 * Infix of macro library names		<PREFIX><INFIX>* (ed. "ETclib2")
 */
#define VS_K_ifxMacLib	"clib"
#define VS_K_ifxPalFil	"pal"

/*
 * Standard directory in search path where palettes and macro libraries are
 * search for. The "%s" in VS_K_stdPalDir is to be replaced by the local
 * language used.
 */
#define VS_K_stdMacDir	"ppl/bin"
#define VS_K_stdPalDir	"config/%s/palettes"

#endif
