create table vdat_blobs
(
  file_key  integer,
  purpose   char(29),
  hull      char( 9),
  set_type  char(19),
  set_name  char(39),
  set_ver   integer,
  set_cur   integer,
  post_date char(19), -- YYYYMMDDHHMMSS
  blob_key  integer
);

create index vdat_blobs_i1 on vdat_blobs(purpose,hull,set_type,set_name,set_cur);
create index vdat_blobs_i2 on vdat_blobs(post_date);

create table isdp_blobs
(
  blob_key  integer,
  blob_sort integer,
  blob_data ris_blob(10000)
);

create index isdp_blobs_i1 on isdp_blobs(blob_key,blob_sort);

