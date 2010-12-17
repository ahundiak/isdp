/*******************************************************************************
PDMfile_mac.h

General Description:

    This file contains macros needed to transfer files.

Macros provided:

    File Movement:

    o pdm$checkin_part()    - check in a part to a specific storage area
    o pdm$checkout_part()   - check out a part and bring it to the current
                              working area
    o pdm$copy_files()      - copy files to the current working area (files
                              will be read-only)

History:

     09/01/92   Mychelle Joiner     Creation Date

*******************************************************************************/


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

Include files:

     PDUerror.h
     PDUfile_mac.h

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

Include files:

     PDUerror.h
     PDUfile_mac.h

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

Include files:

     PDUerror.h
     PDUfile_mac.h

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

