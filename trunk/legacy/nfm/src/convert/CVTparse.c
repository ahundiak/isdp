#include "machine.h"
#include <stdio.h>
#include <string.h>
#include "NFMerrordef.h"

#define TRUE  1
#define FALSE 0

/* This code came from Glenn who got it from DMANDS. I have modified it
   to work for converting our search definitions from I/NFM 2.3 and before
   to I/NFM 3.0. - Karen Tice */

CVTload_definition (where_clause, ret_string)
  char *where_clause;
  char **ret_string;

  {
  long index, i;
  long start;
  long end;
  long clause_len;
  long CONTINUE = TRUE;
  long FIRST_TIC = TRUE;
  char *trio;
  char *dummy_clause;
  char *paren_clause;
  char logical_op[4];

/* get length of where clause and realloc if necessary */
  clause_len=strlen(where_clause);
  *ret_string = (char *) malloc(clause_len+100);  
  dummy_clause = (char *) malloc(clause_len+1);  
  trio = (char *) malloc (clause_len+1);
  paren_clause = (char *) malloc (clause_len+1);
  index=0;
  strcpy (*ret_string, "");

  /* find beginning of cluase */
  while (index<clause_len)
      {
      /* increment index to start of trio */
      while ((where_clause[index]=='(') || (where_clause[index]==' '))
          {
          if (where_clause[index] == '(')
              strcat (*ret_string, "(");
/*
          else
              strcat (*ret_string, " ");
*/
          index++;
          }
      start=index;

      /* increment index to end of trio */
      strcpy (paren_clause, "");
      CONTINUE = TRUE;
      FIRST_TIC = TRUE;
      while ((CONTINUE) && (index<clause_len))
          {
          switch (where_clause[index])
              {
              case ')':
                  CONTINUE = FALSE;
                  strcat (paren_clause, ")");
                  break;
              case ' ':
                  i = index + 1;
                  switch (where_clause[i])
                      {
                      case 'a':
                      case 'A':
                      case 'o':
                      case 'O':
                          CONTINUE = FALSE;
                          break;
                      case ')':
                          CONTINUE = FALSE;
                          strcat (paren_clause, ")");
                          index++;
                          break;
                      default:
                          index++;
                          break;
                      }
                  break;
              case '\'':
                  if (FIRST_TIC)
                      {
                      FIRST_TIC = FALSE;
                      index++;
                      }
                  else
                      {
                      i = index + 1;
                      switch (where_clause[i])
                          {
                          case 'a':
                          case 'A':
                          case 'o':
                          case 'O':
                              CONTINUE = FALSE;
                              break;
                          case ')':
                              CONTINUE = FALSE;
                              strcat (paren_clause, ")");
                              index++;
                              break;
                          default:
                              index++;
                              break;
                          }
                      }
                  break;
              default:
                  index++;
                  break;
              }
          }

      end=index;    

      /* separate trio from where clause */
      strcpy(dummy_clause,&where_clause[start]);
      dummy_clause[end-start]=0;
      strcpy(trio,dummy_clause);

/*      printf ("\ntrio = <%s>\n", trio); */

      CVTparse_trio(trio, ret_string);

      /* increment index to end of clause, or next trio, looking for operator */
      index++;

      while ((index<clause_len)&&
             ((where_clause[index]==')') || (where_clause[index]==' ') ))
          {
          if (where_clause[index] == ')')
              strcat (paren_clause, ")");
/*
          else
              strcat (paren_clause, " ");
*/
          index++;
          }

      strcat (*ret_string, paren_clause);

      if (index<clause_len)
          {
          while (where_clause[index]==' ') index++;
          start = index;

          CONTINUE = TRUE;
          while ((CONTINUE) && (index<clause_len))
              {
              switch (where_clause[index])
                  {
                  case 'a':
                  case 'A':
                      i = index + 3;
                      switch (where_clause[i])
                          {
                          case '(':
                              CONTINUE = FALSE;
                              index = index + 3;
                              break;
                          case ' ':
                              CONTINUE = FALSE;
                              index = index + 3;
                              break;
                          default:
                              index++;
                              break;
                          }
                      break;
                  case 'o':
                  case 'O':
                      i = index + 2;
                      switch (where_clause[i])
                          {
                          case '(':
                              CONTINUE = FALSE;
                              index = index + 2;
                              break;
                          case ' ':
                              CONTINUE = FALSE;
                              index = index + 2;
                              break;
                          default:
                              index++;
                              break;
                          }
                      break;
                  default:
                      index++;
                      break;
                  }
          }

          end = index;

          strcpy(dummy_clause,&where_clause[start]);
          dummy_clause[end-start]=0;
          strcpy(logical_op,dummy_clause);
/*          printf ("logical = <%s>\n", logical_op); */

          /* increment index beyond next '(' */
/*          index++; */

          strcat (*ret_string, " ");
          strcat (*ret_string, logical_op);
          strcat (*ret_string, " ");
          }

      }

  free(dummy_clause);
  free(paren_clause);
  free(trio);

  return (NFM_S_SUCCESS);
  }


