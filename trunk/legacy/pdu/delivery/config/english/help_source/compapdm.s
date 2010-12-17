<TP>PDAdPrPr
:Add Parametric Part:
This command lets you add a parametric part.

<S>Before Using This Command<T>

A parametric catalog must exist.

<S>Operating Sequence<T>

1.   Select the Parametric Part<T> button from the Management<T>
     palette of the PDM/PDU<T> form.

     The Parametric Part Operations<T> form appears.

2.   Make sure the New<T> button at the top of the form is
     selected.

3.   Enter the parametric catalog name and description in the
     appropriate fields of the Parametric Part Operations<T> form.

     The attributes are retrieved.

4.   Add a row with defaults.

     a.   Select the Add Row With Defaults<T> button on the
          Spreadsheet Operations<T> palette.

          The default values set for the catalog attributes appear
          on the first row.

<S>Note:<T>

          The rows are horizontally scrollable.  You can use the
          horizontal scroll bar at the bottom of the value
          definition field to view all of the attribute values. <F>„<T>

5.   Key in the new part information in the appropriate
     attribute columns.

<S>Note:<T>

     If the attribute name has an * next to it, the attribute has a
     list of possible values.  To display the list of values for the
     attribute, tap the middle mouse button on the attribute
     name at the top of the column. A list of values for the
     attribute is displayed.  You can select the desired value by
     placing a data point on the value. <F>„<T>

6.   You can copy the information from one row to another.  To
     copy a row:

     a.   Place a data point next to the Part Number<T> field of the
          row to be copied.

     b.   Select the Copy Row<T> button on the Spreadsheet
          Operations<T> palette.

          The information is copied from one row to the new row.

7.   After the row has been copied, you can modify the values
     entered on the new row.

8.   After you have reviewed the rows you have added, select
     the Add<T> button on the Parametric Part Operations<T> form.

     The parametric parts are added.


<ETP>
<TP>PDAdPr
:Add Part:
This command adds a part to the catalog displayed in the New
Part<T> palette of the Part Operations<T> form. You can add
information about a part, even before it has graphics, to a
catalog.

<S>Before Using This Command<T>

A new part can be added from scratch or can be created from
a similar existing part.  To create a part from scratch, you must
be in the New<T> mode of the Part Operations<T> form.  This mode
requires new part information.  To create a part from a similar
existing part, you must be in the Similar<T> mode of the Part
Operations<T> form.

<S>Note:<T>

The following attributes are required for a graphic, drawing,
or macro part:

Part Number
Revision
Part Type
Local File Name
Storage File Name
Storage Area
ACL Number

                                           AND

The following attributes are required for a nongraphic part:

Part Number
Revision
Part Type (N)

 <F>„<T>

The following are valid part types:

D = Drawing Part
M = Macro Part
G = Graphic Part
N = Nongraphic Part

<S>Operating Sequence<T>

To add a new part from scratch:

1.   Select the Parts<T> button from the Management Palette<T> of
     the PDM/PDU<T> form.

     The Part Operations<T> form appears.

2.   Make sure you are in the New<T> mode of the Part Operations<T>
     form.

3.   Select the catalog for the new part.  This can be done by
     key-in or by selecting a catalog from a list that is generated
     by selecting the List<T> button next to the Catalog<T> field in the
     New Part<T> palette of the Part Operations<T> form.

4.   Enter information about the new part in the New Part, Part
     Attribute Values,<T> and New File Information<T> palettes.

5.   Choose a storage area for the new part.  The default is
     NFMFILES<T>.  If there are no other storage areas, there will
     be no List<T> button next to the field.

6.   Choose an ACL for the new part.  The default is
     PDM_PART_ACL<T>.

7.   Select the Add<T> button from the Part Operations<T> palette on
     the Part Operations<T> form.

     The part is added.

For adding a part from a similar existing part:

1.   Make sure you are in the Similar<T> mode of the Part
     Operations<T> form.

2.   Enter the existing part information in the Existing Part<T>
     palette.

3.   Select the catalog for the new part.  This can be done by
     key-in or by selecting a catalog from a list that is generated
     by selecting the List<T> button next to the Catalog<T> field in the
     New Part<T> palette of the Part Operations<T> form.

