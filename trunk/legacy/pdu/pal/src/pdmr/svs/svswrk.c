#include <stdio.h>
#include <PDUstr.h>

#define	TRUE	1
#define	FALSE	0

extern	char	CurrentSVSView[];
extern	struct	PDUrefresh	*refresh;

extern int	SVSon;

DoesSVSWork (int *EnableSVS)
/* Function decides whether SVS can work on a given view.	*/
{
	_pdm_debug ("Enter DoesSVSWork () - with SVSon     = %d", SVSon);
	_pdm_debug ("			    with EnableSVS = %d", *EnableSVS);

	if (SVSon == TRUE)
	{
		*EnableSVS = InitSmartViewSearch (refresh->rev_catalog);
	}
	else
	{
		*EnableSVS = FALSE;
	}

	_pdm_debug ("Exit DoesSVSWork ()    with EnableSVS = %d", *EnableSVS);

        return (1);
}
