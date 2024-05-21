const ROOT_PATH = ('.' | path expand)

# Load Rime user dir configuration from local file.
export-env {
  load-env (
    open -r './rime_user_dir' | str trim
    | {
      RIME_USER_DIR: ($in | path expand)
    }
  )
}

export def main [] {
  # placeholder
}

alias core-move = move
# move to Rime user dir.
export def move [
  --no-backup (-n)
] {
  use std assert
  ensure-wd

  let files = glob '*.yaml' | path basename
  assert equal ($files | length) 2
  cd $env.RIME_USER_DIR
  $files | each {|file|
    if not $no_backup {
      try {
        mv -nv $file ($file + '.bak')
      } catch {
        match (input "backup file exists. Overwrite? (y/N) ") {
          'y' => {mv -vf $file ($file + '.bak')}
          _ => {error make {msg: "Aborted due to existing bak file"}}
        }
      }
    } else {
      cp -v ($ROOT_PATH | path join $file) .
    }
  } | ignore
}
export alias m = move
export alias mn = move --no-backup

export def rime-deploy [] {
  cd $env.RIME_USER_DIR
  ^rime_deployer --build
}
export alias d = rime-deploy

export def move-deploy [] {
  move --no-backup
  rime-deploy
}
export alias md = move-deploy

def --env ensure-wd [] {
  cd $ROOT_PATH
}
