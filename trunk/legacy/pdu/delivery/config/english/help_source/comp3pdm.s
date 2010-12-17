<TP>implement_pdm
:Implementing I/PDM-PDU:
Implementation is the first and the most important task in
using I/PDM-PDU. This section introduces you to some of the
basic aspects of the implementation process.

To successfully implement I/PDM-PDU, you should configure
the system by planning, analyzing, and organizing resources
and data.  That means you should determine the scope of
implementation by asking some important questions:

1.   What problems are to be solved?

2.   Where do you want to start?

3.   Where do you want to end?

You can address these questions by considering the
following:

<X>õ<T>   Workflow Analysis

<X>õ<T>   Data Analysis and User Classes

<X>õ<T>   System Configuration

<H>Workflow Analysis<T><T>

After initial planning, the first criterion in implementation is
workflow analysis.  A workflow is a set of guidelines that
direct parts through their production cycle.  It limits a user's
access to a part based on the current state of the part. Define
the workflow to include the necessary steps that must be
completed based on whether you plan to utilize a fully
customized system for your production shop or the default
workflow and access control lists that come with I/PDM-PDU.

<H>Data Analysis and User Classes<T><T>

After analyzing the workflow, analyze the type of data to be
stored in the database and the user access mechanism
reflecting the workflow:

<X>õ<T>   List the different catalogs, user-defined attributes that
     describe the parts in the catalog, customized list formats,
     BOM contents, and so forth.

     Define catalogs by determining the type of data to be
     stored in each and the type of searches that are useful for
     retrieving the data.  Select attributes and report formats
     for generating reports.

<X>õ<T>   In addition, decide on the number of user accounts and
     the user classes.  List the users and the respective
     functions they serve in the workflow.  You can use the list
     to create the necessary account for each user and place
     the user in the appropriate class.

<S>Note:<T>

     If you are going to start a customized system to include a
     workflow other than the PDM default workflow, you should
     decide on all possible classes of users who are involved in
     the part approval cycle.  It is necessary to determine the
     access that each user will have to a part depending on the
     state of the part. <F>„<T>

     Use the following questions to define each user class and
     its access privileges:

     a.   How many classes of users do you have in the
          engineering/design department?

     b.   How many classes of users do you have in the drafting
          department?

     c.   How many classes of users do you have in the
          manufacturing department?

     d.   How many of these users will be using the system?

     e.   What access will each user have to each part
          depending upon the state of the part in the approval
          cycle?

<H>System Configuration<T><T>

For configuring the I/PDM-PDU system, you need to make sure
you have the needed software and hardware.  Some of the
important factors you should consider while determining the
requirements are:

<X>õ<T>   The location of the relational database in relative to
     I/PDM and I/NFM.  It is very important that the software is
     downloaded properly, depending on where the database
     resides.

<X>õ<T>   The appropriate management, design, and network
     software needed for client workstations to function
     properly.

<X>õ<T>   Adequate memory to serve the average number of users
     concurrently using the system.

<X>õ<T>   The capacity of the server:

     - What machine will be used as the server?

     - How much memory does the server have?

     - How much disk space is available?

     - How many users will access the server?

<X>õ<T>   The location of the storage area:

     - Will all files be stored in the server node?

     - What other nodes will be used as storage areas?

     - Do each of the alternate storage nodes have
        adequate disk space for file storage?

     - What network protocol will be used for initial
        connection and file transfer?

<H>Types of Configurations<T><T>

There are three ways to configure an I/PDM system:

1.   Simple configuration.

2.   Remote file storage configuration.

3.   Extended configuration.

To understand these configurations, you need to know a few
terms.

The server<T> machine contains the I/PDM software and is
accessed by other machines on the network.

The client<T> machine contains I/PDU software and is the
user-interface to I/PDM.

A protocol<T> :

1.   Lets I/PDM and I/PDU communicate with one another.

2.   Lets I/PDM communicate with the database through RIS, if
     the database is located in a different machine than where
     I/PDM is running.

3.   Transfers files.

