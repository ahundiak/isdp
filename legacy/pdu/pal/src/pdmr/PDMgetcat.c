/*#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include "PALglbs.h"
#include "PDUerror.h"
#include "MEMerrordef.h"
#include "PALmsg.h"
*/
#include "PALpdmr.h"
#include "PALpdmrpro.h"

GetDepthofCatalog( catname, p_depth )
char *catname;
int *p_depth;
{
char *query, *output_str = NULL, *ptr = NULL, viewORtable[10];
int  max_rows, error_code;
int  sts, tbl_no;

        _pdm_debug("Enter: GetDepthofCatalog",0);
        _pdm_debug(" catalog name= %s",catname);

	GetCatTableNo( catname, &tbl_no, viewORtable );

        _pdm_debug("Before depth ", 0 );
        /* Prepare query to get p_depth */
        query = (char *)malloc(156);
        _pdm_debug("Before MEMcheck", 0 );
        MemCheck(query);

        query[0] = '\0';

        sprintf(query,"Select p_depth from pdmcatalogs where n_catalogno = %d",
					tbl_no );

        _pdm_debug("RIS query = %s", query );

        /* Send RIS query */
        max_rows = 1;
        sts = RISquery (query, &max_rows, &output_str, &error_code);

        MyFree(query);
        if (sts < 0)
        {
                fprintf (stderr, "Error In RIS Operation - %d\n", error_code);
                free(output_str);
                return(0);
        }

        _pdm_debug("RISquery output_str = %s", output_str );

       if ((output_str) && (strlen(output_str)))
         {
	_pdm_debug("before strtok", 0);
	ptr = strtok( output_str, "~" );
	_pdm_debug("assigning p_depth", 0);
	*p_depth = atoi( ptr );

	_pdm_debug("p_depth = %d", *p_depth );
	MyFree( output_str );
	_pdm_debug("freeing output_str", 0);
        }
       else
         {
	 _pdm_debug("assigning p_depth", 0);
         *p_depth = 0;
         } 

	 _pdm_debug("Leaving Depth of Catalog", 0);
	return( 1 );


}

GetCatPath( catname, p_depth, catpath )
char *catname;
int  p_depth;
char **catpath;
{
char *query, *output_str, *ptr, viewORtable[6];
int  max_rows, error_code;
int  sts, i, tbl_no;
char tmp[20];

	*catpath = NULL;

	if ( !p_depth )
		return(1);

        _pdm_debug("Enter: GetCatPath",0);
        _pdm_debug(" catalog name= %s",catname);
        _pdm_debug(" catalog depth= %d",p_depth);

	GetCatTableNo( catname, &tbl_no, viewORtable );

        /* Prepare query to get p_levels */
        query = (char *)malloc(1024);
        MemCheck(query);

	strcpy( query, "Select " );
	for( i = 0; i < p_depth; i++ )
	{
        	sprintf(tmp,"p_level%d", i+1 ); 
		strcat( query, tmp );
		if( i < p_depth - 1 )
			strcat( query, "," );
	}

	strcat( query, " from pdmcatalogs where n_catalogno = " );
	sprintf( tmp, "%d", tbl_no );
	strcat( query, tmp ); 

        _pdm_debug("RIS query = %s", query );

        /* Send RIS query */
        max_rows = 1;
        sts = RISquery (query, &max_rows, &output_str, &error_code);

        MyFree(query);
        if (sts < 0)
        {
                fprintf (stderr, "Error In RIS Operation - %d\n", error_code);
                free(output_str);
                return(0);
        }

        _pdm_debug("RISquery output_str = %s", output_str );

	ptr = strtok( output_str, "~" );
	
	*catpath = (char *)malloc( strlen(ptr) + 3 );
	MemCheck( *catpath );
	(*catpath)[0] = '\0';

	while( ptr )
	{
		*catpath = (char *)realloc(*catpath, strlen(*catpath) + 
							strlen(ptr) + 3);
		MemCheck(*catpath);

		strcat(*catpath,ptr);
		strcat(*catpath,":");

		ptr = strtok( NULL, "~" );
	}
	MyFree( output_str );

	_pdm_debug("catpath = %s", *catpath );

	return( 1 );


}
