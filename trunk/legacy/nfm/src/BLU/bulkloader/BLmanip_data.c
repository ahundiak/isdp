#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "UMS.h"
#include "BLums.h"
#include "BLdefs.h"
#include "BLtypes.h"
#include "BLvars.h"


/******************************************************************************

Doc:    BLallocate_data

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLmanip_data.c

Author: Rob Whitesell

Date:   February 2, 1992

Description:
        This function allocates or re-allocates the data section of the 
           attribute structure as needed.
        It writes bad allocation messages to the results file.

Examples:
        BLallocate_data(cell,num,size);

Return Status:
        DMD_S_SUCCESS     -memory allocated
        DMD_E_BAD_ALLOC   -allocation falied.

History:
******************************************************************************/

long BLallocate_data(cell,num,size) 
   int cell;                /* I - cell of structure to mainp. */
   int num;                 /* I - number of cells to allocate */
   int size;                /* I - size of each cell to allocate */
{
int i;

   if (attributes[cell].alloc_num<num) {
      if (attributes[cell].alloc_num)
         attributes[cell].data = (char **) realloc(attributes[cell].data
                                                  ,num*sizeof(char **));
      else
         attributes[cell].data = (char **) malloc(num*sizeof(char **));
      }
 
   if (!attributes[cell].data) {
      attributes[cell].alloc_num = 0;
      BLwrite_result(DMD_E_BAD_ALLOC,"");
      return(DMD_E_BAD_ALLOC);
      }

   if (attributes[cell].alloc_size < size)
      for (i=0;i<attributes[cell].alloc_num;i++)
         attributes[cell].data[i] = (char *) realloc(attributes[cell].data[i]
                                                    ,size*sizeof(char));

   for (i=attributes[cell].alloc_num;i<num;i++)
      attributes[cell].data[i] = (char *) malloc(size*sizeof(char));

   for (i=0;i<num;i++)
      if (!attributes[cell].data[i]) {
         attributes[cell].alloc_num=0;
         attributes[cell].alloc_size=0;
         BLwrite_result(DMD_E_BAD_ALLOC,"");
         return(DMD_E_BAD_ALLOC);
         }

   attributes[cell].alloc_size=size;
   attributes[cell].alloc_num=num;
   return(DMD_S_SUCCESS);
}


/******************************************************************************

Doc:    BLallocate_attrs

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLmanip_data.c

Author: Rob Whitesell

Date:   February 2, 1992

Description:
        This function allocates or re-allocates the attribute structure as
           needed.
        It writes bad allocation messages to the results file.

Examples:
        BLallocate_attrs(num);

Return Status:
        DMD_S_SUCCESS     -memory allocated
        DMD_E_BAD_ALLOC   -allocation falied.

History:
******************************************************************************/

long BLallocate_attrs(num) 
   int num;                 /* I - number of cells to allocate */
{
long status;
int  i;

   if (attributes) 
      attributes = (struct attr_type *) 
                   realloc(attributes,num*sizeof(struct attr_type));
   else
      attributes = (struct attr_type *) 
                   malloc(num*sizeof(struct attr_type));
 
   if (!attributes) {
      BLwrite_result(DMD_E_BAD_ALLOC,"");
      num_of_attr_alloc = 0;
      return(DMD_E_BAD_ALLOC);
      }

   for (i=num_of_attr_alloc;i<num;i++) {
      attributes[i].name = (char *) malloc(MAX_ATTR_NAME_LEN*sizeof(char));
      attributes[i].alloc_size=0;
      attributes[i].alloc_num=0;
      attributes[i].stored=0;
      status = BLallocate_data(i,DATA_CHUNKS,DEFAULT_DATA_LENGTH);
      if (status!=DMD_S_SUCCESS || !attributes[i].name) {
         num_of_attr_alloc = 0;
         BLwrite_result(DMD_E_BAD_ALLOC,"");
         return(DMD_E_BAD_ALLOC);
         }
      }

   num_of_attr_alloc = num;
   return(DMD_S_SUCCESS);
}


/******************************************************************************

Doc:    BLclear_attrs

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLmanip_data.c

Author: Rob Whitesell

Date:   February 2, 1992

Description:
        This function clears the attribute structure for a new record.

Examples:
        BLclear_attrs();

Return Status:
        DMD_S_SUCCESS     -data space cleared

History:
******************************************************************************/

long BLclear_attrs() 
{
   num_of_attributes = 0;
   return(DMD_S_SUCCESS);
}


/******************************************************************************

Doc:    BLcatch_up_data

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLmanip_data.c

Author: Rob Whitesell

Date:   February 2, 1992

Description:
        This function catches up the default values if an aditional file has
           been added.

Examples:
        BLcatch_up_data(num);

Return Status:
        DMD_S_SUCCESS     -data stored.
        any error returned by calling functions.

History:
******************************************************************************/

long BLcatch_up_data(num) 
  long  num;     /* I - the file number to catch up to */
{
int i,j,st;
long status;

   for (i=0;i<num_of_attributes;i++) {
      if (num>attributes[i].alloc_num) {
         status=BLallocate_data(i,(int)num+1,(int)attributes[i].alloc_size);
         if (status != DMD_S_SUCCESS)
            return(status);
         }
      st=(attributes[i].stored)?attributes[i].stored-1:0;
      for (j=st;j<num-1;j++)
         strcpy(attributes[i].data[j+1],attributes[i].data[j]);
      }

   return(DMD_S_SUCCESS);
}


/******************************************************************************

Doc:    BLstore_attrs

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLmanip_data.c

Author: Rob Whitesell

Date:   February 2, 1992

Description:
        This function stores a value in the attribute.
        The index is passed back in slot, if you know the slot, pass a null for
           attr and send the value through slot.

Examples:
        BLstore_attrs(attr
                      &slot
                      data
                      file_num);

Return Status:
        DMD_S_SUCCESS     -data stored.
        any error returned by calling functions.

History:
******************************************************************************/

long BLstore_attrs(attr,slot,data,num) 
  char *attr;    /* I - name of attr to store in; NULL if slot known. */
  long *slot;    /* I/O - slot number for attr */
  char *data;    /* I - data to store */
  long  num;     /* I - the file number this data goes with */
{
int i,k;
long status;

   status=DMD_S_SUCCESS;
   if (attr) {
      for (i=0;i<num_of_attributes;i++)
         if (!strcmp(attributes[i].name,attr) )
            break;
      }
   else
      i=(int)*slot;

   if (i>=num_of_attributes) {
      if (i>=num_of_attr_alloc) 
         status=BLallocate_attrs(i+4);
      if (status != DMD_S_SUCCESS) 
         return(status);
      if (attr)
         strcpy(attributes[i].name,attr);
      for (k=num_of_attributes;k<=i;k++) {
          attributes[k].stored=0;
          attributes[k].data[0][0]=0;
          }
      num_of_attributes=i+1;
      }
   *slot=(long)i;

   if (num>attributes[i].alloc_num) {
      status=BLallocate_data(i,(int)num+1,(int)attributes[i].alloc_size);
      if (status != DMD_S_SUCCESS)
         return(status);
      }

   if (strlen(data)>attributes[i].alloc_size) {
      status=BLallocate_data(i,(int)attributes[i].alloc_num,strlen(data)+5);
      if (status != DMD_S_SUCCESS)
         return(status);
      }

   strcpy(attributes[i].data[num-1],data);
 
   if (num>attributes[i].stored) {
      attributes[i].stored=num;
      if (num != 1)
         status=BLcatch_up_data(num);
      if (status != DMD_S_SUCCESS)
         return(status);
      }
   
   return(DMD_S_SUCCESS);
}
