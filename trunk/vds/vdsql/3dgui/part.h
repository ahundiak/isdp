#ifndef PART_H
#define PART_H

typedef struct
{
  char cat_name[20];
  char num [16];
  char rev [ 8];
  char desc[40];
  int  zone;
  int  unit;
  int  type;  
  char state[16];
  char extr_name[16];  /* The file name with no extension */
  char file_name[16];
  int  file_ver;
  int  file_key;
  char file_date[20];
  char extr_date[20];
} TpdmPart;

extern int load_part_list_file(sqlite *db, char *fileName);

extern int qry_pdm_part(sqlite *db, char *part_num, TpdmPart *part);

extern int create_part_table(sqlite *db);

extern int insert_part(sqlite *db, TpdmPart *part);

/* Full ISDP Information */
typedef struct
{
  char catalog[32];
  char part   [32];
  char rev    [32];

  int  catalog_num;
  int  part_num;
  int  file_num;

  int  sa_num;
  int  sa_node_num;

  char sa_node_path[128];
  char sa_node_name [32];

  char sa_user_name [32];
  char sa_user_pass [32];
  
  char sa_file_name [32];
  char sa_file_date [32];
  char co_file_name [32];
    
  char n_statename[32];
} TpdmInfo;


#endif

