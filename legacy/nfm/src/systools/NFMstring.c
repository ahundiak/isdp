#include "machine.h"
#include "NFMsysinc.h"

/* type = 0 -> upper case type =1 -> lower case */
 long NFMchange_case (str, type)
   char   *str;
   long    type;
   {
     long    x;

     if (str)
      {
         for (x = 0; x < strlen (str); ++x)
          {
            if (type)
             {
               if (str [x] >= 'A' && str [x] <= 'Z') 
                  str [x] = str [x] - 'A' + 'a';
             }
            else
             {
               if (str [x] >= 'a' && str [x] <= 'z') 
                  str [x] = str [x] - 'a' + 'A';
             }
          }
       }

     return (NFM_S_SUCCESS);
   }

 long NFMupper_case (in_str, out_str)
   char   *in_str;
   char   *out_str ;
   {
     char    *fname = "NFMupper_case" ;
     long    x;

     if (in_str)
      {
	for (x = 0; x < strlen (in_str); ++x)
	  {
	    if (in_str [x] >= 'a' && in_str [x] <= 'z') 
	      out_str [x] = in_str [x] - 'a' + 'A';
	    else out_str [x] = in_str[x] ;
	  }
      }

     out_str [strlen (in_str)] = 0 ;
     _NFMdebug ((fname, "In string %s : Out string %s\n", 
		 in_str, out_str)) ;
     return (NFM_S_SUCCESS);
   }

 long NFMlower_case (in_str, out_str)
   char   *in_str;
   char   *out_str;
   {
     char    *fname = "NFMlower_case" ;
     long    x;

     if (in_str)
       {
	 for (x = 0; x < strlen (in_str); ++x)
	   {
	     if (in_str [x] >= 'A' && in_str [x] <= 'Z') 
	       out_str [x] = in_str [x] - 'A' + 'a';
	     else out_str [x] = in_str [x] ;
	   }
       }

     out_str [strlen (in_str)] = 0 ;
     _NFMdebug ((fname, "In String %s : Out String %s\n", in_str, out_str)) ;
     return (NFM_S_SUCCESS);
   }

 long NFMparse_string (in_str, out_str)
   char   *in_str, *out_str;
   {
     char *fname = "NFMparse_string" ;
     long    x, y;

     _NFMdebug ((fname, "In Str  = <%s>\n", in_str ));

     out_str [0] = 0;

     if (in_str)
      {
         for (x = 0, y = 0; x < strlen (in_str); ++x, ++y)
          {
             if (in_str [x] == '\'')
              {
                 out_str [y] = '\'';
                 y++;
              }

             out_str [y] = in_str [x];
          }

         out_str [y] = 0;
      }

     _NFMdebug ((fname, "SUCCESSFUL : Out Str = <%s>\n", out_str));
     return (NFM_S_SUCCESS);
   }
/* This routine searches the input string for tic marks and preceeds each
 * tic mark with another one so that it can be inserted into the
 * database.
 */

NFMj_tic_search( pwd, temp )
   char  *pwd;
   char  *temp;
{
   while( *pwd )
   {
	if( *pwd == '\'' )
	{
	   *temp = '\'';
	   ++temp;
	}
	*temp++ = *pwd++;
   }
   *temp = '\0';
}

/*****
	This function checks for existence of <catalog> and f_<catalog>
	in the from_clause passed in.

	if both
		*return_flag = 2
	else if f_catalog only
		*return_flag = 1
	else
		*return_flag = 0	

******/
int _NFMcat_f_cat(from_clause,return_flag)
	char *from_clause;
	int *return_flag;
{
	char *fname="_NFMcat_f_cat";
	char *c_ptr;
	_NFMdebug((fname,"from_clause <%s>: return_flag address <%x> : *return_flag <%d>\n",from_clause,return_flag,*return_flag));

	/*  Initialize the return flag  */

	*return_flag = 0;

	/*  Check for presence of the file catalog  */

	c_ptr=strstr(from_clause,"f_");
 	if(c_ptr) (*return_flag)++;

	/*  Check for the presence of both catalogs  */

	c_ptr=strstr(from_clause,",");
 	if(c_ptr) (*return_flag)++;

	_NFMdebug((fname,"SUCCESS: *return_flag <%d>: status <0x%.8x>\n",*return_flag,NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}
int _NFMf_cat(clause,return_flag)
	char *clause;
	int *return_flag;
{
	char *fname="_NFMf_cat";
	char *c_ptr;
	_NFMdebug((fname,"clause <%s>: return_flag address <%x> : *return_flag <%d>\n",clause,return_flag,*return_flag));

	/*  Initialize the return flag  */

	*return_flag = 0;

	/*  Check for presence of the file catalog  */

	c_ptr=strstr(clause,"f_a.");
 	if(c_ptr) (*return_flag)++;

	_NFMdebug((fname,"SUCCESS: *return_flag <%d>: status <0x%.8x>\n",*return_flag,NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}

long _DMins_bs(string,length)
	char *string;
	long length;
{
	char *fname="_DMins_bs";
	char *ptr,*ptr2;
	long len=0,i;
	_NFMdebug((fname,"Enter: string <%s> length <%ld>\n",string,length));
	if(string == NULL || *string=='\0')
	{
		_NFMdebug((fname,"String is NULL\n"));
		return(NFM_E_FAILURE);
	}
	len=strlen(string);
	ptr=(char *)malloc(length+1);

	if(ptr == (char *)0)
	{
		_NFMdebug((fname,"Cannot allocate buffer : size <%d>\n",length));
		return(NFM_E_FAILURE);
	}
	ptr2=ptr;
	strcpy(ptr,string);
	len=i=0;
	while(i<length && string[len] != '\0' )
	{
		*ptr = string[len];
		if(string[len]=='\\')
		{
			ptr++;
			i++;
			*ptr='\\';
			if(i==length) break;
		}
		len++;
		ptr++;
		i++;
	}	
	if(i == length)
	{
		_NFMdebug((fname,"String insufficient\n"));
		free(ptr2);
		
		return(NFM_E_FAILURE);
	}
	*ptr='\0';
	strcpy(string,ptr2);
	free(ptr2);
	_NFMdebug((fname,"Success\n"));
	return(NFM_S_SUCCESS);

}


