<TP>cat0
:Catalogs:
I/PDM uses catalogs to manage the parts and assemblies that
are created through I/PDU.  Think of a catalog as a table in
which each row contains information about a part.  The
information is known as its attributes<T>.

<S>Attributes<T>

Catalogs can contain three types of attributes:

1.   System Attributes

2.   User-defined Static Attributes

3.   User-defined Dynamic Attributes

System<T> attributes contain information that I/PDM needs to
manage the part.  System attributes contain two required
attributes:

1.   Part Number

2.   Part Revision

The system attributes may not provide enough information
about the part.  User-defined<T> attributes let you create
additional attributes when creating a catalog.  For example,
you may get parts from six different suppliers.  You can
define an attribute, supplier<T>, to better describe the part.  User
attributes are said to be static<T>.  This means that the attribute
is given a value when the part is added, and the value does
not change.  The value for the attribute can change when
parts are added, but the attribute does not change.  For
example, a catalog may contain an attribute, material<T>.  Every
part that is added to the catalog will contain the attribute,
material, but the value for the attribute may vary from part to
part.

I/PDM also has dynamic<T> attributes.  These attributes are
placement specific, which means that these attributes have
meaning when parts are placed in assemblies.  For example,
diameter can be defined as a dynamic attribute, so that when
a part is placed in an assembly, the system prompts for a
diameter.

After attributes have been added, you might need to change
the synonym for an attribute.  You can use the Change
Attribute<T> button on the Catalog Attributes<T> form to change the
synonym for an attribute.  You cannot change the attribute
name or character type for attributes.

When adding or changing attributes, you must be careful not
to used reserved words<T>.  These are words that are reserved by
the database management system being used.  For a list of
reserved words, refer to the RIS Reference Manual (DNA0032)<T>.

<S>Catalog Types<T>

There are three types of catalogs used in I/PDM:

1.   Standard Catalogs

2.   Parametric Catalogs

3.   External Catalogs

Standard<T> catalogs contain standard parts.  These parts can be
graphic, non-graphic, macro libraries, and drawings.

Parametric<T> catalogs contain parametric parts.  There are
actually two types of parametric catalogs based on how the
part number and part description information is entered.  The
two types of parametric catalogs are:

1.   Standard Parametric<T> catalogs contain parametric parts in
     which the part number and part description are keyed in
     when adding parts.  The parametric catalog definition
     comes from the existence of the catalog tables and
     dynamic attribute tables.  There is a row in the database for
     every part in the catalog.

2.   Computed ID Parametric<T> catalogs contain parametric parts
     in which the part number and part description are derived
     from a formula associated with the catalog.  All parts in
     this catalog use the formula to derive the part number and
     part description.  These catalogs are defined as views of a
     system table (catalog table) and some data tables from an
     external source such as DIN standard.  There does not
     have to be a row in the database for every part in this type
     of catalog.

External<T> catalogs contain data from an external source.
There are actually two types of external catalogs:

1.   Standard external<T> catalogs are populated by importing
     data from an external source.  The catalogs can contain
     regular parts in which the external part number<T> is mapped
     with the customer part number.<T>  The external part number
     is the number stored in the database describing an I/PDM
     part.  The customer part number is the number assigned by
     the customer and is used only in report generation.

2.   Computed ID<T> catalogs are similar to computed ID
     parametric<T> catalogs and are defined as views of system
     tables and external data tables.  Like standard external
     catalogs, computed ID catalogs are populated from an
     external source.  The computed part number is mapped to
     the customer defined part number.  The customer defined
     part number is used only for report generation.

For related information, see the following topic:<T>

1.   <ST>catalogs  Catalogs<T>

2.   <ST>classify  Catalog Classification<T>

3.   <ST>changecat  Changing Catalogs<T>

4.   <ST>catmap  Catalog Mapping<T>


<ETP>
<TP>catalogs
:Creating Catalogs:
The number of catalogs that can exist in an environment is
limited only by the amount of disk space.  There must be at
least one catalog.

