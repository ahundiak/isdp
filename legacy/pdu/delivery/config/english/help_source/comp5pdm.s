<TP>ua1
:Organizing Access Control, Users, and Files:
Before any significant work can be done in I/PDM, you need to
understand how I/PDM stores I/EMS design files and how you
gain access to these files.  To understand how this works,
there are a few terms you must learn.

I/PDM uses nodes and storage areas to store I/EMS design
files across the network.  A node<T> is any addressable
component on a network, such as a workstation or VAX,
which can be accessed remotely or locally.  A storage area<T> is
a specific directory on a node where files are stored.

Knowing where these files are stored is not enough.  You
must have access to I/PDM-PDU commands that let you use
these files for assembly design.  I/PDM uses workflows to
control access to these commands.  A workflow<T> provides a
mechanism to control access to parts and assemblies.  It
controls this access through access control lists (ACLs).  An
access control list (ACL)<T> is a list of users divided in user
classes.  A user<T> is the person performing an I/PDM-PDU
command.  A group of commands can be performed by a user
class.<T>  The user must belong to a user class to perform the
commands for the user class.

The following example illustrates the relationship between
workflows, ACLs, user classes and users.  In this example,
there is one workflow, workflow 1<T>.  Workflow 1 contains one
ACL, ACL 1<T>.  ACL1 has two user classes, userclass 1<T> and
userclass 2<T>. Any users that belong to these userclasses has
access to commands associated with the userclass.

<DG>
help_graphics/ua.6h
<EG>

                     Workflow, Access Control, and User Relationship

For related information, see the following topic:<T>

1.   <ST>node_sa  Nodes and Storage Areas<T>

2.   <ST>workflows  Workflows<T>

3.   <ST>acls  Access Control Lists<T>


<ETP>
<TP>node_sa
:Nodes and Storage Areas:
One of the main advantages of using I/PDM as an
organizational tool is its ability to store files on specified
locations throughout the network.  This storage capability is
accomplished using nodes and storage areas.  As discussed
previously, a node<T> is any addressable component on a
network, such as a workstation or a VAX, where a user can
log in remotely or locally.  A storage area<T> is a specific
directory on a node (usually the PDMserver) where I/EMS
files are stored and from which they are retrieved.  A node can
have many storage areas.

I/NFM initialization creates a default node and storage areas.
The workstation where I/NFM is initialized is defined as node
1.  On node 1, one default storage area is created.  This
storage area, NFMFILES, is the default storage area available
for storing I/EMS files.  Other storage areas for files can  be
created as needed.  I/PDM permits many storage areas.  The
system administrator determines the number of storage areas
on a network.

The system administrator decides how files are to be stored.
There are several options:

<X>õ<T>   Files can be stored based on projects ( all files of one
     project stored in one storage area, and the files of another
     project stored in another storage area ).

<X>õ<T>   Files can be stored based on catalogs.

<X>õ<T>   Files can be randomly stored throughout the network.

<X>õ<T>   Files can also be stored in one location, such as a /usr<T>
     partition or on a VAX.

<S>Creating Nodes<T>

You can create other nodes on the I/PDM system.  The nodes
that you create need a valid protocol to be able to
communicate with the other nodes on the network and to
transfer files.  When creating nodes, the system administrator
is prompted to indicate if the node (workstation) has the
TCP/IP<T> product present.  TCP/IP is a network protocol for
transferring files.  If the node has TCP/IP, then I/PDM attempts
to use the TCP/IP method of transferring files to and from that
node.  If the TCP/IP product is not on the node, then XNS
protocol is used to transfer files.  XNS protocol does not
require passwords to transfer files.  TCP/IP does not require
passwords if the nodes are Intergraph nodes.

<S>Creating Storage Areas<T>

You need the following information when creating storage
areas:

<X>õ<T>   System log-in and password

<X>õ<T>   Directory path

<X>õ<T>   Device type.

