/**********************  File: TRfile_id.c  ******************************/

#include <stdio.h>
#include "igrtypedef.h"
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>

/*----------------------------------------------------------- TRis_ascii */
/*
 *  This function checks if the input file is an
 *  ASCII file
 *
 */


IGRboolean TRis_ascii (filename)
     char *filename;
{
  FILE 		*infile;
  int		x;
  int		tmp;
  IGRboolean	is_ascii = TRUE;

    	/* ---------------------------------------------------
  	 *	Open the input file
  	 * ---------------------------------------------------	*/
  	infile = fopen(filename,"r");
  	if (!infile)
  	
      		return(FALSE);


  	/* -----------------------------------------------------
    	 *	Read first 512 characters and check if are ASCII		
  	 * -----------------------------------------------------*/
  	for(x = 0; x < 512; x++)
  	{
		tmp = getc(infile);
		if (( tmp != EOF) && (! isascii(tmp))) {
		    is_ascii = FALSE;
		  }
  	}

	fclose(infile);
	return( is_ascii );

}
/******* End function   TRis_ascii  *****/


/*--------------------------------------------------------- TRis_object_file */
/*
 *  This function checks if the input file is a non
 *  ASCII file, and if it is an object file
 *
 */

IGRboolean TRis_object_file (filename)
     char *filename;
{
  FILE 		*infile;
  int		x;
  char		buffer_143[12], buffer_200[12];
 

	if ( TRis_ascii (filename) )
	{
		return (FALSE);
	}


    	/* ---------------------------------------------------
  	 *	Open the input file
  	 * ---------------------------------------------------	*/
  	infile = fopen(filename,"r");
  	if (!infile)
      		return(FALSE);

  	/* -----------------------------------------------------
    	 *	Read firs 63 characters. The headers of
	 *      object files in position 52-62 contain the
	 *	string "OMFiledOS"
  	 * -----------------------------------------------------*/

	for (x=0; x<52; x++) getc(infile);  /* Skip first 52 char */
	fscanf (infile, "%11c", buffer_200);     /* Read next 11 char */
        
       /* PR 10/14/92: If the file is a general binary file, the
        * null terminator may occur beyond 12 bytes.  This will result
        * in segmentation violation.  So use strncpy */
  /*    strcpy(buffer_143, buffer_200+2);       */
        strncpy(buffer_143, buffer_200+2, 9);
	buffer_200[9]='\0';
	buffer_143[9]='\0';
	fclose(infile);

	if ( ! strcmp (buffer_143, "OMFiledOS" ) ||
	     ! strcmp (buffer_200, "OMFiledOS") )

		return (TRUE);
	else

		return (FALSE);
}
/**** End function   TRis_object_file ****/


/*--------------------------------------------------------- TRis_iges_file */
/*
 *  This function checks if the input file is an
 *  ASCII file, and if it is an IGES file
 *
 */

IGRboolean TRis_iges_file (filename)
     char *filename;
{
  FILE 		*infile;
  char		buffer[80];

	if ( ! TRis_ascii (filename) )
	{
		return (FALSE);
	}

    	/* ---------------------------------------------------
  	 *	Open the input file
  	 * ---------------------------------------------------	*/

  	infile = fopen(filename,"r");
  	if (!infile)
      		return(FALSE);

  	/* -----------------------------------------------------
    	 *	Read firs 80 characters, and check if
	 *	char 73 is equal 'S', and char 80
	 *	is equal '1'.
  	 * -----------------------------------------------------*/
	
	fscanf (infile, "%80c", buffer);

	fclose(infile);

	if ( buffer[72]=='S' && buffer[79]=='1' )

		return (TRUE);
	else

		return (FALSE);
}

/***** End function  TRis_iges_file  *****/


/*--------------------------------------------------------- TRis_vda_file */
/*
 *  This function checks if the input file is an
 *  ASCII file, and if it is a VDA file
 *  The first line of all VDA files contains the string "=HEADER/"
 */

