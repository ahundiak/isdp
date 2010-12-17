Copyright 1993 Intergraph Corporation
All Rights Reserved

Including software, file formats, and audio-visual displays;
may only be used pursuant to applicable software license agreement;
contains confidential and proprietary information of Intergraph
and/or third parties which is protected by copyright and trade
secret law and may not be provided or otherwise made available
without proper authorization.

RESTRICTED RIGHTS LEGENDS

Use, duplication, or disclosure by the U.S. Government is subject to
restrictions as set forth in subparagraph (c) (1) (ii) of The Rights
in Technical Data and Computer Software clause at DFARS 252.227-7013
or subparagraphs (c) (1) and (2) of Commercial Computer Software --
Restricted Rights at 48 CFR 52.227-19, as applicable.

Unpublished -- rights reserved under the Copyright Laws of the
United States.

Intergraph Corporation
Huntsville, Alabama   35894-0001

-------------------
Version Information
---------------------------------------------------------------------------
Product:      I_NFMUI                                  I/NFM User Interface
Version:      03.04.00.14
Date:         09-OCT-1993

Description:  I/NFM User Interface provides a graphical user interface into
              an I/NFM system. It provides the end user with the ability to
              query the I/NFM database, locate files, add data and files to
              the system, check files in or out, copy files, transition files 
              through a workflow and flag files for administrative functions.

---------------------------------------------------------------------------
End of Version Information
--------------------------

-----------------
Installation Help
-----------------

     ALL NUCLEUS SOFTWARE (ISS 7.x) MUST BE INSTALLED BEFORE I/NFM IS 
     INSTALLED, OTHERWISE, I/NFM WILL BEHAVE IN AN UNPREDICTABLE MANNER.
     THIS VERSION OF I/NFM IS DEPENDENT ON RIS 4.3 OR LATER.

     I_NFMUI is delivered to /usrx/ip32/nfm/i_nfmui. This is where you will
     find the README and the remove script. All executables, config files,
     etc. are delivered to /usrx/ip32/nfm. A a symbolic link is made to 
     /usr/ip32/nfm.

     If the network protocol to be used by I/NFM is TCP/IP, TCP/IP must
     be downloaded prior to the I/NFM Fileserver and Daemon software.

     If RIS does not exist on the machine where the I/NFM server software 
     is being downloaded, a warning will be printed during the newprod 
     session. 

     The I/NFM installation procedure will prompt the user (Y/N)
     for the desired I/NFM components.

     The I/NFM User Interface software can operate in one of two modes.
     The combined client/server images have the NFMserver software
     integrated with the client interface software giving the ability
     to operate as a dedicated I/NFM server. The traditional client
     software communicates remotely with an NFMserver process.

     NOTE: The combined client/server mode of operation is recommended if 
           you will have 15 or more users accessing I/NFM simultaneously.

     Install I/NFM Combined Client-Server Architecture software (y/n/h) ?
     If "NO",
     Install I/NFM Traditional Client software (y/n/h) ?

     The I/NFM Graphic Interface is available built on I/Forms or I/XForms.

     Install I/NFM I/Forms software (y/n/h) ?
     Install I/NFM I/XForms software (y/n/h) ?

     Install I/NFM Alphanumeric software (y/n/h) ?
     Install I/NFM Command Line User Interface (y/n/h) ?
       - This is a UNIX command line interface to I/NFM.

     The I/NFM Workflow Interface is available built on I/Forms or I/XForms.
       - This is a forms-based utility to create and modify user-defined
         workflows.

     Install I/NFM I/Forms Workflow Interface software (y/n/h) ?
     Install I/NFM I/XForms Workflow Interface software (y/n/h) ?

     Install I/NFM Bulkloader (y/n/h) ?

       - This software allows you to enter large amounts of data into
         the system quickly.

     If you are downloading combined client/server architecture,

     Install I/NFM Administrator Utility (y/n/h) ?
       - This is a utility to perform various reports and system
         maintainence tasks.

     If you are downloading a forms UI,

     Install I/NFM Help for the forms interface (y/n/h) ?
       - If the help files are chosen for download, users of the I/NFM
         forms interface will have access to the runtime help facility.  
         Help can be viewed in the forms interface by depressing the 
         "Help" icon.

     If no other software has been requested,

     Install I/NFM File Server and Utility Software (y/n/h) ?
       - This prompt is only issued if no other options have been selected.
         The I/NFM Utilities software is always downloaded automatically
         with each of the other options.  The utilities software is
         comprised of the I/NFM Fileserver and NFMdaemon.  This software
         must reside on all machines that will communicate with I/NFM. The 
         NFMdaemon process will be started during installation of I/NFM
         and subsequent reboots.


     USER PARTITIONS
     To download the I/NFM software to a partition other than /usr, the
     -b option may be specified on the newprod command line.  For example,

             newprod -n deliver.ip32 -b/usr2

     You may also change the destination file system while in newprod.
     If you download software to a partition other than /usr, it is
     important that the /usr/ip32/nfm directory does not exist prior to
     installation.


     UPDATE UTILITY - 
     If your current version of I/NFM is 3.0 or 3.1., an update utility
     will automatically be run for you during installation. This utility 
     will add the new commands to your existing workflow and will add the 
     pre-defined search criterias if they do not exist.

