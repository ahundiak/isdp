<TP>partintro
:Parts and Files:
Parts are the smallest data items in the I/PDM system.  A part
can contain any information that you want to track.  Parts
with similar attributes are grouped into catalogs.

I/PDM lets you manage parts on the I/PDM system.  You can
add new parts, locate parts and files that already exist, check
parts in and out of a permanent storage area, and modify
information for existing parts.

<H>Part Types<T><T>

There are three basic classifications of part types used by
I/PDM. Within these classifications, there are different types
of parts:

1.   Standard Parts

2.   Parametric Parts

3.   Drawing Parts

Standard<T> parts are the basic parts used for assembly design,
such as a bolt or washer. There are two main types of
standard parts:

1.   Graphic<T> parts which have associated graphic files are
     called graphic<T> parts.  The associated graphics file does not
     have to exist when the part is created.

2.   Non-graphic<T> parts are parts that do not have associated
     graphics files. Non-graphic parts are things like paint and
     glue.  These parts are used in an assembly primarily for
     generating a BOM or parts lists.

Parametric<T> parts are basically standard parts with variational
parameters.  For example, suppose you use a steel plate in an
assembly. The plate can have length, width, and thickness as
parameters.  The plate can be placed several times in an
assembly, but with different parameters.  There are two types
of parametric parts:

1.   Standard Parametric Parts parts are derived from the I/EMS
     parametric macro capabilities.

2.   Macro<T> parts are macro libraries that are used to define a
     parametric part.  A macro library<T> is composed of multiple
     I/EMS macros.  Each macro library is treated as a macro
     part in I/PDM.  These libraries can exist with standard parts
     and parametric parts catalogs. I/PDM provides a default
     catalog for macros called pdmlibraries<T>.

Drawing<T> parts represent 2D drawings versus models.  This
part type lets Place Part<T> know that it should associate an
I/EMS drawing view when this part is placed, if no drawing
view already exists.

The following table illustrates the types of parts and the part
type<T> attribute value.
<F>

Part Type           p_parttype

Graphic             G
Non-graphic         N
Parametric          P
Macro               M
Drawings            D

<T>
For related information, see the following topic:<T>

1.   <ST>addpartfile  Adding Parts and Files<T>

2.   <ST>locate  Locating Parts and Files on the System<T>

3.   <ST>modify  Modifying Part Information<T>


<ETP>
<TP>addpartfile
:Adding Parts and Files:
Parts can be added to the catalog using the I/PDM Add Part<T>
command.  This command lets you create new parts from
nothing or based on part information obtained from similar
parts.

The following illustrates the relationship between catalogs
and parts. The catalog contains information about parts that
are similar.

<DG>
help_graphics/part.6h
<EG>

                              Catalog and Part Relationship

There are two steps required to add a part and its files to a
catalog:

1.   Creating a data entry to an existing catalog.

2.   Associating a file.

When a part is added to a catalog, I/PDM creates a part record
in the catalog.  This record contains information provided by
the user when the part is created.  I/PDM requires that the
following information be included before a part can be added:

1.   Part Number

2.   Revision

3.   Part Type --- If the part type is graphic, the part type is G.
     The default is G.

4.   Storage Area

5.   Workflow

6.   ACL Name

7.   Version --- The version is the number of copies of the file
     that are stored.  The default is 1.

I/PDM lets you associate a graphics file when adding a part.
The graphics file does not have to exist when the part is
created, but a filename must be in the local filename attribute.
This local filename specifies where the graphics will be
stored on the local machine.  The part has three attributes
related to the file:

1.   Storage area --- This is where files will be stored at
     checkin.

