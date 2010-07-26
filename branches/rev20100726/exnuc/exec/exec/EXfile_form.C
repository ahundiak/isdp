#include "exsysdep.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <OMerrordef.h>
#include <UNIXerrdef.h>
#include <sys/types.h>
#include <msmacros.h>
#include <execmsg.h>

#ifndef NT
#include <unistd.h>
#include <dirent.h>
#include <sys/param.h>
#else
#define MAXPATHLEN _MAX_PATH
#include <direct.h>
#endif

#include <FI.h>

#ifdef NT
#include <shampub.h>
#endif

#ifdef X11
#include <XFIproto_pub.h>
#endif

#ifdef ENV5
#include <tools.h>
#include <FIproto_pub.h>
#endif

#include <exdef.h>
#include <ex.h>
#include <expriv.h>
#include <exmacros.h>
#include <execmsg.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>
#include <igewindef.h>
#include <igewinmacros.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <OMOSfilehdr.h>
#include <expriv.h>

#ifdef BIG_ENDIAN
#include <exsysdep.h>
#endif


extern  double  drand48();


/* Gadgets */
#define FORM_TITLE	11
#define DIR_NAME	14
#define FILE_NAME	15
#define DIR_WIN		16
#define FILE_WIN	21
#define PATTERN_FLD	22
#define OS_ONLY     20
#define SEED_FILE   26
#define GROUP_OFF   29 /*group to turn off if not retrieve*/


#ifndef NT
#define DIRECTORY_BIT S_IFDIR
#else
#define DIRECTORY_BIT _S_IFDIR
#endif

#ifdef BIG_ENDIAN
#define MYMAGIC 0x4f4d
#else
#define MYMAGIC 0x4d4f
#endif
#if defined (CLIX)
#define NAME_SIZE       16
#else
#define NAME_SIZE	OM_K_MAXOSNAME_LEN
#endif

typedef  char  ENTRY[NAME_SIZE];



/* Static variables for form*/
static char	formname[256],form_seedfile[256],save_cwd[256], *pat_txt;
static ENTRY	*filnam, *dirnam, *product;
static int *formfile_type;
static int	buf_siz, file_cnt;
static Form	fp;
static int EX_os_filter;
static int number_types;

extern char	*sys_errlist[];

static int xmatch( char *, char *);
static void List_Files( Form );
static int Change_Dir( char * );
static int Read_Dir( Form );
static int EXgetfil_form_notif( int, int, double, Form );

extern int EX_swap_string ( char *, char *, char *, char * );
extern int EX_qsort_list( int, int, ENTRY [], ENTRY [] );
extern char *expand_shell_vars( char * );
extern int strcmp_ls( char *, char * );
extern char *EXgetcwd( char *, int );

