-- ============================================================
-- Links isdp ops and copics numbering systems
-- For plates and beams 
-- 

create table tm_struct_ioc
(
  isdp_family   char(19),  -- Extra, for validation ?

  isdp_cage_num char(31),  -- Need the extra 6 characters
   ops_cage_num char(25),
   cop_cage_num char(25),
                           -- Store units along with numeric info, 60SF
  cop_size      char(19),  -- Stock Length or Area
  cop_max_x     char(19),  -- Optional max x size
  cop_max_y     char(19)   -- Optional max y size

);

create index tm_struct_ioc_i1 on tm_struct_ioc(isdp_cage_num);
create index tm_struct_ioc_i2 on tm_struct_ioc( ops_cage_num);
create index tm_struct_ioc_i3 on tm_struct_ioc( cop_cage_num);
create index tm_struct_ioc_i4 on tm_struct_ioc(isdp_family,isdp_cage_num);

