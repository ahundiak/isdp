-------------
Legal Notices
-------------
Copyright 1996, Intergraph Corporation.

All rights reserved.

Including software, file formats, and audio-visual displays;
may be used pursuant to applicable software license agreement;
contains confidential and proprietary information of
Intergraph and/or third parties which is protected by
copyright and trade secret law and may not be provided or
otherwise made available without proper authorization.

Restricted Rights Legend
Use duplication, or disclosure by the Government is subject to
restrictions as set forth in subparagraph (c) (1) (ii) of the
Rights in Technical Data and Computer Software clause at DFARS
252.227-7013 or subparagraphs (c) (1) and (2) of Commercial
Computer Software -- Restricted Rights at 48 CFR 52.227-19, as
applicable.

Unpublished -- rights reserved under the copyright laws of the
United States.

Intergraph Corporation
Huntsville, Alabama   35894-0001
--------------------
End of Legal Notices
--------------------

-------------------
Version Information
-------------------
Product:        RIS Shared Component
Version:        !version!
Date:           !date!
Description:    RIS (Relational Interface System) is a generic relational
                database interface.  The RIS Shared Component allows
                applications to access any supported relational database
                system without modifying source code.  RIS uses ANSI/ISO
                Standard SQL and also provides networking capabilities to
                allow applications to locate their data on one or more
                remote network nodes.

                The RIS Shared Component Packaging Files are required by
                applications that intend to package and redeliver the RIS
                Run-Time Client and Utilities.
--------------------------
End of Version Information
--------------------------

-------------------
System Requirements
-------------------
 Following are the minimum system requirements for the RIS
 Shared Component:

 * Windows NT(r) version 3.51 or Windows 95(r) operating system
 * An Intel(r) processor-based PC with a 386 processor
 * At least 16 megabytes of RAM
--------------------------
End of System Requirements
--------------------------

-----------------
Installation Help
-----------------
SPECIAL NOTES: 

      Version 2.10 or higher of MSVCRT20.DLL is required to run the RIS
      Graphic Utilities.  If an older version of MSVCRT20.DLL is detected
      on the system, version 2.10 will be loaded into the system directory.

	NT:	C:\WINNT\SYSTEM32
 	WIN95:	C:\WIN95\SYSTEM

      If this is the FIRST Intergraph product loaded onto the system, the
      'HKEY_LOCAL_MACHINE\SOFTWARE\Intergraph\Common' Registry key will be
      set to:
                  C:\Program Files\Common Files\Intergraph

      The RIS installation will load the RIS Shared Component (RIS Client
      and Utilities) into the directory specified by the Common Registry key.

      (The above examples use a SystemDrive of C:; the Setup process
       determines the actual SystemDrive.)


For setting up RIS on a WIN32S system, please refer to "32ssetup.txt".
------------------------
End of Installation Help
------------------------

---------------
Getting Started
---------------
The directory for the RIS Shared Component is added to the PATH environment
variable during installation.  If the RIS Shared Component directory name
contains spaces, it is enclosed in quotes so that it can be used by the
command interpreter (CMD.EXE).

A RIS application will attempt to use a RIS Client that is the same version
as the RIS application. If that version of the client is not installed, the
highest version available will be used.  If multiple versions of the RIS
Shared Component are present, inconsistencies could result when starting
applications (e.g. the default schema files would be located in different
directories).

With RIS V5, a utility is delivered to allow earlier RIS applications to
use the latest RIS Client and Utilities.  The "Configure RIS Version" utility
will remove earlier RIS Shared Components (client and utilities) by removing
the older RIS registry entries, removing the older RIS icons, and optionally
removing the risXX.XX Shared Component directory and files.  This directory
will be stored under "<SystemDrive>:\Program Files\Common Files\Intergraph\"
or "<SystemDrive>:\win32app\ingr\share\", depending upon the existing
configuration.

NOTE: If this is run to remove a RIS V4 Shared Component, the RIS V4 Client
      will be inactivated and a local RIS V4 Data Server can only be
      accessed by a REMOTE RIS V4 Client.

The utility is located in the "RIS 05.04" program group and can be
activated via the "Configure RIS Version" icon.  The utility attempts to
copy the RIS parameters file (parms) and schema file (schemas) to the
new RIS V5 directory.  If you have renamed these files, you need to key
in the new names in the From and/or To fields in the "Copy" dialog box.
If you already have RIS V5 parms and/or schemas files, the originals (V5)
are saved files named parms.V5 and schemas.V5.  You also have the option to
remove the older RIS shared component directory and files.  You may not want
to remove these files if you use a RIS V4 application (for example: a RIS V4
recorded session can only be played back with the RIS V4 playback utility).

You should only run the "Configure RIS Version" utility as a user with
administrator privileges.

Additionally, if you have been using RIS V4 and are now going to use RIS
V5, your schema file and data dictionary tables must be upgraded to the
RIS V5 format.  A utility, "risupgrd.exe", is delivered to perform this
conversion.  The utility needs to only be run once for each V4 schema.  It
is also located in the "RIS 05.04" program group and can be activated
with the "Upgrade RIS" icon.

