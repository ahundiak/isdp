
-- ===============================================
-- Contains product structure for an item
-- 
create table tm_ps
(
  parent_cage_num  char(25),    -- OPS item in tm_items
  child_cage_num   char(25),    -- OPS Child

  ps_sort          integer,     -- Order to extract
  ps_qty           char(39),    -- qty per part
  ps_date          char(19)     -- Date posted
);

create index tm_ps_i1 on tm_ps(parent_cage_num,ps_sort);
create index tm_ps_i2 on tm_ps(child_cage_num,parent_cage_num);