The system log-in and password must be an existing log-in for
the node where the storage area will be created.  I/PDM will
not create the login. Likewise, the directory path given must
also be an existing directory for the login.  I/PDM does not
create the directory. The device type refers to the node.  For
more information on nodes and device types, refer to the
I/NFM Reference Manual (DDA0013)<T>.

<S>Setting Protections<T>

Creating an I/PDM storage area specifies only that a directory
may store files.  It does not set protections on the directory.
Making sure that system protections are set on the directory
is the job of the system administrator.  The system
administrator must also set passwords on the logins
associated with storage areas.

The storage areas you create are permanent<T> storage areas.
This means the storage area is created to be a permanent
storage location for files.  The first time a part is checked out,
I/PDM creates a working<T> storage area to hold the part and
reference file being worked on.  I/PDM uses the CLIX account
that executed the checkout to create this storage area based
on the default directory for that user account.  The CLIX
storage area remains after the part is checked in.  If a
different CLIX user executes a part checkout, another
temporary storage area is created based on the default
directory for that CLIX account. Although it is called a
temporary storage area, the entry in the database is
permanent.


<ETP>
<TP>workflows
:Workflows:
To fully understand ACLs and user classes, you must also
understand the concept of workflow.

In I/PDM and the underlying product I/NFM, a workflow serves
two purposes:

1.   Defines a series of stages through which an assembly or
     part moves toward a released stage.  The stages are
     referred to as states<T>.

2.   Provides a mechanism by which access to parts or
     assemblies can be controlled in terms of ACLs and their
     user classes.

I/PDM delivers a default workflow, PDM_PART_WORKFLOW,
for parts.  This is the workflow that most I/PDM parts will
follow.

<S>I/PDM Default Workflow<T>

The PDM_PART_WORKFLOW<T> workflow is the default workflow
for parts.  This workflow ACL contains two user classes:

1.   designer

2.   manager

This workflow should be sufficient for most engineering
operations.  The following illustrates the
PDM_PART_WORKFLOW workflow.

<DG>
help_graphics/pdmcyc.7h
<EG>

                                    PDM_PART_WORKFLOW

Since there are only two user classes and three states, this
workflow is very simple to follow.  The designer can
manipulate the part design while it is in the Design in
Progress<T> state.  After the design is completed, it is moved to
the Design Complete<T> state.  This is the state where the
manager either approves or rejects the design. If the
manager approves the design, it moves to the Release<T> state.
Once in the release state, the design cannot be modified.  If
the manager rejects the design, it returns to the Design in
Progress<T> state where the designer can make the necessary
changes to the design.

This is the only workflow delivered with I/PDM, however
I/NFM delivers default workflows for nodes, catalogs,
projects, workflows, and items to follow.

<S>Default Workflows and ACLs<T>

The following is a list of all the workflow and access control
lists that are delivered with the I/NFM and I/PDM software.
Notice this list also gives the user classes that are included in
each workflow.
<F>Workflow     Access       User Class   Function
             Control
             List

NFM              NFM              administrator   Can create,
Administrative   Administrative                   delete, and
                                                  manipulate
                                                  information for
                                                  nodes, storage
                                                  areas, users,
                                                  access control
                                                  lists, and
                                                  reports.  Can
                                                  also perform
                                                  operator
                                                  functions.
                          operator     Can archive,
                                backup, restore
                                       and delete
                                       files.

NFM          NFM          administrator   Can create and
Catalog      Catalog                      manipulate
                                          catalogs.

NFM          NFM          administrator   Can add,
Project      Project                      change,and
                                          delete a
                                          project, and
                                          perform project
                                          manager
                                          functions.
                          proj.        Can map and
                   manager      define members
                                       for a project.

NFM SDP      NFM SDP      administrator   Can load a new
                                          workflow.

