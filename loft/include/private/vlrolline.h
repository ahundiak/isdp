/*==============================================================================

	I/LOFT (VL):
	Definitions for the RolLn (Roll Line) Object in the lofting product.
	Most definitions are concerned with creation and placement of the 
	RolLn object.
	

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/


#ifndef vlrolline_include
#define vlrolline_include

			/* the macro's name   */
#define VLMacroRolLn         "RolLn"
			/* the object's type name   */
#define VLRolLnName         "roll line"

#define VLRolMinAtt            6	/* number attributes in collection    */
#define VLRolNumTemplates      3	/* number of templates for macro      */
#define VLRolNumFeet		101	/* number of feet(output) of macro    */

#define VLRolMaxNumTemplates   13

		/* indexes of the various templates	*/

#define VLRolCollIndex         0	/* index of the ACrg collection       */
#define VLRolPlateIndex        1	/* index of the plate to be marked    */
#define VLRolProcessIndex      2	/* index of Process Type */

		/* names of the various templates	*/

#define	VLRolCollName		"ParamCollection"
#define VLRolPlateName		"PlateToRolLn"
#define VLRolProcessType	"ProcessType"
#define VLRolGrCrvName	        "CrvInput"

		/* names of the various feet */

#define VLFirstRolName	"FirstRolLn"		/* first line       */
#define VLFirstRolVectName	"VectToFirsRolLn"	/* accompanying Vector,
							   if one.      */

#define VLSecondRolName	"SecondRolLn"		/* second line if one */
#define VLSecondRolVectName	"VectToSecnRolLn"	/* projection vector */

#define VLThirdRolName	"ThirdRolLn"		/* third  line if one */
#define VLThirdRolVectName	"VectToThirRolLn"	/* projection vector */

#define VLFourthRolName	"FourthRolLn"		/* fourth line if one */
#define VLFourthRolVectName	"VectToFortRolLn"	/* projection vector */

#define VLFifthRolName	"FifthRolLn"		/* fifth line, if one */
#define VLFifthRolVectName	"VectToFifRolLn"	/* projection vector */

		/* indexes of the various feet */

#define	VLRolContsIndex		1
#define	VLRolIndex		0
#define	VLVectRolIndex		2
#define	VLSecRolIndex		3
#define	VLSecVectRolIndex	4
#define	VLThrRolIndex		5
#define	VLThrVectRolIndex	6
#define	VLForRolIndex		7
#define	VLForVectRolIndex	8
#define	VLFifRolIndex		9
#define	VLFifVectRolIndex	10

			/* defines for accessing template information	*/

#define VLTypeSide             "PlateBotOrTop"	/* which side of plate
							is to have the
							roll line */
#define	VLRolDirection	"RollInUVDirn"
#define VLRolShipX		"RolShipAxisX"
#define VLRolShipY		"RolShipAxisY"
#define VLRolShipZ		"RolShipAxisZ"

/* the number of roll lines required */
#define VLNbRolLn      "RolLineNumber"

			/* index of parameters in the input collection */

#define TypeSideIndex			0
#define RollDirnIndex			1
#define RollShipXDirnIdx		2
#define RollShipYDirnIdx		3
#define RollShipZDirnIdx		4
#define VLNbRolLnIdx			5

#endif
