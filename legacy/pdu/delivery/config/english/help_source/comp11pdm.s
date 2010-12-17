<TP>rpts0
:Reports:
I/PDM provides a reporting subsystem that lets you generate
reports based on catalogs, parts, and assemblies.  This
subsystem lets you create these reports based on a new
format or on a format that has been previously defined and
saved.  I/PDM also lets you import an existing RIS report
template<T> directly into the management system. For related
information, see the following topic:<T>

<ST>rpttyp  Report Types<T>


<ETP>
<TP>rpttyp
:Report Types:
The Reports<T> form can be used to generate several types of
reports.  The types of reports that can be generated are:

1.   <ST>bom  BOM<T>

2.   <ST>sem  Exploded BOM<T>

3.   <ST>atompart  Summary Atomic Parts<T>

4.   <ST>bompart  Parts List<T>

5.   <ST>partcat  Parts in Catalog<T>

6.   <ST>catdatbase  Catalogs<T>

7.   <ST>wb0  Where Used Highest Level<T>

8.   <ST>wu0  Where Used Immediate<T>


<ETP>
<TP>bom
:BOM:
A bill of materials<T> or BOM<T> is a document associated with an
assembly.  The BOM is a report of the current structure of an
assembly. In I/PDM, the BOM serves as a document for the
assembly.

Typically, the BOM generation is viewed as one of the last
things that is done to an assembly.  However, it can be
generated as often as it is needed.  If only single-level
assemblies are done, the BOM generation may not be needed
until closer to release.  The BOM is generated dynamically as
it is being constructed. For related information, see the
following topic:<T>

1.   <XR>bom_list_format Report Format<T>

2.   <XR>bomcreate Creating Reports<T>

3.   <XR>bom_mapping BOM Mapping<T>

4.   <XR>bom_printing Printing Reports<T>


<ETP>
<TP>sem
:Exploded BOM:
An Exploded BOM<T> report displays all of the subassemblies
contained within an assembly.  This report explodes<T> these
subassemblies to display the atomic parts that make up the
subassemblies.  An Exploded BOM report lets you display the
dynamic attributes for the parts in the assembly.

An Exploded BOM is a level by level report.  If a part exists
more than once at a level, it is only listed once.  The assembly
is exploded to the maximum level as it is defined in the
product structure.

<S>Related Commands<T>

<XR>PDDfExBOFr
Define Exploded BOM List Format<T>
<XR>PDCrExBOFr
Create Exploded BOM<T>
<XR>PDDlExBOFr
Delete Exploded BOM List Format<T>


<ETP>
<TP>atompart
:Summary Atomic Parts:
The Summary Atomic Parts<T> report displays only the atomic
parts that make up the assembly.  If a part appears more than
once in the structure, it is only displayed once in the report.
The subassemblies are not displayed in this report.  You can
format this report to contain the part attributes you want to
appear in the report.

The following illustrates the contents of a Summary BOM
report.

<DG>
help_graphics/spl0.6h
<EG>

                                     Assembly Example

The assembly structure in this example contains an assembly
part numbered Part A<T> and a subassembly numbered
Subassembly A<T>.  The Summary BOM report for Assembly A<T>
would contain the following.

Summary BOM<T>
<F>

Part
Number

Part A
Part B<T>
<S>Related Commands<T>

<XR>PDDfBOSmPr
Define Summary Atomic Parts Format<T>
<XR>PDCrBOSmPr
Create Summary Atomic Parts<T>
<XR>PDDlBOSmPr
Delete Summary Atomic Parts List Format<T>


<ETP>
<TP>bompart
:Parts List:
The Parts List<T> displays all parts within an assembly.  This
report does not maintain the structure, it only lists the parts.
If a part appears in the assembly more than once, it is only
displayed once.

<S>Related Commands<T>

<XR>PDDfBOPrLs
Define Parts List Format<T>
<XR>PDCrBOPrLs
Create Parts List<T>
<XR>PDDlBOPrLs
Delete Parts List Format<T>


<ETP>
<TP>partcat
:Parts in Catalog:
A Parts In Catalog<T> report displays a list of the parts for a
specific catalog.  You can format the report to contain the
part attributes you want to appear in the report.

<S>Related Commands<T>

<XR>PDDfPtCtFr
Define Parts In Catalog List Format<T>
<XR>PDCrPtCtFr
Create Parts In Catalog<T>
<XR>PDDlPtCtFr
Delete Parts In Catalog List Format<T>


<ETP>
<TP>catdatbase
:Catalogs:
A Catalog In Database<T> report displays a list of catalogs found
in the database.  This report can be formatted to include the
common attributes of the catalog such as catalog name,
description<T>, and creator<T>.

<S>Related Commands<T>

<XR>PDDfCtLsFr
Define Catalog In Database List Format<T>
<XR>PDDlCtLsFr
Delete Catalog In Database List Format<T>


<ETP>
<TP>wu0
:Where Used Immediate:
A Where Used Immediate<T> report is a display of all assemblies
that contain a given part in the immediate lower level. When
you specify a part by catalog number, part number, and
revision number, a list of all assemblies containing that part is
generated. The system uses the format that you defined for
this report.

The following illustrates the contents of a Where Used
Immediate report.

<DG>
help_graphics/spl0.6h
<EG>

                                     Assembly Example

The assembly structure in this example contains an atomic
part numbered Part A<T> and a subassembly numbered
Subassembly A<T>.  The Where Used Immediate Report for Part A<T>
would contain the following information.

