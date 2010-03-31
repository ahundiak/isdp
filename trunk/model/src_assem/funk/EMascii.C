/*******************************************************************************
*									       *
* File:   EMascii.c							       *
*									       *
* Description:								       *
*                                                                              *
*     This file contains routines for manipulating the ascii partdata file     *
*									       *
*									       *
* Dependencies:								       *
*                                                                              *
* Notes:							               *
*                                                                              *
* History:        10/07/93    Krishna Kumar(IGI)  creation                     *
*******************************************************************************/
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <sys/stat.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include <exdef.h>
#include <ex.h>
#include <expriv.h>
#include <exmacros.h>
#include <execmsg.h>
#include <exms.h>
#include <msdef.h>
#include "msmacros.h"
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>

#ifndef NT
#include <unistd.h>
#include <dirent.h>
#include <sys/param.h>
#else
#define MAXPATHLEN _MAX_PATH
#include <direct.h>
#endif

#ifdef BIG_ENDIAN
#include <exsysdep.h>
#endif

#ifndef NT
#define DIRECTORY_BIT S_IFDIR
#else
#define DIRECTORY_BIT _S_IFDIR
#endif

#include "DIdef.h"
#include "igetypedef.h"
#include <gr.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include "asmfilemac.h"
#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

#define ASCII_FNAME "partdata.asc"
#define REC_LENGTH  128

#define ASM_NOSUCH_ENTRY -2

static FILE *ascii_fp;
static char fname[256];
static char entry[REC_LENGTH], *ptr; 

IGRlong EMasc_num_parts( IGRlong *msg, IGRchar *dir, IGRint *p_num )
{

  	*msg = MSFAIL;

	fname[0] = '\0';
	entry[0] = '\0';
	if( dir ) 
	{
		strcpy( fname, dir );
		strcat( fname, "/");
	}

	strcat( fname, ASCII_FNAME);

	if( (ascii_fp = fopen( fname, "r" )) == NULL )	
	{
		verbose(printf("Could not open file\n"));
		return( OM_S_SUCCESS );
	}
	else
	{
	        if (fread(entry, REC_LENGTH, 1, ascii_fp) )
		{
			ptr = strtok( entry, ":" );
			ptr = strtok( NULL, "\n" );
			sscanf( ptr, "%d", p_num );
			*msg = MSSUCC;
		}
	}
	fclose( ascii_fp );

	return( OM_S_SUCCESS );
}



IGRlong EMasc_add_part( IGRlong *msg, IGRchar *dir, IGRchar *filename, 
 			IGRchar *number, IGRchar *rev, IGRchar *desc,
			IGRchar *product )
{
int num, stat, found ;
char temp[256];

  	*msg = MSFAIL;
	fname[0] = '\0';
	stat = 'A';
	if( dir ) 
	{
		strcpy( fname, dir );
		strcat( fname, "/");
	}

	strcat( fname, ASCII_FNAME);

	/* First try to open for read&write, if file not present, open it for
           write
        */
	entry[0] = '\0';
	num = 0;
	if( (ascii_fp = fopen( fname, "r+" )) == NULL )	
	{
		if( (ascii_fp = fopen( fname, "w" )) == NULL )	
			return( OM_S_SUCCESS );
		
	}
	else /* File existing, increment the number in first record */
	{
	        fread(entry, REC_LENGTH, 1, ascii_fp);
		ptr = strtok( entry, ":" );
		ptr = strtok( NULL, "\n" );
		sscanf( ptr, "%d", &num );
	}
	/* First, see if an entry with given filename exists */
	found = 0;
	for( ;; )
	{
		if( fgets( entry, REC_LENGTH, ascii_fp ) )
		{
			if( entry[0] == 'A' ) /* count only undeleted */
			{
				strcpy( temp, entry );
				ptr = strtok( temp, "\t" );/* status */
				ptr = strtok( NULL, "\t" );/* fname */
				if ( !strcmp( ptr, filename ) )
				{
					found = 1;
					break;
				}
			}
		}
		else
			break;
	}
	if (!found)
	{
		num += 1;
		sprintf( entry,"Number of parts: %03d\n", num );
		fseek( ascii_fp, 0, SEEK_SET );
		fwrite( entry, strlen(entry), 1, ascii_fp );

		fseek( ascii_fp, 0, SEEK_END );
	}
	else
	{
		num = strlen( entry );
		fseek( ascii_fp, -num, SEEK_CUR );
	}
		
        /* Now write the entry in the file
        */

	sprintf(entry, "%c\t%s\t",stat,filename);
	if( number )
		strcat(entry, number);
	strcat(entry,"\t");
	if( rev )
		strcat(entry, rev);
	strcat(entry,"\t");
	if( desc )
		strcat(entry, desc);
	strcat(entry,"\t");
	if( product )
		strcat(entry, product);
	strcat(entry,"\n");

	if( strlen( entry ) > REC_LENGTH )
		goto wrapup;
	else
		fwrite( entry, strlen(entry), 1, ascii_fp );

	*msg = MSSUCC;
wrapup:
	fclose( ascii_fp );
	return( OM_S_SUCCESS );
}

