/*********

      File from EXNUC ( EXfile_form.C ) modified for Retrieve part command

           Krishna kumar D.      14/07/93     Modification date
           Gang                  10/11/93     Fixed couple of problems
           dkk                   21/03/94     Modified to include osfilter togl
	   Gang                  20/04/94     Hooks for PDM/PDU.
*********/

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

#include "DIdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include <gr.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include "asmfilemac.h"
#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

#define	EXTERN extern
#include "asmglobals.h"

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

extern  double  drand48();
extern  double  atof();

/* Gadgets For Main Form */
#define DIR_NAME	11
#define DIR_LIST_BTN	14
#define FILE_MCF	12
#define SELECT_MCF	28
#define CREATE_BTN	30
#define CHANGE_BTN	32
#define DELETE_BTN      13
#define OSFILTER        20
#define SEED_FILE	27
#define SEED_TXT	29
#define FORM_TITLE	21
#define FROM_DATABASE   26

/* Gadgets For Partdefinition Form */
#define SEED_NAME 	18
#define FILE_NAME 	15
#define PART_ATTR  	12
#define OCCR_ATTR  	19

/* Gadgets for Part Placement */
#define PLACE_TITLE	26
#define PLCMNT_OPS      20 /* gadget on Main Form */
#define GROUP_OFF   	30 /* group to turn off; create, change & delete */

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

#define ASM_NOSUCH_ENTRY -2
typedef  char  	ENTRY[NAME_SIZE];
typedef  char  	PDESC[50];

/* Static variables for form */
static char	formname[256],form_seedfile[256],save_cwd[256], *pat_txt;
static ENTRY	*filnam, *dirnam, *product;
static ENTRY    *pnumb, *prev; 
static PDESC    *pdesc;
static int      *formfile_type;
static int	buf_siz, file_cnt, dir_cnt;
static Form	fp;
static int 	EX_os_filter;
static int 	number_types;
static int      *mask;
static char	*old_dir;
static EMattr 	*attrs, numb, rev, desc;
static int    	numattrs;

/* Extern variable definitions */
extern char	*sys_errlist[];
extern char 	EX_seedfile[];

/* Static functions */
static int 	ChangePrt_Dir( char * );
static int 	ReadPrt_Dir( Form );
static int 	EXgetprtfil_form_notif( int, int, double, Form );

/* Extern function definitions */
extern int  	EX_swap_string ( char *, char *, char *, char * );
extern int  	EX_qsort_list( int, int, ENTRY [], ENTRY [] );
extern char 	*expand_shell_vars( char * );
extern int  	strcmp_ls( char *, char * );
extern char 	*EXgetcwd( char *, int );

void ListPrt_Files( fp )
Form	fp;
{
register int	i, j;
int	sf, rp;
char text_buff[3][MAXPATHLEN];

	FIfld_set_num_rows(fp,FILE_MCF,file_cnt);
	FIg_reset( fp, FILE_MCF );

        /* 
         * Get the patterns from selection MCF for filename, partnumber, 
         * partrev and filter those ROWS that DO NOT match the given patterns
         */
	for( i = 0; i < file_cnt; i++ )
		mask[i] = 0;
	for( i = 0; i < 3; i++ )
	{
		text_buff[i][0] = 0;
		FIfld_get_text(fp,SELECT_MCF,0,i,MAXPATHLEN,
				(unsigned char *)text_buff[i],&sf,&rp);
		if( text_buff[i][0] )
		{
		  	for( j=0; j<file_cnt; j++ )
			switch( i )
			{
				case 0:
					if( ! strcmp_ls(filnam[j],text_buff[i]))
						mask[j] = 1;
					break;
				case 1:
					if( ! strcmp_ls( pnumb[j],text_buff[i]))
						mask[j] = 1;
					break;
				case 2:
					if( ! strcmp_ls( prev[j],text_buff[i]))
						mask[j] = 1;
					break;
			}
		}
	}
	update_file_mcf( fp );
}

update_file_mcf( fp )
Form fp;
{
int i, fil_row = 0;

  	for( i=0; i<file_cnt; i++ ) 
	{
		if( ! mask[i] )
		{
			    FIfld_set_text( fp,FILE_MCF,fil_row,0,filnam[i],0 );
	    	    //    FIfld_set_text( fp,FILE_MCF,fil_row,1,pnumb[i],0);
	    	    //    FIfld_set_text( fp,FILE_MCF,fil_row,2,prev[i],0);
		        //    FIfld_set_text( fp,FILE_MCF,fil_row,2,pdesc[i],0);	
		    	FIfld_set_text( fp,FILE_MCF,fil_row++,3,product[i],0 );
               	}
	  	FIfld_delete_rows(fp, FILE_MCF, fil_row, file_cnt-fil_row);
	}
}

#argsused
long EMGetDbParts(EMPartInfo *dbpart_info)
{
  return(0);
}


