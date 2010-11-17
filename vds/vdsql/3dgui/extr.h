/* ----------------------------------------------
 * Extracted part information
 */
#ifndef EXTR_H
#define EXTR_H

typedef struct 
{
  char extr_name[16];
  int  extr_set;
  int  have_pdm;
  int  have_dup;
  int  have_xml;
  int  have_mdl;
  int  have_ped;
} TpdmExtrPart;

extern int qry_extr_part(sqlite *db, char *part_num, TpdmExtrPart *part);

extern int insert_extr_part(sqlite *db, TpdmExtrPart *part);

extern int process_extracts(sqlite *db, char *dataPath, char *xmlDir, int extr_set);

extern int check_extracts(sqlite *db);


#endif
