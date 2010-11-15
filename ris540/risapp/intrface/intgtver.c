/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**	NAME:							intgtver.c
**	AUTHORS:						Prasad Challa
**	CREATION DATE:					1/93
**	ABSTRACT:
**			Retreives RIS version information.
**	REVISION HISTORY:
**			New Function to verify version requested.
**					-- Hitesh 7/93
*/
 
/*
**	INCLUDES
*/
#include "risstjmp.h"
#include "intrface.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intgtver_c
#include "appver.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "intgtver.prt"
#include "intrap.prt"
#include "interror.prt"
#include "sys.prt"


/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISAPI RISXget_app_version(
	int		*maj,
	int		*min,
	int		*rel)
{

	int sts;

	INT_DBG(("RISget_app_version(maj:0x%x min:0x%x rel:0x%x)\n", 
				maj, min, rel));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET APP VERSION\n");
		fprintf(RIS_RAP, "maj:0x%x\n", maj);
		fprintf(RIS_RAP, "min:0x%x\n", min);
		fprintf(RIS_RAP, "rel:0x%x\n", rel);
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

    if ((sts = SETJMP()) != 0)
    {
        RESETJMP();
        SET_RISCA(sts);
        RISrap_return();
        RIS_RETURN();
    }

    /*
    ** CLIENT DIED not required
    */

    sts = RISapp_init_version();
    if (sts != RIS_SUCCESS)
	{
        LONGJMP(sts);
	}

	if (maj) *maj = RIS_app_version_maj;
	if (min) *min = RIS_app_version_min;
	if (rel) *rel = RIS_app_version_rel;

	RESETJMP();
	INT_DBG(("RISget_app_version: complete\n"));

    SET_RISCA(RIS_SUCCESS);
    RISrap_return();
    RIS_RETURN();
}

/******************************************************************************/
