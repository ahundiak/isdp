/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:				comgtver.c
**	AUTHORS:			Hitesh R. Patel
**	CREATION DATE:			6/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
**		Retrieves version information for a particular dll or executable
**		Retrieves license information for a particular executable
**	CHANGES:
*/
 
/*
**	INCLUDES
*/
#if defined(WIN32)
#include <windows.h>
#include "rismem.h"
#endif
#include "riscom.h"
#include "ris_err.h"
#include "risdebug.h"
#include "rislicns.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define comgtver_c
#if defined(WIN32)
#include "comalloc.prt"
#endif
#include "comdebug.prt"
#include "comgtver.prt"
#include "sys.prt"


/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

#if defined(TEST)
extern void print_fixed_version_info(
	VS_FIXEDFILEINFO *ver_infop)
{
	printf("print_fixed_version_info(ver_infop:0x%x)\n", ver_infop);

	printf("dwSignature                = 0x%x\n", ver_infop->dwSignature);
	printf("dwStrucVersion             = 0x%x\n", ver_infop->dwStrucVersion);
	printf("dwFileVersionMS            = 0x%x\n", ver_infop->dwFileVersionMS);
	printf("HIWORD(dwFileVersionMS)    = %d\n", HIWORD(ver_infop->dwFileVersionMS));
	printf("LOWORD(dwFileVersionMS)    = %d\n", LOWORD(ver_infop->dwFileVersionMS));
	printf("dwFileVersionLS            = 0x%x\n", ver_infop->dwFileVersionLS);
	printf("HIWORD(dwFileVersionLS)    = %d\n", HIWORD(ver_infop->dwFileVersionLS));
	printf("LOWORD(dwFileVersionLS)    = %d\n", LOWORD(ver_infop->dwFileVersionLS));
	printf("dwProductVersionMS         = 0x%x\n", ver_infop->dwProductVersionMS);
	printf("HIWORD(dwProductVersionMS) = %d\n", HIWORD(ver_infop->dwProductVersionMS));
	printf("LOWORD(dwProductVersionMS) = %d\n", LOWORD(ver_infop->dwProductVersionMS));
	printf("dwProductVersionLS         = 0x%x\n", ver_infop->dwProductVersionLS);
	printf("HIWORD(dwProductVersionLS) = %d\n", HIWORD(ver_infop->dwProductVersionLS));
	printf("LOWORD(dwProductVersionLS) = %d\n", LOWORD(ver_infop->dwProductVersionLS));
	printf("dwFileFlagsMask            = 0x%x\n", ver_infop->dwFileFlagsMask);
	printf("dwFileFlags                = 0x%x\n", ver_infop->dwFileFlags);
	printf("dwFileOS                   = 0x%x\n", ver_infop->dwFileOS);
	printf("dwFileType                 = 0x%x\n", ver_infop->dwFileType);
	printf("dwFileSubtype              = 0x%x\n", ver_infop->dwFileSubtype);
	printf("dwFileDateMS               = 0x%x\n", ver_infop->dwFileDateMS);
	printf("dwFileDateLS               = 0x%x\n", ver_infop->dwFileDateLS);
}
#endif

/******************************************************************************/

