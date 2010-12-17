#include "machine.h"
#include <stdio.h>
#include <ctype.h>
#include "SCstruct.h"

#ifdef OS_HPUX
/* HP PORT - IGI - 1 Jul 94 */
#include "NFMcurses.h"
#endif

extern int error_line;
extern char error_msg[132];

char c;
FILE *infile;

int read_function_file(p,filename)
struct SCfunc_st **p;
char *filename;
  {
    *p = NULL;

    if ((infile = fopen(filename,"r")) == NULL)
      {
        sprintf(error_msg,"error opening \"%s\"",filename);
        return(ERROR);
      }

    get_nonwhite_ch();
    
    if (get_group(p) != SUCCESS)
      {
        return(ERROR);
      }
    else if (c != EOF)
      {
        sprintf(error_msg,"entire file not read\n");
        return(ERROR);
      }

    if (*p == NULL)
      {
        (*p) = (struct SCfunc_st *)malloc(sizeof(struct SCfunc_st));
        (*p)->func_string = "Log Out of I/NFM";
        (*p)->func_symb = "LOGOUT";
        (*p)->func_name = "LOGOUT";
        (*p)->parent = NULL;
        (*p)->child = NULL;
        (*p)->prev = NULL;
        (*p)->next = NULL;
      }
    else
      {
        add_exit(*p,0);
      }
    
    return(SUCCESS);
  }

int get_ch()
  {
    c = getc(infile);
    if (c == '\n')
      error_line++;

    return (0);
  }

int get_nonwhite_ch()
  {
    while(1)
      {
        c = getc(infile);
        if (c == '\n')
          error_line++;
        if (!isspace(c) || c == EOF)
          break;
      }
    return (0);
  }

int get_function_name(p)
struct SCfunc_st *p;
  {
    int count = 0;
    char string[80];

    memset(string,0,80);
    if (isalpha(c) || c == '_')
      {
        string[count++] = c;
        get_ch();
        while (isalnum(c) || c == '_')
          {
            string[count++] = c;
            get_ch();
          }
        p->func_name = (char *)malloc(count + 1);
        strcpy(p->func_name,string);
      }
    else
      {
        sprintf(error_msg,
                "Expected <_> or a letter to start function_name() got <%c>",c);
        return(ERROR);
      }

/* make sure c is the next valid character */
    if (isspace(c))
      get_nonwhite_ch();

    return(SUCCESS);
  }

int get_string(p,mode)
struct SCfunc_st *p;
int mode;
  {
    int count = 0;
    char string[80];

    memset(string,0,80);
    while(c != '"')
      {
        if (c == EOF)
          {
            if (mode == STRING)
              strcpy(error_msg,"EOF encountered while reading function string");
            else
              strcpy(error_msg,"EOF encountered while reading function symbol");
            return(ERROR);
          }
        if (c == '\n')
          {
            if (mode == STRING)
              strcpy(error_msg,"EOL encountered while reading function string");
            else
              strcpy(error_msg,"EOL encountered while reading function symbol");
            return(ERROR);
          }
        string[count++] = c;
        get_ch();
      }
    if (mode == STRING)
      {
        p->func_string = (char *)malloc(count + 1);
        strcpy(p->func_string,string);
      }
    else
      {
        p->func_symb = (char *)malloc(count + 1);
        strcpy(p->func_symb,string);
      }

    get_nonwhite_ch();
    return(SUCCESS);
  }

