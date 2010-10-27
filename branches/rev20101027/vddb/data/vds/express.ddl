
create table OPE_EXPR_TABLE             -- expression table master --
(
        EXPR_TYPE                       char(12),
        TABLE_NAME                      char(12),
        TIMESTAMP_0                     char(24),
        USERID_0                        char(12),
        EXPR_DESC                       char(80),
        DATA_TYPE                       smallint
);

create table OPE_DATA_TABLE             -- Text buffer table --
(
        TABLE_NAME                      char(12),
        DATA_GROUP                      char(4),
        DATA_SEQN                       smallint,
        DATA_INFO                       char(240)
);

