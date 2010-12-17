<TP>PDCnPrChOt
:Cancel Part Check Out:
This command lets you cancel the check out of a part.  You
can cancel a single part check out or multiple part
checkouts.

<S>Before Using This Command<T>

Make sure that the part for which you want to cancel the
check out is shown in the Part Selection<T> palette of the
PDM/PDU<T> form or all the parts which you want to cancel the
checkout are selected in the List Parts/Files<T> palette.

I/PDM checks all files.  If the file is out more than once, the
file is left alone.  If the file is out only once, the filename is
put in a list of files that I/PDU will remove.  For each attached
file in an assembly, if the attached file is no longer needed
locally, the attached file is deleted from the local storage
area.

<S>Operating Sequence<T>

1.   Select the Delete Local File<T> button on the File Operations<T>
     palette on the PDM/PDU<T> form.

2.   Highlight the checked out part(s) for cancellation.  If you
     have more than one part highlighted, the Cancel Part
     Check Out<T> form appears displaying a highlighted list of the
     parts you selected to cancel part check out.

     a.   Unhighlight any parts that you want to remain checked
          out by tapping the middle mouse button on the part.
          Save and exit the form to cancel part checkout of the
          highlighted parts.

                                                 OR

          Dismiss the form to exit the cancel part
                checkout command.

     If there is only one part highlighted for cancel part check
     out, the part is deleted from your workstation without
     being copied to the checkin storage area, and marked in the
     database as checked in.


<ETP>
<TP>PDCnFlAr
:Cancel Flag for Archive:
This command cancels a flag that has been set on a part or
assembly for archival.

<S>Before Using This Command<T>

Make sure that the part whose flag is to be cancelled appears
in the Existing Part<T> palette of the Part Operations<T> form in
Change<T> mode.

<S>Operating Sequence<T>

1.   Select the Flag/Cancel Flag<T> button on the Part Operations<T>
     palette of the Part Operations<T> form.

     The Flag Operations<T> palette appears in the bottom right
     corner of the Part Operations<T> form.

2.   Set the Flag/Cancel Flag<T> toggle on the Flag Operations<T>
     palette to Cancel Flag<T>.

3.   Select the Archive<T> button on the Flag Operations<T> palette.

     Unflag part for archive?(y/n)[y]<T>

4.   Press <Return> to cancel the flag.

     The flag for archive is cancelled.

                                              OR

     Key in n<T> and press <Return> if you do not want to
           unflag the part.

     The flag is not cancelled.


<ETP>
<TP>PDCnFlBc
:Cancel Flag for Backup:
This command cancels a flag that has been set on a part or
assembly for backup.

<S>Before Using This Command<T>

Make sure that the part whose flag is to be cancelled appears
in the Existing Part<T> palette of the Part Operations<T> form in
Change<T> mode.

<S>Operating Sequence<T>

1.   Select the Flag/Cancel Flag<T> button on the Part Operations<T>
     palette of the Part Operations<T> form.

     The Flag Operations<T> palette appears in the bottom right
     corner of the Part Operations<T> form.

2.   Set the Flag/Cancel Flag<T> toggle on the Flag Operations<T>
     palette to Cancel Flag<T>.

3.   Select the Backup<T> button on the Flag Operations<T> palette.

     Unflag part for backup?(y/n)[y]<T>

4.   Press <Return> to cancel the flag.

     The flag for backup is cancelled.

                                              OR

     Key in n<T> and press <Return> if you do not want to
           unflag the part.

     The flag is not cancelled.


<ETP>
<TP>PDCnFlDl
:Cancel Flag for Delete:
This command cancels a flag that has been set on a part or
assembly for delete.

<S>Before Using This Command<T>

Make sure that the part whose flag is to be cancelled appears
in the Existing Part<T> palette of the Part Operations<T> form in
Change<T> mode.

<S>Operating Sequence<T>

1.   Select the Flag/Cancel Flag<T> button of the Part Operations<T>
     palette from the Part Operations<T> form.

     The Flag Operations<T> palette appears in bottom right corner
     of the Part Operations<T> form.

2.   Set the Flag/Cancel Flag<T> toggle on the Flag Operations<T>
     palette to Cancel Flag<T>.

3.   Select the Delete<T> button on the Flag Operations<T> palette.

     Unflag part for delete?(y/n)[y]<T>

4.   Press <Return> to cancel the flag.

     The flag for delete is cancelled.

                                              OR

     Key in n<T> and press <Return> if you do not want to
           unflag the part.

     The flag is not cancelled.


<ETP>
<TP>PDCnFlRs
:Cancel Flag for Restore:
This command cancels a flag that has been set on a part or
assembly for restore.

<S>Before Using This Command<T>

Make sure that the part whose flag is to be cancelled appears
in the Existing Part<T> palette of the Part Operations<T> form in
Change<T> mode.

<S>Operating Sequence<T>

1.   Select the Flag/Cancel Flag<T> button from the Part
     Operations<T> palette on the Part Operations<T> form.

     The Flag Operations<T> palette appears in the bottom right
     corner of the Part Operations<T> form.

