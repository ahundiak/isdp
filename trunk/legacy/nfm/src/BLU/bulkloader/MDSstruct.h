typedef struct  mds_struct
    {
    int  attrno;   /* attribute index into nfmattributes table */
    int  tableno;  /* index into nfmtables */
    int  name;     /* attribute name index */
    int  dt;       /* data type index */
    int  syn;      /* synonym index */
    int  app;      /* application index */
    int  r;        /* read index */
    int  w;        /* write index */
    int  u;        /* update index */
    int  d;        /* delete index */
    int  in;       /* checkin index */
    int  out;      /* checkout index */
    int  seq;      /* sequence number index */
    int  list;     /* list number index */
    } MDSptr;

typedef struct  cat_struct
    {
    int  name;     /* attribute name index */
    int  dt;       /* data type index */
    int  syn;      /* synonym index */
    int  app;      /* application index */
    int  r;        /* read index */
    int  w;        /* write index */
    int  u;        /* update index */
    int  d;        /* delete index */
    int  nul;      /* null index */
    int  in;       /* checkin index */
    int  out;      /* checkout index */
    int  seq;      /* sequence number index */
    int  attrno;   /* attribute index into nfmattributes table */
    int  tableno;  /* index into nfmtables */
    int  valueno;  /* index into value tables */
    int  adviceno; /* advice index */
    } CATptr;
