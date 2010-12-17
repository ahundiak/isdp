/************************************************************************* 
 *									 * 
 *                     Shared memory layout is as follows.               * 
 *  									 * 
 *									 * 
 *                Table      Net       Term-   Proc ID   Thread		 * 
 *                Header*  Address     inator            Count 		 *   
 *               -------------------------------------------------	 * 
 *               |2 bytes| 29 bytes | 1 byte | 4 bytes | 2 bytes |	 * 
 *                -------|----------|--------|---------|---------|	 * 
 *                slot 2 |    :     |   :    |   :     |   :     |	 * 
 *                       |----------|--------|---------|---------|	 * 
 *                slot 3 |    :     |   :    |   :     |   :     |	 * 
 *                       |----------|--------|---------|---------|	 * 
 *                slot 4 |    :     |   :    |   :     |   :     |	 * 
 *                       |----------|--------|---------|---------|	 * 
 *                   :   |    :     |   :    |   :     |   :     |	 * 
 *                       |----------|--------|---------|---------|	 * 
 *                slot n |    :     |   :    |   :     |   :     |	 * 
 *                       !----------+--------+---------+---------!	 * 
 *									 * 
 *                            * Number of slots in table.                * 
 *									 * 
 *                          Produced, Written and Directed		 *  
 *                                       by 				 * 
 *                          Adell 'They want EFX' Warren                 * 
 *                                   arw 10-1-94    			 *
 * Revision History:
 *   Ashley - fix for TR 439503225 5/29/96  
 *   Ashley - related to TR 439503225 6/19/96 - buttons were not holding
 *            focus when window was deactivated
 *************************************************************************/ 
  
 
#if defined(unix) 

/*
**  INCLUDES
*/
#include <fcntl.h> 
#include "risver.h" 
#include "risutl.h" 
#include "utl_inf.h" 

/*
**  FUNCTION PROTOTYPES
*/
#include "comumsg.prt"
#include "sys.prt"  
#include "net_sys.prt" 
#include "net_wrap.prt" 
#include "ucoumsg.prt"
 

#define MEM_LEN  (((lic_users ) * 36) + 2)  
#define BADADDR (char *)(-1) 
 
static int dbase_entries = 8; 
static int flag = 0; 
 
/* Database order is INFORMIX SYBASE ORACLE INGRES DB2 RDB OS400 MSSQL*/ 
 
static char dbase_type[8][20] = {"Informix","Sybase","Oracle","Ingres","DB2","RDB","OS400","MSSQL"}; 
static char arg_string[8][20] = {"-informix","-sybase","-oracle","-ingres","-db2","-rdb","-os400","-mssql"}; 

static int  shmemkeys[8]      = {8375352,8375353,8375354,8375355,8375356,8375357,8375358,8375359}; 
 
 
 
static int segid      =  0; 
 
static short lic_users=0; 
static char *addr; 
 

char * attach_memory(int keyvalue) 
{ 
   short scratch;

   if ((segid=shmget(keyvalue,MEM_LEN,0666|IPC_CREAT)) == -1) 
      {    
          return(BADADDR); 
      } 
 
    if ((addr=(char *)shmat(segid,0,0)) == BADADDR) 
      { 
          return(BADADDR); 
      } 
    
    memcpy(&scratch,addr,2);

    if (scratch != 255)
      {
       shmctl(segid,IPC_RMID,(struct shmid_ds *) 0 );
       return(BADADDR);
      }
    else
      return(addr); 
} 
 
 
void bclear(char *ptr2,int len) 
{ 
   char *tmp_holder; 
 
   tmp_holder = ptr2; 
 
   while(tmp_holder - ptr2 < len) 
      *tmp_holder++ = ' '; 
} 
 
 
static int highwater() 
{ 
      FILE *input_file,*fopen(); 
       
      int i; 
 
      struct { 
               int incept_date; 
               int highwater; 
               int current_time; 
           }   header_record; 
 
      char data[40]; 
 
 
      if (getuid() != 0) 
        { 
           printf("Must be super-user to execute! \n"); 
           return(-1); 
        } 
 
      if ((input_file = fopen("/etc/.registry.a","r")) == (FILE *) 0) 
        {  
             printf("RIS Server has not been invoked yet\n"); 
             return(-1) ; 
        } 
 
      fread((char *)&header_record,sizeof (char), 12, input_file); 
       
      if (header_record.highwater) 
       { 
            printf("\n\n\t\t         RIS Server Usage  \n"); 
            printf("  \t\tPeak Users as of %s",ctime((long *) &header_record.current_time)); 
            printf("  \t\t------------------------------------------\n\n"); 
             
            for (i=0; i < header_record.highwater; i++) 
                 if (fread(data,sizeof (char),  30 , input_file))         
                     printf("   \t\t %d \t%s\n",(i+1),data);           
        } 
       else 
            printf("\n\n\tNo RIS Server users since %s\n",ctime((long *) &header_record.current_time)); 
         
 
       fclose(input_file); 
   
       return(0); 
} 
 
