/*
    Slot mappings for a vlt with 2 slots -

    slot  0  ->  Black
    slot  1  ->  White

    Slot mappings for a vlt with 4 slots -

    slot  0  ->  Black
    slot  1  ->  Medium grey
    slot  2  ->  Light grey
    slot  3  ->  White

    Slot mappings for all vlts with > 4 slots -

    slot  0  ->  Black
    slot  1  ->  Off white
    slot  2  ->  Medium grey
    slot  3  ->  Black
    slot  4  ->  Yellow
    slot  5  ->  Light grey
    slot  6  ->  Dark grey
    slot  7  ->  White
    slot  8  ->  Red
    slot  9  ->  Green
    slot 10  ->  Blue
    slot 11  ->  Light yellow
    slot 12  ->  Dark red
    slot 13  ->  Dark green
    slot 14  ->  Dark blue
    slot 15  ->  White
*/

#define MAX_INTENSITY  65535

#define VLT_TWO_SIZE            2
#define VLT_FOUR_SIZE           4
#define VLT_GS_MINIMAL_SIZE     6
#define VLT_GS_EXTENDED_SIZE   11
#define VLT_GX_GZ_SIZE         11

static struct vlt_slot vlt_two[VLT_TWO_SIZE] =
  {
    { 0, 0x0000, 0x0000, 0x0000 },   /*  Black  */
    { 1, 0xffff, 0xffff, 0xffff }    /*  White  */
  };

static struct vlt_slot vlt_four[VLT_FOUR_SIZE] =
  {
    { 0, 0x0000, 0x0000, 0x0000 },   /*  Black        */
    { 1, 0x8888, 0x8888, 0x8888 },   /*  Medium grey  */
    { 2, 0xbbbb, 0xbbbb, 0xbbbb },   /*  Light grey   */
    { 3, 0xffff, 0xffff, 0xffff }    /*  White        */
  };
