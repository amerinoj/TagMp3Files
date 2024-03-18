#!/bin/bash
set -e

# Var
SOURCE=.
DESTINATION=.
LOG="mp3_tag.log"
FORMATO=1
ARTISTA=""
ALBUM=""
TITULO=""
FECHA=""
NOMBRE=""
CUENTA=0

# print a log a message
log ()
{	
	echo -e "mp3_tag_file: $1" >> $LOG
	echo -e "mp3_tag_file: $1" >&2
}

########### MAIN ####################

# Parse options to
while getopts "h:l:f:d:s:" opt; do
  case ${opt} in
        h )
                echo "Usage:"
                echo "    mp3_tag_file -h                          Display this help message."
                echo "    [-s]  PATH                               Source path files."
                echo "    [-f]  [1|2|3]                              Output Format"
                echo "    [-d]  PATH                               Destination path"
                echo "    [-l]  mp3_tag_file.log                   Create a log file."
                echo ""
                echo ""
                echo "    Example:"
                echo "    mp3_tag_file.sh -s ./music -d ./music_taged -f1 -l \"mp3_tag.log\""
                echo ""
                echo "\!Mandatory install ffmpeg dependency\!"
                echo ""
                exit 0
          ;;
	s )
                SOURCE="$OPTARG"
                echo -e  "-------------------------------------"
                echo -e "SOURCE: \e[1m"$SOURCE"\e[21m"
                echo -e "\e[25m\e[21m\e[22m\e[24m\e[25m\e[27m\e[28m"              
        ;;
        d )
                DESTINATION="$OPTARG"
                echo -e  "-------------------------------------"
                echo -e  "DESTINATION: \e[1m"$DESTINATION"\e[21m"
                echo -e "\e[25m\e[21m\e[22m\e[24m\e[25m\e[27m\e[28m"               
         ;;
        f )
                FORMATO="$OPTARG"
                echo -e  "-------------------------------------"
                echo -e  "FORMAT: \e[1m"$FORMATO"\e[21m"
                echo -e "\e[25m\e[21m\e[22m\e[24m\e[25m\e[27m\e[28m"               
         ;;
        l )
                LOG="$OPTARG"
                echo -e  "-------------------------------------"
                echo -e  "LOG: \e[1m"$LOG"\e[21m"
                echo -e "\e[25m\e[21m\e[22m\e[24m\e[25m\e[27m\e[28m"
        ;;
   \? )
                echo "Invalid Option: -$OPTARG" 1>&2
                exit 1
         ;;
  esac
done

# CHECK PATHS
if test -d "$DESTINATION"; then
	log  "Destination $DESTINATION exists."
else
	mkdir "$DESTINATION"
	log  "Destination $DESTINATION created."
fi
		
if ! test -d "$SOURCE"  ; then
	log  "ERROR: Source Directory $SOURCE not exists."
	exit 1;
fi  

if ((FORMATO < 1 || FORMATO >3)); then
  	log  "ERROR: Incorrect format $FORMATO ."
	exit 1;
fi


# PARSE
log  "$(date)" 
CUENTA=0