static int clear_highwater() 
{ 
      FILE *input_file,*fopen(); 
 
      int data_file; 
 
      struct { 
               int incept_date; 
               int highwater; 
               int current_time; 
           }   header_record; 
 
      if (getuid() != 0) 
        { 
           printf("Must be super-user to execute! \n"); 
           return(-1); 
        } 
 
      if ((input_file = fopen("/etc/.registry.a","r")) == (FILE *) 0) 
         return(-1) ; 
 
      fread((char *)&header_record,sizeof (char), 12, input_file); 
       
      fclose(input_file); 
 
      header_record.highwater = 0; 
 
      time((long *) &header_record.current_time); 
 
      /* We want to ensure file protection, so we use open instead of fopen */ 
 
      if ((data_file = open("/etc/.registry.a",O_WRONLY | O_CREAT | O_TRUNC,0666)) == -1) 
              { 
                printf("Could not clear contents, please run as super-user or invoke data server\n"); 
                return(-1); 
              } 
 
      write(data_file,(char *) &header_record,12); 
       
      close(data_file); 
 
      return(0); 
} 
 
 
main(int argc,char **argv) 
{ 
	int i = 0, 
		j = 0, 
		k = 0, 
		proc_id, 
		hit = 0, 
	    hit_flag = 0, 
		process_peak = 0, 
		process_clear_peak = 0, 
		loop_counter = 0; 
 
	short thread_count, 
		  slot_count; 
 
	char data[30], 
		 output_line[80], 
		  *ptr, 
		  *ptr1; 
 
	/*
	** modified messages file; fixed TR# 439600485
	*/
	RISuco_initialize_ums(INIT_UTL_UMS_FILE);

	if (argc == 2)
	{
		if (strcmp(argv[1], "-V") == 0)
		{
			/*PRINTF(MSG(RISUTL_I_COPYRIGHT));*/
			/* 1996.03.12:Alan Barksdale:TR439600483 */
			PRINTF(MSG(RISUTL_I_BEGIN_COPYRIGHT));
			PRINTF(" ");
			PRINTF(COPYRIGHTYEAR);
			PRINTF(", ");
			PRINTF(MSG(RISUTL_I_END_COPYRIGHT));
			PRINTF(MSG(RISUTL_I_LICLIST_UTILITY), RIS_version);
			return(0);
		}
		if (strcmp(argv[1], "-?") == 0)
		{
			PRINTF(MSG(RISUTL_I_LICLIST_USAGE_1));
			PRINTF(MSG(RISUTL_I_LICLIST_USAGE_2));
			PRINTF(MSG(RISUTL_I_LICLIST_USAGE_3));
			PRINTF(MSG(RISUTL_I_LICLIST_USAGE_4));
			PRINTF(MSG(RISUTL_I_LICLIST_USAGE_5));
			PRINTF(MSG(RISUTL_I_LICLIST_USAGE_6));
			return(0);
		}
	}

	if (argc > 1)
	{
		for ( k = 1; k < argc; k++)
		{
			for ( i = 0; i < dbase_entries; i++)
			{
				if (strncmp(argv[1],arg_string[i],4) == 0)
				{
					hit = i;
					hit_flag = 1;
				}

				if ((strncmp(argv[k],"-pea",4)) == 0)
					process_peak = 1;

				if ((strncmp(argv[k],"-cle",4)) == 0)
					process_clear_peak = 1;
			}
		}

		if (((process_peak + process_clear_peak) == 0) &&
			(hit_flag == 0))
		{
			printf("Database not supported at this time\n");
			exit(-1);
		}
	}

	if (process_peak) 
	{ 
		highwater(); 
		return(0); 
	} 

	if (process_clear_peak) 
	{ 
		clear_highwater(); 
		return(0); 
	} 

	if (argc > 1) 
		loop_counter = hit + 1; 
	else 
		loop_counter = dbase_entries; 

	for (j = hit; j < loop_counter; j++) 
	{
		lic_users = 255; 
		  
		if ((ptr = attach_memory(shmemkeys[j])) == BADADDR) 
		continue; 

		flag++; 

		memcpy((char *)&slot_count,ptr,2); /* Get license count user authority */ 
		ptr += 2; 

		printf("\n                          RIS Server   Usage List\n"); 
		printf("                               %s Server\n",dbase_type[j]); 
		printf("                              [%d] Monitor Limit\n\n",slot_count); 
		printf("Server Number\t        Net Address\t\t  # Process ID  \n"); 
		printf("-------------\t        -----------\t\t  ------------\n"); 


		for (i=0; i < slot_count ; i++)
		{
			if (*ptr) 
			{ 
				strncpy(data,ptr,29); 
				ptr += 30; 
				memcpy((char *) &proc_id,ptr,4); 
				ptr += 4; 
				memcpy((char *) &thread_count,ptr,2);          
				ptr += 2; 

				bclear(output_line,80);              /* Format Output Line */ 
				ptr1 = &output_line[8]; 
				strcpy(ptr1,data); 

				ptr1 = &output_line[38]; 
				sprintf(ptr1,"%d\n",proc_id);                 

				ptr1 = output_line;                    /* Strip Nulls */ 

				while(*ptr1++ != '\n') 
					if (*ptr1 == '\0') 
						*ptr1 = ' '; 

				output_line[79] = '\0'; 

				if (i < 10)
				{
					if ( strchr(output_line,'.') != (char *) NULL)
						printf("  %i \t\t%s",i + 1,output_line);
				}
				else
				{
					printf("  %i \t\t%s",i + 1,output_line);  
				}
			}     
			else
			{
				if (i < slot_count)
				{
					if (i < 10)
					{
						printf("  %i\n",i + 1);
					}
				}
				ptr += 36; 
			} 
		}

		shmdt(addr);            /* free shared memory and semaphore */
		printf("\n\n"); 
	}

	if (flag == 0)
	{ 
		printf("No Licensed RIS server is presently executing on this node\n"); 
	} 
	return(0);
} 
#endif /* unix */ 
 
