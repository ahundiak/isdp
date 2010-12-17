#include PDUmacrodef.h

/*******************************************************************************
pdumacros.h

General Description:

    This file contains all macros needed to log in and out of PDM and move
    files.

Macros provided:

    Log in/out:

    o pdm$login()           - log in to PDM
    o pdm$logout()          - log out of PDM

    File Movement:

    o pdm$checkin_part()    - check in a part to a specific storage area
    o pdm$checkout_part()   - check out a part and bring it to the current
			      working area
    o pdm$copy_to_local()   - copy files to the current working area (files
			      will be read-only)

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
     server_name         *char               I   Server name.
     environment_name    *char               I   Environment name.
     username_name       *char               I   Username.
     passwd              *char               I   Password.

Sample Invocation:

     int   return_status;
     char  *server;
     char  *environment;
     char  *username;
     char  *password;

     pdm$login(
                 status            = &return_status,
                 server_name	   = server,
		 environment_name  = environment,
		 user_name	   = username,
		 passwd		   = password
               );

Notes:

     A NULL string may be passed for the password.

Return Status:

	Invalid Server Name
	Cannot connect using current protocol
	Invalid Environment Name
	Environment not updated in clearinghouse database
	Invalid Username Password
	Invalid Username
        Successful Completion

******************************************************************************/
#omdef pdm$login(status,
			server_name,
			environment_name,
			user_name,
			passwd);

	PDUppl_login(status,
			server_name,
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

Notes:

Return Status:

	Command Cancelled
        Successful Completion

******************************************************************************/
#omdef pdm$logout(status);

	PDUppl_logout(status);

#endomdef

/******************************************************************************

Macro:

     pdm$checkout_part

     This macro checks out a part and activates it if the activate flag is
     set to TRUE.

Arguments:

     ARGUMENT       DATA TYPE          I/O  DESCRIPTION
     return_status  int                 O   Return status.
     catalog_name   *char               I   Catalog name.
     partid	    *char               I   Part name.
     revision       *char		I   Part revision.
     activate_flag  int			I   Activation indicator.

Sample Invocation:

     int   return_status;
     char  *catalog;
     char  *partid;
     char  *revision;
     int   activate;

     pdm$checkout_part(
                 status = &return_status,
		 catalog_name	= catalog,
		 partid		= part,
		 revision	= rev,
		 activate_flag	= activate
               );

Return Status:

	User must exter a catalog
	User must exter a part
	User must exter a revision
	Catalog does not exist
        Part does not exist
	Revision does not exist
	File does not exist
	Part Must Be Checked In
        Command Cancelled
        Successful Completion

******************************************************************************/
#omdef pdm$checkout_part(status,
				catalog_name,
				partid,
				revision,
				activate_flag);

	PDUppl_checkout_part(status,
				catalog_name,
				partid,
				revision,
				activate_flag);

#endomdef

/******************************************************************************

Macro:

     pdm$checkin_part

     This macro checks in a part.

Arguments:

     ARGUMENT       DATA TYPE          I/O  DESCRIPTION
     return_status  int                 O   Return status.
     catalog_name   *char               I   Catalog name.
     partid	    *char               I   Part name.
     revision       *char		I   Part revision.

Sample Invocation:

     int   return_status;
     char  *catalog;
     char  *partid;
     char  *revision;

     pdm$checkin_part(
                 status = &return_status,
		 catalog_name	= catalog,
		 partid		= part,
		 revision	= rev,
               );

Return Status:

	User must exter a catalog
	User must exter a part
	User must exter a revision
	Catalog does not exist
        Part does not exist
	Revision does not exist
	File does not exist
	Part Must Be Checked Out
        Command Cancelled
        Successful Completion

******************************************************************************/
#omdef pdm$checkin_part(status,
				catalog_name,
				partid,
				revision);

	PDUppl_checkin_part(status,
				catalog_name,
				partid,
				revision);

#endomdef

/******************************************************************************

Macro:

     pdm$copy_files

     This macro copies the files of the specified part the the current
     working directory.  If the activate flag is set to TRUE, the part
     will be activated.

Arguments:

     ARGUMENT       DATA TYPE          I/O  DESCRIPTION
     return_status  int                 O   Return status.
     catalog_name   *char               I   Catalog name.
     partid	    *char               I   Part name.
     revision       *char		I   Part revision.
     activate_flag  int			I   Activation indicator.

Sample Invocation:

     int   return_status;
     char  *catalog;
     char  *partid;
     char  *revision;
     int   activate;

     pdm$copy_files(
                 status = &return_status,
		 catalog_name	= catalog,
		 partid		= part,
		 revision	= rev,
		 activate_flag	= activate
               );

Return Status:

	User must exter a catalog
	User must exter a part
	User must exter a revision
	Catalog does not exist
        Part does not exist
	Revision does not exist
	File does not exist
	Part Must Be Checked In
        Command Cancelled
        Successful Completion

******************************************************************************/
#omdef pdm$copy_files(status,
				catalog_name,
				partid,
				revision,
				activate_flag);

	PDUppl_copy_files(status,
				catalog_name,
				partid,
				revision,
				activate_flag);

#endomdef

