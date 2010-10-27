#include "stdio.h"
#include "stdlib.h"
#include "string.h"

#define OM_K_MAXINTOSNAME_LEN 32

/* -----------------------------------------------
 * Have an open file and the fisrt character
 * has matched so read ahead and see if the rest matches
 */
int findStrInFileX(FILE *file, char *str, int len)
{
  int  retFlag = 0;
  long pos;
  int  c;
  
  // Not good at all
  if (len < 2) goto wrapup;
  str++; len--;
  
  // Save the current position
  pos = ftell(file);

  // Cycle for each character
  while(len) {
    c = fgetc(file);
    if (c != *str) {
      fseek(file,pos,SEEK_SET);
      goto wrapup;
    }
    str++; len--;  
  }
  printf("String matched at %ld\n",pos);
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Given a file name, find all occurences of the
 * string in it
 */
int findStrInFile(char *fileName, char *str, int len)
{
  int retFlag = 0;
  int c;
  
  FILE *file;
  
  // Open
  file = fopen(fileName,"rb");
  if (file == NULL) {
    printf("*** Unable to open %s for reading\n",fileName);
    goto wrapup;
  }
  printf("Scanning %s for %s\n",fileName,str);
  
  // Cycle through
  while ((c = fgetc(file)) != EOF) {
    if (c == *str) {
      findStrInFileX(file,str,len);
      
    }    
  }
  fclose(file);
  
  // Done
  retFlag = 1;
  

 wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * Given a file name, find all occurences of the
 * string in it
 */
int replaceStrInFile(char *fileNameIn, char *fileNameOut, char *str1, char *str2, int len)
{
  int retFlag = 0;
  int c;
  
  FILE *fileIn;
  FILE *fileOut;
  
  // Open
  fileIn = fopen(fileNameIn,"rb");
  if (fileIn == NULL) {
    printf("*** Unable to open %s for reading\n",fileNameIn);
    goto wrapup;
  }
  fileOut = fopen(fileNameOut,"wb");
  if (fileOut == NULL) {
    printf("*** Unable to open %s for writeing\n",fileNameOut);
    goto wrapup;
  }  
  printf("Scanning  %s for  %s\n",fileNameIn, str1);
  printf("Replacing %s with %s\n",fileNameOut,str2);
  
  // Cycle through
  while ((c = fgetc(fileIn)) != EOF) {
    if (c == *str1) {
      if (findStrInFileX(fileIn,str1,len)) {
	fwrite(str2,1,len,fileOut);
      }
      else {
	fputc(c,fileOut);
      }
    }
    else fputc(c,fileOut);
    
  }
  fclose(fileIn);
  fclose(fileOut);
  
  // Done
  retFlag = 1;
  

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Main routine
 */
int main( int   argc,
          char *argv[] )
{
  int i;
  int len = OM_K_MAXINTOSNAME_LEN;
  char fileNameIn [80];
  char fileNameOut[80];
  
  char name1[OM_K_MAXINTOSNAME_LEN];
  char name2[OM_K_MAXINTOSNAME_LEN];

  memset(name1,0,len);
  memset(name2,0,len);

  if (argc < 4) {
    printf("This program replaces the internal os name for downstream tagged connections.\n");
    printf("If, for example, the internal os name of a hull model file is changed then\n");
    printf("run this program on the various downstream files such as the production file\n");
    printf("on order to restore the connections.\n");
    printf("Usage - replaceOS filename \"old name\" \"new name\"\n");
    return 0;
  }
#if 0
  if (argc > 1) strcpy(fileNameIn,argv[1]);
  else          strcpy(fileNameIn,"2143501000.m");
  sprintf(fileNameOut,"%sX",fileNameIn);
  
  if (argc > 2) strcpy(name1,argv[2]);
  else          strcpy(name1,"2143col~110920001201~68FA");

  if (argc > 3) strcpy(name2,argv[3]);
  else          strcpy(name2,"2143193001.m~060620011146~34DF");

  // findStrInFile(fileNameIn,name1,len);
#endif

  strcpy(fileNameIn,argv[1]);
  sprintf(fileNameOut,"%sX",fileNameIn);
  
  strcpy(name1,argv[2]);
  strcpy(name2,argv[3]);

  replaceStrInFile(fileNameIn,fileNameOut,name1,name2,len);
  
  return 0;
}

