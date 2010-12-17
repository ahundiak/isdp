<TP>pdm_intro
:Understanding I/PDM:
Before you can use I/PDM-PDU, you must understand the
things that make up the entire I/PDM system.

<S>What is a Product Data Manager (PDM) system?<T>

When multiple workstation users on a network generate and
share sets of files and data, problems arise in organizing and
manipulating the data. For example, conflicting and multiple
revisions can occur if more than one person must manipulate
drawings and other types of CAD data.  There may be no
logical grouping of data to indicate its purpose or use. There
is no access control to the data so that further manipulations
such as the creation of reports or assemblies can occur.

The product data manager (PDM) system is a tool that helps
users manipulate and manage data within a networked
environment.  The PDM system keeps track of the product
information used in product development.

<S>What is I/PDM-PDU?<T>

I/PDM-PDU is a product information system that organizes,
manages, and provides easy access to parts and assemblies in
a networked environment. It keeps track of the location of all
files continuously, and prevents multiple users from
modifying the same file at the same time.

I/PDM runs on a client machine and uses relational databases<T>
on a server machine to store information about parts and
assemblies, including information about the file location.
I/PDU is the user-interface to I/PDM.  I/PDU runs on client
workstations and is integrated with the design environment
to provide access to parts and assembly data.  It facilitates
file movements between the file storage locations and users'
workstations.  I/PDU also supports assembly design
activities.

I/PDM has two types of users: administrative and end-user.

<S>Administrative Duties<T>

The duties of the administrator include:

1.   Installing and initializing software properly.

2.   Organizing access control, users, and files.

     a.   Setting up access control lists (ACLs).

     b.   Adding users.

     c.   Defining nodes and storage areas.

     d.   Designing catalogs.

     e.   Mapping catalogs to ACLs and storage areas.

3.   Setting up reports.

     a.   BOM content.

     b.   BOM format.

     c.   BOM mapping.

4.   Archiving, restoring, and backing up files.

<S>End-user Duties<T>

The duties of the end-user include:

1.   Manipulating parts and files.

     a.   Locating parts on the system.

     b.   Defining search criteria.

     c.   Checking in and out parts.

     d.   Managing local files.

     e.   Modifying part and file information.

2.   Implementing the design process.

     a.   Designing assemblies.

     b.   Locating parts for placement.

     c.   Using part placement options.

     d.   Reviewing assembly structure.

3.   Organizing projects.

4.   Generating reports.

5.   Flagging parts and assemblies.

For related information, see the following topic:<T>

1.   <ST>products  Products Needed to Use I/PDM<T>

2.   <ST>sysover  System Overview<T>

3.   <ST>tac  I/PDM Terms and Concepts<T>


<ETP>
<TP>products
:Products Needed to Use I/PDM:
The following products must be downloaded to use I/PDM.
<F>

Server         Workstation/Client

TCP/IP or      TCP/IP or XNS
XNS
RISCCU         RISCCU
RIS            I/NFM (fileserver & daemon)
RDBMS          I/EMS or I/DRAFT or I/MDS
I/NFM          I/PDU
I/PDM<T>
<S>Note:<T>

The RDBMS can be INFORMIX, ORACLE, INGRES, or DB2.  The
proper RIS product is dependent on the RDBMS and the
hardware platform.  See the RIS README files or RIS product
documentation for more information. <F>„<T>

These products must be set up properly and accessible before
I/PDM-PDU can be installed and used.

This process is described further in the topic: <XR>admsetup Implementing
I/PDM-PDU<T>


<ETP>
<TP>sysover
:System Overview:
The I/PDM system consists of the following components:
database, I/NFM, I/PDM, RIS, design files, and I/PDU.

<X>õ<T>   The database is the basic component of the I/PDM data
     management system.  A database contains information the
     software must have to function along with information
     about catalogs, parts, and assemblies. The database is
     created using a RDBMS chosen from INFORMIX On-line,
     INFORMIX Standard Engine, INGRES, ORACLE, or DB2. When
     first created, the database is empty.  You'll need to set up a
     framework for the part information you will place in the
     database later.

<X>õ<T>   I/NFM populates the database with NFM tables and RIS
     schema tables. These tables are the framework into which
     you insert information about parts, assemblies, and so on.

