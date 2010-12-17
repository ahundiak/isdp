Copyright 1993-1995 Intergraph Corporation
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
Product:      I_NFMSRV                                         I/NFM Server
Version:      03.05.02.18
Date:         22-Jun-1995

Description:  I/NFM Server is a software product that provides file access,
              management, and archival across a network of Intergraph Work-
              stations, Intergraph Servers, Intergraph VAXes, PCs and other
              nodes having connectivity to the Intergraph network. I_NFMSRV
              works in conjunction with I/NFM user interface software
              (I_NFMUI).

 ---------------------------------------------------------------------------
End of Version Information
 --------------------------

 -----------------
Installation Help
 -----------------

     ALL NUCLEUS SOFTWARE (ISS 7.x) MUST BE INSTALLED BEFORE I/NFM IS
     INSTALLED, OTHERWISE, I/NFM WILL BEHAVE IN AN UNPREDICTABLE MANNER.
     THIS VERSION OF I/NFM IS DEPENDENT ON RIS 5.0 OR LATER.

     I_NFMSRV is delivered to /usrx/ip32/nfm/i_nfmsrv. This is where you
     will find the README and the remove script. All executables, config
     files, etc. are delivered to /usrx/ip32/nfm. A a symbolic link is
     made to /usr/ip32/nfm.

     If the network protocol to be used by I/NFM is TCP/IP, TCP/IP must
     be downloaded prior to the NFMfileserver and NFMdaemon software.

     On all NON-CLIX platforms, the network protocol is always TCP/IP.

     If RIS does not exist on the machine where the I/NFM server software
     is being downloaded, a warning will be printed during the newprod
     session.

     The I/NFM installation procedure will prompt the user (Y/N)
     for the desired I/NFM components.

     Do you want the I/NFM Server Software?

       - The server software consists of the initialize image and the server
         image. This is the traditional NFMserver architecture.

     Do you want the I/NFM PC Software?

       - This is the I/NFM PC server and client command line interface
         software.

     Do you want the I/NFM Administrator Utility?

       - This is a utility to perform various reports and system
         maintenance tasks.

     Do you want the I/NFM 2.0 to 3.0 Schema Converter?

       - This software is needed to upgrade I/NFM database systems created
         under I/NFM 2.x.

     Do you want the I/NFM File Server and Utility Software?

       - This prompt is only issued if no other options have been selected.
         The I/NFM Utility Software is always downloaded automatically
         with each of the other options.  The Utility Software is
         comprised of the NFMfileserver and NFMdaemon.  This software
         must reside on all machines that will communicate with I/NFM. The
         NFMdaemon process will be started during installation of I/NFM
         and subsequent reboots.


     Do you want the I/NFM DBA Server Software?

       - The server software consists of the initialize image and the server
         image. This is the Combined DBA server architecture.

     USER PARTITIONS
     To download the I/NFM software to a partition other than /usr, the
     -b option may be specified on the newprod command line.  For example,

             newprod -n deliver.ip32 -b/usr2

     You may also change the destination file system while in newprod.
     If you download software to a partition other than /usr, it is
     important that the /usr/ip32/nfm directory does not exist prior to
     installation.

     UPDATE UTILITY 
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
products. The IDL is delivered free with the Intergraph Systems Software 
(ISS) Supplemental Baseline product set.

To get a copy of the current IDL, use the newprod software delivery utility
to deliver ST**008 IDL from the ISS Supplemental Baseline to your workstation
or server. The IDL files are delivered to /usr/ip32/idl.

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

Security
Customer Support
Restrictions
Online Reference Manual
New Features
System Administrator Functions

 -----------------------
End of Product Sections
 -----------------------

 --------
Security
 --------

COPS Test: Passed a COPS security check on 6/2/1995.

 -----------------------
End of Security Section
 -----------------------

 ----------------
Customer Support
 ----------------

Customer Support is initiated by logging software problems or change
request through Intergraph's Customer Support Center. The toll-free
number is 1-800-633-7248.  In Alabama, call (205) 730-4384/4385/4387.

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

I/NFM requires your RIS schema file name to be 'risschema'. This has been
the default schema file name for RIS until RIS 4.0. With RIS 4.0 or later,
the default schema file name is 'schemas'. Any existing schemas will remain
as is with the schema file name 'risschema'. However, any NEW schemas that
are created may have the name of 'schemas'. To then be able to access this
schema remotely, you may have to change the schema file name via 'rismgr'
(old 'risschema_mgr').

