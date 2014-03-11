#!/usr/bin/env bash

#-----------------------------------------------------------------------
#  AUTHOR	: Jean-Francois GAZET
#  WEB 		: http://www.jeffprod.com
#  TWITTER	: @JeffProd
#  MAIL		: jeffgazet@gmail.com
#  LICENCE	: GNU GENERAL PUBLIC LICENSE Version 2, June 1991
#-----------------------------------------------------------------------

#------------------------------------------------------------------------------
#	FUNCTIONS
#------------------------------------------------------------------------------

function redim_image()
	{
	workingDir=$1; # input/output directory 
	imageSize=$2; # choosen image size by user (640x480, 800x600...)
	ext=$3; # file extention (jpg,GIF,png...)

	# changine working directory
	cd ${workingDir}; 

	# number of files with given extension
	shopt -s nullglob
	numfiles=(*.$ext)
	numfiles=${#numfiles[@]}

	# if we have some files with given extension
	if [ "$numfiles" -ne 0 ]; then
		(
		cpt=1; # for % working progress

		# for each file with given extension
		for file in *.$ext; do

			# we want i.e. 800(w)600(h) and 600(w)800(h) to have the same final size
			width=`identify -format "%w" $file`;
			height=`identify -format "%h" $file`;
			if [[ $width < $height ]]; then newImageSize="x${imageSize}"; else newImageSize="${imageSize}x"; fi;

			# let's convert it to requested sized, renamed to "rezise-filename"
			convert $file -resize $newImageSize -quality 95 resize-$file;

			r=$(echo "($cpt/$numfiles)*100" | bc -l) # % working progress with decimals
			r=${r/\.*} # int cast
			echo $r; # used by zenity for working progress
	
			echo "# $cpt/$numfiles $file"; # showing file done in zenity information window
			cpt=$(($cpt+1));
		done
		) | zenity --progress --title="Resize in progress" --percentage=0 --auto-close

		# final information for user into a zenity window
		zenity --info --text "$numfiles images $ext \nresized to $imageSize \nin $workingDir";

	fi; 
	}

#------------------------------------------------------------------------------
#	PROGRAM
#------------------------------------------------------------------------------

# Select images' directory with zenity
dir=$(zenity 	--file-selection \
		--title="Select directory containing images to resize" \
		--directory);
if [ -z "$dir" ]; then zenity --warning --text "Directory not selected"; exit 0; fi

# Select the image size by user
format=$(zenity --list \
		--title="Resize images to..." \
		--text="Select pixel size to fit in" \
		--height=300 \
		--hide-header \
		--column "Image size" \
		160 320 640 800 1280 1600 2048 2280 2580 3000
		);
if [ -z "$format" ]; then zenity --warning --text "Format not selected"; exit 0; fi

# zenity list returns either i.e. '640' or '640|640' in case you enter on keyboard or click on validate button ! so we split
IFS='|' read -a array <<< "$format"; 
format="${array[0]}"; # 640

# Let's do the job for each type of image in the directory, case sensitive
redim_image $dir $format "JPG";
redim_image $dir $format "jpg";
redim_image $dir $format "GIF";
redim_image $dir $format "gif";
redim_image $dir $format "JPEG";
redim_image $dir $format "jpeg";
redim_image $dir $format "PNG";
redim_image $dir $format "png";

exit 0
