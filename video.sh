#!/bin/bash
## make gource video from gource logfile.

# tmp output location. this example will need 13G free.
OUT_PPM="/mnt/raid/phil/out.ppm"
# result
OUT_MP4="dump.mp4"

# dump to $OUT_PPM
gource -1280x720 --camera-mode track --hide progress --output-ppm-stream $OUT_PPM \
       --background-colour 000000 --font-colour 336699 --highlight-users --highlight-colour ff0000 \
       --auto-skip-seconds 1 --seconds-per-day 0.05 --title "hmm..." --user-scale 1 \
       --user-image-dir tmp/avatars --bloom-multiplier 0.5 --bloom-intensity 0.5 --key
       --file-extensions combo.log

# make video with ffmpeg.
ffmpeg -y -r 25 -f image2pipe -vcodec ppm -i $OUT_PPM -vcodec libx264 -preset ultrafast \
       -pix_fmt yuv420p -crf 1 -threads 0 -bf 0 $OUT_MP4

echo "check $OUT_MP4"
rm -f $OUT_PPM
