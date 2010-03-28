/* #######################    APOGEE COMPILED   ######################## */
/******************************************************************************

Function:

    COtool_access_file
    COtool_strip_quotes
    COtool_fi_message    
    COtool_ci_strcmp
    COtool_make_set

Description:    

    These are generic command object functions.

History:    

    jay wallingford     04/10/89    creation date
						  
Bugs:       

    There are no known bugs.

Notes:

******************************************************************************/

class implementation COtools;

#include <stdio.h>
#include <coimport.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <ctype.h>
#include <UMS.h>
#include <OMminimum.h>
#include <OMlimits.h>
#include <OMOSfilehdr.h>
#include <grgsdef.h>
#include <grgs.h>
#include <grgsmacros.h>

#ifdef X11
#include <stdio.h>
#include <math.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#endif

#define MAX_FILE_LEN 256

from GRgrset import GSstart_transition, GSadd, GSend_transition;

extern IGRint
COis_om_file ( fp )
    FILE * fp;
{
    struct OM_sd_OS_filehdr_OM filehdr;

    /*
     * Read in what may be the file header.
     */
    if ( fread ( &filehdr, 
                 sizeof (struct OM_sd_OS_filehdr_OM), 
                 1, fp) )
    {
        /*
         * If the start time is in the right format
         * return true.
         */
        if ( !(strlen(filehdr.start_time) == 25 && 
               isalpha(filehdr.start_time[0])   &&
               isalpha(filehdr.start_time[1])   && 
               isalpha(filehdr.start_time[2])   &&
               (filehdr.start_time[3] == ' ')   && 
               isalpha(filehdr.start_time[4])   &&
               isalpha(filehdr.start_time[5])   && 
               isalpha(filehdr.start_time[6])   &&
               (filehdr.start_time[7] == ' ')   && 
               (isdigit(filehdr.start_time[8])  ||
               (filehdr.start_time[8] == ' '))  &&
               isdigit(filehdr.start_time[9])   && 
               (filehdr.start_time[10] == ' ')  &&
               isdigit(filehdr.start_time[11])  && 
               isdigit(filehdr.start_time[12])  &&
               (filehdr.start_time[13] == ':')  && 
               isdigit(filehdr.start_time[14])  &&
               isdigit(filehdr.start_time[15])  && 
               (filehdr.start_time[16] == ':')  &&
               isdigit(filehdr.start_time[17])  && 
               isdigit(filehdr.start_time[18])  &&
               (filehdr.start_time[19] == ' ')  && 
               isdigit(filehdr.start_time[20])  &&
               isdigit(filehdr.start_time[21])  && 
               isdigit(filehdr.start_time[22])  &&
               isdigit(filehdr.start_time[23])))
        { 
            return(0);
        }
        else return(1);
    }
    
    return(0);
}

extern IGRint 
COtool_access_file ( msg, name, path )
    IGRint *  msg;
    IGRchar * name;
    IGRchar * path;
{
#ifndef NT
    struct stat stat_info;
#else
    struct _stat stat_info;
#endif
    IGRint      i, ok;
    IGRchar     buffer[MAX_FILE_LEN], *p;
    IGRboolean  found = FALSE;

    *msg = 0; 

    /*
     * If the file is specified and it isn't null.
     */
    if ( name && *name ) 
    {
        /*
         * Set the pointer to the path.
         */
        p = (path) ? path : buffer;

        /*
         * If the file can't be found directly search the
         * product paths.
         */
        if ( access ( name, 0x00 ) ) 
        {
            /*
             * Loop for all product paths.
             */
            for ( ok = TRUE,i = 0; ok == TRUE; i++ ) 
            {
                if ( ok = ex$get_path( index = i,
                                       path = p,
                                       len = MAX_FILE_LEN ) )
                {
                    strncat ( p, name, MAX_FILE_LEN - strlen(name) );
                    
                    /*
                     * If the file exists return it's stats.
                     */
                    if ( !access ( p, 0x00 ) )
                    {
                        found = TRUE;
                        break;
                    }
                }
            }
        }
        else 
        {
            strcpy(p, name);
            found = TRUE;
        }

        if (found) 
        {
            *msg |= CO_file_exists;

            /*
             * Set the access permissions.
             */
            if ( !access ( p, 0x04 ) )  *msg |= CO_file_read;
            if ( !access ( p, 0x02 ) )  *msg |= CO_file_write;
            if ( !access ( p, 0x01 ) )  *msg |= CO_file_execute;

            /*
             * Set the file type.
             */
#ifndef NT
            stat(p, &stat_info);
            *msg |= ( stat_info.st_mode & S_IFDIR ) ?
                      CO_file_dir : CO_file_reg;
#else
            _stat(p, &stat_info);
            *msg |= ( stat_info.st_mode & _S_IFDIR ) ?
                      CO_file_dir : CO_file_reg;
#endif
        }
    }

    return ( *msg );
}

