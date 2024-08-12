#!/bin/bash

voices=("Alex" "Daniel" "Fred" "Karen" "Moira" "Rishi" "Samantha" "Tessa" "Veena" "Victoria")

output_dir="./data/gemini"
mkdir -p $output_dir

random_float() {
    awk -v min=$1 -v max=$2 'BEGIN{srand(); print min+rand()*(max-min)}'
}

random_int() {
    echo $(( $RANDOM % ($2 - $1 + 1) + $1 ))
}

for i in {1..2000}
do
    voice=${voices[$RANDOM % ${#voices[@]}]}

    volume=$(random_float 0.5 2.0)
    pitch=$(random_int 0 99)
    rate=$(random_int 120 240)

    filename="${output_dir}/recording_${i}_${voice}_vol${volume}_pitch${pitch}_rate${rate}.wav"

    # Generate AIFF file using say command
    say -v "$voice" -r "$rate" "[[volm ${volume}]] [[pbas ${pitch}]] Hey Gemini" -o "${filename%.wav}.aiff"

    # Convert AIFF to WAV with desired sample rate and bit depth
    ffmpeg -i "${filename%.wav}.aiff" -ar 16000 -acodec pcm_s16le -ac 1 "$filename"

    # Remove the intermediate AIFF file
    rm "${filename%.wav}.aiff"

    echo "Generated recording $i with voice $voice, volume $volume, pitch $pitch, and rate $rate"
done

echo "Finished generating recordings."