int get_function(p)
struct SCfunc_st **p;
  {
    int sts;
    struct SCfunc_st *ptr;

    if (c == EOF)
      {
        *p = NULL;
        return(SUCCESS);
      }

    if (c != '"')
      {
        *p = NULL;
        sprintf(error_msg,"Expected <\"> to begin function string; got <%c>",c);
        return(ERROR);
      }

    ptr = (struct SCfunc_st *)malloc(sizeof(struct SCfunc_st));
    ptr->func_string = NULL;
    ptr->func_symb = NULL;
    ptr->func_name = NULL;
    ptr->parent = NULL;
    ptr->prev = NULL;
    ptr->next = NULL;
    ptr->child = NULL;
    get_ch();

    if ((sts = get_string(ptr,STRING)) != SUCCESS)
      return(sts);

    if (c != ',')
      {
        *p = NULL;
        sprintf(error_msg,
                "Expected a comma <,> after function string; got <%c>",c);
        return(ERROR);
      }

    get_nonwhite_ch();
    if (c != '"')
      {
        *p = NULL;
        sprintf(error_msg,"Expected <\"> to begin function symbol; got <%c>",c);
        return(ERROR);
      }
    
    get_ch();
    if ((sts = get_string(ptr,SYMB)) != SUCCESS)
      return(sts);

    if (c == ',')
      {
        get_nonwhite_ch();
        if ((sts = get_function_name(ptr)) != SUCCESS)
          return(sts);

        if (c == '{')
          {
            get_nonwhite_ch();
            if ((sts = get_group(&ptr->child)) != SUCCESS)
              return(sts);

            if (c != '}')
              {
                sprintf(error_msg,"Expected <}> to end a group; got <%c>",c);
                return(ERROR);
              }
            get_nonwhite_ch();
          }
      }
    else if (c == '{')
      {
        get_nonwhite_ch();
        if ((sts = get_group(&ptr->child)) != SUCCESS)
          return(sts);

        if (c != '}')
          {
            sprintf(error_msg,"Expected <}> to end a group; got <%c>",c);
            return(ERROR);
          }
        get_nonwhite_ch();
      }
    else
      {
        sprintf(error_msg,"Expected <,> or <{>; got <%c>",c);
        return(ERROR);
      }
    *p = ptr;
    return(SUCCESS);
  }

int get_group(p)
struct SCfunc_st **p;
  {
    int sts;
    struct SCfunc_st *ptr;
    struct SCfunc_st *top;
    struct SCfunc_st *bot;

    ptr = NULL;
    top = NULL;
    bot = NULL;

    while (c != EOF && c != '}')
      {
        if ((sts = get_function(&ptr)) != SUCCESS)
          {
            *p = NULL;
            return(sts);
          }


        ptr->prev = bot;
        bot = ptr;

        ptr->next = NULL;
        if (ptr->prev == NULL)
          top = ptr;
        else
          ptr->prev->next = ptr;
        
        ptr = NULL;
      }
    *p = top;
    return(SUCCESS);
  }

int spaces(level)
  {
    int i;

    for (i=0;i<level * 4;i++)
      printf(" ");

    return (0);
  }

int print_tree(p,level)
struct SCfunc_st *p;int level;
  {
    while (p != NULL)
      {
        spaces(level);
        printf("Function String: <%s> <%s>\n",p->func_string,p->func_symb);
        if (p->func_name != NULL)
          {
            spaces(level);
            printf("Function Name: %s\n",p->func_name);
          }
        else
          {
            spaces(level);
            printf("Function name: NONE\n");
          }
        if (p->child != NULL)
          print_tree(p->child,level + 1);
        p = p->next;
      }
    return (0);
  }

int add_exit(p,level)
struct SCfunc_st *p;
  {
    struct SCfunc_st *ptr;
    while (1)
      {
        if (p->child != NULL)
          add_exit(p->child,level+1);
        if (p->next == NULL)
          break;
        p = p->next;
      }
    ptr = (struct SCfunc_st *)malloc(sizeof(struct SCfunc_st));
    if (level)
      {
      ptr->func_string = "Exit this menu";
      ptr->func_symb = "EXIT";
      ptr->func_name = "EXIT";
      }
    else
      {
      ptr->func_string = "Log Out of I/NFM";
      ptr->func_symb = "LOGOUT";
      ptr->func_name = "LOGOUT";
      }
    ptr->parent = NULL;
    ptr->child = NULL;

    ptr->prev = p;
    ptr->next = NULL;
    p->next = ptr;

    return (0);
  }