Nfminit requires utl.msg.  This has been a problem with RIS 4.3.
However new risutil directory has been added to /usrx/ip32/nfm
and it contains these files .So the user can copy them into proper location
from /usrx/ip32/nfm/risutil.

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
you are using the AECSHELL/ADM to I/NFM Bridge. If you are not using the
AECSHELL/ADM to I/NFM Bridge, you may create (or change) your catalogs
with these attributes set to NO for read, write, update, and delete.

Making the n_itemrev ("Item Revision") attribute not readable, not writable,
or not updateable can cause problems. It will not appear in any item 
listings and therefore cannot be manipulated.

CREATE CATALOG:
    While creating Catalogs the Attribute field and the Synonym fields
    can accept only 24 chars after which they get truncated. For Data Type
    the maximum length of character data is char(INT_MAX) which is the
    maximum value the underlying Operating System supports.  For ex.,
    currently under CLIX it is char(2147483647)

    Two users cannot create a catalog at the same time.

While trying to add two or more Items to a Project at the same time,
with one of the items being locked, it is not possible to add any of
the items.

Initializing a second environment on an Oracle database:

  *** There must be a valid CLIX account for each Oracle user (I/NFM
      environment).

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
      execution.  The delete operation can be attempted again without
      error.

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

      VAX FILENAMES - When naming internal storage files, if the internal
      storage area is a VAX, you need to specify an extension for filename
      uniqueness.

      VAX STORAGE AREAS - When using VAX storage areas, you must use the
      full directory specification. You cannot use logicals.

      COPY ITEM - Copy Item did not properly set the n_fileco in
      releases prior to I/NFM 3.2. If "Copy Item Files" fails on
      an item that was created through "Copy Item", the user should
      check to see if the n_fileco attribute is set to NULL even
      though a file is associated with the item. If so, the user
      should call support. TR filed.

      ALL NON-CLIX STORAGE AREAS - File transfers to any non-CLIX
      node use 'ftp' and therefore the destination storage area must
      have a password defined for it.

      FLAG FOR RESTORE - ALPHA INTERFACE -
      The Flag for Restore command is NOT list driven in the alpha
      interface. TR filed.

      ALPHA INTERFACE - PROMOTING ITEMS TO A SET
      If an item is active but no set is active, the "add items to set"
      command adds members to the active item. However, if a set is active,
      the "add items to set command" adds members to the active set. The 
only
      way to add members to the item is to go to "activate" and clear out
      the set.

      ADD MEMBERS TO SET - ALPHA AND FORMS INTERFACES
      No more than 20 items should be added to a set at one time.  The
      user can exit the command and re-enter it to add additional set
members.

      'ITEM NAME' FIELD ON BULKLOADER SHOULD BE READ ONLY.  Since it is
      currently writable, users can change the itemnames.  Since the item-
      name is also the local filename, changing the itemname makes the
      checkin fail.  The field needs to be changed to read only so users
      cannot try to change itemnames. TR filed.

      CATALOG NAMES CAN NOT BE MORE THAN 16 CHARACTERS. Due to a RIS
      limitation, the maximum length of a RIS table name is limited to
      18 characters.  The I/NFM Create Catalog command also produces a
      file table for each catalog, which contains the catalog name plus
      a prefix of f_.  Thus the RIS limitation combined with the I/NFM
      requirement for a file table, limits the length of a catalog name
      to not more than 16 characters.

      Catalog names should not exceed 13 characters, for applications such
      as DM/View, DM/Redline, DMANDS View and DMANDS Redline, catalog names
      should not exceed 13 characters.  These applications, which store
      redlines as files, require file tables for the redline catalogs.
      This requirement uses up 5 characters of the 18 allowed by RIS
      for a catalog name.  The naming convention is f_CatalogName_rl.

  Record and Playback functions are not available in I/NFM for any X/FORMS
  Interface.

  I/NFM will not connect via TCP/IP to a host when the host nodename begins
  with a number instead of a letter.  This is due to a TCP/IP restriction.
  Workaround is to:
           o  Set up an alias for the nodename that starts with a letter
           o  Add alias to the /etc/hosts file
           o  Edit /usr/lib/nodes/owned/nfms_<server> and change nodename to
              the alias
           o  Change nodename of node #1 in nfmnodes table to the alias.
           This will ensure that file transfers use TCP/IP and will enable
           TCP/IP to find the correct node.

  I/NFM does not currently support DECNET and NETWARE even though
  these prompts appear during the I/NFM initialization.

  The -P option with Nfmbulk must have the filename and options appended
  without spaces or the command will fail.

  While "Checking in" and "Checking Out" I/NFM expects certain
  permissions for the files and directories.These are as follows:
  o   The file should have "read" permissions for the owner
      ie: r--------
  o   The directory should have "execute" permissions for
      the owner ie: -wx------

  Alpha numeric interface on SCO UNIX uses ENTER as select key when the 
  Nfmalpha was invoked from a CLIX vt100 terminal. For the CLIX terminal 
  window the ENTER key should be mapped to <ESC>OM. To do this select 
  configure icon of the terminal window, then select macro, select ENTER 
  key, enter <ESC>OM and accept the changes to configure.

  Help is not available for Load Workflow in Workflow Generator.

 -------------------