static int ReadPrt_Dir( fp )
Form	fp;	
{
char		cwd[MAXPATHLEN];
int		i;

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

FILE *file_p;
struct OM_sd_OS_filehdr_OM buffer;
int status;
long msg;
int *newfiles;
int numfils = 0;

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
    	if ( !pdir )
     	{
    		FIg_set_text(fp,FI_MSG_FIELD,sys_errlist[errno]);
#ifdef ENV5
    		Wait_timer(20);
#endif
    		return(0);
	}

 	FIg_set_text(fp,FI_MSG_FIELD,"Reading Directory ...");
 	FIg_set_text(fp,DIR_NAME,cwd);
 	FIfld_set_num_rows(fp,FILE_MCF,0);
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

		if( pnumb ) free( pnumb );
		pnumb = (ENTRY *)calloc( buf_siz, sizeof(ENTRY) );
		if( ! pnumb ) return(0);

		if( prev ) free( prev );
		prev = (ENTRY *)malloc( buf_siz * sizeof(ENTRY) );
		if( ! prev ) return(0);

		if( pdesc ) free( pdesc );
		pdesc = (PDESC *)calloc( buf_siz, sizeof(PDESC) );
		if( ! pdesc ) return(0);
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
   		{        /*not a named pipe continue*/
			if( (stat_buf.st_mode & DIRECTORY_BIT) )
			{
	    			strcpy( dirnam[dir_cnt++], dent->d_name );
			}
			else if ( EX_os_filter )
       			{
              			file_p = (FILE *) fopen ( dent->d_name, "r" );
                		if ( file_p )
                 		{
                  			status = fread(&buffer,(sizeof(struct OM_sd_OS_filehdr_OM )), 1, file_p);
                  			if ( buffer.magic == MYMAGIC )
                    			{
#if defined (CLIX)
      		                            strncpy( filnam[file_cnt], 
                                                        dent->d_name,14 );
                      
#else
                          		    strncpy( filnam[file_cnt], 
                                                        dent->d_name,
                                                        OM_K_MAXOSNAME_LEN -1 );
#endif
	      				    strncpy( product[file_cnt++], 
                                                    buffer.image_name, 10 );
                    			}
                 			fclose (file_p);
                 		}
                	}
                        else /* dump all the files */
                        {
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
                 }/*end if not named pipe*/
	}
	closedir(pdir);

	EX_qsort_list ( 0,dir_cnt - 1,dirnam, 0 );

        /* Now for each file that is existing on the disk, try to get the 
         * partdata from the ascii file in that directory. If not found,
         * make a new entry. Update the ascii file. 
         */
        if( mask ) free( mask );
        mask = ( int * ) calloc( file_cnt, sizeof( int ) );

        newfiles = ( int * )malloc( sizeof( int ) );

	for( i = 0; i < file_cnt; i++ )
	{
	    pnumb[i][0] = prev[i][0] = pdesc[i][0] = 0;
	    asm$get_directory_part( msg = &msg, 
	    			    filename = filnam[i],
				    numb = pnumb[i],
	     			    rev  = prev[i],
				    desc = pdesc[i]);

	    if( msg == MSFAIL )
		continue;
	    else if( (msg == ASM_NOSUCH_ENTRY) && EX_os_filter )
	    { /* No entry for the given unix filename */
		newfiles = ( int * )realloc( newfiles, sizeof(int) *
							(numfils+1));
		newfiles[numfils++] = i;
	    }
#ifdef DEBUG
	    else 
		printf("%s\t%s\t%s\t%s\n",filnam[i],pnumb[i],prev[i],pdesc[i]);
#endif
        }
        if( EX_os_filter )
        {
            /* Depending on the numfils, prompt the user if he wants to update 
             * ascii partdata file, if yes, get the partdata for these files by 
             * opening each of the modules and add the entry in the ascii file 
             * - TBD
             */
/*	
	    for(i = 0; i < numfils; i++)
            {
		update_ascii(newfiles[i]);
            }
*/
    	    free( newfiles );

            /* Now, update the ascii file, so that entries for deleted files
             * will be removed from the ascii file 
             */
	    asm$update_ascii_file( msg = &msg );
	}
        /*
         *  sort the corresponding pnumb, prev & pdesc strings 
         */
        EX_qsort_lists ( 0,file_cnt - 1,filnam, pnumb, prev, pdesc, product );

    	ListPrt_Files( fp );

	FIg_set_text(fp,FI_MSG_FIELD,"");
	return(1);   
#endif /* ifdef NT */
}

update_ascii ( fileind )
int fileind;
{
struct GRid id;
long msg;
char file[256];
int  sts, fileno;

	strcpy( file, filnam[fileind] );
	if( !get_filepart_id( file, &id, &fileno, &sts ) )
         {
            ex$close_module(ftype = EX_invisible, index = fileno);
	    return(0);
         }

	/* Get the number, revision and description 		*/
	sts = asm$get_part_identity( msg = &msg,
				     number = &numb,
				     revision = &rev,
				     description = &desc,
				     part_id = &id );

	/* Add this entry to the ascii file 	*/
	if( msg & sts & 1 )
	{
		asm$add_directory_part( msg = &msg,
			filename   = file,
			numb = numb.value.data.s,
			rev  = rev.value.data.s,
			desc = desc.value.data.s );

		if( !(msg & 1 ))
		  verbose(printf( "Failed to add directory part\n" ));
	}
	else
		verbose(printf("Part not defined completely\n"));

	ex$close_module( ftype = EX_invisible,
			 index = fileno );

	return( 1 );
}

get_filepart_id( char *filename, struct GRid *id, int *fno, int *flag )
{
int sts, msg1, openmode;
struct GRmd_env env;
char path[DI_PATH_MAX];
struct GRid mod_id;
long msg;

        ex$get_cur_mod(id = &mod_id.objid, osnum = &mod_id.osnum);
        DIstmocpy(path,"ref",filename,0,mod_id.osnum);

        /* tell the system that the file is opened for reading partdata */

        ASMset_reading_partdata();

        *flag = 0;  /* Initialise */
	*fno = -1;       
        openmode = EX_read_write;
	sts = ex$retrieve_module( msg = &msg1, ftype = EX_invisible,
                           filename = filename,
                           flag = openmode, file_no = fno,  
			   mount_name = path,mod_type = 2,
                           type = EX_ref,
                           fstat = EX_old_module );

	if (msg1 == EX_flag)
	{
		/* File already open with different permission flag, try
		 * read_only.
		 */
                openmode = EX_read_only;
		sts = ex$retrieve_module( msg = &msg1, ftype = EX_invisible,
                           filename = filename,
                           flag = openmode, file_no = fno,  
			   mount_name = path,mod_type = 2,
                           type = EX_ref,
                           fstat = EX_old_module );
	}
        /* reset */
       	ASMreset_reading_partdata();

	if( msg1 == EX_succ )
	{
		sts = ex$get_invis_info_by_index ( index = *fno,
					  mod_osnum = &env.md_id.osnum,	
					  mod_id = &env.md_id.objid );
		if( sts & 1 )
		{
			sts =  asm$get_file_part (msg = &msg,
		                          mod_env = &env,
                		          part_id = id);
			if( msg & 1 )
				return( 1 );
                        else 
                        {
                        EMattr attrs[3];
			char   *tmpstr;

                            /* First, check if the file is writeable */
                            if( openmode == EX_read_only )
                                return(0);

                            if( access(filename, W_OK) != 0 )/* No write */
                                return(0);

                            /* Create a default file part definition in it */
                            attrs[0].info.type = EM_PART_ATTR;
                            attrs[0].value.type = EM_STRING;
                            strcpy(attrs[0].info.name, "description");
                            strcpy(attrs[0].info.desc, "Part Description");
                            strcpy(attrs[0].value.syntax, "File Part");

                            attrs[1].info.type = EM_COMMON_ATTR;
                            attrs[1].value.type = EM_STRING;
                            strcpy(attrs[1].info.name, "itemno");
                            strcpy(attrs[1].info.desc, "Item Number");
                            strcpy(attrs[1].value.syntax, "1");

                            attrs[2].info.type = EM_INSTANCE_ATTR;
                            attrs[2].value.type = EM_INTEGER;
                            strcpy(attrs[2].info.name, "quantity");
                            strcpy(attrs[2].info.desc, "Quantity");
                            strcpy(attrs[2].value.syntax, "1");

			    tmpstr = strrchr( filename, '/' );
                if (tmpstr == NULL)
                {
                  tmpstr = filename;
                }
                else
                {
                  tmpstr++;
                }
                 sts = asm$create_file_part( msg = &msg,
				                             number = tmpstr,
				                             revision = "1",
                                             mod_env = &env,
                                             num_attributes = 3,
				                             part_id = id,
                                             attributes = attrs );

                if( sts & msg & 1 )
			    {
				*flag = 1; /* File part created afresh */
                                return( 1 );
			    }
			    else
                                verbose(printf("create filepart failed\n"));
                        }
		}
	}
	else
	{
	    verbose(printf("Unable to attach part for read\n"));
	}
	/* Failed */
	return( 0 );
}


