/*************************************************************************
Author	: k.Barbette

Creation: 27-01-1993
18 Dec 2000 law tr-MP4340 eqp_partno was 20 chars. Db was 30.

*************************************************************************/


#ifndef vrequipment
#define vrequipment	1


struct	VRdbEquipDesc
{
	IGRchar		Desc[41];
	IGRchar		Location[21];
};

struct	VRdbEquipPart
{
	IGRchar		Familly[21];
	IGRchar		PartNb[31];  /*** TR-MP4340 ***/
	IGRchar		PartRev[21];
};


/*******************************************************************************
* KDD Aug 97
*
* VREquipment_common structure contains storage space for the instance data 
* of VREquipment class plus selection flag.
* 
*******************************************************************************/
struct VREquipment_common
{
	int		Iwant;		
	IGRchar		EquipNo[80];
};

#define VREquipment_EquipNo	1
#define VR_PID_REPLACE		2

#endif
