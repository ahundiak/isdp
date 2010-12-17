/******************************************************************************

Doc:    BLcatalog

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLcatalog.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This module controls the performing of any catalog operation.
        It writes its own messages to the results file.

Examples:
          BLcatalog();

Return Status:
          (none)

History:
     09/03/91  wrw  -added standard header and converted externs to .h

******************************************************************************/
  

#include <stdio.h>
#include <string.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"


void BLcatalog ()
{

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLcatalog.\n");

   BLwrite_result(DMD_I_CATALOG,parameters.catalog_name);
 
   flags.catalog = 0;

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLcatalog normally.\n");

} /* end BLcatalog */
