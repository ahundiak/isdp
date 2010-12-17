#include "sql.h"

#line 1 "SQLload.rc"
#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         To Execute the RIS Load Schema Function.         *
*                                                                   *
* Arguements       long SQLload_schema ()                           *
*                                                                   *
* Algorithm        This routine loads the Initialize dunp file.     *
*                                                                   *
* Return Status     SQL_S_SUCCESS : Success.                        *
*                   SQL_E_FAILURE : Failure.                        *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
*                                                                   *
*********************************************************************
********************************************************************/

#include "DEBUG.h"
#include "ERR.h"
#include "SQLerrordef.h"
#include "RISloduld.h"

long SQLload_schema ()

{
long  status;
char  message[100];
static char *fname = "SQLload_schema" ;
/* Define a descriptor of type risloddes */
risloddes risloddes;

_SQLdebug ((fname, "Enter.\n"));

/* Initialize the descriptor */
memset ((char *) &risloddes, 0, sizeof(risloddes));

/* Assign necessary fields */
risloddes.filemode = 'w';
strcpy (risloddes.mainfile, "/usr/ip32/nfm/config/initial/ris3.0.dmp");
strcpy (risloddes.badfile, "NFMris.bad");
strcpy (risloddes.logfile, "NFMris.log");

risloddes.schema_count = 1;

/* Allocate memory space to hold information concerning schema */
risloddes.schemas = 
       (rislodsch *) calloc(risloddes.schema_count,sizeof(rislodsch));
	
/* Assign appropriate information concerning schema */
strcpy (risloddes.schemas[0].schname, "nfm_template");
risloddes.schemas[0].select_mode = 'a'; 

/* Call load function passing the address of the descriptor */
status = RIS_loader (&risloddes);
if (status != RIS_SUCCESS)
    {
    _SQLdebug ((fname, "RISload Failure: status = <0x%.8x>\n", status));
    sprintf (message, "RIS_loader : error %ld", status);
    ERRload_struct (SQL, SQL_E_MESSAGE, "%s", message) ;
    return (SQL_E_MESSAGE);
    }

_SQLdebug ((fname, "status <0x%.8x>\n", status)) ;
return (SQL_S_SUCCESS);

}
