
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include	<stdio.h>
#include	<string.h>
#include        "refdef.h"

#define INCLUDE_EXTERN  1
#include "NFMf_xferinc.h"

/* KTB 28 Ded 93. mselems.h redefines boolean */
#include 	"mselems.h"

MSElement *element;
static unsigned short buf[6144];/* Buffer to read elements into */

char *NFMstrlwr(),
     *NFMstrupr(); /** Dur wants them changed from strlwr to something else **/
/* void r50asc();   dbase has a function in libustn.a by this name */
void m_r50asc() ;

#define FEOF (feof(input_file))
#define EOD (buf[bufpos] == 0xffff)
#define FILE_HEADER ((element->buf[0] == 0x0908) || (element->buf[0] == 0x09c8))
#define REF_ATTACH ((element->buf[0] == 0x0509) || (element->buf[0] == 0x4205))
#define RAS_MASK 0xff81
#define RAS_ATTACH ((element->buf[0] & RAS_MASK) == 0x5a01)
#define COLOR_TABLE (element->buf[0] == 0x0501)
#define WTF (unsigned short) (element->buf[1])
#define TRUE 1
#define FALSE 0

#define DISPLAYABLE  0x1
#define PLOTABLE     0x2

#define RASTER_FLAG 110


typedef struct REFLIST
{
  char path [NFM_PATHNAME] ;
  char file [NFM_FILENAME] ;
  struct REFLIST *next ;
} ;

static struct REFLIST *head ;