#if defined(WIN32)
 
/*
**  INCLUDES
*/
#include <windows.h> 
#include <stdlib.h> 
#include <malloc.h> 
#include <string.h> 
#include <stdio.h>       /* to pull in sprintf */
#include <ctl3d.h> 
#include <wchar.h> 
#include <time.h> 
 
#include "rliclist.h"
#include "risver.h"
#include "risutl.h" 
#include "utl_inf.h" 

/*
**  FUNCTION PROTOTYPES
*/
#include "comumsg.prt"
#include "comparcl.prt"
#include "ucoumsg.prt"
 
/* #define MEM_LEN  (LONG) (((lic_users + 256) * 36) + 2) put back when license enforcement back in effect */ 
 
#define MEM_LEN  (LONG) (((lic_users ) * 36) + 2)                                    
#define BADADDR NULL 
 
LONG APIENTRY MainWndProc (HWND, UINT, UINT, LONG); 
LONG APIENTRY FileDlgProc (HWND, UINT, UINT, LONG); 
LONG APIENTRY StatusDlgProc (HWND, UINT, UINT, LONG); 
LONG APIENTRY PeakDlgProc (HWND, UINT, UINT, LONG); 
 
HANDLE hInst; 
HWND   hWnd, hWndDlg, hWndFileDlg; 
DWORD  StepTime; 
 
static HANDLE memory_buffer = NULL; 

static HWND  hWnd_default;

/* Database order is INFORMIX SYBASE ORACLE INGRES DB2 RDB OS400 MSSQL*/ 
 
static char dbase_type[8][20]={"Informix","Sybase","Oracle","Ingres","DB2","RDB","OS400","MSSQL"}; 
static char semaphores [8][20]={"7679311","7679312","7679313","7679314","7679315","7679316","7679317","7679318"}; 
static char shmemkeys  [8][20]={"8375352","8375353","8375354","8375355","8375356","8375357","8375358","8375359"}; 
 
static short lic_users = 0; 
 
static int dbase_entries = 8; 
            
static char active_dbase[20]={"\0"}; 
 
static char  szFilterSpec [128] =						 /* file type filters */
             TEXT("Text Files (*.TXT)\0*.TXT\0All Files (*.*)\0*.*\0"); 
 
static HWND focus_button;

void peak_write_text_file(HWND hDlg,TCHAR *filename) 
{ 
   struct _stat file_status; 
   HANDLE hFilename_out,hFilename_in; 
   TCHAR outfile[256]; 
   char peak_data[40],format_output[256], format_string[80]; 
   int i,byte_count; 
   long _stat(); 
    
   struct {              
                int incept_date; 
                int highwater; 
                int current_time; 
             }  header_record; 
 
              
   if (_stat(filename,&file_status) == 0) 
     { 
        if ((MessageBox(hDlg,"File exist, Do you want to append?", 
                            "Save Peak Usage",MB_ICONQUESTION | MB_YESNO)) == IDYES) 
           { 
                if ((hFilename_out = CreateFile(filename, 
                                 GENERIC_READ | GENERIC_WRITE, 
                                 0, 
                                 NULL, 
                                 OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL)) == INVALID_HANDLE_VALUE ) 
                   { 
                       MessageBox(hDlg,"Can not append to file", 
                                       "Save Peak Usage", 
                                        MB_ICONEXCLAMATION); 
 
                       return ; 
                   } 
                else 
                   { 
                       SetFilePointer(hFilename_out,0,NULL,FILE_END); 
                       WriteFile(hFilename_out,"\r\n\r\n",2,&byte_count,NULL); 
                   } 
           } 
       else 
          return ; 
     } 
   else 
     { 
                if ((hFilename_out = CreateFile(filename, 
                                 GENERIC_READ | GENERIC_WRITE, 
                                 0, 
                                 NULL, 
                                 CREATE_NEW,FILE_ATTRIBUTE_NORMAL,NULL)) == INVALID_HANDLE_VALUE ) 
                   { 
                       MessageBox(hDlg,"Can not write to file", 
                                       "Save Peak Usage", 
                                        MB_ICONEXCLAMATION); 
 
                       return ; 
                   } 
     } 
 
     if (GetWindowsDirectory(outfile,256)) 
         lstrcat(outfile,"\\system32\\reg{p}.dll"); 
 
     if ((hFilename_in = CreateFile(outfile, 
                                 GENERIC_READ | GENERIC_WRITE, 
                                 0, 
                                 NULL, 
                                 OPEN_EXISTING,FILE_ATTRIBUTE_HIDDEN,NULL)) == INVALID_HANDLE_VALUE ) 
         return; 
 
      ReadFile(hFilename_in,&header_record,12,&byte_count,NULL); 
 
      if (header_record.highwater) 
      { 
         strcpy(format_string,(char *) ctime(&header_record.current_time)); 
          
         format_string[strlen(format_string) - 1] = 0x0;                          /* get rid of newline */
 
         sprintf(format_output,"\t\tPeak Ris Data Server Usage\r\n\t\t          as of  \r\n\t\t%s\r\n", 
                              format_string); 
 
         WriteFile(hFilename_out,format_output,strlen(format_output), 
                          &byte_count,NULL); 
 
         strcpy(format_output,"-----------------------------------------------\r\n\r\n"); 
         WriteFile(hFilename_out,format_output,strlen(format_output), 
                          &byte_count,NULL); 
                           
         for (i=0; i < header_record.highwater; i++) 
            {  
               ReadFile(hFilename_in,peak_data,30, &byte_count,NULL); 
               sprintf(format_output,"    %d   \t   %s\r\n",i + 1, peak_data); 
               
               WriteFile(hFilename_out,format_output,strlen(format_output),&byte_count,NULL); 
            } 
      } 
      else 
          MessageBox(hDlg,"No Peak Usage Data","Peak Usage",MB_ICONEXCLAMATION); 
         
      CloseHandle(hFilename_in); 
      CloseHandle(hFilename_out);  
} 
 