All machines on the network must have one of the protocols
supported by Intergraph --- TCP/IP or XNS.  The protocol used
must be the same on all machines on the network.

<S>Simple Configuration<T>

The simple configuration is the easiest system to understand
and maintain because the server, database, and files are all
on one machine.

<DG>
help_graphics/server.6h
<EG>

                               Simple System Configuration

This example illustrates the configuration of a simple system
that has only one server machine.  All of the software needed
to create and maintain the database is loaded on one
machine.  Along with the software, the database and files
used by I/PDM are stored on the server machine.  It is very
important that this machine have enough disk space to
contain everything that is needed to effectively run an I/PDM
system.

<S>Remote File Storage Configuration<T>

It was stated earlier that the files used by I/PDM could be
stored centrally or on other machines across the network.
The previous example shows a system configuration that
stores files centrally on the server machine.  The following
example illustrates a system that stores files on another
machine.

<DG>
help_graphics/server.7h
<EG>

                            System with files stored remotely

You can see that all software is still loaded on the server
machine just as it was in the simple configuration.  The
machine containing the files must have the NFMfileserver
software loaded to allow file transfer to and from this
machine.

<S>Extended Configuration<T>

An extended system can be used when you do not have
adequate disk space on your server machine to store all of
the software and support the database.  The following
illustrates a more complex way to configure the system.

<DG>
help_graphics/server.8h
<EG>

                              Extended System Configuration

In this system, the RIS server software and database reside on
a machine separate from the machine containing the I/PDM,
I/NFM, and RIS client software.  As before the machine that
contains the database must have adequate disk space to
support the database and the  number of users accessing the
database. For related information, see the following topic:<T>

1.   <ST>admsetup  Administrator Setup<T>


<ETP>
<TP>admsetup
:System Setup:
The major task of an administrator is to set up the system
properly. There are several things involved with setting up the
system.  The system administrator must:

1.   Configure the operating environment.

2.   Load the software properly.

3.   Add the appropriate users.

4.   Initialize the software.

For related information, see the following topic:<T>

1.   <ST>config  Configuration<T>

2.   <ST>loading_software  Loading Software<T>

3.   <ST>initial  Initializing the Software<T>

4.   <ST>initprob  Initialization Problems<T>

5.   <ST>checksys  Checking System Setup<T>

6.   <ST>asr0  Accessing the Software<T>

7.   <XR>ua1 Organizing Access Control, Users, and Files<T>

8.   <XR>cat0 Catalogs<T>

9.   <XR>partintro Parts and Files<T>

10.  <XR>assembly0 Assemblies<T>

11.  <XR>archive archive<T>

12.  <XR>prjcts Project Organization<T>

13.  <XR>rpts0 Reports<T>

14.  <XR>pdm_macros I/PDM API Macros<T>


<ETP>
<TP>config
:Operating Environment Configuration:
As the administrator, the first thing you must understand is
what you are configuring.  It is your job to organize the
information flow in and out of the database and to specify
who has access to what kinds of information.  In other words,
you are setting up the operating environment for the
designers who will need to use the part information stored by
the I/PDM system.

An operating environment contains a database or databases.
The databases contain catalogs, storage areas, workflows
and ACLs, assemblies and BOMs, and user names.  For
example, if you run a house repair business, you could set up
an environment for your plumbing parts and one for your
electrical parts.  You could set up one environment that
contains two databases, one each for the plumbing and
electrical. A third option is to set up one environment and one
database.  The database would contain two catalogs, one
each for plumbing and electrical.  These options are
discussed only to make the point that the environment is a
grouping of information that you can choose to organize in a
way appropriate to your needs.  You need to think of who
needs to do what and then set up your environments
appropriately.

The information stored in an environment is unique to that
environment and cannot be shared by other environments.
For example, a user that is logged into the bolts environment
cannot access a catalog located in the transistors
environment.

Successful creation of operating environments relies on
properly loaded software.  The software loading process is
described in the following section.