2.   Set the Flag/Cancel Flag<T> toggle on the Flag Operations<T> to
     Cancel Flag<T>.

3.   Select the Restore<T> button on the Flag Operations<T> palette.

     Unflag part for restore?(y/n)[y]<T>

4.   Press <Return> to cancel the flag.

     The flag for restore is cancelled.

                                              OR

     Key in n<T> and press <Return> if you do not want to
           unflag the part.

     The flag is not cancelled.


<ETP>
<TP>PDCCt
:Change Catalog:
This command lets you add or change static and dynamic
attributes along with their datatypes and synonyms in an
existing catalog.  You can also change the catalog
description, type, attribute order, and the classification for a
catalog.  You cannot, however, change the catalog name.  See
Copy Catalog<T> for changing catalog names.

<S>Before Using This Command<T>

Make sure the catalog you want to change appears in the
Catalog Name<T> field of the Catalog Operations<T> form in Change<T>
mode.

<S>Operating Sequence<T>

1.   If you want to change the classification for a catalog or
     add a catalog to a classification.

     a.   Enter the new classification for the catalog in the
          Classification<T> palette.

     b.   Select the Update Class<T> button on the Catalog
          Operations<T> form.

          The catalog now appears in the new classification.

2.   If you want to change the catalog description, edit the
     description on the Catalog Operations<T> form.

3.   Select the Save and Exit<T> button on the Catalog Operations<T>
     form.

     The Catalog Attributes<T> form appears.

4.   Select the Static<T> or Dynamic<T> button at the top of the form
     to indicate the type of attribute to be changed or added.

5.   If you want to add new attributes:

     a.   Enter the information about the new attribute in the
          Attribute Information<T> palette.

          For more information about adding attributes, refer to
          the section Creating Catalogs<T>.

     b.   Select the Add Attribute<T> button in the Attribute
          Commands<T> palette of the Catalog Attributes<T> form.

          The attribute is added to the list of attributes for the
          catalog.

6.   If you want to change an existing attribute's synonyms or
     default values:

     a.   Highlight the attribute you want to change.

          The attribute appears in the Attribute Information<T>
          palette of the Catalog Attributes<T> form.

     b.   Make the changes to the attribute displayed in the
          Attribute Information<T> palette.

     c.   Select the Change Attribute<T> button in the Attribute
          Commands<T> palette of the Catalog Attributes<T> form.

          The changes are made to the attribute.

7.   If you want to change the attribute order for the attribute:

     a.   Remove the value for the attribute order from the Order<T>
          field.

     b.   Key in the new value for the attribute order in the Order<T>
          field and press <Return>.

          The order for the attributes is changed.

8.   Save and exit the form.

     The Catalog Operations<T> form reappears.


<ETP>
<TP>PDCPr
:Change Part:
This command lets you change the part type, part description,
file information, and attributes that have protections set to
read/write.  These attributes can be denoted by the color of
the field. You cannot change the part number or revision with
this command.  This command also lets you add files.

<S>Before Using This Command<T>

Make sure the catalog containing the part to be changed
appears in the Existing Part<T> palette of the Part Operations<T>
form in Change<T> mode.

<S>Operating Sequence<T>

1.   Enter the part to be changed into the Part Number<T> field of
     the Existing Part<T> palette of the Part Operations<T> form in
     Change<T> mode.

     The read/write attributes for the part appear in the Part
     Attribute Values<T> palette of the Part Operations<T> form and
     information about the existing file for the part appears in
     the Existing Files<T> field of the File Information<T> palette.

2.   Make any changes to the information in the Existing Files<T>
     fields.

3.   Make any changes to the values for the attributes
     appearing in the Part Attribute Values<T> palette.

<S>Note:<T>

     Remember, this is not all of the attributes for the part.  This
     is only the read/write attributes. <F>„<T>

4.   If you want to add other files to the part, you can enter the
     description, local filename, storage filename and file type
     for the file(s) to be added into the New Files<T> fields. Before
     you can add a new file to the part, the existing file must be
     checked out if one has been checked in.

5.   You can also move the part to a new state while in Change<T>
     mode of the Part Operations<T> form.  For more information on
     moving the part to a new state, refer to the Approve Part<T>
     command.

6.   After you have made your changes to the part, select the
     Change/Add Files<T> button from the Part Operations<T> palette
     of the Part Operations<T> form in Change<T> mode.

     The changes are made to the part.


<ETP>
<TP>PDCPrPr
:Change Parametric Part:
This command lets you change any of the read/write
attributes of an existing parametric part.  You can use
commands on the Spreadsheet Operations<T> palette of the
Parametric Part Operations<T> form to make changes to these
attributes

<S>Before Using This Command<T>

Make sure the catalog containing the part to be changed
appears in the Catalog<T> field of the Parametric Part Operations<T>
form in Change<T> mode.

<S>Operating Sequence<T>

1.   Make sure the attribute information for the part to be
     changed appears in the respective attribute value fields
     under the Classification<T> button.

2.   If more than one part appears in this area, place a data
     point next to the part to be changed.

