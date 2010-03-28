/*
Name
        GRlicense

Description
        This file contains the code to retrieve and track licenses.

History
        dhm     05/25/92    creation date.
        dhm     08/25/92    revision date.
        aic     11/03/92    Added kluge to prevent getting multiple licenses
                            in 2.1.0. This will be modified in 2.1.1.
        mrm     12/01/92    removed kludge, revised extensively and added
                            heaps of new code to track licenses
*/

#include <stdio.h>
#include <signal.h>
#include <version.h>
#include <api.h>
#include "igrtypedef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmsg.h"
#include "grlicense.h"

#ifndef TRUE
#define TRUE    1
#define FALSE   0
#endif

#ifdef sparc
#define SIGNUM    SIGXCPU
#else
#define SIGNUM    SIGPWR
#endif

#define PROD_VERSION_YEAR  "1992"

extern int ILic_get_license();
extern char *ILic_format_license_status();
extern struct license_status *ILic_get_license_status();

extern char EX_runname[];

/*
        The following variable is used to store a function pointer in case the
        signal used for NetLS already had a handler initialized.  The handler
        defined here will call that function after completing its processing.
*/
static void (*previous_signal_handler)();

/*
        The following variable is used to maintain a list of licenses.
*/
static GRlicense_info *license_list = NULL;

/*
        The following variable is used to record whether all requests for
        licenses succeed.
*/
static int GRlicense_status = TRUE;

/*
Name
        GRget_license_status

Description
        This function returns TRUE if all license requests succeeded, and
        FALSE otherwise.
*/

int GRget_license_status()
{
    return(GRlicense_status);
}

/*
Name
        GRset_license_status

Description
        This function sets the status used to determine whether all license
        requests succeed.  This is used during switchprod.
*/

void GRset_license_status(sts)
int sts;
{
    GRlicense_status = sts;
}

/*
Name
        GRrecord_license

Description
        This function records a license.
*/

int GRrecord_license(id, name, number, type, expiration)
char *id;
char *name;
int number;
int type;
int expiration;
{
    GRlicense_info *l = license_list;

    if (l)
    {
        /* list initialized, find the end of it */
        while (l->next)
            l = l->next;

        /* add another entry */
        l->next = (GRlicense_info *)calloc((unsigned)1, 
                                           sizeof(GRlicense_info));
        l = l->next;
    }
    else
    {
        /* initialize the list */
        license_list = (GRlicense_info *)calloc((unsigned)1, 
                                                sizeof(GRlicense_info));
        l = license_list;
    }

    /* store the license information */
    strcpy(l->product_id, id);
    strcpy(l->run_name, name);
    l->license_number = number;
    l->license_type = type;
    l->expiration = expiration;
    l->request_count = 1;
    return(TRUE);
}    

/*
Name
        GRcheck_license

Description
        This function checks whether the specified license has already been
        obtained.
*/

GRlicense_info *GRcheck_license(id)
char *id;
{
    GRlicense_info *l = license_list;

    while (l)
    {
        if (strcmp(l->product_id, id) == 0)
            return(l);
        else
            l = l->next;
    }
    return(NULL);
}
    
/*
Name
        GRrelease_license

Description
        This function releases the specified license and removes it from the
        linked list of license information.
*/

int GRrelease_license(id)
char *id;
{
    char *c;
    GRlicense_info *l, *p;

    /* make sure the id is uppercase */
    for (c = id; *c; c++)
        *c = toupper(*c);

    p = NULL;
    l = license_list;
    while (l)
    {
        if (strcmp(l->product_id, id) == 0)
        {
            ILic_return_license(l->license_number);
            if (p)
                p->next = l->next;
            else
                license_list = l->next;
            free(l);
            return(TRUE);
        }
        else
        {
            p = l;
            l = l->next;
        }
    }
    return(FALSE);
}
    
/*
Name
        GRrelease_unneeded_licenses

Description
        This function releases licenses not need by the active product lists.
        It determines which licenses to release by comparing the active search
        path with the runname information stored as licenses are allocated.
        If a licensed product is not in the active list, its license is
        surrendered.

        This function should be called after a switchprod.
*/