_NFMget_micro_files(microfile, file_list)
char *microfile;
MEMptr *file_list; 

    {
    char *fname="_NFMget_micro_files"; 
    FILE  *input_file,            /* Input design file  	            */
	  *fopen();               /* I/O routine                 	    */

    char *ptr,		/* place holder					    */
	 cellib[15],	/* attached cell library			    */
	 refFile[66],	/* reference file name				    */
	 colorTable[33];/*attached color table file			    */

    short words,	/* words read by fread				     */
	  length;	/* length of ascii string returned from rd2asc	     */

    unsigned long startbuf = 0,	/* file position in bytes of start of buffer */
		  endbuf = 0,	/* file position in bytes of end of buffer   */
		  bufpos = 0,	/* words offset within the buffer	     */
		  curpos = 0;	/* current file position in bytes	     */
    long status;
    char record[30]; /* But it is going to be no longer than 16 */
    /* added as 5/12/91 mms */
    unsigned long deleteDups = 0 ;    /* Number of attachments deleted */
    unsigned short attachedRefs[16];  /* Attachment numbers used */
    short    attachNum ;
    long     skip ;
    long     no_elements ;
    char     path [NFM_PATHNAME+1], filename [NFM_FILENAME+1] ;
    long     flag ;
    long     _NFMcheck_for_uniqueness ();

    _NFMdebug((fname,"Entry of Get micro station files [%s]\n", microfile));

    status = NFM_S_SUCCESS;
    deleteDups = 0;
    no_elements = 0 ;

    memset(attachedRefs, 0, 32) ;
    input_file=fopen(microfile,"r");

    if (!input_file)
    {
      _NFMdebug((fname,"Cannot OPEN micro file %s, status <0x%.8x>\n", 
                 microfile,status));	
      status = NFM_E_OPEN_MICRO;
      ERRload_struct(NFM,status,"",NULL);
      return(status);
    }
    skip = 0 ;
    while (!FEOF && !EOD)
    {
	fseek (input_file, curpos, 0);
	words = fread((char *)buf,2,6144,input_file); 
	if (words < 0)
        {
          _NFMdebug ((fname, "words < 0\n"));
	    /* MELANIA - needs to give a good error */
	}
	startbuf = curpos;
	endbuf = startbuf + (words * 2);
	bufpos = 0;
	element = (MSElement *)&buf[bufpos];

/*      swap bytes  lower to upper in word (16 bits) in the SUN microstation */
/* solaris added to if SSRS 27 Dec 93 */
/* HP PORT-IGI- 10 Jun 1994 */
/* Intel/Solaris Port - PS 16 May 95 */
#if (defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| defined(OS_HPUX))
          SWAP_BYTE_ARRAY(element, words); 
#endif

	_NFMdebug ((fname, 
           "after fread in while !FEOF && !EOD curpos <%d> : endbuf <%d> : WTF <%d> : buf[%d] %x\n",
	  curpos, endbuf, WTF, bufpos, buf[bufpos])) ;
	  
	if (buf[bufpos] == 0xffff)
	  {
	    _NFMdebug ((fname, "Encountered END OF FILE\n")) ;
	  }
	else if ((buf[bufpos] & 0x8000) == 0x8000)
	  {
	    _NFMdebug ((fname, "This element has been deleted\n")) ; 

            if (_NFMdebug_st.NFMdebug_on)
              {
                ++no_elements ;
                _NFMdebug ((fname, 
			    "This element %d has been deleted : WTF %u\n",
                            no_elements, WTF)) ;
              }

            if  ((curpos + (WTF + 2) * 2) >= endbuf)
              {
                curpos += ((WTF + 2) *2) ;
                continue ;
              }
 	  }
	else if (WTF > 766)
	  {
	    fclose(input_file);
	    _NFMdebug((fname,"MS element greater than 768 words : Not a design file : WTF is %d\n : skip value is %d", WTF, skip)) ;
	    _NFMfree_REF_struct () ;
	    status = NFM_E_NO_END_OF_DESIGN;
	    ERRload_struct(NFM,status,"%s",microfile);
	    return (status) ;
	  }
	
	while ((curpos + (WTF + 2) * 2) < endbuf && !EOD)
	  {
	      if (! skip) 
	      {
	      _NFMdebug ((fname, "  element was for %d\n", 
	      ++no_elements)) ;
	      _NFMdebug ((fname, "  new element first word is %x\n", 
	      buf[bufpos])) ;
	      }


	    if ((!skip) && (REF_ATTACH))
	      {
		memset(&refFile[0], ' ', 65);
		memcpy (&refFile[0], &element->buf[19], element->buf[18]);
		refFile[element->buf[18]] = '\0';

		/* strip the filename */
		status = _NFMget_path_file (refFile, path, filename, &flag);
		if (status != NFM_S_SUCCESS)
		  {
		    _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
		    _NFMfree_REF_struct () ;
		    return (status) ;
		  }
		status = _NFMcheck_for_uniqueness (path, filename) ;
		if (status == NFM_S_SUCCESS)
		  {
		    strcpy(record, filename);
		    strcat(record,"\1");
		    _NFMdebug((fname,"Extracted micro file %s\n",filename));
		    
		    if((status = MEMwrite(*file_list,record))!= MEM_S_SUCCESS)
		      {
			MEMclose(file_list);
			_NFMdebug((fname,"Get micro files: MEMwrite <0x%.8x>\n",status));
			_NFMfree_REF_struct () ;
			return(status);
		      }
		  }
	      }
	    
	    else if ((!skip) && (RAS_ATTACH))
	      {
                _NFMdebug ((fname, "&element->buf[21] (%s)\n",
                            &element->buf[21]))

                _NFMdebug ((fname, "element->buf[110] (%d)\n",
                            element->buf[RASTER_FLAG]))

                if( (element->buf[RASTER_FLAG] & DISPLAYABLE ) == DISPLAYABLE )
                {

                    memset(&refFile[0], ' ', 65) ;
                    memcpy (&refFile[0], &element->buf[21], 66);
                    refFile[65] = '\0';

		    /* strip the filename */
        	    _NFMdebug ((fname, "get path file for %s\n", refFile));
        	    status = _NFMget_path_file (refFile, path, filename, &flag);
                    if (status != NFM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
                                  status));
		      _NFMfree_REF_struct () ;
		      return (status) ;
		    }
		    _NFMdebug ((fname,
                       "check for uniqueness : path <%s> : filename <%s>\n",
			          path, filename)) ;
		    status = _NFMcheck_for_uniqueness (path, filename) ;
		    if (status == NFM_S_SUCCESS)
		    {
		      strcpy(record, filename) ;
		      strcat(record,"\1");
		      _NFMdebug((fname,"Extracted micro file %s\n",filename));
		          
		      if((status = MEMwrite(*file_list,record))!= MEM_S_SUCCESS)
		      {
			MEMclose(file_list);
			_NFMdebug((fname,"Get micro files: MEMwrite <0x%.8x>\n",status));
			_NFMfree_REF_struct () ;
			return(status);
		      }
		    }
                  }
	      }
	    
	    /*********** mms - coded received from Nancy McCall from Microstation to
	      resolve duplicate attachments ****
	      attachNum =  element->buf[51] >> 8;
	      if (bitset(attachedRefs, attachNum, 1))
	      {
	      element->ehdr.deleted = 1;
	      fseek (input_file, curpos, 0);
	      status = fwrite((char *)element, 2, 1, input_file);
	      if (!status)
	      {
	      _NFMdebug ((fname, "Error deleting duplicate attachment at offset  = %lu, attachment = %d\n",
	      curpos, attachNum));
	      }
	      else
	      {
	      _NFMdebug ((fname, "Deleting duplicate attachment number = %d\n",
	      attachNum));
	      deleteDups++;
	      }
	      }
	      else
	      {
	      set_lvl_typ(attachedRefs, attachNum, 1);
	      }
	      *************************************************/
	    
	    
	    /** This is also commented by Dontu 
	      if (COLOR_TABLE)
	      {
	      memset(&colorTable[0], ' ', 33);
	      memcpy(&colorTable[0], &element->buf[404], element->buf[403]);
	      colorTable[element->buf[403]] = '\0';
	      printf("\ncolor table file name = %s\n", colorTable);
	      }
	      **/
	    
	    skip = 0 ;
	    /* mms - According to Nancy McCall WTF (Word to found) is always the second word (16 bits) of the element */
	    if ((curpos + (WTF + 2) * 2 + 6) >= endbuf)
	      {
		_NFMdebug ((fname, "curpos <%d> : WTF <%d> : endbuf <%d>\n",
			    curpos, WTF, endbuf)) ;
		skip = 1 ;
		if (FEOF)
		  {
		    bufpos += WTF+2 ; /* found a file that broke here */
		  }
		break ;
	      }
	    
	    bufpos += WTF + 2;
	    curpos += (WTF + 2)*2;
	    element = (MSElement *)&buf[bufpos];
	    /*** debug ****
	      _NFMdebug ((fname, "inner loop : curpos <%d> : endbuf <%d> : WTF <%d> : bufpos <%d>\n",
	      curpos, endbuf, WTF, bufpos)) ;
	      *******/
	    
	    /* mms : check for EOD */
	    /**** debug ***
	      _NFMdebug ((fname, "first word is <%x>\n", buf[bufpos])) ;
	      *************/
	    if (buf[bufpos] == 0xffff)
	      {
		_NFMdebug ((fname, "Encountered END OF FILE\n")) ;
	      }
	    else if ((buf[bufpos] & 0x8000) == 0x8000)
	      {
		_NFMdebug ((fname, "This element has been deleted\n")) ;
	      }
	    else if (WTF > 766)
	      {
		fclose(input_file);
		_NFMdebug((fname,"MS element greater than 768 words : Not a design file : WTF is %d\n", WTF)) ;
		_NFMfree_REF_struct () ;
		status = NFM_E_NO_END_OF_DESIGN;
		ERRload_struct(NFM,status,"%s",microfile);
		return (status) ;
	      }
	  } /* while */
	/* mms - this not fix the problem 
	   if (curpos == startbuf
	   && (curpos + (WTF + 2) * 2) >= endbuf
	   && !EOD && !FEOF)
	   curpos += (WTF + 2) * 2;
	   */
      }
    
    if (!EOD)
      {
	_NFMdebug((fname,"Error, design file <%s> has no end-of-design marker\n", microfile));
	_NFMfree_REF_struct () ;
	status = NFM_E_NO_END_OF_DESIGN;
	ERRload_struct(NFM,status,"%s",microfile);
	return (status) ;
      }
    
    fclose(input_file);
    _NFMfree_REF_struct () ;
    _NFMdebug((fname,"Exit of <get micro station files>\n"));
    return(NFM_S_SUCCESS);
    /**
      printf ("\nAll done!\n");
      **/
  }