#argsused
static int EXgetprtfil_form_notif ( f_label, g_label, value, fp )
int		f_label;	/* i - The label of the form	*/
int		g_label;	/* i - The label of the gadget	*/
double		value;		/* i - The value of the gadget	*/
Form		fp;		/* i - Form pointer		*/
{
int     sf, rp, i;
long    stat;
char	text_buff[MAXPATHLEN];
EMPartInfo dbpart_info;

 	FIg_set_text( fp, FI_MSG_FIELD, "" );

  	switch ( g_label )
  	{
		case DIR_NAME:
			FIg_get_text( fp, DIR_NAME, text_buff );
			update_select_mcf( fp, -1);
			move_to_dir( fp, text_buff );
			break;

     		case DIR_LIST_BTN:
			/* show a pulldown list of directories in the directory
                           given in DIR_NAME. If nothing present, use cwd.
			   If a selection is made, show a new pulldown with
                           the directories under the selected one. When the
                           pulldown is dismissed without any selection, 
                           change the directory to the previous selection
                           and update the partlisting MCF.
                        */
			show_dir_listing( fp );
			break;

     		case FILE_MCF:
                        /* Put the selected row in the Select MCF.
			   Note:This MCF will always be REVIEW mode, in this
			   command.
                        */
			update_select_mcf( fp, (int)value );
			for( i = 0; i < 5; i++ )
				FIfld_set_select( fp,g_label,(int)value,i, 0 );
			break;

     		case SELECT_MCF:
			/* Depending on the column, do the corresponding
                           filtering and update the Partlisting MCF and
                           also itself ( and all other columns of this MCF).
			   If there is no wild character, filtering is not
                           attempted.
			*/
			FImcf_get_active_col ( fp, g_label, &i, &sf );
			FIfld_get_text(fp,SELECT_MCF, 0, i,MAXPATHLEN,
					(unsigned char *)text_buff,&sf,&rp);
			if( text_buff[0] && strpbrk( text_buff, "*?[]" ))
			{
			        ListPrt_Files( fp );
				FIfld_erase_cursor( fp, SELECT_MCF );
			}
			break;

     		case CREATE_BTN:
			/* Display the Part Definition form with the part
                           selected on the main form as seed file, and the
                           default attributes/values from the seed file. If
                           no part selected, use EMS default seedfile
			*/
			formname[0] = 0;
			Create_prt( fp );
			if( formname[0] ) /* Go ahead and create it */
			{
       				FIg_get_text( fp, DIR_NAME, text_buff);
       				strcat( text_buff, "/");
       				strcat( text_buff, formname);
				strcpy( formname, text_buff );
	   			FIf_delete ( fp );
				{
	    			int	rsp = EX_FORM_FINISHED;
	
				ex$putque(msg = &stat, response = &rsp);
				}
				break;
			}
			FIf_display( fp );
			break;

     		case CHANGE_BTN:
			break;

     		case DELETE_BTN:
			/* Delete the selected file and its entry from the
                           ascii partdata file
			*/
			delete_file( fp );
			break;

		case OSFILTER:
			/*
			 * Toggle the OSFilter flag
			 */
			if( EX_os_filter )
			    EX_os_filter = FALSE;
                        else
			    EX_os_filter = TRUE;
			update_select_mcf( fp, -1 );

                	ReadPrt_Dir( fp );
                        break;
		
                case FROM_DATABASE:
			FIf_erase(fp);
		        stat = EMGetDbParts(&dbpart_info);
			FIf_display(fp);
			if(stat & 1)
			 {
			  FIfld_set_text(fp,SELECT_MCF,0,0,dbpart_info.filename,
					 0);
			  FIfld_set_text(fp,SELECT_MCF,0,1,dbpart_info.number,
					 0);
			  FIfld_set_text(fp,SELECT_MCF,0,2,dbpart_info.revision,
					 0);
			  FIfld_set_text(fp,SELECT_MCF,0,3,
					 dbpart_info.description,0);
                          ReadPrt_Dir(fp);
			 }
			break;

  		case FI_ACCEPT:
			text_buff[0] = 0;
			FIfld_get_text(fp,SEED_FILE,0,0,MAXPATHLEN,
					(unsigned char *)text_buff,&sf,&rp);
			if(text_buff[0] && strcmp(text_buff,"EMS Default"))
			{
                            /* Set up the seed file */
                            strcpy( EX_seedfile, text_buff );
                        }
			text_buff[0] = 0;			
			FIfld_get_text(fp,SELECT_MCF,0,0,MAXPATHLEN,
					(unsigned char *)text_buff,&sf,&rp);
    			if ( text_buff[0] == 0 ) 
                         {
        	            formname[0] = 0;
                            FIg_set_text(fp,FI_MSG_FIELD,"Part not selected");
                            FIg_reset(fp,FI_ACCEPT);
                         }
			else 
        		{	 
       				FIg_get_text( fp, DIR_NAME, formname);
       				strcat( formname, "/");
       				strcat( formname, text_buff);
        		}
			if( formname[0] )
			{
				if( attrs )
					free( attrs );
				numattrs = 0;
			
				get_part_info( fp );
			}
			else
                       
				break;
   			FIf_delete ( fp );
			{
    			int	rsp = EX_FORM_FINISHED;
	
				ex$putque(msg = &stat, response = &rsp);
			}
			break;

  		case FI_CANCEL:
			FIf_delete ( fp );
			formname[0] = 0;

			{ 
			int	rsp = EM_FORM_CANCELLED;
		  		ex$putque(msg = &stat, response = &rsp);
			}
			break;

  		case FI_CVT_TO_PERM_WIN:
			FIg_erase( fp, FI_CVT_TO_PERM_WIN );
			break;
  	}

  	return(1);
}

