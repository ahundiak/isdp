/* #######################    APOGEE COMPILED   ######################## */

/*\
 	Contains the support routines to implement a dictionary of 
 	(name, object_id) pairs. 
\*/


#include <stdio.h>
/*
#include "coimport.h"
*/

#define	MAX_MEM	10


typedef struct{
		int	oid;
		char	*name;
} ENTRY;

typedef struct{
		ENTRY	*entries;
		int	count;
}	BUFFER;


static BUFFER	ent_buf = { NULL, 0 };


char *calloc(), *realloc();
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ add_mem */
/*
 * This routine reallocates memory to mem_ptr if appropriate.
 *
 */


/*     mem_ptr:   pointer to the first element of the variable array
                  e.g  array_name.
      allocate:   present size(present_index) of the variable array.
    size_bytes:   size of individual elements of the variable array.
*/

char *add_mem(mem_ptr, allocate, size_bytes)
char	*mem_ptr;
int	allocate, size_bytes;
{	

	if(!allocate)	{
		if((mem_ptr=(char *)calloc(MAX_MEM,size_bytes))==NULL)
			return(0);
	}
	else	{
		  if(!(allocate%MAX_MEM))	{ 
			if((mem_ptr=(char *)realloc(mem_ptr,
				 (allocate+MAX_MEM)*size_bytes))==NULL)
				 return(0);
		
		  } 
	}
	
	return((char *)mem_ptr);	
}	


/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ add_to_buf */
/*
 * Adds a ( name, object_id ) pair to the dictionary.
 *
 */

int add_to_buf( name, oid )
char 	*name;
int  	oid;
{
 int i;
 int count = ent_buf.count;

 /* search for an empty slot */
 for(i=0; i<count; i++){
   if(!(ent_buf.entries[i].oid))
		break;
 }

 if(i == count ){ /* if an empty slot is not found, allocate one */
   ent_buf.entries=(ENTRY *)add_mem( (char *)ent_buf.entries,count,sizeof(ENTRY));
   ent_buf.count++;
 }

 /* setup the entry */
 ent_buf.entries[i].oid=oid;
 ent_buf.entries[i].name=(char *)calloc(strlen(name)+1,sizeof(char));
 strcpy(ent_buf.entries[i].name, name);

 return(1);

}

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ rem_from_buf */
/*
 * Removes an entry from the dictionary.
 *
 */

int rem_from_buf(name)
char *name;
{
 int i,j;
 int count = ent_buf.count;

 /* search for the entry */
 for(i=0;i<count; i++){
   if(!(ent_buf.entries[i].name == NULL))
   if(!(j=strcmp(ent_buf.entries[i].name, name)))
		break;
 }

 /* if not found */
 if(i == count) return(0);

 free((char *) ent_buf.entries[i].name);
 ent_buf.entries[i].oid =0;

 return(1);

}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ find_from_buf */
/*
 * Locates an entry in in the directory.
 *
 */

int find_from_buf(name, num, oid)
char *name;
int *num, *oid;
{
 int i,j;
 int count = ent_buf.count;

 /* search for the entry */
 for(i=0;i<count; i++){
    if(!(ent_buf.entries[i].name == NULL))
   if(!(j=strcmp(ent_buf.entries[i].name, name)))
		break;
 }

 
 if(i == count) 	/* if not found */
	*num = 0;
 else  			/* if found */
	*num = 1;
if(!(ent_buf.entries == NULL))
 *oid = ent_buf.entries[i].oid;
 else
 *oid = 0;

 return(1);

}