For more information, see the "New Features" section below and the
"Interoperability and Upgrading" section of the RIS Installation Guide
for 32-Bit Applications.

On NT 4.0, the following products need to be loaded to configure
the FTP Server for use with the 'locate schema' command which locates
a schema file to a remote NT 4.0 machine: 

    Microsoft Peer Web Services (NTW)
    Microsoft Internet Information Server 2.0 (NTS)
   
After the OS installation from the delivery media select:
    Start => Settings => Control Panel
    Network => Services => Add
    From the menu select:
    Microsoft Peer Web Services (NTW) or
    Microsoft Internet Information Server 2.0 (NTS)
    From the next menu select:
    Internet Service Manager and FTP Service

To configure FTP to work with RIS:
    Enter Microsoft Internet Service Manager
    Highlight your machine name, Properties pull down menu,
    from it select Service Properties
    Under "Service", uncheck "Allow only anonymous connections"
    Under "Directories", select Add; Check Virtual Directory 
    Fill in "c:" for Directory; Fill in Alias "/c:"
    Allow Read and Write Access (check both)
    Select Okay
Repeat for any other Drives that remote schema files may reside on.

For redistribution information, rights, and limitations, please refer to
the "Redistribution of RIS Runtime and RIS Utilities" appendix in the RIS
Installation Guide for 32-Bit Applications.
----------------------
End of Getting Started
----------------------

-------------
Documentation
-------------
The Intergraph Bulletin Board Service provides current 
information on documentation for this and other Intergraph 
products.  The Bulletin Board operates 24 hours a day and 
is available in the United States at 1-205-730-8786.

For current information on Intergraph documentation and 
Intergraph document delivery policies, use a World Wide Web 
browser to connect to Intergraph online at 
http://www.intergraph.com, and follow the links to Customer 
Services.
--------------------
End of Documentation
--------------------

--------
Training
--------
To register for training on this or other Intergraph products, call 
Intergraph Training Solutions at 1-800-240-3000.

For current information on Intergraph training, use a World Wide
Web browser to connect to Intergraph online at
http://www.intergraph.com/cust/training.shtml, and follow the links 
to Customer Services.

Training information is also available through the Intergraph Bulletin 
Board and the Intergraph Course Catalog which details all Intergraph 
courses. The course catalog can be obtained by calling the above number. 
The Bulletin Board operates 24 hours a day and is available in the 
United States at 1-205-730-8786.

To receive more information or assistance in planning your training 
curriculum, you can also contact one of the U.S. Regional Training 
Centers at the following numbers:

Location					Phone Number
Atlanta, GA					(770) 333-6800
Chicago, IL					(847) 806-3100
Dallas, TX					(214) 497-0893
Detroit, MI					(810) 351-2900
Houston, TX					(713) 954-8000
Huntsville, AL  (Corporate Headquarters)	(205) 730-6700
Irvine, CA					(714) 727-0646
Lenexa, KS 					(913) 599-1250
Reston, VA					(703) 264-1520
Tampa, FL 					(813) 207-2700

Customers outside the United States should contact their local 
Intergraph office.
---------------
End of Training
---------------

----------------
Product Sections
----------------
Win32s
 - Must connect to a remote RIS client (NT or UNIX)
 - Will ONLY run as a single instance
 - NO setup available
 - Not fully certified
 - Only utilities supported are RISmgr and RISgui
 - Only utility DLL supported is for RISmgr

Windows 95
 - Can use a local RIS client
 - Can not locate a RIS client on a remote Windows 95 system
 - Can not locate a schema file on a remote Windows 95 system
-----------------------
End of Product Sections
-----------------------

------------
New Features
------------
o  The following products were used during the build process:
     Windows NT 3.51
     Microsoft Visual C++ 2.1
     Shamrock/Visual C++ 02.01.10.05
     SetupSDK 02.03.01.02

o  The following products were used during the certification process:
     Windows NTW 3.51, Windows NTS 3.51
     Windows NTW 4.00 , Windows NTS 4.00    
     Windows NTJ 3.5/3.51
     Windows95 - August 1995 release
     Win32s version 1.2
     Microsoft Visual C++ 2.0, 2.1, 2.2

o  The following DLLs are packaged with the RIS product to allow for
   interoperability with previous versions of Shamrock, UMS, and RIS:
     Shamrock/MS SDK 02.00.10.04  (I9SHAMR1.DLL)
     UMS/MS SDK 01.00.02.05       (I9UMS1.DLL)
     RIS 04.03.05.02              (I9RIS.DLL, I9RISFM.DLL, I9RISLU.DLL)
     RIS 05.00.01.33              (I9RIS5.DLL, I9RISFM5.DLL, I9RISLU5.DLL)
   ____________________________________________________________________________

