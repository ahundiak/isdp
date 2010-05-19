/*
Name
        GRlicense

Description
        This file contains the code to retrieve and track licenses.
	This file is NOT compiled on ISL system. As result TR179603671,
	is created. Official correction need to be performed by EMS.

	Original file in $GRNUC/src/co/misc/GRlicense.C
History
        adz     03/10/97    creation date.
*/

#include <stdio.h>
#include <signal.h>
#include <version.h>
#include "igrtypedef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmsg.h"
#include "grlicense.h"

/*
Name
        GRget_license_status:
        This function returns TRUE if all license requests succeeded, and
        FALSE otherwise.
*/

int GRget_license_status()		/* NEED TO BE OVERWRITTEN */
{
    return( 1 );
}

/*
Name
        GRset_license_status:
        This function sets the status used to determine whether all license
        requests succeed.  This is used during switchprod.
*/

void GRset_license_status(sts)		/* NEED TO BE OVERWRITTEN */
int sts;
{
	int	thank_you ;

	thank_you = sts ;
}

/*
Name
        GRrelease_unneeded_licenses:
        This function releases licenses not need by the active product lists.
        It determines which licenses to release by comparing the active search
        path with the runname information stored as licenses are allocated.
        If a licensed product is not in the active list, its license is
        surrendered.

        This function should be called after a switchprod.
*/

void GRrelease_unneeded_licenses()	/* NEED TO BE OVERWRITTEN */
{
}
