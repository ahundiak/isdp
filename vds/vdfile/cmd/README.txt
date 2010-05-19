vds/vdfile/cmd/VDfileBrowse.I contains a most adaptable file browsing tool.

This tool has the options available inside it to fetch a file from any non-hiden directory 
that exists in the file system of the local computer.

The whole operation is available through a fairly well explained macro in 
vds/include/VDfile.h vdfile$BrowseFiles();  

This process operates independently of any other operations and may be fetched at very nearly
any level in VDS.  NO USER INPUT IS REQUIRED for this to operate.  Variables need not be set
in advance unless a default value is desired.  Variables principally serve as return locations

This has a switch to seek out the local path and to turn off browsing files outside 
this path.  

This has a switch to limit user selection of files by type. This may be specified or 
not as the programmer desires.

This has a return value to indicate if the user selected a file.  There is a file returned
any time if one is selected.  There can be returned a blank file selection.

The process has wildcard selection of types of files to display.  This is unlimited in scope.

Default display of previous values can be achieved by merely returning the old values as 
input when beginning a new browser operation.


This also produced some useful subroutines that there may be other uses for. 

Specifically
If the user wishes to get the directory and filename from a full local path there is a tool for this. Specifically the UNIX paths!
vdfile$GetLocalPath(path,dir,file);

IF the user wishes to validate if a string is really a path there is a tool for this.
vdfile$IsPath(path)

If the user wishes to do wildcard selection of data there are tools to do this.
vdfile$IsFilterMatch(filter,name) matches filter to a string
vdfile$GetFilterSplit(filter,frontFilter,backFilter) gets the filters for a filename/extension

If the user wishes to clip the blanks off the front of a string there is a tool to do this.
vdfile$ClipFrontSpaces(buffer)

If the user wishes to know how many blanks are on the front of a string there is a tool to do this.
vdfile$CountOffset(dirPath)