IGRlong EMasc_mod_part( IGRlong *msg, IGRchar *dir, IGRchar *filename, 
 			IGRchar *number, IGRchar *rev, IGRchar *desc,
			IGRchar *product )
{
int  num, stat;
char temp[256];

  	*msg = MSFAIL;
	fname[0] = '\0';
	stat = 'A';
	if( dir ) 
	{
		strcpy( fname, dir );
		strcat( fname, "/");
	}

	strcat( fname, ASCII_FNAME);
	entry[0] = '\0';
	num = 0;
	if( (ascii_fp = fopen( fname, "r+" )) == NULL )	
	{
		return( OM_S_SUCCESS );
		
	}

	for( ;; )
	{
		if( fgets( entry, REC_LENGTH, ascii_fp ) )
		{
			if( entry[0] == 'A' ) /* count only undeleted */
			{
				strcpy( temp, entry);
				ptr = strtok( temp, "\t" );/* status */
				ptr = strtok( NULL, "\t" );/* fname */
				if ( !strcmp( ptr, filename ) )
					break;
			}
		}
		else
		{
			verbose(printf("No such part %s\n",filename ));
			goto wrap_up;
		}
	}
	num = strlen( entry );
	fseek( ascii_fp, -num, SEEK_CUR );
	sprintf(entry, "%c\t%s\t",stat,filename);
	if( number )
		strcat(entry, number);
	strcat(entry,"\t");
	if( rev )
		strcat(entry, rev);
	strcat(entry,"\t");
	if( desc )
		strcat(entry, desc);
	strcat(entry,"\t");
	if( product )
		strcat(entry, product);
	strcat(entry,"\n");
	fwrite( entry, strlen(entry), 1, ascii_fp );

	*msg = MSSUCC;

wrap_up:
	fclose( ascii_fp );
	return( OM_S_SUCCESS );
}

