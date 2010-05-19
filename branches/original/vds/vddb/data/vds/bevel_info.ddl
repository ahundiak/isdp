create table bevel_info
(
  bevel_key   integer,
  bevel_data  char(100)
);

create index bevel_info_i1 on bevel_info(bevel_key);
create index bevel_info_i2 on bevel_info(bevel_data);


