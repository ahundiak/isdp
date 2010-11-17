#include "stdlib.h"
#include "VDdom2.h"
#include "sqlite.h"
#include "dirent.h"

#include "db.h"
#include "part.h"

#define DATA_PATH_HVL "/net/usshville/C/3dgui"
#define DATA_PATH     "/export/home/impd/sp263/isdp/vds/vdsql/3dgui"

int main(int argc, char *argv)
{
  int sts;
  sqlite *db = NULL;
  char buf[256];

  /* Say Hi */
  printf("=== Beg Run ===\n"); 
  domSuppressErrors();

  /* Init */
  setRisServer("lpd");

  /* Rebuild from stratch */
  if (argc > 1) {

    /* New database */
    db = init_database("pdm");
    if (db == NULL) goto wrapup;

    create_part_table(db);

    /* Load master list */
    sprintf(buf,"%s/%s",DATA_PATH,"list_part_all.txt");
    sts = load_part_list_file(db,buf);
    if (!(sts & 1)) goto wrapup;

    /* Create part indexes */
    create_part_indexes(db);
    if (1) goto wrapup;

    /* Pedigree information */
    sprintf(buf,"%s/%s",DATA_PATH,"isdp");
    process_pedigrees(db,buf);
    check_pedigrees(db);

    /* Actual extractions */
    create_extr_table(db);
    process_extracts(db,DATA_PATH,"extract01",1);
    process_extracts(db,DATA_PATH,"extract02",2);
    process_extracts(db,DATA_PATH,"extract03",3);
    process_extracts(db,DATA_PATH,"extract04",4);
    process_extracts(db,DATA_PATH,"extract05",5);
    process_extracts(db,DATA_PATH,"extract06",6);
    process_extracts(db,DATA_PATH,"extract07",7);
    process_extracts(db,DATA_PATH,"extract09",9);
    check_extracts(db);

    /* make_batch(db); */
  
    /* ftp_extracts(db); */


  }
  else {
    db = open_database("pdm");
    if (db == NULL) goto wrapup;
  }
  /* ftp_extracts(db); */
#if 0
  sprintf(buf,"%s/%s",DATA_PATH,"isdp");
  process_pedigrees(db,buf);
  check_pedigrees(db);
#endif

#if 1
  process_extracts(db,DATA_PATH,"extract",10);
  check_extracts(db);
  make_batch(db);
#endif
wrapup:
  if (db) sqlite_close(db);

  return 0;
}