3.   Make any changes to the values appearing in the attribute
     fields.

4.   After you have made your changes to the part, select the
     Change<T> button from the Part Commands<T> palette of the
     Parametric Part Operations<T> form in Change<T> mode.

     The changes are made to the part.

<S>Note:<T>

You can also use this form to move the parametric part to a
new state or delete a parametric part. <F>„<T>


<ETP>
<TP>PDChInPr
:Check In Part:
This command sends a part's file to its storage location and
deletes the local file.

<S>Note:<T>

A part can only be checked in by the user who checked it out. <F>
 „<T>

<S>Before Using This Command<T>

I/PDM lets you check in a single part or an entire list of parts.
If you want to check in a single part, the part to be checked in
must appear in the Part Selection<T> palette of the PDM/PDU<T>
form. The part to be checked in can be entered by key-in,
selected from the list generated by selecting the List<T> button
next to the Part Number<T> field, or selected from the List of
Parts/Files<T> palette.

If you want to check in a list of parts, the parts to be selected
for check in must appear in the List of Parts/Files<T> palette.

For the assembly file, I/PDM checks for references to the file
as an attachment in other assemblies.  If the file is local in the
current storage area, the system does nothing to the file.  If it
is not referenced in another assembly in the current directory,
the file is checked in and the local file is deleted.  For each
attached file in the assembly, if the attached files are no
longer needed, the local file is deleted.

<S>Operating Sequence<T>

To check in a single part:

1.   Make sure the part to be checked in appears in the Part
     Selection<T> palette of the PDM/PDU<T> form.  This can be done
     by key-in, by selecting the part from a list generated by
     selecting the List<T> button next to the Part Number<T> field, or
     by selecting the List Parts in Catalog<T> button from the List
     Parts/Files<T> palette of the PDM/PDU<T> form and selecting the
     part.

2.   Select the Check In<T> button from the File Operations<T> palette
     on the PDM/PDU<T> form.

     The part is sent to the storage location and removed from
     the workstation.

To check in a list of files:

1.   Make sure the parts to be checked in appear in the List of
     Parts/Files<T> palette.

2.   Highlight the parts to be checked in.

     The last part highlighted appears in the Part Selection<T>
     palette.

3.   Select the Check In<T> button from the File Operations<T> palette
     on the PDM/PDU<T> form.

     The parts are sent to the storage locations and removed
     from the workstation.


<ETP>
<TP>PDCpCt
:Copy Catalog:
This command creates a new catalog by copying the structure
for an existing catalog and lets you add or change static and
dynamic attributes for the new catalog.

<S>Before Using This Command<T>

Make sure the catalog to be copied appears in the Template
Catalog<T> field and the Catalog Type<T> toggle is set properly on
the Catalog Operations<T> form in New<T> mode.

<S>Operating Sequence<T>

1.   Enter a new catalog name and description in the
     appropriate fields.

2.   If the new catalog is to be placed in a classification, enter
     information about the classification in the Classification<T>
     section.

     For more information, see the section, Catalog
     Classifications.<T>

3.   Select the Save and Exit<T> button on the Catalog Operations<T>
     form.

     The Catalog Attributes<T> form appears.

4.   Make any changes to the attributes for the catalog.

     For more information, see the Change Catalog<T> command.

5.   Add any attributes needed to the catalog.  For more
     information see the Create Catalog<T> command.

6.   Select the Save and Exit<T> button on the Catalog Attributes<T>
     form.

     The Catalog Operations<T> form is redisplayed and the catalog
     is copied.


<ETP>
<TP>PDCpPr
:Copy Part:
This command duplicates a pointer and graphics reference
file attachment of a part in an assembly file.

<S>Before Using This Command<T>

A file with part pointers placed must be active for design.

<S>Note:<T>

If the part has multiple views, a form displaying a list of the
views will appear when you identify the part.  You can then
select the desired view for the part. <F>„<T>

<S>Operating Sequence<T>

1.   Select the Copy Part<T> button from the Design Operations<T>
     form.

     Identify Part/Reset for list<T>

2.   Select the part pointer to be copied or select the right
     mouse button for a list of parts in the active design.

     If you select the part pointer:<T>

     The part pointer highlights.

     Accept/Reject part<T>

     a.   Enter the data point for the new part pointer.

          The part pointer is copied and the Design Operations<T>
          form redisplays.

     If you select the right mouse button for a list:<T>

     a.   Highlight one or more parts and select the Save and
          Exit<T> button to copy the parts.

          The part is copied and the Design Operations<T> form
          redisplays.


<ETP>
<TP>PDCrBOAcPr
:Create BOM:
This command generates a report in which like parts are
summed at each sub-assembly level.

<S>Before Using This Command<T>

A format must be defined for the report and the assembly
being used in the report must be checked in.

<S>Operating Sequence<T>

1.   Select the BOM<T> button on the Reports<T> form.

