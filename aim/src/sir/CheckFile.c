/*
 * File CheckFile.c this programe checks the exixtance of the file
 * If the file exists, check if it is a valid I/VDS file. this program is used
 * by the script to run Batch DAD. this program need three arguments and they 
 * are Temp file name, Input File Name and line count. program returns 0 for an  * error and 1 for success. to check this type echo $? after this command.
 * */

#include "VDobj.h"


int AuxFileValid(char *FileName, char *FileType, char *CntxtType,
                 char *CntxtId,  int count, char *file_name)
{
FILE         *fp1=NULL, *fp2=NULL;
char          TmpFileName[250], *token=NULL, in_fname[250];
time_t        ltime;
char          buffer[1024]={0};
char          *cptr =  NULL;
char          *tmptr = NULL; 
 
  strcpy(in_fname, file_name);

  fp1 = fopen(FileName, "r");
  if(fp1 == NULL)
  {

   token = strtok( in_fname, "." );
   sprintf( TmpFileName, "%s", token );
   strcat( TmpFileName, ".err" );
   fp2 = fopen(TmpFileName,"a");
    
   if( fp2 == NULL )
   printf( "Cannot open file %s\n", TmpFileName);
   
   time( &ltime );
   fprintf(fp2, "------------------------------------------------------------------------------\n");
  fprintf(fp2, "At Line Number %d File Name cannot be opened %s\n", count,
          ctime(& ltime));
  
   fclose(fp1);
   fclose(fp2);
   return 0;
  } 
  
  fread(buffer, sizeof(char), 1024, fp1);
  cptr = buffer;
  
  while( (tmptr == NULL) && ( cptr - buffer < 1024 ))
  {
    if(cptr[0]!=0)
    {
      tmptr = strstr(cptr, "I/VDS");
      if(tmptr == NULL)
       cptr += strlen(cptr);
    }
    else cptr ++;	
  }

  if(!tmptr) 
  {

   token = strtok( in_fname, "." );
   sprintf( TmpFileName, "%s", token );
   strcat( TmpFileName, ".err" );
   fp2 = fopen(TmpFileName,"a");
    
   if( fp2 == NULL )
   printf( "Cannot open file %s\n", TmpFileName); 
   
   time( &ltime );
   fprintf(fp2, "------------------------------------------------------------------------------\n");
  fprintf(fp2, "At Line Number %d Input parameters are missing %s\n", count,
          ctime(& ltime));
  
   fclose(fp1);
   fclose(fp2);
   return 0;
   

 }
  
 if(!strcasecmp(FileType,"D"))
 {
   
   if(!strcasecmp(CntxtType, "System") || !strcasecmp(CntxtType, "SubSystem"))
     goto label;
   else
    {
   token = strtok( in_fname, "." );
   sprintf( TmpFileName, "%s", token );
   strcat( TmpFileName, ".err" );
   fp2 = fopen(TmpFileName,"a");
    
   if( fp2 == NULL )
   printf( "Cannot open file %s\n", TmpFileName); 
   
   time( &ltime );
   fprintf(fp2, "------------------------------------------------------------------------------\n");
  fprintf(fp2, "At Line Number %d Input parameters are missing %s\n", count,
          ctime(& ltime));
  
   fclose(fp1);
   fclose(fp2);
   return 0; 
    
    }
   
 }   
  
 if(!strcasecmp(FileType,"A") || !strcasecmp(FileType,"M"))
 {
   
   if(!strcasecmp(CntxtType, "Zone") || !strcasecmp(CntxtType, "Unit") ||
      !strcasecmp(CntxtType, "ZoneSystem"))
     goto label;
   else
    {
    token = strtok( in_fname, "." );
   sprintf( TmpFileName, "%s", token );
   strcat( TmpFileName, ".err" );
   fp2 = fopen(TmpFileName,"a");
    
   if( fp2 == NULL )
   printf( "Cannot open file %s\n", TmpFileName); 
   
   time( &ltime );
   fprintf(fp2, "------------------------------------------------------------------------------\n");
  fprintf(fp2, "At Line Number %d Input parameters are missing %s\n", count,
          ctime(& ltime));
  
   fclose(fp1);
   fclose(fp2);
   return 0;
    }
   
 }  

 if(!strcasecmp(FileType, "D") || !strcasecmp(FileType, "A") ||
    !strcasecmp(FileType, "M"))
  goto label;
 else
 {
  token = strtok( in_fname, "." );
   sprintf( TmpFileName, "%s", token );
   strcat( TmpFileName, ".err" );
   fp2 = fopen(TmpFileName,"a");
    
   if( fp2 == NULL )
   printf( "Cannot open file %s\n", TmpFileName); 
   
   time( &ltime );
   fprintf(fp2, "------------------------------------------------------------------------------\n");
  fprintf(fp2, "At Line Number %d Input parameters are missing %s\n", count,
          ctime(& ltime));
  
   fclose(fp1);
   fclose(fp2);
   return 0;
 }
 
label:
 fclose(fp1);
 fclose(fp2);
 return 1;
}
 

