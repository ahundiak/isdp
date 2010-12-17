#include "machine.h"
/******************************************************************************
*                                                                             *
*		MEMcopy_row(list1, list2, row_no)                             *
*               MEMptr list1   == Source MEMBuffer                            *
*               MEMptr *list2  == Destination MEMbuffer pointer               *
*               long row_no    == Row number to copy                          *
*                                                                             *
*      Note:    The calling function should call MEMbuild_array on the source *
*               before calling this function and should call MEMbuild_array   *
*               on the destination after calling this function                *
*                                                                             *
*		Example:                                                      *
*                       MEMbuild_array(list1);                                *
*                           [some more stuff]                                 *
*                       MEMcopy_row(list1, &list2, rownumber);                *
*                       MEMbuild_array(list2);                                *
******************************************************************************/

#include <stdio.h>
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"


MEMcopy_row(list1, list2, row_no)
	MEMptr list1, *list2;
	long row_no ;
{
   	char *fname="MEMcopy_row";
	int i,j;
	char **data, **format,**column ;
        char *size_str ;
	int row_size ;
        long status;
	
        _NFMdebug((fname,"Entry: MEMptr list1 <%x> *list2 <%x> row_no <%d>\n",list1,*list2,row_no ));
	
/* check if the pointer to the list is NULL */
	if(list1 == NULL)
	{
		_NFMdebug((fname,"Input MEMlist is NULL <%d>\n",list1));
                status = ERRload_struct(MEM,MEM_E_NULL_SRC_LIST,"%s","list1");
                return(MEM_E_NULL_SRC_LIST);

	}
/* check if the pointer to the MEMptr is NULL */
	if(list2 == NULL)
	{
	   _NFMdebug((fname,"Output list pointer address is <%d>\n",list2));
           ERRload_struct(MEM,MEM_E_NULL_LIST,"%s","list2 buffer ptr NULL");
           return(MEM_E_NULL_LIST);
	}

/*******MEMbuld_array should not called here since the calling function*******
        takes care of that	-DEP

/ *	build the array of list * /
        if( ( status = MEMbuild_array(list1) ) != MEM_S_SUCCESS )
        {
           _NFMdebug((fname,"MEMbuild_array failed for  input list\
           status = <0x%.8x>\n" , status));
           ERRload_struct(MEM,status,"",NULL);
           return(status);
        }
******************************************************************************/

/* generate the data lists */
        data = (char **) list1->data_ptr;
	column =( char **) list1->column_ptr;
	format = (char **) list1->format_ptr;
		
/* check if output list is empty */
/* Open a memory structure */
        if(*list2 == NULL)
        {
            if((status=MEMopen(list2,4*MEM_SIZE)) != MEM_S_SUCCESS )
            {
              _NFMdebug((fname,"MEMopen failed for list2 status = <0x%.8x>\n", 
							    	      status));
              ERRload_struct(MEM,status,"",NULL);
              return(status);
            }
	

/* write the format */
       	    for(i=0 ; i < list1-> columns; i++)
	    {
	       if((status = MEMwrite_format(*list2,column[i],format[i]))
							       != MEM_S_SUCCESS)
	       {	
                  _NFMdebug((fname,
	     "MEMwrite_format failed for list2 column <%s> status = <0x%.8x>\n",
			     status));
                  ERRload_struct(MEM,status,"",NULL);
		  MEMclose(list2);
       		  return(status);
	       }
            }
        }
       
/*	malloc the string + 2 * number of columns */
        row_size = list1->row_size + 2 * (list1->columns);
  	size_str = (char *) malloc (row_size);
        if(size_str == (char *)0)
	{
 		_NFMdebug((fname,"Malloc failed for size <%d>\n",row_size));
                ERRload_struct(NFM,MEM_E_MALLOC,"%d",row_size);
		return(MEM_E_MALLOC);
	} 
/* load the data for a particular row */
        size_str[0] = '\0' ;
	row_no--;
 	for(i=0;i < list1->columns; i++)
	{
		j= row_no * list1->columns + i;
		strcat(size_str,data[j]);
		strcat(size_str,"\1");
	}
	if((status = MEMwrite(*list2,size_str)) != MEM_S_SUCCESS)
	{
		_NFMdebug((fname,"MEMwrite failed : status <0x%.8x>\n",status));
                ERRload_struct(MEM,status,"",NULL);
		free(size_str);
		return(status);
	}
        free(size_str);
	_NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",MEM_S_SUCCESS));
	return(MEM_S_SUCCESS);		
}