void Clear_file (HWND hDlg) 
{ 
    TCHAR  registry_file[256]; 
     
    struct {              
                int incept_date; 
                int highwater; 
                int current_time; 
             }  header_record; 
 
    LONG    byte_count; 
    HANDLE  hFilename; 
          
    if ((MessageBox(hDlg,"Clear RIS License Server Log File?", 
                            "Clear Log File",MB_ICONQUESTION | MB_YESNO)) == IDYES) 
    { 
        if (GetWindowsDirectory(registry_file,256)) 
           strcat(registry_file,"\\system32\\reg{p}.dll"); 
            
        if ((hFilename = CreateFile(registry_file, 
                            GENERIC_READ | GENERIC_WRITE, 
                            FILE_SHARE_READ | FILE_SHARE_WRITE, 
                            NULL, 
                            OPEN_EXISTING,FILE_ATTRIBUTE_HIDDEN,NULL)) == INVALID_HANDLE_VALUE ) 
                { 
                                           MessageBox(hDlg,"Peak Usage Control Data not available", 
                                                           "Peak Usage",MB_ICONEXCLAMATION);     /* should never get here  */
                                           return ; 
                } 
       ReadFile(hFilename,&header_record,12,&byte_count,NULL); 
 
       CloseHandle(hFilename); 
        
       if ((hFilename = CreateFile(registry_file, 
                            GENERIC_READ | GENERIC_WRITE, 
                            FILE_SHARE_READ | FILE_SHARE_WRITE, 
                            NULL, 
                            TRUNCATE_EXISTING,FILE_ATTRIBUTE_HIDDEN,NULL)) == INVALID_HANDLE_VALUE ) 
                { 
                                           MessageBox(hDlg,"Peak Usage Control Data not available", 
                                                           "Peak Usage",MB_ICONEXCLAMATION);     /* should never get here */
                                           return ; 
                } 
 
        header_record.highwater = 0; 
        time(&header_record.current_time); 
         
        WriteFile(hFilename,&header_record,12,&byte_count,NULL); 
        CloseHandle(hFilename); 
    } 
 
    return ; 
} 
   
void File_Open(HWND hwndOwner) 
{ 
    OPENFILENAME ofn; 
     
 
    TCHAR    szFile[256]      = "\0"; 
                
 
    lstrcpy(szFile,""); 
 
     
     
    ofn.lStructSize         = sizeof(OPENFILENAME); 
    ofn.hwndOwner           = hwndOwner; 
    ofn.lpstrFilter         = szFilterSpec; 
    ofn.lpstrCustomFilter   = NULL; 
    ofn.nMaxCustFilter      = 0; 
    ofn.nFilterIndex        = 1; 
    ofn.lpstrFile           = szFile; 
    ofn.nMaxFile            = 120; 
    ofn.lpstrInitialDir     = NULL; 
    ofn.lpstrFileTitle      = NULL; 
    ofn.nMaxFileTitle       = 120; 
    ofn.lpstrTitle          = TEXT("Save File as"); 
    ofn.lpstrDefExt         = TEXT("*.txt"); 
    ofn.Flags               = OFN_HIDEREADONLY; 
    ofn.lpfnHook            = NULL; 
    ofn.lCustData           = 0; 
    ofn.lpTemplateName      = 0; 
 
   if ( GetOpenFileName (&ofn)) 
       peak_write_text_file(hwndOwner,ofn.lpstrFile); 
} 
 
 
 