get_part_info ( fp )
Form fp;
{
char text_buff[MAXPATHLEN];
int  sf, rp;
        
        text_buff[0] = 0;
	FIfld_get_text(fp,SELECT_MCF,0,1,MAXPATHLEN,
			(unsigned char *)text_buff,&sf,&rp);

	if( !text_buff[0] ) /* If no partnumber given, default to filename */
		FIfld_get_text(fp,SELECT_MCF,0,0,MAXPATHLEN,
			(unsigned char *)text_buff,&sf,&rp);

	fill_attr( EM_PART_ATTR, EM_STRING, "number","Part Number",text_buff,
								&numb );
        text_buff[0] = 0;
	FIfld_get_text(fp,SELECT_MCF,0,2,MAXPATHLEN,
			(unsigned char *)text_buff,&sf,&rp);

        if(text_buff[0] == 0)
         {
	fill_attr( EM_PART_ATTR, EM_STRING, "revision","Part Revision",
						"1", &rev );
         }
       else
        {
	fill_attr( EM_PART_ATTR, EM_STRING, "revision","Part Revision",
						text_buff, &rev );
        }

	numattrs = 3;
	attrs = (EMattr *)malloc( 3*sizeof(EMattr));
        text_buff[0] = 0;
	FIfld_get_text(fp,SELECT_MCF,0,3,MAXPATHLEN,
			(unsigned char *)text_buff,&sf,&rp);
        if(text_buff[0] != 0)
	fill_attr( EM_PART_ATTR, EM_STRING, "description","Part Description",
						text_buff, &attrs[0] );
        else
	fill_attr( EM_PART_ATTR, EM_STRING, "description","Part Description",
						"File Part", &attrs[0] );
	fill_attr( EM_COMMON_ATTR, EM_STRING, "itemno","Item Number","1",
								&attrs[1]);
	fill_attr( EM_INSTANCE_ATTR, EM_INTEGER, "quantity","Quantity","1",
								&attrs[2]);
}

delete_file( fp )
Form fp;
{
int     sf, rp, i;
char	text_buff[MAXPATHLEN], tmp_file[MAXPATHLEN];
long    msg;

	FIg_get_text( fp, DIR_NAME, save_cwd);
	FIfld_get_text(fp,SELECT_MCF,0,0,MAXPATHLEN,
			(unsigned char *)text_buff,&sf,&rp);
	if( text_buff[0] == 0 )
	{
	        FIg_set_text(fp,FI_MSG_FIELD,"Select File to Delete");		
#ifdef ENV5
    		Wait_timer(10);
#endif
	        FIg_set_text(fp,FI_MSG_FIELD,"");
		return;
	}

	strcpy( tmp_file, save_cwd );
	strcat( tmp_file, "/");
	strcat( tmp_file, text_buff );
	remove( tmp_file );

	/* Remove the entry from FILE_MCF */
	for( i = 0; i < file_cnt; i++ )
		if( !strcmp( text_buff, filnam[i] ))
			mask[i] = 1;

	update_file_mcf( fp );			
	update_select_mcf( fp, -1 );

	/* Remove entry from partdata file */
	asm$rem_directory_part( msg = &msg,
				dir = save_cwd,
				filename = text_buff );
}

show_dir_listing( fp )
Form fp;
{
char **locdirnam = NULL;
char  text_buff[MAXPATHLEN];
int  sts, i;
int  xsize, ysize, first = 1;

	for( ;; ) 
	{
		if( dir_cnt == 1 && !first)
			break;

		first = 0;
		if( dir_cnt )
			locdirnam = ( char ** )malloc( sizeof( char * )	* dir_cnt);
		for(i = 0; i < dir_cnt; i++ )
			locdirnam[i] = (char *)dirnam[i];

		FIg_get_size( fp, DIR_NAME, &xsize, &ysize );
      		pull_main (100, fp, DIR_NAME, xsize+10, 0, locdirnam, 
				   dir_cnt, 0, 0, 15, &sts, &i);

		if( sts ) /* A selection is made */
		{
			update_select_mcf( fp, -1 );
			strcpy( text_buff, locdirnam[i] );
			move_to_dir( fp, text_buff );
			if( locdirnam )
				free( locdirnam );
		}
		else break;
	}
}

move_to_dir( fp, dir)
Form fp;
char *dir;
{
char  *expanded_dir;
int   status;

	expanded_dir = EXgetcwd(save_cwd, MAXPATHLEN);
	expanded_dir = expand_shell_vars(dir);

	if( ! ChangePrt_Dir(expanded_dir) ) 
   	{
		status = ReadPrt_Dir( fp );
          	if (!status)
           	{
           		ChangePrt_Dir(save_cwd);
           		ReadPrt_Dir(fp);
           	}
        }
	else
        {
        	FIfld_set_num_rows(fp,FILE_MCF,0);
	  	FIg_set_text(fp,FI_MSG_FIELD,sys_errlist[errno]);
	}
}

