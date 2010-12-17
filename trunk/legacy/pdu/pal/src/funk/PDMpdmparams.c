/******************************************************************************/
/*   	File :	PDMpdmparams.c                                                */
/*  									      */
/*   	Utility to get static and dynamic templates list of macro             */
/*      from 'pdmparameters' table.                                           */
/*  									      */
/*	Date	: 25th, May, 1992	By	Raj Shekar .P		      */
/******************************************************************************/

#include "stdio.h"
#include "string.h"
#include "malloc.h"
#include "MEMstruct.h"
#include "PALglbs.h"
#if defined (sparc) || defined (__sgi) || defined (__Sol2__)
#include <XFIproto_pub.h>
#else
#include <FIproto_pub.h>
#endif

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "exdef.h"

/*#include "PDUproto.h" */
#include "PALfunkpro.h"
#include "PALpdmrpro.h"

#define	PAL_SUCCESS	1
#define	PAL_FAILURE	0

#define Error(string, arg) {		\
        fprintf (stderr, string, arg);	\
	return (PAL_FAILURE);		\
}

#define	MemErr(ptr) {			\
	if (ptr == NULL)		\
		goto CleanUp;		\
}


GetStatAndDynAttribs (  catalog_name, 
			no_stat, stat_attr, stat_type, stat_desc, stat_unit,
			no_dyn,  dyn_attr,  dyn_type,  dyn_desc  )