/*----------------------------------------------------------------------+
|									|
| name		NFMstrupr						|
|									|
| author	BJB					10/86		|
|									|
+----------------------------------------------------------------------*/
char *NFMstrupr (string)
char *string;
    {
    char *start = string;
    for (;*string; string++)
	{
/**#ifdef unix <Changed to the following>**/
/*In the below line 'if UNIX' changed to 'ifdef OS_UNIX' - SSRS 28 Dec 93 */
#ifdef OS_UNIX
	if (!(strncmp(string,"\"",1)))
#else
	if (*string == '"')
#endif
	   break;
	*string = toupper(*string);
	}
    return (start);
    }

/*----------------------------------------------------------------------+
|									|
| name		NFMstrlwr						|
|									|
| author	BJB					10/86		|
|									|
+----------------------------------------------------------------------*/
char *NFMstrlwr (string)
char *string;
    {
    char *start = string;
    for (;*string; string++)
	{
	*string = tolower(*string);
	}
    return (start);
  }

/*----------------------------------------------------------------------+
|                                                                       |
| name          m_r50asc - convers radix 50 input to ascii string output|
|                                                                       |
| author        BJB                                     2/86            |
| changes:      mms -                                   11/92           |
|               r50asc() name is used in dba library libustn.a          |
|               renamed to m_r50asc                                     |
+----------------------------------------------------------------------*/
void m_r50asc (length, input, output)
int     length;         /* => maximum length of output string
                            (excluding terminator). Should be multiple of 3 */
