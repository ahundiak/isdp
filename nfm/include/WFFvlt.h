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

/*  These vlts are presently not used in I/NFM  */

static struct vlt_slot vlt_gs_minimal[VLT_GS_MINIMAL_SIZE] =
  {
	{ 0, 0x0000, 0x0000, 0x0000 },
	{ 1, 0x0000, 0xffff, 0x0000 },
	{13, 0xbbbb, 0xbbbb, 0xbbbb },
	{14, 0x8888, 0x8888, 0x8888 },
	{15, 0xeeee, 0xeeee, 0xeeee },
	{31, 0xffff, 0xffff, 0xffff }
  };

static struct vlt_slot vlt_gs_extended[VLT_GS_EXTENDED_SIZE] =
  {
	{ 1, 0x0000, 0xffff, 0x0000 },      /*  (std) green         */
	{ 2, 0xffff, 0x0000, 0x0000 },      /*  (std) red           */
	{ 3, 0x0000, 0x0000, 0xffff },      /*  (std) blue          */
	{ 4, 0xffff, 0xffff, 0x0000 },      /*  (std) yellow        */
	{ 8, 0xffff, 0xffff, 0xbbbb },      /*  (std) light yellow  */
	{ 9, 0x0000, 0x0000, 0x0000 },      /*  (std) black         */
	{10, 0x5555, 0x5555, 0x5555 },      /*  (std) dark grey     */
	{12, 0xeeee, 0xeeee, 0xeeee },      /*  (std) off white     */
	{13, 0xbbbb, 0xbbbb, 0xbbbb },      /*  (std) light grey    */
	{14, 0x8888, 0x8888, 0x8888 },      /*  (std) medium grey   */
	{31, 0xffff, 0xffff, 0xffff }       /*  (std) white         */
   };

static struct vlt_slot vlt_gx_gz[VLT_GX_GZ_SIZE] =
  {
	{ 1, 0xeeee, 0xeeee, 0xeeee },      /*  (std) off white     */
	{ 2, 0x8888, 0x8888, 0x8888 },      /*  (std) medium grey   */
	{ 3, 0x0000, 0x0000, 0x0000 },      /*  (std) black         */
	{ 4, 0xffff, 0xffff, 0x0000 },      /*  (std) yellow        */
	{ 5, 0xbbbb, 0xbbbb, 0xbbbb },      /*  (std) light grey    */
	{ 6, 0x5555, 0x5555, 0x5555 },      /*  (std) dark grey     */
	{ 7, 0xffff, 0xffff, 0xffff },      /*  (std) white         */
	{ 8, 0xffff, 0x0000, 0x0000 },      /*  (std) red           */
	{ 9, 0x0000, 0xffff, 0x0000 },      /*  (std) green         */
	{10, 0x0000, 0x0000, 0xffff },      /*  (std) blue          */
	{11, 0xffff, 0xffff, 0xbbbb }       /*  (std) light yellow  */
   };