char *EXgetcwd( buf, size )
char *buf;
int size;
{

 if( buf  ||  ( buf = (char *)malloc( size ) ) ) {
#ifndef NT
    register int ret_status,child;
    int fildes[2];

    if( pipe( fildes ) == 0 ) {
#if defined(CLIX) || defined(SUNOS)
	if( child = vfork() ) {
#elif defined(IRIX)
	if( child = fork() ) {
#else
#error OS not defined
#endif
	    if( child != -1 ) {
		do {
		   ret_status = read( fildes[0], buf, size );	/* read pipe */
		} while ( ret_status == -1  &&  errno == EINTR );

		close( fildes[0] ); 			/* close input pipe */
		close( fildes[1] );			/* close output pipe */
		waitpid( child, 0, 0 );		/* cleanup child */
		if( ret_status != -1 ) {
	
			/* eliminate NULL placed on end by "pwd" */

		    if( ret_status < size ) buf[ ret_status - 1 ] = '\0';

		    return( buf );

 		 }

        }

        } else {

	    /* Don't use fclose because of having used "vfork".  Since the
	     * process is not actually copied the use of fclose would wind
	     * up corrupting the data structures representing the stream 
	     * in the parent.
	     */

	    close( fileno(stdout) );	/* close standard out	*/
	    dup( fildes[1] );		/* dup O/P pipe into stdout slot */
	    close( fildes[1] );		/* close output pipe */

	    execlp( "pwd", "pwd", (char *)0 );
	}
    }
#else
    return _getcwd( buf, size );
#endif
 }
 return( (char *)NULL );
}

static int Change_Dir( todir )
char *todir;
{
#ifndef NT
  return chdir( todir );
#else
  return _chdir( todir );
#endif
}

static void List_Files( fp )
	Form	fp;		/* i - form pointer			*/
{
	register int	i, fil_row=0;
	ENTRY		*dp,*pf;

	FIfld_set_num_rows(fp,FILE_WIN,file_cnt);


	if( pat_txt[0] )
	{
	  for( i=0, dp = filnam, pf = product; i<file_cnt; i++, dp++,pf++ )
	  if( strcmp_ls( (char *) dp, pat_txt ) )
            {
	    FIfld_set_text( fp,FILE_WIN,fil_row,0,(char *)dp,0 );
	    FIfld_set_text( fp,FILE_WIN,fil_row++,1,(char *)pf,0 );
            }
	  FIfld_delete_rows(fp, FILE_WIN, fil_row, file_cnt-fil_row);
	}
	else {
	  for( i=0, dp = filnam, pf = product; i<file_cnt; i++, dp++,pf++ )
            {
	    FIfld_set_text( fp,FILE_WIN,i,0,(char *)dp,0 );
            FIfld_set_text( fp,FILE_WIN,i,1,(char *)pf,0 );
            }
	}

	if( strchr(pat_txt, '!') )
	    FIg_set_text(fp,FI_MSG_FIELD," ! not supported in match pattern");

	return;
}


static int Read_Dir( fp )

	Form	fp;		/* i - form pointer			*/
{
	char		cwd[MAXPATHLEN];
	int		dir_cnt, i;
#ifndef NT
	DIR		*pdir;
	struct dirent	*dent;
#endif
/*helpnt*/

#ifndef NT
	struct stat	stat_buf;
#else
	struct _stat	stat_buf;
#endif
	ENTRY		*dp;
    FILE *file_p;
    struct OM_sd_OS_filehdr_OM buffer;
    int status;

    status = (int) EXgetcwd(cwd, MAXPATHLEN);
    if ( !status )
    {
      FIg_set_text(fp,FI_MSG_FIELD,sys_errlist[errno]);
#ifdef ENV5
      Wait_timer(20);
#endif
      return (0);
    }
/*
 *  Read in the new files and directories
*/
#ifndef NT
	dir_cnt = 0;
	pdir = (DIR *) opendir(cwd);
    if ( pdir )
     {   
	 FIg_set_text(fp,FI_MSG_FIELD,"Reading Directory ...");
	 FIg_set_text(fp,DIR_NAME,cwd);
	 FIfld_set_num_rows(fp,FILE_WIN,0);

  	 while( dent = readdir(pdir) ) dir_cnt++;

 	 if( dir_cnt > buf_siz )
	  {
		buf_siz = dir_cnt;
		if( filnam ) free( filnam );
		filnam = (ENTRY *)calloc( buf_siz, sizeof(ENTRY) );
		if( ! filnam ) return(0);

		if( product ) free( product );
		product = (ENTRY *)calloc( buf_siz, sizeof(ENTRY) );
		if( ! product ) return(0);

		if( dirnam ) free( dirnam );
		dirnam = (ENTRY *)calloc( buf_siz, sizeof(ENTRY) );
		if( ! dirnam ) return(0);
	  }

 	 dir_cnt = file_cnt = 0;
	 rewinddir(pdir);
	 dent = readdir(pdir);		/* read "." entry, discard */

 	 while( dent = readdir(pdir) )
	  {
#ifndef NT
	  stat(dent->d_name,&stat_buf);
	  if( !(stat_buf.st_mode & S_IFIFO) )
#else
	  _stat(dent->d_name,&stat_buf);
	  if( !(stat_buf.st_mode & _S_IFMT) )
#endif
	   {
        /*not a named pipe continue*/
		if( (stat_buf.st_mode & DIRECTORY_BIT) )
		{
		    strcpy( dirnam[dir_cnt++], dent->d_name );
		}
		else
		{ 
            if ( EX_os_filter )
               {
                file_p = (FILE *) fopen ( dent->d_name, "r" );
                if ( file_p )
                 {
                  status = fread(&buffer,(sizeof(struct OM_sd_OS_filehdr_OM ))
                                           , 1, file_p);
                  if ( buffer.magic == MYMAGIC )
                    {
#if defined (CLIX)
  		      strncpy( filnam[file_cnt], dent->d_name,14 );
                      
#else
  		      strncpy( filnam[file_cnt], dent->d_name,
                                                OM_K_MAXOSNAME_LEN -1 );
#endif
  		      strncpy( product[file_cnt++], buffer.image_name, 10 );
                    }
                 fclose (file_p);
                 }
                }
               else
                { /*no os filter put everything out*/
#if defined (CLIX)
  		    strncpy( filnam[file_cnt], dent->d_name,14 );
#else
  		    strncpy( filnam[file_cnt], dent->d_name,
                                           OM_K_MAXOSNAME_LEN -1 );
#endif
                    file_p = (FILE *) fopen ( dent->d_name, "r" );
                    if ( file_p )
                     {
                      status = fread(&buffer,
                                  (sizeof(struct OM_sd_OS_filehdr_OM ))
                                           , 1, file_p);
                      if ( buffer.magic == MYMAGIC )
                       {
  		         strncpy( product[file_cnt++], buffer.image_name, 10 );
                       }
                      else
                       {
     		         strcpy( product[file_cnt++], " " );
                       }
                     fclose (file_p);
                     }
                }
		}
      }/*end if named pipe*/
	}
	closedir(pdir);

	EX_qsort_list ( 0,dir_cnt - 1,dirnam, 0 );
	EX_qsort_list ( 0,file_cnt - 1,filnam,product );

	FIfld_set_num_rows(fp,DIR_WIN,dir_cnt);
	for( i=0, dp = dirnam; i<dir_cnt; i++, dp++ )
		FIfld_set_text( fp, DIR_WIN, i, 0, (char *)dp, 0 );

	List_Files( fp );

	FIg_set_text(fp,FI_MSG_FIELD,"");
	return(1);   
   }
  else
#endif
   {
    FIg_set_text(fp,FI_MSG_FIELD,sys_errlist[errno]);
#ifdef ENV5
    Wait_timer(20);
#endif
    return(0);
   }
}
static   int err = 0;
#argsused
static int EXgetfil_form_notif ( f_label, g_label, value, fp )

  int		f_label;	/* i - The label of the form	*/
  int		g_label;	/* i - The label of the gadget	*/
  double	value;		/* i - The value of the gadget	*/
  Form		fp;		/* i - Form pointer		*/
{
  char	text_buff[MAXPATHLEN], *expanded_dir;
  int	sf, rp;
  long  stat;
  int   sts;
  long status;
  char tmp_file[256];
  char msg[MS_MAX_MSG_LENGTH];


  FIg_set_text( fp, FI_MSG_FIELD, "" );
  switch ( g_label )
  {
  case FILE_NAME:
        err = 0;
	FIg_get_text( fp, FILE_NAME, formname);
        if (strlen(formname) > (OM_K_MAXOSNAME_LEN -1) )
          err=1;

        {
          char *tmp1;
          tmp1 = strrchr(formname,'/');
          if (tmp1)
          {
          tmp1++;
          if (strlen(tmp1) > 14)err=2;
          }
          else if (strlen(formname) > 14)err=2;
        }

       if (err)
        {
        char msg_buf[MS_MAX_MSG_LENGTH];
        if (err == 1)
        {
           ex$message(msgnumb = EX_F_MaxPathFilename,
                        type ="%s%",var="",buff = msg_buf);
        }
        else
        {
           ex$message(msgnumb = EX_F_MaxFileName,
                        type ="%s%",var="",buff = msg_buf);
       }

        FIg_set_text(fp,FI_MSG_FIELD,msg_buf);
        formname[0] = 0;
        FIg_set_text(fp,FILE_NAME,"");
        sleep(3);
        err = 0;
        }
    break;

  case SEED_FILE:
        err = 0;
	FIg_get_text( fp, SEED_FILE, form_seedfile);
        if (strlen(form_seedfile) > (OM_K_MAXOSNAME_LEN -1) )
           err = 1;

        {
          char *tmp1;
          tmp1 = strrchr(form_seedfile,'/');
          if (tmp1)
          {
          tmp1++;
          if (strlen(tmp1) > 14)err=2;
          }
          else if (strlen(form_seedfile) > 14)err=2;
        }

        if (err)
        {
        char msg_buf[MS_MAX_MSG_LENGTH];
        if (err == 1)
        {
           ex$message(msgnumb = EX_F_MaxPathFilename,
                        type ="%s%",var="",buff = msg_buf);
        }
        else
        {
           ex$message(msgnumb = EX_F_MaxFileName,
                        type ="%s%",var="",buff = msg_buf);
       }

        FIg_set_text(fp,FI_MSG_FIELD,msg_buf);
        form_seedfile[0] = 0;
        FIg_set_text(fp,SEED_FILE,"");
        sleep(3);
        err = 0;
        }

        else
        {
        sts = EX_get_seed_file(form_seedfile,tmp_file);
        if (!sts)
        {
        ex$message(msgnumb=EX_F_FileNotExist,buff = msg);
        strcpy(tmp_file,form_seedfile);
        strcat(tmp_file,"  ");
        strcat(tmp_file,msg);
        FIg_set_text(fp,FI_MSG_FIELD,tmp_file);
        FIg_set_text(fp,SEED_FILE," ");
        form_seedfile[0] = 0;
        }
        }
    break;

  case OS_ONLY:
    if (EX_os_filter)
        EX_os_filter = FALSE;
    else
        EX_os_filter = TRUE;
	FIg_set_text( fp, FILE_NAME, "");
	Read_Dir( fp );
    break;

  case DIR_NAME:
	expanded_dir = EXgetcwd(save_cwd, MAXPATHLEN);
	FIg_set_text( fp, FILE_NAME, "");
	FIfld_get_text(fp,DIR_NAME,(int)value,0,MAXPATHLEN,(unsigned char *)text_buff,&sf,&rp);
	expanded_dir = expand_shell_vars(text_buff);
	if( ! Change_Dir(expanded_dir) ) 
        {
          status = Read_Dir( fp );
          if (!status)
           {
           Change_Dir(save_cwd);
           Read_Dir(fp);
           }
        }
	else
        {
          FIfld_set_num_rows(fp,DIR_WIN,0);
          FIfld_set_num_rows(fp,FILE_WIN,0);
	  FIg_set_text(fp,FI_MSG_FIELD,sys_errlist[errno]);
	}
	break;

  case DIR_WIN:
	FIg_set_text( fp, FILE_NAME, "");
	FIg_get_text( fp, DIR_NAME, text_buff);
    strcpy(save_cwd,text_buff);
	sprintf( formname, "%s/", text_buff );

	FIfld_get_text(fp,DIR_WIN,(int)value,0,MAXPATHLEN,
                       (unsigned char *)text_buff,&sf,&rp);
	strcat( formname, text_buff);

	if( ! Change_Dir(formname) )
        {
          status = Read_Dir( fp );
          if (!status)
          {
            Change_Dir(save_cwd);
            Read_Dir(fp);
          }
        }
	else
        {
	  FIg_set_text(fp,FI_MSG_FIELD,sys_errlist[errno]);
        }
#ifdef ENV5
	Wait_timer(10);
#endif
	FIfld_set_select(fp, DIR_WIN, (int)value, 0, 0);
	break;

  case FILE_WIN:
	FIfld_get_text(fp,FILE_WIN,(int)value,0,MAXPATHLEN,(unsigned char *)text_buff,&sf,&rp);
	FIg_set_text( fp, FILE_NAME, text_buff);


#ifdef ENV5
	Wait_timer(10);
#endif
	FIfld_set_select(fp, FILE_WIN, (int)value, 0, 0);
	FIfld_set_select(fp, FILE_WIN, (int)value, 1, 0);
	break;

  case PATTERN_FLD:
	FIg_get_text(fp, PATTERN_FLD, text_buff);
	strncpy( pat_txt, text_buff, 29 );
	List_Files( fp );
	break;

  case FI_ACCEPT:

     if (err)break;
	FIg_get_text(fp,FILE_NAME,text_buff);
    if ( text_buff[0] == 0 ) 
         {
         formname[0] = 0;
         }
	else 
         { 
         if (text_buff[0] != '/' )
          {
  	       FIg_get_text( fp, DIR_NAME, formname);
	       strcat( formname, "/");
           strcat( formname, text_buff);
           }
          else
           {
           strcpy(formname,text_buff);
           }
         }
 	   FIf_delete ( fp );
	    { int	rsp = EX_FORM_FINISHED;
	     ex$putque(msg = &stat, response = &rsp);
	    }


	break;

  case FI_CANCEL:
	FIf_delete ( fp );
	formname[0] = 0;

	{ int	rsp = EX_FORM_FINISHED;
	  ex$putque(msg = &stat, response = &rsp);
	}
	break;

  case FI_CVT_TO_PERM_WIN:
	FIg_erase( fp, FI_CVT_TO_PERM_WIN );
	break;
  }
  return 1;
}

/*****************************************************************************

   Doc: EXget_file	"File Requester Box"

   Abstract: This Function allows the user to select a file & the path
	to the file from a list of those directories available in the
	current system.  The user may enter a file name that does not
	exist.  Which is good for save with new name.

   Dependencies: shellvar.c => char * expand_shell_vars(unexpanded_filename)


 ****************************************************************************/

int EXget_file(title, startdir, in_file, pat,file_type,
                       returned_filename,seedfile,form_type,
                                           response,response_data)
char	*title;       /* i - The title on the file requester form. */
char	*startdir;    /* i - The initial directory */
char	*in_file;     /* i - The initial file name to be placed in the file name
			     field.  Usefull for saving.  The user may edit the
			     file name to do a save under new name or simply 
			     hit the check mark. */
char	*pat; /* i - Pattern to match files with 'ls' command. opt NULL	*/
int file_type[];
char    *returned_filename;/*file name returned to user*/
char *seedfile;
int form_type;
int *response;
char *response_data;
/***************************************************************************/
{

char	pat_buff[30], *old_dir = 0;
int	sts;
int     num_bytes;
char done;
int not_done,status;
    if (file_type)
     {
     not_done = TRUE;
     while ( not_done )
      {
      if (file_type[number_types] ) number_types++;

      else not_done = FALSE;
      }
     }
	sts = FIf_new( 0, "EXGetFile", EXgetfil_form_notif, &fp);

/*    FIf_cvrt_to_perm_win(fp);*/

	if (sts != FI_SUCCESS)
	{
		fprintf (stderr, "FIf_new failed: sts = %d\n",sts);
	}


	pat_txt = pat_buff;
	if( pat ) strncpy( pat_txt, pat, 29 );
	else pat_txt[0] = 0;
/*
 *  Save current directory for later recall
*/
	if( (old_dir = EXgetcwd((char *) NULL, MAXPATHLEN)) == NULL)
        {
	  FIg_set_text(fp,FI_MSG_FIELD,sys_errlist[errno]);
          FIf_delete (fp);
          return (0);
        }

	if( startdir )	/* if startdir is NULL, will be "pwd" */
	{
	  if( ! Change_Dir(startdir) )
          {
            FIg_set_text(fp,FILE_NAME,in_file);
          }
	  else
	  {
	    FIg_set_text(fp,FI_MSG_FIELD,sys_errlist[errno]);
	    FIg_set_text(fp,FILE_NAME,"");
	  }
	}

	formfile_type = 0;
        filnam = dirnam = product = 0;
                    	/* initialize ( prevent bad 'free' ) */
	buf_siz = 0;

    done = 0;

	FIg_set_text(fp,FORM_TITLE,title);
	FIg_set_text(fp,PATTERN_FLD,pat_txt);
    if ( form_type != EX_RETRIEVE_FILE_FORM)
     {
     /*not retrieve form*/
     FIg_erase(fp,GROUP_OFF);
     }
    EX_os_filter = TRUE;
    if ( number_types )
  	       formfile_type = (int *)malloc( number_types * sizeof(int) );
    if( FIf_display(fp) == FI_SUCCESS )
	{
        /*
         *  If the seedfile is NULL, then erase the field and title
         */

        if( seedfile == NULL )
           {
           FIg_erase( fp, SEED_FILE );
           FIg_erase( fp, 18 );
           }
        else
           {
           FIg_set_text(fp,SEED_FILE,seedfile);
           strcpy(form_seedfile,seedfile);
           }
	 status = Read_Dir( fp );		/* Display dirs and files in boxes */
     if (!status)
        {
         formname[0] = 0;
         done = 1;
  	     FIf_delete (fp);
        }
      while ( !done )
         {
           /*mode changed from 0 to EX_ALL_CHAR_MODE for 16 bit in form*/
           EX_wait_for_input( response,response_data,
                                    EX_ALL_CHAR_MODE,&num_bytes);  
           if ( *response == EX_FORM_FINISHED )
             {
             done = 1;
             }
           else if ( (*response == EX_CMD_KEY ) || (*response == STRING )
                                   || (*response == CMD_STRING)
                                     || (*response == CLEAR_STACK))
             {           
             formname[0] = 0;
             done = 1;
  	         FIf_delete (fp);
             }           
         }

	}
/*
 *  Change back to original working directory ( if flag so specifies ).
 */

	Change_Dir(old_dir);

    if (old_dir) free (old_dir);
	if( filnam) free(filnam);
	if( dirnam) free(dirnam);
	if( product) free(product);
    if (formfile_type) free (formfile_type);

    /*  Don't copy if the seedfile is NULL */

    if( seedfile != NULL )
       strcpy(seedfile,form_seedfile);

    strcpy (returned_filename,formname);
    if (formname[0] == 0 )
     return (0);
    else
	return( 1 );
}


/*****************************************************************************

   Doc: EXstrcmp_ls

   Abstract: Performs a string comparison similar to pattern matching
	by the shell for the specified pattern text. Pattern may contain
	the meta-characters *, ?, [, and ].

   Note: The '!' meta-character is not supported in this routine.

   History:

	Date		Who	Why
	---------	---	-------------------------------------------
	16 Oct 90	msl	Creation - xmatch extracted from cmu library of
				source code( file expand.c 05-Dec-79  Steven
				Shafer (sas) at Carnegie-Mellon University ).

   Return Status:
	1	-	name matches pattern
	0	-	no match

 ****************************************************************************/

static int xmatch (name,pattern)
char *name,*pattern;
{
	register char *n,*p;	/* pointers into strings */
	register char nc,pc;	/* chars from strings */
	char cur;		/* for [a-z] specs */
	int ok;			/* for [...] specs */

	/* in this routine, one char (or spec) from pattern is
	 * parsed and compared with the appropriate number of chars
	 * from name.  If a match is made, the comparison is continued.
	 * If not, 0 is returned.  The comparison is continued by
	 * recursively calling xmatch with incremented arguments;
	 * this is necessary for the easy evaluation of "*", which
	 * is probably the most common meta-character.
	 */

	n = name;
	p = pattern;
	nc = *n++;
	pc = *p++;

	switch (pc) {

	case '?':
		if (nc == 0)  return (0);
		return (xmatch (n,p));

	case '[':
		ok = 0;
		cur = 0;
		while (pc = *p++) {
			if (pc == ']') {
				if (!ok)  return (0);
				return (xmatch (n,p));
			}
			else if (pc == '-') {
				if (cur <= nc && nc <= *p++)  ok = 1;
			}
			else {
				if (pc == nc)  ok = 1;
				cur = pc;
			}
		}
		return (0);

	case '*':
		if (*p == 0)  return (1);	/* * at end matches anything */
		--n;
		while (*n) {
			if (xmatch (n,p)) return (1);
			n++;
		}
		return (0);

	case '\0':
		return (nc == '\0');

	default:
		if (nc != pc)  return (0);
		return ( xmatch (n,p) );
	}
}

int strcmp_ls( name, pattern )
char	*name;
char	*pattern;
{
  if( name[0] == '.' && pattern[0] != '.' )
    return 0;
  return( xmatch( name, pattern ) );
}


char EXnull_test() { return(1); } /* Used when no filter is specified. */



#define RAND_INT( L, U )				\
	(int)( L + (U-L)*drand48() )

int EX_qsort_list( lower, upper, list,list2)
int	lower;	/* Lower bound of partition */
int	upper;	/* Upper bound of partition */
ENTRY	list[]; /* List to be sorted	    */
ENTRY	list2[]; /* List to be sorted	    */
{
register int i, lastlow;
ENTRY *t;
int status;

if ( upper > lower )
    {
    i=RAND_INT( lower,  upper );
    if (list2)
      EX_swap_string( list[lower], list[i],list2[lower], list2[i] );
    else
      EX_swap_string( list[lower], list[i],0,0 );
    t =  (ENTRY *) list[lower];
    lastlow = lower;
    for ( i=lower+1; i<=upper; i++)
	{
    status = strcmp(list[i],(char *)t);
	if ( status < 0  )
	    {
	    lastlow++;
        if (list2)
           EX_swap_string( list[lastlow], list[i],list2[lastlow], list2[i] );
        else
           EX_swap_string( list[lastlow], list[i],0,0 );
	    }
	}
    if (list2)  
     EX_swap_string( list[lower], list[lastlow],list2[lower], list2[lastlow] );
    else
     EX_swap_string( list[lower], list[lastlow],0,0 );
    EX_qsort_list( lower,  lastlow-1, list,list2 );
    EX_qsort_list( lastlow+1, upper, list,list2 );
    }
    return(1);
}
/*
main ()
{

ENTRY list[3];
ENTRY list2[3];
strcpy (list[0],"junk");
strcpy (list2[0],"junkexnuc");
strcpy (list[1],"morejunk");
strcpy (list2[1],"morejunkems");
strcpy (list[2],"aaa");
strcpy (list2[2],"aaa");

EX_qsort_list(0,2,list,list2);
printf ("list[0] %s \n",list[0]);
printf ("list[0] %s \n",list[1]);
printf ("list[0] %s \n",list[2]);
return(1);
}
*/

int EX_swap_string ( a, b, aa, bb )
char *a;
char *b;
char *aa;
char *bb;
{
  char temp[MAXPATHLEN];
  char temp2[MAXPATHLEN];

  strcpy (temp , a);
  strcpy(a,b);
  strcpy(b,temp);
  if (aa)
  {
    strcpy(temp2 ,aa);
    strcpy(aa ,bb);
    strcpy(bb,temp2);
  }
  return(1);
}
