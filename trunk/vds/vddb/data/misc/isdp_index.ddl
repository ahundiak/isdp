create table isdp_index
(
  index_key  integer,
  index_data char(40)
);

create index isdp_index_i1 on isdp_index(index_key);
create index isdp_index_i2 on isdp_index(index_data);


