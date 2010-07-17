/***************************************************************************
 * I/STRUCT
 *
 * File:	vsjoint/VSwldfrfiles.C
 *
 * Description:
 *
 * Dependencies:
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	09/20/96	K.V.Suresh	Macros to get the weld code and weld
					process from the ascii file
 *
 ***************************************************************************/


/*
	I/STRUCT
*/
#include <stdio.h>
#include "exmacros.h"
#include "DIdef.h"
#include "msdef.h"


/*	
	IN	name		name of the file 
	IN	ptfile		file pointer
	This function opens the file "name" in the current working directory
	or in the product/config/joints or in the user path in read mode
*/
IGRlong VSopen_setup_file (char *name, FILE **ptfile )
{
	char    	complete_path[DI_PATH_MAX],  /* path along with the 
							name of the file    */
			path[DI_PATH_MAX];	     /* path of the file    */
	IGRint  	i;			     /* Loop index 	    */
	IGRlong 	sts;			     /* return status       */

        /*
         * search weld_code or weld_proc file in the current directory
         */

        *ptfile = fopen(name,"r");
        if (*ptfile == NULL) {
                /*
                 * get product path
                 */
                for( i=0; ; i++ ) {
                        sts = ex$get_path(      index   = i,
                                                path    = path,
                                                len     = DI_PATH_MAX,
                                                type    = EX_CONFIG_PATH );
                        if( ! (sts&1))  break;
	                /*
        	         * The first path could be the user path, search in it.
                	 */
                        if (i==0) {
                                sprintf( complete_path, "%s%s", path,name);
                                *ptfile = fopen( complete_path, "r" );
                                if(*ptfile != NULL)      break;
                        }
                        sprintf( complete_path, "%sconfig/joints/%s",
                                                                path,name);
                        *ptfile = fopen( complete_path, "r" );
                        if(*ptfile != NULL)      break;
                        return 0;
                }
        }
        return 1;
} /* VSopen_setup_file */
/*----------------------------------------------------------------------------*/
/*	This function is interface by the macro vs$getWeldCodeASCII	      */
/*----------------------------------------------------------------------------*/
long VSgetWeldCodeASCII( long *msg, char *name, int *count, char ***list )
{

	/*
	 * This function is interfaced by macro `vs$getWeldCodes' defined
	 * in vsjntmacros.h
	 */
	long	sts ;
	FILE	*ptfile = NULL ;
	char	**tmpList ;
	char	buffer[200] ;
	char    word[50], cc ;
	int	len, cnt;

	sts = VSopen_setup_file (name,&ptfile);
	if( !sts ) {
		*msg = MSFAIL;
		goto wrapup;
	}

	cnt = len = 0;
	/*
	 * Allocate the memory for the tmpList
	 */ 
	tmpList = (char **)malloc(sizeof(char *));

        while (EOF != fscanf(ptfile,"%s",word)) {
                cc = word[0];
                if (cc == '%') {
                        if (word[1] == '\0') {
			
				cnt++;
                                fgets(buffer,199, ptfile);
	
				len = strlen(buffer);
		
				tmpList = (char **)realloc( tmpList,
						       (cnt)*sizeof(char *));
				tmpList[(cnt)-1] = (char *)malloc( 
							len*sizeof(char));

				strcpy( tmpList[(cnt)-1], buffer+1 );
                        }
                }
        }
        fclose(ptfile);
	
	*count = cnt ;
	*list	= tmpList;
	*msg = MSSUCC ;

wrapup:
	return sts ;

} /* VSgetWeldCodeASCII */
/*----------------------------------------------------------------------------*/
/*	This function is interface by the macro vs$getWeldProcASCII	      */
/*----------------------------------------------------------------------------*/
long VSgetWeldProcASCII( long *msg, char *name, int *count, char ***list )
{

	/*
	 * This function is interfaced by macro `vs$getWeldCodes' defined
	 * in vsjntmacros.h
	 */
	long	sts ;
	FILE	*ptfile = NULL;
	char	**tmpList ;
	char	buffer[200] ;
	char    word[50], cc ;
	int	len, cnt ;


	sts = VSopen_setup_file (name,&ptfile);
	if( !sts ) {
		*msg = MSFAIL;
		goto wrapup;
	}

	cnt = len = 0;
	/*
	 * Allocate the memory for the tmpList
	 */ 
	tmpList = (char **)malloc(sizeof(char *));
	tmpList[0] = (char *)malloc(80*sizeof(char));

        while (EOF != fscanf(ptfile,"%s",word)) {
                cc = word[0];
                if (cc == '%') {
                        if (word[1] == '\0') {
				cnt++;
                                fgets(buffer,199, ptfile);
	
				len = strlen(buffer);
				tmpList = (char **)realloc( tmpList,
							(cnt)*sizeof(char *));
				tmpList[(cnt)-1] = (char *)malloc( 
							len*sizeof(char));
				strcpy( tmpList[(cnt)-1], buffer+1 );
                        }
                }
        }
        fclose(ptfile);

	*count = cnt ;
	*list	= tmpList;
	*msg = MSSUCC ;

wrapup:
	return sts;

} /* VSgetWeldProcASCII */
/*----------------------------------------------------------------------------*/