o  RIS Orphan Processes

   Several RIS applications have encountered an 'orphan process' problem
   in previous versions of RIS.

   Symptoms:

   1. RIS Client and/or RIS Data Server processes continue to exist on the
      RIS client machine when a user re-boots their RIS application system
      while connected to the database through RIS.  This occurs when a RIS
      application is connected to the RIS client via TCP/IP.  Because the
      RIS client process exists, all RIS server processes connected to the
      RIS client process also continue to exist.

   2. RIS Data Server processes continue to exist on the RIS server system
      when a user re-boots their RIS client system while connected to the
      database through RIS.  This occurs when the RIS client system is
      connected to a RIS Data Server via TCP/IP.

   The RIS Data Server 'orphan process' problem is fixed in the 05.03.01 RIS
   Data Server products.  A similar fix was incorporated into the RIS client
   which is bundled with the RIS data servers and the RIS Development Platform.

   The default wait time before an orphan process terminates is 2 hours.  That
   means, after the RIS application or RIS client system is re-booted, the
   orphan process waits for 2 hours before it terminates.  The wait time can
   be changed and the procedure for this change is platform specific.

   WARNING: The side effect of changing the wait time is that it affects ALL
   applications that use the TCP/IP KeepAlive feature.  It is recommended that
   you NOT set the KeepAlive wait time to less than 30 minutes.

   Following is the description on how the System Administrator can change
   the wait time for the Windows NT platform:

     With the Registry Editor (regedt32.exe), add or modify the KeepAliveTime
     value for the Tcpip\Parameters key.  The system must be rebooted for this
     parameter change to take effect.

     The entry for this TCP/IP parameter appears under the following Registry
     path:

      HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters

     Edit the Tcpip\Parameters Registry Key and Add/Modify the Value:

      Value Name       Data Type     Data (Specify in Binary, Decimal, or Hex)
      _____________    _________     _________________________________________
      KeepAliveTime    REG_DWORD     1 to 0xffffffff milliseconds (hex)

     To add a value, highlight the "Parameters" key, select "Add Value" from
     the "Edit" pulldown menu.  Set the 'Value Name' and 'Data Type' accord-
     ingly.  Select the 'OK' button.  Set the 'Data' value.

     If the KeepAliveTime key already exists, the time-out value can be
     changed by double-clicking on the entry and setting a new value in the
     dialog box.

   Suggested values:

     7,200,000 (decimal) milliseconds - two hours (Default)
     3,600,000 (decimal) milliseconds - 1 hour
     1,800,000 (decimal) milliseconds - 30 minutes
   ____________________________________________________________________________

o  RIS now supports internationalized names for tables, views, indexes,
   schemas, etc.  RIS also supports international character data.

o  Internationalized capabilities (16 bit or multi-byte languages) have been
   certified in this release.  RIS supports internationalization on NT only
   with RIS version 05.03.01 and greater.  Applications wishing to interface
   with Relational Database Management Systems that support 16-bit, or multi-
   byte, languages must be built with the version 05.03.01 or greater RIS
   Development Platform.  Currently, the only RIS Data Servers that will
   support 16-bit/multi-byte languages are RISORADS (RIS Oracle Data Server)
   and RISSYBDS (RIS Sybase SQL Data Server).  The RIS Data Servers also have
   to be version 05.03.01 or greater.

   The ONLY RIS utilities that implement multi-byte character support are
   RISMGR and RISGUI.
   The following RIS utilities will NOT support multi-byte character sets:
	risupgrd         risbatch         risdtype
	rislod           risunlod         risdcode
	risrecrd         risplbck         risclnsr
   Also, there is no RIS API support for internationalization in the rislod
   and risunlod functions.

   RIS limitations/guidelines
    - RIS schema/user names can be internationalized, but not passwords.
    - ONLY alpha-numeric characters can be internationalized.
    - Setup is not fully internationalized.
    - RIS is NOT localizing dialogs, gadgets, error messages, etc.
    - RIS is internationalized on NT only; RIS is not internationalized on
      Unix platforms.  Therefore the RIS application, RIS Client, and RIS
      Data Server must be on NT to take advantage of RIS internationalization.
    - The period (.) used between usernames and passwords must be 8-bit
      English.
    - All punctuation and keywords must be 8-bit English to be parseable by
      RIS.
    - Column datatype definitions must be 8-bit English (int, decimal,
      char(),...).
    - Timestamp data must be 8-bit English.
    - All RIS keywords, Data Definition Language (DDL) statements, Data
      Manipulation Language (DML) statements, and other miscellaneous
      statements (default schema, commit, set...) must be 8-bit English.
    - RIS data dictionary tables and views will always be created using 8-bit
      English characters.
    - Schema/table/view/column/index names can either be 8-bit or 16-bit
      characters.  Due to the fact that schema/table/view/column/index names
      are limited to 18 8-bit characters, internationalized schema/table/view/
      column/index names are limited to 9 16-bit characters.  This is valid only
      when ANSI mode (default mode) is on.

   Some of the information used during a 'create schema' statement can be
   16-bit and some can't.  The user will be able to create a schema or table
   via RISGUI, but he will have to toggle back and forth between 8-bit English
   and his 16-bit language.  Following are the components of a 'create schema'
   statement and which parts must be 8-bit English and which parts can be
   16-bit:
	create schema   - 8-bit English
	schema name     - 8/16 bit
	schema pass     - 8-bit
	db type         - 8-bit
	dbname          - 8/16 bit
	db dir          - 8/16 bit
	osuser          - 16 bit
	ospass          - 8-bit
	ostype          - 8-bit
	db user         - 8/16 bit (if the underlying RDBMS supports 16-bit)
	remote clause   - 8-bit

   Character columns will need to be analyzed to make sure that they are wide
   enough to hold the data.  For example, to hold a 10 character name in a
   16-bit language takes a char(20) column.

   The number of 8-bit characters in a column cannot exceed 240; therefore,
   the number of 16-bit characters in a column cannot exceed 120.
   ____________________________________________________________________________