/*
**	Retrieve fixed portion of version info
**	Input: full path of dll or exe
**	Output: VS_FIXEDFILEINFO struct
*/
#if defined(WIN32)
extern VS_FIXEDFILEINFO *RIScom_get_version_fixed_info(
	char *filepath)
{
	int 	ver_handle;			// GetFileVersionInfo[Size]
	char    *ver_info_buffer;		// Version Info
	int 	ver_info_size;			// Version Size Info
	char    *ver_fixed_buffer = NULL;	// Fixed portion of Version Info    
	UINT    ver_fixed_size = 0;		// Fixed portion Size of Version Info

	COM_DBG(("RIScom_get_version_fixed_info(filepath:%s)\n", filepath));


	/*
	** Get size required to hold version information
	** If size is zero, it CAN mean that current filename does not have
	** version information in its image
	*/
	if( !(ver_info_size = GetFileVersionInfoSize(filepath, &ver_handle)) )
	{
		COM_DBG(("GetFileVersionInfoSize returned:%d\n", GetLastError()));
		return 0;
	}

	/*
	** Allocate memory to hold version information
	*/
	ver_info_buffer = SYS_MALLOC(ver_info_size);

	/*
	** Get version information (it returns fixed and variable information)
	*/
	if( !GetFileVersionInfo(filepath, 
							ver_handle, 
							ver_info_size, 
							ver_info_buffer))
	{
		COM_DBG(("GetFileVersionInfoSize returned:%d\n", GetLastError()));
        if(ver_info_buffer)
        {
		    SYS_FREE(ver_info_buffer);
        }
    	return 0;
	}

	/*
	** Query only fixed portion of version information
	** Second argument is set to "\\" root block which has fixed information
	*/
	if( !VerQueryValue((LPVOID)ver_info_buffer,
 						(LPSTR)"\\",
						(LPVOID)&ver_fixed_buffer,
						(LPDWORD)&ver_fixed_size) ) 
	{
		COM_DBG(("VerQueryValue returned:%d\n", GetLastError()));
        if(ver_info_buffer)
        {
		    SYS_FREE(ver_info_buffer);
        }
    	return 0;
	}							 

	if(ver_info_buffer)
	{
		SYS_FREE(ver_info_buffer);
	}
	COM_DBG(("RIScom_get_version_fixed_info: returning 0x%x\n", ver_fixed_buffer)); 
	return((VS_FIXEDFILEINFO *) ver_fixed_buffer); 
}
#endif

/******************************************************************************/

/*
**	Retrieve variable portion of version info
**	Input: full path of dll or exe, block name and symbol name
**	Output: symbol value string
*/
#if defined(WIN32)
extern char *RIScom_get_version_info(
	char *filepath,
	char *stringblock,
	char *stringname)
{
	int 	ver_handle;					// GetFileVersionInfo[Size]
	char    *ver_info_buffer;			// Version Info
	int 	ver_info_size;				// Version Size Info
	char	ver_input_buffer[RIS_MAX_STRING_SIZE];//Requested infotype string
	char    *ver_buffer = NULL;   		// String portion of Version Info    
	UINT    ver_size = 0;				// String portion Size of Version Info

	COM_DBG(("RIScom_get_version_info(filepath:<%s> stringblock:<%s> stringname:<%s>\n", 
			STRING(filepath), STRING(stringblock), STRING(stringname)));


	/*
	** Get size required to hold version information
	** If size is zero, it CAN mean that current filename does not have
	** version information in its image
	*/
	if( !(ver_info_size = GetFileVersionInfoSize(filepath, &ver_handle)) )
	{
		COM_DBG(("GetFileVersionInfoSize returned:%d\n", GetLastError()));
		return 0;
	}

	/*
	** Allocate memory to hold version information
	*/
	ver_info_buffer = SYS_MALLOC(ver_info_size);

	/*
	** Get version information (it returns fixed and variable information)
	*/
	if( !GetFileVersionInfo(filepath, 
							ver_handle, 
							ver_info_size, 
							ver_info_buffer))
	{
		COM_DBG(("GetFileVersionInfoSize returned:%d\n", GetLastError()));
        if(ver_info_buffer)
        {
        	SYS_FREE(ver_info_buffer);
        }
        return 0;
	}

	/*
	** Query the string portion of version information
	*/
	sprintf(ver_input_buffer,"\\StringFileInfo\\%s\\%s", 
			stringblock, stringname);

	if( !VerQueryValue((LPVOID)ver_info_buffer,
 						(LPSTR)ver_input_buffer,
						(LPVOID)&ver_buffer,
						(LPDWORD)&ver_size) ) 
	{
		COM_DBG(("VerQueryValue returned:%d\n", GetLastError()));
        if(ver_info_buffer)
        {
        	SYS_FREE(ver_info_buffer);
        }
        return 0;
	}							 

	COM_DBG(("RIScom_get_version_info: returning <%s>\n", ver_buffer));
	return(ver_buffer);
}
#endif

/******************************************************************************/