update_select_mcf( fp, ind )
Form fp;
int ind;
{
int i, sf, rp;
char  text_buff[MAXPATHLEN];


	for( i = 0; i < 4; i++ )
	{
		if( ind >= 0 )
			FIfld_get_text(fp,FILE_MCF,ind,i,MAXPATHLEN,
				(unsigned char *)text_buff,&sf,&rp);
		else
			text_buff[0] = 0;

    		FIfld_set_text( fp,SELECT_MCF,0,i,text_buff,0 );
	}
}

#argsused
static int prtdef_form_notif( f_label, g_label, value, fp )
int		f_label;	/* i - The label of the form	*/
int		g_label;	/* i - The label of the gadget	*/
double		value;		/* i - The value of the gadget	*/
Form		fp;		/* i - Form pointer		*/
{
char text_buff[MAXPATHLEN];
int  sf,rp;
int  row, col, pos;

	FIg_set_text(fp,FI_MSG_FIELD,"");
	switch( g_label )
	{
		case PART_ATTR:

			FIfld_get_active_row( fp, g_label, &row, &pos);
			FImcf_get_active_col ( fp, g_label, &col, &pos );

			if( row < 3 && col == 0 ) /* Name column */
			{
				FIfld_get_text(fp,g_label,row,0,MAXPATHLEN,
					   (unsigned char *)text_buff, &sf,&rp);
				if( row == 0 &&  strcmp( text_buff, "number" ) )
				{
					FIfld_set_text(fp,g_label,0,0,"number",0);
					FIg_set_text(fp,FI_MSG_FIELD,"Cannot change reserved names");
				}
				if( row == 1 && strcmp( text_buff, "revision" ))
				{
					FIfld_set_text(fp,g_label,1,0,"revision",0);
					FIg_set_text(fp,FI_MSG_FIELD,"Cannot change reserved names");
				}
				if( row == 2 && strcmp( text_buff, "description") )
				{
					FIfld_set_text(fp,g_label,2,0,"description",0);
					FIg_set_text(fp,FI_MSG_FIELD,"Cannot change reserved names");
				}
				if( row == 3 && strcmp( text_buff, "itemno") )
				{
					FIfld_set_text(fp,g_label,3,0,"itemno",0);
					FIg_set_text(fp,FI_MSG_FIELD,"Cannot change reserved names");
				}

				break;
			}
			if( col == 0 )
			{
				text_buff[0] = 0;
				FIfld_get_text(fp,g_label,row,0,MAXPATHLEN,
					   (unsigned char *)text_buff, &sf,&rp);
				if( text_buff[0] == 0 )
					update_attrs( fp, g_label, row);
			}
			break;
		case OCCR_ATTR:
			FIfld_get_active_row( fp, g_label, &row, &pos);
			FImcf_get_active_col ( fp, g_label, &col, &pos );
/*********
			if( row < 2 && col == 0 ) 
			{
				FIfld_get_text(fp,g_label,row,0,MAXPATHLEN,
					   (unsigned char *)text_buff, &sf,&rp);

				if( row == 0 && strcmp( text_buff, "quantity" ))
				{
					FIfld_set_text(fp,g_label,0,0,"quantity",0);
					FIg_set_text(fp,FI_MSG_FIELD,"Cannot change reserved names");				
				}
				break;
			}
************/
			if( col == 0 )
			{
				text_buff[0] = 0;
				FIfld_get_text(fp,g_label,row,0,MAXPATHLEN,
					   (unsigned char *)text_buff, &sf,&rp);
				if( text_buff[0] == 0 )
					update_attrs( fp, g_label, row );
			}
			break;

		case FI_ACCEPT:
			/* Read the Filename gadget 
			*/
     			FIg_get_text( fp, FILE_NAME, formname);
			if( !formname[0] )
			{
				FIg_set_text( fp, FI_MSG_FIELD,"Enter Filename");
				break;
			}
			if( attrs )
				free( attrs );
			attrs = NULL;
			numattrs = 0;

			/* Now read all the attrs info from the two MCFs */
			get_mcf_attrs( fp, PART_ATTR, &attrs, &numattrs );
			get_mcf_attrs( fp, OCCR_ATTR, &attrs, &numattrs );

   			FIf_delete ( fp );
			{
    			int	rsp = FORM2_FINISHED;
			long 	stat;
	
				ex$putque(msg = &stat, response = &rsp);
			}
			break;

		case FI_CANCEL:
			formname[0] = 0;
   			FIf_delete ( fp );
			{
    			int	rsp = FORM2_FINISHED;
			long 	stat;
	
				ex$putque(msg = &stat, response = &rsp);
			}
			break;

  		case FI_CVT_TO_PERM_WIN:
			FIg_erase( fp, FI_CVT_TO_PERM_WIN );
			break;
	}
	return( 1 );
}

update_attrs( fp, glabel, row)
Form fp;
int  row, glabel;
{
int sf, rp;
char text_buff[MAXPATHLEN];

	FIfld_get_text(fp, glabel,row+1,0,MAXPATHLEN,
				   (unsigned char *)text_buff, &sf,&rp);
	while( text_buff[0] )
	{
		FIfld_set_text( fp, glabel, row, 0, text_buff, 0 );
		FIfld_get_text(fp, glabel,row+1,1,MAXPATHLEN,
				   (unsigned char *)text_buff, &sf,&rp);
		FIfld_set_text( fp, glabel, row, 1, text_buff, 0 );
		FIfld_get_text(fp, glabel,row+1,2,MAXPATHLEN,
				   (unsigned char *)text_buff, &sf,&rp);
		FIfld_set_text( fp, glabel, row, 2, text_buff, 0 );

		row += 1;
		FIfld_get_text(fp, glabel,row+1,0,MAXPATHLEN,
			   (unsigned char *)text_buff, &sf,&rp);
	}
}

