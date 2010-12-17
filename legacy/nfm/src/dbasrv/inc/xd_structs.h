/* $Revision: 1.1 $ */
#ifndef xd_structs
#define xd_structs

struct xd_header_1
{
    unsigned short ele_header;
    unsigned short wtf;      
    unsigned short data_type_code;
    unsigned short application_type;
    double xor, yor, zor, xdl, ydl, zdl;
    double tmatrix[16];
    unsigned int ppl, nol;
    unsigned short dev_res;
    unsigned char sloc, scan_flag;
    unsigned int rot[2];
    unsigned int skew[2];
    unsigned short dtm;
    char design[66], dbase[66], grid[66], description[80];
    unsigned char min_v[8];
    unsigned char max_v[8];
    unsigned char reserved[3];
    unsigned char version;
};

struct xd_header_2
{
    unsigned char gain, offset, vw_sc1, vw_sc2, vwn, reserved;
    unsigned short ent, acv, aid, ari, aiv;
    unsigned int cfp;
    unsigned short ctv, rct;
    unsigned int cte;
    unsigned int dp_offset;
    unsigned int dp_length;
    unsigned short rfu[110];
    unsigned short app_data[128];
};

struct xd_data_packet
{
    unsigned short application_type;
    unsigned short sub_type;
    unsigned int wtf;
};

struct xd_tile_packet
{
    unsigned short application_type;
    unsigned short sub_type;
    unsigned int wtf;
    unsigned short version;
    unsigned short identifier;
    unsigned short rfe0[2];
    unsigned short properties;
    unsigned short data_type;
    char rfe1[100];
    unsigned int tile_size;
    unsigned int rfe2;
    unsigned int s0, a0, u0;
};

struct xd_overview_packet
{
    unsigned short application_type;
    unsigned short sub_type;
    unsigned int wtf;
    unsigned short version;
    unsigned short identifier;
    unsigned short rfe0[2];
    unsigned int num_overviews;
    unsigned int num_rows;
    unsigned int num_columns;
};

#endif
