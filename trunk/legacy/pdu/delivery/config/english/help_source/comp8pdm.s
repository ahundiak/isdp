<TP>assembly0
:Assemblies:
Once you have created parts, you can use those parts when
designing assemblies.  An assembly<T> is a complete design
structure created by combining manufactured parts. You can
create part graphics and top down designs, place and attach
parts to assemblies, and define the origins for those parts.
Parts can be placed with the Place<T> command.

You can also copy parts or replace parts within the assembly.
Once your assemblies are created, you can review the parts in
the active design, locate review parts, and review part
attributes.  Files can be attached using the Place Part<T>
command by checking off the Attach Part<T> field on the
Placement Options<T> form before executing the Place Part<T>
command.  The design file can also be attached by selecting
the Attach<T> button on the Design Operations<T>. For related
information, see the following topic:<T>

1.   <ST>assembly_design  Designing Assemblies<T>

2.   <ST>manipulate_assembly  Manipulating Assemblies<T>

3.   <ST>show_assembly  Show Assemblies<T>

4.   <ST>ass_struct  Assembly Structure<T>


<ETP>
<TP>assembly_design
:Designing Assemblies:
I/PDM provides an assembly design environment which is
integrated with I/EMS and provides access to parts and their
graphics files managed in the PDM database.

Before the concept of assembly design can be understood,
you must first understand these terms.

An atomic<T> part is any I/PDM graphics part, such as a shaft or
bearing, that can be included in an assembly.

An active part<T> is the part or assembly being worked on in
I/EMS. The graphics file corresponding to this active part is
the active I/EMS file.  When designing assemblies, the active
part is the assembly file.

<S>Design Types<T>

I/PDM supports three different design types: bottom-up,
top-down, and nongraphic.  There are no software limitations
on the levels of nesting for any type of assembly; an assembly
can be composed of sub-assemblies and parts at any level.

A bottom-up design<T> is one in which the low-level parts of an
assembly are identified and then assembled into higher-level
units.  For example, a bicycle is made up of many different
parts such as tires, seat, frame, chain, and handlebars.  These
parts can be thought of as the low-level parts which are
assembled into a higher-level unit.  In this case, the
higher-level unit is the bicycle.

                                     Bicycle Assembly

The following illustrates the parts list before and after the
bicycle assembly is created.  Note that after the assembly is
created, the parts list contains the assembly part along with
the individual parts that make up the assembly.

Parts list before assembly<T>
<F>

Part         Revision     Description         Quantity
Number

f-001        a            bicycle frame       1
s-001        a            bicycle seat        1
hb-001       a            bicycle             1
                          handlebars
p-001        a            bicycle pedals      1
rs-001       a            rear sprocket       1
fs-001       a            front sprocket      1
ch-001       a            bicycle chain       1
hb-001       a            bicycle hub         2
rax-001      a            rear axle           1
frax-001     a            front axle          1
t-001        a            bicycle tires       2<T>
Parts list after assembly creation<T>
<F>

Part         Revision     Description         Quantity
Number

b-001        a            bicycle assembly    1
f-001        a            bicycle frame       1
s-001        a            bicycle seat        1
hb-001       a            bicycle             1
                          handlebars
p-001        a            bicycle pedals      1
rs-001       a            rear sprocket       1
fs-001       a            front sprocket      1
ch-001       a            bicycle chain       1
hb-001       a            bicycle hub         2
rax-001      a            rear axle           1
frax-001     a            front axle          1
t-001        a            bicycle tires       2

<T>
A top-down design<T> is an assembly that is completed and
individual parts are broken out of the design file and further
decomposed into other sub-assemblies and parts.  For
example, a bearings assembly may  have a design file
consisting of an outer race and eight ball bearings. You can
take the assembly and break the individual parts out of the
assembly and create a design file for each individual part.
Instead of having one design consisting of an outer race and
eight ball bearings, you would have an individual file for the
shaft and for each of the ball bearings.

                                    Bearings Assembly

The following illustrates the parts list before and after the
bearings assembly is created.  Note that after the assembly is
created, the parts list contains the assembly part along with
the individual parts that make up the assembly.

Parts list before assembly creation<T>
<F>

Part         Revision     Description         Quantity
Number

ba-001       a            bearings assembly   1<T>
Parts list after assembly creation<T>
<F>

Part         Revision     Description         Quantity
Number