2.   Local filename --- This is the filename given when the file is
     brought local (user's workstation).

3.   Storage filename --- This is the name of the file when the
     file is stored in the permanent storage area.

It may become necessary to associate multiple files with a
single part. I/PDM lets you add multiple files to an existing
part.  Through the New<T> and Change<T> modes of the Part
Operations<T> form, multiple files can be added to an existing
part.

<H>Adding Parametric Parts<T><T>

As discussed previously, a parametric part<T> is basically a
standard part with variational parameters.  For example,
suppose you use a steel plate in an assembly.  The plate can
have length, width and thickness as parameters.  The plate
can be placed many times in an assembly but with different
parameters.

In I/EMS, a macro<T> is created to define the geometry and
parameter relationship to the geometry.  Macros are put into
a file which is recognized by I/EMS.  I/EMS may contain one or
more of these files grouped in a macro library.<T>

I/PDM lets you create parametric<T> catalogs which contains
user-defined attributes that describe the parameters defined
in the macro.

<H>Workflow for Creating Parametric Parts<T><T>

The process for creating parametric parts is quite different
from creating standard parts.

1.   Define the Macro<T> --- The first step in creating a parametric
     part is to create the macro geometry.  The macro is created
     to define the geometry and parameter relationship.  For
     more information on macros, refer to the topic Associative
     Geometry<T> in the Intergraph/Engineering Modeling System
     (I/EMS) Reference Manual<T>.

2.   Store the Macro in Library<T> --- The macros created using
     I/EMS associative geometry must be stored.  These macros
     libraries are created by the Review/Define Macro Libraries<T>
     command.  After the macro libraries the Create Macro
     Definition<T> command stores the macros in an object space.
     For more information, refer to the Intergraph/Engineering
     Modeling System (I/EMS) Reference Manual.<T>

3.   Create Parametric Catalog<T> --- After you add the stored
     macro in a macro library, you are ready to create a
     parametric catalog. A parametric catalog contains static
     and dynamic attributes used to represent the parametric
     parameters of the macro.

4.   Add Parts to Catalog<T> --- After you create the catalog, you
     can add parts.  When you add parts to the catalog, you are
     defining the static parameter values for each part in the
     family.

5.   Use Parts in Design<T> --- After parts have been created, the
     Place Part<T> command can place the parts in assemblies.

<S>Related Commands<T>

<XR>PDShLsPrIn
Show List of Parts In Catalog<T>
<XR>PDAdPr
Add Part<T>
<XR>PDAdPrPr
Add Parametric Part<T>
<XR>PDAdPrPj
Add Part To Project<T>
<XR>PDCPr
Change Part<T>
<XR>PDCPrPr
Change Parametric Part<T>
<XR>PDDlPr
Delete Part<T>
<XR>PDDfCtScCr
Define Search Criteria<T>
<XR>PDDfCtLsFr
Define Catalog In Database List Format<T>
<XR>PDDlCtLsFr
Delete Catalog In Database List Format<T>


<ETP>
<TP>locate
:Locating Parts and Files on the System:
As parts and files are added to the I/PDM system, it can
become increasingly difficult to locate these parts or files.
I/PDM provides utilities that simplify the process of locating
parts and files.  It is very important that you understand how
I/PDM locates parts and files. For related information, see the
following topic:<T>

1.   <ST>srch  Defining Search Criteria<T>

2.   <ST>checkin  Part Checkin and Checkout<T>

3.   <ST>checkout  Retrieve for Design<T>

4.   <ST>copylocal  Retrieve for Review<T>

5.   <ST>locfile  Local File Manager<T>


<ETP>
<TP>srch
:Defining Search Criteria:
I/PDM provides methods for searching for specific catalogs
and parts within the I/PDM system.  The following methods
can be used for searching for catalogs and parts.

1.   Classifications let you group catalogs based on their
     similarities and then separate them by their essential
     differences.  A properly implemented classification system
     makes it easier to search for catalogs in the database.  You
     can use the Classification<T> button on the Part Selection<T>
     form to display a list of valid classifications.  From this list
     you can display a list of catalogs found in each
     classification.

2.   Parts may be located using a condition which means that
     something specific is known about the part.  For example,
     the part number can be used.  An example of a condition
     would be: part number = 01 - 99.

3.   Parts may be located using a hierarchical search.  A
     hierarchical search is done when you do not know enough
     specific information to search for an exact part.  You
     conduct several hierarchical searches to narrow down the
     list until you find the information you need.  For example,
     you know that the part has an attribute named color<T>.  You
     can search for all parts that have color as an attribute.
     From that list, you can define another condition to narrow
     the list further.  This is done until you locate the part you
     need.

The search criteria that you use can be saved and used later.
You can select the Save<T> button on the Part Selection<T> form.
This will display a subform that lets you enter a name used to
save the search criteria.

The results of the search can be sorted before the list is
displayed. You can select the Sort<T> button on the Part
Selection<T> form.  This will display the Sort Parts<T> form that lets
you define the sort criteria.  The sort criteria can be saved and
used later.

<S>Related Commands<T>

<XR>PDDfCtScCr
Define Search Criteria<T>
<XR>PDDfCtLsFr
Define Catalog In Database List Format<T>
<XR>PDDlCtLsFr
Delete Catalog In Database List Format<T>


<ETP>
<TP>checkin
:Part Checkin and Checkout:
When parts are added to a catalog, a permanent storage
location is specified for the part record.  If the part is a
graphic part, a design file must be associated with the part.
Parts can be checked in or out from this permanent storage
location.

When a part is checked in, the design file associated with the
part is moved from the local directory to a specified storage
area.  The following illustrates the results of a part checkin.
Before the part, b-01<T>, is checked in, the file associated with
the part, part.ems<T> is stored on a local workstation.  After the
part is checked in, the file is moved to a permanent storage
area and saved as part.ems<T>.

<DG>
help_graphics/checkin.6h
<EG>

                                 Results of Part Checkin


<ETP>
<TP>checkout
:Retrieve for Design:
Before you can modify a part, it must be retrieved for design.
The Retrieve for Design<T> command copies a read and write
version of the part's reference file from the checkin storage
area to the working directory on the user's workstation.  This
working directory is the directory from which I/PDU was
invoked and opened for design. Although the file has been
moved from the permanent storage area, the part entry is still
in the database.  While the file is open for design, no other
user can retrieve the same file for design operations.

The following illustrates the results of the Retrieve for Design<T>
command.   A read/write version of part.ems<T> is copied from the
storage area to the local directory of the user's workstation.
Since this file has read/write permissions, the user can make
changes to the part and check the part back into the
permanent storage area.

<DG>
help_graphics/checkin.7h
<EG>

                              Results of Retrieve for Design


<ETP>
<TP>copylocal
:Retrieve for Review:
It was previously stated that when a part file is open for
design no other users can open the file for design.  Although
another user cannot retrieve the file for design, I/PDM does
let other users retrieve the part's file for review.  The Retrieve
for Review<T> command copies a read-only version of the part's
reference file from the checkin storage area to the working
directory on the user's workstation.  This working area is the
directory from which I/PDU was invoked.

The following illustrates the results of the Retrieve for
Review<T> command.  A read only version of part.ems<T> is copied
from the storage area to the local directory of the user's
workstation.  Since this file has read only permissions, the
user can not make changes to the part.  After the part is
reviewed, the part can be removed with the Delete File from
Local<T> command.

<DG>
help_graphics/local.8h
<EG>

                              Results of Retrieve for Review


<ETP>
<TP>locfile
:Local File Manager:
The I/PDM local file manager<T> keeps track of files that are
checked-out, copied, or moved for reference to the local
workstation and allows you to delete files that are not
needed.

When you retrieve a part for design, a read and write version
of the part's design file is copied to your workstation.  After
you complete the work, you are ready to check the part back
in.  When you  check in the part, the file is moved to the I/PDM
storage area and deleted from your workstation.  However,
when you check out parts that are referenced in an assembly
that is checked out, the deletion  of the part could pose a
problem.  Along with the files you have checked out, you can
copy part files to your workstation for viewing.  This increases
the number of files to be managed on your local workstation.
The local file manager solves these problems.  It monitors the
file's location and how the file reached its location.  It uses
the date-time stamp on the file and the file's location to
determine if a file transfer will occur.

I/PDM follows three rules in file transfer:

1.   If the file is not local, the file is moved.

2.   If the file is local, but the date-time stamp on the file is
     older than the file on the server, the file is moved.

3.   If the file is local, but the date-time stamp on the file is
     newer than the file on the server, the file is not moved.

<S>Related Commands<T>

<XR>PDCpFlTLc
Retrieve for Review<T>
<XR>PDChInPr
Check In Part<T>
<XR>PDCnPrChOt
Cancel Part Check Out<T>
<XR>PDAtPr
Attach Part<T>
<XR>PDDtPr
Detach Part<T>
<XR>PDDlLcFl
Delete Local File<T>


<ETP>
<TP>modify
:Modifying Part Information:
Sometimes it is necessary to modify existing parts and files.
For example, XYZ Bolt Company manufactures different types
of bolts.  A 1/2" fine thread bolt is represented by part number
blt05f<T>.  XZY wants to manufacture a 1/2" coarse thread bolt.
This could be very time consuming if a completely new
design file has to be created.  Fortunately, I/PDM provides
utilities that let you modify parts and files.

The Copy and Change Part<T> command copies information from
an existing part to a new part and lets you modify the new
part.  The XYZ company could use this command to create a
new part based on information from an existing part and
modify the design file associated with the new part.

<S>Note:<T>

The I/EMS Copy<T> command will not copy the file in the
database. <F>„<T>

Parts that are no longer needed can be deleted from a
catalog.  As discussed earlier, the user can flag a part to be
deleted by the system administrator.  However, this does not
remove the database entry for the part.  This is done with the
Delete Part<T> command.

<S>Note:<T>

The I/EMS Delete<T> command will not delete the file from the
database. <F>„<T>

For related information, see the following topic:<T>

<XR>assembly0 Assemblies<T>

<S>Related Commands<T>

<XR>PDShLsPrIn
Show List of Parts In Catalog<T>
<XR>PDAdPr
Add Part<T>
<XR>PDAdPrPj
Add Part To Project<T>
<XR>PDCPr
Change Part<T>
<XR>PDDlPr
Delete Part<T>
<XR>PDDfCtScCr
Define Search Criteria<T>
<XR>PDDfCtLsFr
Define Catalog In Database List Format<T>
<XR>PDDlCtLsFr
Delete Catalog In Database List Format<T>


<ETP>
