%{
#define TRUE 1
#define FALSE 0

struct data_st
  {
    char name[80];
    struct data_st *next;
  };

extern struct data_st *top;

int cmp;
int seen_string = FALSE;
struct data_st *temp,**ptr;

%}

%%
\" {
    getstring();
  }


\/\* {
    getcomment();
  }

NFMfunction {
    seen_string = TRUE;
  }

[_A-Za-z][_A-Za-z0-9]* {

    if (seen_string)
      {
        ptr = &top;
        while ((*ptr) != NULL)
          {
            cmp = strcmp(yytext,(*ptr)->name);
            if (cmp == 0)
              {
                fprintf(stderr,
                        "SCcpp: NFMfunction <%s> multiply defined\n",
                        yytext);
                exit(1);
              }
            if (cmp < 0)
              break;
            ptr = &((*ptr)->next);
          }
        temp = (struct data_st *)malloc(sizeof(struct data_st));
        strcpy(temp->name,yytext);
        temp->next = (*ptr);
        (*ptr) = temp;
        seen_string = FALSE;
      }
  }

\n {
  }

. {
  }
%%
getstring()
  {
    char c;

    c = input();
    while ( c != '\"' )
      {
        if (c == '\\')
          {
            c = input();
          }
        c = input();
      }
  }
  

getcomment()
  {
    char c;

    c = input();

    while( TRUE )
      {
        if( c == '*' )
          {
            c = input();

            if( c == 0 )
              return;

            if( c == '/' )
              return;
          }
        else
          {
            switch( c )
              {
                case 0:
                  return;
  
                default:
                  c = input();
              }
          }
      }
  }
