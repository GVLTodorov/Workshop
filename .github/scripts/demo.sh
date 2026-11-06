# Helpers for the `demos` job in retroboard.yml and planningpoker.yml. Source this from the project
# folder with APP_DLL and APP_URL set. Each demo commits its own result as soon as it's done, so a
# failure in a later demo doesn't lose an earlier one.

# `| tee` alone would hide a crash: a pipe's exit status is otherwise its last command's (tee, which
# always succeeds).
set -o pipefail

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

start_app() {
  # --contentRoot must be given because it otherwise defaults to the working directory, where
  # wwwroot doesn't exist. It must be absolute: a relative value is resolved against the DLL's own
  # folder and silently doubles the path (publish/api/publish/api).
  ASPNETCORE_URLS="$APP_URL" dotnet "publish/api/$APP_DLL" --contentRoot "$PWD/publish/api" > api.log 2>&1 &
  echo $! > api.pid
  trap stop_app EXIT
  timeout 30 bash -c "until curl -sf $APP_URL/healthz >/dev/null; do sleep 1; done"
}

# Waits for the process to exit so that the next demo's app can bind the same port.
stop_app() {
  echo "--- app server log"
  cat api.log || true
  kill "$(cat api.pid)" || true
  wait "$(cat api.pid)" 2>/dev/null || true
}

# Usage: record_gif <demo tool project> <output gif>
#
# GitHub's README sanitizer strips <video> tags, so a GIF is what actually embeds. stats_mode=diff
# and dither=none avoid dithering noise on flat UI colors, since this is screen content rather than
# photographic video.
record_gif() {
  local dir="artifacts/$1" webm
  mkdir -p "$dir"
  dotnet run --project "src/$1" -c Release --no-build -- "$APP_URL" "$dir" | tee "$dir.log"
  webm="$(grep -oP '(?<=^VIDEO_PATH=).+' "$dir.log")"
  ffmpeg -y -i "$webm" \
    -vf "fps=14,scale=1100:-1:flags=lanczos,split[s0][s1];[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=none" \
    "$2"
}

# Usage: commit_and_push <message> <file>
#
# `main` may have moved since checkout, for example from the other project's pipeline. Rebasing is
# safe because each demo only ever commits its own generated file.
commit_and_push() {
  git add "$2"
  if git diff --cached --quiet; then
    echo "$2 unchanged, nothing to commit."
    return 0
  fi
  git commit -m "$1"
  for attempt in 1 2 3 4 5; do
    git pull --rebase --autostash origin main && git push && return 0
    sleep $((attempt * 5))
  done
  echo "Could not push $2 after 5 attempts." >&2
  return 1
}
