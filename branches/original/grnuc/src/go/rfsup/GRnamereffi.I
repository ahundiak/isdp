class implementation GRreffile;

#include "grimport.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "msdef.h"
#include "DImacros.h"
#include "referr.h"
#include <ctype.h>


GRsort_dir_names(ptr1,ptr2)
IGRchar **ptr1,**ptr2;
{
   IGRint l1,l2;

   l1 = strlen(*ptr1);
   l2 = strlen(*ptr2);

   if (l1 < l2)
   {
	return(-1);
   }
   else if (l1 > l2)
   {
	return(1);
   }
   else	
   {
	return(strcmp(*ptr1,*ptr2));
   }
}

/*

Name
  GRname_reffile

Abstract
  This function generates a valid name for a reference file attachment.

Synopsis

int GRname_reffile(msg,name,filename,ref_id,constr_flag,logical)
long		*msg		How did it go (MSSUCC/MSFAIL			OUT;
char		*name		The tentative attachment name			IN;
char		*filename	The file name					IN;
struct GRid	*ref_id		The objid of the attachment			IN;
IGRboolean	*constr_flag	TRUE if the attachment is being constructed	IN;
char		*logical	The logical (attachment) name			OUT;

Description
  This function generates a valid name for a reference file attachment. If a tentative
  name is passed then we generate names from that one (with suffix 1, 2, ... until we
  find a new name). If no tentative name is passed in then we use the file name as a
  starting point. 

Return Value
  Always OM_S_SUCCESS adn *msg = MSSUCC unless a called function fails.
  
Notes

Index

Keywords
  reference-file

History
  00/00/00 : Somebody : created
  03/03/93 : Henry    : support names that starts with a '.' (remove the '.')
  
 */
int GRname_reffile(msg,name,filename,ref_id,constr_flag,logical)
long		*msg;
char		*name;
char		*filename;
struct GRid	*ref_id;
IGRboolean	*constr_flag;
char		*logical;
{
    IGRboolean	name_okay;

    IGRlong	OMmsg;
    IGRint	test_val,
		length,
		length2,
		num,i,j,
		all_digits;

    IGRchar 	**dir_names,
		regexp[DI_PATH_MAX],
		max_char[100],
		new_max[100],
		path[DI_PATH_MAX],
		extension[DI_PATH_MAX],
		current_directory[DI_PATH_MAX],
		name_match[DI_PATH_MAX];

    GRobjid	objid;
    GRspacenum	osnum;

    *msg =  MSSUCC;
    OMmsg = OM_S_SUCCESS;

    dir_names = NULL;

    di$pwd(dirname = current_directory);

    DIstmocpy(path,"ref","refnames",0,ref_id->osnum);

    di$cd(dirname = path);
 
    name_okay = FALSE;

    if ( ! (name || filename))		/* can not do anything		*/
    {
	OMmsg = OM_E_ABORT;
	*msg = MSFAIL;
	goto wrapup;
    }

    if ( name )
    {
	OMmsg = di$translate(
		objname = name,
		p_objid = &objid,
	  	p_osnum = &osnum);

	if (OMmsg == DIR_W_NAME_NOT_FOUND)	 /* if it fails, new name is valid	*/
 	{
	    OMmsg = OM_S_SUCCESS;
	    strcpy(logical,name);
	    name_okay = TRUE;
	}
	else if (*constr_flag)
	{
	    *msg = GRNAMEDUPLICATED;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}  
    }

    if (! name_okay )
    {
      char *pFileName;
      
	if ( ! filename)		/* no where to start, exit	*/
	{
	    OMmsg =  OM_E_ABORT;
	    *msg = MSFAIL;
	    goto wrapup;
	}

        for (pFileName = &filename [strlen ( filename )] - 1; pFileName != filename; pFileName--)
          if (*pFileName == '/')
          {
            pFileName++;
            break;
          }
        
        for (; *pFileName == '.'; pFileName++);

	strcpy(regexp, pFileName);	/* form regular expression	*/
	strcat(regexp,"*");
	length = strlen(pFileName);	/* find where extension starts	*/

	di$ls(regexp = regexp,
	    lines = &dir_names,
	    ptr = &num,
	    options = NULL);
	      
	if ( num == 0)			/* none found			*/
	{
	    strcpy(logical,pFileName);	/* use filename as name		*/
	}
	else
	{
	    qsort(dir_names,num,sizeof(IGRchar *),(IGRint (*)())GRsort_dir_names);

	    strcpy(max_char,"1");	/* beginning extension		*/

	    for ( i = 0; i < num; ++i)
	    {				/* get each name that matched	*/
		di$split(pathname=dir_names[i],
		    name = name_match);
					/* test for an extension	*/
	    	strcpy(extension,&name_match[length]);

	    	length2 = strlen(extension);
	    	if (length2)		/* if extension exists		*/
	    	{
		    all_digits = TRUE;	/* see if it is all integer	*/
		    for ( j = 0; j < length2 && all_digits; ++j)
		    {
		    	if (isalpha(extension[j]))
		    	{
			    all_digits = FALSE;
		    	}
		    }
		    if ( all_digits )	
		    {			
			/* see if extension is greater than maximum 
			 * known extension
			 */

		    	test_val = strcmp(max_char,extension);

		    	if (test_val < 0)
		    	{
			    /* found a hole, use this value
			     */

	    		    strcpy(logical,pFileName);
	    		    strcat(logical,max_char);

    			    di$add_name(objname = logical,
				objid = ref_id->objid);

			    goto wrapup;

		    	}
			else if (test_val == 0)
			{
			    /* if equal, increment max_char
			     */

			    for (j = strlen(max_char)-1; j >= 0; --j)
			    {
				if (max_char[j] < '9')
				{	
				    ++max_char[j];
				    j = -10;		/* exit loop	*/
				}
				else if (max_char[j] == '9')
				{
				    max_char[j] = '0';
				}
			    }
			    if ( j > -2 )
			    {
			       	/* string was all 9's 		*/
			
			       	strcpy(new_max,"1");
				strcat(new_max,max_char);
				strcpy(max_char,new_max);
			    }					
			}
		    }
	    	}
	    }
	    strcpy(logical,pFileName);
	    strcat(logical,max_char);
    	}
    }

  /* 
   * Add name to refnames directory 
   */
  di$add_name ( objname = logical, objid = ref_id->objid );

wrapup:

    if (dir_names)
    {
	di$free(lines = dir_names,
		count = num);
    }

    di$cd(dirname = current_directory);

    return (OMmsg);
}

    
end implementation GRreffile;
