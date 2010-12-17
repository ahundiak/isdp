<TP>PDPPr
:Place Part:
This command lets you define the contents of an assembly.
When you place a part, the system constructs a part pointer
which consists of information about the part, for example,
part number, part revision, and the sequence # of the part.

Placing parts in a bottom-up design does not require that the
graphics already exist.  However, when the graphics do exist
(before or after placement), it is helpful to see the graphics of
the placed part in the active assembly.  The I/PDU Attach Part<T>
command provides this capability.  This command attaches a
reference file of the part's graphics to the assembly design
file.  Typically, the part for attachment is identified in the
active design file and I/PDU makes a copy of the file at the
local workstation.  I/PDU then attaches as a reference file the
graphics in the file.  The graphics in a reference file may be
reviewed but not modified.

In the event the graphics for a part have been created before
the part is placed in the design, you can check the Attach Part<T>
option on the Placement Options<T> form to place the part
pointer and attach the graphics for the part.  This lets you see
the graphics while placing the part pointers.

If you want to remove the graphic representation of a part
from the active assembly file, use the Detach Part<T> command.

Parts can be placed in three ways:

1.   By View Alignment

2.   By 3 Points

3.   By Coordinate System.

You can use the Positioned by<T> field of the Placement Options<T>
form to indicate how the part is to be placed.  You can also
use the Display Part Pointers<T> toggle of the Design Operations<T>
form to indicate if the part pointer information will appear
when the part is placed.

<S>Before Using This Command<T>

The assembly in which the part is being placed must be
retrieved for design.

<S>Operating Sequence --- By view alignment<T>

1.   Select the Place Part<T> button on the Design Operations<T>
     form.

     The Part Selection<T> form appears.

2.   Use the Part Selection<T> form to search for the part to be
     placed.

     For more information, refer to the Define Search Criteria<T>
     command.

3.   Select the Placement Options<T> button on the Part Selection<T>
     form.

     The Placement Options<T> form appears.

4.   View Alignment<T> in the Positioned by<T> field of the Placement
     Options<T> form is defaulted.

5.   Set the other desired options on the Placement Options<T>
     form.

     For more information, see the section, Placement Options
     Form<T> in this document.

6.   Save and exit the Placement Options<T> form.

7.   Save and exit the Part Selection<T> form.

     Enter data point<T>

8.   Place a data point or key in an xy value in the desired view.

<S>Note:<T>

     If there are multiple views defined for the part, a pop-up
     form displays the views for the part.  Highlight the view
     you want to place. <F>„<T>

     The system places the part pointer.  If the Attach Part<T>
     checkbox on the Placement Options<T> form is checked, the
     graphics for the part are attached and the Design
     Operations<T> form is redisplayed.

<S>Operating Sequence --- By 3 points<T>

1.   Select the Place Part<T> button on the Design Operations<T>
     form.

     The Part Selection<T> form appears.

2.   Enter the part to be placed in the Part Selection<T> form.

3.   Select the Placement Options<T> button from the Part
     Selection<T> form.

     The Placement Options<T> form appears.

4.   Place a data point on the arrow at the end of the
     Positioned By<T> field until 3 point<T> is displayed in the field.

     A pop-up list is displayed.

5.   Set the other options on the Placement Options<T> form.

     For more information on the Placement Options<T> form, refer
     to the section, Placements Options Form<T> of this document.

6.   Save and exit the Placement Options<T> form.

7.   Save and exit the Part Selection<T> form.

     Enter point 1 (origin).<T>

8.   Enter a data point or key in an xy value for the origin.

     Enter point 2 (x-axis).<T>

9.   Enter a data point or key in a dx, dl or xy value for the
     x-axis.

     Enter point 3 (y-axis).<T>

10.  Enter a data point or key in a dx, dl or xy value for the
     y-axis.

     The system places the part pointer and the Design
     Operations<T> form redisplays.

<S>Operating Sequence --- By coordinate system:<T>

<S>Note:<T>

An EMS coordinate system must be placed where you want
the part placed before using this command. <F>„<T>

1.   Select the Place Part<T> button on the Design Operations<T>
     form.

     The Part Selection<T> form appears.

2.   Enter the part to be placed in the Part Selection<T> form.

     For more information, see the command Define Search
     Criteria<T>.

3.   Select the Placement Options<T> button from the Part
     Selection<T> form.

     The Placement Options<T> form appears.

4.   Place a datapoint on the arrow at the end of the
     Positioned By<T> field on the Placement Options<T> form until
     Coordinate System<T> is displayed in the field.

5.   Set the other desired options on the Placement Options<T>
     form.

     For more information on the Placement Options<T> form, refer
     to the section, Placements Options<T> form of this document.

6.   Save and exit the Placement Options<T> form.

7.   Save and exit the Part Selection<T> form.

     Identify coordinate system<T>

8.   Identify the coordinate system to be used for placing the
     part.

     Accept/Reject coordinate system<T>

