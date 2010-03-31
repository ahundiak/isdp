#include <stdio.h>
#define BLANKS14 "              "
#define BLANKS07 "       "
#define BLANKS55 "                                                       "

    char name[15];
    char product[8];
    char descript[56];

main()
{

  FILE *db;


  int read_record();

  strcpy(name,BLANKS14);
  strcpy(product,BLANKS07);
  strcpy(descript,BLANKS55);

  printf("   atp name    product description\n");
  printf("-------------- ------- -------------------------------------------------------\n");
  if ((db=fopen("atpdb", "r")) == 0)
    printf("can't open atpdb");
  else
   {
    while ((read_record(db)) == 0)
     {
      printf("%s %s %s\n",name,product,descript); 
      strcpy(name,BLANKS14);
      strcpy(product,BLANKS07);
      strcpy(descript,BLANKS55);
     }
    fclose(db);
   }
}

int read_record(db)
     FILE *db;
     {

       char row[80];
  
       int i=0, j=0;
    
       fgets(row,80,db);

       while (row[i] != '|')
        {
         name[j++]=row[i++];
        }
         name[14]='\0';

       if ((strcmp(name,"END           ")) != 0)
        {
         i++;
         j=0;

         while (row[i] != '|')
          product[j++]=row[i++];

         product[7]='\0';
         i++;
         j=0;

         while (row[i] != '|')
          descript[j++]=row[i++];

         descript[55]='\0';

         return(0);
        }
       else
        return(1);
     }

