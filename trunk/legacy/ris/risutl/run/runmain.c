/* Do not alter this SPC information: $Revision: 1.3.50.1 $ */
#include <windows.h>
#include <stdio.h>
#include <malloc.h>

#include "rislimit.h"

#define runmain_c
#include "runmain.prt"

typedef struct data_s
{
	char *key;
	char *title;
	char *exe;
} data_s;

static data_s data[] =
{
	{	"LOD",		"RIS Loader",			"rislod.exe"	},
	{	"UNLOD",	"RIS Unloader",			"risunlod.exe"	},
	{	"RECRD",	"RIS Record",			"risrecrd.exe"	},
	{	"PLBCK",	"RIS Playback",			"risplbck.exe"	},
	{	"CLNSR",	"RIS Clean Servers",	"risclnsr.exe"	},
	{	"DCODE",	"RIS Decode",			"risdcode.exe"	},
	{	"DTYPE",	"RIS Data Types",		"risdtype.exe"	},
};

static int data_count = sizeof(data)/sizeof(data_s);

extern int WINAPI WinMain(
	HANDLE hInst,
	HANDLE hPrevInst,
	LPSTR lpCmdLn,
	int nShowCmd)
{
	int					i;
	int					argc;
	char				*ptr;
	char				cmd[300] = "";
	char				**argv;
	STARTUPINFO			si;
	PROCESS_INFORMATION	pi;

	argc = parse_command_line(hInst, lpCmdLn, &argv);

	if (argc != 2)
	{
		return 1;
	}

	for (i = 0; i < data_count; i++)
	{
		if (!strcmp(argv[1], data[i].key))
		{
			break;
		}
	}
	if (i == data_count)
	{
		return 1;
	}

	if ((ptr = strrchr(argv[0], '\\')) != NULL)
	{
		ptr++;
		*ptr = '\0';
		strcpy(cmd, argv[0]);
	}
	strcat(cmd, data[i].exe);

    memset(&pi, 0, sizeof(PROCESS_INFORMATION));
	memset(&si, 0, sizeof(STARTUPINFO));

	si.cb = sizeof(STARTUPINFO);
	si.lpTitle = data[i].title;
	si.dwXCountChars = 80;
	si.dwYCountChars = 250;
	si.dwFlags = STARTF_USECOUNTCHARS;

	CreateProcess(NULL, cmd, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, 	
	  	NULL, &si, &pi);
}

static int parse_command_line(
	HANDLE	hInst,
	char *cline,
	char ***argv)
{
	int		c;
	char	*tok;
	char	**v;

	c = 1;
	v = (char **)malloc(c * sizeof(char *));

	v[0] = (char *)malloc(RIS_MAX_PATH_SIZE);
	GetModuleFileName(hInst, v[0], RIS_MAX_PATH_SIZE);

	tok = strtok(cline, " \t");
	while(tok != NULL)
	{
		c++;
		v = (char **)realloc(v, c * sizeof(char *));
		v[c-1] = tok;
		tok = strtok(NULL, " \t");
	}

	*argv = v;
	return c;
}