int main( int argc, char *argv[])
{
 FILE               *fp=NULL, *fp1=NULL;
 char               buffer[1024]={0}, *cptr =  NULL, *tmptr = NULL,
                    server_name[40], buffer3[10], TmpFileName[250]; 
		    
 int                char1,char2, i, status, linecount=0;
 char               buffer1[1000], buffer2[1000], *token, *token1, *token2, 
 		    *token3, *token4, *temp, PdmInfo[100];
 char               RefFileName[128], FileType[20], CntxtType[20], CntxtId[20];	       
 time_t             ltime;    
 
 if(argc != 4)
 {
  printf("\nUsage:\nCheckFile <Tmpfilename> <InputFileName> <linecount> \n");  
  return 0;
 }

 if(access( argv[1], F_OK ) != 0 )
 {
  printf("\nFile doesn't exist");  
  return 0; 
 }


 if(argv[2] != NULL)
  linecount = atoi(argv[2]);
 else
  return 0;


 fp = fopen(argv[1],"r");
 if(fp == NULL)
 {
  printf("\nCouldnot open the file %s", argv[1]);  
  return 0; 
 }

 if(argv[3] != NULL)
 strcpy(buffer3, argv[3]);
 else 
  return 0;
 
  RefFileName[0] = '\0';
  FileType[0]    = '\0';
  CntxtId[0]     = '\0';
  CntxtType[0]   = '\0';
    
  temp = NULL;
  token1 = NULL;
  token2 = NULL;
  token3 = NULL;
  token4 = NULL;
  
  
   while( !feof(fp) )
   {
        char2 = fgetc(fp);
 
        for(i=0;(char2 != '\n');i = i + 1)
         {
          buffer2[i] = (char)char2;
	  if(feof(fp))
	   goto label;
          char2 = fgetc(fp);
         }
  
         buffer2[i] = '\0';
    
       if(strlen(buffer2) > 0)
       token1 = strtok(buffer2, ",");
       if(token1 == NULL)
	goto label;
       token2 = strtok(NULL, ",");
       if(token2 == NULL)
	goto label;
       token3 = strtok(NULL, ",");
       if(token3 == NULL)
	goto label;
       token4 = strtok(NULL, ",");
       if(token4 == NULL)
	goto label;
       
     temp = strtok(token1, "=");
     temp = strtok(NULL, "=");
     if(temp == NULL)
       goto label;
     strcpy(RefFileName, temp);

     temp = strtok(token2, "=");
     temp = strtok(NULL, "=");
     if(temp == NULL)
       goto label;
     strcpy(FileType, temp);
 
     temp = strtok(token3, "=");
     temp = strtok(NULL, "=");
     if(temp == NULL)
       goto label;
     strcpy(CntxtType, temp);

     temp = strtok(token4, "=");
     temp = strtok(NULL, "=");
     if(temp == NULL)
       goto label;
     strcpy(CntxtId, temp);
  
     status = AuxFileValid(RefFileName, FileType, CntxtType, 
                         CntxtId, linecount, buffer3);

     if(status)
      goto label_succ;  
     else 
     {
      fclose(fp);
      return 0;
     } 

   }    

   
label_succ:
   fclose(fp);
   return 1;


label:
   token = strtok( buffer3, "." );
   sprintf( TmpFileName, "%s", token );
   strcat( TmpFileName, ".err" );
   time( &ltime );
   fp1 = fopen(TmpFileName,"a");
    
   if( fp1 == NULL )
   printf( "Cannot open file %s\n", TmpFileName);
  
  time( &ltime );
  fprintf(fp1, "------------------------------------------------------------------------------\n");
  fprintf(fp1, "At Line Number %d Input parameters are missing %s\n", linecount,
          ctime(& ltime));
  
  fclose(fp);
  fclose(fp1);
  return  0; 

} 
