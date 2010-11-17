#include "stdlib.h"
#include "string.h"

/* ----------------------------------------------
 * Basically a simple mod 36 encoding scheme
 */
void encode_num(int num, char *buf)
{
  int pass;
  int mod;
  int val;

  char chr;
  char *p;

  /* Handle 0 as special */
  if (num < 1) 
  {
    strcpy(buf,"0");
    return;
  }

  /* Start with 8 blanks */
  strcpy(buf,"        ");

  /* Cycle through */
  pass = 0;
  while(num)
  {
    mod = num / 36;

    pass++;
    val = num - (mod * 36);
    if (val < 10) chr = '0' +  val;
    else          chr = 'A' + (val - 10);
    *(buf + (8 - pass)) = chr;

    num = mod;
  }

  /* Strip leading blanks */
  for(p = buf; *p == ' '; p++);
  strcpy(buf,p);

  return;
}

/* -----------------------------------------------
 * Generate encrypted file name from
 * catalog and item number.
 */
void encode_filename(int cat_no, int item_no, char *filename)
{
  char cat [32];
  char item[32];
  int  len1,len2;

  /* Init */
  strcpy(filename,"________.___");

  /* The parts */
  encode_num(cat_no,cat);
  encode_num(item_no,item);

  /* First part is easy */
  memcpy(filename,cat,strlen(cat));

  /* Just in case we have a really big number, break it up */
  len1 = strlen(item) - 3;
  if (len1 < 0) len1 = 0;  

  len2 = strlen(item);
  if (len2 > 3) len2 = 3;

  if (len1) 
  {
    memcpy(filename + strlen(filename) - 4 - len1,item,len1);
  }
  memcpy(filename + strlen(filename) - len2,item+len1,len2);
  
  return;
}

