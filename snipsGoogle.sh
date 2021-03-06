#!/bin/bash
# Install mpg123: sudo apt-get install mpg123
# Set your cache path
cache="/usr/share/snips/tts_cache/"

# Edit /etc/snips.toml
# Set "customtts" as snips-tts provider
#
# Add as customtts f.ex.: command = ["/home/pi/snipsWavenet.sh", "%%OUTPUT_FILE%%", "%%LANG%%", "%%TEXT%%", "curl|httpie"]
# Change "PL" to another language country code, "GB" per exemple for a british voice
# Restart snips: systemctl restart snips-*

outfile="$1"
lang="$2"
text="$3"
method="$4"

mkdir -pv "$cache"

languageCode="$lang"-"$country"
googleVoice="$languageCode"-"$voice"
md5string="$text""$lang"
hash="$(echo -n "$md5string" | md5sum | sed 's/ .*$//')"

cachefile="$cache$hash".wav

downloadFile="$cache$hash".mp3

echo "Text: $text"

if [[ ! -f "$cachefile" ]]; then
    echo "Saving sound file $downloadFile"
    if [[ $method = "httpie" ]]; then
        http --debug --download --output "$downloadFile" \
        GET "https://translate.google.com/translate_tts" \
        ie=="UTF-8" \
        client==tw-ob \
        q=="$text" \
        tl=="$lang" \
        total==1 \
        idx==0 \
        textlen==1 \
        User-Agent:"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.125 Safari/537.36"
    else
        text=${text//\'/\\\'}
        curl -G -v \
        -A "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.125 Safari/537.36" \
        --data-urlencode "ie=UTF-8" \
        --data-urlencode "client=tw-ob" \
        --data-urlencode "q=$text" \
        --data-urlencode "tl=$lang" \
        --data-urlencode "total=1" \
        --data-urlencode "idx=0" \
        --data-urlencode "textlen=1" \
        "https://translate.google.com/translate_tts" > "$downloadFile"
    fi

    mpg123 --quiet --wav "$cachefile" "$downloadFile"
    chmod 777 "$cachefile"
    rm "$downloadFile"
else
    echo "Sound file already in cache $downloadFile"
fi

touch "$cachefile"
cp "$cachefile" "$outfile"