void GRrelease_unneeded_licenses()
{
    char active_products[BUFSIZ];
    int sts, size;
    GRlicense_info *l, *p, *t;

    size = BUFSIZ;
    sts = EX_get_srch_path1(EX_runname, 0, active_products, &size);
    if (sts & 1)
    {
        p = NULL;
        l = license_list;
        while (l)
        {
            if (strstr(active_products, l->run_name) == NULL)
            {
                /* this product's license is unneeded - free it */
                ILic_return_license(l->license_number);
                if (p)
                    p->next = l->next;
                else
                    license_list = l->next;
                t = l;
                l = l->next;
                free(t);
            }
            else
            {
                p = l;
                l = l->next;
            }
        }
    }
}

/*
Name
        GRrelease_all_licenses

Description
        This function releases all licenses allocated through GRget_license.
        It should be invoked prior to exiting the process.  Otherwise, there
        will be a delay in the availability of the licenses until I/LICENSE
        notices that the process has died.
*/

void GRrelease_all_licenses()
{
    GRlicense_info *l, *p;

    l = license_list;
    while (l)
    {
        ILic_return_license(l->license_number);
        p = l->next;
        free(l);
        l = p;
    }
    license_list = NULL;
}

/*
Name
        GRreset_license_request_count

Description
        This function resets the request count of each license to zero.
*/

void GRreset_license_request_count()
{
    GRlicense_info *l;

    for (l = license_list; l; l = l->next)
        l->request_count = 0;
}

/*
Name
        GRget_license_info

Description
        This function will return a pointer to the linked list of license
        information.  Since this is a pointer to the same list used by all the
        licensing interface code, it is very important that a caller not dork
        it up.
*/

GRlicense_info *GRget_license_info()
{
    return(license_list);
}

/*
Name
        GRget_current_licenses

Description
        This function will return an array of GRlicense_info structures
        containing the current license information.

Synopsis
        int GRget_current_licenses()
                                output - TRUE for success, FALSE if there are
                                         no licenses outstanding.
        int *n                  output - the number of licenses in the list
        GRlicense_info **list   output - array of n GRlicense_info structures

Notes
        The caller is responsible for deallocating the list with free().
*/

int GRget_current_licenses(n, list)
int *n;
GRlicense_info **list;
{
    int i;
    GRlicense_info *l;

    if (license_list == NULL)
    {
        /* no licenses allocated */
        *n = 0;
        *list = NULL;
    }
    else
    {
        /* shoot through the list to get a size count */
        for (l = license_list, *n = 0; l; l = l->next, (*n)++)
            ;

        /* allocate an array */
        *list = (GRlicense_info *)calloc(*n, sizeof(GRlicense_info));

        /* fill in the array */
        for (l = license_list, i = 0; l; l = l->next, i++)
            (*list)[i] = *l;
    }
    return(*n ? TRUE : FALSE);
}

/*
Name
        GRkill_commands

Description
        This function places a CLEAR_STACK event on the queue to kill all
        commands.
*/

int GRkill_commands(mode)
int mode;
{
    if (mode == EX_CMD_NEW)
    {
        int response;
	long msg;

        response = CLEAR_STACK;
        ex$putque(msg = &msg, pos = FRONT, response = &response);
    }
    return(TRUE);
}

/*
Name
        GRdisable_commands

Description
        This function adds a command server function which will disable all
        commands by killing them as they are invoked.
*/

void GRdisable_commands()
{
    ex$add_cmdserver_func(fun = GRkill_commands);
}

/*
Name
        GRsignal_NetLS_trouble

Description
        This function is invoked as a signal handler by the NetLS system when
        a license has been lost.  The signal warns that the process will be
        killed at some time in the future.  The amount of time before the
        process is killed is defined in the product.def file.

        This function will be set as a signal handler when a license is
        requested through GRlicense.
*/

void GRsignal_NetLS_trouble(sig)
int sig;
{
    static int beenhere = 0;

    sigrelse(sig);
    if (!beenhere)
    {
        ex$message(msgnumb = GR_F_NetLSerror);
        if (previous_signal_handler)
            previous_signal_handler(sig);
        beenhere = 1;
    }
}