/*
**	Retrieve full path of a dll currently in calling process's address space
**	Input: dll or exe name, ptr to hold full path, sizeof(ptr)
**	Output: SUCCESS OR FAILURE
*/
#if defined(WIN32)
extern int RIScom_get_filepath(
	char *filename,
	char *filepath,
	int  length)
{
	HANDLE 	filehandle; 				// GetModuleHandle & GetModuleFileName

	COM_DBG(("RIScom_get_filepath(filename:%s filepath:0x%x length:%d)\n", 
			filename, filepath, length));
	/*
	** Get the handle for filename currently mapped in current process'
	** address space
	*/
	if( !(filehandle = GetModuleHandle(filename)) )
	{
		COM_DBG(("GetModuleHandle returned:%d\n", GetLastError()));
		return 0;
	}
	/*
	** Get full path for the filename
	*/
	if( !GetModuleFileName(filehandle, filepath, length) )
	{
		COM_DBG(("GetModuleFilename returned:%d\n", GetLastError()));
		return 0;
	}
	COM_DBG(("RIScom_get_filepath: returning filepath=<%s>\n", filepath));
	return 1;
}
#endif

/******************************************************************************/

/*
**	Retrieve license info string for USER, COMPANY or SERIAL
**	Input: exe name, lictype (LIC_* listed in rislicns.h)
**	Output: string value	
*/
#if defined(WIN32)
extern char *RIScom_get_license(
	char *filename,
	int	lictype)
{
	HANDLE 	filehandle; 				// GetModuleHandle & GetModuleFileName
	HRSRC	hResInfo, hResource;
	char	resname[3];
	char	*licstring;

	COM_DBG(("RIScom_get_license(filename:%s lictype:%d)\n", filename, lictype));

	switch(lictype)
	{
		case LIC_USER:
			lstrcpy(resname,"#1");
		break;
		case LIC_COMPANY:
			lstrcpy(resname,"#2");
		break;
		case LIC_SERIAL:
			lstrcpy(resname,"#3");
		break;
		default:
			COM_DBG(("RIScom_get_license: INVALID LICTYPE\n"));
			return 0;
	}
	/*
	** Get the handle for filename currently mapped in current process'
	** address space
	*/
	if( !(filehandle = GetModuleHandle(filename)) )
	{
		COM_DBG(("GetModuleHandle returned:%d\n", GetLastError()));
		return 0;
	}
	if( !(hResInfo = FindResource(filehandle, resname, MAKEINTRESOURCE(REG_DATA))) )
	{
		COM_DBG(("FindResource returned:%d\n", GetLastError()));
		return 0;
	}
	if( !(hResource = LoadResource(filehandle, hResInfo)) )
	{
		COM_DBG(("LoadResource returned:%d\n", GetLastError()));
		return 0;
	}
	licstring = (char *)SYS_MALLOC(256);
	if( !(licstring = LockResource(hResource)) )
	{
		COM_DBG(("LockResource returned:%d\n", GetLastError()));
		return 0;
	}
	COM_DBG(("RIScom_get_license: returning licstring=<%s>\n", licstring));
	return licstring;
}
#endif

/******************************************************************************/

#if defined(TEST)
void main()
{
	char *strp;
	char filename[RIS_MAX_PATH_SIZE];
	char filepath[RIS_MAX_PATH_SIZE];
	VS_FIXEDFILEINFO *ver_infop;

	strcpy(filename,"ris.dll");
	if( !RIScom_get_filepath(filename, filepath, sizeof(filepath)) )
	{
		COM_DBG(("GetFileVersionInfoSize returned:%d\n", GetLastError()));
		LONGJMP(RIS_E_CANT_GET_VERSION);
	}

	printf("filepath:%s\n", filepath);

	ver_infop = RIScom_get_version_fixed_info(filepath);
	print_fixed_version_info(ver_infop);

	strp = RIScom_get_version_info(filepath, "040904E4", "FileVersion");
	printf("FileVersion: %s\n", strp);
	strp = RIScom_get_version_info(filepath, "040904E4", "ProductName");
	printf("ProductName: %s\n", strp);

	strcpy(filepath,"c:\\win32app\\ingr\\ris\\risdp\\bin\\riscpp.exe");
	strp = RIScom_get_version_info(filepath, "040904E4", "OriginalName");
	printf("OrginalName: %s\n", strp);

	strp = RIScom_get_license(filepath, LIC_USER);
	printf("user: %s\n", strp);
}

#endif