<ETP>
<TP>loading_software
:Loading the Software:
As discussed in the section, System Overview<T>, I/PDM and
I/PDU require several layers of software to function properly.
The procedures for loading the I/PDM and I/PDU software are
determined by whether they are to be loaded on a Clipper
workstation or InterServe.  I/PDM should be loaded on a
machine which has enough disk space for the files and
database.  For instructions on loading software on a
workstation or InterServe, refer to the Clipper Software
Delivery Guide (DSA0263).<T>  The software must be loaded in
the correct order to ensure proper performance.  The steps
taken to load the software depend on the system
configuration. The following steps should be taken in loading
the software to the server and client machines in a simple
configuration.  If you are using one of the other
configurations previously discussed, load the software
according to the configuration you are using.  Be sure to load
the software in the same order as below.

<S>On the Server<T>

1.   Load the protocol to be used, either TCP/IP or XNS.

2.   Load the RDBMS (INFORMIX SE or On-line, ORACLE, INGRES,
     or DB2).

3.   Reboot system after the RDBMS is loaded.

4.   Load RIS client and server software.

5.   Load I/NFM.

6.   Reboot system after I/NFM is loaded to activate
     NFMfileserver and NFMdaemon.

7.   Load I/PDM.

<S>On the Client<T>

1.   Load the protocol to be used, either TCP/IP or XNS.

2.   Reboot the system after the protocol is loaded.

3.   Load NFMfileserver and NFMdaemon.

4.   Reboot system to activate NFMfileserver and NFMdaemon.

5.   Load RISCCU.

6.   Load EMS.

7.   Load I/PDU.


<ETP>
<TP>lssun
:Configuring the SUN:
If the configuration file for the sun is not correct, I/PDU
requires a modification to the kernel in order to run on the
SUN OS.  You can check the GENERIC<T> file to make sure the
following entries are correct.

1.   Search for IPCMESSAGE and make sure the following lines
     are not commented out.

        options IPCMESSAGE #System V IPC message facility
        options IPCSEMAPHORE #System V IPC semaphore facility
        options IPCSHMEM #System V IPC shared-memory facility

2.   Search for TLI and make sure the following lines are not
     commented out.

        pseudo-device tim64
        pseudo-device tirw64
        pseudo-device tcptli32

If this file is not correct, you will have to make the corrections
before I/PDU will run on the SUN.  After you have downloaded
the software, you can take the following steps to reconfigure
the kernel.

1.   Create a kernel configuration file as root.

     a.   At the $ prompt, become super-user.

     b.   At the # prompt, cd to /usr/sys/sun[3,3x,4,4c]/conf<T>

     c.   At the # prompt, cp GENERIC NEW_KERNEL (where
          NEW_KERNEL represents the name of your new
          configuration).

     d.   At the # prompt, chmod +w NEW_KERNEL

2.   Modify the new configuration file.

     a.   Use an editor (vi or emacs) to modify NEW_KERNEL.

     b.   Search for the line beginning with ident and change the
          kernel name from GENERIC to NEW_KERNEL.

     c.   Search for IPCMESSAGE and make sure the following
          lines are not commented out.

             options IPCMESSAGE     #System V IPC message facility
             options IPCSEMAPHORE   #System V IPC semaphore facility
             options IPCSHMEM    #System V IPC shared-memory facility

     d.   Search for TLI and make sure the following lines are not
          commented out.

             pseudo-device tim64
             pseudo-device tirw64
             pseudo-device tcptli32

     e.   Exit and save the file.

     f.   At the # prompt, cp NEW_KERNEL
          /usr/kvm/sys/sun/3,3x,4,4c]/conf<T>

     g.   At the # prompt, config NEW_KERNEL<T>

     h.   At the # prompt, cd ../NEW_KERNEL<T>

     i.   At the # prompt, make<T>

3.   Install the kernel.

     a.   At the # prompt, mv /vmunix /vmunix.orig<T>

     b.   At the # prompt, cp vmunix /vmunix<T>

4.   Halt and reboot the system.

     a.   At the # prompt, /etc/halt<T>

     b.   Key in >b<T>

The SUN does not broadcast to the network, so you must edit
the /etc/hosts<T> file.  The hosts file must contain all nodes that
have a I/PDM server that you will login to or check in files to.
The following steps describe how the /etc/hosts<T> file should be
edited.

