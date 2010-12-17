
Copyright 1995 Intergraph Corporation
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
Version:      03.05.02.29
Date:         13-MAR-1996

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

     ALL NUCLEUS SOFTWARE (Sun Intel-Solaris 2.4) MUST BE INSTALLED
     BEFORE I/NFM IS INSTALLED, OTHERWISE, I/NFM WILL BEHAVE IN AN
     UNPREDICTABLE MANNER.  THIS VERSION OF I/NFM IS DEPENDENT ON
     RIS 5.2 OR LATER.
 

     I_NFMUI is delivered to /usrx/ip32/nfm/i_nfmui. This is where you will
     find the README and the remove script. All executables, config files,
     etc. are delivered to /usrx/ip32/nfm. A a symbolic link is made to 
     /usr/ip32/nfm.

     If the network protocol to be used by I/NFM is TCP/IP, TCP/IP must
     be downloaded prior to the NFMfileserver and NFMdaemon software.

     On all non-CLIX platforms, the network protocol is always TCP/IP.

     If RIS does not exist on the machine where the I/NFM server software 
     is being downloaded, a warning will be printed during the newprod 
     session.

     RIS is not required for I_NFMUI. 


                          Newprod Procedures
                          __________________

     The I/NFM installation procedure will prompt the user (Y/N)
     for the desired I/NFM components.

     The I/NFM User Interface software can operate in one of two modes.
     The combined client/server images have the NFMserver software
     integrated with the client interface software giving the ability
     to operate as a dedicated I/NFM server. The traditional client
     software can communicate remotely with an NFMserver process.

     NOTE: The combined client/server mode of operation is recommended if 
           you will have 15 or more users accessing I/NFM simultaneously.


                      Traditional Client Newprod Prompts
                      __________________________________

Install I/NFM Combined Client-Server Architecture software (y/n/h) ?

     If "NO",

Install I/NFM Traditional Client software (y/n/h) ?

     The I/NFM Graphic Interface is built on I/XForms.

Install I/NFM I/XForms software (y/n/h) ?

Install I/NFM Alphanumeric software (y/n/h) ?

Install I/NFM Command Line User Interface (y/n/h) ?

       - This is a UNIX command line interface to I/NFM.

     The I/NFM Workflow Interface is built on I/XForms.

Install I/NFM I/XForms Workflow Interface software (y/n/h) ?

       - This is a forms-based utility to create and modify user-defined
         workflows.

Install I/NFM Bulk Loader (y/n/h) ?

       - This software allows you to enter large amounts of data into
         the system quickly.

Install BLU Bulk Loader (y/n/h) ?

       - This software provides a CLI to a flexible bulkloader developed
         for the DMANDS software.


                      Combined-Client Newprod Prompts
                      _______________________________

     If you are downloading combined client/server architecture,

Install I/NFM I/XForms Combined Client-Server software (y/n/h) ? [y]:

Install I/NFM Alphanumeric Combined Client-Server software (y/n/h) ? [y]:

Install I/NFM Command Line User Interface (y/n/h) ? [y]:

Install I/NFM I/XForms Workflow Interface software (y/n/h) ? [y]:

Install I/NFM Bulk Loader (y/n/h) ? [y]:

Install BLU Bulk Loader (y/n/h) ? [y]:

Install I/NFM Administrator Utility (y/n/h) ?

       - This is a utility to perform various reports and system
         maintenance tasks.


                      No Interface Newprod Prompts
                      ____________________________


     If no other software has been requested,

Install I/NFM File Server and Utility Software (y/n/h) ?

       - This prompt is only issued if no other options have been selected.
         The I/NFM Utilities software is always downloaded automatically
         with each of the other options.  The utilities software is
         comprised of the NFMfileserver and NFMdaemon.  This software
         must reside on all machines that will communicate with I/NFM. The 
         NFMdaemon process will be started during installation of I/NFM
         and subsequent reboots.


                              USER PARTITIONS
                              _______________

     To download the I/NFM software to a partition other than /usr, the
     -b option may be specified on the newprod command line.  For example,

             newprod -n deliver.ip32 -b/usr2

     You may also change the destination file system while in newprod.
     If you download software to a partition other than /usr, it is
     important that the /usr/ip32/nfm directory does not exist prior to
     installation.


                              UPDATE UTILITY
                              ______________

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

     Please consult the I/NFM Administration Guide for the I/NFM
     initialization procedures.  Please read the documentation files
     accompanying this delivery in /usr/ip32/nfm/doc, for additional
     information.

----------------------
End of Getting Started
----------------------

-------------
Documentation
-------------

For current information on Intergraph documentation and Intergraph 
document delivery policies, use a World Wide Web browser to connect to 
Intergraph online at http://www.intergraph.com, and follow the links to 
Customer Services.

--------------------
End of Documentation
--------------------

--------
Training
--------

The I/NFM User training course number is TIME1300.
The I/NFM Administrator training course number is TIME2301.
The I/NFM training classes are scheduled for the third week of the second month 
in each quarter for 1996.  To register for a class, call 1-800-240-3000 or 
1-205-730-6700.

---------------
End of Training
---------------

----------------
Product Sections
----------------

