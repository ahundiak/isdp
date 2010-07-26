
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* kgrover.c - ????							*/
/*									*/
/* Object PreProcessor - opp						*/
/* Cameron Stubbs							*/
/* September 1986							*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#include <stdio.h>

void generate_array(filea,fileb)
char *filea;
char *fileb;
 {
  FILE *infile;
  char def[20],name[80];
  int num,mt=0;

  printf ("struct harry_item\n");
  printf (" { char *name; int val; } harry[] =\n");
  printf (" {\n");
  infile = fopen (filea,"r");
  while (!feof(infile))
   {
    int i;
    i = fscanf (infile,"%s",def);
    if (i==EOF) break;
    if (!strcmp("define",def))
     {
      fscanf (infile,"%s%d",name,&num);
      printf ("  { \"%s\", %d },\n",name,num);
      mt = num;
     }
   }
  fclose (infile);
  infile = fopen (fileb,"r");
  while (!feof(infile))
   {
    int i;
    i = fscanf (infile,"%s",def);
    if (i == EOF) break;
    if (!strcmp("#define",def))
     {
      fscanf (infile,"%s%d",name,&num);
      printf ("  { \"%s\", %d },\n",name,num);
     }
   }
  fclose (infile);
  printf ("  { 0, 0 }\n");
  printf (" };\n\n");
  printf ("int harry_edge=%d;\n\n",mt);
 }


main(argc,argv)
int argc;
char *argv[];
 {
  generate_array(argv[1],argv[2]);
  return (0);
 }