void bclear(char *ptr2,int len) 
{ 
   char *tmp_holder; 
 
   tmp_holder = ptr2; 
 
   while(tmp_holder - ptr2 < len) 
      *tmp_holder++ = ' '; 
} 
 
 
LONG fill_dlg_box(char *dbase_vendor,HWND hDlg) 
{ 
     
    CHAR output_line[81], 
         data[30]; 
 
    SHORT thread_count,slot_count; 
    INT i, 
        j, 
        flag = 0, 
        hit = 0, 
        loops = 0, 
        proc_id, 
        current_users = 0; 
 
    HANDLE hShared_memory, 
           hSemaphore = NULL; 
 
    LPBYTE lpMapView, 
           ptr; 
     
                  
    if (dbase_vendor) 
       { 
          for (i = 0; i < dbase_entries; i++) 
               if (strncmp(dbase_vendor,dbase_type[i],3) == 0) 
                  { 
                     hit = i; 
                     break; 
                  } 
       } 
 
    loops = dbase_entries; 
         
    for (j = 0; j < loops; j++) 
      { 
        lic_users = 0; 
 
        if (dbase_vendor)						 
           { 
               j = hit; 
               loops = hit ; 
           }  
 
        if ((hSemaphore = OpenSemaphore(SEMAPHORE_MODIFY_STATE | SYNCHRONIZE , 
                          0,semaphores[j])) == NULL) 
           { 
                  continue; 
           } 
        else 
           { 
                 hShared_memory = OpenFileMapping(FILE_MAP_READ|FILE_MAP_WRITE, 
                                           TRUE,__TEXT(shmemkeys[j])); 
                       
                  if ((ptr = lpMapView = MapViewOfFile(hShared_memory, 
                              FILE_MAP_READ | FILE_MAP_WRITE,0,0,2)) == BADADDR) 
                      { 
                              continue; 
                      } 
                   
                  memcpy((char *)&lic_users,ptr,2); 
 
                  UnmapViewOfFile( lpMapView); 
 
                  if (lic_users == 0) 
                     continue; 
 
                  flag++ ;                      
                  hShared_memory = OpenFileMapping(FILE_MAP_READ|FILE_MAP_WRITE, 
                                                  TRUE,__TEXT(shmemkeys[j])); 
 
                  if (! (ptr = lpMapView = MapViewOfFile(hShared_memory, 
                              FILE_MAP_READ | FILE_MAP_WRITE,0,0,MEM_LEN))) 
                     return(109); 
 
                  break;     
               } 
      } 
 
       
      if (flag) 
        {        
            strcpy(active_dbase,dbase_type[j]); 
 
            if ((strcmp(active_dbase,dbase_type[0])) == 0) 
                 CheckRadioButton(hDlg,RADIO_INFORMIX,RADIO_DB2,RADIO_INFORMIX); 
                  
 
            if ((strcmp(active_dbase,dbase_type[1])) == 0) 
                 CheckRadioButton(hDlg,RADIO_INFORMIX,RADIO_DB2,RADIO_SYBASE); 
 
                  
            if ((strcmp(active_dbase,dbase_type[2])) == 0) 
                 CheckRadioButton(hDlg,RADIO_INFORMIX,RADIO_DB2,RADIO_ORACLE); 
 
                  
            if ((strcmp(active_dbase,dbase_type[3])) == 0) 
                 CheckRadioButton(hDlg,RADIO_INFORMIX,RADIO_DB2,RADIO_INGRES); 
 
                  
            if ((strcmp(active_dbase,dbase_type[4])) == 0) 
                 CheckRadioButton(hDlg,RADIO_INFORMIX,RADIO_DB2,RADIO_DB2); 
 
            
            if ((strcmp(active_dbase,dbase_type[7])) == 0) 
                 CheckRadioButton(hDlg,RADIO_INFORMIX,RADIO_DB2,RADIO_MSSQL); 
       
         
            memcpy((char *)&slot_count,ptr,2);					 
            ptr += 2; 
 
            SetDlgItemText(hDlg,SERVER_HOST_TYPE, 
                            (LPCTSTR) active_dbase); 
                             
            lic_users = slot_count;  
                               
            sprintf(output_line,"%d",lic_users); 
      
                 
            SetDlgItemText(hDlg,LICENSE_USERS, 
                            (LPCTSTR) output_line); 
            /* for (i=0; i < slot_count + 256 ; i++)   for ris 5.4 */ 
             
            for (i=0; i < slot_count  ; i++) 
                { 
                    if (*ptr) 
                       { 
                        strncpy(data,ptr,29); 
                        ptr += 30; 
                        memcpy((char *) &proc_id,ptr,4); 
                        ptr += 4; 
                        memcpy((char *) &thread_count,ptr,2);          
                        ptr += 2; 
                                         
                        bclear(output_line,80); 
/*                      sprintf(output_line,"\t%d\t%s\t%d",(i + 1),data,thread_count); */
                        sprintf(output_line,"\t%d\t%s\t%d",(i + 1),data,proc_id); 
                        SendDlgItemMessage(hDlg,DIALOG_BOX,LB_ADDSTRING, 
                                          (DWORD) -1,(DWORD)(LPCTSTR) output_line); 
 
                        current_users++; 
                       } 
                     else 
                       ptr += 36;      
                 } 
 
            UnmapViewOfFile(lpMapView); 
            CloseHandle(hShared_memory); 
            CloseHandle(hSemaphore); 
        } 
        else 
        { 
            SendDlgItemMessage(hDlg,DIALOG_BOX,LB_ADDSTRING, 
                              (DWORD) -1,(DWORD)(LPCTSTR) "\t        No Active RIS Servers on this node"); 
        } 
 
 
/*        if (current_users > slot_count) 
//          { 
//          SendDlgItemMessage(hDlg,DIALOG_BOX,LB_ADDSTRING, 
//                               (DWORD) -1,(DWORD)(LPCTSTR) " "); 
//           
//          SendDlgItemMessage(hDlg,DIALOG_BOX,LB_ADDSTRING, 
//                               (DWORD) -1,(DWORD)(LPCTSTR) " ** RIS User License Exceeded within 90 day Grace Period **"); 
//          } 
*/
           
     return(0); 
} 
 
