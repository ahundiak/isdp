
/* 
**  InteropRemoveRIS removes the 04.03 key from the 
**  registry if it exists and copies schemas and parameters files
**  to new shared component location.  
**
*/
 
extern void InteropRemoveRIS(HWND in_parent, HWND in_instance);
extern void RmtCenterWindow (HWND, HWND);

LONG RISDeleteDirectory(char *directory,char *pattern);
LONG RISRemoveProductDirsAndFiles(char **FilesDirList,char *ProductPath);

extern char * GetResourceString
(
   HINSTANCE hInstance,
   UINT uIdsFormat,
   ... );
