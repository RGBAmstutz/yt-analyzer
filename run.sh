#!/bin/bash

# activate conda env
eval "$(conda shell.bash hook)"
conda activate yt-analyzer

# execute python code to yank transcript
read -p "please enter a youtube link: " ylink
if ! python ./main.py --link $ylink; then
  exit 1
fi
echo "generated transcript successfully."

# start ollama
echo "running ollama service.."
sudo systemctl start ollama
sleep 1 # allow ollama to start

# list and select model
ollama list
read -p "choose from the above list of models: " model

# output choice
read -p "prompt or summary? " response
case $response in
  summary|Summary|"")
    prompt='please provide a detailed summary of the following video:';;
  prompt|Prompt)
    read -p "enter prompt: " prompt;;
  *)
    echo "invalid response."
    echo "assuming default option: summary."
    prompt='please provide a detailed summary of the following video:';;
esac

# output
echo "---------------------------------------------------"
ollama run \
  $model \
  "$prompt" \
  < ./transcript.txt \
  | tee ./analysis.txt
echo "---------------------------------------------------"

# stop ollama
sudo systemctl stop ollama
echo "exited ollama service successfully."

# transcript
read -p "save transcript? [Y/n] " yn
case $yn in
  y|Y|"")
    echo "transcript saved to $(pwd)/transcript.txt";;
  n|N)
    echo "transcript deleted."
    rm ./transcript.txt;;
  *)
    echo "invalid response."
    echo "saving anyway.";;
esac

# analysis
read -p "save analysis? [Y/n] " yn
case $yn in
  y|Y|"")
    echo "analysis saved to $(pwd)/analysis.txt";;
  n|N)
    echo "analysis deleted."
    rm ./analysis.txt;;
  * )
    echo "invalid response."
    echo "saving anyway.";;
esac

# end
echo "operation complete."
