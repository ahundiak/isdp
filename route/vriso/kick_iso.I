/* -------------------------------------------------------------- */
/*
/*
/*	* 31-Oct-91	1.4.3.7	
/*
/*		Bruno
/*		- Remove the set_path function which had bad arguments
/*		  and bad code ( it did not check on the specified
/*		  file_name existence but on isogen.sh existence to
/*		  decide whether the specified file name existed or
/*		  not ). I replaced its call by a call to VR$GetUnixPath.
/*		  This function was only called in this file.
/*		- Modified the kick_iso function to avoid doing 
/*		  three time and ex$get_path.
/*
 *  10/31/96  KDD	"QUEUE" &"user_mail" 
 *			kicks off VR_ISO_CLIENT_KSH_NAME shell (8 arguments).
/* -------------------------------------------------------------- */

class implementation Root;

#include <stdio.h>
#include <fcntl.h>
#include <sys/errno.h>

#include "exdef.h"
#include "exmacros.h"

#include "VRGlobMac.h"
#include "big.h"
#include "dbs.h"

#define AS_DEBUG 1

extern	char    user_mail[];
extern	char    QUEUE[];


kick_iso(ems_pds,nb_big,iso_name,units,triflex_flag,seed,def)
char			*ems_pds;	/* file to run		         */
short			 nb_big;	/* number of elements            */
char			*iso_name;	/* iso file name	         */
short  		         units;	/* nb of disconnected sections	 */
int			 triflex_flag;  /* flag=1 for stress analysis	 */
char			*seed;		/* seed file name		 */
char			*def;		/* defaults file name 		 */

/*.kick_iso*/
{
 char  szProductPath[100],szFullFilePath[100];
 char  units_set[10];
 int   nb_arg;
 char  *tmp[8],*pName;
 long retmsg;
 int   status;
  FILE  *fp;

 /*"units : %d\n",units*/
 /*"triflex_flag: %d\n",triflex_flag*/
 /*"seed: %s\n",seed*/
 /*"def: %s\n",def*/

 if(nb_big < 0) return 1;

/* Get full path of product in which we will find the kshell to be kicked */

/* set product name in which the executable has to be found. 
 * KDD Nov-10-96 	Always kick off VR_ISO_CLIENT_KSH_NAME.
 *			The later tests QUEUE value to start NQS or isogen.sh 
 *	Result:		pName ="Route", is same for Triflex and Isogen.
*/

 if (triflex_flag) 	pName = "Route";
 else			pName = VR_ROUTE_PROD_NAME;

 status= VR$GetUnixPath (msg 		= &retmsg,
			product_name	= pName,
			file_path	= ems_pds,
			product_path	= szProductPath,
			product_path_len= sizeof (szProductPath)  );

 if ( !(status&1) ) {
	printf("File %s not found in any product !\n", ems_pds);
	return 0;
 }

/* Build full pathname of the shell file */
sprintf ( szFullFilePath, "%s%s", szProductPath, ems_pds );

/* ---- Why ? I don't know but I leave it --- */
if(! (fp=(FILE*)fopen(szProductPath,"r")) )
	printf("product isogen not found\n");

if(!triflex_flag)
{ 
	/*| ISOGEN Start process\n*/

	nb_arg = 8;
	sprintf(units_set,"%d",units);
	tmp[0] = szFullFilePath;
	tmp[1] = szProductPath;
	tmp[2] = iso_name;
	tmp[3] = units_set;
	tmp[4] = seed;
	tmp[5] = def;
	tmp[6] = QUEUE;
	tmp[7] = user_mail;

 /*"Run: %d, argc: %s,%s,%s,%s,%s,%s\n", nb_arg,tmp[0], tmp[1], tmp[2], tmp[3], tmp[4],tmp[5]*/
}
else
{

	/*|TRIFLEX Start process\n*/

	nb_arg = 5;
	sprintf(units_set,"%d",units);
	tmp[0] = szFullFilePath;
	tmp[1] = szProductPath;
	tmp[2] = iso_name;
	tmp[3] = def;
	tmp[4] = units_set;

 /*"Run:%d,  argc: %s, %s, %s, %s\n", nb_arg,tmp[0], tmp[1], tmp[2],tmp[3],tmp[4]*/
}


 if( !ex$fork(	num_entry = nb_arg,
		argu	  = tmp ))
   {
    printf("Error in fork command, no iso extraction done\n");
    return 0;
   }

 return 1;
}


end implementation Root;