for FILE in "$SOURCE"/*
do
	  
	ARTISTA="$(ffmpeg -i $FILE 2>&1 | grep 'artist' | cut -d ':' -f2 | awk '{$1=$1};1')"
	ALBUM="$(ffmpeg -i $FILE 2>&1 | grep 'album           :' | cut -d ':' -f2 | awk '{$1=$1};1')"
	TITULO="$(ffmpeg -i $FILE 2>&1 | grep 'title' | cut -d ':' -f2 | awk '{$1=$1};1')"
	FECHA="$(ffmpeg -i $FILE 2>&1 | grep 'date' | cut -d ':' -f2 | awk '{$1=$1};1')"
	
	#remove special characters
	ESPECIAL="\/¿?:."
	ARTISTA="${ARTISTA//[$'\t\r\n']}"
	ARTISTA="${ARTISTA//[$ESPECIAL]/}"
	ALBUM="${ALBUM//[$'\t\r\n']}"
	ALBUM="${ALBUM//[$ESPECIAL]/}"
	TITULO="${TITULO//[$'\t\r\n']}"
	TITULO="${TITULO//[$ESPECIAL]/}"
	FECHA="${FECHA//[$'\t\r\n']}"
	FECHA="${FECHA//[$ESPECIAL]/}"

	if [ "$FORMATO" -eq "1" ]; then
		NOMBRE="$ARTISTA - $TITULO"
  		
  	else
		if [ "$FORMATO" -eq "2" ]; then
		NOMBRE="$TITULO - $ALBUM"
		else
			if [ "$FORMATO" -eq "3" ]; then
			NOMBRE="$TITULO"
			fi
		fi
  	 
	fi
	
	

	
	if [ -z "$ARTISTA" ]; then
	      log "ERROR: ARTISTA is empty in  "$FILE" (NOTHING WAS DONE) "
	      log "ERROR"
	      
	else
		log "$TITULO  - $ALBUM - $FECHA - $ARTISTA"
		

		


		if [ "$FORMATO" -eq "1" ]; then
		
			if test -f "$DESTINATION/$NOMBRE.mp3"; then
				log  "WARNING:\t\t $NOMBRE.mp3  file it already exists."
				FILE1_SIZE=$(stat --format=%s "$FILE")
				FILE2_SIZE=$(stat --format=%s "$DESTINATION/$NOMBRE.mp3")
				if [ "$FILE1_SIZE" -gt "$FILE2_SIZE" ]; then
					cp $FILE "$DESTINATION/$NOMBRE.mp3"
					log  "\t\t\t $NOMBRE.mp3  copied."
				else
					log  "\t\t\t $NOMBRE.mp3  keeped."
				fi
				log  "OK."
			else
				cp $FILE "$DESTINATION/$NOMBRE.mp3"
				log  "\t\t\t $NOMBRE.mp3  copied."
				log  "OK."
			fi		
		
	  	else

			if test -d "$DESTINATION/$ARTISTA"; then
				log  "\t /$ARTISTA : Directory exists."
			else
				mkdir "$DESTINATION/$ARTISTA"
				log  "\t /$ARTISTA : Directory created."
			fi
		
			if [ "$FORMATO" -eq "2" ]; then

				
				if test -f "$DESTINATION/$ARTISTA/$NOMBRE.mp3"; then
					log  "WARNING:\t\t $NOMBRE.mp3  file it already exists."
					FILE1_SIZE=$(stat --format=%s "$FILE")
					FILE2_SIZE=$(stat --format=%s "$DESTINATION/$ARTISTA/$NOMBRE.mp3")
					if [ "$FILE1_SIZE" -gt "$FILE2_SIZE" ]; then
						cp $FILE "$DESTINATION/$ARTISTA/$NOMBRE.mp3"
						log  "\t\t\t $NOMBRE.mp3  copied."
					else
						log  "\t\t\t $NOMBRE.mp3  keeped."
					fi
					log  "OK."
				else
					cp $FILE "$DESTINATION/$ARTISTA/$NOMBRE.mp3"
					log  "\t\t\t $NOMBRE.mp3  copied."
					log  "OK."
				fi			
		
			else
				if [ "$FORMATO" -eq "3" ]; then

					if test -d "$DESTINATION/$ARTISTA/$ALBUM"; then
						log  "\t\t /$ARTISTA/$ALBUM : Directory exists."
					else
						mkdir "$DESTINATION/$ARTISTA/$ALBUM"
						log  "\t\t /$ARTISTA/$ALBUM : Directory created."
					fi	
					
					if test -f "$DESTINATION/$ARTISTA/$ALBUM/$NOMBRE.mp3"; then
						log  "WARNING:\t\t $NOMBRE.mp3  file it already exists."
						FILE1_SIZE=$(stat --format=%s "$FILE")
						FILE2_SIZE=$(stat --format=%s "$DESTINATION/$ARTISTA/$ALBUM/$NOMBRE.mp3")
						if [ "$FILE1_SIZE" -gt "$FILE2_SIZE" ]; then
							cp $FILE "$DESTINATION/$ARTISTA/$ALBUM/$NOMBRE.mp3"
							log  "\t\t\t $NOMBRE.mp3  copied."
						else
							log  "\t\t\t $NOMBRE.mp3  keeped."
						fi
						log  "OK."
					else
						cp $FILE "$DESTINATION/$ARTISTA/$ALBUM/$NOMBRE.mp3"
						log  "\t\t\t $NOMBRE.mp3  copied."
						log  "OK."
					fi
				
				fi
			fi
		fi
	
	fi
	log "______________________________________________________________________________________________"
	CUENTA=$((CUENTA+1))
	
done
log "$CUENTA Files Processed"
log "Finished"
