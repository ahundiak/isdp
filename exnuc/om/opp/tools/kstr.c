
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* kstr.c - ???								*/
/*									*/
/* Object PreProcessor - opp						*/
/* Cameron Stubbs							*/
/* September 1986							*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#include <stdio.h>
#include <malloc.h>

#define isterminal(c) (c==' ')||(c=='\t')||(c=='(')||(c==',')||(c==')')||(c=='\n')||(c=='=')
#define gobble do c=getchar(); while (isterminal(c)); if (c!=EOF) ungetc (c,stdin)


char *sting_array[1000];
int sai=0;


void bugger ()
 {
  int i,j;
  char *t;
  for (i=0; i<sai-1; i++)
   {
    for (j=i+1; j<sai; j++)
     {
      if (strcmp(sting_array[i],sting_array[j])>0)
       {
        t = sting_array[i];
        sting_array[i] = sting_array[j];
        sting_array[j] = t;
       }
     }
   }
 }


search (t)
char *t;
 {
  int i;
  for (i=0; i<sai; i++) if (!strcmp(sting_array[i],t)) return (i);
  return (sai);
 }


void insert(t)
char *t;
 {
  int i;

  i = search (t);
  if (i==sai)
   {
    sting_array[i] = (char *)malloc((strlen(t)+8)&0xfffffff8);
    strcpy (sting_array[i],t);
    sai++;
   }
 }


main()
 {
  char blurb[80];
  int c;
  int i;
 
  while (1)
   {
    scanf ("%[^= \t(,)\n]",blurb);
    gobble;
    if (c==EOF) break;
    if (!strcmp(blurb,"new_pnode"))
     {
      scanf ("%[^ \t(,)\n]",blurb);
      insert (blurb);
     }
   }
  bugger();
  for (i=0; i<sai; i++)
   printf ("#define %s %d\n",sting_array[i],i+0x10000);
  printf ("\n\n\n");
  printf ("struct pnode\n");
  printf (" {\n");
  printf ("  int typ;\n");
/*  printf ("  struct pnode *flink;\n"); */
  printf ("  struct pnode *l[1];\n");
  printf (" };\n");
  return(0);
 }