<S>On the SUN<T>

1.   At the $ prompt, become super-user.

2.   At the # prompt, open the /etc/hosts<T> file.

3.   Add the nodenames and tcp addresses of all workstations
     that will be networking with the SUN.

<S>On Machines Networking with the SUN<T>

1.   At the $ prompt, become super-user.

2.   At the # prompt, edit the /etc/hosts<T> file.

3.   Add the nodenames and tcp addresses of the SUN.

A node file must be created in the /usr/lib/nodes/heard<T>
directory for the checkin storage areas that will be checked in
from a SUN workstation.  If the checkin storage area is a SUN
workstation a /usr/lib/nodes/heard directory<T> must be created
and the client SUN node file information placed in the
directory.  The following steps explain how to do this.

1.   At the # prompt, cd /usr/lib/nodes/heard

2.   At the # prompt, cp <nodename> <filename> (where
     <nodename> is the nodename of the Clipper workstation
     and <filename> is the nodename of the SUN).

3.   Edit <filename>.

     a.   Get the SUN's ethernet address.  This address is
          displayed when the SUN is booting up.  Copy this number
          down when the system is booting up.

     b.   Edit the ethernet address of the SUN on the lines that
          say Owner<T> and Address.<T>

     c.   Edit the tcp address on the line containing tcp_address<T>.

     d.   Exit and save the file.


<ETP>
<TP>username
:Users:
I/PDM uses three different usernames:

1.   The CLIX username and password.

2.   The RIS schema name and password.

3.   The I/PDM username and password.

<S>CLIX username<T>

A CLIX user is recognized by a unique username and possibly
a password. CLIX users have a home directory, file ownership,
and file access privileges defined for them.  CLIX access does
not necessarily give access to I/PDM.

<S>RIS schema name<T>

The schema is a collection of tables, views, and privileges
owned by a user on a database.

The schema has a name and password assigned by the
schema creator.  This is used when RIS opens the schema for
transactions.  I/PDM checks this name/password combination
when a I/PDU user logs into I/PDM.

<S>I/PDM username<T>

An account with the username nfmadmin<T> must be added to
the I/NFM-PDM server machine.  This is the I/PDM
administrative account.  The home directory and other
subdirectories created underneath it contain all system
reports, the default user storage location, and utilities
directories for each I/PDM operating environment.  This
account is also used to initialize I/NFM and I/PDM and to
transfer files.  The I/PDM administrative user owns the
database schema.

This account must be passworded and the directory
protections must be set to make sure that only the I/PDM
administrative staff has access to this account.

<S>Changing the nfmadmin Password<T>

The nfmadmin<T> account password can be changed.  However,
this password is very delicate and you must be extremely
careful when changing the password.  The following steps
must be followed when changing the password.

1.   Login to the nfmadmin<T> account and use the UNIX passwd<T>
     command to change the user password.

2.   Enter interactive ris and change the system user
     password.

     a.   Key in /usr/ip32/ris/bin/ris<T>

     b.   At the ris prompt, key in alter schema
          schema_name.schema_password modify user password
          new_password;<T>

          where schema_name is the existing schema name,
          schema_password is the existing schema password, and
          new_password is the new nfmadmin<T> password.

     c.   Key in exit<T>;

3.   Enter the I/NFM admin<T> utility and change the nfme_file<T>.

     a.   Key in /usr/ip32/nfm/bin/Nfmadmin<T>

     b.   Select Configure<T>.

     c.   Select Environment<T>.

     d.   Select the environment you wish to change.

          -  Highlight the environment.

          -  Press the <Enter> key.

          -  Press the <PF1> key.

     e.   Change the RISDBA PASSWORD<T> to the nfmadmin<T>
          password and press the <PF1> key.

     f.   Exit the NFMadmin<T> utility.

4.   Copy the nfme_environment<T> file to pdme_environment<T> and
     broadcast the new files onto the network.

     a.   Become superuser.

     b.   cd /usr/lib/nodes/owned<T>

     c.   cp nfme_environment pdme_environment<T>

     d.   clh -u nfme_environment<T>

     e.   clh -u pdme_environment<T>