ba-001       a            bearings assembly   1
or-001       a            outer race          1
br-001       a            ball bearing        1
br-002       a            ball bearing        1
br-003       a            ball bearing        1
br-004       a            ball bearing        1
br-005       a            ball bearing        1
br-006       a            ball bearing        1
br-007       a            ball bearing        1
br-008       a            ball bearing        1<T>
A nongraphic design<T> is an assembly that contains no
graphics, but an assembly structure is defined.  For example,
you might want to create an assembly for documentation
purposes.  The assembly structure lists information about the
parts in the assembly and the level at which they appear.

During bottom-up design the parts or sub-assemblies that are
to be placed<T> or used in this assembly are selected from the
I/PDM catalogs.  When parts are selected for placement in an
assembly, the selected part is placed in the Part Selection<T>
area (as a result of selecting it from the list) and is then
placed.

<S>Related Commands<T>

<XR>PDPPr
Place Part<T>
<XR>PDAtPr
Attach Part<T>
<XR>PDDtPr
Detach Part<T>
<XR>PDDfOr
Define Origin<T>
<XR>PDDlOr
Delete Origin<T>
<XR>PDDlPr
Delete Part<T>


<ETP>
<TP>manipulate_assembly
:Manipulating Assemblies:
Once you have created your assemblies, I/PDM lets you
manipulate these assemblies.  You can place parts in an
assembly, copy a part in the assembly, and replace parts in the
assembly.

<H>Assembly Concepts<T><T>

The following sections discuss assembly manipulations:

<X>õ<T>   Part Placement

<X>õ<T>   Dynamic Attributes

<X>õ<T>   Defined Origin

<X>õ<T>   Placement Quantities

<X>õ<T>   Tag Numbering

<X>õ<T>   Part Attachment

<X>õ<T>   Copy Part

<X>õ<T>   Replace Part

<S>Part Placement<T>

I/PDM has several part placement options that add flexibility
to placing parts.  These options appear on the Placement
Options<T> form.

The assembly design is similar to I/EMS in that it uses
reference files as parts within an assembly. However, in
I/PDM a part can be placed in an assembly without attaching
the corresponding I/EMS file for that part.  The part placement
is identified using a part pointer<T> which simply acts as a place
holder.  The part pointer consists of information  about the
part such as part name, part revision, and instance number.
The part being placed does not have to be a graphic part.  The
placement can be given a unique user ID called a usage-id<T>.
The following illustrates and describes the default contents
of a part pointer which appears on layer 1023.

<DG>
help_graphics/partpoint.6
<EG>

<X>õ<T>   gear4<T> --- This is the part you are placing.

<X>õ<T>   b<T> --- This is the revision for the part you are placing.

<X>õ<T>   #1<T> --- This is the instance number for this part.  This
     number uniquely identifies a part type instance.

The part pointer can be turned off by turning off the layer that
contains the part pointer.  A toggle on the Placement Options<T>
form lets you indicate whether to view a part pointer.

The previous example illustrates the default contents for a
part pointer.  The default contents for the usage id contained
in the part pointer are the same for standard parts and
parametric parts.  You can use the Placement Options<T> form to
change the contents of the usage id.

If the usage id becomes greater than 25 characters, the
following is used as the usage id for both standard and
parametric parts:

n_catalogno   n_itemno   instance #

The following example illustrates the contents of a usage id
with more than 25 characters.

Catalog plate = n_catalogno = 20
Catalog plate2 = n_catalogno = 50

p1 = n_item = 3 = n_catalogno = 20
p2 = n_item = 4 = n_catalogno = 50

At part placement time, the text of the usage id would be:
<F>

Part         usage id
Placed       Contents

p1           20 3 #1
p2           50 4 #2
p1           20 3 #3

<T>
As you can see, although p1 was placed two times, the
instance # is unique for each placement of p1.

<S>Changing a Parametric usage id<T>

When a parametric catalog is created, a usage id<T> can be
entered into the Default Usage ID<T> field of the Catalog
Operations<T> form.   The system uses this usage id when placing
parts.  If no usage id is defined when the catalog is created,
the contents of the  usage id is part number, part revision, and
instance number.

Suppose we create a parametric catalog and define the usage
id as plate<T>.  At part placement time, the text for the usage id
would be:
<F>

Part         usage id
Placed       Contents

p1           plate #1
p2           plate #2
p3           plate #3

<T>
The instance number is unique for each placement, even if the
part is placed multiple times.

The following illustrates the part pointer for parametric part
p1 containing the usage id, plate.

