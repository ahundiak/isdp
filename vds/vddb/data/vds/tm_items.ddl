-- ============================================================
-- Master list of all tree manager items (parts, assemblies etc)
-- 
create table tm_items
(
  item_id           char(19),  -- Unique record number
  item_type         integer,   -- Part, Standard Assy, Other
  item_src          integer,   -- OPS, ISDP File

  item_cage_num     char(25),  -- The master index???
  item_cage_code    char(5),
  item_num          char(19),  -- Also called mino
  item_rev          char(4),   -- Just for tracking
  item_cur_rev      integer,   -- Current or active

  noun_name         char(25),  -- For grouping
  type              char(25),
  modifier          char(25),

  comm_code         char(12),  -- make it compatible with tm_assys

  discipline        integer,
  classification    integer,

  unit_of_measure   char(2),
  copics_short_desc char(25),  -- copics_short_description
  updatedate        char(19)
);

-- Select distinct noun_name from tm_items where 
--   item_cur_rev = 1 and item_type = 4
-- Select distinct comm_code from tm_items where 
--   item_cur_rev = 1 and item_type = 4

-- Select from tm_items where 
--   noun_name = "NOUN" and item_cur_rev = 1 and item_type = 4
--   order by item_cage_code

-- Select from tm_items where 
--   item_cage_code = "" and item_cur_rev = 1 and item_type = 4

-- Delete from tm_items where item_src = OPS

-- Delete from tm_item_attrs where
--   tm_item_attrs.item_id = tm_items.item_id and tm_items.item_src = OPS

-- Lots of possibilites, just create the ones know need for now
-- 
create index tm_items_i01 on tm_items(item_src);
create index tm_items_i02 on tm_items(item_cur_rev,item_type);

create index tm_items_i03 on tm_items(item_cur_rev,item_type,noun_name);
create index tm_items_i04 on tm_items(item_cur_rev,item_type,noun_name,item_cage_code);

create index tm_items_i05 on tm_items(item_cur_rev,item_type,comm_code);
create index tm_items_i06 on tm_items(item_cur_rev,item_type,comm_code,item_cage_code);

create index tm_items_i07 on tm_items(item_cur_rev,item_type,item_cage_code);
create index tm_items_i08 on tm_items(item_cur_rev,item_cage_code);

-- ===============================================
-- Contains a list of attributes for a given item
-- 

create table tm_item_attrs
(
  item_id       char(19), -- Link to tm_items

  attr_name     char(31), -- Attribute name
  attr_value    char(79), -- The actual value
  attr_sort     integer,  -- Allow controlling order returned

  attr_info     char(79)  -- future use, specific info about an attribute 
                          -- such as data type or length
);

create index tm_item_attrs_i1 on tm_item_attrs(item_id);
create index tm_item_attrs_i2 on tm_item_attrs(item_id,attr_sort);
create index tm_item_attrs_i3 on tm_item_attrs(item_id,attr_name);

-- ===============================================
-- Contains product structure for an item
-- 
create table tm_item_ps
(
  item_id          char(19),    -- Link to tm_items table
  item_id_ps       char(19),    -- child index

  ps_sort          integer,     -- Order to extract
  ps_qty           char(19),    -- qty per part
  ps_date          char(19)
);

create index tm_item_ps_i1 on tm_item_ps(item_id,ps_sort);
create index tm_item_ps_i2 on tm_item_ps(item_id_ps,item_id);

-- ============================================================
-- Maps isdp cage numbers (usually for struct) to ops cage numbers
-- 
create table tm_isdp_item
(
  item_cage_num     char(25),  -- OPS
  isdp_cage_num     char(25)   -- ISDP
);

create index tm_isdp_item_i1 on tm_isdp_item(item_cage_num);
create index tm_isdp_item_i2 on tm_isdp_item(isdp_cage_num);