9.   Enter a data point for acceptance.

     The part pointer is placed.

                                              OR

     Tap <R> not to accept the coordinate system.

<S>Note:<T>

The Dynamic Attribute Information<T> form appears if you place a
data point in the Display Dynamic Attribute Form<T> checkbox on
the Placement Options<T> form.  This form lets you assign values
to dynamic attributes at placement time. <F>„<T>


<ETP>
<TP>PDUPoPr
:Position Part:
This command lets you position graphic parts that were
placed in an assembly using the Define/Modify Assembly
Structure<T> form.

<S>Before Using This Command<T>

Make sure the assembly structure part information appears in
the Part Selection<T> palette of the PDM/PDU<T> form.

<S>Operating Sequence<T>

1.   Select the Assembly Structure<T> button from the
     Management<T> palette of the PDM/PDU<T> form.

     The Define/Modify Assembly Structure<T> form appears.

2.   To create the assembly structure by keying in part:

     a.   Set the Key in Part/Select from List<T> toggle to Key in Part<T>.

     b.   Enter the part information in the Part Selection<T> palette
          of the Define/Modify Assembly Structure<T> form by key-in
          or by using the list button.

     c.   Select the Placement Options<T> button.

          The Placement Options<T> form is displayed.

     d.   Place a data point in the checkboxes of the options that
          you want for this particular part placement.

<S>Note:<T>

          If you place a data point in the checkbox beside the
          Display Dynamic Attr. Form<T> option, the Dynamic Attr.<T>
          form will display after you select the Place<T> button on
          the Design/Modify Assembly Structure<T> form. <F>„<T>

     e.   Save and exit the Placement Options<T> form.

     f.   Select the Place<T> button.

<S>Note:<T>

          If you placed a data point in the Display Dynamic Attr.
          Form<T> option on the Placement Options<T> form, the
          Dynamic Attributes<T> form is displayed.  Enter the correct
          information in this form and select the Save and Exit<T>
          button. <F>„<T>

          The part information is entered in the Assembly
          Structure<T> palette.

     g.   Repeat steps 2a - 2f to until the assembly structure is
          complete.

3.   To create the assembly structure by selecting parts from a
     list:

     a.   Set the Key in Part/Select from List<T> toggle to Select from
          List<T>.

     b.   Select the Search<T> button from the Define/Modify
          Assembly Structure<T> form.

          The Part Selection<T> form appears.

     c.   Enter the search criteria for the desired parts.

     d.   Select the Search<T> button from the Part Selection<T> form.

          The results are displayed on the Part Selection<T> form.

     e.   Select the Save and Exit<T> button on the Part Selection<T>
          form.

          The list is displayed on the Define/Modify Assembly
          Structure<T> form.

     f.   Highlight the part to be added to the assembly structure.

     g.   Select the Placement Options<T> button.

          The Placement Options<T> form is displayed.

     h.   Place a data point in the checkboxes of the options that
          you want for this particular part placement.

<S>Note:<T>

          If you place a data point in the checkbox beside the
          Display Dynamic Attr. Form<T> option, the Dynamic Attr.<T>
          form will display after you select the Place<T> button on
          the Design/Modify Assembly Structure<T> form. <F>„<T>

     i.   Save and exit the Placement Options<T> form.

     j.   Select the Place<T> button.

<S>Note:<T>

          If you placed a data point in the Display Dynamic Attr.
          Form<T> option on the Placement Options<T> form, the
          Dynamic Attributes<T> form is displayed.  Enter the correct
          information in this form and select the Save and Exit<T>
          button. <F>„<T>

          The part is added to the Assembly Structure<T> form.

     k.   Repeat steps 3f - 3j until the assembly structure is
          complete.

4.   After the assembly structure is defined, select the Process<T>
     button on the Define/Modify Assembly Structure<T> form.

5.   Exit the Define/Modify Assembly Structure<T> form.

     The PDM/PDU<T> form reappears.

6.   Enter the assembly part information in the Part Selection<T>
     palette.

7.   Select the Retrieve for Design<T> button.

     The Design Operations<T> form appears.

8.   Select the Position Part<T> button.

     The List of Parts<T> form appears displaying the parts found in
     the assembly that are positionless.

9.   Highlight a part to be positioned.

     The Placement Options<T> button is activated.

10.  Select the Placement Options<T> button.

     The Placement Options<T> form is displayed.

11.  Place a data point in the checkboxes of the options that
     you want for this particular part placement.

12.  Save and exit the Placement Options<T> form.

13.  Select the Save and Exit<T> button on the List of Parts<T> form.
     Enter data point<T>

14.  Enter a data point where you want the part positioned.

     The part pointer is placed and attached if you specified to
     do so on the Placement Options<T> form.

     The Design Operations<T> form is redisplayed.

15.  Repeat steps 8 - 11 until all desired parts are positioned.

16.  Select the Save & Exit<T> button to exit the design and save
     the results.

     Save and exit design(y/n)[y]?<T>

17.  Key in y<T> and press <Return> to save the positioned parts.


<ETP>