------------------------
End of Installation Help
------------------------

---------------
Getting Started
---------------

     Please consult the I/NFM Reference Manual for the I/NFM
     initialization procedures.  Please read the documentation files
     accompanying this delivery in /usr/ip32/nfm/doc.

----------------------
End of Getting Started
----------------------

-------------
Documentation
-------------

For current information on product documentation, please see the Intergraph
Document List (IDL). This online information source lists and describes the
available documents that support Intergraph application and system software
products. The IDL is delivered free with the Intergraph Systems Software (ISS)
Supplemental Baseline product set.

To get a copy of the current IDL, use the newprod software delivery utility to
deliver ST**008 IDL from the ISS Supplemental Baseline to your workstation or
server. The IDL files are delivered to /usr/ip32/idl.

Instructions on using the menu-driven IDL interface are available in the 
README and idl.doc files located in /usr/ip32/idl.

For information on Intergraph documentation and Intergraph document delivery
policies, use a World Wide Web browser to connect to Intergraph online at
http://www.intergraph.com, and follow the links to Customer Services.

--------------------
End of Documentation
--------------------

--------
Training
--------

The I/NFM User training course number is TIME1300.
The I/NFM Administrator training course number is TIME2301.
NFM training classes are scheduled for the third week of the second month
in each quarter of 1996.

---------------
End of Training
---------------

----------------
Product Sections
----------------

Restrictions
Online Reference Manual
New Features

-----------------------
End of Product Sections
-----------------------

------------
Restrictions
------------

I/NFM requires your RIS schema file name to be 'risschema'. This has been
the default schema file name for RIS until RIS 4.0. With RIS 4.0 or later, 
the default schema file name is 'schemas'. Any existing schemas will remain
as is with the schema file name 'risschema'. However, any NEW schemas that
are created may have the name of 'schemas'. To then be able to access this 
schema remotely, you may have to change the schema file name via 'rismgr'
(old 'risschema_mgr').

Currently, there is no Nfmutil client executable delivered to operate in
a "Combined Client Only" mode. The Nfmutil image must interface with an 
NFMserver image somewhere on the network. If you have set up your site to 
operate in a "combined only" mode, you must download the NFMserver image 
to some machine on the network. You must also create a server node file 
via the Nfmadmin utility to broadcast the information needed to connect 
to the new server node.