The number of catalogs created depends on the the types of
parts managed by I/PDM.   Suppose company ABC wants all
the parts it designs to reside in the same catalog.  ABC has
three kinds of parts: electric motors, bearings and bolts.
Electric motors require horsepower and amperage as
attributes, bearings require diameter and material as
attributes, and bolts require diameter, pitch and material as
attributes.  If the company keeps all of these attributes in one
catalog, six user-defined attributes are required.  For bearing
parts, the columns for horsepower, amperage, pitch and
height may not contain a value.  The result is a catalog with
wasted space and a lack of organization.  In this case, it is
better to have a separate catalog for each kind of part.  A
preliminary analysis shows that the number of catalogs
depends on the number of different types of parts and
assemblies.  The common rule is that similar parts reside in
the same catalog.

Of the three catalog types used in I/PDM, the user can create
standard catalogs and parametric catalogs.  External
catalogs contain information from external sources and are
not created by the user.

<S>Rules for Creating Catalogs<T>

The following rules apply to creating I/PDM catalogs.

<X>õ<T>   Catalog names can be either upper or lower case.

<X>õ<T>   Catalog names can contain up to 14 characters.

<X>õ<T>   Catalog names can not start with ris<T>.

<X>õ<T>   Catalog attributes can contain up to 20 characters.

<X>õ<T>   Catalog attributes can not contain an underscore (_) as
     the second character.

<S>Related Commands<T>

<XR>PDCrCt
Create Catalog<T>
<XR>PDDlCt
Delete Catalog<T>


<ETP>
<TP>classify
:Catalog Classifications:
Classification<T> groups similar items together based on their
similarities and then separates them by their essential
differences. For example, suppose company xyz produces
fasteners.  These fasteners can be nuts or washers.  All parts
produced by the company are similar and could be grouped
together in a classification called fasteners<T>.  However, there
are essential differences between washers and nuts.
Therefore, creating additional classifications separates these
parts into two distinct classifications --- nuts<T> and washers.<T>
As previously defined, an I/PDM catalog<T> is a set of parts that
contain the same attributes.  As catalogs are created, they
can be assigned a hierarchial classification of any number of
levels.  When new parts are added, they can be added to the
correct catalog classification.  If the new part does not
belong to an existing classification, you can create a new
catalog and define a new classification for the part.

<S>Why use classifications?<T>

As the number of catalogs needed in the I/PDM system
increases, it may become more difficult to quickly access a
specific part in the database.  Properly classifying catalogs
lets you identify a relatively small group of catalogs that
contain a specific part rather than search through every
catalog in the database.

<S>How are classifications designed?<T>

Before a classification system can work effectively, it must
be properly designed.

The classification must be contain all of the items that
already exist, but flexible enough to accommodate any new
items.

The parameters of the classification must be clearly defined
to make sure that only similar items are grouped together.
For example, whenever a new part is added to a catalog, it
should be clear that no other catalog contains the
characteristics of this part.

The classification must be based on permanent
characteristics that will not change over time.  This ensures
that no matter how many items are added to the
classification, the classification will remain consistent.

The classification should be developed from the user's
point-of-view. Since the user will be searching for parts and
catalogs in the database, the parts and catalogs should be
classified in a way that is easy for the user to access.

With these principles established, there are a few things that
can be done to design the classification.

<X>õ<T>   Determine the user's needs before designing the
     classification.

<X>õ<T>   Define the scope of the classification and determine
     what data should be included.

<X>õ<T>   Once you have determined the data to be included in the
     classification, try to use as few attributes as necessary to
     create well defined catalogs within the classification.  Do
     not include any meaningless or redundant attributes that
     might slow down searches and other processes.

<S>Example classification<T>

The following illustrates an example of a four level
classification. As you can see, classifying the catalogs into
levels makes it easier to choose the correct catalog when
adding new parts or searching for existing parts.

<DG>
help_graphics/catalogs0.6h
<EG>

                                Four Level Classification

<H>Adding Classifications<T><T>

