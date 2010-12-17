<TP>PDDcPr
:Save & Exit:
This command deactivates and saves the part that is retrieved
for design.

<S>Before Using This Command<T>

The part must be retrieved for design.

<S>Operating Sequence<T>

1.   Select the Save & Exit<T> button on the Design Operations<T>
     form.

     Save and exit design(y/n)[y]?<T>

2.   Press <Return> to exit design and save the part.

                                              OR

3.   Key in n<T> and press <Return> to remain in design.


<ETP>
<TP>PDDcChInPr
:Save, Exit & Checkin:
This command deactivates the part that is retrieved for design
and then checks the part into the database.

<S>Before Using This Command<T>

A part must be retrieved for design.

1.   Select the Save, Exit & Checkin<T> button on the Design
     Operations<T> form.

     Exit, Save and Checkin(y/n)[y]?<T>

2.   Press <Return> to save and check in the part.

                                              OR

3.   Key in n<T> and press <Return> to remain in the design
     session.


<ETP>
<TP>PDShBOMp
:Show BOM Mapping:
This command displays the current BOM mapping.  You can
review the attributes that are included, along with their data
types and sizes and synonyms.

<S>Before Using This Command<T>

A BOM must have been created and the report name for the
BOM must appear in the Report Format Name<T> field of the
Reports<T> form.

<S>Operating Sequence<T>

1.   Select the BOM Mapping<T> button on the Reports<T> form.

     The BOM Contents/Mapping<T> form appears displaying the
     mapping of the BOM.

     For more information, see the Define BOM Mapping<T>
     command.


<ETP>
<TP>PDShLsBO
:Show List of BOMs:
This command lets you view a list of BOMs along with the
catalogs, parts, revision, and creation date corresponding to
each BOM table.

<S>Before Using This Command<T>

At least one BOM must exist.

<S>Operating Sequence<T>

1.   Select the Reports<T> button from the Management<T> palette of
     the PDM/PDU<T> form.

     The Reports<T> form appears.

2.   Set the Part Selection/Existing BOM Selection<T> toggle to
     Existing BOM Selection.<T>

     A list of BOMs is displayed on the form.

<S>Note:<T>

     You can use the Delete<T> button on this form to delete a BOM. <F>
      „<T>


<ETP>
<TP>PDShLsCt
:Show List of Catalogs:
This command displays a list of all catalogs available. You can
use this command to view a list of I/PDM catalogs or to select
a catalog to make it active.  This command can be executed in
two ways:

1.   By selecting the List<T> button next to the Catalog<T> field in the
     Part Selection<T> palette on the various forms. Selecting the
     List<T> button displays a list of classifications and any
     catalogs that do not belong to a classification.  You can
     select a classification to display a list of catalogs within
     the classification.

2.   By selecting the Display Catalogs<T> entry under the L<T>
     buttons on the Part Selection<T> form.

<S>Operating Sequence<T>

The following is the operating sequence for the second
method:

1.   Select the L1<T> button on the Part Selection<T> form.

     A form displays the entry, Display Catalogs,<T> and a list of
     classifications.

2.   Select the Display Catalogs<T> entry from the form.

     A list of all catalogs in the database appears.

<S>Note:<T>

If you select the L2<T> button, a list of all catalogs under that
classification is displayed. <F>„<T>


<ETP>
<TP>PDShLsLcFl
:Show List of Local Files:
When you copy a file to local or attach reference files, you are
essentially getting a copy of a file with read-only file
permissions. The Show List of Local Files<T> command allows
you to review a complete list of files that are currently local
and the files that have been checked out by the user.

<S>Before Using this Command<T>

You can control the files that appear by using the Local File
List Type<T> roll-through list.  The possible values for this list are:

1.   All Local Files<T> --- Shows all local files that are checked out,
     copied, or copied for reference.

2.   Checked In<T> --- Shows all local files that have been checked
     in by the user in the past.

3.   Checked Out<T> --- Shows all local files that the user has
     checked out.

<S>Operating Sequence<T>

1.   Set the Local File List Type<T> roll-through list on the
     PDM/PDU<T> to the appropriate value.

2.   Select the List of Local Files<T> button on the PDM/PDU<T> form.

     The files are displayed in the List of Parts/Files<T> palette of
     the PDM/PDU<T> form.


<ETP>
<TP>PDShLsPrIn
:Show List of Parts In Catalog:
This command displays the contents of the catalog appearing
in the Part Selection<T> area of the PDM/PDU<T> form and lets you
select a part to place in the Part Selection<T> area.

There are two methods for executing this command.  In both
methods, you must enter a catalog name in the Catalog<T> field
of the Part Selection<T> palette of the PDM/PDU<T> form before
executing the command.  The two methods are:

1.   To select the List<T> button next to the Part Number<T> field in
     the Part Selection<T> palette of the PDM/PDU<T> form.  This
     method quickly generates a list that displays only the parts
     found in the catalog.

2.   To select the List of Parts in Catalog<T> button in the List
     Parts/Files<T> palette on the PDM/PDU<T> form. This method
     generates a list that displays information about the part
     including part number, revision, description, file type, and
     file name.

<S>Operating Sequence<T>

To execute this command using the first method:

1.   Enter the catalog name in the Catalog<T> field of the Part
     Selection<T> area of the PDM/PDU<T> form either by key-in or by
     selecting from a list.

2.   Select the List<T> button next to the Part Number<T> field of the
     Part Selection<T> palette of the PDM/PDU<T> form.

     A popup list of the parts found in the catalogs is displayed.

                                              OR

3.   Once the attributes for the catalog are displayed, place a
     data point on the part number attributes.

     A list of parts for that catalog is displayed.

To execute this command using the second method:

1.   Enter the catalog name in the Catalog<T> field of the Part
     Selection<T> area of the PDM/PDU<T> form either by key-in or by
     selecting from a list.

2.   Select the List Parts in Catalog<T> button on the PDM/PDU<T>
     form.

     The list of parts appears in the List of Parts/Files<T> palette on
     the PDM/PDU<T> form.


<ETP>