Security
Version Compatibility
Customer Support
Restrictions
On-Line Reference Manual
New Features
System Administrator Functions
New Fixes
Open Problems

-----------------------
End of Product Sections
-----------------------

--------
Security
--------
 
Not applicable.

---------------
End of Security
----------------
 
---------------------
Version Compatibility
---------------------

I/NFM User Interface 03.05.02.29 (Intel-Solaris only)
    o Compatible with I/NFM Server 03.05.02.29.

I/NFM User Interface 03.05.02.18 (CLIX, SCO-UNIX & Sun Solaris only)
    o Compatible with I/NFM Server 03.05.02.18.

----------------------------
End of Version Compatibility
----------------------------

----------------
Customer Support
----------------
 
Customer Support is initiated by logging software problems or change
request through Intergraph's Customer Support Center. The toll-free
number is 1-800-633-7248.
 
You will be required to provide your Site ID, the software product in
question, and a brief description of the problem. This information is
placed in a customer worksheet database, and transferred via electronic
mail to the responsible software support analyst.
 
Experience has shown that problem resolution is facilitated if the
customer has the following information (if applicable) at hand when
first contacting the software support analyst.
 
    1.  SOFTWARE CONFIGURATION
            a.  Application software version. This is obtained
                    by keying in 'dates' at the CLIX prompt.
            b.  Layered products software versions. These are obtained
                    by keying in 'dates' at the CLIX prompt.
            c.  Nucleus software versions. These are obtained
                    by keying in 'dates' at the CLIX prompt.
            d.  Has the system/nucleus software configuration changed
                    recently?
    2.  HARDWARE CONFIGURATION
            a.  CPU type - for CLIX nodes, keyin inqcpuid
            b.  Memory - for CLIX nodes, keyin inqmemory
            c.  Disk storage - for CLIX nodes, keyin Free
            d.  Has the system hardware configuration changed
                    recently?
    3.  PROBLEM SPECIFICS
            a.  Does the problem occur:
              - in a specific part of the product?
               - for more than one username?
               - for the administrative username?
               - on a workstation or a PC?
               - on more than one workstation?
               - on more than one PC?
               - in different sessions?
               - in a specific I/NFM environment?
               - in a specific I/NFM catalog?
               - in a specific I/NFM item of file?
               - with a specific file format or type?
            b. Is the problem reproducible?
 
-----------------------
End of Customer Support
-----------------------
 
------------
Restrictions
------------

RIS VERSION:
    This version of I/NFM on Intel-Solaris is developed/tested on
    RIS 5.2 or later.

SCHEMA FILE:
I/NFM requires your RIS schema file name to be 'risschema'. This has been
the default schema file name for RIS until RIS 4.0. With RIS 4.0 or later, 
the default schema file name is 'schemas'. Any existing schemas will remain
as is with the schema file name 'risschema'. However, any NEW schemas that
are created may have the name of 'schemas'. To then be able to access this 
schema remotely, you may have to change the schema file name via 'rismgr'
(old 'risschema_mgr').

NFMINIT ON INTEL-SOLARIS: 
In the Nfminit procedure when initializing an INFORMIX 7.1 database on 
Intel-Solaris 2.4.  The format for entering data in the dbpath field on 
screen four has changed from using only the dbname to using dbname@dbserver.
If only the dbname is used the user will receive the error "Underlying DBMS 
could not open database."
 
NFMADMIN:
    Login to environments using command line arguments is not
    supported in Nfmadmin.

NFMUTIL:
Currently, there is no Nfmutil client executable delivered to operate in
a "Combined Client Only" mode. The Nfmutil image must interface with an 
NFMserver image somewhere on the network. If you have set up your site to 
operate in a "combined only" mode, you must download the NFMserver image 
to some machine on the network. You must also create a server node file 
via the Nfmadmin utility to broadcast the information needed to connect 
to the new server node.

LOOKING GLASS:
There are two catalog attributes that have been defined for certain Looking
Glass applications. These are n_iconname (Looking Glass Icon Name) and
n_lgfiletype (Looking Glass File Type). They are of no use to I/NFM unless
you are using the AECSHELL/ADM to I/NFM Bridge. If you are not using the
AECSHELL/ADM to I/NFM Bridge, you may create (or change) your catalogs 
with these attributes set to NO for read, write, update, and delete.

ITEM REVISION:
    Making the n_itemrev ("Item Revision") attribute not readable, not
    writable, or not updatable can cause problems. It will not appear in
    any item listings and therefore cannot be manipulated.

NEWPROD:
When newprodding I/NFM to an Intel-Solaris platform, if the user uses
the f command to change file systems, the Deltools Newprod command is
sometimes picking up some bogus information and displaying it with the
prompt for changing file systems.  A sample of the problem follows:
Key in the directory name (currently "/opt/ingr") [VB]: Hello World!
The user must delete the errant entry and type in a valid file system
name. This is a bug with DELTOOLS and a TR #289600011 has been filed
with DELTOOLS.
 
XFORMS MENU DISPLAY:
Using Nfmfix, the user may encounter an XFORMSRT problem where the
menubar and menupanel display smaller and skewed to the left.  The
text on the menubar and menupanel are barely readable and resizing
the menus has no discernible affect.  A TR # 249600041 has been logged 
with the XFORMSRT product and a simple effective workaround is available.  
To alleviate the symptoms, the user must remove the menu_locations file
that I/NFM creates in the users HOME directory.  This file is created
by the application and contains the x and y coordinates for the menu-
bar and menupanel.
 