4.   Enter the information for the new part.

     a.   Enter the part number, revision, part type, and
          description for the new part in the New Part<T> palette of
          the Part Operations<T> form

     b.   Enter the information about the new file in the New File
          Information<T> palette of the Part Operations<T> form.

     c.   Enter the part attribute values in the Part Attribute
          Values<T> palette of the Part Operations<T> form.

5.   Choose a storage area for the new part.  The default is
     NFMFILES<T>.  If there are no other storage areas, there will
     be no List<T> button next to the field.

6.   Choose an ACL for the new part.  The default is
     PDM_PART_ACL<T>.

7.   Select the Add<T> button on the Part Operations<T> palette on
     the Part Operations<T> form.

     The part is added.


<ETP>
<TP>PDAdPrPj
:Add Part To Project:
This command adds a part to a project as a referenced part.
You can add information about a part, even before it has
graphics, to a project.

<S>Before Using This Command<T>

A project must be added through I/NFM.  The catalog to which
the part will be added must be mapped to an ACL and storage
area through I/NFM. For more information on projects, see the
I/NFM Administrator's Reference Manual, (DDA0013).<T>

<S>Operating Sequence<T>

1.   Enter the correct project name in the Project<T> field of the
     Existing Part<T> palette on the Part Operations<T> form while in
     Change<T> mode.

2.   Enter the catalog containing the part to be added to the
     project in the Catalog<T> of the Existing Part<T> palette of the
     Part Operations<T> form.

3.   Enter the part number for the part to be added in the part
     number field of the Existing Part<T> palette on the Part
     Operations<T> form.

4.   Select the Add to Project<T> button on the Part Operations<T>
     palette of the Part Operations<T> form.


<ETP>
<TP>PDApPr
:Approve Part:
This command lets you change the status of a part in the
approval cycle, which is defined by the I/PDM workflow.  This
command works for graphic, macro, drawing, and parametric
parts.

<S>Operating Sequence<T>

For approving graphic, macro, and drawing parts.<T>

1.   Make sure the part to be approved appears in the Existing
     Part<T> palette of the Part Operations<T> form in Change<T> mode.

2.   Select the Move To Next State<T> button on the Part
     Operations<T> form.

     The Possible State Transitions<T> form appears displaying a
     list of possible states for this part if there are multiple
     transitions.  The default workflow only has one transition,
     so no list would appear.

3.   Highlight the needed state.

     The part is moved to that state and the new state appears
     in the State Name<T> field on the Part Operations<T> form.

For approving parametric parts.<T>

1.   Make sure the part to be approved appears in the list of
     parametric parts displayed on the Parametric Part
     Operations<T> form in Change<T> mode.

2.   Select the part to be approved by placing a data point in
     the column just left of the Part Number<T> attribute column.

3.   Select the Move To Next State<T> button on the Parametric
     Part Operations<T> form in Change<T> mode.

     A form displays the possible states for the part.  The
     default workflow only has one possible transition state,
     design complete<T>.

4.   Highlight the new state from the list.

     The list disappears and the part is moved to that state.


<ETP>
<TP>PDAtPr
:Attach Part:
This command attaches the graphic file so you can see the
actual graphics of the selected part in the active assembly.

<S>Before Using This Command<T>

The assembly part must be retrieved for design and a part
pointer must be placed and the graphics are not attached.

I/PDM checks each file that is copied for attachment.  If the
file is local, it compares the file's version against the version
of the file that is checked in.  If the local version is older, the
file is moved. If the file is not local, the file is copied to local.

<S>Operating Sequence<T>

1.   Select the Attach<T> button from the Design Commands<T>
     palette of the Design Operations<T> form.

     Identify Part/Reset for list<T>

2.   Select the part pointer for the part to be attached or tap
     the right mouse button for a list of parts in the active
     design that are not attached.

<S>Note:<T>

     If the part pointer has multiple views, a form displays a list
     of the views for the part.  You can highlight the view for
     the part pointer to be attached. <F>„<T>

     If you select the part pointer:  The part pointer highlights.

     Accept/Reject part<T>

     a.   Enter a data point to accept or tap <R> to reject.

     The part is attached to the part pointer and the Design
     Operations<T> form is redisplays. If you select the right mouse
     button for a list:

     a.   Highlight one or more parts and select the Save & Exit<T>
          button to attach the parts. The part is attached to the
          part pointer and the Design Operations<T> form redisplays.


<ETP>