End of Restrictions
 -------------------

 -----------------------
Online Reference Manual
 -----------------------

      I/NFM is delivered with a "doc" directory that contains
      several files that may be used as an on-line reference manual.

      access.txt
         How to access and use I/NFM through the various interfaces.

      admin.txt
         How to use the I/NFM Administrator Utility.

      bulkload.txt
         How to use the I/NFM Bulkload Utility.

      clh.txt
         Gives information about clearing house.

      cli.txt
         How to use the I/NFM Command Line Interface. This file has had
         extensive updates for the I/NFM 3.2 software.

      converter.txt
         How to use the I/NFM 2.x to 3.x converter.

      cp_acl_usr.txt
         Documentation on the new Copy ACL Users command.

      dbasrv.txt
         A document on how to use the DBASRV

      design.txt
         The functional design document for I/NFM 3.0.

      impact_34.txt
         The Impact Statement document of I/NFM

      pc.txt
         How to use the command line interface on the PC.
      
      pcnet.txt
         Information about Internal storage Areas of Non-CLIX nodes

      plotting.txt
         How to use the new Plot commands.

      proc_on_trans.txt
         How to use the process on transition capabilities.

      rm_proc.txt
         How to dissociate A Process from a transition

      schema.txt
         The I/NFM 3.0 schema

      setup.txt
         How to set up I/NFM.

      workflow.txt
         A document on how to understand workflows and changes between I/NFM
         2.x and 3.x workflows.

      workflow_ui.txt
         A document on how to understand and use the workflow interface.

      wf_train.txt
         This is a training exercise in using the workflow interface.

      NFMtrain32.txt
         A workflow ASCII file that can be loaded to use with the 
wf_train.txt
         document.


 ------------------------------
End of Online Reference Manual
 ------------------------------

 ------------
New Features
 ------------

  I/NFM 3.5

      SCO UNIX PORT
      I/NFM has been ported to the SCO UNIX platform.

      SETS
      Raster files may be added as primary members to sets.

      CLEARINGHOUSE ON SCO UNIX
      A new utility, clhtodat, converts I/NFM CLIX clearinghouse
      files into the NFMser.dat, NFMenv.dat, and NFMowne.dat
      files used by I/NFM on SCO UNIX.  These new NFM*.dat files
      replace the clearinghouse functionality provided on CLIX.

      SCO UNIX TO CLEARINGHOUSE
      A new utility, dattoclh, converts I/NFM SCO NFM*.dat files
      (NFMser.dat, NFMenv.dat, and NFMowne.dat) into the corresponding
      CLIX clearinghouse /usr/lib/nodes files on the CLIX systems.
 
      SYBASE SUPPORT
      I/NFM now supports Sybase databases.

      CLIX : Interim Viewing Solution
      In order to provide a higher accuracy view than DM/View provides,
      Intergraph introduced an interim viewing solution. The solution is 
      described in detail in the file "view_sol.txt". Two files are 
      referenced in "view_sol.txt", namely convert.bat and convert.sh. 
      All three files are delivered with NFMserver and can be found in the 
      /usrx/ip32/nfm/bin/  directory. 

 -------------------
End of New Features
 -------------------

 ------------------------------
System Administrator Functions
 ------------------------------

I/NFM System Administrator should periodically monitor files created by
I/NFM. Below is a brief description of these files:

1. /usr/tmp/NFMserver.log keeps track of the I/NFM Clients.

2. If the I/NFM configuration file /etc/nfmd.conf has been configured to
   produce I/NFM debugger files, these debugger files should be deleted
   periodically. NFMserver creates upto three debugger files whereas
   NFMfileserver creates upto debugger two files.

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

 --------------------
End of Open Problems
 --------------------
