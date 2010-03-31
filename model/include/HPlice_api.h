
/* Application Programmer's Interface to Software Licensing */
/* Last Updated December 3, 1991 */

#ifndef _API_H_
#define _API_H_

#include <signal.h>
#include <stdio.h>

/* This is a macro to set up a default signal handler to handle the PSD's
** shutdown warning signal.  If you are using the API_GET_LICENSE macro,
** please invoke this macro at block level 0 in the same file.
*/
#ifdef __STDC__
#define API_HANDLE_SHUTDOWN() \
static void _api_handle_shutdown_signal ( int signum ) \
{ \
  signal ( signum, _api_handle_shutdown_signal ); \
  fprintf ( stderr, \
    "Application is shutting down, license is lost.  Please exit.\n"); \
}
#else
#define API_HANDLE_SHUTDOWN() \
static void _api_handle_shutdown_signal ( signum ) \
int signum; \
{ \
  signal ( signum, _api_handle_shutdown_signal ); \
  fprintf ( stderr, \
    "Application is shutting down, license is lost.  Please exit.\n"); \
}
#endif

/* This macro is a "quick and dirty" method of using software licensing.
** This should be invoked during initialization of the application.  The
** macro requires two character string arguments:
**           Product number (e.g. "SS01043")
**           Product version (e.g. "1991")
*/
#define API_GET_LICENSE(product_number,product_version) \
{ \
  int status, license; \
  char options[128]; \
\
  /* Set up a signal handler in case the license is lost while the \
  ** application is running. */ \
  signal ( SIGUSR1, _api_handle_shutdown_signal ); \
\
  /* This is where the license is requested. */ \
  status = ILic_get_license ( product_number, product_version, SIGUSR1, \
			      options, sizeof options, &license, \
			      (int *) 0, (int *) 0, (char *) 0, 0, 0 ); \
\
  /* Check to see if a license was granted.  If no license is available \
  ** then the program will exit. */ \
  switch (status) \
  { \
    case API_LICENSE_GRANTED: \
      break; \
    case API_TECHNICAL_ERROR: \
      fprintf ( stderr, "Error: %s", \
	ILic_format_license_status(ILic_get_license_status(license))); \
      exit(-1); \
    case API_NO_LICENSE_ERROR: \
      fprintf ( stderr, "Error: No license: %s", options); \
      exit(-1); \
    case API_NO_LICENSE_WARNING: \
      fprintf ( stderr, "Warning: No license.\n"); \
      fprintf ( stderr, "%s", options); \
      fprintf ( stderr, "%s", \
	ILic_format_license_status(ILic_get_license_status(license))); \
      break; \
    case API_NO_LICENSE_DEMO: \
      fprintf ( stderr, "%s", options); \
      fprintf ( stderr, "Demo mode is not supported by this application.\n"); \
      ILic_return_license ( license ); \
      exit(-1); \
    default: \
      fprintf ( stderr, "Error: unknown license return status=%d\n", status); \
      fprintf ( stderr, "%s", \
	ILic_format_license_status(ILic_get_license_status(license))); \
      exit(-1); \
  } \
}

/* This macro is a more secure method of using software licensing.
** This should be invoked during initialization of the application.  The
** macro requires six arguments (see ILic_get_license for details):
**           Product number (e.g. "SS01043")
**           Product version (e.g. "1991")
**           License number (user declared variable name)
**           Fixup area address (e.g. &global_var)
**           Fixup area length
**           Fixup method
*/
#define API_GET_SECURE_LICENSE(product_number, product_version, license, fixup_area_addr, fixup_area_length, fixup_method) \
{ \
  int status ; \
  char options[128]; \
\
  /* Set up a signal handler in case the license is lost while the \
  ** application is running. */ \
  signal ( SIGUSR1, _api_handle_shutdown_signal ); \
\
  /* This is where the license is requested. */ \
  status = ILic_get_license ( product_number, product_version, SIGUSR1, \
			     options, sizeof options, (int *) &license, \
			     (int *) 0, (int *) 0, (char *) fixup_area_addr, \
			     fixup_area_length, fixup_method ); \
\
  /* Check to see if a license was granted.  If no license is available \
  ** then the program will exit. */ \
  switch (status) \
  { \
    case API_LICENSE_GRANTED: \
      break; \
    case API_TECHNICAL_ERROR: \
      fprintf ( stderr, "Error: %s", \
	ILic_format_license_status(ILic_get_license_status(license))); \
      exit(-1); \
    case API_NO_LICENSE_ERROR: \
      fprintf ( stderr, "Error: No License: %s", options); \
      exit(-1); \
    case API_NO_LICENSE_WARNING: \
      fprintf ( stderr, "Warning: No License.\n"); \
      fprintf ( stderr, "%s", options); \
      fprintf ( stderr, "%s", \
	ILic_format_license_status(ILic_get_license_status(license))); \
      break; \
    case API_NO_LICENSE_DEMO: \
      fprintf ( stderr, "%s", options); \
      fprintf ( stderr, "Demo mode is not supported by this application.\n"); \
      ILic_return_license ( license ); \
      exit(-1); \
    default: \
      fprintf ( stderr, "Error: Unknown License return status=%d\n", status); \
      fprintf ( stderr, "%s", \
	ILic_format_license_status(ILic_get_license_status(license))); \
      exit(-1); \
  } \
}