2.   Enter the format name in the Report Format Name<T> field.
     This name can be entered by key-in or selected from the list
     generated by selecting the List<T> button next to the field.
     This report name can also be a format created in RIS.

     To use a report format created in RIS:

     a.   Make sure the RIS template file resides in the directory
          from which EMS was executed.

     b.   Enter the template file name in the Report Format Name<T>
          field.

     c.   Select the Import RIS<T> button.

          The template file is copied to
          /usrx/nfmadmin/<environment name>/pdmreports<T>
          directory.  Once in this directory, the name will appear in
          the list generated by the List<T> button next to the Report
          Format Name<T> field.

3.   Make sure the Part Selection/Existing BOM Selection<T>
     toggle is set to Part Selection<T>.

4.   Enter the catalog name, part number, part revision, and
     part description for the assembly that you want to create a
     BOM for in the Part Selection<T> palette.

<S>Note:<T>

     You can use the Search<T> button to search for the desired
     assembly. <F>„<T>

5.   If you want to save the report to a file for printing, set the
     Don't Save To File/Save To File<T> toggle to Save To File<T>.

6.   If you want to save the report to a file, enter the full path in
     the Output Filename<T> field.  If you only enter a filename, the
     report will be saved to a file in the current working
     directory.

7.   Select the Create<T> button at the bottom of the Reports<T> form.

     The BOM<T> report is created and displayed.

8.   Select the quit<T> button to cancel the report and return to
     the Reports<T> form.


<ETP>
<TP>PDCrWhUsAs
:Create BOM Where Used Immediate:
This command generates a list of all assemblies and
sub-assemblies where the part occurs at the first level.  It
either uses an existing report format or lets the user create
one before processing the report information.

<S>Before Using This Command<T>

A format must be defined for the report.

<S>Operating Sequence<T>

1.   Select the Where Used Immediate<T> button on the Reports<T>
     form.

2.   Enter the format name in the Report Format Name<T> field.  If
     a predefined format does not exist for the name add it to
     the list of formats through the Define Report Format<T> form.
     This name can be entered by key-in or selected from the list
     generated by selecting the List<T> button next to the field.
     This report name can also be a format created in RIS.

     To use a report format created in RIS:

     a.   Make sure the RIS template file resides in the directory
          from which EMS was executed.

     b.   Enter the template file name in the Report Format Name<T>
          field.

     c.   Select the Import RIS<T> button.

          The template file is copied to
          /usrx/nfmadmin/<environment name>/pdmreports<T>
          directory.  Once in this directory, the name will appear in
          the list generated by the List<T> button next to the Report
          Format Name<T> field.

3.   Enter the catalog name, part number, and part revision for
     the selected part in the Part Selection<T> palette of the
     Reports<T> form.

<S>Note:<T>

     You can use the Search<T> button to search for the desired
     part. <F>„<T>

4.   If you want to save the report to a file for printing, set the
     Don't Save To File/Save To File<T> toggle to Save To File<T>.

5.   If you want to save the report to a file, enter the full path in
     the Output Filename<T> field.  If you only enter a filename, the
     report will be saved to a file in the current working
     directory.

6.   Select the Create<T> button at the bottom of the Reports<T> form.

     The Where Used Immediate<T> report is created and displayed.

7.   Select the quit<T> button to cancel the report and return to
     the Reports<T> form.


<ETP>
<TP>PDCrWhUsHL
:Create BOM Where Used at Highest Level:
This command generates a list of all assemblies in which the
part occurs.  It uses either an existing report format or lets
the user create a format before generating the report.

<S>Before Using This Command<T>

A list format must be defined for the report and the part used
in the report must be checked in.

<S>Operating Sequence<T>

1.   Select the Where Used Highest Lvl<T> button on the Reports<T>
     form.

2.   Enter the report name in the Report Format Name<T> field.  If a
     predefined format does not exist for the name, add it to the
     list of formats through the Define Report Format<T> form.  This
     name can be entered by key-in or selected from a list
     generated by selecting the List<T> button next to the field.
     This report can also be a format create in RIS.

     To use a report format created in RIS:

     a.   Make sure the RIS template file resides in the directory
          from which EMS was executed.

     b.   Enter the template file name in the Report Format Name<T>
          field.

     c.   Select the Import RIS<T> button.

          The template file is copied to
          /usrx/nfmadmin/<environment name>/pdmreports<T>
          directory.  Once in this directory, the name will appear in
          the list generated by the List<T> button next to the Report
          Format Name<T> field.

3.   Make sure the Part Selection/Existing BOM Selection<T>
     toggle is set to Part Selection.<T>

4.   Enter the catalog name, part number and part revision for
     the part to be used in the report in the Part Selection<T>
     palette of the Reports<T> form.

<S>Note:<T>

     You can select the Search<T> button to search for the desired
     part. <F>„<T>

5.   If you want to save the report to a file for printing, set the
     Don't Save To File/Save To File<T> toggle to Save To File<T>.

6.   If you want to save the report to a file, enter the full path in
     the Output Filename<T> field.  If you only enter a filename, the
     report will be saved to a file in the current working
     directory.

7.   Select the Create<T> button at the bottom of the Reports<T> form.

     The Where Used at Highest Level<T> report is created and
     displayed.