<DG>
help_graphics/partpoint.8
<EG>

                              Parametric Part Pointer plate

The usage id that is defined at catalog creation time can be
changed by entering a new id  in the Usage ID<T> field of the
Placement Options<T> before placing the part.  Suppose we use
the Placement Options<T> form to change the usage id, plate<T> to
plate2<T>.  At part placement time, the text for the usage id
would be:
<F>

Part         usage id
Placed       Contents

p1           plate2 #1
p2           plate2 #2
p3           plate2 #3

<T>
The following illustrates the part pointer for parametric part
p1 containing the usage id, plate2.

<DG>
help_graphics/partpoint.9
<EG>

                              Parametric Part Pointer plate2

<S>Changing a Standard usage id<T>

When a standard catalog is created, a usage id can be entered
in the Default Usage ID<T> field of the Catalog Operations<T> form.
The system uses this usage id when placing standard parts.  If
no usage id is defined when the catalog is created, the
contents of the standard usage id  default to part number,
part revision, and instance number.

Suppose we create a standard catalog and define the usage
id<T> as bolt<T>.  At part placement time, the text for the usage id
would be:
<F>

Part         usage id
Placed       Contents

p1           bolt #1
p2           bolt #2
p3           bolt #3

<T>
The instance number is unique for each placement, even if the
part is placed multiple times.

The following illustrates the part pointer for standard part p1
containing the usage id, bolt.

<DG>
help_graphics/partpoint.10
<EG>

                               Parametric Part Pointer bolt

The usage id that is defined at catalog creation time can be
changed by entering a new id in the Usage ID<T> field of the
Placement Options<T> form before placing the part.  Suppose we
use change the usage id, bolt<T> to bolt2<T>.  At part placement
time, the text for the usage id would be:
<F>

Part         usage id
Placed       Contents

p1           bolt2 #1
p2           bolt2 #2
p3           bolt2 #3

<T>
The following illustrates the part pointer for standard part p1
containing the usage id, bolt2.

<DG>
help_graphics/partpoint.11
<EG>

                              Parametric Part Pointer bolt2

<S>Dynamic Attributes<T>

Depending on the catalog the part came from, additional
placement specific attribute values can be entered when
placing parts.  For example, all bolts placed from a catalog
named bolts<T> may need to record a torque value when placed.
These placement specific attributes are known as dynamic<T>
attributes because their values can vary from one occurrence
to another.  The dynamic attributes are declared at the time a
catalog is created, or at a subsequent modification time.
Their values are given when a part is placed.

<S>Defined Origin<T>

The defined origin<T> appears very similar to the part pointer,
but serves a different purpose.  Defining an origin associates
a saved view with a coordinate system that will be used later
for part pointer attachment.  When you define the origin, you
can also specify the saved view and name.  The default view
is PDUview<T>.  The following illustrates and describes a defined
origin.

<DG>
help_graphics/partpoint.7
<EG>

                                      Defined Origin

<X>õ<T>   ORIGIN<T> --- This prefix appears on all defined origins to
     help distinguish it from a part pointer and other coordinate
     systems.

<X>õ<T>   gearview<T> --- This is the saved view name.

When placing a part, the user can choose the view for
attaching the part graphics. The quantity default is 1<T> per
placement.  Parts that are placed for documentation<T> purposes
can have quantities reflecting the use.  For example, if a rivet
is used 100 times in an assembly and the 100 usages are not
geometrically significant, then you can place one rivet with a
quantity of 100.  This is also done when placing nongraphic
parts such as paint and glue.  The quantity would represent
the volume of paint or glue.

<S>Tag Numbering<T>

Tag numbering is done for the first level parts only.  I/PDM
assigns the tag numbers when parts are placed in an
assembly.  Optionally, alternate tag numbers can be assigned
by the user.  I/PDM maintains the alternate tag numbers the
same way it maintains the default tag numbers.  Alternate tag
numbers allow the flexibility to associate ASCII tag numbers.

The following rules apply to tag numbers:

<X>õ<T>   The tag number of a part in an assembly remains the
     same in every occurrence of that part in that assembly.

<X>õ<T>   The default tag number of a part is assigned at the time a
     part is first placed in that assembly.  Once assigned, the
     default tag number cannot be changed by the user.  The
     user can optionally assign an alternate tag number, which
     remains the same for every occurrence of that part in that
     assembly.  The alternate tag number can be changed by the
     user, in which case that part will take on the new alternate
     tag number in all occurrences.  An error is reported if you
     try to change the alternate tag number of a part to an
     existing tag number.