char 	*catalog_name;
int 	*no_stat, *no_dyn;
char 	***stat_attr, ***stat_type, ***stat_desc, ***stat_unit,
	***dyn_attr,  ***dyn_type,  ***dyn_desc;
{

	/*	This function reads the 'pdmparameters' table	*/
	/*	and retrieves all the 'Static Attributes' of 	*/
	/*	of a macro					*/

	char	*ptr, *output,
		query[140];
	int	sts, error, max_rows;

	_pdm_debug("Entered GetStatAndDynattribs",0);

	/* Free the variables if already allocated */
	FreeArrayPtr(*dyn_attr, *no_dyn);
	FreeArrayPtr(*dyn_type, *no_dyn);
	FreeArrayPtr(*dyn_desc,*no_dyn);
	*no_dyn = 0;

	FreeArrayPtr(*stat_attr, *no_stat);			
	FreeArrayPtr(*stat_type, *no_stat);			
	FreeArrayPtr(*stat_desc, *no_stat);
	FreeArrayPtr(*stat_unit, *no_stat);
	*no_stat = 0;

	max_rows = 0;
	sprintf(query,"SELECT p_iotype, p_templatename, p_type,n_synonym, p_units FROM pdmparameters where n_catalogname = '%s'", catalog_name);

	_pdm_debug("GetStatAndDynattribs:query is %s",query);

	sts = RISquery( query, &max_rows, &output, &error);


	if( sts < 0 ){
		free(output);
		Error ("Error Accessing 'pdmparameters'. Error - %d\n", error);
	}
	_pdm_debug(" output: %s",output );

	*dyn_attr   = (char **) malloc ( sizeof (char *));
	*stat_attr = (char **) malloc ( sizeof (char *));
	*dyn_type  = (char **) malloc ( sizeof (char *));
	*stat_type = (char **) malloc ( sizeof (char *));
	*dyn_desc  = (char **) malloc ( sizeof (char *));
	*stat_desc  = (char **) malloc ( sizeof (char *));
	*stat_unit = (char **) malloc ( sizeof (char *));
	
	ptr = strtok (output, "~");

	while (ptr != NULL){

		if (!strncmp (ptr, "D", 1)){

			/* Advance to p_template */
			ptr = strtok (NULL, "~");

			*dyn_attr = (char **) realloc (*dyn_attr, (*no_dyn + 1) * sizeof (char *));
			MemErr (*dyn_attr);
			(*dyn_attr)[*no_dyn] = (char *) malloc (strlen (ptr) + 1);
			MemErr ((*dyn_attr)[*no_dyn]);
			strcpy ((*dyn_attr)[*no_dyn], ptr);

			/* Advance to p_type */
			ptr = strtok (NULL, "~");
			*dyn_type = (char **) realloc (*dyn_type, (*no_dyn + 1) * sizeof (char *));
			(*dyn_type)[*no_dyn] = (char *) malloc (strlen (ptr) + 1);
			MemErr ((*dyn_type)[*no_dyn]);
			strcpy ((*dyn_type)[*no_dyn], ptr);

			/* Advance to p_synonym */
			ptr = strtok (NULL, "~");
			*dyn_desc = (char **) realloc (*dyn_desc, (*no_dyn + 1) * sizeof (char *));
			(*dyn_desc)[*no_dyn] = (char *) malloc (strlen (ptr) + 1);
			MemErr ((*dyn_desc)[*no_dyn]);
			strcpy ((*dyn_desc)[*no_dyn], ptr);

			/* Advance to p_units */
			ptr = strtok (NULL, "~");

			*no_dyn = *no_dyn + 1;
		}
		else {
			/* Advance to p_template */
			ptr = strtok (NULL, "~");
			*stat_attr = (char **) realloc (*stat_attr, (*no_stat + 1) * sizeof (char *));
			MemErr (*stat_attr);
			(*stat_attr)[*no_stat] = (char *) malloc (strlen (ptr) + 1);
			MemErr ((*stat_attr)[*no_stat]);
			strcpy ((*stat_attr)[*no_stat], ptr);

			/* Advance to p_type	*/
			ptr = strtok (NULL, "~");	
			*stat_type = (char **) realloc (*stat_type, (*no_stat + 1) * sizeof (char *));
			MemErr (	*stat_type);
			(*stat_type)[*no_stat]= (char *) malloc (strlen (ptr) + 2);
			MemErr ((*stat_type)[*no_stat]);
			strcpy ((*stat_type)[*no_stat], ptr);
/*
printf("stat attr type: %s", ptr );
printf("stat attr type: %s", (*stat_type)[*no_stat] );
*/

			/* Advance to p_synonym	*/
			ptr = strtok (NULL, "~");	
			*stat_desc = (char **) realloc (*stat_desc, (*no_stat + 1) * sizeof (char *));
			MemErr (	*stat_desc);
			(*stat_desc)[*no_stat]= (char *) malloc (strlen (ptr) + 1);
			MemErr ((*stat_desc)[*no_stat]);
			strcpy ((*stat_desc)[*no_stat], ptr);

			/* Advance to p_unit	*/
			ptr = strtok (NULL, "~");	
			*stat_unit = (char **) realloc (*stat_unit, (*no_stat + 1) * sizeof (char *));
			MemErr (	*stat_unit);
			(*stat_unit)[*no_stat] = (char *) malloc (strlen (ptr) + 1);
			MemErr ((*stat_unit)[*no_stat]);
			strcpy ((*stat_unit)[*no_stat], ptr);

			*no_stat = (*no_stat) + 1;

		
						}

		ptr = strtok (NULL, "~");	/* Advance to p_dyn */

	}
#ifdef PDEBUG
	printf("no of stat %d\n", *no_stat ); 
	printf("no of dyn %d\n", *no_dyn ); 
	for(i=0;i<*no_dyn;i++)
		printf("dynattr[%d]=%s\n",i,(*dyn_attr)[i]);
	for(i=0;i<*no_stat;i++)
		printf("statattr[%d]=%s\n",i,(*stat_attr)[i]);
#endif

	return (PAL_SUCCESS);

CleanUp :
	
	FreeArrayPtr(*stat_attr,*no_stat);
	FreeArrayPtr(*stat_unit,*no_stat);
	FreeArrayPtr(*stat_type,*no_stat);
	*no_stat = 0;

	FreeArrayPtr(*dyn_attr,*no_dyn);
	FreeArrayPtr(*dyn_type,*no_dyn);
	FreeArrayPtr(*dyn_desc,*no_dyn);
	*no_dyn = 0 ;

	return (PAL_FAILURE);
}