8.   Select the quit<T> button to cancel the report and return to
     the Reports<T> form.


<ETP>
<TP>PDCrCt
:Create Catalog:
This command creates standard or parametric catalog with
static and dynamic attributes defined by the user.

<S>Note:<T>

You can change the synonyms of any user-defined attributes
and add new attributes at a later time. The catalog names can
be either upper or lower case characters and can be up to 14
characters long.  A catalog cannot be created beginning with
ris.<T>  Catalog attributes can be up to 20 characters long. <F>„<T>

<S>Before Using This Command<T>

Make sure that the New<T> button is selected on the Catalog
Operations<T> form.

<S>Operating Sequence --- Parametric Catalog<T>

1.   Set the Catalog Type<T> toggle to Parametric<T>.

2.   Enter the catalog name and description in the appropriate
     fields of the Catalog Operations<T> form.

3.   I/PDM provides a default ACL named NFM_CATALOG_ACL.

4.   You can enter a default usage id in the Default Usage ID<T>
     field. This is the id that will be used for all parts added to
     the catalog that are placed in an assembly.

5.   To add classifications for this catalog, continue to the
     next step.  If you do not want to add classifications, go to
     step 9.

6.   Place a data point in the Catalog Classification<T> palette.

     A small subform displays an entry, new category<T>, followed
     by a list of available classifications.  If no classifications
     exist, new category<T> is the only entry listed on the subform.

7.   If no classifications exist or the desired classification
     does not exist:

     a.   Select the new category<T> entry from the list.

     b.   Key in the name of the classification and press
          <Return>.

     c.   Repeat steps 9a and 9b to add any lower level
          classifications that might be needed.

8.   If the desired classification already exists:

     a.   Highlight the desired classification name from the list.

          The list disappears and the classification name appears
          in the Catalog Classification<T> palette.

     b.   Repeat this step as necessary.

     c.   Save and exit the Catalog Operations<T> form and save the
          information.

          The Parametric Attributes<T> form appears.

     d.   Place a data point in the Macro Library<T> field of the
          Parametric Attributes<T> form.

          The Part Selection<T> form appears.

     e.   Enter the catalog that contains the desired macro in the
          Catalog<T> field.

     f.   Place a data point on the Part Number<T> row under the
          Attribute<T> column.

          A list of part numbers is displayed.

     g.   Select the desired macro part.

     h.   Select the Search<T> button.

     i.   Save and exit the Part Selection<T> form.

          The macro information appears in the Macro Library<T>
          field of the Parametric Attributes<T> form.

     j.   Place a data point on the Macro Name<T> field of the
          Parametric Attributes<T> form.

          If there is only one macro, the name is displayed in the
          Macro Name<T> field. If there is more than one macro, a list
          is displayed for you to select the desired macro.

<S>Note:<T>

          If you are using a sketch file, you can enter the name for
          the sketch in the Sketch File Name<T> field. <F>„<T>

     k.   Save and exit the form.

          The Catalog Attributes<T> form appears.

          This form lets you change the synonyms  of the required
          attributes, add user-defined attributes, assign values to
          attributes, and assign protections to the attributes.

9.   If you want to add new attributes to the catalog continue
     with this step.  If you do not want to add new attributes, go
     to step 10.

     a.   Select the Static<T> or Dynamic<T> button to indicate the type
          of attributes to be added.

     b.   Key in the attribute name, datatype, synonym, and
          default value for the new attribute in the Attribute
          Information<T> palette.

          The Range<T> and List<T> buttons let you assign either a range
          of values  or a list of possible values for the attribute.
          You can enter these values before you add or change the
          attribute for the catalog.  The Function<T> button lets you
          enter a function which can generate values for the
          attribute.

     c.   Set the protections for the attribute by setting the
          toggles in the Protections<T> palette to Yes<T> or No<T>.

          For more information on attributes, refer to the section,
          Catalogs,<T> in this document.

     d.   Once you have entered the information about the
          attribute, select the Add Attribute<T> button on the
          Attribute Commands<T> palette of the Catalog Attributes<T>
          form.

          The attribute appears in the area at the top of the form.

          You can list the system attributes for the catalog by
          setting the Show System Attributes<T> toggle to Yes<T>.

     e.   Repeat steps 9b - 9d to add additional attributes.

10.  Select the Save and Exit<T> button to create the catalog.

     The form disappears and the catalog is created.

     <S>Operating Sequence --- Standard Catalog<T>

11.  Set the Catalog Type<T> toggle to Standard<T>.

12.  Enter the catalog name and description in the appropriate
     fields of the Catalog Operations<T> form.

13.  I/PDM provides a default ACL named NFM_CATALOG_ACL.

14.  To add classifications for this catalog, continue to the
     next step.  If you do not want to add classifications, go to
     step 18.

15.  Place a data point in the Catalog Classification<T> palette.

     A small subform displays an entry, new category<T>, followed
     by a list of available classifications.  If no classifications
     exist, new category<T> is the only entry listed on the subform.