IGRboolean TRis_vda_file (filename)
     char *filename;
{
  FILE 		*infile = NULL;
  char		buffer[81], pattern[7];
  IGRboolean    is_vda = FALSE, get1 = FALSE, get2 = FALSE;
  char          *p=NULL, *tmpp;

	if ( ! TRis_ascii (filename) )
	{
	    goto quit;
	}

    	/* ---------------------------------------------------
  	 *	Open the input file
  	 * ---------------------------------------------------	*/

  	infile = fopen(filename,"r");
  	if (!infile)
	    goto quit;

  	/* -----------------------------------------------------
    	 *	Read first 80 characters, and check if
	 *      there is pattern "HEADER", if so, check if
	 *      the first nonblank character before it is
	 *      "=" and the first nonblank character after
	 *      it is "/"
  	 * -----------------------------------------------------*/

	if ( fread(buffer, 1, 80, infile) != 80 )
	    goto quit;

	strcpy(pattern, "HEADER");
        p = strstr(buffer, pattern);
	if ( p == NULL )
	    goto quit;
	for ( tmpp = p - 1; tmpp >= buffer; tmpp-- )
	{
	    if ( *tmpp != ' ')
	    {
		if ( *tmpp == '=' )
		    get1 = TRUE;
		break;
	    }
	}
	if ( get1 )	/* found "=" */
	{
	    for ( tmpp = p + strlen(pattern); tmpp < buffer+80; tmpp++ )
	    {
	        if ( *tmpp != ' ' )
	        {
		    if ( *tmpp == '/' )
		        get2 = TRUE;
		    break;
	        }
	    }
	}
        if (get1 && get2)
	    is_vda = TRUE;

quit:
	if (infile) fclose(infile);
    	return(is_vda);
}
/***** End function  TRis_vda_file  *****/

/*--------------------------------------------------------- TRis_dxf_file */
/*
 *  This function checks if the input file is an
 *  ASCII file, and if it is an DXF file
 *	We first read 1024 chars from an "ascii" file, then try to find if
 *	the first 2 non comment lines are "0" and "SECTION"
 *	Comment line is started with "999" and maybe of any length. So
 *	theoritically it may say some DXF file that has too many comments
 *	at beginning is a non-dxf file. But it's unlikely to happen.
 */

IGRboolean TRis_dxf_file (filename)
     char *filename;
{
#define	BUFRDLEN	1024
  FILE 		*infile;
  char		*ptCh, *ptChEnd, buffer[BUFRDLEN];
  int		is_dxf = FALSE;
  long		start_offset;

	if ( ! TRis_ascii (filename) )
	{
		return (FALSE);
	}

    	/* ---------------------------------------------------
  	 *	Open the input file
  	 * ---------------------------------------------------	*/

  	infile = fopen(filename,"r");
  	if (!infile)
      		return(FALSE);
	start_offset = ftell(infile);

	if ( fread(buffer, 1, BUFRDLEN, infile) != BUFRDLEN ) {
	  goto quit;
	}

        if ( ! buffer[0] )  {
	  goto quit;
	}

	ptCh = buffer;
	ptChEnd = buffer + BUFRDLEN;

TryRd:
	while ( ptCh < ptChEnd && 
		(*ptCh == ' ' || *ptCh == '\t' || *ptCh == '\n' ) ) 
	  ptCh++;	/* skip all white spaces and '\n'  */

	if ( *ptCh == '0' ) {

	  ptCh++;
	  while ( ptCh <  ptChEnd && 
		    ( *ptCh == ' ' || *ptCh == '\t' || *ptCh == '\r' ) ) 
	    ptCh++;	/* skip all white spaces and \r(From PC) */

	  if ( ptCh >= ptChEnd || *ptCh != '\n' ) {
	    goto quit;	/* expecting a '\n' */
	  }

	  ptCh++;
	  if ( ptCh > ptChEnd-6 ) goto quit;
	  if ( !strncmp ( ptCh, "SECTION", 7 ) ) {
	    ptCh += 7;
	    while ( ptCh <  ptChEnd && 
                    ( *ptCh == ' ' || *ptCh == '\t' || *ptCh == '\r'  ) ) 
	      ptCh++;	/* skip all white spaces and \r */
	    if ( ptCh == ptChEnd || *ptCh == '\n' )
	      is_dxf = TRUE;
 	  }

	  goto quit;
	}
	else if ( *ptCh == '9' ) {
	  if ( *(ptCh+1) == '9' && *(ptCh+2) == '9' ) {
	    ptCh += 3;
	    while ( ptCh <  ptChEnd && 
                    ( *ptCh == ' ' || *ptCh == '\t' || *ptCh == '\r' ) ) 
	      ptCh++; 	/* skip all possible whilte spaces */
	    if ( ptCh >= ptChEnd || *ptCh != '\n' ) {
	      goto quit;	/* expecting a '\n' */
	    }
	    ptCh++;	/* skip first '\n' */
	    while ( ptCh < ptChEnd && *ptCh != '\n' )	
	      ptCh++;	/* filter comment line */
	    
	    goto TryRd;
	  }
	}

quit:
	fclose(infile);
	return (is_dxf);
}
/***** End function  TRis_dxf_file  *****/