/*
**			APplication Interface condition codes
*/

/* These are the possible return codes from calls to the licensing routines. */
#define API_LICENSE_GRANTED 0	/* Application is licensed to run. */
#define API_TECHNICAL_ERROR 1	/* Some error occurred in communications with
				the Policy Server.  System error code is in
				errno.  Application should display appropriate
				error message and terminate. */
#define API_NO_LICENSE_ERROR 2	/* No license is available for the product.
				Application should display appropriate error
				message and terminate. */
#define API_NO_LICENSE_WARNING 3 /* No license is available for the product.
				Application should display appropriate error
				message and continue to function as if a
				license were available. */
#define API_NO_LICENSE_DEMO 4	/* No license is available for the product. 
				Application can continue to function in a
				"demo" mode with limited functionality. */


/* These are the definitions of the license types. */
#define API_RESERVED_LICENSE 0xffffffff
#define API_NETLS_NODELOCKED 1
#define API_NETLS_CONCURRENT 2
#define API_NETLS_USEONCE    4

/*
**			APplication Interface status check
*/

struct license_status
{
  long mtype;
  unsigned int flags;
  unsigned int token_type;
  unsigned int node_locked_status;
  unsigned int concurrent_status;
  unsigned int use_once_status;
  unsigned long request_time;
  unsigned long last_access_time;
};

/* flag definition masks */
#define RESERVED_LICENSE	0x01
#define RECLAIMING_LICENSE_1	0x04
#define RECLAIMING_LICENSE_2	0x08
#define SHUTDOWN_PROCESS	0x10
#define GRACE_PERIOD		0x40
#define PERMISSIVE_POLICY	0x80

/* Support macro definitions */
#if defined(__STDC__) || defined(__cplusplus)
#define __P(args) args
#else
#define __P(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/*
**			APplication Interface routines
*/

/* Basic call to get a license. */

int ILic_get_license __P( ( 
    char          * product_id,      /* String */
    char          * product_version, /* String */
    short          signal_num,      /* Signal to use to force a
					clean rundown. */
    char          * product_options, /* Optional.  Annotation,
					if any is returned. */
    int             option_length,   /* Optional.  Size of
					product_options area. */
    int           * license_number,  /* Optional.  Output license id. */
    int           * exp_date,        /* Optional.  Earliest expiration
					date of the license(s). */
    int           * license_type,    /* Optional.  Type of license used. */
    char          * fixup_address,   /* Optional.  Address of data
					to be modified. */
    int             fixup_length,    /* Optional.  Amount of data to
					be modified. */
    int             fixup_method     /* Optional.  Algorithm to be used
					to modify data. */
    )) ;


/* To return a license before exiting: */

int ILic_return_license __P( (
    int             license_number   /* License id from ILic_get_license
					or ILic_get_license_w. */
    )) ;

/* If an application is willing to wait for a license to become available,
** the ILic_get_license_w routine will hang until a license is granted. */