5.   Login to I/NFM and change the nfmadmin<T> user password.

6.   Use Change Storage Area Password<T> to change all storage
     areas controlled by nfmadmin<T> to reflect the new nfmadmin<T>
     password.


<ETP>
<TP>initial
:Initializing the Software:
After the database has been created, I/NFM and I/PDM must
be initialized before the software can be used.

1.   <ST>init1  Initializing I/NFM<T>

2.   <ST>initialization  Initializing I/PDM<T>


<ETP>
<TP>init1
:Initializing I/NFM:
The initialization procedures for I/NFM are contingent upon
the type of RDBMS that you have chosen: INFORMIX (standard
or on-line), INGRES, ORACLE, or DB2. This section explains the
step-by-step instructions for initializing I/NFM with standard
or on-line INFORMIX only<T>.

For instructions on initializing I/NFM on ORACLE, see the
appendix Initializing I/NFM with ORACLE<T> in the I/NFM
Reference Manual (DDA0013).<T>

For instructions on initializing I/NFM with INGRES, see the
appendix Initializing I/NFM with INGRES<T> in the I/NFM
Reference Manual (DDA0013)<T>.

During the process, you will create a new user account on the
node(s) where you installed I/NFM, RIS, and the INFORMIX
software.  Next, you will create an I/NFM database.  Finally,
you will initialize I/NFM.

1.   INFORMIX must<T> be installed on the RIS server before<T> you
     can initialize I/NFM. All INFORMIX directories,
     subdirectories and files must have an ownership and group
     of informix<T>.

2.   Create a new system account on the RIS client node.

<S>Note:<T>

     If I/NFM, I/PDM, and the RDBMS are on the same machine,
     the RIS client and server run on this machine as well. <F>„<T>

     a.   Log on to the RIS client node (where the I/NFM server
          software is installed).

     b.   Create a new system account named nfmadmin<T>. A
          password on this account is mandatory.

     c.   Add the following information to the .profile<T> file of this
          account, where /usrx<T> is the partition that applies for
          each entry:

          INFORMIXDIR=/usrx/informix<T>
          SQLEXEC=/usrx/informix/lib/sqlexec<T> if using Standard Engine INFORMIX

                                                 OR

          SQLEXEC=/usrx/informix/lib/sqlturbo<T> if using
                on-line INFORMIX export INFORMIXDIR

          If your database will reside in a directory other than
          /usr/nfmadmin<T>, you must also include the following line
          in your .profile<T>, and export that entry.

          DBPATH=/usrx/<T><I/NFM database administrator name><T>

          export INFORMIXDIR SQLEXEC DBPATH<T>

     d.   The following lines must exist in the /etc/group<T> file for
          the nfmadmin<T> account.

          informix::123:informix
          nfmadmin::800:nfmadmin

          The group numbers for these accounts need not be the
          numbers shown above, but the group number must be
          unique.

3.   Create the database for I/NFM.

     a.   Log onto the I/NFM server machine using the account
          where you want your database to reside. For example, if
          you are logged in as nfmadmin<T> your database will be
          created in the /usrx/nfmadmin<T> directory.

     b.   Key in the following line exactly as shown below to
          create the database:

          infxcreate <database name> -e S<T>

          Where S<T> represents standard engine INFORMIX

                                                 OR

          infxcreate <database name> -e O<T>

          Where O represents on-line INFORMIX.

          Your database is created and contains only system
          tables.<T>

<S>Note:<T>

          If you created your database under a login other than
          nfmadmin<T>, you will need to access isql and grant dba to
          the nfmadmin<T> account for that database. This must be
          done before<T> you can initialize I/NFM. <F>„<T>

4.   Initialize I/NFM.

     a.   You should be logged into the RIS client node (or where
          the I/NFM software resides) using the nfmadmin<T>
          account name.

     b.   At the $<T> prompt, key in /usrx/ip32/nfm/bin/Nfminit<T>

          Where /usrx<T> is the partition where I/NFM is installed.  A
          series of forms appear on the screen.  Where applicable,
          defaults are displayed in brackets. Modify and/or
          accept each form by pressing the <PF1> key.  If you
          want to terminate the process at any time while you are
          answering the questions, press the <PF3> key.