/*
Name
        GRlicense

Description
        This function obtains a license for a product.

Notes
        The initial release will be in the "no-teeth" mode, meaning that the
        I/LICENSE call will always return a status of API_LICENSE_GRANTED.
        Also, note that the GRlicense call will handle putting up the error
        box with the appropiate message error message displayed.
 
Synopsis
        char *product_id    input - The product id number
        char *run_name      input - The product run name from the 
                            product_data file
        int options         input (optional) - Flags to specify alternative
                            behavior; see definitions in grlicense.h

Sample Call
        int status;

        status = gr$get_license(product_id = "SM01041", run_name = "Ems");
        if (status == FALSE)
        {
            code to handle license failure
        }

Return Codes
        TRUE - license obtained
        FALSE - no license obtained

Error messages
        The following error messages may be displayed if there is a problem
        obtaining a license:

        GR_F_NoLicenseGranted           ERROR: No license granted for product
        GR_F_NetLSerror                 ERROR: Severe licensing error! 
                                        You are about to be killed.
                                        Save work now.
        GR_F_NoLicenseWarning           WARNING: License not granted 
                                        for product
        GR_F_LicenseExpiresTomorrow     WARNING: License will expire tomorrow
 
History
        dhm     08/25/92    revision date.
        dhm     09/17/92    added optional options flag for future use.
        mrm     12/01/92    added product name to error messages
*/

int GRget_license(product_id, run_name, options)
char *product_id, *run_name;
int options;
{
    int sts, license_number, expiration, license_type;
    static int set_sig_handler = TRUE;
    void (*func)();
    char *c, buf[128], product_options[BUFSIZ], *lic_sts;
    GRlicense_info *l;

    /*
        Establish a signal handler to be invoked if NetLS decides something is
        rotten in License-ville.  The signal handler will warn the user that
        termination is imminent.
    */

    if (set_sig_handler)
    {
        set_sig_handler = FALSE;
        func = sigset(SIGNUM, GRsignal_NetLS_trouble);
        if (func != SIG_ERR)
            previous_signal_handler = func;
    }

    /* make sure the id is uppercase */
    for (c = product_id; *c; c++)
        *c = toupper(*c);

    /*
        Check whether this license has already been obtained.
    */

    if (l = GRcheck_license(product_id))
    {
        /*
            A license has already been obtained; just increment the request
            counter and return 
        */

        l->request_count++;
        return(TRUE);
    }

    /*
        Call I/LICENSE to get the license for the specified product.
    */

    product_options[0] = NULL;

    sts = ILic_get_license(product_id, PROD_VERSION_YEAR, SIGNUM, 
                           product_options, BUFSIZ,
                           &license_number, &expiration, &license_type,
                           NULL, NULL, NULL); /* fixup args */

    lic_sts = ILic_format_license_status(ILic_get_license_status
                                         (license_number));

    switch (sts)
    {
      case API_LICENSE_GRANTED:

        /* check expiration date */
        if ((license_type != API_RESERVED_LICENSE) &&
            (expiration < (time(0) + (24*60*60))))
        {
            GRget_product_name(product_id, buf);
            ex$message(msgnumb = GR_F_LicenseExpiresTomorrow,
                       type = "%s %s %s",
                       var = `buf, product_options, lic_sts`);
        }

        /* record the license request */
        GRrecord_license(product_id, run_name, license_number, 
                         license_type, expiration);

        break;

      case API_NO_LICENSE_WARNING:

        /* lucky day - a free ride */
        GRget_product_name(product_id, buf);
        ex$message(msgnumb = GR_F_NoLicenseWarning,
                   type = "%s %s %s",
                   var = `buf, product_options, lic_sts`);
        break;

      case API_TECHNICAL_ERROR:
      case API_NO_LICENSE_ERROR:
      case API_NO_LICENSE_DEMO:
      default:

        /* whoops - some one's going to be miffed */
        GRlicense_status = FALSE;
        GRget_product_name(product_id, buf);
        ex$message(msgnumb = GR_F_NoLicenseGranted,
                   type = "%s %s %s",
                   var = `buf, product_options, lic_sts`);

        if (options & GRExitOnError)
            /* bail out - caller asked for it! */
            exit(1);
        else if (options & GRDisableOnError)
            /* disable all commands */
            GRdisable_commands();
        return(FALSE);
    }
    return(TRUE);
}
