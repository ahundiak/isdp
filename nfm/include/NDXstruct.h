#ifndef NDX_STRUCT_H
#define NDX_STRUCT_H

typedef struct  ndx_struct
    {
    int  name;     /* attribute name index */
    int  dt;       /* data type index */
    int  syn;      /* synonym index */
    int  nfm;      /* nfm name index */
    int  open;     /* open to nfm index */
    int  app;      /* application index */
    int  r;        /* read index */
    int  w;        /* write index */
    int  u;        /* update index */
    int  d;        /* delete index */
    int  nul;      /* null index */
    int  key;      /* keyin index */
    int  in;       /* checkin index */
    int  out;      /* checkout index */
    int  seq;      /* sequence number index */
    int  list;     /* list number index */
    } NDXptr;

typedef struct  ndx_new_struct
    {
    int  name;     /* attribute name index */
    int  dt;       /* data type index */
    int  syn;      /* synonym index */
    int  nfm;      /* nfm name index */
    int  open;     /* open to nfm index */
    int  app;      /* application index */
    int  r;        /* read index */
    int  w;        /* write index */
    int  u;        /* update index */
    int  d;        /* delete index */
    int  nul;      /* null index */
    int  key;      /* keyin index */
    int  in;       /* checkin index */
    int  out;      /* checkout index */
    int  seq;      /* sequence number index */
    int  list;     /* list number index */
    int  new_name;     /* attribute name index */
    int  new_dt;       /* data type index */
    int  new_syn;      /* synonym index */
    int  new_open;     /* open to nfm index */
    int  new_app;      /* application index */
    int  new_r;        /* read index */
    int  new_w;        /* write index */
    int  new_u;        /* update index */
    int  new_d;        /* delete index */
    int  new_nul;      /* null index */
    int  new_key;      /* keyin index */
    int  new_in;       /* checkin index */
    int  new_out;      /* checkout index */
    int  new_seq;      /* sequence number index */
    int  new_list;     /* list number index */
    } NDXnewptr;

typedef struct  ndx_newer_struct
    {
    int  syn ;     /* synonym name index */
    int  null;     /* null index */
    int  r;        /* read index */
    int  advise;   /* advise number index */
    int  list;     /* value list index */
    } NDXnptr;

#endif