XFORMS USER INTERFACE:
    If the size of an XWindow is changed with the button in the upper
    right corner, the window changes, but the resident XFORM, such as,
    Review of Item, stays the same size. A TR # 249600702 has been filed
    againt XFORMSRT.
 
XDISPLAY ONTO CLIX MACHINES:
    Exporting X display onto a CLIX box and running Nfmfix may sometimes
    give fatal errors if XWINDOW is not configured properly during
    newprod. This can be resolved by downloading the XWINDOW product
    again with the following options:

    Speedo=no
    pcfMisc=yes
    pcf75dpi=yes
    pcf100dpi=yes
    AsianMisc=no

REMOVING THE PRODUCT THROUGH DELTOOLS:
    Whenever a product is deleted through the DELTOOLS/remove utility,
    the user is prompted to remove the product directory.  If the user
    responds Yes to the prompt, then both the product directory and the
    product entry in the /usr/ip32/ingrconfig file are deleted, so that
    the dates command won't display the product name.

    If the user responds No the the prompt, neither step is performed.

    In the case of I/NFM where multiple products reside in the same
    product directory and executables are common to both products,
    if the user responds No to the prompt in order to retain the product
    directory, the product entry in the ingrconfig file is not deleted.
    This will cause the dates command to still show the product and is
    considered a limitation of DELTOOLS."

CREATE CATALOG:
    While creating Catalogs the Attribute field and the Synonym fields
    can accept only 24 chars after which they get truncated. For Data Type
    the maximum length of character data is char(INT_MAX) which is the
    maximum value the underlying Operating System supports.  For ex.,
    currently under CLIX it is char(2147483647)

    Two users cannot create a catalog at the same time.

WORKFLOW INTERFACE - SCREEN DISPLAY
    On Intel-Solaris the Sizes of BAR/PANEL menus are sometimes big and 
    may overlap on each other. The workaround is to copy the file 
    menu_locations from $INGRHOME/nfm/config/english/menus/workflow
    directory to user's home directory. 

ADD ITEMS TO PROJECT:
    While trying to add two or more Items to a Project at the same time,
    with one of the items being locked, it is not possible to add any of
    the items.

SECOND ORACLE INSTANCE:
Initializing a second environment on an Oracle database:

  *** There must be a separate, valid CLIX account for each Oracle
      user (I/NFM environment).

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

COMMAND LINE INTERFACE:
  Item names and revisions that contain a space are not
  supported.

DELETE COPIED FILES:
  This command in the combined I/Forms interface will allow the
  list of local files to remain active after successful
  execution.  The delete operation can be attempted again without
  error.

DISPLAY LIST OF ITEMS IN CATALOG:
  This command will not support catalogs with more than 60
  user-defined attributes.

DISPLAY LIST OF WORKFLOWS:
  This command must be invoked before newly added workflows will
  appear on the workflow popup list. TR filed.

FLAG PROJECT FILES FOR BACKUP/ARCHIVE:
  This command will not fail gracefully if the project has no
  items. TR filed.

FLAGGING:
  Flagging an item that has no files checked in can cause
  unpredictable results.

LOAD WORKFLOW - WORKFLOW INTERFACE:
  Loading the signoff workflow returns the message "unknown
  command" but loads the workflow successfully. TR filed.

LOCAL FILE MANAGER:
  If user removes local files at the CLIX level, this update is
  not reflected in the list of local files in the database. 
  Using the "Delete Copied Files" command corrects the listing,
  but returns an error. TR filed on error message.

REVIEW ITEM ATTRIBUTES:
  This command will not support catalogs with more than 30
  user-defined attributes.

UTILITIES - SYSTEM GENERATED LABELS - I/XFORMS INTERFACE:
  When processing an archive or backup request, not selecting a
  label will cause the system to generate one for the user. 

STORAGE AREA NAMES:
  For the storage areas being added on external/peripheral devices, then
  the pathname must be the full path of device name ( as specified in 
  the /dev directory). This is because the device names may differ for
  each Operating System. 

  If you are an existing CLIX I/NFM user and have device storage areas 
  setup on CLIX machines you need to make the following changes, in order 
  to complete successful backups.
 
	. When you do archive/backup/restore of items of non-CLIX environments, 
	  to a storage area on a peripheral device attached to a CLIX node,
	  then, give the full path of device name.
	. For all storage areas created in non-CLIX environments, give full
	  path for storage areas on peripheral devices, irrespective of whether
	  the device is connected to a CLIX/non-CLIX node.

  If you are using I/NFM in a non-CLIX environment, but have
  storage areas set up on CLIX machines, you need to make
  sure the Operating System Type for these nodes is CLIX and
  not UNIX.  The attribute is n_opsys in the nfmnodes table.
  If the attribute is set to CLIX, the NFMserver will be able
  to interpret mt6 as /dev/rmt/mt6 without operator intervention.
  If the n_opsys value is not CLIX, then the NFMserver will use
  whatever storage area path is given.  If the full device path
  is not provided, then backups and archives may not be written
  properly (ie: they may get written to a file on the hard drive
  in /usr/ip32/nfm/utilities instead of being written to tape).