int ILic_get_license_w __P( ( 
    char          * product_id,      /* String */
    char          * product_version, /* String */
    short           signal_num,      /* Signal to use to force a
					clean rundown. */
    char          * product_options, /* Optional.  Annotation,
					if any is returned. */
    int             option_length,   /* Optional.  Size of
					product_options area. */
    int           * license_number,  /* Optional.  Output license id. */
    int           * exp_date,        /* Optional.  Earliest expiration
					date of the license(s). */
    int           * license_type,    /* Optional.  Type of license used. */
    char          * fixup_address,   /* Optional.  Address of data
					to be modified. */
    int             fixup_length,    /* Optional.  Amount of data to
					be modified. */
    int             fixup_method     /* Optional.  Algorithm to be used
					to modify data. */
    )) ;

/* Reserve a license for later use.  This routine will have the Policy
** Server get a license and hold it for a later ILic_get_license request.
** Note:  A reserved license can only be used on the machine it is
** reserved by.  There is no way to "unreserve" a license. */

int ILic_reserve_license __P( (
    char          * product_id,      /* String */
    char          * product_version, /* String.  Must match exactly. */
    unsigned int    duration,        /* Number of seconds to keep
					the reserved license. */
    char          * product_options, /* Optional.  Annotation,
					if any is returned. */
    int             option_length,   /* Optional.  Size of
					product_options area. */
    int           * exp_date,        /* Optional.  Earliest expiration
					date of the license(s). */
    int           * license_type     /* Optional.  Type of license used. */

    )) ;
/*
  Note:  The ILic_reserve_license call is not needed by most applications.
  It is provided as a way for a user to pre-checkout a license for a
  number of hours, with the knowledge that the user will be needing
  that license during that time period.  There will be a tool provided
  for the user to reserve licenses for applications.  Since a license
  is locked to the machine which reserves it for the specified duration,
  there is a limit on the reservation's duration (currently 7 days).
*/

/* This call allows two or more processes to share a license.  The process
** which is granted the license (using ILic_get_license or ILic_get_license_w)
** calls ILic_export_license for each process that is to share the license. */

int ILic_export_license __P( (
    int              license_number  /* License id to be exported. */
    ));

/* This call is the other side of ILic_export_license.  It registers a process
** as using a license that was granted to another process.  A call to
** ILic_export_license must have been made by a process who is already
** registered as a user of the license. */

int ILic_register_process __P( ( 
    int              license_number  /* License id to register with. */
    ));
/*
  Note: The argument (license_number) was output from ILic_get_license or
  ILic_get_license_w in another process.  It is the application's responsibility
  to pass this value between processes.

  The use of the ILic_export_license and ILic_register_process is encouraged
  in a multiple process environment.  This allows the tracking of processes by 
  the licensing system without all processes having to acquire a license.  
  An example of their use:

      Process `A' uses ILic_get_license to acquire a license for the product.  
      Since process `A' is going to fork and exec two child processes (`B'
      and `C'), process `A' first calls ILic_export_license twice.  The
      children processes are launched, passing the license number, and both
      children call ILic_register_process.  Process `B' must also fork and
      exec a child process of its own, so it calls ILic_export_license, and
      launches process `D' (also passing the license number).  Process `D'
      calls ILic_register_process.  Now, if process `A' exits (or the license
      is lost), all of the children processes who registered will receive the
      shutdown_signal specified in the ILic_get_license call.
*/


/* This is how an application gets more information about a license returned
** from ILic_get_license or ILic_get_license_w.  It either returns a pointer
** to a license_status structure which contains the information, or on error
** it returns a 0.  Note: The return value points to static data whose content
** is overwritten by each call. */

struct license_status * ILic_get_license_status __P( ( 
    int              license_number  /* License id from ILic_get_license. */
    ));

/* This routine generates a "standard" text string from a license_status
** structure.  If status (the input) is 0, this routine will use data from
** the last ILic_get_license_status call.  If the last ILic_get_license_status
** call failed, this routine will generate a correct message about why that call
** failed.  Note: The return value points to static data whose content is
** overwritten by each call. */

char * ILic_format_license_status __P( ( 
    struct license_status * status
    )) ;


/* This routine places an ASCII string into the Policy Server's log file.
** Note: If necessary, the string will be broken up into substrings of a
** maximum length of 50 characters. */

int ILic_log_information __P( (
    char *string
    )) ;
	
#if defined(__cplusplus)
}
#endif

#endif
