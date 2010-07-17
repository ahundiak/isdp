/*
	I/STRUCT
*/
class specification VSrtUpdCmd(0:0) of super_cmd ;

override	execute ;

end specification VSrtUpdCmd ;

/****************************************************************************

        Description:

	This command updates old objects ( created before creating VDSroot
object ) to subclass of VDSroot. This command has been adopted from 
VDS command vdconvert/cmd/VDrtupdcls.sl.

 	Correction done by Eric Faivre do correct the design file
 	with objects created before using VDSroot class.

	Below you find the problem description of Eric.


I found that the problem comes from the class VDSroot !!!.

When you create a plate in a new design file, the system creates the plate
but also some other objects ( OM objects ), one of this object is the
OMOSCO.

The OMOSCO object is unique and represents a class definition ( OM class ).
It contains some informations about the class it represent and the number
of objects of this class.

This is the class hierarchy of a source plate.

		 Root
		 |
		 V
		 .
		 .
		 |
		 NDnode
		 |
		 V
		 .
		 .
		 |
		 VDSroot
		 |
		 V
		 |
		 VScpx
		 |
		 V
		 |
		 VSsrcPlate

When constructing a plate the system see if the OMOSCO of the class
VSsrcPlate exist, if no it creates it. Looks the parent class, here VScpx.
See if the OMOSCO of the class VScpx exist, if no it creates it ... until
Root class.

You can have several plates, but you have only ONE OMOSCO of class VSsrcPlate.
The OMOSCO knows the number of elements of that class.

When you delete the plate, it's that you did on the test case, the system
delete the plate, and delete also all the OMOSCO if its number of element is
zero.

For example, you have two plates. You delete the first one. The system
deletes only the plate ( graphic ), it doesn't delete the OMOSCO because
the second plate still exist.

when you delete the second plate, the system deletes the plate ( graphic ).
Delete also the OMOSCO of the class VSsrcPlate. Looks the parent class,
here VScpx. See if the number of element of class VScpx still exist ( No,
because its an abstract class ), so it delete the OMOSCO of the class
VScpx ... until Root.

This is the mechanisum of the delete.

In the test case, the plates were created before the implementation of the
class VDSroot. So, the OMOSCO object of the class VDSroot doesn't exist in
the test case !!!

When you delete the last plate with the product where VDSroot is implemented.
The system assumes that the OMOSCO of the class VDSroot exist do delete it,
but, it doesn't exist and we have a memory fault ( the OMOSCO of the class
VDSroot is a NULL pointer in the list of OMOSCO ).

The problem appears here with a plate, but we can have the same thing which
all objects sub-classed from VDSroot !!! ( PIPING, LOFT, VDS, ... )

That means also that the file created in 2.2 ( where VDSroot doesn't exist )
will fail with some commands in 2.3 !!!


        History:
        EF     11-23-1994      Creation date

 ****************************************************************************/