PERIPHERAL DEVICE NAMES:
      On CLIX machines, to_flop and fr_flop utilities take care of archiving
      or backing up files on multiple volumes of floppies and the user is not
      required to give the device pathnames for storage areas on floppies. 
      However, because the to_flop and fr_flop do not exist on non-CLIX 
      machines, it is mandatory for the user to use full device path name 
      for storage areas on external devices.

WORKFLOW INTERFACE - CHANGING THE NAME OF A CLASS:
      If you attempt to change the name of a class, the error "The 
      specified class does not exist" is returned. TR filed.

DELETE PROJECT MAPPINGS:
      Delete Project ACL Mapping fails with 
      "Item is owned by this project that follows the mapping being 
      deleted" even though there is no item following the ACL in the 
      project. Items are in the catalog that follow the ACL, but they 
      have been removed from the project. Delete Project SA Mapping also 
      fails if an item is in the catalog with the internal location, 
      even though the item does not belong to the project. TR filed.

VAX FILENAMES:
      When naming internal storage files, if the internal storage area is 
      a VAX, you need to specify an extension for filename uniqueness.

VAX STORAGE AREAS:
      When using VAX storage areas, you must use the full directory 
      specification. You cannot use logicals.

COPY ITEM:
      Copy Item did not properly set the n_fileco in releases prior to 
      I/NFM 3.2. If "Copy Item Files" fails on an item that was created through
      "Copy Item", the user should check to see if the n_fileco attribute is 
      set to NULL even though a file is associated with the item. If so, the 
      user should call support. TR filed.

FILE TRANSFERS:
      All non-CLIX storage areas - File transfers to any non-CLIX
      node use 'ftp' and therefore the destination storage area must
      have a password defined for it.

FLAG FOR RESTORE - ALPHA INTERFACE:
      The Flag for Restore command is NOT list driven in the alpha 
      interface. TR filed.

ALPHA INTERFACE - PROMOTING ITEMS TO A SET:
      If an item is active but no set is active, the "add items to set"
      command adds members to the active item. However, if a set is
      active, the "add items to set command" adds members to the active
      set. The only way to add members to the item is to go to "activate"
      and clear out the set.

ADD MEMBERS TO SET - BOTH INTERFACES:
      No more than 20 items should be added to a set at one time.
      The user can exit the command and re-enter it to add additional
      set members.

ITEM NAME:
      Item Name field on bulkloader should be read only.  Since it is
      currently writable, users can change the itemnames.  Since the item-
      name is also the local filename, changing the itemname makes the
      checkin fail.  The field needs to be changed to read only so users
      cannot try to change itemnames. TR filed.

CATALOG NAMES:
      Catalog names can not be more than 16 characters.  Due to a RIS
      limitation, the maximum length of a RIS table name is limited to
      18 characters.  The I/NFM Create Catalog command also produces a
      file table for each catalog, which contains the catalog name plus
      a prefix of f_.  Thus the RIS limitation combined with the I/NFM
      requirement for a file table, limits the length of a catalog name
      to not more than 16 characters.

      Catalog names should not exceed 13 characters for applications
      such as DM/View, DM/Redline, DMANDS View and DMANDS Redline.
      These applications, which store redlines as files, require file
      tables for the redline catalogs.  This requirement uses up five
      characters of the 18 allowed by RIS for a catalog name.  The
      naming convention is f_CatalogName_rl.

RECORD AND PLAYBACK:
      Record and Playback functions are not available in I/NFM for any
      I/XFORMS Interface.

TCP/IP CONNECTIONS: 
  I/NFM will not connect via TCP/IP to a host when the host's nodename begins
  with a number instead of a letter.  This is due to a TCP/IP restriction.
  The Workaround is to:
           o  Set up an alias for the nodename that starts with a letter
           o  Add alias to the /etc/hosts file
           o  Edit /usr/lib/nodes/owned/nfms_<server> and change nodename to
              the alias
           o  Change nodename of node #1 in nfmnodes table to the alias.
           This will ensure that file transfers use TCP/IP and will enable
           TCP/IP to find the correct node.

DECNET:
  I/NFM currently does not support DECNET even though
  this prompt appears during the I/NFM Initialization.

NETWARE:
  I/NFM currently does not support NETWARE even though
  this prompt appears during the I/NFM Initialization.

NFMBULK OPTION:
  The -P option with Nfmbulk must have the file and options appended
  without spaces or the command will fail.

CHECKIN/CHECKOUT FILE PERMISSIONS:
  While "Checking in" and "Checking Out" I/NFM expects certain
  permissions for the files and directories.These are as follows:
  o   The file should have "read" permissions for the owner
      ie: r--------
  o   The directory should have "execute" permissions for
      the owner ie: -wx------

NFMCLI-CHECKOUT SET/CANCEL SET CHECKOUT:
  In Nfmcli, sometimes the checkout_set and cancel_checkout_set commands may
  return the error message "Connection with I/NFM server has broken". A
  TR #249505168 is filed to correct this inconsistency.
 
