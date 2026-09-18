#!/usr/bin/env bash
# llm-env.sh — set the translation pipeline's model configuration for LOCAL use.
#
#   SOURCE it, do not execute it:
#
#       source scripts/llm-env.sh
#
# Why this file exists. The model endpoint is a configuration value (R3 §8.1)
# and is stored nowhere in the repository: in CI it comes from GitHub repository
# variables and secrets; locally it comes from your shell. There is no .env file
# and nothing in the pipeline reads one. This is the local half of that contract.
#
# This is a developer convenience for one machine. The department's official
# endpoint is still an open question (R1b open question 4) and nothing here
# presumes an answer to it.

# --- Ollama, two routes ----------------------------------------------------
# Both were probed from this machine on 2026-09-18. THE MODEL ID DIFFERS
# BETWEEN THEM, which is the easy mistake:
#
#   A. LOCAL OLLAMA, proxying the cloud model   <-- the default below
#        endpoint  http://host.docker.internal:11434/v1
#        model     deepseek-v4.1-flash:cloud     (WITH the cloud suffix)
#        key       none needed
#      EVERY cloud model needs the suffix on this route -- it is what tells the
#      local Ollama to proxy rather than look for a pulled model. A model that
#      already carries a tag takes it with a hyphen: 'gpt-oss:120b-cloud', not
#      'gpt-oss:120b'. Without it the call returns 404 'model not found'.
#      `ollama signin` stores the ollama.com credential on this machine and
#      Ollama forwards the call, so no Authorization header is involved and no
#      secret ever becomes an environment variable. Verified: a completion for
#      deepseek-v4.1-flash:cloud succeeded here with no key set.
#
#   B. OLLAMA CLOUD, called directly
#        endpoint  https://ollama.com/v1
#        model     deepseek-v4.1-flash           (NO :cloud suffix -- that
#                                                 suffix is the LOCAL Ollama's
#                                                 marker for a proxied model;
#                                                 ollama.com does not use it)
#        key       REQUIRED -- /v1/chat/completions returns 401 without one
#      Use this only if you want the container to reach ollama.com without a
#      local Ollama running. Put the key in scripts/llm-env.local, never here.
#
# Route A is the default because it keeps the key off this repository entirely,
# which is the whole point of the local setup.

# --- the endpoint, as the CONTAINER sees it --------------------------------
# NOT localhost. The renderer runs inside a container, where localhost is the
# container itself. host.docker.internal resolves to the host; Docker Desktop
# provides it on Windows and macOS, and on Linux the `docker run` must also pass
#   --add-host=host.docker.internal:host-gateway
# .github/scripts/translate-main.sh already does, and so does translate-local.sh.
#
# translate.py appends "/chat/completions", so this must be the BASE url and end
# at /v1.
export LLM_ENDPOINT="${LLM_ENDPOINT:-http://host.docker.internal:11434/v1}"
export LLM_MODEL="${LLM_MODEL:-deepseek-v4.1-flash:cloud}"

# For route B, either edit scripts/llm-env.local with both lines --
#     LLM_ENDPOINT=https://ollama.com/v1
#     LLM_MODEL=deepseek-v4.1-flash
#     LLM_API_KEY=...
# -- or set them in the shell before sourcing this file; the assignments above
# defer to anything already set.

# --- timeout ---------------------------------------------------------------
# translate.py defaults to 120 seconds. A whole procedure through a reasoning
# model takes longer than that, and the timeout surfaces as a HELD document
# rather than an obvious error — so give it room.
export LLM_TIMEOUT="${LLM_TIMEOUT:-900}"

# --- provenance (R1b §8) ---------------------------------------------------
# Recorded in the generated document's front matter.
#
# REVIEWED_BY and REVIEW_DATE are deliberately NOT set here. They name the
# person who has read and signed off the English rendering, and a local test run
# is not a review. Leaving them empty keeps the provenance block honest.
export PROMPT_VERSION="${PROMPT_VERSION:-1.0}"

# --- the API key -----------------------------------------------------------
# You do NOT need one for a ":cloud" model through a local Ollama. `ollama
# signin` stores the ollama.com credential on this machine, Ollama proxies the
# call, and the OpenAI-compatible endpoint on 11434 wants no Authorization
# header. Verified against this workstation — a chat completion for
# deepseek-v4.1-flash:cloud succeeded with no key present.
#
# translate.py omits the header entirely when the key is empty, so leave it
# unset. Set one only if you point LLM_ENDPOINT at a service that authenticates
# directly (for example https://ollama.com/v1).
#
# Put any secret in scripts/llm-env.local — git-excluded, never committed:
#     LLM_API_KEY=...
_llm_env_local="$(dirname "${BASH_SOURCE[0]}")/llm-env.local"
if [ -f "$_llm_env_local" ]; then
  set -a; . "$_llm_env_local"; set +a
  echo "loaded overrides from scripts/llm-env.local"
fi
unset _llm_env_local

echo "LLM_ENDPOINT   = $LLM_ENDPOINT"
echo "LLM_MODEL      = $LLM_MODEL"
echo "LLM_TIMEOUT    = $LLM_TIMEOUT"
echo "PROMPT_VERSION = $PROMPT_VERSION"
if [ -n "${LLM_API_KEY:-}" ]; then
  echo "LLM_API_KEY    = (set, ${#LLM_API_KEY} chars)"
else
  echo "LLM_API_KEY    = (unset — correct for a local Ollama)"
fi
