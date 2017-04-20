#!/bin/bash

for f in *.fa
do
	NAMESP=$(echo $f | cut -d "." -f 1)
	perl -pi -e "s/>/>$NAMESP\_/g" $f
done