get_mcf_attrs( fp, glabel, attrib, num )
Form fp;
int glabel;
EMattr **attrib;
int    *num;
{
int sf, rp;
char text_buff[MAXPATHLEN];
int row = 0, ind;

	if( glabel == PART_ATTR )
	{
		FIg_get_text( fp, FILE_NAME, numb.value.syntax);

		strcpy( numb.info.name, "number");
		numb.info.type = EM_PART_ATTR;
		numb.value.type = EM_STRING;

		FIfld_get_text(fp,PART_ATTR,0,1,MAX_DESC,
				(unsigned char *)numb.info.desc,&sf,&rp);
		text_buff[0] = 0;
		FIfld_get_text(fp,PART_ATTR,0,2,MAXPATHLEN,
				(unsigned char *)text_buff,&sf,&rp);
		if( text_buff[0] )
			strcpy( numb.value.syntax, text_buff );

		strcpy( rev.info.name, "revision");
		rev.info.type = EM_PART_ATTR;
		rev.value.type = EM_STRING;
		FIfld_get_text(fp,PART_ATTR,1,1,MAX_DESC,
				(unsigned char *)rev.info.desc,&sf,&rp);
		FIfld_get_text(fp,PART_ATTR,1,2,MAX_SYNTAX,
				(unsigned char *)rev.value.syntax,&sf,&rp);

/* Description will go into attrs[0], since asm$create_file_part() doesn't have
   it as an argument.
		strcpy( desc.info.name, "description");
		desc.info.type = EM_PART_ATTR;
		desc.value.type = EM_STRING;

		FIfld_get_text(fp,PART_ATTR,2,1,MAX_DESC,
				(unsigned char *)desc.info.desc,&sf,&rp);
		FIfld_get_text(fp,PART_ATTR,2,2,MAX_SYNTAX,
				(unsigned char *)desc.value.syntax,&sf,&rp);
		remove_quotes( text_buff );
		strcpy( desc.value.data.s, text_buff );
		strcpy( desc.value.syntax, text_buff );
*/
		row = 2;
	}
	FIfld_get_text(fp, glabel,row,0,MAXPATHLEN,
			   (unsigned char *)text_buff, &sf,&rp);
	while( text_buff[0] )
	{
		if( *num )
			*attrib = (EMattr *)realloc( *attrib, sizeof(EMattr)*(*num+1) );
		else
			*attrib = (EMattr *)malloc( sizeof(EMattr) );

		ind = *num;
		/*
                 * Set the type for system attributes
		 */
		if( !strcmp( text_buff, "description" ) )
                  {
			(*attrib)[ind].value.type = EM_STRING;
                  }
                else
		 if( !strcmp( text_buff, "itemno" ) )
			(*attrib)[ind].value.type = EM_STRING;
		 else
			(*attrib)[ind].value.type = EM_CALCULATED;

		if( glabel == PART_ATTR )
                 {
                   if(!strcmp( text_buff, "itemno" ) )
			(*attrib)[ind].info.type = EM_COMMON_ATTR;
                   else
			(*attrib)[ind].info.type = EM_PART_ATTR;
                 }
		else
			(*attrib)[ind].info.type = EM_INSTANCE_ATTR;
		strcpy((*attrib)[ind].info.name, text_buff);

		FIfld_get_text(fp, glabel,row,1,MAXPATHLEN,
			   (unsigned char *)text_buff, &sf,&rp);
		strcpy((*attrib)[ind].info.desc, text_buff);

		FIfld_get_text(fp, glabel,row,2,MAXPATHLEN,
			   (unsigned char *)text_buff, &sf,&rp);

                if((*attrib)[ind].value.type != EM_CALCULATED)
                 {
		   strcpy( (*attrib)[ind].value.data.s, text_buff );
		   strcpy( (*attrib)[ind].value.syntax, text_buff );
                 }
                else
		 if(remove_quotes( text_buff ))
		  {
			(*attrib)[ind].value.type = EM_STRING;
			strcpy( (*attrib)[ind].value.data.s, text_buff );
			strcpy( (*attrib)[ind].value.syntax, text_buff );
		  }
		 else 
		  {
			(*attrib)[ind].value.type = EM_DOUBLE;
			(*attrib)[ind].value.data.d = atof(text_buff);
			strcpy((*attrib)[ind].value.syntax, text_buff );
		  }

		*num += 1;
		ind = *num;
		row += 1;
		FIfld_get_text(fp, glabel,row,0,MAXPATHLEN,
			   (unsigned char *)text_buff, &sf,&rp);
	}
}

Create_prt( fp ) 
Form fp;
{
int        sts, sf, rp;
Form       fp1;
char       text_buff[MAXPATHLEN];
int        done, found;
char       tmp_file[MAXPATHLEN];
int	   response, num_bytes;
char	   response_data[256];

	text_buff[0] = tmp_file[0] = 0;
	FIfld_get_text(fp,SELECT_MCF,0,0,MAXPATHLEN,(unsigned char *)text_buff,
								&sf,&rp);

	/* Check if the file exists and readable */
	if( text_buff[0] )
	if( access( text_buff, R_OK ) == -1 )
	{
		sprintf( tmp_file,"File <%s> cannot be a seedfile", text_buff);
		FIg_set_text( fp, FI_MSG_FIELD, tmp_file );
		return(0);
	}

        FIg_set_text(fp,FI_MSG_FIELD,"Reading seed part attributes...");

	sts = FIf_new( 101, "EMPartDef", prtdef_form_notif, &fp1);

	if (sts != FI_SUCCESS)
	{
		fprintf (stderr, "FIf_new failed: sts = %d\n",sts);
		return( 0 );
	}

	if( text_buff[0] == 0 )
	{
		/* Get the EMS default seed_file 
		*/
                found = EX_get_seed_file( tmp_file, text_buff );
		FIg_set_text( fp1, SEED_NAME, "EMS Default" );
		if( !found )
		{
			return( 0 ); /*** ??? ***/
		}
	}
	else
		FIg_set_text( fp1, SEED_NAME, text_buff );

	display_part_attrs( fp1, text_buff );

        FIg_set_text(fp,FI_MSG_FIELD," ");
	FIf_erase( fp );
	FIf_display( fp1 );

	done = 0;
   	while ( !done )
        {
                /*
                 * mode changed from 0 to EX_ALL_CHAR_MODE for 16 bit in form
                 */
           	EX_wait_for_input( &response, response_data,EX_ALL_CHAR_MODE,
                                                            &num_bytes);  
           	if ( response == FORM2_FINISHED )
             		done = 1;
           	else if ( (response == EX_CMD_KEY )
			 || (response == STRING )
                       	 || (response == CMD_STRING)
                         || (response == CLEAR_STACK))
             	{           
             		done = 1;
  	         	FIf_delete (fp1);
			return( 0 );
             	}           
        }
	return ( 1 );
}

