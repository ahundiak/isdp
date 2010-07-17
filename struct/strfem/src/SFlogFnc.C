/*
  Functions which write errors during conversion to log file
*/

#include <stdio.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <time.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "exmacros.h"
#include "msdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

#include "wl.h"
#include "igecolor.h"
#include "igecolmacros.h"

#include "vderrmacros.h"
#include "SFdef.h"

long SFgetLogFile (
  char		*logfile
)
{
long  		sts;
struct GRid	mod_id;
int		len, startChar;


   if ( !logfile ) { sts = 0; goto wrapup; }

   sts = 1;
   sts = ex$get_cur_mod ( id = &mod_id.objid,
			  osnum = &mod_id.osnum );
   if ( !(sts&1) ) { sts = 0; goto wrapup; }
   sts = VDget_filename_from_os ( mod_id.osnum, logfile );
   if ( !(sts&1) ) { sts = 0; goto wrapup; }

   len = strlen ( logfile );
   if ( len == 14 )
   {
      if ( logfile[10] == '.' &&
	   logfile[11] == 'l' &&
	   logfile[12] == 'o' &&
	   logfile[13] == 'g'    )
      {
	sts = 0;
	goto wrapup;
      }
   }

   startChar = ( len > 10 ) ? 10 : len;
   strcpy ( &logfile[startChar], ".log" );
   __DBGpr_str ( "logfile", logfile );

wrapup:
   return sts;
}



/*
   writes to file
*/

long  SFwriteToLogFile(
 long			*msg,
 char			*name,            /* I */
 char			PlOrBeamOrStfnr,  /* (I) =0 plate, =1 beam, =2 stfnr */
 struct  GRid		obj		  /* I - object id of the input obj */
)
{
long		sts;
char		logfile[15], elementFile[15];
FILE		*fp = NULL;
struct stat	Statbuf;


   if ( !msg || !name )
	{ *msg = MSINARG; sts = OM_E_INVARG; goto wrapup; }

   sts = OM_S_SUCCESS;
   *msg = MSSUCC;

   sts = SFgetLogFile ( logfile );
   if ( !(sts&1) ) goto wrapup;

   /* write header if creating for first time */
   if ( stat(logfile,&Statbuf) < 0 )
   {
      if ( (fp = (FILE *) fopen( logfile, "a" )) == NULL )
      {
	printf("Can not open [%s] for appending\n", logfile);
	goto wrapup;
      }

      fprintf(fp,
	"#\n#  Log file showing ERRORS occured during conversion\n" );
      fclose(fp);
   }

   if ( (fp = (FILE *) fopen( logfile, "a" )) == NULL )
   {
      printf("Can not open [%s] for appending\n", logfile);
      goto wrapup;
   }

   /* get filename in which input object exists */
   sts = VDget_filename_from_os ( obj.osnum, elementFile );

   fprintf(fp, "Date : %s   Time : %s\n", VD_date(), VD_time());

   
   if ( PlOrBeamOrStfnr == SF_PLATE )
   {
      fprintf(fp, "Plate '%s'[%d,%d] of file '%s' could not be extracted\n\n",
		  name, obj.objid, obj.osnum, elementFile );
   }
   else if ( PlOrBeamOrStfnr == SF_BEAM )
   {
      fprintf(fp, "Beam '%s'[%d,%d] of file '%s' could not be extracted\n\n",
		  name, obj.objid, obj.osnum, elementFile );
   }
   else
   {
     fprintf(fp,"Stiffener '%s'[%d,%d] of file '%s' could not be extracted\n\n",
		  name, obj.objid, obj.osnum, elementFile );
   }

   fclose ( fp );

wrapup:
/*
   printf("Returning from SFwriteToLogFile, sts = [%d]\n", sts );
*/
   return sts;
}

