#!/bin/bash

mkdir site_dumps 2> /dev/null
mkdir site_dumps/new 2> /dev/null

grep -v "^#" < sites.txt | 
while read -r website; do 
	{
		webfile=${website//\/}
		tmp_dir="site_dumps/new/$webfile"
		save_dir="site_dumps/$webfile"

		if [ -z "$website" ]; then
			exit 0
		fi

		if [ ! -e "$save_dir" ]; then
			curl -s $website > $tmp_dir; 
			echo $website "INIT"
		else
			curl -s $website >  $tmp_dir; 
			if [ ! -s "$tmp_dir" ]; then
                if [ -s $save_dir  ]; then
                       	echo $website "FAIL"
						cp $tmp_dir $save_dir 
						continue
				fi
		    fi
			web1=$(md5sum < $save_dir)
			web2=$(md5sum < $tmp_dir)
			if [[ $web1 != $web2 ]]; then
				echo $website
			fi
		fi
		cp $tmp_dir $save_dir
	} &

done