o  UNION and UNION ALL Supported

   RIS Version 5.x supports UNION and UNION ALL operators with the select
   statement.  For example:

      select * from union select from t1;

      select c1, c2, from t1 union all select c21, c22 from t2;

o  Objects of Different Owners Within a Schema

   In RIS Version 4, a schema created by an RDBMS user contained only
   objects owned by that user.  In RIS Version 5.x, a schema can contain
   objects owned by multiple users.  For example, schema S1, created by
   RDBMS user U1, can contain objects owned by RDBMS users U2 and U3,
   as well as those owned by U1.  This capability:

   - Is a fundamental redefinition of a schema to be simply a named
     collection of objects in a database.

   - Lets data owned by privileged accounts be included without views
     or security violations.

   - Allows sharing of common objects among schemas.  For example, table T1,
     created by user U1, can be shared by schemas S1, S2, and S3, where S1
     was created by user U1, S2 by user U2, and S3 by user U3.

   - Lets applications easily create logical groupings of tables.

   Considerations when using this capability:

   - Since objects owned by different users can be included in the schema,
     the owner information is maintained in the RIS dictionary.  The
     dbms_owner value applies to a table, view, or an index, and can be in
     upper or lower case.

   - This capability cannot be accessed through RIS Version 4.

   - The access restrictions of the underlying RDBMS will be encountered
     when using this capability.

   - Most databases allow two different users to create tables, views, and
     indexes with the same name.  However the names of tables, views, and
     indexes within a schema are unique, regardless of the dbms_owner.  If
     both T1 owned by U1, and T1 owned by U2 need to be included in a schema,
     one of the tables has to be aliased.

o  Object Aliases

   With RIS Version 5.x, any column or table name can be given an alias.
   For example, table abc_123 with columns abc1, abc2, and abc3, can be
   included and referred to as EMPLOYEES with columns FIRST_NAME, GENDER,
   and DATE_OF_BIRTH, respectively.  This capability:

   - Lets identically-named tables owned by different RDBMS users exist in
     a single schema.  For example, suppose three different users create
     three different tables with the same name:

     RDBMS:  PROJ1.NAMES, PROJ2.NAMES, PROJ3.NAMES

     These tables must be aliased so that they have distinct names.

     SCHEMA1:  NAMES1, NAMES2, NAMES3

   - Names in RIS can be longer than the underlying database supports.

   - Object names and keyword conflicts can be worked around.  For example,
     if a column name is a RIS keyword, such as t1(informix, oracle, db2),
     it can be included as t1(col1, col2, col3).

   Considerations when using this capability:

   - An exclude/include sequence will lose all aliases.

   - This capability cannot be accessed through RIS Version 4.

   - Within RIS only the RIS names (aliases) are valid.  The external/DBMS
     name is not valid.

o  Multi-User/Secure Schemas

   For RIS Version 5.x, this type of schema has no username/password
   combination stored for it.  The RIS Version 4 (single user) schema is
   still supported and still the default.  This capability:

   - Allows no connection until a user provides a username/password
     combination.

   - Lets users use the same schema, but provide different RDBMS logins.

   Considerations when using this capability:

   - No password is stored in any form by RIS.

   - Individuals appear distinct to the RDBMS and are subject to RDBMS
     security tracking.

   - The 'declare schema' statement lets you specify a schema name and
     password, and optionally, the user and password of the user who owns
     the schema, and the operating system user and password in the RIS
     in-memory data dictionary cache.  This statement MUST be used to
     access secure schemas.  It can also be used to access standard schemas.
     See the Relational Interface System (RIS) SQL Reference Manual for more
     information.  This capability can be used by any site.  It is most
     useful to those interested in high levels of security (usually DB2,
     ORACLE, and so on).

   - The schema administrator (user who creates the schema) controls authority
     to connect to a schema and to create tables on a schema, using:

        GRANT CONNECT TO <rdbms_user>;
        REVOKE CONNECT FROM <rdbms_user>;
        GRANT RESOURCE TO <rdbms_user>;
        REVOKE RESOURCE FROM <rdbms_user>;

   - A username/password combination should be provided before a schema is
     open.

   - There will be case-sensitivity of the RDBMS username (except in cases
     where some databases accept names in a particular case; then RIS will
     perform a conversion).

   - This capability cannot be accessed through RIS Version 4.

