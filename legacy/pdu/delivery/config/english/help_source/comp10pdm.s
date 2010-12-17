<TP>prjcts
:Project Organization:
I/NFM and I/PDM provide a way for you to organize the
different design projects you are working on.  In I/NFM, you
can define a project<T>, which is simply a grouping of parts and
assemblies being used in a particular design project.  For
example, you are designing two types of boats: a sailboat and
a speedboat.  You could define a project called sailboat and
one called speedboat.  Within the speedboat project, you
could list all the parts and assemblies that are being used on
the speedboat.  You can do the same for the sailboat project.
You can use these projects to generate lists and reports that
are similar to sets.  Projects are just one way of organizing
design project information.  You can also use catalog
classifications to organize design project information.

All projects are created and managed through I/NFM.  You use
I/PDM to add parts to a project and to list projects and their
contents.

<S>The Relationship of Workflows and Projects<T>

Since projects are one of the ways in which you can organize
information, they have workflows that are separate from
other workflows associated with catalogs.

Each project has one workflow, but the parts mapped to the
project can belong to other workflows as well as to the
project's workflow. This implies that you can manipulate a
part in different ways depending on the workflows to which it
may be assigned.  However, if a part/assembly is owned by
one project, it cannot be owned by other projects.  The
part/assembly can only be referenced by the other projects.
The part/assembly can still be owned by other non-project
workflows.

The project workflow and ACL limit access to commands and
parts, just as they do for catalogs. A designer might be limited
to using only design commands on a part within the project.
However, since that part can belong to other workflows, the
designer might be able to design and<T> manage the part in
another workflow.

Another way of restricting projects is through project
mapping<T>. Project mapping restricts the parts that can be
added to a project.  In other words, mapping defines a
membership criteria for parts that can be placed in the project.

<H>Project Manipulation<T><T>

Project manipulation commands let you add new projects to
I/PDM and manipulate projects and their contents.

A part can be added to a project at either part creation time or
anytime thereafter.  An existing part with no project
association can be added to a project only if it belongs to a
qualifying catalog and follows the workflow assigned to the
project.

Any part that you add to I/PDM while you have a project active
is associated with that active project and must follow the
workflow for the project.

You cannot add a part to a project, if the part does not meet
the project's membership criteria.

<S>Related Commands<T>

<XR>PDAdPrPj
Add Part To Project<T>

<H>Project Mapping<T><T>

Projects can be mapped to specified ACLs and storage areas.
Mapping a project is the same as mapping a catalog.  If you
map a project to an ACL, access to that project and the
contents of that project is limited to the access restrictions
defined in the ACL.  When a project is mapped to a specific
storage area, internal file storage locations are restricted to
that storage area.

<S>Note:<T>

Before a project can be mapped to a catalog, the catalog must
be first mapped to a storage location. <F>„<T>

<H>Project Flagging<T><T>

A project can be flagged for archive, backup or restore.
Project flagging works much like part flagging.  The project
must be flagged for archive, backup or restore and then the
selected utility is processed on the flagged project.  You can
cancel a flag on a project anytime before the request is
processed.


<ETP>