<S>Where Used Immediate<T>
<F>Part Number

Assembly A
Subassembly
A<T>
<S>Related Commands<T>

<XR>PDDfWhUsAs
Define Where Used Immediate List Format<T>
<XR>PDCrWhUsAs
Create BOM Where Used Immediate<T>
<XR>PDDlWhUsAs
Delete Where Used Immediate List Format<T>


<ETP>
<TP>wb0
:Where Used Highest Level:
A Where Used in Highest Level<T> report displays the highest
level in which the part occurs.  When you specify a part by
catalog number, part number, and revision number, a report is
generated showing the highest level assembly containing
that part. The format for this report is created with these
commands.  The Part Number<T> and Revision<T> attributes are
required for this report.

The following illustrates the contents of a Where Used
Highest Level report.

<DG>
help_graphics/spl0.6h
<EG>

                                     Assembly Example

The assembly structure in this example contains an atomic
part numbered Part A<T> and a subassembly numbered
Subassembly A.<T>  The Where Used Highest Level report for Part
A<T> would contain the following information.

<S>Where Used Highest Level<T>
<F>Part Number

Assembly A<T>
<S>Related Commands<T>

<XR>PDDfWhUsHL
Define Where Used at Highest Level List Format<T>
<XR>PDCrWhUsHL
Create BOM Where Used at Highest Level<T>
<XR>PDDlWhUsHL
Delete Where Used at Highest Level List Format<T>


<ETP>
<TP>bom_list_format
:Report Format:
The format definition defines the format for information in the
report. This definition consists of the position header lines
and the contents of the report.  For example, the part number
can be specified to appear in columns 1 through 20 and the
part revision in columns 24 through 28.

The I/PDM Reports<T> form contains three buttons that let you
add, modify, and delete list formats.

The Add<T> button on the Reports<T> form lets you add a new list
format.  Before you can define the format, you must enter the
new report format name in the Report Format Name<T> field.  This
is a name under which the list format will be saved.  After a
name has been entered in the Report Format Name<T> field,
select the Add<T> button to display the Define Report Format<T>
form.  This form lets you define the list format for the report.
After the information has been entered, the Exit and Save<T>
button dismisses the form and saves the format.

The Modify<T> button on the Reports<T> form lets you make changes
to an existing report format.  Before a format can be modified,
the format name must be displayed in the Report Format Name<T>
field.  After a name has been entered in the Report Format
Name<T> field, select the Modify<T> button to display the Define
Report Format<T> form.  This form displays the current format for
the report and lets you modify the list format.  After the
format has been modified, the Exit and Save<T> button dismisses
the form and saves the new format.

The Delete<T> button on the Reports<T> form lets you delete an
existing report format.  Before a format can be deleted, the
report format name must be displayed in the Report Format
Name<T> field.  After a name has been entered in the Report
Format Name<T> field, select the Delete<T> button to delete the
format listed in the Report Format Name<T>.

<S>Related Commands<T>

<XR>PDDfBOLsFr
Define BOM List Format<T>
<XR>PDDlBOLsFr
Delete BOM List Format<T>


<ETP>
<TP>bomcreate
:Creating Reports:
After a list format has been defined for a report, you can
generate the report.  The Create<T> button on the Reports<T> form
uses the format displayed in the Report Format Name<T> field to
create a report based on the information entered in the Part
Selection<T> palette.

The Display Existing Report<T> button lets you display the report
contained in the Output Filename<T> field of the the Reports<T> form
to the screen.  This button becomes active when the Save To
File/Don't Save To File<T> toggle is set to Save To File<T>.


<ETP>
<TP>bom_mapping
:BOM Mapping:
BOM mapping ensures that all catalog attributes can be
included in a BOM.  The system automatically maps BOM
attributes to catalog attributes with the same name.
However, there may be a number of user-defined attributes
that do not have a BOM attribute.  BOM mapping lets you map
these catalog attributes to a BOM attribute, so the attribute
can be included in a report.  I/PDM also lets you map any
dynamic attributes to a BOM attribute.  It may become
necessary to change the mapping for BOM attributes.  I/PDM
lets you change the mapping for the attributes.

The BOM Contents/Mapping<T> form lets you map BOM attributes
and add new BOM attributes.  The BOM Contents/Mapping<T>
form appears when you select the BOM Mapping<T> button on
the Reports<T> form.

BOM attributes can be mapped by entering information in the
fields of the Mapping<T> and selecting the Map Attribute<T> button.
The BOM attribute is now mapped to a specific catalog
attribute and can be added to a report.

BOM attributes can be added by entering information in the
fields of the Attribute Information<T> palette and selecting the
Add Attribute<T> button.

<S>Related Commands<T>

<XR>PDChBOMp Define BOM Mapping<T>
<XR>PDShBOMp Show BOM Mapping<T>


<ETP>
<TP>bom_printing
:Printing Reports:
I/PDM provides print options which let you save the report in
ASCII format.  Once in this format, the report can be displayed
on a screen or printed.

The Save To File/Don't Save To File Toggle<T> toggle on the
Reports<T> form lets you save the report in ASCII format. Setting
the toggle to Save To File<T> displays the Output Filename<T> field
that lets you enter a file name for storing the report in ASCII
format.

The Display Existing Report Button<T> button becomes active
when the Save To File/Don't Save To File<T> toggle is set to Save
To File<T> and lets you display the report found in the Output
Filename<T> field to the screen.


<ETP>