o  Shared Dictionaries

   In RIS Version 5.x, when a schema s1 is created and creates the dictionary
   as in RIS Version 4, schemas s2, s3, s4, and so on, can be created using
   the dictionary created by schema s1.  This capability:

   - Allows multiple schemas in databases that cannot have tables of the
     same name (Rdb and non-ANSI INFORMIX).

   - Requires minimal dictionary creation when there are many schemas.

   - Allows dictionary creation, administration, and ownership outside of
     RIS for DB2 and SYBASE.

   Considerations when using this capability:

   - The system administrator must grant and revoke an RDBMS user the
     authority to create a schema on a dictionary, using:

        GRANT SCHEMA TO <rdbms_user>;
        REVOKE SCHEMA FROM <rdbms_user>;

   - The creator of a dictionary will not be able to drop all his/her
     schemas while there are other schemas in the dictionary.

   - An application based on RIS Version 4 must create a dictionary in
     order to use it.  Additional schemas can then be added to the
     dictionary and used by applications based on RIS Version 5.x.  Schemas
     s2, s3, s4, and so on, cannot be accessed from RIS Version 4.

o  Dictionary Objects

   Dictionary objects in RIS Version 5.x are all renamed (ris5*).  This
   capability:

   - Removes the distinction between ris* and ris_*.

   - Makes RIS dictionary objects now appear in the dictionary views.

   Considerations when using this capability:

   - Additional columns will be needed to distinguish among schemas in
     shared dictionaries, to distinguish between user objects and
     dictionary objects, and for internal/external object names.

   - Names will need to be changed in queries.

   - New columns should be considered in queries.

o  Dictionary Views

   In RIS Version 4, the internal RIS dictionary tables were documented,
   with the note that they are not intended for application use, and
   information about them was maintained in the dictionary.  In RIS
   Version 5.x, the internal tables will not be documented and information
   about them will not be available in the dictionary.  Only dictionary
   views can be accessed from an application.

   In RIS Version 4, the dictionary views showed information about only
   the user (or application) objects and the base tables contained both
   application objects and RIS dictionary objects.  In RIS Version 5.x,
   since the base tables are not accessible from the applications, the
   views show both user objects and RIS objects.

   Considerations:

   - If only user objects need to be selected, the condition ris_object='N'
     should be used in the WHERE clause.  This applies to the views
     ris5columns, ris5column_privs, ris5tables, and ris5table_privs.

   - In RIS Version 4, the views risdbms_tables, risdbms_views, and
     risdbms_indexes listed the objects, views, and indexes, respectively,
     that were in the database, but not included in the schema.  Due to the
     RIS Version 5.x capabilities allowing objects of different users within
     a schema and shared dictionaries, the exact equivalent of the RIS
     Version 4 views cannot be provided.

   - In Version 5.x, the ris5dbms_tables view lists all the tables in the
     database, along with the user that owns the database.  The ris5dbms_views
     view lists all the views in the database, along with the user that owns
     the database.  The ris5dbms_indexes view lists all the indexes in the
     database, along with the user that owns the database.  In some cases,
     these lists may include only those tables/views/indexes accessible to
     the current login/user of the database.

   - These views are not recommended for use by applications.  If used, the
     query should have some restrictive condition (specifically, WHERE).
     Using select * from these views can lead to significant performance
     degradation.  Since this view is defined to show everything, it should
     be used with caution.  In some cases these views will be accessible only
     for the dictionary creator since some databases do not allow granting
     system privileges on catalogs (where these views are defined).

