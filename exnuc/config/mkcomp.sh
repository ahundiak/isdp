# JWW:	23-Jan-1990	Revised:	07-Aug-1990 @14:45
# This is a script that will create the component file from the
# component.db that is in the ~/config directory.  It will keep
# things that are needed but remove Product names and Managers names.
echo ""
echo "	Saving component file to $HOME/component~"
mv component $HOME/component~
echo ""
echo "	Creating:	$PWD/component"
echo "		from:	$PWD/component.db"
echo ""
# Removing the Product names and Managers names.
cut -d\| -f1 component.db >component
