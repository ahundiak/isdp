/*******************************************************************************
PDMlog_macro.h

General Description:

    This file contains the macros needed to log in and out of PDM.

Macros provided:

    Log in/out:

    o pdm$login()           - log in to PDM
    o pdm$logout()          - log out of PDM

History:

     09/01/92   Mychelle Joiner     Creation Date

*******************************************************************************/
/******************************************************************************

Macro:

     pdm$login

     This macro logs the user in to PDM.

Arguments:

     ARGUMENT            DATA TYPE          I/O  DESCRIPTION
     status              *int                O   Return status.
     environment_name    *char               I   Environment name.
     username_name       *char               I   Username.
     passwd              *char               I   Password.

Sample Invocation:

     int   return_status;
     char  *environment;
     char  *username;
     char  *password;

     pdm$login(
                 status            = &return_status,
		 environment_name  = environment,
		 user_name	   = username,
		 passwd		   = password
               );

Notes:

     A NULL string may be passed for the password.

Return Status:

	Cannot connect using current protocol
	Invalid Environment Name
	Environment not updated in clearinghouse database
	Invalid Username Password
	Invalid Username
        Successful Completion

Include files:

     PDUerror.h
     PDUlog_macro.h

******************************************************************************/
#omdef pdm$login(status,
			environment_name,
			user_name,
			passwd);

	PDUppl_login(status,
			environment_name,
			user_name,
			passwd);

#endomdef

/******************************************************************************

Macro:

     pdm$logout

     This macro logs the user out of PDM.

Arguments:

     ARGUMENT       DATA TYPE          I/O  DESCRIPTION
     return_status  int                 O   Return status.

Sample Invocation:

     int   return_status;

     pdm$logout(
                 status = &return_status
               );

Return Status:

	Command Cancelled
        Successful Completion

Include files:

     PDUerror.h
     PDUlog_macro.h

******************************************************************************/
#omdef pdm$logout(status);

	PDUppl_logout(status);

#endomdef