<X>õ<T>   I/PDM populates the database with I/PDM tables.  Much
     like the NFM tables, these tables will store information
     about catalogs, parts, assemblies, reports, and so on.
     I/PDM uses relational databases to store and manage
     information that is stored in the tables.

<X>õ<T>   Now you have a database that is set up to receive
     information.  You will have chosen your database from the
     choices discussed above. I/PDM needs a way to talk with
     each of the potential RDBMS choices, so it uses RIS.  You
     may never know that you are even using RIS, but when you
     do things like check out a part, you are using RIS. RIS can
     talk to any of the possible database types.

<X>õ<T>   Next, you'll encounter files.  These are files in which
     parts have been created and saved.  The designer (the
     I/PDU user) can now store information about the part and
     about the file's location in the database.

<X>õ<T>   I/PDU lets the designer store the part information and
     file location in the database.  The designer can also find
     out what other parts exist in the system, change existing
     parts, and build assemblies using existing parts.

The products required for I/PDM are layered on one another.
Because the software is layered, most of the tasks done by
the software are transparent to the user.


<ETP>
<TP>tac
:I/PDM Terms and Concepts:
It is very important that you understand several terms and
concepts before you begin using I/PDM.

The operating environment<T> contains a database or databases.
These databases contain catalogs, storage areas, workflows,
ACLs, assemblies and BOMs, and user names.

The operating environment is like your office.  You go to your
office to work because all your equipment is there, as well as
the information you need to do the work.  You can have
several offices if you have several jobs.  In the same way, you
can have several environments if you have several databases.
The database can be thought of as the information you need
to perform your job.  The environment is discussed further in
the Operating Environment Configuration<T> section.

When you initialize I/NFM and I/PDM, the operating
environment is populated with tables.  These tables set up a
framework in the database into which part or file information
will be inserted.  In the office analogy, these tables would be
like the office equipment you use to perform your job.  This
table population process is invisible, but the tables do exist
and they are very delicate.  Users should not use RDBMS tools
to write or delete information from these tables; otherwise,
data integrity may be lost or the database may get corrupted
for use with I/PDM.

The following illustrates an operating environment.  As you
can see the operating environment is located on a server node
and contains a database.  The database contains information
about the components that make up the operating
environment such as workflows, ACLs, catalogs, parts, and
assemblies.

<DG>
help_graphics/config.6
<EG>

                                  Operating Environment

A schema<T> is a collection of information that exists within
each database.  The schema describes the set-up of the
database with respect to the tables contained in the
database, allowable views, and privileges owned by a
database user.  When someone requests action from the
database, RIS handles that request.  Since the schema knows
how the database is set up, it handles the action on behalf of
RIS.

Parts<T> are the smallest data items in the I/PDM system.  A part
can be anything you want to keep track of, such as an I/EMS
design file.  Parts are organized into catalogs<T>, which contain
similar parts or parts that have the same set of attributes.
These attributes might include the part number, part revision,
creator, or creation date.

For related information, see the following topic(s): <XR>addpartfile Adding
Parts and Files<T>.

When catalogs are added, they can be assigned a specific
classification<T>.  This classification groups catalogs based on
their similarities and then separates them by their essential
differences.  For example, business XYZ produces fasteners.
These fasteners can be nuts and bolts.  All parts produced by
the company are similar and could be grouped together in a
classification called fasteners.<T>  However there are essential
differences between nuts and bolts.   To make sure that the
catalogs are grouped correctly, the system administrator can
create two distinct classifications --- nuts<T> and bolts<T>.  For
related information, see the following topic: Catalog
Classifications<T>.

A table<T> is a collection of rows and columns in a database.  A
row is a single record and a column is an attribute about the
record.

A workflow<T> controls access to the parts in a catalog.  The
software is delivered with a default workflow.  This workflow
has built-in access privileges, which enable access to the part
based on its state<T> in the approval cycle and the user classes<T>
that have access to it.

The system administrator creates access control lists (ACLs)<T>
that assign the privileges of the user classes to individual
users and lets users access parts.  The table containing
information for this feature also resides within the operating
environment.


<ETP>
