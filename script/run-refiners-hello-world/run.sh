#!/bin/bash

CUR_DIR=${PWD}

echo ""
echo "REFINERS GITHUB REPO CHECKOUT PATH: ${CM_GIT_REPO_REFINERS_CHECKOUT_PATH}"
echo "MODEL PATH: ${CM_ML_MODEL_PATH}"
echo "Current execution path: ${CUR_DIR}"
echo "Path to script: ${CM_TMP_CURRENT_SCRIPT_PATH}"

cd ${CM_TMP_CURRENT_SCRIPT_PATH}
mkdir -p tmp
cd tmp

#export PYTHONPATH=${CM_GIT_REPO_REFINERS_CHECKOUT_PATH}/src:$PYTHONPATH


if [[ "${CM_REFINERS_SKIP_CONVERT}" == "" ]]; then
  echo ""
  echo "curl -LO https://huggingface.co/pcuenq/pokemon-lora/resolve/main/pytorch_lora_weights.bin"
  echo ""
  curl -LO https://huggingface.co/pcuenq/pokemon-lora/resolve/main/pytorch_lora_weights.bin
  test $? -eq 0 || exit 1

  echo ""
  echo "python scripts/convert-lora-weights.py --from pytorch_lora_weights.bin --output-file pokemon_lora.safetensors"
  echo ""
  ${CM_PYTHON_BIN_WITH_PATH} ${CM_GIT_REPO_REFINERS_CHECKOUT_PATH}/scripts/convert-lora-weights.py --from pytorch_lora_weights.bin --output-file pokemon_lora.safetensors
  test $? -eq 0 || exit 1

  echo ""
  echo "python scripts/convert-clip-weights.py --output-file CLIPTextEncoderL.safetensors"
  echo ""
  ${CM_PYTHON_BIN_WITH_PATH} ${CM_GIT_REPO_REFINERS_CHECKOUT_PATH}/scripts/convert-clip-weights.py --output-file CLIPTextEncoderL.safetensors --from ${CM_ML_MODEL_PATH}
  test $? -eq 0 || exit 1

  echo ""
  echo "python scripts/convert-sd-lda-weights.py --output-file lda.safetensors"
  echo ""
  ${CM_PYTHON_BIN_WITH_PATH} ${CM_GIT_REPO_REFINERS_CHECKOUT_PATH}/scripts/convert-sd-lda-weights.py --output-file lda.safetensors --from ${CM_ML_MODEL_PATH}
  test $? -eq 0 || exit 1

  echo ""
  echo "python scripts/convert-sd-unet-weights.py --output-file unet.safetensors"
  echo ""
  ${CM_PYTHON_BIN_WITH_PATH} ${CM_GIT_REPO_REFINERS_CHECKOUT_PATH}/scripts/convert-sd-unet-weights.py --output-file unet.safetensors --from ${CM_ML_MODEL_PATH}
  test $? -eq 0 || exit 1
fi

rm -f ${CM_REFINERS_OUTPUT_FILE}
rm -f ${CUR_DIR}/${CM_REFINERS_OUTPUT_FILE}

echo ""
echo "python main.py"
echo ""
${CM_PYTHON_BIN_WITH_PATH} ${CM_TMP_CURRENT_SCRIPT_PATH}/main.py
test $? -eq 0 || exit $?

cp ${CM_REFINERS_OUTPUT_FILE} ${CUR_DIR}
