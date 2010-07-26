/*
Name
        grlicense.h

Description
        This file contains structures used by the GRNUC - I/LICENSE interface
        code.

History
        mrm     12/01/92    creation
*/

#ifndef grlicense_h
#define grlicense_h

/*
        These definitions are used with the "options" argument in the macro
        gr$get_license.
*/

#define GRExitOnError       0x00000001  /* exit the process if a license */
                                        /* cannot be obtained */

#define GRDisableOnError    0x00000002  /* disable all commands if a license */
                                        /* cannot be obtained - note that */
                                        /* this includes both Save and Exit, */
                                        /* so this option should be used */
                                        /* with care, and *never* from a */
                                        /* switchprod situation */
/*
Name
        gr$get_license

Description
        This macro retrieves a license for a product.  All license requests
        are recorded and duplicate requests are silently ignored.  Licenses
        will be released when the product exits or is swapped out via
        switchprod.  This function will display an error box to the user if a
        license is not obtained.

Synopsis
        char *product_id    input - The product id number
        char *run_name      input - The product run name from the 
                            product_data file
        int options         input (optional) - Flags to specify alternative
                            behavior; see definitions above

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
*/

#omdef  gr$get_license(product_id, run_name, options = NULL)
        GRget_license((product_id), (run_name), (options))
#endomdef

/*
        This structure is used to maintain a list of outstanding license
        information.
*/

typedef struct GR_license_info
{
    struct GR_license_info *next;
    char product_id[32];
    char run_name[32];
    int license_number;
    int license_type;
    int expiration;
    int request_count;
} GRlicense_info;

#endif
