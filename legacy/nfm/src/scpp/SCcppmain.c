#include "machine.h"
#include <stdio.h>

#define TRUE	1
#define FALSE	0

struct data_st
  {
    char name[80];
    struct data_st *next;
  };

extern FILE *yyin;

struct data_st *top = NULL,*temp;

main(argc,argv)
int argc;
char *argv[];
  {
    int i;
    int functions;    /* MVVMK 23 Apr 96 */
    int count;

    for (i=1;i<argc;i++)
      {
        if ((yyin = fopen(argv[i],"r")) == NULL)
          {
            fprintf(stderr,"SCcpp: unable to open %s\n",argv[i]);
            perror("SCcpp");
            exit(1);
          }
        yylex();
        fclose(yyin);
      }

    printf("#include \"SCstruct.h\"\n\n");
    count = 0;
    temp = top;
    while (temp != NULL)
      {
        printf("NFMfunction %s();\n",temp->name);
        temp = temp->next;
        count ++;
      }

    printf("\nint SCatofn_count = %d;\n\n",count);

    count = printf("struct SCatofn_st SCatofn[] = {");
    temp = top;
    while (temp != NULL)
      {
        printf("{\"%s\",%s}",temp->name,temp->name);
        if (temp->next != NULL)
          {
            printf(",\n");
            for (i=0;i<count;i++)
              printf(" ");
          }
        functions   = 1;
        temp = temp->next;
      }
/* MVVMK */
     if (!functions) 
	printf("\"\"");

    printf("};\n");
    exit(0);
  }