NFM Item     NFM Item     designer     Can add and
                                       manipulate
                                       parts, and
                                       approve parts
                                       for supervisor
                                       inspection.
                          supervisor   Can manipulate
                                part after
                                       designer has
                                       approved it.
                                       Can also
                                       approve part
                                       for manager
                                       inspection.
                          manager      Can manipulate
                                part after
                                       supervisor has
                                       approved it.
                                       Can also
                                       release part.
PDM Part     PDM Part     designer     Can add and
                                       manipulate
                                       parts, and
                                       approve parts
                                       for manager
                                       inspection.
                          manager      Can manipulate
                                part after
                                       designer has
                                       approved it.
                                       Can also
                                       release or
                                       reject part.<T>
<S>Note:<T>

I/PDM parts should follow the PDM_PART_WORKFLOW.  The
NFM_ITEM_WORKFLOW is for items that are added through
the I/NFM interface to I/NFM catalogs. <F>„<T>

As mentioned previously, I/NFM prevents you from modifying
the workflows that deal with nodes, projects, and workflows.
However, you can modify the two default workflows that deal
with catalogs, items, and parts.  The three workflows you can
modify are NFM_CATALOG_WORKFLOW,
NFM_ITEM_WORKFLOW, and PDM_PART_WORKFLOW.  These
workflows should only be modified by an experienced I/PDM
system administrator.


<ETP>
<TP>acls
:Access Control Lists:
An access control list (ACL) is an important tool for
controlling part access during the stages of the workflow.  An
ACL defines who (user) can perform what set of commands
(user class) on the part to which the ACL is assigned.  In this
way, the ACL controls user access to I/PDM parts as they
move through the workflow.

<S>What are users?<T>

A user can be the person creating the part or someone other
than the designer, such as a manager.

There is one default user: the nfmadmin<T> user.  This user is
added when I/NFM and I/PDM are initialized.  The nfmadmin
user is usually the administrator, because this user can set up
the user classes.  The nfmadmin user can access any
command in the system.

<S>Note:<T>

Throughout the remainder of this document, the term user
will refer to an I/NFM-I/PDU user login. <F>„<T>

An employee can belong to several user classes as shown in
the example ACLs discussed later.

<S>What are User Classes?<T>

A user class is a designation assigned to a particular group of
commands.  For example, the designation of designer<T> may be
assigned to the user who performs these commands.

Add Part<T>
Change Part<T>
Place Part<T>

Any user who belongs to the designer user class can use
these commands.

In summary, an administrator specifies what kind of user an
employee is to be. In doing so, the administrator is also
specifying what kinds of duties that user can perform.

<S>Examples of ACLs<T>

Consider this example ACL:

Access Control List #1<T>
<F>

User Class        User
designer          David
                  Tracy
manager           Jerri
                  Dean
                  Nicole

<T>
In this ACL, David and Tracy are defined as designers.  Jerri,
Dean, and Nicole are defined as managers.  This ACL
indicates two things, using David and Tracy as examples.

<X>õ<T>   David and Tracy can access the part belonging to this
     ACL.

<X>õ<T>   They can use only the commands that have been
     assigned to designers. For example, as designers, they
     might be able to modify the part, but they cannot approve
     the part modification.  Approval would be a process
     assigned to the managers, Jerri, Dean, and Nicole.
     Likewise, Jerri, Dean, and Nicole might not be able to
     modify the part.

This ACL demonstrates that users can be assigned different
tasks by moving them into a different workflow.

Access Control List #2<T>
<F>

User Class        User
designer          David
                  Jerri
                  Nicole
manager           David
                  Dean

<T>
This ACL permits David to both and design and manage parts
belonging to this ACL.  Jerri and Nicole perform totally
different tasks in ACL #2 than they did in ACL #1.

These examples demonstrate that you can configure users
and user classes in many different ways, thus affecting, on a
part-by-part basis, who can manipulate the part depending on
the ACL to which the part belongs.


<ETP>