CVTparse_trio(trio, ret_string)
  char *trio;
  char **ret_string;

  {
  char cat_alias[20];
  char attribute[20];
  char operator[10];
  char value[80];
  long index,index1,length;
  long CONTINUE_FLAG;
  long TIC_FLAG;
  char *dummy_trio;

  length = strlen(trio);
  dummy_trio = (char *) malloc(length+1);
  strcpy(dummy_trio,trio);
  index=0;
  index1=0;

  while ((index<length)&&(trio[index]!='.'))
      {
      index++;
      index1++;
      }

  /* In I/NFM 2.3 or before, search definitions may or may not have catalog
     aliases. If it does, replace it with "a."; if not, add "a.". */

  if (index >= length)  /* no catalog alias */
      {
/*      printf ("no catalog alias\n"); */
      strcpy(dummy_trio,trio);
      index = 0;  /* reset index */
      }
  else  /* catalog alias */
      {
      dummy_trio[index1]=0;
      strcpy(cat_alias,dummy_trio);
/*      printf ("cat_alias = <%s>\n",cat_alias); */
      strcpy(dummy_trio,&trio[index+1]);
      index++;  /* move past '.' */
      }

  index1=0;

  /* find attribute name */
  CONTINUE_FLAG = TRUE;
  while ((index<length) && (CONTINUE_FLAG)) 
      {
      switch (trio[index])
          {
          case ' ':   /* blank space */
          case '=':   /* equal */
          case '!':   /* not equal */
          case '<':   /* less than */
          case '>':   /* greater than */
              CONTINUE_FLAG = FALSE;
              break;
          default:
              index++;
              index1++;
              break;
          }
      }
  dummy_trio[index1]=0;
  strcpy(attribute,dummy_trio);
/*  printf ("attribute = <%s>\n",attribute); */

  /* parse past blank spaces */
  while ((index<length)&&(trio[index]==' ')) index++;
  index1=0;
  strcpy(dummy_trio,&trio[index]);

  /* find operator */
  CONTINUE_FLAG = TRUE;
  while ((index<length) && (CONTINUE_FLAG)) 
      {
      switch (trio[index])
          {
          case ' ':   /* blank space */
          case '\'':  /* tic */
          case '0':
          case '1':
          case '2':
          case '3':
          case '4':
          case '5':
          case '6':
          case '7':
          case '8':
          case '9':
              CONTINUE_FLAG = FALSE;
              break;
          default:
              index++;
              index1++;
              break;
          }
      }
  dummy_trio[index1]=0;
  strcpy(operator,dummy_trio);
/*  printf ("operator = <%s>\n",operator); */

/* We need 'like'
  if (strcmp(operator,"like")==0) strcpy(operator,"=");
*/

  while ((index<length)&&(trio[index]==' ')) index++;

  TIC_FLAG = FALSE;
  if ((trio[index]=='\'') || (trio[index]=='\"'))
      {
      /* note that value is enclosed by tics */
      TIC_FLAG = TRUE;
      index++;
      }

  index1=0;
  strcpy(dummy_trio,&trio[index]);

  if (TIC_FLAG)
      {
      while ((index<length)&&(trio[index]!='\'')&&(trio[index]!='\"'))
          {
          index++;
          index1++;
          }
      }
  else
      {
      while ((index<length)&&(trio[index]!=' '))
          {
          index++;
          index1++;
          }
      }
  if ((dummy_trio[index1-1]=='\'') || (dummy_trio[index1-1]=='\"')) index1--;
  dummy_trio[index1]=0;
  strcpy(value,dummy_trio);

/* I don't see a need for this. In fact, we NEED '%'!
  for (index=0;index<strlen(value);index++)
      {
      if (value[index]=='%')
          value[index]='*';
      }
*/
/*  printf ("value = <%s>\n",value); */

  strcat (*ret_string, "a.");
  strcat (*ret_string, attribute);
  strcat (*ret_string, " ");
  strcat (*ret_string, operator);
  strcat (*ret_string, " ");
  if (TIC_FLAG)
      strcat (*ret_string, "'");
  strcat (*ret_string, value);
  if (TIC_FLAG)
      strcat (*ret_string, "'");

  free(dummy_trio);
}