short   *input;         /* => radix 50 to be converted */
char    *output;         /* <= output string */

    {
    int             i, j;
    unsigned short  temp1, temp2;
    char            *out;

    for (i=0; i<(length+2)/3; i++)
        {
        temp1 = *input++;

        for (j=0, out=output+2; j<3; j++)
            {
            temp2 = temp1 % 40;
            temp1 /= 40;

            if (temp2 == 0) *out-- = ' ';
            else if (temp2 <= 26) *out-- = 'A' - 1 + temp2;
            else if (temp2 == 27) *out-- = '$';
            else if (temp2 == 28) *out-- = '.';
            else if (temp2 == 29) *out-- = '_';
            else *out-- = temp2 + '0' - 30;
            }
        output += 3;
        }
    *output = '\0';
    }

/*----------------------------------------------------------------------+
|									|
|   name	set_lvl_typ - set search criteria for specified level	|
|			      or type					|
|   author	myp							|
|									|
+----------------------------------------------------------------------*/
void set_lvl_typ (array, num, offset)
unsigned short array[];
short num;
short offset;
    {
    short i, j;

    i = (num - offset) / 16;
    j = (num - offset) % 16;
    
    array[i] |= 1 << j;
    } /* end set_lvl_typ */

/*----------------------------------------------------------------------+
|									|
| name		bitset - checks if bit is set in word			|
|									|
| author	myp					10/87		|
|									|
+----------------------------------------------------------------------*/
unsigned short bitset (array, num, offset)
unsigned short array[];
short num;
short offset;
    {
    short i, j;

    i = (num - offset) / 16;
    j = (num - offset) % 16;
    
    
    return (array[i] & 1 << j);
    }

