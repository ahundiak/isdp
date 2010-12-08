#ifndef PDMstruct_h
#define PDMstruct_h

typedef struct PDMpart
{
  char n_itemname[40];
  char n_itemrev[40];
  char n_itemdesc[40];
  char p_parttype[2];
}* PDMparts;

typedef struct PDMcatalog
{
  char n_catalogname[20];
  char n_catalogdesc[40];
  char n_type[4];
}* PDMcatalogs;

typedef struct PDMbom
{
  char p_bomname[21];
  int  n_catalogno;
  int  n_itemno;
}* PDMboms;

#endif