<S>Note:<T>

          Before you begin to answer the following questions, you
          may want to review the information that appears below
          each question, to ensure that you have the appropriate
          information to respond to the initialization. <F>„<T>

     c.   The first form adds the administrator server node to
          I/NFM.

          - NODE DESC.                 [I/NFM server node]<T>

                  The I/NFM server node description.<T>

          - TCP EXISTS                 [Y]<T>

                  Does TCP/IP exist on the I/NFM server node? If the
        answer to this question is yes, then TCP/IP will be used
        during I/NFM initialization, even if XNS is available.<T>

          - XNS EXISTS                 [Y]<T>

                  Does XNS exist on the I/NFM server node?<T>

          - DECNET EXISTS              [N]<T>

                  Does DECNET exist on the I/NFM server node?<T>

          - NETWARE EXISTS             [N]<T>

                  Does NETWARE exist on the I/NFM server node?<T>

          - NFS EXISTS                 [N]<T>

                  Does NFS exist on the I/NFM server node?<T>

     d.   The second form adds the administrator storage area to
          I/NFM.

          - STORAGE NAME                   [nfm]<T>

                  The name of the default file storage location. This
        is the logical name for the storage area, not the
        nodename, and is the home directory for the I/NFM server
        machine corresponding to the I/NFM administrator login
        directory.<T>

          - USERNAME                       [nfmadmin]<T>

                  The username for entry on the I/NFM server node.
        This is generally the account in which the initialization
        took place.<T>

          - PASSWORD                       [ ]<T>

                  The password for entry on the I/NFM server node.<T>

     e.   The third form adds the administrator user to I/NFM.

          - USER DESC.                     [I/NFM Administrator]<T>

                  Description of the I/NFM Administrator.<T>

          - EMAIL ADDR.                    [ ]<T>

                  The Electronic Mail Address of the I/NFM
        Administrator.<T>

     f.   The last form gathers information to be used in the
          I/NFM initialization.

          - SERVER NAME                    [nfm]<T>

                  The suffix of the nodename broadcast for the I/NFM
        server ("nfms_nfm").  If more than one nfm/ris database
        will reside on the network, each node must have a
        unique suffix, therefore you should not use the default.<T>

          - ENV. NAME                      [nfm]<T>

                  The suffix of the environment created ("nfme_nfm").
        If more than one nfm/ris database will reside on the
        network, each environment must have a unique suffix,
        therefore you should not use the default.<T>

          - RDBMS TYPE                     [informix ]<T>

                   The type of Relational Database Management
        System, INFORMIX, INGRES, ORACLE or DB2.<T>

          - RDBMS HOME DIRECTORY                [/usrx/informix]<T>

                   Where the RDBMS exists (pathname).<T>

          - RIS DATABASE PATH               [/usrx/nfmadmin/nfm ]<T>

                   For standard engine INFORMIX, the location (full
        pathname) of the I/NFM database created.  You must use
        the full pathname even if the database was created in
        /usrx/nfmadmin.<T>

                                                  OR

             RIS DATABASE PATH               [database name]<T>

                   For on-line INFORMIX, the RIS database path should
                   be just<T> [database name used in the infxcreate
                       statement<T>].

          - ENVIRONMENT NODE                    [ ]<T>

                   CLIX node name for the I/NFM environment and the
        RIS server.<T>

          - ENVIRONMENT NETWORK                 [xns]<T>

                   The type of network on the RIS server, XNS or
        TCP/IP.<T>

          - SCHEMA NAME                    [nfm]<T>

                   The I/NFM database schema name to be created
        through the I/NFM initialization.<T>

          - SCHEMA PASSWD                  [ ]<T>

                   The I/NFM database schema password. This
        password is optional.<T>

          - ENVIRONMENT USERNAME           [nfmadmin] <T>

                   The I/NFM database user account on the RIS
        server.  This should be the account used to initialize.<T>

          - ENVIRONMENT USER PASSWORD      [ ] <T>

                   The I/NFM database user password on the RIS
        server.<T>