<X>õ<T>   When a part is replaced by another part, the tag number
     of the old part is retained, unless the new part already
     exists in the assembly.  In this case, the tag number is
     changed to that of the existing part.

<X>õ<T>   When all occurrences of a part in an assembly are
     deleted, the default tag number cannot be reused for parts
     in any subsequent part placements.

The rules of tag numbering can be seen in the following
example. Consider Assembly A and its components.
<F>

Assembly   Default Tag    Alternate Tag
           Number         Number
A
      B               1       bracket-b

      E               2       lever

      B               1       bracket-b

      E               2       lever

      F               3       xyz-f

<T>
Suppose you place part G in assembly A.  Part G's default tag
number is 4.  The user placing the part can assign an
alternate tag number for this part.

If the alternate tag number of part E is changed from lever to
bracket-b, an error indicates the alternate tag number is used
by another part.  However, part E's tag number can be
changed from lever to lever-e in all of part E's occurrences.

If part B is replaced by part H, the default tag number of part H
will remain 1 and the alternate tag number of part H will
remain bracket-b, since part H did not occur in assembly A
until this time.

If part F is replaced by part E, the default tag number and
alternate tag number of part F changes to that of part E,
because part E occurred in assembly A before this change.

The effects of the above changes in assembly A will result in
the following new tag numbers.
<F>

Assembly   Default Tag    Alternate Tag
           Number         Number
A
     H          1           bracket-b
     E          2            lever-e
     H          1           bracket-b
     E          2            lever-e
     E          2            lever-e
     G          4              abc

<T>
Assigning tag numbers in a single level reflects the standard
use of tag numbers. Alternate tag number provisions allow
flexibility.

<S>Attach Part<T>

A graphic part can be placed in an assembly even before the
graphic file exists.  Placing a part only creates a place holder.
Once the graphics file exists, the part can be viewed in the
context of the assembly by attaching<T>.  Attaching locates the
graphics file for the part, brings the file to the workstation,
and attaches it.  This entire process is transparent to the user.
Attached files can also be detached when not needed using
the Detach<T> command.  The Attach<T> command in the single level
assemblies can be invoked by selecting the part pointer.  The
parts that are attached are recorded between design
sessions. For example, after attaching a few parts, the user
checks the assembly file in.  If the user checks out the
assembly again, the attached reference files also are brought
down to the user's workstation.

<S>Copy Part<T>

As you place parts in an assembly, you may find that you need
multiple occurrences of a part.  I/PDM lets you have multiple
occurrences of a part within an assembly, but only requires
you to place the part one time.  After you have placed a part
pointer, you can copy the pointer to different positions in the
assembly.  The Copy<T> command lets you duplicate a pointer
and its attached reference file in an assembly file.

<S>Replace Part<T>

Sometimes, it becomes necessary to replace an existing part
in an assembly with a new part.  This might present a problem
if there are multiple occurrences of the part in the assembly.
The Replace Part<T> command solves this problem.  This
command lets you replace a single occurrence or all
occurrences of the old part.

Before any modifications can be made to the part file, it must
be retrieved for design.  Once the changes have been made,
the part file can be checked back into its permanent storage
location.

<S>Related Commands<T>

<XR>PDRpPr
Replace Part<T>
<XR>PDDlOr
Delete Origin<T>


<ETP>
<TP>show_assembly
:Show Assemblies:
The part pointers that are in the design may be toggled on and
off while in the design session. You can quickly locate the
review parts in an assembly or review those part attributes
simply by tapping the middle mouse button on the part
graphics that you want to review.


<ETP>
<TP>ass_struct
:Assembly Structure:
The capability to view parts in multi-level assemblies is a
unique feature in I/PDM.  The Define/Modify Assembly
Structure<T> form lets you define a new assembly structure or
modify an existing assembly structure.  The location of the
part in respect to its parent is stored in the database.  The
attached parts are preserved between design sessions as in
first-level attachments.  The parts can be detached by
removing them from the BOM. When needed, the entire
sub-assembly within an assembly can be brought in and
attached.

As an assembly is being constructed by placing parts, the
assembly structure is being generated dynamically.  This
structure can be viewed at any time during assembly creation
by selecting Review Structure<T> button on the PDM/PDU<T> form.
This structure is stored in the database and can also be
reviewed after the assembly file has been checked in.


<ETP>
