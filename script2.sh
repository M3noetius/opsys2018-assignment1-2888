#!/bin/bash

#Init 
tmpuzip="./tempunzip1337"
repos=$(tempfile)
assignments="assignments"

mkdir "$tmpuzip"

# Check assignments folder
if [ ! -d "$assignments" ]; then
	mkdir $assignments
fi

#Unzip file and search for repos
tar -xvf $1 -C $tmpuzip > /dev/null

for file in $(find $tmpuzip -type f -name "*.txt"); do 
	cat $file | grep "^https" | head -n 1 >> $repos
done

# Clean up extracted data
rm -R $tmpuzip

# Clone repos
grep -v "^#" < $repos | 
while read -r repo_name; do 
        GIT_TERMINAL_PROMPT=0 git clone $repo_name -q  2> /dev/null
        if [[ $? -eq 0 ]]; then 
            echo "$repo_name:" "Cloning OK"
            # May crash in mv due to the same named repo 
            # Only for debug purposes
            mv $(basename -s .git $repo_name) $assignments/ 2> /dev/null || 
            rm -R $(basename -s .git $repo_name)
        else
            echo "$repo_name:" "Cloning FAILED"
            exit 1
        fi
done


# Check validity
for folder in $(ls ./$assignments/); do
	folder=${folder%%/}
	echo $folder":"
	folder="./$assignments/$folder"
	
	# minus 2 because we want to exclude the . and .git directory
	echo "Number of directories :" $(($(find $folder -type d ! -path "$folder/.git/*" | wc -l) - 2))


	txt_number=$(($(find $folder -type f ! -path "$folder/.git/*"  -name "*.txt"| wc -l)))
	echo "Number of txt files :" $txt_number

	echo "Number of other files :"  $(($(find $folder -type f ! -path "$folder/.git/*" | wc -l) - $txt_number))

	if [ ! -f "./$folder/dataA.txt" -a ! -f "./$folder/more/dataB.txt" -a ! -f "./$folder/more/dataC.txt" ]; then 
		echo "Directory structure is NOT OK." 
	else
		echo "Directory structure is OK."
	fi; 
done



