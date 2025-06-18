# necessary imports
import sys
import argparse
from youtube_transcript_api import YouTubeTranscriptApi
from youtube_transcript_api._errors import TranscriptsDisabled

# parse arguments when running file
parser = argparse.ArgumentParser()
parser.add_argument('--link', type=str, required=True, help='link to parse transcript for')
args = parser.parse_args()
# fetch url from arguments
url = args.link
id = url.split("?v=")[1]

# call youtube api
ytt_api = YouTubeTranscriptApi()
try:
    raw_transcript = ytt_api.fetch(id)
except TranscriptsDisabled:
    sys.exit("transcripts are unavailable for this video.")
except:
    sys.exit("unknown exception occurred.")

# write transcript to file
with open ("transcript.txt", "w") as f:
    for segment in raw_transcript:
        f.write(" " + segment.text)