16.  If no classifications exist or the desired classification
     does not exist:

     a.   Select the new category<T> entry from the list.

     b.   Key in the name of the classification and press
          <Return>.

     c.   Repeat steps 16a and 16b to add any lower level
          classifications that might be needed.

17.  If the desired classification already exists:

     a.   Highlight the desired classification name from the list.

          The list disappears and the classification name appears
          in the Catalog Classification<T> palette.

     b.   Save and exit the Catalog Operations<T> form and save the
          information.

          The Catalog Attributes<T> form appears.

          This form lets you change the synonyms  of the required
          attributes, add user-defined attributes, assign values to
          attributes, and assign protections to the attributes.

18.  If you want to add new attributes to the catalog continue
     with this step.  If you do not want to add new attributes, go
     to step 19.

     a.   Select the Static<T> or Dynamic<T> button to indicate the type
          of attributes to be added.

     b.   Key in the attribute name, datatype, synonym, and
          default value for the new attribute in the Attribute
          Information<T> palette.

          The Range<T> and List<T> buttons let you assign either a range
          of values  or a list of possible values for the attribute.
          You can enter these values before you add or change the
          attribute for the catalog.  The Function<T> button lets you
          enter a function which can generate values for the
          attribute.

     c.   Set the protections for the attribute by setting the
          toggles in the Attribute Protections<T> palette to Yes<T> or No<T>.

          For more information on attributes, refer to the section,
          Catalogs,<T> in this document.

     d.   Once you have entered the information about the
          attribute, select the Add Attribute<T> button on the
          Attribute Commands<T> palette of the Catalog Attributes<T>
          form.

          The attribute appears in the area at the top of the form.

          You can list the system attributes for the catalog by
          setting the Show System Attributes<T> toggle to Yes<T>.

     e.   Repeat steps 18b - 18d to add additional attributes.

19.  Save and exit the form to create the catalog.

     The form disappears and the catalog is created.


<ETP>
<TP>PDCrExBOFr
:Create Exploded BOM:
This command generates an exploded bill of materials for the
part shown in the Part Selection<T> palette of the Reports<T> form.

<S>Before Using this Command<T>

A format must be defined for the report and the assembly
being used in the report must be checked in.

<S>Operating Sequence<T>

1.   Select the Exploded BOM<T> button on the Reports<T> form.

2.   Enter the format name in the Report Format Name<T> field.
     This name can be entered by key-in or selected from the list
     generated by selecting the List<T> button next to the field.
     This report name can also be a format created in RIS.

     To use a report format created in RIS:

     a.   Make sure the RIS template file resides in the directory
          from which EMS was executed.

     b.   Enter the template file name in the Report Format Name<T>
          field.

     c.   Select the Import RIS<T> button.

          The template file is copied to
          /usrx/nfmadmin/<environment name>/pdmreports<T>
          directory.  Once in this directory, the name will appear in
          the list generated by the List<T> button next to the Report
          Format Name<T> field.

3.   Make sure the Part Selection/Existing BOM Selection<T>
     toggle is set to Part Selection<T>.

4.   Enter the catalog name, part number and part revision for
     the assembly in the Part Selection<T> palette.

<S>Note:<T>

     You can use the Search<T> button to search for the desired
     assembly. <F>„<T>

5.   If you want to save the report to a file for printing, set the
     Don't Save To File/Save To File<T> toggle to Save To File<T>.

6.   If you want to save the report to a file, enter the full path in
     the Output Filename<T> field.  If you only enter a filename, the
     report will be saved to a file in the current working
     directory.

7.   Select the Create<T> button at the bottom of the Reports<T> form.

     The Exploded BOM<T> report is created and displayed.

8.   Dismiss the report and return to the Reports<T> form.


<ETP>
<TP>PDCrNnAs
:Create Nongraphic Assembly:
This command lets you define an assembly structure by
supplying information about each component of the
assembly: catalog, part number, revision, quantity, and usage
information.  This command lets you modify an existing
assembly structure or define a new structure.

<S> Before Using This Command<T>

Make sure an assembly part has been added.

<S>Operating Sequence<T>

To add parts to an assembly:

1.   Select the Assembly Structure<T> button from the
     Management<T> palette of the PDM/PDU<T> form.

     The Define/Modify Assembly Structure<T> form appears.

2.   The part to be added to the assembly can be entered by
     key-in or by selecting from a list that is generated by
     selecting the List<T> button next to the Part Number<T> field of
     the Assembly Selection<T> palette of the Define/Modify
     Assembly Structure<T> form.

3.   If the Key in Part/Select from List<T> toggle is set to Key in
     Part<T>:

     a.   Enter information about the parts to be placed in the
          assembly in the fields below the Key in Part/Select from
          List<T> toggle.  You can key in the part number or select
          from a list generated by selecting the List<T> button next to
          the Part Number<T> field.

     b.   You can select the Placement Options<T> button to set
          options for placing the part.

          For more information, refer to the section Placement
          Options Form.<T>

          The Placement Options<T> form appears.

     c.   Select the desired options and save and exit the
          Placement Options<T> form.

     d.   Select the Place<T> button on the Define/Modify Assembly
          Structure<T> form.

          The part is added to the assembly.