Classifications are created with the Catalog Operations<T> form
in New<T> mode.  At least one catalog must be created at the
lowest level of the classification when the classification is
created. For example, if you are adding  a first level
classification called Fasteners<T>, you must add at least one
catalog when you are creating this classification.  As new
classifications are needed they can be added to the system as
a first level classification or a sub-level of an existing
classification.

The following describes how to create a portion of the
classification system previously discussed and add a catalog
to the Hex<T> classification.

1.   Make sure you are in New<T> mode of the Catalog Operations<T>
     form.

2.   Key in locknut<T> in the Catalog Name<T> field of the Catalog
     Operations<T> form.

3.   Key in locknut<T> in the Description<T> field of the Catalog
     Operations<T> form.

4.   Enter a data point in the Catalog Classification<T> palette.

     A subform containing the entry, new category<T> plus a list of
     any classifications and catalogs found at this level is
     displayed.

5.   Key in Parts<T> and press <Return>.

     The classification name is entered in the Catalog
     Classification<T> palette and the cursor goes to the next line.

6.   Key in Fasteners<T> and press <Return>.

     The classification name is entered in the Catalog
     Classification<T> palette and the cursor goes to the next line.

7.   Key in Nuts<T> and press <Return>.

     The classification name is entered in the Catalog
     Classification<T> palette and the cursor goes to the next line.

8.   Key in Hex<T> and press <Return>.

     The classification name is entered in the Catalog
     Classification<T> palette and the cursor goes to the next line.

     The following illustrates the Catalog Operations<T> form after
     this information is entered.

9.   Exit and save the form.

     The Catalog Attribute<T> form appears.

10.  We will not add any attributes, so exit the form.

     The classification system is created and the catalog,
     locknut, is added to the classification, Hex.

Now that this classification system has been created, new
classifications and catalogs can be added to any of the
existing classifications.


<ETP>
<TP>changecat
:Changing Catalogs:
After a catalog is created, it may become necessary to change
the catalog.  You can change an existing catalog, or copy an
existing catalog to a new catalog and change the new
catalog.  I/PDM lets you add additional user-defined or
dynamic attributes to the new catalog.  When new attributes
are added to a catalog, I/PDM lets you define a range of
values or a list of possible values that are valid for the
attributes. You can also change a user-defined attribute or a
list of user-defined attributes.  When an attribute is added,
the second character in the attribute name cannot be an
underbar (_).

<S>Related Commands<T>

<XR>PDDlCt
Delete Catalog<T>


<ETP>
<TP>catmap
:Catalog Mapping:
The information contained in catalogs must be protected.  As
new parts are added, you want to make sure that the files
associated with the parts are stored in the proper place.  Also,
you may want to limit access to these catalogs and parts.
I/PDM lets you map catalogs to storage areas and ACLs.

<S>Mapping Catalogs to Storage Areas<T>

A storage area is a directory where EMS design files are
stored.  There can be as many storage areas as needed.  These
storage areas are typically located on the I/PDM server, but
can be spread throughout the network.

A preliminary analysis of the company workflow will reveal
the number of storage areas that are needed.  The number
required is a function of the disk space availability and the
way files are grouped for convenience.  For example, all
model files for product X are stored in storage area S. You can
ensure that this occurs by mapping the catalogs containing X
file information to storage area S.  When someone adds a part
to catalogs for part X, the information will be stored in storage
area S.

Mapping catalogs to storage areas offers easy access to
catalogs, better organization, and more security.

<S>Mapping Catalogs to ACLs<T>

ACLs is a list of users divided into user classes.  As users are
added to user classes, they are given access to the commands
within the user class.

As the number of users within a particular user class
increases, a problem of data security may arise.  I/PDM helps
you solve this problem by mapping the catalog to an ACL.

By mapping the catalog to an ACL, you restrict user access to
the catalog data, providing more security to the data.

<S>Related Commands<T>

<XR>PDAdPr
Add Part<T>
<XR>PDAdPrPj
Add Part To Project<T>
<XR>PDCPr
Change Part<T>
<XR>PDDlPr
Delete Part<T>


<ETP>