ALPHA INTERFACE KEYS:
  Alpha numeric interface on Intel-Solaris uses ENTER as select key when the
  Nfmalpha was invoked from a CLIX vt100 terminal. For the CLIX terminal
  window the ENTER key should be mapped to <ESC>OM. To do this select
  configure icon of the terminal window, then select macro, select ENTER
  key, enter <ESC>OM and accept the changes to configure.

  On Intel-Solaris Platform F6 is set for Accept Key as an alternative to
  usual F1 key as F1 is by default set to Help. Similarly, F5 is set for
  Selection. The native terminal type is sun-cmd. The key mapping is also
  supported for xterm.

  When using a telnet session from a CLIX-platform to a non-CLIX platform,
  the environment variable TERM should be exported to 'vt100' to make the
  PF1 key to work properly as shown below. 
          TERM=vt100
          export TERM
  The user must also set the CLIX Window Keyboard setting for keypad from
  Numeric to Application. If this is not done, then the PF1 and the Enter
  keys do not map properly.
 
ON-LINE HELP:
  On-Line Help is not available for I/NFM on the Intel-Solaris platform.

I/FTR:
  I/FTR is not available for I/NFM on the Intel-Solaris platform.

PLOTTING:
  Plotting is not available for I/NFM on the Intel-Solaris platform.

-------------------
End of Restrictions
-------------------

-----------------------
On-Line Reference Manual
-----------------------

      I/NFM is delivered with a "doc" directory that contains
      several files that may be used as an On-Line reference manual.
      These files may be found in /usr/ip32/nfm/doc.

      NFMtrain.32
         A workflow ASCII file that can be loaded to use with the
         wf_train.txt document.

      access 
         How to access and use I/NFM through the various interfaces.

      admin
         How to use the I/NFM Administrator Utility.

      bulkload
         How to use the I/NFM Bulkload Utility.

      clh
         Gives information about clearing house.

      cli
         How to use the I/NFM Command Line Interface. This file has had 
         extensive updates for the I/NFM 3.2 software.

      converter
         How to use the I/NFM 2.x to 3.x converter.

      copy_acl_users
         Documentation on the new Copy ACL Users command.

      dbasrv
         A document on how to use the DBASRV

      design
         The functional design document for I/NFM 3.0. 

      impact_of_34
         The Impact Statement document of I/NFM

      pc
         How to use the command line interface on the PC.

      pcnet
         Information about Internal storage Areas of Non-CLIX nodes

      plotting
         How to use the new Plot commands.

      proc_on_trans
         How to use the process on transition capabilities.

      rm_proc_on_trans
         How to dissociate A Process from a transition

      schema
         The I/NFM 3.0 schema

      setup
         How to set up I/NFM.

      wf_train.txt
         This is a training exercise in using the workflow interface.

      workflow
         A document on how to understand workflows and changes between
         I/NFM 2.x and 3.x workflows.

      workflow_ui
         A document on how to understand and use the workflow interface. 

------------------------------
End of On-Line Reference Manual
------------------------------

------------
New Features
------------

I/NFM 3.5

INTEL-SOLARIS PORT:
    I/NFM has been ported to Intel-Solaris version 2.4.

SETS:
    Raster files may be added as primary members to sets.

CLEARINGHOUSE TO INTEL-SOLARIS:
    A new utility, clhtodat, converts I/NFM CLIX clearinghouse
    files in /usr/lib/nodes into the NFMser.dat, NFMenv.dat and
    NFMowne.dat files used by I/NFM on Intel-Solaris platforms.
    These new NFM*.dat files replace the clearinghouse functionality
    provided on CLIX.

INTEL-SOLARIS TO CLEARINGHOUSE:
    A new utility, dattoclh, converts I/NFM Intel-Solaris NFM*.dat
    files (NFMser.dat, NFMenv.dat and NFMowne.dat) into the
    corresponding CLIX clearinghouse /usr/lib/nodes files for
    transport and use on CLIX systems.

SYBASE SUPPORT:
    I/NFM now supports Sybase databases.

INFORMIX 7.1 SUPPORT:
        Here is a brief description on how to a create database using INFORMIX
        On-Line ( version 7.1 ) for I/NFM. For more details, please refer to
        an INFORMIX 7.1  Administrator's Guide.
 
        In the 'nfmadmin' login account,
        . export the INFORMIXDIR environment variable to point to the informix
          user's login directory.
        . export the INFORMIXSERVER environment variable to to On-Line
          DBSERVERNAME (This is the value set to the DBSERVERNAME parameter in
          the $INFORMIXDIR/etc/<configuration_file>. Please contact the System
          Administrator to know this value).
        . Check if the 'oninit' processes are running through 'ps' command. If
          not, then run $INFORMIXDIR/bin/oninit either as informix user or as
          SU.
        . Run the INFORMIX dbaccess tool. When the menu appears follow the path
          in the 'database' sub menu to create a new database ie., select
          database, create, enter the database name, choose dbspace, log mode,
          exit and  create_new_database.
        . If a database is not created with 'nfmadmin' as owner, then grant
          connect, resource privileges to 'nfmadmin' user on the database,
          so that database can be accessed.
 