LONG APIENTRY PeakDlgProc (HWND hDlg, UINT message, UINT wParam, LONG lParam) 
{ 
     LONG tabs[3],                              
          byte_count, 
          i, 
          time(); 
           
     struct _stat file_status; 
      
     TCHAR registry_file[256]; 
      
     char  peak_data[40], 
           output_line[90];      
 
     HANDLE  hFilename; 
      
     struct {              
                int incept_date; 
                int highwater; 
                int current_time; 
             }  header_record; 
 
     tabs[0] = 5 * 4;                       /* List Box Tab Settings */
     tabs[1] = 14 * 4; 
     tabs[2] = 40 * 4; 
 
     switch(message) 
      { 
            case WM_INITDIALOG: 
                                    SendDlgItemMessage(hDlg,PEAK_LIST_BOX,LB_SETTABSTOPS, 3 , (LONG) tabs); 
                      
                                    if (GetWindowsDirectory(registry_file,256)) 
                                             strcat(registry_file,"\\system32\\reg{p}.dll"); 
       
                                    if (strlen(registry_file) == 20 || (_stat(registry_file,&file_status)) == -1) 
                                        { 
                                              
                                            break; 
                                        } 
 
                                    if ((hFilename = CreateFile(registry_file, 
                                                                GENERIC_READ | GENERIC_WRITE, 
                                                                FILE_SHARE_READ | FILE_SHARE_WRITE, 
                                                                NULL, 
                                         OPEN_EXISTING,FILE_ATTRIBUTE_HIDDEN,NULL)) == INVALID_HANDLE_VALUE ) 
                                       { 
               
                                           MessageBox(hDlg,"Peak Usage Control Data not available", 
                                                           "Ris License List",MB_ICONEXCLAMATION);     // should never get here 
                                           break; 
                                       } 
                                    else 
                                       { 
                                         ReadFile(hFilename,&header_record,12,&byte_count,NULL); 
                                         sprintf(output_line,"   %s",ctime(&header_record.current_time)); 
                                         SetDlgItemText(hDlg,PEAK_TIME,(LPCTSTR) output_line); 
                                          
                                        for (i=0; i < header_record.highwater; i++) 
                                          {  
                                            ReadFile(hFilename,peak_data,30, &byte_count,NULL); 
                                            sprintf(output_line,"                 %d  \t       %s",(i+1),peak_data); 
                                            SendDlgItemMessage(hDlg,PEAK_LIST_BOX,LB_ADDSTRING, 
                                                              (DWORD) -1,(DWORD)(LPCTSTR) output_line); 
                                          } 
                                        CloseHandle(hFilename); 
                                       } 
               

                                    /* Ashley - fix for TR 439503225 5/29/96 */
 				    SendDlgItemMessage(hDlg,PEAK_EXIT,BM_SETSTYLE, BS_DEFPUSHBUTTON, (LONG) TRUE);	
					
                                    return FALSE; 
 
            case WM_COMMAND: 
                    switch (LOWORD(wParam)) 
                    { 
                            case  PEAK_CLEAR: 
                                               Clear_file(hDlg); 
                                               break; 
                            case  PEAK_SAVE: 
                                               File_Open(hDlg); 
                                               break; 
                            case  PEAK_PRINT: 
                                               break; 
                            case  PEAK_EXIT: 
                                               EndDialog(hDlg,TRUE); 
                                               break; 
                              
                        default: 
                              return(FALSE);    // Tell manager to do whatever else needs to be done... 
                    } 
        default: 
             return FALSE; 
      } 
       
   return TRUE; 
} 
 
 
static LONG GetRegKeyValueEx( 
	HKEY hKey, 
	LPCTSTR szKey, 
	LPTSTR szValueName, 
	LPDWORD lpdwType, 
	LPBYTE lpBuf, 
	DWORD cbBuf) 
{ 
	HKEY	hKey2; 
	DWORD	cb = cbBuf; 
    LONG	lRetVal; 
 
 
    if (lRetVal = RegOpenKeyEx(hKey, szKey, 0, KEY_READ, &hKey2) != ERROR_SUCCESS) 
	{ 
		RegCloseKey(hKey2); 
		 
		return(ERROR_BADKEY); 
	} 
	if (lRetVal = RegQueryValueEx(hKey2, (LPTSTR)szValueName, NULL, 
		lpdwType, lpBuf, &cb) != ERROR_SUCCESS) 
	{ 
		RegCloseKey(hKey2); 
		 
		return(ERROR_BADKEY); 
	} 
	 
	return(lRetVal); 
} 
 