When the initialization is complete, the system will respond
with the message Successful Completion<T>.

After successfully initializing I/NFM, the database contains
the RIS schema tables and the I/NFM schema tables.


<ETP>
<TP>initialization
:Initializing I/PDM:
The I/PDM software must be initialized on the server before
you can activate the product.  The server can be a Clipper
workstation, InterServe or Sun.  When you initialize software
you are simply setting internal structures to beginning values.

The following instructions explain the step-by-step
instructions for initializing I/PDM.

1.   Make sure all of the supporting software is installed and
     initialized on the I/PDM machine.

2.   Log onto the I/PDM machine using an administrative login
     created when I/NFM was initialized.

3.   Once you have logged into the operating system, you can
     initialize I/PDM by keying in:

     /usrx/ip32/pdm/bin/PDMinit<T> and press <Return>.

     Where /usrx<T> represents the partition where I/PDM was
     loaded.

     A form appears requesting information needed to initialize
     I/PDM.  Where applicable, defaults are displayed in
     brackets.  Modify and/or accept the information on the
     form by pressing the <PF1> key.  To terminate the process
     at any time while you are answering the questions, press
     <Ctrl-C>.

     - Environment name            [               ]<T>

             The I/PDM environment being initialized.<T>

     - User name                   [nfmadmin       ]<T>

             The username used to initialize I/PDM.  The default is
        nfmadmin.<T>

     - Password                    [               ]<T>

             The password for the username being used to initialize
        I/PDM.<T>

     - PDM/SQL Debug               [/dev/null      ]<T>

             Indicates where debug files will be created.  You can
        key in a directory path and filename for the debug file.<T>

<S>Note:<T>

After I/PDM has been initialized once, you do not have to
repeat the initialization procedures--even when you download
new software. <F>„<T>

I/PDM creates several tables during initialization.  A message
appears on the screen as these  are created. When I/PDM is
initialized, the file,
/usr/lib/nodes/owned/pdme_<environmentname><T>, is created.
This file represents an operating environment created on the
server for I/PDM.  You need to make sure that this file was
created.

<S>System After Initialization<T>

The following illustrates how the system should look after
initialization. The following lists the login, database,
directories, and files that are generated during initialization.

<X>õ<T>   Database Created<T> --- <database name used in
     initialization>

<X>õ<T>   Administrative login<T> --- nfmadmin

<X>õ<T>   Files Created<T> ---

      /usr/lib/nodes/heard/nfms_<servername>
      /usr/lib/nodes/heard/nfme_<environmentname>
      /usr/lib/nodes/heard/pdme_<environmentname>
      /usr/lib/nodes/owned/nfms_<servername>
      /usr/lib/nodes/owned/nfme_<environmentname>
      /usr/lib/nodes/owned/pdme_<environmentname>
      /usrx/ip32/ris/risschema      (created first time I/NFM is initialized.)
      /usrx/ip32/ris/risschema.LCK  (created first time I/NFM is initialized.)

<X>õ<T>   Directories Created<T> ---

      /usr/nfmadmin/<environmentname>
      /usr/nfmadmin/<environmentname>/files (default file storage area)
      /usr/nfmadmin/<environmentname>/systems (user defined report storage area)
      /usr/nfmadmin/<environmentname>/utilities (HD temporary backup storage area)
      /usr/nfmadmin/<environmentname>/pdmpplfiles (functions and APIs)
      /usr/nfmadmin/<environmentname>/pdmreports (RIS import reports)


<ETP>
<TP>initprob
:Initialization Problems:
Problems can occur when I/NFM and I/PDM are initialized.
The following describes several errors that prevent I/NFM
and/or I/PDM from being properly initialized.

<X>õ<T>   The RDBMS is not loaded.

<X>õ<T>   The username/password combination is invalid.

<X>õ<T>   The wrong protocol is chosen.

<X>õ<T>   RIS is not loaded.

