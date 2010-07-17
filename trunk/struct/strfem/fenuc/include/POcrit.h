#ifndef POcrit_def
#define	POcrit_def

/*****************************************************************************

   Doc: POcrit.h

   Abstract: Contains the criteria data structure for grouping according
	to the given criteria.

   History:

	Date		Who	Why
	---------	---	------------------------------------------
	 9 Nov 89	msl	Creation

 ****************************************************************************/

#include "POlim.h"

typedef struct post_grp_criteria {
	char		name[PO_PDNAME_LEN];	/* data name		*/
	int		cat;			/* data catagory	*/
	long		ndins;			/* number of dins in process */
	long		dins[6];		/* dins to check criteria on */
	double		max;			/* max data on dins	*/
	double		min;			/* min data on dins	*/
	char		lim_type; 		/* See POdef.h		*/
	double		upper_lim;		/* upper criteria limit	*/
	double		lower_lim;		/* lower criteria limit	*/
	int		region;			/* See POdef.h		*/
   }POgrp_crit;

#endif