/*--------------------------------------------------------- TRis_TV_file */
/*
 *  This function checks the extension of the file name, if it is in
 *  the format of *:X, then it is a TECH2D file
 */

IGRboolean TRis_TV_file (filename)
     char *filename;
{
  int len, is_TV=0;

  len = strlen(filename);
  if (len > 2 && filename[len-2] == ':' && filename[len-1] == 'X')
  {
    is_TV = 1;
  }
  return(is_TV);
}
/***** End function  TRis_TV_file  *****/

/*----------------------------------------------------------- TRis_MS_file */
/*
 *  This function checks if the input file is a MicroStation
 *  IGDS file
 *
 */


IGRboolean TRis_MS_file (filename)
     char *filename;
{
  int 		fd, msg;
  int  		is_MS = TRUE;

    	/* 
  	 *  Open the input file
  	 */
    	if( (fd = open( filename, O_RDONLY, 0 )) == -1 )
    	{
		is_MS = FALSE;
		goto quit;
	}

	/* 
	 *  Check is file is MS IGDS 
	 */
	is_MS =  TRicheck_igds (&msg, &fd);

	/*
	 *  TRicheck_igds closes the file if is not MS IGDS, so we need
	 *  to close it only if it is MS IGDS
         */
	if ( is_MS )
	{
	   close (fd);
	}

quit:

  return (is_MS);

}
/******* End function   TRis_MS_file  *****/

/*+++++++++++++++++++++++++++++++++++++++++++++++ TRread_string */
TRread_string(fp, buffer)
FILE *fp;
char *buffer;
{
  char  ch;
  int  iPtr=0, iOk=0, letter;

  while ( (letter=getc( fp )) != EOF )
  {
    ch = letter;		/* for safety */
    if ( ch != '\n' ) 
    {
      if ( iOk || (ch != ' ' && ch != '\t') )
      {
        iOk = 1; /* started non_white space */
        buffer[iPtr++] = ch;
      }
    }
    else 
    {
      if ( iOk )  /* return if valid string */
      {
	buffer[iPtr] = '\0';
	return(0);
      }
      else
      {
        iOk = 1;	/* Only skip first '\n'	*/
      }
    }
  }
  return(EOF);
}

/*--------------------------------------------------------- TRcheck_ext */
/*
 *  This function checks if the input file has the
 *  extension passed by the calling function
 *
 */

IGRboolean TRcheck_ext (filename, extension)
     char *filename, *extension;
{
  FILE 		*infile;
  char		*cp;
  extern char *strrchr();
    	/* ---------------------------------------------------
  	 *	Open the input file
  	 * ---------------------------------------------------	*/

  	infile = fopen(filename,"r");
  	if (!infile)
      		return(FALSE);

	fclose (infile);

  	/* -----------------------------------------------------
    	 *	Check extention
  	 * -----------------------------------------------------*/
	
	cp = strrchr (filename, '.');

	if ( ! cp )
		return (FALSE);
	
	if ( ! strcmp( ++cp, extension ) )
		return (TRUE);
	else
		return (FALSE);
}
/***** End function  TRcheck_ext  *****/

