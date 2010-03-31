#include <stdio.h>
#define BLANKS14 "              "
#define BLANKS07 "       "
#define BLANKS55 "                                                       "
#define BLANKS80 "                                                                                "

    char name[15];
    char product[8];
    char descript[56];

main(argc,argv)
 int argc;
 char *argv[];
{

  FILE *db;

  char cmd_line[81];
  char prod[15];
  char keyword[25];

  int read_record();
  int check_product();

  if (argc < 2)
   {
     puts("** usage -- selectatp [product] keyword");
     exit(1);
   }
  else
   {
    if (argc == 2)
     {
      strcpy(prod,"any");
      strcpy(keyword,argv[1]);
     }
    else
     {
      strcpy(prod,argv[1]);
      strcpy(keyword,argv[2]);
     }
   }
 
 
  strcpy(cmd_line,BLANKS80);
  strcpy(cmd_line,"grep ");
  strcat(cmd_line,keyword);
  strcat(cmd_line," atpdb > tatpdb");
  system(cmd_line);
  system("echo 'END|' >> tatpdb");

  strcpy(name,BLANKS14);
  strcpy(product,BLANKS07);
  strcpy(descript,BLANKS55);

  printf("   atp name    product description\n");
  printf("-------------- ------- -------------------------------------------------------\n");
  if ((db=fopen("tatpdb", "r")) == 0)
    printf("can't open tatpdb");
  else
   {
    while ((read_record(db)) == 0)
     {
      if ((check_product(prod)) == 0)
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


int check_product(prod)
     char *prod;
   {

     char match_char;
     int i=0;
     int found=1;

     if ((strcmp(prod,"any")) == 0)
      return(0);
     else
      {
       if ((strcmp(prod,"EMS")) == 0)
        match_char='E';
       else
        if ((strcmp(prod,"DRAFT")) == 0)
         match_char='D';
        else
         if ((strcmp(prod,"MDS")) == 0)
          match_char='M';
         else
          match_char='Z';


       while (product[i] != '\0')
        {
          if (match_char == product[i++])
            found=0;
        }
       return(found);
      }
    }