<X>õ<T>   The database name used in initialization does not exist.

<X>õ<T>   The servername and environment names do not get
     broadcast properly.

<X>õ<T>   The protections for the /usr/lib/nodes/owned<T> directory
     are incorrect.

<X>õ<T>   The entries in the /etc/nfmd.conf<T> are incorrect or
     missing.


<ETP>
<TP>checksys
:Checking System Setup:
There are a few things that you can do to ensure the system is
set up correctly.

1.   If the software is loaded correctly and all entries have
     been made to the appropriate files you should be able to
     visit the server node from another workstation.

2.   You should be able to fmu or ftp files between machines
     depending on which protocol is used.

3.   If you have TCP/IP and have problems with file transfer
     make sure that TCP/IP is running.  You can start TCP/IP by
     rebooting your machine or by starting TCP/IP manually.

Follow these steps to start TCP/IP.

1.   Become superuser.

2.   Change to the /etc/init.d<T> directory

3.   Key in ./tcpip stop<T> to make sure TCP/IP is not running.

4.   Key in ./tcpip start<T> to start TCP/IP again.


<ETP>
<TP>asr0
:Accessing I/PDM:
Once I/PDM has been successfully initialized, you are ready to
access the server software using the interfaces, and begin
adding information to the operating environment.  Most of the
administrative functions are performed through I/NFM.  I/NFM
is accessed through the I/NFM client software, which acts as
an interface to the I/NFM server software.  There are some
administrative commands performed by I/PDM.  These
administrative and all end-user functions are performed
through the I/PDU interface.

<S>Note:<T>

I/NFM contains two interfaces: a forms interface and an
alphanumeric interface.  For more information on these
interfaces, refer to the Introduction<T>  of the I/NFM Reference
Manual. (DDA0013)<T> <F>„<T>

For related information, see the following topic:<T>

1.   <ST>accessing_pdu  Accessing I/PDM<T>

2.   <ST>exiting_software  Exiting the Software<T>

For more information on accessing I/PDM, refer to the
Introduction<T> of the I/NFM Reference Manual (DDA0013)<T>.


<ETP>
<TP>accessing_pdu
:Accessing I/PDM:
To work with I/PDU software, you first have to log onto the
system.   Once you have logged onto the system, activate the
I/PDM software by keying in /usr/ip32/ems/bin/ems<T>.  Because
I/PDM is built on EMS, you must specify a dummy filename
each time you access I/PDM.  This file is referred to as a
dummy file because it remains empty. You do not create
graphics in this file. After you specify the filename, the EMS
command menu bar appears.

The menu bar contains the Product/Task<T> button.

<DG>
help_graphics/sp0.6
<EG>

                                   Product/Task Button

This button is different for the different members of the EMS
family of products.  You select this button with the left mouse
button to display a pull-down menu.

<DG>
help_graphics/pulldown.6
<EG>

                                      Pull-down Menu

When you select PDM<T> from this pull-down menu, the Login to
PDM<T> form appears. The username and associated password
are provided by the system administrator.  Each environment
acts as a database, storing information about files, and there
can be multiple environments per server.  You can use the List<T>
button next to the Environment<T> field to display a list of all
environments for the server you are using.  The values for the
Username<T> and Environment<T> fields default to the values used
the previous time you logged into I/PDM.  The only thing you
need to enter to reconnect to the previous server and
environment is the user password.  When all information is
correct, exit the form, saving the information.  If the login is
successful, the PDM/PDU<T> form appears.  This form displays
the username and environment you are using.  If the login is
not successful, an error message appears in the message area
giving the reason for failure.


<ETP>
<TP>exiting_software
:Exiting the Software:
To end an I/PDU session, you should exit the software
properly.  This process is simple but very important.

1.   To exit I/PDU, disconnect from the server and operating
     environment by selecting the Logout<T> button on the
     PDM/PDU<T> form. This breaks the connection from the server
     and operating environment, but you will still have access to
     the EMS commands.

2.   Select the EMS Exit<T> icon to exit EMS and return to an
     operating system prompt.


<ETP>