There are two catalog attributes that have been defined for certain Looking
Glass applications. These are n_iconname (Looking Glass Icon Name) and
n_lgfiletype (Looking Glass File Type). They are of no use to I/NFM unless
you are using the AECSHELL/ADM to NFM Bridge. If you are not using the
AECSHELL/ADM to NFM Bridge, you may create (or change) your catalogs 
with these attributes set to NO for read, write, update, and delete.

Making the n_itemrev ("Item Revision") attribute not readable, writable,
or updateable can cause problems. It will not appear in any item listings 
and therefore cannot be manipulated.

Initializing a second environment on an Oracle database:

  *** There must be a valid CLIX account for each Oracle user (I/NFM
      environment.

  Initializing I/NFM is slightly different for each relational database.
  When I/NFM is initialized on an ORACLE database, you must first enter
  the ORACLE database and add the I/NFM admin user.

     grant dba, connect, resource to <user> identified by <password>

  During the Nfminit execution, I/NFM asks the user for "Environment
  Username" and "Env User Password". These values must be <user> and
  <password> from the above "grant" statement and a user can only own 
  ONE schema. There can only be ONE site ID (database) per 'instance'
  of ORACLE. This <user> and <password> information is stored in a
  nfme_<environment> file in an encrypted format.

  The FIRST environment initialized will use the 'nfmadmin' user. The 
  'nfmadmin' system account is required.

  To initialize a SECOND environment, you must use a DIFFERENT 
  environment username/password. This information is also stored in a
  new nfme_<environment> file. This must also be a valid CLIX account.

  When accessing this environment remotely, I/NFM reads the 
  nfme_<environment> file to find the information necessary to do a
  "locate schema". The environment username/password must be a valid 
  system account.

      COMMAND LINE INTERFACE
      Item names and revisions that contain a space are not
      supported.

      DELETE COPIED FILES      
      This command in the combined I/Forms interface will allow the
      list of local files to remain active after successful 
      execution.  Can attempt the delete again without error.

      DISPLAY LIST OF ITEMS IN CATALOG
      This command will not support catalogs with more than 60
      user-defined attributes.

      DISPLAY LIST OF WORKFLOWS
      This command must be invoked before newly added workflows will
      appear on the workflow popup list. TR filed.

      FLAG PROJECT FILES FOR BACKUP/ARCHIVE
      This command will not fail gracefully if the project has no
      items. TR filed.

      FLAGGING
      Flagging an item that has no files checked in can cause
      unpredictable results.

      LOAD WORKFLOW - WORKFLOW INTERFACE
      Loading the signoff workflow returns the message "unknown
      command" but loads the workflow successfully. TR filed.

      LOCAL FILE MANAGER
      If user removes local files at the CLIX level, this update is
      not reflected in the list of local files in the database. 
      Using the "Delete Copied Files" command corrects the listing,
      but returns an error. TR filed on error message.

      REVIEW ITEM ATTRIBUTES
      This command will not support catalogs with more than 30
      user-defined attributes.

      UTILITIES - SYSTEM GENERATED LABELS - I/FORMS INTERFACE
      When processing an archive or backup request, not selecting a
      label will cause the system to generate one for the user. 

      PLOT ITEM - LIST PROCESSING. WHEN PLOTTING 2 OR MORE ITEMS FROM A 
      list the first item selected is successful, all others return 
      MEM_E_EXTRA_DATA. You cannot use list processing to plot items.
      TR filed.

      WORKFLOW INTERFACE - CHANGING THE NAME OF A CLASS
      If you attempt to change the name of a class, the error "The 
      specified class does not exist" is returned. TR filed.

      DELETE PROJECT MAPPINGS - Delete Project ACL Mapping fails with 
      "Item is owned by this project that follows the mapping being 
      deleted" even though there is no item following the ACL in the 
      project. Items are in the catalog that follow the ACL, but they 
      have been removed from the project. Delete Project SA Mapping also 
      fails if an item is in the catalog with the internal location, 
      even though the item does not belong to the project. TR filed.

      VAX FILENAMES - When naming internal storage files if the internal 
      storage area is a VAX, you need to specify an extension for filename 
      uniqueness.

      VAX STORAGE AREAS - When using VAX storage areas, you must use the
      full directory specificaton. You cannot use logicals.

      COPY ITEM - Copy Item did not properly set the n_fileco in releases
      prior to NFM 3.2 (3.0 or 3.1). If "Copy Item Files" fails on an item
      that was created through "Copy Item", the user should check to see if 
      the n_fileco attribute is set to NULL eventhough a file is associated
      with the item. If so, the user should call support. TR filed.

      ALL NON-CLIX STORAGE AREAS - File transfers to any non-CLIX
      node use 'ftp' and therefore the destination storage area must have
      password defined for it.

      FLAG FOR RESTORE - ALPHA INTERFACE -
      The Flag for Restore command is NOT list driven in the alpha 
      interface. TR filed.

      ALPHA INTERFACE - PROMOTING ITEMS TO A SET
      If an item is active but no set is active, the "add items to set" 
      command adds members to the active item. However, if a set is active,
      the "add items to set command" adds members to the active set. The only
      way to add members to the item is to go to "activate" and clear out 
      the set. 

      ADD MEMBERS TO SET - BOTH INTERFACES
      No more than 20 items should be added to a set at one time.  User can
      exit the command and re-enter it to add additional set members. 

      'ITEM NAME' FIELD ON BULKLOADER SHOULD BE READ ONLY.  SINCE IT IS
      currently writable, users can change the itemnames.  Since the item-
      name is also the local filename, changing the itemname makes the
      checkin fail.  Field needs to be changed to read only so users cannot
      try to change itemnames. TR filed.

      

-------------------
End of Restrictions
-------------------

-----------------------
Online Reference Manual
-----------------------

      I/NFM is delivered with a "doc" directory that contains
      several files that may be used as an on-line reference manual.

      access 
         How to access and use I/NFM through the various interfaces.

      admin
         How to use the I/NFM Administrator Utility.

      bulkload
         How to use the I/NFM Bulkload Utility.

      cli
         How to use the I/NFM Command Line Interface. This file has had 
         extensive updates for the I/NFM 3.2 software.

      converter
         How to use the I/NFM 2.x to 3.x converter.

      copy_acl_users
         Documentation on the new Copy ACL Users command.

      design
         The functional design document for I/NFM 3.0. 

      pc
         How to use the command line interface on the PC.

      plotting
         How to use the new Plot commands.

      proc_on_trans
         How to use the process on transition capabilities.

      schema
         The I/NFM 3.0 schema

      setup
         How to set up I/NFM.

     workflow
         A document on how to understand workflows and changes between I/NFM
         2.x and 3.x workflows.

     workflow_ui
         A document on how to understand and use the workflow interface. 

     wf_train.txt
         This is a training exercise in using the workflow interface.

     NFMtrain.32
         A workflow ascii file that can be loaded to use with the wf_train.txt
         document.

 
    The following files have been updated:

      File:
          /usr/ip32/nfm/doc/NFMtrain.32
      Replaces:
          /usr/ip32/nfm/doc/NFMtrain.txt
      File:
          /usr/ip32/nfm/config/workflow/NFMexample.32
      Replaces:
          /usr/ip32/nfm/config/workflow/NFMexample.30
      File:
          /usr/ip32/nfm/config/workflow/NFMsimple.32
      Replaces:
          /usr/ip32/nfm/config/workflow/NFMsimple.30
      File:
          /usr/ip32/nfm/config/workflow/NFMsignoff.32
      Replaces:
          /usr/ip32/nfm/config/workflow/NFMsignoff.30

    
------------------------------
End of Online Reference Manual
------------------------------

------------
New Features
------------

  I/NFM 3.2

      RESTORING FROM TAPE
      Restore operations from tape can now be completed without
      bringing the entire cpio saveset from the tape on archives
      performed using the I/NFM 3.2 software (old archives will
      still be restored using the old method).  This feature will
      result in less disk space being required for restore operations.

      NONCOMMAND PROCESS ON TRANSITION
      The transitions (Approve Item, Reject Item, etc.) invoked due 
      to proper invocation of the "Make Transition" command can now 
      cause a user-defined process to be executed.

      ADD ITEM CAPABILITY IN CLI
      Users can now add items from the Command Line Interface. For
      details and additional new features in the CLI, see the 
      /usr/ip32/nfm/doc/cli document.

      C4 NATIVE IMAGES
      All C4 designated images in this release are compiled C4 native
      to maximize the performance of I/NFM on the C400 platform.

  I/NFM 3.1

      SEARCH CRITERIA
      Four predefined public search criteria are now delivered with I/NFM.
      The "Checked_in" search criteria will display a list of all checked
      in items.  The "Checked_out" search criteria will display a list of
      all checked out items.  The "No_set" search criteria will display a
      list of only non-set items. And the "Sets_only" search criteria
      will display a list of set items only.

      DEFINE SEARCH CRITERIA - FORMS INTERFACE
      The ability to check and process a search criteria before the define
      search criteria interface form is dismissed has been added.

      FLAG SET FOR RESTORE
      When flagging a set for restore, only the primary members
      are flagged for restore.  Secondary set members must be flagged
      individually. 

      UTILITIES
      Several subtle enhancements have been made to the utilities
      software in order to make it more reliable, stable, and easy to
      use.

      WORKFLOW INTERFACE
      Users can now change attribute values of workflows, states,
      and transitions in the workflow interface.  For workflows, the 
      "Description" attribute may be change.  For states, the "State 
      Name", "Description", "Transfer from State Value", "Transfer to 
      State Value", "Number of Signoffs", "Signoff Type", and "Sequence 
      Number" may be modified. For Transitions, the "Transition Name", 
      "From State", "To State", "Log On Success", "Log On Failure", and
      "Notify".

      CHANGE ITEM
      CHANGE FILE ATTRIBUTES
      Users are now allowed to change the internal storage area of an
      item while the item is archived.  This will allow users to
      restore an archive after the original internal storage area has
      been eliminated.

      DELETE SAVESET ENTRIES
      Users are now allowed to delete saveset entries for files that
      have been backed up.
 
      FORMS INTERFACE - COLLAPSE ICON
      The administrator and user main forms in the I/Forms interface
      has been equipped with a "collapse" icon.  When selected, all
      I/NFM menus, forms, and displays are collapsed into a single
      icon.  Selecting the collapsed icon will "uncollapse" the forms
      and menus. 
 
      SEARCH ACROSS CATALOGS - ALPHANUMERIC INTERFACE
      The ability to create a list of items from multiple catalogs has
      now been added to the alphanumeric interface.

      LIST DRIVEN COMMANDS - ALPHANUMERIC INTERFACE
      The alphanumeric interface has been equipped with the ability to
      perform list driven operations.

      REVIEW/CHANGE ENVIRONMENT - ALPHANUMERIC INTERFACE
      The "Review/Change Environment" command has been added to the 
      alphanumeric interface.  This command allows the user to review
      the active operating environment and change it.

  I/NFM 3.0

      NEW NETWORK PROTOCOL
      I/NFM uses the Transport Layer Interface (TLI) for all network 
      activity.  This new protocol does not require the use of passwords 
      for file transfer.  Security of the system is maintained by the 
      operating system and I/NFM.

      WORKFLOW INTERFACE
      The "Nfmwff" (Workflow Interface) is an I/Forms based server image.
      This executable is used to Define/Modify/Delete user defined Item
      workflows.

      NFMDAEMON and NFMFILESERVER
      The NFMdaemon is used to communicate data transfer between the I/NFM
      client and the I/NFM server.  It is also used to communicate data
      transfers between the I/NFM fileservers.

      COMMAND LINE INTERFACE
      The I/NFM command line interface (CLI) software allows users to
      process commands in a batch environment.  It will only recognize
      a specific subset of I/NFM commands. 
      For more information refer to the cli document file in 
      /usr/ip32/nfm/doc.

      The UNIX CLI image is called "Nfmcli"; the PC CLI image is called
      "nfmpc.exe".  Anyone wishing to use the PC CLI must send the 
      PCserver executable (delivered with the server) to the PC using
      FTP.  The PCserver is a binary executable and it must be sent in
      the binary mode via FTP.     
      The CLI executables are delivered with the interfaces.
      The PCserver is delivered with the server and the combined
      client/server.

      To install nfmpc, type the following from C:\>

          ninstall -h<pc nodename> -p<pathname>

      The directory structure is created for you and the appropriate
      files are placed.

      To invoke the UNIX CLI keyin the following :
         /usr/ip32/nfm/bin/Nfmcli -f <command_file> [options] 

      To invoke the PC CLI keyin the following :

         nfmpc -f <command_file> [options] 

            or for interactive mode,

         nfmpc

      Changes for NFM 3.2

      LOGIN PERFORMANCE
      Several enhancements have been made to the I/NFM server and
      client software to reduce the length of login time for I/NFM.

      LIST OF CATALOGS ON CROSS REFERENCE LISTING
      The "Display Cross Reference Listing" command in the Nfmadmin
      utility will now prompt for a list of catalogs on which to
      generate the report.

      BLOCK LISTINGS
      All listings will now return data according to a blocking factor
      defined for each site.  This blocking factor gives users the
      ability to see data immediately when requesting a display that
      may take several minutes to manually scan.  To configure block
      listings, execute "DisplayRows" under the "Configure" option from
      the Nfmadmin utility.

      DEFAULT WORKFLOW
      When a user logs into I/NFM, the default working area  will be blank
      if the user's current directory is entered into I/NFM as a 
      working area belonging to another user or if the directory is
      entered as another type of storage area besides a working area.

      ADD ACL SIGNOFF USERS WITH OVERRIDE
      The I/Forms interface now supports the ability to give override
      privileges when establishing signoff users.

      WORKFLOW INTERFACE - MODIFY WORKFLOW 
      States are automatically resequenced if a new state is added
      with a sequence number less than the greatest sequence number.

          Example:

	    state                   sequence number
            -----                   ---------------

            creation complete       2
            design complete         3
            modification complete   4
            released                5
	
          A new state named "release signoff" is added with a sequence 
          number of 5. New sequence numbers are:

            state                   sequence number
            -----                   ---------------

            creation complete       2
            design complete         3
            modification complete   4
            release signoff         5
            released                6


      New commands for NFM 3.2


      PLOT ITEM
      PLOT SET
      These commands will allow users to generate a plot for item files
      that are not local to the user and have a pre-defined IPARM
      file. For more information about plotting, see the "plotting" file
      in /usr/ip32/nfm/doc.

      COPY ACL USERS
      This command allows users to copy the user-to-class mapping of
      an existing ACL to a new ACL.  It is not necesssary that the
      ACL's belong to the same workflow.  All duplicate classes will be
      resolved. For more information about copying ACL users, see the 
      "copy_acl_users" file in /usr/ip32/nfm/doc.

      SAVE ITEM FILE(S)
      SAVE SET FILE(S)
      This command allows a user to post modifications to the
      permanent storage area for a file that is checked out while
      retaining the checked out status.  The effect is the same as
      performing a check in and an immediate check out.

      DUMP WORKFLOW
      This command in the Workflow Interface allows a user to produce
      an ascii file from an item workflow.

-------------------
End of New Features
-------------------

---------
New Fixes
---------

----------------
End of New Fixes
----------------

-------------
Open Problems
-------------

--------------------
End of Open Problems
--------------------