/*++++++++++++++++++++++++++++++++++++++++++++++++++++ TRget_ingrhome */
/* ABSTRACT:
 	This routine returns the path stored in INGRHOME. If INGRHOME
	is a list of paths (dir1:dir2:dir3) it will return the first
	path.

   SYNOPSIS:
	TRget_ingrhome ()

   RETURN:
	char *, pointing to the path assigned to INGRHOME, if INGRHOME
	is a list of paths it will return the first path.
		- OR -
 	NULL if INGRHOME is not defined or contains a null string.

   NOTES:
   SEE:
*/
char *TRget_ingrhome()
{
  char	*pdp=NULL, *getenv(), *sp=NULL;

  pdp = getenv ( "INGRHOME" );

  if ( pdp &&  *pdp != '\0' )
  {
	sp = (char *) strchr (pdp, ':');
	if (sp)
	{
	   *sp='\0';
	}
  }
  else
  {
	pdp=NULL;
  }

  return (pdp);

}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++ TRconv_short */
void TRconv_short(in,out)
char *in,*out;
{
    char tmp;

    tmp = *in;
    *out = *(in+1);
    *(out+1) = tmp;
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++ TRicheck_igds */
IGRint TRicheck_igds ( msg, file_des )
IGRint          *msg;
IGRint		*file_des;

{

    struct TRcheckigds
    {
       IGRuchar 		level;
       IGRuchar 		type;
       IGRshort			words_to_follow;
    }check_buf;

    IGRlong			status;
#ifdef BIG_ENDIAN
    IGRshort                    swapped_value;
    IGRshort                    swapped_value1;
#endif

    *msg = TRUE;

    /*
     *  Read the first element in the file and
     *  make sure it is a type nine element.
     */

    if ( (status = read ( *file_des, &check_buf, 4 )) == 4 )
    {
#ifdef BIG_ENDIAN
        TRconv_short(&check_buf.words_to_follow,&swapped_value);
	if ( check_buf.type != 9  ||  swapped_value != 766 )
#else
	if ( check_buf.type != 9  ||  check_buf.words_to_follow != 766 )
#endif
	{
	    status = FALSE;
	    close ( *file_des );
	}
	else
	{
	    /*
	     *  Reset the file pointers to prepare
	     *  for translation of the file.
	     */

	    status = TRUE;
	lseek ( *file_des, 0, 0 );

	}
    }    
    else
    {
	status = FALSE;
	close ( *file_des );
    }


    return ( status );

}


/* ++++++++++++++++++++++++++++++++++++++++++++TRis_cadds_file() ++++ */


IGRboolean TRis_cadds_file (filename)
     char *filename;
{

  FILE              *infile;
  char              *cp;
  extern char   *strrchr();

  if(TRcheck_ext(filename,"_pd"))
        return(TRUE);
  
  /* ---------------------------------------------------
   *    Open the input file
   * ---------------------------------------------------        */
  
  infile = fopen(filename,"r");
  if (!infile)
        return(FALSE);
  fclose (infile);
  
  cp = strrchr (filename, '/');
  if(cp)
	{
	  if (!strcmp( ++cp, "_pd"))
            return (TRUE);
	  else
            return (FALSE);
	}
  else
        {
	  if (!strcmp( filename, "_pd"))
            return (TRUE);
	  else
            return (FALSE);
        }
}

/* ++++++++++++++++++++++++++++++++++++++++++++TRis_catia_file() ++++ */

/* Check if file is a catia file or not. */

IGRboolean TRis_catia_file (filename)
     char *filename;
{

  FILE              *infile;  /* file pointer to check if file is readable */
  char              *cp;
  extern char   *strrchr();                /* standard string function */
  char          catiafile[32];             /* catia filename           */
  int           k,len=0;
  
  infile = fopen(filename,"r");
  if (!infile)
        return(FALSE);
  
  fclose (infile);

  cp = strrchr (filename, '/');
  if(cp)
      strcpy(catiafile,++cp);
  else
      strcpy(catiafile,filename);

  len = strlen(catiafile);
  
  /* All catia files should start with a "fic" */
  if (strncmp(catiafile,"fic",3))
        return(FALSE);
  
  /* Current allowable range is from fic0 to fic9999 ( should be more than
     sufficient ) */
  
  if( strlen(catiafile) > 7 || strlen(catiafile) < 4)
        return(FALSE);
  
  /* Check if they are all digits */
  for(k=3;k < len; k++)
        {
          if(!isdigit(catiafile[k]))
                return(FALSE);
        }
  return(TRUE);
}

/* ++++++++++++++++++++++++++++++++++++++++++++TRis_ddn_file() ++++ */
/*
 *  This function checks if the input file is an ICEMDDN file.
 *  The decision logic was taken from icemddn subroutine GETFT.
 *  ASCII and binary files are supported.
 *  DDN part and pattern files are recognized.
 */

IGRboolean TRis_ddn_file (filename)
     char *filename;
{
#ifdef DEBUG
#define _debug(x) x
#else
#define _debug(x)
#endif

#define ICEM_APARID     "ASCII PART"
#define ICEM_APARID_L   10
#define ICEM_APATID     "ASCII PATTERN"
#define ICEM_APATID_L   13
#define ICEM_AVARID     "ICEM DDN VARIABLES LIBRARY"
#define ICEM_BINBUF_L   128
#define ICEM_GUTF       "GUTF"
#define ICEM_GUTF_L     4
#define ICEM_IDBPAR	111588001	/* binary part id */
#define ICEM_IDDFID	31290002	/* directory file id */
#define ICEM_IDPATT	21845
#define ICEM_PLTBIN1	0x003D1C49
#define ICEM_PLTBIN2	0x43454D20
#define ICEM_PLTCHR1	0x30201B5C
#define ICEM_PLTCHR2	0x1B584943
#define ICEM_PLTCGM	"BEGMF"
#define ICEM_PLTCGM_L	5
#define ICEM_PLTDDN	"ICEM PLOT FILE"
#define ICEM_PLTDDN_L	14
#define ICEM_SEAFIL	".icem_search"
#define ICEM_LINE_L	250

  extern char   *strrchr();                /* standard string function */

  int		buffer[ICEM_BINBUF_L];
  char		*cp;
  FILE		*infile;  /* file pointer to check if file is readable */
  IGRboolean	is_ddn = FALSE;
  char          lfn[32];		/* filename           */
  char		line [ICEM_LINE_L];
  char		line2[ICEM_LINE_L];
  int		nw;
  
  _debug(fprintf(stderr,"filename=%s\n",filename);)
  cp = strrchr (filename, '/');
  if(cp)
      strcpy(lfn,++cp);
  else
      strcpy(lfn,filename);

  _debug(fprintf(stderr,"lfn=%s\n",lfn);)
  
  /* Check for part instance search file */
  if (!strcmp(lfn,ICEM_SEAFIL))
  {
        _debug(fprintf(stderr,".icem_search file detected\n");)
	return(is_ddn);
  }
  infile = fopen(filename,"r");
  if (!infile)
  {
        _debug(fprintf(stderr,"file %s does not exist\n",filename);)
	return(is_ddn);
  }
  
  fclose (infile);
  
  if (!TRis_ascii(filename))
  {
/* Check binary file */
    infile = fopen(filename,"r");
    if (!infile)
	return(is_ddn);
    if ( fread(buffer, sizeof(int), ICEM_BINBUF_L, infile) != ICEM_BINBUF_L )
    {
      goto quit;
    }
    _debug(fprintf(stderr,"Binary file header was read\n");)
    _debug(fprintf(stderr," %x %x %x\n",buffer[0],buffer[1],buffer[2]);)
    _debug(fprintf(stderr," %x %d\n",buffer[19],buffer[19]);)

/*  Check for ddn directory file */
    if(buffer[0] == ICEM_IDDFID)
      goto quit;

/*  Check for pre 2.1 GUTF file */
    if(!strncmp((char *)&buffer[0], ICEM_GUTF, ICEM_GUTF_L))
      goto quit;

/*  Check for pre 2.1 pattern file */
    if(buffer[0] == ICEM_IDPATT)
    {
      goto quit;
    }

/*  Check for CGM binary */
    if( (buffer[0] == ICEM_PLTBIN1) && (buffer[1] == ICEM_PLTBIN2) )
      goto quit;
    if( (buffer[0] == ICEM_PLTCHR1) && (buffer[1] == ICEM_PLTCHR2) )
      goto quit;

/*  Check for a 2.1 binary part or pattern */
    if( buffer[19] == ICEM_IDBPAR )
    {
      if( buffer[18] == -1 )
      {
        _debug(fprintf(stderr,"ddn file is a binary pattern\n");)
	is_ddn = TRUE;
      }
      else
      {
        _debug(fprintf(stderr,"ddn file is a binary part\n");)
	is_ddn = TRUE;
      }
    }
  }
  else
  {
/*  Check ascii file */
    infile = fopen(filename,"r");
    if (!infile)
	return(is_ddn);

/*  Read first record */
    if(!fgets(line, ICEM_LINE_L, infile))
      goto quit;
    _debug(fprintf(stderr,"partname=%s\n",line);)

/*  Check if ascii variable file */
    if(!strcmp(line, ICEM_AVARID))
      goto quit;

/*  Check if CGM plot file */
    if(!strncmp(line, ICEM_PLTCGM, ICEM_PLTCGM_L))
      goto quit;

/*  Check if DDN plot file (tape 9 format) */
    if(!strncmp(line, ICEM_PLTDDN, ICEM_PLTDDN_L))
      goto quit;

/*  Read 2. and 3. record */
    if(!fgets(line2, ICEM_LINE_L, infile))
      goto quit;
    _debug(fprintf(stderr,"line2=%s\n",line2);)

    if(!fgets(line, ICEM_LINE_L, infile))
      goto quit;
    _debug(fprintf(stderr,"line3=%s\n",line);)

    sscanf(line2, "%d", &nw);
    _debug(fprintf(stderr,"nw=%d\n",nw);)

    switch(nw)
    {
    case 4:
    case 5:
/*    Pre 2.1 iparta file */
      is_ddn = TRUE;
      _debug(fprintf(stderr,"ddn file is an IPARTA\n");)
      break;
    case 11:
    case 13:
/*    This could be a 2.1 ascii part/pattern file */

      if(!strncmp(line, ICEM_APARID, ICEM_APARID_L))
      {
        _debug(fprintf(stderr,"ddn file is %s\n",ICEM_APARID);)
	is_ddn = TRUE;
      }
      else if(!strncmp(line, ICEM_APATID, ICEM_APATID_L))
      {
        _debug(fprintf(stderr,"ddn file is %s\n",ICEM_APATID);)
	is_ddn = TRUE;
      }
      break;
    }
  }
quit:

  fclose (infile);
  return(is_ddn);

}

/* ++++++++++++++++++++++++++++++++++++++++++++TRis_step_file() ++++ */
/*
 *  This function checks if the input file is a ProSTEP ASCII file.
 */

IGRboolean TRis_step_file (filename)
     char *filename;
{

#define ProSTEP_FILE_ID		"ISO-10303-21;"
#define ProSTEP_FILE_ID_L	12
#define ProSTEP_LINE_L		20


  FILE		*infile = NULL;
  IGRboolean	is_step = FALSE;
  char		line [ProSTEP_LINE_L];
  

  if ( ! TRis_ascii (filename) )
  {
    _debug(fprintf(stderr,"file %s is not ascii\n",filename);)
    return (FALSE);
  }

/*  Check ascii file */
  infile = fopen(filename,"r");
  if (!infile)
  {
    _debug(fprintf(stderr,"file %s does not exist\n",filename);)
    return(FALSE);
  }

/*  Read first record */
  if(!fgets(line, ProSTEP_LINE_L, infile))
    goto quit;
  _debug(fprintf(stderr,"First line =%s\n",line);)

/*  Check for ProSTEP header */
  if(!strncmp(line, ProSTEP_FILE_ID, ProSTEP_FILE_ID_L))
  {
    _debug(fprintf(stderr,"ProSTEP file header found in file %s\n", filename);)
    is_step = TRUE; 
  }

quit:

  if ( infile )
    fclose (infile);

  return(is_step);
}