o  BLOBS

   To utilize BLOBS and TEXT data, the client and data server versions must
   be at least version 05.01.01.xx.

   RIS Version 5.x allows long binary or text data.  This capability:

   - Can be used for document or picture storage by INFORMIX OnLine and
     ORACLE.  RIS has no BLOB support for SYBASE, DB2, Rdb, Informix
     Standard Engine, or Microsoft SQL Server.

   - Lets users insert, update, or retrieve large data.

   - Lets the user access character strings with a length greater than 249
     characters for other RDBMSs not supporting BLOB.

   Considerations when using this capability:

   - The BLOB capability cannot be accessed through RIS Version 4.

   - This feature is available only through the programming interface; no
     interactive access is available.

   - The application should track the data length.

   -  The RIS_BLOB data type is for binary data; for example, GIF files,
      executables, and so forth.  RIS makes no attempt to convert or
      interpret the data.

   -  The RIS_TEXT data type is for text data; for example, ASCII files.

   -  RIS does convert the text data between different hardware platforms
      as it would for character data.

   -  Text data can be inserted into a ris_blob column, but NO blob data
      should be inserted into a ris_text column.

   -  The following statement creates a table containing a column of
      ris_blob/ris_text data type:

         create table emp (name char(25), id int, picture ris_blob(50000));

      The size of the blob/text column is set to 0 if no size is specified
      in the 'create table' statement.  In this case, the maximum length of
      the data is dependent on the underlying database.  If this size is set,
      RIS uses the value to impose a maximum data size.  If the maximum data
      size is set to 0, data can only be retrieved from the database into a
      memory array, not into a file.

   -  BLOB/TEXT data can be fetched or inserted from/into a blob/text column
      only by using the ris_blob or ris_text data structure in an embedded
      RIS program.

   -  The 'file_used' field is required for both insertion and retrieval.  RIS
      will use either the filename or array as the targeted user variable
      depending upon the value in the 'file_used' field.

   -  RIS_BLOB and RIS_TEXT columns cannot be used in the SQL WHERE clause
      or GROUP BY statements, and cannot be indexed.

   -  The number of ris_blob/ris_text columns allowed in one table is subject
      to the restrictions of the underlying RDBMS.  INFORMIX allows multiple
      blob/text columns while ORACLE allows one blob/text column per table.

   -  ORACLE specific BLOB information
      To manipulate RIS Blob/Text data, any tables with blob/text fields need
      to be created through RIS and the data inserted only through RIS.

      Currently, RIS uses the first 8 bytes of the blob/text column to store
      the length of the data.  Existing tables with data, when included in a
      RIS schema, will result in incomplete data (first 8 bytes missing) when
      retrieved from the database.

      When the maximum size limit for a blob/text column is zero, data
      cannot being retrieved from the database to a file.  For this option
      to work correctly, the size must be set to a non-zero value.  The limit
      size could be set to zero in the following situations:
        - An existing table which has blob/text columns is included in a
          RIS schema
        - A table is excluded from the RIS schema and later included back
          into the schema
        - A table is created through RIS without specifying a blob/text
          column size.
      This situation does not apply when the data is retrieved into a memory
      array.

      To check the value of the maximum size limit, select the value of the
      'char_max_column' field from the RIS data dictionary:
          select char_max_length from ris5columns
                   where table_name = 'blob_table' and column_name = 'c1';

      To reset the value of 'char_max_column':
          exec oracle update "RC01".ri05_t03 set char_max_length = 10000
            where table_id = (select table_id from "RC01".ri05_t02
              where table_name = 'blob_table' and schema_name = 'sch1')
                and column_name = 'c1';
      or, use the 'risdtype' utility to reset the size limit.
      Example:
         C:\> risdtype
         ...
         Enter schema(<CR> to exit):sch1
         Enter a table or view name (or ? for a list of names):
         >blob_table

         Pos         Column Name        type type-string len  prec scale null
         ---- ------------------------- ---- ----------- ---- ---- ----- ----
            1                        c1   15    ris_blob 0    null  null  YES

         Do you wish to modify this column? <y(es), n(o), d(one with table)>>y

         0 UNSUPPORTED
         1 CHARACTER
         2 RIS_BLOB
         6 RIS_TEXT

        Choose a datatype from those listed (enter the number) >>2
        Current maximum ris_blob length is:0
        Current maximum ris_blob length is:10000
        Current status for nullable is YES, nulls are allowed
        Are null values allowed? <y(es), n(o)> >>y
        Column definitions modified for object sch1.blob_table:

        Pos       Column Name          type type-string len  prec scale null
        ---- ------------------------- ---- ----------- ---- ---- ----- ----
           1                        c1   15    ris_blob 10000 null  null YES

        Is this correct? <y(es), n(o), q(uit)> >>y

      In the above example, RC01 is the dictionary owner as shown in the schema
      file, 'blob_table' is the name of the table with a blob column, 'sch1' is
      the name of the schema the blob table was included into, and 'c1' is the
      name of the blob_column.  The 'char_max_length' field may be set to values
      other than 10000.

      RIS can limit the data size inserted into a blob/text column if a size
      is specified when the table is created. 
      For example:
		create table blob1 (c1 ris_blob(10000));

      would impose a limit of 10,000 bytes.  If the table is created
      without specifying a size, then the underlying RDBMS's maximum limit
      for blob/text data will be used.
      For example:
		create table blob2 (c2 ris_blob));

      For Text/Blob data to be retrieved into a file from the database, the
      maximum size limit cannot be zero.  When retrieving data to memory, the
      size limit can be zero.

o  Multiple versions of RIS / Interoperability

   RIS Version 5.x lets multiple versions of RIS products be available
   simultaneously on most systems.

   Version 4 Application can work with either a Version 4 Client or a
   Version 5 Client.

   Version 4 Client can work with either a Version 4 Data Server or a
   Version 5 Data Server.

   This capability allows continued use of RIS Version 4 applications
   with minimal impact.  Version 4 applications should continue to run.

   The following application-client-server combinations are possible:

      4 - 4 - 4

      4 - 4 - 5

      4 - 5 - 5

      5 - 5 - 5

   Considerations when using this capability:

  * IMPORTANT * IMPORTANT * IMPORTANT * IMPORTANT * IMPORTANT * IMPORTANT *

   - A Version 5 Application can read a Version 4 parameter file.

   - A Version 5 Client CANNOT work with a Version 4 SCHEMA FILE.

   - A Version 4 Client CANNOT work with a Version 5 SCHEMA FILE.

   - A Version 5 Data Server CANNOT work with a Version 4 dictionary/schema.

   - A Version 4 Data Server CANNOT work with a Version 5 dictionary/schema.

   - Multiple versions are available remotely through TCP only.

   - The ORACLE 7 Data Server requires the RIS V5.x Client.

   - The Sybase Data Server and Microsoft SQL Server Data Server should use
     at least a version 05.02 client to fully utilize decimal data.

  A RIS Version 4 application will attempt to start up a RIS Version 4
  Client.  Only if it is absent will it start up a RIS Version 5.x
  Client.  The same is true for Client/Server.

  Only RIS Version 5.x applications can query RIS Version 5.x dictionary
  objects.  Only RIS Version 4 applications can query RIS Version 4
  dictionary objects.

  The risdtype utility of RIS Version 4 cannot be used with the RIS
  Client Version 5 or the RIS Data Server Version 5.

