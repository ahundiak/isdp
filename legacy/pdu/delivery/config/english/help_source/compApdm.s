<TP>pdm_schema
:I/PDM Schema:
This appendix outlines the I/PDM conceptual schema. All
I/PDM required attributes are prefixed with p_<T> and all I/PDM
tables have been prefixed with pdm<T>.  Most of the tables and
all of the templates (a grouping of attributes stored in
nfmattributes table) are created during I/PDM initialization.
The templates are then used by the PDMserver<T> to provide the
required server functionality.  It is important to note that the
schema described here is specific to I/PDM and can be
thought of as an extension to the I/NFM schema.  Together
these two schemas help realize the required relational data
model for I/PDM.

For more information about the I/NFM schema, see the I/NFM
Reference Manual<T>.

<S>bom_template --- Template<T>

This template is defined primarily to store the content of a
I/PDM bill of materials report.  It will contain the system
required attributes.  Users can modify/update it with
user-defined attributes.  These attributes must then be
mapped.
<F>

Attribute       Data Type      Description

p_tagno         integer        Unique tag no.
p_alttagno      char(25)       Alternate tag no.
n_catalogname   char(16)       Name of the catalog.
n_itemname      char(15)       Name of the part.
n_itemrev       char(15)       Revision of the part.
n_itemdesc      char(40)       Part description.
n_creationdate   timestamp      Part creation date.
n_updatedate    timestamp      Part update date.
p_attached      char(1)        Reference file
                               attachment. ( Y or N )
p_history       char(10)       Part history.
p_quantity      double         Part quantity.
p_childno       integer        Child assembly number.
p_usageid       char(25)       Part usage ID.
p_viewid        char(25)       Graphic View ID (will
                               be dropped in future).
p_incpartrpt    char(1)        Include part in report.
p_mrpbomuom     char(10)       BOM unit of measure.
p_mrpeffectdate   char(8)        MRP effective date.
p_mrpinvuom     char(10)       MRP inventory unit of
                               measure.<T>
<S>pdmbommap --- Table<T>

This tables keeps the mapping of user defined attributes in
the pdmbomcontent template.
<F>

Attribute       Data Type      Description

p_bomattrno     integer        Index into
                               nfmattributes indicates
                               the template attribute
                               being mapped.
n_catalogno     integer        Index into
                               nfmattributes.
p_mapattrno     integer        Index into
                               nfmattributes indicates
                               the attribute in the
                               catalog.<T>
<S>pdmboms --- Table<T>

This table keeps track of all the BOM types.
<F>

Attribute       Data Type      Description

n_catalogno     integer        Index into nfmcatalogs.
n_itemno        integer        Index into <catalog>.
p_createdate    timestamp      BOM creation date.
p_bomname       char(20)       BOM table name.
p_locked        char(1)        Flag for BOM track.<T>
<S>pdmcatalog --- Template<T>

This is a list of NFM catalog attributes whose synonyms have
been renamed in I/PDM catalogs.  The data types remain the
same.
<F>NFM Name        PDM Synonym

n_itemname      Part Number
n_itemrev       Part Revision
n_itemdesc      Part Description
n_cofilename    Local Filename
n_cifilename    Storage Filename
c_coout         File Status
n_setindicator   Assembly Indicator
n_archivestate   Archive State
n_creationdate   Part Creation Date
n_updatedate    Part Update Date

<T>
The following attributes are added and are specific to I/PDM
catalogs.
<F>Attribute       Data Type      Description

p_explode       char(1)        Indicates if the
                               assembly is to be
                               exploded in BOM. (Y or
                               N)
p_maxlevel      integer        Indicates the level to
                               which the assembly
                               needs to be exploded in
                               a BOM report.  Used
                               only if p_seplode is
                               set to Y.
p_parttype      char(1)        Part type
p_incpartrpt    char(1)        Indicates if part is to
                               be included in summary.
p_mrpbomuom     char(10)       BOM unit of measure.
p_mrpeffectdate   char(8)        MRP effective date.
p_mrpinvuom     char(10)       MRP inventory unit of
                               measure.
p_mrpfieldupd   char(20)       MRP field update.
p_mrppart       char(1)        MRP part.
p_mrpstruct     char(1)        MRP structure.<T>
<S>pdmcit --- Table<T>

This table is an extension to nfmsetcit and stores I/PDM
specific data in a parent-child relationship.
<F>

Attribute       Data Type      Description

p_citno         integer        Index into nfmsetcit.
p_attached      char(1)        Reference file
                               attachment.
p_history       char(10)       Part history.
p_orient        char(240)      Graphic orientation.
p_quantity      double         Part quantity.
p_childno       integer        Child assembly number.
p_usageid       char(25)       Part usage ID.
p_viewid        char(25)       Graphic view ID.
p_tagno         integer        Unique tag no.
p_alttagno      char(25)       Alternate tag no.
p_incbom        char(1)        Include in BOM.
                               Default is Y<F>.
p_explode       char(1)
p_pdcno         integer        Index into y_xxx table.
n_catalogname   char(40)       Catalog name of part.
n_itemname      char(40)       Part number.
n_itemrev       char(40)       Part revision.
n_cofilename    char(14)       Filename of Part
                               Attached.<T>
<S>pdmdrawings --- Catalog<T>

Catalog to store drawings and drawing sheet information.
This is the default catalog that drawings are stored in unless a
user specifies a drawing catalog created by the database.

<S>pdmdraw_template --- Template<T>

This template is used for addition of attributes to the
<catalog> table to support the drawing information.
<F>

Attribute       Data Type      Description