static char * GetHelpDir() 
{ 
   char     *envname; 
   static char helpname[512]; 
   HKEY     hKey2; 
   TCHAR    devKey[255] ;
   LONG	    lResult; 
   DWORD    dwType; 
   
   if ((envname = getenv("RISDEVDIR")) != NULL) 
      { 
           sprintf(helpname,"%s\\risutl\\config\\english\\help\\rislist.hlp",envname); 
           return(helpname); 
      } 

/*** 1996.05.25 - Melania M Stewart - TR#439601201 - Key was hardcoded to 05.03 ***/       
    sprintf (devKey, "SOFTWARE\\Intergraph\\RIS\\%s", RIS_MAJ_MIN_STR) ; 
    if (((lResult = RegOpenKeyEx(HKEY_LOCAL_MACHINE, devKey, 
					0, KEY_READ, &hKey2)) == ERROR_SUCCESS)  && 
		(GetRegKeyValueEx(HKEY_LOCAL_MACHINE,devKey, 
			"PathName", &dwType, helpname, 512) == ERROR_SUCCESS)) 
	{ 
	    if (helpname[strlen(helpname)-1] == '\\') 
        	    strcat(helpname,"config\\english\\help\\rislist.hlp");
            else
        	    strcat(helpname,"\\config\\english\\help\\rislist.hlp");
/*** 1996.05.25 - Melania M Stewart - The RegCloseKey() was commented out. ***/       
	    RegCloseKey(hKey2); 
	    return(helpname); 
	} 
	 
    strcpy(helpname,"rislist.hlp"); 
    return(helpname); 
} 
 
 
LONG APIENTRY StatusDlgProc (HWND hDlg, UINT message, UINT wParam, LONG lParam) 
{ 
    int status; 
 
    char output_line[81]; 
          
     TCHAR machine_name[40]; 
      
     DWORD machine_name_length = MAX_COMPUTERNAME_LENGTH + 1; 
 
     LONG tabs[3];                               
      

     tabs[0] = 5 * 4;                       // List Box Tab Settings 
     tabs[1] = 14 * 4; 
     tabs[2] = 40 * 4; 
      

    switch(message) 
      { 
	    break; 
            case WM_SYSCOLORCHANGE: 
                                      return 0; 
 
            case WM_INITDIALOG: 
                                    SendDlgItemMessage(hDlg,DIALOG_BOX,LB_SETTABSTOPS, 3 , (LONG) tabs); 
                                     
                                    GetComputerName(machine_name,&machine_name_length); 
                                    wsprintf(output_line,TEXT("\\\\%s"),machine_name);                  // handle unicode stuff 
                                    SetDlgItemText(hDlg,SERVER_HOST_NAME,(LPCTSTR) output_line);         

                                    /* Ashley 5/29/96 - default the radio button to Informix */                            
                                    strcpy(active_dbase,"Informix"); 
                                    CheckRadioButton(hDlg,RADIO_INFORMIX,RADIO_DB2,RADIO_INFORMIX); 
                                    SetDlgItemText(hDlg,SERVER_HOST_TYPE, (LPCTSTR) active_dbase);

                                    status = fill_dlg_box(NULL,hDlg); 

                                    hWnd_default = GetDlgItem(hDlg,REFRESH_BUTTON);
                                    SetFocus(hWnd_default);

                                    /* Ashley - fix for TR 439503225 5/29/96 */
 				    SendDlgItemMessage(hDlg,REFRESH_BUTTON,BM_SETSTYLE, BS_DEFPUSHBUTTON, (LONG) TRUE);	
				   
		                    return FALSE; 
 
            case WM_COMMAND: 
                    switch (LOWORD(wParam)) 
                    { 
                        case  RADIO_INFORMIX: 
                              strcpy(active_dbase,"Informix"); 
                              break; 
                               
                        case  RADIO_SYBASE: 
                              strcpy(active_dbase,"Sybase"); 
                              break; 
 
                        case  RADIO_INGRES: 
                              strcpy(active_dbase,"Ingres"); 
                              break; 
               
                        case  RADIO_ORACLE: 
                              strcpy(active_dbase,"Oracle"); 
                              break; 
                               
                        case  RADIO_MSSQL: 
                              strcpy(active_dbase,"MSSQL"); 
                              break; 
                               
                        case  RADIO_DB2: 
                              strcpy(active_dbase,"DB2"); 
                              break; 
                               
                        case  REFRESH_BUTTON: 
                              if (active_dbase[0] == '\0') 
			      {
                                MessageBox(hDlg,"Please select a vendor database type", 
		                    "Vendor Database",MB_ICONEXCLAMATION); 
                                /* Ashley - fix for TR 439503225 5/29/96 */
                                hWnd_default = GetDlgItem(hDlg,REFRESH_BUTTON);
                                SetFocus(hWnd_default);
				
			      }
                              else 
                              { 
                                SetDlgItemText(hDlg,SERVER_HOST_TYPE, 
                                    (LPCTSTR) active_dbase); 
 
                                SetDlgItemText(hDlg,LICENSE_USERS,(LPCTSTR) ""); 
                             
                                SendDlgItemMessage(hDlg,DIALOG_BOX,LB_RESETCONTENT,0,0L); 
                                                                 
                                status = fill_dlg_box(active_dbase,hDlg);    
                              } 
                               
                              break; 
                               
  
                        case  PEAK_BUTTON: 
                              DialogBox(hInst, 
                                        "PEAK_DIALOG", 
                                        hDlg, 
                                        (DLGPROC) PeakDlgProc); 
                                         
                              /* Ashley - fix for TR 439503225 5/29/96 */
                              hWnd_default = GetDlgItem(hDlg,PEAK_BUTTON);
                              SetFocus(hWnd_default);
                              break; 
 
                               
                        case HELP_BUTTON: 
                              { 
                                 char *pathname; 
                                  
		                 pathname = GetHelpDir(); 
		                  
                                 /* Ashley - fix for TR 439503225 5/29/96 */
                              	 hWnd_default = GetDlgItem(hDlg,HELP_BUTTON);
                                 SetFocus(hWnd_default);
                                 if (!WinHelp (hDlg, pathname, HELP_CONTENTS,0L)) 
	                              { 
	                               /*   MessageBox (GetFocus(), */
	                               /*   _GetResourceString(gco.hhLib,IDS_HELP_FAIL),desc, MB_TASKMODAL|MB_OK|MB_ICONHAND); */
	                             } 
	                              
                                 /* Ashley - fix for TR 439503225 5/29/96 */
                              	 hWnd_default = GetDlgItem(hDlg,HELP_BUTTON);
                                 SetFocus(hWnd_default);
	                         break; 
		              } 
                               
                        case  EXIT_BUTTON: 
                              EndDialog(hDlg,TRUE); 
 		              PostQuitMessage (0) ;                              
                              break; 
                               
                        default: 
                              return(FALSE);    // Tell manager to do whatever else needs to be done... 
                     } 
        default: 
            return FALSE; 
 
    } 
 
    return(0); 
} 