o  Upgrade Utility

   A utility, called 'risupgrd', is delivered with the RIS Client to
   convert a schema (RIS data dictionary and schema file) from RIS
   Version 4 to RIS Version 5.  This process is mandatory when upgrading
   the RIS data server to version 5.  A version 5 client is required to
   execute the RIS upgrade procedure.  The RIS upgrade utility is
   accessible via the command line by the file name "risupgrd.exe" or
   via the "Upgrade RIS" icon located in the "RIS 05.04" program group.
   When executed from an icon, scrolling is not enabled for the default
   window.  It may be helpful to add scroll bars to the window on NT to
   ensure that information is not lost when scrolled off the screen.
   Scrolling can be enabled by increasing the "Screen Buffer Height" size
   in the "Screen Size and Position" section from the Properties pulldown
   menu of the window.

   Considerations when using this utility:

   - This conversion should be applied to every existing schema when RIS
     Version 5.x Data Servers are installed.

   - The RIS Version 4 Data Servers should be removed.

   - The conversion of the dictionary is irreversible and is done in-place.

   - The schema file conversion is non-destructive.  The Version 5 schema
     file is generated from the Version 4 schema file.  This allows a mix
     of Version 4 and Version 5 clients to access Version 5 data server.
     The schema file that matches the client version has to be used, using
     the Locate Schema File statement.  A new schema file name must be used
     when converting the schema file.  Do not use the same name for the v5
     schema file as for the v4 schema file.

o  Parameter file

   The parameter file generated by a Version 5 application or utility will
   be compatible with Version 4 applications.  Unlike Version 4, Version 5
   is more tolerant with respect to parameter files: one or more parameters
   may be omitted and RIS will use default values.

   A new parameter CLIENT_VERSION has been added with the default value set
   to 0.0, meaning that the application will connect to a compatible client.
   When future versions of RIS become available, Version 5.0 and higher
   applications will be able to use this parameter to specify the client
   version.  USE OF THIS PARAMETER WILL CAUSE Version 4 applications to FAIL,
   hence for now, it is best left commented out.

o  Utilities

   Considerations when using the Version 5.x loader/unloader:

   - The loader/unloader provides no BLOB support.

   - The unloader unloads (or saves) RIS names (aliases) only, not the
     underlying object names.

   - The unloader unloads (or saves) schema ownership only, not underlying
     RDBMS ownership.

o  Recommendations for migrating to Version 5 :

   - Experiment with the RIS Schema Manager.  The schema changes/options
     are most visible there.

   - Evaluate the potential of the ability to include objects of other
     users in schemas.

   - Evaluate the potential of aliases.

   - Experiment with shared dictionaries to eliminate fears that they will
     cause problems.

   - Experiment with interoperability to eliminate fears of running
     applications based on RIS Version 4 with a Version 5.x server.

   - Evaluate BLOBs to determine whether or not this would be useful if
     used only with ORACLE and INFORMIX OnLine.

   - Run the upgrade utility on the biggest sample schemas you have.
-------------------
End of New Features
-------------------

