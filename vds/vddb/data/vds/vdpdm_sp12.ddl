--*******************************************
-- vdpdm update ddl.  This is additional tables
-- which need to be created for added vdpdm functionality
--
-- vdpdm_post_date    table used to display when a table was
--                    posted to.
--
--
--*******************************************

create table VDPDM_POST_DATE   -- post dates for all dynamic tables
(
    FILE_KEY      integer,
    DB_TABLE      char(40),
    POST_DATE     char(40)
);
