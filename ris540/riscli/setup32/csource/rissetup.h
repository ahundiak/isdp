/* Do not alter this SPC information: $Revision: 1.2.54.1 $ */

#include <windows.h>

/* Setup function to install the RIS shared component.		       */
/*								       */
/* The container application must call ReadInfFile() one time before   */
/* any of the shared components' setup functions are called.           */
/*
/* return is 0 if component was not installed because		       */
/* the local host was up to date				       */
/* return is 1 if component was installed because		       */
/* the local host was not up to date				       */
/* return is 2 if component was installed because		       */
/* the component was new to the local host			       */

extern int SetupRIS ();

/* The RegEdtRIS is the name of the setup function that must be        */
/* called by container applications to edit the registry for RIS       */
/* and to add the RIStcpsrService into the Services		       */

extern void RegEdtRIS (int action, CHAR *listEntry);