---------
New Fixes
---------
[TR #439602540]
    Configure RIS Version utility contains references to a version 4 schema file
     when it should reference the more generic term  "previous"  versions.
    
[TR #439602337]
    RISLOD returns the error RISUTL_E_CANT_OPEN_TEMP_FILE when
    opening more than 50 files during one session.

[TR #439602060]
    When RISUTL debug is turned on, risrecrd does not write information into
     the output file.

[TR #439601662]
    Cannot checksum a schema file or create a schema using a remote schema
    file on NTS 4.0 or NTW 4.0.

[TR #439601444]
    An application built on NT seems to have a memory leak when calling on 
    execute immediate, or on prepare.  The clear statement does not clear it.

[TR #439601283]
    Using RIS Schema Manager, TCP should be the default network protocol
    instead of XNS in the Create Schema form.

[TR #439601280]
    Application using RIS 05.03 on a Windows 3.1/WIN32S system receives
    a network error when trying to connect to a remote client.

[TR #439601220]
    RISGUI does not display more than 6 digits of a double field.

[TR #439600371]
    Using risbatch to locate a remote client, if the protocol is entered
    in lower case, the operation will fail with the error "Invalid
    choice".

[TR #439600181]
    The RIS interface on NT restricts the user to one language setting -
    the one that the system is set to. This means that one can not access
    an english schema and a danish schema in the same session.

[TR #439600179]
    Rismgr causes a Dr. Watson error on NT when the environment variable
    RIS_LANGUAGE is set to Danish, and the NT language is set to English.
    The Dr Watson error identifies an access violation.

[TR #439503959]
    The "response interval" clause for the "set network verification"
    command is not working for a RIS Oracle Data Server on NT.

[TR #439503953]
    The RIS License List Utility is not displaying correct information on
    the number of active RIS data servers.

[TR #439503632]
    The Secure Schema Access screen locks up if you select a secure
    schema from the RIS Manager first.

[TR #439503443]
    If 2 or more statements separated by 2 semi-colons(stmt1;;stmt2) are
    executed in Interactive RIS(risgui), the first statement is executed,
    the remaining statements are ignored, but the message indicates
    successful completion.

[TR #439503226]
    The RIS ServerLicense List Utility should have a Help button that
    references the Licensing Help Information.

[TR #439503225]
    The RIS Server License List Utility should have default buttons
    that are selected when the 'Enter' key is used.

[TR #439503166]
    When attempting to run risgui and rismgr and the system has version
    2.00 of MSVCRT20.DLL, the RIS utilities return errors and will not
    run.

    Error: "procedure entry point _adj_fdivr_m64 could not be found in
            DLL MSVCRT20.DLL"

    RIS now loads the 2.10 version of MSVCRT20.DLL. However, it's possible
    another application installation may overwrite this DLL with an earlier
    version.

[TR #439503090]
    When a table is dropped via 'rismgr' and in the same session the
    "Include Table" form is invoked, the table just dropped will appear.

[TR #439503065]
    Default options for the Include and Exclude Forms in RIS Schema
    Manager should be consistent with all other forms.

[TR #439502896]
    RIS reports an incorrect error name for an error number when using
    an invalid schema and selecting the "Dictionary Access" form.

[TR #439502890]
    If an invalid schema ( e.g. one where the RIS data dictionary has
    been dropped but the schema file still contains information on it) is
    selected from RIS Schema Manager(rismgr) and the "Dictionary Access"
    button is selected from "Schema Definition", RIS gets into a loop
    reporting the error RIS_E_SCHEMA_DOES_NOT_EXIST.

[TR #439502842]
    The unsupported database type "SQL/DS" database type should be
    removed from the "Set" option of 'risgui' and 'rismgr'.

[TR #439502841]
    The "Set" option of 'risgui' and 'rismgr' refers to Microsoft SQL
    Server as "MS SQLSR", but most other references use "MSSQL".

[TR #439502538]
    If the input filename used when inserting BLOBs into a database does
    not have the correct permissions(read access), RIS will return an
    internal error. The error should be RIS_E_OPEN_BLOB_FILE_ERROR.

[TR #439502534]
    Resetting some parameters in the parms file will cause the data
    dictionary table to return invalid results.

[TR #439502302]
    In the 'Create Schema' form of rismgr/xrismgr, if the 'Echo' flags
    are turned on for the passwords and then the Reset button is
    selected, the flags are returned to 'No Echo' but the passwords will
    still be displayed when entered.

[TR #439501699]
    During the RIS upgrade process, if only the schema file name, instead
    of a path and name, is entered for the version 5 schema file,
    risupgrd will error out with a signal 11 interrupt.

[TR #439501677]
    When English is commented out of the langs file, RISMGR core dumps.

[TR #439501608]
    Rismgr->include table->DBMS User field should be scrollable.
    The "dbms User" pulldown list for the "Include Table" command in
    RISMGR can only show 5 DBMS users.

[TR #439500875]
    RISLOD failed to load a view under the following circumstance:
      create view v1(col1,col2) as select col1,col2 from t1
    Problem occured when there was no space between the view name (v1)
    and the left parenthesis following it.

[TR #439500235]
    RISCLNSR fails to clean up the RIS dictionary tables when the tables
    have a process id identical to the process id of the server process
    that the RISCLNSR program starts up.

[TR #439407619]
    WIN32S - When a non-English language is specified to be used by
    RISinitialize(), or no RISinitialize() statement is used so that the
    default OS language is used, English will continue to be the language
    used by the application.

[TR #439407587]
    When the RIS client has been located on an NT system, trying to
    use an invalid schema file may cause the client to abort.

[TR #439407333]
    When RIS_PARAMETERS is set to an old or non-existent path, the RISMGR
    will core dump when trying to run it in interactive mode.  The RIS
    Interactive tool gives an error message stating that the parameters
    file could not be found.  So the RIS Mgr should do the same.

[TR #439406935]
    The RIS client on NT may return an invalid error name associated with
    an error number.

[TR #439406616]
    If a RIS unload file contains a schema name containing uppercase
    characters, the rislod utility will fail when executed with options
    specified on the command line.

[TR #439304729]
    An application on NT can not close files if it opens them before
    starting the client and the client is still active. The client
    inherits all open files from the application and does not know how to
    close them. The current workaround is to start the client before
    opening any files that the application may desire to delete, rename,
    or close.
----------------
End of New Fixes
----------------

-------------
Open Problems
-------------
Following are the known problems with the RIS Shared Component (Client 
and Utilities).

[TR #439601440]
    RISMGR and RISGUI forms fields are not sized properly on NTJ 3.51.  
    Possible OS problem, pending outside support.

[TR #439601492]
    Cannot create a schema or access the schema file after locating the
    schema file to a remote NT system from a UNIX platform.

    Workaround: a schema file must exist, if not create a empty file.
    On UNIX use DOS 8.3 notation for directory names containing spaces. 
    Example:
      d:/progra~1/common~1/interg~1/ris05.04/schemas 
    for the default location of
      d:\program files\common files\intergraph\ris05.04\schemas.
--------------------
End of Open Problems
--------------------