IGRlong EMasc_rem_part( IGRlong *msg, IGRchar *dir, IGRchar *filename, 
			IGRint index)
{
int num, lindx = 0;
char temp[256];

  	*msg = MSFAIL;
	fname[0] = '\0';
	entry[0] = '\0';
	if( dir ) 
	{
		strcpy( fname, dir );
		strcat( fname, "/");
	}

	strcat( fname, ASCII_FNAME);
	if( (ascii_fp = fopen( fname, "r+" )) == NULL )	
	{
		return( OM_S_SUCCESS );
	}
	/* Decrement the Number of parts */
        fread(entry, REC_LENGTH, 1, ascii_fp);
	ptr = strtok( entry, ":" );
	ptr = strtok( NULL, "\n" );
	sscanf( ptr, "%d", &num );
	if( num > 0 )
		num -= 1;
	sprintf( entry,"Number of parts: %03d\n", num );
	fseek( ascii_fp, 0, SEEK_SET );
	fwrite( entry, strlen(entry), 1, ascii_fp );

	for( ;; )
	{
		if( fgets( entry, REC_LENGTH, ascii_fp ) )
		{
			if( entry[0] == 'A' ) /* count only undeleted */
			if( index != -1 ) /* Delete by index, this takes precedence */
			{
				lindx++;	
				if ( lindx == index )
					break;
			}
			else
			{
				strcpy( temp, entry );
				ptr = strtok( temp, "\t" );/* status */
				ptr = strtok( NULL, "\t" );/* fname */
				if ( !strcmp( ptr, filename ) )
					break;
			}
		}
		else
		{
			if( index != -1 ) /* reached EOF */
			{
				verbose(printf("Given index %d out of range\n",index));
				goto wrap_up;
			}
			else if ( filename )
			{
				verbose(printf("No such part %s\n",filename ));
				goto wrap_up;
			}
		}
	}
	entry[0] = 'D'; /* Set the status of the part to "Deleted" */
	num = strlen( entry );
	fseek( ascii_fp, -num, SEEK_CUR );
	fwrite( entry, strlen(entry), 1, ascii_fp );

	*msg = MSSUCC;

wrap_up:
	fclose( ascii_fp );
	return( OM_S_SUCCESS );
}

IGRlong EMasc_get_part( IGRlong *msg, IGRchar *dir, IGRchar *filename, 
			unsigned short *perm,IGRchar *numb,IGRchar *rev,IGRchar *desc, 
			IGRint index)
{
int lindx = 0;
char temp[256], tempfname[256];
struct stat stat_buf;
int pdat = FALSE;

  	*msg = ASM_NOSUCH_ENTRY;
	fname[0] = '\0';
	entry[0] = '\0';
	if( dir ) 
	{
		strcpy( fname, dir );
		strcat( fname, "/");
	}

	strcat( fname, ASCII_FNAME);
	if( (ascii_fp = fopen( fname, "r" )) == NULL )	
	{
		return( OM_S_SUCCESS );
	}

	/* If the input contains the "filename", then return the "numb", "rev",
           "desc", otherwise, given either "index" or "numb" & "rev" return the
           "filename".
	*/ 
	if( strlen( filename ) > 0 )
		pdat = TRUE;

	for( ;; )
	{
		if( fgets( entry, REC_LENGTH, ascii_fp ) )
		{
			if( entry[0] == 'A' ) /* consider only undeleted */
			if( pdat ) 
			{
				strcpy( temp, entry);
				ptr = strtok( temp, "\t" );/* status */
				ptr = strtok( NULL, "\t" );/* fname */
				if( !strcmp( filename, ptr ) )
				{
					ptr = strtok( NULL, "\t" );/* numb */
					if( ptr && numb )
						strcpy( numb, ptr );
					ptr = strtok( NULL, "\t" );/* rev  */
					if( ptr && rev )
						strcpy( rev, ptr );
					ptr = strtok( NULL, "\t" );/* desc */
					if( ptr && desc )
						strcpy( desc, ptr );
					*msg = MSSUCC;
					goto wrap_up;
				}
			}
			else if( index != -1 ) /* get by index, this takes precedence */
			{
				lindx++;	
				if ( lindx == index )
				{
					strcpy( temp, entry);
					ptr = strtok( temp, "\t" );/* status */
					ptr = strtok( NULL, "\t" );/* fname */
					strcpy( tempfname, ptr ); /* store it */
					break;
				}
			}
			else
			{
				strcpy( temp, entry );
				ptr = strtok( temp, "\t" );/* status */
				ptr = strtok( NULL, "\t" );/* fname */
				strcpy( tempfname, ptr ); /* store it */
				ptr = strtok( NULL, "\t" );/* number */

				/* Both number and rev should match */
				if( !strcmp( ptr, numb ) )
				{
					ptr = strtok( NULL, "\t" );/* rev */
					if ( !strcmp( ptr, rev ) )
						break;
				}
			}
		}
		else 
		{
			if( pdat )
			{
				*msg = ASM_NOSUCH_ENTRY;
				goto wrap_up;
			}
			else if( index != -1 ) /* reached EOF */
			{
				verbose(printf("Given index %d out of range\n",index));
				*msg = ASM_NOSUCH_ENTRY;
				goto wrap_up;
			}
			else if ( numb && rev )
			{
				*msg = ASM_NOSUCH_ENTRY;
				goto wrap_up;
			}
		}
	}
	/* Got an entry with matching number & rev, or matching index, and
           its file name is in tempfname, check if it exists in the directory.
        */
	fname[0] = '\0';
	if( dir ) 
	{
		strcpy( fname, dir );
		strcat( fname, "/");
	}

	strcat( fname, tempfname );
	if ( stat( fname, &stat_buf ) == 0 )
	{
		*msg = MSSUCC;
		strcpy( filename, tempfname );
		/* Get the file permissions */
		if( perm )
			*perm = stat_buf.st_mode;
	}
	else
		verbose(printf("Part file %s doesn't exist\n", tempfname));

wrap_up:
	fclose( ascii_fp );
	return( OM_S_SUCCESS );
}


