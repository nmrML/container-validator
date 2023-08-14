#!/bin/sh
HOME=/var/www/
export HOME

## Whenever you change a path here, 
## also update the appropriate apparmor profile 
## under /etc/apparmor.d/local/vol.openms.src.trunk.OpenMS-nmrML.bin.FileInfo 

/OpenMS/OpenMS-nmrML/bin/FileInfo -ini /var/www/html/nmrML-validator/FileInfo.ini -v -in "$1"  -in_type nmrML

#/OpenMS/OpenMS-nmrML/bin/SemanticValidator -in "$1"  -cv /nmrML/nmrCV.obo -mapping_file /nmrML/nmr-mapping.xml