display_part_attrs( fp, filename )
Form fp;
char *filename;
{
struct GRid partid;
int gadget, pind, iind, row;
int sts,i,fileno;
long msg;
char tmp_string[256];

	/* Get the filepart id and then the attribute data,
           if found, display in the form2.
	*/
	if( !get_filepart_id( filename, &partid, &fileno, &sts ))
	{
		FIg_set_text( fp, FI_MSG_FIELD, "Seedfile is not a File Part");

    		FIfld_set_text( fp,PART_ATTR,0,0,"number",0 );
    		FIfld_set_text( fp,PART_ATTR,1,0,"revision",0 );
    		FIfld_set_text( fp,PART_ATTR,2,0,"description",0 );
    		FIfld_set_text( fp,PART_ATTR,3,0,"itemno",0 );
    		FIfld_set_text( fp,PART_ATTR,3,2,"1",0 );

                ex$close_module(ftype = EX_invisible, index = fileno);
		return ( 1 );
	}
	sts = asm$attribute_count( msg = &msg,
			       id = &partid,
			       count = &numattrs );
	if( !( msg & 1 ) )
		return( 0 );

	attrs = ( EMattr * )malloc( sizeof( EMattr ) * numattrs );
	pind = iind = 0;
	for( i = 0; i < numattrs; i++ )
	{
		sts = asm$get_attribute (msg = &msg,
		                         id = &partid,
		                         index = i,
		                         attribute = &attrs[i]);
		if( !(sts & 1 ))
		{
		  	verbose(printf("Error getting attribute at %d\n",i));
			continue;
		}

		/* Now depending on the attribute type show it in
		   the corresponding MCF
		*/
		if( (attrs[i].info.type == EM_PART_ATTR ) ||
                    (attrs[i].info.type == EM_COMMON_ATTR))
		{
			gadget = PART_ATTR;
			row = pind;
		}
		else 
		{
			gadget = OCCR_ATTR;
			row = iind;
		}

    		FIfld_set_text( fp,gadget,row,0,attrs[i].info.name,0 );
    		FIfld_set_text( fp,gadget,row,1,attrs[i].info.desc,0 );

/*		if( attrs[i].value.type == EM_DOUBLE )
			sprintf( tmp_string, "%lf", attrs[i].value.data.d );
		else if( attrs[i].value.type == EM_INTEGER )
			sprintf( tmp_string, "%d", attrs[i].value.data.i );
		else if( attrs[i].value.type == EM_STRING)
			sprintf( tmp_string, "\"%s\"", attrs[i].value.data.s );
		else  case of EM_CALCULATED ??
*/

		strcpy( tmp_string, attrs[i].value.syntax );
    		FIfld_set_text( fp,gadget,row,2,tmp_string,0 );

		if( (attrs[i].info.type == EM_PART_ATTR ) ||
                    (attrs[i].info.type == EM_COMMON_ATTR))
			pind++;
		else if( attrs[i].info.type == EM_INSTANCE_ATTR )
			iind++;

	}		
	ex$close_module( ftype = EX_invisible, index = fileno );
	return(1);
}
/*
Change_prt( fp )
Form fp;
{
;
}	
*/

static int ChangePrt_Dir( todir )
char *todir;
{
#ifndef NT
  return chdir( todir );
#else
  return _chdir( todir );
#endif
}


#define RAND_INT( L, U )				\
	(int)( L + (U-L)*drand48() )

int EX_qsort_lists( lower, upper, list,list1,list2,list3,list4)
int	lower;	/* Lower bound of partition */
int	upper;	/* Upper bound of partition */
ENTRY	list[]; /* Basis List to be sorted  */
ENTRY	list1[]; /* List to be sorted       */
ENTRY	list2[]; /* List to be sorted	    */
PDESC   list3[]; /* List to be sorted	    */
ENTRY	list4[]; /* List to be sorted	    */
{
register int i, lastlow;
ENTRY *t;
int status;

	if ( upper > lower )
    	{
    		i=RAND_INT( lower,  upper );

		EX_swap_strings( lower, i, list, list1, list2, list3, list4 );

    		t =  (ENTRY *) list[lower];
    		lastlow = lower;
    		for ( i=lower+1; i<=upper; i++)
		{
    			status = strcmp(list[i],(char *)t);
			if ( status < 0  )
	    		{
	    			lastlow++;
	           		EX_swap_strings( lastlow,i,list,list1,list2,
							list3,list4);
	    		}
		}
		EX_swap_strings( lower,lastlow,list,list1,list2,list3,list4);

    		EX_qsort_lists( lower,lastlow-1,list,list1,list2,list3,list4 );
    		EX_qsort_lists( lastlow+1,upper,list,list1,list2,list3,list4 );
    	}
    	return(1);
}


/* This function will swap the strings in adjacent arguments */
int EX_swap_strings ( i, j, a, b, c, d, e )
ENTRY *a, *b, *c, *e;
PDESC *d;
int i, j;
{
  char temp[MAXPATHLEN];

  strcpy (temp,a[i]);
  strcpy(a[i],a[j]);
  strcpy(a[j],temp);

  strcpy (temp,b[i]);
  strcpy(b[i],b[j]);
  strcpy(b[j],temp);

  strcpy (temp,c[i]);
  strcpy(c[i],c[j]);
  strcpy(c[j],temp);

  strcpy (temp,d[i]);
  strcpy(d[i],d[j]);
  strcpy(d[j],temp);

  strcpy (temp,e[i]);
  strcpy(e[i],e[j]);
  strcpy(e[j],temp);

  return(1);
}


/*****************************************************************************

   Doc: EXgetprt_file	"File Requester Box"   - Modified for 2.4+ - DKK(IGI)

   Abstract: This Function allows the user to select a file & the path
	to the file from a list of those directories available in the
	current system.  The user may enter a file name that does not
	exist.  Which is good for save with new name.

   Dependencies: shellvar.c => char * expand_shell_vars(unexpanded_filename)


****************************************************************************/

int EXgetprt_file(title, startdir, in_file, pat,file_type,
		       number, revi, attribs, noattr,my_id,
                       returned_fname,seedfile,form_type,
                                           response,response_data)