long _NFMget_path_file (abs_path, path, file, flag)
	char *abs_path ;
	char *path ;
	char *file ;
	long *flag ;
{
  char *fname = "_NFMget_path_file" ;
  long no_rel_path, count, i, split, len ;
  char *ptr, wa[MAXFILELENGTH+1], env[MAXFILELENGTH+1] ;
  char apath [MAXFILELENGTH+1] ;
  long cnt, prev ;
  int i_status ;
  char innameP [MAXFILELENGTH+1], envvarP [MAXFILELENGTH+1] ;
  char extP [MAXFILELENGTH+1], file1 [MAXFILELENGTH+1] ;
  
  _NFMdebug ((fname, "abs_path <%s>\n", abs_path));
  
  len = strlen (abs_path) ;
  
  if ((abs_path[len-1] == '/') || (abs_path[len-1] == '\\'))
    {
      abs_path[len-1] = 0 ;
    }
  
  no_rel_path = 0 ;
  ptr = abs_path ;
  count = 0 ;
  *flag = REF_NO_PATH ; 
  strcpy (file, abs_path) ;
  
  if ((strncmp (ptr, "../", 3) == 0) ||
      (strncmp (ptr, "..\\", 3) == 0))
    {
      *flag = REF_REL_PATH ; 
      count += 3 ;
      ptr = &ptr [count] ;
      _NFMdebug ((fname, "ptr is %s\n", ptr)) ;
      ++no_rel_path ;
      
      while ((strncmp (ptr, "../", 3) == 0) ||
	     (strncmp (ptr, "..\\", 3) == 0))
	{
	  count += 3 ;
	  ptr = &ptr [count] ;
	  _NFMdebug ((fname, "ptr is %s\n", ptr)) ;
	  ++no_rel_path ;
	}
    }
  
  cnt = 0 ;
  if (*flag == REF_REL_PATH)
    {
	  len = strlen (ptr) ;
	  prev = -1 ;
	  for (i=len; i>0; i--)
	    {
	      if ((ptr[i] == '/') || (ptr [i] == '//'))
		{
		  prev = i ;
		  break ;
		}
	    }
	  if (prev > 0)
	    {
	      strcpy (file, &ptr[i+1]) ;
	      strcpy (path, "") ;
	      _NFMdebug ((fname, "RELATIVE PATH\n"));
	      return (NFM_S_SUCCESS) ;
	    }
	}
  else
    {
      prev = -1 ;
      len = strlen (abs_path) ;	
      for (i=0; i<len; i++)
	{
	  /* 133 = [ */
          _NFMdebug ((fname, "abs_path[%d] = %c\n",
                      i, abs_path[i]));
	  if ((abs_path[i] == '/') || (abs_path [i] == '//') ||
	      (abs_path[i] == ':') || (abs_path [i] == '\133') ||
              (abs_path[i] == '\\'))
	    {
	      prev = i ;
              _NFMdebug ((fname, "prev = %d\n", prev));
	      if (abs_path[i] == ':')
		{
		  *flag = REF_ENV_PATH ;
		  strcpy (env, abs_path) ;
                  /* look for the end of the path and mark it */
                  for (split = i; i < len; i++)
                  {
                    if (abs_path[i] == '/' ||
                        abs_path[i] == '\\'  )
                      split = i;
                  } 
		  env [split] = 0 ;
                  /* strip file name */
		  strcpy (file, &abs_path[split+1]) ;
		  _NFMdebug ((fname, "env <%s> : file <%s>\n", env, file));
		  strcpy (path, "ENVIRONMENT PATH") ;
		  return (NFM_S_SUCCESS) ;
		}
	      else if (abs_path [i] == '\133')
		{
		  _NFMdebug ((fname, "VAX\n"));
		  /* VAX */
		  *flag = REF_VAX_PATH ;
		  for (; i<len; i++)
		    {
		      if (abs_path [i] == '\135')
			{
			  _NFMdebug ((fname, "found bracket\n"));
			  break ;
			}
		    }
		  path [0] = 0 ;
		  prev = -1 ;
		  strcpy (file, &abs_path [i+1]) ;
		}
	    }
	}

      _NFMdebug ((fname, "prev = %d\n", prev));
      
      if (prev > 0)
	{
	  *flag = REF_ABS_PATH ;
	  
	  strcpy(path,abs_path);
	  path [prev] = 0 ;
	  
	  strcpy(file, &abs_path[prev+1]);
	  _NFMdebug ((fname, "ABS PATH\n"));
	  return (NFM_S_SUCCESS) ;

	}
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMcheck_for_uniqueness (path, file)
	char *path ;
	char *file ;
{
char *fname = "_NFMcheck_for_uniqueness" ;
long status ;
struct REFLIST *tmp_ptr ;	

	tmp_ptr = head ;
	while (tmp_ptr != 0)
	{
/*
	_NFMdebug ((fname, "Comparing %s with %s and %s with %s\n",
	tmp_ptr->file, file,
	tmp_ptr->path, path)) ;
*/
		if ((!strcmp (tmp_ptr->file, file)) &&
		    (!strcmp (tmp_ptr->path, path)))
		{
			_NFMdebug ((fname, "Already referenced\n")) ;
			return (NFM_E_FAILURE) ;
		}
		tmp_ptr=tmp_ptr->next ;
	}

	tmp_ptr = (struct REFLIST *) calloc (1, sizeof (struct REFLIST)) ;
	if (tmp_ptr == 0)
	{
		_NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
			status)) ;
		ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
		return (NFM_E_MALLOC) ;
	}

	strcpy (tmp_ptr->file, file) ;
	strcpy (tmp_ptr->path, path) ;
	tmp_ptr->next = 0 ;

	if (head != 0)
	{
		tmp_ptr->next = head ;
		head = tmp_ptr ;
	}
	else
	{
		head = tmp_ptr ;
	}

	_NFMdebug ((fname, "SUCCESSFUL\n")) ;
	return (NFM_S_SUCCESS) ;
}

long _NFMfree_REF_struct ()
{
struct REFLIST *tmp_ptr ;
	
	while (head != 0)
	{
		tmp_ptr = head->next ;
		free (head) ;
		head = tmp_ptr ;
	}

return (NFM_S_SUCCESS) ;
}

