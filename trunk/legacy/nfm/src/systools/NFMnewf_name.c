#include "machine.h"
/************************************************************************
*			NFMnew_file_name				*
*	This procedure retrieves the  new file name based on     	*
*	catalog number and file number					*
*	Method								*
*	Use a 12 byte string						*
*	Load "." in 9th position					*
*	Calculate base36 number for catalog number and file number	*
*	If length (cat_no36) + length (file_no36) > 10			*
*	Filename cannot be accomodated					*
*	else
*	m= length cat_no36, n = length file_no36			*
*	load cat_no36 in first m bytes					*
*	load "_" in 12 - m -n  next bytes				*
*	load file_no36 in the next n bytes				*
*	shift byte 9, 10 ,11 to right					*
*	load "." in byte 9						*	
************************************************************************/
#include "NFMsysinc.h"


#define SEPARATOR _
#define FILE_NAME_SIZE	16
#define MAX_FILE_SIZE	11


long NFMnew_file_name(user_id,catalog_no,file_no,new_file_name)
	long user_id,catalog_no,file_no;
	char *new_file_name; /* Responsibility of calling function to
				allocate atleast FILE_NAME_SIZE of space
				*/
{
	char file_name[FILE_NAME_SIZE],catalog[FILE_NAME_SIZE],file[FILE_NAME_SIZE];
	char *fname="NFMnew_file_name";
	long status,i,j,k;
	_NFMdebug((fname,"Entry>>user_id  %d  cat_no  %d  fileno\
 %d\n\t\tnew file name\t%s\n",user_id,catalog_no,file_no,new_file_name));
/* check if catalog number and file number are valid */
	if(catalog_no <=0 || file_no <= 0)
	{
		_NFMdebug((fname,"<ERROR> catalog number <%d> or file_number<%d>\
\n is <= 0\n",catalog_no,file_no));
		status=ERRload_struct(NFM,NFM_E_NULL_VALUE,"%s","catalog no or file no");
		if(status!=ERR_S_SUCCESS)
			_NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
		return(NFM_E_NULL_VALUE);
	}
/* convert the catalog number and file number to base 36 */

	if((NFMbase36(catalog_no,catalog)) < 0)
	{
		_NFMdebug((fname,"<ERROR>Cannot get base36 for catalog number <%d> \n",catalog_no));
		status=ERRload_struct(NFM,NFM_E_BASE_36,"%s","catalog no");
		if(status!=ERR_S_SUCCESS)
			_NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
		return(NFM_E_BASE_36);
	}
/* convert the catalog number and file number to base 36 */
	if((NFMbase36(file_no,file)) < 0)
	{
		_NFMdebug((fname,"<ERROR>Cannot get base36 for file number <%d> \n",file_no));
		status=ERRload_struct(NFM,NFM_E_BASE_36,"%s","file no");
		if(status!=ERR_S_SUCCESS)
			_NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
		return(NFM_E_BASE_36);
	}
/* check if the string length of catalog + file <= 10  */

	i=strlen(catalog)+strlen(file);
	if(i > MAX_FILE_SIZE -1)
	{
		_NFMdebug((fname,"<ERROR>sizeof(catalog + file) > 10\ncatalog <%s> file<%s>\n",catalog,file));
		status=ERRload_struct(NFM,NFM_E_FILE_LEN,"%d",i);
		if(status!=ERR_S_SUCCESS)
			_NFMdebug((fname,"ERRload_struct status = <0x%.8x>\n",status));
		return(NFM_E_FILE_LEN);
	}
/*	Number of _ in the name */
	j= MAX_FILE_SIZE -i;
	for(i=0;i<FILE_NAME_SIZE;i++) file_name[i] = '\0';
	strcpy(file_name,catalog);
	i=strlen(catalog);
	for(k=i;k < i+j; k++) file_name[k] ='_';
	strcat(file_name,file);
/* Insert a dot at location 8 (0 1 2 ... ) */
	j=strlen(file_name);
	for (i=0;i< 8; i++)
		new_file_name[i]=file_name[i];
	new_file_name[8]='.';
	for(i=8;i < j;i++)
		new_file_name[i+1]=file_name[i];
	new_file_name[MAX_FILE_SIZE+1]='\0';

	_NFMdebug((fname,"SUCCESSFUL file_name is <%s>\n",new_file_name));
	return(NFM_S_SUCCESS);
}