char	*title;       /* i - The title on the file requester form. */
char	*startdir;    /* i - The initial directory */
char	*in_file;     /* i - The initial file name to be placed in the file name
			     field.  Usefull for saving.  The user may edit the
			     file name to do a save under new name or simply 
			     hit the check mark. */
char	*pat;         /* i - Pattern to match files with 'ls' command. opt NULL	*/
int file_type[];
char *returned_fname; /* file name returned to user */
char *seedfile;
int form_type;
int *response;
char *response_data;
EMattr *number, *revi;
EMattr **attribs;
int  *noattr;
OM_S_OBJID my_id;
/***************************************************************************/
{
char	pat_buff[30];
int	sts, i;
int     num_bytes;
char 	done;
int 	not_done,status;

	if (file_type)
     	{
		not_done = TRUE;
     		while ( not_done )
      		{
      			if (file_type[number_types] )
				number_types++;
      			else 
				not_done = FALSE;
      		}
     	}
	sts = FIf_new( 100, "EMGetPrtFile", EXgetprtfil_form_notif, &fp);

	if (sts != FI_SUCCESS)
	{
		fprintf (stderr, "FIf_new failed: sts = %d\n",sts);
	}

        FIf_set_cmd_oid_os(fp,my_id,OM_Gw_current_OS);

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
	  	if( ! ChangePrt_Dir(startdir) )
          	{
			FIfld_set_text( fp, SELECT_MCF, 0, 0, in_file, 0 );
          	}
	  	else
	  	{
		    	FIg_set_text(fp,FI_MSG_FIELD,sys_errlist[errno]);
			FIfld_set_text( fp, SELECT_MCF, 0, 0, "", 0 );
	  	}
	}

	formfile_type = 0;
        filnam = dirnam = product = pnumb = prev = 0;
	mask = 0;
	pdesc = 0;

        /* initialize ( prevent bad 'free' ) */
	buf_siz = 0;

	attrs = NULL;
	numattrs = 0;

	done = 0;

    	if ( form_type != EX_RETRIEVE_FILE_FORM)     
	{
		FIg_erase(fp, DELETE_BTN);
		FIg_erase(fp, OSFILTER);
		FIg_erase(fp, SEED_FILE);
		FIg_erase(fp, SEED_TXT);
		FIg_erase(fp, FROM_DATABASE);
	}
	else
	{
        char *buf = NULL;

            /* if PDU/PDM is not loaded, erase FROM_DATABASE gadget */
	    sts = ex$get_product_data(in_runname = "Pdu", product_path = &buf);
            if(!sts)
                FIg_erase(fp, FROM_DATABASE);
	}
        if( title )
            FIg_set_text(fp, FORM_TITLE, title);

	/*
   	 * This should be called only once, beginning of a design session.
	 */
	EMinitialise();

    	EX_os_filter = TRUE;
    	if ( number_types )
  	       formfile_type = (int *)malloc( number_types * sizeof(int) );

	for( i = 0; i < 5; i++ )
		FIfld_set_mode( fp, FILE_MCF, i, FI_SINGLE_SELECT );
	
	/* Set up the seed file name */
	FIg_set_text( fp, SEED_FILE,"EMS Default");

    	if( FIf_display(fp) == FI_SUCCESS )
	{
		/* Display file names and partdata in partlisting MCF */
	 	status = ReadPrt_Dir( fp );
     		if (!status)
        	{
         		formname[0] = 0;
         		done = 1;
  	     		FIf_delete (fp);
        	}
      		while ( !done )
         	{
           		EX_wait_for_input( response,response_data,0,&num_bytes);  
           		if ( *response == EX_FORM_FINISHED ||
				*response == EM_FORM_CANCELLED )
             		{
             			done = 1;
             		}
           		else if ( (*response == EX_CMD_KEY )
				 || (*response == STRING )
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

	ChangePrt_Dir(old_dir);

/* Set the output variables 
 */
	if( formname[0] )
	{
		if( number )
			*number = numb;
		if( revi )
			*revi = rev;
		if( attribs )
			*attribs = attrs;
		if( noattr )
			*noattr = numattrs;
	}

    	if (old_dir)
		free (old_dir);
	if( filnam) 
		free(filnam);
	if( dirnam) 
		free(dirnam);
	if( product) 
		free(product);
	if( pnumb ) 
		free(pnumb);
	if( prev ) 
		free(prev);
	if( pdesc ) 
		free(pdesc);
    	if (formfile_type) 
		free (formfile_type);

    	strcpy(returned_fname,formname);

    	if (formname[0] == 0 )
     		return (0);
    	else
		return( 1 );
}

/* This function is to set the static globals in this file */
Init_plprt_form( Form fp )
{
int status, i;

        FIg_set_text(fp, FORM_TITLE, "Place Part");
	FIg_erase(fp,OSFILTER);
	FIg_erase(fp,SEED_TXT);
	FIg_erase(fp,SEED_FILE);
	FIg_erase(fp,DELETE_BTN);
	FIg_erase(fp,FROM_DATABASE);

	/*
	 *  Save current directory for later recall
 	*/
	if( (old_dir = EXgetcwd((char *) NULL, MAXPATHLEN)) == NULL)
        {
	  	FIg_set_text(fp,FI_MSG_FIELD,sys_errlist[errno]);
               	return (0);
        }
        filnam = dirnam = product = pnumb = prev = 0;
	mask = 0;
	pdesc = 0;

        /* initialize ( prevent bad 'free' ) */
	buf_siz = 0;

	for( i = 0; i < 5; i++ )
		FIfld_set_mode( fp, FILE_MCF, i, FI_SINGLE_SELECT );

    	EX_os_filter = TRUE;
 	status = ReadPrt_Dir( fp );
	if (!status)
		return(0);

	return( 1 );
}

/* This is called from place part CO. */
Reset_prtDir()
{
	/*
	 *  Change back to original working directory
  	 */

	ChangePrt_Dir(old_dir);

	/*
	 * Free the memory allocated to the static globals
	 */
    	if (old_dir)
		free (old_dir);
	if( filnam) 
		free(filnam);
	if( dirnam) 
		free(dirnam);
	if( product) 
		free(product);
	if( pnumb ) 
		free(pnumb);
	if( prev ) 
		free(prev);
	if( pdesc ) 
		free(pdesc);
}