extern int
COtool_same_file (file1, file2)
    char * file1;
    char * file2;
{
    int msg = 0;
#ifndef NT
    struct stat stat1,stat2;
#else
    struct _stat stat1,stat2;
#endif

#ifndef NT
    if ( !(stat(file1, &stat1) & stat(file2, &stat2)) )
#else
    if ( !(_stat(file1, &stat1) & _stat(file2, &stat2)) )
#endif
    {
        msg = (stat1.st_ino == stat2.st_ino) ;
    }
    return(msg);
}

extern int 
COtool_strip_quotes (s)
    char *  s;
{
    char *  p;
    char *  q;
    char *  r;

    r = s;

    if ( p = strchr(s, '\"') ) 
    {
        if ( q = strrchr(++p, '\"') ) 
        {
            *q = '\0';
            while ( *r++ = *p++ );
            return(1);
        }
    }
    return(0);
}

#include <msdef.h>
#include <msmacros.h>
#include <FI.h>

extern int 
COtool_fi_message(form, label, msgnumb, delay_to_clear)
     Form form;
     int label;
     int msgnumb;
     int delay_to_clear;
{ 
    char buffer[UMS_MAX_BUFLEN];
#ifdef X11
    struct timeval xtimer;
    double tmp_sec, xdsec, xdusec;
#endif
    
    if ( msgnumb ) {
        ex$message ( msgnumb = msgnumb, buff = buffer );
    }
    else buffer[0] = '\0';

    FIfld_set_text(form, label, 0, 0, buffer, FALSE);
    if (delay_to_clear != -1)
    {
#ifdef X11
    	 tmp_sec = delay_to_clear/60.0;
    	 xdusec = modf(tmp_sec, &xdsec);
    	 xtimer.tv_sec = (int)xdsec;
    	 xtimer.tv_usec = (int)(xdusec * 1000000);
    	 select(1, 0, 0, 0, &xtimer);
#else
         Wait_timer(delay_to_clear);
#endif
         FIfld_set_text(form, label, 0, 0, "", FALSE);
    }
    return (1);
}

extern int
COtool_ci_strcmp ( s, t )
char * s, * t;
{
    for ( ; tolower(*s) == tolower(*t); s++, t++ )
        if ( *s == '\0' ) return(0);
    return ( tolower(*s) - tolower(*t) );
}
    
extern int
COtool_make_set ( msg, mod_env, gr_ids, num, gs_id )
    IGRint * msg;
    struct GRmd_env * mod_env;
    struct GRid * gr_ids;
    IGRint num;
    struct GRid * gs_id;
{
    IGRint status, properties, relation, i;
    struct GRid sv_id;

    status = OM_S_SUCCESS;
    *msg =  MSSUCC;

    gs_id->osnum = mod_env->md_id.osnum;

    status = gr$gsinit ( msg = msg,
                         flag = 2,
                         senderid = NULL_OBJID,
                         osnum = gs_id->osnum,
                         p_objid = &(gs_id->objid) );

    if ( !(status & *msg & 1) ) goto quit;

    /*
     * Start a transition on the graphics set. This creates the 
     * saved set.
     */
    properties = 0;
    status = om$send ( msg = message GRgrset.GSstart_transition ( (IGRlong *)msg,
                                                                  mod_env,
                                                                  &properties,
                                                                  NULL,
                                                                  &sv_id ),
                       targetid = gs_id->objid,
                       targetos = gs_id->osnum,
                       senderid = NULL_OBJID );

    if ( !(status & *msg & 1) ) goto quit;

    /*
     * Add all the ids to the graphics set.
     */
    for ( i=0; i<num; ++i )
    {
        relation = GO_INSIDE;
        status = om$send ( msg = message GRgrset.GSadd ( (IGRlong *)msg,
                                                         &gr_ids[i],
                                                         &relation ),
                           targetid = sv_id.objid,
                           targetos = sv_id.osnum,
                           senderid = NULL_OBJID );

        if ( !(status & *msg & 1) ) goto quit;
    }
   
    /*
     * Clean up.
     */
    status = om$send ( msg = message GRgrset.GSend_transition ( (IGRlong *)msg, NULL ),
                       targetid = gs_id->objid,
                       targetos = gs_id->osnum,
                       senderid = NULL_OBJID );

quit:

    if ( !(status & *msg & 1) ) *msg = MSFAIL;

    return ( OM_S_SUCCESS);
}
end implementation COtools;