4.   If the Key in Part/Select from List<T> toggle is set to Select
     from List<T>:

     a.   Select the Search<T> button on the Define/Modify
          Assembly Structure<T> form.

          The Part Selection<T> form appears.

     b.   Define the search criteria.

          For more information, see the command, Define Search
          Criteria.<T>

     c.   Check off the Part Selection<T> form.

          The Key in Part/Select from List<T> toggle on the
          Define/Modify Assembly Structure<T> is set to Select from
          List<T> and the results from the search are displayed in the
          Part Selection<T> area.

     d.   Select the parts from this list to be placed in the
          assembly.

5.   Select the Placement Options<T> button to review the options
     for placing the part.

6.   After you have set the options, save and exit the
     Placement Options<T> form.

7.   Select the Place<T> button on the Define/Modify Assembly
     Structure<T> form.

     The part is added to the assembly.

8.   Repeat steps 4 -7 until you have completed the assembly
     structure.

9.   Select the Process<T> button on the Define/Modify Assembly
     Structure<T> form to save the assembly structure.

10.  Exit the form to return to the PDM/PDU<T> form.

To delete parts from an assembly:

1.   Select the Assembly Structure<T> button from the
     Management<T> palette of the PDM/PDU<T> form.

     The Define/Modify Assembly Structure<T> form appears.

2.   Make sure the assembly structure appears in the
     Assembly Structure<T> palette of the Define/Modify Assembly
     Structure<T> form.

     The parts that make up the assembly are listed in the
     Assembly Structure<T> of the Define/Modify Assembly
     Structure<T> form.

3.   Highlight the part to be deleted from the assembly.

4.   Select the Delete<T> button.

     Delete part selected in Assembly Structure (y/n)? [y]<T>

5.   Press <Return> to delete the part.

                                              OR

     Key in n<T> to not delete the part from the assembly.

6.   Select the Process<T> button on the Define/Modify Assembly
     Structure<T> form.

7.   Exit the Define/Modify Assembly Structure<T> form and return
     to the PDM/PDU<T> form.


<ETP>
<TP>PDCrPtCtFr
:Create Parts In Catalog:
This command generates a report which lists the parts in the
catalog displayed in the Part Selection<T> palette of the Reports<T>
form.

<S>Before Using this Command<T>

A format must be defined for the report.

<S>Operating Sequence<T>

1.   Select the Parts in Catalog<T> button on the Reports<T> form.

2.   Enter the format name in the Report Format Name<T> field.
     This name can be entered by key-in or selected from the list
     generated by selecting the List<T> button next to the field.
     This report name can also be a format created in RIS.

     To use a report format created in RIS:

     a.   Make sure the RIS template file resides in the directory
          from which EMS was executed.

     b.   Enter the template file name in the Report Format Name<T>
          field.

     c.   Select the Import RIS<T> button.

          The template file is copied to
          /usrx/nfmadmin/<environment name>/pdmreports<T>
          directory.  Once in this directory, the name will appear in
          the list generated by the List<T> button next to the Report
          Format Name<T> field.

3.   Make sure the Part Selection/Existing BOM Selection<T>
     toggle is set to Part Selection<T>.

4.   Enter the catalog in the Part Selection<T> palette.

5.   If you want to save the report to a file for printing, set the
     Don't Save To File/Save To File<T> toggle to Save To File<T>.

6.   If you want to save the report to a file, enter the full path in
     the Output Filename<T> field.  If you only enter a filename, the
     report will be saved to a file in the current working
     directory.

7.   Select the Create<T> button at the bottom of the Reports<T> form.

     The Parts In Catalog<T> report is created and displayed.

8.   Exit the form.


<ETP>
<TP>PDCrBOPrLs
:Create Parts List:
This command lets you generate a list of parts report from an
assembly.

<S>Before Using This Command<T>

A format must be defined for the report and the assembly
being used in the report must be checked in.

<S>Operating Sequence<T>

1.   Select the Parts List<T> Button on the Reports<T> form.

2.   Enter the format name in the Report Format Name<T> field.
     This name can be entered by key-in or selected from the list
     generated by selecting the List<T> button next to the field.
     This report name can also be a format created in RIS.

     To use a report format created in RIS:

     a.   Make sure the RIS template file resides in the directory
          from which EMS was executed.

     b.   Enter the template file name in the Report Format Name<T>
          field.

     c.   Select the Import RIS<T> button.

          The template file is copied to
          /usrx/nfmadmin/<environment name>/pdmreports<T>
          directory.  Once in this directory, the name will appear in
          the list generated by the List<T> button next to the Report
          Format Name<T> field.

3.   Set the Part Selection/Existing BOM Selection<T> to Part
     Selection<T>.

4.   Enter information about the assembly part in the Part
     Selection<T> palette.

<S>Note:<T>

     You can use the Search<T> button to search for the desired
     part. <F>„<T>

5.   If you want to save the report to a file for printing, set the
     Don't Save To File/Save To File<T> toggle to Save To File<T>.