CVTload_definition2 (order_clause, ret_string)
  char *order_clause;
  char **ret_string;

  {
  long index;
  long start;
  long end;
  long clause_len;
  long CONTINUE = TRUE;
  long COMMA = FALSE;
  char *attr;
  char *dummy_clause;

/* get length of order clause and realloc if necessary */
  clause_len=strlen(order_clause);
  *ret_string = (char *) malloc(clause_len+100);  
  dummy_clause = (char *) malloc(clause_len+1);  
  attr = (char *) malloc (clause_len+1);
  index=0;
  strcpy (*ret_string, "");

  /* find beginning of cluase */
  while (index<clause_len)
      {
      /* increment index to start of attribute */
      while (order_clause[index]==' ')
          index++;
      start=index;

      /* increment index to end of attr */
      CONTINUE = TRUE;
      COMMA = FALSE;
      while ((CONTINUE) && (index<clause_len))
          {
          switch (order_clause[index])
              {
              case ',':
                  CONTINUE = FALSE;
                  COMMA = TRUE;
                  break;
              default:
                  index++;
                  break;
              }
          }

      end=index;    

      /* separate attr from order clause */
      strcpy(dummy_clause,&order_clause[start]);
      dummy_clause[end-start]=0;
      strcpy(attr,dummy_clause);

/*      printf ("\nattr = <%s>\n", attr); */

      CVTparse_attr(attr, ret_string);

      /* increment index to end of clause, or next attr */
      index++;

      while ((index<clause_len)&&
             (order_clause[index]==' ') )
          index++;

      if (COMMA)
          strcat (*ret_string, ",");
      }

  free(dummy_clause);
  free(attr);

/*  printf ("ret_string = <%s>\n", *ret_string); */

  return (NFM_S_SUCCESS);
  }


CVTparse_attr(attr, ret_string)
  char *attr;
  char **ret_string;

  {
  char cat_alias[20];
  char attribute[20];
  long index,index1,length;
  long CONTINUE_FLAG = TRUE;
  char *dummy_attr;

  length = strlen(attr);
  dummy_attr = (char *) malloc(length+1);
  strcpy(dummy_attr,attr);
  index=0;
  index1=0;

  while ((index<length)&&(attr[index]!='.'))
      {
      index++;
      index1++;
      }

  /* In I/NFM 2.3 or before, sort definitions may or may not have catalog
     aliases. If it does, replace it with "a."; if not, add "a.". */

  if (index >= length)  /* no catalog alias */
      {
/*      printf ("no catalog alias\n"); */
      strcpy(dummy_attr,attr);
      index = 0;  /* reset index */
      }
  else  /* catalog alias */
      {
      dummy_attr[index1]=0;
      strcpy(cat_alias,dummy_attr);
/*      printf ("cat_alias = <%s>\n",cat_alias); */
      strcpy(dummy_attr,&attr[index+1]);
      index++;  /* move past '.' */
      }

  index1=0;

  /* find attribute name */
  CONTINUE_FLAG = TRUE;
  while ((index<length) && (CONTINUE_FLAG)) 
      {
      switch (attr[index])
          {
          case ' ':   /* blank space */
              CONTINUE_FLAG = FALSE;
              break;
          default:
              index++;
              index1++;
              break;
          }
      }
  dummy_attr[index1]=0;
  strcpy(attribute,dummy_attr);
/*  printf ("attribute = <%s>\n",attribute); */

  strcat (*ret_string, "a.");
  strcat (*ret_string, attribute);

  free(dummy_attr);
}

