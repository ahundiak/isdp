/* $Id: VDnfmEnv.c,v 1.2 2001/02/11 17:59:46 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdnfm/list/main.c
 *
 * Description: List NFM Enviroments
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDnfmEnv.c,v $
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/21/05  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDrisc.h"
#include "VDnfmc.h"

main()
{
    IGRchar fileName[128];

    VDnfmGetEnvInfoFileName(fileName);

    VDnfmDumpEnvInfoFile(stdout, fileName);

}
