#!/bin/bash


#This function tests if a line is empty or a comment
#returns:(0 if line is not empty/comment)&&(1 if the line is a comment or empty)
function line_is_valid () {
	if [[ $1 == \#* ]] ||  [[ -z $1 ]]
	then
		return 1
	else
	 	return 0
	fi	
}


#This function is used to initialize a url inside source.If the url doesnt exist in source.txt ,it is added 
# and the appropriate stdout is printed
#returns:(0 if the url was initialized)&&(1 if the url has already been initialized)
function search_update() {
	
	if ! grep -q "$1" source.txt
	then
		if curl -s "$1" > temp.txt 
		then
			md5="$(md5sum temp.txt | awk '{ print $1 }')"
			echo $md5 $1 >> source.txt
			echo "$1 INIT"	
		else
			echo "$1 FAILED" >&2
		fi
	
	else
	
		if curl -s "$1" > temp.txt
		then	
			newHash="$(md5sum temp.txt | awk '{ print $1 }')"
			prevHash="$(grep "$1" source.txt | awk '{ print $1 }')"
			if ! [ "$newHash" = "$prevHash" ]
			then
				echo $1
				sed -i "s/$prevHash/$newHash/" source.txt
			fi	
		else
			echo "$1 FAILED" >&2
		fi
	fi
}







#Making sure that source.txt exists
if ! [[ -r source.txt ]] 
then
	touch source.txt
fi
#fetching all urls
while read row 
do
	if  line_is_valid $row 
	then
	urls="$urls $row "
	fi
done < $1



for url in $urls
do
	search_update $url &	
done 
wait
