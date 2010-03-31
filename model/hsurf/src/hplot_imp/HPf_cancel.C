
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#include <stdio.h>
#include <string.h>
#include <FI.h>

#include "OMminimum.h"
#include "DIdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "msmacros.h"
#include "plotmsg.h"
#include "madef.h"
#include "godef.h"

#include "HSplot.h"
#include "HSplot_def.h"
#include "HSplot_label.h"
#include "HSplot_def.h"
#include "HSplot.h"
#include "hsmsg.h"

#include "wl.h"
#include "HSpr_hplot.h"



/*---HPcancel_plot------------------------------------------*/

/*
NAME
   HPcancel_plot

KEYWORDS
   shaded plotting
   plot queue status
   cancel

DESCTIPION
   Submit a request to cancel a job in the active queue

PARAMETERS
   gadget_label   :(IN) : id of the gadget selected
   into      :(IN) : shaded plotting global information

GLOBALS USED
   -none-

FUNCTIONS CALLED
   FIfld_get_num_rows
   FIfld_get_text
   FIfld_set_select
   FIfld_set_text
   FIg_display
   ex$message
   fgets
   pclose
   popen
   sizeof
   sprintf
   sscanf
   strcmp
   strlen
   strncmp

HISTORY
   ??/??/??   M. Mathis, M. Lanier
      Created
*/

IGRint   HPcancel_plot( IGRint              gadget_label,
                        struct HSplot_info  *info )

{
   IGRchar  buf[128], buf1[32];
   char     *c, *c2, *j;
   IGRint   sts, i, rpos;
   IGRint   sel;
   FILE     *pp, *popen();

   sts = PI_F_FAIL;

   if( strlen( info->job_to_can ) == 0 )
   {
      ex$message( msgnumb = HS_P_IdJob, buff = buf );

      FIfld_set_text( info->displayed_form,
                      FI_MSG_FIELD,
                      0,
                      0,
                      buf,
                      0 );

      FIg_display( info->displayed_form, FI_MSG_FIELD );
   }
   else
   {
      /* get the nodename of the job to cancel from the nodename field */
      if (c = strchr((char *)info->nodename, '@'))
      {
         if (c2 = strchr( c, ';'))
         {
            *c2 = NULL;
         }
      }
      else
      {
         buf1[0] = NULL;
         c = buf1;
      }

      /* strip the domain from the job spec */
      if (j = strchr(info->job_to_can, (int)'.'))
      {
         if (j = strchr(j + 1, (int)'.'))
         {
            *j = NULL;
         }
      }

      /* open a pipe to the qdel command */
      sprintf( buf, "qdel -k %s%s ",
              info->job_to_can, c );

      pp = popen( buf, "r" );

      if( pp == NULL )
      {
         ex$message( msgnumb = HS_E_CantExe,
                     type = "%s",
                     var = `"/usr/bin/qdel"`,
                     buff = buf );

         FIfld_set_text( info->displayed_form,
                         FI_MSG_FIELD,
                         0,
                         0,
                         buf,
                         0 );

         FIg_display( info->displayed_form, FI_MSG_FIELD );
      }
      else
      {
         /* get the results of the job deletion */

         if( fgets( buf, sizeof( buf ), pp ) == NULL )
         {
            ex$message( msgnumb = HS_E_CantCanJob,
                        type = "%s",
                        var = `info->job_to_can`,
                        buff = buf );
         }

         /* display the qdel results */

         FIfld_set_text( info->displayed_form,
                         FI_MSG_FIELD,
                         0,
                         0,
                         buf,
                         0 );

         FIg_display( info->displayed_form, FI_MSG_FIELD );

         /* close the pipe */
         pclose( pp );

         /* figure out whether a job was deleted */
         if( sscanf( buf, "%*s %*s %*s %*s %s", buf1 ) )
         {
            if( strncmp( buf1, "deleted.", 8 ) == 0 )
            {
               sts = PI_S_SUCCESS;
            }
         }

         /* find the row on the form which lists the deleted job */

         FIfld_get_num_rows( info->displayed_form, QS_JOB_LIST, &i );
         /*i - 1;*/
         while( i >= 0 )
         {
            FIfld_get_text( info->displayed_form,
                            QS_JOB_LIST,
                            i,
                            0,
                            128,
                            buf,
                            &sel,
                            &rpos );

            sscanf( buf, "%*s %*s %s", buf1 );
            if( strcmp( info->job_to_can, buf1 ) == 0 )
            {
               /*
                * erase/unhilite the entry in question
                */

               if( sts == PI_S_SUCCESS )
               {
                  FIfld_set_text( info->displayed_form,
                                  QS_JOB_LIST,
                                  i,
                                  0,
                                  "",
                                  0 );

                  FIg_display( info->displayed_form,
                               QS_JOB_LIST );
               }
               else
               {
                  FIfld_set_select( info->displayed_form,
                                    QS_JOB_LIST,
                                    i,
                                    0,
                                    0 );
                }
               break;
            }
            i--;
         }
         info->job_to_can[0] = NULL;
      }
   }
   return( sts );
}
