<TP>archive
:Archive, Backup, Restore, and Delete:
It is common practice to save part and assembly information
in the catalog to an off-line media as part of a regular backup
or permanent archive. Whether you are saving information to
a backup or a permanent archive, the part or assembly record
information is kept in the catalog.  When a part or assembly is
archived, the files are physically moved from their I/PDM
storage area to the archive media.  When a part or assembly is
backed up, the file is copied to the archive media. Archived
files can be restored<T> into circulation when needed.  Files that
are no longer needed can be deleted<T> from the system.

There are two steps involved in archive, backup, restore, and
deletion:

1.   The end user indicates which process is to be done by
     flagging<T> the part or assembly accordingly.

2.   The system administrator processes the request on the
     part or assembly.

The actual function is done through I/NFM.  For more
information on archiving, backing up, deleting, and restoring
files, refer to the I/NFM Reference Manual.<T>

<S>Archive<T>

When an assembly is archived, the assembly file is archived to
an off-line device, and the parts that make up the assembly
are backed up.  For example, suppose the following assembly
was flagged for archive:

<DG>
help_graphics/spl0.6h
<EG>

                                    Archived Assembly

When the request for archive is processed, Assembly A is
archived or moved to an off-line device, while Subassembly A,
Part A, and Part B are backed up or copied to the device.

<S>Backup<T>

When a part is backed up, the physical file is copied from the
checkin storage area to a permanent storage area, and the
original file is left in the checkin storage area.

<S>Restore<T>

It may become necessary to retrieve files from the archive
media.  You can restore a file that has been archived. When
you restore a file, the file is physically moved from the archive
media to the checkin storage area.

<S>Deletion<T>

It is very important that you understand how parts are
deleted.  When a flagged part is processed for deletion, the
part is not removed from the catalog.  All part entries remain in
the database tables.  It is important that the I/PDU Delete Part<T>
command be executed to delete the entries from the database
tables.  The following steps describe the deletion process.

1.   User flags part for deletion.

2.   Administrator processes deletion request.

3.   Administrator executes the Delete Part<T> command to
     remove entries from database.

Before an assembly can be deleted, all parts must be
detached from the assembly.  Once the parts have been
detached, the deletion process is the same as for other parts.

<S>Related Commands<T>

<XR>PDFlPrAr
Flag Part for Archive<T>
<XR>PDFlPrRs
Flag Part for Restore<T>
<XR>PDFlPrBc
Flag Part for Backup<T>
<XR>PDFlPrDl
Flag Part for Delete<T>
<XR>PDCnFlAr
Cancel Flag for Archive<T>
<XR>PDCnFlRs
Cancel Flag for Restore<T>
<XR>PDCnFlBc
Cancel Flag for Backup<T>
<XR>PDCnFlDl
Cancel Flag for Delete<T>


<ETP>