6.   If you want to save the report to a file, enter the full path in
     the Output Filename<T> field.  If you only enter a filename, the
     report will be saved to a file in the current working
     directory.

7.   Select the Create<T> button at the bottom of the Reports<T> form.

     The Parts List<T> report is created and displayed.

8.   Exit the form.


<ETP>
<TP>PDCrBOSmPr
:Create Summary Atomic Parts:
This command generates a list of the atomic parts that make
an assembly.

<S>Before Using this Command<T>

A format must be defined for the report and the assembly
being used in the report must be checked in.

<S>Operating Sequence<T>

1.   Select the Summary Atomic Parts<T> button on the Reports<T>
     form.

2.   Enter the format name in the Report Format Name<T> field.
     This name can be entered by key-in or selected from the list
     generated by selecting the List<T> button next to the field.
     This report name can also be a format created in RIS.

     To use a report format created in RIS:

     a.   Make sure the RIS template file resides in the directory
          from which EMS was executed.

     b.   Enter the template file name in the Report Format Name<T>
          field.

     c.   Select the Import RIS<T> button.

          The template file is copied to
          /usrx/nfmadmin/<environment name>/pdmreports<T>
          directory.  Once in this directory, the name will appear in
          the list generated by the List<T> button next to the Report
          Format Name<T> field.

3.   Make sure the Part Selection/Existing BOM Selection<T>
     toggle is set to Part Selection<T>.

4.   Enter the information about the assembly in the Part
     Selection<T> palette.

<S>Note:<T>

     You can use the Search<T> button to search for the desired
     part. <F>„<T>

5.   If you want to save the report to a file for printing, set the
     Don't Save To File/Save To File<T> toggle to Save To File<T>.

6.   If you want to save the report to a file, enter the full path in
     the Output Filename<T> field.  If you only enter a filename, the
     report will be saved to a file in the current working
     directory.

7.   Select the Create<T> button at the bottom of the Reports<T> form.

     The Summary of Atomic Parts<T> report is created and
     displayed.

8.   Exit the form.


<ETP>
<TP>PDCrTpDwPr
:Create Top Down Part:
This command lets you design an assembly in one file and
then break it down into several smaller design files.

<S>Before Using This Command<T>

The assembly must be retrieved for design and displayed in
the Active Part Information<T> palette of the Design Operations<T>
form.

<S>Operating Sequence<T>

1.   Select the Topdown Design<T> button on the Design
     Operations<T> form.

     Add part? (y/n)[y]<T>

<S>Note:<T>

     This prompt lets you save the individual part that you are
     breaking out of the assembly as a new part or as an
     existing part. <F>„<T>

2.   If you want to add a new part, press <Return>.

     The Part Operations<T> form appears.

     a.   Enter the information for the new part in the New Part<T>
          palette and the New File Information<T> palette.

     b.   Select the Add<T> button.

          After the part is added, the Part Operations<T> form
          disappears.

3.   If you want to save the individual part as an existing part,
     key in n<T> and press <Return>.

     The Identify Part<T> form appears.

     a.   Enter the information about the existing part by keying
          in the information or by using the List<T> button.  You may
          use the Search<T> button to search for the part.

     b.   Save and exit the Identify Part<T> form to return to the
          Design Operations<T> form.

4.   Fence (f), individual select (i), or parts list (p)? [f]<T>

<S>Note:<T>

     This prompt lets you select a group of elements or an
     individual element or a part. <F>„<T>

5.   If you want to fence the element, press <Return>.

     Enter 1st diagonal point<T>

     a.   Enter a data point outside the element(s).

          Enter 2nd diagonal point<T>

     b.   Enter the second data point to form a fence around the
          element(s).

6.   If you want to select an individual element, key in i<T> and
     press <Return>.

     Identify element/Move on<T>

     a.   Place a data point on the desired element.

          Identify next element/Reject<T>

     b.   Place a data point away from the element to accept the
          element.

     c.   Tap <R> until you receive a message that the software
          is saving and renaming the selected part.

7.   If you want to select a PDU part, key in p<T> and press
     <Return>.

     A list of PDU parts placed in the active assembly is
     displayed.

     a.   Select the desired part from the List of Parts<T> form.

     b.   Save and exit the form.

     User-defined or default origin? (u/d)[d]<T>

8.   Press <Return> if you want to use the default origin.

                                              OR

     If you want to define an origin, key in u<T> and press
     <Return>.

9.   Enter view name<T>

     a.   Key in the view name for the origin or accept the
          default origin name.

          Enter data point<T>

     b.   Place a data point where the origin should be
          positioned, or key in the data point for the origin.  For
          example, <esc>xy=0,0,0,top<T>.

10.  Check in this part? (y/n)[y]<T>

     Press <Return> to check in the part or key in n<T> and press
     <Return> if you do not want to check in the part.

     Attach part graphics?(y/n) [y]<T>

11.  Press <Return> to attach the graphics part.

                                              OR

     Key in n<T> and press <Return> if you do not want to attach
     the graphics.

     The individual part is created and the Design Operations<T>
     form is redisplayed.


<ETP>