DATABASE NAMES:
    The maximum length of database names allowed depends on the type
    or rdbms and the operating system limitations. For example,
    Informix7.1, Database names should be no longer than 18 characters
    for OnLine and no longer than 10 characters for INFORMIX-SE. In
    case of Oracle it is maximum 8 characters. For more details and
    latest information, please refer to the respctive Reference Manuals
    of the RDBMS.
 
-------------------
End of New Features
-------------------

------------------------------
System Administrator Functions
------------------------------

The I/NFM System Administrator should periodically monitor the files
created by I/NFM.  These files may show errors or other problems and
can become extremely large.  If left unchecked, these files can fill up
the disk drive.  Below is a brief description of these files:

1. /usr/tmp/NFMserver.log keeps track of the I/NFM Clients.

2. If the I/NFM configuration file /etc/nfmd.conf has been configured
   to produce I/NFM debug files, these debug files should be deleted
   periodically.  NFMserver creates upto three debug files whereas
   NFMfileserver creates up to debug two files.

-------------------------------------
End of System Administrator Functions
-------------------------------------


---------
New Fixes
---------

----------------
End of New Fixes
----------------

-------------
Open Problems
-------------

[TR #249601545]
    Using Nfmfix and adding a storage area through Admin-Storage Area-Add
    Storage Area, if the password is 14 characters, the command fails.
    Even though the password field is char(14) according to the error
    message which reads "Password length "14" is greater than or equal to
    maximum possible password length "14"".
    This also fails when adding a default storage area during the add
    node process.

[TR #249601468]
    There is no apparent keyboard representation on a TDx of the Accept
    (PF1) and the Select/Underline (KP0) keys during a telnet session.
    This applies when using NFM locally on a TDx running ISOL.
    The data in the README file doesn't cover this.

[TR #249601430]
    Process on Transition doesn't work in combined client compared to
    traditional.  Loaded a POT that uses Nfmcli to flag files for backup
    when they are checked in.  Works fine in when checking in using tra-
    ditional, but it fails when checking in using combined client.

[TR #249601376]
    Checkout and subsequent checkin of a master file results in the
    message "Lock Tables statement must be the first statement in the
    transaction".  This occurs in the Nfmfix interface as well as in
    DMMGR v 1.x.  A DMMGR Undo Checkout command fixes the problem.

[TR #249600700]
    Admin - Nodes - Add Nodes.
    The Add I/NFM Node form allows the user to repeatedly hit the Process
    button without changing any attribute values without giving a warning
    message that the node already exists. The only messages seen are
    "Addin the node ..." and "Setting the workflow state ...".
    There is no Successful Completion message either.

[TR #249600696]
    Items & Files - Criteria - Define Sort Criteria.
    When the user hits Return in the Criteria Name field the cursor does
    not automatically jump to the Description field.

[TR #249600660]
    Newprodding I_NFMUI to an Intel-Solaris platform shows the user the
    following message "This version of the I/NFM user interface software
    represents major changes and enhancements over previous versions..."
    This is incorrect.  This version contains only minor changes.

[TR #249600649]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the Add Item form accepted and truncated data entered into
    Local File Name (n_cofilename), File Type (n_filetype) and Internal
    File Name (n_cifilename) fields without warning the user.

[TR #249600197]
    Installing NFM on x86/Solaris creates a recursive link when
    variable INGRHOME is used.

[TR #249600078]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, I used User - Session - Review/Change Environment to change
    environments successfully after copying my /usr2/ip32/ris/schemasv5
    file to/usr2/ip32/ris/schemas.  After that, all NFM functions retur-
    ned the error message "This statement can not be used without a de-
    fault schema.".

[TR #249600063]
    Using Nfmfix, Cancelling the Delete Item confirmation box removes the
    Item Name and the Revision from the NFM main menu.  If the command is
    cancelled, the data should be left in the fields as is done with the
    Lock Item command and the Unlock Item command.

[TR #249600014]
    The error message "Unable to find nfm schema name for node ""."
    needs to be changed so that "nfm" reads "I/NFM".

[TR #249507169]
    The Help button on the Nfmfix combined client login form does not
    return the message "Help is not available".

[TR #249506624]
    Newprodding NFM to an Intel-Solaris system, the default file system
    is /opt and if the user tries to change the targeted file system with
    the f command, the prompt and default is:
    Key in the directory name (currently "/usr") [VB]: Hello World!
    The user can delete the default and successfully key in another file
    system.  This is probably a problem with DELTOOLS and it has been
    logged with DELTOOLS support.

[TR #249506411]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the cursor should automatically appear in the Old Password
    field when the Change Password for User form appears.

[TR #249506407]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the Help button on the Change Password for Working Area
    does not respond that Help is not available.

[TR #249506406]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, if an item is flagged for Archive and the user hits Flag
    Files for Delete and confirms it, the error msg reads "Item "tina1"
    is currently flagged".  It should provide the revision in the error
    msg also.

[TR #249506404]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, if an item is flagged for Archive and the user hits Flag
    for Backup and confirms it, the error msg is "Item "1" is currently
    flagged".  If the user then hits Flag for Delete the error msg is
    "Item "tina1.a1" not archived".  The first msg provides incomplete
    item and revision information while the second msg is grammatically
    incorrect and should read "Item "tina1.a1" is not archived".

[TR #249506403]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, a Confirmation box is needed when a Criteria Name is used
    and one already exists for the Define a Sort Criteria form.  Other-
    wise the previous Sort Criteria is overwritten and the user is not
    warned.

[TR #249506399]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the cursor does not automatically jump from the Criteria
    Name field to the Description field on the Define a Sort Criteria
    form.

[TR #249506397]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the cursor does not automatically jump from the Criteria
    Name field to the Description field when a Return is hit on the De-
    fine Search Criteria form.

[TR #249506375]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, when the Add Files to Item form is first displayed and the
    user selects an Interal Location from the Validation List, a message
    is displayed at the bottom of the form, but it is erased too fast to
    be read.

[TR #249506373]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, with the Move Files buttons displayed, if the user hits the
    Review Item Attributes button from the Main menubar, the Move Files
    buttons disappear.

[TR #249506372]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, after attempting to delete a locked item, the item name is
    removed from the main NFM menu.  Since the item was not deleted, the
    name should not be removed.

[TR #249506370]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the cursor should automatically be placed in the Value
    field when the Add Item to Catalog form first appears.

[TR #249506369]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the Up Arrow functions like the Down Arrow key on the Copy
    Item form.

[TR #249506367]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the cursor does not automatically jump from field to field
    on the Add Files to Item form.

[TR #249506365]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, if the user enters a Verify Password that doesn't match the
    New Password on the Change Password for Storage Area form, an error
    msg appears, but the cursor does not automatically get placed back in
    the Old Password field.

[TR #249506364]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, if the user enters an invalid Old Password on the Change
    Password for Storage Area form and hits the Accept, he will receive
    an error message.  If the user goes back to the form, the cursor does
    not automatically display in the first field as it does when the form
    appears initally.

[TR #249506362]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the Add Storage Area form allows the user to add a storage
    area with a path that doesn't exist.  Verified with the Display List
    of Storage Areas command.

[TR #249506361]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the Up Arrow functions like the Down Arrow on the Add I/NFM
    Storage Area form.  Also, both arrows stop at the password field and
    don't allow the user to scroll through it, even if a password had
    been added previously.

[TR #249506360]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the Validation List fields need to be wider.  In some cases
    the List is less than a third the width of the form and data is not
    fully displayed.  The data can only be seen by using the clunky left-
    right arrows.  Attributes with this problem include; Node Number,
    Device Type, Type and Owner Number.

[TR #249506359]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the user is allowed to enter invalid information for Node
    Name, machine Type and Operating System.  After hitting the Accept
    button, the message returned to the user is not very helpful.  It
    reads "System/Storage area was created for TCP/IP but TCP/IP address
    does not exist".  Also, the Display Storage Area form did not show
    where any storage area had been created.

[TR #249506358]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, if the user enters nothing for a required field on the Add
    I/NFM Node form and hits the Accept button, the cursor should auto-
    matically be returned to the Value field and the problem field should
    be highlighted.  Same thing when an invalid value is entered and
    Accepted.

[TR #249506357]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the cursor should automatically appear in the User Name
    field when the Add I/NFM Storage Area form is displayed as a subform
    to the Add I/NFM Node form.

[TR #249506356]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the cursor should automatically appear in the Value field
    when the Add I/NFM Node form is displayed.  When the form appears,
    the cursor appears as as a non-filled rectangle instead of a filled
    rectangle and when the user tries to type a value, it disappears.
    The user must then use the mouse to place the cursor in the Value
    field.

[TR #249506355]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the Add Node form allows the user to enter an invalid stor-
    age area path with no error msg.

[TR #249506352]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the Add Node form didn't provide a space to add values for
    DECNet and NetWare.  Yet these values appear on the List of I/NFM
    Nodes form.

[TR #249506350]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the Add I/NFM Node form has no user prompts when the user
    scrolls from field to field.

[TR #249506349]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the Add I/NFM Node form has no Validation List for Machine
    Type or Operating System.  This is needed for users to have a chance
    to enter the correct value.  PCs, when not added correctly, become
    troublesome when the user is trying to use DM/Manager as a client.

[TR #249506347]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, if the user displays the pick list for Catalog Name, but
    doesn't make a selection and simply hits the Cancel button, the Item
    Name and Revision are erased.  They should be left on screen if no
    catalog is selected.

[TR #249506346]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, if the user performs a Checkout twice on an item with no
    files checked in or associated with it, the user will receive a false
    error message "Checkout failed; item tina5 revision a1 is already
    checked out".

[TR #249506345]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, if the user selects an item that has not been checked in &
    has no files associated with it, and performs a Check Out twice, the
    status becomes "ON".  This is not a valid status.  This also happens
    after a Copy Out or Check In is performed before the Check Out com-
    mand in the same situation.  Use the Review Item Attributes form to
    monitor the process.

[TR #249506343]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, after entering a New Password value and then entering a
    different Verify Password value and hitting the Return key, the user
    sees the message "Successful completion".  Even though it wasn't and
    after the user hits the Accept button, a proper error message is re-
    turned.

[TR #249506342]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the Change Password form does not come up with the cursor
    automatically in the first field, New Password.

[TR #249506341]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the arrow keys stop on the password field, even after a
    password has been entered.

[TR #249506340]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the Up Arrow key doesn't work properly on the Add I/NFM
    User form.  It acts like the Down Arrow key.

[TR #249506339]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the message "This attribute is not allowed NULL values"
    displays when the Create Catalog form first displays.  However, if
    the user does not add a Catalog Name and scrolls through the list of
    attributes, the message does not reappear when the cursor comes back
    to Catalog Name.  It does reappear momentarily when the user moves
    the cursor to the next field.

[TR #249506337]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the cursor does not automatically jump to the next field
    when the user hits the Return key on the Create Catalog form.

[TR #249506336]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, on the Add Item to Catalog form, if the user adds a couple
    of items and scrolls through the list a couple of times, then the
    right and left arrow keys no longer work in the Value field.

[TR #249506335]
    Using Nfmfix exported from an Intel-Solaris box and displaying on a
    CLIX box, the prompt for attribute Version Limit on the Add Item to
    Catalog form shows "(1)" at the end.  This should be removed because
    it could cause the user to think he is limited to 1 version of each
    file.

[TR #249506098]
    Nfmfix - Items&Files, Flag, Flag for Restore
    Are allowed to flag a set for restore if the set is checked out and
    had not been either archived or backed up.

[TR #249506074]
    Nfmfix - Checkout
    Checkout an item with no files checked in and receive the message
    "Invalid SQL statement.  Expected end of statement, got 'nfmadmin'."

[TR #249506019]
    Nfmalpha - User, Information, Record End
    Does not display the "Successful Completion" message.  So you don't
    know when it has completed.

[TR #249505976]
    Nfmalpha - Workflow, ACL's, Delete Signoff Users section of all
    Am allowed to delete all the signoff users even though a minimum of
    one is required.

[TR #249505894]
    Nfmalpha - Item, Flag, Flag Restore
    If the item is checked out then the message "Item <item name> is
    checked out" flashes by, but then it displays the message "Successful
    Completion".

[TR #249505825]
    Nfmalpha - Admin, Utilities, Archive, Archive
    When PF1 is choosen on the list of flagged items the message
    "Working.." is not displayed.  So you do not know if you really hit
    PF1 until is completes.

[TR #249505819]
    Nfmfix, Nfmalpha - Admin, Utility, Delete Saveset Entries
    If no savesets exist then the message 'Error deleting saveset ""' is
    displayed.  It should say 'No savesets exist'.

[TR #249505816]
    Nfmbulk - When the NFM server selection prompt is displayed the
    message "Working.." is still displayed.  It will go away when either
    the cursor is moved up/down the servers or a server is choosen.  The
    "Working.." message is also displayed when the list of environments
    is displayed.  It will be removed in the same manner.

[TR #249505815]
    Nfmbulk -s<server> will display the list of environments.  If PF3 is
    choosen then the messages "Cannot get server name" and "Working .."
    are displayed before exiting.  The server message also appears if PF3
    is taken on the server selection display.

[TR #249505814]
    Nfmbulk will return back to the command line prompt if the user
    enters the wrong username.password three times.

[TR #249505677]
    Nfmalpha - Items&Files, Manip Items, Copy Item
    Does not always review the copylocks value.  If it is changed from
    Y to N, it will still copy if Nfmalpha is not ended and restarted.

[TR #249505669]
    Nfmfix - Items&Files, Manip Item, Copy Item
    Attempt to copy an item and file when the item copy lock is NO and it
    is checked out, then receive "Error is not loaded in the structure".

[TR #249505665]
    Nfmalpha/Nfmfix - Item, Manip Item, Copy
    A message should be displayed when copying files that are checked out
    "The files copied are the internal copies of the files, not the files
    in the working area".

[TR #249505231]
    Nfmalpha - Workflow, ACLs, Add_Class_Users
    All users are displayed for each class, even those that have already
    been added to the ACL.  It should only display those that may still
    be added to the ACL.

[TR #249505163]
    Nfmcli - search_name (sort_name), list_items
    The list_items command does not verify that the search or sort
    criteria name is valid.

[TR #249505079]
    Nfmfix - Items&Files, Manip Items, Add Item, Display Item
    If an item is added with a description of 80 characters then the
    Display Item and Review Item Attributes do not display all 80 chars
    at a readable speed.  The first 24 characters are good then when the
    horizontal button is pressed the rest of the characters flash by
    until the end.

[TR #249504907]
    Nfmfix - Items&files, Manip Files, Add Files to Item
    Does not advance the cursor to the next entry.  If the "Add File to
    List" button is used then the check button then it displays "Need to
    enter data for 'Local File Name'".  It will not let you out with the
    check button until another file is entered.

[TR #249504795]
    Nfmfix - Admin/Catalog/Create Catalog
    When it first comes up the check button is automatically pressed and
    an error message "This attribute is not allowed NULL values" is
    displayed.  You then have to click on the Catalog Name to enter the
    name.  It also does not automatically advance to the next attribute
    after entering, each desired attribute must be selected individually.

[TR #249504192]
    A secondary set member that is in a state in the workflow where
    copies are not allowed is still copied out with the set when the set
    is copied  out.  This violates security.

--------------------
End of Open Problems
--------------------