p_mcatno        integer        Index into nfmcatalogs.
p_mitemno       integer        Index into <catalog>.
p_sheetcount    integer        Number of sheets in
                               drawing.<T>
<S>pdmfdraw_template --- Template<T>

This template is used for addition of attributes in the
f_<catalog> table to support drawing sheet information.
<F>

Attribute       Data Type      Description

p_sheetno       integer        Sheet number.
p_sheetdesc     char(25)       Description of sheet.
p_seedfile      char(14)       Seedfile used to create
                               sheet.
p_size          char(1)        Drawing size.<T>
<S>pdmfilename --- Table<T>

This table stores next available filename that is numeric.
<F>

Attribute       Data Type      Description

p_cofilename    char(14)       Next available numeric
                               filename.<T>
<S>pdmcatalogs ---Table<T>

This table stores catalog characteristics.
<F>

Attribute       Data Type      Description

n_catalogno     integer        Index into nfmcatalogs.
p_autofilename   char(1)        Automatic filename
                                generation for parts in
                                catalog (Y or N).
p_dyntable      char(18)       Table name of where
                               catalog's dynamic
                               attribute information
                               is stored.
p_defname       char(40)       Default part placement
                               name/usage id.
p_level1        char(50)       Level 1 - n values
                               define the hierarchial
                               path to all PDM
                               catalogs.
p_level2        char(50)
p_level3        char(50)
p_leveln        char(50)
p_depth         integer        Depth of the catalog
                               definition<T>
<S>pdmparameters --- Table<T>

This table is used to store the parameter definition type of the
template of a macro.
<F>

Attribute       Data Type      Description

n_catalogname   char(18)       Name of parametric
                               catalog.
n_synonym       char(40)       Description of the
                               parameter
p_templatename   char(20)       Name of the template
                                parameter.
p_type          char(20)       Template type.
p_iotype        char(3)        Indicates static or
                               dynamic. SC<F> ---
                               Static, DC<F> ---
                               Dynamic, DL<F> ---
                               Dynamic locate.
p_units         char(10)       Units of template<T>
<S>pdmparamloc --- Table<T>
<F>Attribute       Data Type      Description

n_catalogname   char(18)       Name of the parametric
                               catalog.
p_macrocat      char(18)       Name of the macro
                               library catalog.
p_macropartno   char(40)       Part Number of the
                               macro library
p_macrorev      char(40)       Revision of the macro
                               library.
p_macroname     char(30)       Name of the macro in
                               the macro library.
p_rle           char(14)       Name of the rle sketch
                               file.<T>
<S>pdmseedfiles --- Catalog<T>

This catalog stores seed files used by the drawing subsystem
in I/PDM. The n_itemname defaults to the seedfile name, the
revision to A<T>, the storage area NFMfiles, and the ACL to
PDM_ITEM_ACL.

<S>pdmtables --- Table<T>

 This table keeps track of the I/PDM specific tables.
<F>

Attribute       Data Type      Description

n_catalogno     integer        Index into nfmcatalogs.
n_itemno        integer        Index into <catalog>.
p_createdate    timestamp      Creation date.
p_tablename     char(20)       Table name.
p_tabletype     char(1)        Table type.
p_locked        char(1)        Flag for table lock.<T>
<S>pdmviews --- Template<T>

This template contains all the attributes required to store the
view information.  There is one view table per catalog.  The
template is used to create the pdmviews table.
<F>

Attribute       Data Type      Description

n_itemno        integer        Index into catalog.
p_origin        char(100)      Graphic view origin.
p_rotation      char(240)      Rotation matrix.
p_viewname      char(40)       View name.<T>
<S>v_<catalog> --- Table<T>

This table is created when the catalog is created.  It is created
with the attributes in the pdmviews template.

<S>y_<catalog> --- Table<T>

This table is created for catalogs containing dynamic
attributes.  When creating the catalog, users may specify a
different table name for dynamic attributes or an existing
dynamic table to store the dynamic values.  These values are
loaded during I/PDM checkin.  There is a column representing
each user defined dynamic attribute.
<F>

Attribute       Data Type      Description

p_citno         integer        Index into nfmsetcit.
p_pdcno         integer        Unique table index.<T>
<S>psurptopts --- Table<T>

This table stores the report name and the definition of the
title, width, etc.  There will be one row for each type of report.
<F>

Attribute       Data Type      Description

p_templateno    integer        Unique table index.
p_table         char(30)       Name of the table
                               report will be
                               generated against.
p_templatename   char(20)       Name of the template
                                (report).
p_templatetype   char(2)        Type of template
                                (report).
p_description   char(50)       Description of template
                               (report).
p_output        char(50)       Output filename.
p_title         char(50)       Title of report.
p_subtotals     integer        Number of sub-total
                               lines.
p_totals        integer        Number of total lines.
p_width         integer        Width of the report.
p_lines         integer        Lines per page.
p_templib       char(20)       Name of the template
                               library.<T>
<S>psurptlist --- Table<T>

This table contains information about the report name.
<F>

Attribute       Data Type      Description

p_templateno    integer        psurptopts Table index.
p_name          char(18)       Column/Attribute name.
p_header        char(30)       Column Header.
p_type          integer        Field type (0-column,
                               1-counter).
p_start         integer        Start position relative
                               to 1.
p_length        integer        Column width.
p_decimal       integer        Decimal places for
                               floating pt.
p_sort          integer        0-don't sort, 1-n
                               sequential key.
p_subtotal      integer        0-don't subtotal,
                               1-subtotal column.
p_total         integer        0-don't total, 1-total
                               columns.
p_justification   integer        Column justification.<T>

<ETP>
