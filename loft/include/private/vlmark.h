/*==============================================================================

	I/LOFT:
	Definitions for the Mark (Marking Line) Object in the
	Loft product .  Most definitions are concerned with creation and
	placement of the Mark object.

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

#include "vlglinedef.h"

#ifndef vlmark_include
#define vlmark_include

			/* the macro's name   */
#define VLMacroMark         "Mark"
			/* the object's type name   */
#define VLMarkName         "Mark"

#define VLMrkMinAtt            2	/* number attributes in collection    */
#define VLMrkNumTemplates      3	/* number of templates for macro      */
#define VLMrkNumFeet	       100	/* number of feet(output) of macro    */
#define VLMrkParams            4	/* number attributes in collection    */
#define VLMrkMaxNumTemplates   53

		/* indexes of the various templates	*/

#define VLMrkCollIndex         0	/* index of the ACrg collection       */
#define VLMrkPlateIndex        1	/* index of the plate to be marked    */
#define VLMrkStiffIndex        2	/* index of the stiffener/plate 
					   defining the mark		      */

		/* names of the various templates	*/

#define	VLMrkCollName		"ParamCollection"

#define VLMrkPlateName		"PlateToMark"
#define VLMrkStiffName		"StiffenOrPlate"
#define VLMrkGrCrvName          "CrvInput"

		/* names of the various feet */

#define VLFullLineName		"FullLine"		/* Mark without trim  */
#define VLMrkParamsName		N_MF_CONTENTS		/* was "Parameters"*/
#define VLFirstMrkName		"FirstMark"		/* first mark	      */
#define VLSecondMrkName		"SecondMark"		/* second mark if one */
#define VLThirdMrkName		"ThirdMark"		/* third  mark if one */
#define VLFourthMrkName		"FourthMark"		/* fourth mark if one */
#define VLFifthMrkName		"FifthMark"		/* fifth  mark if one */
#define VLSixthMrkName		"SixthMark"		/* sixth  mark if one */
#define VLSeventhMrkName	"SeventhMark"		/* seventhmark if one */
#define VLEighthMrkName		"EighthMark"		/* eighth mark if one */
#define VLNinethMrkName		"NinethMark"		/* nineth mark if one */
#define VLTenthMrkName		"TenthMark"		/* tenth  mark if one */


/* NO LONGER USED to cope with reworked marking line 1/94 */
#define VLSecondMrkOffsName	"OffsToSecndMark"	/* its offset, if one */
#define VLFirstMrkOffsName	"OffsToFirstMark"	/* accompanying offset
							   mark, if one.      */

		/* indexes of the various feet, the first two being for
			genLine compatibility */

#define	VLFulLinIndex		0
#define	VLMrkParIndex		1
				/* the following are the useful feet */
#define	VLFirMrkIndex		2
#define	VLSecMrkIndex		3
#define	VLThrMrkIndex		4
#define	VLForMrkIndex		5
#define	VLFifMrkIndex		6
#define	VLSixMrkIndex		7
#define	VLSevMrkIndex		8
#define	VLEigMrkIndex		9
#define	VLNinMrkIndex		10
#define	VLTenMrkIndex		11

			/* defines for accessing template information	*/

#define VLTypeSide             "PlateBotOrTop"		/* which side of plate
							is to be marked	      */

#define VLIntsTypeSide         "StiffBotOrTop"		/* which side of 
							 stiffening plate or 
							 which edge of stiffener
							 is to define the mark*/

			/* index of parameters in the collection */
#define TypeSideIndex           0
#define TypeIntsSideIndex       1

#endif