IGRlong EMasc_update_file( IGRlong *msg, IGRchar *dir ) 
{
char **entries, **files, temp[256];
int i, numents;
char filpath[256];

	*msg = MSFAIL;
	fname[0] = '\0';
	if( dir ) 
	{
		strcpy( fname, dir );
		strcat( fname, "/");
	}

	strcat( fname, ASCII_FNAME );
	if( (ascii_fp = fopen( fname, "r+" )) == NULL )	
	{
		return( OM_S_SUCCESS );
	}
	entries = ( char ** )malloc( sizeof( char * ) );
	files = ( char ** )malloc( sizeof( char * ) );
	numents = 0;
	fname[0] = '\0';
	if( dir ) 
	{
		strcpy( fname, dir );
		strcat( fname, "/");
	}

	fgets( entry, REC_LENGTH, ascii_fp ); /* First record */
	for( ;; )
	{
		if( fgets( entry, REC_LENGTH, ascii_fp ) )
		{
			if( entry[0] == 'A' ) /* consider only undeleted */
			{
				strcpy( temp, entry );
				ptr = strtok( temp+2, "\t" ); /* filename */
				strcpy( filpath, fname );
				strcat( filpath, ptr );
				if( access( filpath, 0 ) == 0 ) /*existing file */
				{
					if( EMis_om_file( filpath ) )/* OM File */
					{
						entries = (char **)realloc( entries, sizeof( char * ) * ( numents + 1 ));
						ASMstrcpy( &entries[numents++], entry, 0 );
					}
					else verbose(printf("%s: not an OM file\n",filpath));
				}
				else perror(filpath);
			}
		}
		else
			break;
	}
	fclose( ascii_fp );

	strcat( fname, ASCII_FNAME );
	remove( fname );
	if( (ascii_fp = fopen( fname, "w" )) == NULL )	
	{
		return( OM_S_SUCCESS );
	}
	
	sprintf( entry,"Number of parts: %03d\n", numents );
	fseek( ascii_fp, 0, SEEK_SET );
	fwrite( entry, strlen(entry), 1, ascii_fp );

	for( i = 0; i < numents; i++ )
		fwrite( entries[i], strlen(entries[i]), 1, ascii_fp );

	*msg = MSSUCC;
	fclose( ascii_fp );

	return( OM_S_SUCCESS );
}


ASMstrcpy( str1, str2, flg )
char **str1, *str2;
int flg;
{
	if( flg ) /* Free only if flg is TRUE */
	if( ((*str1) != NULL) && strcmp(*str1,"") ) 
		free( *str1 );

	(*str1) = malloc(strlen(str2) + 1 );
	strcpy( (*str1), str2);

	return( 1 );
}

