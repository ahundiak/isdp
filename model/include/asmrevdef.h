/*
Name
        asmrevdef.h

Description
        This file contains definitions used by the revise assembly command.

History
        dkk     06/16/94    creation
        dkk     07/12/94    added other bits for op_type
*/

#ifndef revasm_include
#define revasm_include

/*
        Operation types supported 
*/
#define OPERATION_TYPES         0x000000ff
#define UpdateOperation 	0x00000001
#define CopyOperation           0x00000002
#define ReplaceOperation        0x00000004
#define EditOperation           0x00000008
#define NoOperation             0x00000010
#define OverwriteOperation      0x00000020

/*
	Other bits in op_type
*/
#define SPECIAL_BITS                    0xffffff00
#define Reference_file_not_found	0x00000100
#define SUBASSY_EXPLODED		0x01000000

/*
        Definitions used by the Revise Assembly form interface code
*/

#define RevAssyMCF              12
#define CopyAllButton           16
#define DepthSlider             29
#define PreservePathToggle      19
#define PathField               20
#define SuffixField             24

#define NestLevelColumn         0
#define CurrentNameColumn       1
#define OperationColumn         2
#define NewNameColumn           3
#define PartNumberColumn        4
#define RevisionColumn          5
#define DescriptionColumn       6

#define RevAssemblyFormLabel    999
#define IndentWidth             2

#endif