int APIENTRY WinMain(
	HINSTANCE	hInstance, 
	HINSTANCE	hPrevInstance, 
	LPSTR		lpCmdLine, 
	int			nCmdShow)
{
	int      argc;
	char     **argv;
	char     buf[100];	

	MSG      msg; 
	WNDCLASS wc; 
	RECT     rect; 

	// UNREFERENCED_PARAMETER( lpCmdLine ); 
	UNREFERENCED_PARAMETER( hPrevInstance ); 

	hInst = hInstance; 

	/*
	** /V and /? added to fix TR# 439601763.  Surjit (08/16/96)
	*/
	RISuco_initialize_ums(INIT_UTL_UMS_FILE);

	argc = RIScom_parse_command_line(hInst, lpCmdLine, &argv);

	if (argc == 2 && (!strcmp(argv[1], "-V") || !strcmp(argv[1], "/V")))
	{
		char buf2[100];
		strcpy(buf, MSG(RISUTL_I_BEGIN_COPYRIGHT));
		sprintf(buf,"%s %s, %s", buf, COPYRIGHTYEAR,
				MSG(RISUTL_I_END_COPYRIGHT));
		sprintf(buf2, MSG(RISUTL_I_LICLIST_UTILITY), RIS_version);
		strcat(buf, buf2);
		MessageBox(NULL, buf, "RIS Monitor Utility",
				   MB_ICONINFORMATION | MB_OK | MB_TASKMODAL);
		return(0);
	}
	else if (argc == 2 && (!strcmp(argv[1], "-?") || !strcmp(argv[1], "/?")))
	{
		sprintf(buf, "Usage: rliclist [ /V | /? ]\n"
					 "       /V  Display the version.\n"
					 "       /?  Display the usage.\n");
		MessageBox(NULL, buf, "RIS Monitor Utility",
				   MB_ICONINFORMATION | MB_OK | MB_TASKMODAL);
		return(0);
	}
	else if (argc != 1)
	{
		sprintf(buf, "ERROR - Unsupported option(s)!\n"
					 "Usage: rliclist [ /V | /? ]\n");
		MessageBox(NULL, buf, "RIS Monitor Utility",
				   MB_ICONSTOP | MB_OK | MB_TASKMODAL);
		return(1);
	}

	wc.style = 0;                          // Replaces CS_SIZEREDRAW. 
	wc.lpfnWndProc = (WNDPROC)MainWndProc; // The client window procedure. 
	wc.cbClsExtra = 0;                     // No room reserved for extra data. 
	wc.cbWndExtra = 0; 
	wc.hInstance = hInstance; 
	wc.hIcon = LoadIcon (hInst, "adell"); 
	wc.hCursor = LoadCursor (NULL, IDC_ARROW); 
	wc.hbrBackground = GetStockObject (WHITE_BRUSH); 
	wc.lpszMenuName = ""; 
	wc.lpszClassName = "SetInfoWClass"; 

	RegisterClass(&wc); 

	hWnd = CreateWindow ("SetInfoWClass", 
		   "RIS Server Usage List ", 
		   /* WS_OVERLAPPEDWINDOW,  We Don't want sizing border */
		   WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU  | WS_MINIMIZEBOX | WS_BORDER,
		   CW_USEDEFAULT, 
		   CW_USEDEFAULT, 
		   640,                                     /* width */
		   440,                                     /* height */
		   NULL, 
		   NULL, 
		   hInstance, 
		   NULL); 

	Ctl3dRegister(hInst); 
	Ctl3dAutoSubclass(hInst); 

	hWndDlg     = CreateDialog (hInst, "StatusDlg", hWnd, (DLGPROC)StatusDlgProc); 

	GetClientRect (hWnd, &rect); 
	SendMessage (hWnd, WM_SIZE, 480, 640); 
	ShowWindow  (hWndDlg,  SW_SHOW);  
	ShowWindow  (hWnd, nCmdShow); 

	while (GetMessage (&msg, NULL, 0, 0)) 
		if (!IsDialogMessage (hWndDlg, &msg)) 
		   DispatchMessage (&msg);   /* Dispatch message to window. */

	return (msg.wParam);           /* Returns value from PostQuitMessage. */
} 
 
LONG APIENTRY MainWndProc (HWND hwnd, 
                           UINT message, 
                           UINT wParam, 
                           LONG lParam) 
{ 
  switch (message) 
      {
/*   Ashley - fix for TR 439503225 6/18/96 */  
	case WM_ACTIVATE: 
		if ( ! LOWORD(wParam) )  /* is the window being activated ? */
		{
			focus_button = GetFocus(); /* save current button */
			return FALSE; /* let Windows finish the processing */
		}
		else
		{
		 	SetFocus(focus_button); /* restore button focus */
		 	return TRUE; /* done with processing */
		}
/* end Ashley's changes */
        case WM_SIZE : 
             SetWindowPos (hWndDlg, NULL, 0,0, LOWORD(lParam), 440, 0); 
             return (0); 
 
        case WM_DESTROY : 
             PostQuitMessage (0); 
             return (0); 
 
       } 
        
    return DefWindowProc (hwnd, message, wParam, lParam); 
} 
 
 
#endif /* WIN32 */ 