int EMget_dir_listing( char *dir, char ***file_list, int *num_files )
{
#ifndef NT
	DIR		*pdir;
	struct dirent	*dent;
#endif
#ifndef NT
	struct stat	stat_buf;
#else
	struct _stat	stat_buf;
#endif
char	cwd[256];
int	status, dir_cnt;

    if( ! dir )
    {
        status = (int) EXgetcwd(cwd, 256);
        if ( !status )
        {
            verbose(printf("EXgetcwd failed\n"));
      	    return (0);
        }
    }
    else strcpy( cwd, dir );

    /*
     *  Read in the list of files
     */
#ifndef NT
    dir_cnt = 0;
    pdir = (DIR *) opendir(cwd);
    if ( !pdir )
    {
        verbose(printf("opendir failed on %s\n", cwd));
        return(0);
    }
    while( dent = readdir(pdir) ) dir_cnt++;

    *file_list = (char **)malloc( dir_cnt * sizeof( char * ));

    rewinddir(pdir);
    dent = readdir(pdir);		/* read "." entry, discard */
    dir_cnt = 0;
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
                continue;
	    }
	    else if(EMis_om_file( dent->d_name ))
       	    {
#if defined (CLIX)
                (*file_list)[dir_cnt] = (char *)malloc(15);
                strncpy( (*file_list)[dir_cnt++], dent->d_name,14 );
#else
                (*file_list)[dir_cnt] = (char *)malloc(OM_K_MAXOSNAME_LEN);
       	        strncpy( (*file_list)[dir_cnt++], dent->d_name, 
                                        OM_K_MAXOSNAME_LEN -1 );
#endif
	    }
	}
    }
    closedir(pdir);

    *num_files = dir_cnt;

    return( 1 );
#endif /* ifdef NT */
}

IGRint EMadd_new_parts( IGRlong *msg, IGRchar *dir )
{
char **files = NULL;
int  i, numfils, sts;
char pnumb[50], prev[50], pdesc[100];

    *msg = MSFAIL;

    sts = EMget_dir_listing( dir, &files, &numfils );

    if( !sts )
        return( sts );

    /* Now for each OS file that is existing on the disk, try to get the 
     * partdata from the ascii file in that directory. If not found,
     * make a new entry. Update the ascii file. 
     */
    for( i = 0; i < numfils; i++ )
    {
        sts = asm$get_directory_part( msg = msg, 
				dir = dir,
        			filename = files[i],
				numb = pnumb,
	     			rev  = prev,
				desc = pdesc);
        if( *msg == MSFAIL )
        {
            verbose(printf("failed to get part for %s\n", files[i] ));
	    continue;
        }
	else if((*msg == ASM_NOSUCH_ENTRY))
	{ 
            /* No entry for the given unix filename */
    	    if( !update_ascii_file( dir, files[i]))
            {
                verbose(printf("failed to enter part info for %s\n", files[i]));
                continue;
            }
	}
    }

    for( i = 0; i < numfils; i ++ )
	free( files[i] );

    if( files )
        free( files );

    return( 1 );
}

update_ascii_file ( partdir, partfilename )
char *partdir, *partfilename;
{
struct GRid id;
long        msg;
int         sts, fileno;
EMattr      numb, rev, desc;

	if( !get_filepart_id( partfilename, &id, &fileno, &sts ) )
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
                        dir        = partdir,
			filename   = partfilename,
			numb = numb.value.data.s,
			rev  = rev.value.data.s,
			desc = desc.value.data.s );

		if( !(msg & 1 ))
                {
		    verbose(printf( "Failed to add directory part\n" ));
                    return(0);
                }
	}
	else
        {
	    verbose(printf("Part not defined completely\n"));
            return(0);
        }

	ex$close_module( ftype = EX_invisible,
			 index = fileno );

	return( 1 );
}

